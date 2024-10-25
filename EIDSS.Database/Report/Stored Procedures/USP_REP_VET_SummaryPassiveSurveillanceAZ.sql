
--*************************************************************************
-- Name 				: report.USP_REP_VET_SummaryPassiveSurveillanceAZ
-- Description			: Used in Summary Veterinary Report For Passive Surveillance
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_SummaryPassiveSurveillanceAZ 
'ru', 
N'2016-01-01',
N'2016-12-31',
7718730000000,
'7722710000000,49558320000000,7722280000000'
*/ 

CREATE PROCEDURE [Report].[USP_REP_VET_SummaryPassiveSurveillanceAZ]
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

	
	SET @SDDate=report.FN_GBL_MinMaxTime_GET(CAST(@SD AS DATETIME),0)
	SET @EDDate=report.FN_GBL_MinMaxTime_GET(CAST(@ED AS DATETIME),1)
	
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
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) fgr
	WHERE fgr.name = N'Baku'

	--1344340000000 --Other rayons
	SELECT
		@idfsRegionOtherRayons = fgr.idfsReference
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) fgr
	WHERE fgr.name = N'Other rayons'

	--1344350000000 --Nakhichevan AR
	SELECT
		@idfsRegionNakhichevanAR = fgr.idfsReference
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) fgr
	WHERE fgr.name = N'Nakhichevan AR'  
	
	
	DECLARE @vet_form_1_use_specific_gis BIGINT
	DECLARE @vet_form_1_specific_gis_region BIGINT
	DECLARE @vet_form_1_specific_gis_rayon BIGINT
	DECLARE	@attr_part_in_report			BIGINT

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
	
	
	CREATE TABLE #VetCase
		(
			idfsRegion BIGINT
			, idfsRayon BIGINT
			, idfsSpeciesType BIGINT
			, intSickAnimalQty INT
			, intDeadAnimalQty INT
		)	

	
	;WITH NotDeletedDiagnosis AS (
		SELECT
			CAST(r_d.[name] AS NVARCHAR(2000)) AS [name]
			, ISNULL(r_d.idfsReference,d_actual.idfsDiagnosis) AS idfsDiagnosis
			, ISNULL(d_actual.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
			, ROW_NUMBER() OVER (PARTITION BY ISNULL(r_d.idfsReference,d_actual.idfsDiagnosis) ORDER BY ISNULL(d_actual.idfsDiagnosis, r_d.idfsReference)) AS rn
		FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d
		LEFT JOIN trtDiagnosis d_actual
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000019) r_d_actual ON
				r_d_actual.idfsReference = d_actual.idfsDiagnosis
		ON r_d_actual.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
			AND d_actual.idfsUsingType = 10020001	/*Case-based*/
			AND d_actual.intRowStatus = 0
	)
	, NotDeletedSpecies AS (
		SELECT
			CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
			, ISNULL(r_sp.idfsReference, st_actual.idfsSpeciesType) AS idfsSpeciesType
			, ISNULL(st_actual.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
			, ROW_NUMBER() OVER (PARTITION BY ISNULL(r_sp.idfsReference, st_actual.idfsSpeciesType) ORDER BY ISNULL(st_actual.idfsSpeciesType, r_sp.idfsReference)) AS rn
		FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_sp
		LEFT JOIN trtSpeciesType st_actual
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000086) r_sp_actual ON	
				r_sp_actual.idfsReference = st_actual.idfsSpeciesType
		ON r_sp_actual.[name] = r_sp.[name] COLLATE Cyrillic_General_CI_AS
			AND st_actual.intRowStatus = 0
	)

	
	INSERT INTO #VetCase
	SELECT
		ISNULL(reg_specific.idfsReference, tgl.idfsRegion)
		, ISNULL(ray_specific.idfsReference, tgl.idfsRayon)
		, Actual_Species_Type.idfsActualSpeciesType
		, SUM(ISNULL(ts.intSickAnimalQty, 0))
		, SUM(ISNULL(ts.intDeadAnimalQty, 0))
	FROM tlbVetCase tvc
	JOIN tlbFarm tf ON
		tf.idfFarm = tvc.idfFarm
		AND tf.intRowStatus = 0
	JOIN tlbGeoLocation tgl ON
		tgl.idfGeoLocation = tf.idfFarmAddress
		AND tgl.intRowStatus = 0
	
	JOIN NotDeletedDiagnosis AS Actual_Diagnosis ON
		Actual_Diagnosis.idfsDiagnosis = tvc.idfsFinalDiagnosis
		AND Actual_Diagnosis.rn = 1
		AND Actual_Diagnosis.idfsActualDiagnosis = @Diagnosis
		
	JOIN tlbHerd th ON
		th.idfFarm = tf.idfFarm
		AND th.intRowStatus = 0
	JOIN tlbSpecies ts ON
		ts.idfHerd = th.idfHerd
		AND ts.intRowStatus = 0
		AND ISNULL(ts.intTotalAnimalQty, 0) > 0
		AND ISNULL(ts.intSickAnimalQty, 0) + ISNULL(ts.intDeadAnimalQty, 0) > 0
	JOIN NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = ts.idfsSpeciesType
		AND Actual_Species_Type.rn = 1
	JOIN @SpeciesTypeTable stt ON
		stt.[key] = Actual_Species_Type.idfsActualSpeciesType
	
	-- Site, Organization entered case
	JOIN tstSite s
		LEFT JOIN report.FN_REP_InstitutionRepair(@LangID) i ON
			i.idfOffice = s.idfOffice
	ON s.idfsSite = tvc.idfsSite
	
	-- Specific Region and Rayon for the site with specific attributes (B46)
	LEFT JOIN trtBaseReferenceAttribute bra
		LEFT JOIN trtGISBaseReferenceAttribute gis_bra_region
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific ON
				reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
		ON CAST(gis_bra_region.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
			AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
		LEFT JOIN trtGISBaseReferenceAttribute gis_bra_rayon
			JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific ON
				ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference 
		ON CAST(gis_bra_rayon.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
			AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
	ON bra.idfsBaseReference = i.idfsOfficeAbbreviation
		AND bra.idfAttributeType = @vet_form_1_use_specific_gis
		AND CAST(bra.varValue AS NVARCHAR) = s.strSiteID	
	
	WHERE tvc.intRowStatus = 0
		AND idfsCaseReportType <> 4578940000001 /*Active*/
		AND idfsCaseClassification = 350000000 /*Confirmed Case*/
		AND ISNULL(tvc.datFinalDiagnosisDate, tvc.datTentativeDiagnosis1Date) BETWEEN @SDDate AND @EDDate
	GROUP BY ISNULL(reg_specific.idfsReference, tgl.idfsRegion)
		, ISNULL(ray_specific.idfsReference, tgl.idfsRayon)
		, Actual_Species_Type.idfsActualSpeciesType


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
		,MAX(ISNULL(VetCase.intSickAnimalQty,0)) AS intSickAnimalTotalQty
		,MAX(ISNULL(VetCase.intDeadAnimalQty,0)) AS intDeadAnimalTotalQty
	FROM report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) AS reg
	JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*rftRegion*/) AS refReg ON
		reg.idfsRegion = refReg.idfsReference			
		AND reg.idfsCountry = @CountryID
	JOIN report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) AS ray ON 
		ray.idfsRegion = reg.idfsRegion	
	JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*rftRayon*/) AS refRay ON
		ray.idfsRayon = refRay.idfsReference
	LEFT JOIN @SpeciesTypeTable stt ON 1=1
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000086) ref_spec ON
		stt.[key] = ref_spec.idfsReference	
	LEFT JOIN #VetCase AS VetCase ON
		VetCase.idfsRegion = ray.idfsRegion
		AND VetCase.idfsRayon = ray.idfsRayon
		AND ref_spec.idfsReference = VetCase.idfsSpeciesType

	GROUP BY CASE ray.idfsRegion 
				WHEN @idfsRegionBaku THEN 1 
				WHEN @idfsRegionOtherRayons THEN 2
				WHEN @idfsRegionNakhichevanAR THEN 3
				ELSE 0
			END
			, refReg.[name]
			, refRay.[name]
			, ref_spec.[name] 
	ORDER BY intRegionOrder, strRayon

