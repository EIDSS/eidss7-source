--*************************************************************************
-- Name: report.USP_REP_VET_Form1ASanitaryMeasuresAZ
--
-- Description: Select Sanitary Measures data for Veterinary 
-- Report Form Vet1A.
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------
-- Stephen Long         05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_Form1ASanitaryMeasuresAZ 'en',2014,2016
EXEC report.USP_REP_VET_Form1ASanitaryMeasuresAZ 'ru',2017,2018
EXEC report.USP_REP_VET_Form1ASanitaryMeasuresAZ @LangID=N'en', @FromYear = 2014, @ToYear = 2014, @FromMonth = 9, @ToMonth = 9
*/
CREATE PROCEDURE [Report].[USP_REP_VET_Form1ASanitaryMeasuresAZ]
    (
      @LangID AS NVARCHAR(10)
    , @FromYear AS INT
	, @ToYear AS INT
	, @FromMonth AS INT = NULL
	, @ToMonth AS INT = NULL
	, @RegionID AS BIGINT = NULL
	, @RayonID AS BIGINT = NULL
	, @OrganizationEntered AS BIGINT = NULL
	, @OrganizationID AS BIGINT = NULL
)
WITH RECOMPILE
AS
BEGIN

DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
if Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

DECLARE @Result AS TABLE
(
	strKey					NVARCHAR(200) COLLATE database_default NOT NULL PRIMARY KEY,
	strMeasureName			NVARCHAR(2000) COLLATE database_default NULL,
	SanitaryMeasureOrderColumn	INT NULL,
	intNumberFacilities		INT NULL,
	intSquare				FLOAT NULL,
	strNote					NVARCHAR(2000) COLLATE database_default NULL,
	blnAdditionalText		BIT
)

DECLARE	@idfsSummaryReportType	BIGINT
SET	@idfsSummaryReportType = 10290035	-- Veterinary Report Form Vet 1A - Sanitary

DECLARE	@idfsMatrixType	BIGINT
SET	@idfsMatrixType = 71260000000	-- Veterinary-sanitary measures

-- Specify the value of missing month if remaining month is specified in interval (1-12)
IF	@FromMonth IS NULL AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth IS NULL AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start and End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	DATE
DECLARE	@EndDate	DATE

IF	@FromMonth IS NULL or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0101'
ELSE IF @FromMonth < 10
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0' + CAST(@FromMonth AS NVARCHAR) + N'01'
ELSE
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + CAST(@FromMonth AS NVARCHAR) + N'01'

IF	@ToMonth IS NULL or @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear AS NVARCHAR) + N'0101'
	SET	@EndDate = DATEADD(YEAR, 1, @EndDate)
END
ELSE
BEGIN
	IF @ToMonth < 10
		SET	@EndDate = CAST(@ToYear AS NVARCHAR) + N'0' + CAST(@ToMonth AS NVARCHAR) + N'01'
	ELSE
		SET	@EndDate = CAST(@ToYear AS NVARCHAR) + CAST(@ToMonth AS NVARCHAR) + N'01'
	
	SET	@EndDate = DATEADD(MONTH, 1, @EndDate)
END


/*Vet Sanitary Aggregate Matrix that was activated and has the latest Activation Start Date
* , which belongs to the period between first date of the year specified in From Year filter 
* and last date of the year specified in To Year filter, among all activated Vet Sanitary Aggregate Matrices 
* with Activation Start Date belonging to the same period
*/
DECLARE @idfSanitaryVersion BIGINT 

SELECT
	@idfSanitaryVersion = tamvh.idfVersion
FROM dbo.tlbAggrMatrixVersionHeader tamvh
WHERE tamvh.blnIsActive = 1
	AND tamvh.intRowStatus = 0
	AND tamvh.datStartDate BETWEEN @StartDate AND @EndDate
	AND tamvh.idfsMatrixType = @idfsMatrixType
	AND NOT EXISTS (SELECT
						1
					FROM dbo.tlbAggrMatrixVersionHeader tamvh2
					WHERE tamvh2.blnIsActive = 1
						AND tamvh2.intRowStatus = 0
						AND tamvh2.datStartDate BETWEEN @StartDate AND @EndDate
						AND (tamvh2.datStartDate > tamvh.datStartDate
							OR(tamvh2.datStartDate = tamvh.datStartDate AND tamvh2.idfVersion > tamvh.idfVersion)
							)
						AND tamvh2.idfsMatrixType = 71260000000 /*Veterinary-sanitary measures*/)

-- Select report informative part - start
DECLARE	@attr_part_in_report			BIGINT

SELECT	@attr_part_in_report = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'attr_part_in_report'


DECLARE	@Sanitary_Number_of_facilities	BIGINT
DECLARE	@Sanitary_Area					BIGINT
DECLARE	@Sanitary_Note					BIGINT

-- Sanitary_Number_of_facilities
SELECT		@Sanitary_Number_of_facilities = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Sanitary_Number_of_facilities'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Sanitary_Area
SELECT		@Sanitary_Area = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Sanitary_Area'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Sanitary_Note
SELECT		@Sanitary_Note = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Sanitary_Note'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0


DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM dbo.tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

-- Select aggregate data
DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT


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

SET @AggrCaseType = 10102003 /*Vet Aggregate Action*/

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)

CREATE TABLE	#VetAggregateAction
(	idfAggrCase				BIGINT NOT NULL PRIMARY KEY,
	idfSanitaryObservation	BIGINT,
	datStartDate			DATETIME,
	idfSanitaryVersion		BIGINT
	, idfsRegion BIGINT
	, idfsRayon BIGINT
	, idfsAdministrativeUnit BIGINT
	, datFinishDate DATETIME
)

DECLARE	@idfsCurrentCountry	BIGINT
SELECT	@idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

INSERT INTO	#VetAggregateAction
(	idfAggrCase,
	idfSanitaryObservation,
	datStartDate,
	idfSanitaryVersion
	, idfsRegion
	, idfsRayon
	, idfsAdministrativeUnit
	, datFinishDate
)
SELECT		a.idfAggrCase,
			obs.idfObservation,
			a.datStartDate,
			a.idfSanitaryVersion
			, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
			, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
			, a.idfsAdministrativeUnit
			, a.datFinishDate
FROM		dbo.tlbAggrCase a
INNER JOIN	dbo.tlbObservation obs ON obs.idfObservation = a.idfSanitaryObservation
LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
ON			c.idfsReference = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
ON			r.idfsRegion = a.idfsAdministrativeUnit 
LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
ON			rr.idfsRayon = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
ON			s.idfsSettlement = a.idfsAdministrativeUnit
-- Site, Organization entered aggregate action
INNER JOIN	dbo.tstSite sit
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN sit.intFlags = 10 THEN @SpecificOfficeId ELSE sit.idfOffice END
ON			sit.idfsSite = a.idfsSite
WHERE		a.idfsAggrCaseType = @AggrCaseType
-- Time Period satisfies Report Filters
			AND (	@StartDate <= a.datStartDate
					AND a.datFinishDate < @EndDate
				)
	AND (
			(r.idfsRegion = @RegionID OR @RegionID IS NULL)
			OR (
				(rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
			OR (
				a.idfsAdministrativeUnit = s.idfsSettlement
				AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
				AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
				)
		)	
			-- Entered by organization satisfies Report Filters
			AND (@OrganizationEntered IS NULL or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))
			AND a.intRowStatus = 0

	SELECT	
		@MinAdminLevel = idfsStatisticAreaType
		, @MinTimeInterval = idfsStatisticPeriodType
	FROM report.FN_AggregateSettings_GET (10102003 /*Vet Aggregate Action*/)

	DELETE FROM #VetAggregateAction
	WHERE idfAggrCase IN (
		SELECT
			idfAggrCase
		FROM (
			SELECT 
				COUNT(*) OVER (PARTITION BY ac.idfAggrCase) cnt
				, ac2.idfAggrCase
				, CASE 
					WHEN DATEDIFF(YEAR, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) > 1 
						THEN 10091005 --sptYear
					WHEN DATEDIFF(quarter, ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091003 --sptQuarter
					WHEN DATEDIFF(MONTH, ac2.datStartDate, ac2.datFinishDate) = 0 AND report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091001 --sptMonth
					WHEN report.FN_GBL_WeekDateDiff_GET(ac2.datStartDate, ac2.datFinishDate) = 0 AND DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) > 1
						THEN 10091004 --sptWeek
					WHEN DATEDIFF(DAY, ac2.datStartDate, ac2.datFinishDate) = 0
						THEN 10091002 --sptOnday
				END AS TimeInterval
				, CASE
					WHEN ac2.idfsAdministrativeUnit = c2.idfsReference THEN 10089001 --satCountry
					WHEN ac2.idfsAdministrativeUnit = r2.idfsRegion THEN 10089003 --satRegion
					WHEN ac2.idfsAdministrativeUnit = rr2.idfsRayon THEN 10089002 --satRayon
					WHEN ac2.idfsAdministrativeUnit = s2.idfsSettlement THEN 10089004 --satSettlement
				END AS AdminLevel
			FROM #VetAggregateAction ac
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
			ON			c.idfsReference = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
			ON			r.idfsRegion = ac.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
			ON			rr.idfsRayon = ac.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
			ON			s.idfsSettlement = ac.idfsAdministrativeUnit
			JOIN #VetAggregateAction ac2 ON
				(
					ac2.datStartDate BETWEEN ac.datStartDate AND ac.datFinishDate
					OR ac2.datFinishDate BETWEEN ac.datStartDate AND ac.datFinishDate
				)
			LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c2
			ON			c2.idfsReference = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r2
			ON			r2.idfsRegion = ac2.idfsAdministrativeUnit 
			LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr2
			ON			rr2.idfsRayon = ac2.idfsAdministrativeUnit
			LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s2
			ON			s2.idfsSettlement = ac2.idfsAdministrativeUnit
			WHERE COALESCE(s2.idfsRayon, rr2.idfsRayon) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsRegion, rr2.idfsRegion, r2.idfsRegion) = ac.idfsAdministrativeUnit
				OR COALESCE(s2.idfsCountry, rr2.idfsCountry, r2.idfsCountry, c2.idfsReference) = ac.idfsAdministrativeUnit
		) a
		WHERE cnt > 1	
			AND CASE WHEN TimeInterval = @MinTimeInterval AND AdminLevel = @MinAdminLevel THEN 1 ELSE 0 END = 0
	)

DECLARE	@VetAggregateActionData	table
(	strKey						NVARCHAR(200) COLLATE database_default NOT NULL PRIMARY KEY,
	idfsSanitaryActiON			BIGINT NOT NULL,
	strMeasureName				NVARCHAR(2000) COLLATE database_default NULL,
	intNumberFacilities			INT NULL,
	intSquare					FLOAT NULL,
	strNote						NVARCHAR(2000) COLLATE database_default NULL,
	SanitaryMeasureOrderColumn	INT NULL,
	MTXOrderColumn				INT NULL
)

DECLARE @NotDeletedAggregateSanitaryAction TABLE (
	[name] NVARCHAR(500)
	, idfsSanitaryAction BIGINT
	, intOrder INT
	, rn INT
)

INSERT INTO @NotDeletedAggregateSanitaryAction
SELECT
	r_sm_actual.[name]
	, r_sm_actual.idfsReference AS idfsSanitaryAction
	, r_sm_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_sm_actual.[name] ORDER BY r_sm_actual.idfsReference) AS rn
FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000079) r_sm_actual /*Sanitary Measure List*/

INSERT INTO	@VetAggregateActionData
(	strKey,
	idfsSanitaryAction,
	strMeasureName,
	intNumberFacilities,
	intSquare,
	strNote,
	SanitaryMeasureOrderColumn,
	MTXOrderColumn
)
SELECT		CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20)) AS strKey,
			ISNULL(Actual_Measure_Name.idfsSanitaryAction, mtx.idfsSanitaryAction) AS idfsSanitaryAction,
			ISNULL(r_sm.[name], N'') AS strMeasureName,
			SUM(ISNULL(CAST(Sanitary_Number_of_facilities.varValue AS INT), 0)) AS intNumberFacilities,
			SUM(ISNULL(CAST(Sanitary_Area.varValue AS FLOAT), 0.00)) AS intSquare,
			MAX(left(ISNULL(CAST(Sanitary_Note.varValue AS NVARCHAR), N''), 2000)) AS strNote,
			ISNULL(Actual_Measure_Name.intOrder, ISNULL(r_sm.intOrder, -1000)) AS SanitaryMeasureOrderColumn,
			ISNULL(mtx.intNumRow, -1000) AS MTXOrderColumn

FROM		#VetAggregateAction vaa
-- Matrix version
INNER JOIN	dbo.tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = @idfsMatrixType
			AND (	-- Get matrix version selected by the user in aggregate action
					h.idfVersion = vaa.idfSanitaryVersion
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate action start date
					OR (	vaa.idfSanitaryVersion IS NULL 
							AND h.idfVersion = @idfSanitaryVersion
						)
				)
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	dbo.tlbAggrSanitaryActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Measure Name
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000079) r_sm /*Sanitary Measure List*/
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateSanitaryAction AS Actual_Measure_Name ON
		Actual_Measure_Name.[name] = r_sm.[name] COLLATE Cyrillic_General_CI_AS
		AND Actual_Measure_Name.rn = 1
ON			r_sm.idfsReference = mtx.idfsSanitaryAction

-- Number_of_facilities
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfSanitaryObservation
 			AND ap.idfRow = mtx.idfAggrSanitaryActionMTX
			AND ap.idfsParameter = @Sanitary_Number_of_facilities
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfActivityParameters ASC
 		) AS  Sanitary_Number_of_facilities

-- Area
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfSanitaryObservation
 			AND ap.idfRow = mtx.idfAggrSanitaryActionMTX
			AND ap.idfsParameter = @Sanitary_Area
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfActivityParameters ASC
 		) AS  Sanitary_Area

-- Note
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfSanitaryObservation
 			AND ap.idfRow = mtx.idfAggrSanitaryActionMTX
			AND ap.idfsParameter = @Sanitary_Note
			AND ap.intRowStatus = 0
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfActivityParameters ASC
 		) AS  Sanitary_Note

GROUP BY	CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20)),
			ISNULL(Actual_Measure_Name.idfsSanitaryAction, mtx.idfsSanitaryAction),
			ISNULL(r_sm.[name], N''),
			ISNULL(Actual_Measure_Name.intOrder, ISNULL(r_sm.intOrder, -1000)),
			ISNULL(mtx.intNumRow, -1000)
/*Condition is not included in the report specification
-- Do not include the rows with Number of facilities = 0 in the report
having		sum(ISNULL(CAST(Sanitary_Number_of_facilities.varValue AS int), 0)) > 0
*/

DECLARE @NotDeletedAggregateSanitaryActionWithoutData TABLE (
	[name] NVARCHAR(500)
	, idfsSanitaryAction BIGINT
	, intOrder INT
	, rn INT
)

INSERT INTO @NotDeletedAggregateSanitaryActionWithoutData
SELECT
	r_sm_actual.[name]
	, r_sm_actual.idfsReference AS idfsSanitaryAction
	, r_sm_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_sm_actual.[name] ORDER BY r_sm_actual.idfsReference) AS rn
FROM dbo.FN_GBL_Reference_GETList (@LangID, 19000079) r_sm_actual /*Sanitary Measure List*/

-- Return all measures even witout FF values
INSERT INTO	@VetAggregateActionData
(	strKey,
	idfsSanitaryAction,
	strMeasureName,
	intNumberFacilities,
	intSquare,
	strNote,
	SanitaryMeasureOrderColumn,
	MTXOrderColumn
)
SELECT		CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20)) AS strKey,
			ISNULL(Actual_Measure_Name.idfsSanitaryAction, mtx.idfsSanitaryAction) AS idfsSanitaryAction,
			ISNULL(r_sm.[name], N'') AS strMeasureName,
			0 AS intNumberFacilities,
			CAST(0 AS FLOAT) AS intSquare,
			N'' AS strNote,
			ISNULL(Actual_Measure_Name.intOrder, ISNULL(r_sm.intOrder, -1000)) AS SanitaryMeasureOrderColumn,
			ISNULL(mtx.intNumRow, -1000) AS MTXOrderColumn

FROM		dbo.tlbAggrMatrixVersionHeader h
			
-- Matrix row
INNER JOIN	dbo.tlbAggrSanitaryActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Measure Name
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000079) r_sm /*Sanitary Measure List*/
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateSanitaryActionWithoutData AS Actual_Measure_Name ON
		Actual_Measure_Name.[name] = r_sm.[name] COLLATE Cyrillic_General_CI_AS
		AND Actual_Measure_Name.rn = 1
ON			r_sm.idfsReference = mtx.idfsSanitaryAction
LEFT JOIN	@VetAggregateActionData vaad
ON			vaad.strKey = CAST(ISNULL(Actual_Measure_Name.idfsSanitaryAction, 
								mtx.idfsSanitaryAction) AS NVARCHAR(20))
WHERE		h.idfVersion = @idfSanitaryVersion
			AND vaad.strKey IS NULL

-- Fill result table
INSERT INTO	@Result
(	strKey,
	strMeasureName,
	SanitaryMeasureOrderColumn,
	intNumberFacilities,
	intSquare,
	strNote
)
SELECT		a.strKey,
			a.strMeasureName,
			ISNULL(a.MTXOrderColumn, a.SanitaryMeasureOrderColumn),
			a.intNumberFacilities,
			a.intSquare,
			CASE
				WHEN	@FromYear = @ToYear
						and	@FromMonth = @ToMonth
					THEN	a.strNote
				ELSE	N''
			END
FROM		@VetAggregateActionData a
-- SELECT report informative part - start

-- Return results
IF (SELECT COUNT(*) FROM @result) = 0
	SELECT	CAST('' AS NVARCHAR(200)) AS strKey,
	CAST('' AS NVARCHAR(2000)) AS strMeasureName,
	CAST(NULL AS INT) AS SanitaryMeasureOrderColumn,
	CAST(NULL AS INT) AS intNumberFacilities, 
	CAST(null AS FLOAT) AS intSquare, 
	CAST(null AS NVARCHAR(2000)) AS strNote,
	0 AS blnAdditionalText
ELSE
	SELECT * FROM @result ORDER BY strMeasureName

-- Drop temporary tables
IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

END