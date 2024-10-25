

--- This stored proc is called the report:
--
--	Comparative Report on Infectious Diseases/Conditions (by Months)
--
--  Mark Wilson Updated for EIDSS7 standards

/*
--Example of a call of procedure:

exec report.USP_REP_Hum_ComparativeGG_Calculations '01/01/2015', '12/31/2015'

exec report.USP_REP_Hum_ComparativeGG_Calculations 'ru', 2011, 2012 

*/ 
CREATE PROCEDURE [Report].[USP_REP_Hum_ComparativeGG_Calculations]
 (   
	@StartDate DATETIME,
    @FinishDate DATETIME,
    @RegionID BIGINT = NULL,
    @RayonID BIGINT = NULL
)

AS
BEGIN

	SET DATEFIRST 1; -- SET MONDAY AS First day of week.

	DECLARE
	  
		@MinAdminLevel			BIGINT,
		@MinTimeInterval		BIGINT,
		@AggrCaseType			BIGINT,
  		@idfsCustomReportType	BIGINT,		
		@FFP_Total				BIGINT,
		@FFP_Age_0				BIGINT,
		@FFP_Age_1_4			BIGINT,
		@FFP_Age_5_14			BIGINT,
		@CountryID				BIGINT,
		@LangID					NVARCHAR(10)='en'

	SET	@CountryID = 780000000
	  
	SET @idfsCustomReportType = 10290051 /*Comparative Report on Infectious Diseases/Conditions (by MONTHs)*/

	SELECT 
		@FFP_Age_0 = idfsFFObject

	FROM dbo.trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_Age_0'
	AND intRowStatus = 0

	SELECT 
		@FFP_Age_1_4 = idfsFFObject 
	
	FROM dbo.trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_Age_1_4'
	AND intRowStatus = 0

	SELECT 
		@FFP_Age_5_14 = idfsFFObject 

	FROM dbo.trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_Age_5_14'
	AND intRowStatus = 0

	SELECT 
		@FFP_Total = idfsFFObject

	FROM dbo.trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType
	AND strFFObjectAlias = 'FFP_Total'
	AND intRowStatus = 0

	SET @AggrCaseType = 10102001

	SELECT	
		@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType

	FROM report.FN_GBL_AggregateSettings_GET (@AggrCaseType)--@AggrCaseType

	DECLARE	@ReportHumanAggregateCase TABLE
	(	
		idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
		idfCaseObservation BIGINT,
		datStartDate DATETIME,
		idfVersion BIGINT
	)

	INSERT INTO	@ReportHumanAggregateCase

	SELECT	
		a.idfAggrCase,
		a.idfCaseObservation,
		a.datStartDate,
		a.idfVersion

	FROM dbo.tlbAggrCase a
	LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON			c.idfsReference = a.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
	ON			r.idfsRegion = a.idfsAdministrativeUnit 
	LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
	ON			rr.idfsRayon = a.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
	ON			s.idfsSettlement = a.idfsAdministrativeUnit
	
	WHERE a.idfsAggrCaseType = @AggrCaseType
	AND (@StartDate <= a.datStartDate AND a.datFinishDate < @FinishDate)

	AND ((@MinTimeInterval = 10091005 AND DATEDIFF(YEAR, a.datStartDate, a.datFinishDate) = 0 AND DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) > 1)
		OR (@MinTimeInterval = 10091003 AND DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) = 0 AND DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) > 1)
		OR (@MinTimeInterval = 10091001 AND DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) = 0 AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1)
		OR (@MinTimeInterval = 10091004 AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0 AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) > 1)
		OR (@MinTimeInterval = 10091002	AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 0)
	)

	AND ((@MinAdminLevel = 10089001 AND a.idfsAdministrativeUnit = c.idfsReference)
		OR (@MinAdminLevel = 10089003 AND a.idfsAdministrativeUnit = r.idfsRegion AND (r.idfsRegion = @RegionID OR @RegionID IS NULL))
		OR (@MinAdminLevel = 10089002 AND a.idfsAdministrativeUnit = rr.idfsRayon AND (rr.idfsRayon = @RayonID OR @RayonID IS NULL) AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL))
		OR (@MinAdminLevel = 10089004 AND a.idfsAdministrativeUnit = s.idfsSettlement AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) AND (s.idfsRegion = @RegionID OR @RegionID IS NULL))
	)

	AND a.intRowStatus = 0

	DECLARE	@ReportAggregateDiagnosisValuesTable TABLE
	(	
		idfsBaseReference BIGINT NOT NULL PRIMARY KEY,
		intTotal INT NOT NULL,
		intAge_0_15	INT NOT NULL
	)

	INSERT INTO	@ReportAggregateDiagnosisValuesTable

	SELECT		
		fdt.idfsDiagnosis,
		SUM(ISNULL(CAST(agp_Total.varValue AS INT), 0)),
		SUM(ISNULL(CAST(agp_Age_0.varValue AS INT), 0)) + SUM(ISNULL(CAST(agp_Age_1_4.varValue AS INT), 0)) + SUM(ISNULL(CAST(agp_Age_5_14.varValue AS INT), 0))

	FROM @ReportHumanAggregateCase fhac
	-- Matrix version
	INNER JOIN dbo.tlbAggrMatrixVersionHeader h ON h.idfsMatrixType = 71190000000	-- Human Aggregate Case
			   AND (h.idfVersion = fhac.idfVersion 
					OR (fhac.idfVersion IS NULL	AND	h.datStartDate <= fhac.datStartDate
						AND	h.blnIsActive = 1
						AND NOT EXISTS (
										SELECT	*
										FROM dbo.tlbAggrMatrixVersionHeader h_later
										WHERE h_later.idfsMatrixType = 71190000000	-- Human Aggregate Case
											  AND h_later.datStartDate <= fhac.datStartDate
											  AND h_later.blnIsActive = 1
											  AND h_later.intRowStatus = 0
											  AND h_later.datStartDate > h.datStartDate
										)
						))
				AND h.intRowStatus = 0
	-- Matrix row
	INNER JOIN dbo.tlbAggrHumanCaseMTX mtx ON mtx.idfVersion = h.idfVersion AND mtx.intRowStatus = 0
	INNER JOIN #ReportDiagnosisTable fdt ON fdt.idfsDiagnosis = mtx.idfsDiagnosis        
	--	Total		
	LEFT JOIN dbo.tlbActivityParameters agp_Total ON agp_Total.idfObservation= fhac.idfCaseObservation AND agp_Total.idfsParameter = @FFP_Total AND agp_Total.idfRow = mtx.idfAggrHumanCaseMTX
			  AND agp_Total.intRowStatus = 0 AND SQL_VARIANT_PROPERTY(agp_Total.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
	--	Age_0		
	LEFT JOIN dbo.tlbActivityParameters agp_Age_0 ON agp_Age_0.idfObservation = fhac.idfCaseObservation AND agp_Age_0.idfsParameter = @FFP_Age_0 AND agp_Age_0.idfRow = mtx.idfAggrHumanCaseMTX
			  AND agp_Age_0.intRowStatus = 0 AND SQL_VARIANT_PROPERTY(agp_Age_0.varValue, 'BaseType') in ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

	--	Age_1_4		
	LEFT JOIN dbo.tlbActivityParameters agp_Age_1_4 ON agp_Age_1_4.idfObservation = fhac.idfCaseObservation
			  AND agp_Age_1_4.idfsParameter = @FFP_Age_1_4 AND agp_Age_1_4.idfRow = mtx.idfAggrHumanCaseMTX AND agp_Age_1_4.intRowStatus = 0
			  AND SQL_VARIANT_PROPERTY(agp_Age_1_4.varValue, 'BaseType') in ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			
	--	Age_5_14		
	LEFT JOIN dbo.tlbActivityParameters agp_Age_5_14 ON agp_Age_5_14.idfObservation = fhac.idfCaseObservation AND agp_Age_5_14.idfsParameter = @FFP_Age_5_14 AND agp_Age_5_14.idfRow = mtx.idfAggrHumanCaseMTX
			  AND agp_Age_5_14.intRowStatus = 0 AND SQL_VARIANT_PROPERTY(agp_Age_5_14.varValue, 'BaseType') in ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
						
	GROUP BY fdt.idfsDiagnosis

	DECLARE	@ReportCaseTable TABLE
	(	
		idfsDiagnosis BIGINT  NOT NULL,
		idfCase BIGINT NOT NULL primary key,
		intYear INT NULL,
		idfsHumanGender BIGINT,
		idfsRegion BIGINT,
		idfsRayon BIGINT
	)

	INSERT INTO	@ReportCaseTable

	SELECT 
		DISTINCT fdt.idfsDiagnosis,
		hc.idfHumanCase AS idfCase,
		CASE 
			WHEN ISNULL(hc.idfsHumanAgeType, -1) = 10042003 AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 200) THEN hc.intPatientAge -- Years
			WHEN ISNULL(hc.idfsHumanAgeType, -1) = 10042002 AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 60) THEN CAST(hc.intPatientAge/12 AS INT) -- MONTHS
			WHEN ISNULL(hc.idfsHumanAgeType, -1) = 10042001	AND (ISNULL(hc.intPatientAge, -1) >= 0) THEN 0-- Days
			ELSE NULL END,
		h.idfsHumanGender, /*gender*/
		CASE
			WHEN loc_exp.idfsRegion IS NOT NULL THEN loc_exp.idfsRegion
			ELSE cra.idfsRegion END AS idfsRegion,  /*region CR*/
		 CASE
			WHEN loc_exp.idfsRegion IS NOT NULL THEN loc_exp.idfsRayon
			ELSE cra.idfsRayon END  idfsRayon  /*rayon CR*/
			
	FROM dbo.tlbHumanCase hc
	INNER JOIN #ReportDiagnosisTable fdt ON fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
	INNER JOIN dbo.tlbHuman h LEFT OUTER JOIN tlbGeoLocation cra ON h.idfCurrentResidenceAddress = cra.idfGeoLocation AND cra.intRowStatus = 0
		  ON hc.idfHuman = h.idfHuman AND h.intRowStatus = 0
	LEFT OUTER JOIN dbo.tlbGeoLocation loc_exp ON hc.idfPointGeoLocation = loc_exp.idfGeoLocation AND loc_exp.intRowStatus = 0
   
	-- MCW changed this code to use COALESCE and BETWEEN rather than a bunch of ISNULLs and <= and >	
/* Original code:
	WHERE	(@StartDate <= ISNULL(hc.datOnSetDate, IsNull(hc.datFinalDiagnosisDate, ISNULL(hc.datTentativeDiagnosisDate, IsNull(hc.datNotificationDate, hc.datEnteredDate))))
			/*Added 2018-01-22 - start*/and ISNULL(hc.datOnSetDate, IsNull(hc.datFinalDiagnosisDate, ISNULL(hc.datTentativeDiagnosisDate, IsNull(hc.datNotificationDate, hc.datEnteredDate)))) < @FinishDate/*Added 2018-01-22 - end*/
			--/*Commented 2018-01-22 - start*/--and ISNULL(hc.datOnSetDate, IsNull(hc.datFinalDiagnosisDate, ISNULL(hc.datTentativeDiagnosisDate, IsNull(hc.datNotificationDate, hc.datEnteredDate)))) < DATEADD(day, 1, @FinishDate)--/*Commented 2018-01-22 - end*/--
*/
	WHERE (COALESCE(HC.datOnsetDate, HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate, HC.datNotificationDate, HC.datEnteredDate) BETWEEN @StartDate AND @FinishDate)
	AND (ISNULL(loc_exp.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/ OR ISNULL(loc_exp.idfsCountry, cra.idfsCountry) IS NULL OR ISNULL(loc_exp.idfsCountry, cra.idfsCountry) = 780000000)
	AND	(CASE WHEN loc_exp.idfsRegion IS NOT NULL THEN loc_exp.idfsRegion ELSE cra.idfsRegion END = @RegionID OR @RegionID IS NULL)
	AND (CASE WHEN loc_exp.idfsRegion IS NOT NULL THEN loc_exp.idfsRayon ELSE cra.idfsRayon END = @RayonID OR @RayonID IS NULL) 
	AND hc.intRowStatus = 0 AND COALESCE(hc.idfsFinalCaseStatus, hc.idfsInitialCaseStatus, 370000000) <> 370000000 --'casRefused'

	--Total
	DECLARE	@ReportCaseDiagnosisTotalValuesTable TABLE
	(	
		idfsDiagnosis BIGINT NOT NULL PRIMARY KEY,
		intTotal INT NOT NULL
	)

	INSERT INTO	@ReportCaseDiagnosisTotalValuesTable

	SELECT 
		fct.idfsDiagnosis,
		COUNT(fct.idfCase)

	FROM @ReportCaseTable fct
	GROUP BY fct.idfsDiagnosis

	--Total Age_0_15
	DECLARE	@ReportCaseDiagnosis_Age_0_15_TotalValuesTable TABLE
	(	
		idfsDiagnosis BIGINT NOT NULL PRIMARY KEY,
		intAge_0_15 INT NOT NULL
	)

	INSERT INTO	@ReportCaseDiagnosis_Age_0_15_TotalValuesTable

	SELECT
		fct.idfsDiagnosis,
		COUNT(fct.idfCase)

	FROM @ReportCaseTable fct
	WHERE (fct.intYear BETWEEN 0 AND 14)
	GROUP BY fct.idfsDiagnosis

	--aggregate cases
	UPDATE fdt
	SET				
		fdt.intAge_0_15 = fadvt.intAge_0_15,
		fdt.intTotal = fadvt.intTotal	
	FROM #ReportDiagnosisTable fdt
	INNER JOIN	@ReportAggregateDiagnosisValuesTable fadvt ON fadvt.idfsBaseReference = fdt.idfsDiagnosis

	--standard cases
	UPDATE fdt
	SET 
		fdt.intTotal = ISNULL(fdt.intTotal, 0) + fcdvt.intTotal
	FROM #ReportDiagnosisTable fdt
	INNER JOIN	@ReportCaseDiagnosisTotalValuesTable fcdvt ON fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
	
	UPDATE fdt
	SET 
		fdt.intAge_0_15 = ISNULL(fdt.intAge_0_15, 0) + fcdvt.intAge_0_15
	FROM #ReportDiagnosisTable fdt
	INNER JOIN	@ReportCaseDiagnosis_Age_0_15_TotalValuesTable fcdvt ON fcdvt.idfsDiagnosis = fdt.idfsDiagnosis

END
	

