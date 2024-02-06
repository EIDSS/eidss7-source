-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_DISEASE_ANTIVIRALTHERAPIES_SET
--
-- Description: Update column idfHumanCase in tlbAntimicrobialTherapy.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    6/5/2019 Initial release for new API.
-- Ann Xiong    6/12/2019 Added idfAntimicrobialTherapy
--
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_DISEASE_ANTIVIRALTHERAPIES_SET]
	@idfAntimicrobialTherapy		BIGINT NULL, 
 	@SurvivorHumanDiseaseReportID		BIGINT = NULL,
	@SupersededHumanDiseaseReportID		BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 

	BEGIN TRY

		BEGIN TRANSACTION

			UPDATE 	dbo.tlbAntimicrobialTherapy
			SET 	idfHumanCase   = @SurvivorHumanDiseaseReportID				
			WHERE	idfHumanCase   = @SupersededHumanDiseaseReportID and idfAntimicrobialTherapy = @idfAntimicrobialTherapy
			
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
