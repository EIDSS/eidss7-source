-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_FARM_DISEASE_REPORT_SET
--
-- Description: Update column idfFarmActual in tlbFarm.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    10/2/2019 Initial release for new API.
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_FARM_DISEASE_REPORT_SET]
	@idfVetCase					BIGINT NULL, 
 	@SurvivorFarmMasterID		BIGINT = NULL,
	@SupersededFarmMasterID		BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 
	DECLARE	@idfFarm	BIGINT

	BEGIN TRY

		BEGIN TRANSACTION

			SELECT	@idfFarm = idfFarm
			FROM	dbo.tlbVetCase 
			WHERE	idfVetCase = @idfVetCase

			UPDATE 	dbo.tlbFarm
			SET 	idfFarmActual   = @SurvivorFarmMasterID
			WHERE	idfFarm   = @idfFarm and idfFarmActual = @SupersededFarmMasterID
			
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
