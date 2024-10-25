

-- ================================================================================================
-- Name: USSP_OMM_VET_TEST_SET
--
-- Description: Add, update and delete veterinary tests associated with an outbreak.
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese    11/14/2019 Initial release
-- Stephen Long     03/09/2020 Changed non-laboratory test indicator to 1.
-- Mark Wilson      10/20/2021 removed @LanguageID and cleaned up insert and update
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_OMM_VET_TEST_SET]
(
	@idfTesting BIGINT OUTPUT,
	@idfsTestName BIGINT NULL,
	@idfsTestCategory BIGINT NULL,
	@idfsTestResult BIGINT NULL,
	@idfsTestStatus BIGINT = 10001005,
	@idfsDiagnosis BIGINT NULL,
	@idfMaterial BIGINT NULL,
	@datConcludedDate DATETIME NULL,
	@intRowStatus INT NULL,
	@RowAction NVARCHAR(1) NULL,
	@User NVARCHAR(200) NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @idfTestValidation AS BIGINT;

	BEGIN TRY
		IF @RowAction = 'I'
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				@tableName = 'tlbTesting',
				@idfsKey = @idfTesting OUTPUT;

			INSERT INTO dbo.tlbTesting
			(
			    idfTesting,
			    idfsTestName,
			    idfsTestCategory,
			    idfsTestResult,
			    idfsTestStatus,
			    idfsDiagnosis,
			    idfMaterial,
			    intRowStatus,
			    rowguid,
			    datStartedDate,
			    datConcludedDate,
			    idfTestedByOffice,
			    idfTestedByPerson,
			    idfResultEnteredByOffice,
			    idfResultEnteredByPerson,
			    idfValidatedByOffice,
			    idfValidatedByPerson,
			    blnReadOnly,
			    blnNonLaboratoryTest,
			    blnExternalTest,
			    idfPerformedByOffice,
			    datReceivedDate,
			    strContactPerson,
			    strMaintenanceFlag,
			    strReservedAttribute,
			    PreviousTestStatusID,
			    SourceSystemNameID,
			    SourceSystemKeyValue,
			    AuditCreateUser,
			    AuditCreateDTM,
			    AuditUpdateUser,
			    AuditUpdateDTM
			)
			VALUES 
			(
				@idfTesting,
				@idfsTestName,
				@idfsTestCategory,
				@idfsTestResult,
				@idfsTestStatus, --Default value, because Use Case doesn't allow editing and new record required this. Must be revisited
				@idfsDiagnosis,
				@idfMaterial,
				0,
				NEWID(),
				NULL,
				@datConcludedDate,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				1, -- Test entered by epi user
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				10519001,
				'[{"idfTesting":' + CAST(@idfTesting AS NVARCHAR(300)) + '}]',
				@User,
				GETDATE(),
				@User,
				GETDATE()
			);

			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTestValidation',
				@idfTestValidation OUTPUT;

			INSERT INTO dbo.tlbTestValidation
			(
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
			    rowguid,
			    blnReadOnly,
			    strMaintenanceFlag,
			    strReservedAttribute,
			    SourceSystemNameID,
			    SourceSystemKeyValue,
			    AuditCreateUser,
			    AuditCreateDTM,
			    AuditUpdateUser,
			    AuditUpdateDTM
			)
			VALUES 
			(
				@idfTestValidation,
				@idfsDiagnosis,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				@idfTesting,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				0,
				NEWID(),
				NULL,
				NULL,
				NULL,
				10519001,
				'[{"idfTestValidation":' + CAST(@idfTestValidation AS NVARCHAR(300)) + '}]',
				@User,
				GETDATE(),
				@User,
				GETDATE()
			);

		END
		ELSE
		BEGIN
			SET @intRowStatus = 0;

			IF @RowAction = 'D'
			BEGIN
				SET @intRowStatus = 1;
			END

			UPDATE dbo.tlbTesting
			SET idfsTestName = @idfsTestName,
				idfsTestCategory = @idfsTestCategory,
				idfsTestResult = @idfsTestResult,
				idfsDiagnosis = @idfsDiagnosis,
				idfMaterial = @idfMaterial,
				blnNonLaboratoryTest = 1,
				datConcludedDate = @datConcludedDate,
				intRowStatus = @intRowStatus,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE idfTesting = @idfTesting;
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
