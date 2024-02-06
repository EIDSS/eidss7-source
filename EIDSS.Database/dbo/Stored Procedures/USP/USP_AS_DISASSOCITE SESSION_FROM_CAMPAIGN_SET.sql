-- ================================================================================================
-- Name: [USP_AS_DISASSOCITE SESSION_FROM_CAMPAIGN_SET]
--
-- Description: update disassociate session from active surveillance campaign record for the vet/Human human module.
--          
-- Revision History:
-- Name						Date       Change Detail
-- ------------------		---------- -----------------------------------------------------------------

-- Mani						03/11/2022  Initial Release 
-- Testing code:
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AS_DISASSOCITE SESSION_FROM_CAMPAIGN_SET] (
	@idfCampaign BIGINT,
	@idfMonitoringSesion BIGINT,
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	
	
	DECLARE @ReturnCode INT = 0
	DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS'

	BEGIN TRY

		BEGIN TRANSACTION
	

			UPDATE dbo.tlbMonitoringSession 
			SET idfCampaign = null,
				AuditUpdateDTM = GETDATE(),
				AuditCreateUser = @AuditUserName
			WHERE idfMonitoringSession = @idfMonitoringSesion AND idfCampaign= @idfCampaign

			
		

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT 
			@ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage
			

	END TRY

	BEGIN CATCH
		IF @@Trancount > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT
			@ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage;
		THROW;
	END CATCH
END
