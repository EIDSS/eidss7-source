-- ================================================================================================
-- Name: FN_LAB_VECTOR_SESSION_DISEASES_GET
--
-- Description: Returns the delimited list of disease identifiers and names for a surveillance 
-- session.
--          
-- Author: Stephen Long
--
-- Revision History:
--		Name       Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       02/09/2022 Initial release
-- Stephen Long       05/20/2022 Added vector ID.
-- Stephen Long       05/23/2022 Added material table select.
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_LAB_VECTOR_SESSION_DISEASES_GET] (@LanguageID NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(   
    SELECT vss.idfVectorSurveillanceSession AS VectorSurveillanceSessionID,
           vss.DiseaseID AS DiseaseID,
           name AS DiseaseName
    FROM
    (
        SELECT DISTINCT
            Material.idfVectorSurveillanceSession,
            Material.DiseaseID,
            diseaseName.name
        FROM dbo.tlbMaterial Material
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = Material.DiseaseID
        WHERE Material.intRowStatus = 0
              AND Material.idfVectorSurveillanceSession IS NOT NULL
              AND Material.DiseaseID IS NOT NULL 
    ) vss
    GROUP BY vss.idfVectorSurveillanceSession, 
             vss.DiseaseID, 
             vss.name
    UNION
    SELECT vss.idfVectorSurveillanceSession AS VectorSurveillanceSessionID,
           vss.idfsDiagnosis AS DiseaseID,
           name AS DiseaseName
    FROM
    (
        SELECT DISTINCT
            Vss.idfVectorSurveillanceSession,
            Vssd.idfsDiagnosis,
            diseaseName.name
        FROM dbo.tlbVectorSurveillanceSessionSummary Vss
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis Vssd
                ON Vss.[idfsVSSessionSummary] = Vssd.[idfsVSSessionSummary]
                   AND Vssd.intRowStatus = 0
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = Vssd.idfsDiagnosis
        WHERE vss.intRowStatus = 0
              AND Vss.idfVectorSurveillanceSession IS NOT NULL
    ) vss
    GROUP BY vss.idfVectorSurveillanceSession, 
             vss.idfsDiagnosis, 
             vss.name 
);
