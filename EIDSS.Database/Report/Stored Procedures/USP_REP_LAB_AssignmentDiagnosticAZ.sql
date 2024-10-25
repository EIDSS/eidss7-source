
--*************************************************************************
-- Name 				: report.USP_REP_LAB_AssignmentDiagnosticAZ
-- DescriptiON			: This procedure used in Assignment For Laboratory Diagnostic report to populate the Main Body
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_LAB_AssignmentDiagnosticAZ 'en', 'HUMBA00019AS45', 955250000000
EXEC report.USP_REP_LAB_AssignmentDiagnosticAZ 'ru', 'HUMBA00019AS45', 955250000000
*/

CREATE PROCEDURE [Report].[USP_REP_LAB_AssignmentDiagnosticAZ]
	(
		@LangID		AS NVARCHAR(10), 
		@CaseID		AS VARCHAR(36),
		@SentToID	AS BIGINT,
		@SiteID		AS BIGINT = NULL
	)
AS	

-- Field description may be found here
--https://95.167.107.114/BTRP/Project_Documents/08x-Implementation/Customizations/AJ/AJ Customization EIDSS v6/Reports/Assignment for Laboratory Diagnostic/Specification for reportdevelopment - Assignment for Laboratory Diagnostic.docx
-- by number marked red at screen form prototype 

DECLARE	@ReportTable TABLE
(	
--- new fields
	strSentOrganizationNameAddress	NVARCHAR(4000) COLLATE database_default NULL, --3
	strCaseHistoryPatientCardID		NVARCHAR(4000) COLLATE database_default NULL, --5
	strTestForDisease 				NVARCHAR(2000) COLLATE database_default NULL, --1 from footer
	
	strReferringPhysiciansName		NVARCHAR(2000) COLLATE database_default NULL, --12
--- old fields
	strReceivedOrganizationNameAddress	NVARCHAR(4000) COLLATE database_default NULL, --4
	strPatientName				NVARCHAR(2000) COLLATE database_default NULL,--6
	strSex						NVARCHAR(200) COLLATE database_default NULL, --7
	datDateOfBirth				DATETIME NULL,	   --8
	strAge		 				NVARCHAR(200) COLLATE database_default NULL, --9
	strAddress 					NVARCHAR(4000) COLLATE database_default NULL,--10
	strDiagnosis 				NVARCHAR(2000) COLLATE database_default NULL, --11
	strSampleId 				NVARCHAR(200) COLLATE database_default NULL, --14
	strSampleType 				NVARCHAR(2000) COLLATE database_default NULL, --13
	datSampleCollectedDate		DATETIME NULL,	   --15
	datSampleSentDate			DATETIME NULL	   --16
	
)

DECLARE
	@strSentOrganizationNameAddress NVARCHAR(2000)
	



INSERT INTO	@ReportTable
(	
	
	strSentOrganizationNameAddress,
	strCaseHistoryPatientCardID,
	strTestForDisease,
	strReferringPhysiciansName,
	
	strReceivedOrganizationNameAddress,
	strPatientName,
	strSex,
	datDateOfBirth,
	strAge,
	strAddress,
	strDiagnosis,
	strSampleId,
	strSampleType,
	datSampleCollectedDate,
	datSampleSentDate
)
SELECT	
			notf_sent_by.name,
			null AS strCaseHistoryPatientCardID,
			dbo.FN_GBL_ConcatFullName(sent_by_empl.strFamilyName, sent_by_empl.strFirstName, sent_by_empl.strSecondName),
			null AS strReferringPhysiciansName,
			
			m_i_sent_to.name AS strSentOrganizationNameAddress,
			report.FN_REP_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName),
			ISNULL(r_ps.[name], N''),
			h.datDateofBirth,
			CASE
				WHEN	hc.intPatientAge is not null AND r_hat.[name] is not null
					THEN	CAST(hc.intPatientAge AS NVARCHAR(20)) + ISNULL(N' (' + r_hat.[name] + N')', N'')
				ELSE	NULL
			END,
			
			CASE
				WHEN	LTRIM(RTRIM(ISNULL(r_ray_cr.[name], N''))) <> N''
						AND gis_bra.idfsGISBaseReference is null
						AND LTRIM(RTRIM(ISNULL(r_reg_cr.[name], N''))) <> N''
					THEN	r_countr_cr.name  + N', ' +  r_reg_cr.[name] + N', ' + r_ray_cr.[name]
				WHEN	LTRIM(RTRIM(ISNULL(r_ray_cr.[name], N''))) <> N''
						AND (	gis_bra.idfsGISBaseReference is not null
								OR	LTRIM(RTRIM(ISNULL(r_reg_cr.[name], N''))) = N''
							)
					THEN	r_countr_cr.name  + N', ' +  r_ray_cr.[name]
				WHEN	LTRIM(RTRIM(ISNULL(r_ray_cr.[name], N''))) = N''
						AND LTRIM(RTRIM(ISNULL(r_reg_cr.[name], N''))) <> N''
					THEN	r_countr_cr.name  + N', ' +  r_reg_cr.[name]															 
				ELSE	''
			END
			
			
			,
			ISNULL(r_d.[name], N''),
			ISNULL(m.strFieldBarcode, N''),
			ISNULL(r_st.[name], N''),
			m.datFieldCollectionDate,
			m.datFieldSentDate
FROM		tlbHumanCase hc
LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r_d /*Diagnosis*/
ON			r_d.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000042) r_hat	/*Human Age Type*/
ON			r_hat.idfsReference = hc.idfsHumanAgeType	
LEFT JOIN	report.FN_REP_InstitutionRepair(@LangID) notf_sent_by
ON			notf_sent_by.idfOffice = hc.idfSentByOffice
	
INNER JOIN	tlbHuman h
	LEFT JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000043) r_ps	/*Human Gender*/
	ON			r_ps.idfsReference = h.idfsHumanGender
	LEFT JOIN	tlbGeoLocation gl
	ON			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	
	LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) ray_cr
			INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) r_ray_cr /*Rayon*/
			ON			r_ray_cr.idfsReference = ray_cr.idfsRayon
	ON			ray_cr.idfsRayon = gl.idfsRayon
	LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) reg_cr
		INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) r_reg_cr /*Region*/
		ON			r_reg_cr.idfsReference = reg_cr.idfsRegion
		INNER JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) r_countr_cr /*Country*/
		ON			r_countr_cr.idfsReference = reg_cr.idfsCountry
		LEFT JOIN	trtGISBaseReferenceAttribute gis_bra
			INNER JOIN	trtAttributeType at
			ON			at.idfAttributeType = gis_bra.idfAttributeType
						AND at.strAttributeTypeName = N'hide_region_from_report_header'
		ON			gis_bra.idfsGISBaseReference = reg_cr.idfsRegion
					AND gis_bra.strAttributeItem = N'AZ Human Lab Reports'
					AND CAST(gis_bra.varValue AS NVARCHAR) = CAST(N'AZ Human Lab Reports' AS NVARCHAR(20))
	ON			reg_cr.idfsRegion = ISNULL(ray_cr.idfsRegion, gl.idfsRegion)

	
	
ON			h.idfHuman = hc.idfHuman

LEFT JOIN tlbPerson sent_by_empl
on hc.idfSentByPerson = sent_by_empl.idfPerson

LEFT JOIN	tlbMaterial m
	INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000087) r_st	/*Sample Type*/
	ON			r_st.idfsReference = m.idfsSampleType
	
	LEFT JOIN report.FN_REP_InstitutionRepair(@LangID) m_i_sent_to
	on m_i_sent_to.idfOffice = m.idfSendToOffice
ON			m.idfHuman = h.idfHuman
			AND m.intRowStatus = 0
			AND m.idfsSampleType <> 10320001 /*Unknown*/
			AND m.idfParentMaterial is null /*it is initially collected sample*/
			AND m.idfSendToOffice = @SentToID

WHERE		hc.intRowStatus = 0
			AND hc.strCaseID = @CaseID /*Samples belong to specified case*/


SELECT * 
FROM @ReportTable



