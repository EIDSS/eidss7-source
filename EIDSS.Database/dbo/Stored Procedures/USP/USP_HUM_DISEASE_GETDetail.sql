﻿--*************************************************************
-- Name 				: USP_HUM_DISEASE_GETDetail
-- Description			: List Human Disease Report
--          
-- Author               : Mandar Kulkarni
-- Revision History
-- Name	Date		Change Detail
-- JWJ	20180418	Added cols for hum disease summary section of the hum disease page
-- HAP  20180801    Added columns DiseaseReportTypeID and strMonitoringSessionID to be returned
-- HAP  20181102    Added column LegacyCaseID to be returned 
-- HAP  20181130    Added columns blnClinicalDiagBasis, blnLabDiagBasis, blnEpiDiagBasis, DateofClassification, idfsYNExposureLocationKnown to be returned
-- HAP  20181207    Added column tlbOutBreak.strOutbreakID to be returned
-- HAP  20181213    Removed VaccinationName and VaccinationDate columns to be returned
-- HAP  20190210    Added column idfCSObservation to be returned for Flex Form integration
-- HAP  20190409    Added columns parentHumanDiseaseReportID and relatedHumanDiseaseReportIdList to be returned for use case HUC11 Changed Diagnosis Human Disease Report​ 
-- HAP  20190614    Added columns for Point location values to be returned
-- HAP  20190629    Added column strPointForeignAddress to be returned
-- SLV	20190703	Removed redundant call to FN_GBL_ReferenceRepair
-- Ann Xiong	   09/12/2019 Added script to select PatientStatus, HospitalName, PreviouslySoughtCare, 
--                            YNSpecificVaccinationAdministered, YNSpecimenCollected, YNExposureLocationKnown, 
--                            ExposureLocationType, ExposureLocationDescription, Country, Settlement for Human Disease Report Deduplication.
-- Ann Xiong	   09/13/2019 Modified SP to replace InitialCaseClassification.idfsReferenceType = 19000111 with InitialCaseClassification.idfsReferenceType = 19000011,
-- 							  replace NonNotifiableDiagnosis.idfsReferenceType = 19000019 with NonNotifiableDiagnosis.idfsReferenceType = 19000149
-- Ann Xiong	   09/16/2019 Modified SP to replace SoughtCareFacility.name as strSoughtCareFacility with tlbHumanCase.strSoughtCareFacility
-- 							  replace HospitalizationStatus.idfsReferenceType = 19000100 with HospitalizationStatus.idfsReferenceType = 19000041
-- Stephen Long    10/02/2019 Changed select person calls over to left joins to person.  POCO was not generating with the function call.
-- Ann Xiong	   03/13/2020 Uncommented 10 fields of Human Disease Report Deduplication were commented out
-- LM				06/07/2020 Updated Selecting Connected Disease Reports
-- LM				11/02/2020 Added strNotCollectedReason To Ouput
-- Mark Wilson		12/22/2020 Changed Institution join to E7 SP
-- Mike Kornegay	09/23/2021 Removed duplicate fields from select.
-- Mark Wilson		09/23/2021 Fixed Locations and offices
-- Mark Wilson		10/01/2021 updated join to gisLocation
-- Minal Shah	    10/22/2021 Added strGroundType, dblPointAccuracy and dblPointAlignment
-- Minal Shah		11/03/2021 Added blnInitialSSD and blnFinalSSD columns
-- Minal Shah		01/25/2021 Replaced long name to org abbrev
-- Stephen Long     01/16/2023 Fixes to use translated values on reference types.
-- Mani Govindarajan 03/20/2023 Added idfParentMonitoringSession in output
-- Testing code:
-- 
/* 
EXEC USP_HUM_DISEASE_GETDetail 'en-US', 71413

*/
--*************************************************************
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_GETDetail]
(
    @LangID NVARCHAR(50),
    @SearchHumanCaseId BIGINT = NULL
)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @ReturnMessage VARCHAR(MAX) = 'Success';
        DECLARE @ReturnCode BIGINT = 0;
	DECLARE @idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_Get(@LangID)
	DECLARE @idfsLanguageEn BIGINT = dbo.FN_GBL_LanguageCode_Get('en-US')

        SELECT hc.idfHumanCase,
               hc.idfHuman,
               hc.idfsHospitalizationStatus,
               hc.idfsYNSpecimenCollected,
               hc.idfsHumanAgeType,
               hc.idfsYNAntimicrobialTherapy,
               hc.idfsYNHospitalization,
               hc.idfsYNRelatedToOutbreak,
               hc.idfsOutCome,
               hc.idfsInitialCaseStatus,
               hc.idfsTentativeDiagnosis as idfsFinalDiagnosis,
               tentativeDiagnosisRef.[name] AS strFinalDiagnosis,
               hc.idfsFinalCaseStatus,
               FinalCaseClassification.[name] AS strFinalCaseStatus,
               hc.idfSentByOffice,
               hc.idfInvestigatedByOffice,
               hc.idfReceivedByOffice,
               hc.idfEpiObservation,
               hc.idfCSObservation,
               hc.datNotificationDate,
               hc.datCompletionPaperFormDate,
               hc.datFirstSoughtCareDate,
               hc.datHospitalizationDate,
               hc.datFacilityLastVisit,
               hc.datExposureDate,
               hc.datDischargeDate,
               hc.datOnSetDate,
               hc.datInvestigationStartDate AS StartDateofInvestigation,
               hc.datFinalDiagnosisDate AS datDateOfDiagnosis,
               hc.datFinalDiagnosisDate,
               hc.strNote,
               hc.strCurrentLocation,
               hc.strHospitalizationPlace,
               hc.strLocalIdentifier,
               SoughtByOfficeRef.[name] AS strSoughtCareFacility,
               hc.strSentByFirstName,
               hc.strSentByPatronymicName,
               hc.strSentByLastName,
               hc.strReceivedByFirstName,
               hc.strReceivedByPatronymicName,
               hc.strReceivedByLastName,
               hc.strEpidemiologistsName,
               hc.strClinicalDiagnosis,
               hc.strClinicalNotes,
               hc.strSummaryNotes,
               hc.intPatientAge,
               hc.blnClinicalDiagBasis,
               hc.blnLabDiagBasis,
               hc.blnEpiDiagBasis,
               hc.idfPersonEnteredBy,
               hc.idfPointGeoLocation,
               gl.idfsGroundType AS idfsPointGroundType,
               gl.idfsGeoLocationType AS idfsPointGeoLocationType,
               gl.idfsCountry AS idfsPointCountry,
               gl.idfsRegion AS idfsPointRegion,
               gl.idfsRayon AS idfsPointRayon,
               gl.idfsSettlement AS idfsPointSettlement,
               gl.dblDistance AS dblPointDistance,
               gl.dblLatitude AS dblPointLatitude,
               gl.dblLongitude AS dblPointLongitude,
               gl.dblElevation AS dblPointElevation,
               gl.dblAlignment AS dblPointAlignment,
               gl.dblAccuracy AS dblPointAccuracy,
               gl.strForeignAddress AS strPointForeignAddress,
               hc.idfSentByPerson,
               hc.idfReceivedByPerson,
               hc.idfInvestigatedByPerson,
               hc.idfsYNTestsConducted,
               hc.idfSoughtCareFacility,
               hc.idfsNonNotifiableDiagnosis,
               NonNotifiableDiagnosisRef.[name] AS stridfsNonNotifiableDiagnosis,
               hc.idfOutbreak,
               hc.strCaseId,
               hc.idfsCaseProgressStatus,
               hc.idfsSite,
               hc.strSampleNotes,
               hc.uidOfflineCaseID,
               hc.datFinalCaseClassificationDate,
               hc.idfHospital,
               hc.idfsYNSpecificVaccinationAdministered,
               hc.idfsNotCollectedReason,
               hc.strNotCollectedReason,
               hc.idfsYNPreviouslySoughtCare,
               hc.idfsYNExposureLocationKnown,
               hc.datEnteredDate,
               hc.datModificationDate,
               hc.idfsFinalDiagnosis AS idfsDiagnosis, --possible duplicate
               hc.idfsFinalState,
               hc.DiseaseReportTypeID,
               ReportTypeRef.[name] AS 'ReportType',
               hc.LegacyCaseID,
               hc.datFinalCaseClassificationDate AS DateofClassification,
               o.strOutbreakID,
               o.strDescription,
               h.strPersonId,
               h.datDateOfDeath,
               ISNULL(ld.Level2Name, ld_en.Level2Name) AS Region,
               ISNULL(ld.Level3Name, ld_en.Level3Name) AS Rayon,
               HumanAgeRef.[name] AS HumanAgeType,
               OutcomeRef.[name] AS Outcome,
               NonNotifiableDiagnosisRef.[name] AS NonNotifiableDiagnosis,
               NotCollectedReasonRef.[name] AS NotCollectedReason,
               CaseProgressStatusRef.[name] AS CaseProgressStatus,
               SpecificVaccinationAdministered.[name] AS YNSpecificVaccinationAdministered,
               PreviouslySoughtCareRef.[name] AS PreviouslySoughtCare,
               ExposureLocationKnown.[name] AS YNExposureLocationKnown,
               HospitalizationStatusRef.[name] AS HospitalizationStatus,
               Hospitalization.[name] AS YNHospitalization,
               AntimicrobialTherapy.[name] AS YNAntimicrobialTherapy,
               SpecimenCollection.[name] AS YNSpecimenCollected,
               RelatedToOutBreak.[name] AS YNRelatedToOutBreak,
               tentativeDiagnosisRef.[name] AS TentativeDiagnosis,
               FinalDiagnosis.[name] AS SummaryIdfsFinalDiagnosis,
               InitialCaseClassification.[name] AS InitialCaseStatus,
               FinalCaseClassification.[name] AS FinalCaseStatus,
               SentByOfficeRef.LongName AS SentByOffice,
               ReceivedByOfficeRef.LongName AS ReceivedByOffice,
               HospitalRef.LongName AS HospitalName,
               InvestigateByOfficeRef.LongName AS InvestigatedByOffice,
               TestConducted.[name] AS YNTestConducted,
               MonitoringSession.strMonitoringSessionID,
               ExposureLocationTypeRef.[name] AS ExposureLocationType,
               groundTypeRef.[name] AS strGroundType,
               gl.strDescription AS ExposureLocationDescription,
               ISNULL(FinalCaseClassification.[name], InitialCaseClassification.[name]) AS SummaryCaseClassification,
               dbo.fnConcatFullName(
                                       sentByPersonRef.strFamilyName,
                                       sentByPersonRef.strFirstName,
                                       sentByPersonRef.strSecondName
                                   ) AS SentByPerson,
               dbo.fnConcatFullName(
                                       receivedByPersonRef.strFamilyName,
                                       receivedByPersonRef.strFirstName,
                                       receivedByPersonRef.strSecondName
                                   ) AS ReceivedByPerson,
               dbo.fnConcatFullName(
                                       investigatedByPersonRef.strFamilyName,
                                       investigatedByPersonRef.strFirstName,
                                       investigatedByPersonRef.strSecondName
                                   ) AS InvestigatedByPerson,
               dbo.fnConcatFullName(
                                       personEnteredByRef.strFamilyName,
                                       personEnteredByRef.strFirstName,
                                       personEnteredByRef.strSecondName
                                   ) AS EnteredByPerson,
               tlbEnteredByOffice.[name] AS strOfficeEnteredBy,
               tlbEnteredByOffice.idfOffice AS idfOfficeEnteredBy,
               SentByOfficeRef.[name] AS strNotificationSentby,
               '' AS strNotificationReceivedby,
               PatientState.[name] AS PatientStatus,
               ISNULL(ld.Level1Name, ld_en.Level1Name) AS Country,
               ISNULL(ld.Level4Name, ld_en.Level4Name) AS Settlement,
               dbo.fnConcatFullName(ha.strLastName, ha.strFirstName, ha.strSecondName) AS PatientFarmOwnerName,
               addinfo.EIDSSPersonID AS EIDSSPersonID,
               ha.idfHumanActual AS HumanActualId,
               initialSyndromicSurveielanceDiseases.blnSyndrome AS blnInitialSSD,
               finalSyndromicSurveielanceDiseases.blnSyndrome AS blnFinalSSD,
               hc.idfParentMonitoringSession,
               hc.idfsTentativeDiagnosis as DiseaseId,
               tentativeDiagnosisRef.[name] as DiseaseName,
               hc.datTentativeDiagnosisDate as DateOfDiagnosis,
               hc.idfsFinalDiagnosis as ChangedDiseaseId,
               FinalDiagnosis.[name] as ChangedDiseaseName,
               hc.datFinalDiagnosisDate as DateOfChangedDiagnosis,
               CAST(NULL as bigint) as ChangeDiagnosisReasonId

        FROM dbo.tlbHumanCase hc WITH (NOLOCK)
            LEFT JOIN dbo.tlbOutbreak AS o
                ON o.idfOutbreak = hc.idfOutbreak
            LEFT JOIN dbo.tlbHuman AS h
                ON h.idfHuman = hc.idfHuman
            LEFT JOIN dbo.tlbHumanActual AS ha
                ON ha.idfHumanActual = h.idfHumanActual
                   AND h.intRowStatus = 0
            LEFT JOIN dbo.HumanActualAddlInfo AS addinfo
                ON addinfo.HumanActualAddlInfoUID = h.idfHumanActual
                   AND addinfo.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation AS gl
                ON gl.idfGeoLocation = hc.idfPointGeoLocation
                   AND gl.intRowStatus = 0

            LEFT JOIN dbo.gisLocationDenormalized ld
                ON ld.idfsLocation = gl.idfsLocation AND ld.idfsLanguage = @idfsLanguage
            LEFT JOIN dbo.gisLocationDenormalized ld_en
                ON ld_en.idfsLocation = gl.idfsLocation AND ld.idfsLanguage = @idfsLanguageEn
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000036) AS ExposureLocationTypeRef
                ON ExposureLocationTypeRef.idfsReference = gl.idfsGeoLocationType
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000038) AS groundTypeRef
                ON groundTypeRef.idfsReference = gl.idfsGroundType

            LEFT JOIN dbo.trtDiagnosis AS initialSyndromicSurveielanceDiseases
                ON initialSyndromicSurveielanceDiseases.idfsDiagnosis = hc.idfsTentativeDiagnosis
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS tentativeDiagnosisRef
                ON tentativeDiagnosisRef.idfsReference = hc.idfsTentativeDiagnosis

            LEFT JOIN dbo.trtDiagnosis AS finalSyndromicSurveielanceDiseases
                ON finalSyndromicSurveielanceDiseases.idfsDiagnosis = hc.idfsFinalDiagnosis
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS FinalDiagnosis
                ON FinalDiagnosis.idfsReference = hc.idfsFinalDiagnosis

            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000042) AS HumanAgeRef
                ON HumanAgeRef.idfsReference = hc.idfsHumanAgeType
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000064) AS OutcomeRef
                ON OutcomeRef.idfsReference = hc.idfsOutcome
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011) AS InitialCaseClassification
                ON InitialCaseClassification.idfsReference = hc.idfsInitialCaseStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011) AS FinalCaseClassification
                ON FinalCaseClassification.idfsReference = hc.idfsFinalCaseStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000149) AS NonNotifiableDiagnosisRef
                ON NonNotifiableDiagnosisRef.idfsReference = hc.idfsNonNotifiableDiagnosis
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000144) AS ReportTypeRef
                ON ReportTypeRef.idfsReference = hc.DiseaseReportTypeID
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) AS NotCollectedReasonRef
                ON NotCollectedReasonRef.idfsReference = hc.idfsNotCollectedReason
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000111) CaseProgressStatusRef
                ON CaseProgressStatusRef.idfsReference = hc.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS SpecificVaccinationAdministered
                ON SpecificVaccinationAdministered.idfsReference = hc.idfsYNSpecificVaccinationAdministered
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS PreviouslySoughtCareRef
                ON PreviouslySoughtCareRef.idfsReference = hc.idfsYNPreviouslySoughtCare
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS ExposureLocationKnown
                ON ExposureLocationKnown.idfsReference = hc.idfsYNExposureLocationKnown
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000041) AS HospitalizationStatusRef
                ON HospitalizationStatusRef.idfsReference = hc.idfsHospitalizationStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS Hospitalization
                ON Hospitalization.idfsReference = hc.idfsYNHospitalization
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS AntimicrobialTherapy
                ON AntimicrobialTherapy.idfsReference = hc.idfsYNAntimicrobialTherapy
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS SpecimenCollection
                ON SpecimenCollection.idfsReference = hc.idfsYNSpecimenCollected
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS RelatedToOutBreak
                ON RelatedToOutBreak.idfsReference = hc.idfsYNRelatedToOutbreak
            LEFT JOIN dbo.tlbOffice RBO
                ON RBO.idfOffice = hc.idfReceivedByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) ReceivedByOfficeRef
                ON ReceivedByOfficeRef.idfsReference = RBO.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbOffice IBO
                ON IBO.idfOffice = hc.idfInvestigatedByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) InvestigateByOfficeRef
                ON InvestigateByOfficeRef.idfsReference = IBO.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbOffice SBO
                ON SBO.idfOffice = hc.idfSentByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) SentByOfficeRef
                ON SentByOfficeRef.idfsReference = SBO.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbOffice SoughtByOffice
                ON SoughtByOffice.idfOffice = hc.idfSoughtCareFacility
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) SoughtByOfficeRef
                ON SoughtByOfficeRef.idfsReference = SoughtByOffice.idfsOfficeAbbreviation
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000100) AS TestConducted
                ON TestConducted.idfsReference = hc.idfsYNTestsConducted
            LEFT JOIN dbo.tstSite S
                ON S.idfsSite = hc.idfsSite
            LEFT JOIN dbo.FN_HUM_Institution_GET(@LangID) AS tlbEnteredByOffice
                ON tlbEnteredByOffice.idfOffice = S.idfOffice
                   AND tlbEnteredByOffice.idfsSite = hc.idfsSite

            LEFT JOIN dbo.tlbPerson AS sentByPersonRef
                ON sentByPersonRef.idfPerson = hc.idfSentByPerson
                   AND sentByPersonRef.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson AS receivedByPersonRef
                ON receivedByPersonRef.idfPerson = hc.idfReceivedByPerson
                   AND receivedByPersonRef.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson AS investigatedByPersonRef
                ON investigatedByPersonRef.idfPerson = hc.idfInvestigatedByPerson
                   AND investigatedByPersonRef.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson AS personEnteredByRef
                ON personEnteredByRef.idfPerson = hc.idfPersonEnteredBy
                   AND personEnteredByRef.intRowStatus = 0

            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000035) AS PatientState
                ON PatientState.idfsReference = hc.idfsFinalState
            LEFT JOIN dbo.tlbOffice Hospital
                ON Hospital.idfOffice = hc.idfHospital
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) HospitalRef
                ON HospitalRef.idfsReference = Hospital.idfsOfficeAbbreviation


            LEFT JOIN dbo.tlbMonitoringSession AS MonitoringSession
                ON MonitoringSession.idfMonitoringSession = hc.idfParentMonitoringSession

        WHERE hc.idfHumanCase = @SearchHumanCaseId
              OR @SearchHumanCaseId IS NULL;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        THROW;
    END CATCH
END
