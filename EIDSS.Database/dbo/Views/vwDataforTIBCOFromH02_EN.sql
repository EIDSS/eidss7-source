--IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDataforTIBCOFromH02_EN]'))
--DROP VIEW [dbo].[vwDataforTIBCOFromH02_EN]
--GO

CREATE VIEW [dbo].[vwDataforTIBCOFromH02_EN]
as


select		--v.[sflHC_CaseProgressStatus_ID] as N'',
			[ref_sflHC_CaseProgressStatus].[name] as N'Case status',
			v.[sflHC_CaseID] as N'Case ID' /*N'Hadisənin Q/N'*/, 
			v.[sflHC_EnteredDate] as N'Date Entered' /*N'Daxil edilmə tarixi'*/, 
			--v.[sflHC_EnteredBySite_ID] as N'' /*N''*/, 
			[ref_sflHC_EnteredBySite].[name] as N'Entered by Organization' /*N'Daxil edən müəssisə'*/, 
			v.[sflHC_CompletionPaperFormDate] as N'Date of Completion of Paper form' /*N'Kağız formanın doldurulma tarixi'*/, 
			--v.[sflHC_Diagnosis_ID] as N'' /*N''*/, 
			[ref_sflHC_Diagnosis].[name] as N'Diagnosis' /*N'Diaqnoz'*/, 
			v.[sflHC_DiagnosisDate] as N'Diagnosis Date' /*N'Diaqnozun qoyulma tarixi'*/, 
			
			v.[sflHC_NotificationDate] as N'Notification Date' /*N'Bildiriş tarixi'*/, 
			--v.[sflHC_SentByOffice_ID] as N'' /*N''*/, 
			[ref_sflHC_SentByOffice].[name] as N'Notification sent by: Facility' /*N'Təcili bildirişi göndərən: Müəssisə'*/, 
			--v.[sflHC_ReceivedByOffice_ID] as N'' /*N''*/, 
			[ref_sflHC_ReceivedByOffice].[name] as N'Notification received by: Facility' /*N'Təcili bildirişi qəbul edən: Müəssisə'*/, 
			--v.[sflHC_InvestigatedByOffice_ID] as N'' /*N''*/, 
			[ref_sflHC_InvestigatedByOffice].[name] as N'Investigator Organization' /*N'Tədqiqatı aparan təşkilat'*/, 
			v.[sflHC_InvestigationStartDate] as N'Starting Date of Investigation' /*N'Tədqiqatın başlanma tarixi'*/, 
			
			--v.[sflHC_PatientPersonalIDType_ID] as N'' /*N''*/, 
			[ref_sflHC_PatientPersonalIDType].[name] as N'Patient Personal ID Type' /*N'Fərdi İN Növü'*/, 
			v.[sflHC_PatientPersonalID] as N'Patient Personal ID' /*N'Fərdi İN'*/, 
			v.[sflHC_PatientName] as N'Patient Name' /*N'S.A.A.'*/, 
			v.[sflHC_PatientDOB] as N'Date of Birth' /*N'Doğum tarixi'*/, 
			--v.[sflHC_PatientSex_ID] as N'' /*N''*/, 
			[ref_sflHC_PatientSex].[name] as N'Sex' /*N'Cinsi'*/, 

			--v.[sflHC_PatientCRRegion_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientCRRegion].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientCRRegion].[name] as N'Current Residence: Region' /*N'Cari yaşayış yeri: Region'*/, 
			--v.[sflHC_PatientCRRayon_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientCRRayon].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientCRRayon].[name] as N'Current Residence: Rayon' /*N'Cari yaşayış yeri: Rayon'*/, 
			--v.[sflHC_PatientCRSettlement_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientCRSettlement].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientCRSettlement].[name] as N'Current Residence: Town or Village' /*N'Cari yaşayış yeri: Şəhər/Kənd'*/, 
			--v.[sflHC_PatientCRAddress_ID] as N'' /*N''*/, 
			[ref_GL_sflHC_PatientCRAddress].[strDefaultShortAddressString] as N'Current Residence: Address' /*N'Cari yaşayış yeri: Ünvan'*/, 
			v.[sflHC_PatientPhone] as N'Current Residence: Phone Number' /*N'Cari yaşayış yeri: Telefon nömrəsi'*/, 

			--v.[sflHC_PatientNationality_ID] as N'' /*N''*/, 
			[ref_sflHC_PatientNationality].[name] as N'Citizenship' /*N'Vətəndaşlığı'*/, 

			v.[sflHC_PatientEmployer] as N'Name of Employer' /*N'İş yerinin adı'*/, 
			--v.[sflHC_PatientEmpCountry_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientEmpCountry].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientEmpCountry].[name] as N'Address of Employer: Country' /*N'İş yerinin ünvanı: Ölkə'*/, 
			--v.[sflHC_PatientEmpRegion_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientEmpRegion].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientEmpRegion].[name] as N'Address of Employer: Region' /*N'İş yerinin ünvanı: Region'*/, 
			--v.[sflHC_PatientEmpRayon_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientEmpRayon].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientEmpRayon].[name] as N'Address of Employer: Rayon' /*N'İş yerinin ünvanı: Rayon'*/, 
			--v.[sflHC_PatientEmpSettlement_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientEmpSettlement].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientEmpSettlement].[name] as N'Address of Employer: Town or Village' /*N'İş yerinin ünvanı: Şəhər/Kənd'*/, 
			--v.[sflHC_PatientEmpAddress_ID] as N'' /*N''*/, 
			[ref_GL_sflHC_PatientEmpAddress].[strDefaultShortAddressString] as N'Address of Employer: Address' /*N'İş yerinin ünvanı: Ünvan'*/, 
			v.[sflHC_PatientEmployerPhone] as N'Address of Employer: Phone Number' /*N'İş yerinin ünvanı: Telefon'*/, 
			
			--v.[sflHC_PatientOccupation_ID] as N'' /*N''*/, 
			[ref_sflHC_PatientOccupation].[name] as N'Occupation' /*N'Məşğuliyyət'*/, 

			--v.[sflHC_PatientPRCountry_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientPRCountry].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientPRCountry].[name] as N'Permanent Residence: Country' /*N'Daimi yaşayış yeri: Ölkə'*/, 
			--v.[sflHC_PatientPRRegion_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientPRRegion].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientPRRegion].[name] as N'Permanent Residence: Region' /*N'Daimi yaşayış yeri: Region'*/, 
			--v.[sflHC_PatientPRRayon_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientPRRayon].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientPRRayon].[name] as N'Permanent Residence: Rayon' /*N'Daimi yaşayış yeri: Rayon'*/, 
			--v.[sflHC_PatientPRSettlement_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_PatientPRSettlement].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_PatientPRSettlement].[name] as N'Permanent Residence: Town or Village' /*N'Daimi yaşayış yeri: Şəhər/Kənd'*/, 
			--v.[sflHC_PatientPRAddress_ID] as N'' /*N''*/, 
			--v.[sflHC_PatientPRForeignAddress] as N'' /*N''*/, 
			case when v.[sflHC_PatientPRIsForeignAddress_ID] = 10100001 /*Yes*/ then v.[sflHC_PatientPRForeignAddress] else [ref_GL_sflHC_PatientPRAddress].[strDefaultShortAddressString] end as N'Permanent Residence: Address' /*N'Daimi yaşayış yeri: Ünvan'*/, 
			v.[sflHC_PatientPRPhone] as N'Permanent Residence: Phone Number' /*N'Daimi yaşayış yeri: Telefon'*/, 

			v.[sflHC_SymptomOnsetDate] as N'Date of Symptoms Onset' /*N'Simptomların başlanma tarixi'*/, 
			--v.[sflHC_PatientNotificationStatus_ID] as N'' /*N''*/, 
			[ref_sflHC_PatientNotificationStatus].[name] as N'Status of the Patient at Time of Notification' /*N'Təcili bildiriş vaxtı xəstənin vəziyyəti'*/, 
			--v.[sflHC_ChangedDiagnosis_ID] as N'' /*N''*/, 
			[ref_sflHC_ChangedDiagnosis].[name] as N'Changed Diagnosis' /*N'Dəyişdirilmiş diaqnoz'*/, 
			v.[sflHC_ChangedDiagnosisDate] as N'Date of Changed Diagnosis' /*N'Dəyişdirilmiş diaqnozun tarixi'*/, 

			--v.[sflHC_HospitalizationStatus_ID] as N'' /*N''*/, 
			[ref_sflHC_HospitalizationStatus].[name] as N'Current Location of Patient at Time of Notification' /*N'Təcili bildiriş vaxtı xəstənin hazırki yerləşməsi'*/, 
			--v.[sflHC_CurrentLocation_ID] as N'' /*N''*/, 
			[ref_sflHC_CurrentLocation].[name] as N'Hospital Name at Time of Notification' /*N'Təcili bildiriş vaxtı xəstəxananın adı'*/, 
			v.[sflHC_OtherLocation] as N'Other Location Name at Time of Notification' /*N'Təcili bildiriş vaxtı digər yerin adı'*/, 

			--v.[sflHC_InitialCaseClassification_ID] as N'' /*N''*/, 
			[ref_sflHC_InitialCaseClassification].[name] as N'Initial Case Classification' /*N'Hadisənin ilkin təsnifatı'*/, 
			--v.[sflHC_FacilityWherePatientFSC_ID] as N'' /*N''*/, 
			[ref_sflHC_FacilityWherePatientFSC].[name] as N'Facility Where Patient First Sought Care' /*N'Xəstənin ilk yardım üçün müraciət etmiş müəssisə'*/, 
			v.[sflHC_PatientFirstSoughtCareDate] as N'Date Patient First Sought Care' /*N'İlk müraciət tarixi'*/, 
			--v.[sflHC_NonNotifiableDiagnosis_ID] as N'' /*N''*/, 
			[ref_sflHC_NonNotifiableDiagnosis].[name] as N'Non-Notifiable Diagnosis from facility where patient first sought care' /*N'Xəstənin ilk yardım üçün müraciət etdiyi müəssisədə qoyulmuş qeyri-yoluxucu diaqnoz'*/, 

			--v.[sflHC_Hospitalization_ID] as N'' /*N''*/, 
			[ref_sflHC_Hospitalization].[name] as N'Hospitalization' /*N'Hospitalizasiya'*/, 
			v.[sflHC_HospitalizationPlace] as N'Place of Hospitalization' /*N'Hospitalizasiya yeri'*/, 
			v.[sflHC_PatientHospitalizationDate] as N'Date of Hospitalization' /*N'Hospitalizasiya tarixi'*/, 
			--v.[sflHC_AntimicrobialTherapy_ID] as N'' /*N''*/, 
			[ref_sflHC_AntimicrobialTherapy].[name] as N'Antibiotic/Antiviral therapy administered before samples collection' /*N'Nümunələr toplanmazdan əvvəl antibiotik\antivirus müalicəsi aparılıbmı'*/, 
			v.[sflHC_ExposureDate] as N'Date of Exposure' /*N'Təxmini yoluxma tarixi'*/, 

			--v.[sflHC_LocationType_ID] as N'' /*N''*/,
			[ref_sflHC_LocationType].[name] as N'Location of exposure: Location Type' /*N'Təxmini yoluxma yeri: Ərazinin növü'*/,
			--v.[sflHC_RelatedToOutbreak_ID] as N'' /*N''*/, 
			--v.[sflHC_LocationIsForeignAddress_ID] as N'' /*N''*/, 
			[ref_sflHC_LocationIsForeignAddress].[name] as N'Location of exposure: Foreign Address - Y/N' /*N'Təxmini yoluxma yeri: Xaricdəki Ünvan - B/X'*/, 
			--v.[sflHC_LocationCountry_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_LocationCountry].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_LocationCountry].[name] as N'Location of exposure: Country' /*N'Təxmini yoluxma yeri: Ölkə'*/, 
			--v.[sflHC_LocationRegion_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_LocationRegion].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_LocationRegion].[name] as N'Location of exposure: Region' /*N'Təxmini yoluxma yeri: Region'*/, 
			--v.[sflHC_LocationRayon_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_LocationRayon].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_LocationRayon].[name] as N'Location of exposure: Rayon' /*N'Təxmini yoluxma yeri: Rayon'*/, 
			--v.[sflHC_LocationSettlement_ID] as N'' /*N''*/, 
			--[ref_GIS_sflHC_LocationSettlement].[ExtendedName] as N'' /*N''*/, 
			[ref_GIS_sflHC_LocationSettlement].[name] as N'Location of exposure: Settlement' /*N'Təxmini yoluxma yeri: Yaşayış Məntəqəsi'*/, 
			v.[sflHC_LocationForeignAddress] as N'Location of exposure: Foreign Address' /*N'Təxmini yoluxma yeri: Xaricdəki Ünvan'*/,

			--v.[sflHC_SamplesCollected_ID] as N'' /*N''*/, 
			[ref_sflHC_SamplesCollected].[name] as N'Samples Collected' /*N'Nümunələr toplanılıbmı'*/, 
			--v.[sflHC_TestConducted_ID] as N'' /*N''*/, 
			[ref_sflHC_TestConducted].[name] as N'Tests Conducted' /*N'Testlər aparılıb'*/, 

			--v.[sflHC_FinalCaseClassification_ID] as N'' /*N''*/, 
			[ref_sflHC_FinalCaseClassification].[name] as N'Final Case Classification' /*N'Hadisənin son təsnifatı'*/, 
			v.[sflHC_DateFinalCaseClassification] as N'Date of Final Case Classification' /*N'Hadisənin son təsnifat tarixi'*/, 
			--v.[sflHC_FinalDiagnosis_ID] as N'' /*N''*/, 
			[ref_sflHC_FinalDiagnosis].[name]as N'Final Diagnosis' /*N'Son diaqnoz'*/, 
			v.[sflHC_FinalDiagnosisDate] as N'Final Diagnosis Date' /*N'Son diaqnozun tarixi'*/, 

			--v.[sflHC_ClinicalDiagBasis_ID] as N'' /*N''*/, 
			[ref_sflHC_ClinicalDiagBasis].[name] as N'Basis of Diagnosis: Clinical' /*N'Diaqnozun əsası: Kliniki'*/, 
			--v.[sflHC_EpiDiagBasis_ID] as N'' /*N''*/, 
			[ref_sflHC_EpiDiagBasis].[name] as N'Basis of Diagnosis: Epidemiological Links' /*N'Diaqnozun əsası: Epidemioloji'*/, 
			--v.[sflHC_LabDiagBasis_ID] as N'' /*N''*/, 
			[ref_sflHC_LabDiagBasis].[name] as N'Basis of Diagnosis: Laboratory Test' /*N'Diaqnozun əsası: Laborator testlər'*/, 

			--v.[sflHC_Outcome_ID] as N'' /*N''*/, 
			[ref_sflHC_Outcome].[name] as N'Outcome' /*N'Nəticə'*/, 

			[ref_sflHC_RelatedToOutbreak].[name] as N'Is this Case Related to an Outbreak' /*N'Hadisənin hər hansı bir alovlanma ilə əlaqəsi varmı'*/, 
			v.[sflHC_OutbreakID] as N'Outbreak ID' /*N'Alovlanmanın Q/N'*/, 
			
			v.[sflHC_PatientAgeFullYear] as N'Number of Years of the Patient at time of exposure' /*N'Yoluxma zamanı xəstənin yaşı'*/,
			v.[sflHC_Population] as N'Population based on Current Residence Address and year specified Date of Final Case Classification' /*N'Əhalinin sayı (Cari yaşayış yerinin ünvanına və Hadisənin son təsnifat tarixinə əsasən)'*/,
			v.[sflHC_PatientCRLongitude] as N'Current Residence Address: Longitude' /*N'Cari yaşayış yeri: Uzunluq dairəsi'*/,
			v.[sflHC_PatientCRLatitude] as N'Current Residence Address: Latitude' /*N'Cari yaşayış yeri: En dairəsi'*/,
			v.[sflHC_LocationLongitude] as N'Location of exposure or Current Residence Address: Longitude' /*N'Təxmini yoluxma yeri və ya Cari yaşayış yeri: Uzunluq dairəsi'*/,
			v.[sflHC_LocationLatitude] as N'Location of exposure or Current Residence Address: Latitude' /*N'Təxmini yoluxma yeri və ya Cari yaşayış yeri: En dairəsi'*/

from		vwDataforTIBCOFromH02_IDs v

left join	FN_GBL_ReferenceRepair('en', 19000046) [ref_sflHC_EnteredBySite] 
on			[ref_sflHC_EnteredBySite].idfsReference = v.[sflHC_EnteredBySite_ID] 
left join	FN_GBL_GIS_GeoLocationTranslation('en') [ref_GL_sflHC_PatientCRAddress]  
on			[ref_GL_sflHC_PatientCRAddress].idfGeoLocation = v.[sflHC_PatientCRAddress_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_AntimicrobialTherapy] 
on			[ref_sflHC_AntimicrobialTherapy].idfsReference = v.[sflHC_AntimicrobialTherapy_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000019) [ref_sflHC_ChangedDiagnosis] 
on			[ref_sflHC_ChangedDiagnosis].idfsReference = v.[sflHC_ChangedDiagnosis_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000041) [ref_sflHC_HospitalizationStatus] 
on			[ref_sflHC_HospitalizationStatus].idfsReference = v.[sflHC_HospitalizationStatus_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000019) [ref_sflHC_Diagnosis] 
on			[ref_sflHC_Diagnosis].idfsReference = v.[sflHC_Diagnosis_ID] 
left join	FN_GBL_GIS_GeoLocationTranslation('en') [ref_GL_sflHC_PatientEmpAddress]  
on			[ref_GL_sflHC_PatientEmpAddress].idfGeoLocation = v.[sflHC_PatientEmpAddress_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000001) [ref_GIS_sflHC_PatientEmpCountry]  
on			[ref_GIS_sflHC_PatientEmpCountry].idfsReference = v.[sflHC_PatientEmpCountry_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000002) [ref_GIS_sflHC_PatientEmpRayon]  
on			[ref_GIS_sflHC_PatientEmpRayon].idfsReference = v.[sflHC_PatientEmpRayon_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000003) [ref_GIS_sflHC_PatientEmpRegion]  
on			[ref_GIS_sflHC_PatientEmpRegion].idfsReference = v.[sflHC_PatientEmpRegion_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000004) [ref_GIS_sflHC_PatientEmpSettlement]  
on			[ref_GIS_sflHC_PatientEmpSettlement].idfsReference = v.[sflHC_PatientEmpSettlement_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000046) [ref_sflHC_ReceivedByOffice] 
on			[ref_sflHC_ReceivedByOffice].idfsReference = v.[sflHC_ReceivedByOffice_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000046) [ref_sflHC_SentByOffice] 
on			[ref_sflHC_SentByOffice].idfsReference = v.[sflHC_SentByOffice_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_Hospitalization] 
on			[ref_sflHC_Hospitalization].idfsReference = v.[sflHC_Hospitalization_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000046) [ref_sflHC_CurrentLocation] 
on			[ref_sflHC_CurrentLocation].idfsReference = v.[sflHC_CurrentLocation_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_RelatedToOutbreak] 
on			[ref_sflHC_RelatedToOutbreak].idfsReference = v.[sflHC_RelatedToOutbreak_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000002) [ref_GIS_sflHC_LocationRayon]  
on			[ref_GIS_sflHC_LocationRayon].idfsReference = v.[sflHC_LocationRayon_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000003) [ref_GIS_sflHC_LocationRegion]  
on			[ref_GIS_sflHC_LocationRegion].idfsReference = v.[sflHC_LocationRegion_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000054) [ref_sflHC_PatientNationality] 
on			[ref_sflHC_PatientNationality].idfsReference = v.[sflHC_PatientNationality_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000046) [ref_sflHC_InvestigatedByOffice] 
on			[ref_sflHC_InvestigatedByOffice].idfsReference = v.[sflHC_InvestigatedByOffice_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000064) [ref_sflHC_Outcome] 
on			[ref_sflHC_Outcome].idfsReference = v.[sflHC_Outcome_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000002) [ref_GIS_sflHC_PatientCRRayon]  
on			[ref_GIS_sflHC_PatientCRRayon].idfsReference = v.[sflHC_PatientCRRayon_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000003) [ref_GIS_sflHC_PatientCRRegion]  
on			[ref_GIS_sflHC_PatientCRRegion].idfsReference = v.[sflHC_PatientCRRegion_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000004) [ref_GIS_sflHC_PatientCRSettlement]  
on			[ref_GIS_sflHC_PatientCRSettlement].idfsReference = v.[sflHC_PatientCRSettlement_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000043) [ref_sflHC_PatientSex] 
on			[ref_sflHC_PatientSex].idfsReference = v.[sflHC_PatientSex_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_SamplesCollected] 
on			[ref_sflHC_SamplesCollected].idfsReference = v.[sflHC_SamplesCollected_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000035) [ref_sflHC_PatientNotificationStatus] 
on			[ref_sflHC_PatientNotificationStatus].idfsReference = v.[sflHC_PatientNotificationStatus_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000019) [ref_sflHC_FinalDiagnosis] 
on			[ref_sflHC_FinalDiagnosis].idfsReference = v.[sflHC_FinalDiagnosis_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000011) [ref_sflHC_InitialCaseClassification] 
on			[ref_sflHC_InitialCaseClassification].idfsReference = v.[sflHC_InitialCaseClassification_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000011) [ref_sflHC_FinalCaseClassification] 
on			[ref_sflHC_FinalCaseClassification].idfsReference = v.[sflHC_FinalCaseClassification_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000061) [ref_sflHC_PatientOccupation] 
on			[ref_sflHC_PatientOccupation].idfsReference = v.[sflHC_PatientOccupation_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000004) [ref_GIS_sflHC_LocationSettlement]  
on			[ref_GIS_sflHC_LocationSettlement].idfsReference = v.[sflHC_LocationSettlement_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_ClinicalDiagBasis] 
on			[ref_sflHC_ClinicalDiagBasis].idfsReference = v.[sflHC_ClinicalDiagBasis_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_EpiDiagBasis] 
on			[ref_sflHC_EpiDiagBasis].idfsReference = v.[sflHC_EpiDiagBasis_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_LabDiagBasis] 
on			[ref_sflHC_LabDiagBasis].idfsReference = v.[sflHC_LabDiagBasis_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000046) [ref_sflHC_FacilityWherePatientFSC] 
on			[ref_sflHC_FacilityWherePatientFSC].idfsReference = v.[sflHC_FacilityWherePatientFSC_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000149) [ref_sflHC_NonNotifiableDiagnosis] 
on			[ref_sflHC_NonNotifiableDiagnosis].idfsReference = v.[sflHC_NonNotifiableDiagnosis_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_TestConducted] 
on			[ref_sflHC_TestConducted].idfsReference = v.[sflHC_TestConducted_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000003) [ref_GIS_sflHC_PatientPRRegion]  
on			[ref_GIS_sflHC_PatientPRRegion].idfsReference = v.[sflHC_PatientPRRegion_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000002) [ref_GIS_sflHC_PatientPRRayon]  
on			[ref_GIS_sflHC_PatientPRRayon].idfsReference = v.[sflHC_PatientPRRayon_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000004) [ref_GIS_sflHC_PatientPRSettlement]  
on			[ref_GIS_sflHC_PatientPRSettlement].idfsReference = v.[sflHC_PatientPRSettlement_ID] 
left join	FN_GBL_GIS_GeoLocationTranslation('en') [ref_GL_sflHC_PatientPRAddress]  
on			[ref_GL_sflHC_PatientPRAddress].idfGeoLocation = v.[sflHC_PatientPRAddress_ID] 
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000001) [ref_GIS_sflHC_PatientPRCountry]  
on			[ref_GIS_sflHC_PatientPRCountry].idfsReference = v.[sflHC_PatientPRCountry_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000148) [ref_sflHC_PatientPersonalIDType] 
on			[ref_sflHC_PatientPersonalIDType].idfsReference = v.[sflHC_PatientPersonalIDType_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000036) [ref_sflHC_LocationType]
on			[ref_sflHC_LocationType].idfsReference = v.[sflHC_LocationType_ID]
left join	FN_GBL_GIS_ExtendedReferenceRepair('en', 19000001) [ref_GIS_sflHC_LocationCountry]  
on			[ref_GIS_sflHC_LocationCountry].idfsReference = v.[sflHC_LocationCountry_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000100) [ref_sflHC_LocationIsForeignAddress] 
on			[ref_sflHC_LocationIsForeignAddress].idfsReference = v.[sflHC_LocationIsForeignAddress_ID] 
left join	FN_GBL_ReferenceRepair('en', 19000111) [ref_sflHC_CaseProgressStatus] 
on			[ref_sflHC_CaseProgressStatus].idfsReference = v.[sflHC_CaseProgressStatus_ID]



--Not needed--left join	fnReference('en', 19000044) ref_None	-- Information String
--Not needed--on			ref_None.idfsReference = 0		-- Workaround. We dont need (none) anymore




--GO


