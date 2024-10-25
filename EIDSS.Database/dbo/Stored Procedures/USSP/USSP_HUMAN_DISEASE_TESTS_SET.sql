
-- Stored Procedure

-- ================================================================================================
-- Name: USSP_HUMAN_DISEASE_TESTS_SET
--
-- Description: Add/update and delete of human disease report field tests.
--          
-- Author: Jeff Johnson
--
-- Revision History:
--
--		Name		Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Jeff Johnson     07/03/2018 Initial release 
-- Harold Prior     11/09/2018 Updated to include USSP_GBL_TEST_VALIDATION_SET
-- Harold Prior     12/21/2018 Changed @Tests parameter to NVARCHAR
-- Lamont Mitchell  01/02/2019 Added @idfTesting to output in Select
-- Harold Prior     01/29/2019 Updated by Mark to fix Cannot insert the value NULL into column 
--                             'idfTesting', table 'EIDSS7_DT.dbo.tlbTestValidation' error
-- Harold Prior     01/30/2019 Removed call to USSP_GBL_TEST_VALIDATION_SET after Test Insert and 
--                             replaced with Test Validation Insert query in this stored proc
-- LJM				20200309	Removed calling [USSP_GBL_TEST_VALIDATION_SET] and included the logic inside of this SP
-- Stephen Long     03/11/2020 Changed non-laboratory test indicator (blnNonLaboratoryTest) to true 
--                             as these are tests that should not appear in the lab module.
--LJM				Modifed to include idfValidated and idfinterpretedBy
-- Mark Wilson		01/07/2021 changed INT to BIGINT for @idfTestValidationTemp
-- Testing code:
-- exec USSP_HUMAN_DISEASE_TESTS_SET null
-- ================================================================================================
CREATE   PROCEDURE [dbo].[USSP_HUMAN_DISEASE_TESTS_SET]
	@idfHumanCase BIGINT = NULL,
	@TestsParameters NVARCHAR(MAX) = NULL,
	@AuditUser		 NVARCHAR(100) = ''

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SupressSelect TABLE (
		returnCode INT,
		returnMessage VARCHAR(200)
		)
	DECLARE
		--@idfHumanCase	bigint,
		@idfMaterial BIGINT,
		@strBarcode NVARCHAR(200),
		@strFieldBarcode NVARCHAR(200),
		@idfsSampleType BIGINT,
		@strSampleTypeName NVARCHAR(2000),
		@datFieldCollectionDate DATETIME2,
		@idfSendToOffice BIGINT,
		@strSendToOffice NVARCHAR(2000),
		@idfFieldCollectedByOffice BIGINT,
		@strFieldCollectedByOffice NVARCHAR(2000),
		@datFieldSentDate DATETIME2,
		@idfsSampleKind BIGINT,
		@sampleKindTypeName NVARCHAR(2000),
		@idfsSampleStatus BIGINT,
		@sampleStatusTypeName NVARCHAR(2000),
		@idfFieldCollectedByPerson BIGINT,
		@datSampleStatusDate DATETIME2,
		@sampleGuid UNIQUEIDENTIFIER,
		@idfTesting BIGINT,
		@idfTestingNew BIGINT,
		@idfsTestName BIGINT,
		@idfsTestCategory BIGINT,
		@idfsTestResult BIGINT,
		@idfsTestStatus BIGINT,
		@idfsDiagnosis BIGINT,
		@strTestStatus NVARCHAR(2000),
		@name NVARCHAR(2000),
		@datReceivedDate DATETIME2,
		@datConcludedDate DATETIME2,
		@idfTestedByPerson BIGINT,
		@idfTestedByOffice BIGINT,
		@idfValidatedByOffice BIGINT,
		@idfValidatedByPerson BIGINT,
		@idfInterpretedByOffice BIGINT,
		@idfInterpretedByPerson BIGINT,
		@blnCaseCreated BIT,
		@idfsInterpretedStatus BIGINT,
		@strInterpretedComment NVARCHAR(2000),
		@datInterpretedDate DATETIME2,
		@strInterpretedBy NVARCHAR(2000),
		@blnValidateStatus BIT,
		@strValidateComment NVARCHAR(2000),
		@datValidationDate DATETIME2,
		@strValidatedBy NVARCHAR(2000),
		@strAccountName NVARCHAR(2000),
		@testGuid UNIQUEIDENTIFIER,
		@intRowStatus INT,
		@idfTestValidation BIGINT = NULL,
		@RowAction NVARCHAR(1)
	DECLARE @returnCode INT = 0;
	DECLARE @idfTestValidationTemp BIGINT = NULL
	DECLARE @idfPersonTemp BIGINT = NULL
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @TestsTemp AS TABLE (
           [idfHumanCase] [BIGINT],
            [idfMaterial] [bigint],
            [strBarcode] [nvarchar](200),
            [strFieldBarcode] [nvarchar](200),
            [idfsSampleType] [bigint],
            [strSampleTypeName] [nvarchar](2000),
            [datFieldCollectionDate] [datetime2],
            [idfSendToOffice] [bigint],
            [strSendToOffice] [nvarchar](2000),
            [idfFieldCollectedByOffice] [bigint],
            [strFieldCollectedByOffice] [nvarchar](2000),
            [datFieldSentDate] [datetime2],
            [idfsSampleKind] [bigint],
            [SampleKindTypeName] [nvarchar](2000),
            [idfsSampleStatus] [bigint],
            [SampleStatusTypeName] [nvarchar](2000),
            [idfFieldCollectedByPerson] [bigint],
            [datSampleStatusDate] [datetime2],
--            [sampleGuid] [uniqueidentifier],
            [idfTesting] [bigint],
            [idfsTestName] [bigint],
            [idfsTestCategory] [bigint],
			[strTestCategory] NVARCHAR(2000),
            [idfsTestResult] [bigint],
            [idfsTestStatus] [bigint],
            [idfsDiagnosis] [bigint],
			[strDiagnosis] NVARCHAR(2000),
            [strTestStatus] [nvarchar](2000),
			[strTestResult] NVARCHAR(2000),
            [name] [nvarchar](2000),
            [datReceivedDate] [datetime2],
            [datConcludedDate] [datetime2],
            [idfTestedByPerson] [bigint],
            [idfTestedByOffice] [bigint],
            [datInterpretedDate] [datetime2],
            [idfsInterpretedStatus] [bigint],
            [strInterpretedComment] [nvarchar](2000),
            [strInterpretedBy] [nvarchar](2000),
            [strInterpretedStatus] [nvarchar](2000),
            [datValidationDate] [datetime2],
            [blnValidateStatus] [bit],
            [strValidateComment] [nvarchar](2000),
            [strValidatedBy] [nvarchar](2000),
            [strAccountName] [nvarchar](2000),
--			[testGuid] NVARCHAR(MAX),
            [intRowStatus] [int],
			[strTestedByPerson] NVARCHAR(2000),
			[strTestedByOffice] NVARCHAR(2000),
			[blnNonLaboratoryTest] BIT,
            [idfValidatedByPerson] [bigint],
            [idfInterpretedByPerson] [BIGINT],
            [filterTestByDisease] BIT,
			[idfsYNTestsConducted] BIGINT,
			[RowAction] [nvarchar](1)
		)

	INSERT INTO @TestsTemp
	SELECT *
	FROM OPENJSON(@TestsParameters) WITH (
           [idfHumanCase] [BIGINT],
            [idfMaterial] [bigint],
            [strBarcode] [nvarchar](200),
            [strFieldBarcode] [nvarchar](200),
            [idfsSampleType] [bigint],
            [strSampleTypeName] [nvarchar](2000),
            [datFieldCollectionDate] [datetime2],
            [idfSendToOffice] [bigint],
            [strSendToOffice] [nvarchar](2000),
            [idfFieldCollectedByOffice] [bigint],
            [strFieldCollectedByOffice] [nvarchar](2000),
            [datFieldSentDate] [datetime2],
            [idfsSampleKind] [bigint],
            [SampleKindTypeName] [nvarchar](2000),
            [idfsSampleStatus] [bigint],
            [SampleStatusTypeName] [nvarchar](2000),
            [idfFieldCollectedByPerson] [bigint],
            [datSampleStatusDate] [datetime2],
--            [sampleGuid] [uniqueidentifier],
            [idfTesting] [bigint],
            [idfsTestName] [bigint],
            [idfsTestCategory] [bigint],
			[strTestCategory] NVARCHAR(2000),
            [idfsTestResult] [bigint],
            [idfsTestStatus] [bigint],
            [idfsDiagnosis] [bigint],
			[strDiagnosis] NVARCHAR(2000),
            [strTestStatus] [nvarchar](2000),
			[strTestResult] NVARCHAR(2000),
            [name] [nvarchar](2000),
            [datReceivedDate] [datetime2],
            [datConcludedDate] [datetime2],
            [idfTestedByPerson] [bigint],
            [idfTestedByOffice] [bigint],
            [datInterpretedDate] [datetime2],
            [idfsInterpretedStatus] [bigint],
            [strInterpretedComment] [nvarchar](2000),
            [strInterpretedBy] [nvarchar](2000),
            [strInterpretedStatus] [nvarchar](2000),
            [datValidationDate] [datetime2],
            [blnValidateStatus] [bit],
            [strValidateComment] [nvarchar](2000),
            [strValidatedBy] [nvarchar](2000),
            [strAccountName] [nvarchar](2000),
--			[testGuid] NVARCHAR(MAX),
			[intRowStatus] [int],
			[strTestedByPerson] NVARCHAR(2000),
			[strTestedByOffice] NVARCHAR(2000),
			[blnNonLaboratoryTest] BIT,
            [idfValidatedByPerson] [bigint],
            [idfInterpretedByPerson] [BIGINT],
            [filterTestByDisease] BIT,
			[idfsYNTestsConducted] BIGINT,
			[RowAction] [nvarchar](1)
			)

	BEGIN TRY
		WHILE EXISTS (
				SELECT *
				FROM @TestsTemp
				)
		BEGIN
		
			SELECT TOP 1
				--@idfHumanCase=	idfHumanCase,
				@idfMaterial = idfMaterial,
				@strBarcode =	strBarcode,
				@strFieldBarcode = strFieldBarcode,
				--@idfsSampleType=	idfsSampleType,
				--@strSampleTypeName=	strSampleTypeName,
				--@datFieldCollectionDate=	datFieldCollectionDate,
				--@idfSendToOffice=	idfSendToOffice,
				--@strSendToOffice=	strSendToOffice,
				--@idfFieldCollectedByOffice=	idfFieldCollectedByOffice,
				--@strFieldCollectedByOffice=	strFieldCollectedByOffice,
				--@datFieldSentDate=	datFieldSentDate,
				--@idfsSampleKind=	idfsSampleKind,
				--@SampleKindTypeName=	SampleKindTypeName,
				--@idfsSampleStatus=	idfsSampleStatus,
				--@SampleStatusTypeName=	SampleStatusTypeName,
				--@idfFieldCollectedByPerson=	idfFieldCollectedByPerson,
				--@datSampleStatusDate=	datSampleStatusDate,
				--	@sampleGuid=	sampleGuid,
				@idfTesting = idfTesting,
				@idfsTestName = idfsTestName,
				@idfsTestCategory = idfsTestCategory,
				@idfsTestResult = idfsTestResult,
				@idfsTestStatus = idfsTestStatus,
				@idfsDiagnosis = idfsDiagnosis,
				--@strTestStatus=	strTestStatus,
				--@name=	name,
				@idfValidatedByOffice = NULL,
				@idfValidatedByPerson = idfValidatedByPerson,
				@idfInterpretedByOffice = NULL,
				@idfInterpretedByPerson = idfInterpretedByPerson,
				@blnCaseCreated = NULL,
				@datReceivedDate = datReceivedDate,
				@datConcludedDate = NULL,
				@idfTestedByPerson = idfTestedByPerson,
				@idfTestedByOffice = idfTestedByOffice,
				@idfsInterpretedStatus = idfsInterpretedStatus,
				@strInterpretedComment = strInterpretedComment,
				@datInterpretedDate = datInterpretedDate,
				@strInterpretedBy = strInterpretedBy,
				@blnValidateStatus = blnValidateStatus,
				@strValidateComment = strValidateComment,
				@datValidationDate = datValidationDate,
				@strValidatedBy = strValidatedBy,
				@strAccountName = strAccountName,
				@intRowStatus = intRowStatus,
				@RowAction = RowAction
			FROM @TestsTemp

			IF NOT EXISTS (
					SELECT idfTesting
					FROM tlbTesting
					WHERE idfTesting = @idfTesting
					)
			BEGIN
				SET @idfMaterial = (
						SELECT TOP 1 idfMaterial
						FROM tlbMaterial
						WHERE idfHumanCase = @idfHumanCase
						And strFieldBarcode = @strFieldBarcode
							AND intRowStatus = 0
						)

				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbTesting',
					@idfTesting OUTPUT;

				INSERT INTO dbo.tlbTesting (
					idfHumanCase,
					idfMaterial,
					--,strBarcode
					--,strFieldBarcode
					--,idfsSampleType
					--,strSampleTypeName
					--,datFieldCollectionDate
					--,idfSendToOffice
					--,strSendToOffice
					--,idfFieldCollectedByOffice
					--,strFieldCollectedByOffice
					--,datFieldSentDate
					--,idfsSampleKind
					--,SampleKindTypeName
					--,idfsSampleStatus
					--,SampleStatusTypeName
					--,idfFieldCollectedByPerson
					--,datSampleStatusDate
					--,sampleGuid
					idfTesting,
					idfsTestName,
					idfsTestCategory,
					idfsTestResult,
					idfsTestStatus,
					idfsDiagnosis
					--,strTestStatus
					--,name
					,
					datReceivedDate,
					datConcludedDate,
					idfTestedByPerson,
					idfTestedByOffice,
					intRowStatus,
					idfObservation,
					blnReadOnly,
					blnNonLaboratoryTest,
					AuditCreateUser
					)
				VALUES (
					@idfHumanCase,
					@idfMaterial,
					--,@strBarcode
					--,@strFieldBarcode
					--,@idfsSampleType
					--,@strSampleTypeName
					--,@datFieldCollectionDate
					--,@idfSendToOffice
					--,@strSendToOffice
					--,@idfFieldCollectedByOffice
					--,@strFieldCollectedByOffice
					--,@datFieldSentDate
					--,@idfsSampleKind
					--,@SampleKindTypeName
					--,@idfsSampleStatus
					--,@SampleStatusTypeName
					--,@idfFieldCollectedByPerson
					--,@datSampleStatusDate
					--,@sampleGuid
					@idfTesting,
					@idfsTestName,
					@idfsTestCategory,
					@idfsTestResult,
					@idfsTestStatus,
					@idfsDiagnosis
					--,@strTestStatus
					--,@name
					,
					@datReceivedDate,
					@datConcludedDate,
					@idfTestedByPerson,
					@idfTestedByOffice,
					@intRowStatus,
					0,
					0,
					1, --Default to 1 for epi user entry.
					@AuditUser
					)

				-- TEST_VALIDATION	
				--SELECT @idfPersonTemp = P.IdfPerson
				--FROM dbo.tlbPerson P
				--INNER JOIN tstUserTable U
				--	ON U.IdfPerson = P.IdfPerson
				--		AND strAccountName = @strAccountName

				--Print 'call  USSP_GBL_TEST_VALIDATION_SET after insert to tlbTesting' 
				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbTestValidation',
					@idfTestValidation OUTPUT;

				INSERT INTO dbo.tlbTestValidation (
					idfTestValidation,
					idfsDiagnosis,
					idfsInterpretedStatus,
					idfValidatedByOffice,
					idfValidatedByPerson,
					idfInterpretedByOffice,
					idfInterpretedByPerson,
					idfTesting,
					blnValidateStatus,
					blnCaseCreated,
					strValidateComment,
					strInterpretedComment,
					datValidationDate,
					datInterpretationDate,
					intRowStatus,
					blnReadOnly,
					strMaintenanceFlag,
					AuditCreateUser
					)
				VALUES (
					@idfTestValidation,
					@idfsDiagnosis,
					@idfsInterpretedStatus,
					@idfValidatedByOffice,
					@idfValidatedByPerson,
					@idfInterpretedByOffice,
					@idfInterpretedByPerson,
					@idfTesting,
					@blnValidateStatus,
					@blnCaseCreated,
					@strValidateComment,
					@strInterpretedComment,
					@datValidationDate,
					@datInterpretedDate,
					0,
					0,
					NULL,
					@AuditUser
					);
			END
			ELSE
			BEGIN
				UPDATE dbo.tlbTesting
				SET
					idfHumanCase=	@idfHumanCase,
					idfMaterial=	@idfMaterial,
					--,strBarcode=	@strBarcode
					--,strFieldBarcode=	@strFieldBarcode
					--,idfsSampleType=	@idfsSampleType
					--,strSampleTypeName=	@strSampleTypeName
					--,datFieldCollectionDate=	@datFieldCollectionDate
					--,idfSendToOffice=	@idfSendToOffice
					--,strSendToOffice=	@strSendToOffice
					--,idfFieldCollectedByOffice=	@idfFieldCollectedByOffice
					--,strFieldCollectedByOffice=	@strFieldCollectedByOffice
					--,datFieldSentDate=	@datFieldSentDate
					--,idfsSampleKind=	@idfsSampleKind
					--,SampleKindTypeName=	@SampleKindTypeName
					--,idfsSampleStatus=	@idfsSampleStatus
					--,SampleStatusTypeName=	@SampleStatusTypeName
					--,idfFieldCollectedByPerson=	@idfFieldCollectedByPerson
					--,datSampleStatusDate=	@datSampleStatusDate
					--,sampleGuid=	@sampleGuid
					--idfTesting=	@idfTesting
					idfsTestName = @idfsTestName,
					idfsTestCategory = @idfsTestCategory,
					idfsTestResult = @idfsTestResult,
					idfsTestStatus = @idfsTestStatus,
					idfsDiagnosis = @idfsDiagnosis
					--,strTestStatus=	@strTestStatus
					--,name=	@name
					,
					datReceivedDate = @datReceivedDate,
					datConcludedDate = @datConcludedDate,
					idfTestedByPerson = @idfTestedByPerson,
					idfTestedByOffice = @idfTestedByOffice
					--	,rowGuid=	@testGuid
					,
					intRowStatus = (CASE
										WHEN  @RowAction = 'D' THEN 1 
										ELSE 0
									END),
					idfObservation = 0,
					blnReadOnly = 0,
					blnNonLaboratoryTest = 1, --Default to 1 for epi user entry.
					AuditUpdateUser = @AuditUser
				WHERE idfTesting = @idfTesting AND idfMaterial = @idfMaterial;

				-- TEST_VALIDATION	
				SELECT @idfTestValidationTemp = idfTestValidation
				FROM dbo.tlbTestValidation
				WHERE idfTesting = @idfTesting

				IF NOT EXISTS (
						SELECT idfTestValidation
						FROM dbo.tlbTestValidation
						WHERE idfTestValidation = @idfTestValidationTemp
						)
				BEGIN
					--Print 'call  USSP_GBL_TEST_VALIDATION_SET after update to tlbTesting' + CONVERT(VARCHAR(MAX), @idfTesting)
					--Begin Validation Insert
					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbTestValidation',
						@idfTestValidation OUTPUT;

					INSERT INTO dbo.tlbTestValidation (
						idfTestValidation,
						idfsDiagnosis,
						idfsInterpretedStatus,
						idfValidatedByOffice,
						idfValidatedByPerson,
						idfInterpretedByOffice,
						idfInterpretedByPerson,
						idfTesting,
						blnValidateStatus,
						blnCaseCreated,
						strValidateComment,
						strInterpretedComment,
						datValidationDate,
						datInterpretationDate,
						intRowStatus,
						blnReadOnly,
						strMaintenanceFlag,
						AuditCreateUser
						)
					VALUES (
						@idfTestValidation,
						@idfsDiagnosis,
						@idfsInterpretedStatus,
						@idfValidatedByOffice,
						@idfValidatedByPerson,
						@idfInterpretedByOffice,
						@idfInterpretedByPerson,
						@idfTesting,
						@blnValidateStatus,
						@blnCaseCreated,
						@strValidateComment,
						@strInterpretedComment,
						@datValidationDate,
						@datInterpretedDate,
						0,
						0,
						'I',
						@AuditUser
						);
						--End Validation insert
				END
				ELSE
				BEGIN
					--Update Validation
					UPDATE dbo.tlbTestValidation
					SET idfsDiagnosis = @idfsDiagnosis,
						idfsInterpretedStatus = @idfsInterpretedStatus,
						idfValidatedByOffice = @idfValidatedByOffice,
						idfValidatedByPerson = @idfValidatedByPerson,
						idfInterpretedByOffice = @idfInterpretedByOffice,
						idfInterpretedByPerson = @idfInterpretedByPerson,
						idfTesting = @idfTesting,
						blnValidateStatus = @blnValidateStatus,
						blnCaseCreated = @blnCaseCreated,
						strValidateComment = @strValidateComment,
						strInterpretedComment = @strInterpretedComment,
						datValidationDate = @datValidationDate,
						datInterpretationDate = @datValidationDate,
						intRowStatus = @intRowStatus,
						blnReadOnly = 0,
						strMaintenanceFlag = 'U',
						AuditUpdateUser = @AuditUser
					WHERE idfTestValidation = @idfTestValidationTemp
						--End Update Validation
				END
			END

			--DELETE FROM	@TestsTemp WHERE testGuid = @testGuid
			SET ROWCOUNT 1

			DELETE
			FROM @TestsTemp

			SET ROWCOUNT 0
		END --end loop, WHILE EXISTS (SELECT * FROM @TestsTemp)
				--SELECT @returnCode 'ReturnCode', @returnMsg 'ResturnMessage',@idfTesting 'idfTesting';
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
