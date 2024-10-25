

--*************************************************************************
-- Name 				: report.USP_REP_HUM_WhoMeaslesRubella
--
-- Description			: SINT03 - WHO Report on Measles and Rubella.
-- 
-- Author               : Mark Wilson
-- Revision History
--		Name			Date       Change Detail
--	Mark Wilson		25-Mar-2020	   Updated dates conversions and added
--								   call to report.FN_REP_LastDayOfMonth
-- Testing code:
/*
--Example of a call of procedure:
exec report.USP_REP_HUM_WhoMeaslesRubella @LangID=N'en',@Year=2017,@Month=3,@idfsDiagnosis=NULL -- both

exec report.USP_REP_HUM_WhoMeaslesRubella @LangID=N'en',@Year=2017,@Month=3, @idfsDiagnosis=7720040000000--Measles AJ
exec report.USP_REP_HUM_WhoMeaslesRubella @LangID=N'en',@Year=2017,@Month=3, @idfsDiagnosis=9843460000000--Measles GG

exec report.USP_REP_HUM_WhoMeaslesRubella @LangID=N'en',@Year=2019,@Month=11, @idfsDiagnosis=7720770000000--Rubella AJ
exec report.USP_REP_HUM_WhoMeaslesRubella @LangID=N'en',@Year=2017,@Month=3, @idfsDiagnosis=9843820000000--Rubella GG

*/

CREATE  PROCEDURE [Report].[USP_REP_HUM_WhoMeaslesRubella]
(
	@LangID AS NVARCHAR(50) = 'en', -- default to English.  No multi-language support.
	@StartDate	AS DATETIME,	 
	@EndDate	AS DATETIME,
	--@Year AS INT, 
	--@Month AS INT = NULL,
	@idfsDiagnosis AS NVARCHAR(100) = NULL
)
AS	
	
BEGIN
	
	DECLARE	@ResultTable TABLE
	(	  
		idfsBaseReference BIGINT NOT NULL PRIMARY KEY,
		strCaseID NVARCHAR(300) COLLATE DATABASE_DEFAULT NOT NULL,
		intInitialDiagnosis	INT NOT NULL,
		intAreaID INT NOT NULL,
		datDateOfRashOnSET DATE NULL,
		intSex INT NOT NULL, 
		datDateOfBirth DATE NULL,
		intNomberOfVaccines	INT NOT NULL,
		datDateOfLastVaccination DATE NULL,
		datNotificationDate DATE NULL,
		datInvestigationStartDate DATE NULL,
		intOutcome INT NOT NULL,
		intHospitalization INT NOT NULL,
		intImportedCase	INT NOT NULL,
		datSpecimenCollection DATE NULL,
		intTestResult INT NOT NULL,
		intFinalCaseClassification INT NULL 

	)
	
	DECLARE 
		@idfsCustomReportType BIGINT,
		@FFP_MeaslesOnSetDate BIGINT,
		@FFP_RubellaOnSetDate BIGINT,
		@FFP_MeaslesNumberOfVaccine BIGINT,
		@FFP_RubellaNumberOfVaccine BIGINT,
		@FFP_MeaslesDateOfLastVaccine BIGINT,
		@FFP_RubellaDateOfLastVaccine BIGINT,
		@FFP_MeaslesSourceOfInfectionImportedCase BIGINT,
		@FFP_RubellaSourceOfInfectionImportedCase BIGINT,
		@idfsDiagnosis_Measles BIGINT,
		@idfsDiagnosis_Rubella BIGINT,
		--@StartDate DATETIME,
		--@EndDate DATETIME,
		@m NVARCHAR(10)
	
	--IF @Month IS NULL 
	--BEGIN
	--	SET @StartDate = CAST(CAST(@Year AS NVARCHAR) + '0101' AS DATETIME)
	--	SET @EndDate = CAST(CAST(@Year AS NVARCHAR) + '1231' AS DATETIME)
	--END
	--ELSE BEGIN
	--	IF @Month < 10 
	--		SET @m = '0' + CAST(@Month AS NVARCHAR(2))
	--		ELSE SET @m = CAST(@Month AS NVARCHAR(2))
	--	SET @StartDate = CAST(CAST(@Year AS NVARCHAR) + CAST(@m AS NVARCHAR) + '01' AS DATETIME)
		
	--	IF @Month = 12 
	--		BEGIN  SET @Month = 1  SET @Year = @Year+1 END 
	--		ELSE 	SET @Month = @Month +1
	--	IF @Month < 10 
	--		SET @m = '0' + CAST(@Month AS NVARCHAR(2)) 
	--		ELSE SET @m = CAST(@Month AS NVARCHAR(2))
	--	SET @EndDate = report.FN_REP_LastDayOfMonth(CAST(CAST(@Year AS NVARCHAR) + CAST(@m AS NVARCHAR) + '01' AS DATETIME))
	--END

	--PRINT @StartDate
	--PRINT @EndDate
	SET @idfsCustomReportType = 10290020 /*AJ WHO Report on Measles and Rubella*/

	DECLARE @gisRayon TABLE
	(
		idfsRayon BIGINT,
        idfsRegion BIGINT,
        idfsCountry BIGINT,
        node HIERARCHYID,
        [name] NVARCHAR(255),
        idfsGISReferenceType BIGINT,
        strDefault NVARCHAR(200),
        LongName NVARCHAR(255),
        intOrder INT,
        ExtendedName NVARCHAR(200),
        intRowStatus INT
    )
    INSERT INTO @gisRayon
    SELECT * FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/)
    
  --Measles-Additional information on rash-Date of onset
	SELECT 
		@FFP_MeaslesOnSetDate = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_MeaslesOnSetDate'
	AND intRowStatus = 0

  --Rubella-Additional information on rash-Date of onset
	SELECT 
		@FFP_RubellaOnSetDate = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_RubellaOnSetDate'
	AND intRowStatus = 0
	
	--Measles-Vaccination status-Number of Measles vaccine doses received
    SELECT 
		@FFP_MeaslesNumberOfVaccine = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_MeaslesNumberOfVaccine'
	AND intRowStatus = 0	
	
	--Rubella-Vaccination status-Number of Rubella vaccine doses received
	SELECT
		@FFP_RubellaNumberOfVaccine = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_RubellaNumberOfVaccine'
	AND intRowStatus = 0
	
	--Measles-Vaccination status-Date of last Measles vaccine
    SELECT 
		@FFP_MeaslesDateOfLastVaccine = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_MeaslesDateOfLastVaccine'
	AND intRowStatus = 0		
	
	--Rubella-Vaccination status-Date of last Rubella vaccine
	SELECT 
		@FFP_RubellaDateOfLastVaccine = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_RubellaDateOfLastVaccine'
	AND intRowStatus = 0
	
	--Measles-Source of infection-Imported case
	SELECT 
		@FFP_MeaslesSourceOfInfectionImportedCase = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_MeaslesSourceOfInfectionImportedCase'
	AND intRowStatus = 0		
	
	--Rubella-Source of infection-Imported case
	SELECT 
		@FFP_RubellaSourceOfInfectionImportedCase = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_RubellaSourceOfInfectionImportedCase'
	AND intRowStatus = 0		
	
	
	--idfsDiagnosis for:
	--Measles
	SELECT 
		TOP 1 @idfsDiagnosis_Measles = d.idfsDiagnosis
	FROM dbo.trtDiagnosis d
	INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt ON dgrt.idfsDiagnosis = d.idfsDiagnosis AND dgrt.idfsCustomReportType = @idfsCustomReportType
	INNER JOIN dbo.trtReportDiagnosisGroup dg ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
												AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Measles'
	WHERE d.intRowStatus = 0
	
	--Rubella
	SELECT top 1 @idfsDiagnosis_Rubella = d.idfsDiagnosis
	FROM trtDiagnosis d
	INNER JOIN dbo.trtDiagnosisToGroupForReportType dgrt ON dgrt.idfsDiagnosis = d.idfsDiagnosis AND dgrt.idfsCustomReportType = @idfsCustomReportType
	INNER JOIN dbo.trtReportDiagnosisGroup dg ON dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
												AND dg.intRowStatus = 0 AND dg.strDiagnosisGroupAlias = 'DG_Rubella'
	WHERE d.intRowStatus = 0	
	
	PRINT @idfsDiagnosis_Measles
	PRINT @idfsDiagnosis_Rubella

	
	DECLARE @AreaIDs TABLE
	(
		intAreaID INT,
		idfsRegion BIGINT,
		idfsRayon BIGINT
	)

	INSERT INTO @AreaIDs 
	SELECT		
		CAST(tgra.varValue AS int), 
		gr.idfsRegion, 
		gr.idfsRayon

	FROM trtGISBaseReferenceAttribute tgra
	INNER JOIN trtAttributeType tat ON tat.idfAttributeType = tgra.idfAttributeType AND tat.strAttributeTypeName = 'MRrep_specific_gis_rayon'
	INNER JOIN @gisRayon gr ON gr.idfsRayon = tgra.idfsGISBaseReference
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------	
	INSERT INTO	@ResultTable

	SELECT 
		DISTINCT hc.idfHumanCase AS idfCase,
		hc.strCaseID,

		CASE WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles THEN 1 
			 WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella THEN 2
  			 ELSE 0 END, --intInitialDiagnois

		aid.intAreaID, 

		CASE WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles AND 
				  (CAST(SQL_VARIANT_PROPERTY(ap_m.varValue, 'BaseType') AS NVARCHAR) LIKE N'%date%' 
				  OR (CAST(SQL_VARIANT_PROPERTY(ap_m.varValue, 'BaseType') AS NVARCHAR) LIKE N'%char%' AND ISDATE(CAST(ap_m.varValue AS NVARCHAR)) = 1 ))
				  THEN CONVERT(DATE, CAST(ap_m.varValue AS DATETIME), 105)
			 WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella AND 
				  (CAST(SQL_VARIANT_PROPERTY(ap_r.varValue, 'BaseType') AS NVARCHAR) LIKE N'%date%'
				  OR (CAST(SQL_VARIANT_PROPERTY(ap_r.varValue, 'BaseType') AS NVARCHAR) LIKE N'%char%' AND ISDATE(CAST(ap_r.varValue AS NVARCHAR)) = 1 ))
				  THEN CONVERT(DATE, CAST(ap_r.varValue AS DATETIME), 105)
			 ELSE NULL END, --datDateOfRashOnset

  		CASE WHEN h.idfsHumanGender = 10043001 THEN 2
  			 WHEN h.idfsHumanGender = 10043002 THEN 1
  			 ELSE 4 END, --  intSex
  			
  		CONVERT(DATE, h.datDateofBirth, 105), --datDateOfBirth
  			
  		CASE WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles AND 
				  SQL_VARIANT_PROPERTY(ap_m1.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
				  THEN CAST(ap_m1.varValue AS BIGINT)
			 WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella AND 
			      SQL_VARIANT_PROPERTY(ap_r1.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
				  THEN CAST(ap_r1.varValue AS BIGINT)
			 ELSE 9 END, --intNomberOfVaccines
  			  
		CASE WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles AND 
							(CAST(SQL_VARIANT_PROPERTY(ap_m2.varValue, 'BaseType') AS NVARCHAR) LIKE N'%date%'   OR
							(CAST(SQL_VARIANT_PROPERTY(ap_m2.varValue, 'BaseType') AS NVARCHAR) LIKE N'%char%' AND ISDATE(CAST(ap_m2.varValue AS NVARCHAR)) = 1 ))
							THEN CONVERT(DATE, CAST(ap_m2.varValue AS DATETIME), 105)
					   WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella AND 
							(CAST(SQL_VARIANT_PROPERTY(ap_r2.varValue, 'BaseType') AS NVARCHAR) LIKE N'%date%'   OR
							(CAST(SQL_VARIANT_PROPERTY(ap_r2.varValue, 'BaseType') AS NVARCHAR) LIKE N'%char%' AND ISDATE(CAST(ap_r2.varValue AS NVARCHAR)) = 1 ))
							THEN CONVERT(DATE, CAST(ap_r2.varValue AS DATETIME), 105)
				  ELSE NULL
  				END, --datDateOfLastVaccination
  			
  				CONVERT(DATE, hc.datNotificationDate, 105), --datNotificationDate
  			
  				CONVERT(DATE, hc.datInvestigationStartDate, 105), --datInvestigationStartDate
  			
  				CASE hc.idfsOutcome
  					WHEN 10770000000 THEN 1
  					WHEN 10760000000 THEN 2
  					WHEN 10780000000 THEN 3
  					ELSE 3
  				END, --   intOutcome 
  			 
  				CASE hc.idfsYNHospitalization   
  					WHEN 10100001 THEN 1
  					WHEN 10100002 THEN 2
  					WHEN 10100003 THEN 9
  					ELSE 9
  				END, -- intHospitalization  
  			
  				CASE  
  					CASE WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles AND 
								SQL_VARIANT_PROPERTY(ap_m3.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
								THEN CAST(ap_m3.varValue AS BIGINT)
						   WHEN hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella AND 
								SQL_VARIANT_PROPERTY(ap_r3.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
								THEN CAST(ap_r3.varValue AS BIGINT)
						   ELSE NULL
  					END
  					WHEN 25460000000 THEN 1
  					WHEN 25640000000 THEN 2
  					WHEN 25660000000 THEN 9
  					ELSE 9 
  				 END,   --intImportedCase
  			 
			 CASE 
				WHEN hc.idfsYNSpecimenCollected = 10100001 THEN
				(SELECT TOP 1 FORMAT(m.datFieldCollectionDate, 'yyyy-mm-dd')
					FROM tlbMaterial m
					WHERE m.idfsSampleType = 7721770000000
					AND m.idfHuman = h.idfHuman
					AND m.intRowStatus = 0
					ORDER BY m.datFieldCollectionDate DESC
				)
				ELSE NULL
			 END , --datSpecimenCollection
      
			CASE
				(
					SELECT
						CASE 
							WHEN hc.idfsYNSpecimenCollected = 10100001 AND PositiveResult > 0 THEN 'PositiveResult'
							WHEN hc.idfsYNSpecimenCollected = 10100001 AND NegativeResult > 0 THEN 'NegativeResult'
							WHEN hc.idfsYNSpecimenCollected = 10100001 AND IndeterminateResult > 0 THEN 'IndeterminateResult'
							WHEN hc.idfsYNSpecimenCollected = 10100001 AND NotSpecifiedResult > 0 THEN 'NotSpecifiedResult'
							WHEN CntResult = 0 THEN 'NoRecord'
						END
					FROM (
						SELECT
							SUM(CASE WHEN tt.idfsTestResult = 7723960000000 THEN 1 ELSE 0 END) PositiveResult
							, SUM(CASE WHEN tt.idfsTestResult = 7723940000000 THEN 1 ELSE 0 END) NegativeResult	
							, SUM(CASE WHEN tt.idfsTestResult = 7723820000000 THEN 1 ELSE 0 END) IndeterminateResult
							, SUM(CASE WHEN ISNULL(tt.idfsTestResult, -1) = -1 THEN 1 ELSE 0 END) NotSpecifiedResult
							, COUNT(*) CntResult
						FROM tlbTesting tt
						WHERE tt.idfMaterial = 
							(
								SELECT TOP 1 
									m.idfMaterial
								FROM tlbMaterial m
								WHERE m.idfsSampleType = 7721770000000
									AND m.idfHuman = 1680000871
									AND m.intRowStatus = 0
								ORDER BY m.datFieldCollectionDate DESC 
							)
					)  x
				)
				WHEN 'PositiveResult' THEN 1
				WHEN 'NegativeResult' THEN 2
				WHEN 'IndeterminateResult' THEN 4
				WHEN 'NotSpecifiedResult' THEN 3
				WHEN 'NoRecord' THEN 0
				ELSE 4
			END	AS intTestResult,
		
		
			CASE 
				WHEN hc.idfsFinalCaseStatus = 370000000 
						THEN 0
				WHEN hc.idfsFinalCaseStatus = 350000000 
					AND hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles
					AND hc.blnLabDiagBasis = 1
						THEN 1
				WHEN hc.idfsFinalCaseStatus = 350000000 
					AND hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles
					AND hc.blnLabDiagBasis = 0
					AND hc.blnEpiDiagBasis = 1
						THEN 2
				WHEN hc.idfsFinalCaseStatus = 350000000 
					AND hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles
					AND hc.blnLabDiagBasis = 0
					AND hc.blnEpiDiagBasis = 0
					AND hc.blnClinicalDiagBasis = 1
						THEN 3
				WHEN hc.idfsFinalCaseStatus = 350000000 
					AND hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella
					AND hc.blnLabDiagBasis = 1
						THEN 6
				WHEN hc.idfsFinalCaseStatus = 350000000 
					AND hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella
					AND hc.blnLabDiagBasis = 0
					AND hc.blnEpiDiagBasis = 1
						THEN 7
				WHEN hc.idfsFinalCaseStatus = 350000000 
					AND hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella
					AND hc.blnLabDiagBasis = 0
					AND hc.blnEpiDiagBasis = 0
					AND hc.blnClinicalDiagBasis = 1
						THEN 8
				WHEN hc.idfsFinalCaseStatus = 360000000
					OR hc.idfsFinalCaseStatus = 380000000
						THEN NULL
				ELSE NULL
			END intFinalCaseClassification
  			      			
	  FROM tlbHumanCase hc

		  INNER JOIN tlbHuman h
			  LEFT OUTER JOIN tlbGeoLocation gl
			  ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
          
			  LEFT JOIN @AreaIDs aid
			  ON aid.idfsRegion = gl.idfsRegion AND 
			  aid.idfsRayon = gl.idfsRayon
          
		  ON hc.idfHuman = h.idfHuman AND
			 h.intRowStatus = 0
        
		  LEFT JOIN tstSite ts
		  ON ts.idfsSite = hc.idfsSite
			AND ts.intRowStatus = 0
			AND ts.intFlags = 1         
        
		  LEFT JOIN tlbObservation ob_m  
			  INNER JOIN  tlbActivityParameters ap_m
			  ON ap_m.idfObservation = ob_m.idfObservation
			  AND ap_m.intRowStatus = 0
			  AND ap_m.idfsParameter = @FFP_MeaslesOnSetDate
		  ON ob_m.idfObservation = hc.idfCSObservation
		  AND ob_m.intRowStatus = 0
      
		  LEFT JOIN tlbObservation ob_r  
			  INNER JOIN  tlbActivityParameters ap_r
			  ON ap_r.idfObservation = ob_r.idfObservation
			  AND ap_r.intRowStatus = 0
			  AND ap_r.idfsParameter = @FFP_RubellaOnSetDate
		  ON ob_r.idfObservation = hc.idfCSObservation
		  AND ob_r.intRowStatus = 0      
  			
  			
		  LEFT JOIN tlbObservation ob_m1  
			  INNER JOIN  tlbActivityParameters ap_m1
			  ON ap_m1.idfObservation = ob_m1.idfObservation
			  AND ap_m1.intRowStatus = 0
			  AND ap_m1.idfsParameter = @FFP_MeaslesNumberOfVaccine
		  ON ob_m1.idfObservation = hc.idfEpiObservation
		  AND ob_m1.intRowStatus = 0
      
		  LEFT JOIN tlbObservation ob_r1
			  INNER JOIN  tlbActivityParameters ap_r1
			  ON ap_r1.idfObservation = ob_r1.idfObservation
			  AND ap_r1.intRowStatus = 0
			  AND ap_r1.idfsParameter = @FFP_RubellaNumberOfVaccine
		  ON ob_r1.idfObservation = hc.idfEpiObservation
		  AND ob_r1.intRowStatus = 0        			
  			
  			
		  LEFT JOIN tlbObservation ob_m2  
			  INNER JOIN  tlbActivityParameters ap_m2
			  ON ap_m2.idfObservation = ob_m2.idfObservation
			  AND ap_m2.intRowStatus = 0
			  AND ap_m2.idfsParameter = @FFP_MeaslesDateOfLastVaccine
		  ON ob_m2.idfObservation = hc.idfEpiObservation
		  AND ob_m2.intRowStatus = 0
      
		  LEFT JOIN tlbObservation ob_r2
			  INNER JOIN  tlbActivityParameters ap_r2
			  ON ap_r2.idfObservation = ob_r2.idfObservation
			  AND ap_r2.intRowStatus = 0
			  AND ap_r2.idfsParameter = @FFP_RubellaDateOfLastVaccine
		  ON ob_r2.idfObservation = hc.idfEpiObservation
		  AND ob_r2.intRowStatus = 0        			
  			
		  LEFT JOIN tlbObservation ob_m3  
			  INNER JOIN  tlbActivityParameters ap_m3
			  ON ap_m3.idfObservation = ob_m3.idfObservation
			  AND ap_m3.intRowStatus = 0
			  AND ap_m3.idfsParameter = @FFP_MeaslesSourceOfInfectionImportedCase
		  ON ob_m3.idfObservation = hc.idfEpiObservation
		  AND ob_m3.intRowStatus = 0
      
		  LEFT JOIN tlbObservation ob_r3
			  INNER JOIN  tlbActivityParameters ap_r3
			  ON ap_r3.idfObservation = ob_r3.idfObservation
			  AND ap_r3.intRowStatus = 0
			  AND ap_r3.idfsParameter = @FFP_RubellaSourceOfInfectionImportedCase
		  ON ob_r3.idfObservation = hc.idfEpiObservation
		  AND ob_r3.intRowStatus = 0        			  			
  			
  		
	  WHERE	
		hc.intRowStatus = 0 AND
		ts.idfsSite IS NULL AND
		(
		-- Measles
			(
			  hc.idfsTentativeDiagnosis = @idfsDiagnosis_Measles AND 
			  (CAST(SQL_VARIANT_PROPERTY(ap_m.varValue, 'BaseType') AS NVARCHAR) LIKE N'%date%'   OR
						(CAST(SQL_VARIANT_PROPERTY(ap_m.varValue, 'BaseType') AS NVARCHAR) LIKE N'%char%' AND ISDATE(CAST(ap_m.varValue AS NVARCHAR)) = 1 )) AND
		  
			  CAST(ap_m.varValue AS DATETIME) BETWEEN @StartDate AND @EndDate
			) 
			OR 
			-- Rubella
			(
			  hc.idfsTentativeDiagnosis = @idfsDiagnosis_Rubella AND 
			  (CAST(SQL_VARIANT_PROPERTY(ap_r.varValue, 'BaseType') AS NVARCHAR) LIKE N'%date%'   OR
						(CAST(SQL_VARIANT_PROPERTY(ap_r.varValue, 'BaseType') AS NVARCHAR) LIKE N'%char%' AND ISDATE(CAST(ap_r.varValue AS NVARCHAR)) = 1 )) AND
			  CAST(ap_r.varValue AS DATETIME) BETWEEN @StartDate AND @EndDate
			)
		)
		AND hc.idfsTentativeDiagnosis = CASE WHEN @idfsDiagnosis IS NULL THEN hc.idfsTentativeDiagnosis ELSE @idfsDiagnosis END
  
	IF (SELECT COUNT(*) FROM @ResultTable) = 0
		SELECT 1 AS idfsBaseReference,
				NULL AS strCaseID,
				NULL AS intInitialDiagnosis,
				NULL AS intAreaID,
				NULL AS datDateOfRashOnSET,
				NULL AS intSex, 
				NULL AS datDateOfBirth,
				NULL AS intNomberOfVaccines,
				NULL AS datDateOfLastVaccination,
				NULL AS datNotificationDate,
				NULL AS datInvestigationStartDate,
				NULL AS intOutcome,
				NULL AS intHospitalization,
				NULL AS intImportedCase,
				NULL AS datSpecimenCollection,
				NULL AS intTestResult,
				NULL AS intFinalCaseClassification
	ELSE		
		SELECT * FROM @ResultTable
		ORDER BY 
			datDateOfRashOnset, 
			strCaseID	
		
END


