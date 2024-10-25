
/**************************************************************************************************************************************
* Check script of data migration results: Human Disease Report Counts and Key Differences.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 are located.
* By default, in the script EIDSSv6.1 database has the name Falcon, and EIDSSv7 database has the name Giraffe.
**************************************************************************************************************************************/

declare	@strNationalLng nvarchar(200)
set @strNationalLng = N'' -- Georgian - ka, Azerbaijani - az-L

declare	@intLngEn bigint
declare @intLngNat bigint

set @intLngEn = [Falcon].dbo.fnGetLanguageCode('en')
set @intLngNat = [Falcon].dbo.fnGetLanguageCode(@strNationalLng)

if @intLngNat is null
	set	@intLngNat = @intLngEn

declare	@idfsCountry bigint
set @idfsCountry = [Falcon].dbo.fnCurrentCountry()

declare	@Differences table
(	idfId int not null primary key,
	strDifference nvarchar(200) collate Cyrillic_General_CI_AS not null
)


insert into @Differences (idfId, strDifference) values
 (1, N'New record in v7')
,(2, N'Not transferred from v6')
,(3, N'HDR v7 matching HC v6.1')
,(4, N'Several HDR v7 matching HC v6.1')
,(5, N'Deletion State Change')
,(6, N'Tentative Diagnosis Change')
,(7, N'Tentative Diagnosis Date Change')
,(8, N'Changed Diagnosis Change')
,(9, N'Changed Diagnosis Date Change')

,(10, N'Patient Name Change')
,(11, N'Patient Date of Birth Change')
,(12, N'Patient Age Change')
,(13, N'Patient Gender Change')
,(14, N'Patient CR Address Change')
,(15, N'Patient has no reference to Person List in v7')

,(16, N'Initial Case Classification Change')
,(17, N'Basis of Diagnosis Change')
,(18, N'Final Case Classification Change')
,(19, N'Final Case Classification Date Change')
,(20, N'Case Status Change')

,(21, N'Passive Report Type Change')
,(22, N'Is Employed Change')
,(23, N'Is there another Phone Number Change')
,(24, N'Is there another Address Change')
,(25, N'Patient previously sought care Change')
,(26, N'Hospitalization Change')
,(27, N'Is Location of Exposure Known Change')
,(28, N'Legacy Case ID Change')


select	STUFF(diff.strDifferences, 1, 1, N'') as 'Migration Result',
		isnull(cast(tlbHumanCase_v6.idfHumanCase as varchar(20)), N'') as 'System Identifier v6',
		case when tlbHumanCase_v6.datEnteredDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datEnteredDate, 104) end as 'Entered Date v6',
		isnull(tlbHumanCase_v6.strCaseID, N'') as 'Case ID v6',
		coalesce(gl_cr_region_en_v6.strTextString, gl_cr_region_v6.strDefault, N'') as 'Region v6',
		coalesce(gl_cr_rayon_en_v6.strTextString, gl_cr_rayon_v6.strDefault, N'') as 'Rayon v6',
		coalesce(gl_cr_stlm_en_v6.strTextString, gl_cr_stlm_v6.strDefault, N'') as 'Settlement v6',
		[Falcon].dbo.fnConcatFullName(tlbHuman_v6.strLastName, tlbHuman_v6.strFirstName, tlbHuman_v6.strSecondName) as 'Patient Name v6',
		coalesce(tentative_diag_en_v6.strTextString, tentative_diag_v6.strDefault, N'') as 'Diagnosis v6',
		case when tlbHumanCase_v6.datTentativeDiagnosisDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datTentativeDiagnosisDate, 104) end as 'Diagnosis Date v6',
		coalesce(initial_cc_en_v6.strTextString, initial_cc_v6.strDefault, N'') as 'Initial Case Classification v6',
		coalesce(final_diag_en_v6.strTextString, final_diag_v6.strDefault, N'') as 'Changed Diagnosis v6',
		case when tlbHumanCase_v6.datFinalDiagnosisDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datFinalDiagnosisDate, 104) end as 'Changed Diagnosis Date v6',
		coalesce(final_cc_en_v6.strTextString, final_cc_v6.strDefault, N'') as 'Final Case Classification v6',
		replace(replace(cast(isnull(tlbHumanCase_v6.blnClinicalDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Clinical') + 
			case when cast(isnull(tlbHumanCase_v6.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v6.blnEpiDiagBasis, 0) as int) = 2 then N',' else N'' end +
			replace(replace(cast(isnull(tlbHumanCase_v6.blnEpiDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Epi') + 
				case when tlbHumanCase_v6.blnLabDiagBasis = 1 and cast(isnull(tlbHumanCase_v6.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v6.blnEpiDiagBasis, 0) as int) >= 1 then N',' else N'' end + 
				replace(replace(cast(isnull(tlbHumanCase_v6.blnLabDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Lab') as 'Basis of Diagnosis v6.1',
		case when tlbHumanCase_v6.datFinalCaseClassificationDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datFinalCaseClassificationDate, 104) end as 'Final Case Classification Date v6',
		coalesce(cs_en_v6.strTextString, cs_v6.strDefault, N'') as 'Case Status v6',
		N'Employer Name v6: ' +  case when ltrim(rtrim(isnull(tlbHuman_v6.strEmployerName, N''))) = N'' then N'Not specified' else ltrim(rtrim(isnull(tlbHuman_v6.strEmployerName, N''))) end + N'; ' + 
			N'Employer Address v6: ' + case when gl_emp_v6.blnForeignAddress = 1 then N'Foreign Address specified' when gl_emp_v6.blnForeignAddress = 0 and gl_emp_v6.idfsRegion is not null then 'Filled in' else N'Not specified' end + N'; ' +
			N'Work Phone Number v6: ' + case when ltrim(rtrim(isnull(tlbHuman_v6.strWorkPhone, N''))) = N'' then N'Not specified' else ltrim(rtrim(isnull(tlbHuman_v6.strWorkPhone, N''))) end as N'Employee Info v6',
		case when gl_reg_v6.blnForeignAddress = 1 then N'Foreign Address specified' when gl_reg_v6.blnForeignAddress = 0 and gl_reg_v6.idfsRegion is not null then 'Filled in' else N'Not specified' end as N'Registration (Alternative) Address v6',
		N'Non-Notifiable Diagnosis: ' + case when tlbHumanCase_v6.idfsNonNotifiableDiagnosis is null then N'Not specified' else coalesce(nonnotifdiag_en_v6.strTextString, nonnotifdiag_v6.strDefault, N'') end + N';' +
			N'Facility patient first sought care: ' + case when tlbHumanCase_v6.idfSoughtCareFacility is null then N'Not specified' else isnull(soughtCareFacility_v6.[name], N'') end + N';' +
			N'Date patient first sought care: ' + case when tlbHumanCase_v6.[datFirstSoughtCareDate] is null then N'Not specified' else convert(nvarchar, tlbHumanCase_v6.[datFirstSoughtCareDate], 104) end as 'Patient Sought Care Info v6',
		coalesce(ynk_hospitalization_en_v6.strTextString, ynk_hospitalization_v6.strDefault, N'') as 'Hospitalization v6',
		N'Exposure Location v6: ' + case when gl_locexp_v6.blnForeignAddress = 1 then N'Foreign Address specified' when gl_locexp_v6.blnForeignAddress = 0 and gl_locexp_v6.idfsRegion is not null then 'Filled in' else N'Not specified' end + N'; ' +
			N'Date of Exposure v6: ' + case when tlbHumanCase_v6.[datExposureDate] is null then N'Not specified' else convert(nvarchar, tlbHumanCase_v6.[datExposureDate], 104) end as N'Location of Exposure Info v6',

		isnull(cast(tlbHumanCase_v7.idfHumanCase as varchar(20)), N'') as 'System Identifier v7',
		case when tlbHumanCase_v7.datEnteredDate is null then N'' else convert(nvarchar, tlbHumanCase_v7.datEnteredDate, 104) end as 'Entered Date v7',
		isnull(tlbHumanCase_v7.strCaseID, N'') as 'Case ID v7',
		isnull(tlbHumanCase_v7.LegacyCaseID, N'') as 'Legacy Case ID v7',
		coalesce(ld_cr_lng_v7.Level2Name, ld_cr_en_v7.Level2Name, N'') as 'Region v7',
		coalesce(ld_cr_lng_v7.Level3Name, ld_cr_en_v7.Level3Name, N'') as 'Rayon v7',
		coalesce(ld_cr_lng_v7.Level4Name, ld_cr_en_v7.Level4Name, N'') as 'Settlement v7',
		[Falcon].dbo.fnConcatFullName(tlbHuman_v7.strLastName, tlbHuman_v7.strFirstName, tlbHuman_v7.strSecondName) as 'Patient Name v7',
		isnull(haai_v7.EIDSSPersonID, N'') as 'EIDSS Person ID v7',
		coalesce(tentative_diag_en_v7.strTextString, tentative_diag_v7.strDefault, N'') as 'Diagnosis v7',
		case when tlbHumanCase_v7.datTentativeDiagnosisDate is null then N'' else convert(nvarchar, tlbHumanCase_v7.datTentativeDiagnosisDate, 104) end as 'Diagnosis Date v7',
		coalesce(final_diag_en_v7.strTextString, final_diag_v7.strDefault, N'') as 'Changed Diagnosis v7',
		case when tlbHumanCase_v7.datFinalDiagnosisDate is null then N'' else convert(nvarchar, tlbHumanCase_v7.datFinalDiagnosisDate, 104) end as 'Diagnosis Date v7',
		coalesce(initial_cc_en_v7.strTextString, initial_cc_v7.strDefault, N'') as 'Initial Case Classification v7',
		coalesce(final_cc_en_v7.strTextString, final_cc_v7.strDefault, N'') as 'Final Case Classification v7',
		replace(replace(cast(isnull(tlbHumanCase_v7.blnClinicalDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Clinical') + 
			case when cast(isnull(tlbHumanCase_v7.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v7.blnEpiDiagBasis, 0) as int) = 2 then N',' else N'' end +
			replace(replace(cast(isnull(tlbHumanCase_v7.blnEpiDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Epi') + 
				case when tlbHumanCase_v7.blnLabDiagBasis = 1 and cast(isnull(tlbHumanCase_v7.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v7.blnEpiDiagBasis, 0) as int) >= 1 then N',' else N'' end + 
				replace(replace(cast(isnull(tlbHumanCase_v7.blnLabDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Lab') as 'Basis of Diagnosis v7.1',
		case when tlbHumanCase_v7.datFinalCaseClassificationDate is null then N'' else convert(nvarchar, tlbHumanCase_v7.datFinalCaseClassificationDate, 104) end as 'Final Case Classification Date v7',
		coalesce(cs_en_v7.strTextString, cs_v7.strDefault, N'') as 'Case Status v7',
		coalesce(rt_en_v7.strTextString, rt_v7.strDefault, N'') as 'Report Type v7',
		coalesce(ynk_emp_en_v7.strTextString, ynk_emp_v7.strDefault, N'') as 'Patient Is Employed v7',
		coalesce(ynk_another_phone_en_v7.strTextString, ynk_another_phone_v7.strDefault, N'') as 'Another Phone for Patient v7',
		coalesce(ynk_another_address_en_v7.strTextString, ynk_another_address_v7.strDefault, N'') as 'Another Address for Patient v7',
		coalesce(ynk_soughtcare_en_v7.strTextString, ynk_soughtcare_v7.strDefault, N'') as 'Patient Previously Sought Care v7',
		coalesce(ynk_hospitalization_en_v7.strTextString, ynk_hospitalization_v7.strDefault, N'') as 'Hospitalization v7',
		coalesce(ynk_locexp_en_v7.strTextString,ynk_locexp_v7.strDefault, N'') as 'Location of Exposure is known v7'

from
(
	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7


	left join	[Giraffe].[dbo].[trtBaseReference] tentative_diag_v7
	on			tentative_diag_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsTentativeDiagnosis]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] tentative_diag_en_v7
	on			tentative_diag_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsTentativeDiagnosis]
				and tentative_diag_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] tentative_diag_lng_v7
	on			tentative_diag_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsTentativeDiagnosis]
				and tentative_diag_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[trtBaseReference] final_diag_v7
	on			final_diag_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_diag_en_v7
	on			final_diag_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
				and final_diag_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_diag_lng_v7
	on			final_diag_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
				and final_diag_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] cs_v7
	on			cs_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsCaseProgressStatus]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] cs_en_v7
	on			cs_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsCaseProgressStatus]
				and cs_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] cs_lng_v7
	on			cs_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsCaseProgressStatus]
				and cs_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] initial_cc_v7
	on			initial_cc_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsInitialCaseStatus]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] initial_cc_en_v7
	on			initial_cc_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsInitialCaseStatus]
				and initial_cc_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] initial_cc_lng_v7
	on			initial_cc_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsInitialCaseStatus]
				and initial_cc_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[trtBaseReference] final_cc_v7
	on			final_cc_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalCaseStatus]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_cc_en_v7
	on			final_cc_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalCaseStatus]
				and final_cc_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_cc_lng_v7
	on			final_cc_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalCaseStatus]
				and final_cc_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] rt_v7
	on			rt_v7.[idfsBaseReference] = tlbHumanCase_v7.[DiseaseReportTypeID]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] rt_en_v7
	on			rt_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[DiseaseReportTypeID]
				and rt_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] rt_lng_v7
	on			rt_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[DiseaseReportTypeID]
				and rt_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[tlbHuman] tlbHuman_v7
	on			tlbHuman_v7.[idfHuman] = tlbHumanCase_v7.[idfHuman]
	left join	[Giraffe].[dbo].[HumanAddlInfo] hai_v7
	on			hai_v7.[HumanAdditionalInfo] = tlbHuman_v7.[idfHuman]


	left join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7
	on			tlbHumanActual_v7.[idfHumanActual] = tlbHuman_v7.[idfHumanActual]
	left join	[Giraffe].[dbo].[HumanActualAddlInfo] haai_v7
	on			haai_v7.[HumanActualAddlInfoUID] = tlbHuman_v7.[idfHumanActual]


	left join	[Giraffe].[dbo].[tlbGeoLocation] gl_cr_v7
	on			gl_cr_v7.[idfGeoLocation] = tlbHuman_v7.[idfCurrentResidenceAddress]

	left join	[Giraffe].[dbo].[gisLocationDenormalized] ld_cr_en_v7
	on			ld_cr_en_v7.[idfsLocation] = gl_cr_v7.[idfsLocation]
				and ld_cr_en_v7.[idfsLanguage] = @intLngEn

	left join	[Giraffe].[dbo].[gisLocationDenormalized] ld_cr_lng_v7
	on			ld_cr_lng_v7.[idfsLocation] = gl_cr_v7.[idfsLocation]
				and ld_cr_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] ynk_emp_v7
	on			ynk_emp_v7.[idfsBaseReference] = hai_v7.[IsEmployedID]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_emp_en_v7
	on			ynk_emp_en_v7.[idfsBaseReference] = hai_v7.[IsEmployedID]
				and ynk_emp_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_emp_lng_v7
	on			ynk_emp_lng_v7.[idfsBaseReference] = hai_v7.[IsEmployedID]
				and ynk_emp_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[trtBaseReference] ynk_another_phone_v7
	on			ynk_another_phone_v7.[idfsBaseReference] = hai_v7.[IsAnotherPhoneID]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_another_phone_en_v7
	on			ynk_another_phone_en_v7.[idfsBaseReference] = hai_v7.[IsAnotherPhoneID]
				and ynk_another_phone_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_another_phone_lng_v7
	on			ynk_another_phone_lng_v7.[idfsBaseReference] = hai_v7.[IsAnotherPhoneID]
				and ynk_another_phone_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] ynk_another_address_v7
	on			ynk_another_address_v7.[idfsBaseReference] = hai_v7.[IsAnotherAddressID]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_another_address_en_v7
	on			ynk_another_address_en_v7.[idfsBaseReference] = hai_v7.[IsAnotherAddressID]
				and ynk_another_address_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_another_address_lng_v7
	on			ynk_another_address_lng_v7.[idfsBaseReference] = hai_v7.[IsAnotherAddressID]
				and ynk_another_address_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] ynk_soughtcare_v7
	on			ynk_soughtcare_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNPreviouslySoughtCare]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_soughtcare_en_v7
	on			ynk_soughtcare_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNPreviouslySoughtCare]
				and ynk_soughtcare_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_soughtcare_lng_v7
	on			ynk_soughtcare_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNPreviouslySoughtCare]
				and ynk_soughtcare_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] ynk_hospitalization_v7
	on			ynk_hospitalization_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNHospitalization]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_hospitalization_en_v7
	on			ynk_hospitalization_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNHospitalization]
				and ynk_hospitalization_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_hospitalization_lng_v7
	on			ynk_hospitalization_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNHospitalization]
				and ynk_hospitalization_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] ynk_locexp_v7
	on			ynk_locexp_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNExposureLocationKnown]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_locexp_en_v7
	on			ynk_locexp_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNExposureLocationKnown]
				and ynk_locexp_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] ynk_locexp_lng_v7
	on			ynk_locexp_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsYNExposureLocationKnown]
				and ynk_locexp_lng_v7.[idfsLanguage] = @intLngNat

)
full join
(	[Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6
	left join	[Giraffe].[dbo].[_dmccHumanCase] cchc
	on	cchc.[idfHumanCase_v6] = tlbHumanCase_v6.[idfHumanCase]


	left join	[Falcon].[dbo].[trtBaseReference] tentative_diag_v6
	on			tentative_diag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] tentative_diag_en_v6
	on			tentative_diag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
				and tentative_diag_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] tentative_diag_lng_v6
	on			tentative_diag_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
				and tentative_diag_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[trtBaseReference] final_diag_v6
	on			final_diag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_diag_en_v6
	on			final_diag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
				and final_diag_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_diag_lng_v6
	on			final_diag_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
				and final_diag_lng_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] cs_v6
	on			cs_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsCaseProgressStatus]
	left join	[Falcon].[dbo].[trtStringNameTranslation] cs_en_v6
	on			cs_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsCaseProgressStatus]
				and cs_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] cs_lng_v6
	on			cs_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsCaseProgressStatus]
				and cs_lng_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] initial_cc_v6
	on			initial_cc_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsInitialCaseStatus]
	left join	[Falcon].[dbo].[trtStringNameTranslation] initial_cc_en_v6
	on			initial_cc_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsInitialCaseStatus]
				and initial_cc_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] initial_cc_lng_v6
	on			initial_cc_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsInitialCaseStatus]
				and initial_cc_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[trtBaseReference] final_cc_v6
	on			final_cc_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalCaseStatus]
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_cc_en_v6
	on			final_cc_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalCaseStatus]
				and final_cc_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_cc_lng_v6
	on			final_cc_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalCaseStatus]
				and final_cc_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[trtBaseReference] ynk_hospitalization_v6
	on			ynk_hospitalization_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNHospitalization]
	left join	[Falcon].[dbo].[trtStringNameTranslation] ynk_hospitalization_en_v6
	on			ynk_hospitalization_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNHospitalization]
				and ynk_hospitalization_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] ynk_hospitalization_lng_v6
	on			ynk_hospitalization_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNHospitalization]
				and ynk_hospitalization_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[trtBaseReference] nonnotifdiag_v6
	on			nonnotifdiag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsNonNotifiableDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] nonnotifdiag_en_v6
	on			nonnotifdiag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsNonNotifiableDiagnosis]
				and nonnotifdiag_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] nonnotifdiag_lng_v6
	on			nonnotifdiag_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsNonNotifiableDiagnosis]
				and nonnotifdiag_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[fnInstitutionRepair]('en') soughtCareFacility_v6
	on			soughtCareFacility_v6.[idfOffice] = tlbHumanCase_v6.[idfSoughtCareFacility]


	left join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
	on			tlbHuman_v6.[idfHuman] = tlbHumanCase_v6.[idfHuman]

	left join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6
	on			tlbHumanActual_v6.[idfHumanActual] = tlbHuman_v6.[idfHumanActual]


	left join	[Falcon].[dbo].[tlbGeoLocation] gl_cr_v6
	on			gl_cr_v6.[idfGeoLocation] = tlbHuman_v6.[idfCurrentResidenceAddress]

	left join	[Falcon].[dbo].[gisBaseReference] gl_cr_region_v6
	on			gl_cr_region_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRegion
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_region_en_v6
	on			gl_cr_region_en_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRegion
				and gl_cr_region_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_region_lng_v6
	on			gl_cr_region_lng_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRegion
				and gl_cr_region_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[gisBaseReference] gl_cr_rayon_v6
	on			gl_cr_rayon_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRayon
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_rayon_en_v6
	on			gl_cr_rayon_en_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRayon
				and gl_cr_rayon_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_rayon_lng_v6
	on			gl_cr_rayon_lng_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRayon
				and gl_cr_rayon_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[gisBaseReference] gl_cr_stlm_v6
	on			gl_cr_stlm_v6.[idfsGISBaseReference] = gl_cr_v6.idfsSettlement
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_stlm_en_v6
	on			gl_cr_stlm_en_v6.[idfsGISBaseReference] = gl_cr_v6.idfsSettlement
				and gl_cr_stlm_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_stlm_lng_v6
	on			gl_cr_stlm_lng_v6.[idfsGISBaseReference] = gl_cr_v6.idfsSettlement
				and gl_cr_stlm_lng_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[tlbGeoLocation] gl_emp_v6
	on			gl_emp_v6.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]


	left join	[Falcon].[dbo].[tlbGeoLocation] gl_reg_v6
	on			gl_reg_v6.[idfGeoLocation] = tlbHuman_v6.[idfRegistrationAddress]


	left join	[Falcon].[dbo].[tlbGeoLocation] gl_locexp_v6
	on			gl_locexp_v6.[idfGeoLocation] = tlbHumanCase_v6.[idfPointGeoLocation]


	outer apply
	(	select
					STRING_AGG(ISNULL(cchc_diff_v7res.strCaseID, cchc_diff.strCaseID_v7), N',') as strOtherMatchingHDRs
		from		[Giraffe].[dbo].[_dmccHumanCase] cchc_diff
		left join	[Giraffe].[dbo].[tlbHumanCase] cchc_diff_v7res
		on			cchc_diff_v7res.[idfHumanCase] = cchc_diff.[idfHumanCase_v7]
		where		cchc_diff.[idfHumanCase_v6] = tlbHumanCase_v6.[idfHumanCase]
					and cchc_diff.[idfId] <> cchc.[idfId]
	) cchc_other
)
on	cchc.[idfHumanCase_v7] = tlbHumanCase_v7.[idfHumanCase]
outer apply
(	select	ISNULL(
		(
			select		N', ' + d.strDifference
			from		@Differences d
			where		(	(tlbHumanCase_v6.[idfHumanCase] is null and d.idfId = 1)
							or	(tlbHumanCase_v7.[idfHumanCase] is null and d.idfId = 2)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and cchc_other.strOtherMatchingHDRs is null
									and d.idfId = 3
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and cchc_other.strOtherMatchingHDRs is not null
									and d.idfId = 4
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (tlbHumanCase_v6.[intRowStatus] <> tlbHumanCase_v7.[intRowStatus])
									and d.idfId = 5
								)


							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[idfsTentativeDiagnosis] is null and tlbHumanCase_v7.[idfsTentativeDiagnosis] is not null
											)
											or	(	tlbHumanCase_v6.[idfsTentativeDiagnosis] is not null and tlbHumanCase_v7.[idfsTentativeDiagnosis] is null
												)
											or	(	tlbHumanCase_v6.[idfsTentativeDiagnosis] is not null and tlbHumanCase_v7.[idfsTentativeDiagnosis] is not null
													and tlbHumanCase_v6.[idfsTentativeDiagnosis] <> tlbHumanCase_v7.[idfsTentativeDiagnosis]
												)
										)
									and d.idfId = 6
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[datTentativeDiagnosisDate] is null and tlbHumanCase_v7.[datTentativeDiagnosisDate] is not null
											)
											or	(	tlbHumanCase_v6.[datTentativeDiagnosisDate] is not null and tlbHumanCase_v7.[datTentativeDiagnosisDate] is null
												)
											or	(	tlbHumanCase_v6.[datTentativeDiagnosisDate] is not null and tlbHumanCase_v7.[datTentativeDiagnosisDate] is not null
													and tlbHumanCase_v6.[datTentativeDiagnosisDate] <> tlbHumanCase_v7.[datTentativeDiagnosisDate]
												)
										)
									and d.idfId = 7
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[idfsFinalDiagnosis] is null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
											)
											or	(	tlbHumanCase_v6.[idfsFinalDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is null
												)
											or	(	tlbHumanCase_v6.[idfsFinalDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
													and tlbHumanCase_v6.[idfsFinalDiagnosis] <> tlbHumanCase_v7.[idfsFinalDiagnosis]
												)
										)
									and d.idfId = 8
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[datFinalDiagnosisDate] is null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
											)
											or	(	tlbHumanCase_v6.[datFinalDiagnosisDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is null
												)
											or	(	tlbHumanCase_v6.[datFinalDiagnosisDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
													and tlbHumanCase_v6.[datFinalDiagnosisDate] <> tlbHumanCase_v7.[datFinalDiagnosisDate]
												)
										)
									and d.idfId = 9
								)


							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHuman_v6.[strLastName] is null and tlbHuman_v7.[strLastName] is not null
											)
											or	(	tlbHuman_v6.[strLastName] is not null and tlbHuman_v7.[strLastName] is null
												)
											or	(	tlbHuman_v6.[strLastName] is not null and tlbHuman_v7.[strLastName] is not null
													and tlbHuman_v6.[strLastName] <> tlbHuman_v7.[strLastName]
												)

											or	(	tlbHuman_v6.[strFirstName] is null and tlbHuman_v7.[strFirstName] is not null
												)
											or	(	tlbHuman_v6.[strFirstName] is not null and tlbHuman_v7.[strFirstName] is null
												)
											or	(	tlbHuman_v6.[strFirstName] is not null and tlbHuman_v7.[strFirstName] is not null
													and tlbHuman_v6.[strFirstName] <> tlbHuman_v7.[strFirstName]
												)

											or	(	tlbHuman_v6.[strSecondName] is null and tlbHuman_v7.[strSecondName] is not null
												)
											or	(	tlbHuman_v6.[strSecondName] is not null and tlbHuman_v7.[strSecondName] is null
												)
											or	(	tlbHuman_v6.[strSecondName] is not null and tlbHuman_v7.[strSecondName] is not null
													and tlbHuman_v6.[strSecondName] <> tlbHuman_v7.[strSecondName]
												)
										)
									and d.idfId = 10
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHuman_v6.[datDateofBirth] is null and tlbHuman_v7.[datDateofBirth] is not null
											)
											or	(	tlbHuman_v6.[datDateofBirth] is not null and tlbHuman_v7.[datDateofBirth] is null
												)
											or	(	tlbHuman_v6.[datDateofBirth] is not null and tlbHuman_v7.[datDateofBirth] is not null
													and tlbHuman_v6.[datDateofBirth] <> tlbHuman_v7.[datDateofBirth]
												)
										)
									and d.idfId = 11
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[intPatientAge] is null and tlbHumanCase_v7.[intPatientAge] is not null
											)
											or	(	tlbHumanCase_v6.[intPatientAge] is not null and tlbHumanCase_v7.[intPatientAge] is null
												)
											or	(	tlbHumanCase_v6.[intPatientAge] is not null and tlbHumanCase_v7.[intPatientAge] is not null
													and tlbHumanCase_v6.[intPatientAge] <> tlbHumanCase_v7.[intPatientAge]
												)

											or	(	tlbHumanCase_v6.[idfsHumanAgeType] is null and tlbHumanCase_v7.[idfsHumanAgeType] is not null
												)
											or	(	tlbHumanCase_v6.[idfsHumanAgeType] is not null and tlbHumanCase_v7.[idfsHumanAgeType] is null
												)
											or	(	tlbHumanCase_v6.[idfsHumanAgeType] is not null and tlbHumanCase_v7.[idfsHumanAgeType] is not null
													and tlbHumanCase_v6.[idfsHumanAgeType] <> tlbHumanCase_v7.[idfsHumanAgeType]
												)

											or	(	tlbHumanCase_v6.[intPatientAge] is null and hai_v7.[ReportedAge] is not null
												)
											or	(	tlbHumanCase_v6.[intPatientAge] is not null and hai_v7.[ReportedAge] is null
												)
											or	(	tlbHumanCase_v6.[intPatientAge] is not null and hai_v7.[ReportedAge] is not null
													and tlbHumanCase_v6.[intPatientAge] <> hai_v7.[ReportedAge]
												)

											or	(	tlbHumanCase_v6.[idfsHumanAgeType] is null and hai_v7.[ReportedAgeUOMID] is not null
												)
											or	(	tlbHumanCase_v6.[idfsHumanAgeType] is not null and hai_v7.[ReportedAgeUOMID] is null
												)
											or	(	tlbHumanCase_v6.[idfsHumanAgeType] is not null and hai_v7.[ReportedAgeUOMID] is not null
													and tlbHumanCase_v6.[idfsHumanAgeType] <> hai_v7.[ReportedAgeUOMID]
												)
										)
									and d.idfId = 12
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHuman_v6.[idfsHumanGender] is null and tlbHuman_v7.[idfsHumanGender] is not null
											)
											or	(	tlbHuman_v6.[idfsHumanGender] is not null and tlbHuman_v7.[idfsHumanGender] is null
												)
											or	(	tlbHuman_v6.[idfsHumanGender] is not null and tlbHuman_v7.[idfsHumanGender] is not null
													and tlbHuman_v6.[idfsHumanGender] <> tlbHuman_v7.[idfsHumanGender]
												)
										)
									and d.idfId = 13
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	gl_cr_v6.[idfsGeoLocationType] is null and gl_cr_v7.[idfsGeoLocationType] is not null
											)
											or	(	gl_cr_v6.[idfsGeoLocationType] is not null and gl_cr_v7.[idfsGeoLocationType] is null
												)
											or	(	gl_cr_v6.[idfsGeoLocationType] is not null and gl_cr_v7.[idfsGeoLocationType] is not null
													and gl_cr_v6.[idfsGeoLocationType] <> gl_cr_v7.[idfsGeoLocationType]
												)


											or	(	gl_cr_v6.[idfsCountry] is null and ld_cr_en_v7.[Level1ID] is not null
												)
											or	(	gl_cr_v6.[idfsCountry] is not null and ld_cr_en_v7.[Level1ID] is null
												)
											or	(	gl_cr_v6.[idfsCountry] is not null and ld_cr_en_v7.[Level1ID] is not null
													and gl_cr_v6.[idfsCountry] <> ld_cr_en_v7.[Level1ID]
												)

											or	(	gl_cr_v6.[blnForeignAddress] is null and gl_cr_v7.[blnForeignAddress] is not null
												)
											or	(	gl_cr_v6.[blnForeignAddress] is not null and gl_cr_v7.[blnForeignAddress] is null
												)
											or	(	gl_cr_v6.[blnForeignAddress] is not null and gl_cr_v7.[blnForeignAddress] is not null
													and gl_cr_v6.[blnForeignAddress] <> gl_cr_v7.[blnForeignAddress]
												)


											or	(	gl_cr_v6.[blnForeignAddress] is not null and gl_cr_v7.[blnForeignAddress] is not null
													and gl_cr_v6.[blnForeignAddress] = gl_cr_v7.[blnForeignAddress]
													and gl_cr_v6.[blnForeignAddress] = 0
													and	(	(	gl_cr_v6.[idfsRegion] is null and ld_cr_en_v7.[Level2ID] is not null
															)
															or	(	gl_cr_v6.[idfsRegion] is not null and ld_cr_en_v7.[Level2ID] is null
																)
															or	(	gl_cr_v6.[idfsRegion] is not null and ld_cr_en_v7.[Level2ID] is not null
																	and gl_cr_v6.[idfsRegion] <> ld_cr_en_v7.[Level2ID]
																)

															or	(	gl_cr_v6.[idfsRayon] is null and ld_cr_en_v7.[Level3ID] is not null
																)
															or	(	gl_cr_v6.[idfsRayon] is not null and ld_cr_en_v7.[Level3ID] is null
																)
															or	(	gl_cr_v6.[idfsRayon] is not null and ld_cr_en_v7.[Level3ID] is not null
																	and gl_cr_v6.[idfsRayon] <> ld_cr_en_v7.[Level3ID]
																)

															or	(	gl_cr_v6.[idfsRayon] is null and ld_cr_en_v7.[Level3ID] is not null
																)
															or	(	gl_cr_v6.[idfsRayon] is not null and ld_cr_en_v7.[Level3ID] is null
																)
															or	(	gl_cr_v6.[idfsRayon] is not null and ld_cr_en_v7.[Level3ID] is not null
																	and gl_cr_v6.[idfsRayon] <> ld_cr_en_v7.[Level3ID]
																)

															or	(	gl_cr_v6.[idfsSettlement] is null and ld_cr_en_v7.[Level4ID] is not null
																)
															or	(	gl_cr_v6.[idfsSettlement] is not null and ld_cr_en_v7.[Level4ID] is null
																)
															or	(	gl_cr_v6.[idfsSettlement] is not null and ld_cr_en_v7.[Level4ID] is not null
																	and gl_cr_v6.[idfsSettlement] <> ld_cr_en_v7.[Level4ID]
																)
														)
												)


											or	(	gl_cr_v6.[blnForeignAddress] is not null and gl_cr_v7.[blnForeignAddress] is not null
													and gl_cr_v6.[blnForeignAddress] = gl_cr_v7.[blnForeignAddress]
													and gl_cr_v6.[blnForeignAddress] = 1
													and	(	(	gl_cr_v6.[strAddressString] is null and gl_cr_v7.[strAddressString] is not null
															)
															or	(	gl_cr_v6.[strAddressString] is not null and gl_cr_v7.[strAddressString] is null
																)
															or	(	gl_cr_v6.[strAddressString] is not null and gl_cr_v7.[strAddressString] is not null
																	and gl_cr_v6.[strAddressString] <> gl_cr_v7.[strAddressString]
																)
														)
												)
										)
									and d.idfId = 14
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	tlbHumanActual_v7.[idfHumanActual] is null
											or haai_v7.[HumanActualAddlInfoUID] is null
										)
									and d.idfId = 15
								)


							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[idfsInitialCaseStatus] is null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
											)
											or	(	tlbHumanCase_v6.[idfsInitialCaseStatus] is not null and tlbHumanCase_v7.[idfsInitialCaseStatus] is null
												)
											or	(	tlbHumanCase_v6.[idfsInitialCaseStatus] is not null and tlbHumanCase_v7.[idfsInitialCaseStatus] is not null
													and tlbHumanCase_v6.[idfsInitialCaseStatus] <> tlbHumanCase_v7.[idfsInitialCaseStatus]
												)
										)
									and d.idfId = 16
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[blnClinicalDiagBasis] is null and tlbHumanCase_v7.[blnClinicalDiagBasis] is not null
											)
											or	(	tlbHumanCase_v6.[blnClinicalDiagBasis] is not null and tlbHumanCase_v7.[blnClinicalDiagBasis] is null
												)
											or	(	tlbHumanCase_v6.[blnClinicalDiagBasis] is not null and tlbHumanCase_v7.[blnClinicalDiagBasis] is not null
													and tlbHumanCase_v6.[blnClinicalDiagBasis] <> tlbHumanCase_v7.[blnClinicalDiagBasis]
												)
											or	(	tlbHumanCase_v6.[blnEpiDiagBasis] is null and tlbHumanCase_v7.[blnEpiDiagBasis] is not null
												)
											or	(	tlbHumanCase_v6.[blnEpiDiagBasis] is not null and tlbHumanCase_v7.[blnEpiDiagBasis] is null
												)
											or	(	tlbHumanCase_v6.[blnEpiDiagBasis] is not null and tlbHumanCase_v7.[blnEpiDiagBasis] is not null
													and tlbHumanCase_v6.[blnEpiDiagBasis] <> tlbHumanCase_v7.[blnEpiDiagBasis]
												)
											or	(	tlbHumanCase_v6.[blnLabDiagBasis] is null and tlbHumanCase_v7.[blnLabDiagBasis] is not null
												)
											or	(	tlbHumanCase_v6.[blnLabDiagBasis] is not null and tlbHumanCase_v7.[blnLabDiagBasis] is null
												)
											or	(	tlbHumanCase_v6.[blnLabDiagBasis] is not null and tlbHumanCase_v7.[blnLabDiagBasis] is not null
													and tlbHumanCase_v6.[blnLabDiagBasis] <> tlbHumanCase_v7.[blnLabDiagBasis]
												)
										)
									and d.idfId = 17
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[idfsFinalCaseStatus] is null and tlbHumanCase_v7.[idfsFinalCaseStatus] is not null
											)
											or	(	tlbHumanCase_v6.[idfsFinalCaseStatus] is not null and tlbHumanCase_v7.[idfsFinalCaseStatus] is null
												)
											or	(	tlbHumanCase_v6.[idfsFinalCaseStatus] is not null and tlbHumanCase_v7.[idfsFinalCaseStatus] is not null
													and tlbHumanCase_v6.[idfsFinalCaseStatus] <> tlbHumanCase_v7.[idfsFinalCaseStatus]
												)
										)
									and d.idfId = 18
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[datFinalCaseClassificationDate] is null and tlbHumanCase_v7.[datFinalCaseClassificationDate] is not null
											)
											or	(	tlbHumanCase_v6.[datFinalCaseClassificationDate] is not null and tlbHumanCase_v7.[datFinalCaseClassificationDate] is null
												)
											or	(	tlbHumanCase_v6.[datFinalCaseClassificationDate] is not null and tlbHumanCase_v7.[datFinalCaseClassificationDate] is not null
													and tlbHumanCase_v6.[datFinalCaseClassificationDate] <> tlbHumanCase_v7.[datFinalCaseClassificationDate]
												)
										)
									and d.idfId = 19
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[idfsCaseProgressStatus] is null and tlbHumanCase_v7.[idfsCaseProgressStatus] is not null
											)
											or	(	tlbHumanCase_v6.[idfsCaseProgressStatus] is not null and tlbHumanCase_v7.[idfsCaseProgressStatus] is null
												)
											or	(	tlbHumanCase_v6.[idfsCaseProgressStatus] is not null and tlbHumanCase_v7.[idfsCaseProgressStatus] is not null
													and tlbHumanCase_v6.[idfsCaseProgressStatus] <> tlbHumanCase_v7.[idfsCaseProgressStatus]
												)
										)
									and d.idfId = 20
								)


							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	tlbHumanCase_v7.[DiseaseReportTypeID] is null
											or	(	tlbHumanCase_v7.[DiseaseReportTypeID] is not null and tlbHumanCase_v7.[DiseaseReportTypeID] <> 4578940000002 /*Passive*/
												)
										)
									and d.idfId = 21
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	(	(	(	tlbHuman_v6.strEmployerName is not null
														and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'' collate Cyrillic_General_CI_AS
													)
													or	(	gl_emp_v6.blnForeignAddress = 1 
															or gl_emp_v6.idfsRegion is not null
														)
													or	(	tlbHuman_v6.strWorkPhone is not null
															and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'' collate Cyrillic_General_CI_AS
														)
												)
												and (	hai_v7.[IsEmployedID] is null
														or	(	hai_v7.[IsEmployedID] is not null and hai_v7.[IsEmployedID] <> 10100001 /*Yes*/
															)
													)
											)
											or	(	(	(	tlbHuman_v6.strEmployerName is null
															or ltrim(rtrim(tlbHuman_v6.strEmployerName)) = N'' collate Cyrillic_General_CI_AS
														)
														and	(	gl_emp_v6.idfGeoLocation is null
																or	(	gl_emp_v6.blnForeignAddress = 0 
																		and gl_emp_v6.idfsRegion is null
																	)
															)
														and	(	tlbHuman_v6.strWorkPhone is null
																or ltrim(rtrim(tlbHuman_v6.strWorkPhone)) = N'' collate Cyrillic_General_CI_AS
															)
													)
													and hai_v7.[IsEmployedID] is not null
												)
										)
									and d.idfId = 22
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	hai_v7.[IsAnotherPhoneID] is not null
											and hai_v7.[IsAnotherPhoneID] <> 10100002 /*No*/
										)
									and d.idfId = 23
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	(	(	gl_reg_v6.blnForeignAddress = 1 
													or gl_reg_v6.idfsRegion is not null
												)
												and (	hai_v7.[IsAnotherAddressID] is null
														or	(	hai_v7.[IsAnotherAddressID] is not null and hai_v7.[IsAnotherAddressID] <> 10100001 /*Yes*/
															)
													)
											)
											or	(	(	gl_reg_v6.idfGeoLocation is null
														or	(	gl_reg_v6.blnForeignAddress = 0 
																and gl_reg_v6.idfsRegion is null
															)
													)
													and hai_v7.[IsAnotherAddressID] is not null
													and hai_v7.[IsAnotherAddressID] <> 10100002 /*No*/
												)
										)
									and d.idfId = 24
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	(	(	tlbHumanCase_v6.[idfSoughtCareFacility] is not null
													or	tlbHumanCase_v6.[datFirstSoughtCareDate] is not null
													or	tlbHumanCase_v6.[idfsNonNotifiableDiagnosis] is not null
												)
												and (	tlbHumanCase_v7.[idfsYNPreviouslySoughtCare] is null
														or	(	tlbHumanCase_v7.[idfsYNPreviouslySoughtCare] is not null and tlbHumanCase_v7.[idfsYNPreviouslySoughtCare] <> 10100001 /*Yes*/
															)
													)
											)
											or	(	(	tlbHumanCase_v6.[idfSoughtCareFacility] is null
														and	tlbHumanCase_v6.[datFirstSoughtCareDate] is null
														and	tlbHumanCase_v6.[idfsNonNotifiableDiagnosis] is null
													)
													and tlbHumanCase_v7.[idfsYNPreviouslySoughtCare] is not null
												)
										)
									and d.idfId = 25
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	(	tlbHumanCase_v6.[idfsYNHospitalization] is not null
												and tlbHumanCase_v7.[idfsYNHospitalization] is null
											)
											or	(	tlbHumanCase_v6.[idfsYNHospitalization] is null
													and tlbHumanCase_v7.[idfsYNHospitalization] is not null
												)
											or	(	tlbHumanCase_v6.[idfsYNHospitalization] is not null
													and tlbHumanCase_v7.[idfsYNHospitalization] is not null
													and tlbHumanCase_v6.[idfsYNHospitalization] <> tlbHumanCase_v7.[idfsYNHospitalization]
												)
										)
									and d.idfId = 26
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	(	(	(	gl_locexp_v6.[idfsCountry] is not null
														and	gl_locexp_v6.[idfsCountry] <> @idfsCountry
														and gl_locexp_v6.blnForeignAddress = 1
													)
													or	gl_locexp_v6.idfsRegion is not null
													or	tlbHumanCase_v6.[datExposureDate] is not null
												)
												and (	tlbHumanCase_v7.[idfsYNExposureLocationKnown] is null
														or	(	tlbHumanCase_v7.[idfsYNExposureLocationKnown] is not null and tlbHumanCase_v7.[idfsYNExposureLocationKnown] <> 10100001 /*Yes*/
															)
													)
											)
											or	(	(	(	gl_locexp_v6.idfGeoLocation is null
															or	(	gl_locexp_v6.blnForeignAddress = 0 
																	and gl_locexp_v6.idfsRegion is null
																)
															or	(	gl_locexp_v6.blnForeignAddress = 1
																	and (	gl_locexp_v6.[idfsCountry] is null
																			or 	gl_locexp_v6.[idfsCountry] = @idfsCountry
																		)
																)
														)
														and	tlbHumanCase_v6.[datExposureDate] is null
													)
													and tlbHumanCase_v7.[idfsYNExposureLocationKnown] is not null
												)
										)
									and d.idfId = 27
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and	(	(	tlbHumanCase_v6.[strCaseID] is not null
												and tlbHumanCase_v7.[LegacyCaseID] is null
											)
											or	(	tlbHumanCase_v6.[strCaseID] is null
													and tlbHumanCase_v7.[LegacyCaseID] is not null
												)
											or	(	tlbHumanCase_v6.[strCaseID] is not null
													and tlbHumanCase_v7.[LegacyCaseID] is not null
													and tlbHumanCase_v6.[strCaseID] <> tlbHumanCase_v7.[LegacyCaseID] collate Cyrillic_General_CI_AS
												)
										)
									and d.idfId = 28
								)
						)
			order by	d.idfId asc
			for xml path('')
		), N',') strDifferences
) diff
order by	tlbHumanCase_v6.datEnteredDate, tlbHumanCase_v6.strCaseID, tlbHumanCase_v6.idfHumanCase, tlbHumanCase_v7.datEnteredDate, tlbHumanCase_v7.LegacyCaseID, tlbHumanCase_v7.strCaseID, tlbHumanCase_v7.idfHumanCase
