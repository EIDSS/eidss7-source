



--=====================================================================================================
-- Created by:				Mark Wilson
-- Description:				Collect Human case properties from different tables;
/*
----testing code:
select * from report.FN_REP_HumanCaseProperties_GET('en-US')
*/
--=====================================================================================================

CREATE FUNCTION [Report].[FN_REP_HumanCaseProperties_GET]
(
	@LangID AS NVARCHAR(50) = NULL
)
RETURNS	 TABLE
AS
RETURN
	SELECT 
		HC.idfHumanCase					AS idfCase,
		ISNULL(HC.idfsFinalCaseStatus, HC.idfsInitialCaseStatus)					AS idfsCaseStatus,
		HC.idfsCaseProgressStatus		AS idfsCaseProgressStatus,
		10012003								AS idfsCaseType,
		HC.idfOutbreak					AS idfOutbreak,
		HC.datEnteredDate				AS datEnteredDate,
		H.idfsOccupationType				AS idfsOccupationType,
		H.idfCurrentResidenceAddress		AS idfCurrentResidenceAddress,
		H.idfEmployerAddress				AS idfEmployerAddress,
		H.idfRegistrationAddress			AS idfRegistrationAddress,
		H.idfsNationality					AS idfsNationality,
		HC.idfsInitialCaseStatus		AS idfsInitialCaseStatus,
		HC.idfsHospitalizationStatus	AS idfsHospitalizationStatus,
		HC.idfsYNAntimicrobialTherapy	AS idfsYNAntimicrobialTherapy,
		HC.idfsYNHospitalization		AS idfsYNHospitalization,
		HC.idfsYNSpecimenCollected		AS idfsYNSpecimenCollected,
		HC.idfsYNRelatedToOutbreak		AS idfsYNRelatedToOutbreak,
		HC.idfsOutcome					AS idfsOutcome,
		HC.idfSentByOffice				AS idfSentByOffice,
		HC.idfReceivedByOffice			AS idfReceivedByOffice,
		HC.idfInvestigatedByOffice		AS idfInvestigatedByOffice,
		HC.idfSoughtCareFacility		AS idfSoughtCareFacility,
		HC.datNotificationDate			AS datNotificationDate,
		HC.datCompletionPaperFormDate	AS datCompletionPaperFormDate,
		HC.datFirstSoughtCareDate		AS datFirstSoughtCareDate,
		HC.datModificationDate			AS datModificationDate,
		HC.datHospitalizationDate		AS datHospitalizationDate,
		HC.datFacilityLastVisit			AS datFacilityLastVisit,
		HC.datExposureDate				AS datExposureDate,
		HC.datDischargeDate				AS datDischargeDate,
		HC.datOnSetDate					AS datOnSetDate,
		HC.datInvestigationStartDate	AS datInvestigationStartDate,
		HC.datTentativeDiagnosisDate	AS datTentativeDiagnosisDate,
		HC.datFinalDiagnosisDate		AS datFinalDiagnosisDate,
		fnGeoLocation.name						AS strGeoLocation,			
		H.datDateofBirth					AS datDateofBirth,
		H.datDateOfDeath					AS datDateOfDeath,
		HA.strPersonID					AS strPersonID,
		rfPersonIDType.[name]					AS strPersonIDType,
		HC.strCaseID					AS strCaseID,
		HC.strLocalIdentifier			AS strLocalIdentifier,
		rfGender.[name]							AS strPatientGender,
		rfDiagnosis.[name]						AS strTentetiveDiagnosis,
		rfChangedDiagnosis.[name]				AS strFinalDiagnosis,
		rfNonNotifiableDiagnosis.[name]			AS strClinicalDiagnosis,
		HC.strHospitalizationPlace		AS strHospitalizationPlace,
		HC.strCurrentLocation			AS strCurrentLocation,
		H.strEmployerName					AS strEmployerName,
		H.strRegistrationPhone				AS strRegistrationPhone,
		H.strHomePhone						AS strHomePhone,
		H.strWorkPhone						AS strWorkPhone,
		dbo.fnConcatFullName(H.strLastName, H.strFirstName, H.strSecondName) AS strPatientFullName,
		dbo.fnConcatFullName(receivedPerson.strFamilyName, receivedPerson.strFirstName, receivedPerson.strSecondName) AS strReceivedByFullName,
		dbo.fnConcatFullName(sentPerson.strFamilyName, sentPerson.strFirstName, sentPerson.strSecondName) AS strSentByFullName,
		rfFinalState.[name]						AS strFinalState,
		rfSoughtCareFacility.idfsOfficeAbbreviation		AS strSoughtCareFacility,
		rfNotCollectedReason.[name]				AS strNotCollectedReason, 
		HC.strNote						AS strNote,
		HC.strSummaryNotes				AS strSummaryNotes,
		HC.strClinicalNotes				AS strClinicalNotes,
		dbo.fnConcatFullName(invPerson.strFamilyName, invPerson.strFirstName, invPerson.strSecondName) AS strEpidemiologistsName,
		rfAgeType.[name]						AS strPatientAgeType,
		HC.intPatientAge				AS intPatientAge,
		HC.blnClinicalDiagBasis			AS blnClinicalDiagBasis,
		HC.blnLabDiagBasis				AS blnLabDiagBasis,
		HC.blnEpiDiagBasis				AS blnEpiDiagBasis,
		HC.idfHospital					AS idfHospital,
		HC.datFinalCaseClassificationDate AS datFinalCaseClassificationDate,
		HC.strSampleNotes				AS strSampleNotes
	
	-- get case
	FROM dbo.tlbHumanCase AS HC
			 
	-- Get patient
	 LEFT JOIN	dbo.tlbHuman AS H
			ON	HC.idfHuman = H.idfHuman AND
			    H.intRowStatus = 0
	-- Get patient person id type
	 LEFT JOIN	dbo.tlbHumanActual AS HA ON	HA.idfHumanActual = H.idfHumanActual 
     LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000148) rfPersonIDType ON rfPersonIDType.idfsReference = HA.idfsPersonIDType
			
	-- Get Age Type 
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000042 /* rftHumanAgeType*/) rfAgeType ON HC.idfsHumanAgeType	= rfAgeType.idfsReference
	-- Get Gender
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000043 /* rftHumanGender*/) rfGender ON H.idfsHumanGender	= rfGender.idfsReference
	-- Get Diagnosis
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019/*'rftDiagnosis' */) AS rfDiagnosis ON rfDiagnosis.idfsReference=HC.idfsTentativeDiagnosis
	-- Get Final Diagnosis
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019/*'rftDiagnosis' */) AS rfChangedDiagnosis ON rfChangedDiagnosis.idfsReference=HC.idfsFinalDiagnosis
	-- Get Final State
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000035/*'rftFinalState' */) AS rfFinalState ON rfFinalState.idfsReference=HC.idfsFinalState
	 LEFT JOIN	dbo.fnInstitution(@LangID) AS rfSoughtCareFacility ON rfSoughtCareFacility.idfOffice=HC.idfSoughtCareFacility
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000150/*'rftNotCollectedReason' */) AS rfNotCollectedReason ON  rfNotCollectedReason.idfsReference=HC.idfsNotCollectedReason
	 LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000149/*'rftNonNotifiableDiagnosis' */) AS rfNonNotifiableDiagnosis ON  rfNonNotifiableDiagnosis.idfsReference=HC.idfsNonNotifiableDiagnosis
	  
	-- Get Received by person
	 LEFT JOIN	dbo.tlbPerson AS receivedPerson ON receivedPerson.idfPerson=HC.idfReceivedByPerson
	-- Get Received by person
	 LEFT JOIN	dbo.tlbPerson AS sentPerson ON sentPerson.idfPerson=HC.idfSentByPerson
	-- Get Investigated by person
	 LEFT JOIN	dbo.tlbPerson AS invPerson ON invPerson.idfPerson=HC.idfInvestigatedByPerson
						
			
	 LEFT JOIN dbo.FN_GBL_GeoLocationTranslation(@LangID) fnGeoLocation ON	fnGeoLocation.idfGeoLocation = HC.idfPointGeoLocation

	WHERE HC.intRowStatus = 0
