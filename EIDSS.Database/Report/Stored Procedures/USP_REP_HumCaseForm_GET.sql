--*************************************************************************
-- Name 				: report.USP_REP_HumCaseForm_GET
-- DescriptiON			: Select data for Human Case Investigation report.
--          
-- Author               : Mark Wilson
-- Revision History
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Mark Wilson	       03-23-2022 Initial E7 version
-- Srini Goli          10/20/2022 Updated SentByOffice
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*

--Example of a call of procedure:

exec report.USP_REP_HumCaseForm_GET @LangID=N'en-US',@ObjID=121490

*/
CREATE PROCEDURE [Report].[USP_REP_HumCaseForm_GET]
(
    @LangID AS NVARCHAR(10),
    @ObjID AS BIGINT = NULL
)
AS
SELECT HC.idfCase AS idfCase,
       HC.strLocalIdentifier AS LocalID,
       SentByOfficeRef.LongName AS OrgSentNotification,
       InvestigatedByOfficeRef.LongName AS OrgConductInv,
       LRegistration.AdminLevel2Name AS RegRegion,
       LRegistration.AdminLevel3Name AS RegRayon,
       LRegistration.AdminLevel4Name AS RegVillage,
       tRegistratedLocation.strStreetName AS RegStreet,
       tRegistratedLocation.strPostCode AS RegPostalCode,
       tRegistratedLocation.strBuilding AS RegBuld,
       tRegistratedLocation.strHouse AS RegHouse,
       tRegistratedLocation.strApartment AS RegApp,
       HC.strRegistrationPhone AS RegPhone,
       CASE
           WHEN tRegistratedLocation.blnForeignAddress = 1 THEN
               tRegistratedLocation.strAddressString
           ELSE
               ''
       END AS RegForeignAddress,
       tRegistratedLocation.dblLongitude AS RegLongitude,
       tRegistratedLocation.dblLatitude AS RegLatitude,
                                                             ---- Employer Address---
       LEmployer.AdminLevel1Name AS EmpCountry,
       LEmployer.AdminLevel2Name AS EmpRegion,
       LEmployer.AdminLevel3Name AS EmpRayon,
       LEmployer.AdminLevel4Name AS EmpVillage,
       tEmployerLocation.strStreetName AS EmpStreet,
       HC.strWorkPhone AS EmpPhone,
       tEmployerLocation.strPostCode AS EmpPostalCode,
       tEmployerLocation.strBuilding AS EmpBuild,
       tEmployerLocation.strHouse AS EmpHouse,
       tEmployerLocation.strApartment AS EmpApp,
       rfInitialCaseStatus.[name] AS InitCaseStatus,
       HC.datNotificationDate AS DateFromHealthCareProvider, -- dbo.Activity.datReportDate
       HC.strCaseID AS CaseIdentifier,
       HC.datInvestigationStartDate AS StartingDateOfInvestigation,
       HC.datCompletionPaperFormDate AS CompletionPaperFormDate,
       HC.strPatientFullName AS NameOfPatient,
       HC.datDateofBirth AS DOB,
       HC.strPersonID AS strPersonID,
       HC.strPersonIDType AS strPersonIDType,
       HC.strPatientAgeType AS AgeType,
       HC.intPatientAge AS Age,
       HC.strPatientGender AS Sex,
       rfNationality.[name] AS Citizenship,
       LCurrent.AdminLevel2Name AS Region,
       LCurrent.AdminLevel3Name AS Rayon,
       LCurrent.AdminLevel4Name AS City,
       tCurrentLocation.strStreetName AS Street,
       tCurrentLocation.strPostCode AS strPost_Code,
       HC.strHomePhone AS PhoneNumber,
       rfOccupationType.[name] AS Occupation,
       tCurrentLocation.strBuilding AS BuildingNum,
       tCurrentLocation.strHouse AS HouseNum,
       tCurrentLocation.strApartment AS AptNum,
       tCurrentLocation.dblLongitude AS Longitude,
       tCurrentLocation.dblLatitude AS Latitude,
       rfHospitalizationStatus.[name] AS strCurrentLocationStatus,
       HC.strEmployerName AS NameOfEmployer,
       HC.datFacilityLastVisit AS datFacilityLastVisit,
       HC.datExposureDate AS DateOfExposure,
       HC.datOnSetDate AS DateofSymptomsOnset,
       HC.datFirstSoughtCareDate AS DateOfFirstSoughtCare,
       SoughtCareFacility.EnglishFullName AS FacilityOfPatientSoughtCare,
       CurrentLocationOffice.AbbreviatedName AS CurrentLocationOfficeName,
       HC.datHospitalizationDate AS HospitalizationDate,
       HC.datDischargeDate AS DateOfDischarged,
       HC.strHospitalizationPlace AS PlaceOfHospitalization,
       rfHospitalisationYN.[name] AS Hospitalization,
       HC.strClinicalNotes AS ClinicalComments,
       (
           SELECT strDefault
           FROM trtbasereference
           WHERE idfsBaseReference = hc.idfsCaseStatus
       ) AS FinalCaseClassification,
       HC.datFinalCaseClassificationDate AS FinalCaseClassificationDate,
       rfCaseStatus.[name] AS CaseProgerssStatus,
       ISNULL(HC.strFinalDiagnosis, HC.strTentetiveDiagnosis) AS FinalDiagnosis,
       ISNULL(HC.datFinalDiagnosisDate, HC.datTentativeDiagnosisDate) AS FinalDiagDate,
       HC.strTentetiveDiagnosis AS InitialDiagnosis,
       HC.datTentativeDiagnosisDate AS InitialDiagDate,
       HC.strClinicalDiagnosis AS ClinicalDiagnosis,
       rfSpecimenCollectedYN.[name] AS SpeciemenCollected,
       HC.strNotCollectedReason AS ReasonForNotCollectingSpeciemens,
       tHumanCase.strSampleNotes AS strSampleNotes,
       rfTherapyYN.[name] AS Antibiotics,
       ISNULL(tHumanCase.blnClinicalDiagBasis, 0) AS blnClinicalDiagBasis,
       ISNULL(tHumanCase.blnLabDiagBasis, 0) AS blnLabDiagBasis,
       ISNULL(tHumanCase.blnEpiDiagBasis, 0) AS blnEpiDiagBasis,
       rfOutcome.[name] AS Outcome,
       HC.datDateOfDeath AS DateOfDeath,
       rfRelatedToOutbreakYN.[name] AS RelatedToOutbreak,
       tOutbreak.strOutbreakID AS OutbreakID,
       HC.strSummaryNotes AS SummaryComments,
       HC.strEpidemiologistsName AS EpiName,
       HC.strGeoLocation AS strGeoLocation,
       HC.strFinalState AS strFinalState,
       HC.strNote AS strClinicalInformationComments
FROM report.FN_REP_HumanCaseProperties_GET(@LangID) AS HC
    -- Get Current ADDRESS 
    LEFT JOIN dbo.tlbGeoLocation tCurrentLocation
        ON HC.idfCurrentResidenceAddress = tCurrentLocation.idfGeoLocation
    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LCurrent
        ON LCurrent.idfsLocation = tCurrentLocation.idfsLocation
    -- Get registration location 
    LEFT JOIN dbo.tlbGeoLocation tRegistratedLocation
        ON HC.idfRegistrationAddress = tRegistratedLocation.idfGeoLocation
    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LRegistration
        ON LRegistration.idfsLocation = tRegistratedLocation.idfsLocation
    -- Get Employer ADDRESS 
    LEFT JOIN dbo.tlbGeoLocation tEmployerLocation
        ON HC.idfEmployerAddress = tEmployerLocation.idfGeoLocation
    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LEmployer
        ON LEmployer.idfsLocation = tEmployerLocation.idfsLocation
    -- Get sent by office name
    LEFT JOIN dbo.tlbOffice SBO
        ON SBO.idfOffice = hc.idfSentByOffice
    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) SentByOfficeRef
        ON SentByOfficeRef.idfsReference = SBO.idfsOfficeAbbreviation
    -- Get investigated by office name
    LEFT JOIN dbo.tlbOffice IBO
        ON IBO.idfOffice = hc.idfInvestigatedByOffice
    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) InvestigatedByOfficeRef
        ON InvestigatedByOfficeRef.idfsReference = IBO.idfsOfficeAbbreviation
    -- Get investigated by office name
    LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS SoughtCareFacility
        ON SoughtCareFacility.idfOffice = HC.idfSoughtCareFacility
    -- Get investigated by office name
    LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS CurrentLocationOffice
        ON CurrentLocationOffice.idfOffice = HC.idfHospital
    -- Get Case status
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000111) AS rfCaseStatus
        ON rfCaseStatus.idfsReference = HC.idfsCaseProgressStatus
    -- Get Case classification
    --LEFT JOIN  dbo.FN_GBL_Reference_GETList(@LangID, 19000111) AS rfInitialCaseStatus ON rfInitialCaseStatus.idfsReference = HC.idfsInitialCaseStatus
    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011) AS rfInitialCaseStatus
        ON rfInitialCaseStatus.idfsReference = hc.idfsInitialCaseStatus
    -- Get Nationality
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000054) AS rfNationality
        ON rfNationality.idfsReference = HC.idfsNationality
    -- Get HospitalizationStatus
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000041) AS rfHospitalizationStatus
        ON rfHospitalizationStatus.idfsReference = HC.idfsHospitalizationStatus
    -- Get OcupationType
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000061) AS rfOccupationType
        ON rfOccupationType.idfsReference = HC.idfsOccupationType
    -- Get is Hospitalisation
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfHospitalisationYN
        ON rfHospitalisationYN.idfsReference = HC.idfsYNHospitalization
    -- Get is SpecimenCollected
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfSpecimenCollectedYN
        ON rfSpecimenCollectedYN.idfsReference = HC.idfsYNSpecimenCollected
    -- Get is AntimicrobialTherapy
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfTherapyYN
        ON rfTherapyYN.idfsReference = HC.idfsYNAntimicrobialTherapy
    -- Get is RelatedToOutbreak
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000100) AS rfRelatedToOutbreakYN
        ON rfRelatedToOutbreakYN.idfsReference = HC.idfsYNRelatedToOutbreak
    -- Get is Outcome
    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000064) AS rfOutcome
        ON rfOutcome.idfsReference = HC.idfsOutcome
    -- Get Outbreak
    LEFT JOIN dbo.tlbOutbreak AS tOutbreak
        ON tOutbreak.idfOutbreak = HC.idfOutbreak
    LEFT JOIN dbo.tlbHumanCase AS tHumanCase
        ON tHumanCase.idfHumanCase = @ObjID
WHERE @ObjID = HC.idfCase
      OR @ObjID IS NULL;
GO