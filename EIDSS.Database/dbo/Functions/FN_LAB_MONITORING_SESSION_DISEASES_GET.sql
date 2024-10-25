-- ================================================================================================
-- Name: FN_LAB_MONITORING_SESSION_DISEASES_GET
--
-- Description: Returns the delimited list of disease identifiers and names for a surveillance 
-- session.
--          
-- Author: Stephen Long
--
-- Revision History:
--		Name       Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       02/08/2022 Initial release
-- Stephen Long       05/20/2022 Changed disease name split from comma to semi-colon.
-- Stephen Long       10/21/2022 Changed from semi-colon to pipe.
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_LAB_MONITORING_SESSION_DISEASES_GET] (@LanguageID NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT msd.idfMonitoringSession AS MonitoringSessionID,
           STRING_AGG(msd.idfsDiagnosis, ',') AS DiseaseID,
           STRING_AGG(name, '|') AS DiseaseName
    FROM
    (
        SELECT DISTINCT
            msd.idfMonitoringSession,
            msd.idfsDiagnosis,
            diseaseName.name, 
            diseaseName.name AS DisplayName 
        FROM dbo.tlbMonitoringSessionToDiagnosis msd
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = msd.idfsDiagnosis
        WHERE msd.intRowStatus = 0
    ) msd
    GROUP BY msd.idfMonitoringSession
);
