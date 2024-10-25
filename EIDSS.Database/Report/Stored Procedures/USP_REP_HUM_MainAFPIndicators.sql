
--********************************************************************************************************
-- Name 				: report.USP_REP_HUM_MainAFPIndicators
-- Description			: This procedure returns resultset for Main indicators of AFP surveillance report
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail

/*
--Example of a call of procedure:

exec report.USP_REP_HUM_MainAFPIndicators 'en', N'20160101', N'20161231'

*/ 
CREATE PROCEDURE [Report].[USP_REP_HUM_MainAFPIndicators]
(
	 @LangID		AS NVARCHAR(50),
	 @SD			AS DATETIME, 
	 @ED			AS DATETIME
)
AS	

	DECLARE 
		@CountryID BIGINT,
		@idfsLanguage BIGINT,
		@Year INT,
		@idfsStatType BIGINT,
		@idfsCustomReportType BIGINT,

		@idfsRegionBaku BIGINT,
		@idfsRegionOtherRayons BIGINT,
		@idfsRegionNakhichevanAR BIGINT,
		@FFP_Date_of_onset_of_paralysis BIGINT
	
	DECLARE @ReportTable TABLE
	(
		idfsRegion BIGINT NOT NULL,
		idfsRayon BIGINT NOT NULL,
		strRegion NVARCHAR(200) NOT NULL,
		strRayon NVARCHAR(200) NOT NULL,
		intChildren INT, 
		intRegisteredAFP INT,
		intRegisteredAFPWithSamples INT,
		intRegionOrder INT NOT NULL,
		intMaxYearForStatistics INT,
		intLastParalisysOnsetYear INT
	)

	SET @idfsCustomReportType =  10290006
	SET @idfsLanguage = dbo.fnGetLanguageCode (@LangID)		
	SET @CountryID = 170000000
	SET @Year = Year(@SD)
	
	--Flexible Form Type = �Human Clinical Signs� AND Tooltip = �Acute Flaccid Paralysis-Date of onset of paralysis� 
	SELECT @FFP_Date_of_onset_of_paralysis = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Date_of_onset_of_paralysis'
	AND intRowStatus = 0

	--SET @idfsStatType = 8425310000000 -- Population under 15
	SELECT @idfsStatType = tbra.idfsBaseReference
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'Statistical Data Type'
		
		INNER JOIN trtBaseReferenceAttribute tbra2
			INNER JOIN trtAttributeType tat2
			ON tat2.idfAttributeType = tbra2.idfAttributeType
			AND tat2.strAttributeTypeName = 'attr_part_in_report'
		ON tbra.idfsBaseReference = tbra2.idfsBaseReference
		AND tbra2.varValue = @idfsCustomReportType 
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Population under 15'
  
	--1344330000000 --Baku
	SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Baku'

	--1344340000000 --Other rayons
	SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Other rayons'


	--1344350000000 --Nakhichevan AR
	SELECT @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Nakhichevan AR'
  
	INSERT INTO @ReportTable
	(
		idfsRegion,
		idfsRayon,
		strRegion,
		strRayon,
		intRegionOrder
	)
	SELECT
		ray.idfsRegion,
		ray.idfsRayon,

		ISNULL(gsnt_reg.strTextString, gbr_reg.strDefault),
		ISNULL(gsnt_ray.strTextString, gbr_ray.strDefault),

		CASE ray.idfsRegion
		  WHEN @idfsRegionBaku			--Baku
		  THEN 1
	      
		  WHEN @idfsRegionOtherRayons	--Other rayons
		  THEN 2
	      
		  WHEN @idfsRegionNakhichevanAR --Nakhichevan AR
		  THEN 3
	      
		  else 0
		end AS intRegionOrder
	  
	FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) ray
	  INNER JOIN report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) reg
	  ON ray.idfsRegion = reg.idfsRegion
	  AND reg.intRowStatus = 0
	  AND reg.idfsCountry = @CountryID
	  
	  INNER JOIN gisBaseReference gbr_reg
	  ON gbr_reg.idfsGISBaseReference = reg.idfsRegion
	  AND gbr_reg.intRowStatus = 0
	  
	  INNER JOIN dbo.gisStringNameTranslation gsnt_reg
	  ON gsnt_reg.idfsGISBaseReference = gbr_reg.idfsGISBaseReference
	  AND gsnt_reg.idfsLanguage = @idfsLanguage
	  AND gsnt_reg.intRowStatus = 0
	  
	  INNER JOIN gisBaseReference gbr_ray
	  ON gbr_ray.idfsGISBaseReference = ray.idfsRayon
	  AND gbr_ray.intRowStatus = 0
	  
	  INNER JOIN dbo.gisStringNameTranslation gsnt_ray
	  ON gsnt_ray.idfsGISBaseReference = gbr_ray.idfsGISBaseReference
	  AND gsnt_ray.idfsLanguage = @idfsLanguage
	  AND gsnt_ray.intRowStatus = 0
	  
	WHERE ray.intRowStatus = 0



	UPDATE rfstat SET
		rfstat.intMaxYearForStatistics = maxYear
	FROM @ReportTable rfstat
	INNER JOIN (
		SELECT MAX(year(stat.datStatisticStartDate)) AS maxYear, rfs.idfsRayon
		FROM @ReportTable  rfs    
			INNER JOIN dbo.tlbStatistic stat
			ON stat.idfsArea = rfs.idfsRayon 
				AND stat.intRowStatus = 0
				AND stat.idfsStatisticDataType = @idfsStatType  -- Population under 15
				AND year(stat.datStatisticStartDate) <= @Year
		GROUP BY  idfsRayon
	  ) AS mrfs
	ON rfstat.idfsRayon = mrfs.idfsRayon
                                      	

	UPDATE rt SET
		rt.intChildren = CAST(s.varValue AS INT)
	FROM @ReportTable rt
	INNER JOIN dbo.tlbStatistic s
	ON	rt.idfsRayon = s.idfsArea AND
		s.intRowStatus = 0 AND
		s.idfsStatisticDataType = @idfsStatType AND
		s.datStatisticStartDate = CAST(rt.intMaxYearForStatistics AS varchar(4)) + '-01-01' 


   
	DECLARE @DiagnosisTable TABLE
	(
	idfsDiagnosis BIGINT NOT NULL PRIMARY KEY
	)

	INSERT INTO @DiagnosisTable
	(
		idfsDiagnosis
	)
	SELECT 
		fdt.idfsDiagnosisOrReportDiagnosisGroup
	FROM  dbo.trtReportRows fdt
		INNER JOIN trtDiagnosis trtd
		ON trtd.idfsDiagnosis = fdt.idfsDiagnosisOrReportDiagnosisGroup AND
		trtd.intRowStatus = 0
	WHERE  fdt.idfsCustomReportType = @idfsCustomReportType 


	DECLARE	@ReportCaseTable	TABLE
	(	
		idfCase			BIGINT NOT NULL PRIMARY KEY,
		idfsRegion		BIGINT NOT NULL,
		idfsRayon		BIGINT NOT NULL,
		datOnSetDate	DATETIME,
		IsSampleExists	bit NOT NULL default(0)
	)


	INSERT INTO	@ReportCaseTable
	(	
		idfCase,
		idfsRegion,
		idfsRayon,
		datOnSetDate
	)
	SELECT DISTINCT
		hc.idfHumanCase AS idfCase,
		gl.idfsRegion,  /*region CR*/
		gl.idfsRayon,  /*rayon CR*/
  		CAST(tap.varValue AS DATETIME) AS datOnSetDate
	FROM tlbHumanCase hc
	INNER JOIN tlbHuman h
		INNER  JOIN tlbGeoLocation gl
		ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
	ON hc.idfHuman = h.idfHuman AND
	   h.intRowStatus = 0

	INNER JOIN	@ReportTable fdt
	ON	fdt.idfsRegion = gl.idfsRegion
		AND fdt.idfsRayon = gl.idfsRayon
			
	INNER JOIN @DiagnosisTable dt
	ON dt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

	INNER JOIN tlbObservation obs
		INNER JOIN tlbActivityParameters tap
		ON tap.idfObservation = obs.idfObservation
		AND tap.intRowStatus = 0
		AND tap.idfsParameter = @FFP_Date_of_onset_of_paralysis
		AND (
				CAST(SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
				(CAST(SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(tap.varValue AS NVARCHAR)) = 1 )	
			)  
	ON	obs.idfObservation = hc.idfCSObservation
		AND obs.intRowStatus = 0			
			
			
	LEFT JOIN tstSite ts
	ON	ts.idfsSite = hc.idfsSite
		AND ts.intRowStatus = 0
		AND ts.intFlags = 1
  			
	WHERE	hc.datTentativeDiagnosisDate is NOT NULL AND
			(@SD <= CAST(tap.varValue AS DATETIME) AND CAST(tap.varValue AS DATETIME) < DATEADD(day, 1, @ED)) 
			AND gl.idfsRegion is NOT NULL 
			AND gl.idfsRayon is NOT NULL
			AND ts.idfsSite is NULL
			AND hc.intRowStatus = 0 
			AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/

	UPDATE rct SET
		rct.IsSampleExists = 1
	FROM @ReportCaseTable rct
	WHERE EXISTS
	(
		SELECT  *
		FROM @ReportCaseTable  rct1
			INNER JOIN tlbMaterial m
			ON m.idfHumanCase = rct1.idfCase
			AND m.intRowStatus = 0
		WHERE	m.datFieldCollectionDate - rct1.datOnSetDate <=  14 
				AND rct.idfCase = rct1.idfCase
	)


	DECLARE	@ReportCaseTableWithLastOnsetDate	TABLE
	(	
		idfCase				BIGINT NOT NULL PRIMARY KEY,
		idfsRegion			BIGINT NOT NULL,
		idfsRayon			BIGINT NOT NULL,
		datLastOnSetDate	DATETIME
	)


	INSERT INTO	@ReportCaseTableWithLastOnsetDate
	(	
		idfCase,
		idfsRegion,
		idfsRayon,
		datLastOnSetDate
	)
	SELECT DISTINCT
		hc.idfHumanCase AS idfCase,
		gl.idfsRegion,  /*region CR*/
		gl.idfsRayon,  /*rayon CR*/
  		CAST(tap.varValue AS DATETIME) AS datOnSetDate
	FROM tlbHumanCase hc
	INNER JOIN tlbHuman h
		INNER  JOIN tlbGeoLocation gl
		ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
	ON hc.idfHuman = h.idfHuman AND
	   h.intRowStatus = 0

	INNER JOIN	@ReportTable fdt
	ON	fdt.idfsRegion = gl.idfsRegion
		AND fdt.idfsRayon = gl.idfsRayon
			
	INNER JOIN @DiagnosisTable dt
	ON dt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

	INNER JOIN tlbObservation obs
		INNER JOIN tlbActivityParameters tap
		ON tap.idfObservation = obs.idfObservation
		AND tap.intRowStatus = 0		
		AND tap.idfsParameter = @FFP_Date_of_onset_of_paralysis
		AND (
				CAST(SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
				(CAST(SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(tap.varValue AS NVARCHAR)) = 1 )	
			)  
	ON	obs.idfObservation = hc.idfCSObservation
		AND obs.intRowStatus = 0			
			
	LEFT JOIN tstSite ts
	ON	ts.idfsSite = hc.idfsSite
		AND ts.intRowStatus = 0
		AND ts.intFlags = 1
  			
	WHERE	hc.datTentativeDiagnosisDate is NOT NULL AND
			CAST(tap.varValue AS DATETIME) < @SD
			AND gl.idfsRegion is NOT NULL 
			AND gl.idfsRayon is NOT NULL
			AND ts.idfsSite is NULL
			AND hc.intRowStatus = 0 
			AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/
			

	--Total
	DECLARE	@ReportCaseDiagnosisTotalValuesTable	TABLE
	(	
		intTotal		INT NOT NULL,
		idfsRegion		BIGINT NOT NULL,
		idfsRayon		BIGINT NOT NULL
	)

	INSERT INTO	@ReportCaseDiagnosisTotalValuesTable
	(	
		intTotal,
		idfsRegion,
		idfsRayon
	)
	SELECT 
		count(fct.idfCase),
		idfsRegion,
		idfsRayon
	FROM		@ReportCaseTable fct
	GROUP BY	fct.idfsRegion, fct.idfsRayon

	--Total cases with samples
	DECLARE	@ReportCaseDiagnosisTotalValuesTableWithSamples	TABLE
	(	
		intTotal		INT NOT NULL,
		idfsRegion		BIGINT NOT NULL,
		idfsRayon		BIGINT NOT NULL
	)

	INSERT INTO	@ReportCaseDiagnosisTotalValuesTableWithSamples
	(	
		intTotal,
		idfsRegion,
		idfsRayon
	)
	SELECT 
		count(rct.idfCase),
		idfsRegion,
		idfsRayon
	FROM		@ReportCaseTable rct
	WHERE		rct.IsSampleExists = 1
	GROUP BY	rct.idfsRegion, rct.idfsRayon


	--Last paralisys onset year
	DECLARE	@ReportCaseLastParalisysOnsetYearTable	TABLE
	(	
		intLastParalisysOnsetYear		INT NOT NULL,
		idfsRegion						BIGINT NOT NULL,
		idfsRayon						BIGINT NOT NULL
	)

	INSERT INTO	@ReportCaseLastParalisysOnsetYearTable
	(	
		intLastParalisysOnsetYear,
		idfsRegion,
		idfsRayon
	)
	SELECT 
		ISNULL(year(max(fct.datLastOnSetDate)), 0),
		idfsRegion,
		idfsRayon
	FROM		@ReportCaseTableWithLastOnsetDate fct
	GROUP BY	fct.idfsRegion, fct.idfsRayon
	


	-- calculated fields
	UPDATE		rt
	SET			rt.intRegisteredAFP = fcdvt.intTotal
	FROM		@ReportTable rt
	INNER JOIN	@ReportCaseDiagnosisTotalValuesTable fcdvt
	ON			fcdvt.idfsRegion = rt.idfsRegion
				AND fcdvt.idfsRayon = rt.idfsRayon
  	   

	UPDATE		rt
	SET			rt.intRegisteredAFPWithSamples = fcdvts.intTotal
	FROM		@ReportTable rt
	INNER JOIN	@ReportCaseDiagnosisTotalValuesTableWithSamples fcdvts
	ON			fcdvts.idfsRegion = rt.idfsRegion
				AND fcdvts.idfsRayon = rt.idfsRayon
	WHERE rt.intRegisteredAFP > 0


	UPDATE		rt
	SET			rt.intLastParalisysOnsetYear = fcdvt.intLastParalisysOnsetYear
	FROM		@ReportTable rt
	INNER JOIN	@ReportCaseLastParalisysOnsetYearTable fcdvt
	ON			fcdvt.idfsRegion = rt.idfsRegion
				AND fcdvt.idfsRayon = rt.idfsRayon

;With Cte AS
(
	SELECT   
		strRegion,
		strRayon,
		intChildren,  --(1)
		intRegisteredAFP, --(2)
		IIF(ISNULL(intChildren,0)<>0,CAST(100000*intRegisteredAFP/CAST(intChildren AS FLOAT) AS Decimal(6,2)),0) NonPolioAFPrate, --(3)
		intRegisteredAFPWithSamples, --(4)
		IIF(ISNULL(intRegisteredAFP,0)<>0,CAST(intRegisteredAFPWithSamples/CAST(intRegisteredAFP AS FLOAT) AS Decimal(6,2)),NULL) AS Percentage, --(5) is a percentage of (4) FROM (2)
		IIF(intLastParalisysOnsetYear is NULL, NULL,Year(@SD)-intLastParalisysOnsetYear) AS D,
		ISNULL(intChildren,0)/100000.00 AS A,
		intLastParalisysOnsetYear,
		intRegionOrder
	FROM @ReportTable
	)
	
	--SELECT 
	--	strRegion
	--	,strRayon
	--	,intChildren AS intChildren_1
	--	,intRegisteredAFP AS intRegisteredAFP_2
	--	,NonPolioAFPrate AS NonPolioAFPrate_3  -- [2]*100000/[1]
	--	,intRegisteredAFPWithSamples AS intRegisteredAFPWithSamples_4
	--	,Percentage AS Percentage_5  -- 100*[4]/[2]
	--	,A
	--	,D
	--	,A*D AS R
	--	,intLastParalisysOnsetYear
	--	,IIF(NonPolioAFPrate>intRegisteredAFP,intChildren*Percentage,NonPolioAFPrate*Percentage) AS AFP_Surveillance_Index_AsPerRequiremt7_old
	--  ,IIF(NonPolioAFPrate>intChildren,intChildren*Percentage,NonPolioAFPrate*Percentage) AS AFP_Surveillance_Index_AsPerRequiremt7_New
	--	,IIF(NonPolioAFPrate>=intRegisteredAFP,intChildren*intRegisteredAFP,intChildren*Percentage) AS AFP_Surveillance_Index_AsPerOldApp6_1  --Calculation done AS per 6.1 Report, Requirement NOT matching...
	--	,IIF(A >= 1,A,IIF(ROUND(A*D,0)>=1,1,0)) ExpectedCase
 --   FROM Cte
	--order by intRegionOrder, strRayon 
	
	SELECT 
		strRegion
		,strRayon
		,intChildren AS intChildren
		,intRegisteredAFP AS intRegisteredAFP
		,NonPolioAFPrate AS NonPolioAFPrate  -- [2]*100000/[1]
		,IIF(NonPolioAFPrate>intChildren,intChildren*Percentage,NonPolioAFPrate*Percentage) AS AFP_Surveillance_Index --AS 7.1 requirement(Confirmed by Celnah)
		,CAST(IIF(A >= 1,A,IIF(ROUND(A*D,0)>=1,1,0)) AS INT) ExpectedCase
    FROM Cte
	order by intRegionOrder, strRayon 
				


