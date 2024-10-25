-- ================================================================================================
-- Name: POPULATE DISEASE ID ON MATERIAL TABLE FROM HUMAN AND VET CASE FINAL DIAGNOSIS
--
-- Description: Execute on all environments.  Performance improvements for lab stored procedures.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    03/09/2023 Run for build 7.0.338.x
-- ================================================================================================
UPDATE m SET m.DiseaseID = COALESCE (hc.idfsFinalDiagnosis , hc.idfsTentativeDiagnosis)
FROM dbo.tlbMaterial m
INNER JOIN dbo.tlbHumanCase hc ON hc.idfHumanCase = m.idfHumanCase
WHERE m.LabModuleSourceIndicator = 0

UPDATE m SET m.DiseaseID = COALESCE (vc.idfsFinalDiagnosis , vc.idfsTentativeDiagnosis)
FROM dbo.tlbMaterial m
INNER JOIN dbo.tlbVetCase vc ON vc.idfVetCase = m.idfVetCase
WHERE m.LabModuleSourceIndicator = 0

GO