-- ================================================================================================
-- Name: POPULATE DISEASE ID ON MATERIAL TABLE FROM HUMAN AND VET CASE FINAL DIAGNOSIS
--
-- Description: Execute on all environments.  Performance improvements for lab stored procedures.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    02/11/2022 Run for build 7.0.235.x
-- ================================================================================================
update m set m.DiseaseID = hc.idfsFinalDiagnosis
FROM dbo.tlbMaterial m
inner join dbo.tlbHumanCase hc on hc.idfHumanCase = m.idfHumanCase and hc.intRowStatus = 0
where m.intRowStatus = 0 and m.LabModuleSourceIndicator = 0 and hc.idfsFinalDiagnosis is not null

update m set m.DiseaseID = vc.idfsFinalDiagnosis
FROM dbo.tlbMaterial m
inner join dbo.tlbVetCase vc on vc.idfVetCase = m.idfVetCase and vc.intRowStatus = 0
where m.intRowStatus = 0 and m.LabModuleSourceIndicator = 0 and vc.idfsFinalDiagnosis is not null