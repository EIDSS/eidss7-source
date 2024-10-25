

--********************************************************************************************************
-- Name 				: USP_REP_HUM_DataQualityIndicators_Graph2
-- Description			: This procedure returns resultset for Main indicators of AFP surveillance report
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--

--Example of a call of procedure:
 
--SELECT td.idfsDiagnosis, tbr.strDefault, tsnt.strTextString, tsnt.idfsLanguage, td.idfsUsingType
--  FROM trtDiagnosis td
--INNER JOIN trtBaseReference tbr
--ON tbr.idfsBaseReference = td.idfsDiagnosis
--INNER JOIN trtStringNameTranslation tsnt
--ON tsnt.idfsBaseReference = tbr.idfsBaseReference

--WHERE
--tbr.strDefault like '%Acute intestinal infection %'
--AND tbr.intRowStatus = 0
/*
 EXEC report.USP_REP_HUM_DataQualityIndicators_Graph2 
 'en', 
'7718070000000,7718060000000',
 2014,
 1,
 12
 
 EXEC report.USP_REP_HUM_DataQualityIndicators_Graph2 
 'en', 
'0,7718070000000',
 2016,
 1,
 1,
 '1344330000000'
*/ 
--********************************************************************************************************
CREATE PROCEDURE [Report].[USP_REP_HUM_DataQualityIndicators_Graph2]
 (
	 @LangID   as NVARCHAR(50),
	 @Diagnosis   AS NVARCHAR(MAX),  
	 @Year   as INT, 
	 @StartMonth  as INT = null,
	 @EndMonth  as INT = null,
	 @RegionID as BIGINT = null,
	 @RayonID as BIGINT = null,
	 @SiteID   as BIGINT = null
 )
 as	
	SET nocount ON
    SET @Diagnosis=CASE (LEFT(@Diagnosis,2)) WHEN '0,' THEN Substring(@Diagnosis,3,len(@Diagnosis)) ELSE @Diagnosis END
 	DECLARE 
 	     @CountryID	BIGINT
 		,@iDiagnosis	INT
 		,@SDDate DATETIME
 		,@EDDate DATETIME
 		,@idfsLanguage BIGINT
 		,@idfsCustomReportType BIGINT
 	
 		,@Ind_1_Notification  NUMERIC(4,2)
 		,@Ind_2_CaseInvestigation  NUMERIC(4,2)
 		,@Ind_3_TheResultsOfLabTestsAndInterpretation  NUMERIC(4,2)
 		
 		,@Ind_N1_CaseStatus  NUMERIC(4,2)
 		,@Ind_N1_DateofCompletionPF  NUMERIC(4,2)
 		,@Ind_N1_NameofEmployer  NUMERIC(4,2)
 		,@Ind_N1_CurrentLocationPatient NUMERIC(4,2)
 		,@Ind_N1_NotifDateTime  NUMERIC(4,2)
		,@Ind_N2_NotifDateTime  NUMERIC(4,2)
		,@Ind_N3_NotifDateTime  NUMERIC(4,2)
 		,@Ind_N1_NotifSentByName  NUMERIC(4,2)
 		,@Ind_N1_NotifReceivedByFacility  NUMERIC(4,2)
 		,@Ind_N1_NotifReceivedByName  NUMERIC(4,2)
 		,@Ind_N1_TimelinessOfDataEntryDTEN  NUMERIC(4,2)
		,@Ind_N2_TimelinessOfDataEntryDTEN  NUMERIC(4,2)
		,@Ind_N3_TimelinessOfDataEntryDTEN  NUMERIC(4,2)
 		,@Ind_N1_DIStartingDTOfInvestigation  NUMERIC(4,2)
		,@Ind_N2_DIStartingDTOfInvestigation  NUMERIC(4,2)
		,@Ind_N3_DIStartingDTOfInvestigation  NUMERIC(4,2)
 		,@Ind_N1_DIOccupation  NUMERIC(4,2)
 		,@Ind_N1_CIInitCaseClassification  NUMERIC(4,2)
 		,@Ind_N1_CILocationOfExposure NUMERIC(4,2)
 		,@Ind_N1_CIAntibioticTherapyAdministratedBSC  NUMERIC(4,2)
 		,@Ind_N1_SamplesCollection  NUMERIC(4,2)
 		,@Ind_N1_ContactLisAddContact  NUMERIC(4,2)
 		,@Ind_N1_CaseClassificationCS  NUMERIC(4,2)
 		,@Ind_N1_EpiLinksRiskFactorsByEpidCard   NUMERIC(4,2)
		,@Ind_N2_EpiLinksRiskFactorsByEpidCard   NUMERIC(4,2)
		,@Ind_N3_EpiLinksRiskFactorsByEpidCard   NUMERIC(4,2)
 		,@Ind_N1_FCCOBasisOfDiagnosis  NUMERIC(4,2)
 		,@Ind_N1_FCCOOutcome NUMERIC(4,2)
 		,@Ind_N1_FCCOIsThisCaseRelatedToOutbreak  NUMERIC(4,2)
 		,@Ind_N1_FCCOEpidemiologistName  NUMERIC(4,2)
 		,@Ind_N1_ResultsOfLabTestsTestsConducted  NUMERIC(4,2)
 		,@Ind_N1_ResultsOfLabTestsResultObservation  NUMERIC(4,2)
 		
		,@idfsRegionBaku BIGINT
		,@idfsRegionOtherRayons BIGINT
		,@idfsRegionNakhichevanAR BIGINT		
 	
  	
 	DECLARE @DiagnosisTable	table
 	(
 		intRowNumber INT identity(1,1) primary key,
 		[key]		NVARCHAR(300),
 		[value]		NVARCHAR(300),
 		intNotificationToCHE INT,
 		intStartingDTOfInvestigation INT,
 		blnLaboratoryConfirmation bit,
 		intQuantityOfMandatoryFieldCS INT,
 		intQuantityOfMandatoryFieldCSForDC INT,
 		intEPILincsAndFactors INT		
 	)
 	
 	DECLARE @ReportTable table
 	(
 			idfsBaseReference	BIGINT identity not null primary key,
 			idfsRegion			BIGINT not null,
 	/*1*/	strRegion			NVARCHAR(200) not null,
 			intRegionOrder		INT null,
 			idfsRayon			BIGINT not null,
 	/*2*/	strRayon			NVARCHAR(200) not null,
 			strAZRayon			NVARCHAR(200) not null,
 			intRayonOrder		INT null,
 			intCaseCount		INT not null,
 			idfsDiagnosis		BIGINT not null,
 	/*3*/	strDiagnosis		NVARCHAR (300) collate database_default not null,
 	
 	/*6(1+2+3+5+6+8+9+10)*/dbl_1_Notification NUMERIC(4,2) null,
 	/*7(1)*/	dblCaseStatus	NUMERIC(4,2) null,
 	/*8(2)*/	dblDateOfCompletionOfPaperForm	NUMERIC(4,2) null,
 	/*9(3)*/	dblNameOfEmployer	NUMERIC(4,2) null,
 	/*11(5)*/	dblCurrentLocationOfPatient	NUMERIC(4,2) null,
 	/*12(6)*/	dblNotificationDateTime	NUMERIC(4,2) null,
 	/*13(7)*/	dbldblNotificationSentByName	NUMERIC(4,2) null,
 	/*14(8)*/	dblNotificationReceivedByFacility	NUMERIC(4,2) null,
 	/*15(9)*/	dblNotificationReceivedByName	NUMERIC(4,2) null,
 	/*16(10)*/	dblTimelinessofDataEntry	NUMERIC(4,2) null,
 	
 	/*17(11..23)*/dbl_2_CaseInvestigation	NUMERIC(4,2) null,
 	/*18(11)*/	dblDemographicInformationStartingDateTimeOfInvestigation	NUMERIC(4,2) null,
 	/*19(12)*/	dblDemographicInformationOccupation	NUMERIC(4,2) null,
 	/*20(13)*/	dblClinicalInformationInitialCaseClassification	NUMERIC(4,2) null,
 	/*21(14)*/	dblClinicalInformationLocationOfExposure NUMERIC(4,2) null,
 	/*22(15)*/	dblClinicalInformationAntibioticAntiviralTherapy NUMERIC(4,2) null,
 	/*23(16)*/	dblSamplesCollectionSamplesCollected	NUMERIC(4,2) null,
 	/*24(17)*/	dblContactListAddContact	NUMERIC(4,2) null,
 	/*25(18)*/	dblCaseClassificationClinicalSigns NUMERIC(4,2) null,
 	/*26(19)*/	dblEpidemiologicalLinksAndRiskFactors NUMERIC(4,2) null,
 	/*27(20)*/	dblFinalCaseClassificationBasisOfDiagnosis	NUMERIC(4,2) null,
 	/*28(21)*/	dblFinalCaseClassificationOutcome	NUMERIC(4,2) null,
 	/*29(22)*/	dblFinalCaseClassificationIsThisCaseOutbreak	NUMERIC(4,2) null,
 	/*30(23)*/	dblFinalCaseClassificationEpidemiologistName	NUMERIC(4,2) null,
 	
 	/*31(24+25)*/dbl_3_TheResultsOfLaboratoryTests NUMERIC(4,2) null,
 	/*32(24)*/	dblTheResultsOfLaboratoryTestsTestsConducted	NUMERIC(4,2) null,
 	/*33(25)*/	dblTheResultsOfLaboratoryTestsResultObservation	NUMERIC(4,2) null,
 	
 	/*34*/		dblSummaryScoreByIndicators NUMERIC(4,2) null
  	)
 	
	IF @StartMonth IS null
	BEGIN
		SET @SDDate = (CAST(@Year as VARCHAR(4)) + '01' + '01')
		SET @EDDate = dateADD(yyyy, 1, @SDDate)
	END
	ELSE
	BEGIN	
	  IF @StartMonth < 10	
			SET @SDDate = (CAST(@Year as VARCHAR(4)) + '0' +CAST(@StartMonth as VARCHAR(2)) + '01')
	  ELSE				
			SET @SDDate = (CAST(@Year as VARCHAR(4)) + CAST(@StartMonth as VARCHAR(2)) + '01')
			
	  IF (@EndMonth is null) or (@StartMonth = @EndMonth)
			SET @EDDate = dateADD(mm, 1, @SDDate)
	  ELSE	BEGIN
			IF @EndMonth < 10	
				SET @EDDate = (CAST(@Year as VARCHAR(4)) + '0' +CAST(@EndMonth as VARCHAR(2)) + '01')
			ELSE				
				SET @EDDate = (CAST(@Year as VARCHAR(4)) + CAST(@EndMonth as VARCHAR(2)) + '01')
				
			SET @EDDate = dateADD(mm, 1, @EDDate)
	  END
	END		
	 	
			
 	SET @CountryID = 170000000
 	
 	SET @idfsLanguage = dbo.fnGetLanguageCode(@LangID)
 	
 	SET @idfsCustomReportType =  10290021
 	
 	INSERT INTO @DiagnosisTable ([key])
	SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@Diagnosis,1,',')
 	
 	
 	-- IF @Diagnosis is blanc, fill to @DiagnosisTable all diagnosis
 	IF (SELECT COUNT(*) FROM @DiagnosisTable)=0	
 	BEGIN
 		insert into @DiagnosisTable (
 			[key],
 			[value]
 		) 
 		SELECT tbr.idfsBaseReference, tbr.strBaseReferenceCode
 		FROM trtBaseReference tbr
 			INNER JOIN trtBaseReferenceToCP tbrtc
			ON tbrtc.idfsBaseReference = tbr.idfsBaseReference
			
			INNER JOIN tstCustomizationPackage cp
			ON cp.idfCustomizationPackage = tbrtc.idfCustomizationPackage
			AND cp.idfsCountry = @CountryID
			
			INNER JOIN trtBaseReferenceAttribute tbra3
 				INNER JOIN trtAttributeType tat3
 				ON tat3.idfAttributeType = tbra3.idfAttributeType
 				AND tat3.strAttributeTypeName = 'QI Laboratory Confirmation'
 			ON tbra3.idfsBaseReference = tbr.idfsBaseReference
 		WHERE tbr.idfsReferenceType = 19000019 /*diagnosis*/
 		AND tbr.intRowStatus = 0
 		AND (tbr.intHACode & 2) > 1
 		--AND tbr.strBaseReferenceCode like '%;%'
 	END
 	
 	
 	-- new !
 	UPDATE dt SET
 		dt.intNotificationToCHE	=			CASE 
 												WHEN SQL_VARIANT_PROPERTY(tbra1.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 												THEN CAST(tbra1.varValue as INT)
 												ELSE null
 											END,
		dt.intStartingDTOfInvestigation =	CASE 
 												WHEN SQL_VARIANT_PROPERTY(tbra2.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 												THEN CAST(tbra2.varValue as INT)
 												ELSE null
 											END,
		dt.blnLaboratoryConfirmation =		CASE 
 												WHEN SQL_VARIANT_PROPERTY(tbra3.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 												THEN CAST(tbra3.varValue as INT)
 												ELSE null
 											END,
		dt.intQuantityOfMandatoryFieldCS =	CASE 
 												WHEN SQL_VARIANT_PROPERTY(tbra5.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 												THEN CAST(tbra5.varValue as INT)
 												ELSE null
 											END,
		dt.intQuantityOfMandatoryFieldCSForDC =	CASE 
 													WHEN SQL_VARIANT_PROPERTY(tbra6.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 													THEN CAST(tbra6.varValue as INT)
 													ELSE null
 												END,
		dt.intEPILincsAndFactors =			CASE 
 												WHEN SQL_VARIANT_PROPERTY(tbra7.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 												THEN CAST(tbra7.varValue as INT)
 												ELSE null
 											END								
 	FROM @DiagnosisTable dt
 		LEFT JOIN trtBaseReferenceAttribute tbra1
 			INNER JOIN trtAttributeType tat1
 			ON tat1.idfAttributeType = tbra1.idfAttributeType
 			AND tat1.strAttributeTypeName = 'QI Transmission of Emergency Notification to CHE'
 		ON tbra1.idfsBaseReference = dt.[key]
 		
 		LEFT JOIN trtBaseReferenceAttribute tbra2
 			INNER JOIN trtAttributeType tat2
 			ON tat2.idfAttributeType = tbra2.idfAttributeType
 			AND tat2.strAttributeTypeName = 'QI Starting date, time of investigation'
 		ON tbra2.idfsBaseReference = dt.[key]
 		
 		LEFT JOIN trtBaseReferenceAttribute tbra3
 			INNER JOIN trtAttributeType tat3
 			ON tat3.idfAttributeType = tbra3.idfAttributeType
 			AND tat3.strAttributeTypeName = 'QI Laboratory Confirmation'
 		ON tbra3.idfsBaseReference = dt.[key]
 		
 	 	LEFT JOIN trtBaseReferenceAttribute tbra5
 			INNER JOIN trtAttributeType tat5
 			ON tat5.idfAttributeType = tbra5.idfAttributeType
 			AND tat5.strAttributeTypeName = 'QI Quantity of mandatory fields of Clinical Signs'
 		ON tbra5.idfsBaseReference = dt.[key]
 	 	
 	 	LEFT JOIN trtBaseReferenceAttribute tbra6
 			INNER JOIN trtAttributeType tat6
 			ON tat6.idfAttributeType = tbra6.idfAttributeType
 			AND tat6.strAttributeTypeName = 'QI Quantity of mandatory fields of Clinical Signs that’s nesessary for diagnosis confirmation by Clinical Signs ("Yes")'
 		ON tbra6.idfsBaseReference = dt.[key]
 		
 	 	LEFT JOIN trtBaseReferenceAttribute tbra7
 			INNER JOIN trtAttributeType tat7
 			ON tat7.idfAttributeType = tbra7.idfAttributeType
 			AND tat7.strAttributeTypeName = 'QI Epidemiological Links AND Risk Factors - Minimum quantity logically filled fields.'
 		ON tbra7.idfsBaseReference = dt.[key] 		
 		 	 	
 	
 	--SELECT * FROM @DiagnosisTable dt
 	--INNER JOIN trtDiagnosis td
 	--ON  dt.[key] = td.idfsDiagnosis
 	--INNER JOIN trtBaseReference tbr
 	--ON tbr.idfsBaseReference = td.idfsDiagnosis
 	
 	
	-- new
	--1.
	SELECT 
		@Ind_1_Notification = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.Notification'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')
	
	--1.1.
 	SELECT 
		@Ind_N1_CaseStatus = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.1. CASE Status'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')
	
	--1.2.
	SELECT 
		@Ind_N1_DateofCompletionPF = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.2. Date of Completion of Paper form'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')
	
	--1.3.
	SELECT 
		@Ind_N1_NameofEmployer = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.3. Name of Employer'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 	
 	
 	--1.5.
 	SELECT 
		@Ind_N1_CurrentLocationPatient = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.5. Current location of patient'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 	
 	
 	--1.6.
 	SELECT 
		@Ind_N1_NotifDateTime = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.6. Notification date, time'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N2_NotifDateTime = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N2'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.6. Notification date, time'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N3_NotifDateTime = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N3'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.6. Notification date, time'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')	
	
	--1.8.
 	SELECT 
		@Ind_N1_NotifSentByName = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.8. Notification sent by: Name'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--1.9.
 	SELECT 
		@Ind_N1_NotifReceivedByFacility = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.9. Notification received by: Facility'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--1.10.
 	SELECT 
		@Ind_N1_NotifReceivedByName = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.10. Notification received by: Name'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--1.11.
 	SELECT 
		@Ind_N1_TimelinessOfDataEntryDTEN = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N2_TimelinessOfDataEntryDTEN = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N2'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N3_TimelinessOfDataEntryDTEN = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N3'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '1.11. Timeliness of Data Entry, date AND time of the Emergency Notification'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')	 	
 	
 	--2.
 	SELECT 
		@Ind_2_CaseInvestigation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2. CASE Investigation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')
 	
 	--2.1.1.
 	SELECT 
		@Ind_N1_DIStartingDTOfInvestigation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N2_DIStartingDTOfInvestigation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N2'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N3_DIStartingDTOfInvestigation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N3'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.1.1. Demographic Information -Starting date, time of investigation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')	 	 	
 	
 	--2.1.2.
 	SELECT 
		@Ind_N1_DIOccupation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.1.2. Demographic Information – Occupation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	--2.2.1.
 	SELECT 
		@Ind_N1_CIInitCaseClassification = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.2.1. Clinical information - Initial CASE Classification'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.2.2.
 	SELECT 
		@Ind_N1_CILocationOfExposure = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.2.2. Clinical information - Location of Exposure IF it known'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.2.3.
 	SELECT 
		@Ind_N1_CIAntibioticTherapyAdministratedBSC = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.2.3. Clinical information - Antibiotic/Antiviral therapy administrated before samples collection'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.3.1.
 	SELECT 
		@Ind_N1_SamplesCollection = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.3.1. Samples Collection  - Samples collected'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.4.1.
 	SELECT 
		@Ind_N1_ContactLisAddContact = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.4.1. Contact List  - Add Contact'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.5.
 	SELECT 
		@Ind_N1_CaseClassificationCS = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.5. CASE Classification (Clinical signs)'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.6.1.
 	SELECT 
		@Ind_N1_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N2_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N2'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	SELECT 
		@Ind_N3_EpiLinksRiskFactorsByEpidCard = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
			ON tat.idfAttributeType = tbra.idfAttributeType
			AND tat.strAttributeTypeName = 'Indicators Max Score N3'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.6.1. Epidemiological Links AND Risk Factors - by Epidemiological card'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')	 	
 	

 	--2.7.3.
 	SELECT 
		@Ind_N1_FCCOBasisOfDiagnosis = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.7.3. Final CASE Classification AND Outcome - Basis of Diagnosis'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
	
	--2.7.4.
 	SELECT 
		@Ind_N1_FCCOOutcome = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.7.4. Final CASE Classification AND Outcome – Outcome'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.7.5.
 	SELECT 
		@Ind_N1_FCCOIsThisCaseRelatedToOutbreak = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.7.5. Final CASE Classification AND Outcome - Is this CASE related to an outbreak'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--2.7.6.
 	SELECT 
		@Ind_N1_FCCOEpidemiologistName = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '2.7.6. Final CASE Classification AND Outcome - Epidemiologist name'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT') 
 	
 	--3.
 	SELECT 
		@Ind_3_TheResultsOfLabTestsAndInterpretation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '3.The results of Laboratory Tests AND  Interpretation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')
 	
 	--3.1.
 	SELECT 
		@Ind_N1_ResultsOfLabTestsTestsConducted = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '3.1. The results of Laboratory Tests AND Interpretation - Tests Conducted'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')
 	
 	--3.2.
	SELECT 
		@Ind_N1_ResultsOfLabTestsResultObservation = CAST(tbra.varValue as NUMERIC(4,2))
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN trtAttributeType tat
 			ON tat.idfAttributeType = tbra.idfAttributeType
 			AND tat.strAttributeTypeName = 'Indicators Max Score N'
	WHERE tbra.idfsBaseReference = @idfsCustomReportType
	AND tbra.strAttributeItem = '3.2. The results of Laboratory Tests AND Interpretation - Result/Observation'
	AND SQL_VARIANT_PROPERTY(tbra.varValue, 'BaseType') in ('BIGINT','DECIMAL','FLOAT','INT','NUMERIC','REAL','SMALLINT','TINYINT')  
 

 
 	--Transport CHE
 	DECLARE @TransportCHE BIGINT
 
 	SELECT @TransportCHE = frr.idfsReference
 	FROM dbo.fnGisReferenceRepair('en', 19000020) frr
 	WHERE frr.name =  'Transport CHE'
 	print @TransportCHE
 	

	--1344330000000 --Baku
	SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Baku'

	--1344340000000 --Other rayons
	SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Other rayons'


	--1344350000000 --Nakhichevan AR
	SELECT @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue as NVARCHAR(100)) = N'Nakhichevan AR'
	
	
	-------------------------------------------
	DECLARE @isTLVL BIGINT
	SET @isTLVL = 0
	
	SELECT @isTLVL = CASE WHEN ts.idfsSiteType = 10085007 THEN 1 ELSE 0 END 
	FROM tstSite ts
	WHERE ts.idfsSite = isnull(@SiteID, dbo.FN_GBL_SITEID_GET())

	DECLARE @isWeb BIGINT
	SET @isWeb = 0 
  
	SELECT @isWeb = isnull(ts.blnIsWEB, 0) 
	FROM tstSite ts
	WHERE ts.idfsSite = dbo.FN_GBL_SITEID_GET()  
	-------------------------------------------
  
  
	
  
    IF OBJECT_ID('tempdb.dbo.#FilteredRayonsTable') is not null 
	drop table #FilteredRayonsTable
	create table #FilteredRayonsTable  
	(
	idfsRegion BIGINT,
	idfsRayon BIGINT,
	primary key (idfsRegion, idfsRayon)  
	)
  
  	--DECLARE #ReportDataTable table
  	IF OBJECT_ID('tempdb.dbo.#ReportDataTable') is not null 
	drop table #ReportDataTable
	create table #ReportDataTable
	(
		id INT identity(1,1) primary key,
 		IdRegion BIGINT,
 		strRegion NVARCHAR(2000) collate database_default,
 		IdRayon	BIGINT,
 		strRayon NVARCHAR(2000) collate database_default,
 		strAZRayon NVARCHAR(2000) collate database_default,
 		IdDiagnosis BIGINT,
 		Diagnosis NVARCHAR(2000) collate database_default,
 		intRegionOrder INT,
 		intRayonOrder INT,
 		CountCasesForDiag INT
 	)
  

  	--DECLARE #ReportCaseTable table
  	IF OBJECT_ID('tempdb.dbo.#ReportCaseTable') is not null 
	drop table #ReportCaseTable
  	create table #ReportCaseTable
	(
					id INT identity(1,1) primary key,
 					idfCase BIGINT,
 					IdRegion BIGINT,
 					strRegion NVARCHAR(2000) collate database_default,
 					IdRayon	BIGINT,
 					strRayon NVARCHAR(2000) collate database_default,
 					strAZRayon  NVARCHAR(2000) collate database_default,
 					intRegionOrder INT,
 					intRayonOrder INT,
 					idfsShowDiagnosis BIGINT,
 					Diagnosis NVARCHAR(2000) collate database_default,	
 					idfsShowDiagnosisFromCase BIGINT,	
 																				
 		/*7(1)*/	IndCaseStatus FLOAT, 
 		/*8(2)*/	IndDateOfCompletionPaperFormDate FLOAT, 
 		/*9(3)*/	IndNameOfEmployer FLOAT, 
 		/*11(5)*/	IndCurrentLocation FLOAT, 
 		/*12(6)*/	IndNotificationDate FLOAT, 
 		/*13(7)*/	IndNotificationSentByName FLOAT, 
 		/*14(8)*/	IndNotificationReceivedByFacility FLOAT, 
 		/*15(9)*/	IndNotificationReceivedByName FLOAT,
 		/*16(10)*/	IndDateAndTimeOfTheEmergencyNotification FLOAT, 
 		
 		/*18(11)*/	IndInvestigationStartDate FLOAT, 
 		/*19(12)*/	IndOccupationType FLOAT, 
 		/*20(13)*/	IndInitialCaseClassification FLOAT, 
 		/*21(14)*/	IndLocationOfExplosure FLOAT, 
 		/*22(15)*/	IndAATherapyAdmBeforeSamplesCollection FLOAT, 
 		/*23(16)*/	IndSamplesCollected FLOAT, 
 		/*24(17)*/	IndAddcontact FLOAT, 
 		/*25(18)*/	IndClinicalSigns FLOAT, 
 		/*26(19)*/	IndEpidemiologicalLinksAndRiskFactors FLOAT,

 		/*27(20)*/	IndBasisOfDiagnosis FLOAT, 
 		/*28(21)*/	IndOutcome FLOAT, 
 		/*29(22)*/	IndISThisCaseRelatedToOutbreak FLOAT, 
 		/*30(23)*/	IndEpidemiologistName FLOAT, 

 		/*32(24)*/	IndResultsTestsConducted FLOAT, 
 		/*33(25)*/	IndResultsResultObservation FLOAT 
	)
	
	IF OBJECT_ID('tempdb.dbo.#ReportCaseTable_CountForDiagnosis') is not null 
	drop table #ReportCaseTable_CountForDiagnosis
	create table #ReportCaseTable_CountForDiagnosis
	(
	CountCase INT
 	, IdRegion BIGINT
 	, IdRayon BIGINT
	, idfsShowDiagnosis BIGINT
	primary key (IdRegion, IdRayon, idfsShowDiagnosis)
	)
 		
 
	insert into #FilteredRayonsTable
	SELECT  
		CASE WHEN s_current.intFlags = 1 AND cp.idfsCountry = @CountryID THEN @TransportCHE ELSE gls.idfsRegion END as idfsRegion,
		CASE WHEN s_current.intFlags = 1 AND cp.idfsCountry = @CountryID THEN s_current.idfsSite ELSE gls.idfsRayon END as idfsRayon
	FROM  tstSite s_current
		INNER JOIN	tstCustomizationPackage cp
		ON			cp.idfCustomizationPackage = s_current.idfCustomizationPackage
					AND cp.idfsCountry = @CountryID
		INNER JOIN	tlbOffice o_current
		ON			o_current.idfOffice = s_current.idfOffice
					AND o_current.intRowStatus = 0
		INNER JOIN	tlbGeoLocationShared gls
		ON			gls.idfGeoLocationShared = o_current.idfLocation
	WHERE  s_current.idfsSite = isnull(@SiteID, dbo.FN_GBL_SITEID_GET())
	   AND gls.idfsRayon is not null
	UNION
	SELECT  
		CASE WHEN s.intFlags = 1 AND cp.idfsCountry = @CountryID THEN @TransportCHE ELSE gls.idfsRegion END as idfsRegion,
		CASE WHEN s.intFlags = 1 AND cp.idfsCountry = @CountryID THEN s.idfsSite ELSE gls.idfsRayon END as idfsRayon
	FROM  tstSite s
		INNER JOIN	tstCustomizationPackage cp
		ON			cp.idfCustomizationPackage = s.idfCustomizationPackage	
					AND cp.idfsCountry = @CountryID
		
		INNER JOIN	tlbOffice o
		ON			o.idfOffice = s.idfOffice
					AND o.intRowStatus = 0
		INNER JOIN	tlbGeoLocationShared gls
		ON			gls.idfGeoLocationShared = o.idfLocation
		
		INNER JOIN	tflSiteToSiteGroup sts
			INNER JOIN	tflSiteGroup tsg
			ON			tsg.idfSiteGroup = sts.idfSiteGroup
						AND tsg.idfsRayon is null
		ON			sts.idfsSite = s.idfsSite
		
		INNER JOIN	tflSiteGroupRelation sgr
		ON			sgr.idfSenderSiteGroup = sts.idfSiteGroup
		
		INNER JOIN	tflSiteToSiteGroup stsr
			INNER JOIN	tflSiteGroup tsgr
			ON			tsgr.idfSiteGroup = stsr.idfSiteGroup
						AND tsgr.idfsRayon is null
		ON			sgr.idfReceiverSiteGroup =stsr.idfSiteGroup
					AND stsr.idfsSite = isnull(@SiteID, dbo.FN_GBL_SITEID_GET())
	WHERE  gls.idfsRayon is not null		
    
	-- + border area
	insert into #FilteredRayonsTable (idfsRayon)
	SELECT distinct
		osr.idfsRayon
	FROM #FilteredRayonsTable fr
		INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
          ON r.idfsRayon = fr.idfsRayon
          AND r.intRowStatus = 0
          
        INNER JOIN	tlbGeoLocationShared gls
		ON			gls.idfsRayon = r.idfsRayon
	
		INNER JOIN	tlbOffice o
		ON			gls.idfGeoLocationShared = o.idfLocation
					AND o.intRowStatus = 0
		
		INNER JOIN tstSite s
			INNER JOIN	tstCustomizationPackage cp
			ON			cp.idfCustomizationPackage = s.idfCustomizationPackage	
		ON s.idfOffice = o.idfOffice
		
		INNER JOIN tflSiteGroup tsg_cent 
		ON tsg_cent.idfsCentralSite = s.idfsSite
		AND tsg_cent.idfsRayon is null
		AND tsg_cent.intRowStatus = 0	
		
		INNER JOIN tflSiteToSiteGroup tstsg
		ON tstsg.idfSiteGroup = tsg_cent.idfSiteGroup
		
		INNER JOIN tstSite ts
		ON ts.idfsSite = tstsg.idfsSite
		
		INNER JOIN tlbOffice os
		ON os.idfOffice = ts.idfOffice
		AND os.intRowStatus = 0
		
		INNER JOIN tlbGeoLocationShared ogl
		ON ogl.idfGeoLocationShared = o.idfLocation
		
		INNER JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) osr
		ON osr.idfsRayon = ogl.idfsRayon
		AND ogl.intRowStatus = 0				
		
		LEFT JOIN #FilteredRayonsTable fr2 
		ON	osr.idfsRayon = fr2.idfsRayon
	WHERE fr2.idfsRayon is null
	

	insert into #ReportDataTable
	(IdRegion
 	,strRegion
 	,IdRayon
 	,strRayon
 	,strAZRayon
 	,IdDiagnosis
 	,Diagnosis
 	,intRegionOrder
 	,intRayonOrder
	)
 	
 	SELECT
 		reg.idfsRegion			as IdRegion
 		, refReg.[name]			as strRegion
 		, ray.idfsRayon			as IdRayon
 		, refRay.[name]			as strRayon
 		, refRayAZ.[name]		as strAZRayon
 		, 0						as IdDiagnosis
 		, ''					as Diagnosis
 		, CASE reg.idfsRegion
				  WHEN @idfsRegionBaku --1344330000000 --Baku
				  THEN 1
			      
				  WHEN @idfsRegionOtherRayons --1344340000000 --Other rayons
				  THEN 2
			      
				  WHEN @idfsRegionNakhichevanAR --1344350000000 --Nakhichevan AR
				  THEN 3
			      
				  ELSE 0
		  END 					as intRegionOrder
 		, 0						as intRayonOrder		
 	FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) as reg
 	JOIN fnGisReference(@LangID, 19000003 /*rftRegion*/) as refReg ON
 		reg.idfsRegion = refReg.idfsReference			
 		AND reg.idfsCountry = @CountryID
 	JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) as ray ON
 		ray.idfsRegion = reg.idfsRegion	
 	JOIN fnGisReference(@LangID, 19000002 /*rftRayon*/) as refRay ON
 		ray.idfsRayon = refRay.idfsReference
 	JOIN fnGisReference('az-l', 19000002 /*rftRayon*/) as refRayAZ ON
 		ray.idfsRayon = refRayAZ.idfsReference
	LEFT JOIN #FilteredRayonsTable frt
 		ON frt.idfsRegion = reg.idfsRegion
 		AND frt.idfsRayon = ray.idfsRayon 	

 	WHERE CAST(@Diagnosis as NVARCHAR(max)) = ''
 	AND (@isTLVL = 0 or frt.idfsRayon is not null or @isWeb = 1)
 	
 	
   UNION all
 	
 	SELECT 
 		tbr.idfsGISBaseReference		as IdRegion
 		, frr.[name]					as strRegion
 		, ts.idfsSite					as IdRayon
 		, fir.[name]					as strRayon
 		, firAZ.[name]					as strAZRayon
 		, 0								as IdDiagnosis
 		, ''							as Diagnosis 		
 		, 4								as intRegionOrder
 		, tbr1.intOrder					as intRayonOrder		
 	FROM gisBaseReference tbr --TransportCHE
 	JOIN dbo.fnGisReferenceRepair(@LangID, 19000020) frr
 		ON frr.idfsReference = tbr.idfsGISBaseReference
 		AND tbr.idfsGISBaseReference = @TransportCHE
	cross JOIN tstSite ts
		LEFT JOIN #FilteredRayonsTable frt
 		ON frt.idfsRegion = @TransportCHE
 		AND frt.idfsRayon = ts.idfsSite

 	JOIN tstCustomizationPackage cp
 		ON cp.idfCustomizationPackage = ts.idfCustomizationPackage
 		AND cp.idfsCountry = @CountryID
	JOIN dbo.fnInstitutionRepair(@LangID) fir	
		ON fir.idfOffice = ts.idfOffice
		AND ts.intFlags = 1
	JOIN dbo.fnInstitutionRepair('az-l') firAZ	
		ON firAZ.idfOffice = ts.idfOffice
		AND ts.intFlags = 1
	JOIN trtBaseReference tbr1
	ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation 
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) = ''		 	
	AND (@isTLVL = 0 or frt.idfsRayon is not null or @isWeb = 1)
	
 	

	UNION all
	
	SELECT
 		reg.idfsRegion			as IdRegion
 		, refReg.[name]			as strRegion
 		, ray.idfsRayon			as IdRayon
 		, refRay.[name]			as strRayon
 		, refRayAZ.[name]		as strAZRayon
 		, CAST(dt.[key] as BIGINT)				as IdDiagnosis
 		, refDiag.name			as Diagnosis
 		, CASE reg.idfsRegion
				  WHEN @idfsRegionBaku --1344330000000 --Baku
				  THEN 1
			      
				  WHEN @idfsRegionOtherRayons --1344340000000 --Other rayons
				  THEN 2
			      
				  WHEN @idfsRegionNakhichevanAR --1344350000000 --Nakhichevan AR
				  THEN 3
			      
				  ELSE 0
		  END 					as intRegionOrder
 		, 0						as intRayonOrder
 	FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) as reg
 	JOIN fnGisReference(@LangID, 19000003 /*rftRegion*/) as refReg ON
 		reg.idfsRegion = refReg.idfsReference			
 		AND reg.idfsCountry = @CountryID
 	JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) as ray ON
 		ray.idfsRegion = reg.idfsRegion	
 	JOIN fnGisReference(@LangID, 19000002 /*rftRayon*/) as refRay ON
 		ray.idfsRayon = refRay.idfsReference	
 	JOIN fnGisReference('az-l', 19000002 /*rftRayon*/) as refRayAZ ON
 		ray.idfsRayon = refRayAZ.idfsReference
	LEFT JOIN #FilteredRayonsTable frt
 		ON frt.idfsRegion = reg.idfsRegion
 		AND frt.idfsRayon = ray.idfsRayon

 	CROSS JOIN @DiagnosisTable as dt	
 	JOIN fnReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) as refDiag ON
 		dt.[key] = refDiag.idfsReference	
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) <> ''
 	AND (@isTLVL = 0 or frt.idfsRayon is not null or @isWeb = 1)
 	
 	
 	UNION all
 	
 	SELECT 
 		tbr.idfsGISBaseReference		as IdRegion
 		, frr.[name]					as strRegion
 		, ts.idfsSite					as IdRayon
 		, fir.[name]					as strRayon
 		, firAZ.[name]					as strAZRayon
		, CAST(dt.[key] as BIGINT)		as IdDiagnosis
 		, refDiag.name					as Diagnosis
 		, 4								as intRegionOrder
 		, tbr1.intOrder					as intRayonOrder		
 	FROM gisBaseReference tbr --TransportCHE
 	JOIN dbo.fnGisReferenceRepair(@LangID, 19000020) frr
 		ON frr.idfsReference = tbr.idfsGISBaseReference
 		AND tbr.idfsGISBaseReference = @TransportCHE
	cross JOIN tstSite ts
		LEFT JOIN #FilteredRayonsTable frt
 		ON frt.idfsRegion = @TransportCHE
 		AND frt.idfsRayon = ts.idfsSite
 	JOIN tstCustomizationPackage cp
 		ON cp.idfCustomizationPackage = ts.idfCustomizationPackage
 		AND cp.idfsCountry = @CountryID 		
	JOIN dbo.fnInstitutionRepair(@LangID) fir	
		ON fir.idfOffice = ts.idfOffice
		AND ts.intFlags = 1
	JOIN dbo.fnInstitutionRepair('az-l') firAZ
		ON firAZ.idfOffice = ts.idfOffice
		AND ts.intFlags = 1		
	JOIN trtBaseReference tbr1
		ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation 
 	cross JOIN @DiagnosisTable as dt	
 	JOIN fnReferenceRepair(@LangID, 19000019 /*rftDiagnosis*/) as refDiag 
 		ON	dt.[key] = refDiag.idfsReference	
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) <> ''		
	AND (@isTLVL = 0 or frt.idfsRayon is not null or @isWeb = 1)
	
	 	
	
	DECLARE @EPI table 
	(
	idfHumanCase BIGINT primary key,
	countEPI INT	
	)
	
	insert into @EPI (idfHumanCase, countEPI)
	SELECT 
		hcs.idfHumanCase,
		count(tap.idfActivityParameters) as countEPI
	FROM tlbHumanCase hcs
		INNER JOIN tlbObservation obs
		ON obs.idfObservation = hcs.idfEpiObservation
		AND obs.intRowStatus = 0
				
		INNER JOIN ffFormTemplate fft
		ON fft.idfsFormTemplate = obs.idfsFormTemplate
		AND idfsFormType = 10034011 /*Human Epi Investigations*/ 

		INNER JOIN dbo.ffParameterForTemplate pft
		ON pft.idfsFormTemplate = obs.idfsFormTemplate
		AND pft.intRowStatus = 0					
	
		INNER JOIN ffParameter fp
			INNER JOIN ffParameterType fpt
			ON fpt.idfsParameterType = fp.idfsParameterType
			AND fpt.idfsReferenceType is not null
			AND fpt.intRowStatus = 0
		ON fp.idfsParameter = pft.idfsParameter 
		AND fp.idfsFormType = 10034011 /*Human Epi Investigations*/ 
		--AND fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
		AND fp.intRowStatus = 0
	
		INNER JOIN tlbActivityParameters tap
		ON tap.idfObservation = obs.idfObservation
		AND tap.idfsParameter = fp.idfsParameter
		AND (
			fp.idfsParameterType = 217140000000 /*Y_N_Unk*/ AND CAST(tap.varValue as NVARCHAR)  in ( N'25460000000' /*pfv_YNU_yes*/ , N'25640000000' /*pfv_YNU_no*/)
			or
			fp.idfsParameterType <> 217140000000 AND tap.varValue is not null
			)
		AND tap.intRowStatus = 0
	WHERE hcs.intRowStatus = 0 
 		AND hcs.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/  
 		AND (@SDDate <= hcs.datFinalCaseClassificationDate AND hcs.datFinalCaseClassificationDate < @EDDate)
	group by hcs.idfHumanCase

 	--SELECT epi.idfHumanCase, epi.countEPI, thc.strCaseID FROM @EPI epi
 	--INNER JOIN tlbHumanCase thc
 	--ON thc.idfHumanCase = epi.idfHumanCase
 	--WHERE thc.strCaseID = 'HWEB00155811'
 	
 	
 	
 	DECLARE @CS table 
	(
	idfHumanCase BIGINT primary key,
	countCS INT,
	blnUNI bit
	)
	
	insert into @CS (idfHumanCase, countCS, blnUNI)
	SELECT 
		hcs.idfHumanCase,
		count(tap.idfActivityParameters) as countCS,
		fft.blnUNI
		
	FROM tlbHumanCase hcs
		INNER JOIN tlbObservation obs
		ON obs.idfObservation = hcs.idfCSObservation
		AND obs.intRowStatus = 0
		
		INNER JOIN dbo.ffParameterForTemplate pft
		ON pft.idfsFormTemplate = obs.idfsFormTemplate
		AND pft.idfsEditMode = 10068003 /*Mandatory*/
		AND pft.idfsFormTemplate = obs.idfsFormTemplate
		AND pft.intRowStatus = 0
		
		INNER JOIN ffFormTemplate fft
		ON fft.idfsFormTemplate = pft.idfsFormTemplate
		
		LEFT JOIN ffParameter fp
		ON fp.idfsParameter = pft.idfsParameter
		AND (fp.idfsParameterType = 217140000000 /*Y_N_Unk*/ or fp.idfsParameterType = 10071045	 /*text - parString*/)
		AND fp.idfsFormType = 10034010 /*Human Clinical Signs*/ 
		AND fp.intRowStatus = 0
					
		INNER JOIN tlbActivityParameters tap
		ON tap.idfObservation = obs.idfObservation
		AND tap.idfsParameter = fp.idfsParameter
		AND tap.intRowStatus = 0
		
		AND (
			(CAST(tap.varValue as NVARCHAR) = N'25460000000' /*pfv_YNU_yes,	Yes*/ 
			AND fp.idfsParameterType = 217140000000 /*Y_N_Unk*/
			AND fft.blnUNI = 0
			)
			or
			(fft.blnUNI = 1 AND
			fp.idfsParameterType = 10071045	 /*text - parString*/
			AND CAST(tap.varValue as NVARCHAR(500)) <> ''
			)
		)
	
		
	WHERE hcs.intRowStatus = 0 
 		AND hcs.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/  
 		AND (@SDDate <= hcs.datFinalCaseClassificationDate AND hcs.datFinalCaseClassificationDate < @EDDate)
	group by hcs.idfHumanCase, fft.blnUNI
 		

 	--SELECT cs.idfHumanCase, cs.countCS, thc.strCaseID FROM @CS cs
 	--INNER JOIN tlbHumanCase thc
 	--ON thc.idfHumanCase = cs.idfHumanCase
 	
 	--INNER JOIN tlbHuman th
 	--ON th.idfHuman = thc.idfHuman
 	
 	--INNER JOIN tlbGeoLocation tgl
 	--ON tgl.idfGeoLocation = th.idfCurrentResidenceAddress
 	--AND tgl.idfsRayon = 1344420000000
 	--WHERE thc.strCaseID = 'HWEB00154695'
 	
 	
 		
	IF OBJECT_ID('tempdb.dbo.#CCP') is not null 
	drop table #CCP
 	create table  #CCP  
	(
	idfHumanCase BIGINT primary key,
	countCCP INT	
	)
	
	insert into #CCP (idfHumanCase, countCCP)
	SELECT tccp.idfHumanCase,
 			count(tccp.idfContactedCasePerson) as CountContacts
 		FROM tlbContactedCasePerson tccp 
 		INNER JOIN tlbHumanCase thc
 		ON thc.idfHumanCase = tccp.idfHumanCase
 		WHERE thc.intRowStatus = 0 
 		AND thc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/  
 		AND (@SDDate <= thc.datFinalCaseClassificationDate AND thc.datFinalCaseClassificationDate < @EDDate)
 		AND tccp.intRowStatus = 0
 	group by tccp.idfHumanCase

	
	
	IF OBJECT_ID('tempdb.dbo.#CTR') is not null 
	drop table #CTR
 	create table  #CTR  
	(
	idfHumanCase BIGINT primary key,
	countCTR INT	
	)
	
	insert into #CTR (idfHumanCase, countCTR)
	SELECT m.idfHumanCase, count(tt.idfTesting) as CountTestResults
 		FROM tlbMaterial m
 			INNER JOIN tlbTesting tt
 			ON tt.idfMaterial = m.idfMaterial
 			AND tt.intRowStatus = 0
 			AND tt.idfsTestResult is not null
 			INNER JOIN tlbHumanCase thc
 			ON thc.idfHumanCase = m.idfHumanCase
 		WHERE thc.intRowStatus = 0 
 			AND thc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/  
 			AND (@SDDate <= thc.datFinalCaseClassificationDate AND thc.datFinalCaseClassificationDate < @EDDate)
 			AND m.intRowStatus = 0
 			AND m.idfHumanCase is not null
 		group by m.idfHumanCase
 			
	
	insert into #ReportCaseTable 
	(
 					idfCase,
 					IdRegion,
 					strRegion,
 					IdRayon,
 					strRayon,
 					strAZRayon,
 					intRegionOrder,
 					intRayonOrder,
 					idfsShowDiagnosis,
 					Diagnosis,	
 					idfsShowDiagnosisFromCase,	
 																				
 		/*7(1)*/	IndCaseStatus, 			
 		/*8(2)*/	IndDateOfCompletionPaperFormDate, 
 		/*9(3)*/	IndNameOfEmployer, 
 		/*11(5)*/	IndCurrentLocation, 
 		/*12(6)*/	IndNotificationDate, 
 		/*13(7)*/	IndNotificationSentByName, 
 		/*14(8)*/	IndNotificationReceivedByFacility, 
 		/*15(9)*/	IndNotificationReceivedByName,
 		/*16(10)*/	IndDateAndTimeOfTheEmergencyNotification, 
 		
 		/*18(11)*/	IndInvestigationStartDate, 
 		/*19(12)*/	IndOccupationType, 
 		/*20(13)*/	IndInitialCaseClassification, 
 		/*21(14)*/	IndLocationOfExplosure, 
 		/*22(15)*/	IndAATherapyAdmBeforeSamplesCollection, 
 		/*23(16)*/	IndSamplesCollected, 
 		/*24(17)*/	IndAddcontact, 
 		/*25(18)*/	IndClinicalSigns, 
 		/*26(19)*/	IndEpidemiologicalLinksAndRiskFactors, 
 		
 		/*27(20)*/	IndBasisOfDiagnosis, 
 		/*28(21)*/	IndOutcome, 
 		/*29(22)*/	IndISThisCaseRelatedToOutbreak, 
 		/*30(23)*/	IndEpidemiologistName, 
 		
 		/*32(24)*/	IndResultsTestsConducted, 
 		/*33(25)*/	IndResultsResultObservation 
	 )	
	 SELECT
 		hc.idfHumanCase as idfCase
 		, fdt.IdRegion 
 		, fdt.strRegion 
 		, fdt.IdRayon
 		, fdt.strRayon 
 		, fdt.strAZRayon
 		, fdt.intRegionOrder
 		, fdt.intRayonOrder
 		, isnull(fdt.IdDiagnosis, '')											as idfsShowDiagnosis 
 		, isnull(fdt.Diagnosis, '')												as Diagnosis 	
 		, isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)				as idfsShowDiagnosisFromCase		
 																		
 		,/*7(1)*/ 
 		CASE 
 			WHEN hc.idfsCaseProgressStatus = 10109002 /*Closed*/ 
 				THEN @Ind_N1_CaseStatus 
 			ELSE 0.00 
 		END	as IndCaseStatus 
 		
 		,/*8(2)*/ 
 		CASE 
 			WHEN isnull(hc.datCompletionPaperFormDate, '') <> '' 
 				THEN @Ind_N1_DateofCompletionPF 
 			ELSE 0.00 
 		END		as IndDateOfCompletionPaperFormDate 
 		
 		,/*9(3)*/ 
 		CASE 
 			WHEN isnull(h.strEmployerName, '') <> '' 
 				THEN @Ind_N1_NameofEmployer 
 			ELSE 0.00 
 		END	as IndNameOfEmployer 
 		
 		,/*11(5)*/ 
 		CASE 
 			WHEN isnull(hc.idfsHospitalizationStatus, 0) <> 0 
 				THEN @Ind_N1_CurrentLocationPatient 
 			ELSE 0.00 
 		END		as IndCurrentLocation 
 		
 		,/*12(6)*/ 
 		CASE 
 			WHEN (isnull(hc.datCompletionPaperFormDate, '') <> '' AND hc.datCompletionPaperFormDate = hc.datNotificationDate)
 					OR (
 							isnull(hc.datCompletionPaperFormDate, '') <> '' 
 							AND isnull(hc.datNotificationDate, '') <> '' 
 							AND CAST(hc.datNotificationDate - hc.datCompletionPaperFormDate as FLOAT) < 1
 						)
 				THEN @Ind_N1_NotifDateTime
 			WHEN isnull(hc.datCompletionPaperFormDate, '') <> '' 
 					AND isnull(hc.datNotificationDate, '') <> '' 
 					AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datCompletionPaperFormDate) as FLOAT) between 1 AND 2
 				THEN @Ind_N2_NotifDateTime
 			WHEN isnull(hc.datCompletionPaperFormDate, '') <> ''
 					AND isnull(hc.datNotificationDate, '') <> ''
 					AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datCompletionPaperFormDate) as FLOAT) > 2
 				THEN @Ind_N3_NotifDateTime
 			ELSE 0.00
 		END	as IndNotificationDate 
 		
 		
 		,/*13(7)*/ 
		CASE 
			WHEN isnull(hc.idfSentByPerson, '') <> '' 
				THEN @Ind_N1_NotifSentByName 
			ELSE 0.00 
		END	as IndNotificationSentByName 
 		
 		,/*14(8)*/ 
		CASE 
			WHEN isnull(hc.idfReceivedByOffice, '') <> '' 
				THEN @Ind_N1_NotifReceivedByFacility 
			ELSE 0.00 
		END	as IndNotificationReceivedByFacility 
 		
 		,/*15(9)*/ 
		CASE 
			WHEN isnull(hc.idfReceivedByPerson, '') <> ''
				THEN @Ind_N1_NotifReceivedByName 
			ELSE 0.00 
		END	as IndNotificationReceivedByName
 		
 		,/*16(10)*/ 
		CASE 
			WHEN isnull(hc.datEnteredDate, '') <> '' 
					AND isnull(hc.datNotificationDate, '') <> '' 
					AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) as FLOAT) < 1
				THEN @Ind_N1_TimelinessOfDataEntryDTEN
			WHEN isnull(hc.datEnteredDate, '') <> '' 
					AND isnull(hc.datNotificationDate, '') <> '' 
					AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) as FLOAT) between 1 AND 2
				THEN @Ind_N2_TimelinessOfDataEntryDTEN
			WHEN isnull(hc.datEnteredDate, '') <> ''
					AND isnull(hc.datNotificationDate, '') <> ''
					AND CAST(dbo.fnDateCutTime(hc.datEnteredDate) - dbo.fnDateCutTime(hc.datNotificationDate) as FLOAT) > 2
				THEN @Ind_N3_TimelinessOfDataEntryDTEN
			ELSE 0.00
		END	as IndDateAndTimeOfTheEmergencyNotification 
		
 		,/*18(11)*/ 
		CASE 
			WHEN isnull(hc.datInvestigationStartDate, '') <> '' 
			AND isnull(hc.datNotificationDate, '') <> '' 
			AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) as FLOAT) < 1
			THEN @Ind_N1_DIStartingDTOfInvestigation
 			
			WHEN isnull(hc.datInvestigationStartDate, '') <> '' 
			AND isnull(hc.datNotificationDate, '') <> '' 
			AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) as FLOAT) between 1 AND 2
			THEN @Ind_N2_DIStartingDTOfInvestigation
 			
			WHEN isnull(hc.datInvestigationStartDate, '') <> ''
					AND isnull(hc.datNotificationDate, '') <> ''
					AND CAST(dbo.fnDateCutTime(hc.datNotificationDate) - dbo.fnDateCutTime(hc.datInvestigationStartDate) as FLOAT) > 2
			THEN @Ind_N3_DIStartingDTOfInvestigation
 			
			ELSE 0.00
		END	as IndInvestigationStartDate 
 		
 		,/*19(12)*/ 
 			CASE	WHEN isnull(h.idfsOccupationType, '') <> '' 
 				THEN @Ind_N1_DIOccupation 
 				ELSE 0.00 
 			END																					as IndOccupationType --20(13)
 			
 		, CASE	WHEN isnull(hc.idfsInitialCaseStatus, '') = 380000000 /*Suspect*/
 				OR isnull(hc.idfsInitialCaseStatus, '') = 360000000 /*Probable CASE*/ 
 				THEN @Ind_N1_CIInitCaseClassification 
 				ELSE 0.00 
 				END																				as IndInitialCaseClassification --21(14)
 		  
 		, CASE 
 			WHEN isnull(tgl.idfsRegion, 0) <> 0 
 				AND isnull(tgl.idfsRayon, 0) <> 0 
 				AND isnull(tgl.idfsSettlement, 0) <> 0
				THEN @Ind_N1_CILocationOfExposure 
				ELSE 0.00 
	 		  END																				as IndLocationOfExplosure --22(15)
 		  
 		, CASE	WHEN isnull(hc.idfsYNAntimicrobialTherapy, '') <> '' 
 				THEN @Ind_N1_CIAntibioticTherapyAdministratedBSC 
 				ELSE 0.00 
 				END																				as IndAATherapyAdmBeforeSamplesCollection --23(16)
 					
 					
 					
 		, CASE	WHEN (dt.blnLaboratoryConfirmation = 1 AND  
 					hc.idfsYNSpecimenCollected = 10100001 /*Yes*/) or
 					dt.blnLaboratoryConfirmation = 0
 				THEN  @Ind_N1_SamplesCollection  
 				ELSE 0.00 END																	as IndSamplesCollected -- 24(17)
 		
 		
 		
 		, CASE	WHEN CCP.CountCCP > 0
 				THEN @Ind_N1_ContactLisAddContact
 				ELSE 0.00 END 																	as IndAddcontact -- 25(18)
 				 		
 		, CASE	WHEN 
 					dt.intQuantityOfMandatoryFieldCSForDC = 0 
 					or
 					(dt.intQuantityOfMandatoryFieldCSForDC = 1 AND
 					CS.blnUNI = 1 AND
 					CS.countCS >= 1
 					)
 					or
 					(dt.intQuantityOfMandatoryFieldCSForDC > 0 
 					AND CS.blnUNI = 0
 					AND CS.countCS >= dt.intQuantityOfMandatoryFieldCSForDC) 
 				THEN @Ind_N1_CaseClassificationCS
 				ELSE 0.00
 				END																				as IndClinicalSigns -- 26(19)
 		
 		, CASE	WHEN (dt.intEPILincsAndFactors > 0
 				AND EPI.countEPI > 0.8 * dt.intEPILincsAndFactors) or
 				dt.intEPILincsAndFactors = 0
 				THEN @Ind_N1_EpiLinksRiskFactorsByEpidCard
 				
 				WHEN dt.intEPILincsAndFactors > 0
 				AND EPI.countEPI > 0.5 * dt.intEPILincsAndFactors
 				AND EPI.countEPI <= 0.8 * dt.intEPILincsAndFactors
 				THEN @Ind_N2_EpiLinksRiskFactorsByEpidCard
 				
 				WHEN dt.intEPILincsAndFactors > 0
 				AND EPI.countEPI <= 0.5 * dt.intEPILincsAndFactors
 				THEN @Ind_N3_EpiLinksRiskFactorsByEpidCard
 				ELSE 0.00
 				END																				as IndEpidemiologicalLinksAndRiskFactors --27(20)
 		
 		
 		, CASE WHEN isnull(hc.blnClinicalDiagBasis, '') = 1 
 				OR isnull(hc.blnLabDiagBasis, '') = 1 
 				OR isnull(hc.blnEpiDiagBasis, '') = 1 
 				THEN @Ind_N1_FCCOBasisOfDiagnosis 
 				ELSE 0.00 
 				END																				as IndBasisOfDiagnosis --30(23)
 		
 		, CASE WHEN isnull(hc.idfsOutcome, '') <> '' 
 				THEN @Ind_N1_FCCOOutcome 
 				ELSE 0.00 
 				END																				as IndOutcome --31(24)
 		
 		, CASE WHEN isnull(hc.idfsYNRelatedToOutbreak, '') = 10100001 /*Yes*/
 			OR isnull(hc.idfsYNRelatedToOutbreak, '') = 10100002 /*No*/
 				THEN @Ind_N1_FCCOIsThisCaseRelatedToOutbreak
 				 ELSE 0.00 
 				END																				as IndISThisCaseRelatedToOutbreak	 --32(25)
 		, CASE	WHEN isnull(hc.idfInvestigatedByPerson, '') <> '' 
 				THEN @Ind_N1_FCCOEpidemiologistName 
 				ELSE 00.00 
 				END																				as IndEpidemiologistName --33(26)
 		
 		, CASE	WHEN (dt.blnLaboratoryConfirmation = 1
 				AND hc.idfsYNTestsConducted	= 10100001 /*Yes*/) or 
 				dt.blnLaboratoryConfirmation = 0
 				THEN @Ind_N1_ResultsOfLabTestsTestsConducted
 				ELSE 0.00
 				END																				as IndResultsTestsConducted --35(27)
 		, CASE	WHEN (dt.blnLaboratoryConfirmation = 1
 				AND CTR.CountCTR > 0) or 
 				dt.blnLaboratoryConfirmation = 0
 				THEN @Ind_N1_ResultsOfLabTestsResultObservation 
 				ELSE 0.00
 				END																				as IndResultsResultObservation --36(28)
 		
  	FROM (SELECT * FROM #ReportDataTable as rt
  	      WHERE (rt.IdRegion = @RegionID or @RegionID is null) AND
  				(rt.IdRayon = @RayonID or @RayonID is null)
  	)fdt 
	
 	LEFT JOIN tlbHumanCase hc 

		JOIN tstSite ts
 		ON ts.idfsSite = hc.idfsSite 		
 			     
 		JOIN tlbHuman h 
 		ON	hc.idfHuman = h.idfHuman 
 			AND h.intRowStatus = 0
 			
 		JOIN tlbGeoLocation gl 
 		ON	h.idfCurrentResidenceAddress = gl.idfGeoLocation 
 			AND gl.intRowStatus = 0    
 			
 		LEFT JOIN tlbGeoLocation tgl 
 		ON	tgl.idfGeoLocation = hc.idfPointGeoLocation
 		AND tgl.intRowStatus = 0
 			
 	ON	
 		hc.intRowStatus = 0 
 		AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/  
 		AND (@SDDate <= hc.datFinalCaseClassificationDate AND hc.datFinalCaseClassificationDate < @EDDate)
 		AND
 		(
 			(isnull(ts.intFlags, 0) = 0 AND
 				 fdt.IdRegion = gl.idfsRegion AND
				 fdt.IdRayon = gl.idfsRayon
 			) or
			(ts.intFlags = 1 AND
				fdt.IdRegion = @TransportCHE AND
				fdt.IdRayon = hc.idfsSite         
			)
        ) AND 
        fdt.IdDiagnosis =
 						CASE 
 							WHEN CAST(@Diagnosis as NVARCHAR(max)) <> '' THEN isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)	
 							ELSE fdt.IdDiagnosis
 						END
 						
	LEFT JOIN @DiagnosisTable dt
  	ON dt.[key] = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)	
  	 						
 	LEFT JOIN @CS as CS
 	ON CS.idfHumanCase = hc.idfHumanCase
 	
 	LEFT JOIN @EPI as EPI
 	ON EPI.idfHumanCase = hc.idfHumanCase
 	
  	LEFT JOIN #CCP as CCP
 	ON CCP.idfHumanCase = hc.idfHumanCase
 	
 	LEFT JOIN #CTR as CTR
 	ON CTR.idfHumanCase = hc.idfHumanCase
	
 	


	insert into #ReportCaseTable_CountForDiagnosis 
 	SELECT
 		count(*) as CountCase
 		,IdRegion
 		, IdRayon
 		, idfsShowDiagnosis
 	FROM #ReportCaseTable rct
 		LEFT JOIN @DiagnosisTable dt
 		ON dt.[key] = rct.idfsShowDiagnosisFromCase
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) <> ''
 	AND rct.idfCase is not null
 	group by IdRegion, strRegion, intRegionOrder, IdRayon, strRayon, intRayonOrder, idfsShowDiagnosis, Diagnosis, blnLaboratoryConfirmation,  intQuantityOfMandatoryFieldCSForDC
	UNION all
 	SELECT
 		0 as CountCase
 		,IdRegion
 		, IdRayon
 		, idfsShowDiagnosis
 	FROM #ReportCaseTable rct
 		LEFT JOIN @DiagnosisTable dt
 		ON dt.[key] = rct.idfsShowDiagnosisFromCase
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) <> ''
 	AND rct.idfCase is null
 	group by IdRegion, strRegion, intRegionOrder, IdRayon, strRayon, intRayonOrder, idfsShowDiagnosis, Diagnosis, blnLaboratoryConfirmation,  intQuantityOfMandatoryFieldCSForDC


 ;
 with 
 ReportSumCaseTable 
 as
 (
 	SELECT
 		rct.IdRegion
 		, rct.strRegion																											
 		, rct.IdRayon
 		, rct.strRayon		
 		, rct.strAZRayon																										
 		, rct.idfsShowDiagnosis
 		, rct.Diagnosis																											
  		, rct.intRegionOrder
 		, rct.intRayonOrder
 		, rct_count.CountCase as intCaseCount	
 		,/*7(1)*/ 
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndCaseStatus)/rct_count.CountCase								
 				END													as IndCaseStatus							
 		,/*8(2)*/ 
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndDateOfCompletionPaperFormDate)/rct_count.CountCase			
 				END													as IndDateOfCompletionPaperFormDate				
 		,/*9(3)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndNameOfEmployer)/rct_count.CountCase							
 				END													as IndNameOfEmployer							
 		,/*11(5)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndCurrentLocation)/rct_count.CountCase						
 				END													as IndCurrentLocation							
 		,/*12(6)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationDate)/rct_count.CountCase							
 				END													as IndNotificationDate							
 		,/*13(7)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationSentByName)/rct_count.CountCase					
 				END													as IndNotificationSentByName					
 		,/*14(8)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationReceivedByFacility)/rct_count.CountCase			
 				END													as IndNotificationReceivedByFacility			
 		,/*15(9)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationReceivedByName)/rct_count.CountCase				
 				END													as IndNotificationReceivedByName				
 		,/*16(10)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndDateAndTimeOfTheEmergencyNotification)/rct_count.CountCase	
 				END													as IndDateAndTimeOfTheEmergencyNotification		
  		,/*18(11)*/
  		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndInvestigationStartDate)/rct_count.CountCase					
 				END													as IndInvestigationStartDate					
 		,/*19(12)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndOccupationType)/rct_count.CountCase							
 				END													as IndOccupationType							
 		,/*20(13)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndInitialCaseClassification)/rct_count.CountCase				
 				END													as IndInitialCaseClassification					
 		,/*21(14)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndLocationOfExplosure)/rct_count.CountCase						
 				END													as IndLocationOfExplosure						
 		,/*22(15)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndAATherapyAdmBeforeSamplesCollection)/rct_count.CountCase		
 				END													as IndAATherapyAdmBeforeSamplesCollection		
 		,/*23(16)*/
 		CASE	WHEN rct_count.CountCase > 0
 				THEN sum(IndSamplesCollected)/rct_count.CountCase
 				ELSE 0.00 
 				END													as IndSamplesCollected							
 		,/*24(17)*/
 		CASE	WHEN rct_count.CountCase > 0
 				THEN sum(IndAddcontact)/rct_count.CountCase								
 				ELSE 0.00 
 				END													as IndAddcontact								
 		,/*25(18)*/
 		CASE	WHEN rct_count.CountCase > 0 
 				THEN sum(IndClinicalSigns)/rct_count.CountCase	
 				ELSE 0.00 END										as IndClinicalSigns								
 		,/*26(19)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndEpidemiologicalLinksAndRiskFactors)/rct_count.CountCase		
 				END													as IndEpidemiologicalLinksAndRiskFactors		
 		,/*27(20)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndBasisOfDiagnosis)/rct_count.CountCase							
 				END													as IndBasisOfDiagnosis							
 		,/*28(21)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndOutcome)/rct_count.CountCase									
 				END													as IndOutcome									
 		,/*29(22)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndISThisCaseRelatedToOutbreak)/rct_count.CountCase				
 				END													as IndISThisCaseRelatedToOutbreak				
 		,/*30(23)*/
 		CASE	WHEN rct_count.CountCase = 0 
 				THEN 0.00
 				ELSE sum(IndEpidemiologistName)/rct_count.CountCase						
 				END													as IndEpidemiologistName						
 		,/*32(24)*/
 		CASE	WHEN rct_count.CountCase > 0
 				THEN sum(IndResultsTestsConducted)/rct_count.CountCase	
 				ELSE 0.00
 				END													as IndResultsTestsConducted						
 		,/*33(25)*/
 		CASE	WHEN rct_count.CountCase > 0
 				THEN sum(IndResultsResultObservation)/rct_count.CountCase					
 				ELSE 0.00 
 				END													as IndResultsResultObservation					
 	FROM #ReportCaseTable rct
 		INNER JOIN #ReportCaseTable_CountForDiagnosis rct_count
 		ON rct.IdRegion = rct_count.IdRegion
 		AND rct.IdRayon = rct_count.IdRayon
 		AND rct.idfsShowDiagnosis = rct_count.idfsShowDiagnosis
 		LEFT JOIN @DiagnosisTable dt
 		ON dt.[key] = rct.idfsShowDiagnosisFromCase
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) <> ''
 	group by rct.IdRegion, rct.strRegion, rct.intRegionOrder, rct.IdRayon, rct.strRayon, rct.strAZRayon, rct.intRayonOrder, 
 	rct.idfsShowDiagnosis, rct.Diagnosis, dt.blnLaboratoryConfirmation, dt.intQuantityOfMandatoryFieldCSForDC, rct_count.CountCase
 )
 , ReportSumCaseTableForRayons
 as
 (
 	SELECT
 		IdRegion
 		, strRegion																											
 		, IdRayon
 		, strRayon		
 		, strAZRayon																									
 		, idfsShowDiagnosis
 		, Diagnosis																											
  		, intRegionOrder
 		, intRayonOrder
 		,/*7(1)*/	sum(IndCaseStatus)										as IndCaseStatus							
 		,/*8(2)*/	sum(IndDateOfCompletionPaperFormDate)					as IndDateOfCompletionPaperFormDate				
 		,/*9(3)*/	sum(IndNameOfEmployer)									as IndNameOfEmployer							
 		,/*11(5)*/	sum(IndCurrentLocation)									as IndCurrentLocation						
 		,/*12(6)*/	sum(IndNotificationDate)								as IndNotificationDate							
 		,/*13(7)*/	sum(IndNotificationSentByName)							as IndNotificationSentByName					
 		,/*14(8)*/	sum(IndNotificationReceivedByFacility)					as IndNotificationReceivedByFacility			
 		,/*15(9)*/	sum(IndNotificationReceivedByName)						as IndNotificationReceivedByName				
 		,/*16(10)*/	sum(IndDateAndTimeOfTheEmergencyNotification)			as IndDateAndTimeOfTheEmergencyNotification		
 
 		,/*18(11)*/ sum(IndInvestigationStartDate)							as IndInvestigationStartDate					
 		,/*19(12)*/ sum(IndOccupationType)									as IndOccupationType							
 		,/*20(13)*/ sum(IndInitialCaseClassification)						as IndInitialCaseClassification					
 		,/*21(14)*/ sum(IndLocationOfExplosure)								as IndLocationOfExplosure						
 		,/*22(15)*/ sum(IndAATherapyAdmBeforeSamplesCollection)				as IndAATherapyAdmBeforeSamplesCollection		
 		
 		,/*23(16)*/
 		CASE	WHEN dt.blnLaboratoryConfirmation = 1 
 				THEN sum(IndSamplesCollected)
 				ELSE 0.00 
 				END															as IndSamplesCollected							
 		, CASE	WHEN dt.blnLaboratoryConfirmation = 1 
 				THEN count(idfCase)
 				ELSE 0.00 
 				END															as CountIndSamplesCollected							
 		,/*24(17)*/ sum(IndAddcontact)										as IndAddcontact								
 		,/*25(18)*/
 		CASE	WHEN dt.intQuantityOfMandatoryFieldCSForDC > 0 
 				THEN sum(IndClinicalSigns)
 				ELSE 0.00 END												as IndClinicalSigns								
 		, CASE	WHEN dt.intQuantityOfMandatoryFieldCSForDC > 0 
 				THEN count(idfCase)
 				ELSE 0.00 END												as CountIndClinicalSigns								
 		,/*26(19)*/ sum(IndEpidemiologicalLinksAndRiskFactors)				as IndEpidemiologicalLinksAndRiskFactors		
		
 		,/*27(20)*/ sum(IndBasisOfDiagnosis)								as IndBasisOfDiagnosis							
 		,/*28(21)*/ sum(IndOutcome)											as IndOutcome									
 		,/*29(22)*/ sum(IndISThisCaseRelatedToOutbreak)						as IndISThisCaseRelatedToOutbreak				
 		,/*30(23)*/ sum(IndEpidemiologistName)								as IndEpidemiologistName						
 		,/*32(24)*/
 		CASE	WHEN dt.blnLaboratoryConfirmation = 1 
 				THEN sum(IndResultsTestsConducted)	
 				ELSE 0.00
 				END															as IndResultsTestsConducted						
 		, CASE	WHEN dt.blnLaboratoryConfirmation = 1 
 				THEN count(idfCase)	
 				ELSE 0.00
 				END															as CountIndResultsTestsConducted	 				
 		,/*33(25)*/
 		CASE	WHEN dt.blnLaboratoryConfirmation = 1 
 				THEN sum(IndResultsResultObservation)					
 				ELSE 0.00 
 				END															as IndResultsResultObservation					
 		, CASE	WHEN dt.blnLaboratoryConfirmation = 1 
 				THEN count(idfCase)					
 				ELSE 0.00 
 				END															as CountIndResultsResultObservation
 		, count(idfCase)													as CountRecForDiag	
 	FROM #ReportCaseTable rct
 		LEFT JOIN @DiagnosisTable dt
 		ON dt.[key] = rct.idfsShowDiagnosisFromCase
	WHERE CAST(@Diagnosis as NVARCHAR(max)) = '' 		
 	group by IdRegion, strRegion, intRegionOrder, IdRayon, strRayon, strAZRayon, intRayonOrder, idfsShowDiagnosis, Diagnosis, blnLaboratoryConfirmation, intQuantityOfMandatoryFieldCSForDC
 )
 , ReportSumCaseTableForRayons_Summary
 as
 (
 	SELECT
 		IdRegion
 		, strRegion																										
 		, IdRayon
 		, strRayon		
 		, strAZRayon																								
 		, '' as idfsShowDiagnosis
 		, '' as Diagnosis																											
  		, intRegionOrder
 		, intRayonOrder
		, sum(CountRecForDiag) as intCaseCount -- UPDATE 29.11.14
		
 		,/*7(1)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndCaseStatus)/sum(CountRecForDiag)										
 				END																		as IndCaseStatus								
 		,/*8(2)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndDateOfCompletionPaperFormDate)/sum(CountRecForDiag)					
 				END																		as IndDateOfCompletionPaperFormDate				
 		,/*9(3)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndNameOfEmployer)/sum(CountRecForDiag)									
 				END																		as IndNameOfEmployer							
 		,/*11(5)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndCurrentLocation)/sum(CountRecForDiag)									
 				END																		as IndCurrentLocation							
 		,/*12(6)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationDate)/sum(CountRecForDiag)									
 				END																		as IndNotificationDate							
 		,/*13(7)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationSentByName)/sum(CountRecForDiag)							
 				END																		as IndNotificationSentByName				
 		,/*14(8)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationReceivedByFacility)/sum(CountRecForDiag)					
 				END																		as IndNotificationReceivedByFacility			
 		,/*15(9)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndNotificationReceivedByName)/sum(CountRecForDiag)						
 				END																		as IndNotificationReceivedByName				
 		,/*16(10)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndDateAndTimeOfTheEmergencyNotification)/sum(CountRecForDiag)			
 				END																		as IndDateAndTimeOfTheEmergencyNotification		
 				
 		,/*18(11)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndInvestigationStartDate)/sum(CountRecForDiag)							
 				END																		as IndInvestigationStartDate					
 		,/*19(12)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndOccupationType)/sum(CountRecForDiag)									
 				END																		as IndOccupationType							
 		,/*20(13)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndInitialCaseClassification)/sum(CountRecForDiag)						
 				END																		as IndInitialCaseClassification					
 		,/*21(14)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndLocationOfExplosure)/sum(CountRecForDiag)								
 				END																		as IndLocationOfExplosure						
 		,/*22(15)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndAATherapyAdmBeforeSamplesCollection)/sum(CountRecForDiag)				
 				END																		as IndAATherapyAdmBeforeSamplesCollection		
 		
 		,/*23(16)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 THEN 0.00
 				WHEN sum(CountIndSamplesCollected) = 0 THEN 0.00
 				ELSE sum(IndSamplesCollected)/sum(CountIndSamplesCollected) 						
 				END																		as IndSamplesCollected							
 		,/*24(17)*/
 		 CASE	WHEN sum(CountRecForDiag) = 0 THEN 0.00
 				ELSE sum(IndAddcontact)/sum(CountRecForDiag)									
 				END																		as IndAddcontact								
 		,/*25(18)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 THEN 0.00
 				WHEN sum(CountIndClinicalSigns) = 0 THEN 0.00
 				ELSE sum(IndClinicalSigns)/sum(CountIndClinicalSigns)								
 				END																		as IndClinicalSigns								
 		,/*26(19)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndEpidemiologicalLinksAndRiskFactors)/sum(CountRecForDiag)				
 				END																		as IndEpidemiologicalLinksAndRiskFactors		

 		,/*27(20)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndBasisOfDiagnosis)/sum(CountRecForDiag)									
 				END																		as IndBasisOfDiagnosis							
 		,/*28(21)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndOutcome)/sum(CountRecForDiag)											
 				END																		as IndOutcome									
 		,/*29(22)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndISThisCaseRelatedToOutbreak)/sum(CountRecForDiag)						
 				END																		as IndISThisCaseRelatedToOutbreak				
 		,/*30(23)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 
 				THEN 0.00
 				ELSE sum(IndEpidemiologistName)/sum(CountRecForDiag)								
 				END																		as IndEpidemiologistName	
 									
 		,/*32(24)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 THEN 0.00
 				WHEN sum(CountIndResultsTestsConducted) = 0 THEN 0.00
 				ELSE sum(IndResultsTestsConducted)/sum(CountIndResultsTestsConducted)				
 				END																		as IndResultsTestsConducted						
 		,/*33(25)*/
 		 CASE	WHEN sum(isnull(CountRecForDiag,0)) = 0 THEN 0.00
 				WHEN sum(CountIndResultsResultObservation) = 0 THEN 0.00
 				ELSE sum(IndResultsResultObservation)/sum(CountIndResultsResultObservation)		
 				END																		as IndResultsResultObservation					
 				
 													
 	FROM ReportSumCaseTableForRayons rct
 	WHERE CAST(@Diagnosis as NVARCHAR(max)) = '' 
 	group by IdRegion, strRegion, intRegionOrder, IdRayon, strRayon, strAZRayon, intRayonOrder--, CountRecForDiag -- UPDATE 29.11.14
 ) 
 

	insert into @ReportTable
	 (
 		idfsRegion
 		, strRegion	
 		, intRegionOrder								
 		, idfsRayon
 		, strRayon
 		, strAZRayon
 		, intRayonOrder
 		, intCaseCount
 		, idfsDiagnosis
 		, strDiagnosis
 		, dbl_1_Notification
 		, dblCaseStatus
 		, dblDateOfCompletionOfPaperForm
 		, dblNameOfEmployer
 		, dblCurrentLocationOfPatient
 		, dblNotificationDateTime
 		, dbldblNotificationSentByName
 		, dblNotificationReceivedByFacility
 		, dblNotificationReceivedByName
 		, dblTimelinessofDataEntry
 		, dbl_2_CaseInvestigation
 		, dblDemographicInformationStartingDateTimeOfInvestigation
 		, dblDemographicInformationOccupation
 		, dblClinicalInformationInitialCaseClassification
 		, dblClinicalInformationLocationOfExposure
 		, dblClinicalInformationAntibioticAntiviralTherapy
 		, dblSamplesCollectionSamplesCollected
 		, dblContactListAddContact
 		, dblCaseClassificationClinicalSigns
 		, dblEpidemiologicalLinksAndRiskFactors
 		, dblFinalCaseClassificationBasisOfDiagnosis
 		, dblFinalCaseClassificationOutcome
 		, dblFinalCaseClassificationIsThisCaseOutbreak
 		, dblFinalCaseClassificationEpidemiologistName
 		, dbl_3_TheResultsOfLaboratoryTests
 		, dblTheResultsOfLaboratoryTestsTestsConducted
 		, dblTheResultsOfLaboratoryTestsResultObservation
 		, dblSummaryScoreByIndicators
	 )
	 
	SELECT
 			  IdRegion
			, strRegion	
	 		, intRegionOrder
 			, IdRayon
			, strRayon
			, strAZRayon
 			, intRayonOrder
 			, intCaseCount
			, idfsShowDiagnosis
		 	, Diagnosis
 	
		 	,/*6(1+2+3+5+6+8+9+10)*/
		 				  /*7(1)*/IndCaseStatus
 						+ /*8(2)*/IndDateOfCompletionPaperFormDate
 						+ /*9(3)*/IndNameOfEmployer
 						+ /*11(5)*/IndCurrentLocation
 						+ /*12(6)*/IndNotificationDate
 						+ /*13(7)*/IndNotificationSentByName
 						+ /*14(8)*/IndNotificationReceivedByFacility
 						+ /*15(9)*/IndNotificationReceivedByName
 						+ /*16(10)*/IndDateAndTimeOfTheEmergencyNotification
 																	as IndNotification
	
			, /*7(1)*/IndCaseStatus									as IndCaseStatus
			, /*8(2)*/IndDateOfCompletionPaperFormDate				as IndDateOfCompletionPaperFormDate
 			, /*9(3)*/IndNameOfEmployer								as IndNameOfEmployer
 			, /*11(5)*/IndCurrentLocation							as IndCurrentLocation
 			, /*12(6)*/IndNotificationDate							as IndNotificationDate
 			, /*13(7)*/IndNotificationSentByName					as IndNotificationSentByName
 			, /*14(8)*/IndNotificationReceivedByFacility			as IndNotificationReceivedByFacility
 			, /*15(9)*/IndNotificationReceivedByName				as IndNotificationReceivedByName
 			, /*16(10)*/IndDateAndTimeOfTheEmergencyNotification	as IndDateAndTimeOfTheEmergencyNotification
	 	
 	
		 	,/*17(11..23)*/ 
		 				  /*18(11)*/IndInvestigationStartDate
 						+ /*19(12)*/IndOccupationType
 						+ /*20(13)*/IndInitialCaseClassification
 						+ /*21(14)*/IndLocationOfExplosure
 						+ /*22(15)*/IndAATherapyAdmBeforeSamplesCollection
 						+ /*23(16)*/IndSamplesCollected
 						+ /*24(17)*/IndAddcontact 
 						+ /*25(18)*/IndClinicalSigns 
 						+ /*26(19)*/IndEpidemiologicalLinksAndRiskFactors
 						+ /*27(20)*/IndBasisOfDiagnosis
 						+ /*28(21)*/IndOutcome 
 						+ /*29(22)*/IndISThisCaseRelatedToOutbreak
 						+ /*30(23)*/IndEpidemiologistName
 																	as IndCaseInvestigation
 																	
			, /*18(11)*/IndInvestigationStartDate					as IndInvestigationStartDate
			, /*19(12)*/IndOccupationType							as IndOccupationType
			, /*20(13)*/IndInitialCaseClassification				as IndInitialCaseClassification
			, /*21(14)*/IndLocationOfExplosure						as IndLocationOfExplosure
			, /*22(15)*/IndAATherapyAdmBeforeSamplesCollection		as IndAATherapyAdmBeforeSamplesCollection
			, /*23(16)*/IndSamplesCollected							as IndSamplesCollected
			, /*24(17)*/IndAddcontact								as IndAddcontact
			, /*25(18)*/IndClinicalSigns							as IndClinicalSigns
			, /*26(19)*/IndEpidemiologicalLinksAndRiskFactors		as IndEpidemiologicalLinksAndRiskFactors
			, /*27(20)*/IndBasisOfDiagnosis							as IndBasisOfDiagnosis
			, /*28(21)*/IndOutcome									as IndOutcome
			, /*29(22)*/IndISThisCaseRelatedToOutbreak				as IndISThisCaseRelatedToOutbreak
			, /*30(23)*/IndEpidemiologistName						as IndEpidemiologistName
	

			,/*31(24+25)*/
						  /*32(24)*/IndResultsTestsConducted
						+ /*33(25)*/IndResultsResultObservation							
																	as IndResults
			, /*32(24)*/IndResultsTestsConducted					as IndResultsTestsConducted
			, /*33(25)*/IndResultsResultObservation					as IndResultsResultObservation
	 	
		 	,/*34*/ 
 				  /*7(1)*/IndCaseStatus
				+ /*8(2)*/IndDateOfCompletionPaperFormDate
				+ /*9(3)*/IndNameOfEmployer
				+ /*11(5)*/IndCurrentLocation
				+ /*12(6)*/IndNotificationDate
				+ /*13(7)*/IndNotificationSentByName
				+ /*14(8)*/IndNotificationReceivedByFacility
				+ /*15(9)*/IndNotificationReceivedByName
				+ /*16(10)*/IndDateAndTimeOfTheEmergencyNotification 				

				+ /*18(11)*/IndInvestigationStartDate
				+ /*19(12)*/IndOccupationType
				+ /*20(13)*/IndInitialCaseClassification
				+ /*21(14)*/IndLocationOfExplosure
				+ /*22(15)*/IndAATherapyAdmBeforeSamplesCollection
				+ /*23(16)*/IndSamplesCollected
				+ /*24(17)*/IndAddcontact 
				+ /*25(18)*/IndClinicalSigns 
				+ /*26(19)*/IndEpidemiologicalLinksAndRiskFactors
				+ /*27(20)*/IndBasisOfDiagnosis
				+ /*28(21)*/IndOutcome 
				+ /*29(22)*/IndISThisCaseRelatedToOutbreak
				+ /*30(23)*/IndEpidemiologistName 				
 								
 				+ /*32(24)*/IndResultsTestsConducted
				+ /*33(25)*/IndResultsResultObservation					
 																as SummaryScoreByIndicators
	FROM ReportSumCaseTable
	WHERE CAST(@Diagnosis as NVARCHAR(max)) <> ''

	UNION all
	 
	SELECT
 		      IdRegion
			, strRegion	
	 		, intRegionOrder
 			, IdRayon
	 		, strRayon
			, strAZRayon
 			, intRayonOrder
 			, intCaseCount
			, idfsShowDiagnosis
			, Diagnosis

		 	,/*6(1+2+3+5+6+8+9+10)*/
		 				  /*7(1)*/IndCaseStatus
 						+ /*8(2)*/IndDateOfCompletionPaperFormDate
 						+ /*9(3)*/IndNameOfEmployer
 						+ /*11(5)*/IndCurrentLocation
 						+ /*12(6)*/IndNotificationDate
 						+ /*13(7)*/IndNotificationSentByName
 						+ /*14(8)*/IndNotificationReceivedByFacility
 						+ /*15(9)*/IndNotificationReceivedByName
 						+ /*16(10)*/IndDateAndTimeOfTheEmergencyNotification 						
 																as IndNotification

			, /*7(1)*/IndCaseStatus									as IndCaseStatus
			, /*8(2)*/IndDateOfCompletionPaperFormDate				as IndDateOfCompletionPaperFormDate
 			, /*9(3)*/IndNameOfEmployer								as IndNameOfEmployer
 			, /*11(5)*/IndCurrentLocation							as IndCurrentLocation
 			, /*12(6)*/IndNotificationDate							as IndNotificationDate
 			, /*13(7)*/IndNotificationSentByName					as IndNotificationSentByName
 			, /*14(8)*/IndNotificationReceivedByFacility			as IndNotificationReceivedByFacility
 			, /*15(9)*/IndNotificationReceivedByName				as IndNotificationReceivedByName
 			, /*16(10)*/IndDateAndTimeOfTheEmergencyNotification	as IndDateAndTimeOfTheEmergencyNotification	
	
		 	,/*17(11..23)*/ 
		 				  /*18(11)*/IndInvestigationStartDate
 						+ /*19(12)*/IndOccupationType
 						+ /*20(13)*/IndInitialCaseClassification
 						+ /*21(14)*/IndLocationOfExplosure
 						+ /*22(15)*/IndAATherapyAdmBeforeSamplesCollection
 						+ /*23(16)*/IndSamplesCollected
 						+ /*24(17)*/IndAddcontact 
 						+ /*25(18)*/IndClinicalSigns 
 						+ /*26(19)*/IndEpidemiologicalLinksAndRiskFactors
 						+ /*27(20)*/IndBasisOfDiagnosis
 						+ /*28(21)*/IndOutcome 
 						+ /*29(22)*/IndISThisCaseRelatedToOutbreak
 						+ /*30(23)*/IndEpidemiologistName	
		 															as IndCaseInvestigation

			, /*18(11)*/IndInvestigationStartDate					as IndInvestigationStartDate
			, /*19(12)*/IndOccupationType							as IndOccupationType
			, /*20(13)*/IndInitialCaseClassification				as IndInitialCaseClassification
			, /*21(14)*/IndLocationOfExplosure						as IndLocationOfExplosure
			, /*22(15)*/IndAATherapyAdmBeforeSamplesCollection		as IndAATherapyAdmBeforeSamplesCollection
			, /*23(16)*/IndSamplesCollected							as IndSamplesCollected
			, /*24(17)*/IndAddcontact								as IndAddcontact
			, /*25(18)*/IndClinicalSigns							as IndClinicalSigns
			, /*26(19)*/IndEpidemiologicalLinksAndRiskFactors		as IndEpidemiologicalLinksAndRiskFactors
			, /*27(20)*/IndBasisOfDiagnosis							as IndBasisOfDiagnosis
			, /*28(21)*/IndOutcome									as IndOutcome
			, /*29(22)*/IndISThisCaseRelatedToOutbreak				as IndISThisCaseRelatedToOutbreak
			, /*30(23)*/IndEpidemiologistName						as IndEpidemiologistName	
	
			,/*31(24+25)*/
						  /*32(24)*/IndResultsTestsConducted
						+ /*33(25)*/IndResultsResultObservation							
																	as IndResults
			, /*32(24)*/IndResultsTestsConducted					as IndResultsTestsConducted
			, /*33(25)*/IndResultsResultObservation					as IndResultsResultObservation	
	
		 	,/*34*/ 
 				  /*7(1)*/IndCaseStatus
				+ /*8(2)*/IndDateOfCompletionPaperFormDate
				+ /*9(3)*/IndNameOfEmployer
				+ /*11(5)*/IndCurrentLocation
				+ /*12(6)*/IndNotificationDate
				+ /*13(7)*/IndNotificationSentByName
				+ /*14(8)*/IndNotificationReceivedByFacility
				+ /*15(9)*/IndNotificationReceivedByName
				+ /*16(10)*/IndDateAndTimeOfTheEmergencyNotification 				

				+ /*18(11)*/IndInvestigationStartDate
				+ /*19(12)*/IndOccupationType
				+ /*20(13)*/IndInitialCaseClassification
				+ /*21(14)*/IndLocationOfExplosure
				+ /*22(15)*/IndAATherapyAdmBeforeSamplesCollection
				+ /*23(16)*/IndSamplesCollected
				+ /*24(17)*/IndAddcontact 
				+ /*25(18)*/IndClinicalSigns 
				+ /*26(19)*/IndEpidemiologicalLinksAndRiskFactors
				+ /*27(20)*/IndBasisOfDiagnosis
				+ /*28(21)*/IndOutcome 
				+ /*29(22)*/IndISThisCaseRelatedToOutbreak
				+ /*30(23)*/IndEpidemiologistName 				
 								
 				+ /*32(24)*/IndResultsTestsConducted
				+ /*33(25)*/IndResultsResultObservation
				 				
 																as SummaryScoreByIndicators
	 FROM ReportSumCaseTableForRayons_Summary
	 WHERE CAST(@Diagnosis as NVARCHAR(max)) = ''
	
	
	
; With MaxValues AS
(
SELECT 	
		-1 as	idfsBaseReference
		,-1 as	idfsRegion
		,'' as	strRegion
		,-1 as	intRegionOrder
		,-1 as	idfsRayon
		,'' as	strRayon
		,'' as  strAZRayon
		,-1 as	intRayonOrder
		, 0 as  intCaseCount
		,-1 as	idfsDiagnosis
		,'' as	strDiagnosis	

		,@Ind_1_Notification as dbl_1_Notification
 		,@Ind_N1_CaseStatus as dblCaseStatus
 		,@Ind_N1_DateofCompletionPF as dblDateOfCompletionOfPaperForm
 		,@Ind_N1_NameofEmployer as dblNameOfEmployer
 		,@Ind_N1_CurrentLocationPatient as dblCurrentLocationOfPatient
 		,@Ind_N1_NotifDateTime as dblNotificationDateTime
 		,@Ind_N1_NotifSentByName as dbldblNotificationSentByName
 		,@Ind_N1_NotifReceivedByFacility as dblNotificationReceivedByFacility
 		,@Ind_N1_NotifReceivedByName as dblNotificationReceivedByName
 		,@Ind_N1_TimelinessOfDataEntryDTEN as dblTimelinessofDataEntry
 		
		,@Ind_2_CaseInvestigation as dbl_2_CaseInvestigation
 		,@Ind_N1_DIStartingDTOfInvestigation as dblDemographicInformationStartingDateTimeOfInvestigation
  		,@Ind_N1_DIOccupation as dblDemographicInformationOccupation
 		,@Ind_N1_CIInitCaseClassification as dblClinicalInformationInitialCaseClassification
 		,@Ind_N1_CILocationOfExposure as dblClinicalInformationLocationOfExposure
 		,@Ind_N1_CIAntibioticTherapyAdministratedBSC as dblClinicalInformationAntibioticAntiviralTherapy
 		,@Ind_N1_SamplesCollection as dblSamplesCollectionSamplesCollected
 		,@Ind_N1_ContactLisAddContact as dblContactListAddContact
 		,@Ind_N1_CaseClassificationCS as dblCaseClassificationClinicalSigns
 		,@Ind_N1_EpiLinksRiskFactorsByEpidCard as dblEpidemiologicalLinksAndRiskFactors
 		,@Ind_N1_FCCOBasisOfDiagnosis as dblFinalCaseClassificationBasisOfDiagnosis
 		,@Ind_N1_FCCOOutcome as dblFinalCaseClassificationOutcome
 		,@Ind_N1_FCCOIsThisCaseRelatedToOutbreak as dblFinalCaseClassificationIsThisCaseOutbreak
 		,@Ind_N1_FCCOEpidemiologistName as dblFinalCaseClassificationEpidemiologistName
 		,@Ind_3_TheResultsOfLabTestsAndInterpretation as dbl_3_TheResultsOfLaboratoryTests
 		,@Ind_N1_ResultsOfLabTestsTestsConducted as dblTheResultsOfLaboratoryTestsTestsConducted
 		,@Ind_N1_ResultsOfLabTestsResultObservation as dblTheResultsOfLaboratoryTestsResultObservation
 		,@Ind_1_Notification + @Ind_2_CaseInvestigation + @Ind_3_TheResultsOfLabTestsAndInterpretation  as dblSummaryScoreByIndicators
 ),
 
 AvgValues AS
 (		
--Averages
SELECT 
 				 -2 idfsBaseReference
 				,-2 idfsRegion
 				,'' strRegion
 				,2 intRegionOrder
 				,-2 idfsRayon
 				,'' strRayon
 				,'' strAZRayon
 				,-2 intRayonOrder
 				,SUM(intCaseCount) intCaseCount
 				,-2 idfsDiagnosis
 				,'' strDiagnosis
 				
				,/*6(1+2+3+5+6+8+9+10)*/	AVG(CASE WHEN rt.dbl_1_Notification<>0 THEN rt.dbl_1_Notification END) dbl_1_Notification
				,/*7(1)*/					AVG(CASE WHEN rt.dblCaseStatus<>0 THEN rt.dblCaseStatus END) dblCaseStatus
				,/*8(2)*/					AVG(CASE WHEN rt.dblDateOfCompletionOfPaperForm<>0 THEN rt.dblDateOfCompletionOfPaperForm END) dblDateOfCompletionOfPaperForm
				,/*9(3)*/					AVG(CASE WHEN rt.dblNameOfEmployer<>0 THEN rt.dblNameOfEmployer END) dblNameOfEmployer
				,/*11(5)*/					AVG(CASE WHEN rt.dblCurrentLocationOfPatient<>0 THEN rt.dblCurrentLocationOfPatient END) dblCurrentLocationOfPatient
				,/*12(6)*/					AVG(CASE WHEN rt.dblNotificationDateTime<>0 THEN rt.dblNotificationDateTime END) dblNotificationDateTime
				,/*13(7)*/					AVG(CASE WHEN rt.dbldblNotificationSentByName<>0 THEN rt.dbldblNotificationSentByName END) dbldblNotificationSentByName
				,/*14(8)*/					AVG(CASE WHEN rt.dblNotificationReceivedByFacility<>0 THEN rt.dblNotificationReceivedByFacility END) dblNotificationReceivedByFacility
				,/*15(9)*/					AVG(CASE WHEN rt.dblNotificationReceivedByName<>0 THEN rt.dblNotificationReceivedByName END) dblNotificationReceivedByName
				,/*16(10)*/					AVG(CASE WHEN rt.dblTimelinessofDataEntry<>0 THEN rt.dblTimelinessofDataEntry END) dblTimelinessofDataEntry
 	
				,/*17(11..23)*/				AVG(CASE WHEN rt.dbl_2_CaseInvestigation<>0 THEN rt.dbl_2_CaseInvestigation END)dbl_2_CaseInvestigation
				,/*18(11)*/					AVG(CASE WHEN rt.dblDemographicInformationStartingDateTimeOfInvestigation<>0 THEN rt.dblDemographicInformationStartingDateTimeOfInvestigation END) dblDemographicInformationStartingDateTimeOfInvestigation
				,/*19(12)*/					AVG(CASE WHEN rt.dblDemographicInformationOccupation<>0 THEN rt.dblDemographicInformationOccupation END) dblDemographicInformationOccupation
				,/*20(13)*/					AVG(CASE WHEN rt.dblClinicalInformationInitialCaseClassification<>0 THEN rt.dblClinicalInformationInitialCaseClassification END) dblClinicalInformationInitialCaseClassification
				,/*21(14)*/					AVG(CASE WHEN rt.dblClinicalInformationLocationOfExposure<>0 THEN rt.dblClinicalInformationLocationOfExposure END)dblClinicalInformationLocationOfExposure
				,/*22(15)*/					AVG(CASE WHEN rt.dblClinicalInformationAntibioticAntiviralTherapy<>0 THEN rt.dblClinicalInformationAntibioticAntiviralTherapy END) dblClinicalInformationAntibioticAntiviralTherapy
				,/*23(16)*/					AVG(CASE WHEN rt.dblSamplesCollectionSamplesCollected<>0 THEN rt.dblSamplesCollectionSamplesCollected END) dblSamplesCollectionSamplesCollected
				,/*24(17)*/					AVG(CASE WHEN rt.dblContactListAddContact<>0 THEN rt.dblContactListAddContact END) dblContactListAddContact
				,/*25(18)*/					AVG(CASE WHEN rt.dblCaseClassificationClinicalSigns<>0 THEN rt.dblCaseClassificationClinicalSigns END) dblCaseClassificationClinicalSigns
				,/*26(19)*/					AVG(CASE WHEN rt.dblEpidemiologicalLinksAndRiskFactors<>0 THEN rt.dblEpidemiologicalLinksAndRiskFactors END) dblEpidemiologicalLinksAndRiskFactors
				,/*27(20)*/					AVG(CASE WHEN rt.dblFinalCaseClassificationBasisOfDiagnosis<>0 THEN rt.dblFinalCaseClassificationBasisOfDiagnosis END) dblFinalCaseClassificationBasisOfDiagnosis
				,/*28(21)*/					AVG(CASE WHEN rt.dblFinalCaseClassificationOutcome<>0 THEN rt.dblFinalCaseClassificationOutcome END) dblFinalCaseClassificationOutcome
				,/*29(22)*/					AVG(CASE WHEN rt.dblFinalCaseClassificationIsThisCaseOutbreak<>0 THEN rt.dblFinalCaseClassificationIsThisCaseOutbreak END) dblFinalCaseClassificationIsThisCaseOutbreak
				,/*30(23)*/					AVG(CASE WHEN rt.dblFinalCaseClassificationEpidemiologistName<>0 THEN rt.dblFinalCaseClassificationEpidemiologistName END) dblFinalCaseClassificationEpidemiologistName
 	
				,/*31(24+25)*/				AVG(CASE WHEN rt.dbl_3_TheResultsOfLaboratoryTests<>0 THEN rt.dbl_3_TheResultsOfLaboratoryTests END) dbl_3_TheResultsOfLaboratoryTests
				,/*32(24)*/					AVG(CASE WHEN rt.dblTheResultsOfLaboratoryTestsTestsConducted<>0 THEN rt.dblTheResultsOfLaboratoryTestsTestsConducted END) dblTheResultsOfLaboratoryTestsTestsConducted
				,/*33(25)*/					AVG(CASE WHEN rt.dblTheResultsOfLaboratoryTestsResultObservation<>0 THEN rt.dblTheResultsOfLaboratoryTestsResultObservation END) dblTheResultsOfLaboratoryTestsResultObservation
 	
 				,/*35*/						AVG(CASE WHEN rt.dblSummaryScoreByIndicators<>0 THEN rt.dblSummaryScoreByIndicators END) dblSummaryScoreByIndicators
  	
FROM @ReportTable rt
)

SELECT Indicators,ROUND(Percentage/100,2) Percentage
FROM (
SELECT 
	'en' strLanguage,N'1. Notification' as Indicators, (SELECT dbl_1_Notification FROM AvgValues)*100/(SELECT dbl_1_Notification FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.1. CASE Status' as Indicators, (SELECT dblCaseStatus FROM AvgValues)*100/(SELECT dblCaseStatus FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.2. Date of Completion of Paper form' as Indicators, (SELECT dblDateOfCompletionOfPaperForm FROM AvgValues)*100/(SELECT dblDateOfCompletionOfPaperForm FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.3. Name of Employer' as Indicators, (SELECT dblNameOfEmployer FROM AvgValues)*100/(SELECT dblNameOfEmployer FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.4. Current location of patient' as Indicators, (SELECT dblCurrentLocationOfPatient FROM AvgValues)*100/(SELECT dblCurrentLocationOfPatient FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.5. Notification date' as Indicators, (SELECT dblNotificationDateTime FROM AvgValues)*100/(SELECT dblNotificationDateTime FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.6. Notification sent by: Name' as Indicators, (SELECT dbldblNotificationSentByName FROM AvgValues)*100/(SELECT dbldblNotificationSentByName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.7. Notification received by: Facility' as Indicators, (SELECT dblNotificationReceivedByFacility FROM AvgValues)*100/(SELECT dblNotificationReceivedByFacility FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.8. Notification received by: Name' as Indicators, (SELECT dblNotificationReceivedByName FROM AvgValues)*100/(SELECT dblNotificationReceivedByName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'1.9. Date AND time of the Emergency Notification' as Indicators, (SELECT dblTimelinessofDataEntry FROM AvgValues)*100/(SELECT dblTimelinessofDataEntry FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2. CASE Investigation' as Indicators, (SELECT dbl_2_CaseInvestigation FROM AvgValues)*100/(SELECT dbl_2_CaseInvestigation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.1.1. Starting date of investigation' as Indicators, (SELECT dblDemographicInformationStartingDateTimeOfInvestigation FROM AvgValues)*100/(SELECT dblDemographicInformationStartingDateTimeOfInvestigation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.1.2. Occupation' as Indicators, (SELECT dblDemographicInformationOccupation FROM AvgValues)*100/(SELECT dblDemographicInformationOccupation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.2.1. Initial CASE Classification' as Indicators, (SELECT dblClinicalInformationInitialCaseClassification FROM AvgValues)*100/(SELECT dblClinicalInformationInitialCaseClassification FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.2.2. Location of Exposure IF it known' as Indicators, (SELECT dblClinicalInformationLocationOfExposure FROM AvgValues)*100/(SELECT dblClinicalInformationLocationOfExposure FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.2.3. Antibiotic/Antiviral therapy administrated before samples collection' as Indicators, (SELECT dblClinicalInformationAntibioticAntiviralTherapy FROM AvgValues)*100/(SELECT dblClinicalInformationAntibioticAntiviralTherapy FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.3. Samples collected' as Indicators, (SELECT dblSamplesCollectionSamplesCollected FROM AvgValues)*100/(SELECT dblSamplesCollectionSamplesCollected FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.4. Contacts' as Indicators, (SELECT dblContactListAddContact FROM AvgValues)*100/(SELECT dblContactListAddContact FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.5. Clinical signs' as Indicators, (SELECT dblCaseClassificationClinicalSigns FROM AvgValues)*100/(SELECT dblCaseClassificationClinicalSigns FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.6. Epidemiological Links' as Indicators, (SELECT dblEpidemiologicalLinksAndRiskFactors FROM AvgValues)*100/(SELECT dblEpidemiologicalLinksAndRiskFactors FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.7.1. Basis of Diagnosis' as Indicators, (SELECT dblFinalCaseClassificationBasisOfDiagnosis FROM AvgValues)*100/(SELECT dblFinalCaseClassificationBasisOfDiagnosis FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.7.2. Outcome' as Indicators, (SELECT dblFinalCaseClassificationOutcome FROM AvgValues)*100/(SELECT dblFinalCaseClassificationOutcome FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.7.3. Is this CASE related to an outbreak' as Indicators, (SELECT dblFinalCaseClassificationIsThisCaseOutbreak FROM AvgValues)*100/(SELECT dblFinalCaseClassificationIsThisCaseOutbreak FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'2.7.4. Epidemiologist name' as Indicators, (SELECT dblFinalCaseClassificationEpidemiologistName FROM AvgValues)*100/(SELECT dblFinalCaseClassificationEpidemiologistName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'3. The results of Laboratory Tests AND Interpretation' as Indicators, (SELECT dbl_3_TheResultsOfLaboratoryTests FROM AvgValues)*100/(SELECT dbl_3_TheResultsOfLaboratoryTests FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'3.1 Tests Conducted' as Indicators, (SELECT dblTheResultsOfLaboratoryTestsTestsConducted FROM AvgValues)*100/(SELECT dblTheResultsOfLaboratoryTestsTestsConducted FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'en' strLanguage,N'3.2. Test Result/Observation' as Indicators, (SELECT dblTheResultsOfLaboratoryTestsResultObservation FROM AvgValues)*100/(SELECT dblTheResultsOfLaboratoryTestsResultObservation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1. Экстренное извещение' as Indicators, (SELECT dbl_1_Notification FROM AvgValues)*100/(SELECT dbl_1_Notification FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.1. Состояние случая' as Indicators, (SELECT dblCaseStatus FROM AvgValues)*100/(SELECT dblCaseStatus FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.2. Дата заполнения бумажной формы' as Indicators, (SELECT dblDateOfCompletionOfPaperForm FROM AvgValues)*100/(SELECT dblDateOfCompletionOfPaperForm FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.3. Место работы' as Indicators, (SELECT dblNameOfEmployer FROM AvgValues)*100/(SELECT dblNameOfEmployer FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.4. Текущее местонахождение пациента' as Indicators, (SELECT dblCurrentLocationOfPatient FROM AvgValues)*100/(SELECT dblCurrentLocationOfPatient FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.5. Дата и время передачи экстр. извещения' as Indicators, (SELECT dblNotificationDateTime FROM AvgValues)*100/(SELECT dblNotificationDateTime FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.6. Сотрудник, передавший извещение' as Indicators, (SELECT dbldblNotificationSentByName FROM AvgValues)*100/(SELECT dbldblNotificationSentByName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.7. Учреждение, принявшее извещение' as Indicators, (SELECT dblNotificationReceivedByFacility FROM AvgValues)*100/(SELECT dblNotificationReceivedByFacility FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.8. Сотрудник, принявший извещение' as Indicators, (SELECT dblNotificationReceivedByName FROM AvgValues)*100/(SELECT dblNotificationReceivedByName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'1.9. Дата и время получения экстренного извещения' as Indicators, (SELECT dblTimelinessofDataEntry FROM AvgValues)*100/(SELECT dblTimelinessofDataEntry FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2. Карта эпидемиологического расследования' as Indicators, (SELECT dbl_2_CaseInvestigation FROM AvgValues)*100/(SELECT dbl_2_CaseInvestigation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.1.1. Дата начала расследования' as Indicators, (SELECT dblDemographicInformationStartingDateTimeOfInvestigation FROM AvgValues)*100/(SELECT dblDemographicInformationStartingDateTimeOfInvestigation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.1.2. Род деятельности пациента' as Indicators, (SELECT dblDemographicInformationOccupation FROM AvgValues)*100/(SELECT dblDemographicInformationOccupation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.2.1. Начальная классификация случая' as Indicators, (SELECT dblClinicalInformationInitialCaseClassification FROM AvgValues)*100/(SELECT dblClinicalInformationInitialCaseClassification FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.2.2. Место заражения' as Indicators, (SELECT dblClinicalInformationLocationOfExposure FROM AvgValues)*100/(SELECT dblClinicalInformationLocationOfExposure FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.2.3. Антибиотик/антивирусная терапия' as Indicators, (SELECT dblClinicalInformationAntibioticAntiviralTherapy FROM AvgValues)*100/(SELECT dblClinicalInformationAntibioticAntiviralTherapy FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.3. Отбор проб' as Indicators, (SELECT dblSamplesCollectionSamplesCollected FROM AvgValues)*100/(SELECT dblSamplesCollectionSamplesCollected FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.4. Контактные лица' as Indicators, (SELECT dblContactListAddContact FROM AvgValues)*100/(SELECT dblContactListAddContact FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.5. Клинические признаки' as Indicators, (SELECT dblCaseClassificationClinicalSigns FROM AvgValues)*100/(SELECT dblCaseClassificationClinicalSigns FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.6. Эпидемиологические связи' as Indicators, (SELECT dblEpidemiologicalLinksAndRiskFactors FROM AvgValues)*100/(SELECT dblEpidemiologicalLinksAndRiskFactors FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.7.1. Основание для постановки диагноза' as Indicators, (SELECT dblFinalCaseClassificationBasisOfDiagnosis FROM AvgValues)*100/(SELECT dblFinalCaseClassificationBasisOfDiagnosis FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.7.2. Исход случая' as Indicators, (SELECT dblFinalCaseClassificationOutcome FROM AvgValues)*100/(SELECT dblFinalCaseClassificationOutcome FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.7.3. Связь со вспышкой' as Indicators, (SELECT dblFinalCaseClassificationIsThisCaseOutbreak FROM AvgValues)*100/(SELECT dblFinalCaseClassificationIsThisCaseOutbreak FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'2.7.4. Имя эпидемиолога' as Indicators, (SELECT dblFinalCaseClassificationEpidemiologistName FROM AvgValues)*100/(SELECT dblFinalCaseClassificationEpidemiologistName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'3. Результаты лабораторных тестов' as Indicators, (SELECT dbl_3_TheResultsOfLaboratoryTests FROM AvgValues)*100/(SELECT dbl_3_TheResultsOfLaboratoryTests FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'3.1. Проведение тестов' as Indicators, (SELECT dblTheResultsOfLaboratoryTestsTestsConducted FROM AvgValues)*100/(SELECT dblTheResultsOfLaboratoryTestsTestsConducted FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'ru' strLanguage,N'3.2. Результат теста' as Indicators, (SELECT dblTheResultsOfLaboratoryTestsResultObservation FROM AvgValues)*100/(SELECT dblTheResultsOfLaboratoryTestsResultObservation FROM MaxValues) as Percentage
--
UNION ALL
SELECT 
	'az-L' strLanguage,N'1. Təcili bildiriş' as Indicators, (SELECT dbl_1_Notification FROM AvgValues)*100/(SELECT dbl_1_Notification FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.1. Hadisənin statusu' as Indicators, (SELECT dblCaseStatus FROM AvgValues)*100/(SELECT dblCaseStatus FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.2. Kağız formanın doldurulma tarixi' as Indicators, (SELECT dblDateOfCompletionOfPaperForm FROM AvgValues)*100/(SELECT dblDateOfCompletionOfPaperForm FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.3. Iş yerinin adı' as Indicators, (SELECT dblNameOfEmployer FROM AvgValues)*100/(SELECT dblNameOfEmployer FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.4. Xəstənin hazırki yeri' as Indicators, (SELECT dblCurrentLocationOfPatient FROM AvgValues)*100/(SELECT dblCurrentLocationOfPatient FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.5. Bildiriş tarixi' as Indicators, (SELECT dblNotificationDateTime FROM AvgValues)*100/(SELECT dblNotificationDateTime FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.6. Bildirişi göndərən işçi' as Indicators, (SELECT dbldblNotificationSentByName FROM AvgValues)*100/(SELECT dbldblNotificationSentByName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.7. Bildirişi qəbul edən müəssisə' as Indicators, (SELECT dblNotificationReceivedByFacility FROM AvgValues)*100/(SELECT dblNotificationReceivedByFacility FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.8. Bildirişi qəbul edən işçi' as Indicators, (SELECT dblNotificationReceivedByName FROM AvgValues)*100/(SELECT dblNotificationReceivedByName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'1.9. Bildirişin qəbul edilmə vaxtı və tarixi' as Indicators, (SELECT dblTimelinessofDataEntry FROM AvgValues)*100/(SELECT dblTimelinessofDataEntry FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2. Epidemioloji tədqiqat' as Indicators, (SELECT dbl_2_CaseInvestigation FROM AvgValues)*100/(SELECT dbl_2_CaseInvestigation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.1.1. Tədqiqatın başlanma tarixi' as Indicators, (SELECT dblDemographicInformationStartingDateTimeOfInvestigation FROM AvgValues)*100/(SELECT dblDemographicInformationStartingDateTimeOfInvestigation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.1.2. Xəstənin məşğuliyyəti' as Indicators, (SELECT dblDemographicInformationOccupation FROM AvgValues)*100/(SELECT dblDemographicInformationOccupation FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.2.1. Hadisənin ilkin təsnifatı' as Indicators, (SELECT dblClinicalInformationInitialCaseClassification FROM AvgValues)*100/(SELECT dblClinicalInformationInitialCaseClassification FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.2.2. Yoluxma yeri' as Indicators, (SELECT dblClinicalInformationLocationOfExposure FROM AvgValues)*100/(SELECT dblClinicalInformationLocationOfExposure FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.2.3. Antibiotik/virus terapiya' as Indicators, (SELECT dblClinicalInformationAntibioticAntiviralTherapy FROM AvgValues)*100/(SELECT dblClinicalInformationAntibioticAntiviralTherapy FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.3. Nümunələrin toplanması' as Indicators, (SELECT dblSamplesCollectionSamplesCollected FROM AvgValues)*100/(SELECT dblSamplesCollectionSamplesCollected FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.4. Təmasda olanlar' as Indicators, (SELECT dblContactListAddContact FROM AvgValues)*100/(SELECT dblContactListAddContact FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.5. Kliniki əlamətlər' as Indicators, (SELECT dblCaseClassificationClinicalSigns FROM AvgValues)*100/(SELECT dblCaseClassificationClinicalSigns FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.6. Epid əlaqələr' as Indicators, (SELECT dblEpidemiologicalLinksAndRiskFactors FROM AvgValues)*100/(SELECT dblEpidemiologicalLinksAndRiskFactors FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.7.1. Diaqnozun əsası' as Indicators, (SELECT dblFinalCaseClassificationBasisOfDiagnosis FROM AvgValues)*100/(SELECT dblFinalCaseClassificationBasisOfDiagnosis FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.7.2. Hadisənin nəticəsi' as Indicators, (SELECT dblFinalCaseClassificationOutcome FROM AvgValues)*100/(SELECT dblFinalCaseClassificationOutcome FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.7.3. Alovlanma ilə əlaqə' as Indicators, (SELECT dblFinalCaseClassificationIsThisCaseOutbreak FROM AvgValues)*100/(SELECT dblFinalCaseClassificationIsThisCaseOutbreak FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'2.7.4. Epidemioloqun adı' as Indicators, (SELECT dblFinalCaseClassificationEpidemiologistName FROM AvgValues)*100/(SELECT dblFinalCaseClassificationEpidemiologistName FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'3. Laborator nəticələr' as Indicators, (SELECT dbl_3_TheResultsOfLaboratoryTests FROM AvgValues)*100/(SELECT dbl_3_TheResultsOfLaboratoryTests FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'3.1. Aparılmış testlər' as Indicators, (SELECT dblTheResultsOfLaboratoryTestsTestsConducted FROM AvgValues)*100/(SELECT dblTheResultsOfLaboratoryTestsTestsConducted FROM MaxValues) as Percentage
UNION ALL
SELECT 
	'az-L' strLanguage,N'3.2. Testin nəticəsi' as Indicators, (SELECT dblTheResultsOfLaboratoryTestsResultObservation FROM AvgValues)*100/(SELECT dblTheResultsOfLaboratoryTestsResultObservation FROM MaxValues) as Percentage
) A
WHERE strLanguage=@LangID			

