-- ================================================================================================
-- Name: USP_VCT_CAMPAIGN_MONITORING_SESSION_DEL
--
-- Description:	Removes the campaign link from a monitoring session.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     09/23/2020 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VCT_CAMPAIGN_MONITORING_SESSION_DEL] (
	@LanguageID NVARCHAR(50) = NULL,
	@MonitoringSessionID BIGINT, 
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnCode INT = 0,
			@ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

		BEGIN TRANSACTION;

			UPDATE dbo.tlbMonitoringSession
			SET idfCampaign = NULL, 
				AuditUpdateDTM = GETDATE(),		
				AuditUpdateUser = @AuditUserName
			WHERE idfMonitoringSession = @MonitoringSessionID;

		IF @@TRANCOUNT > 0
			AND @returnCode = 0
			COMMIT;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage;

		THROW;
	END CATCH
END
