-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_DEL
--
-- Description:	Sets an active surveillance monitoring session record to "inactive" for the human 
-- module.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/06/2019 Initial release.
-- Mark Wilson		08/18/2021 added all children tables and removed LanguageID
-- Stephen Long     06/06/2023 Added check for child dependent objects.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_DEL] (@MonitoringSessionID BIGINT)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
                @ReturnCode BIGINT = 0,
                @SampleCount AS INT = 0,
                @LabTestCount AS INT = 0,
                @TestInterpretationCount AS INT = 0,
                @DiseaseReportCount AS INT = 0,
                @AggregateCount AS INT = 0;

        BEGIN TRANSACTION;

        DECLARE @tlbMonitoringSessionSummary TABLE (idfMonitorintSessionSummary BIGINT)

        SELECT @AggregateCount = COUNT(*)
        FROM dbo.tlbMonitoringSessionSummary mss
        WHERE mss.idfMonitoringSession = @MonitoringSessionID
              AND mss.intRowStatus = 0;

        SELECT @DiseaseReportCount = COUNT(*)
        FROM dbo.tlbHumanCase h
        WHERE h.idfParentMonitoringSession = @MonitoringSessionID
              AND h.intRowStatus = 0;

        SELECT @TestInterpretationCount = COUNT(*)
        FROM dbo.tlbTestValidation tv
            INNER JOIN dbo.tlbTesting t
                ON t.idfTesting = tv.idfTesting
                   AND t.intRowStatus = 0
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfMonitoringSession = @MonitoringSessionID
              AND tv.intRowStatus = 0;

        SELECT @LabTestCount = COUNT(*)
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND m.intRowStatus = 0
        WHERE m.idfMonitoringSession = @MonitoringSessionID
              AND t.intRowStatus = 0;

        SELECT @SampleCount = COUNT(*)
        FROM dbo.tlbMaterial
        WHERE idfMonitoringSession = @MonitoringSessionID
              AND intRowStatus = 0;

        IF @SampleCount = 0
           AND @LabTestCount = 0
           AND @TestInterpretationCount = 0
           AND @AggregateCount = 0
           AND @DiseaseReportCount = 0
        BEGIN
            INSERT into @tlbMonitoringSessionSummary
            SELECT idfMonitoringSessionSummary
            FROM dbo.tlbMonitoringSessionSummary
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSession
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID;

            UPDATE dbo.tlbMonitoringSessionToDiagnosis
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSessionAction
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSessionSummary
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID

            UPDATE dbo.tlbMonitoringSessionSummaryDiagnosis
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSessionSummary IN (
                                                     SELECT * FROM @tlbMonitoringSessionSummary
                                                 )

            UPDATE dbo.tlbMonitoringSessionSummarySample
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSessionSummary IN (
                                                     SELECT * FROM @tlbMonitoringSessionSummary
                                                 )

            UPDATE dbo.tlbMonitoringSessionToMaterial
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE()
            WHERE idfMonitoringSession = @MonitoringSessionID
        END
        ELSE
        BEGIN
            SET @ReturnCode = 1;
            SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
        END;

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
