-- ================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_SET_MCW
--
-- Description:	Check to see if a diagnosis currently exists by name
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/28/2018 Initial release.
-- Ricky Moss		02/10/2019 Checks to see when updating a case classification that the name 
--							   does not exists in another reference and updates English value
-- Ricky Moss		03/13/2020 Refactor to check duplicates and resolution for Bug 6254
-- Ricky Moss		03/17/2020 Refactor to check duplicates and resolution for Bug 6254
-- Ricky Moss		03/19/2020 Resolved does and resolution for Bug 6254
-- Ricky Moss		03/20/2020 Refactored stored procedure to make no changes if disease currently 
--							   exists
-- Ricky Moss		06/05/2020 Reactivation of inactive record if a disease is being created with 
--							   an existing name
-- Ricky Moss		06/11/2020 Added Using Types to check for duplicates
-- Doug Albanese	04/12/2021 Refactored to use two branches and incorporate 
--							   USSP_GBL_Basereference_Set
-- Doug Albanese	04/14/2021 Corrected a Begin/Commit Transaction block problem.
-- Doug Albanese	04/14/2021 Added Penside Tests, Lab Tests, and Sample Type save routines
-- Stephen Long     05/30/2021 Added default permissions for new disease; business rule described 
--							   in use case SAUC62.
-- Doug Albanese	08/02/2021 Added duplication detection
-- Doug Albanese	08/03/2021 Modified duplication detection to handle the existence of 
--                             previously deleted items
-- Mark Wilson		08/03/2021 Modified to call USP_GBL_BaseReference_SET and to include Using 
--                             Type in duplicate checks
-- Doug Albanese	10/25/2021 Changes discussed with Mark Wilson to eliminate a duplication issue 
--                             found on a join
-- Stephen Long     07/18/2022 Added site alert logic.
-- Leo Tracchia		02/20/2023 Added data audit logic for inserts and updates	
-- Leo Tracchia		03/14/2023 Added additional logic for data audit on strDefault, strName, intHACode, and blnSyndrome
-- Leo Tracchia		04/12/2023 Added additional parameters for data audit on the call to [USSP_DISEASETOLABTEST_SET] 
--
-- exec USP_REF_DIAGNOSISREFERENCE_SET null, 'Blackerleg', 'Darkbrownleg', null, null, 2, 10020002, null, null, null, 0, 0, 'en-US', 0
-- exec USP_REF_DIAGNOSISREFERENCE_SET 58218970000129, 'Canine Distemper 4', 'Canine Distemper 4', 'CD09.5', null, 32, 10020002, null, '58218970000050', '9844470000000,9844480000000,9844490000000,58218970000051', 0, 0, 'en-US', 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_DIAGNOSISREFERENCE_SET]
(
    @idfsDiagnosis BIGINT = NULL,
    @strDefault VARCHAR(200),
    @strName NVARCHAR(200),
    @strOIECode NVARCHAR(200),
    @strIDC10 NVARCHAR(200),
    @intHACode INT,
    @idfsUsingType BIGINT,
    @strPensideTest NVARCHAR(MAX),
    @strLabTest NVARCHAR(MAX),
    @strSampleType NVARCHAR(MAX),
    @blnZoonotic BIT = 0,
    @blnSyndrome BIT = 0,
    @LangId NVARCHAR(50),
    @intOrder INT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    DECLARE @ReturnCode INT
        = 0,
            @ReturnMessage NVARCHAR(max) = 'SUCCESS',
            @existingDefault BIGINT,
            @existingName BIGINT,
            @idfTestForDisease BIGINT,
            @idfsTestName BIGINT,
            @idfPensideTestForDisease BIGINT,
            @idfsPensideTestName BIGINT,
            @idfMaterialForDisease BIGINT,
            @idfsSampleType BIGINT,
            @DuplicateDefault INT = 0, -- updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.
            @bNewRecord BIT = 0;
    DECLARE @tempPensideTestToDisease TABLE (idfsPensideTestName BIGINT);
    DECLARE @tempTestToDisease TABLE (idfsTestName BIGINT);
    DECLARE @tempSampleTypeToDisease TABLE (idfsSampleType BIGINT);

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

	--Data Audit--

		--DECLARE @idfUserId BIGINT = NULL;
		--DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017018; 
		DECLARE @idfObject bigint = @idfsDiagnosis;
		DECLARE @idfObjectTable_trtDiagnosis bigint = 75840000000;		
		DECLARE @idfDataAuditEvent bigint = NULL;		

		DECLARE @trtDiagnosis_BeforeEdit TABLE
		(
			strDefault nvarchar(2000),
			strName nvarchar(2000),
			intHACode int,
			idfsDiagnosis bigint,
			idfsUsingType bigint,
            strIDC10 nvarchar(200),
            strOIECode nvarchar(200),
            blnZoonotic bit,
            blnSyndrome bit,
            AuditUpdateDTM datetime,
            AuditUpdateUser nvarchar(200)            
		)

		DECLARE @trtDiagnosis_AfterEdit TABLE
		(
			strDefault nvarchar(2000),
			strName nvarchar(2000),
			intHACode int,
			idfsDiagnosis bigint,
			idfsUsingType bigint,
            strIDC10 nvarchar(200),
            strOIECode nvarchar(200),
            blnZoonotic bit,
            blnSyndrome bit,
            AuditUpdateDTM datetime,
            AuditUpdateUser nvarchar(200)            
		)

		-- Get and Set UserId and SiteId
		--SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo

	--Data Audit--

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @idfsDiagnosis IS NULL
			BEGIN -- this is an insert.  check if the strDefault is a duplicate -- MCW added check for Using type
				IF EXISTS
				(
					SELECT R.*
					FROM dbo.trtBaseReference R
						INNER JOIN dbo.trtDiagnosis D
							ON D.idfsDiagnosis = R.idfsBaseReference
							   AND D.idfsUsingType = @idfsUsingType
					WHERE R.strDefault = @strDefault
						  AND R.idfsReferenceType = 19000019
						  AND R.intRowStatus = 0
				)
				BEGIN
					SET @DuplicateDefault = 1;
				END
			END
        ELSE
			BEGIN -- this is an update.  check if the strDefault is a duplicate
				IF EXISTS
				(
					SELECT R.idfsBaseReference,
						   D.idfsUsingType
					FROM dbo.trtBaseReference R
						INNER JOIN dbo.trtDiagnosis D
							ON D.idfsDiagnosis = R.idfsBaseReference
							   AND D.intRowStatus = 0
							   AND D.idfsUsingType = @idfsUsingType
					WHERE R.strDefault = @strDefault
						  AND R.idfsReferenceType = 19000019
						  AND R.intRowStatus = 0
						  AND R.idfsBaseReference <> @idfsDiagnosis
				)
				BEGIN
					SET @DuplicateDefault = 1;
				END
			END

        IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate
			BEGIN
				SET @ReturnMessage = 'DOES EXIST';
				SET @idfsDiagnosis = NULL;
			END
        ELSE -- there is no duplicate, so continue
        BEGIN            

            IF EXISTS
            (
                SELECT *
                FROM dbo.trtDiagnosis
                WHERE idfsDiagnosis = @idfsDiagnosis
            )
            BEGIN
				--DataAudit-- 
				
					--  tauDataAuditEvent  Event Type - Edit 
					set @idfsDataAuditEventType = 10016003;
			
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtDiagnosis, @idfDataAuditEvent OUTPUT

				--DataAudit-- 

				INSERT INTO @trtDiagnosis_BeforeEdit (
					strDefault,
					strName,
					intHACode,
					idfsDiagnosis,
					idfsUsingType, 
					strIDC10, 
					strOIECode, 
					blnZoonotic, 
					blnSyndrome)
				SELECT 
					bf.strDefault,
					nt.strTextString,
					bf.intHACode,
					d.idfsDiagnosis,
					d.idfsUsingType, 
					d.strIDC10, 
					d.strOIECode, 
					d.blnZoonotic, 
					d.blnSyndrome									
					FROM trtDiagnosis d
					LEFT JOIN trtBaseReference bf on d.idfsDiagnosis = bf.idfsBaseReference
					LEFT JOIN trtStringNameTranslation nt on d.idfsDiagnosis = nt.idfsBaseReference
					WHERE idfsDiagnosis = @idfsDiagnosis;

				EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsDiagnosis OUTPUT,
					@ReferenceType = 19000019,
					@LangID = @LangID,
					@DefaultName = @strDefault,
					@NationalName = @strName,
					@HACode = @intHACode,
					@Order = @intOrder,
					@System = 0,
					@User = @AuditUserName;

                UPDATE dbo.trtDiagnosis
                SET idfsUsingType = @idfsUsingType,
                    strIDC10 = @strIDC10,
                    strOIECode = @strOIECode,
                    blnZoonotic = ISNULL(@blnZoonotic, 0),
                    blnSyndrome = ISNULL(@blnSyndrome, 0),
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsDiagnosis = @idfsDiagnosis;

				INSERT INTO @trtDiagnosis_AfterEdit (
					strDefault,
					strName,
					intHACode,
					idfsDiagnosis,
					idfsUsingType, 
					strIDC10, 
					strOIECode, 
					blnZoonotic, 
					blnSyndrome)
				SELECT 
					bf.strDefault,
					nt.strTextString,
					bf.intHACode,
					d.idfsDiagnosis,
					d.idfsUsingType, 
					d.strIDC10, 
					d.strOIECode, 
					d.blnZoonotic, 
					d.blnSyndrome									
					FROM trtDiagnosis d
					LEFT JOIN trtBaseReference bf on d.idfsDiagnosis = bf.idfsBaseReference
					LEFT JOIN trtStringNameTranslation nt on d.idfsDiagnosis = nt.idfsBaseReference
					WHERE idfsDiagnosis = @idfsDiagnosis;

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
					@idfObjectTable_trtDiagnosis, 
					81120000000,
					a.idfsDiagnosis,
					null,
					a.strDefault,
					b.strDefault 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
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
					@idfObjectTable_trtDiagnosis, 
					81390000000,
					a.idfsDiagnosis,
					null,
					a.strName,
					b.strName 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.strName <> b.strName) 
					or(a.strName is not null and b.strName is null)
					or(a.strName is null and b.strName is not null)

				--intHACode "Accessory Code"
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
					@idfObjectTable_trtDiagnosis, 
					81090000000,
					a.idfsDiagnosis,
					null,
					a.intHACode,
					b.intHACode 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.intHACode <> b.intHACode) 
					or(a.intHACode is not null and b.intHACode is null)
					or(a.intHACode is null and b.intHACode is not null)

				--idfsUsingType
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
					@idfObjectTable_trtDiagnosis, 
					4578050000000,
					a.idfsDiagnosis,
					null,
					a.idfsUsingType,
					b.idfsUsingType 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.idfsUsingType <> b.idfsUsingType) 
					or(a.idfsUsingType is not null and b.idfsUsingType is null)
					or(a.idfsUsingType is null and b.idfsUsingType is not null)

				--strIDC10
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
					@idfObjectTable_trtDiagnosis, 
					81160000000,
					a.idfsDiagnosis,
					null,
					a.strIDC10,
					b.strIDC10 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.strIDC10 <> b.strIDC10) 
					or(a.strIDC10 is not null and b.strIDC10 is null)
					or(a.strIDC10 is null and b.strIDC10 is not null)

				--strOIECode
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
					@idfObjectTable_trtDiagnosis, 
					81170000000,
					a.idfsDiagnosis,
					null,
					a.strOIECode,
					b.strOIECode 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.strOIECode <> b.strOIECode) 
					or(a.strOIECode is not null and b.strOIECode is null)
					or(a.strOIECode is null and b.strOIECode is not null)
					
				--blnZoonotic
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
					@idfObjectTable_trtDiagnosis, 
					51389460000000,					
					a.idfsDiagnosis,
					null,
					a.blnZoonotic,
					b.blnZoonotic 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.blnZoonotic <> b.blnZoonotic) 
					or(a.blnZoonotic is not null and b.blnZoonotic is null)
					or(a.blnZoonotic is null and b.blnZoonotic is not null)

				--blnSyndrome
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
					@idfObjectTable_trtDiagnosis, 
					51586990000118,
					a.idfsDiagnosis,
					null,
					a.blnSyndrome,
					b.blnSyndrome 
				from @trtDiagnosis_BeforeEdit a  inner join @trtDiagnosis_AfterEdit b on a.idfsDiagnosis = b.idfsDiagnosis
				where (a.blnSyndrome <> b.blnSyndrome) 
					or(a.blnSyndrome is not null and b.blnSyndrome is null)
					or(a.blnSyndrome is null and b.blnSyndrome is not null)

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsDiagnosis,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END
            ELSE
            BEGIN

				EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsDiagnosis OUTPUT,
					@ReferenceType = 19000019,
					@LangID = @LangID,
					@DefaultName = @strDefault,
					@NationalName = @strName,
					@HACode = @intHACode,
					@Order = @intOrder,
					@System = 0,
					@User = @AuditUserName;

				--Data Audit--

					-- tauDataAuditEvent Event Type - Create 
					set @idfsDataAuditEventType = 10016001;
			
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @UserId, @SiteId, @idfsDataAuditEventType, @idfsObjectType, @idfsDiagnosis, @idfObjectTable_trtDiagnosis, @idfDataAuditEvent OUTPUT

				--Data Audit--

                INSERT INTO dbo.trtDiagnosis
                (
                    idfsDiagnosis,
                    idfsUsingType,
                    strIDC10,
                    strOIECode,
                    intRowStatus,
                    rowguid,
                    blnZoonotic,
                    strMaintenanceFlag,
                    strReservedAttribute,
                    blnSyndrome,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES(
					@idfsDiagnosis,
					@idfsUsingType,
					@strIDC10,
					@strOIECode,
					0  ,
					NEWID(),
					ISNULL(@blnZoonotic, 0),
					'ADD',
					'EIDSS7 Disease',
					ISNULL(@blnSyndrome, 0),
					10519001,
					N'[{"idfsDiagnosis":' + CAST(@idfsDiagnosis AS NVARCHAR(300)) + '}]',
					@AuditUserName,
					GETDATE()
				);

				--Data Audit--							

					INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					VALUES (@idfDataAuditEvent, @idfObjectTable_trtDiagnosis, @idfsDiagnosis)
			
				--Data Audit--

                -- Add read permission allow to the default employee group.
                DECLARE @ObjectAccessID BIGINT;
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tstObjectAccess',
                                                  @ObjectAccessID OUTPUT;

                INSERT INTO dbo.tstObjectAccess
                (
                    idfObjectAccess,
                    idfsObjectOperation,
                    idfsObjectType,
                    idfsObjectID,
                    idfActor,
                    idfsOnSite,
                    intPermission,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue
                )
                VALUES
                (   @ObjectAccessID,
                    10059003, -- Read permission
                    10060001, -- Disease record
                    @idfsDiagnosis,
                    -506,     -- Default employee group
                    1,        -- First level site
                    2,        -- Allow permission
                    0,
                    10519001,
                    N'[{"idfObjectAccess":' + CAST(@ObjectAccessID AS NVARCHAR(300)) + '}]'
                );

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                               @EventTypeId,
                                               @UserId,
                                               @idfsDiagnosis,
                                               NULL,
                                               @SiteId,
                                               NULL,
                                               @SiteId,
                                               @LocationId,
                                               @AuditUserName;
            END

            --Common actions
             EXEC dbo.USSP_DISEASETOLABTEST_SET @idfsDiagnosis, @strLabTest, @SiteId, @UserId, @idfDataAuditEvent;

            EXEC dbo.USSP_DISEASETOPENSIDETEST_SET @idfsDiagnosis, @strPensideTest, @SiteId, @UserId, @idfDataAuditEvent;

            EXEC dbo.USSP_DISEASETOSAMPLETYPE_SET @idfsDiagnosis, @strSampleType, @SiteId, @UserId, @idfDataAuditEvent;
        END
        COMMIT TRANSACTION;

        SELECT @ReturnMessage AS 'ReturnMessage',
               @ReturnCode AS 'ReturnCode',
               @idfsDiagnosis AS 'idfsDiagnosis';
    END TRY
    BEGIN CATCH
        --Rollback the transaction
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK
        END;

        THROW;
    END CATCH
END
