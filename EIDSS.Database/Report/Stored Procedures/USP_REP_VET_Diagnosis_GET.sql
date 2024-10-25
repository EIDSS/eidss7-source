


-- ================================================================================================
-- Name: report.USP_REP_VET_Diagnosis_GET
--
-- Description: Get data for Diagnosis details for Vet report.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
/*
--Example of a call of procedure:

exec report.USP_REP_VET_Diagnosis_GET 1 , 'en-US' 

*/ 

CREATE  PROCEDURE [Report].[USP_REP_VET_Diagnosis_GET]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS

	SELECT		
		rfDiagnosis0.[name]		AS strTentativeDiagnosis,
		rfDiagnosis1.[name]		AS strTentativeDiagnosis1,
		rfDiagnosis2.[name]		AS strTentativeDiagnosis2,
		rfDiagnosisf.[name]		AS strFinalDiagnosis,
		VC.datTentativeDiagnosisDate,
		VC.datTentativeDiagnosis1Date,
		VC.datTentativeDiagnosis2Date,
		VC.datFinalDiagnosisDate,
		diagnosis0.strOIECode		AS strTentativeDiagnosisCode,
		diagnosis1.strOIECode		AS strTentativeDiagnosis1Code,
		diagnosis2.strOIECode		AS strTentativeDiagnosis2Code,
		diagnosisf.strOIECode		AS strFinalDiagnosisCode
	
	FROM dbo.tlbVetCase	AS VC
	-- Get Diagnosis
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfDiagnosis0 ON rfDiagnosis0.idfsReference = VC.idfsTentativeDiagnosis
	 LEFT JOIN  dbo.trtDiagnosis AS diagnosis0 ON diagnosis0.idfsDiagnosis = VC.idfsTentativeDiagnosis
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfDiagnosis1 ON rfDiagnosis1.idfsReference = VC.idfsTentativeDiagnosis1	
	 LEFT JOIN  dbo.trtDiagnosis AS diagnosis1 ON diagnosis1.idfsDiagnosis = VC.idfsTentativeDiagnosis1
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfDiagnosis2 ON rfDiagnosis2.idfsReference = VC.idfsTentativeDiagnosis2
	 LEFT JOIN  dbo.trtDiagnosis AS diagnosis2 ON diagnosis2.idfsDiagnosis = VC.idfsTentativeDiagnosis2
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfDiagnosisf ON rfDiagnosisf.idfsReference = VC.idfsFinalDiagnosis
	 LEFT JOIN  dbo.trtDiagnosis AS diagnosisf ON diagnosisf.idfsDiagnosis = VC.idfsFinalDiagnosis
			
	WHERE  VC.idfVetCase = @ObjID
	AND  VC.intRowStatus = 0
			
