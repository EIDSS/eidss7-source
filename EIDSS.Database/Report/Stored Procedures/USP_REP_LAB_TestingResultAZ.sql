

--*************************************************************************
-- Name 				: report.USP_REP_LAB_TestingResultAZ
-- Description			: This procedure used in Laboratory Testing Results report.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_LAB_TestingResultAZ 'en', 'SAZXR000110003', NULL, 871
EXEC report.USP_REP_LAB_TestingResultAZ 'ru', 'SWAZ160001', NULL, 871
*/

CREATE PROCEDURE [Report].[USP_REP_LAB_TestingResultAZ]
	(
		@LangID		AS NVARCHAR(10), 
		@SampleID	AS VARCHAR(36),
		@DepartmentID  AS BIGINT,
		@SiteID AS BIGINT = NULL
	)
AS	

-- Field description may be found here
-- https://95.167.107.114/BTRP/Project_Documents/08x-Implementation/Customizations/AJ/AJ Customization_Phase_2/Reports/Laboratory testing results/Specification for reportdevelopment -Laboratory testing results.docx
-- by number marked red at screen form prototype 


DECLARE	@ReportTable TABLE
(	
	strCaseId				NVARCHAR(200) COLLATE database_default NULL, --1
	strReceivedOrganizationNameAddress	NVARCHAR(2000) COLLATE database_default NULL, --14
	strPatientName			NVARCHAR(2000) COLLATE database_default NULL,--5
	strSex					NVARCHAR(200) COLLATE database_default NULL, --6
	datDateOfBirth			DATETIME NULL,	   --7
	strAge		 			NVARCHAR(200) COLLATE database_default NULL, --8
	strAddress 				NVARCHAR(4000) COLLATE database_default NULL,--9
	strDiagnosis 			NVARCHAR(2000) COLLATE database_default NULL, --4
	strSampleId 			NVARCHAR(200) COLLATE database_default NULL, --17
	strSampleType 			NVARCHAR(2000) COLLATE database_default NULL, --10
	strTestName 			NVARCHAR(2000) COLLATE database_default NULL, --19
	strResult				NVARCHAR(2000) COLLATE database_default NULL, --20
	datFooterDate			DATETIME NULL,	   --
	
	--- new fields
	
	datCollectionDate		DATETIME NULL,	   --11
	strSentOrganizationNameAddress	NVARCHAR(2000) COLLATE database_default NULL, --12
	datSentDate				DATETIME NULL,	   --13
	datAccessionDate		DATETIME NULL,	   --15
	strSampleConditionReceived	NVARCHAR(2000) COLLATE database_default NULL, --16
	datResultDate			DATETIME NULL,	   --21
	strTestedBy				NVARCHAR(2000) COLLATE database_default null --22
)	

-- Report informative part

DECLARE	@MaterialTable 	TABLE
(	idfMaterial				BIGINT NOT NULL PRIMARY KEY,
	idfRootMaterial			BIGINT NULL,
	idfParentMaterial		BIGINT NULL,
	strCaseId				NVARCHAR(200) COLLATE database_default NULL, --
	strPatientName			NVARCHAR(2000) COLLATE database_default NULL,--
	strSex					NVARCHAR(200) COLLATE database_default NULL, --
	datDateOfBirth			DATETIME NULL,	   --
	strAge		 			NVARCHAR(200) COLLATE database_default NULL, --
	strAddress 				NVARCHAR(4000) COLLATE database_default NULL,--
	strDiagnosis 			NVARCHAR(2000) COLLATE database_default NULL, --
	strSampleId 			NVARCHAR(200) COLLATE database_default NULL, --
	strSampleType 			NVARCHAR(2000) COLLATE database_default NULL, --
	
	datCollectionDate		DATETIME NULL,	   --11
	strSentOrganizationNameAddress	NVARCHAR(2000) COLLATE database_default NULL, --12
	datSentDate				DATETIME NULL,	   --13
	datAccessionDate		DATETIME NULL,	   --15
	strSampleConditionReceived	NVARCHAR(2000) COLLATE database_default NULL, --16
	datResultDate			DATETIME NULL,	   --21
	strTestedBy				NVARCHAR(2000) COLLATE database_default null --22

)	

-- Header

DECLARE	@CurrentCountry	NVARCHAR(2000)
SELECT		@CurrentCountry = r_c.[name]
FROM		gisCountry c
INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) r_c
ON			r_c.idfsReference = c.idfsCountry
WHERE		c.intRowStatus = 0
			AND c.idfsCountry = report.FN_GBL_CurrentCountry_GET()

DECLARE	@RayonID	BIGINT
DECLARE	@RegionID	BIGINT
DECLARE	@OrganizationID_GenerateReport	BIGINT
DECLARE	@OrganizationName_GenerateReport	NVARCHAR(2000)

SELECT		@OrganizationID_GenerateReport = i.idfOffice,
			@OrganizationName_GenerateReport = i.[name],
			@RegionID = gls.idfsRegion,
			@RayonID = gls.idfsRayon
FROM		report.FN_REP_InstitutionRepair(@LangID) i
INNER JOIN	tstSite s
ON			s.idfOffice = i.idfOffice
LEFT JOIN	tlbGeoLocationShared gls
ON			gls.idfGeoLocationShared = i.idfLocation
where		s.idfsSite = @SiteID

if	@OrganizationName_GenerateReport IS NULL
	SET	@OrganizationName_GenerateReport = N''


DECLARE	@Header	NVARCHAR(4000)
SET	@Header = N''


DECLARE	@Rayon_Name				NVARCHAR(2000)
SELECT		@Rayon_Name = r_ray.[name],
			@RegionID = 
			CASE
				WHEN	@RegionID IS NULL
					THEN	ray.idfsRayon
				ELSE	@RegionID
			END
FROM		report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) r_ray /*Rayon*/
INNER JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) ray
on			ray.idfsRayon = r_ray.idfsReference
where		r_ray.idfsReference = @RayonID
if	@Rayon_Name IS NULL
	SET	@Rayon_Name = N''


DECLARE	@Region_Name			NVARCHAR(2000)
DECLARE	@Hide_Region			bit
SELECT		@Region_Name = r_reg.[name],
			@Hide_Region =
			CASE
				WHEN	gis_bra.idfGISBaseReferenceAttribute IS NULL
					THEN	CAST(0 AS bit)
				ELSE	CAST(1 AS bit)
			END
FROM		report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) r_reg /*Region*/
LEFT JOIN	trtGISBaseReferenceAttribute gis_bra
	INNER JOIN	trtAttributeType at
	on			at.idfAttributeType = gis_bra.idfAttributeType
				AND at.strAttributeTypeName = N'hide_region_from_report_header'
on			gis_bra.idfsGISBaseReference = r_reg.idfsReference
			AND gis_bra.strAttributeItem = N'AZ Human Lab Reports'
			AND CAST(gis_bra.varValue AS NVARCHAR) = CAST(N'AZ Human Lab Reports' AS NVARCHAR(20))
where		r_reg.idfsReference = @RegionID
if	@Region_Name IS NULL
	SET	@Region_Name = N''
if	@Hide_Region IS NULL
	SET	@Hide_Region = 1

DECLARE	@Region_Rayon_Info	NVARCHAR(4000)
SET	@Region_Rayon_Info = N''

IF @RegionID IS NULL
	SET	@Region_Rayon_Info = N''
ELSE IF @RegionID IS NOT NULL AND (@RayonID IS NULL	or LTRIM(RTRIM(@Rayon_Name)) = N'')
BEGIN
	SET	@Region_Rayon_Info = ISNULL(@Region_Name, N'')
END
ELSE IF @RegionID IS NOT NULL AND @RayonID IS NOT NULL AND LTRIM(RTRIM(@Rayon_Name)) <> N''
BEGIN
	if	@Hide_Region = 1
		SET	@Region_Rayon_Info = ISNULL(@Rayon_Name, N'')
	ELSE
		SET	@Region_Rayon_Info = ISNULL(@Region_Name, N'') + N', ' + ISNULL(@Rayon_Name, N'')
END


IF rtrim(ltrim(@Region_Rayon_Info)) = N'' or @OrganizationID_GenerateReport IS NULL
BEGIN
	SET	@Header = @OrganizationName_GenerateReport
END
ELSE IF rtrim(ltrim(@Region_Rayon_Info)) <> N'' AND @OrganizationID_GenerateReport IS NOT NULL
BEGIN
	SET	@Header = @OrganizationName_GenerateReport + N', ' + @Region_Rayon_Info
END


-- Report informative part


insert into	@MaterialTable
(	idfMaterial,
	idfRootMaterial,
	idfParentMaterial,
	strCaseId,
	strPatientName,
	strSex,
	datDateOfBirth,
	strAge,
	strAddress,
	strDiagnosis,
	strSampleId,
	strSampleType,
	
	--new fields
	datCollectionDate,
	strSentOrganizationNameAddress,
	datSentDate,
	datAccessionDate,
	strSampleConditionReceived
)
SELECT		m.idfMaterial,
			m.idfRootMaterial,
			m.idfParentMaterial,
			ISNULL(hc.strCaseID, N''),
			report.FN_REP_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName),
			ISNULL(r_ps.[name], N''),
			h.datDateofBirth,
			CASE
				WHEN	hc.intPatientAge IS NOT NULL AND r_hat.[name] IS NOT NULL
					THEN	CAST(hc.intPatientAge AS NVARCHAR(20)) + ISNULL(N' (' + r_hat.[name] + N')', N'')
				ELSE	null
			END,
			r_cnt.name + 
				ISNULL(', ' + CASE WHEN gis_HideReg.idfGISBaseReferenceAttribute IS NOT NULL THEN NULL ELSE r_reg.name END, '' ) +
				ISNULL(', ' + r_ray.name, '') 
			,
			ISNULL(r_d.[name], N''),
			ISNULL(m.strBarcode, N''),
			ISNULL(r_st.[name], N''),
			
			--new fields
			m.datFieldCollectionDate,
			CASE WHEN m.idfParentMaterial IS NULL 
					THEN sentByOffice.name
					ELSE trOut_SendFromOffice.name
			END AS strSentOrganizationNameAddress,
			m.datFieldSentDate,
			m.datAccession,
			acsCond.name AS strSampleConditionReceived
			
FROM		tlbMaterial m

INNER JOIN	tlbHuman h
	LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000043) r_ps	/*Human Gender*/
	on			r_ps.idfsReference = h.idfsHumanGender
	LEFT JOIN	tlbGeoLocation gl
	on			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	--LEFT JOIN	fnGeoLocationTranslation(@LangID) glt
	--on			glt.idfGeoLocation = h.idfCurrentResidenceAddress
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) r_cnt /*Country*/
	on r_cnt.idfsReference = gl.idfsCountry
	
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) r_ray /*Rayon*/
	on r_ray.idfsReference = gl.idfsRayon
	
	LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) r_reg /*Region*/
		LEFT JOIN	trtGISBaseReferenceAttribute gis_HideReg
			INNER JOIN	trtAttributeType at
			ON			at.idfAttributeType = gis_HideReg.idfAttributeType
						AND at.strAttributeTypeName = N'hide_region_from_report_header'
		ON			gis_HideReg.idfsGISBaseReference = r_reg.idfsReference
					AND gis_HideReg.strAttributeItem = N'AZ Human Lab Reports'
					AND CAST(gis_HideReg.varValue AS NVARCHAR) = CAST(N'AZ Human Lab Reports' AS NVARCHAR(20))
	ON r_reg.idfsReference = gl.idfsRegion
	
	
	
ON			h.idfHuman = m.idfHuman
INNER JOIN	tlbHumanCase hc
	LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d /*Diagnosis*/
	ON			r_d.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
	LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000042) r_hat	/*Human Age Type*/
	ON			r_hat.idfsReference = hc.idfsHumanAgeType	
ON			hc.idfHuman = h.idfHuman
			AND hc.intRowStatus = 0

INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000087) r_st	/*Sample Type*/
ON			r_st.idfsReference = m.idfsSampleType

LEFT JOIN report.FN_REP_InstitutionRepair(@LangID) sentByOffice
ON sentByOffice.idfOffice = hc.idfSentByOffice

LEFT JOIN tlbMaterial parentMaterial
	LEFT JOIN tlbTransferOutMaterial ttom
		INNER JOIN tlbTransferOUT tto
		ON tto.idfTransferOut = ttom.idfTransferOut
		LEFT JOIN report.FN_REP_InstitutionRepair(@LangID) trOut_SendFromOffice
		ON trOut_SendFromOffice.idfOffice = tto.idfSendFromOffice
	ON ttom.idfMaterial = parentMaterial.idfMaterial
ON parentMaterial.idfMaterial = m.idfParentMaterial

LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000110) acsCond
ON acsCond.idfsReference = m.idfsAccessionCondition

WHERE		m.intRowStatus = 0
			AND m.idfsCurrentSite = @SiteID /*Sample belongs to current laboratory*/
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND ISNULL(m.blnReadOnly, 0) <> 1 /*It is not copy of another sample*/
			AND ISNULL(m.idfsAccessionCondition,0) <> 10108003 /*Rejected*/
			AND m.strBarcode = @SampleID /*Sample has specified Lab ID*/


DECLARE	@ChildMaterials	TABLE
(	idfRootMaterial		BIGINT NULL,
	idfMaterial			BIGINT NOT NULL PRIMARY KEY,
	idfParentMaterial	BIGINT NULL	
)

INSERT INTO	@ChildMaterials
(
	idfRootMaterial,
	idfMaterial,
	idfParentMaterial
)
SELECT		mt.idfRootMaterial,
			mt.idfMaterial,
			mt.idfParentMaterial
FROM		@MaterialTable mt
	INNER JOIN tlbMaterial m
	ON m.idfMaterial = mt.idfMaterial
	AND (m.idfInDepartment = @DepartmentID or @DepartmentID IS NULL)
	

DECLARE	@rowaffected	INT
SET	@rowaffected = 1

WHILE	@rowaffected > 0
BEGIN
	INSERT INTO	@ChildMaterials
	(
		idfRootMaterial,
		idfMaterial,
		idfParentMaterial
	)
	SELECT	distinct
				m.idfRootMaterial,
				m.idfMaterial,
				m.idfParentMaterial
	FROM		tlbMaterial m
	LEFT JOIN	tstSite s
	ON			s.idfsSite = m.idfsSite
	INNER JOIN	@ChildMaterials cm_parent
	ON			cm_parent.idfMaterial = m.idfParentMaterial
	LEFT JOIN	@ChildMaterials cm_ex
	ON			cm_ex.idfMaterial = m.idfMaterial
	WHERE		m.intRowStatus = 0
				AND (m.idfInDepartment = @DepartmentID or @DepartmentID IS NULL)
				AND (ISNULL(m.blnAccessioned, 0) = 0 or s.idfsSite = @SiteID)
				AND cm_ex.idfMaterial IS NULL

	SET	@rowaffected = @@rowcount
END


INSERT INTO	@ReportTable
(	strCaseId,
	strReceivedOrganizationNameAddress,
	strPatientName,
	strSex,
	datDateOfBirth,
	strAge,
	strAddress,
	strDiagnosis,
	strSampleId,
	strSampleType,
	strTestName,
	strResult,
	datFooterDate,
	
	--new fields
	datCollectionDate,	   --11
	strSentOrganizationNameAddress, --12
	datSentDate,	   --13
	datAccessionDate,	   --15
	strSampleConditionReceived, --16
	datResultDate,	   --21
	strTestedBy	--22
)
SELECT		mt.strCaseId,
			@Header,
			mt.strPatientName,
			mt.strSex,
			mt.datDateOfBirth,
			mt.strAge,
			mt.strAddress,
			mt.strDiagnosis,
			mt.strSampleId,
			mt.strSampleType,
			r_tn.[name],
			r_tr.[name],
			NULL,
			
			mt.datCollectionDate,
			mt.strSentOrganizationNameAddress,
			mt.datSentDate,
			mt.datAccessionDate,
			mt.strSampleConditionReceived,
			t.datConcludedDate,
			CASE 
				WHEN ISNULL(t.blnExternalTest, 0) = 0 THEN report.FN_REP_ConcatFullName(p_TestedBy.strFamilyName, p_TestedBy.strFirstName, p_TestedBy.strSecondName)
				WHEN t.blnExternalTest = 1 THEN o_ResultReceivedFrom.name + ISNULL(', ' + t.strContactPerson, '')
				ELSE null
			END AS strTestedBy
FROM		@MaterialTable mt
LEFT JOIN	tlbTesting t
	LEFT JOIN tlbPerson p_TestedBy
	ON p_TestedBy.idfPerson = t.idfTestedByPerson

	LEFT JOIN report.FN_REP_InstitutionRepair(@LangID) o_ResultReceivedFrom
	ON o_ResultReceivedFrom.idfOffice = t.idfPerformedByOffice
	
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000097) r_tn /*Test Name*/
	ON			r_tn.idfsReference = t.idfsTestName
	LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000096) r_tr /*Test Result*/
	ON			r_tr.idfsReference = t.idfsTestResult
ON			t.intRowStatus = 0
			AND ISNULL(t.blnNonLaboratoryTest, 0) <> 1 /*Laboratory Test*/
			AND ISNULL(t.blnReadOnly, 0) <> 1 /*It is not copy of another test*/
			/*Test belongs to any child of the sample or it is external result for the sample transferred to not EIDSS laboratory*/
			AND exists	(
					SELECT	*
					FROM	@ChildMaterials cm
					where	cm.idfMaterial = t.idfMaterial
						)
			/*Test Status is Final or Amended*/
			AND (	t.idfsTestStatus = 10001001	/*Final*/
					or	t.idfsTestStatus = 10001006 /*Amended*/
				)
	
IF	EXISTS	(
		SELECT	*
		FROM	@ReportTable
			)
BEGIN
	SELECT 
		strCaseId,
		strReceivedOrganizationNameAddress,
		strPatientName,
		strSex,
		datDateOfBirth,
		strAge,
		strAddress,
		strDiagnosis,
		strSampleId,
		strSampleType,
		strTestName,
		strResult,
		datFooterDate,
		
		--new fields
		datCollectionDate,	   --11
		strSentOrganizationNameAddress, --12
		datSentDate,	   --13
		datAccessionDate,	   --15
		strSampleConditionReceived, --16
		datResultDate,	   --21
		strTestedBy	--22
	FROM @ReportTable
END
ELSE IF	EXISTS	(
			SELECT	*
			FROM	@MaterialTable
				)
BEGIN	
	SELECT		mt.strCaseId,
				@Header AS strReceivedOrganizationNameAddress,
				mt.strPatientName,
				mt.strSex,
				mt.datDateOfBirth,
				mt.strAge,
				mt.strAddress,
				mt.strDiagnosis,
				mt.strSampleId,
				mt.strSampleType,
				CAST(NULL AS NVARCHAR) AS strTestName,
				CAST(NULL AS NVARCHAR) AS strResult,
				CAST(NULL AS DATE) AS datFooterDate,
				
				--new fields
				mt.datCollectionDate,	   --11
				mt.strSentOrganizationNameAddress, --12
				mt.datSentDate,	   --13
				mt.datAccessionDate,	   --15
				mt.strSampleConditionReceived, --16
				CAST(NULL AS DATE) AS datResultDate,	   --21
				CAST(NULL AS NVARCHAR) AS strTestedBy	--22
	
	FROM		@MaterialTable mt	
END
ELSE
BEGIN
	SELECT		'' AS strCaseId,
				@Header AS strReceivedOrganizationNameAddress,
				'' AS strPatientName,
				'' AS strSex,
				CAST(NULL AS DATE) AS datDateOfBirth,
				'' AS strAge,
				'' AS strAddress,
				'' AS strDiagnosis,
				'' AS strSampleId,
				'' AS strSampleType,
				CAST(NULL AS NVARCHAR) AS strTestName,
				CAST(NULL AS NVARCHAR) AS strResult,
				CAST(NULL AS DATE) AS datFooterDate,
				
				--new fields
				CAST(NULL AS DATE) AS datCollectionDate,	   --11
				CAST(NULL AS NVARCHAR) AS strSentOrganizationNameAddress, --12
				CAST(NULL AS DATE) AS datSentDate,	   --13
				CAST(NULL AS DATE) AS datAccessionDate,	   --15
				CAST(NULL AS NVARCHAR) AS strSampleConditionReceived, --16
				CAST(NULL AS DATE) AS datResultDate,	   --21
				CAST(NULL AS NVARCHAR) AS strTestedBy	--22
				
				
				
END


