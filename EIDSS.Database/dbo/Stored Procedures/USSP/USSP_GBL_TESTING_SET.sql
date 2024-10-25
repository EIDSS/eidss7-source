
-- ================================================================================================
-- Name: USSP_GBL_TESTING_SET
--
-- Description:	Inserts or updates testing records for various use cases.
--
-- Author: Stephen Long
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Stephen Long     04/03/2018	Initial release.
-- Stephen Long     03/13/2020	Synching up other environments.
-- Doug Albanese	01/11/2021	Added parameter to treat this SP as a psuedo function call, so that 
--								an insert into can be used to capture the idfTesting value
-- Steven Verner	10/20/2021	Added @AuditUser parameter to indicate user performing the action.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_TESTING_SET] (
	@LangID NVARCHAR(50),
	@idfTesting BIGINT OUTPUT,
	@idfsTestName BIGINT = NULL,
	@idfsTestCategory BIGINT = NULL,
	@idfsTestResult BIGINT = NULL,
	@idfsTestStatus BIGINT,
	@idfsDiagnosis BIGINT,
	@idfMaterial BIGINT = NULL,
	@idfBatchTest BIGINT = NULL,
	@idfObservation BIGINT,
	@intTestNumber INT = NULL,
	@strNote NVARCHAR(500) = NULL,
	@intRowStatus INT = NULL,
	@datStartedDate DATETIME = NULL,
	@datConcludedDate DATETIME = NULL,
	@idfTestedByOffice BIGINT = NULL,
	@idfTestedByPerson BIGINT = NULL,
	@idfResultEnteredByOffice BIGINT = NULL,
	@idfResultEnteredByPerson BIGINT = NULL,
	@idfValidatedByOffice BIGINT = NULL,
	@idfValidatedByPerson BIGINT = NULL,
	@blnReadOnly BIT,
	@blnNonLaboratoryTest BIT,
	@blnExternalTest BIT = NULL,
	@idfPerformedByOffice BIGINT = NULL,
	@datReceivedDate DATETIME = NULL,
	@strContactPerson NVARCHAR(200) = NULL,
	@strMaintenanceFlag NVARCHAR(20) = NULL,
	@RecordAction NCHAR(1),
	@idfVector BIGINT = NULL,
	@AuditUser NVARCHAR(100) = NULL
	)
AS
DECLARE @returnCode INT = 0;
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @RecordAction = 'I'
		BEGIN
			DECLARE @SupressSelect TABLE (
				retrunCode INT,
				returnMsg VARCHAR(200)
				)

			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 
				@tableName = 'tlbTesting',
				@idfsKey = @idfTesting OUTPUT;

			INSERT INTO dbo.tlbTesting (
				idfTesting,
				idfsTestName,
				idfsTestCategory,
				idfsTestResult,
				idfsTestStatus,
				idfsDiagnosis,
				idfMaterial,
				idfBatchTest,
				idfObservation,
				intTestNumber,
				strNote,
				intRowStatus,
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
				idfVector,
				SourceSystemNameID,
			    SourceSystemKeyValue,
			    AuditCreateUser,
			    AuditCreateDTM,
			    AuditUpdateUser,
			    AuditUpdateDTM
				)
			VALUES (
				@idfTesting,
				@idfsTestName,
				@idfsTestCategory,
				@idfsTestResult,
				@idfsTestStatus,
				@idfsDiagnosis,
				@idfMaterial,
				@idfBatchTest,
				@idfObservation,
				@intTestNumber,
				@strNote,
				@intRowStatus,
				@datStartedDate,
				@datConcludedDate,
				@idfTestedByOffice,
				@idfTestedByPerson,
				@idfResultEnteredByOffice,
				@idfResultEnteredByPerson,
				@idfValidatedByOffice,
				@idfValidatedByPerson,
				@blnReadOnly,
				@blnNonLaboratoryTest,
				@blnExternalTest,
				@idfPerformedByOffice,
				@datReceivedDate,
				@strContactPerson,
				@strMaintenanceFlag,
				@idfVector,
				10519001,
				'[{"idfTesting":' + CAST(@idfTesting AS NVARCHAR(300)) + '}]',
				@AuditUser,
				GETDATE(),
				@AuditUser,
				GETDATE()
				);
		END
		ELSE
		BEGIN
			UPDATE dbo.tlbTesting
			SET idfsTestName = @idfsTestName,
				idfsTestCategory = @idfsTestCategory,
				idfsTestResult = @idfsTestResult,
				idfsTestStatus = @idfsTestStatus,
				idfsDiagnosis = @idfsDiagnosis,
				idfMaterial = @idfMaterial,
				idfBatchTest = @idfBatchTest,
				idfObservation = @idfObservation,
				intTestNumber = @intTestNumber,
				strNote = @strNote,
				intRowStatus = @intRowStatus,
				datStartedDate = @datStartedDate,
				datConcludedDate = @datConcludedDate,
				idfTestedByOffice = @idfTestedByOffice,
				idfTestedByPerson = @idfTestedByPerson,
				idfResultEnteredByOffice = @idfResultEnteredByOffice,
				idfResultEnteredByPerson = @idfResultEnteredByPerson,
				idfValidatedByOffice = @idfValidatedByOffice,
				idfValidatedByPerson = @idfValidatedByPerson,
				blnReadOnly = @blnReadOnly,
				blnNonLaboratoryTest = @blnNonLaboratoryTest,
				blnExternalTest = @blnExternalTest,
				idfPerformedByOffice = @idfPerformedByOffice,
				datReceivedDate = @datReceivedDate,
				strContactPerson = @strContactPerson,
				strMaintenanceFlag = @strMaintenanceFlag,
				idfVector = @idfVector,
				AuditUpdateUser = @AuditUser,
				AuditUpdateDTM = GETDATE()
			WHERE idfTesting = @idfTesting;
		END

		SELECT @returnCode 'ReturnCode',
			@returnMsg 'ReturnMessage',
			@idfTesting 'idfTesting';
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
