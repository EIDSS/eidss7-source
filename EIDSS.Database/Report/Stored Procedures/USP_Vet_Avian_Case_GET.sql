-- ================================================================================================
-- Name: report.USP_Vet_Avian_Case_GET
--
-- Description:	Get data for Avian disease report.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/* Sample Code

EXEC report.USP_Vet_Avian_Case_GET 
	@ObjID = 12,
	@LangID = N'en-US'

*/

CREATE  PROCEDURE [Report].[USP_Vet_Avian_Case_GET]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS
BEGIN

	DECLARE @DiagnosisTable TABLE	
	(		
		strTentativeDiagnosis  NVARCHAR(MAX),
		strTentativeDiagnosis1  NVARCHAR(MAX),
		strTentativeDiagnosis2  NVARCHAR(MAX),
		strFinalDiagnosis  NVARCHAR(MAX),
		datTentativeDiagnosisDate DATETIME,
		datTentativeDiagnosis1Date DATETIME,
		datTentativeDiagnosis2Date DATETIME,
		datFinalDiagnosisDate DATETIME,
		strTentativeDiagnosisCode  NVARCHAR(MAX),
		strTentativeDiagnosis1Code  NVARCHAR(MAX),
		strTentativeDiagnosis2Code  NVARCHAR(MAX),
		strFinalDiagnosisCode   NVARCHAR(MAX)
	)
				
	INSERT INTO @DiagnosisTable exec Report.USP_REP_VET_Diagnosis_GET 
		@ObjID = @ObjID, 
		@LangID = @LangID
							
	DECLARE @AllDiagnoses 	NVARCHAR(MAX)
	SELECT @AllDiagnoses =  (case when (strFinalDiagnosis is null) then '' else strFinalDiagnosis + ', ' end) + 
							(case when (strTentativeDiagnosis2 is null) then '' else strTentativeDiagnosis2 +', ' end) + 
							(case when (strTentativeDiagnosis1 is null) then '' else strTentativeDiagnosis1 + ', ' end) + 
							(case when (strTentativeDiagnosis is null) then '' else strTentativeDiagnosis  end) 
	from @DiagnosisTable

	SELECT  
		vc.strCaseID			AS CaseIdentifier,
		vc.strFieldAccessionID	AS FieldAccessionID,
		vc.datInvestigationDate	AS DateOfInvestigation,
		vc.datEnteredDate		AS DataEntryDate,
		vc.datReportDate		AS ReportedDate,
		vc.datAssignedDate		AS AssignedDate,
		vc.idfSiteID			AS SiteID,
		vc.strEnteredName		AS EnteredName,
		vc.strInvestigationName	AS InvestigationName,
		vc.strReportedName		AS ReportedName,
		vc.strFarmCode			AS FarmCode,
		vc.strNationalName		AS FarmName,
		vc.strFarmerName		AS FarmerName,
		vc.strContactPhone		AS FarmPhone,
		vc.strFax				AS FarmFax,
		vc.strEmail				AS FarmEMail,
		vc.dblLongitude			AS FarmLongitude,
		vc.dblLatitude			AS FarmLatitude,
		vc.idfsCountry			AS FarmCountryId,
		vc.idfsRegion			AS FarmRegionId,
		vc.idfsRayon			AS FarmRayonId,
		vc.idfsSettlement		AS FarmSettlementId,
		vc.strFarmLocation		AS FarmLocation,
		vc.strFarmRegion		AS FarmRegion,
		vc.strFarmRayon			AS FarmRayon,
		vc.strSettlement		AS Settlement,
		rfTypeOfFarmName.[name]	AS TypeOfFarm,
		NULL					AS ProductionType,
		NULL					AS IntendedUse,
		vc.strFarmAddress		AS FarmAddress,
		rfClassification.[name]	AS CaseClassification,
		rfCaseStatus.[name]		AS CaseType,
		rfReportType.[name]		AS ReportType,
		O.strOutbreakID		AS OutbreakID,
		@AllDiagnoses			AS AllDiagnoses,
		F.intBuidings		AS NumberOfBarnsBuildings ,
		F.intBirdsPerBuilding		AS NumberBirdsPerBarnsBuildings,
		dbo.FN_GBL_AddressString_Deny_Rights(@LangID, vc.idfFatmGeoLocation, 1) AS FarmAddressDenyRightsSettlement,
		dbo.FN_GBL_AddressString_Deny_Rights(@LangID, vc.idfFatmGeoLocation, 0) AS FarmAddressDenyRightsDetailed

	FROM Report.FN_REP_Vet_Report_Properties_GET(@LangID) AS vc
	
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000011) AS rfClassification ON rfClassification.idfsReference = vc.idfsCaseClassification
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000144)	AS rfReportType ON rfReportType.idfsReference = vc.idfsCaseReportType
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000111)	AS rfCaseStatus ON rfCaseStatus.idfsReference = vc.idfsCaseProgressStatus
	LEFT JOIN dbo.tlbOutbreak O ON O.idfOutbreak = vc.idfOutbreak AND O.intRowStatus = 0
	LEFT JOIN dbo.tlbFarm F	ON vc.idfFarm = F.idfFarm
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000008) AS rfTypeOfFarmName ON rfTypeOfFarmName.idfsReference = F.idfsAvianFarmType
	
	WHERE  vc.idfCase = @ObjID
	     
END	     
	     

			

