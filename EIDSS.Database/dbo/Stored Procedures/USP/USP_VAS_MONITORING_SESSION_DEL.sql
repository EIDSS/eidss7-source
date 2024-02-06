
-- ================================================================================================
-- Name: USP_VCT_MONITORING_SESSION_DEL
--
-- Description:	Sets an active surveillance monitoring session record to "inactive".
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     05/02/2019 Initial release.
-- Stephen Long     07/10/2019 Added dependent child object checks.
-- Mike Kornegay	08/22/2022 Added tlbMonitoringSessionToMaterial table.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_DEL] (
	@LanguageID NVARCHAR(50) = NULL,
	@MonitoringSessionID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnCode INT = 0,
			@ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
			@FarmCount AS INT = 0,
			@SampleCount AS INT = 0,
			@LabTestCount AS INT = 0,
			@TestInterpretationCount AS INT = 0,
			@DiseaseReportCount AS INT = 0,
			@AggregateCount AS INT = 0;

		BEGIN TRANSACTION;

		SELECT @AggregateCount = COUNT(*)
		FROM dbo.tlbMonitoringSessionSummary mss
		WHERE mss.idfMonitoringSession = @MonitoringSessionID
			AND mss.intRowStatus = 0;

		SELECT @DiseaseReportCount = COUNT(*)
		FROM dbo.tlbVetCase v
		WHERE v.idfParentMonitoringSession = @MonitoringSessionID
			AND v.intRowStatus = 0;

		SELECT @TestInterpretationCount = COUNT(*)
		FROM dbo.tlbTestValidation tv
		INNER JOIN dbo.tlbTesting AS t
			ON t.idfTesting = tv.idfTesting
				AND t.intRowStatus = 0
		INNER JOIN dbo.tlbMaterial AS m
			ON m.idfMaterial = t.idfMaterial
				AND m.intRowStatus = 0
		WHERE m.idfMonitoringSession = @MonitoringSessionID
			AND tv.intRowStatus = 0;

		SELECT @LabTestCount = COUNT(*)
		FROM dbo.tlbTesting t
		INNER JOIN dbo.tlbMaterial AS m
			ON m.idfMaterial = t.idfMaterial
				AND m.intRowStatus = 0
		WHERE m.idfMonitoringSession = @MonitoringSessionID
			AND t.intRowStatus = 0;

		SELECT @SampleCount = COUNT(*)
		FROM dbo.tlbMaterial
		WHERE idfMonitoringSession = @MonitoringSessionID
			AND intRowStatus = 0;

		SELECT @FarmCount = COUNT(*)
		FROM dbo.tlbFarm
		WHERE idfMonitoringSession = @MonitoringSessionID
			AND intRowStatus = 0;

		IF @FarmCount = 0
			AND @SampleCount = 0
			AND @LabTestCount = 0
			AND @TestInterpretationCount = 0
			AND @AggregateCount = 0 
			AND @DiseaseReportCount = 0
		BEGIN
			UPDATE dbo.tlbMonitoringSession
			SET intRowStatus = 1,
				idfCampaign = NULL, 
				AuditUpdateDTM = GETDATE()
			WHERE idfMonitoringSession = @MonitoringSessionID;

			UPDATE dbo.MonitoringSessionToSampleType 
			SET intRowStatus = 1, 
				AuditUpdateDTM = GETDATE()
			WHERE idfMonitoringSession = @MonitoringSessionID;

			UPDATE dbo.tlbMonitoringSessionToDiagnosis
			SET intRowStatus = 1 
			WHERE idfMonitoringSession = @MonitoringSessionID;

			UPDATE dbo.tlbMonitoringSessionToMaterial
			SET intRowStatus = 1 
			WHERE idfMonitoringSession = @MonitoringSessionID;

			UPDATE dbo.tlbMonitoringSessionAction
			SET intRowStatus = 1, 
				AuditUpdateDTM = GETDATE()
			WHERE idfMonitoringSession = @MonitoringSessionID;
		END
		ELSE
		BEGIN
			SET @ReturnCode = 1;
			SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
		END;

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
