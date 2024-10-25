-- ================================================================================================
-- Name: USP_REF_STATISTICDATATYPE_SET
--
-- Description:	Creates or updates a statistical data type.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss       09/28/2018 Initial release.
-- Ricky Moss		12/13/2018 Removed the return code and reference id variables
-- Ricky Moss		12/20/2018 Merged SET AND DOESEXIST stored procedures
-- Ricky Moss		02/11/2019 Checks to see when updating a statistical data type that the name 
--                             does not exists in another reference
-- Ricky Moss		09/20/2019 Refactored duplication check code
-- Ricky Moss		02/17/2020 Refactored to check for duplicates and translated values and update
-- Ricky Moss		03/18/2020 corrected update portion
-- Ricky Moss		03/20/2020 corrected table name
-- Ricky Moss		04/16/2020 reactivated inactive record if being readded
-- Doug Albanese	04/12/2020 Refactored to make use of USSP_GBL_BaseReference_SET, and to change 
--                             the branch decisions for insert/update.
-- Doug Albanese	07/31/2021 Added duplication fix
-- Doug Albanese	08/03/2021 Modified duplication detection to handle the existence of 
--                             previously deleted items
-- Doug Albanese	08/09/2021 Refactored against changes, provided by Mark Wilson, to complete 
--                             the work on this
-- Stephen Long     07/18/2022 Added site alert logic.
-- Leo Tracchia     02/27/2023 Added data auditing logic.
-- Leo Tracchia     03/10/2023 Added additional changes for data audit on strDefault and strName
/*

exec USP_REF_STATISTICDATATYPE_SET NULL, 'Mark Wilson Test Number 02468', 'Test Locally', 19000090, 10091005, 10089002, 1, 'en-US'

exec USP_REF_STATISTICDATATYPE_SET 39850000000, 'Population', 'Population', 19000090, 10091005, 10089001, 1, 'en'

exec USP_REF_STATISTICDATATYPE_SET 389445040003919, 'Change to something else new', 'Population', 19000090, 10091005, 10089001, 1, 'en-US'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_STATISTICDATATYPE_SET]
(
    @idfsStatisticDataType AS BIGINT = NULL,
    @strDefault AS NVARCHAR(200),
    @strName AS NVARCHAR(200),
    @idfsReferenceType AS BIGINT,
    @idfsStatisticPeriodType AS BIGINT,
    @idfsStatisticAreaType AS BIGINT = NULL,
    @blnRelatedWithAgeGroup AS BIT,
    @LangID AS NVARCHAR(50),
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN

    DECLARE @ReturnMessage NVARCHAR(MAX) = N'SUCCESS',
            @ReturnCode INT = 0,
            @DuplicateDefault INT = 0 -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    BEGIN TRY
        IF @idfsStatisticDataType IS NULL
			BEGIN -- this is an insert.  check if the strDefault is a duplicate
				IF EXISTS
				(
					SELECT *
					FROM dbo.trtBaseReference
					WHERE strDefault = @strDefault
						  AND idfsReferenceType = 19000090
						  AND trtBaseReference.intRowStatus = 0
				)
				BEGIN
					SET @DuplicateDefault = 1;
				END
			END
        ELSE
			BEGIN -- this is an update.  check if the strDefault is a duplicate
				IF EXISTS
				(
					SELECT *
					FROM dbo.trtBaseReference
					WHERE idfsBaseReference <> @idfsStatisticDataType
						  AND strDefault = @strDefault
						  AND idfsReferenceType = 19000090
						  AND trtBaseReference.intRowStatus = 0
				)
				BEGIN
					SET @DuplicateDefault = 1;
				END
			END

        IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate

			BEGIN
				SET @ReturnMessage = 'DOES EXIST';
			END

        ELSE -- there is no duplicate, so continue

			BEGIN

			--Begin: Data Audit Declarations--

			DECLARE @idfUserId BIGINT = @UserId;
			DECLARE @idfSiteId BIGINT = @SiteId;
			DECLARE @idfsDataAuditEventType bigint = NULL;
			DECLARE @idfsObjectType bigint = 10017050; --select * from trtBaseReference where idfsReferenceType = 19000017 and strdefault like '%stat%'
			DECLARE @idfObject bigint = @idfsStatisticDataType;
			DECLARE @idfObjectTable_trtBaseReference bigint = 75820000000;
			DECLARE @idfObjectTable_trtStringNameTranslation bigint = 75990000000;
			DECLARE @idfObjectTable_trtStatisticDataType bigint = 75980000000;		
			DECLARE @idfDataAuditEvent bigint = NULL;		

			DECLARE @trtStatisticDataType_BeforeEdit TABLE
			(
				strDefault nvarchar(2000),
				strName nvarchar(2000),
				idfsStatisticDataType bigint,
				idfsReferenceType bigint,
				idfsStatisticAreaType bigint,
				idfsStatisticPeriodType bigint,									
				blnRelatedWithAgeGroup bit					
			)

			DECLARE @trtStatisticDataType_AfterEdit TABLE
			(
				strDefault nvarchar(2000),
				strName nvarchar(2000),
				idfsStatisticDataType bigint,
				idfsReferenceType bigint,
				idfsStatisticAreaType bigint,
				idfsStatisticPeriodType bigint,									
				blnRelatedWithAgeGroup bit	
			)				

			--End: Data Audit--			


				IF NOT EXISTS
				(
					SELECT *
					FROM dbo.trtStatisticDataType
					WHERE idfsStatisticDataType = @idfsStatisticDataType
				)
				BEGIN

					INSERT INTO @SuppressSelect
					EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsStatisticDataType OUTPUT,
						@ReferenceType = 19000090,
						@LangID = @LangID,
						@DefaultName = @strDefault,
						@NationalName = @strName,
						@HACode = NULL,
						@Order = NULL,
						@System = 0,
						@User = @AuditUserName;

					--Begin: Data Audit for INSERT--

					-- tauDataAuditEvent Event Type - Create 
					SET @idfsDataAuditEventType = 10016001;
			
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfsStatisticDataType, @idfObjectTable_trtStatisticDataType, @idfDataAuditEvent OUTPUT

					--End: Data Audit for INSERT--

					INSERT INTO dbo.trtStatisticDataType
					(
						idfsStatisticDataType,
						idfsReferenceType,
						idfsStatisticAreaType,
						idfsStatisticPeriodType,
						intRowStatus,
						rowguid,
						blnRelatedWithAgeGroup,
						strMaintenanceFlag,
						strReservedAttribute,
						SourceSystemNameID,
						SourceSystemKeyValue,
						AuditCreateDTM,
						AuditCreateUser
					)
					VALUES
					(@idfsStatisticDataType,
					 @idfsReferenceType,
					 @idfsStatisticAreaType,
					 @idfsStatisticPeriodType,
					 0  ,
					 NEWID(),
					 @blnRelatedWithAgeGroup,
					 NULL,
					 NULL,
					 10519001,
					 '[{"idfsBaseReference":' + CAST(@idfsStatisticDataType AS NVARCHAR(300)) + '}]',
					 GETDATE(),
					 @AuditUserName
					);

					--Begin: Data Audit for INSERT--					

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					VALUES (@idfDataAuditEvent, @idfObjectTable_trtStatisticDataType, @idfsStatisticDataType)
			
					--End: Data Audit for INSERT--

				END
            ELSE
				BEGIN

					--Begin: Data Audit for UPDATE--
				
					--  tauDataAuditEvent  Event Type - Edit 
					set @idfsDataAuditEventType = 10016003;
			
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfsStatisticDataType, @idfObjectTable_trtStatisticDataType, @idfDataAuditEvent OUTPUT

					INSERT INTO @trtStatisticDataType_BeforeEdit (
						strDefault,
						strName,
						idfsStatisticDataType,
						idfsReferenceType,
						idfsStatisticAreaType,
						idfsStatisticPeriodType,									
						blnRelatedWithAgeGroup)
					SELECT 
						bf.strDefault,
						nt.strTextString,
						sdt.idfsStatisticDataType,
						sdt.idfsReferenceType,
						sdt.idfsStatisticAreaType,
						sdt.idfsStatisticPeriodType,									
						sdt.blnRelatedWithAgeGroup
					FROM trtStatisticDataType sdt
					LEFT JOIN trtBaseReference bf on sdt.idfsStatisticDataType = bf.idfsBaseReference
					LEFT JOIN trtStringNameTranslation nt on sdt.idfsStatisticDataType = nt.idfsBaseReference
					WHERE idfsStatisticDataType = @idfsStatisticDataType;

					--End: Data Audit for UPDATE--
					
					INSERT INTO @SuppressSelect
					EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsStatisticDataType OUTPUT,
						@ReferenceType = 19000090,
						@LangID = @LangID,
						@DefaultName = @strDefault,
						@NationalName = @strName,
						@HACode = NULL,
						@Order = NULL,
						@System = 0,
						@User = @AuditUserName;

					UPDATE dbo.trtStatisticDataType
					SET idfsReferenceType = @idfsReferenceType,
						idfsStatisticAreaType = @idfsStatisticAreaType,
						idfsStatisticPeriodType = @idfsStatisticPeriodType,
						blnRelatedWithAgeGroup = @blnRelatedWithAgeGroup,
						intRowStatus = 0,
						rowguid = ISNULL(rowguid, NEWID()),
						AuditUpdateDTM = GETDATE(),
						AuditUpdateUser = @AuditUserName
					WHERE idfsStatisticDataType = @idfsStatisticDataType;

					--Begin: Data Audit for UPDATE--

					INSERT INTO @trtStatisticDataType_AfterEdit (
						strDefault,
						strName,
						idfsStatisticDataType,
						idfsReferenceType,
						idfsStatisticAreaType,
						idfsStatisticPeriodType,									
						blnRelatedWithAgeGroup)
					SELECT 
						bf.strDefault,
						nt.strTextString,
						sdt.idfsStatisticDataType,
						sdt.idfsReferenceType,
						sdt.idfsStatisticAreaType,
						sdt.idfsStatisticPeriodType,									
						sdt.blnRelatedWithAgeGroup
					FROM trtStatisticDataType sdt
					LEFT JOIN trtBaseReference bf on sdt.idfsStatisticDataType = bf.idfsBaseReference
					LEFT JOIN trtStringNameTranslation nt on sdt.idfsStatisticDataType = nt.idfsBaseReference
					WHERE idfsStatisticDataType = @idfsStatisticDataType;

					--strDefault
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_trtBaseReference, 
						81120000000,
						a.idfsStatisticDataType,
						null,
						a.strDefault,
						b.strDefault 
					from @trtStatisticDataType_BeforeEdit a  inner join @trtStatisticDataType_AfterEdit b on a.idfsStatisticDataType = b.idfsStatisticDataType
					where (a.strDefault <> b.strDefault) 
						or(a.strDefault is not null and b.strDefault is null)
						or(a.strDefault is null and b.strDefault is not null)

					--strName (strTextString, aka "National Value" aka "Translated Value")
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_trtStringNameTranslation, 
						81390000000,
						a.idfsStatisticDataType,
						null,
						a.strName,
						b.strName 
					from @trtStatisticDataType_BeforeEdit a  inner join @trtStatisticDataType_AfterEdit b on a.idfsStatisticDataType = b.idfsStatisticDataType
					where (a.strName <> b.strName) 
						or(a.strName is not null and b.strName is null)
						or(a.strName is null and b.strName is not null)

					--idfsReferenceType
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_trtStatisticDataType, 
						81350000000,
						a.idfsStatisticDataType,
						null,
						a.idfsReferenceType,
						b.idfsReferenceType 
					from @trtStatisticDataType_BeforeEdit a  inner join @trtStatisticDataType_AfterEdit b on a.idfsStatisticDataType = b.idfsStatisticDataType
					where (a.idfsReferenceType <> b.idfsReferenceType) 
						or(a.idfsReferenceType is not null and b.idfsReferenceType is null)
						or(a.idfsReferenceType is null and b.idfsReferenceType is not null)

					--idfsStatisticAreaType
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_trtStatisticDataType, 
						4578150000000,
						a.idfsStatisticDataType,
						null,
						a.idfsStatisticAreaType,
						b.idfsStatisticAreaType 
					from @trtStatisticDataType_BeforeEdit a  inner join @trtStatisticDataType_AfterEdit b on a.idfsStatisticDataType = b.idfsStatisticDataType
					where (a.idfsStatisticAreaType <> b.idfsStatisticAreaType) 
						or(a.idfsStatisticAreaType is not null and b.idfsStatisticAreaType is null)
						or(a.idfsStatisticAreaType is null and b.idfsStatisticAreaType is not null)

					--idfsStatisticPeriodType
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_trtStatisticDataType, 
						4578160000000,
						a.idfsStatisticDataType,
						null,
						a.idfsStatisticPeriodType,
						b.idfsStatisticPeriodType 
					from @trtStatisticDataType_BeforeEdit a  inner join @trtStatisticDataType_AfterEdit b on a.idfsStatisticDataType = b.idfsStatisticDataType
					where (a.idfsStatisticPeriodType <> b.idfsStatisticPeriodType) 
						or(a.idfsStatisticPeriodType is not null and b.idfsStatisticPeriodType is null)
						or(a.idfsStatisticPeriodType is null and b.idfsStatisticPeriodType is not null)

					--blnRelatedWithAgeGroup
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_trtStatisticDataType, 
						12014490000000,
						a.idfsStatisticDataType,
						null,
						a.blnRelatedWithAgeGroup,
						b.blnRelatedWithAgeGroup 
					from @trtStatisticDataType_BeforeEdit a  inner join @trtStatisticDataType_AfterEdit b on a.idfsStatisticDataType = b.idfsStatisticDataType
					where (a.blnRelatedWithAgeGroup <> b.blnRelatedWithAgeGroup) 
						or(a.blnRelatedWithAgeGroup is not null and b.blnRelatedWithAgeGroup is null)
						or(a.blnRelatedWithAgeGroup is null and b.blnRelatedWithAgeGroup is not null)

					--End: Data Audit for UPDATE--
				END

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsStatisticDataType,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @idfsStatisticDataType AS idfsStatisticDataType;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

