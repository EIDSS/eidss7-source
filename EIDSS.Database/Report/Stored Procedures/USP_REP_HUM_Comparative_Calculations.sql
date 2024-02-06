

--*************************************************************************
-- Name 				: report.USP_REP_HUM_Comparative_Calculations
-- Description			: This procedure returns data for AJ - Comparative Report (used in report.USP_REP_HUM_Comparative for Calculations) 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
-- Need Temptable(#ReportDiagnosisTable) to run
*/

 
CREATE PROCEDURE [Report].[USP_REP_HUM_Comparative_Calculations]
    @CountryID BIGINT,
    @StartDate DATETIME,
    @FinishDate DATETIME,
    @RegionID BIGINT,
    @RayonID BIGINT,
    @OrganizationID	AS BIGINT = null -- idfsSiteID!!

AS
BEGIN

EXEC dbo.[USP_GBL_FirstDay_SET]

DECLARE
	  
    @MinAdminLevel		BIGINT,
    @MinTimeInterval	BIGINT,
    @AggrCaseType		BIGINT,

  	@idfsCustomReportType	BIGINT,		
	@FFP_Total				BIGINT,
	@FFP_Age_0_17			BIGINT,
	@LangID					VARCHAR(2)='en'


	  
   SET @idfsCustomReportType = 10290001 /*Comparative Report*/


	SELECT @FFP_Total = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Total'
	AND intRowStatus = 0


	SELECT @FFP_Age_0_17 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_0_17'
	AND intRowStatus = 0
	

/*
19000091	rftStatisticPeriodType:
    10091001	sptMonth	Month
    10091002	sptOnday	Day
    10091003	sptQuarter	Quarter
    10091004	sptWeek	Week
    10091005	sptYear	Year
19000089	rftStatisticAreaType
    10089001	satCountry	Country
    10089002	satRayon	Rayon
    10089003	satRegion	Region
    10089004	satSettlement	Settlement
19000102	rftAggregateCaseType:
    10102001  Aggregate Case
*/



SET @AggrCaseType = 10102001

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)--@AggrCaseType


DECLARE	@ReportHumanAggregateCase	TABLE
(	
  idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
  idfCaseObservation BIGINT,
  datStartDate DATETIME,
  idfVersion BIGINT
)


INSERT INTO	@ReportHumanAggregateCase
(	
  idfAggrCase,
  idfCaseObservation,
  datStartDate,
  idfVersion
)
SELECT	  a.idfAggrCase,
          a.idfCaseObservation,
          a.datStartDate,
		  a.idfVersion
FROM		tlbAggrCase a
	LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON			c.idfsReference = a.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
	ON			r.idfsRegion = a.idfsAdministrativeUnit 
	LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
	ON			rr.idfsRayon = a.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
	ON			s.idfsSettlement = a.idfsAdministrativeUnit
	LEFT JOIN tstCustomizationPackage tcpac 
	ON			tcpac.idfsCountry = @CountryID
	LEFT JOIN tstSite ts
	ON			ts.idfsSite = a.idfsAdministrativeUnit
				AND ts.idfCustomizationPackage = tcpac.idfCustomizationPackage
				AND ts.intFlags = 1			    

WHERE 			
			a.idfsAggrCaseType = @AggrCaseType
			AND (	@StartDate <= a.datStartDate
					AND a.datFinishDate < @FinishDate
				)
			AND (	(	@MinTimeInterval = 10091005 --'sptYear'
						AND DATEDIFF(YEAR, a.datStartDate, a.datFinishDate) = 0
						AND DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) > 1
					)
					OR	(	@MinTimeInterval = 10091003 --'sptQuarter'
							AND DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) = 0
							AND DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091001 --'sptMonth'
							AND DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) = 0
							AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091004 --'sptWeek'
							AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0
							AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091002--'sptOnday'
						AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 0)
				)    		
			AND (	
        			(	@MinAdminLevel = 10089001 --'satCountry' 
						AND a.idfsAdministrativeUnit = c.idfsReference
						AND @OrganizationID IS NULL
					)
				OR	(	@MinAdminLevel = 10089003 --'satRegion' 
						AND a.idfsAdministrativeUnit = r.idfsRegion
						AND (r.idfsRegion = @RegionID OR @RegionID IS NULL)
							AND (@OrganizationID IS NULL)
					)
				OR	(	@MinAdminLevel = 10089002 --'satRayon' 
						AND a.idfsAdministrativeUnit = rr.idfsRayon
						AND (rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
						AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
							AND (@OrganizationID IS NULL)
					)
				OR	(	@MinAdminLevel = 10089004 --'satSettlement' 
						AND a.idfsAdministrativeUnit = s.idfsSettlement
						AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
						AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
						AND (@OrganizationID IS NULL)
					)
				OR	(
		    			a.idfsAdministrativeUnit = ts.idfsSite
						AND (ts.idfsSite = @OrganizationID or @OrganizationID IS NULL)
						AND @RayonID IS NULL
						AND @RegionID IS NULL
			    )
	      )
AND a.intRowStatus = 0


DECLARE	@ReportAggregateDiagnosisValuesTable	TABLE
(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
	intTotal			INT NOT NULL,
	intAge_0_17			INT NOT NULL
)


INSERT INTO	@ReportAggregateDiagnosisValuesTable
(	idfsBaseReference,
	intTotal,
	intAge_0_17
)
SELECT		
	fdt.idfsDiagnosis,
	SUM(ISNULL(CAST(agp_Total.varValue AS INT), 0)),
	SUM(ISNULL(CAST(agp_Age_0_17.varValue AS INT), 0))

FROM		@ReportHumanAggregateCase fhac
-- UPDATEd for version 6
			
-- Matrix version
INNER JOIN	tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = 71190000000	-- Human Aggregate Case
			AND (	-- Get matrix version selected by the user in aggregate case
					h.idfVersion = fhac.idfVersion 
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate case start date
					OR (	fhac.idfVersion IS NULL 
							AND	h.datStartDate <= fhac.datStartDate
							AND	h.blnIsActive = 1
							AND NOT EXISTS	(
										SELECT	*
										FROM	tlbAggrMatrixVersionHeader h_later
										WHERE	h_later.idfsMatrixType = 71190000000	-- Human Aggregate Case
												AND	h_later.datStartDate <= fhac.datStartDate
												AND	h_later.blnIsActive = 1
												AND h_later.intRowStatus = 0
												AND	h_later.datStartDate > h.datStartDate
						)
						))
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	tlbAggrHumanCaseMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0
INNER JOIN	#ReportDiagnosisTable fdt
ON			fdt.idfsDiagnosis = mtx.idfsDiagnosis

            
        
        
--	Total		
LEFT JOIN	dbo.tlbActivityParameters agp_Total
ON			agp_Total.idfObservation= fhac.idfCaseObservation
			AND	agp_Total.idfsParameter = @FFP_Total
			AND agp_Total.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Total.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Total.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')


--	Age_0_17		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_0_17
ON			agp_Age_0_17.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_0_17.idfsParameter = @FFP_Age_0_17
			AND agp_Age_0_17.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_0_17.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_0_17.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
GROUP BY	fdt.idfsDiagnosis

DECLARE	@ReportCaseTable	TABLE
(	idfsDiagnosis		BIGINT  NOT NULL,
	idfCase				BIGINT NOT NULL PRIMARY KEY,
	intYear				INT NULL,
	idfsHumanGender		BIGINT,
	idfsRegion			BIGINT,
	idfsRayon			BIGINT
)


INSERT INTO	@ReportCaseTable
(	idfsDiagnosis,
	idfCase,
	intYear,
	idfsHumanGender,
	idfsRegion,
	idfsRayon
)
SELECT DISTINCT
			fdt.idfsDiagnosis,
			hc.idfHumanCase AS idfCase,
			CASE
				WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
						AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 200)
					THEN	hc.intPatientAge
				WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042002	-- Months
						AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 60)
					THEN	cast(hc.intPatientAge / 12 AS INT)
				WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042001	-- Days
						AND (ISNULL(hc.intPatientAge, -1) >= 0)
					THEN	0
				ELSE	null
			END,
			h.idfsHumanGender, /*gender*/
			gl.idfsRegion,  /*region CR*/
			gl.idfsRayon  /*rayon CR*/
			
FROM tlbHumanCase hc

    INNER JOIN	#ReportDiagnosisTable fdt
    ON			fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

    INNER JOIN tlbHuman h
        LEFT OUTER JOIN tlbGeoLocation gl
        ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
      ON hc.idfHuman = h.idfHuman AND
         h.intRowStatus = 0
      
    LEFT JOIN tstSite ts
    ON ts.idfsSite = hc.idfsSite
    AND ts.intRowStatus = 0
    AND ts.intFlags = 1
			
WHERE		hc.datFinalCaseClassificationDate is NOT NULL 
			AND
			(		@StartDate <= hc.datFinalCaseClassificationDate
					AND hc.datFinalCaseClassificationDate < @FinishDate				
			) 
			AND
		  (gl.idfsRegion = @RegionID AND ts.idfsSite IS NULL or @RegionID IS NULL) AND
		  (gl.idfsRayon = @RayonID AND ts.idfsSite IS NULL OR @RayonID IS NULL)	AND
		  (ts.idfsSite = @OrganizationID or @OrganizationID IS NULL)

		AND hc.intRowStatus = 0
		AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/


--Total
DECLARE	@ReportCaseDiagnosisTotalValuesTable	TABLE
(	idfsDiagnosis	BIGINT NOT NULL PRIMARY KEY,
	intTotal		INT NOT NULL
)

INSERT INTO	@ReportCaseDiagnosisTotalValuesTable
(	idfsDiagnosis,
	intTotal
)
SELECT fct.idfsDiagnosis,
			count(fct.idfCase)
FROM		@ReportCaseTable fct
GROUP BY	fct.idfsDiagnosis



--Total Age_0_17
DECLARE	@ReportCaseDiagnosis_Age_0_17_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_0_17				INT NOT NULL
)

INSERT INTO	@ReportCaseDiagnosis_Age_0_17_TotalValuesTable
(	idfsDiagnosis,
	intAge_0_17
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@ReportCaseTable fct
WHERE		(fct.intYear >= 0 AND fct.intYear <= 17)
GROUP BY	fct.idfsDiagnosis





--aggregate cases
UPDATE		fdt
SET				
			fdt.intAge_0_17 = fadvt.intAge_0_17,
			fdt.intTotal = fadvt.intTotal	
FROM		#ReportDiagnosisTable fdt
INNER JOIN	@ReportAggregateDiagnosisValuesTable fadvt
ON			fadvt.idfsBaseReference = fdt.idfsDiagnosis



--standard cases
UPDATE		fdt
SET			fdt.intTotal = ISNULL(fdt.intTotal, 0) + fcdvt.intTotal
FROM		#ReportDiagnosisTable fdt
INNER JOIN	@ReportCaseDiagnosisTotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis


UPDATE		fdt
SET			fdt.intAge_0_17 = ISNULL(fdt.intAge_0_17, 0) + fcdvt.intAge_0_17
FROM		#ReportDiagnosisTable fdt
INNER JOIN	@ReportCaseDiagnosis_Age_0_17_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis

END


