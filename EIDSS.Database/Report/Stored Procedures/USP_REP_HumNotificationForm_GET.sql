-- ================================================================================================
-- Name: USP_REP_Lim_Sample_GET
--
-- Description:	Select data for Container details report.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- Srini Goli		10/20/2022	Changed Facility Names to Match Application 
-- ---------------- ---------- -------------------------------------------------------------------
-- 

/*
--Example of a call of procedure:

exec report.[USP_REP_HumNotificationForm_GET] 'en-US', 90723

exec report.[USP_REP_HumNotificationForm_GET] 'en-US', 90724

*/


Create  Procedure [Report].[USP_REP_HumNotificationForm_GET]
	(
		@LangID as nvarchar(10),
		@ObjID	as bigint
	)
AS	
	select 
		idfCase,
		rfHumanCase.strLocalIdentifier				as FieldCaseID,
		rfHumanCase.datCompletionPaperFormDate		as DateOfCompletionForm,
		rfHumanCase.strCaseID						as CaseIdentifier,
		rfHumanCase.strTentetiveDiagnosis			as Diagnosis,
		rfHumanCase.datTentativeDiagnosisDate		as DateOfDiagnosis,
		rfHumanCase.strPatientFullName				as NameOfPatient,
		rfHumanCase.datDateofBirth					as DOB,
		rfHumanCase.strPersonID						as strPersonID,
		rfHumanCase.strPersonIDType					as strPersonIDType,
		rfHumanCase.strPatientAgeType				as AgeType,
		rfHumanCase.intPatientAge					as Age,
		rfHumanCase.strPatientGender				as Sex,
		rfCurrentRegion.[name]						as Region,
		rfCurrentRayon.[name]						as Rayon,	
		rfCurrentSettlement.[name]					as City,
		tCurrentLocation.strPostCode				as PostalCode,
		tCurrentLocation.strStreetName				as Street,
		rfHumanCase.strHomePhone					as PhoneNumber,
		rfHumanCase.strEmployerName					as NameOfEmployer,
		rfHumanCase.datFacilityLastVisit			as DateofLastVisitToEmployer,
		tCurrentLocation.strBuilding				as BuildingNum,
		tCurrentLocation.strHouse					as HouseNum,
		tCurrentLocation.strApartment				as AptNum,
		rfNationality.[name]						as Nationality,
		dbo.FN_GBL_AddressString(@LangID, rfHumanCase.idfEmployerAddress) AS AddressOfEmployerOrChildrenFacility ,
			---- Employer Address---
		rfEmployerRegion.[name]						as EmpRegion,
		rfEmployerRayon.[name]						as EmpRayon,
		rfEmployerSettlement.[name]					as EmpVillage,
		tEmployerLocation.strStreetName				as EmpStreet,
		rfHumanCase.strWorkPhone					as EmpPhone,
		tEmployerLocation.strPostCode				as EmpPostalCode,
		tEmployerLocation.strBuilding				as EmpBuild,
		tEmployerLocation.strHouse					as EmpHouse,
		tEmployerLocation.strApartment				as EmpApp,
	
		rfHumanCase.datOnSetDate					as DateofSymptomsOnset,
		rfHumanCase.strFinalState					as SatusOfThePatient,
		rfHumanCase.strFinalDiagnosis				as ChangedDiagnosis,
		rfHumanCase.datFinalDiagnosisDate			as DateOfChangedDiagnosis,
		rfHumanCase.idfsHospitalizationStatus		as HomeHospitalOther,
		--CASE WHEN rfHumanCase.idfsHospitalizationStatus = 5360000000 THEN HospitalRef.LongName --Hospital
		--	 WHEN rfHumanCase.idfsHospitalizationStatus = 5360000000 THEN rfHumanCase.strCurrentLocation --Other
		--	 ELSE N'' END							as HospitalName,
		HospitalRef.LongName						as HospitalName,
		rfHumanCase.strNote							as Comments,
		rfHumanCase.datNotificationDate				as NotificationDate,
		rfHumanCase.datNotificationDate				as NotificationTime,
		rfHumanCase.strSentByFullName				as SentByName,
		--rfSendByOffice.[name]						as SentbyFacility,
		rfHumanCase.strReceivedByFullName			as ReceivedbyName,
		--rfReceivedByOffice.[name]					as ReceivedFacility
		SentByOfficeRef.LongName					as SentbyFacility,
		ReceivedByOfficeRef.LongName				as ReceivedFacility
	from		dbo.FN_REP_HumanCaseProperties_GET(@LangID) as rfHumanCase
	-- Get HOME ADDRESS 
	 left join	dbo.tlbGeoLocation tCurrentLocation
			on	rfHumanCase.idfCurrentResidenceAddress = tCurrentLocation.idfGeoLocation
 	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*'rftCountry'*/) rfCurrentCountry 
			on	rfCurrentCountry.idfsReference = tCurrentLocation.idfsCountry
	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*'rftRegion'*/)  rfCurrentRegion 
			on	rfCurrentRegion.idfsReference = tCurrentLocation.idfsRegion
	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*'rftRayon'*/)   rfCurrentRayon 
			on	rfCurrentRayon.idfsReference = tCurrentLocation.idfsRayon
	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004 /*'rftSettlement'*/) rfCurrentSettlement
			on	rfCurrentSettlement.idfsReference = tCurrentLocation.idfsSettlement
	 left join	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000054 /*'rftNationality'*/) as rfNationality
			on	rfNationality.idfsReference=rfHumanCase.idfsNationality
	 left join	dbo.tlbGeoLocation tEmployerLocation
			on	rfHumanCase.idfEmployerAddress = tEmployerLocation.idfGeoLocation
 	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*'rftCountry'*/) rfEmployerCountry 
			on	rfEmployerCountry.idfsReference = tEmployerLocation.idfsCountry
	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*'rftRegion'*/)  rfEmployerRegion 
			on	rfEmployerRegion.idfsReference = tEmployerLocation.idfsRegion
	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*'rftRayon'*/)   rfEmployerRayon 
			on	rfEmployerRayon.idfsReference = tEmployerLocation.idfsRayon
	 left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004 /*'rftSettlement'*/) rfEmployerSettlement
			on	rfEmployerSettlement.idfsReference = tEmployerLocation.idfsSettlement
	-- Get office name
	left join dbo.tlbOffice SBO ON SBO.idfOffice = rfHumanCase.idfSentByOffice
		left join dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) SentByOfficeRef ON SentByOfficeRef.idfsReference = SBO.idfsOfficeAbbreviation
	left join dbo.tlbOffice RBO ON RBO.idfOffice = rfHumanCase.idfReceivedByOffice
		left join dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) ReceivedByOfficeRef ON ReceivedByOfficeRef.idfsReference = RBO.idfsOfficeAbbreviation
	left join dbo.tlbOffice Hospital on Hospital.idfOffice = rfHumanCase.idfHospital
		left join dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) HospitalRef ON HospitalRef.idfsReference = Hospital.idfsOfficeAbbreviation
	-- Filter condition
	where	@ObjID = idfCase


GO


