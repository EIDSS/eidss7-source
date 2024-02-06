
/**************************************************************************************************************************************
* Check script of data migration results: Human Disease Report Counts.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 are located.
* By default, in the script EIDSSv6.1 database has the name Falcon and EIDSSv7 database has the name Giraffe.
* Specify abbreviation of national language if needed.
**************************************************************************************************************************************/

declare	@strNationalLng nvarchar(200)
set @strNationalLng = N'' -- Georgian - ka, Azerbaijani - az-L

declare	@intLngEn bigint
declare @intLngNat bigint

set @intLngEn = [Falcon].dbo.fnGetLanguageCode('en')
set @intLngNat = [Falcon].dbo.fnGetLanguageCode(@strNationalLng)

if @intLngNat is null
	set	@intLngNat = @intLngEn

declare	@Differences table
(	idfId int not null primary key,
	strDifference nvarchar(200) collate Cyrillic_General_CI_AS not null
)

insert into @Differences (idfId, strDifference) values
 (1, N'New record in v7')
,(2, N'Not transferred from v6')
,(3, N'Initial HDR v7 based on HC v6.1')
,(4, N'Related HDR v7 based on Diagnosis Change History of HC v6.1')
,(5, N'Most recent HDR v7 based on Diagnosis Change History of HC v6.1')
,(6, N'Most recent HDR v7 based on Changed Diagnosis of HC v6.1')
,(7, N'HDR v7 matching HC v6.1')
,(8, N'Deletion State Change')
,(9, N'Diagnosis Change')
,(10, N'Diagnosis Date Change')
,(11, N'Initial Case Classification Change')
,(12, N'Basis of Diagnosis Change')
,(13, N'Final Case Classification Change')
,(14, N'Final Case Classification Date Change')
,(15, N'Case Status Change')


select	STUFF(diff.strDifferences, 1, 1, N'') as 'Migration Result',
		isnull(cast(tlbHumanCase_v6.idfHumanCase as varchar(20)), N'') as 'System Identifier v6',
		case when tlbHumanCase_v6.datEnteredDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datEnteredDate, 104) end as 'Entered Date v6',
		isnull(tlbHumanCase_v6.strCaseID, N'') as 'Case ID v6',
		coalesce(gl_cr_region_en_v6.strTextString, gl_cr_region_v6.strDefault, N'') as 'Region v6',
		coalesce(gl_cr_rayon_en_v6.strTextString, gl_cr_rayon_v6.strDefault, N'') as 'Rayon v6',
		[Falcon].dbo.fnConcatFullName(tlbHuman_v6.strLastName, tlbHuman_v6.strFirstName, tlbHuman_v6.strSecondName) as 'Patient Name v6',
		coalesce(tentative_diag_en_v6.strTextString, tentative_diag_v6.strDefault, N'') as 'Diagnosis v6',
		case when tlbHumanCase_v6.datTentativeDiagnosisDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datTentativeDiagnosisDate, 104) end as 'Diagnosis Date v6',
		coalesce(initial_cc_en_v6.strTextString, initial_cc_v6.strDefault, N'') as 'Initial Case Classification v6',
		coalesce(prev_diag_en_v6.strTextString, prev_diag_v6.strDefault, N'') as 'Diagnosis Change History - Before Change v6',
		coalesce(change_diag_en_v6.strTextString, change_diag_v6.strDefault, N'') as 'Diagnosis Change History - After Change v6',
		case when tlbChangeDiagnosisHistory_v6.datChangedDate is null then N'' else convert(nvarchar, tlbChangeDiagnosisHistory_v6.datChangedDate, 104) end as 'Diagnosis Change History - Date v6',
		coalesce(change_diag_reason_en_v6.strTextString, change_diag_reason_v6.strDefault, tlbChangeDiagnosisHistory_v6.strReason, N'') as 'Diagnosis Change History - Reason v6',
		coalesce(final_diag_en_v6.strTextString, final_diag_v6.strDefault, N'') as 'Current Changed Diagnosis v6',
		case when tlbHumanCase_v6.datFinalDiagnosisDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datFinalDiagnosisDate, 104) end as 'Current Changed Diagnosis Date v6',
		coalesce(final_cc_en_v6.strTextString, final_cc_v6.strDefault, N'') as 'Final Case Classification v6',
		replace(replace(cast(isnull(tlbHumanCase_v6.blnClinicalDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Clinical') + 
			case when cast(isnull(tlbHumanCase_v6.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v6.blnEpiDiagBasis, 0) as int) = 2 then N',' else N'' end +
			replace(replace(cast(isnull(tlbHumanCase_v6.blnEpiDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Epi') + 
				case when tlbHumanCase_v6.blnLabDiagBasis = 1 and cast(isnull(tlbHumanCase_v6.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v6.blnEpiDiagBasis, 0) as int) >= 1 then N',' else N'' end + 
				replace(replace(cast(isnull(tlbHumanCase_v6.blnLabDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Lab') as 'Basis of Diagnosis v6.1',
		case when tlbHumanCase_v6.datFinalCaseClassificationDate is null then N'' else convert(nvarchar, tlbHumanCase_v6.datFinalCaseClassificationDate, 104) end as 'Final Case Classification Date v6',
		coalesce(cs_en_v6.strTextString, cs_v6.strDefault, N'') as 'Case Status v6',

		--isnull(tlbHumanCase_v6.strNote, N'') as 'Additional Notes v6',

		isnull(cast(tlbHumanCase_v7.idfHumanCase as varchar(20)), N'') as 'System Identifier v7',
		case when tlbHumanCase_v7.datEnteredDate is null then N'' else convert(nvarchar, tlbHumanCase_v7.datEnteredDate, 104) end as 'Entered Date v7',
		isnull(tlbHumanCase_v7.strCaseID, N'') as 'Case ID v7',
		isnull(tlbHumanCase_v7.LegacyCaseID, N'') as 'Legacy Case ID v7',
		coalesce(gl_cr_region_en_v7.strTextString, gl_cr_region_v7.strDefault, N'') as 'Region v7',
		coalesce(gl_cr_rayon_en_v7.strTextString, gl_cr_rayon_v7.strDefault, N'') as 'Rayon v7',
		[Falcon].dbo.fnConcatFullName(tlbHuman_v7.strLastName, tlbHuman_v7.strFirstName, tlbHuman_v7.strSecondName) as 'Patient Name v7',
		coalesce(final_diag_en_v7.strTextString, final_diag_v7.strDefault, N'') as 'Diagnosis v7',
		case when tlbHumanCase_v7.datFinalDiagnosisDate is null and tlbHumanCase_v7.datTentativeDiagnosisDate is null then N'' else convert(nvarchar, isnull(tlbHumanCase_v7.datFinalDiagnosisDate, tlbHumanCase_v7.datTentativeDiagnosisDate), 104) end as 'Diagnosis Date v7',
		coalesce(initial_cc_en_v7.strTextString, initial_cc_v7.strDefault, N'') as 'Initial Case Classification v7',
		coalesce(final_cc_en_v7.strTextString, final_cc_v7.strDefault, N'') as 'Final Case Classification v7',
		replace(replace(cast(isnull(tlbHumanCase_v7.blnClinicalDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Clinical') + 
			case when cast(isnull(tlbHumanCase_v7.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v7.blnEpiDiagBasis, 0) as int) = 2 then N',' else N'' end +
			replace(replace(cast(isnull(tlbHumanCase_v7.blnEpiDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Epi') + 
				case when tlbHumanCase_v7.blnLabDiagBasis = 1 and cast(isnull(tlbHumanCase_v7.blnClinicalDiagBasis, 0) as int) + cast(isnull(tlbHumanCase_v7.blnEpiDiagBasis, 0) as int) >= 1 then N',' else N'' end + 
				replace(replace(cast(isnull(tlbHumanCase_v7.blnLabDiagBasis, 0) as nvarchar(1)), N'0', N''), N'1', N'Lab') as 'Basis of Diagnosis v7.1',
		case when tlbHumanCase_v7.datFinalCaseClassificationDate is null then N'' else convert(nvarchar, tlbHumanCase_v7.datFinalCaseClassificationDate, 104) end as 'Final Case Classification Date v7',
		coalesce(cs_en_v7.strTextString, cs_v7.strDefault, N'') as 'Case Status v7',

		isnull(related_hdr.strRootCaseID, N'') as 'Initial Related HDR - Case ID',
		isnull(related_hdr.strRootLegacyCaseID, N'') as 'Initial Related HDR - Legacy Case ID',

		isnull(related_hdr.strCreatedFromCaseID, N'') as 'Created from HDR - Case ID',
		isnull(related_hdr.strCreatedFromLegacyCaseID, N'') as 'Created from HDR - Legacy Case ID'--,

		--isnull(tlbHumanCase_v7.strNote, N'') as 'Additional Notes v7'
from
(
	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7

	left join	[Giraffe].[dbo].[trtBaseReference] final_diag_v7
	on			final_diag_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_diag_en_v7
	on			final_diag_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
				and final_diag_en_v7.[idfsLanguage] = @intLngNat
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_diag_lng_v7
	on			final_diag_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
				and final_diag_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[trtBaseReference] cs_v7
	on			cs_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsCaseProgressStatus]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] cs_en_v7
	on			cs_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsCaseProgressStatus]
				and cs_en_v7.[idfsLanguage] = @intLngNat
	left join	[Giraffe].[dbo].[trtStringNameTranslation] cs_lng_v7
	on			cs_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsCaseProgressStatus]
				and cs_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[trtBaseReference] initial_cc_v7
	on			initial_cc_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsInitialCaseStatus]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] initial_cc_en_v7
	on			initial_cc_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsInitialCaseStatus]
				and initial_cc_en_v7.[idfsLanguage] = @intLngNat
	left join	[Giraffe].[dbo].[trtStringNameTranslation] initial_cc_lng_v7
	on			initial_cc_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsInitialCaseStatus]
				and initial_cc_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[trtBaseReference] final_cc_v7
	on			final_cc_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalCaseStatus]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_cc_en_v7
	on			final_cc_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalCaseStatus]
				and final_cc_en_v7.[idfsLanguage] = @intLngNat
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_cc_lng_v7
	on			final_cc_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalCaseStatus]
				and final_cc_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[tlbHuman] tlbHuman_v7
	on	tlbHuman_v7.[idfHuman] = tlbHumanCase_v7.[idfHuman]

	left join	[Giraffe].[dbo].[tlbGeoLocation] gl_cr_v7
	on			gl_cr_v7.[idfGeoLocation] = tlbHuman_v7.[idfCurrentResidenceAddress]

	--left join	[Giraffe].[dbo].[gisBaseReference] gl_cr_country_v7
	--on			gl_cr_country_v7.[idfsGISBaseReference] = gl_cr_v7.idfsCountry
	--left join	[Giraffe].[dbo].[gisStringNameTranslation] gl_cr_country_en_v7
	--on			gl_cr_country_en_v7.[idfsGISBaseReference] = gl_cr_v7.idfsCountry
	--			and gl_cr_country_en_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[gisBaseReference] gl_cr_region_v7
	on			gl_cr_region_v7.[idfsGISBaseReference] = gl_cr_v7.idfsRegion
	left join	[Giraffe].[dbo].[gisStringNameTranslation] gl_cr_region_en_v7
	on			gl_cr_region_en_v7.[idfsGISBaseReference] = gl_cr_v7.idfsRegion
				and gl_cr_region_en_v7.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[gisBaseReference] gl_cr_rayon_v7
	on			gl_cr_rayon_v7.[idfsGISBaseReference] = gl_cr_v7.idfsRayon
	left join	[Giraffe].[dbo].[gisStringNameTranslation] gl_cr_rayon_en_v7
	on			gl_cr_rayon_en_v7.[idfsGISBaseReference] = gl_cr_v7.idfsRayon
				and gl_cr_rayon_en_v7.[idfsLanguage] = @intLngNat

	outer apply
	(	select top 1	hdr_root.strCaseID as [strRootCaseID], hdr_root.[LegacyCaseID] as [strRootLegacyCaseID],
						hdr_relate_to.strCaseID as [strCreatedFromCaseID], hdr_relate_to.[LegacyCaseID] as [strCreatedFromLegacyCaseID]
		from	[Giraffe].[dbo].[HumanDiseaseReportRelationship] hdrr
		join	[Giraffe].[dbo].[tlbHumanCase] hdr_root
		on		hdr_root.[idfHumanCase] = hdrr.[RelatedToHumanDiseaseReportIdRoot]
		join	[Giraffe].[dbo].[tlbHumanCase] hdr_relate_to
		on		hdr_relate_to.[idfHumanCase] = hdrr.[RelateToHumanDiseaseReportID]
		where	hdrr.[HumanDiseaseReportID] = tlbHumanCase_v7.[idfHumanCase]
				and hdrr.intRowStatus <= tlbHumanCase_v7.intRowStatus
				--and hdrr.[RelationshipTypeID] = 10503001
	) related_hdr

)
full join
(	[Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6
	left join	[Giraffe].[dbo].[_dmccHumanCase] cchc
	on	cchc.[idfHumanCase_v6] = tlbHumanCase_v6.[idfHumanCase]
	left join	[Falcon].[dbo].[tlbChangeDiagnosisHistory] tlbChangeDiagnosisHistory_v6
	on			tlbChangeDiagnosisHistory_v6.[idfHumanCase] = tlbHumanCase_v6.[idfHumanCase]
				and tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] = cchc.[idfChangeDiagnosisHistory_v6]

	left join	[Falcon].[dbo].[trtBaseReference] prev_diag_v6
	on			prev_diag_v6.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsPreviousDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] prev_diag_en_v6
	on			prev_diag_en_v6.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsPreviousDiagnosis]
				and prev_diag_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] change_diag_v6
	on			change_diag_v6.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] change_diag_en_v6
	on			change_diag_en_v6.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis]
				and change_diag_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] change_diag_reason_v6
	on			change_diag_reason_v6.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsChangeDiagnosisReason]
	left join	[Falcon].[dbo].[trtStringNameTranslation] change_diag_reason_en_v6
	on			change_diag_reason_en_v6.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsChangeDiagnosisReason]
				and change_diag_reason_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] tentative_diag_v6
	on			tentative_diag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] tentative_diag_en_v6
	on			tentative_diag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
				and tentative_diag_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] final_diag_v6
	on			final_diag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_diag_en_v6
	on			final_diag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
				and final_diag_en_v6.[idfsLanguage] = @intLngNat



	left join	[Falcon].[dbo].[trtBaseReference] cs_v6
	on			cs_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsCaseProgressStatus]
	left join	[Falcon].[dbo].[trtStringNameTranslation] cs_en_v6
	on			cs_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsCaseProgressStatus]
				and cs_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] initial_cc_v6
	on			initial_cc_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsInitialCaseStatus]
	left join	[Falcon].[dbo].[trtStringNameTranslation] initial_cc_en_v6
	on			initial_cc_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsInitialCaseStatus]
				and initial_cc_en_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[trtBaseReference] final_cc_v6
	on			final_cc_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalCaseStatus]
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_cc_en_v6
	on			final_cc_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalCaseStatus]
				and final_cc_en_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
	on	tlbHuman_v6.[idfHuman] = tlbHumanCase_v6.[idfHuman]

	left join	[Falcon].[dbo].[tlbGeoLocation] gl_cr_v6
	on			gl_cr_v6.[idfGeoLocation] = tlbHuman_v6.[idfCurrentResidenceAddress]

	--left join	[Falcon].[dbo].[gisBaseReference] gl_cr_country_v6
	--on			gl_cr_country_v6.[idfsGISBaseReference] = gl_cr_v6.idfsCountry
	--left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_country_en_v6
	--on			gl_cr_country_en_v6.[idfsGISBaseReference] = gl_cr_v6.idfsCountry
	--			and gl_cr_country_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[gisBaseReference] gl_cr_region_v6
	on			gl_cr_region_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRegion
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_region_en_v6
	on			gl_cr_region_en_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRegion
				and gl_cr_region_en_v6.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[gisBaseReference] gl_cr_rayon_v6
	on			gl_cr_rayon_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRayon
	left join	[Falcon].[dbo].[gisStringNameTranslation] gl_cr_rayon_en_v6
	on			gl_cr_rayon_en_v6.[idfsGISBaseReference] = gl_cr_v6.idfsRayon
				and gl_cr_rayon_en_v6.[idfsLanguage] = @intLngNat

	outer apply
	(	select	top 1 cchc_diff.[idfId]
		from	[Giraffe].[dbo].[_dmccHumanCase] cchc_diff
		where	cchc_diff.[idfHumanCase_v6] = tlbHumanCase_v6.[idfHumanCase]
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
									and cchc_other.idfId is null
									and d.idfId = 7
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and cchc_other.idfId is not null
									and cchc.[isInitial] = 1
									and d.idfId = 3
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and cchc_other.idfId is not null
									and cchc.[isInitial] = 0
									and cchc.[isFinal] = 0
									and tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] is not null
									and d.idfId = 4
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and cchc_other.idfId is not null
									and cchc.[isInitial] = 0
									and cchc.[isFinal] = 1
									and tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] is not null
									and d.idfId = 5
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and cchc_other.idfId is not null
									and cchc.[isInitial] = 0
									and cchc.[isFinal] = 1
									and tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] is null
									and d.idfId = 6
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (tlbHumanCase_v6.[intRowStatus] <> tlbHumanCase_v7.[intRowStatus])
									and d.idfId = 8
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	cchc.[isInitial] = 1
												and (	(	tlbHumanCase_v6.[idfsTentativeDiagnosis] is null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
														)
														or	(	tlbHumanCase_v6.[idfsTentativeDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is null
															)
														or	(	tlbHumanCase_v6.[idfsTentativeDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
																and tlbHumanCase_v6.[idfsTentativeDiagnosis] <> tlbHumanCase_v7.[idfsFinalDiagnosis]
															)
													)
											)
											or	(	cchc.[isInitial] = 0
													and cchc.[isFinal] = 0
													and tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] is not null
													and (	(	tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis] is null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
															)
															or	(	tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is null
																)
															or	(	tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
																	and tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis] <> tlbHumanCase_v7.[idfsFinalDiagnosis]
																)
														)
												)
											or	(	cchc.[isInitial] = 0
													and cchc.[isFinal] = 1
													and (	(	tlbHumanCase_v6.[idfsFinalDiagnosis] is null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
															)
															or	(	tlbHumanCase_v6.[idfsFinalDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is null
																)
															or	(	tlbHumanCase_v6.[idfsFinalDiagnosis] is not null and tlbHumanCase_v7.[idfsFinalDiagnosis] is not null
																	and tlbHumanCase_v6.[idfsFinalDiagnosis] <> tlbHumanCase_v7.[idfsFinalDiagnosis]
																)
														)
												)
										)
									and d.idfId = 9
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	cchc.[isInitial] = 1
												and (	(	tlbHumanCase_v6.[datTentativeDiagnosisDate] is null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
														)
														or	(	tlbHumanCase_v6.[datTentativeDiagnosisDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is null
															)
														or	(	tlbHumanCase_v6.[datTentativeDiagnosisDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
																and tlbHumanCase_v6.[datTentativeDiagnosisDate] <> tlbHumanCase_v7.[datFinalDiagnosisDate]
															)
													)
											)
											or	(	cchc.[isInitial] = 0
													and cchc.[isFinal] = 0
													and tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] is not null
													and (	(	tlbChangeDiagnosisHistory_v6.[datChangedDate] is null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
															)
															or	(	tlbChangeDiagnosisHistory_v6.[datChangedDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is null
																)
															or	(	tlbChangeDiagnosisHistory_v6.[datChangedDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
																	and tlbChangeDiagnosisHistory_v6.[datChangedDate] <> tlbHumanCase_v7.[datFinalDiagnosisDate]
																)
														)
												)
											or	(	cchc.[isInitial] = 0
													and cchc.[isFinal] = 1
													and (	(	tlbHumanCase_v6.[datFinalDiagnosisDate] is null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
															)
															or	(	tlbHumanCase_v6.[datFinalDiagnosisDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is null
																)
															or	(	tlbHumanCase_v6.[datFinalDiagnosisDate] is not null and tlbHumanCase_v7.[datFinalDiagnosisDate] is not null
																	and tlbHumanCase_v6.[datFinalDiagnosisDate] <> tlbHumanCase_v7.[datFinalDiagnosisDate]
																)
														)
												)
										)
									and d.idfId = 10
								)
							or	(	tlbHumanCase_v6.[idfHumanCase] is not null and tlbHumanCase_v7.[idfHumanCase] is not null
									and (	(	tlbHumanCase_v6.[idfsInitialCaseStatus] is null and tlbHumanCase_v7.[idfsInitialCaseStatus] is not null
											)
											or	(	tlbHumanCase_v6.[idfsInitialCaseStatus] is not null and tlbHumanCase_v7.[idfsInitialCaseStatus] is null
												)
											or	(	tlbHumanCase_v6.[idfsInitialCaseStatus] is not null and tlbHumanCase_v7.[idfsInitialCaseStatus] is not null
													and tlbHumanCase_v6.[idfsInitialCaseStatus] <> tlbHumanCase_v7.[idfsInitialCaseStatus]
												)
										)
									and d.idfId = 11
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
									and d.idfId = 12
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
									and d.idfId = 13
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
									and d.idfId = 14
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
									and d.idfId = 15
								)
						)
			order by	d.idfId asc
			for xml path('')
		), N',') strDifferences
) diff
order by	tlbHumanCase_v6.datEnteredDate, tlbHumanCase_v6.strCaseID, tlbHumanCase_v6.idfHumanCase, tlbHumanCase_v7.datEnteredDate, tlbHumanCase_v7.LegacyCaseID, tlbHumanCase_v7.strCaseID, tlbHumanCase_v7.idfHumanCase
