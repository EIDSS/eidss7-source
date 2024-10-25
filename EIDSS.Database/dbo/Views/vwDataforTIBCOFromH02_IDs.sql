--IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDataforTIBCOFromH02_IDs]'))
--DROP VIEW [dbo].[vwDataforTIBCOFromH02_IDs]
--GO

CREATE VIEW [dbo].[vwDataforTIBCOFromH02_IDs]
as

select		hc.idfHumanCase as [PKField], 
			gl_cr_hc.idfGeoLocation as [sflHC_PatientCRAddress_ID], 
			hc.idfsYNAntimicrobialTherapy as [sflHC_AntimicrobialTherapy_ID], 
			hc.strCaseID as [sflHC_CaseID], 
			d_changed_hc.idfsDiagnosis as [sflHC_ChangedDiagnosis_ID], 
			hc.idfsHospitalizationStatus as [sflHC_HospitalizationStatus_ID], 
			hc.datEnteredDate as [sflHC_EnteredDate], 
			h_hc.datDateofBirth as [sflHC_PatientDOB], 
			hc.datFinalDiagnosisDate as [sflHC_ChangedDiagnosisDate], 
			hc.datCompletionPaperFormDate as [sflHC_CompletionPaperFormDate], 
			hc.datExposureDate as [sflHC_ExposureDate], 
			hc.datOnSetDate as [sflHC_SymptomOnsetDate], 
			d_init_hc.idfsDiagnosis as [sflHC_Diagnosis_ID], 
			hc.datTentativeDiagnosisDate as [sflHC_DiagnosisDate], 
			gl_emp_hc.idfGeoLocation as [sflHC_PatientEmpAddress_ID], 
			h_hc.strWorkPhone as [sflHC_PatientEmployerPhone], 
			gl_emp_hc.idfsRayon as [sflHC_PatientEmpRayon_ID], 
			gl_emp_hc.idfsRegion as [sflHC_PatientEmpRegion_ID], 
			gl_emp_hc.idfsCountry as [sflHC_PatientEmpCountry_ID], 
			gl_emp_hc.idfsSettlement as [sflHC_PatientEmpSettlement_ID], 
			o_rec_hc.idfsOfficeName as [sflHC_ReceivedByOffice_ID], 
			o_sent_hc.idfsOfficeName as [sflHC_SentByOffice_ID], 
			hc.idfsYNHospitalization as [sflHC_Hospitalization_ID], 
			case when hc.idfsHospitalizationStatus = 5350000000 then o_hosp_hc.idfsOfficeAbbreviation else null end as [sflHC_CurrentLocation_ID], 
			hc.idfsYNRelatedToOutbreak as [sflHC_RelatedToOutbreak_ID], 
			gl_hc.idfsRayon as [sflHC_LocationRayon_ID], 
			gl_hc.idfsRegion as [sflHC_LocationRegion_ID], 
			dbo.FN_GBL_ConcatFullName(h_hc.strLastName, h_hc.strFirstName, h_hc.strSecondName) as [sflHC_PatientName], 
			h_hc.strEmployerName as [sflHC_PatientEmployer], 
			h_hc.idfsNationality as [sflHC_PatientNationality_ID], 
			hc.datNotificationDate as [sflHC_NotificationDate], 
			o_inv_hc.idfsOfficeName as [sflHC_InvestigatedByOffice_ID], 
			outb.strOutbreakID as [sflHC_OutbreakID], 
			hc.idfsOutcome as [sflHC_Outcome_ID], 
			h_hc.strHomePhone as [sflHC_PatientPhone], 
			gl_cr_hc.idfsRayon as [sflHC_PatientCRRayon_ID], 
			gl_cr_hc.idfsRegion as [sflHC_PatientCRRegion_ID], 
			gl_cr_hc.idfsSettlement as [sflHC_PatientCRSettlement_ID], 
			h_hc.idfsHumanGender as [sflHC_PatientSex_ID], 
			hc.idfsYNSpecimenCollected as [sflHC_SamplesCollected_ID], 
			hc.datInvestigationStartDate as [sflHC_InvestigationStartDate], 
			hc.idfsFinalState as [sflHC_PatientNotificationStatus_ID], 
			d_fin_hc.idfsDiagnosis as [sflHC_FinalDiagnosis_ID], 
			hc.idfsInitialCaseStatus as [sflHC_InitialCaseClassification_ID], 
			hc.idfsFinalCaseStatus as [sflHC_FinalCaseClassification_ID], 
			case when IsNull(hc.idfsFinalDiagnosis, -1) > 0 then hc.datFinalDiagnosisDate else hc.datTentativeDiagnosisDate end as [sflHC_FinalDiagnosisDate], 
			h_hc.idfsOccupationType as [sflHC_PatientOccupation_ID], 
			hc.datHospitalizationDate as [sflHC_PatientHospitalizationDate], 
			hc.datFirstSoughtCareDate as [sflHC_PatientFirstSoughtCareDate], 
			gl_hc.idfsSettlement as [sflHC_LocationSettlement_ID], 
			hc.strHospitalizationPlace as [sflHC_HospitalizationPlace], 
			(IsNull(hc.blnClinicalDiagBasis, 0) * 10100001 + (1 - IsNull(hc.blnClinicalDiagBasis, 0)) * 10100002) as [sflHC_ClinicalDiagBasis_ID], 
			(IsNull(hc.blnEpiDiagBasis, 0) * 10100001 + (1 - IsNull(hc.blnEpiDiagBasis, 0)) * 10100002) as [sflHC_EpiDiagBasis_ID], 
			(IsNull(hc.blnLabDiagBasis, 0) * 10100001 + (1 - IsNull(hc.blnLabDiagBasis, 0)) * 10100002) as [sflHC_LabDiagBasis_ID], 
			o_fsc_hc.idfsOfficeName as [sflHC_FacilityWherePatientFSC_ID], 
			hc.idfsNonNotifiableDiagnosis as [sflHC_NonNotifiableDiagnosis_ID], 
			case when hc.idfsHospitalizationStatus = 5360000000 then hc.strCurrentLocation else null end as [sflHC_OtherLocation], 
			hc.idfsYNTestsConducted as [sflHC_TestConducted_ID], 
			gl_reg_hc.idfsRegion as [sflHC_PatientPRRegion_ID], 
			gl_reg_hc.idfsRayon as [sflHC_PatientPRRayon_ID], 
			gl_reg_hc.idfsSettlement as [sflHC_PatientPRSettlement_ID], 
			gl_reg_hc.idfGeoLocation as [sflHC_PatientPRAddress_ID], 
			gl_reg_hc.idfsCountry as [sflHC_PatientPRCountry_ID], 
			case gl_reg_hc.blnForeignAddress when 1 then 10100001 else 10100002 end as [sflHC_PatientPRIsForeignAddress_ID], 
			case gl_reg_hc.blnForeignAddress when 1 then gl_reg_hc.strForeignAddress else null end as [sflHC_PatientPRForeignAddress], 
			h_hc.strRegistrationPhone as [sflHC_PatientPRPhone], 
			o_ent_hc.idfsOfficeName as [sflHC_EnteredBySite_ID], 
			hc.datFinalCaseClassificationDate as [sflHC_DateFinalCaseClassification], 
			h_hc.idfsPersonIDType as [sflHC_PatientPersonalIDType_ID], 
			h_hc.strPersonID as [sflHC_PatientPersonalID], 
			gl_hc.idfsGeoLocationType as [sflHC_LocationType_ID],
			gl_hc.idfsCountry  as [sflHC_LocationCountry_ID], 
			case when gl_hc.idfsGeoLocationType = 10036001 then 10100001 when gl_hc.idfsGeoLocationType is null then null else 10100002 end  as [sflHC_LocationIsForeignAddress_ID], 
			case when gl_hc.blnForeignAddress = 1 then gl_hc.strForeignAddress else null end  as [sflHC_LocationForeignAddress],
			case
				when	(	hc.idfsHumanAgeType = 10042002 and -- Month
							hc.intPatientAge between 0 and 11) or
						(	hc.idfsHumanAgeType = 10042001 and -- Days
							hc.intPatientAge between 0 and 364) or
						(	hc.idfsHumanAgeType = 10042003 and -- Years
							hc.intPatientAge = 0)
					then	cast(0 as int)
				when	(	hc.idfsHumanAgeType = 10042002 and -- Month
							hc.intPatientAge between 12 and 60)
					then	cast((hc.intPatientAge / 12) as int)
				when	(	hc.idfsHumanAgeType = 10042003 and -- Years
							hc.intPatientAge > 0)
					then	hc.intPatientAge
				else	cast(null as int)
			end as [sflHC_PatientAgeFullYear],
			stat.intStatisticsValue as [sflHC_Population],
			case
				when	(isnull(gl_cr_hc.dblLatitude, 0) <> 0 and isnull(gl_cr_hc.dblLongitude, 0) <> 0)
					then	gl_cr_hc.dblLatitude
				when	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is not null
					then	s_gl_cr_hc.dblLatitude
				when	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is null
						and gl_cr_hc.idfsRayon is not null
					then	s_mcfr_gl_cr_hc.dblLatitude
				else	cast(null as float)				
			end as [sflHC_PatientCRLatitude],
			case
				when	(isnull(gl_cr_hc.dblLatitude, 0) <> 0 and isnull(gl_cr_hc.dblLongitude, 0) <> 0)
					then	gl_cr_hc.dblLongitude
				when	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is not null
					then	s_gl_cr_hc.dblLongitude
				when	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is null
						and gl_cr_hc.idfsRayon is not null
					then	s_mcfr_gl_cr_hc.dblLongitude
				else	cast(null as float)				
			end as [sflHC_PatientCRLongitude],
			case
				when	gl_hc.idfsGeoLocationType = 10036001 /*Foreign Address*/
						and gl_hc.idfsCountry <> dbo.FN_GBL_CURRENTCOUNTRY_GET()
					then	null
				when	(isnull(gl_hc.dblLatitude, 0) <> 0 and isnull(gl_hc.dblLongitude, 0) <> 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
					then	gl_hc.dblLatitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsSettlement is not null
					then	s_gl_hc.dblLatitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsSettlement is null
						and gl_hc.idfsRayon is not null
					then	s_mcfr_gl_hc.dblLatitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsRayon is null
						and	(isnull(gl_cr_hc.dblLatitude, 0) <> 0 and isnull(gl_cr_hc.dblLongitude, 0) <> 0)
					then	gl_cr_hc.dblLatitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsRayon is null
						and	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is not null
					then	s_gl_cr_hc.dblLatitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsRayon is null
						and	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is null
						and gl_cr_hc.idfsRayon is not null
					then	s_mcfr_gl_cr_hc.dblLatitude
				else	cast(null as float)				
			end as [sflHC_LocationLatitude],
			case
				when	gl_hc.idfsGeoLocationType = 10036001 /*Foreign Address*/
						and gl_hc.idfsCountry <> dbo.FN_GBL_CURRENTCOUNTRY_GET()
					then	null
				when	(isnull(gl_hc.dblLatitude, 0) <> 0 and isnull(gl_hc.dblLongitude, 0) <> 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
					then	gl_hc.dblLongitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsSettlement is not null
					then	s_gl_hc.dblLongitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsSettlement is null
						and gl_hc.idfsRayon is not null
					then	s_mcfr_gl_hc.dblLongitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsRayon is null
						and	(isnull(gl_cr_hc.dblLatitude, 0) <> 0 and isnull(gl_cr_hc.dblLongitude, 0) <> 0)
					then	gl_cr_hc.dblLongitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsRayon is null
						and	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is not null
					then	s_gl_cr_hc.dblLongitude
				when	(isnull(gl_hc.dblLatitude, 0) = 0 or isnull(gl_hc.dblLongitude, 0) = 0)
						and (	isnull(gl_hc.idfsGeoLocationType, -1) <> 10036001 /*Foreign Address*/
								or	gl_hc.idfsCountry is null
								or	gl_hc.idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()
							)
						and gl_hc.idfsRayon is null
						and	(isnull(gl_cr_hc.dblLatitude, 0) = 0 or isnull(gl_cr_hc.dblLongitude, 0) = 0)
						and gl_cr_hc.idfsSettlement is null
						and gl_cr_hc.idfsRayon is not null
					then	s_mcfr_gl_cr_hc.dblLongitude
				else	cast(null as float)				
			end as [sflHC_LocationLongitude], 
			hc.idfsCaseProgressStatus as [sflHC_CaseProgressStatus_ID]

from 

( 
	tlbHumanCase hc 
	inner join	tlbHuman h_hc 
	on			h_hc.idfHuman = hc.idfHuman 
				and h_hc.intRowStatus = 0 
left join 

  	 
  		tlbOffice o_hosp_hc 
  	 
  
ON o_hosp_hc.idfOffice = hc.idfHospital 
left join 

 
	tlbGeoLocation gl_cr_hc  

ON gl_cr_hc.idfGeoLocation = h_hc.idfCurrentResidenceAddress AND gl_cr_hc.intRowStatus = 0 
left join 

	dbo.FN_GBL_GetStatisticsForYearsWithoutParameters(39850000000 /*Population*/, null, 2009 /**/) stat

on			stat.idfsAdminUnit = gl_cr_hc.idfsRayon
			and stat.intYear = year(coalesce(hc.datFinalCaseClassificationDate, hc.datTentativeDiagnosisDate, hc.datEnteredDate))
left join 

	gisSettlement s_gl_cr_hc

on			s_gl_cr_hc.idfsSettlement = gl_cr_hc.idfsSettlement
left join 

	gisMainCityForRayon mcfr_gl_cr_hc  
	join	gisSettlement s_mcfr_gl_cr_hc
	on		s_mcfr_gl_cr_hc.idfsSettlement = mcfr_gl_cr_hc.idfsMainSettlement

on			mcfr_gl_cr_hc.idfsRayon = gl_cr_hc.idfsRayon
left join 

 
	tlbGeoLocation gl_emp_hc 
 

ON gl_emp_hc.idfGeoLocation = h_hc.idfEmployerAddress AND gl_emp_hc.intRowStatus = 0 
left join 

 
	tlbGeoLocation gl_hc 
 

ON gl_hc.idfGeoLocation = hc.idfPointGeoLocation AND gl_hc.intRowStatus = 0
left join 

	gisSettlement s_gl_hc

on			s_gl_hc.idfsSettlement = gl_hc.idfsSettlement
left join 

	gisMainCityForRayon mcfr_gl_hc  
	join	gisSettlement s_mcfr_gl_hc
	on		s_mcfr_gl_hc.idfsSettlement = mcfr_gl_hc.idfsMainSettlement

on			mcfr_gl_hc.idfsRayon = gl_hc.idfsRayon
left join 

 
	tlbGeoLocation gl_reg_hc 
 

ON gl_reg_hc.idfGeoLocation = h_hc.idfRegistrationAddress AND gl_reg_hc.intRowStatus = 0 
left join 

 
	tlbOffice o_fsc_hc 
 

ON o_fsc_hc.idfOffice = hc.idfSoughtCareFacility AND o_fsc_hc.intRowStatus = 0 
left join 

 
	tlbOffice o_inv_hc 
 

ON o_inv_hc.idfOffice = hc.idfInvestigatedByOffice AND o_inv_hc.intRowStatus = 0 
left join 

 
	tlbOffice o_rec_hc 
 

ON o_rec_hc.idfOffice = hc.idfReceivedByOffice AND o_rec_hc.intRowStatus = 0 
left join 

 
	tlbOffice o_sent_hc 
 

ON o_sent_hc.idfOffice = hc.idfSentByOffice AND o_sent_hc.intRowStatus = 0 
left join 

 
	tlbOutbreak outb 
 

ON outb.idfOutbreak = hc.idfOutbreak AND outb.intRowStatus = 0 
left join 

 
	trtDiagnosis d_changed_hc 
 

ON d_changed_hc.idfsDiagnosis = hc.idfsFinalDiagnosis 
left join 

 
	trtDiagnosis d_fin_hc 
 

ON d_fin_hc.idfsDiagnosis = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) 
left join 

 
	trtDiagnosis d_init_hc 
 

ON d_init_hc.idfsDiagnosis = hc.idfsTentativeDiagnosis 
left join 

( 
	tstSite s_ent_hc 
	inner join	tlbOffice o_ent_hc 
	on			o_ent_hc.idfOffice = s_ent_hc.idfOffice 
) 

ON s_ent_hc.idfsSite = hc.idfsSite 
) 



where		hc.intRowStatus = 0


--GO


