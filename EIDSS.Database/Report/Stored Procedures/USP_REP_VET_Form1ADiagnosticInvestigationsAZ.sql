--*************************************************************************
-- Name: report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ
--
-- Description: Select Diagnostic investigations data for Veterinary Report Form Vet1A.
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
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ 'en',2014,2016
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ @LangID=N'en', @FromYear = 2016, @ToYear = 2016, @FromMonth = 1, @ToMonth = 11
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ 'en',2012,2013
EXEC report.USP_REP_VET_Form1ADiagnosticInvestigationsAZ @LangID=N'en', @FromYear = 2015, @ToYear = 2015, @FromMonth = 1, @ToMonth = 12
*/
CREATE  PROCEDURE [Report].[USP_REP_VET_Form1ADiagnosticInvestigationsAZ]
    (
        @LangID as NVARCHAR(10)
        , @FromYear AS INT
		, @ToYear AS INT
		, @FromMonth AS INT = NULL
		, @ToMonth AS INT = NULL
		, @RegionID AS BIGINT = NULL
		, @RayonID AS BIGINT = NULL
		, @OrganizationEntered AS BIGINT = NULL
		, @OrganizationID AS BIGINT = NULL
		, @idfUserID AS BIGINT = NULL
    )
WITH RECOMPILE
AS

--DECLARE @LangID as NVARCHAR(10) = N'en'
--        , @FromYear AS INT = 2015
--		, @ToYear AS INT = 2015
--		, @FromMonth AS INT = 1
--		, @ToMonth AS INT = 12
--		, @RegionID AS BIGINT = NULL
--		, @RayonID AS BIGINT = NULL
--		, @OrganizationEntered AS BIGINT = NULL
--		, @OrganizationID AS BIGINT = NULL
--		, @idfUserID AS BIGINT = NULL


BEGIN


DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
IF Object_ID('tempdb..#ActiveSurveillanceSessionList') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionList'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ASAnimal') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ASAnimal'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionSourceData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionSourceData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END

DECLARE @Result AS TABLE
(
	strDiagnosisSpeciesKey	NVARCHAR(200) collate database_default NOT NULL primary key,
	strInvestigationName	NVARCHAR(2000) collate database_default null,
	idfsDiagnosticAction	bigint NOT NULL,
	idfsDiagnosis			bigint NOT NULL,
	idfsSpeciesType			bigint NOT NULL,
	strDiagnosisName		NVARCHAR(2000) collate database_default null,
	strOIECode				NVARCHAR(200) collate database_default null,
	strSpecies				NVARCHAR(2000) collate database_default null,
	strFooterPerformer		NVARCHAR(2000) collate database_default null,
	intTested				INT NULL,
	intPositivaReaction		INT NULL,
	strNote					NVARCHAR(2000) collate database_default null,
	InvestigationOrderColumn	INT NULL,
	SpeciesOrderColumn		INT NULL,
	DiagnosisOrderColumn	INT NULL,
	blnAdditionalText		BIT
)

DECLARE	@idfsSummaryReportType	bigint
SET	@idfsSummaryReportType = 10290033	-- Veterinary Report Form Vet 1A - Diagnostic

DECLARE	@idfsMatrixType	bigint
SET	@idfsMatrixType = 71460000000	-- Diagnostic investigations


-- Specify the value of missing month IF remaining month is specified in interval (1-12)
IF	@FromMonth is null AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth is null AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start AND End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	date
DECLARE	@EndDate	date

IF	@FromMonth is null or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0101'
ELSE IF @FromMonth < 10
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0' + CAST(@FromMonth as NVARCHAR) + N'01'
ELSE
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + CAST(@FromMonth as NVARCHAR) + N'01'

IF	@ToMonth is null or @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0101'
	SET	@EndDate = dateadd(year, 1, @EndDate)
END
ELSE
BEGIN
	IF @ToMonth < 10
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0' + CAST(@ToMonth as NVARCHAR) + N'01'
	ELSE
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + CAST(@ToMonth as NVARCHAR) + N'01'
	
	SET	@EndDate = dateadd(month, 1, @EndDate)
END

DECLARE	@OrganizationName_GenerateReport	NVARCHAR(2000)
SELECT		@OrganizationName_GenerateReport = i.EnglishFullName
FROM		dbo.FN_GBL_Institution_Min(@LangID) i
WHERE		i.idfOffice = @OrganizationID
IF	@OrganizationName_GenerateReport is null
	SET	@OrganizationName_GenerateReport = N''


-- Calculate Footer parameter "Name AND Last Name of Performer:" - start
DECLARE	@FooterNameOfPerformer	NVARCHAR(2000)
SET	@FooterNameOfPerformer = N''

-- Show the user Name AND Surname which is generating the report 
-- AND near it current organization name (Organization from which user has logged on to the system) 
--     in round brackets in respective report language

DECLARE	@EmployeeName_GenerateReport	NVARCHAR(2000)
SELECT		@EmployeeName_GenerateReport = dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
FROM		tlbPerson p
INNER JOIN	tstUserTable ut
ON			ut.idfPerson = p.idfPerson
WHERE		ut.idfUserID = @idfUserID
IF	@EmployeeName_GenerateReport is null
	SET	@EmployeeName_GenerateReport = N''

SET	@FooterNameOfPerformer = @EmployeeName_GenerateReport
IF	ltrim(rtrim(@OrganizationName_GenerateReport)) <> N''
BEGIN
	IF	ltrim(rtrim(@FooterNameOfPerformer)) = N''
	BEGIN
		SET @FooterNameOfPerformer = N'(' + @OrganizationName_GenerateReport + N')' 
	END
	ELSE
	BEGIN
		SET	@FooterNameOfPerformer = @FooterNameOfPerformer + N' (' + @OrganizationName_GenerateReport + N')'
	END
END

-- Calculate Footer parameter "Name AND Last Name of Performer:" - end

-- Select report informative part - start

DECLARE	@vet_form_1_use_specific_gis	bigint
DECLARE	@vet_form_1_specific_gis_region	bigint
DECLARE	@vet_form_1_specific_gis_rayon	bigint
DECLARE	@attr_part_in_report			bigint

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

DECLARE	@Diagnostic_Tested		BIGINT
DECLARE	@Diagnostic_Positive	BIGINT
DECLARE	@Diagnostic_Note		BIGINT


-- Diagnostic_Tested
SELECT		@Diagnostic_Tested = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Diagnostic_Tested'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Diagnostic_Positive
SELECT		@Diagnostic_Positive = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Diagnostic_Positive'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Diagnostic_Note
SELECT		@Diagnostic_Note = p.idfsParameter
FROM		trtFFObjectForCustomReport ff_for_cr
INNER JOIN	ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Diagnostic_Note'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

-- Lab Diagnostic - investigation type for data from AS Session
DECLARE	@Lab_diagnostics				BIGINT
DECLARE	@Lab_diagnostics_Translation	NVARCHAR(2000)
DECLARE	@Lab_diagnostics_Order			int

SELECT		@Lab_diagnostics = rat.idfsReference,
			@Lab_diagnostics_Translation = rat.[name],
			@Lab_diagnostics_Order = rat.intOrder
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue as NVARCHAR) = CAST(@idfsSummaryReportType as NVARCHAR(20))
			AND bra.strAttributeItem = N'Name of investigation - Lab diagnostics'

IF	@Lab_diagnostics is null
	SET	@Lab_diagnostics = -1
IF	@Lab_diagnostics_Translation is null
	SET	@Lab_diagnostics_Translation = N''
	
	
-- Project monitoring - investigation type for data from AS Session
DECLARE	@Project_monitoring				BIGINT
DECLARE	@Project_monitoring_Translation	NVARCHAR(2000)
DECLARE	@Project_monitoring_Order			int

SELECT		@Project_monitoring = rat.idfsReference,
			@Project_monitoring_Translation = rat.[name],
			@Project_monitoring_Order = rat.intOrder
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue as NVARCHAR) = CAST(@idfsSummaryReportType as NVARCHAR(20))
			AND bra.strAttributeItem = N'Name of investigation - Project monitoring'

IF	@Project_monitoring is null
	SET	@Project_monitoring = -1
IF	@Project_monitoring_Translation is null
	SET	@Project_monitoring_Translation = N''

-- Included state sector - note for data from AS Session containing farm, 
-- which has ownership structure = State Farm AND is counted for the report
DECLARE	@Included_state_sector				BIGINT
DECLARE	@Included_state_sector_Translation	NVARCHAR(2000)

SELECT		@Included_state_sector = rat.idfsReference,
			@Included_state_sector_Translation = rat.[name]
FROM		trtBaseReferenceAttribute bra
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) rat	/*Report Additional Text*/
ON			rat.idfsReference = bra.idfsBaseReference
WHERE		bra.idfAttributeType = @attr_part_in_report
			AND CAST(bra.varValue as NVARCHAR) = CAST(@idfsSummaryReportType as NVARCHAR(20))
			AND bra.strAttributeItem = N'Note - Diagnostic'

IF	@Included_state_sector is null
	SET	@Included_state_sector = -1
IF	@Included_state_sector_Translation is null
	SET	@Included_state_sector_Translation = N''

-- Active Surveillance Session List for calculations
CREATE TABLE	#ActiveSurveillanceSessionList
(	idfMonitoringSessiON			BIGINT NOT NULL PRIMARY KEY
	, LabDiagnostics BIT NOT NULL
)


INSERT INTO	#ActiveSurveillanceSessionList
(	idfMonitoringSession
	, LabDiagnostics
)
SELECT	DISTINCT
			ms.idfMonitoringSession
			, CASE WHEN tc.idfCampaign IS NULL THEN 1 ELSE 0 END
FROM		
-- AS Session
			tlbMonitoringSession ms

-- Site, Organization entered session
INNER JOIN	tstSite s
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN s.intFlags = 10 THEN @SpecificOfficeId ELSE s.idfOffice END

	-- Specific Region AND Rayon for the site with specific attributes (B46)
	LEFT JOIN	trtBaseReferenceAttribute bra
	ON			bra.idfsBaseReference = i.idfsOfficeAbbreviation
				AND bra.idfAttributeType = @vet_form_1_use_specific_gis
				AND CAST(bra.varValue as NVARCHAR) = s.strSiteID
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_region
	ON			CAST(gis_bra_region.varValue as NVARCHAR) = s.strSiteID
				AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
	LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific
	ON			reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
	LEFT JOIN	trtGISBaseReferenceAttribute gis_bra_rayon
	ON			CAST(gis_bra_rayon.varValue as NVARCHAR) = s.strSiteID
				AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
	LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific
	ON			ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference

ON			s.idfsSite = ms.idfsSite

-- Region AND Rayon
LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg
ON			reg.idfsReference = ms.idfsRegion
LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray
ON			ray.idfsReference = ms.idfsRayon

LEFT JOIN tlbCampaign tc ON 
	tc.idfCampaign = ms.idfCampaign 
	AND tc.intRowStatus = 0 
	AND tc.idfsCampaignType = 10150002 /*Study*/

WHERE		ms.intRowStatus = 0

			-- Session Start Date is not blank
			AND ms.datStartDate IS NOT NULL


			-- From Year, Month To Year, Month
			AND ISNULL(ms.datEndDate, ms.datStartDate) >= @StartDate
			AND ISNULL(ms.datEndDate, ms.datStartDate) < @EndDate
			
			-- Region
			AND (@RegionID is null or (@RegionID IS NOT NULL AND ISNULL(reg_specific.idfsReference, reg.idfsReference) = @RegionID))
			-- Rayon
			AND (@RayonID is null or (@RayonID IS NOT NULL AND ISNULL(ray_specific.idfsReference, ray.idfsReference) = @RayonID))
			
			-- Entered by organization
			AND (@OrganizationEntered is null or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))





-- Active Surveillance Session data
create TABLE	#ActiveSurveillanceSessionData
(	strDiagnosisSpeciesKey			NVARCHAR(200) collate database_default NOT NULL /*primary key*/,
	idfsDiagnosis					BIGINT NOT NULL,
	idfsDiagnosticActiON			BIGINT NOT NULL,
	idfsSpeciesType					BIGINT NOT NULL,
	strInvestigationName			NVARCHAR(2000) collate database_default null,
	strDiagnosisName				NVARCHAR(2000) collate database_default null,
	strOIECode						NVARCHAR(200) collate database_default null,
	strSpecies						NVARCHAR(2000) collate database_default null,
	intTested						INT NULL,
	intPositivaReactiON				INT NULL,
	blnAddNote						INT NULL default (0),
	InvestigationOrderColumn		INT NULL,
	SpeciesOrderColumn				INT NULL,
	DiagnosisOrderColumn			INT NULL
)



DECLARE	@NotDeletedDiagnosis TABLE
(	idfsDiagnosis		BIGINT NOT NULL primary key,
	[name]				NVARCHAR(2000) collate Cyrillic_General_CI_AS null,
	intOrder			INT NULL,
	strOIECode			NVARCHAR(200) collate Cyrillic_General_CI_AS null, 
	idfsActualDiagnosis	BIGINT NOT NULL
)

INSERT INTO	@NotDeletedDiagnosis
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
			  END as intOrder
			, CASE
				WHEN	actual_diagnosis.idfsDiagnosis IS NOT NULL
					THEN actual_diagnosis.strOIECode
				ELSE	d.strOIECode
			  END as strOIECode
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
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET('en', 19000019) r_d_actual
	ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
	WHERE		d_actual.idfsUsingType = 10020001	/*Case-based*/
				AND d_actual.intRowStatus = 0
			) actual_diagnosis
	ON		actual_diagnosis.[name] = r_d.[name] collate Cyrillic_General_CI_AS
			AND actual_diagnosis.rn = 1


DECLARE	@NotDeletedSpecies TABLE
(	idfsSpeciesType			BIGINT NOT NULL primary key,
	[name]					NVARCHAR(2000) collate Cyrillic_General_CI_AS null,
	intOrder			INT NULL,
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
					THEN actual_SpeciesType.intOrder
				ELSE	r_sp.intOrder
			  END as intOrder
			, ISNULL(actual_SpeciesType.idfsSpeciesType, r_sp.idfsReference) AS idfsActualSpeciesType
FROM		dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
LEFT JOIN	(
	SELECT	st_actual.idfsSpeciesType,
			r_st_actual.[name],
			r_st_actual.intOrder,
			ROW_NUMBER() OVER (PARTITION BY r_st_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
	FROM		trtSpeciesType st_actual
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET('en', 19000086) r_st_actual
	ON			r_st_actual.idfsReference = st_actual.idfsSpeciesType
	WHERE		st_actual.intRowStatus = 0
		) actual_SpeciesType
on		actual_SpeciesType.[name] = r_sp.[name] collate Cyrillic_General_CI_AS
		AND actual_SpeciesType.rn = 1


INSERT INTO	#ActiveSurveillanceSessionData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strInvestigationName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intTested,
	intPositivaReaction,
	blnAddNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn
)
SELECT
	CAST(ndd.idfsActualDiagnosis AS NVARCHAR(20)) + N'_' + 
		CAST(ndsp.idfsActualSpeciesType AS NVARCHAR(20)) + N'_' + 
		CAST(CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics ELSE @Project_monitoring END AS NVARCHAR(20)) AS strDiagnosisSpeciesKey,
	ndd.idfsActualDiagnosis AS idfsDiagnosis,
	CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics ELSE @Project_monitoring END AS idfsDiagnosticAction,
	ndsp.idfsActualSpeciesType AS idfsSpeciesType,
	CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics_Translation ELSE @Project_monitoring_Translation END AS strInvestigationName,
	ISNULL(ndd.[name], N'') AS strDiagnosisName,
	ISNULL(ndd.strOIECode, N'') AS strOIECode,
	ISNULL(ndsp.[name], N'') AS strSpecies,
		COUNT(DISTINCT /*DISTINCT for calculating 
						number of unique animals - 
						ticket 10165*/ sd.idfMaterial),
		COUNT(DISTINCT /*DISTINCT for calculating 
						number of unique animals - 
						ticket 10165*/ sd.idfTesting),
		SUM(CAST((ISNULL(sd.idfsOwnershipStructure, 0) / 10820000000) AS INT)) AS blnAddNote, /*State Farm*/
	CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics_Order ELSE @Project_monitoring_Order END AS InvestigationOrderColumn,
	ISNULL(ndsp.intOrder, -1000) AS SpeciesOrderColumn,
	ISNULL(ndd.intOrder, -1000) AS DiagnosisOrderColumn
	
FROM
(
	SELECT DISTINCT
			asd.idfsDiagnosis,
				sp.idfsSpeciesType,
				a.idfAnimal as idfMaterial,
				CASE
					WHEN t.idfTesting IS NOT NULL
						THEN	a.idfAnimal
					ELSE	null
				END as idfTesting,
				--a.idfsOwnershipStructure
				CASE
					WHEN	f.idfsOwnershipStructure = 10820000000 /*State Farm*/
						THEN	10820000000 /*State Farm*/
					ELSE	null
				END idfsOwnershipStructure
			, asl.LabDiagnostics
	FROM		tlbMaterial m

	JOIN tlbAnimal a ON
		a.idfAnimal = m.idfAnimal
		AND a.intRowStatus = 0

	JOIN tlbSpecies sp ON
		sp.idfSpecies = a.idfSpecies
		AND sp.intRowStatus = 0

	--JOIN @NotDeletedSpecies ndsp ON
	--	ndsp.idfsSpeciesType = sp.idfsSpeciesType

	JOIN tlbHerd h ON
		h.idfHerd = sp.idfHerd
		AND h.intRowStatus = 0

	JOIN tlbFarm f ON
		f.idfFarm = h.idfFarm
		AND f.intRowStatus = 0
		AND f.idfMonitoringSession = m.idfMonitoringSession

	JOIN #ActiveSurveillanceSessionList asl ON
		asl.idfMonitoringSession = f.idfMonitoringSession
	
	outer apply	(
		SELECT	DISTINCT
					ms_to_d.idfsDiagnosis--, ndd.idfsActualDiagnosis
		FROM		tlbMonitoringSessionToDiagnosis ms_to_d
		
		--join		@NotDeletedDiagnosis ndd
		--ON			ndd.idfsDiagnosis = ms_to_d.idfsDiagnosis
		
		WHERE		ms_to_d.idfMonitoringSession = asl.idfMonitoringSession
					AND ms_to_d.idfsSpeciesType = sp.idfsSpeciesType
					AND ms_to_d.intRowStatus = 0
				) asd

	LEFT JOIN	tlbTesting t
		join	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000001) ref_teststatus
		on		ref_teststatus.idfsReference = t.idfsTestStatus
	ON			t.idfMaterial = m.idfMaterial
				AND t.intRowStatus = 0
				and	t.idfsDiagnosis = asd.idfsDiagnosis
				AND ISNULL(t.blnExternalTest, 0) = 0
				AND ref_teststatus.idfsReference IN (10001001, 10001006)  /*Final, Amended*/
				AND exists	(
						SELECT TOP 1 1
						FROM	trtTestTypeToTestResult tttttr
						WHERE	tttttr.idfsTestName = t.idfsTestName
								AND tttttr.idfsTestResult = t.idfsTestResult
								AND tttttr.intRowStatus = 0
								AND tttttr.blnIndicative = 1
							)

	WHERE		m.intRowStatus = 0
				AND asd.idfsDiagnosis IS NOT NULL
				AND m.idfsSampleType <> 10320001	/*Unknown*/
				AND m.datFieldCollectionDate IS NOT NULL
				AND exists	(
						SELECT TOP 1 1
						FROM	tlbMonitoringSessionToDiagnosis ms_to_d
						WHERE	ms_to_d.idfMonitoringSession = asl.idfMonitoringSession
								AND ms_to_d.intRowStatus = 0
								AND ms_to_d.idfsDiagnosis = asd.idfsDiagnosis
								AND ms_to_d.idfsSpeciesType = sp.idfsSpeciesType
								AND (	ms_to_d.idfsSampleType is null
										OR	(	ms_to_d.idfsSampleType IS NOT NULL
												AND ms_to_d.idfsSampleType = m.idfsSampleType
											)
									)
							)
) sd

INNER JOIN	@NotDeletedDiagnosis ndd
ON			ndd.idfsDiagnosis = sd.idfsDiagnosis

INNER JOIN	@NotDeletedSpecies ndsp
ON			ndsp.idfsSpeciesType = sd.idfsSpeciesType

GROUP BY	CAST(ndd.idfsActualDiagnosis as NVARCHAR(20)) + N'_' + 
				CAST(ndsp.idfsActualSpeciesType as NVARCHAR(20)) + N'_' + 
				CAST(CASE WHEN LabDiagnostics = 1 THEN @Lab_diagnostics ELSE @Project_monitoring END AS NVARCHAR(20)),
			ndd.idfsActualDiagnosis,
			ndsp.idfsActualSpeciesType,
			ISNULL(ndd.[name], N''),
			ISNULL(ndd.strOIECode, N''),
			ISNULL(ndsp.[name], N''),
			ISNULL(ndsp.intOrder, -1000),
			ISNULL(ndd.intOrder, -1000),
			LabDiagnostics






-- Select aggregate data
DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT



SET @AggrCaseType = 10102003 /*Vet Aggregate Action*/

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_AggregateSettings_GET (@AggrCaseType)

CREATE TABLE #VetAggregateAction
(	idfAggrCase					BIGINT NOT NULL PRIMARY KEY,
	idfDiagnosticObservation	BIGINT,
	datStartDate				datetime,
	idfDiagnosticVersion		BIGINT
	, idfsRegion BIGINT
	, idfsRayon BIGINT
	, idfsAdministrativeUnit BIGINT
	, datFinishDate DATETIME
)

DECLARE	@idfsCurrentCountry	BIGINT
SELECT	@idfsCurrentCountry = ISNULL(dbo.FN_GBL_CURRENTCOUNTRY_GET(), 170000000) /*Azerbaijan*/

INSERT INTO	#VetAggregateAction
(	idfAggrCase,
	idfDiagnosticObservation,
	datStartDate,
	idfDiagnosticVersion
	, idfsRegion
	, idfsRayon
	, idfsAdministrativeUnit
	, datFinishDate
)
SELECT		a.idfAggrCase,
			obs.idfObservation,
			a.datStartDate,
			a.idfDiagnosticVersion
			, COALESCE(s.idfsRegion, rr.idfsRegion, r.idfsRegion, NULL) AS idfsRegion
			, COALESCE(s.idfsRayon, rr.idfsRayon, NULL) AS idfsRayon
			, a.idfsAdministrativeUnit
			, a.datFinishDate
FROM		tlbAggrCase a
INNER JOIN	tlbObservation obs
ON			obs.idfObservation = a.idfDiagnosticObservation
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
			AND (@OrganizationEntered is null or (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

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

DECLARE	@VetAggregateActionData	TABLE
(	strDiagnosisSpeciesKey		NVARCHAR(200) collate database_default NOT NULL primary key,
	idfsDiagnosis				BIGINT NOT NULL,
	idfsDiagnosticAction		BIGINT NOT NULL,
	idfsSpeciesType				BIGINT NOT NULL,
	strInvestigationName		NVARCHAR(2000) collate database_default null,
	strDiagnosisName			NVARCHAR(2000) collate database_default null,
	strOIECode					NVARCHAR(200) collate database_default null,
	strSpecies					NVARCHAR(2000) collate database_default null,
	intTested					INT NULL,
	intPositivaReactiON			INT NULL,
	strNote						NVARCHAR(2000) collate database_default null,
	SpeciesOrderColumn			INT NULL,
	DiagnosisOrderColumn		INT NULL,
	InvestigationOrderColumn	INT NULL
)

DECLARE @NotDeletedAggregateDiagnosis TABLE (
	[name] NVARCHAR(500)
	, idfsDiagnosis BIGINT
	, intOrder INT
	, strOIECode NVARCHAR(100)
	, rn INT
)

INSERT INTO @NotDeletedAggregateDiagnosis
SELECT
	r_d_actual.[name]
	, d_actual.idfsDiagnosis
	, r_d_actual.intOrder
	, d_actual.strOIECode
	, ROW_NUMBER() OVER (PARTITION BY r_d_actual.[name] ORDER BY d_actual.idfsDiagnosis) AS rn
FROM		trtDiagnosis d_actual
INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d_actual
ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
WHERE		d_actual.idfsUsingType = 10020002	/*Aggregate*/
			AND d_actual.intRowStatus = 0
	

DECLARE @NotDeletedAggregateSpecies TABLE (
	[name] NVARCHAR(500)
	, idfsSpeciesType BIGINT
	, intOrder INT
	, rn INT
)	

INSERT INTO @NotDeletedAggregateSpecies
SELECT
	r_sp_actual.[name]
	, st_actual.idfsSpeciesType
	, r_sp_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_sp_actual.[name] ORDER BY st_actual.idfsSpeciesType) AS rn
FROM		trtSpeciesType st_actual
INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_sp_actual
ON			r_sp_actual.idfsReference = st_actual.idfsSpeciesType
WHERE		st_actual.intRowStatus = 0


DECLARE @NotDeletedAggregateInvestigationType TABLE (
	[name] NVARCHAR(500)
	, idfsDiagnosticAction BIGINT
	, intOrder INT
	, rn INT
)

INSERT INTO @NotDeletedAggregateInvestigationType
SELECT
	r_di_actual.[name]
	, r_di_actual.idfsReference as idfsDiagnosticAction
	, r_di_actual.intOrder
	, ROW_NUMBER() OVER (PARTITION BY r_di_actual.[name] ORDER BY r_di_actual.idfsReference) AS rn
FROM		report.FN_GBL_ReferenceRepair_GET(@LangID, 19000021) r_di_actual



INSERT INTO	@VetAggregateActionData
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strInvestigationName,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intTested,
	intPositivaReaction,
	strNote,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	InvestigationOrderColumn
)
SELECT		CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, 
								mtx.idfsDiagnosticAction) as NVARCHAR(20)) as strDiagnosisSpeciesKey,
			ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis) as idfsDiagnosis,
			ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, mtx.idfsDiagnosticAction) as idfsDiagnosticAction,
			ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType) as idfsSpeciesType,
			ISNULL(r_di.[name], N'') as strInvestigationName,
			ISNULL(r_d.[name], N'') as strDiagnosisName,
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')) as strOIECode,
			ISNULL(r_sp.[name], N'') as strSpecies,
			SUM(ISNULL(CAST(Diagnostic_Tested.varValue as int), 0)) as intTested,
			SUM(ISNULL(CAST(Diagnostic_Positive.varValue as int), 0)) as intPositivaReaction,
			MAX(LEFT(ISNULL(CAST(Diagnostic_Note.varValue as NVARCHAR), N''), 2000)) as strNote,
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)) as SpeciesOrderColumn,
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)) as DiagnosisOrderColumn,
			ISNULL(Actual_Investigation_Type.intOrder, ISNULL(r_di.intOrder, -1000)) as InvestigationOrderColumn
			
FROM		#VetAggregateAction vaa
-- Matrix version
INNER JOIN	tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = @idfsMatrixType
			AND (	-- Get matrix version selected by the user in aggregate action
					h.idfVersion = vaa.idfDiagnosticVersion
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate action start date
					or (	vaa.idfDiagnosticVersion is null 
							and	h.datStartDate <= vaa.datStartDate
							and	h.blnIsActive = 1
							AND not exists	(
										SELECT	*
										FROM	tlbAggrMatrixVersionHeader h_later
										WHERE	h_later.idfsMatrixType = @idfsMatrixType
												and	h_later.datStartDate <= vaa.datStartDate
												and	h_later.blnIsActive = 1
												AND h_later.intRowStatus = 0
												and	h_later.datStartDate > h.datStartDate
											)
						)
				)
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	tlbAggrDiagnosticActionMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0

-- Diagnosis       
INNER JOIN	trtDiagnosis d
	INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) r_d
	ON			r_d.idfsReference = d.idfsDiagnosis

	-- Not deleted diagnosis with the same name AND aggregate using type
	LEFT JOIN @NotDeletedAggregateDiagnosis AS Actual_Diagnosis ON
		Actual_Diagnosis.[name] = r_d.[name] collate Cyrillic_General_CI_AS
		AND Actual_Diagnosis.rn = 1
ON			d.idfsDiagnosis = mtx.idfsDiagnosis

-- Species Type
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) r_sp
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateSpecies AS Actual_Species_Type ON
		Actual_Species_Type.[name] = r_sp.[name] collate Cyrillic_General_CI_AS
		AND Actual_Species_Type.rn = 1
ON			r_sp.idfsReference = mtx.idfsSpeciesType

-- Investigation Type
INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000021) r_di
	-- Not deleted species type with the same name
	LEFT JOIN @NotDeletedAggregateInvestigationType AS Actual_Investigation_Type ON
		Actual_Investigation_Type.[name] = r_di.[name] collate Cyrillic_General_CI_AS
		AND Actual_Investigation_Type.rn = 1
ON			r_di.idfsReference = mtx.idfsDiagnosticAction

-- Tested
outer apply ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfDiagnosticObservation
 			AND ap.idfRow = mtx.idfAggrDiagnosticActionMTX
			AND ap.idfsParameter = @Diagnostic_Tested
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) as  Diagnostic_Tested

-- Positive reaction
outer apply ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfDiagnosticObservation
 			AND ap.idfRow = mtx.idfAggrDiagnosticActionMTX
			AND ap.idfsParameter = @Diagnostic_Positive
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) as  Diagnostic_Positive

-- Note
outer apply ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	tlbActivityParameters ap
 	WHERE	ap.idfObservation = vaa.idfDiagnosticObservation
 			AND ap.idfRow = mtx.idfAggrDiagnosticActionMTX
			AND ap.idfsParameter = @Diagnostic_Note
			AND ap.intRowStatus = 0
			AND ap.varValue IS NOT NULL
 			order by ap.idfActivityParameters asc
 		) as  Diagnostic_Note

GROUP BY	CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, 
								mtx.idfsDiagnosticAction) as NVARCHAR(20)),
			ISNULL(Actual_Diagnosis.idfsDiagnosis, mtx.idfsDiagnosis),
			ISNULL(Actual_Investigation_Type.idfsDiagnosticAction, mtx.idfsDiagnosticAction),
			ISNULL(Actual_Species_Type.idfsSpeciesType, mtx.idfsSpeciesType),
			ISNULL(r_di.[name], N''),
			ISNULL(r_d.[name], N''),
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')),
			ISNULL(r_sp.[name], N''),
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)),
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)),
			ISNULL(Actual_Investigation_Type.intOrder, ISNULL(r_di.intOrder, -1000))
-- Do not include the rows with Tested = 0 in the report
HAVING		SUM(ISNULL(CAST(Diagnostic_Tested.varValue AS INT), 0)) > 0


-- Fill result TABLE
INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strInvestigationName,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	strFooterPerformer,
	intTested,
	intPositivaReaction,
	strNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT DISTINCT
			s.strDiagnosisSpeciesKey,
			s.strInvestigationName,
			s.idfsDiagnosis,
			s.idfsDiagnosticAction,
			s.idfsSpeciesType,
			s.strDiagnosisName,
			s.strOIECode,
			s.strSpecies,
			@FooterNameOfPerformer,
			s.intTested,
			s.intPositivaReaction,
			CASE
				WHEN	s.blnAddNote > 0
					THEN	@Included_state_sector_Translation
				ELSE	N''
			END,
			s.InvestigationOrderColumn,
			s.SpeciesOrderColumn,
			s.DiagnosisOrderColumn,
			1 AS blnAdditionalText

FROM		#ActiveSurveillanceSessionData s



INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	strInvestigationName,
	idfsDiagnosis,
	idfsDiagnosticAction,
	idfsSpeciesType,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	strFooterPerformer,
	intTested,
	intPositivaReaction,
	strNote,
	InvestigationOrderColumn,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	blnAdditionalText
)
SELECT		a.strDiagnosisSpeciesKey,
			a.strInvestigationName,
			a.idfsDiagnosis,
			a.idfsDiagnosticAction,
			a.idfsSpeciesType,
			a.strDiagnosisName,
			a.strOIECode,
			a.strSpecies,
			@FooterNameOfPerformer,
			a.intTested,
			a.intPositivaReaction,
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
			
FROM		@VetAggregateActionData a
LEFT JOIN	@Result r
ON			r.strDiagnosisSpeciesKey = a.strDiagnosisSpeciesKey
WHERE		r.idfsDiagnosis is null

-- Update orders in the table
update	r
SET		r.InvestigationOrderColumn = -1000000,
		r.DiagnosisOrderColumn = 0,
		r.SpeciesOrderColumn = 0
FROM	@Result r
WHERE	(ISNULL(r.idfsDiagnosticAction, -1) = @Lab_diagnostics OR ISNULL(r.idfsDiagnosticAction, -1) = @Project_monitoring)
		AND (	ISNULL(r.InvestigationOrderColumn, 0) <> -1000000
				OR	ISNULL(r.DiagnosisOrderColumn, 0) <> 0
				OR	ISNULL(r.SpeciesOrderColumn, 0) <> 0
			)

update		r
SET			r.InvestigationOrderColumn = ISNULL(adaMTX.intNumRow, 0),
			r.DiagnosisOrderColumn = 0,
			r.SpeciesOrderColumn = 0
FROM		@Result r
INNER JOIN	tlbAggrDiagnosticActionMTX adaMTX
ON			adaMTX.idfsDiagnosis = r.idfsDiagnosis
			AND adaMTX.idfsDiagnosticAction = r.idfsDiagnosticAction
			AND adaMTX.idfsSpeciesType = r.idfsSpeciesType
			AND adaMTX.intRowStatus = 0
INNER JOIN	tlbAggrMatrixVersionHeader amvh
ON			amvh.idfVersion = adaMTX.idfVersion
			AND amvh.intRowStatus = 0
			AND amvh.blnIsActive = 1
			AND amvh.blnIsDefault = 1
			AND amvh.datStartDate <= getdate()
WHERE		(	ISNULL(r.InvestigationOrderColumn, 0) <> ISNULL(adaMTX.intNumRow, 0)
				OR	ISNULL(r.DiagnosisOrderColumn, 0) <> 0
				OR	ISNULL(r.SpeciesOrderColumn, 0) <> 0
			)

update		r
SET			r.InvestigationOrderColumn = 1000000,
			r.DiagnosisOrderColumn = 0,
			r.SpeciesOrderColumn = 0
FROM		@Result r

WHERE		not exists	(
					SELECT	*
					FROM		tlbAggrDiagnosticActionMTX adaMTX
					INNER JOIN	tlbAggrMatrixVersionHeader amvh
					ON			amvh.idfVersion = adaMTX.idfVersion
								AND amvh.intRowStatus = 0
								AND amvh.blnIsActive = 1
								AND amvh.blnIsDefault = 1
								AND amvh.datStartDate <= getdate()
					WHERE		adaMTX.idfsDiagnosis = r.idfsDiagnosis
								AND adaMTX.idfsDiagnosticAction = r.idfsDiagnosticAction
								AND adaMTX.idfsSpeciesType = r.idfsSpeciesType
								AND adaMTX.intRowStatus = 0
						)
			AND (ISNULL(r.idfsDiagnosticAction, -1) = @Lab_diagnostics OR ISNULL(r.idfsDiagnosticAction, -1) = @Project_monitoring)
			AND (	ISNULL(r.InvestigationOrderColumn, 0) <> 1000000
					OR	ISNULL(r.DiagnosisOrderColumn, 0) <> 0
					OR	ISNULL(r.SpeciesOrderColumn, 0) <> 0
				)


-- Select report informative part - start

-- Return results
IF (SELECT COUNT(*) FROM @result) = 0
	select	'' as strDiagnosisSpeciesKey,
	'' as strInvestigationName,
	- 1 as idfsDiagnosis,
	- 1 as idfsDiagnosticAction,
	- 1 as idfsSpeciesType,
	'' as strDiagnosisName,
	'' as strOIECode, 
	'' as strSpecies,
	@FooterNameOfPerformer as strFooterPerformer,
	null as intTested, 
	null as intPositivaReaction, 
	null as strNote,
	null as InvestigationOrderColumn,
	null as SpeciesOrderColumn, 
	null as DiagnosisOrderColumn,
	0   as blnAdditionalText
ELSE
	SELECT * FROM @result ORDER BY InvestigationOrderColumn, strInvestigationName, DiagnosisOrderColumn, strDiagnosisName, idfsDiagnosis, SpeciesOrderColumn, blnAdditionalText
	
	

	
	     
-- Drop temporary tables
IF Object_ID('tempdb..#ActiveSurveillanceSessionList') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionList'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ASDiagnosisAndSpeciesType') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ASDiagnosisAndSpeciesType'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ASAnimal') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ASAnimal'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#ActiveSurveillanceSessionSourceData') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #ActiveSurveillanceSessionSourceData'
	EXECUTE sp_executesql @drop_cmd
END

IF Object_ID('tempdb..#VetAggregateAction') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetAggregateAction'
	EXECUTE sp_executesql @drop_cmd
END




END


