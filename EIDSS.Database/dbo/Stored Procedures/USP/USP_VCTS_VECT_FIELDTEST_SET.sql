-- ================================================================================================
-- Name: USP_VCTS_VECT_FIELDTEST_SET
--
-- Description:	Inserts or updates vector "fieldtest" create vector surveillance session use case.
--                      
-- Author: Harold Pryor
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Harold Pryor     04/17/2018	Initial release.
-- Harold Pryor     05/17/2018	Changed GetUTCDate() to GetDate()  
-- Harold Pryor     05/22/2018	Updated to update @RecordAction
-- Harold Pryor     05/29/2018	Updated to pass @idfTestedByOffice, @idfTestedByPerson and 
--								@idfsTestResult values to dbo.USSP_GBL_TESTING_SET 
-- Lamont Mitchell  01/23/2019	ALIASED output and Supressed Select Statment, Removed Output 
--								parameter and moved to Select
-- Stephen Long     03/07/2020	Changed non-laboratory test indicator (blnNonLaboratoryTest) to true 
--								as these are field tests that should not appear in the lab module.
-- Doug Albanese	01/11/2021	Added idfVector, due to a  recent decision and update on the db table of tlbTesting
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VCTS_VECT_FIELDTEST_SET] (
	@idfMaterial		BIGINT,
	@LangID				VARCHAR(50),
	@idfTesting			BIGINT = NULL,
	@idfsTestName		BIGINT = NULL,
	@idfsTestCategory	BIGINT = NULL,
	@idfTestedByOffice	BIGINT = NULL,
	@idfsTestResult		BIGINT = NULL,
	@idfTestedByPerson	BIGINT = NULL,
	@idfsDiagnosis		BIGINT,
	@datConcludedDate	DATETIME = NULL,
	@idfVector			BIGINT = NULL
	)
AS
DECLARE @returnCode INT = 0;
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
DECLARE @intRowStatus INT = 0,
	@datReceivedDate DATETIME = GETDATE(),
	@datStartDate DATETIME = GETDATE(),
	@RecordAction NCHAR(1) = 'I',
	@idfsTestStatus INT = 10001005, -- default set to Not Started 	
	@idfObservation INT = 0,
	@blnReadOnly BIT = 0,
	@blnNonLaboratory BIT = 1, --default set to 1 for field tests
	@idfTestingOut BIGINT

IF EXISTS (
		SELECT idfTesting
		FROM dbo.tlbTesting
		WHERE idfTesting = @idfTesting
		)
BEGIN
	SET @RecordAction = 'U'
END

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @SupressSelect TABLE (
			RetrunCode INT,
			ReturnMessage NVARCHAR(MAX),
			idfTesting BIGINT
			)

		BEGIN TRANSACTION;

		BEGIN
			
			EXEC dbo.USSP_GBL_TESTING_SET @LangID,
				@idfTesting,
				@idfsTestName,
				@idfsTestCategory,
				@idfsTestResult,
				@idfsTestStatus,
				@idfsDiagnosis,
				@idfmaterial,
				NULL,
				@idfObservation,
				NULL,
				NULL,
				@intRowStatus,
				@datStartDate,
				@datConcludedDate,
				@idfTestedByOffice,
				@idfTestedByPerson,
				NULL,
				NULL,
				NULL,
				NULL,
				@blnReadOnly,
				@blnNonLaboratory,
				NULL,
				NULL,
				@datReceivedDate,
				NULL,
				NULL,
				@RecordAction,
				@idfVector

		END

		IF @@TRANCOUNT > 0
			AND @returnCode = 0
			COMMIT;

		SELECT @returnCode 'ReturnCode',
			@returnMsg 'ReturnMessage',
			@idfTestingOut 'idfTesting';
	END TRY

	BEGIN CATCH
		IF @@Trancount = 1
			ROLLBACK;

		Throw;
	END CATCH
END
