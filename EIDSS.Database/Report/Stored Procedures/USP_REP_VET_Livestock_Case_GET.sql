
-------------------------------------------------------------------------------------------------
-- Name 				: report.USP_REP_VET_Livestock_Case_GET
-- DescriptiON			: Select data for LiveStock Test report.
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*

exec report.USP_REP_VET_Livestock_Case_GET @LangID=N'en',@ObjID=1

*/

CREATE PROCEDURE [Report].[USP_REP_VET_Livestock_Case_GET]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS

	declare @DiagnosisTable as Table	(		
				strTentativeDiagnosis  nvarchar(max)
				,strTentativeDiagnosis1  nvarchar(max)
				,strTentativeDiagnosis2  nvarchar(max)
				,strFinalDiagnosis  nvarchar(max)
				,datTentativeDiagnosisDate datetime
				,datTentativeDiagnosis1Date datetime
				,datTentativeDiagnosis2Date datetime
				,datFinalDiagnosisDate datetime
				,strTentativeDiagnosisCode  nvarchar(max)
				,strTentativeDiagnosis1Code  nvarchar(max)
				,strTentativeDiagnosis2Code  nvarchar(max)
				,strFinalDiagnosisCode   nvarchar(max)
				)
				
	INSERT INTO @DiagnosisTable exec report.USP_REP_VET_Diagnosis_GET @ObjID, @LangID
							
	declare @AllDiagnoses 	nvarchar(max)
	select @AllDiagnoses =  (case when (strFinalDiagnosis is null) then '' else strFinalDiagnosis + ', ' end) + 
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
		vc.strFarmAddress		AS FarmAddress,
		rfClassification.[name]	AS CaseClassification,
		rfCaseStatus.[name]		AS CaseType,
		rfReportType.[name]		AS ReportType,
		O.strOutbreakID	AS OutbreakID,
		sess.strMonitoringSessionID AS SessionID ,
		
		@AllDiagnoses			AS AllDiagnoses,
		dbo.FN_GBL_AddressString_Deny_Rights(@LangID, vc.idfFatmGeoLocation,1) AS FarmAddressDenyRightsSettlement,
		dbo.FN_GBL_AddressString_Deny_Rights(@LangID, vc.idfFatmGeoLocation,0) AS FarmAddressDenyRightsDetailed,
		
		vc.strNote				AS Comments,
		
		NULL						AS ProductionStructure,
		rfOwnershipTypeName.[name]	AS OwnershipType,
		NULL						AS GrazingPattern,
		NULL						AS movementPattern

	FROM report.FN_REP_Vet_Report_Properties_GET(@LangID) AS vc
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000011) AS rfClassification ON rfClassification.idfsReference = vc.idfsCaseClassification
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000144) AS rfReportType ON rfReportType.idfsReference = vc.idfsCaseReportType
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000111) AS rfCaseStatus ON rfCaseStatus.idfsReference = vc.idfsCaseProgressStatus
	LEFT JOIN dbo.tlbOutbreak O ON O.idfOutbreak = vc.idfOutbreak AND O.intRowStatus = 0
	LEFT JOIN dbo.tlbMonitoringSession sess ON sess.idfMonitoringSession = vc.idfParentMonitoringSession AND sess.intRowStatus = 0
	LEFT JOIN dbo.tlbFarm AS F ON VC.idfFarm = F.idfFarm
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000065) AS rfOwnershipTypeName ON rfOwnershipTypeName.idfsReference = F.idfsOwnershipStructure

	WHERE  vc.idfCase = @ObjID

			

