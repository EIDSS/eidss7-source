--*************************************************************************
-- Name: report.USP_REP_VET_Form1ReportAZ
--
-- Description: Select data for REPORT ON Veterinary Report Form Vet1.
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
EXEC report.USP_REP_VET_Form1ReportAZ @LangID=N'en', @FromYear = 2012, @ToYear = 2014
EXEC report.USP_REP_VET_Form1ReportAZ 'ru',2012,2013, @OrganizationEntered = 48120000000, @OrganizationID = 48120000000

*/
CREATE PROCEDURE [Report].[USP_REP_VET_Form1ReportAZ]
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
		, @idfUserID AS BIGINT = NULL
    )
AS
BEGIN

DECLARE	@drop_cmd	NVARCHAR(4000)

-- Drop temporary tables
IF Object_ID('tempdb..#VetCaseTable') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseTable'
	EXECUTE sp_executesql @drop_cmd
END

DECLARE @Result AS TABLE
(
	strDiagnosisSpeciesKey		NVARCHAR(200) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY,
	idfsDiagnosis				BIGINT NOT NULL,
	strDiagnosisName			NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	strOIECode					NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	strSpecies					NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	intNumberSensSpecies		INT NULL,
	intNumberUnhealthySt		INT NULL,
	intNumberSick				INT NULL,
	intNumberDead				INT NULL,
	intNumberVaccinated			INT NULL,
	intOtherMeasures 			INT NULL,
	intNumberAnnihilated		INT NULL,
	intNumberSlaughtered		INT NULL,
	intNumberUnhealthyStLeft	INT NULL,
	intNumberDiseased			INT NULL,
	SpeciesOrderColumn			INT NULL,
	DiagnosisOrderColumn		INT NULL,
	strFooterPerformer			NVARCHAR(2000) COLLATE DATABASE_DEFAULT null
)
/*
INSERT INTO @Result Values('aaa', 7718320000000, 'diagnos', 'B051', 'dog', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('b', 7718320000000, 'diagnos', 'B051', 'cat', 13, 24, 35, 46, 57, 68, 79, 80, 91, 112, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('c', 7718730000000, 'diagnos2', 'B103, B152, B253', 'sheep', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('в', 7718350000000, 'diagnos3', 'B0512', 'cat', 13, 24, 35, 46, 57, 68, 79, 80, 91, 112, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('ф', 7718760000000, 'diagnos4', 'B1031, B152, B253', 'sheep', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('aaa1', 7718520000000, 'diagnos5', 'B051', 'dog', 12, 23, 34, 45, 56, 67, 78, 89, 90, 111, 1, 1, 'sentby', 'Vasya Pupkin')
INSERT INTO @Result Values('b1', 7718520000000, 'diagnos5', 'B051', 'cat', 13, 24, 35, 46, 57, 68, 79, 80, 91, 112, 1, 1, 'sentby', 'Vasya Pupkin')
*/

DECLARE	@idfsSummaryReportType	BIGINT
SET	@idfsSummaryReportType = 10290032	-- Veterinary Report Form Vet 1


-- Specify the value of missing month if remaining month is specified in interval (1-12)
IF	@FromMonth IS NULL AND @ToMonth IS NOT NULL AND @ToMonth >= 1 AND @ToMonth <= 12
	SET	@FromMonth = 1
IF	@ToMonth IS NULL AND @FromMonth IS NOT NULL AND @FromMonth >= 1 AND @FromMonth <= 12
	SET	@ToMonth = 12

-- Calculate Start AND End dates for conditions: Start Date <= date from Vet Case < End date
DECLARE	@StartDate	date
DECLARE	@EndDate	date

IF	@FromMonth IS NULL or @FromMonth < 1 or @FromMonth > 12
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0101'
else if @FromMonth < 10
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + N'0' + CAST(@FromMonth as NVARCHAR) + N'01'
else
	SET	@StartDate = CAST(@FromYear as NVARCHAR) + CAST(@FromMonth as NVARCHAR) + N'01'

IF	@ToMonth IS NULL or @ToMonth < 1 or @ToMonth > 12
BEGIN
	SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0101'
	SET	@EndDate = dateadd(year, 1, @EndDate)
END
else
BEGIN
	if @ToMonth < 10
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + N'0' + CAST(@ToMonth as NVARCHAR) + N'01'
	else
		SET	@EndDate = CAST(@ToYear as NVARCHAR) + CAST(@ToMonth as NVARCHAR) + N'01'
	
	SET	@EndDate = dateadd(month, 1, @EndDate)
END

DECLARE	@OrganizationName_GenerateReport	NVARCHAR(2000)
SELECT		@OrganizationName_GenerateReport = i.EnglishFullName
FROM		dbo.FN_GBL_Institution_Min(@LangID) i
WHERE		i.idfOffice = @OrganizationID
IF	@OrganizationName_GenerateReport IS NULL
	SET	@OrganizationName_GenerateReport = N''



-- Calculate Footer parameter "Name and Last Name of Performer:" - start
DECLARE	@FooterNameOfPerformer	NVARCHAR(2000)
SET	@FooterNameOfPerformer = N''

-- Show the user Name and Surname which is generating the report 
-- and near it current organization name (Organization from which user has logged on to the system) 
--     in round brackets in respective report language

DECLARE	@EmployeeName_GenerateReport	NVARCHAR(2000)
SELECT		@EmployeeName_GenerateReport = dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
FROM		dbo.tlbPerson p
INNER JOIN	dbo.tstUserTable ut
ON			ut.idfPerson = p.idfPerson
WHERE		ut.idfUserID = @idfUserID
IF	@EmployeeName_GenerateReport IS NULL
	SET	@EmployeeName_GenerateReport = N''

SET	@FooterNameOfPerformer = @EmployeeName_GenerateReport
IF	LTRIM(RTRIM(@OrganizationName_GenerateReport)) <> N''
BEGIN
	IF	LTRIM(RTRIM(@FooterNameOfPerformer)) = N''
	BEGIN
		set @FooterNameOfPerformer = N'(' + @OrganizationName_GenerateReport + N')' 
	END
	else
	BEGIN
		SET	@FooterNameOfPerformer = @FooterNameOfPerformer + N' (' + @OrganizationName_GenerateReport + N')'
	END
END

-- Calculate Footer parameter "Name and Last Name of Performer:" - end

-- Select report informative part - start

DECLARE	@vet_form_1_use_specific_gis	BIGINT
DECLARE	@vet_form_1_specific_gis_region	BIGINT
DECLARE	@vet_form_1_specific_gis_rayon	BIGINT

SELECT	@vet_form_1_use_specific_gis = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_use_specific_gis'

SELECT	@vet_form_1_specific_gis_region = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_region'

SELECT	@vet_form_1_specific_gis_rayon = at.idfAttributeType
FROM	dbo.trtAttributeType at
WHERE	at.strAttributeTypeName = N'vet_form_1_specific_gis_rayon'

DECLARE @SpecificOfficeId BIGINT
SELECT
	 @SpecificOfficeId = ts.idfOffice
FROM dbo.tstSite ts 
WHERE ts.intRowStatus = 0
	AND ts.intFlags = 100 /*organization with abbreviation = Baku city VO*/

DECLARE	@Livestock_Vaccinated_number BIGINT
DECLARE	@Avian_Vaccinated_number	BIGINT

DECLARE	@Livestock_Quarantined_number	BIGINT
DECLARE	@Avian_Quarantined_number	BIGINT

DECLARE	@Livestock_Desinfected_number	BIGINT
DECLARE	@Avian_Desinfected_number	BIGINT

DECLARE	@Livestock_Number_selected_for_monitoring	BIGINT
DECLARE	@Avian_Number_selected_for_monitoring	BIGINT

DECLARE	@Livestock_Annihilated_number	BIGINT
DECLARE	@Avian_Annihilated_number	BIGINT

DECLARE	@Livestock_Slaughtered_number	BIGINT
DECLARE	@Avian_Slaughtered_number	BIGINT

DECLARE	@Livestock_Number_of_diseased_left	BIGINT
DECLARE	@Avian_Number_of_diseased_left	BIGINT

-- Vaccinated_number - start
SELECT		@Livestock_Vaccinated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Vaccinated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Vaccinated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Vaccinated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Vaccinated_number - end

-- Quarantined_number - start
SELECT		@Livestock_Quarantined_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Quarantined_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Quarantined_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Quarantined_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Quarantined_number - end

-- Desinfected_number - start
SELECT		@Livestock_Desinfected_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Desinfected_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Desinfected_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Desinfected_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Desinfected_number - end

-- Number_selected_for_monitoring - start
SELECT		@Livestock_Number_selected_for_monitoring = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Number_selected_for_monitoring'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Number_selected_for_monitoring = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Number_selected_for_monitoring'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Number_selected_for_monitoring - end

-- Annihilated_number - start
SELECT		@Livestock_Annihilated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Annihilated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Annihilated_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Annihilated_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Annihilated_number - end

-- Slaughtered_number - start
SELECT		@Livestock_Slaughtered_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Slaughtered_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Slaughtered_number = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Slaughtered_number'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Slaughtered_number - end

-- Number_of_diseased_left - start
SELECT		@Livestock_Number_of_diseased_left = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Livestock_Number_of_diseased_left'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0

SELECT		@Avian_Number_of_diseased_left = p.idfsParameter
FROM		dbo.trtFFObjectForCustomReport ff_for_cr
INNER JOIN	dbo.ffParameter p
ON			p.idfsParameter = ff_for_cr.idfsFFObject
WHERE		ff_for_cr.strFFObjectAlias = N'Avian_Number_of_diseased_left'
			AND ff_for_cr.idfsCustomReportType = @idfsSummaryReportType
			AND ff_for_cr.intRowStatus = 0
-- Number_of_diseased_left - end


CREATE TABLE #VetCaseTable
(	idfID							BIGINT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
	idfVetCase						BIGINT NOT NULL,
	strDiagnosisSpeciesKey			NVARCHAR(200) COLLATE DATABASE_DEFAULT NOT NULL,
	idfsDiagnosis					BIGINT NOT NULL,
	strDiagnosisName				NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	strOIECode						NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	strSpecies						NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
	SpeciesOrderColumn				INT NULL,
	DiagnosisOrderColumn			INT NULL,
	idfsSpeciesType					BIGINT NOT NULL,
	idfSpecies						BIGINT NOT NULL,
	idfObservation					BIGINT NOT NULL,
	intDeadAnimalQty				INT NULL,
	intSickAnimalQty				INT NULL,
	intTotalAnimalQty				INT NULL,
	intVaccinatedNumber				INT NULL,
	intVaccinatedNumber_FF			INT NULL,
	intQuarantinedNumber			INT NULL,
	intDesinfectedNumber			INT NULL,
	intSelectedForMonitoringNumber	INT NULL,
	intAnnihilatedNumber			INT NULL,
	intSlaughteredNumber			INT NULL,
	intDiseasedLeftNumber			INT NULL
)

INSERT INTO	#VetCaseTable
(	idfVetCase,
	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	idfsSpeciesType,
	idfSpecies,
	idfObservation,
	intDeadAnimalQty,
	intSickAnimalQty,
	intTotalAnimalQty,
	intVaccinatedNumber,
	intVaccinatedNumber_FF,
	intQuarantinedNumber,
	intDesinfectedNumber,
	intSelectedForMonitoringNumber,
	intAnnihilatedNumber,
	intSlaughteredNumber,
	intDiseasedLeftNumber
)
SELECT		vc.idfVetCase as idfVetCase,
			CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType) as NVARCHAR(20)) as strDiagnosisSpeciesKey,
			ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis) as idfsDiagnosis,
			ISNULL(r_d.[name], N'') as strDiagnosisName,
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')) as strOIECode,
			ISNULL(r_sp.[name], N'') as strSpecies,
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)) as SpeciesOrderColumn,
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)) as DiagnosisOrderColumn,
			ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType) as idfsSpeciesType,
			sp.idfSpecies as idfSpecies,
			obs.idfObservation as idfObservation,
			ISNULL(sp.intDeadAnimalQty, 0) as intDeadAnimalQty,
			ISNULL(sp.intSickAnimalQty, 0) as intSickAnimalQty,
			ISNULL(sp.intTotalAnimalQty, ISNULL(sp.intDeadAnimalQty, 0) + ISNULL(sp.intSickAnimalQty, 0)) as intTotalAnimalQty,
			MAX(ISNULL(vac.intNumberVaccinated, 0)) as intNumberVaccinated,
			ISNULL(CAST(Vaccinated_number.varValue AS INT), 0) as intNumberVaccinated_FF,
			ISNULL(CAST(Quarantined_number.varValue AS INT), 0) as intQuarantinedNumber,
			ISNULL(CAST(Desinfected_number.varValue AS INT), 0) as intDesinfectedNumber,
			ISNULL(CAST(Number_selected_for_monitoring.varValue AS INT), 0) as intSelectedForMonitoringNumber,
			ISNULL(CAST(Annihilated_number.varValue AS INT), 0) as intAnnihilatedNumber,
			ISNULL(CAST(Slaughtered_number.varValue AS INT), 0) as intSlaughteredNumber,
			ISNULL(CAST(Number_of_diseased_left.varValue AS INT), 0) as intDiseasedLeftNumber
FROM		
-- Veterinary Case
			dbo.tlbVetCase vc

-- Diagnosis = Final Diagnosis of Veterinary Case
INNER JOIN	dbo.trtDiagnosis d
	INNER JOIN	dbo.FN_GBL_DiagnosisRepair(@LangID, 19000019, null) r_d
	ON			r_d.idfsDiagnosis = d.idfsDiagnosis

	-- Not deleted diagnosis with the same name and using type
	OUTER APPLY (
 		SELECT TOP 1
 					d_actual.idfsDiagnosis, r_d_actual.intOrder, d_actual.strOIECode
 		FROM		dbo.trtDiagnosis d_actual
		INNER JOIN	dbo.FN_GBL_Reference_GETList(@LangID, 19000019) r_d_actual
		ON			r_d_actual.idfsReference = d_actual.idfsDiagnosis
 		WHERE		d_actual.idfsUsingType = d.idfsUsingType
					AND d_actual.intRowStatus = 0
					AND r_d_actual.[name] = r_d.[name]
 		ORDER BY d_actual.idfsDiagnosis ASC
 			) AS  Actual_Diagnosis
				
ON			d.idfsDiagnosis = vc.idfsFinalDiagnosis
			AND d.idfsUsingType = 10020001	/*Case-based*/

-- Species - start
INNER JOIN	dbo.tlbFarm f
-- Region and Rayon
	LEFT JOIN	dbo.tlbGeoLocation gl
		LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg
		ON			reg.idfsReference = gl.idfsRegion
		LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray
		ON			ray.idfsReference = gl.idfsRayon
	ON			gl.idfGeoLocation = f.idfFarmAddress
ON			f.idfFarm = vc.idfFarm
			AND f.intRowStatus = 0
INNER JOIN	dbo.tlbHerd h
ON			h.idfFarm = f.idfFarm
			AND h.intRowStatus = 0
INNER JOIN	dbo.tlbSpecies sp
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) r_sp
	ON			r_sp.idfsReference = sp.idfsSpeciesType

	-- Not deleted species type with the same name
	OUTER APPLY (
 		SELECT TOP 1
 					st_actual.idfsSpeciesType, r_sp_actual.intOrder
 		FROM		dbo.trtSpeciesType st_actual
		INNER JOIN	dbo.FN_GBL_Reference_GETList(@LangID, 19000086) r_sp_actual
		ON			r_sp_actual.idfsReference = st_actual.idfsSpeciesType
 		WHERE		st_actual.intRowStatus = 0
					AND r_sp_actual.[name] = r_sp.[name]
 		ORDER BY st_actual.idfsSpeciesType ASC
 			) AS  Actual_Species_Type

ON			sp.idfHerd = h.idfHerd
			AND sp.intRowStatus = 0
			-- not blank value in Sick and/or Dead fields
			AND (	sp.intDeadAnimalQty IS NOT NULL
					or sp.intSickAnimalQty IS NOT NULL
				)
-- Species - end

-- Site, Organization entered case
INNER JOIN	dbo.tstSite s 
	LEFT JOIN	dbo.FN_GBL_Institution_Min(@LangID) i
	ON			i.idfOffice = CASE WHEN s.intFlags = 10 THEN @SpecificOfficeId ELSE s.idfOffice END
ON			s.idfsSite = vc.idfsSite

-- Specific Region and Rayon for the site with specific attributes (B46)
LEFT JOIN	dbo.trtBaseReferenceAttribute bra
	LEFT JOIN	dbo.trtGISBaseReferenceAttribute gis_bra_region
		INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) reg_specific
		ON			reg_specific.idfsReference = gis_bra_region.idfsGISBaseReference
	ON			CAST(gis_bra_region.varValue as NVARCHAR) = CAST(bra.varValue as NVARCHAR)
				AND gis_bra_region.idfAttributeType = @vet_form_1_specific_gis_region
	LEFT JOIN	dbo.trtGISBaseReferenceAttribute gis_bra_rayon
		INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) ray_specific
		ON			ray_specific.idfsReference = gis_bra_rayon.idfsGISBaseReference
	ON			CAST(gis_bra_rayon.varValue as NVARCHAR) = CAST(bra.varValue as NVARCHAR)
				AND gis_bra_rayon.idfAttributeType = @vet_form_1_specific_gis_rayon
ON			bra.idfsBaseReference = i.idfsOfficeAbbreviation
			AND bra.idfAttributeType = @vet_form_1_use_specific_gis
			AND CAST(bra.varValue as NVARCHAR) = s.strSiteID

-- Vaccination records
LEFT JOIN	dbo.tlbVaccination vac
ON			vac.idfVetCase = vc.idfVetCase
			AND vac.idfSpecies = sp.idfSpecies
			AND vac.idfsDiagnosis = d.idfsDiagnosis -- NOT from specification, but from common sense
			AND vac.intNumberVaccinated IS NOT NULL
			AND vac.intRowStatus = 0


-- Species Observation
LEFT JOIN	dbo.tlbObservation	obs
ON			obs.idfObservation = sp.idfObservation


-- FF values

-- Vaccinated_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Vaccinated_number, @Avian_Vaccinated_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
			AND NOT EXISTS	(
						SELECT	*
						FROM	dbo.tlbVaccination vac_ex
						WHERE	vac_ex.idfVetCase = vc.idfVetCase
								AND vac_ex.idfSpecies = sp.idfSpecies
								AND vac_ex.idfsDiagnosis = d.idfsDiagnosis -- NOT from specification, but from common sense
								AND vac_ex.intNumberVaccinated IS NOT NULL
								AND vac_ex.intRowStatus = 0
							)
 			ORDER BY ap.idfRow ASC
 		) AS  Vaccinated_number

-- Quarantined_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Quarantined_number, @Avian_Quarantined_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Quarantined_number

-- Desinfected_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Desinfected_number, @Avian_Desinfected_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Desinfected_number

-- Number_selected_for_monitoring
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Number_selected_for_monitoring, @Avian_Number_selected_for_monitoring)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Number_selected_for_monitoring

-- Annihilated_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Annihilated_number, @Avian_Annihilated_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Annihilated_number

-- Slaughtered_number
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Slaughtered_number, @Avian_Slaughtered_number)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Slaughtered_number

-- Number_of_diseased_left
OUTER APPLY ( 
 	SELECT TOP 1
 			ap.varValue
 	FROM	dbo.tlbActivityParameters ap
 	WHERE	ap.idfObservation = obs.idfObservation
			AND ap.idfsParameter IN (@Livestock_Number_of_diseased_left, @Avian_Number_of_diseased_left)
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') IN ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			AND ap.varValue IS NOT NULL
 			ORDER BY ap.idfRow ASC
 		) AS  Number_of_diseased_left


WHERE		vc.intRowStatus = 0
			-- Case Classification = Confirmed
			AND vc.idfsCaseClassification = 350000000	/*Confirmed*/
			
			-- From Year, Month To Year, Month
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) >= @StartDate
			AND ISNULL(vc.datFinalDiagnosisDate, vc.datTentativeDiagnosis1Date) < @EndDate
			
			-- Region
			AND (@RegionID IS NULL OR (@RegionID IS NOT NULL AND ISNULL(reg_specific.idfsReference, reg.idfsReference) = @RegionID))
			-- Rayon
			AND (@RayonID IS NULL OR (@RayonID IS NOT NULL AND ISNULL(ray_specific.idfsReference, ray.idfsReference) = @RayonID))
			
			-- Entered BY organization
			AND (@OrganizationEntered IS NULL OR (@OrganizationEntered IS NOT NULL AND i.idfOffice = @OrganizationEntered))

GROUP BY	vc.idfVetCase,
			CAST(ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis) as NVARCHAR(20)) + N'_' + 
				CAST(ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType) as NVARCHAR(20)),
			ISNULL(Actual_Diagnosis.idfsDiagnosis, d.idfsDiagnosis),
			ISNULL(r_d.[name], N''),
			ISNULL(Actual_Diagnosis.strOIECode, ISNULL(d.strOIECode, N'')),
			ISNULL(r_sp.[name], N''),
			ISNULL(Actual_Species_Type.intOrder, ISNULL(r_sp.intOrder, -1000)),
			ISNULL(Actual_Diagnosis.intOrder, ISNULL(r_d.intOrder, -1000)),
			ISNULL(Actual_Species_Type.idfsSpeciesType, sp.idfsSpeciesType),
			sp.idfSpecies,
			obs.idfObservation,
			ISNULL(sp.intDeadAnimalQty, 0),
			ISNULL(sp.intSickAnimalQty, 0),
			ISNULL(sp.intTotalAnimalQty, ISNULL(sp.intDeadAnimalQty, 0) + ISNULL(sp.intSickAnimalQty, 0)),
			ISNULL(CAST(Vaccinated_number.varValue AS INT), 0),
			ISNULL(CAST(Quarantined_number.varValue AS INT), 0),
			ISNULL(CAST(Desinfected_number.varValue AS INT), 0),
			ISNULL(CAST(Number_selected_for_monitoring.varValue AS INT), 0),
			ISNULL(CAST(Annihilated_number.varValue AS INT), 0),
			ISNULL(CAST(Slaughtered_number.varValue AS INT), 0),
			ISNULL(CAST(Number_of_diseased_left.varValue AS INT), 0)

INSERT INTO	@Result
(	strDiagnosisSpeciesKey,
	idfsDiagnosis,
	strDiagnosisName,
	strOIECode,
	strSpecies,
	intNumberSensSpecies,
	intNumberUnhealthySt,
	intNumberSick,
	intNumberDead,
	intNumberVaccinated,
	intOtherMeasures,
	intNumberAnnihilated,
	intNumberSlaughtered,
	intNumberUnhealthyStLeft,
	intNumberDiseased,
	SpeciesOrderColumn,
	DiagnosisOrderColumn,
	strFooterPerformer
)
SELECT DISTINCT
			vct.strDiagnosisSpeciesKey,
			vct.idfsDiagnosis,
			vct.strDiagnosisName,
			vct.strOIECode,
			vct.strSpecies,
			sum(ISNULL(vct.intTotalAnimalQty, 0) - ISNULL(vct.intSickAnimalQty, 0) - ISNULL(vct.intDeadAnimalQty, 0)), /*intNumberSensSpecies - Number of sensitive species*/
			count(vct.idfVetCase), /*intNumberUnhealthySt - Number of unhealthy stations*/
			sum(ISNULL(vct.intSickAnimalQty, 0)), /*intNumberSick - Number of sick*/
			sum(ISNULL(vct.intDeadAnimalQty, 0)), /*intNumberDead - Number of dead*/
			sum(ISNULL(vct.intVaccinatedNumber, 0) + ISNULL(vct.intVaccinatedNumber_FF, 0)), /*intNumberVaccinated - Vaccinated*/
			sum(ISNULL(vct.intQuarantinedNumber, 0) + 
				ISNULL(vct.intDesinfectedNumber, 0) + 
				ISNULL(vct.intSelectedForMonitoringNumber, 0)), /*intOtherMeasures - Other measures (disinfection, monitoring and etc.)*/
			sum(ISNULL(vct.intAnnihilatedNumber, 0)), /*intNumberAnnihilated - Annihilated*/
			sum(ISNULL(vct.intSlaughteredNumber, 0)), /*intNumberSlaughtered - Slaughtered*/
			0, /*intNumberUnhealthyStLeft - Left until the end of the reported period: Number of unhealthy stations*/
			sum(ISNULL(vct.intDiseasedLeftNumber, 0)), /*intNumberDiseased - Left until the end of the reported period: Number of diseased*/
			vct.SpeciesOrderColumn,
			vct.DiagnosisOrderColumn,
			@FooterNameOfPerformer

FROM		#VetCaseTable vct

GROUP BY	vct.strDiagnosisSpeciesKey,
			vct.idfsDiagnosis,
			vct.strDiagnosisName,
			vct.strOIECode,
			vct.strSpecies,
			vct.SpeciesOrderColumn,
			vct.DiagnosisOrderColumn

/*intNumberUnhealthyStLeft - Left until the end of the reported period: Number of unhealthy stations*/
update		r
SET			r.intNumberUnhealthyStLeft = 
			(	SELECT	count(vct.idfVetCase)
				FROM	#VetCaseTable vct
				WHERE	vct.strDiagnosisSpeciesKey = r.strDiagnosisSpeciesKey
						AND vct.intDiseasedLeftNumber > 0
			)
FROM		@Result r

-- Select report informative part - start

-- Return results
if (SELECT count(*) FROM @result) = 0
	SELECT	'' as strDiagnosisSpeciesKey,
	- 1 as idfsDiagnosis,
	'' as strDiagnosisName,
	'' as strOIECode, 
	'' as strSpecies,
	null as intNumberSensSpecies, 
	null as intNumberUnhealthySt, 
	null as intNumberSick, 
	null as intNumberDead, 
	null as intNumberVaccinated, 
	null as intOtherMeasures, 
	null as intNumberAnnihilated, 
	null as intNumberSlaughtered, 
	null as intNumberUnhealthyStLeft, 
	null as intNumberDiseased, 
	null as SpeciesOrderColumn, 
	null as DiagnosisOrderColumn, 
	@FooterNameOfPerformer as strFooterPerformer
else
	SELECT * FROM @result ORDER BY DiagnosisOrderColumn, strDiagnosisName, idfsDiagnosis, SpeciesOrderColumn


-- Drop temporary tables
if Object_ID('tempdb..#VetCaseTable') IS NOT NULL
BEGIN
	SET	@drop_cmd = N'drop table #VetCaseTable'
	execute sp_executesql @drop_cmd
END
	     
END

