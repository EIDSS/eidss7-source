
--*************************************************************************
-- Name 				: report.USP_REP_VET_RBERabiesCasesReportGG
-- Description			: Select data for spRepRBERabiesCasesReportGG report.
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
--
/*
EXEC report.USP_REP_VET_RBERabiesCasesReportGG
@LangID=N'en',
@StartDate='2015-01-01 00:00:00',
@EndDate='2015-12-31 00:00:00'

EXEC report.USP_REP_VET_RBERabiesCasesReportGG
@LangID=N'ka',
@StartDate='2010-07-01 00:00:00',
@EndDate='2016-12-31 00:00:00',
@Regions=N'37030000000,37100000000',
@Rayons=N'3350000000,3340000000'
*/

CREATE PROCEDURE [Report].[USP_REP_VET_RBERabiesCasesReportGG]
    (
          @LangID AS NVARCHAR(10)
        , @StartDate AS DATETIME
 		, @EndDate AS DATETIME
 		, @StartDate2 AS DATETIME = NULL
 		, @EndDate2 AS DATETIME = NULL
		, @Regions AS NVARCHAR(MAX) = NULL
		, @Rayons AS NVARCHAR(MAX) = NULL
		, @UserId AS BIGINT = NULL
		, @UseArchiveData	AS BIT = 0 --if User selected Use Archive Data then 1
    )
AS
BEGIN
	
	DECLARE @Country BIGINT = 780000000 /*Georgia*/
	
	IF @Regions='0' SET @Regions = NULL
	IF @Rayons='0' SET @Rayons = NULL
	
	DECLARE @strLocation NVARCHAR(MAX) = ''
	
	SELECT 
		@strLocation += fgs.name
	FROM dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) fgs
	WHERE fgs.idfsReference = @Country

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
    
-------------------------------------------------------------	
--	DECLARE @iRegions INT
	DECLARE @RegionsTable TABLE (idfsRegion BIGINT)

	INSERT INTO @RegionsTable 
	SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@Regions,1,',')
------------------------------------------------------------	

------------------------------------------------------------
--	DECLARE @iRayons INT
	DECLARE @RayonsTable TABLE (idfsRayon BIGINT)

	INSERT INTO @RayonsTable 
	SELECT CAST([Value] AS BIGINT)FROM report.FN_GBL_SYS_SplitList(@Rayons,1,',')
-----------------------------------------------------------	
	DECLARE @RayonsForLocationsTable TABLE (RegionName NVARCHAR(200), RayonName NVARCHAR(200))
	IF (SELECT COUNT(*) FROM @RegionsTable rt) <> 0 AND (SELECT COUNT(*) FROM @RayonsTable) = 0
	SELECT @strLocation += ', ' +
		STUFF (
				(
					SELECT
						 ', ' + rflt.RegionName
					FROM @RayonsForLocationsTable rflt
					FOR XML PATH (''), TYPE
				).value('.','nvarchar(max)')
		,1,2,'')
	ELSE IF (SELECT COUNT(*) FROM @RegionsTable rt) <> 0 AND (SELECT COUNT(*) FROM @RayonsTable) <> 0
	SELECT @strLocation += ', ' +
		STUFF (
				(
					SELECT
						 '; ' + rflt.RegionName + CASE WHEN rflt.RayonName <> '' THEN ', ' + rflt.RayonName ELSE '' END
					FROM @RayonsForLocationsTable rflt
					FOR XML PATH (''), TYPE
				).value('.','nvarchar(max)')
		,1,2,'')
	
	--SELECT @strLocation	
	
	IF (SELECT COUNT(*) FROM @RegionsTable) = 0
	INSERT INTO @RegionsTable
	SELECT DISTINCT
		gr.idfsRegion
	FROM @gisRayon gr
	WHERE gr.idfsCountry = @Country
	
	INSERT INTO @RayonsTable
	SELECT DISTINCT
		gr.idfsRayon
	FROM @gisRayon gr
	JOIN @RegionsTable regt ON regt.idfsRegion = gr.idfsRegion
	WHERE gr.idfsCountry = @Country
		AND NOT EXISTS (
						SELECT 
							*
						FROM @gisRayon gr2
						JOIN @RayonsTable rt ON	rt.idfsRayon = gr2.idfsRayon
						WHERE gr2.idfsRegion = gr.idfsRegion
						)
	
	DECLARE @FilteredRayons AS TABLE (idfsRayon BIGINT PRIMARY KEY)
	INSERT INTO @FilteredRayons (idfsRayon)
	SELECT 
		gr.idfsRayon
	FROM @gisRayon gr
	JOIN @RegionsTable r1 ON r1.idfsRegion = gr.idfsRegion
	JOIN @RayonsTable r2 ON r2.idfsRayon = gr.idfsRayon
	WHERE gr.idfsCountry = @Country


	DECLARE @FromDate DATETIME 
		, @ToDate DATETIME
		, @FromDate2 DATETIME = NULL
		, @ToDate2 DATETIME = NULL
	
	SET @FromDate = dbo.fn_SetMinMaxTime(@StartDate,0)
	SET @ToDate = dbo.fn_SetMinMaxTime(@EndDate,1)
	
	SET @FromDate2 = dbo.fn_SetMinMaxTime(@StartDate2,0)
	SET @ToDate2 = dbo.fn_SetMinMaxTime(@EndDate2,1)
	
		
	DECLARE @strReportingPerson NVARCHAR(200)
	SELECT
		@strReportingPerson = tp.strFirstName + '/' + tp.strFamilyName
	FROM tlbPerson tp
	JOIN tstUserTable tut ON
		tut.idfPerson = tp.idfPerson
	WHERE tut.idfUserID = @UserId
		
	DECLARE @strInstitution NVARCHAR(200)
	SELECT
		@strInstitution = fr.name
	FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000046 /*Organization Name*/) fr
	JOIN tlbOffice to1 ON
		to1.idfsOfficeName = fr.idfsReference
	JOIN tlbPerson tp ON
		tp.idfInstitution = to1.idfOffice
	JOIN tstUserTable tut ON
		tut.idfPerson = tp.idfPerson
	WHERE tut.idfUserID = @UserId
	
	DECLARE @idfsSummaryReportType BIGINT		
	SET @idfsSummaryReportType = 10290028 /*RBE - Quarterly Surveillance Sheet*/
	
	DECLARE @idfsReportDiagnosisGroup BIGINT		
	SELECT 
		@idfsReportDiagnosisGroup = trdg.idfsReportDiagnosisGroup
	FROM trtReportDiagnosisGroup trdg
	WHERE trdg.strDiagnosisGroupAlias = N'Rabies Group'
		
	
	DECLARE @Result AS TABLE
	(
		intRowNumber					NVARCHAR(36) NOT NULL PRIMARY KEY,
		datDate							DATETIME NULL,
		strArea							NVARCHAR(200) NULL,
		intDomesticDog					INT NULL,
		intDomesticCat					INT NULL,
		intDomesticCattle				INT NULL,
		intDomesticEquine				INT NULL,
		intDomesticSheep				INT NULL,
		intDomesticGoat					INT NULL,
		intDomesticPig					INT NULL,
		intDomesticStrayDog				INT NULL,
		intDomesticOther				INT NULL,
		intDomesticUnspecified			INT NULL,
		intWildlifeFox					INT NULL,
		intWildlifeRaccoonDog			INT NULL,
		intWildlifeRaccoon				INT NULL,
		intWildlifeWolf					INT NULL,
		intWildlifeBadger				INT NULL,
		intWildlifeMarten				INT NULL,
		intWildlifeOtherMustelides		INT NULL,
		intWildlifeOtherCarnivores		INT NULL,
		intWildlifeWildBoar				INT NULL,
		intWildlifeRoeDeer				INT NULL,
		intWildlifeRedDeer				INT NULL,
		intWildlifeFallowDeer			INT NULL,
		intWildlifeOther				INT NULL,
		intWildlifeBat					INT NULL,
		intWildlifeUnspecified			INT NULL,
		intHumanCases					INT NULL,	
		dblLongitude					FLOAT NULL,
		dblLatitude						FLOAT NULL,
		strReportingPerson				NVARCHAR(200),
		strInstitution					NVARCHAR(200),
		strLocation						NVARCHAR(2000)
	)
	
	
;

WITH TestRabiesFluorescence AS (
	SELECT
		tt.idfMaterial
		, MIN(tt.datConcludedDate) AS TestResultDate
	FROM tlbTesting tt
	JOIN trtTestTypeForCustomReport tttfcr ON
		tttfcr.idfsTestName = tt.idfsTestName
		AND tttfcr.intRowOrder = 1 /*Rabies fluorescence*/
		AND tttfcr.idfsCustomReportType = @idfsSummaryReportType
	JOIN trtBaseReference tbr_testresult ON
		tbr_testresult.idfsBaseReference = tt.idfsTestResult
		AND tbr_testresult.idfsReferenceType = 19000096
		AND tbr_testresult.strDefault = 'Positive'
	WHERE tt.idfsTestStatus IN (10001001/*Final*/, 10001006/*Amended*/)	
	GROUP BY tt.idfMaterial
)
, TestBioassays AS (
	SELECT
		tt.idfMaterial
		, MIN(tt.datConcludedDate) AS TestResultDate
	FROM tlbTesting tt
	JOIN trtTestTypeForCustomReport tttfcr ON
		tttfcr.idfsTestName = tt.idfsTestName
		AND tttfcr.intRowOrder = 2 /*Bioassays*/
		AND tttfcr.idfsCustomReportType = @idfsSummaryReportType
	JOIN trtBaseReference tbr_testresult ON
		tbr_testresult.idfsBaseReference = tt.idfsTestResult
		AND tbr_testresult.idfsReferenceType = 19000096
		AND tbr_testresult.strDefault = 'Positive'
	WHERE tt.idfsTestStatus IN (10001001/*Final*/, 10001006/*Amended*/)	
	GROUP BY tt.idfMaterial
)
, SpeciesAndGroups AS (
	SELECT 
		ISNULL(tstgfcr.idfsSpeciesGroup, 0) AS SpeciesGroupId
		, ISNULL(tbr_specname.idfsBaseReference, 0) AS SpeciesTypeId
		, tscicr.intItemOrder AS ColumnNumber
	FROM trtSpeciesContentInCustomReport tscicr
	LEFT JOIN trtSpeciesGroup tsg 
		JOIN trtSpeciesToGroupForCustomReport tstgfcr ON
			tstgfcr.idfsSpeciesGroup = tsg.idfsSpeciesGroup
			AND tstgfcr.idfsCustomReportType = @idfsSummaryReportType
			AND tstgfcr.intRowStatus = 0
	ON tsg.idfsSpeciesGroup = tscicr.idfsSpeciesOrSpeciesGroup
		AND tsg.intRowStatus = 0
		
	JOIN trtBaseReference tbr_specname ON
		tbr_specname.idfsBaseReference = ISNULL(tstgfcr.idfsSpeciesType, tscicr.idfsSpeciesOrSpeciesGroup)
		AND tbr_specname.idfsReferenceType = 19000086
		AND tbr_specname.intRowStatus = 0
		
	WHERE (tscicr.intRowStatus = 0 OR tscicr.intRowStatus IS NULL)
		AND (tscicr.idfsCustomReportType = @idfsSummaryReportType OR tscicr.idfsCustomReportType IS NULL)
)
, VetCases AS (
	SELECT DISTINCT
		sag.ColumnNumber
		, COALESCE(trf.TestResultDate, tb.TestResultDate)		AS datDate
		, ref_Region.name + '/' + ref_Rayon.name				AS strArea
		, CASE 
			WHEN ts_a.idfsSpeciesType = sag.SpeciesTypeId 
				THEN 1
			ELSE NULL 
		  END													AS SpeciesColumn
		, NULL													AS HumanCases
		, tgl.dblLongitude										AS Longitude
		, tgl.dblLatitude										AS Latitude
		, @strReportingPerson									AS ReportingPerson
		, @strInstitution										AS Institution
		, ta.idfAnimal											AS AnimalSpecies
	FROM tlbVetCase tvc
	JOIN trtDiagnosisToGroupForReportType tt ON
		tt.idfsCustomReportType = @idfsSummaryReportType
		AND tt.idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
		AND tt.idfsDiagnosis = tvc.idfsShowDiagnosis
	JOIN tlbFarm tf ON
		tf.idfFarm = tvc.idfFarm
		AND tf.intRowStatus = 0
	JOIN tlbGeoLocation tgl ON
		tgl.idfGeoLocation = tf.idfFarmAddress
		AND tgl.intRowStatus = 0
	JOIN @FilteredRayons fr ON
		fr.idfsRayon = tgl.idfsRayon
	JOIN FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS ref_Region ON
		ref_Region.idfsReference = tgl.idfsRegion
	JOIN FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS ref_Rayon ON
		ref_Rayon.idfsReference = tgl.idfsRayon	
	JOIN tlbMaterial tm ON
		tm.idfVetCase = tvc.idfVetCase
		AND tm.intRowStatus = 0
			
	JOIN tlbAnimal ta 
		JOIN tlbSpecies ts_a ON
			ts_a.idfSpecies = ta.idfSpecies
			AND ts_a.intRowStatus = 0
	ON ta.idfAnimal = tm.idfAnimal
		AND ta.intRowStatus = 0
	
	LEFT JOIN TestRabiesFluorescence trf ON
		trf.idfMaterial = tm.idfMaterial
	LEFT JOIN TestBioassays tb ON
		tb.idfMaterial = tm.idfMaterial
		
	CROSS JOIN SpeciesAndGroups sag
	
	WHERE tvc.idfsCaseClassification = 350000000 /*Confirmed Case*/
		AND tvc.intRowStatus = 0
		AND tvc.idfsCaseType = 10012003 /*Livestock*/
		AND COALESCE(trf.TestResultDate, tb.TestResultDate, 0) <> 0
		AND (COALESCE(trf.TestResultDate, tb.TestResultDate) BETWEEN @FromDate AND @EndDate	
				OR (@FromDate2 IS NOT NULL AND @EndDate2 IS NOT NULL 
						AND COALESCE(trf.TestResultDate, tb.TestResultDate) BETWEEN @FromDate2 AND @EndDate2)
			)
)
, GroupVetCases AS (
	SELECT
		ColumnNumber
		, datDate				AS datDate
		, strArea				AS strArea
		, MAX(SpeciesColumn)	AS SpeciesColumn
		, NULL					AS HumanCases
		, Longitude				AS Longitude
		, Latitude				AS Latitude
		, ReportingPerson		AS ReportingPerson
		, Institution			AS Institution
	FROM VetCases
	GROUP BY ColumnNumber, datDate, strArea, Longitude, Latitude, ReportingPerson, Institution	
)

	
	INSERT INTO @Result
	(
		intRowNumber,
		datDate,
		strArea,
		intDomesticDog,
		intDomesticCat,
		intDomesticCattle,
		intDomesticEquine,
		intDomesticSheep,
		intDomesticGoat,
		intDomesticPig,
		intDomesticStrayDog,
		intDomesticOther,
		intDomesticUnspecified,
		intWildlifeFox,
		intWildlifeRaccoonDog,
		intWildlifeRaccoon,
		intWildlifeWolf,
		intWildlifeBadger,
		intWildlifeMarten,
		intWildlifeOtherMustelides,
		intWildlifeOtherCarnivores,
		intWildlifeWildBoar,
		intWildlifeRoeDeer,
		intWildlifeRedDeer,
		intWildlifeFallowDeer,
		intWildlifeOther,
		intWildlifeBat,
		intWildlifeUnspecified,
		intHumanCases,
		dblLongitude,
		dblLatitude,
		strReportingPerson,
		strInstitution,
		strLocation
	)
	
	SELECT 
		NEWID(),
		datDate,
		strArea,
		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],
		HumanCases,
		Longitude,
		Latitude,
		ReportingPerson,
		Institution,
		@strLocation
	FROM GroupVetCases
	PIVOT (MAX(SpeciesColumn) for ColumnNumber IN (
			[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])) AS pvt

	UNION ALL
	
	SELECT
		NEWID()
		, COALESCE(thc.datOnSetDate, thc.datFinalDiagnosisDate, thc.datTentativeDiagnosisDate, thc.datNotificationDate
					, thc.datEnteredDate, 0)									AS datDate
		, ref_Region.name + '/' + ref_Rayon.name								AS strArea
		, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
		, 1																		AS HumanCases
		, ISNULL(tgl_Point.dblLongitude, tgl_CurrentResidence.dblLongitude)		AS Longitude
		, ISNULL(tgl_Point.dblLatitude, tgl_CurrentResidence.dblLatitude)		AS Latitude
		, @strReportingPerson													AS ReportingPerson
		, @strInstitution														AS Institution
		, @strLocation															AS strLocation
	FROM tlbHumanCase thc
	JOIN trtDiagnosisToGroupForReportType tt ON
		tt.idfsCustomReportType = @idfsSummaryReportType
		AND tt.idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
		AND tt.idfsDiagnosis = COALESCE(thc.idfsFinalDiagnosis, thc.idfsTentativeDiagnosis)
	JOIN tlbHuman th ON
		th.idfHuman = thc.idfHuman
		AND th.intRowStatus = 0
	LEFT JOIN tlbGeoLocation tgl_Point ON
		tgl_Point.idfGeoLocation = thc.idfPointGeoLocation
		AND tgl_Point.intRowStatus = 0
	LEFT JOIN tlbGeoLocation tgl_CurrentResidence ON
		tgl_CurrentResidence.idfGeoLocation = th.idfCurrentResidenceAddress
		AND tgl_CurrentResidence.intRowStatus = 0
	JOIN FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS ref_Region ON
		ref_Region.idfsReference = ISNULL(tgl_Point.idfsRegion, tgl_CurrentResidence.idfsRegion)
	JOIN FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS ref_Rayon ON
		ref_Rayon.idfsReference = ISNULL(tgl_Point.idfsRayon, tgl_CurrentResidence.idfsRayon)
	JOIN @FilteredRayons fr ON
		fr.idfsRayon = ref_Rayon.idfsReference
		
	WHERE COALESCE(thc.idfsFinalCaseStatus, thc.idfsInitialCaseStatus) = 350000000 /*Confirmed Case*/
		AND thc.intRowStatus = 0		
		AND COALESCE(thc.datOnSetDate, thc.datFinalDiagnosisDate, thc.datTentativeDiagnosisDate, thc.datNotificationDate, thc.datEnteredDate, 0) <> 0
		AND (COALESCE(thc.datOnSetDate, thc.datFinalDiagnosisDate, thc.datTentativeDiagnosisDate, thc.datNotificationDate
			, thc.datEnteredDate) BETWEEN @FromDate AND @EndDate
				OR (@FromDate2 IS NOT NULL AND @EndDate2 IS NOT NULL 
						AND COALESCE(thc.datOnSetDate, thc.datFinalDiagnosisDate, thc.datTentativeDiagnosisDate, thc.datNotificationDate
								, thc.datEnteredDate) BETWEEN @FromDate2 AND @EndDate2)
		
			)	

	
	
	IF (SELECT COUNT(*) FROM @Result) = 0
	INSERT INTO @Result
	(
		intRowNumber,
		strReportingPerson,
		strInstitution,
		strLocation
	)
	SELECT
		NEWID()
		, @strReportingPerson
		, @strInstitution
		, @strLocation
	
	
	
	
	SELECT 
		* 
	FROM @Result r
	ORDER BY r.datDate, r.strArea
	
END

