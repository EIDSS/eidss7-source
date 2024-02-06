-- ================================================================================================
-- Name: USP_REF_SPECIESTYPE_SET
-- 
-- Description:	Adds or updates a species type reference
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss       10/02/2018 Initial release.
-- Ricky Moss		10/04/2018 Updated the update piece of the stored procedure
-- Ricky Moss		12/13/2018 Removed the return codes and reference id
-- Lamont Mitchell	01/02/2019 Aliased Columns in Final Output
-- Ricky Moss		01/02/2019 Replace fnGetLanguageCode with FN_GBL_LanguageCode_GET function
-- Ricky Moss		02/10/2019 Checks to see when updating a species type that the name does not 
--                             exists in another reference and updates English value
-- Ricky Moss		06/18/2019 Correct duplicate prevention issue and Reactivate inactive species 
--                             types if trying to re-add
-- Ricky Moss		07/22/2019 Refactoring to check for duplicates and added customization to base 
--                             reference
-- Ricky Moss		09/23/2019 Refactoring to check for duplicates and added customization to base 
--                             reference
-- Ricky Moss		02/18/2020 Refactoring to check for duplicates and added customization to base 
--                             reference
-- Doug Albanese	04/09/2021 Refactored to make use of USSP_GBL_BaseReference_SET, and to change 
--                             the branch decisions for insert/update.
-- Doug Albanese	04/09/2021 Added use of IntHACode and IntOrder to call for 
--                             USSP_GBL_BaseReference_SET
-- Doug Albanese	08/02/2021 Added duplication detection
-- Doug Albanese	08/03/2021 Modified duplication detection to handle the existence of previously 
--                             deleted items
-- Doug Albanese	08/09/2021 Refactored against changes, provided by Mark Wilson, to complete the 
--                             work on this
-- Doug Albanese	10/22/2021 intOrder was notbeing used by USP_GBL_BaseReference_SET
-- Stephen Long     07/18/2022 Added site alert logic.
-- Stephen Long     11/01/2022 Changed parameter name @idfsSpeciesType to @IdfsSpeciesType.
-- Ann Xiong		02/24/2023 Implemented Data Audit
-- Ann Xiong		02/27/2023 Called USSP_GBL_BASE_REFERENCE_SET instead of USP_GBL_BaseReference_SET to use its data auditing
-- Ann Xiong		03/06/2023 Updated idfMainObject on tauDataAuditEvent after INSERT INTO dbo.trtSpeciesType
--
-- exec USP_REF_SPECIESTYPE_SET null, 'Aardvark', 'Aardvark', '', 32, 1, 'en'
-- exec USP_REF_SPECIESTYPE_SET 837790000000, 'Buffalo', 'Buffalo', '', 32, 0, 'en'
-- exec USP_REF_SPECIESTYPE_SET 9719060001176, 'Other', 'Other', '', 98, 700, 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_SPECIESTYPE_SET]
(
    @IdfsSpeciesType BIGINT = NULL,
    @strDefault VARCHAR(200),
    @strName NVARCHAR(200),
    @strCode NVARCHAR(50),
    @intHACode INT,
    @intOrder INT,
    @LangID NVARCHAR(50),
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
            @existingDefault BIGINT,
            @existingName BIGINT,
            @DuplicateDefault INT = 0; -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

	--Data Audit--
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017009;                         -- Species
	declare @idfObject bigint = @IdfsSpeciesType;
	declare @idfObjectTable_trtSpeciesType bigint = 75960000000;
	declare @idfDataAuditEvent bigint= NULL;

	DECLARE @trtSpeciesType_BeforeEdit TABLE
	(
        		SpeciesTypeID BIGINT,
        		strCode varchar(200)
	);
	DECLARE @trtSpeciesType_AfterEdit TABLE
	(
        		SpeciesTypeID BIGINT,
        		strCode varchar(200)
	);

	--Data Audit--

    BEGIN TRY
        DECLARE @bNewRecord BIT = 0;

        IF @IdfsSpeciesType IS NULL
        BEGIN -- this is an insert.  check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000086
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
                WHERE idfsBaseReference <> @IdfsSpeciesType
                      AND strDefault = @strDefault
                      AND idfsReferenceType = 19000086
                      AND trtBaseReference.intRowStatus = 0
            )
            BEGIN
                SET @DuplicateDefault = 1;
            END
        END

        IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate
        BEGIN
            SET @ReturnMessage = 'DOES EXIST'
        END
        ELSE -- there is no duplicate, so continue
        BEGIN

            --INSERT INTO @SuppressSelect
            --EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @IdfsSpeciesType OUTPUT,
            --                                   @ReferenceType = 19000086,
            --                                   @LangID = @LangID,
            --                                   @DefaultName = @strDefault,
            --                                   @NationalName = @strName,
            --                                   @HACode = @intHACode,
            --                                   @Order = @intOrder,
            --                                   @System = 0, 
            --                                   @User = @AuditUserName;

            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.trtSpeciesType
                WHERE idfsSpeciesType = @IdfsSpeciesType
            )
            BEGIN
				--Data Audit--
				-- tauDataAuditEvent Event Type - Create 
				set @idfsDataAuditEventType =10016001;
				-- insert record into tauDataAuditEvent - 
				EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@IdfsSpeciesType, @idfObjectTable_trtSpeciesType, @idfDataAuditEvent OUTPUT
				--Data Audit--

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @IdfsSpeciesType OUTPUT,
                                                        19000086,
                                                        @LangID,
                                                        @strDefault,
                                                        @strName,
                                                        @intHACode,
                                                        @intOrder,
                                                        0,
                                                        @AuditUserName,
                                                        @idfDataAuditEvent,
                                                        NULL;

                INSERT INTO dbo.trtSpeciesType
                (
                    idfsSpeciesType,
                    strCode,
                    intRowStatus,
                    rowguid,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@IdfsSpeciesType,
                 @strCode,
                 0  ,
                 NEWID(),
                 NULL,
                 NULL,
                 10519002,
                 '[{"idfsSpeciesType":' + CAST(@IdfsSpeciesType AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE()
                );

				--Data Audit--
				-- Update idfMainObject on tauDataAuditEvent
				UPDATE dbo.tauDataAuditEvent
				SET idfMainObject = @IdfsSpeciesType
				WHERE idfDataAuditEvent = @idfDataAuditEvent;

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_trtSpeciesType, @IdfsSpeciesType)
				--Data Audit--

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @IdfsSpeciesType,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE
            BEGIN
                -- Data audit
                INSERT INTO @trtSpeciesType_BeforeEdit
                (
                        SpeciesTypeID,
                        strCode
                 )
                 SELECT 	idfsSpeciesType,
                    		strCode
                 FROM		dbo.trtSpeciesType
                 WHERE 		idfsSpeciesType = @IdfsSpeciesType;

			    --  tauDataAuditEvent  Event Type- Edit 
			    set @idfsDataAuditEventType =10016003;
			    -- insert record into tauDataAuditEvent - 
			    EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType,@idfsObjectType,@IdfsSpeciesType, @idfObjectTable_trtSpeciesType, @idfDataAuditEvent OUTPUT

                -- End data audit

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @IdfsSpeciesType OUTPUT,
                                                        19000086,
                                                        @LangID,
                                                        @strDefault,
                                                        @strName,
                                                        @intHACode,
                                                        @intOrder,
                                                        0,
                                                        @AuditUserName,
                                                        @idfDataAuditEvent,
                                                        NULL;

                UPDATE dbo.trtSpeciesType
                SET strCode = @strCode,
                    rowguid = ISNULL(rowguid, NEWID()),
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfsSpeciesType = @IdfsSpeciesType;

                -- Data audit
                INSERT INTO @trtSpeciesType_AfterEdit
                (
                        SpeciesTypeID,
                        strCode
                 )
                 SELECT 	idfsSpeciesType,
                    		strCode
                 FROM		dbo.trtSpeciesType
                 WHERE 		idfsSpeciesType = @IdfsSpeciesType;

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue
                )
                SELECT	@idfDataAuditEvent,
                           @idfObjectTable_trtSpeciesType,
                           4578140000000,
                           a.SpeciesTypeID,
                           NULL,
                           b.strCode,
                           a.strCode
                FROM @trtSpeciesType_AfterEdit AS a
                        FULL JOIN @trtSpeciesType_BeforeEdit AS b
                            ON a.SpeciesTypeID = b.SpeciesTypeID
                WHERE (a.strCode <> b.strCode)
                          OR (
                                 a.strCode IS NOT NULL
                                 AND b.strCode IS NULL
                             )
                          OR (
                                 a.strCode IS NULL
                                 AND b.strCode IS NOT NULL
                             );

                -- End data audit

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @IdfsSpeciesType,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
        END

        SELECT @ReturnMessage AS ReturnMessage,
               @ReturnCode AS ReturnCode,
               @IdfsSpeciesType AS IdfSpeciesType;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
