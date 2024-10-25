-- ================================================================================================
-- Name: FN_GBL_SESSION_DISEASEIDS_GET
--
-- Description: Returns the delimited list of disease identifiers for a surveillance session.
--          
-- Author: Stephen Long
--
-- Revision History:
--		Name       Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       01/27/2022 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_SESSION_DISEASEIDS_GET] (@MonitoringSessionID AS BIGINT)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @identifiers VARCHAR(MAX);

    SELECT @identifiers = ISNULL(@identifiers + ',', '') + CAST(msd.idfsDiagnosis AS VARCHAR(50))
    FROM
    (
        SELECT DISTINCT
            msd.idfsDiagnosis
        FROM dbo.tlbMonitoringSessionToDiagnosis msd
        WHERE msd.idfMonitoringSession = @MonitoringSessionID
        UNION
        SELECT DISTINCT
            mssd.idfsDiagnosis
        FROM dbo.tlbMonitoringSessionSummary mss
        INNER JOIN dbo.tlbMonitoringSessionSummaryDiagnosis mssd
                ON mss.idfMonitoringSessionSummary = mssd.idfMonitoringSessionSummary
        WHERE mss.idfMonitoringSession = @MonitoringSessionID
    ) AS msd
    ORDER BY msd.idfsDiagnosis;

    RETURN @identifiers;
END
