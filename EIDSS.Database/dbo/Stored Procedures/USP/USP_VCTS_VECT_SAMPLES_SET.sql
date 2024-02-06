-- ================================================================================================
-- Name: USP_VCTS_VECT_SAMPLES_SET
--
-- Description:	Inserts or updates vector sample for the vector surveillance session use cases.
--                      
-- Author: Harold Pryor
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Harold Pryor     04/17/2018	Initial release.
-- Harold Pryor     05/16/2018	Removed @datAccession 
-- Harold Pryor     05/21/2018	Modified @idfSampleType to @idfsSampleType 
-- Harold Pryor     06/21/2018	Modified to add @strFieldBarcode input parameter
-- Lamont Mitcell	01/23/19	Aliased Return Columns added Supress Statement
-- Stephen Long     04/16/2020	Changed call to USSP_GBL_SAMPLE_SET, and added site ID and entered 
--								date parameters.
-- Doug Albanese	12/15/2020	Use case change to add Disease for labratory accession.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VCTS_VECT_SAMPLES_SET] (
	@LangID NVARCHAR(50) = NULL,
	@idfMaterial BIGINT = NULL,
	@strFieldBarcode NVARCHAR(200) = NULL,
	@idfsSampleType BIGINT = NULL,
	@idfVectorSurveillanceSession BIGINT = NULL,
	@idfVector BIGINT = NULL,
	@idfSendToOffice BIGINT = NULL,
	@idfFieldCollectedByOffice BIGINT = NULL,
	@strNote NVARCHAR(500) = NULL,
	@datFieldCollectionDate DATETIME = NULL,
	@EnteredDate DATETIME = NULL,
	@SiteID BIGINT,
	@idfsDiagnosis BIGINT
	)
AS
DECLARE @returnCode INT = 0;
DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
DECLARE @intRowStatus INT = 0,
	@datFieldSentDate DATETIME = GETDATE(),
	@RecordAction CHAR(1) = 'I',
	@SampleID BIGINT;

IF @datFieldCollectionDate IS NULL
	SET @datFieldCollectionDate = GETDATE();

BEGIN
	SET NOCOUNT ON;

	DECLARE @SupressSelect TABLE (
		ReturnCode INT,
		ReturnMessage VARCHAR(200),
		idfMaterial BIGINT
		);

	BEGIN TRY
		IF EXISTS (
				SELECT *
				FROM dbo.tlbMaterial
				WHERE idfMaterial = @idfMaterial
				)
		BEGIN
			SET @RecordAction = 'U';
		END;

		BEGIN TRANSACTION;

		--INSERT INTO @SupressSelect
		EXECUTE dbo.USSP_GBL_SAMPLE_SET 
			@LangID,
			@idfMaterial OUTPUT,
			@idfsSampleType,
			NULL, 
			NULL, 
			NULL,
			NULL,
			NULL,
			@idfVector,
			NULL,
			@idfVectorSurveillanceSession,
			NULL,
			NULL,
			@datFieldCollectionDate,
			NULL,
			@idfFieldCollectedByOffice,
			@datFieldSentDate,
			@idfSendToOffice,
			@strFieldBarcode,
			@SiteID,
			@EnteredDate,
			0,
			NULL,
			@strNote,
			NULL,
			@idfsDiagnosis,
			NULL,
			@intRowStatus,
			@RecordAction;

		SET @SampleID = @idfMaterial;

		IF @@TRANCOUNT > 0
			AND @returnCode = 0
			COMMIT TRANSACTION;

		SELECT @returnCode ReturnCode,
			@returnMsg ReturnMessage,
			@SampleID SampleID;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @returnCode = ERROR_NUMBER()
		SET @returnMsg = 'ErrorNumber: ' + convert(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + convert(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + convert(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + convert(VARCHAR, isnull(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

		THROW;
	END CATCH
END
