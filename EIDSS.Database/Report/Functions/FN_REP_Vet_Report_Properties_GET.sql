-------------------------------------------------------------------------------------------------
-- Name 				: report.FN_REP_Vet_Report_Properties_GET
-- DescriptiON			: Select data for Vet Report.
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*

select * FROM dbo.FN_REP_Vet_Report_Properties_GET(@LangID=N'en-US')

*/ 


CREATE FUNCTION [Report].[FN_REP_Vet_Report_Properties_GET]
(
	@LangID AS NVARCHAR(50) = 'en-US'
)
RETURNS	 TABLE
AS
RETURN
	SELECT  
		VC.idfVetCase AS idfCase,					
		VC.strCaseID,
		
		VC.strFieldAccessionID,	
		VC.datInvestigationDate,	
		VC.datEnteredDate,			
		VC.datReportDate,			
		VC.datAssignedDate,		
		dbo.FN_GBL_SITEID_GET() AS idfSiteID,
		dbo.FN_GBL_ConcatFullName(tPersonEntered.strFamilyName, 
								tPersonEntered.strFirstName, 
								tPersonEntered.strSecondName)		AS strEnteredName,
		dbo.FN_GBL_ConcatFullName(	tPersonInvestigated.strFamilyName, 
								tPersonInvestigated.strFirstName, 
								tPersonInvestigated.strSecondName)	AS strInvestigationName,
		dbo.FN_GBL_ConcatFullName(	tPersonReported.strFamilyName, 
								tPersonReported.strFirstName, 
								tPersonReported.strSecondName)		AS strReportedName,
		F.idfFarm,					
		F.strFarmCode,	
		F.strNote,			
		F.strNationalName,			
		dbo.FN_GBL_ConcatFullName(	H.strLastName, 
								H.strFirstName, 
								H.strSecondName)			AS strFarmerName,
		F.strContactPhone,			
		F.strFax,					
		F.strEmail,		
		tFarmAddress.dblLongitude,
		tFarmAddress.dblLatitude,
		dbo.FN_GBL_AddressString(@LangID, tFarmAddress.idfGeoLocation) AS strFarmLocation,
		rfFarmRegion.[name]				AS strFarmRegion,
		rfFarmRayon.[name]				AS strFarmRayon,
		rfFarmSettlement.[name]			AS strSettlement,
		dbo.FN_GBL_AddressString(@LangID, tFarmAddress.idfGeoLocation) AS strFarmAddress,
		tFarmAddress.idfGeoLocation		AS idfFatmGeoLocation,
		tFarmAddress.idfsCountry		AS idfsCountry,
		tFarmAddress.idfsRegion			AS idfsRegion,
		tFarmAddress.idfsRayon			AS idfsRayon,
		tFarmAddress.idfsSettlement		AS idfsSettlement,
		VC.idfOutbreak,
		VC.idfsCaseClassification,
		VC.idfsCaseType,
		VC.idfsCaseProgressStatus,
		VC.idfsCaseReportType,
		VC.idfParentMonitoringSession

	FROM dbo.tlbVetCase	AS VC

	-- Get Farm
	 LEFT JOIN	
	 (
		 dbo.tlbFarm AS F
		-- Get Farm Owner
		LEFT JOIN dbo.tlbHuman AS H	ON H.idfHuman = F.idfHuman AND H.intRowStatus = 0
						   
		-- Get Farm Address
		 LEFT JOIN	
				( dbo.tlbGeoLocation	AS tFarmAddress
					INNER JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000003) AS  rfFarmRegion ON rfFarmRegion.idfsReference = tFarmAddress.idfsRegion
					INNER JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002) AS rfFarmRayon ON rfFarmRayon.idfsReference = tFarmAddress.idfsRayon
					 LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000004) AS rfFarmSettlement ON	rfFarmSettlement.idfsReference = tFarmAddress.idfsSettlement
				)
				ON	tFarmAddress.idfGeoLocation = F.idfFarmAddress
			   AND  tFarmAddress.intRowStatus = 0
		)
		ON	VC.idfFarm = F.idfFarm 
		AND F.intRowStatus = 0


			
	-- Get Person Entered By
	 LEFT JOIN	(
								dbo.tlbPerson	AS tPersonEntered
					INNER JOIN	dbo.tlbEmployee AS tEmployeeEntered
							ON	tEmployeeEntered.idfEmployee = tPersonEntered.idfPerson
						   AND  tEmployeeEntered.intRowStatus = 0
				)
			ON	tPersonEntered.idfPerson = VC.idfPersonEnteredBy
		   
	-- Get Person Reported By
	 LEFT JOIN	(
								dbo.tlbPerson AS tPersonReported
					INNER JOIN	dbo.tlbEmployee AS tEmployeeReported
							ON	tEmployeeReported.idfEmployee = tPersonReported.idfPerson
						   AND  tEmployeeReported.intRowStatus = 0
				)
			ON	tPersonReported.idfPerson = VC.idfPersonReportedBy
	-- Get Person Investigated By
	 LEFT JOIN	(
								dbo.tlbPerson AS tPersonInvestigated
					INNER JOIN	dbo.tlbEmployee AS tEmployeeInvestigated
							ON	tEmployeeInvestigated.idfEmployee = tPersonInvestigated.idfPerson
						   AND  tEmployeeInvestigated.intRowStatus = 0
				)
			ON	tPersonInvestigated.idfPerson = VC.idfPersonInvestigatedBy

	WHERE VC.intRowStatus = 0
