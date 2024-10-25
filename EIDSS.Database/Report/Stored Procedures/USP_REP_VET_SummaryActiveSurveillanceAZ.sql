--*************************************************************************
-- Name: report.USP_REP_VET_SummaryActiveSurveillanceAZ
-- Description: Used in Summary Veterinary Report For Active Surveillance
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_SummaryActiveSurveillanceAZ 
'en', 
N'2016-01-01T00:00:00',
N'2018-11-30T00:00:00',
7718730000000,
'49558320000000,7722710000000'


EXEC report.USP_REP_VET_SummaryActiveSurveillanceAZ 
'en', 
N'2016-01-01T00:00:00',
N'2016-12-31T00:00:00',
7718730000000,
49558320000000
--'<ItemList><Item key="49558320000000" value=""/></ItemList>'

*/ 
CREATE PROCEDURE [Report].[USP_REP_VET_SummaryActiveSurveillanceAZ]
(
	 @LangID			AS NVARCHAR(50),
	 @SD				AS DATETIME, 
	 @ED				AS DATETIME,
	 @Diagnosis			AS BIGINT,
	 @SpeciesType		AS NVARCHAR(MAX),
	 @InvestigationOrMeasureType BIGINT = NULL
)
AS

	DECLARE @SDDate AS DATETIME
	DECLARE @EDDate AS DATETIME
	DECLARE @CountryID BIGINT
	DECLARE @iSpeciesType INT
	
	DECLARE @idfsRegionBaku BIGINT,
		@idfsRegionOtherRayons BIGINT,
		@idfsRegionNakhichevanAR BIGINT
		
		
	DECLARE @sql AS NVARCHAR (MAX) = ''

	
	SET @SDDate=dbo.fn_SetMinMaxTime(CAST(@SD AS DATETIME),0)
	SET @EDDate=dbo.fn_SetMinMaxTime(CAST(@ED AS DATETIME),1)
	
	SET @CountryID = 170000000
				

	DECLARE @SpeciesTypeTable	TABLE
		(
			[key]  NVARCHAR(300)			
		)	
	
	INSERT INTO @SpeciesTypeTable 
 	SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@SpeciesType,1,',')

	--1344330000000 --Baku
	SELECT
		@idfsRegionBaku = fgr.idfsReference
	FROM dbo.FN_GBL_GIS_Reference('en', 19000003) fgr
	WHERE fgr.name = N'Baku'

	--1344340000000 --Other rayons
	SELECT
		@idfsRegionOtherRayons = fgr.idfsReference
	FROM dbo.FN_GBL_GIS_Reference('en', 19000003) fgr
	WHERE fgr.name = N'Other rayons'

	--1344350000000 --Nakhichevan AR
	SELECT
		@idfsRegionNakhichevanAR = fgr.idfsReference
	FROM dbo.FN_GBL_GIS_Reference('en', 19000003) fgr
	WHERE fgr.name = N'Nakhichevan AR'  
	
	
	DECLARE @vet_form_1_use_specific_gis BIGINT 
	DECLARE @vet_form_1_specific_gis_region BIGINT 
	DECLARE @vet_form_1_specific_gis_rayon BIGINT
	DECLARE @attr_part_in_report BIGINT 

	SELECT 
		@vet_form_1_use_specific_gis = at.idfAttributeType
	FROM trtAttributeType at
	WHERE at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

	SELECT 
		@vet_form_1_specific_gis_region = at.idfAttributeType
	FROM trtAttributeType at
	WHERE at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

	SELECT 
		@vet_form_1_specific_gis_rayon = at.idfAttributeType
	FROM trtAttributeType at
	WHERE at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'
	
	SELECT
		@attr_part_in_report = at.idfAttributeType
	FROM	trtAttributeType at
	WHERE	at.strAttributeTypeName = N'attr_part_in_report'
	
	
	

DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary TABLEs
IF Object_ID('tempdb..#MonitoringSession') is NOT NULL
BEGIN
	SET	@drop_cmd = N'drop TABLE #MonitoringSession'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#MaterialCnt') is NOT NULL
BEGIN
	SET	@drop_cmd = N'drop TABLE #MaterialCnt'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#TestCnt') is NOT NULL
BEGIN
	SET	@drop_cmd = N'drop TABLE #TestCnt'
	EXECUTE sp_executesql @drop_cmd
END

	

	CREATE TABLE #MonitoringSession (
		idfMonitoringSession BIGINT
		, idfsRegion BIGINT
		, idfsRayon BIGINT
	)
		
	INSERT INTO #MonitoringSession
	SELECT DISTINCT 
		tms.idfMonitoringSession
		, ISNULL(reg_specific.idfsReference, tms.idfsRegion)
		, ISNULL(ray_specific.idfsReference, tms.idfsRayon)
	FROM dbo.tlbMonitoringSession tms
	
	-- Site, Organization entered case
	JOIN dbo.tstSite s
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) i ON
			i.idfOffice = s.idfOffice
	ON s.idfsSite = tms.idfsSite
		-- Specific Region and Rayon for the site with specific attributes (B46)
	LEFT JOIN dbo.trtBaseReferenceAttribute bra
		LEFT JOIN dbo.trtGISBaseReferenceAttribute gis_bra_region
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific ON
				reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
		ON CAST(gis_bra_region.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
			AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
		LEFT JOIN dbo.trtGISBaseReferenceAttribute gis_bra_rayon
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific ON
				ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference 
		ON CAST(gis_bra_rayon.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
			AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
	ON bra.idfsBaseReference = i.idfsOfficeAbbreviation
		AND bra.idfAttributeType = @vet_form_1_use_specific_gis
		AND CAST(bra.varValue AS NVARCHAR) = s.strSiteID			
		
	WHERE tms.intRowStatus = 0
		AND tms.datStartDate IS NOT NULL
		AND ISNULL(tms.datEndDate, tms.datStartDate) BETWEEN @SDDate AND @EDDate

	DECLARE	@NotDeletedDiagnosis TABLE
	(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
		[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
		idfsActualDiagnosis	BIGINT NOT NULL
	)
	
	INSERT INTO	@NotDeletedDiagnosis
	(	idfsDiagnosis,
		[name],
		idfsActualDiagnosis
	)
	SELECT
		r_d.idfsReference AS idfsDiagnosis
		, r_d.[name] AS [name]
		, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
	LEFT JOIN	(
		SELECT	d_actual.idfsDiagnosis,
				r_d_actual.[name],
				ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
		FROM		dbo.trtDiagnosis d_actual
		INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000019) r_d_actual
		ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
		WHERE		d_actual.idfsUsingType = 10020001	/*Case-based*/
					AND d_actual.intRowStatus = 0
				) actual_diagnosis
		ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
				AND actual_diagnosis.rn = 1
	WHERE	ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) = @Diagnosis

	DECLARE	@NotDeletedSpecies TABLE
	(	idfsSpeciesType			BIGINT NOT NULL PRIMARY KEY,
		[name]					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
		idfsActualSpeciesType	BIGINT NOT NULL
	)

	INSERT INTO	@NotDeletedSpecies
	(	idfsSpeciesType,
		[name],
		idfsActualSpeciesType
	)
		SELECT
			r_sp.idfsReference AS idfsSpeciesType
			, CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
			, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
		FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
		LEFT JOIN	(
			SELECT	st_actual.idfsSpeciesType,
					r_st_actual.[name],
					ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
			FROM		dbo.trtSpeciesType st_actual
			INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000086) r_st_actual
			ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
			WHERE		st_actual.intRowStatus = 0
				) actual_SpeciesType
		ON		actual_SpeciesType.[name] = r_sp.[name] COLLATE Cyrillic_General_CI_AS
				AND actual_SpeciesType.rn = 1
		INNER JOIN	@SpeciesTypeTable stt
		ON			stt.[key] = ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference)


	CREATE TABLE #MaterialCnt (
		idfMonitoringSession BIGINT
		, idfsSpeciesType BIGINT
		, idfAnimalCount INT
	)
	
	INSERT INTO #MaterialCnt
	SELECT
		tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType
		, COUNT(DISTINCT ta.idfAnimal) cnt
	FROM dbo.tlbMaterial tm
	JOIN #MonitoringSession ms ON
		ms.idfMonitoringSession = tm.idfMonitoringSession
	JOIN dbo.tlbAnimal ta ON
		ta.idfAnimal = tm.idfAnimal
		AND ta.intRowStatus = 0
	JOIN dbo.tlbSpecies ts ON
		ts.idfSpecies = ta.idfSpecies
		AND ts.intRowStatus = 0

	JOIN @NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = ts.idfsSpeciesType

	WHERE tm.intRowStatus = 0
			AND tm.datFieldCollectionDate IS NOT NULL
			AND tm.intRowStatus = 0
			AND tm.idfsSampleType <> 10320001	/*Unknown*/
			AND tm.datFieldCollectionDate is NOT NULL

			AND EXISTS	(
					SELECT TOP 1 1
					FROM	dbo.tlbMonitoringSessionToDiagnosis ms_to_d

					JOIN	@NotDeletedDiagnosis AS Actual_Diagnosis ON
						Actual_Diagnosis.idfsDiagnosis = ms_to_d.idfsDiagnosis

					WHERE	ms_to_d.idfMonitoringSession = ms.idfMonitoringSession
							AND ms_to_d.intRowStatus = 0
							AND ms_to_d.idfsSpeciesType = ts.idfsSpeciesType
							AND (	ms_to_d.idfsSampleType is null
									or	(	ms_to_d.idfsSampleType is NOT NULL
											AND ms_to_d.idfsSampleType = tm.idfsSampleType
										)
								)
						)
	GROUP BY tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType


	CREATE TABLE #TestCnt (
		idfMonitoringSession BIGINT
		, idfsSpeciesType BIGINT
		, idfAnimalCount INT
	)


	INSERT INTO #TestCnt
	SELECT
		tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType
		, COUNT(DISTINCT ta.idfAnimal) cnt
	FROM dbo.tlbTesting tt
	JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000001) ref_teststatus ON
		ref_teststatus.idfsReference = tt.idfsTestStatus
	JOIN dbo.tlbMaterial tm ON
		tm.idfMaterial = tt.idfMaterial
		AND tm.intRowStatus = 0
		AND tm.datFieldCollectionDate IS NOT NULL
		AND tm.intRowStatus = 0
		AND tm.idfsSampleType <> 10320001	/*Unknown*/
		AND tm.datFieldCollectionDate is NOT NULL
	JOIN #MonitoringSession ms ON
		ms.idfMonitoringSession = tm.idfMonitoringSession
	JOIN dbo.tlbAnimal ta ON
		ta.idfAnimal = tm.idfAnimal
		AND ta.intRowStatus = 0
	JOIN dbo.tlbSpecies ts ON
		ts.idfSpecies = ta.idfSpecies
		AND ts.intRowStatus = 0

	JOIN @NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = ts.idfsSpeciesType
	WHERE tt.idfsDiagnosis = @Diagnosis
		AND ref_teststatus.idfsReference IN (10001001, 10001006)  /*Final, Amended*/
		AND tt.intRowStatus = 0
		AND isnull(tt.blnExternalTest, 0) = 0
		AND EXISTS	(
				SELECT TOP 1 1
				FROM	dbo.trtTestTypeToTestResult tttttr
				WHERE	tttttr.idfsTestName = tt.idfsTestName
						AND tttttr.idfsTestResult = tt.idfsTestResult
						AND tttttr.intRowStatus = 0
						AND tttttr.blnIndicative = 1
					)
	
			AND EXISTS	(
					SELECT TOP 1 1
					FROM	dbo.tlbMonitoringSessionToDiagnosis ms_to_d

					JOIN	@NotDeletedDiagnosis AS Actual_Diagnosis ON
						Actual_Diagnosis.idfsDiagnosis = ms_to_d.idfsDiagnosis

					WHERE	ms_to_d.idfMonitoringSession = ms.idfMonitoringSession
							AND ms_to_d.intRowStatus = 0
							AND ms_to_d.idfsDiagnosis = tt.idfsDiagnosis
							AND ms_to_d.idfsSpeciesType = ts.idfsSpeciesType
							AND (	ms_to_d.idfsSampleType is null
									OR	(	ms_to_d.idfsSampleType is NOT NULL
											AND ms_to_d.idfsSampleType = tm.idfsSampleType
										)
								)
						)

	GROUP BY tm.idfMonitoringSession
		, Actual_Species_Type.idfsActualSpeciesType
		
		
	CREATE TABLE #ActiveSurveillanceSessions
		(
			idfsRegion BIGINT
			, idfsRayon BIGINT
			, idfsSpeciesType BIGINT
			, CntMaterial INT
			, CntTest INT
		)	

	INSERT INTO #ActiveSurveillanceSessions
	SELECT
		ms.idfsRegion
		, ms.idfsRayon
		, mc.idfsSpeciesType
		, SUM(mc.idfAnimalCount) as CntMaterial
		, SUM(ISNULL(tc.idfAnimalCount, 0)) as CntTest
	FROM #MonitoringSession ms
	JOIN #MaterialCnt mc ON
		mc.idfMonitoringSession = ms.idfMonitoringSession
	LEFT JOIN #TestCnt tc ON
		tc.idfMonitoringSession = ms.idfMonitoringSession
		AND tc.idfsSpeciesType = mc.idfsSpeciesType
	GROUP BY ms.idfsRegion
		, ms.idfsRayon
		, mc.idfsSpeciesType

	SELECT 
		CASE ray.idfsRegion 
			WHEN @idfsRegionBaku THEN 1 
			WHEN @idfsRegionOtherRayons THEN 2
			WHEN @idfsRegionNakhichevanAR THEN 3
			ELSE 0
		END AS intRegionOrder
		,refReg.[name] AS strRegion
		,refRay.[name] AS strRayon
		,ref_spec.[name] AS strSpecies
		,MAX(isnull(ASSessions.CntMaterial,0)) as CntMaterial
		,MAX(isnull(ASSessions.CntTest,0)) as CntTest
	FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
	JOIN FN_GBL_GIS_Reference(@LangID, 19000003 /*rftRegion*/) AS refReg ON
		reg.idfsRegion = refReg.idfsReference			
		AND reg.idfsCountry = @CountryID
	JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray ON 
		ray.idfsRegion = reg.idfsRegion	
	JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*rftRayon*/) AS refRay ON
		ray.idfsRayon = refRay.idfsReference
	LEFT JOIN @SpeciesTypeTable stt ON 1=1
	LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000086) ref_spec ON
		stt.[key] = ref_spec.idfsReference	
	LEFT JOIN #ActiveSurveillanceSessions AS ASSessions ON
		ASSessions.idfsRegion = ray.idfsRegion
		AND ASSessions.idfsRayon = ray.idfsRayon
		AND ASSessions.idfsSpeciesType = ref_spec.idfsReference

	GROUP BY CASE ray.idfsRegion 
				WHEN @idfsRegionBaku THEN 1 
				WHEN @idfsRegionOtherRayons THEN 2
				WHEN @idfsRegionNakhichevanAR THEN 3
				ELSE 0
			END
			,refReg.[name]
			,refRay.[name]
			,ref_spec.[name]
	ORDER BY intRegionOrder, strRayon