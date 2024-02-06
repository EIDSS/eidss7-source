

--##SUMMARY Select data for REPORT ON ACTIONS TAKEN AGAINST EPIZOOTIC: Diagnostic investigations report.

--##RETURNS Doesn't use

/*
--Example of a call of procedure:
EXEC report.USP_REP_VET_Form1AVaccinationMeasuresAZ 'en',2014,2016
EXEC report.USP_REP_VET_Form1AVaccinationMeasuresAZ 'ru',2017,2018
EXEC report.USP_REP_VET_Form1AVaccinationMeasuresAZ @LangID=N'en', @FromYear = 2016, @ToYear = 2016, @FromMonth = 1, @ToMonth = 11, @RegionID = 1344340000000, @RayonID = 1344870000000
*/
CREATE PROCEDURE [Report].[USP_REP_VET_Form1AVaccinationMeasuresAZ]
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
IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetCaseData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateActionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateActionData'
	EXECUTE sp_executesql @drop_cmd
END


DECLARE @Result AS TABLE
(
	strDiagnosisSpeciesKey	NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL PRIMARY KEY,
	strMeasureName			NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	idfsDiagnosis			BIGINT NOT NULL,
	idfsProphylacticAction	BIGINT NOT NULL,
	idfsSpeciesType			BIGINT NOT NULL,
	strDiagnosisName		NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strOIECode				NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL,
	strSpecies				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intActionTaken			INT NULL,
	strNote					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	InvestigationOrderColumn	INT NULL,
	SpeciesOrderColumn		INT NULL,
	DiagnosisOrderColumn	INT NULL,
	blnAdditionalText		BIT
)


DECLARE	@idfsSummaryReportType	BIGINT
SET	@idfsSummaryReportType = 10290034	-- Veterinary Report Form Vet 1A - Prophylactics

DECLARE	@idfsMatrixType	BIGINT
SET	@idfsMatrixType = 71300000000	-- Treatment-prophylactics AND vaccination measures


-- Specify the value of missing month IF remaining month is specified in interval (1-12)
IF	@FromMonth IS NULL AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth IS NULL AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start and End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	date
DECLARE	@EndDate	date

IF	@FromMonth IS NULL or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0101'
ELSE IF @FromMonth < 10
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + N'0' + CAST(@FromMonth AS NVARCHAR) + N'01'
ELSE
	SET	@StartDate = CAST(@FromYear AS NVARCHAR) + CAST(@FromMonth AS NVARCHAR) + N'01'

IF	@ToMonth IS NULL OR @ToMonth < 1 or @ToMonth > 12
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

-- Select report informative part - start

DECLARE	@vet_form_1_use_specific_gis	BIGINT
DECLARE	@vet_form_1_specific_gis_region	BIGINT
DECLARE	@vet_form_1_specific_gis_rayon	BIGINT
DECLARE	@attr_part_in_report			BIGINT

SELECT	@vet_form_1_use_specific_gis = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

SELECT	@vet_form_1_specific_gis_region = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

SELECT	@vet_form_1_specific_gis_rayon = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'

SELECT	@attr_part_in_report = at.idfAttributeType
FROM	trtAttributeType at
WHERE	at.strAttributeTypeName = N'attr_part_in_report'

DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

DECLARE	@Prophylactics_Livestock_Treated_number	BIGINT
DECLARE	@Prophylactics_Avian_Treated_number		BIGINT

DECLARE	@Prophylactics_Aggr_Action_taken		BIGINT
DECLARE	@Prophylactics_Aggr_Note				BIGINT

-- Prophylactics_Livestock_Treated_number
SELECT		@Prophylactics_Livestock_Treated_number = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Livestock_Treated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Prophylactics_Avian_Treated_number
SELECT		@Prophylactics_Avian_Treated_number = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Avian_Treated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Prophylactics_Aggr_Action_taken
SELECT		@Prophylactics_Aggr_Action_taken = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Aggr_Action_taken'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Prophylactics_Aggr_Note
SELECT		@Prophylactics_Aggr_Note = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Prophylactics_Aggr_Note'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0


-- Treatment - Prophylactic measure for data from Vet Case
DECLARE	@Treatment				BIGINT
DECLARE	@Treatment_Translation	NVARCHAR(2000)

SELECT		@Treatment = rat.idfsReference,
			@Treatment_Translation = rat.[name]
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue AS NVARCHAR) = CAST(@idfsSummaryReportType AS NVARCHAR(20))
			AND bra.strAttributeItem = N'Name of measure'

IF	@Treatment IS NULL
	SET	@Treatment = -1
IF	@Treatment_Translation IS NULL
	SET	@Treatment_Translation = N''

-- Included state sector - note for data from Vet Cases connecting to the farms, 
-- which have ownership structure = State Farm AND are counted for the report
DECLARE	@Included_state_sector				BIGINT
DECLARE	@Included_state_sector_Translation	NVARCHAR(2000)

SELECT		@Included_state_sector = rat.idfsReference,
			@Included_state_sector_Translation = rat.[name]
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue AS NVARCHAR) = CAST(@idfsSummaryReportType AS NVARCHAR(20))
			AND bra.strAttributeItem = N'Note - Prophylactics'

IF	@Included_state_sector IS NULL
	SET	@Included_state_sector = -1
IF	@Included_state_sector_Translation IS NULL
	SET	@Included_state_sector_Translation = N''




-- Vet Case data
create table	#VetCaseData
(	strDiagnosisSpeciesKey			NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL PRIMARY KEY,
	idfsDiagnosis					BIGINT NOT NULL,
	idfsProphylacticActiON			BIGINT NOT NULL,
	idfsSpeciesType					BIGINT NOT NULL,
	strMeasureName					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strDiagnosisName				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strOIECode						NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL,
	strSpecies						NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intActionTaken					INT NULL,
	blnAddNote						INT NULL default (0),
	SpeciesOrderColumn				INT NULL,
	DiagnosisOrderColumn			INT NULL
)



DECLARE	@NotDeletedCaseBasedDiagnosis table
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
	[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder			INT NULL,
	strOIECode			NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL, 
	idfsActualDiagnosis	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedCaseBasedDiagnosis
(	idfsDiagnosis,
	[name],
	intOrder,
	strOIECode,
	idfsActualDiagnosis
)
SELECT
			r_d.idfsReference AS idfsDiagnosis
			, r_d.[name] AS [name]
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					then actual_diagnosis.intOrder
				ELSE	r_d.intOrder
			  END AS INTOrder
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					then actual_diagnosis.strOIECode
				ELSE	d.strOIECode
			  END AS strOIECode
			, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
LEFT JOIN	trtDiagnosis d
ON			d.idfsDiagnosis = r_d.idfsReference
LEFT JOIN	(
	SELECT	d_actual.idfsDiagnosis,
			r_d_actual.[name],
			r_d_actual.intOrder,
			d_actual.strOIECode,
			ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
	FROM		trtDiagnosis d_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000019) r_d_actual
	ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
	WHERE		d_actual.idfsUsingType = 10020001	/*Case-based*/
				AND d_actual.intRowStatus = 0
			) actual_diagnosis
	ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_diagnosis.rn = 1

DECLARE	@NotDeletedAggregateDiagnosis table
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
	[name]				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder			INT NULL,
	strOIECode			NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL, 
	idfsActualDiagnosis	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedAggregateDiagnosis
(	idfsDiagnosis,
	[name],
	intOrder,
	strOIECode,
	idfsActualDiagnosis
)
SELECT
			r_d.idfsReference AS idfsDiagnosis
			, r_d.[name] AS [name]
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					THEN actual_diagnosis.intOrder
				ELSE	r_d.intOrder
			  END AS INTOrder
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					then actual_diagnosis.strOIECode
				ELSE	d.strOIECode
			  END AS strOIECode
			, ISNULL(actual_diagnosis.idfsDiagnosis, r_d.idfsReference) AS idfsActualDiagnosis
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
LEFT JOIN	trtDiagnosis d
ON			d.idfsDiagnosis = r_d.idfsReference
LEFT JOIN	(
	SELECT	d_actual.idfsDiagnosis,
			r_d_actual.[name],
			r_d_actual.intOrder,
			d_actual.strOIECode,
			ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
	FROM		trtDiagnosis d_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000019) r_d_actual
	ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
	WHERE		d_actual.idfsUsingType = 10020002	/*Aggregate*/
				AND d_actual.intRowStatus = 0
			) actual_diagnosis
	ON		actual_diagnosis.[name] = r_d.[name] COLLATE Cyrillic_General_CI_AS
			AND actual_diagnosis.rn = 1


DECLARE	@NotDeletedSpecies table
(	idfsSpeciesType			BIGINT NOT NULL PRIMARY KEY,
	[name]					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder				INT NULL,
	idfsActualSpeciesType	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedSpecies
(	idfsSpeciesType,
	[name],
	intOrder,
	idfsActualSpeciesType
)
SELECT
			r_sp.idfsReference AS idfsSpeciesType
			, CAST(r_sp.[name] AS NVARCHAR(2000)) AS [name]
			, CASE
				WHEN	actual_SpeciesType.idfsSpeciesType IS NOT NULL
					then actual_SpeciesType.intOrder
				ELSE	r_sp.intOrder
			  END AS INTOrder
			, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
LEFT JOIN	(
	SELECT	st_actual.idfsSpeciesType,
			r_st_actual.[name],
			r_st_actual.intOrder,
			ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
	FROM		trtSpeciesType st_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000086) r_st_actual
	ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
	WHERE		st_actual.intRowStatus = 0
		) actual_SpeciesType
ON		actual_SpeciesType.[name] = r_sp.[name] COLLATE Cyrillic_General_CI_AS
		AND actual_SpeciesType.rn = 1


DECLARE @NotDeletedProphylacticAction TABLE
(	idfsProphylacticActiON			BIGINT NOT NULL PRIMARY KEY,
	[name]							NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intOrder						INT NULL,
	idfsActualProphylacticAction	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedProphylacticAction
(	idfsProphylacticAction,
	[name],
	intOrder,
	idfsActualProphylacticAction
)
SELECT
			r_pm.idfsReference AS idfsProphylacticAction
			, CAST(r_pm.[name] AS NVARCHAR(2000)) AS [name]
			, CASE
				WHEN	actual_ProphylacticAction.idfsProphylacticAction IS NOT NULL
					then actual_ProphylacticAction.intOrder
				ELSE	r_pm.intOrder
			  END AS INTOrder
			, ISNULL(actual_ProphylacticAction.idfsProphylacticAction, r_pm.idfsReference) AS idfsActualProphylacticAction
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000074/*Prophylactic Measure List*/) r_pm
LEFT JOIN	(
	SELECT	pa_actual.idfsProphilacticAction AS idfsProphylacticAction,
			r_pa_actual.[name],
			r_pa_actual.intOrder,
			ROW_NUMBER() OVER (PARTITION BY r_pa_actual.[name] ORDER BY pa_actual.idfsProphilacticAction) AS rn
	FROM		trtProphilacticAction pa_actual
	INNER JOIN	dbo.FN_GBL_Reference_GETList('en', 19000074/*Prophylactic Measure List*/) r_pa_actual
	ON			r_pa_actual.idfsReference = pa_actual.idfsProphilacticAction
	WHERE		pa_actual.intRowStatus = 0
		) actual_ProphylacticAction
ON		actual_ProphylacticAction.[name] = r_pm.[name] COLLATE Cyrillic_General_CI_AS
		AND actual_ProphylacticAction.rn = 1


INSERT INTO	#VetCaseData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strMeasureName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	blnAddNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn
)
SELECT		(CAST(Actual_Diagnosis.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(Actual_Species_Type.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(@Treatment, -1) AS NVARCHAR(20))) COLLATE Latin1_General_CI_AS AS strDiagnosisSpeciesKey,
			Actual_Diagnosis.idfsActualDiagnosis AS idfsDiagnosis,
			ISNULL(@Treatment, -1) AS idfsProphylacticAction,
			Actual_Species_Type.idfsActualSpeciesType AS idfsSpeciesType,
			@Treatment_Translation,
			ISNULL(Actual_Diagnosis.[name], N'') AS strDiagnosisName,
			ISNULL(Actual_Diagnosis.strOIECode, N'') AS strOIECode,
			ISNULL(Actual_Species_Type.[name], N'') AS strSpecies,
			SUM(ISNULL(CAST(Treated_number.varValue AS INT), 0)) AS INTActionTaken,
			SUM(CAST((ISNULL(fot.idfsReference, 0) / 10820000000) AS INT)) AS blnAddNote, /*State Farm*/
			ISNULL(Actual_Species_Type.intOrder, -1000) AS SpeciesOrderColumn,
			ISNULL(Actual_Diagnosis.intOrder, -1000) AS DiagnosisOrderColumn
FROM		
-- Veterinary Case
			tlbVetCase vc

-- Diagnosis = Final Diagnosis of Veterinary Case
INNER JOIN	@NotDeletedCaseBasedDiagnosis AS Actual_Diagnosis ON
	Actual_Diagnosis.idfsDiagnosis = VC.idfsFinalDiagnosis


-- Species - start
INNER JOIN	tlbFarm f

	-- Region AND Rayon
	LEFT JOIN	tlbGeoLocation gl
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg
		ON			reg.idfsReference = gl.idfsRegion
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray
		ON			ray.idfsReference = gl.idfsRayon
	ON			gl.idfGeoLocation = f.idfFarmAddress

	-- State Farm
	LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000065) fot	/*Farm Ownership Type*/
	ON			fot.idfsReference = f.idfsOwnershipStructure
				AND fot.idfsReference = 10820000000 /*State Farm*/
ON			f.idfFarm = vc.idfFarm
			AND f.intRowStatus = 0
INNER JOIN	tlbHerd h
ON			h.idfFarm = f.idfFarm
			AND h.intRowStatus = 0
INNER JOIN	tlbSpecies sp
	INNER JOIN	@NotDeletedSpecies AS Actual_Species_Type ON
		Actual_Species_Type.idfsSpeciesType = sp.idfsSpeciesType
ON			sp.idfHerd = h.idfHerd
			AND sp.intRowStatus = 0
			-- Sick + Dead > 0
			AND ISNULL(sp.intDeadAnimalQty, 0) + ISNULL(sp.intSickAnimalQty, 0) > 0
			-- Total > 0
			AND ISNULL(sp.intTotalAnimalQty, 0) > 0

-- Species - end

-- Site, Organization entered case
INNER JOIN	tstSite s
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN s.intFlags = 10 THEN @SpecificOfficeId ELSE s.idfOffice END
ON			s.idfsSite = vc.idfsSite

-- Specific Region and Rayon for the site with specific attributes (B46)
LEFT JOIN	trtBaseReferenceAttribute bra
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_region
		INNER JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific
		ON			reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
	ON			CAST(gis_bra_region.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
				AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_rayon
		INNER JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific
		ON			ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference
	ON			CAST(gis_bra_rayon.varValue AS NVARCHAR) = CAST(bra.varValue AS NVARCHAR)
				AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
ON			bra.idfsBaseReference = i.idfsOfficeAbbreviation
			AND bra.idfAttributeType = @vet_form_1_use_specific_gis
			AND CAST(bra.varValue AS NVARCHAR) = s.strSiteID

-- Species Observation
LEFT JOIN	tlbObservation	obs
ON			obs.idfObservation = sp.idfObservation


-- FF: Treated number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter in (@Prophylactics_Livestock_Treated_number, @Prophylactics_Avian_Treated_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfRow asc
 		) AS  Treated_number

WHERE		vc.intRowStatus = 0
			-- Case Classification = Confirmed
			AND vc.idfsCaseClassification = 350000000	/*Confirmed*/
			
			-- FF: Treated number > 0
			AND CAST(Treated_number.varValue AS INT) > 0

			-- From Year, Month To Year, Month
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) >= @StartDate
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) < @EndDate
			
			-- Region
			AND (@RegionID IS NULL or (@RegionID IS NOT NULL AND ISNULL(reg_specific.idfsReference, reg.idfsReference) = @RegionID))
			-- Rayon
			AND (@RayonID IS NULL or (@RayonID IS NOT NULL AND ISNULL(ray_specific.idfsReference, ray.idfsReference) = @RayonID))
			
			-- Entered by organization
			AND (@OrganizationEntered IS NULL or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

GROUP BY	CAST(Actual_Diagnosis.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(Actual_Species_Type.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(@Treatment, -1) AS NVARCHAR(20)) COLLATE Latin1_General_CI_AS,
			Actual_Diagnosis.idfsActualDiagnosis,
			Actual_Species_Type.idfsActualSpeciesType,
			ISNULL(Actual_Diagnosis.[name], N''),
			ISNULL(Actual_Diagnosis.strOIECode, N''),
			ISNULL(Actual_Species_Type.[name], N''),
			ISNULL(Actual_Species_Type.intOrder, -1000),
			ISNULL(Actual_Diagnosis.intOrder, -1000)


-- SELECT aggregate data
DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT



SET @AggrCaseType = 10102003 /*Vet Aggregate Action*/

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)

create TABLE	#VetAggregateAction
(	idfAggrCase					BIGINT NOT NULL PRIMARY KEY,
	idfProphylacticObservation	BIGINT,
	datStartDate				datetime,
	idfProphylacticVersion		BIGINT
	, idfsRegion BIGINT
	, idfsRayon BIGINT
	, idfsAdministrativeUnit BIGINT
	, datFinishDate DATETIME
)

DECLARE	@idfsCurrentCountry	BIGINT
SELECT	@idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

INSERT INTO	#VetAggregateAction
(	idfAggrCase,
	idfProphylacticObservation,
	datStartDate,
	idfProphylacticVersion
	, idfsRegion
	, idfsRayon
	, idfsAdministrativeUnit
	, datFinishDate
)
SELECT		a.idfAggrCase,
			obs.idfObservation,
			a.datStartDate,
			a.idfProphylacticVersion
			, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
			, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
			, a.idfsAdministrativeUnit
			, a.datFinishDate
FROM		tlbAggrCase a
INNER JOIN	tlbObservation obs
ON			obs.idfObservation = a.idfProphylacticObservation
LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
ON			c.idfsReference = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
ON			r.idfsRegion = a.idfsAdministrativeUnit 
LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
ON			rr.idfsRayon = a.idfsAdministrativeUnit
LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
ON			s.idfsSettlement = a.idfsAdministrativeUnit

-- Site, Organization entered aggregate action
INNER JOIN	tstSite sit
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = sit.idfOffice
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


create TABLE	#VetAggregateActionData
(	strDiagnosisSpeciesKey		NVARCHAR(200) COLLATE Latin1_General_CI_AS not null PRIMARY KEY,
	idfsDiagnosis				BIGINT NOT NULL,
	idfsProphylacticAction		BIGINT NOT NULL,
	idfsSpeciesType				BIGINT NOT NULL,
	strMeasureName				NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strDiagnosisName			NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strOIECode					NVARCHAR(200) COLLATE Cyrillic_General_CI_AS NULL,
	strSpecies					NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	intActionTaken				INT NULL,
	strNote						NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	SpeciesOrderColumn			INT NULL,
	DiagnosisOrderColumn		INT NULL,
	InvestigationOrderColumn	INT NULL
)


INSERT INTO	#VetAggregateActionData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strMeasureName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	strNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	InvestigationOrderColumn
)
SELECT		CAST(ndad.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(nds.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ndpa.idfsActualProphylacticAction AS NVARCHAR(20)) COLLATE Latin1_General_CI_AS AS strDiagnosisSpeciesKey,
			ndad.idfsActualDiagnosis AS idfsDiagnosis,
			ndpa.idfsActualProphylacticAction AS idfsProphylacticAction,
			nds.idfsActualSpeciesType AS idfsSpeciesType,
			ISNULL(ndpa.[name], N'') AS strMeasureName,
			ISNULL(ndad.[name], N'') AS strDiagnosisName,
			ISNULL(ndad.strOIECode, N'') AS strOIECode,
			ISNULL(nds.[name], N'') AS strSpecies,
			SUM(ISNULL(CAST(Action_taken.varValue AS INT), 0)) AS INTTested,
			max(left(ISNULL(CAST(Prophylactics_Note.varValue AS NVARCHAR), N''), 2000)) AS INTPositivaReaction,
			ISNULL(nds.intOrder, -1000) AS SpeciesOrderColumn,
			ISNULL(ndad.intOrder, -1000) AS DiagnosisOrderColumn,
			ISNULL(ndpa.intOrder, -1000) AS InvestigationOrderColumn
FROM		#VetAggregateAction vaa
-- Matrix version
INNER JOIN	tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = @idfsMatrixType
			AND (	-- Get matrix version selected by the user in aggregate action
					h.idfVersion = vaa.idfProphylacticVersion
					-- IF matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate action start date
					OR (	vaa.idfProphylacticVersion IS NULL 
							AND	h.datStartDate <= vaa.datStartDate
							AND	h.blnIsActive = 1
							AND NOT EXISTS	(
										SELECT	*
										FROM	tlbAggrMatrixVersionHeader h_later
										WHERE	h_later.idfsMatrixType = @idfsMatrixType
												AND	h_later.datStartDate <= vaa.datStartDate
												AND	h_later.blnIsActive = 1
												AND h_later.intRowStatus = 0
												AND	h_later.datStartDate > h.datStartDate
											)
						)
				)
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	tlbAggrProphylacticActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Diagnosis       
INNER JOIN	@NotDeletedAggregateDiagnosis ndad
ON			ndad.idfsDiagnosis = mtx.idfsDiagnosis

-- Species Type
INNER JOIN	@NotDeletedSpecies nds
ON			nds.idfsSpeciesType = mtx.idfsSpeciesType

-- Measure Name
INNER JOIN	@NotDeletedProphylacticAction  ndpa
ON			ndpa.idfsProphylacticAction = mtx.idfsProphilacticAction

-- Action_taken
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfProphylacticObservation
 			AND ap.idfRow = mtx.idfAggrProphylacticActionMTX
			AND ap.idfsParameter = @Prophylactics_Aggr_Action_taken
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) AS  Action_taken

-- Note
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfProphylacticObservation
 			AND ap.idfRow = mtx.idfAggrProphylacticActionMTX
			AND ap.idfsParameter = @Prophylactics_Aggr_Note
			AND ap.intRowStatus = 0
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) AS  Prophylactics_Note

GROUP BY	CAST(ndad.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
				CAST(nds.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
				CAST(ndpa.idfsActualProphylacticAction AS NVARCHAR(20)) COLLATE Latin1_General_CI_AS,
			ndad.idfsActualDiagnosis,
			ndpa.idfsActualProphylacticAction,
			nds.idfsActualSpeciesType,
			ISNULL(ndpa.[name], N''),
			ISNULL(ndad.[name], N''),
			ISNULL(ndad.strOIECode, N''),
			ISNULL(nds.[name], N''),
			ISNULL(nds.intOrder, -1000),
			ISNULL(ndad.intOrder, -1000),
			ISNULL(ndpa.intOrder, -1000)
-- Do not include the rows with Action Taken = 0 in the report
HAVING		SUM(ISNULL(CAST(Action_taken.varValue AS INT), 0)) > 0


-- Fill result TABLE
INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strMeasureName,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	strNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT DISTINCT
			s.strDiagnosisSpeciesKey,
			s.strMeasureName,
			s.idfsDiagnosis,
			s.idfsProphylacticAction,
			s.idfsSpeciesType,
			s.strDiagnosisName,
			s.strOIECode,
			s.strSpecies,
			s.intActionTaken,
			CASE
				WHEN	s.blnAddNote > 0
					THEN	@Included_state_sector_Translation
				ELSE	N''
			END,
			s.SpeciesOrderColumn,
			s.DiagnosisOrderColumn,
			1 AS blnAdditionalText

FROM		#VetCaseData s

INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strMeasureName,
	idfsDiagnosis,
	idfsProphylacticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intActionTaken,
	strNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT		a.strDiagnosisSpeciesKey,
			a.strMeasureName,
			a.idfsDiagnosis,
			a.idfsProphylacticAction,
			a.idfsSpeciesType,
			a.strDiagnosisName,
			a.strOIECode,
			a.strSpecies,
			a.intActionTaken,
			CASE
				WHEN	@FromYear = @ToYear
						and	@FromMonth = @ToMonth
					THEN	a.strNote
				ELSE	N''
			END,
			a.InvestigationOrderColumn,
			a.SpeciesOrderColumn,
			a.DiagnosisOrderColumn,
			0 AS blnAdditionalText
			
FROM		#VetAggregateActionData a
LEFT JOIN	@Result r
ON			r.strDiagnosisSpeciesKey = a.strDiagnosisSpeciesKey
WHERE		r.idfsDiagnosis IS NULL

-- Update orders in the table
UPDATE		r
SET			r.InvestigationOrderColumn = ROrderTable.RowOrder,
			r.DiagnosisOrderColumn = 0,
			r.SpeciesOrderColumn = 0
FROM		@Result r
INNER JOIN	(	
	SELECT	r_order.strDiagnosisSpeciesKey,
			ROW_NUMBER () OVER	(	ORDER BY	ISNULL(r_order.strMeasureName, N''), 
												ISNULL(r_order.strDiagnosisName, N''),
												ISNULL(r_order.SpeciesOrderColumn, 0),
												ISNULL(r_order.strSpecies, N'')
								) AS RowOrder
	FROM	@Result r_order
			) AS ROrderTable
ON			ROrderTable.strDiagnosisSpeciesKey = r.strDiagnosisSpeciesKey


-- SELECT report informative part - start

/*
insert into @Result Values('aaa', 'dddd', 7718320000000, 'diagnos', 'B051', 'dog', 12, 'fff', 34, 45, 56)
insert into @Result Values('b', 'dddd', 7718320000000, 'diagnos', 'B051', 'cat', 13, 'jjj', 24, 35, 46)
insert into @Result Values('c', 'gdhdfgdh', 7718730000000, 'diagnos2', 'B103, B152, B253', 'sheep', 12, 'note', 23, 34, 45)
insert into @Result Values('?', 'sdfgsafdgsdfg', 7718350000000, 'diagnos3', 'B0512', 'cat', 13, 'note2', 24, 35, 46)
insert into @Result Values('?', 'sdfgsafdgsdfg', 7718760000000, 'diagnos4', 'B1031, B152, B253', 'sheep', 12, 'note5', 23, 34, 45)
insert into @Result Values('aaa1', 'sdfgsafdgsdfg', 7718520000000, 'diagnos5', 'B051', 'dog', 12, 'notedddd', 23, 34, 45)
insert into @Result Values('b1', 'sdfgsafdgsdfg', 7718520000000, 'diagnos5', 'B051', 'cat', 13, 'notesdfgs', 24, 35, 46)
*/


-- Return results
IF (SELECT COUNT(*) FROM @result) = 0
	SELECT	'' AS strDiagnosisSpeciesKey,
	'' AS strMeasureName,
	- 1 AS idfsDiagnosis,
	- 1 AS idfsProphylacticAction,
	- 1 AS idfsSpeciesType,
	'' AS strDiagnosisName,
	'' AS strOIECode, 
	'' AS strSpecies,
	NULL AS INTActionTaken, 
	NULL AS strNote,
	NULL AS InvestigationOrderColumn, 
	NULL AS SpeciesOrderColumn, 
	NULL AS DiagnosisOrderColumn,
	0 AS blnAdditionalText
ELSE
	SELECT * FROM @result ORDER BY InvestigationOrderColumn

-- Drop temporary tables
IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetCaseData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateActionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateActionData'
	EXECUTE sp_executesql @drop_cmd
END
	     
END




