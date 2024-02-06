-- ================================================================================================
-- Name: FN_GBL_SESSION_DISEASE_NAMES_GET
--
-- Description: Returns the delimited list of disease names for a surveillance session.
--          
-- Author: Stephen Long
--
-- Revision History:
--		Name       Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       01/27/2022 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_SESSION_DISEASE_NAMES_GET] (@MonitoringSessionID AS BIGINT, @LanguageID NVARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @names NVARCHAR(MAX);

    SELECT @names = ISNULL(@names + ';', '') + CAST(msd.name AS NVARCHAR(200))
    FROM
    (
        SELECT DISTINCT
            msd.idfsDiagnosis,
            diseaseName.name
        FROM dbo.tlbMonitoringSessionToDiagnosis msd
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName ON 
				diseaseName.idfsReference = msd.idfsDiagnosis
        WHERE msd.idfMonitoringSession = @MonitoringSessionID
        UNION
        SELECT DISTINCT
        mssd.idfsDiagnosis,
            diseaseName.name
        FROM dbo.tlbMonitoringSessionSummary mss
            INNER JOIN dbo.tlbMonitoringSessionSummaryDiagnosis mssd
                ON mss.idfMonitoringSessionSummary = mssd.idfMonitoringSessionSummary
						INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName ON 
				diseaseName.idfsReference = mssd.idfsDiagnosis
        WHERE mss.idfMonitoringSession = @MonitoringSessionID
    ) AS msd
    ORDER BY msd.idfsDiagnosis;

    RETURN @names;
END
