



--*************************************************************
-- Name 				: FN_REP_VetCase_Get
-- Description			: Returns List of Vet case details for 
--                        use with reports  
--						
-- Author               : Mark Wilson
-- Revision History
--
--		Name       Date       Change Detail
--	Mark Wilson  July-2019   Updated to get diagnosis from FN_ReferenceRepair_GET
--                           instead of tlbVetCaseDisplayDiagnosis
--  Srini Goli   Feb-18-2019 Updated to get the DisplayName for selected language.
--
-- Testing code:
--
-- SELECT * FROM report.FN_REP_VetCase_Get('ka',null)
--
--*************************************************************
  
/*  
--Example of a call of procedure:  
SELECT * FROM report.FN_REP_VetCase_Get ('ka', NULL) where idfsCaseProgressStatus = 10109002
  
*/  
  
  
CREATE FUNCTION [Report].[FN_REP_VetCase_Get]
(  
	@LangID AS NVARCHAR(50),   
	@UserID NVARCHAR(100) = NULL
)  
RETURNS TABLE  

AS  
 
RETURN   
SELECT
	VC.idfVetCase AS idfCase,   
    VC.datAssignedDate,   
    VC.datEnteredDate ,    
    VC.strCaseID,   
    VC.datReportDate,   
    VC.datInvestigationDate,  
    VC.idfsShowDiagnosis,  
	COALESCE(VC.datFinalDiagnosisDate, VC.datTentativeDiagnosis2Date, VC.datTentativeDiagnosis1Date, VC.datTentativeDiagnosisDate) AS datDiagnosisDate,
	COALESCE(VC.datReportDate, VC.datInvestigationDate, VC.datFinalDiagnosisDate, VC.datEnteredDate) AS DateOfRecord,
    VC.idfsFinalDiagnosis, 
    VC.idfPersonEnteredBy,  
    VC.idfsCaseClassification,    
    VC.idfsCaseProgressStatus,  
    ISNULL(VC.idfsCaseReportType,4578940000002) AS idfsCaseReportType, --passive as default  
    CaseReportType.name AS strCaseReportType,  
    DiagnosisRef.name AS FinalDiagnosisName,   
    ISNULL(Diagnosis.[name],   VC.strDefaultDisplayDiagnosis) AS DiagnosisName, 
    CaseStatus.name AS CaseStatusName,   
    CaseClassification.name AS CaseClassificationName,   
    CaseType.name AS strCaseType,  
    VC.idfsCaseType,  
    NULLIF(VC.idfsCaseType,0) AS idfsCaseTypeNullable,
	VC.uidOfflineCaseID,
    F.idfFarmAddress AS idfAddress,  
    ISNULL(ref_Settlement.name + ', ', '') + ISNULL(ref_Rayon.name + ', ', '')+ref_Region.name AS AddressName,
    tlbGeoLocation.idfsCountry,  
    tlbGeoLocation.idfsRegion,  
    tlbGeoLocation.idfsRayon,  
    tlbGeoLocation.idfsSettlement,  
    F.idfFarm,  
    ISNULL(F.strNationalName, F.strInternationalName) AS FarmName,   
    F.idfsAvianFarmType,  
    F.idfsAvianProductionType,  
    F.idfsFarmCategory,  
    F.idfsOwnershipStructure,  
    F.idfsMovementPattern,  
    F.idfsIntendedUse,  
    F.idfsGrazingPattern,  
    F.idfsLivestockProductionType,  
    F.strInternationalName,  
    F.strNationalName,  
    F.strFarmCode,  
    F.strFax,  
    F.strEmail,  
    F.strContactPhone,  
    farmOwner.strFirstName AS strOwnerFirstName,  
    farmOwner.strSecondName AS strOwnerMiddleName,  
    farmOwner.strLastName AS strOwnerLastName,  
    CASE WHEN VC.idfsCaseType= 10012004/*avian*/ THEN F.intAvianSickAnimalQty ELSE F.intLivestockSickAnimalQty END AS intSickAnimalQty ,  
    CASE WHEN VC.idfsCaseType= 10012004/*avian*/ THEN F.intAvianTotalAnimalQty ELSE F.intLivestockTotalAnimalQty END AS intTotalAnimalQty ,  
    CASE WHEN VC.idfsCaseType= 10012004/*avian*/ THEN F.intAvianDeadAnimalQty ELSE F.intLivestockDeadAnimalQty END AS intDeadAnimalQty,
	VC.idfsSite           
   
FROM 
(  
	dbo.tlbVetCase VC
	LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID,19000011) AS CaseClassification ON VC.idfsCaseClassification = CaseClassification.idfsReference  --'rftCaseClassification'
	LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID,19000111) AS CaseStatus ON VC.idfsCaseProgressStatus = CaseStatus.idfsReference  --'rftCaseProgressStatus'
	LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID,19000012) AS CaseType ON VC.idfsCaseType = CaseType.idfsReference   --'rftCaseType'
	LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS DiagnosisRef ON VC.idfsFinalDiagnosis = DiagnosisRef.idfsReference --'rftDiagnosis'
) 
  
INNER JOIN dbo.tlbFarm AS F ON F.idfFarm = VC.idfFarm AND F.intRowStatus = 0  
LEFT JOIN dbo.tlbHuman farmOwner ON farmOwner.idfHuman = F.idfHuman
LEFT JOIN dbo.tlbGeoLocation ON tlbGeoLocation.idfGeoLocation = F.idfFarmAddress  
LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS ref_Region ON ref_Region.idfsReference = tlbGeoLocation.idfsRegion
LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS ref_Rayon ON ref_Rayon.idfsReference = tlbGeoLocation.idfsRayon
LEFT JOIN report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS ref_Settlement ON ref_Settlement.idfsReference = tlbGeoLocation.idfsSettlement
LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID,19000144) AS CaseReportType ON ISNULL(VC.idfsCaseReportType,4578940000002) = CaseReportType.idfsReference  
LEFT JOIN report.FN_GBL_ReferenceRepair_GET(@LangID,19000019) Diagnosis ON Diagnosis.idfsReference = COALESCE(VC.idfsFinalDiagnosis, VC.idfsTentativeDiagnosis2,VC.idfsTentativeDiagnosis1,VC.idfsTentativeDiagnosis)
LEFT JOIN dbo.tstUserTable ut ON ut.idfUserID = @UserID
LEFT JOIN dbo.tstSite s ON s.idfsSite = report.FN_GBL_SiteID_GET()

WHERE VC.intRowStatus = 0  


