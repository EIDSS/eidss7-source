
--*************************************************************************
-- Name 				: dbo.USP_HUM_REP_WHOEXPORT_GG
--
-- Description			: SINT03 - WHO Export dbo ON Measles AND Rubella for GG.
-- 
-- Author               : Mandar Kulkarni
-- Revision History
--		Name			Date       Change Detail

-- Testing code:

--Example of a call of PROCEDURE:
--GG
--exec dbo.[USP_HUM_REP_WHOEXPORT_GG] @LangID=N'en',@StartDate='20140101',@EndDate='20141231', @idfsDiagnosis = 9843460000000   
--*************************************************************************

CREATE  PROCEDURE [dbo].[USP_HUM_REP_WHOEXPORT_GG]
 (
		@LangID		AS NVARCHAR(50), 
		@StartDate DATETIME,
		@EndDate DATETIME,
		@idfsDiagnosis BIGINT
 )
AS	

BEGIN


DECLARE	@cmd	NVARCHAR(4000)

-- Drop temporary tables
IF Object_ID('tempdb..#HumanCasesToExport') IS NOT NULL
BEGIN
	SET	@cmd = N'drop TABLE #HumanCasesToExport'
	EXEC sp_executesql @cmd
END

IF Object_ID('tempdb..#FFToExport') IS NOT NULL
BEGIN
	SET	@cmd = N'drop TABLE #FFToExport'
	EXEC sp_executesql @cmd
END

IF Object_ID('tempdb..#ResultTable') IS NOT NULL
BEGIN
	SET	@cmd = N'drop TABLE #ResultTable'
	EXEC sp_executesql @cmd
END

-- CREATE temporary tables
IF Object_ID('tempdb..#HumanCasesToExport') IS NULL
CREATE TABLE #HumanCasesToExport
(	idfHumanCase				BIGINT NOT NULL PRIMARY KEY,
	idfHuman					BIGINT NOT NULL,
	idfCRAddress				BIGINT NULL,
	idfsDiagnosis				BIGINT NOT NULL,
	idfCSObservation			BIGINT NULL,
	idfEpiObservation			BIGINT NULL,
	datDateOnset				DATETIME NOT NULL,
	idfOutbreak					BIGINT NULL,
	NumberOfReceivedDoses		NVARCHAR(50) collate Cyrillic_General_CI_AS NULL,
	DateOfLastVaccination		DATETIME NULL,
	Fever						BIGINT NULL,
	Cough						BIGINT NULL,
	Coryza						BIGINT NULL,  		
	Conjunctivitis				BIGINT NULL,  
	RashDuration				NVARCHAR(50) collate Cyrillic_General_CI_AS NULL,	
	SourceOfInfection			BIGINT NULL,   
	Complications				BIGINT NULL,    
	Encephalitis				BIGINT NULL,    
	Pneumonia					BIGINT NULL,    	
	Diarrhoea					BIGINT NULL,    
	Other						NVARCHAR(500) collate Cyrillic_General_CI_AS NULL,	
	datConcludedDate			DATETIME NULL,
	idfsSampleType				BIGINT NULL,
	datFieldCollectionDate		DATETIME NULL,
	idfsTestResult				BIGINT NULL,
	idfsTestStatus				BIGINT NULL,
	idfTesting					BIGINT NULL
)
DELETE FROM #HumanCasesToExport

IF Object_ID('tempdb..#FFToExport') IS NULL
CREATE TABLE #FFToExport
(	idfActivityParameters		BIGINT NOT NULL PRIMARY KEY,
	idfsParameter				BIGINT NOT NULL,
	idfObservation				BIGINT NOT NULL,
	idfRow						BIGINT NOT NULL,
	varValue					sql_variant NULL
)
DELETE FROM #FFToExport

IF Object_ID('tempdb..#ResultTable') IS NULL
CREATE TABLE	#ResultTable
(	  
	  idfCase					BIGINT NOT NULL PRIMARY KEY
	, strCaseID					NVARCHAR(300) collate database_default NOT NULL 
	, intAreaID					INT NOT NULL 
	, datDRash					date NULL
	, intGenderID				INT NOT NULL 
	, datDBirth					date NULL
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
	, strSrcOutbreakID			NVARCHAR(50) collate database_default NULL default NULL
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
	, strCommentsEpi			NVARCHAR(500) collate database_default NULL 
)
DELETE FROM #ResultTable

DECLARE 
  
	@idfsSummaryReportType			BIGINT,
	
	
	@FFP_DateOfOnset_M				BIGINT,
	@FFP_DateOfOnset_R				BIGINT,  	
		
	@FFP_NumberOfReceivedDoses_M	BIGINT,
	@FFP_NumberOfReceivedDoses_R	BIGINT,  		
	
	@FFP_DateOfLastVaccination_M	BIGINT,
	@FFP_DateOfLastVaccination_R	BIGINT,  		
	
	@FFP_Fever_M					BIGINT,
	@FFP_Fever_R					BIGINT,  		
	
	@FFP_Cough_M					BIGINT,
	@FFP_Cough_R					BIGINT,  	
	
	@FFP_Coryza_M					BIGINT,
	@FFP_Coryza_R					BIGINT,  	  	
	
	@FFP_Conjunctivitis_M			BIGINT,
	@FFP_Conjunctivitis_R			BIGINT,  	   				
	
	@FFP_RashDuration_M				BIGINT,
	@FFP_RashDuration_R				BIGINT,  		
	
	@FFP_SourceOfInfection_M		BIGINT,
	@FFP_SourceOfInfection_R		BIGINT,  		
	
	@FFP_Complications_M			BIGINT,
	@FFP_Complications_R			BIGINT,  		

	@FFP_Encephalitis_M				BIGINT,
	@FFP_Encephalitis_R				BIGINT,  		
	  		
	@FFP_Pneumonia_M				BIGINT,
	@FFP_Pneumonia_R				BIGINT,  		
	  		  		
	@FFP_Diarrhoea_M				BIGINT,
	--@FFP_Diarrhoea_R				BIGINT,  		
	  		  		
	@FFP_Other_M					BIGINT,  		  		
	--@FFP_Other_R					BIGINT,  	 
	 		
	@idfsDiagnosis_Measles			BIGINT,
	@idfsDiagnosis_Rubella			BIGINT
	
			  	
SET @idfsSummaryReportType = 10290027 /*WHO dbo - AJ&GG*/

--HCS FF - Rash onset date. / HCS FF- Date of onset
SELECT @FFP_DateOfOnset_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_DateOfOnset_M'
AND intRowStatus = 0

SELECT @FFP_DateOfOnset_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_DateOfOnset_R'
AND intRowStatus = 0
  
--HEI - Number of received doses (any vaccine with measles component) / HEI - Number of Measles vaccine doses received
SELECT @FFP_NumberOfReceivedDoses_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_NumberOfReceivedDoses_M'
AND intRowStatus = 0

SELECT @FFP_NumberOfReceivedDoses_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_NumberOfReceivedDoses_R'
AND intRowStatus = 0  	

--HEI - Date of last vaccination/HEI - Date of last Measles vaccine
SELECT @FFP_DateOfLastVaccination_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_DateOfLastVaccination_M'
AND intRowStatus = 0	

SELECT @FFP_DateOfLastVaccination_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_DateOfLastVaccination_R'
AND intRowStatus = 0	  
	
--HCS - Fever/HCS - Fever
SELECT @FFP_Fever_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Fever_M'
AND intRowStatus = 0

SELECT @FFP_Fever_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Fever_R'
AND intRowStatus = 0  	
	
--HCS - Cough / Coryza / Conjunctivitis /HCS - Cough / Coryza / Conjunctivitis
SELECT @FFP_Cough_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Cough_M'
AND intRowStatus = 0	

SELECT @FFP_Cough_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Cough_R'
AND intRowStatus = 0	 


SELECT @FFP_Coryza_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Coryza_M'
AND intRowStatus = 0	

SELECT @FFP_Coryza_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Coryza_R'
AND intRowStatus = 0	  	


SELECT @FFP_Conjunctivitis_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Conjunctivitis_M'
AND intRowStatus = 0	

SELECT @FFP_Conjunctivitis_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Conjunctivitis_R'
AND intRowStatus = 0	  	


--HCS - Rash duration / HCS - Duration (days)
SELECT @FFP_RashDuration_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_RashDuration_M'
AND intRowStatus = 0

SELECT @FFP_RashDuration_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_RashDuration_R'
AND intRowStatus = 0  	
	
--EPI - Source of infection / EPI - Source of infection
SELECT @FFP_SourceOfInfection_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_SourceOfInfection_M'
AND intRowStatus = 0		

SELECT @FFP_SourceOfInfection_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_SourceOfInfection_R'
AND intRowStatus = 0	  	

--HCS - Complications / HCS - Complications
SELECT @FFP_Complications_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Complications_M'
AND intRowStatus = 0		

SELECT @FFP_Complications_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Complications_R'
AND intRowStatus = 0		  

--HCS - Encephalitis / HCS - Encephalitis
SELECT @FFP_Encephalitis_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Encephalitis_M'
AND intRowStatus = 0		

SELECT @FFP_Encephalitis_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Encephalitis_R'
AND intRowStatus = 0	  	

--HCS - Pneumonia / HCS - Pneumonia
SELECT @FFP_Pneumonia_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Pneumonia_M'
AND intRowStatus = 0	

SELECT @FFP_Pneumonia_R = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Pneumonia_R'
AND intRowStatus = 0	  	
	
--HCS - Diarrhoea / HCS - Diarrhoea
SELECT @FFP_Diarrhoea_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Diarrhoea_M'
AND intRowStatus = 0		

--SELECT @FFP_Diarrhoea_R = idfsFFObject FROM trtFFObjectForCustomReport
--WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Diarrhoea_R'
--AND intRowStatus = 0		  	

--HCS - Other (specify) / HCS - Other
SELECT @FFP_Other_M = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Other_M'
AND intRowStatus = 0	 

--SELECT @FFP_Other_R = idfsFFObject FROM trtFFObjectForCustomReport
--WHERE idfsCustomReportType = @idfsSummaryReportType AND strFFObjectAlias = 'FFP_Other_R'
--AND intRowStatus = 0	   	

 	
--idfsDiagnosis for:
--Measles
SELECT top 1 @idfsDiagnosis_Measles = d.idfsDiagnosis
FROM trtDiagnosis d
  INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt
  ON dgrt.idfsDiagnosis = d.idfsDiagnosis
  AND dgrt.idfsCustomReportType = @idfsSummaryReportType
  
  INNER JOIN dbo.trtReportDiagnosisGroup dg
  ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
  AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Measles'
 WHERE d.intRowStatus = 0

--Rubella
SELECT top 1 @idfsDiagnosis_Rubella = d.idfsDiagnosis
FROM trtDiagnosis d
  INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt
  ON dgrt.idfsDiagnosis = d.idfsDiagnosis
  AND dgrt.idfsCustomReportType = @idfsSummaryReportType
  
  INNER JOIN dbo.trtReportDiagnosisGroup dg
  ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
  AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Rubella'
 WHERE d.intRowStatus = 0	


 DECLARE @AreaIDs TABLE
 (
 intAreaID INT,
 idfsRegion BIGINT
 )

INSERT INTO @AreaIDs (intAreaID, idfsRegion)
SELECT		
CAST(tgra.varValue AS INT), gr.idfsRegion
FROM trtGISBaseReferenceAttribute tgra
	INNER JOIN trtAttributeType tat
	ON tat.idfAttributeType = tgra.idfAttributeType
	AND tat.strAttributeTypeName = 'WHOrep_specific_gis_region'

	INNER JOIN gisRegion gr
	ON gr.idfsRegion = tgra.idfsGISBaseReference

DECLARE	@DateOnsetParameter BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@DateOnsetParameter = @FFP_DateOfOnset_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@DateOnsetParameter = @FFP_DateOfOnset_R

INSERT INTO	#HumanCasesToExport
(	idfHumanCase,
	idfHuman,
	idfCRAddress,
	idfsDiagnosis,
	idfCSObservation,
	idfEpiObservation,
	datDateOnset,
	idfOutbreak
)
SELECT	hc.idfHumanCase,
		h.idfHuman,
		h.idfCurrentResidenceAddress,
		ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis),
		hc.idfCSObservation,
		hc.idfEpiObservation,
		COALESCE(	
			CASE
				WHEN	(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') AS NVARCHAR) like N'%date%') or
						(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset.varValue AS NVARCHAR)) = 1) 
					THEN dbo.fnDateCutTime(CAST(ap_DateOfOnset.varValue AS DATETIME))
					ELSE NULL
			END, hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate
			),
		hc.idfOutbreak
FROM tlbHumanCase hc

	INNER JOIN tlbHuman h
	ON hc.idfHuman = h.idfHuman AND  h.intRowStatus = 0	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM tlbActivityParameters ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @DateOnsetParameter
			AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_DateOfOnset

WHERE	
	hc.intRowStatus = 0
	AND 	
	ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis 
	AND
	COALESCE(	
		CASE
			WHEN	(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') AS NVARCHAR) like N'%date%') or
					(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset.varValue AS NVARCHAR)) = 1) 
				THEN dbo.fnDateCutTime(CAST(ap_DateOfOnset.varValue AS DATETIME))
				ELSE NULL
		END, hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate
			) >= @StartDate
	
	AND
	COALESCE(	
		CASE
			WHEN	(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') AS NVARCHAR) like N'%date%') or
					(CAST(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfOnset.varValue AS NVARCHAR)) = 1) 
				THEN dbo.fnDateCutTime(CAST(ap_DateOfOnset.varValue AS DATETIME))
				ELSE NULL
		END, hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate
			) < @EndDate   			
		AND hc.idfHumanCase = (SELECT TOP 1 idfHumanCase FROM tlbHumanCase thc WHERE thc.idfCSObservation = hc.idfCSObservation and thc.idfsFinalDiagnosis = @idfsDiagnosis)

INSERT INTO	#FFToExport
(	idfActivityParameters,
	idfsParameter,
	idfObservation,
	idfRow,
	varValue
)
SELECT		ap.idfActivityParameters,
			ap.idfsParameter,
			ap.idfObservation,
			ap.idfRow,
			ap.varValue
FROM		tlbActivityParameters ap
INNER JOIN	#HumanCasesToExport hc_cs
ON			hc_cs.idfCSObservation = ap.idfObservation
WHERE		ap.intRowStatus = 0

INSERT INTO	#FFToExport
(	idfActivityParameters,
	idfsParameter,
	idfObservation,
	idfRow,
	varValue
)
SELECT		ap.idfActivityParameters,
			ap.idfsParameter,
			ap.idfObservation,
			ap.idfRow,
			ap.varValue
FROM		tlbActivityParameters ap
INNER JOIN	#HumanCasesToExport hc_epi
ON			hc_epi.idfEpiObservation = ap.idfObservation
left JOIN	#HumanCasesToExport hc_cs
ON			hc_cs.idfCSObservation = hc_epi.idfEpiObservation
WHERE		ap.intRowStatus = 0
			AND hc_cs.idfHumanCase IS NULL


DECLARE	@FFP_NumberOfReceivedDoses BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_NumberOfReceivedDoses = @FFP_NumberOfReceivedDoses_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_NumberOfReceivedDoses = @FFP_NumberOfReceivedDoses_R

DECLARE	@FFP_DateOfLastVaccination BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_DateOfLastVaccination = @FFP_DateOfLastVaccination_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_DateOfLastVaccination = @FFP_DateOfLastVaccination_R
	
DECLARE	@FFP_Fever BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Fever = @FFP_Fever_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Fever = @FFP_Fever_R

DECLARE	@FFP_Cough BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Cough = @FFP_Cough_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Cough = @FFP_Cough_R
	
DECLARE	@FFP_Coryza BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Coryza = @FFP_Coryza_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Coryza = @FFP_Coryza_R
	
DECLARE	@FFP_Conjunctivitis BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Conjunctivitis = @FFP_Conjunctivitis_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Conjunctivitis = @FFP_Conjunctivitis_R
	
DECLARE	@FFP_RashDuration BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_RashDuration = @FFP_RashDuration_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_RashDuration = @FFP_RashDuration_R

DECLARE	@FFP_SourceOfInfection BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_SourceOfInfection = @FFP_SourceOfInfection_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_SourceOfInfection = @FFP_SourceOfInfection_R

DECLARE	@FFP_Complications BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Complications = @FFP_Complications_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Complications = @FFP_Complications_R

DECLARE	@FFP_Encephalitis BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Encephalitis = @FFP_Encephalitis_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Encephalitis = @FFP_Encephalitis_R

DECLARE	@FFP_Pneumonia BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Pneumonia = @FFP_Pneumonia_M
ELSE IF	@idfsDiagnosis = @idfsDiagnosis_Rubella
	SET	@FFP_Pneumonia = @FFP_Pneumonia_R

DECLARE	@FFP_Diarrhoea BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Diarrhoea = @FFP_Diarrhoea_M

DECLARE	@FFP_Other BIGINT = -100
IF	@idfsDiagnosis = @idfsDiagnosis_Measles
	SET	@FFP_Other = @FFP_Other_M


UPDATE hc
SET	hc.NumberOfReceivedDoses = CAST(ap_NumberOfReceivedDoses.varValue AS NVARCHAR(50)),
	hc.DateOfLastVaccination = 
	CASE
		WHEN CAST(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
				(CAST(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap_DateOfLastVaccination.varValue AS NVARCHAR)) = 1 )	
			THEN dbo.FN_GBL_DATECUTTIME(CAST(ap_DateOfLastVaccination.varValue AS DATETIME))
		ELSE NULL
	END,
	hc.Fever = 
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Fever.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Fever.varValue AS BIGINT)
		ELSE NULL
	END,
	hc.Cough =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Cough.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Cough.varValue AS BIGINT)
		ELSE NULL
	END,
	hc.Coryza =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Coryza.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Coryza.varValue AS BIGINT)
		ELSE NULL
	END,  		
	hc.Conjunctivitis =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Conjunctivitis.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Conjunctivitis.varValue AS BIGINT)
		ELSE NULL
	END,  
	hc.RashDuration = CAST(ap_RashDuration.varValue AS NVARCHAR(50)),	
	hc.SourceOfInfection =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_SourceOfInfection.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_SourceOfInfection.varValue AS BIGINT)
		ELSE NULL
	END,   
	hc.Complications =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Complications.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Complications.varValue AS BIGINT)
		ELSE NULL
	END,    
	hc.Encephalitis =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Encephalitis.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Encephalitis.varValue AS BIGINT)
		ELSE NULL
	END,    
	hc.Pneumonia =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Pneumonia.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Pneumonia.varValue AS BIGINT)
		ELSE NULL
	END,    	
	hc.Diarrhoea =
	CASE
		WHEN SQL_VARIANT_PROPERTY(ap_Diarrhoea.varValue, 'BaseType') in ('BIGINT','decimal','float','INT','numeric','real','smallint','tinyint')
			THEN CAST(ap_Diarrhoea.varValue AS BIGINT)
		ELSE NULL
	END,    
	hc.Other = CAST(ap_Other.varValue AS NVARCHAR(500))	  		  		  		  			

 FROM #HumanCasesToExport hc
			
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfEpiObservation
			AND	ap.idfsParameter = @FFP_NumberOfReceivedDoses
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_NumberOfReceivedDoses		
	 			
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfEpiObservation
			AND	ap.idfsParameter = @FFP_DateOfLastVaccination
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_DateOfLastVaccination 	
		
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Fever
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Fever	
	
		
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Cough
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Cough	
	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Coryza
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Coryza
	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Conjunctivitis	
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Conjunctivitis

	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_RashDuration	
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_RashDuration
	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfEpiObservation
			AND	ap.idfsParameter = @FFP_SourceOfInfection	
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_SourceOfInfection
	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Complications		
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Complications
	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Encephalitis				
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Encephalitis

	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Pneumonia				
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Pneumonia
	
	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Diarrhoea						
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Diarrhoea


	OUTER APPLY ( 
		SELECT top 1 
			ap.varValue
		FROM #FFToExport ap
		WHERE	ap.idfObservation = hc.idfCSObservation
			AND	ap.idfsParameter = @FFP_Other							
			--AND ap.intRowStatus = 0
		ORDER BY ap.idfRow ASC	
	) AS  ap_Other


UPDATE	ct
SET		ct.datConcludedDate = material.datConcludedDate,
		ct.idfsSampleType = material.idfsSampleType,
		ct.datFieldCollectionDate = material.datFieldCollectionDate,
		ct.idfsTestResult = material.idfsTestResult,
		ct.idfsTestStatus = material.idfsTestStatus,
		ct.idfTesting = material.idfTesting
FROM	#HumanCasesToExport ct	
OUTER APPLY	(
	SELECT top 1 
		dbo.fnDateCutTime(tt.datConcludedDate) AS datConcludedDate,
		ISNULL(rm.idfsSampleType, m.idfsSampleType) AS idfsSampleType,
		m.datFieldCollectionDate,
		tt.idfsTestResult,
		tt.idfsTestStatus,
		tt.idfTesting
	FROM tlbMaterial m
		left JOIN tlbTesting tt
			INNER JOIN trtTestTypeForCustomReport ttcr
			ON ttcr.idfsTestName = tt.idfsTestName
			AND ttcr.intRowStatus = 0
			AND ttcr.idfsCustomReportType = @idfsSummaryReportType
		ON tt.idfMaterial = m.idfMaterial
		/*Added 2018-01-22 start*/
		AND tt.idfsDiagnosis = ct.idfsDiagnosis
		/*Added 2018-01-22 END*/
		AND tt.intRowStatus = 0
		AND tt.datConcludedDate IS NOT NULL
		
		left JOIN tlbMaterial rm
		ON rm.idfMaterial = m.idfParentMaterial
		AND rm.intRowStatus = 0						
		
   WHERE m.idfHumanCase = ct.idfHumanCase
			AND m.intRowStatus = 0
   ORDER BY ISNULL(tt.datConcludedDate, '19000101') DESC, m.datFieldCollectionDate DESC
   )	AS material	 

	SELECT
		ct.idfHumanCase AS idfCase,
		hc.strCaseID AS strCaseID,
		'GEO' + hc.strCaseID AS strCaseID,
		aid.intAreaID, 
		dbo.fnDateCutTime(ct.datDateOnset) AS datDRash, 
		CASE 
			WHEN h.idfsHumanGender = 10043001 THEN 2
			WHEN h.idfsHumanGender = 10043002 THEN 1
			ELSE 4
		END AS intGenderID, 
		dbo.fnDateCutTime(h.datDateofBirth) AS datDBirth, 
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
		
		ISNULL(CASE WHEN isnumeric(ct.NumberOfReceivedDoses) = 1  AND CAST(ct.NumberOfReceivedDoses AS varchar) NOT in ('.', ',', '-', '+', '$')
					THEN	
						CASE  CAST(ct.NumberOfReceivedDoses AS BIGINT)
							WHEN 9878670000000 THEN 0
							WHEN 9878680000000 THEN 1
							WHEN 9878690000000 THEN 2
							WHEN 9878700000000 THEN 3
							ELSE 9
						END	
					ELSE 9 END
			, 9)	 AS intNumOfVaccines, 
			
		ct.DateOfLastVaccination AS datDvaccine, 			
		dbo.fnDateCutTime(hc.datNotificationDate) AS datDNotification, 
		dbo.fnDateCutTime(hc.datInvestigationStartDate) AS datDInvestigation, 
 		
		CASE ct.Fever
			WHEN 25460000000 THEN 1
			WHEN 25640000000 THEN 2
			WHEN 25660000000 THEN 9
			ELSE NULL
		END	 AS intClinFever, 
		
		CASE 
			CASE 
				WHEN ct.Cough = 25460000000 or ct.Coryza = 25460000000 or ct.Conjunctivitis = 25460000000 THEN 25460000000
				WHEN ct.Cough = 25640000000 AND ct.Coryza = 25640000000 AND ct.Conjunctivitis = 25640000000 THEN 25640000000
				ELSE 25660000000
			END		
			WHEN 25460000000 THEN 1
			WHEN 25640000000 THEN 2
			ELSE 9
		END	 AS intClinCCC, 			    			
		CASE WHEN isnumeric(ct.RashDuration) = 1  AND CAST(ct.RashDuration AS varchar) NOT in ('.', ',', '-', '+', '$')
				THEN --CAST(ct.RashDuration AS INT) 
					 CAST(CAST(replace(ct.RashDuration,',','.') AS decimal) AS INT)
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
		
		-- GG - FF parameter = 'Source of infection' -- idfsParameter = 9951440000000
		--9879590000000	Imported
		--9879600000000	Import-related
		--9879610000000	Indigenous
		--9879620000000	Unknown
		--Indigenous=Endemic, Imported=Imported, Import-related=Import-related, Unknown = Unknown, Blank = Blank

		CASE ct.SourceOfInfection 
			--GG
			WHEN 9879590000000 THEN 1 --Imported = Imported
			WHEN 9879610000000 THEN 2 --Indigenous = Endemic
			WHEN 9879600000000 THEN 3 -- Import-related=Import-related
			WHEN 9879620000000 THEN 9 --  Unknown = Unknown
			ELSE NULL --Blank = Blank
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
				-- GG
				WHEN ct.Complications = 25460000000 AND ct.idfsDiagnosis = @idfsDiagnosis_Measles THEN 25460000000
				WHEN ct.Complications = 25640000000 AND ct.idfsDiagnosis = @idfsDiagnosis_Measles THEN 25640000000
				WHEN ct.Complications = 25660000000 AND ct.idfsDiagnosis = @idfsDiagnosis_Measles THEN 25660000000
				ELSE 25660000000
			END		
			WHEN 25460000000 THEN 1
			WHEN 25640000000 THEN 2
			WHEN 25660000000 THEN 9
			ELSE NULL
		END	 AS intCompComplications, 		 					
		
		CASE WHEN ct.Complications = 25460000000 /*Yes*/ AND ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			THEN
				CASE ct.Encephalitis 
					WHEN 25460000000 THEN 1 
					WHEN 25640000000 THEN 2 
					WHEN 25660000000 THEN 9 		
					ELSE NULL
				END	 
			ELSE NULL
		END AS intCompEncephalitis, 				
		
		CASE WHEN ct.Complications = 25460000000 /*Yes*/ AND ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			THEN
				CASE ct.Pneumonia 
					WHEN 25460000000 THEN 1 
					WHEN 25640000000 THEN 2 
					WHEN 25660000000 THEN 9 		
					ELSE NULL
				END		 
			ELSE NULL
		END AS intCompPneumonia, 				
    
		NULL AS intCompMalnutrition, 
		
		CASE WHEN ct.Complications = 25460000000 /*Yes*/ AND ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			THEN
				CASE ct.Diarrhoea 
					WHEN 25460000000 THEN 1 
					WHEN 25640000000 THEN 2 
					WHEN 25660000000 THEN 9 		
					ELSE NULL
				END		 
			ELSE NULL
		END AS intCompDiarrhoea, 		
		
		CASE WHEN ct.Complications = 25460000000 /*Yes*/ AND ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			THEN
				CASE WHEN len(ct.Other) > 0 THEN 1 ELSE 2 END 
			ELSE NULL
		END AS intCompOther, 		
            
		CASE 
			WHEN hc.idfsFinalCaseStatus = 370000000  --NOT a CASE
					THEN 0
			WHEN hc.idfsFinalCaseStatus = 350000000 --Confirmed
				AND ct.idfsDiagnosis = @idfsDiagnosis_Measles
				AND hc.blnLabDiagBasis = 1
					THEN 1
			WHEN hc.idfsFinalCaseStatus = 350000000  --Confirmed
				AND ct.idfsDiagnosis = @idfsDiagnosis_Measles
				AND ISNULL(hc.blnLabDiagBasis, 0) = 0
				AND hc.blnEpiDiagBasis = 1
					THEN 2
			WHEN hc.idfsFinalCaseStatus = 360000000 --Probable
				AND ct.idfsDiagnosis = @idfsDiagnosis_Measles
				AND (hc.blnLabDiagBasis = 1 or hc.blnEpiDiagBasis = 1 or hc.blnClinicalDiagBasis = 1)
					THEN 3
			WHEN hc.idfsFinalCaseStatus = 350000000 
				AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella
				AND hc.blnLabDiagBasis = 1
					THEN 6
			WHEN hc.idfsFinalCaseStatus = 350000000 
				AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella
				AND ISNULL(hc.blnLabDiagBasis, 0) = 0
				AND hc.blnEpiDiagBasis = 1
					THEN 7
			WHEN hc.idfsFinalCaseStatus = 360000000 --Probable
				AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella
				AND  (hc.blnLabDiagBasis = 1 or hc.blnEpiDiagBasis = 1 or hc.blnClinicalDiagBasis = 1)
					THEN 8
			WHEN hc.idfsFinalCaseStatus = 380000000
				OR hc.idfsFinalCaseStatus = 12137920000000
				or hc.idfsFinalCaseStatus IS NULL
				or (hc.blnLabDiagBasis IS NULL AND hc.blnEpiDiagBasis IS NULL AND hc.blnClinicalDiagBasis IS NULL)
					THEN NULL
			ELSE NULL
		END intFinalClassification,        
    
    
		CASE 
		   WHEN hc.idfsYNSpecimenCollected = 10100001 THEN ct.datFieldCollectionDate
		   ELSE NULL
		END AS datDSpecimen,       
        
		--Type of sample associated with the test which result IS shown in #29/31. 
		--IF #29/31 IS blank THEN the sample with the latest date of sample collection should be taken. 
		--Blood = 1 Serum, 
		--Blood - serum=1 Serum, 
		--Saliva=2 Saliva/oral fluid, 
		--Swab - Rhinopharyngeal = 3 Nasopharyngeal swab, 
		--Urine=5 Urine, 
		--Blood - anticoagulated whole blood= 6 EDTA whole blood, 
		--in other CASE = 7 Other specimen. 
		--Which sample to send, it shall be defined BY tests (see 29/31) NB: Parent Sample Type should be tranferred to CISID in CASE Sample Derivative was created.
		CASE
			ISNULL(CASE 
			   WHEN hc.idfsYNSpecimenCollected = 10100001 THEN ct.idfsSampleType
			   ELSE NULL
			END, -1)
			--GG
			WHEN 9844440000000 /*Blood*/ THEN 1 --Serum
			WHEN 9844480000000/*Blood - serum*/  THEN 1 --Serum
			WHEN 9845550000000	/*Saliva*/ THEN 2 --Saliva/oral fluid
			WHEN 9845840000000	/*Swab - Rhinopharyngeal*/ THEN 3 --Nasopharyngeal swab
			WHEN 9846060000000	/*Urine*/ THEN 5 --Urine
			WHEN 9844450000000 /*Blood - anticoagulated whole blood*/ THEN 6 --EDTA whole blood
			WHEN -1 THEN NULL
			ELSE 7
		END AS intSpecimen,    

		CASE 
		   WHEN hc.idfsYNSpecimenCollected = 10100001 THEN ct.datConcludedDate
		   ELSE NULL
		END AS datDLabResult,    			            
       
		

		--Test Name: ELISA IgM, Antibody detection
		--The Result of the lastest "ELISA IgM, Antibody detection" 
		--Test Name shall be taken (BY Result Date). 
		--1 Positive = Positive AND Test Status = Final or Amended, 
		--2 Negative= Negative AND Test Status = Final or Amended, 
		--4 Inclonclusive = Cut off AND Test Status = Final or Amended, 
		--0 NOT Tested = IF sample data IS filled in #26/27 but no test data available, 
		--3 In Process = any test result (including blank) for assigned test AND Test Status = In Process or Preliminary      
		CASE
			ISNULL(
					CASE 
					   WHEN hc.idfsYNSpecimenCollected = 10100001 AND ct.idfsDiagnosis = @idfsDiagnosis_Measles AND ct.idfsTestStatus in (10001001, 10001006) --Final or Amended
							THEN ct.idfsTestResult
					   WHEN hc.idfsYNSpecimenCollected = 10100001 AND ct.idfsDiagnosis = @idfsDiagnosis_Measles AND ct.idfsTestStatus in( 10001003, 10001004)	--In Process or Preliminary   
							THEN 3
					   WHEN ct.idfsDiagnosis = @idfsDiagnosis_Measles AND ct.idfTesting IS NULL AND ct.idfsSampleType IS NOT NULL
							THEN 0
					   ELSE NULL
					END, -1)
			--GG
			WHEN 9848880000000 THEN 4--Indeterminate
			WHEN 9848980000000 THEN 2--Negative
			WHEN 9849050000000 THEN 1--Positive
			WHEN 3			   THEN 3--In Process
			WHEN 0			   THEN 0--Tested
			WHEN -1 THEN NULL
			ELSE NULL
		END AS intMeaslesIgm,    
		
		NULL AS intMeaslesVirusDetection,
		
		CASE
			ISNULL(
				CASE 
					   WHEN hc.idfsYNSpecimenCollected = 10100001 AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella AND ct.idfsTestStatus  in (10001001, 10001006) --Final or Amended
							THEN ct.idfsTestResult
					   WHEN hc.idfsYNSpecimenCollected = 10100001 AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella AND ct.idfsTestStatus in( 10001003, 10001004)	--In Process or Preliminary   
							THEN 3
					   WHEN ct.idfsDiagnosis = @idfsDiagnosis_Rubella AND ct.idfTesting IS NULL	 AND ct.idfsSampleType IS NOT NULL
							THEN 0
					   ELSE NULL
			END, -1)
			WHEN 9848880000000 THEN 4--Indeterminate
			WHEN 9848980000000 THEN 2--Negative
			WHEN 9849050000000 THEN 1--Positive
			WHEN 3			   THEN 3--In Process
			WHEN 0			   THEN 0--Tested
			WHEN -1 THEN NULL
			ELSE NULL
		END AS intRubellaIgm,  
		NULL AS intRubellaVirusDetection,
		'Outbreak ID: ' + to1.strOutbreakID AS strCommentsEpi
 			      			
 FROM	#HumanCasesToExport ct
	INNER JOIN tlbHumanCase hc
	ON hc.idfHumanCase = ct.idfHumanCase

	INNER JOIN tlbHuman h
	ON h.idfHuman = ct.idfHuman

	INNER JOIN	tlbGeoLocation gl
	ON gl.idfGeoLocation = ct.idfCRAddress

	INNER JOIN @AreaIDs aid
	ON aid.idfsRegion = gl.idfsRegion

	left JOIN tlbOutbreak to1
	ON to1.idfOutbreak = hc.idfOutbreak
	AND to1.intRowStatus = 0   
ORDER BY ct.datDateOnset, hc.strCaseID


--INSERT INTO	#ResultTable
-- (	
--	  idfCase
--	, strCaseID	
--	, intAreaID	
--	, datDRash	
--	, intGenderID
--	, datDBirth	
--	, intAgeAtRashOnset	
--	, intNumOfVaccines	
--	, datDvaccine	
--	, datDNotification	
--	, datDInvestigation	
--	, intClinFever		
--	, intClinCCC	
--	, intClinRashDuration	
--	, intClinOutcome		
--	, intClinHospitalization	
--	, intSrcInf				
--	, intSrcOutbreakRelated		
--	, strSrcOutbreakID		
--	, intCompComplications	
--	, intCompEncephalitis	
--	, intCompPneumonia		
--	, intCompMalnutrition	
--	, intCompDiarrhoea		
--	, intCompOther		
--	, intFinalClassification
--	, datDSpecimen			
--	, intSpecimen			
--	, datDLabResult			
--	, intMeaslesIgm			
--	, intMeaslesVirusDetection	
--	, intRubellaIgm		
--	, intRubellaVirusDetection		
--	, strCommentsEpi			
--)
--SELECT 
--	idfHumanCase
--	, strCaseID	
--	, intAreaID	
--	, datDRash	
--	, intGenderID
--	, datDBirth	
--	, intAgeAtRashOnset	
--	, intNumOfVaccines	
--	, datDvaccine	
--	, datDNotification	
--	, datDInvestigation	
--	, intClinFever		
--	, intClinCCC	
--	, intClinRashDuration	
--	, intClinOutcome		
--	, intClinHospitalization	
--	, intSrcInf				
--	, intSrcOutbreakRelated		
--	, strSrcOutbreakID		
--	, intCompComplications	
--	, intCompEncephalitis	
--	, intCompPneumonia		
--	, intCompMalnutrition	
--	, intCompDiarrhoea		
--	, intCompOther		
--	, intFinalClassification
--	, datDSpecimen			
--	, intSpecimen			
--	, datDLabResult			
--	, intMeaslesIgm			
--	, intMeaslesVirusDetection	
--	, intRubellaIgm				
--	, intRubellaVirusDetection
--	, strCommentsEpi	 


--FROM hc_table
 


--SELECT * FROM #ResultTable
--ORDER BY datDRash, strCaseID

-- Drop temporary tables
IF Object_ID('tempdb..#HumanCasesToExport') IS NOT NULL
BEGIN
SET	@cmd = N'drop TABLE #HumanCasesToExport'
EXEC sp_executesql @cmd
END

IF Object_ID('tempdb..#ResultTable') IS NOT NULL
BEGIN
SET	@cmd = N'drop TABLE #ResultTable'
EXEC sp_executesql @cmd
END

END


