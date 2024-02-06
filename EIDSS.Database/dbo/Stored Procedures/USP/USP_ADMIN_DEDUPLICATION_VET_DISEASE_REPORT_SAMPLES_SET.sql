-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_VET_DISEASE_REPORT_SAMPLES_SET
--
-- Description: Update column idfVetCase in tlbMaterial.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    12/4/2019 Initial release for new API.
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_VET_DISEASE_REPORT_SAMPLES_SET]
	@idfMaterial							BIGINT NULL, 
 	@SurvivorVeterinaryDiseaseReportID		BIGINT = NULL,
	@SupersededVeterinaryDiseaseReportID	BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 

	BEGIN TRY

		BEGIN TRANSACTION


			UPDATE 	dbo.tlbMaterial
			SET 	idfVetCase   = @SurvivorVeterinaryDiseaseReportID		
			WHERE	idfVetCase    = @SupersededVeterinaryDiseaseReportID and idfMaterial = @idfMaterial
			
			IF @@TRANCOUNT > 0 
				COMMIT TRANSACTION;
			
			SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMsg'
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER()
		SET @ReturnMsg = 'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
							+ ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
			   				+ ' ErrorState: ' + convert(varchar,ERROR_STATE())
			   				+ ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
			   				+ ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
			   				+ ' ErrorMessage: '+ ERROR_MESSAGE()

		SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMsg'

	END CATCH
END
