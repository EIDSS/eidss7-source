
   
--*************************************************************************
-- Name 				: dbo.USSP_HUM_REP_WHOEXPORT_AJ
--
-- Description			: SINT03 - WHO Export dbo ON Measles AND Rubella for GG.
-- 
-- Author               : Mandar Kulkarni
-- Revision History
--		Name			DATE       Change Detail

-- Testing code:

--Example of a call of PROCEDURE:
--GG
--exec dbo.[USSP_HUM_REP_WHOEXPORT_AJ] @LangID=N'en',@StartDate='20140101',@EndDate='20141231', @idfsDiagnosis = 9843460000000   
--*************************************************************************
CREATE  PROCEDURE [dbo].[USSP_HUM_REP_WHOEXPORT_AJ]
   	(
   		@LangID		AS NVARCHAR(50), 
   		@StartDate DATETIME,
   		@EndDate DATETIME,
   		@idfsDiagnosis BIGINT
   	)
AS	
   
   	
BEGIN
   	
DECLARE	@ResultTable	TABLE
(	  
 	idfCase						BIGINT NOT NULL PRIMARY KEY
   	, strCaseID					NVARCHAR(300) COLLATE database_default NOT NULL 
   	, intAreaID					INT NOT NULL 
   	, datDRash					DATE NULL
   	, intGenderID				INT NOT NULL 
   	, datDBirth					DATE NULL
   	, intAgeAtRashOnset			INT NULL
   	, intNumOfVaccines			INT NULL
   	, datDvaccine				DATETIME NULL
   	, datDNotification			DATETIME NULL
   	, datDInvestigation			DATETIME NULL
   	, intClinFever				INT NULL
   	, intClinCCC				INT NULL
   	, intClinRashDuration		INT NULL
   	, intClinOutcome			INT NULL
   	, intClinHospitalization	INT NULL
   	, intSrcInf					INT NULL
   	, intSrcOutbreakRelated		INT NULL
   	, strSrcOutbreakID			NVARCHAR(50) COLLATE database_default NULL default NULL
   	, intCompComplications		INT NULL
   	, intCompEncephalitis		INT NULL
   	, intCompPneumonia			INT NULL
   	, intCompMalnutrition		INT NULL
   	, intCompDiarrhoea			INT NULL
   	, intCompOther				INT NULL
   	, intFinalClassification	INT NULL
   	, datDSpecimen				DATETIME NULL
   	, intSpecimen				INT NULL
   	, datDLabResult				DATETIME NULL
   	, intMeaslesIgm				INT NULL
   	, intMeaslesVirusDetection	INT NULL		
   	, intRubellaIgm				INT NULL
   	, intRubellaVirusDetection	INT NULL
   	, strCommentsEpi			NVARCHAR(500) COLLATE database_default NULL 
)
   	
   		
   	
DECLARE 
   	  
   	@idfsCustomReportType			BIGINT,
   		
   	@FFP_DateOfOnset_M				BIGINT,
   	@FFP_DateOfOnset_R				BIGINT,  	
   			
   	@FFP_NumberOfReceivedDoses_M	BIGINT,
   	@FFP_NumberOfReceivedDoses_R	BIGINT,  		
   		
   	@FFP_DateOfLastVaccination_M	BIGINT,
   	@FFP_DateOfLastVaccination_R	BIGINT,  		
   		
   	@FFP_Fever_M					BIGINT,
   	   		
   	@FFP_Cough_M					BIGINT,
   		   		
   	@FFP_Coryza_M					BIGINT,
   	   		
   	@FFP_Conjunctivitis_M			BIGINT,
   	   		
   	@FFP_RashDuration_M				BIGINT,
   	@FFP_RashDuration_R				BIGINT,  		
   		
   	@FFP_SourceOfInfection_M		BIGINT,
   	@FFP_SourceOfInfection_R		BIGINT,  		
   		
   	@FFP_Encephalitis_M				BIGINT,
   	@FFP_Encephalitis_R				BIGINT,  		
   		  		
   	@FFP_Pneumonia_M				BIGINT,
   	@FFP_Pneumonia_R				BIGINT,  		
   		  		  		
   	@FFP_Diarrhoea_M				BIGINT,
     		  		  		
   	@FFP_Other_M					BIGINT,  		  		
   	@FFP_Other_R					BIGINT,  	 
   		 		
  	@idfsDiagnosis_Measles			BIGINT,
   	@idfsDiagnosis_Rubella			BIGINT,
   		
   	@idfsCountry					BIGINT
   		
   		
   	
SET @idfsCountry = 170000000
 				
			  	
SET @idfsCustomReportType = 10290027 /*WHO dbo - AJ&GG*/
   
--HCS FF - Rash onset DATE. / HCS FF- DATE of onset
SELECT @FFP_DateOfOnset_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_DateOfOnset_M'
AND intRowStatus = 0
   	
SELECT @FFP_DateOfOnset_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_DateOfOnset_R'
AND intRowStatus = 0
   	  
--HEI - Number of received doses (any vaccine WITH measles component) / HEI - Number of Measles vaccine doses received
SELECT @FFP_NumberOfReceivedDoses_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_NumberOfReceivedDoses_M'
AND intRowStatus = 0
   	
SELECT @FFP_NumberOfReceivedDoses_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_NumberOfReceivedDoses_R'
AND intRowStatus = 0  	
   	
--HEI - DATE of last vaccination/HEI - DATE of last Measles vaccine
SELECT @FFP_DateOfLastVaccination_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_DateOfLastVaccination_M'
AND intRowStatus = 0	
   	
SELECT @FFP_DateOfLastVaccination_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_DateOfLastVaccination_R'
AND intRowStatus = 0	  
   		
--HCS - Fever/HCS - Fever
SELECT @FFP_Fever_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Fever_M'
AND intRowStatus = 0
   	
     		
--HCS - Cough / Coryza / Conjunctivitis /HCS - Cough / Coryza / Conjunctivitis
SELECT @FFP_Cough_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Cough_M'
AND intRowStatus = 0	

   	
SELECT @FFP_Coryza_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Coryza_M'
AND intRowStatus = 0	
   	
    	
SELECT @FFP_Conjunctivitis_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Conjunctivitis_M'
AND intRowStatus = 0	
   	
    	
--HCS - Rash duration / HCS - Duration (days)
SELECT @FFP_RashDuration_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_RashDuration_M'
AND intRowStatus = 0
   	
SELECT @FFP_RashDuration_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_RashDuration_R'
AND intRowStatus = 0  	
   		
--EPI - Source of infection / EPI - Source of infection
SELECT @FFP_SourceOfInfection_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_SourceOfInfection_M'
AND intRowStatus = 0		
   	
SELECT @FFP_SourceOfInfection_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_SourceOfInfection_R'
AND intRowStatus = 0	  	
   	
--HCS - Encephalitis / HCS - Encephalitis
SELECT @FFP_Encephalitis_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Encephalitis_M'
AND intRowStatus = 0		
   	
SELECT @FFP_Encephalitis_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Encephalitis_R'
AND intRowStatus = 0	  	
   	
--HCS - Pneumonia / HCS - Pneumonia
SELECT @FFP_Pneumonia_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Pneumonia_M'
AND intRowStatus = 0	
   	
SELECT @FFP_Pneumonia_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Pneumonia_R'
AND intRowStatus = 0	  	
   		
--HCS - Diarrhoea / HCS - Diarrhoea
SELECT @FFP_Diarrhoea_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Diarrhoea_M'
AND intRowStatus = 0		

--HCS - Other (specify) / HCS - Other
SELECT @FFP_Other_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Other_M'
AND intRowStatus = 0	 
   	
SELECT @FFP_Other_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Other_R'
AND intRowStatus = 0	   	
   	
   	 	
--idfsDiagnosis for:
--Measles
SELECT TOP 1 @idfsDiagnosis_Measles = d.idfsDiagnosis
FROM trtDiagnosis d
   	INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt
   	ON dgrt.idfsDiagnosis = d.idfsDiagnosis
   	AND dgrt.idfsCustomReportType = @idfsCustomReportType
   	  
   	INNER JOIN dbo.trtReportDiagnosisGroup dg
   	ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
   	AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Measles'
    WHERE d.intRowStatus = 0
   	
--Rubella
SELECT TOP 1 @idfsDiagnosis_Rubella = d.idfsDiagnosis
FROM trtDiagnosis d
   	INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt
   	ON dgrt.idfsDiagnosis = d.idfsDiagnosis
   	AND dgrt.idfsCustomReportType = @idfsCustomReportType
   	  
   	INNER JOIN dbo.trtReportDiagnosisGroup dg
   	ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
   	AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Rubella'
    WHERE d.intRowStatus = 0	     
   	
   	
DECLARE @AreaIDs TABLE
(
	intAreaID INT,
	idfsRegion BIGINT,
	idfsRayon BIGINT
)

INSERT INTO @AreaIDs (intAreaID, idfsRegion, idfsRayon)
SELECT		
CAST(tgra.varValue AS INT), reg.idfsReference, ray.idfsReference
FROM trtGISBaseReferenceAttribute tgra
	INNER JOIN trtAttributeType tat
	ON tat.idfAttributeType = tgra.idfAttributeType
	AND tat.strAttributeTypeName = 'WHOrep_specific_gis_rayon'
  INNER JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*Rayon*/) ray
	ON ray.idfsReference = tgra.idfsGISBaseReference
  INNER JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*Region*/) reg
  ON ray.node.GetAncestor(1) = reg.node AND reg.intRowStatus = 0
 	    
   	
;WITH hc_obs
AS (
SELECT 
   	hc.idfHumanCase,
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_M.varValue, 'BaseType') AS NVARCHAR) like N'%DATE%' OR
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_M.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset_M.varValue AS NVARCHAR)) = 1 )	)  
 			THEN dbo.FN_GBL_DATECUTTIME(CAST(ap_DateOfOnset_M.varValue AS DATETIME))
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella AND 
 			(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_R.varValue, 'BaseType') AS NVARCHAR) like N'%DATE%' OR
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_R.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset_R.varValue AS NVARCHAR)) = 1 )	)  
 			THEN dbo.FN_GBL_DATECUTTIME(CAST(ap_DateOfOnset_R.varValue AS DATETIME))
 		ELSE NULL
   	END AS DateOfOnset,
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles 
 			THEN CAST(ap_NumberOfReceivedDoses_M.varValue AS NVARCHAR(50)) 
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella 
  			THEN CAST(ap_NumberOfReceivedDoses_R.varValue AS NVARCHAR(50))
 		ELSE NULL
   	END AS NumberOfReceivedDoses,
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			CAST(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination_M.varValue, 'BaseType') AS NVARCHAR) like N'%DATE%' OR
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination_M.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfLastVaccination_M.varValue AS NVARCHAR)) = 1 )	
 			THEN dbo.FN_GBL_DATECUTTIME(CAST(ap_DateOfLastVaccination_M.varValue AS DATETIME))
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella AND 
 			CAST(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination_R.varValue, 'BaseType') AS NVARCHAR) like N'%DATE%' OR
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination_R.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfLastVaccination_R.varValue AS NVARCHAR)) = 1 )	
 			THEN dbo.FN_GBL_DATECUTTIME(CAST(ap_DateOfLastVaccination_R.varValue AS DATETIME))
 		ELSE NULL
   	END AS DateOfLastVaccination,
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Fever_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Fever_M.varValue AS BIGINT)
 		ELSE NULL
   	END AS Fever,
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Cough_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Cough_M.varValue AS BIGINT)
 		ELSE NULL
   	END AS Cough,
  		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Coryza_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Coryza_M.varValue AS BIGINT)
 		ELSE NULL
   	END AS Coryza,  		
 
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Conjunctivitis_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Conjunctivitis_M.varValue AS BIGINT)
 		ELSE NULL
   	END AS Conjunctivitis,  
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles 
 			THEN CAST(ap_RashDuration_M.varValue AS NVARCHAR(50))
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella 
 			THEN CAST(ap_RashDuration_R.varValue AS NVARCHAR(50))
 		ELSE NULL
   	END AS RashDuration,	
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_SourceOfInfection_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_SourceOfInfection_M.varValue AS BIGINT)
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella AND 
 			SQL_VARIANT_PROPERTY(ap_SourceOfInfection_R.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_SourceOfInfection_R.varValue AS BIGINT)
 		ELSE NULL
   	END AS SourceOfInfection,   
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Encephalitis_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Encephalitis_M.varValue AS BIGINT)
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella AND 
 			SQL_VARIANT_PROPERTY(ap_Encephalitis_R.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Encephalitis_R.varValue AS BIGINT)
 		ELSE NULL
   	END AS Encephalitis,    
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Pneumonia_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Pneumonia_M.varValue AS BIGINT)
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella AND 
 			SQL_VARIANT_PROPERTY(ap_Pneumonia_R.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Pneumonia_R.varValue AS BIGINT)
 		ELSE NULL
   	END AS Pneumonia,    	

   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 			SQL_VARIANT_PROPERTY(ap_Diarrhoea_M.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
 			THEN CAST(ap_Diarrhoea_M.varValue AS BIGINT)
 		ELSE NULL
   	END AS Diarrhoea,    
   		
   	CASE
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles 
 			THEN CAST(ap_Other_M.varValue AS NVARCHAR(500))
 		WHEN ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella 
 			THEN CAST(ap_Other_R.varValue AS NVARCHAR(500))
 		ELSE NULL
   	END AS Other	  		  		  		  			
 
    FROM tlbHumanCase hc
 	INNER JOIN tlbHuman h
 	ON hc.idfHuman = h.idfHuman AND  h.intRowStatus = 0
 		   
 	LEFT JOIN tstSite ts
 	ON ts.idfsSite = hc.idfsSite
 	AND ts.intRowStatus = 0
 	AND ts.intFlags = 1         
 		     
	LEFT JOIN tlbObservation ob_CS 
		ON	ob_CS.idfObservation = hc.idfCSObservation
 		AND ob_CS.intRowStatus = 0
 			
	LEFT JOIN tlbObservation ob_EPI 
		ON	ob_EPI.idfObservation = hc.idfEpiObservation
 		AND ob_EPI.intRowStatus = 0 	 		     
 		     
    
   	---     
	
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_DateOfOnset_M
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_DateOfOnset_M
 		 		
  	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_DateOfOnset_R
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_DateOfOnset_R 	
 		 		
 				
 	---
	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_EPI.idfObservation
 			AND	ap.idfsParameter = @FFP_NumberOfReceivedDoses_M
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_NumberOfReceivedDoses_M 		
		
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_EPI.idfObservation
 			AND	ap.idfsParameter = @FFP_NumberOfReceivedDoses_R
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_NumberOfReceivedDoses_R 	 		 			
     			
    ---		
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_EPI.idfObservation
 			AND	ap.idfsParameter = @FFP_DateOfLastVaccination_M
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_DateOfLastVaccination_M 	
 
  	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_EPI.idfObservation
 			AND	ap.idfsParameter = @FFP_DateOfLastVaccination_R
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_DateOfLastVaccination_R  		   			
   			
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Fever_M
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Fever_M 	
 		
   	---
	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Cough_M
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Cough_M 	
 		
  	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Coryza_M
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Coryza_M
 
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Conjunctivitis_M	
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Conjunctivitis_M

   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_RashDuration_M	
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_RashDuration_M
 
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_RashDuration_R		
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_RashDuration_R 		
   		
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_EPI.idfObservation
 			AND	ap.idfsParameter = @FFP_SourceOfInfection_M		
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_SourceOfInfection_M
 
   	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_EPI.idfObservation
 			AND	ap.idfsParameter = @FFP_SourceOfInfection_R			
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_SourceOfInfection_R 				
   		
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Encephalitis_M				
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Encephalitis_M
 
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Encephalitis_R					
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Encephalitis_R
	
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Pneumonia_M					
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Pneumonia_M
 
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Pneumonia_R						
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Pneumonia_R 			
 	
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Diarrhoea_M						
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Diarrhoea_M
 
   	---
 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Other_M							
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Other_M
 

 	OUTER APPLY ( 
 		SELECT TOP 1 
 			ap.varValue
 		FROM tlbActivityParameters ap
 		WHERE	ap.idfObservation = ob_CS.idfObservation
 			AND	ap.idfsParameter = @FFP_Other_R								
 			AND ap.intRowStatus = 0
 		ORDER BY ap.idfRow ASC	
 	) AS  ap_Other_R 		
WHERE 	
 	ts.idfsSite is NULL AND
 	ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis AND
 	(
 	-- Measles
 	(
 		ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles AND 
 		(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_M.varValue, 'BaseType') AS NVARCHAR) like N'%DATE%'  OR
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_M.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset_M.varValue AS NVARCHAR)) = 1 )	 
		) 		  
 		AND 
 		CAST(ap_DateOfOnset_M.varValue AS DATETIME) is NOT NULL AND
 		CAST(ap_DateOfOnset_M.varValue AS DATETIME) >= @StartDate AND
 		CAST(ap_DateOfOnset_M.varValue AS DATETIME) <  @EndDate
 	) 
 	OR 
 	-- Rubella
 	(
 		ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella AND 
 		(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_R.varValue, 'BaseType') AS NVARCHAR) like N'%DATE%'   OR
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset_R.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset_R.varValue AS NVARCHAR)) = 1 )	 
		) 	
		AND 
 		CAST(ap_DateOfOnset_R.varValue AS DATETIME) is NOT NULL AND
 		CAST(ap_DateOfOnset_R.varValue AS DATETIME) >= @StartDate AND
 		CAST(ap_DateOfOnset_R.varValue AS DATETIME) <  @EndDate
 	)
 	)		
), -- END of hc_obs
 	
hc_table
AS 
(
 	SELECT DISTINCT
 		hc.idfHumanCase AS idfCase,
 		'AZE' + hc.strCaseID AS strCaseID,
 		aid.intAreaID, 
 		hc_obs.DateOfOnset AS datDRash, 
 		CASE 
 			WHEN h.idfsHumanGender = 10043001 THEN 2
 			WHEN h.idfsHumanGender = 10043002 THEN 1
 			ELSE 4
 		END AS intGenderID, 
      	dbo.FN_GBL_DATECUTTIME(h.datDateofBirth) AS datDBirth, 
      	CASE
 			WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
 					AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 200)
 				THEN	hc.intPatientAge
 			WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042002	-- Months
 					AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 60)
 				THEN	CAST(hc.intPatientAge / 12 AS INT)
 			WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042001	-- Days
 					AND (ISNULL(hc.intPatientAge, -1) >= 0)
 				THEN	0
 			ELSE	NULL
 		END	 AS intAgeAtRashOnset,     	
 			
 		ISNULL(CASE WHEN isnumeric(hc_obs.NumberOfReceivedDoses) = 1 AND CAST(hc_obs.NumberOfReceivedDoses AS varchar) NOT in ('.', ',', '-', '+', '$')
 					THEN --CAST(hc_obs.NumberOfReceivedDoses AS INT)
 							CAST(CAST(replace(hc_obs.NumberOfReceivedDoses,',','.') AS decimal) AS INT)
 					ELSE 9 END
 			, 9)	 AS intNumOfVaccines, 
 				
 		hc_obs.DateOfLastVaccination AS datDvaccine, 			
     	dbo.FN_GBL_DATECUTTIME(hc.datNotificationDate) AS datDNotification, 
     	dbo.FN_GBL_DATECUTTIME(hc.datInvestigationStartDate) AS datDInvestigation, 
     		
     	CASE hc_obs.Fever
 			WHEN 25460000000 THEN 1
 			WHEN 25640000000 THEN 2
 			WHEN 25660000000 THEN 9
 			ELSE NULL
 		END	 AS intClinFever, 
 			
     	CASE 
     		CASE 
     			WHEN hc_obs.Cough = 25460000000 OR hc_obs.Coryza = 25460000000 OR hc_obs.Conjunctivitis = 25460000000 THEN 25460000000
     			WHEN hc_obs.Cough = 25640000000 AND hc_obs.Coryza = 25640000000 AND hc_obs.Conjunctivitis = 25640000000 THEN 25640000000
     			ELSE 25660000000
     		END		
 			WHEN 25460000000 THEN 1
 			WHEN 25640000000 THEN 2
 			ELSE 9
 		END	 AS intClinCCC, 			    			
 		CASE WHEN isnumeric(hc_obs.RashDuration) = 1 AND CAST(hc_obs.RashDuration AS varchar) NOT in ('.', ',', '-', '+', '$')
 			THEN --CAST(hc_obs.RashDuration AS INT) 
 					CAST(CAST(replace(hc_obs.RashDuration,',','.') AS decimal) AS INT)
 			ELSE NULL END AS intClinRashDuration,
    			
 		CASE hc.idfsOutcome
 			WHEN 10770000000 THEN 1
 			WHEN 10760000000 THEN 2
 			WHEN 10780000000 THEN 3
 			ELSE 3
 		END AS intClinOutcome, 
 			
     	CASE hc.idfsYNHospitalization   
   			WHEN 10100001 THEN 1
   			WHEN 10100002 THEN 2
   			WHEN 10100003 THEN 9
   			ELSE NULL
   		END AS intClinHospitalization, 

 		-- AZ
 		-- If Yes, THEN Imported, if No, THEN Endemic, If Unknown OR NOT filled, THEN Unknown 
 		--1 Imported
 		--2 Endemic
 		--3 Import-related
 		--9 Unknown
     	CASE hc_obs.SourceOfInfection 
     		-- az
 			WHEN 25460000000 THEN 1 -- Yes = Imported
 			WHEN 25640000000 THEN 2 -- No = Endemic
 			WHEN 25660000000 THEN 9 -- Unknown = Unknown
 			ELSE 9
 		END	 AS intSrcInf, 
 			
 			
 		CASE hc.idfsYNRelatedToOutbreak
   			WHEN 10100001 THEN 1
   			WHEN 10100002 THEN 2
   			WHEN 10100003 THEN 9
   			ELSE NULL
   		END AS intSrcOutbreakRelated, 
      
		'' AS strSrcOutbreakID,
			
    	CASE 
     		CASE 
     			--AJ
     			WHEN( hc_obs.Encephalitis = 25460000000 OR 
     					hc_obs.Pneumonia =  25460000000 OR 
     					hc_obs.Diarrhoea =  25460000000) 
     				AND @idfsCountry = 170000000 THEN 25460000000
     				
     			WHEN ( hc_obs.Encephalitis = 25640000000 AND
     					hc_obs.Pneumonia =   25640000000 AND 
     					(hc_obs.Diarrhoea =  25640000000 OR ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella)
     				) 
     				AND @idfsCountry = 170000000 THEN 25640000000
     			ELSE 25660000000
     		END		
 			WHEN 25460000000 THEN 1
 			WHEN 25640000000 THEN 2
 			WHEN 25660000000 THEN 9
 			ELSE NULL
 		END	 AS intCompComplications, 		 					
			
			
     	CASE hc_obs.Encephalitis 
 			WHEN 25460000000 THEN 1 
 			WHEN 25640000000 THEN 2 
 			WHEN 25660000000 THEN 9 		
 			ELSE NULL
 		END	 AS intCompEncephalitis, 				
			
     	CASE hc_obs.Pneumonia 
 			WHEN 25460000000 THEN 1 
 			WHEN 25640000000 THEN 2 
 			WHEN 25660000000 THEN 9 		
 			ELSE NULL
 		END	 AS intCompPneumonia, 				
        
		NULL AS intCompMalnutrition, 
			
     	CASE hc_obs.Diarrhoea 
 			WHEN 25460000000 THEN 1 
 			WHEN 25640000000 THEN 2 
 			WHEN 25660000000 THEN 9 		
 			ELSE NULL
 		END	 AS intCompDiarrhoea, 		
 			
 		CASE WHEN len(hc_obs.Other) > 0 THEN 1 ELSE 2 END AS intCompOther, 		
                
   		CASE 
   			WHEN hc.idfsFinalCaseStatus = 370000000 /*NOT a CASE - casRefused*/
   					THEN 0
   			WHEN hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
   				AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles
   				AND hc.blnLabDiagBasis = 1
   					THEN 1
   			WHEN hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
   				AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles
   				AND ISNULL(hc.blnLabDiagBasis, 0) = 0
   				AND hc.blnEpiDiagBasis = 1
   					THEN 2
   			WHEN hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
   				AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles
   				AND ISNULL(hc.blnLabDiagBasis, 0) = 0
   				AND ISNULL(hc.blnEpiDiagBasis, 0) = 0
   				AND hc.blnClinicalDiagBasis = 1
   					THEN 3
   			WHEN hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
   				AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella
   				AND hc.blnLabDiagBasis = 1
   					THEN 6
   			WHEN hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
   				AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella
   				AND ISNULL(hc.blnLabDiagBasis, 0) = 0
   				AND hc.blnEpiDiagBasis = 1
   					THEN 7
   			WHEN hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
   				AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella
   				AND ISNULL(hc.blnLabDiagBasis, 0) = 0
   				AND ISNULL(hc.blnEpiDiagBasis, 0) = 0
   				AND hc.blnClinicalDiagBasis = 1
   					THEN 8
   			WHEN hc.idfsFinalCaseStatus = 360000000 /*Probable CASE*/
   				OR hc.idfsFinalCaseStatus = 380000000 /*Suspect*/
   					THEN NULL
   			ELSE NULL
   		END intFinalClassification,        
        
        
        CASE 
            WHEN hc.idfsYNSpecimenCollected = 10100001 
				THEN material.datFieldCollectionDate
				ELSE NULL
        END AS datDSpecimen,    
            
            
			--Dry drop of Blood=4 Dry blood spot, 
			--Serum=1 Serum, 
			--Saliva=2 Saliva/oral fluid, 
			--Nasopharyngal swab=3 Nasopharyngal swab, 
			--Urine=5 Urine, 
			--in other CASE = 7 Other specimen.
		CASE
			ISNULL(CASE 
				WHEN hc.idfsYNSpecimenCollected = 10100001 
					THEN material.idfsSampleType
					ELSE NULL
			END, -1)
			--AJ
			WHEN 49558310000000	/*Serum*/  THEN 1 --Serum
			WHEN 7721970000000	/*Saliva*/ THEN 2 --Saliva/oral fluid
			WHEN 7721900000000	/*Nasopharyngal swab*/ THEN 3 --Nasopharyngeal swab
			WHEN 7721620000000	/*Dry drop of Blood*/ THEN 4 --Dry blood spot
			WHEN 7722180000000	/*Urine*/ THEN 5 --Urine				
			WHEN -1 THEN NULL
			ELSE 7
		END AS intSpecimen,    

		CASE 
            WHEN hc.idfsYNSpecimenCollected = 10100001 
				THEN material.datConcludedDate
				ELSE NULL
        END AS datDLabResult,    			            

        CASE
			ISNULL(CASE 
				WHEN hc.idfsYNSpecimenCollected = 10100001 AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Measles 
					THEN material.idfsTestResult
					ELSE NULL
			END, -1)
			--AJ
			WHEN 7723820000000 THEN 4--Indeterminate
			WHEN 7723940000000 THEN 2--Negative
			WHEN 7723960000000 THEN 1--Positive
			WHEN -1 THEN NULL
			ELSE 4
		END AS intMeaslesIgm,    
			
		NULL AS intMeaslesVirusDetection,
			
		CASE
			ISNULL(CASE 
				WHEN hc.idfsYNSpecimenCollected = 10100001 AND ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis_Rubella 
					THEN material.idfsTestResult
					ELSE NULL
			END, -1)
			--AJ
			WHEN 7723820000000 THEN 4--Indeterminate
			WHEN 7723940000000 THEN 2--Negative
			WHEN 7723960000000 THEN 1--Positive
			WHEN -1 THEN NULL
			ELSE 4
		END AS intRubellaIgm,  
		NULL AS intRubellaVirusDetection,
		'Outbreak ID: ' + to1.strOutbreakID AS strCommentsEpi
    			      			
    FROM tlbHumanCase hc
	INNER JOIN hc_obs
	ON hc_obs.idfHumanCase = hc.idfHumanCase

		INNER JOIN (tlbHuman h
			INNER JOIN tlbGeoLocation gl
			ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
		     
			INNER JOIN @AreaIDs aid
			ON aid.idfsRegion = gl.idfsRegion AND 
			(aid.idfsRayon = gl.idfsRayon OR aid.idfsRayon is NULL)
		)    
		ON hc.idfHuman = h.idfHuman AND
		h.intRowStatus = 0
         
        LEFT JOIN tlbOutbreak to1
        ON to1.idfOutbreak = hc.idfOutbreak
        AND to1.intRowStatus = 0   
            
		LEFT JOIN tstSite ts
		ON ts.idfsSite = hc.idfsSite
		AND ts.intRowStatus = 0
		AND ts.intFlags = 1         

	OUTER APPLY
		(SELECT TOP 1 
				dbo.FN_GBL_DATECUTTIME(tt.datConcludedDate) AS datConcludedDate,
				m.idfsSampleType AS idfsSampleType,
				m.datFieldCollectionDate,
				tt.idfsTestResult
                FROM tlbMaterial m
					INNER JOIN tlbTesting tt
					ON tt.idfMaterial = m.idfMaterial
					AND tt.intRowStatus = 0
					AND tt.datConcludedDate is NOT NULL
					INNER JOIN trtTestTypeForCustomReport ttcr
					ON ttcr.idfsTestName = tt.idfsTestName
					AND ttcr.intRowStatus = 0
					AND ttcr.idfsCustomReportType = @idfsCustomReportType
                WHERE m.idfHuman = h.idfHuman
                AND m.intRowStatus = 0
                ORDER BY ISNULL(tt.datConcludedDate, '19000101') desc, m.datFieldCollectionDate desc
            )	AS material	   
 	 		
  	
WHERE	
 		ts.idfsSite is NULL AND
 		ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis AND
 		hc_obs.DateOfOnset >= @StartDate AND
 		hc_obs.DateOfOnset <  @EndDate
		AND hc.idfHumanCase = (SELECT TOP 1 idfHumanCase FROM tlbHumanCase thc WHERE thc.idfCSObservation = hc.idfCSObservation and thc.idfsFinalDiagnosis = @idfsDiagnosis)
 
) -- END of hc_table
 		
 		

   	
   	
INSERT INTO	@ResultTable
    (	
 		idfCase
 	, strCaseID	
 	, intAreaID	
   	, datDRash	
   	, intGenderID
   	, datDBirth	
   	, intAgeAtRashOnset	
   	, intNumOfVaccines	
   	, datDvaccine	
   	, datDNotification	
   	, datDInvestigation	
   	, intClinFever		
   	, intClinCCC	
   	, intClinRashDuration	
   	, intClinOutcome		
   	, intClinHospitalization	
   	, intSrcInf				
   	, intSrcOutbreakRelated		
   	, strSrcOutbreakID		
   	, intCompComplications	
   	, intCompEncephalitis	
   	, intCompPneumonia		
   	, intCompMalnutrition	
   	, intCompDiarrhoea		
   	, intCompOther		
   	, intFinalClassification
   	, datDSpecimen			
   	, intSpecimen			
   	, datDLabResult			
   	, intMeaslesIgm			
   	, intMeaslesVirusDetection	
   	, intRubellaIgm				
   	, intRubellaVirusDetection
   	, strCommentsEpi			
)
SELECT 
 	idfCase
 	, strCaseID	
 	, intAreaID	
   	, datDRash	
   	, intGenderID
   	, datDBirth	
   	, intAgeAtRashOnset	
   	, intNumOfVaccines	
   	, datDvaccine	
   	, datDNotification	
   	, datDInvestigation	
   	, intClinFever		
   	, intClinCCC	
   	, intClinRashDuration	
   	, intClinOutcome		
   	, intClinHospitalization	
   	, intSrcInf				
   	, intSrcOutbreakRelated		
   	, strSrcOutbreakID		
   	, intCompComplications	
   	, intCompEncephalitis	
   	, intCompPneumonia		
   	, intCompMalnutrition	
   	, intCompDiarrhoea		
   	, intCompOther		
   	, intFinalClassification
   	, datDSpecimen			
   	, intSpecimen			
   	, datDLabResult			
   	, intMeaslesIgm			
   	, intMeaslesVirusDetection	
   	, intRubellaIgm		
   	, intRubellaVirusDetection		
   	, strCommentsEpi	 
 	
 	
FROM hc_table
     
   
  

  		
	
SELECT * FROM @ResultTable
ORDER BY datDRash, strCaseID	
END


