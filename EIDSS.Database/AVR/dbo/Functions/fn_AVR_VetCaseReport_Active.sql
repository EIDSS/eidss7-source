﻿

CREATE FUNCTION [dbo].[fn_AVR_VetCaseReport_Active]
(
@LangID	as nvarchar(50)
)
returns table
as
return
select		
v.[sflVC_AssignedDate], 
			v.[sflVC_CaseID], 
			v.[sflVC_CaseClassification_ID], 
			[ref_sflVC_CaseClassification].[name] as [sflVC_CaseClassification], 
			v.[sflVC_CaseType_ID], 
			[ref_sflVC_CaseType].[name] as [sflVC_CaseType], 
			v.[sflVC_FarmAddressCountry_ID], 
			[ref_GIS_sflVC_FarmAddressCountry].[ExtendedName] as [sflVC_FarmAddressCountry], 
			[ref_GIS_sflVC_FarmAddressCountry].[name] as [sflVC_FarmAddressCountry_ShortGISName], 
			v.[sflVC_EnteredDate], 
			v.[sflVC_FarmID], 
			v.[sflVC_FarmName], 
			v.[sflVC_FarmOwner], 
			v.[sflVC_FieldAccessionID], 
			v.[sflVC_FinalDiagnosis_ID], 
			[ref_sflVC_FinalDiagnosis].[name] as [sflVC_FinalDiagnosis], 
			v.[sflVC_FinalDiagnosisDate], 
			v.[sflVC_FinalDiagnosisCode], 
			v.[sflVC_TentativeDiagnosis1_ID], 
			[ref_sflVC_TentativeDiagnosis1].[name] as [sflVC_TentativeDiagnosis1], 
			v.[sflVC_TentativeDiagnosisDate1], 
			v.[sflVC_TentativeDiagnosisCode1], 
			v.[sflVC_TentativeDiagnosis2_ID], 
			[ref_sflVC_TentativeDiagnosis2].[name] as [sflVC_TentativeDiagnosis2], 
			v.[sflVC_TentativeDiagnosisDate2], 
			v.[sflVC_TentativeDiagnosisCode2], 
			v.[sflVC_TentativeDiagnosis3_ID], 
			[ref_sflVC_TentativeDiagnosis3].[name] as [sflVC_TentativeDiagnosis3], 
			v.[sflVC_TentativeDiagnosisDate3], 
			v.[sflVC_TentativeDiagnosisCode3], 
			v.[sflVC_ReportDate], 
			v.[sflVC_InvestigationDate], 
			v.[sflVC_FarmAddressRayon_ID], 
			[ref_GIS_sflVC_FarmAddressRayon].[ExtendedName] as [sflVC_FarmAddressRayon], 
			[ref_GIS_sflVC_FarmAddressRayon].[name] as [sflVC_FarmAddressRayon_ShortGISName], 
			v.[sflVC_FarmAddressRegion_ID], 
			[ref_GIS_sflVC_FarmAddressRegion].[ExtendedName] as [sflVC_FarmAddressRegion], 
			[ref_GIS_sflVC_FarmAddressRegion].[name] as [sflVC_FarmAddressRegion_ShortGISName], 
			v.[sflVC_FarmAddressSettlement_ID], 
			[ref_GIS_sflVC_FarmAddressSettlement].[ExtendedName] as [sflVC_FarmAddressSettlement], 
			[ref_GIS_sflVC_FarmAddressSettlement].[name] as [sflVC_FarmAddressSettlement_ShortGISName], 
			v.[sflVC_CaseProgressStatus_ID], 
			[ref_sflVC_CaseProgressStatus].[name] as [sflVC_CaseProgressStatus], 
			v.[sflVC_FarmLocationCoordinates], 
			v.[sflVC_Diagnosis_ID], 
			[ref_sflVC_Diagnosis].[name] as [sflVC_Diagnosis], 
			v.[sflVC_CaseReportType_ID], 
			[ref_sflVC_CaseReportType].[name] as [sflVC_CaseReportType] 
from		vw_AVR_VetCaseReport_Active v

left join	fnReferenceRepair(@LangID, 19000011) [ref_sflVC_CaseClassification] 
on			[ref_sflVC_CaseClassification].idfsReference = v.[sflVC_CaseClassification_ID] 
left join	fnReferenceRepair(@LangID, 19000012) [ref_sflVC_CaseType] 
on			[ref_sflVC_CaseType].idfsReference = v.[sflVC_CaseType_ID] 
left join	fnGisExtendedReferenceRepair(@LangID, 19000001) [ref_GIS_sflVC_FarmAddressCountry]  
on			[ref_GIS_sflVC_FarmAddressCountry].idfsReference = v.[sflVC_FarmAddressCountry_ID] 
left join	fnReferenceRepair(@LangID, 19000019) [ref_sflVC_FinalDiagnosis] 
on			[ref_sflVC_FinalDiagnosis].idfsReference = v.[sflVC_FinalDiagnosis_ID] 
left join	fnReferenceRepair(@LangID, 19000019) [ref_sflVC_TentativeDiagnosis1] 
on			[ref_sflVC_TentativeDiagnosis1].idfsReference = v.[sflVC_TentativeDiagnosis1_ID] 
left join	fnReferenceRepair(@LangID, 19000019) [ref_sflVC_TentativeDiagnosis2] 
on			[ref_sflVC_TentativeDiagnosis2].idfsReference = v.[sflVC_TentativeDiagnosis2_ID] 
left join	fnReferenceRepair(@LangID, 19000019) [ref_sflVC_TentativeDiagnosis3] 
on			[ref_sflVC_TentativeDiagnosis3].idfsReference = v.[sflVC_TentativeDiagnosis3_ID] 
left join	fnGisExtendedReferenceRepair(@LangID, 19000004) [ref_GIS_sflVC_FarmAddressSettlement]  
on			[ref_GIS_sflVC_FarmAddressSettlement].idfsReference = v.[sflVC_FarmAddressSettlement_ID] 
left join	fnReferenceRepair(@LangID, 19000111) [ref_sflVC_CaseProgressStatus] 
on			[ref_sflVC_CaseProgressStatus].idfsReference = v.[sflVC_CaseProgressStatus_ID] 
left join	fnReferenceRepair(@LangID, 19000144) [ref_sflVC_CaseReportType] 
on			[ref_sflVC_CaseReportType].idfsReference = v.[sflVC_CaseReportType_ID] 


FULL JOIN	(
	gisRayon AS AllRayons
		INNER JOIN	fnGisExtendedReferenceRepair(@LangID, 19000002) AS [ref_GIS_sflVC_FarmAddressRayon]	-- Rayon
			ON	[ref_GIS_sflVC_FarmAddressRayon].idfsReference = AllRayons.idfsRayon
	INNER JOIN	gisRegion AS AllRegions
		INNER JOIN	fnGisExtendedReferenceRepair(@LangID, 19000003) AS [ref_GIS_sflVC_FarmAddressRegion]	-- Region
			ON	[ref_GIS_sflVC_FarmAddressRegion].idfsReference = AllRegions.idfsRegion
		ON	AllRegions.idfsRegion = AllRayons.idfsRegion AND 
			AllRegions.idfsCountry = AllRayons.idfsCountry
	INNER JOIN	(
		tstSite s
		INNER JOIN	tstLocalSiteOptions lso
			ON	lso.strName = N'SiteID' AND 
				lso.strValue = CAST(s.idfsSite AS NVARCHAR(200))
		INNER JOIN	tstCustomizationPackage cp
			ON	cp.idfCustomizationPackage = s.idfCustomizationPackage
				)
		ON	cp.idfsCountry = AllRayons.idfsCountry

	INNER JOIN	(
		fnReferenceRepairWithNoneValue(@LangID, 19000019) AS [ref_sflVC_Diagnosis]
			LEFT JOIN	trtDiagnosis AS AllDiagnoses 
				left join	fnReferenceRepair(@LangID, 19000100) [ref_sflVC_DiagnosisIsZoonotic] 
					on			[ref_sflVC_DiagnosisIsZoonotic].idfsReference = 
								(IsNull(AllDiagnoses.blnZoonotic, 0) * 10100001 + (1 - IsNull(AllDiagnoses.blnZoonotic, 0)) * 10100002) 
				ON	AllDiagnoses.idfsDiagnosis = [ref_sflVC_Diagnosis].idfsReference
				)
		ON	(	(	AllDiagnoses.idfsDiagnosis is not null
				) OR
				(	[ref_sflVC_Diagnosis].idfsReference = -1 AND
					AllDiagnoses.idfsDiagnosis is null
				)
			)
					)
ON	(	AllRayons.idfsRayon = v.[sflVC_FarmAddressRayon_ID]	AND 
		AllRegions.idfsRegion = v.[sflVC_FarmAddressRegion_ID] AND
		[ref_sflVC_Diagnosis].idfsReference = IsNull(v.[sflVC_Diagnosis_ID], -1)
	)


--Not needed--left join	fnReference(@LangID, 19000044) ref_None	-- Information String
--Not needed--on			ref_None.idfsReference = 0		-- Workaround. We dont need (none) anymore

 
where		(

			(
			(v.[sflVC_CaseReportType_ID] = 4578940000001) 
				)	or	(v.[PKField] is null) 
			) 
				and	(	(v.[PKField] is not null)	
						or	(	(v.[PKField] is null)
								and	(
(	AllDiagnoses.idfsUsingType = 10020001	AND						-- Case-based
	AllDiagnoses.intRowStatus = 0	AND
	(	IsNull([ref_sflVC_Diagnosis].intHACode, 96) & 32 > 0	OR	-- Livestock
		IsNull([ref_sflVC_Diagnosis].intHACode, 96) & 64 > 0		-- Avian
	)	AND
	[ref_GIS_sflVC_FarmAddressRegion].intRowStatus = 0	AND
	AllRegions.intRowStatus = 0	AND
	[ref_GIS_sflVC_FarmAddressRayon].intRowStatus = 0	AND
	AllRayons.intRowStatus = 0
)
									)
							)
					)

