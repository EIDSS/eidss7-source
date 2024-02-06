
--*************************************************************
-- Name 				: USP_Vet_Diagnosis
-- Description			: Diagnosis details for Vet report
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
--
--Example of a call of procedure:
/*

exec Report.USP_Vet_Diagnosis 2356 , 'en-US' 
  
*/ 

CREATE  PROCEDURE [Report].[USP_Vet_Diagnosis]
    (
        @ObjID	AS BIGINT,
        @LangID AS NVARCHAR(10)
    )
AS

	SELECT		
		RD0.[name] AS strTentativeDiagnosis,
		RD1.[name] AS strTentativeDiagnosis1,
		RD2.[name] AS strTentativeDiagnosis2,
		RDF.[name] AS strFinalDiagnosis,
		VC.datTentativeDiagnosisDate,
		VC.datTentativeDiagnosis1Date,
		VC.datTentativeDiagnosis2Date,
		VC.datFinalDiagnosisDate,
		D0.strOIECode AS strTentativeDiagnosisCode,
		D1.strOIECode AS strTentativeDiagnosis1Code,
		D2.strOIECode AS strTentativeDiagnosis2Code,
		DF.strOIECode AS strFinalDiagnosisCode
	
	FROM dbo.tlbVetCase	AS VC
	-- Get Diagnosis
	 LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS RD0 ON RD0.idfsReference = VC.idfsTentativeDiagnosis
	 LEFT JOIN dbo.trtDiagnosis AS D0 ON D0.idfsDiagnosis = VC.idfsTentativeDiagnosis
	 LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019)AS RD1 ON RD1.idfsReference = VC.idfsTentativeDiagnosis1	
	 LEFT JOIN dbo.trtDiagnosis AS D1 ON D1.idfsDiagnosis = VC.idfsTentativeDiagnosis1
	 LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS RD2 ON RD2.idfsReference = VC.idfsTentativeDiagnosis2
	 LEFT JOIN dbo.trtDiagnosis AS D2 ON D2.idfsDiagnosis = VC.idfsTentativeDiagnosis2
	 LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS RDF ON RDF.idfsReference = VC.idfsFinalDiagnosis
	 LEFT JOIN dbo.trtDiagnosis AS DF ON DF.idfsDiagnosis = VC.idfsFinalDiagnosis
			
	WHERE  VC.idfVetCase = @ObjID
	AND  VC.intRowStatus = 0

