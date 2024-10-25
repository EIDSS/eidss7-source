

-- This stored proc is called by the report:
--
-- Comparative Report of Several Years by Months
--
-- it updates the temp tables created in the main report script
--
--  Mark Wilson updated for EIDSS7 standards
--
CREATE PROCEDURE [Report].[USP_REP_HUM_ComparativeSeveralYearsByMonthsGG_Calculations]
(
    @CountryID BIGINT,
    @StartDate DATETIME,
    @FinishDate DATETIME,
    @RegionID BIGINT,
    @RayonID BIGINT
)
AS
BEGIN

	SET DATEFIRST 1; -- SET first day of week to Monday

	DECLARE
		@MinAdminLevel BIGINT,
		@MinTimeInterval BIGINT,
		@AggrCaseType BIGINT,
  		@idfsCustomReportType BIGINT,		
		@FFP_Total BIGINT,
		@LangID	NVARCHAR(10)='en'

	SET @idfsCustomReportType = 10290053 /*GG Comparative Report of several years by months*/

	SELECT 
		@FFP_Total = idfsFFObject 
	FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType 
	AND strFFObjectAlias = 'FFP_Total' COLLATE Cyrillic_General_CI_AS
	AND intRowStatus = 0

	IF OBJECT_ID('tempdb.dbo.#ReportDiagnoses') IS NULL 
	CREATE TABLE #ReportDiagnoses
	(	
		idfID BIGINT NOT NULL IDENTITY (1, 1),
		idfsDiagnosis BIGINT NOT NULL,
		idfsDiagnosisReportGroup BIGINT NOT NULL,
		idfsDiagnosisGroup BIGINT null,
		PRIMARY KEY	(
			idfsDiagnosis ASC,
			idfsDiagnosisReportGroup ASC
					)
	)

	SET @AggrCaseType = 10102001	-- Human Aggregate Case

	SELECT	
		@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_GBL_AggregateSettings_GET(@AggrCaseType)--@AggrCaseType


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

	FROM tlbAggrCase a
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
		  OR (@MinTimeInterval = 10091004 AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0 AND DATEDIFF(day, a.datStartDate, a.datFinishDate) > 1)
		  OR (@MinTimeInterval = 10091002 AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 0))  
	    		
	AND ((@MinAdminLevel = 10089001  AND a.idfsAdministrativeUnit = c.idfsReference)
		  OR (@MinAdminLevel = 10089003 AND a.idfsAdministrativeUnit = r.idfsRegion	AND (r.idfsRegion = @RegionID OR @RegionID IS NULL))
		  OR (@MinAdminLevel = 10089002 AND a.idfsAdministrativeUnit = rr.idfsRayon AND (rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
										AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL))
		  OR (@MinAdminLevel = 10089004 AND a.idfsAdministrativeUnit = s.idfsSettlement AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
										AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)))

	AND a.intRowStatus = 0

	DECLARE	@ReportAggregateValuesTable	TABLE
	(	
		idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
		intMonth INT NOT NULL,
		intYear INT NOT NULL,
		intTotal INT NOT NULL
	)

	INSERT INTO	@ReportAggregateValuesTable

	SELECT	
		fhac.idfAggrCase,
		MONTH(fhac.datStartDate),
		YEAR(fhac.datStartDate),
		SUM(ISNULL(CAST(agp_Total.varValue AS INT), 0))

	FROM @ReportHumanAggregateCase fhac
	-- Updated for version 6
	-- Matrix version
	INNER JOIN tlbAggrMatrixVersionHeader h ON h.idfsMatrixType = 71190000000	-- Human Aggregate Case
				AND (h.idfVersion = fhac.idfVersion 
					-- If matrix version is not SELECTed by the user in aggregate case, 
					-- then SELECT active matrix with the latest date activation that is earlier than aggregate case start date
					OR (fhac.idfVersion IS NULL AND h.datStartDate <= fhac.datStartDate AND h.blnIsActive = 1
								AND NOT EXISTS	(SELECT	*
												 FROM	tlbAggrMatrixVersionHeader h_later
												 WHERE	h_later.idfsMatrixType = 71190000000	-- Human Aggregate Case
												 AND h_later.datStartDate <= fhac.datStartDate
												 AND h_later.blnIsActive = 1
												 AND h_later.intRowStatus = 0
												 AND h_later.datStartDate > h.datStartDate))) AND h.intRowStatus = 0
			
	-- Matrix row
	INNER JOIN	tlbAggrHumanCaseMTX mtx ON mtx.idfVersion = h.idfVersion AND mtx.intRowStatus = 0
               
	--	Total		
	LEFT JOIN dbo.tlbActivityParameters agp_Total ON agp_Total.idfObservation= fhac.idfCaseObservation
				  AND agp_Total.idfsParameter = @FFP_Total AND agp_Total.idfRow = mtx.idfAggrHumanCaseMTX AND agp_Total.intRowStatus = 0
				  AND SQL_VARIANT_PROPERTY(agp_Total.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

	WHERE ((SELECT COUNT(*) FROM #ReportDiagnoses rd_count) = 0
			OR EXISTS 
			(
				SELECT	TOP 1 1
				FROM #ReportDiagnoses rd
				WHERE rd.idfsDiagnosis = mtx.idfsDiagnosis				  
			)
		  )
	GROUP BY 
		fhac.idfAggrCase,
		YEAR(fhac.datStartDate),
		MONTH(fhac.datStartDate)

	DECLARE	@ReportCaseTable TABLE
	(	
		idfCase	BIGINT NOT NULL PRIMARY KEY,
		intMonth INT NOT NULL,
		intYear	INT NOT NULL
	)

	INSERT INTO	@ReportCaseTable

	SELECT 
		DISTINCT hc.idfHumanCase AS idfCase,
		MONTH(COALESCE(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate)),
		YEAR(COALESCE(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate))	
	FROM tlbHumanCase hc
	INNER JOIN tlbHuman h
			LEFT OUTER JOIN tlbGeoLocation cra ON h.idfCurrentResidenceAddress = cra.idfGeoLocation AND cra.intRowStatus = 0
		  ON hc.idfHuman = h.idfHuman AND h.intRowStatus = 0

	LEFT OUTER JOIN tlbGeoLocation loc_exp ON hc.idfPointGeoLocation = loc_exp.idfGeoLocation AND loc_exp.intRowStatus = 0
			
	WHERE	(@StartDate <= COALESCE(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate)
				/*Added 2018-01-22 - start*/and COALESCE(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate) < @FinishDate/*Added 2018-01-22 - end*/
				--/*Commented 2018-01-22 - start*/--and COALESCE(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate) < DATEADD(day, 1, @FinishDate)--/*Commented 2018-01-22 - end*/--
			) and
			(	isnull(loc_exp.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
				or isnull(loc_exp.idfsCountry, cra.idfsCountry) is null
				or isnull(loc_exp.idfsCountry, cra.idfsCountry) = 780000000
			) and	
			(case
				when	loc_exp.idfsRegion is NOT NULL
					then loc_exp.idfsRegion
				else cra.idfsRegion
			 end = @RegionID
			 or @RegionID is null
			) and 
			(case
				when	loc_exp.idfsRegion is NOT NULL
					then loc_exp.idfsRayon
				else cra.idfsRayon
			 end = @RayonID
			 or @RayonID is null
			) and		  
			hc.intRowStatus = 0 and
			COALESCE(hc.idfsFinalCaseStatus, hc.idfsInitialCaseStatus, 370000000) <> 370000000 /*Not a Case*/ and
			(	(SELECT count(*) from #ReportDiagnoses rd_count) = 0
				or	exists	(
						SELECT	top 1 1
						from	#ReportDiagnoses rd
						where	rd.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis, -1)
							)
			)

	--Total
	--standard cases
	DECLARE	@ReportCaseTotalValuesTable	TABLE
	(	
		intMonth BIGINT NOT NULL,
		intTotal INT NOT NULL,
		intYear	 int NOT NULL,
		PRIMARY KEY (intYear, intMonth)
	)

	INSERT INTO	@ReportCaseTotalValuesTable

	SELECT
		fct.intMonth,
		COUNT(fct.idfCase),
		fct.intYear

	FROM @ReportCaseTable fct
	GROUP BY
		fct.intYear, 
		fct.intMonth


	-- aggregate cases
	DECLARE	@ReportAggrCaseTotalValuesTable	TABLE
	(	
		intMonth BIGINT NOT NULL,
		intTotal INT NOT NULL,
		intYear INT NOT NULL,
		PRIMARY KEY (intYear, intMonth)
	)

	INSERT INTO	@ReportAggrCaseTotalValuesTable
	SELECT
		fct.intMonth,
		SUM(fct.intTotal),
		fct.intYear
	FROM @ReportAggregateValuesTable fct
	GROUP BY
		fct.intYear, 
		fct.intMonth

	
	IF EXISTS(SELECT * FROM report.HumComparativeSeveralYearsByMonthsGG)  
	BEGIN
		UPDATE rt
			SET rt.intTotal = ISNULL(rt.intTotal, 0) + rctvt.intTotal

		FROM report.HumComparativeSeveralYearsByMonthsGG rt
		INNER JOIN @ReportCaseTotalValuesTable rctvt ON rctvt.intMonth = rt.intMonth AND rctvt.intYear = rt.intYear


		UPDATE rt
			SET rt.intTotal = ISNULL(rt.intTotal,0) + ractvt.intTotal

		FROM report.HumComparativeSeveralYearsByMonthsGG rt
		INNER JOIN @ReportAggrCaseTotalValuesTable ractvt ON  ractvt.intMonth = rt.intMonth AND ractvt.intYear = rt.intYear
	END

END


