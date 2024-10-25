
-- ================================================================================================
-- Name: USSP_OMM_LAB_TEST_SET
--
-- Description:	Inserts, updates or deletes lab tests for veterinary disease reports associated 
-- with an outbreak.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese	08/18/2019 Initial release
-- Stephen Long     03/09/2020 Changed non-laboratory test indicator to 1.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_OMM_LAB_TEST_SET] (
	@LanguageID NVARCHAR(50),
	@idfTest BIGINT OUTPUT,
	@idfsTestName BIGINT NULL,
	@idfsTestCategory BIGINT NULL,
	@idfsTestResult BIGINT NULL,
	@idfsTestStatus BIGINT NULL,
	@idfsDiagnosis BIGINT NULL,
	@idfMaterial BIGINT NULL,
	@RowAction NVARCHAR(1) NULL,
	@User NVARCHAR(200) NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @intRowStatus AS INT = 0;

	BEGIN TRY
		IF @RowAction = 'I'
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTesting',
				@idfTest OUTPUT;

			INSERT INTO dbo.tlbTesting (
				idfTesting,
				idfsTestName,
				idfsTestCategory,
				idfsTestResult,
				idfsTestStatus,
				idfsDiagnosis,
				idfMaterial,
				blnNonLaboratoryTest,
				intRowStatus,
				AuditCreateDTM,
				AuditCreateUser
				)
			VALUES (
				@idfTest,
				@idfsTestName,
				@idfsTestCategory,
				@idfsTestResult,
				10001005, --Default value, because Use Case doesn't allow editing and new record required this. Must be revisited
				@idfsDiagnosis,
				@idfMaterial,
				1, -- Test entered by epi user
				0,
				GETDATE(),
				@User
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
				intRowStatus = @intRowStatus,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE idfTesting = @idfTest;
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
