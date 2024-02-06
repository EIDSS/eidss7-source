-- ================================================================================================
-- Name: FN_AS_SAMPLE_DISEASES_GET
--
-- Description: Returns the delimited list of disease identifiers and names for a surveillance 
-- session.
--          
-- Author: Stephen Long
--
-- Revision History:
--		Name       Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       10/18/2022 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_AS_SAMPLE_DISEASES_GET] (@LanguageID NVARCHAR(50), @MonitoringSessionID BIGINT)
RETURNS TABLE
AS
RETURN
(
    SELECT msm.idfMaterial AS SampleID,
           STRING_AGG(msm.idfsDisease, ',') AS DiseaseID,
           STRING_AGG(name, ', ') AS DiseaseName
    FROM
    (
        SELECT msm.idfMaterial,
            msm.idfsDisease,
            diseaseName.name
        FROM dbo.tlbMonitoringSessionToMaterial msm
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = msm.idfsDisease
        WHERE msm.intRowStatus = 0 AND msm.idfMonitoringSession = @MonitoringSessionID
    ) msm
    GROUP BY msm.idfMaterial
);
