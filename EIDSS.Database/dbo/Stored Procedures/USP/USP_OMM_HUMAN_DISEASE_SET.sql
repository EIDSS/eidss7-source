-- ================================================================================================
-- Name: USP_OMM_HUMAN_DISEASE_SET
--
-- Description:	Insert OR UPDATE human disease record
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese	02/2019    Created a shell of the Human Disease Report for Outbreak use only
-- Doug Albanese	05/21/2020 Removed the Case Monitoring SP call and moved it up to the parent 
--                             SP (USP_OMM_Case_Set)
-- Doug Albanese	10/12/2020 Corrected Audit information
-- Doug Albanese	04/19/2022 Refreshed this SP from the one used for "Human Disease Report". 
--                             This is a temporarly solution, until it is rewritten to use 
--                             Location Hierarchy
-- Doug Albanese	04/26/2022 Removed all supression, since the "INSERTS" of this SP are 3 levels 
--                             deep and only used by USP_OMM_Case_Set
-- Doug Albanese	05/06/2022 Added indicator for Tests conducted
-- Doug Albanese	03/10/2023 Added Data Auditing
-- Doug Albanese	04/28/2023 Removed suppression on USSP_GBL_DATA_AUDIT_EVENT_SET
-- Stephen Long     05/17/2023 Fix for item 5584.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_HUMAN_DISEASE_SET]
(
    @idfHumanCase BIGINT = -1 OUTPUT,                     -- tlbHumanCase.idfHumanCase Primary Key`
    @idfHuman BIGINT = NULL,                              -- tlbHumanCase.idfHuman
    @strHumanCaseId NVARCHAR(200) = '(new)',
    @OutbreakCaseReportUID BIGINT = NULL,
    @idfHumanActual BIGINT,                               -- tlbHumanActual.idfHumanActual
    @idfsFinalDiagnosis BIGINT,                           -- tlbhumancase.idfsTentativeDiagnosis/idfsFinalDiagnosis
    @datDateOfDiagnosis DATETIME = NULL,                  --tlbHumanCase.datTentativeDiagnosisDate/datFinalDiagnosisDate
    @datNotificationDate DATETIME = NULL,                 --tlbHumanCase.DatNotIFicationDate
    @idfsFinalState BIGINT = NULL,                        --tlbHumanCase.idfsFinalState

    @idfSentByOffice BIGINT = NULL,                       -- tlbHumanCase.idfSentByOffice
    @strSentByFirstName NVARCHAR(200) = NULL,             --tlbHumanCase.strSentByFirstName
    @strSentByPatronymicName NVARCHAR(200) = NULL,        --tlbHumancase.strSentByPatronymicName
    @strSentByLastName NVARCHAR(200) = NULL,              --tlbHumanCase.strSentByLastName
    @idfSentByPerson BIGINT = NULL,                       --tlbHumcanCase.idfSentByPerson

    @idfReceivedByOffice BIGINT = NULL,                   -- tlbHumanCase.idfReceivedByOffice
    @strReceivedByFirstName NVARCHAR(200) = NULL,         --tlbHumanCase.strReceivedByFirstName
    @strReceivedByPatronymicName NVARCHAR(200) = NULL,    --tlbHumanCase.strReceivedByPatronymicName
    @strReceivedByLastName NVARCHAR(200) = NULL,          --tlbHuanCase.strReceivedByLastName
    @idfReceivedByPerson BIGINT = NULL,                   -- tlbHumanCase.idfReceivedByPerson

    @idfsHospitalizationStatus BIGINT = NULL,             -- tlbHumanCase.idfsHospitalizationStatus
    @idfHospital BIGINT = NULL,                           -- tlbHumanCase.idfHospital
    @strCurrentLocation NVARCHAR(200) = NULL,             -- tlbHumanCase.strCurrentLocation
    @datOnSetDate DATETIME = NULL,                        -- tlbHumanCase.datOnSetDate
    @idfsInitialCaseStatus BIGINT = NULL,                 -- tlbHumanCase.idfsInitialCaseStatus
    @idfsYNPreviouslySoughtCare BIGINT = NULL,            --idfsYNPreviouslySoughtCare
    @datFirstSoughtCareDate DATETIME = NULL,              --tlbHumanCase.datFirstSoughtCareDate
    @idfSoughtCareFacility BIGINT = NULL,                 --tlbHumanCase.idfSoughtCareFacility
    @idfsNonNotIFiableDiagnosis BIGINT = NULL,            --tlbHumanCase.idfsNonNotIFiableDiagnosis
    @idfsYNHospitalization BIGINT = NULL,                 -- tlbHumanCase.idfsYNHospitalization
    @datHospitalizationDate DATETIME = NULL,              --tlbHumanCase.datHospitalizationDate 
    @datDischargeDate DATETIME = NULL,                    -- tlbHumanCase.datDischargeDate
    @strHospitalName NVARCHAR(200) = NULL,                --tlbHumanCase.strHospitalizationPlace  
    @idfsYNAntimicrobialTherapy BIGINT = NULL,            --  tlbHumanCase.idfsYNAntimicrobialTherapy 
    @strAntibioticName NVARCHAR(200) = NULL,              -- tlbHumanCase.strAntimicrobialTherapyName
    @strDosage NVARCHAR(200) = NULL,                      --tlbHumanCase.strDosage
    @datFirstAdministeredDate DATETIME = NULL,            -- tlbHumanCase.datFirstAdministeredDate
    @strClinicalNotes NVARCHAR(500) = NULL,               -- tlbHumanCase.strClinicalNotes , or strSummaryNotes
    @strNote NVARCHAR(500) = NULL,                        -- tlbHumanCase.strNote
    @idfsYNSpecIFicVaccinationAdministered BIGINT = NULL, --  tlbHumanCase.idfsYNSpecIFicVaccinationAdministered
    @idfInvestigatedByOffice BIGINT = NULL,               -- tlbHumanCase.idfInvestigatedByOffice 
    @idfInvestigatedByPerson BIGINT = NULL,
    @StartDateofInvestigation DATETIME = NULL,            -- tlbHumanCase.datInvestigationStartDate
    @idfsYNRelatedToOutbreak BIGINT = NULL,               -- tlbHumanCase.idfsYNRelatedToOutbreak
    @idfOutbreak BIGINT = NULL,                           --idfOutbreak  
    @idfsYNExposureLocationKnown BIGINT = NULL,           --tlbHumanCase.idfsYNExposureLocationKnown
    @idfPointGeoLocation BIGINT = NULL,                   --tlbHumanCase.idfPointGeoLocation
    @datExposureDate DATETIME = NULL,                     -- tlbHumanCase.datExposureDate 
    @strLocationDescription NVARCHAR(MAX) = NULL,         --tlbGeolocation.Description

    @CaseGeoLocationID BIGINT = NULL,
    @CaseidfsLocation BIGINT = NULL,
    @CasestrStreetName NVARCHAR(200) = NULL,
    @CasestrApartment NVARCHAR(200) = NULL,
    @CasestrBuilding NVARCHAR(200) = NULL,
    @CasestrHouse NVARCHAR(200) = NULL,
    @CaseidfsPostalCode NVARCHAR(200) = NULL,
    @CasestrLatitude FLOAT = NULL,
    @CasestrLongitude FLOAT = NULL,
    @CasestrElevation FLOAT = NULL,
    @idfsLocationGroundType BIGINT = NULL,                --tlbGeolocation.GroundType
    @intLocationDistance FLOAT = NULL,                    --tlbGeolocation.Distance
    @idfsFinalCaseStatus BIGINT = NULL,                   --tlbHuanCase.idfsFinalCaseStatus 
    @idfsOutcome BIGINT = NULL,                           -- --tlbHumanCase.idfsOutcome 
    @datDateofDeath DATETIME = NULL,                      -- tlbHumanCase.datDateOfDeath 
    @idfsCaseProgressStatus BIGINT = 10109001,            --	tlbHumanCase.reportStatus, default = In-process
    @idfPersonEnteredBy BIGINT = NULL,
    @idfsYNSpecimenCollected BIGINT = NULL,
    @DiseaseReportTypeID BIGINT = NULL,
    @blnClinicalDiagBasis BIT = NULL,
    @blnLabDiagBasis BIT = NULL,
    @blnEpiDiagBasis BIT = NULL,
    @DateofClassification DATETIME = NULL,
    @strSummaryNotes NVARCHAR(MAX) = NULL,
    @idfEpiObservation BIGINT = NULL,
    @idfCSObservation BIGINT = NULL,
    @SamplesParameters NVARCHAR(MAX) = NULL,
    @TestsParameters NVARCHAR(MAX) = NULL,
    @idfsYNTestsConducted BIGINT = NULL,
    @AntiviralTherapiesParameters NVARCHAR(MAX) = NULL,
    @VaccinationsParameters NVARCHAR(MAX) = NULL,
    @CaseMonitoringsParameters NVARCHAR(MAX) = NULL,
    @ContactsParameters NVARCHAR(MAX) = NULL,
    @strStreetName NVARCHAR(200) = NULL,
    @strHouse NVARCHAR(200) = NULL,
    @strBuilding NVARCHAR(200) = NULL,
    @strApartment NVARCHAR(200) = NULL,
    @strPostalCode NVARCHAR(200) = NULL,
    @User NVARCHAR(100) = NULL
)
AS
DECLARE @returnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        -- Data audit Declarations (Start)
        DECLARE @AuditUserID BIGINT = NULL;
        DECLARE @AuditSiteID BIGINT = NULL;
        DECLARE @DataAuditEventID BIGINT = NULL;
        DECLARE @DataAuditEventTypeID BIGINT = NULL;
        DECLARE @ObjectTypeID BIGINT = 10017080;
        DECLARE @ObjectID BIGINT = @idfOutbreak;
        DECLARE @ObjectTableID BIGINT = 75610000000;
        -- Data audit Declarations (End)

        -- Data audit UserInfo (Start)
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@User) userInfo;
        -- Data audit UserInfo (End)

        --Data Audit Before Edit Table (Start)
        DECLARE @HumanCaseBeforeEdit TABLE
        (
            blnClinicalDiagBasis BIT,
            blnEpiDiagBasis BIT,
            blnLabDiagBasis BIT,
            datCompletionPaperFormDate DATETIME,
            datDischargeDate DATETIME,
            datExposureDate DATETIME,
            datFacilityLastVisit DATETIME,
            datFinalDiagnosisDate DATETIME,
            datHospitalizationDate DATETIME,
            datInvestigationStartDate DATETIME,
            datModificationDate DATETIME,
            datTentativeDiagnosisDate DATETIME,
            idfHumanCase BIGINT,
            idfInvestigatedByOffice BIGINT,
            idfPointGeoLocation BIGINT,
            idfReceivedByOffice BIGINT,
            idfsFinalDiagnosis BIGINT,
            idfsFinalState BIGINT,
            idfsHospitalizationStatus BIGINT,
            idfsHumanAgeType BIGINT,
            idfsInitialCaseStatus BIGINT,
            idfsOutcome BIGINT,
            idfsTentativeDiagnosis BIGINT,
            idfsYNAntimicrobialTherapy BIGINT,
            idfsYNHospitalization BIGINT,
            idfsYNRelatedToOutbreak BIGINT,
            idfsYNSpecimenCollected BIGINT,
            intPatientAge INT,
            strClinicalDiagnosis NVARCHAR(2000),
            strCurrentLocation NVARCHAR(2000),
            strEpidemiologistsName NVARCHAR(2000),
            strHospitalizationPlace NVARCHAR(2000),
            strLocalIdentifier NVARCHAR(2000),
            strNotCollectedReason NVARCHAR(2000),
            strNote NVARCHAR(2000),
            strReceivedByFirstName NVARCHAR(2000),
            strReceivedByLastName NVARCHAR(2000),
            strReceivedByPatronymicName NVARCHAR(2000),
            strSentByFirstName NVARCHAR(2000),
            strSentByLastName NVARCHAR(2000),
            strSentByPatronymicName NVARCHAR(2000),
            strSoughtCareFacility NVARCHAR(2000),
            idfsFinalCaseStatus BIGINT,
            idfSentByOffice BIGINT,
            idfEpiObservation BIGINT,
            idfCSObservation BIGINT,
            idfDeduplicationResultCase BIGINT,
            datNotificationDate DATETIME,
            datFirstSoughtCareDate DATETIME,
            datOnSetDate DATETIME,
            strClinicalNotes NVARCHAR(2000),
            strSummaryNotes NVARCHAR(2000),
            idfHuman BIGINT,
            idfPersonEnteredBy BIGINT,
            idfSentByPerson BIGINT,
            idfReceivedByPerson BIGINT,
            idfInvestigatedByPerson BIGINT,
            idfsYNTestsConducted BIGINT,
            idfSoughtCareFacility BIGINT,
            idfsNonNotifiableDiagnosis BIGINT,
            idfsNotCollectedReason BIGINT,
            idfOutbreak BIGINT,
            datEnteredDate DATETIME,
            strCaseID NVARCHAR(200),
            idfsCaseProgressStatus BIGINT,
            strSampleNotes NVARCHAR(2000),
            uidOfflineCaseID UNIQUEIDENTIFIER,
            datFinalCaseClassificationDate DATETIME,
            idfHospital BIGINT
        );
        --Data Audit Before Edit Table (End)

        --Data Audit After Edit Table (Start)
        DECLARE @HumanCaseAfterEdit TABLE
        (
            blnClinicalDiagBasis BIT,
            blnEpiDiagBasis BIT,
            blnLabDiagBasis BIT,
            datCompletionPaperFormDate DATETIME,
            datDischargeDate DATETIME,
            datExposureDate DATETIME,
            datFacilityLastVisit DATETIME,
            datFinalDiagnosisDate DATETIME,
            datHospitalizationDate DATETIME,
            datInvestigationStartDate DATETIME,
            datModificationDate DATETIME,
            datTentativeDiagnosisDate DATETIME,
            idfHumanCase BIGINT,
            idfInvestigatedByOffice BIGINT,
            idfPointGeoLocation BIGINT,
            idfReceivedByOffice BIGINT,
            idfsFinalDiagnosis BIGINT,
            idfsFinalState BIGINT,
            idfsHospitalizationStatus BIGINT,
            idfsHumanAgeType BIGINT,
            idfsInitialCaseStatus BIGINT,
            idfsOutcome BIGINT,
            idfsTentativeDiagnosis BIGINT,
            idfsYNAntimicrobialTherapy BIGINT,
            idfsYNHospitalization BIGINT,
            idfsYNRelatedToOutbreak BIGINT,
            idfsYNSpecimenCollected BIGINT,
            intPatientAge INT,
            strClinicalDiagnosis NVARCHAR(2000),
            strCurrentLocation NVARCHAR(2000),
            strEpidemiologistsName NVARCHAR(2000),
            strHospitalizationPlace NVARCHAR(2000),
            strLocalIdentifier NVARCHAR(2000),
            strNotCollectedReason NVARCHAR(2000),
            strNote NVARCHAR(2000),
            strReceivedByFirstName NVARCHAR(2000),
            strReceivedByLastName NVARCHAR(2000),
            strReceivedByPatronymicName NVARCHAR(2000),
            strSentByFirstName NVARCHAR(2000),
            strSentByLastName NVARCHAR(2000),
            strSentByPatronymicName NVARCHAR(2000),
            strSoughtCareFacility NVARCHAR(2000),
            idfsFinalCaseStatus BIGINT,
            idfSentByOffice BIGINT,
            idfEpiObservation BIGINT,
            idfCSObservation BIGINT,
            idfDeduplicationResultCase BIGINT,
            datNotificationDate DATETIME,
            datFirstSoughtCareDate DATETIME,
            datOnSetDate DATETIME,
            strClinicalNotes NVARCHAR(2000),
            strSummaryNotes NVARCHAR(2000),
            idfHuman BIGINT,
            idfPersonEnteredBy BIGINT,
            idfSentByPerson BIGINT,
            idfReceivedByPerson BIGINT,
            idfInvestigatedByPerson BIGINT,
            idfsYNTestsConducted BIGINT,
            idfSoughtCareFacility BIGINT,
            idfsNonNotifiableDiagnosis BIGINT,
            idfsNotCollectedReason BIGINT,
            idfOutbreak BIGINT,
            datEnteredDate DATETIME,
            strCaseID NVARCHAR(200),
            idfsCaseProgressStatus BIGINT,
            strSampleNotes NVARCHAR(2000),
            uidOfflineCaseID UNIQUEIDENTIFIER,
            datFinalCaseClassificationDate DATETIME,
            idfHospital BIGINT
        );
        --Data Audit After Edit Table (End)

        DECLARE @SupressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage VARCHAR(200)
        );
        DECLARE @SupressSelectHumanCase TABLE
        (
            ReturnCode INT,
            ReturnMessage VARCHAR(200),
            idfHumanCase BIGINT
        );
        DECLARE @COPYHUMANACTUALTOHUMAN_ReturnCode INT = 0;

        EXECUTE dbo.USP_OMM_COPYHUMANACTUALTOHUMAN @idfHumanActual,
                                                   @idfHuman OUTPUT;

        EXECUTE dbo.USSP_GBL_ADDRESS_SET @GeolocationID = @CaseGeoLocationID OUTPUT,
                                         @ResidentTypeID = NULL,
                                         @GroundTypeID = NULL,
                                         @GeolocationTypeID = NULL,
                                         @LocationID = @CaseidfsLocation,
                                         @Apartment = @CasestrApartment,
                                         @Building = @CasestrBuilding,
                                         @StreetName = @CasestrStreetName,
                                         @House = @CasestrHouse,
                                         @PostalCodeString = @CaseidfsPostalCode,
                                         @DescriptionString = NULL,
                                         @Distance = NULL,
                                         @Latitude = @CasestrLatitude,
                                         @Longitude = @CasestrLongitude,
                                         @Elevation = @CasestrElevation,
                                         @Accuracy = NULL,
                                         @Alignment = NULL,
                                         @ForeignAddressIndicator = null,
                                         @ForeignAddressString = null,
                                         @GeolocationSharedIndicator = 0,
                                         @AuditUserName = @User,
                                         @ReturnCode = @ReturnCode OUTPUT,
                                         @ReturnMessage = @ReturnMessage OUTPUT;

        IF NOT EXISTS
        (
            SELECT idfHumanCase
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase
        )
        BEGIN
            -- Get next key value
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbHumanCase', @idfHumanCase OUTPUT;

            -- Data audit (Create)
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @idfHumanCase,
                                                      @ObjectTableID,
                                                      @strHumanCaseID,
                                                      @DataAuditEventID OUTPUT;

            -- Data audit (Create)
            INSERT INTO dbo.tlbHumanCase
            (
                idfHumanCase,
                idfHuman,
                strCaseId,
                idfsFinalDiagnosis,
                datFinalDiagnosisDate,
                datNotIFicationDate,
                idfsFinalState,
                idfSentByOffice,
                strSentByFirstName,
                strSentByPatronymicName,
                strSentByLastName,
                idfSentByPerson,
                idfReceivedByOffice,
                strReceivedByFirstName,
                strReceivedByPatronymicName,
                strReceivedByLastName,
                idfReceivedByPerson,
                idfsHospitalizationStatus,
                idfHospital,
                strCurrentLocation,
                datOnSetDate,
                idfsInitialCaseStatus,
                idfsYNPreviouslySoughtCare,
                datFirstSoughtCareDate,
                idfSoughtCareFacility,
                idfsNonNotIFiableDiagnosis,
                idfsYNHospitalization,
                datHospitalizationDate,
                datDischargeDate,
                strHospitalizationPlace,
                idfsYNAntimicrobialTherapy,
                strClinicalNotes,
                strNote,
                idfsYNSpecIFicVaccinationAdministered,
                idfInvestigatedByOffice,
                idfInvestigatedByPerson,
                datInvestigationStartDate,
                idfsYNRelatedToOutbreak,
                idfOutbreak,
                idfsYNExposureLocationKnown,
                datExposureDate,
                idfsFinalCaseStatus,
                idfsOutcome,
                intRowStatus,
                idfsCaseProgressStatus,
                datModificationDate,
                datEnteredDate,
                idfPersonEnteredBy,
                idfsYNSpecimenCollected,
                DiseaseReportTypeID,
                blnClinicalDiagBasis,
                blnLabDiagBasis,
                blnEpiDiagBasis,
                datFinalCaseClassificationDate,
                strsummarynotes,
                idfEpiObservation,
                idfCSObservation,
                idfsYNTestsConducted,
                AuditCreateUser,
                AuditCreateDTM
            )
            VALUES
            (@idfHumanCase,
             @idfHuman,
             @strHumanCaseId,
             @idfsFinalDiagnosis,
             @datDateOfDiagnosis,
             @datNotificationDate,
             @idfsFinalState,
             @idfSentByOffice,
             @strSentByFirstName,
             @strSentByPatronymicName,
             @strSentByLastName,
             @idfSentByPerson,
             @idfReceivedByOffice,
             @strReceivedByFirstName,
             @strReceivedByPatronymicName,
             @strReceivedByLastName,
             @idfReceivedByPerson,
             @idfsHospitalizationStatus,
             @idfHospital,
             @strCurrentLocation,
             @datOnSetDate,
             @idfsInitialCaseStatus,
             @idfsYNPreviouslySoughtCare,
             @datFirstSoughtCareDate,
             @idfSoughtCareFacility,
             @idfsNonNotIFiableDiagnosis,
             @idfsYNHospitalization,
             @datHospitalizationDate,
             @datDischargeDate,
             @strHospitalName,
             @idfsYNAntimicrobialTherapy,
             @strClinicalNotes,
             @strNote,
             @idfsYNSpecIFicVaccinationAdministered,
             @idfInvestigatedByOffice,
             @idfInvestigatedByPerson,
             @StartDateofInvestigation,
             @idfsYNRelatedToOutbreak,
             @idfOutbreak,
             @idfsYNExposureLocationKnown,
             @datExposureDate,
             @idfsFinalCaseStatus,
             @idfsOutcome,
             0  ,
             @idfsCaseProgressStatus,
             GETDATE(),
             GETDATE(),
             @idfPersonEnteredBy,
             @idfsYNSpecimenCollected,
             @DiseaseReportTypeID,
             @blnClinicalDiagBasis,
             @blnLabDiagBasis,
             @blnEpiDiagBasis,
             @DateofClassification,
             @strSummaryNotes,
             @idfEpiObservation,
             @idfCSObservation,
             @idfsYNTestsConducted,
             @User,
             GETDATE()
            );
        END
        ELSE
        BEGIN
            -- Data audit Edit (Start)
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
            SELECT @strHumanCaseId = strOutbreakCaseID
            FROM dbo.OutbreakCaseReport
            WHERE idfHumanCase = @idfHumanCase;

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @idfHumanCase,
                                                      @ObjectTableID,
                                                      @strHumanCaseId,
                                                      @DataAuditEventID OUTPUT;
            -- Data audit Edit (End)

            --Date Audit Collect Record Details Before Update (Start)
            INSERT INTO @HumanCaseBeforeEdit
            (
                blnClinicalDiagBasis,
                blnEpiDiagBasis,
                blnLabDiagBasis,
                datCompletionPaperFormDate,
                datDischargeDate,
                datExposureDate,
                datFacilityLastVisit,
                datFinalDiagnosisDate,
                datHospitalizationDate,
                datInvestigationStartDate,
                datModificationDate,
                datTentativeDiagnosisDate,
                idfHumanCase,
                idfInvestigatedByOffice,
                idfPointGeoLocation,
                idfReceivedByOffice,
                idfsFinalDiagnosis,
                idfsFinalState,
                idfsHospitalizationStatus,
                idfsHumanAgeType,
                idfsInitialCaseStatus,
                idfsOutcome,
                idfsTentativeDiagnosis,
                idfsYNAntimicrobialTherapy,
                idfsYNHospitalization,
                idfsYNRelatedToOutbreak,
                idfsYNSpecimenCollected,
                intPatientAge,
                strClinicalDiagnosis,
                strCurrentLocation,
                strEpidemiologistsName,
                strHospitalizationPlace,
                strLocalIdentifier,
                strNotCollectedReason,
                strNote,
                strReceivedByFirstName,
                strReceivedByLastName,
                strReceivedByPatronymicName,
                strSentByFirstName,
                strSentByLastName,
                strSentByPatronymicName,
                strSoughtCareFacility,
                idfsFinalCaseStatus,
                idfSentByOffice,
                idfEpiObservation,
                idfCSObservation,
                idfDeduplicationResultCase,
                datNotificationDate,
                datFirstSoughtCareDate,
                datOnSetDate,
                strClinicalNotes,
                strSummaryNotes,
                idfHuman,
                idfPersonEnteredBy,
                idfSentByPerson,
                idfReceivedByPerson,
                idfInvestigatedByPerson,
                idfsYNTestsConducted,
                idfSoughtCareFacility,
                idfsNonNotifiableDiagnosis,
                idfsNotCollectedReason,
                idfOutbreak,
                datEnteredDate,
                strCaseID,
                idfsCaseProgressStatus,
                strSampleNotes,
                uidOfflineCaseID,
                datFinalCaseClassificationDate,
                idfHospital
            )
            SELECT blnClinicalDiagBasis,
                   blnEpiDiagBasis,
                   blnLabDiagBasis,
                   datCompletionPaperFormDate,
                   datDischargeDate,
                   datExposureDate,
                   datFacilityLastVisit,
                   datFinalDiagnosisDate,
                   datHospitalizationDate,
                   datInvestigationStartDate,
                   datModificationDate,
                   datTentativeDiagnosisDate,
                   idfHumanCase,
                   idfInvestigatedByOffice,
                   idfPointGeoLocation,
                   idfReceivedByOffice,
                   idfsFinalDiagnosis,
                   idfsFinalState,
                   idfsHospitalizationStatus,
                   idfsHumanAgeType,
                   idfsInitialCaseStatus,
                   idfsOutcome,
                   idfsTentativeDiagnosis,
                   idfsYNAntimicrobialTherapy,
                   idfsYNHospitalization,
                   idfsYNRelatedToOutbreak,
                   idfsYNSpecimenCollected,
                   intPatientAge,
                   strClinicalDiagnosis,
                   strCurrentLocation,
                   strEpidemiologistsName,
                   strHospitalizationPlace,
                   strLocalIdentifier,
                   strNotCollectedReason,
                   strNote,
                   strReceivedByFirstName,
                   strReceivedByLastName,
                   strReceivedByPatronymicName,
                   strSentByFirstName,
                   strSentByLastName,
                   strSentByPatronymicName,
                   strSoughtCareFacility,
                   idfsFinalCaseStatus,
                   idfSentByOffice,
                   idfEpiObservation,
                   idfCSObservation,
                   idfDeduplicationResultCase,
                   datNotificationDate,
                   datFirstSoughtCareDate,
                   datOnSetDate,
                   strClinicalNotes,
                   strSummaryNotes,
                   idfHuman,
                   idfPersonEnteredBy,
                   idfSentByPerson,
                   idfReceivedByPerson,
                   idfInvestigatedByPerson,
                   idfsYNTestsConducted,
                   idfSoughtCareFacility,
                   idfsNonNotifiableDiagnosis,
                   idfsNotCollectedReason,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   strSampleNotes,
                   uidOfflineCaseID,
                   datFinalCaseClassificationDate,
                   idfHospital
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;
            --Date Audit Collect Record Details Before Update (End)

            UPDATE dbo.tlbHumanCase
            SET idfsTentativeDiagnosis = @idfsFinalDiagnosis,
                idfsFinalDiagnosis = @idfsFinalDiagnosis,
                datFinalDiagnosisDate = @datDateOfDiagnosis,
                datNotIFicationDate = @datNotificationDate,
                idfsFinalState = @idfsFinalState,
                idfSentByOffice = @idfSentByOffice,
                strSentByFirstName = @strSentByFirstName,
                strSentByPatronymicName = @strSentByPatronymicName,
                strSentByLastName = @strSentByLastName,
                idfSentByPerson = @idfSentByPerson,
                idfReceivedByOffice = @idfReceivedByOffice,
                strReceivedByFirstName = @strReceivedByFirstName,
                strReceivedByPatronymicName = @strReceivedByPatronymicName,
                strReceivedByLastName = @strReceivedByLastName,
                idfReceivedByPerson = @idfReceivedByPerson,
                idfsHospitalizationStatus = @idfsHospitalizationStatus,
                idfHospital = @idfHospital,
                strCurrentLocation = @strCurrentLocation,
                datOnSetDate = @datOnSetDate,
                idfsInitialCaseStatus = @idfsInitialCaseStatus,
                idfsYNPreviouslySoughtCare = @idfsYNPreviouslySoughtCare,
                datFirstSoughtCareDate = @datFirstSoughtCareDate,
                idfSoughtCareFacility = @idfSoughtCareFacility,
                idfsNonNotIFiableDiagnosis = @idfsNonNotIFiableDiagnosis,
                idfsYNHospitalization = @idfsYNHospitalization,
                datHospitalizationDate = @datHospitalizationDate,
                datDischargeDate = @datDischargeDate,
                strHospitalizationPlace = @strHospitalName,
                idfsYNAntimicrobialTherapy = @idfsYNAntimicrobialTherapy,
                strClinicalNotes = @strClinicalNotes,
                strNote = @strNote,
                idfsYNSpecIFicVaccinationAdministered = @idfsYNSpecIFicVaccinationAdministered,
                idfInvestigatedByOffice = @idfInvestigatedByOffice,
                idfInvestigatedByPerson = @idfInvestigatedByPerson,
                datInvestigationStartDate = @StartDateofInvestigation,
                idfsYNRelatedToOutbreak = @idfsYNRelatedToOutbreak,
                idfOutbreak = @idfOutbreak,
                idfsYNExposureLocationKnown = @idfsYNExposureLocationKnown,
                datExposureDate = @datExposureDate,
                idfsFinalCaseStatus = @idfsFinalCaseStatus,
                idfsOutcome = @idfsOutcome,
                idfsCaseProgressStatus = @idfsCaseProgressStatus,
                datModificationDate = GETDATE(),
                idfsYNSpecimenCollected = @idfsYNSpecimenCollected,
                idfsYNTestsConducted = @idfsYNTestsConducted,
                DiseaseReportTypeID = @DiseaseReportTypeID,
                blnClinicalDiagBasis = @blnClinicalDiagBasis,
                blnLabDiagBasis = @blnLabDiagBasis,
                blnEpiDiagBasis = @blnEpiDiagBasis,
                datFinalCaseClassificationDate = @DateofClassification,
                strsummarynotes = @strSummaryNotes,
                idfEpiObservation = @idfEpiObservation,
                idfCSObservation = @idfCSObservation,
                idfHuman = @idfHuman,
                AuditUpdateUser = @User,
                AuditUpdateDTM = GETDATE()
            WHERE idfHumanCase = @idfHumanCase;

            --Date Audit Collect Record Details After Update (Start)
            INSERT INTO @HumanCaseAfterEdit
            (
                blnClinicalDiagBasis,
                blnEpiDiagBasis,
                blnLabDiagBasis,
                datCompletionPaperFormDate,
                datDischargeDate,
                datExposureDate,
                datFacilityLastVisit,
                datFinalDiagnosisDate,
                datHospitalizationDate,
                datInvestigationStartDate,
                datModificationDate,
                datTentativeDiagnosisDate,
                idfHumanCase,
                idfInvestigatedByOffice,
                idfPointGeoLocation,
                idfReceivedByOffice,
                idfsFinalDiagnosis,
                idfsFinalState,
                idfsHospitalizationStatus,
                idfsHumanAgeType,
                idfsInitialCaseStatus,
                idfsOutcome,
                idfsTentativeDiagnosis,
                idfsYNAntimicrobialTherapy,
                idfsYNHospitalization,
                idfsYNRelatedToOutbreak,
                idfsYNSpecimenCollected,
                intPatientAge,
                strClinicalDiagnosis,
                strCurrentLocation,
                strEpidemiologistsName,
                strHospitalizationPlace,
                strLocalIdentifier,
                strNotCollectedReason,
                strNote,
                strReceivedByFirstName,
                strReceivedByLastName,
                strReceivedByPatronymicName,
                strSentByFirstName,
                strSentByLastName,
                strSentByPatronymicName,
                strSoughtCareFacility,
                idfsFinalCaseStatus,
                idfSentByOffice,
                idfEpiObservation,
                idfCSObservation,
                idfDeduplicationResultCase,
                datNotificationDate,
                datFirstSoughtCareDate,
                datOnSetDate,
                strClinicalNotes,
                strSummaryNotes,
                idfHuman,
                idfPersonEnteredBy,
                idfSentByPerson,
                idfReceivedByPerson,
                idfInvestigatedByPerson,
                idfsYNTestsConducted,
                idfSoughtCareFacility,
                idfsNonNotifiableDiagnosis,
                idfsNotCollectedReason,
                idfOutbreak,
                datEnteredDate,
                strCaseID,
                idfsCaseProgressStatus,
                strSampleNotes,
                uidOfflineCaseID,
                datFinalCaseClassificationDate,
                idfHospital
            )
            SELECT blnClinicalDiagBasis,
                   blnEpiDiagBasis,
                   blnLabDiagBasis,
                   datCompletionPaperFormDate,
                   datDischargeDate,
                   datExposureDate,
                   datFacilityLastVisit,
                   datFinalDiagnosisDate,
                   datHospitalizationDate,
                   datInvestigationStartDate,
                   datModificationDate,
                   datTentativeDiagnosisDate,
                   idfHumanCase,
                   idfInvestigatedByOffice,
                   idfPointGeoLocation,
                   idfReceivedByOffice,
                   idfsFinalDiagnosis,
                   idfsFinalState,
                   idfsHospitalizationStatus,
                   idfsHumanAgeType,
                   idfsInitialCaseStatus,
                   idfsOutcome,
                   idfsTentativeDiagnosis,
                   idfsYNAntimicrobialTherapy,
                   idfsYNHospitalization,
                   idfsYNRelatedToOutbreak,
                   idfsYNSpecimenCollected,
                   intPatientAge,
                   strClinicalDiagnosis,
                   strCurrentLocation,
                   strEpidemiologistsName,
                   strHospitalizationPlace,
                   strLocalIdentifier,
                   strNotCollectedReason,
                   strNote,
                   strReceivedByFirstName,
                   strReceivedByLastName,
                   strReceivedByPatronymicName,
                   strSentByFirstName,
                   strSentByLastName,
                   strSentByPatronymicName,
                   strSoughtCareFacility,
                   idfsFinalCaseStatus,
                   idfSentByOffice,
                   idfEpiObservation,
                   idfCSObservation,
                   idfDeduplicationResultCase,
                   datNotificationDate,
                   datFirstSoughtCareDate,
                   datOnSetDate,
                   strClinicalNotes,
                   strSummaryNotes,
                   idfHuman,
                   idfPersonEnteredBy,
                   idfSentByPerson,
                   idfReceivedByPerson,
                   idfInvestigatedByPerson,
                   idfsYNTestsConducted,
                   idfSoughtCareFacility,
                   idfsNonNotifiableDiagnosis,
                   idfsNotCollectedReason,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   strSampleNotes,
                   uidOfflineCaseID,
                   datFinalCaseClassificationDate,
                   idfHospital
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;
            --Date Audit Collect Record Details After Update (End)

            --Date Audit Create Entry For Any Changes Made (Start)
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79490000000, --blnClinicalDiagBasis
                   a.idfHumanCase,
                   NULL,
                   b.blnClinicalDiagBasis,
                   a.blnClinicalDiagBasis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.blnClinicalDiagBasis <> b.blnClinicalDiagBasis)
                  OR (
                         a.blnClinicalDiagBasis IS NOT NULL
                         AND b.blnClinicalDiagBasis IS NULL
                     )
                  OR (
                         a.blnClinicalDiagBasis IS NULL
                         AND b.blnClinicalDiagBasis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79500000000, --blnEpiDiagBasis
                   a.idfHumanCase,
                   NULL,
                   b.blnEpiDiagBasis,
                   a.blnEpiDiagBasis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.blnEpiDiagBasis <> b.blnEpiDiagBasis)
                  OR (
                         a.blnEpiDiagBasis IS NOT NULL
                         AND b.blnEpiDiagBasis IS NULL
                     )
                  OR (
                         a.blnEpiDiagBasis IS NULL
                         AND b.blnEpiDiagBasis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79510000000, --blnLabDiagBasis
                   a.idfHumanCase,
                   NULL,
                   b.blnLabDiagBasis,
                   a.blnLabDiagBasis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.blnLabDiagBasis <> b.blnLabDiagBasis)
                  OR (
                         a.blnLabDiagBasis IS NOT NULL
                         AND b.blnLabDiagBasis IS NULL
                     )
                  OR (
                         a.blnLabDiagBasis IS NULL
                         AND b.blnLabDiagBasis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79520000000, --datCompletionPaperFormDate
                   a.idfHumanCase,
                   NULL,
                   b.datCompletionPaperFormDate,
                   a.datCompletionPaperFormDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datCompletionPaperFormDate <> b.datCompletionPaperFormDate)
                  OR (
                         a.datCompletionPaperFormDate IS NOT NULL
                         AND b.datCompletionPaperFormDate IS NULL
                     )
                  OR (
                         a.datCompletionPaperFormDate IS NULL
                         AND b.datCompletionPaperFormDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79530000000, --datDischargeDate
                   a.idfHumanCase,
                   NULL,
                   b.datDischargeDate,
                   a.datDischargeDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datDischargeDate <> b.datDischargeDate)
                  OR (
                         a.datDischargeDate IS NOT NULL
                         AND b.datDischargeDate IS NULL
                     )
                  OR (
                         a.datDischargeDate IS NULL
                         AND b.datDischargeDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79540000000, --datExposureDate
                   a.idfHumanCase,
                   NULL,
                   b.datExposureDate,
                   a.datExposureDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datExposureDate <> b.datExposureDate)
                  OR (
                         a.datExposureDate IS NOT NULL
                         AND b.datExposureDate IS NULL
                     )
                  OR (
                         a.datExposureDate IS NULL
                         AND b.datExposureDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79550000000, --datFacilityLastVisit
                   a.idfHumanCase,
                   NULL,
                   b.datFacilityLastVisit,
                   a.datFacilityLastVisit,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFacilityLastVisit <> b.datFacilityLastVisit)
                  OR (
                         a.datFacilityLastVisit IS NOT NULL
                         AND b.datFacilityLastVisit IS NULL
                     )
                  OR (
                         a.datFacilityLastVisit IS NULL
                         AND b.datFacilityLastVisit IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79560000000, --datFinalDiagnosisDate
                   a.idfHumanCase,
                   NULL,
                   b.datFinalDiagnosisDate,
                   a.datFinalDiagnosisDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFinalDiagnosisDate <> b.datFinalDiagnosisDate)
                  OR (
                         a.datFinalDiagnosisDate IS NOT NULL
                         AND b.datFinalDiagnosisDate IS NULL
                     )
                  OR (
                         a.datFinalDiagnosisDate IS NULL
                         AND b.datFinalDiagnosisDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79570000000, --datHospitalizationDate
                   a.idfHumanCase,
                   NULL,
                   b.datHospitalizationDate,
                   a.datHospitalizationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datHospitalizationDate <> b.datHospitalizationDate)
                  OR (
                         a.datHospitalizationDate IS NOT NULL
                         AND b.datHospitalizationDate IS NULL
                     )
                  OR (
                         a.datHospitalizationDate IS NULL
                         AND b.datHospitalizationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79580000000, --datInvestigationStartDate
                   a.idfHumanCase,
                   NULL,
                   b.datInvestigationStartDate,
                   a.datInvestigationStartDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datInvestigationStartDate <> b.datInvestigationStartDate)
                  OR (
                         a.datInvestigationStartDate IS NOT NULL
                         AND b.datInvestigationStartDate IS NULL
                     )
                  OR (
                         a.datInvestigationStartDate IS NULL
                         AND b.datInvestigationStartDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79590000000, --datModificationDate
                   a.idfHumanCase,
                   NULL,
                   b.datModificationDate,
                   a.datModificationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datModificationDate <> b.datModificationDate)
                  OR (
                         a.datModificationDate IS NOT NULL
                         AND b.datModificationDate IS NULL
                     )
                  OR (
                         a.datModificationDate IS NULL
                         AND b.datModificationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79600000000, --datTentativeDiagnosisDate
                   a.idfHumanCase,
                   NULL,
                   b.datTentativeDiagnosisDate,
                   a.datTentativeDiagnosisDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datTentativeDiagnosisDate <> b.datTentativeDiagnosisDate)
                  OR (
                         a.datTentativeDiagnosisDate IS NOT NULL
                         AND b.datTentativeDiagnosisDate IS NULL
                     )
                  OR (
                         a.datTentativeDiagnosisDate IS NULL
                         AND b.datTentativeDiagnosisDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79610000000, --idfHumanCase
                   a.idfHumanCase,
                   NULL,
                   b.idfHumanCase,
                   a.idfHumanCase,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHumanCase <> b.idfHumanCase)
                  OR (
                         a.idfHumanCase IS NOT NULL
                         AND b.idfHumanCase IS NULL
                     )
                  OR (
                         a.idfHumanCase IS NULL
                         AND b.idfHumanCase IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79620000000, --idfInvestigatedByOffice
                   a.idfHumanCase,
                   NULL,
                   b.idfInvestigatedByOffice,
                   a.idfInvestigatedByOffice,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfInvestigatedByOffice <> b.idfInvestigatedByOffice)
                  OR (
                         a.idfInvestigatedByOffice IS NOT NULL
                         AND b.idfInvestigatedByOffice IS NULL
                     )
                  OR (
                         a.idfInvestigatedByOffice IS NULL
                         AND b.idfInvestigatedByOffice IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79630000000, --idfPointGeoLocation
                   a.idfHumanCase,
                   NULL,
                   b.idfPointGeoLocation,
                   a.idfPointGeoLocation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfPointGeoLocation <> b.idfPointGeoLocation)
                  OR (
                         a.idfPointGeoLocation IS NOT NULL
                         AND b.idfPointGeoLocation IS NULL
                     )
                  OR (
                         a.idfPointGeoLocation IS NULL
                         AND b.idfPointGeoLocation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79640000000, --idfReceivedByOffice
                   a.idfHumanCase,
                   NULL,
                   b.idfReceivedByOffice,
                   a.idfReceivedByOffice,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfReceivedByOffice <> b.idfReceivedByOffice)
                  OR (
                         a.idfReceivedByOffice IS NOT NULL
                         AND b.idfReceivedByOffice IS NULL
                     )
                  OR (
                         a.idfReceivedByOffice IS NULL
                         AND b.idfReceivedByOffice IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79660000000, --idfsFinalDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.idfsFinalDiagnosis,
                   a.idfsFinalDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsFinalDiagnosis <> b.idfsFinalDiagnosis)
                  OR (
                         a.idfsFinalDiagnosis IS NOT NULL
                         AND b.idfsFinalDiagnosis IS NULL
                     )
                  OR (
                         a.idfsFinalDiagnosis IS NULL
                         AND b.idfsFinalDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79670000000, --idfsFinalState
                   a.idfHumanCase,
                   NULL,
                   b.idfsFinalState,
                   a.idfsFinalState,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsFinalState <> b.idfsFinalState)
                  OR (
                         a.idfsFinalState IS NOT NULL
                         AND b.idfsFinalState IS NULL
                     )
                  OR (
                         a.idfsFinalState IS NULL
                         AND b.idfsFinalState IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79680000000, --idfsHospitalizationStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsHospitalizationStatus,
                   a.idfsHospitalizationStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsHospitalizationStatus <> b.idfsHospitalizationStatus)
                  OR (
                         a.idfsHospitalizationStatus IS NOT NULL
                         AND b.idfsHospitalizationStatus IS NULL
                     )
                  OR (
                         a.idfsHospitalizationStatus IS NULL
                         AND b.idfsHospitalizationStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79690000000, --idfsHumanAgeType
                   a.idfHumanCase,
                   NULL,
                   b.idfsHumanAgeType,
                   a.idfsHumanAgeType,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsHumanAgeType <> b.idfsHumanAgeType)
                  OR (
                         a.idfsHumanAgeType IS NOT NULL
                         AND b.idfsHumanAgeType IS NULL
                     )
                  OR (
                         a.idfsHumanAgeType IS NULL
                         AND b.idfsHumanAgeType IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79700000000, --idfsInitialCaseStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsInitialCaseStatus,
                   a.idfsInitialCaseStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsInitialCaseStatus <> b.idfsInitialCaseStatus)
                  OR (
                         a.idfsInitialCaseStatus IS NOT NULL
                         AND b.idfsInitialCaseStatus IS NULL
                     )
                  OR (
                         a.idfsInitialCaseStatus IS NULL
                         AND b.idfsInitialCaseStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79710000000, --idfsOutcome
                   a.idfHumanCase,
                   NULL,
                   b.idfsOutcome,
                   a.idfsOutcome,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsOutcome <> b.idfsOutcome)
                  OR (
                         a.idfsOutcome IS NOT NULL
                         AND b.idfsOutcome IS NULL
                     )
                  OR (
                         a.idfsOutcome IS NULL
                         AND b.idfsOutcome IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79720000000, --idfsTentativeDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.idfsTentativeDiagnosis,
                   a.idfsTentativeDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsTentativeDiagnosis <> b.idfsTentativeDiagnosis)
                  OR (
                         a.idfsTentativeDiagnosis IS NOT NULL
                         AND b.idfsTentativeDiagnosis IS NULL
                     )
                  OR (
                         a.idfsTentativeDiagnosis IS NULL
                         AND b.idfsTentativeDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79730000000, --idfsYNAntimicrobialTherapy
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNAntimicrobialTherapy,
                   a.idfsYNAntimicrobialTherapy,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNAntimicrobialTherapy <> b.idfsYNAntimicrobialTherapy)
                  OR (
                         a.idfsYNAntimicrobialTherapy IS NOT NULL
                         AND b.idfsYNAntimicrobialTherapy IS NULL
                     )
                  OR (
                         a.idfsYNAntimicrobialTherapy IS NULL
                         AND b.idfsYNAntimicrobialTherapy IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79740000000, --idfsYNHospitalization
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNHospitalization,
                   a.idfsYNHospitalization,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNHospitalization <> b.idfsYNHospitalization)
                  OR (
                         a.idfsYNHospitalization IS NOT NULL
                         AND b.idfsYNHospitalization IS NULL
                     )
                  OR (
                         a.idfsYNHospitalization IS NULL
                         AND b.idfsYNHospitalization IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79750000000, --idfsYNRelatedToOutbreak
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNRelatedToOutbreak,
                   a.idfsYNRelatedToOutbreak,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNRelatedToOutbreak <> b.idfsYNRelatedToOutbreak)
                  OR (
                         a.idfsYNRelatedToOutbreak IS NOT NULL
                         AND b.idfsYNRelatedToOutbreak IS NULL
                     )
                  OR (
                         a.idfsYNRelatedToOutbreak IS NULL
                         AND b.idfsYNRelatedToOutbreak IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79760000000, --idfsYNSpecimenCollected
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNSpecimenCollected,
                   a.idfsYNSpecimenCollected,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNSpecimenCollected <> b.idfsYNSpecimenCollected)
                  OR (
                         a.idfsYNSpecimenCollected IS NOT NULL
                         AND b.idfsYNSpecimenCollected IS NULL
                     )
                  OR (
                         a.idfsYNSpecimenCollected IS NULL
                         AND b.idfsYNSpecimenCollected IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79770000000, --intPatientAge
                   a.idfHumanCase,
                   NULL,
                   b.intPatientAge,
                   a.intPatientAge,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.intPatientAge <> b.intPatientAge)
                  OR (
                         a.intPatientAge IS NOT NULL
                         AND b.intPatientAge IS NULL
                     )
                  OR (
                         a.intPatientAge IS NULL
                         AND b.intPatientAge IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79780000000, --strClinicalDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.strClinicalDiagnosis,
                   a.strClinicalDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strClinicalDiagnosis <> b.strClinicalDiagnosis)
                  OR (
                         a.strClinicalDiagnosis IS NOT NULL
                         AND b.strClinicalDiagnosis IS NULL
                     )
                  OR (
                         a.strClinicalDiagnosis IS NULL
                         AND b.strClinicalDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79790000000, --strCurrentLocation
                   a.idfHumanCase,
                   NULL,
                   b.strCurrentLocation,
                   a.strCurrentLocation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strCurrentLocation <> b.strCurrentLocation)
                  OR (
                         a.strCurrentLocation IS NOT NULL
                         AND b.strCurrentLocation IS NULL
                     )
                  OR (
                         a.strCurrentLocation IS NULL
                         AND b.strCurrentLocation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79800000000, --strEpidemiologistsName
                   a.idfHumanCase,
                   NULL,
                   b.strEpidemiologistsName,
                   a.strEpidemiologistsName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strEpidemiologistsName <> b.strEpidemiologistsName)
                  OR (
                         a.strEpidemiologistsName IS NOT NULL
                         AND b.strEpidemiologistsName IS NULL
                     )
                  OR (
                         a.strEpidemiologistsName IS NULL
                         AND b.strEpidemiologistsName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79810000000, --strHospitalizationPlace
                   a.idfHumanCase,
                   NULL,
                   b.strHospitalizationPlace,
                   a.strHospitalizationPlace,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strHospitalizationPlace <> b.strHospitalizationPlace)
                  OR (
                         a.strHospitalizationPlace IS NOT NULL
                         AND b.strHospitalizationPlace IS NULL
                     )
                  OR (
                         a.strHospitalizationPlace IS NULL
                         AND b.strHospitalizationPlace IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79820000000, --strLocalIdentifier
                   a.idfHumanCase,
                   NULL,
                   b.strLocalIdentifier,
                   a.strLocalIdentifier,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strLocalIdentifier <> b.strLocalIdentifier)
                  OR (
                         a.strLocalIdentifier IS NOT NULL
                         AND b.strLocalIdentifier IS NULL
                     )
                  OR (
                         a.strLocalIdentifier IS NULL
                         AND b.strLocalIdentifier IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79830000000, --strNotCollectedReason
                   a.idfHumanCase,
                   NULL,
                   b.strNotCollectedReason,
                   a.strNotCollectedReason,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strNotCollectedReason <> b.strNotCollectedReason)
                  OR (
                         a.strNotCollectedReason IS NOT NULL
                         AND b.strNotCollectedReason IS NULL
                     )
                  OR (
                         a.strNotCollectedReason IS NULL
                         AND b.strNotCollectedReason IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79840000000, --strNote
                   a.idfHumanCase,
                   NULL,
                   b.strNote,
                   a.strNote,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strNote <> b.strNote)
                  OR (
                         a.strNote IS NOT NULL
                         AND b.strNote IS NULL
                     )
                  OR (
                         a.strNote IS NULL
                         AND b.strNote IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79850000000, --strReceivedByFirstName
                   a.idfHumanCase,
                   NULL,
                   b.strReceivedByFirstName,
                   a.strReceivedByFirstName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strReceivedByFirstName <> b.strReceivedByFirstName)
                  OR (
                         a.strReceivedByFirstName IS NOT NULL
                         AND b.strReceivedByFirstName IS NULL
                     )
                  OR (
                         a.strReceivedByFirstName IS NULL
                         AND b.strReceivedByFirstName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79860000000, --strReceivedByLastName
                   a.idfHumanCase,
                   NULL,
                   b.strReceivedByLastName,
                   a.strReceivedByLastName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strReceivedByLastName <> b.strReceivedByLastName)
                  OR (
                         a.strReceivedByLastName IS NOT NULL
                         AND b.strReceivedByLastName IS NULL
                     )
                  OR (
                         a.strReceivedByLastName IS NULL
                         AND b.strReceivedByLastName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79870000000, --strReceivedByPatronymicName
                   a.idfHumanCase,
                   NULL,
                   b.strReceivedByPatronymicName,
                   a.strReceivedByPatronymicName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strReceivedByPatronymicName <> b.strReceivedByPatronymicName)
                  OR (
                         a.strReceivedByPatronymicName IS NOT NULL
                         AND b.strReceivedByPatronymicName IS NULL
                     )
                  OR (
                         a.strReceivedByPatronymicName IS NULL
                         AND b.strReceivedByPatronymicName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79880000000, --strSentByFirstName
                   a.idfHumanCase,
                   NULL,
                   b.strSentByFirstName,
                   a.strSentByFirstName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSentByFirstName <> b.strSentByFirstName)
                  OR (
                         a.strSentByFirstName IS NOT NULL
                         AND b.strSentByFirstName IS NULL
                     )
                  OR (
                         a.strSentByFirstName IS NULL
                         AND b.strSentByFirstName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79890000000, --strSentByLastName
                   a.idfHumanCase,
                   NULL,
                   b.strSentByLastName,
                   a.strSentByLastName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSentByLastName <> b.strSentByLastName)
                  OR (
                         a.strSentByLastName IS NOT NULL
                         AND b.strSentByLastName IS NULL
                     )
                  OR (
                         a.strSentByLastName IS NULL
                         AND b.strSentByLastName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79900000000, --strSentByPatronymicName
                   a.idfHumanCase,
                   NULL,
                   b.strSentByPatronymicName,
                   a.strSentByPatronymicName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSentByPatronymicName <> b.strSentByPatronymicName)
                  OR (
                         a.strSentByPatronymicName IS NOT NULL
                         AND b.strSentByPatronymicName IS NULL
                     )
                  OR (
                         a.strSentByPatronymicName IS NULL
                         AND b.strSentByPatronymicName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79910000000, --strSoughtCareFacility
                   a.idfHumanCase,
                   NULL,
                   b.strSoughtCareFacility,
                   a.strSoughtCareFacility,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSoughtCareFacility <> b.strSoughtCareFacility)
                  OR (
                         a.strSoughtCareFacility IS NOT NULL
                         AND b.strSoughtCareFacility IS NULL
                     )
                  OR (
                         a.strSoughtCareFacility IS NULL
                         AND b.strSoughtCareFacility IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855690000000, --idfsFinalCaseStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsFinalCaseStatus,
                   a.idfsFinalCaseStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsFinalCaseStatus <> b.idfsFinalCaseStatus)
                  OR (
                         a.idfsFinalCaseStatus IS NOT NULL
                         AND b.idfsFinalCaseStatus IS NULL
                     )
                  OR (
                         a.idfsFinalCaseStatus IS NULL
                         AND b.idfsFinalCaseStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855700000000, --idfSentByOffice
                   a.idfHumanCase,
                   NULL,
                   b.idfSentByOffice,
                   a.idfSentByOffice,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfSentByOffice <> b.idfSentByOffice)
                  OR (
                         a.idfSentByOffice IS NOT NULL
                         AND b.idfSentByOffice IS NULL
                     )
                  OR (
                         a.idfSentByOffice IS NULL
                         AND b.idfSentByOffice IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855710000000, --idfEpiObservation
                   a.idfHumanCase,
                   NULL,
                   b.idfEpiObservation,
                   a.idfEpiObservation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfEpiObservation <> b.idfEpiObservation)
                  OR (
                         a.idfEpiObservation IS NOT NULL
                         AND b.idfEpiObservation IS NULL
                     )
                  OR (
                         a.idfEpiObservation IS NULL
                         AND b.idfEpiObservation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855720000000, --idfCSObservation
                   a.idfHumanCase,
                   NULL,
                   b.idfCSObservation,
                   a.idfCSObservation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfCSObservation <> b.idfCSObservation)
                  OR (
                         a.idfCSObservation IS NOT NULL
                         AND b.idfCSObservation IS NULL
                     )
                  OR (
                         a.idfCSObservation IS NULL
                         AND b.idfCSObservation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855730000000, --idfDeduplicationResultCase
                   a.idfHumanCase,
                   NULL,
                   b.idfDeduplicationResultCase,
                   a.idfDeduplicationResultCase,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfDeduplicationResultCase <> b.idfDeduplicationResultCase)
                  OR (
                         a.idfDeduplicationResultCase IS NOT NULL
                         AND b.idfDeduplicationResultCase IS NULL
                     )
                  OR (
                         a.idfDeduplicationResultCase IS NULL
                         AND b.idfDeduplicationResultCase IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855740000000, --datNotificationDate
                   a.idfHumanCase,
                   NULL,
                   b.datNotificationDate,
                   a.datNotificationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datNotificationDate <> b.datNotificationDate)
                  OR (
                         a.datNotificationDate IS NOT NULL
                         AND b.datNotificationDate IS NULL
                     )
                  OR (
                         a.datNotificationDate IS NULL
                         AND b.datNotificationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855750000000, --datFirstSoughtCareDate
                   a.idfHumanCase,
                   NULL,
                   b.datFirstSoughtCareDate,
                   a.datFirstSoughtCareDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFirstSoughtCareDate <> b.datFirstSoughtCareDate)
                  OR (
                         a.datFirstSoughtCareDate IS NOT NULL
                         AND b.datFirstSoughtCareDate IS NULL
                     )
                  OR (
                         a.datFirstSoughtCareDate IS NULL
                         AND b.datFirstSoughtCareDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855760000000, --datOnSetDate
                   a.idfHumanCase,
                   NULL,
                   b.datOnSetDate,
                   a.datOnSetDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datOnSetDate <> b.datOnSetDate)
                  OR (
                         a.datOnSetDate IS NOT NULL
                         AND b.datOnSetDate IS NULL
                     )
                  OR (
                         a.datOnSetDate IS NULL
                         AND b.datOnSetDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855770000000, --strClinicalNotes
                   a.idfHumanCase,
                   NULL,
                   b.strClinicalNotes,
                   a.strClinicalNotes,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strClinicalNotes <> b.strClinicalNotes)
                  OR (
                         a.strClinicalNotes IS NOT NULL
                         AND b.strClinicalNotes IS NULL
                     )
                  OR (
                         a.strClinicalNotes IS NULL
                         AND b.strClinicalNotes IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855780000000, --strSummaryNotes
                   a.idfHumanCase,
                   NULL,
                   b.strSummaryNotes,
                   a.strSummaryNotes,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSummaryNotes <> b.strSummaryNotes)
                  OR (
                         a.strSummaryNotes IS NOT NULL
                         AND b.strSummaryNotes IS NULL
                     )
                  OR (
                         a.strSummaryNotes IS NULL
                         AND b.strSummaryNotes IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4577900000000, --idfHuman
                   a.idfHumanCase,
                   NULL,
                   b.idfHuman,
                   a.idfHuman,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHuman <> b.idfHuman)
                  OR (
                         a.idfHuman IS NOT NULL
                         AND b.idfHuman IS NULL
                     )
                  OR (
                         a.idfHuman IS NULL
                         AND b.idfHuman IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4577910000000, --idfPersonEnteredBy
                   a.idfHumanCase,
                   NULL,
                   b.idfPersonEnteredBy,
                   a.idfPersonEnteredBy,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfPersonEnteredBy <> b.idfPersonEnteredBy)
                  OR (
                         a.idfPersonEnteredBy IS NOT NULL
                         AND b.idfPersonEnteredBy IS NULL
                     )
                  OR (
                         a.idfPersonEnteredBy IS NULL
                         AND b.idfPersonEnteredBy IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578390000000, --idfSentByPerson
                   a.idfHumanCase,
                   NULL,
                   b.idfSentByPerson,
                   a.idfSentByPerson,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfSentByPerson <> b.idfSentByPerson)
                  OR (
                         a.idfSentByPerson IS NOT NULL
                         AND b.idfSentByPerson IS NULL
                     )
                  OR (
                         a.idfSentByPerson IS NULL
                         AND b.idfSentByPerson IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578400000000, --idfReceivedByPerson
                   a.idfHumanCase,
                   NULL,
                   b.idfReceivedByPerson,
                   a.idfReceivedByPerson,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfReceivedByPerson <> b.idfReceivedByPerson)
                  OR (
                         a.idfReceivedByPerson IS NOT NULL
                         AND b.idfReceivedByPerson IS NULL
                     )
                  OR (
                         a.idfReceivedByPerson IS NULL
                         AND b.idfReceivedByPerson IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578410000000, --idfInvestigatedByPerson
                   a.idfHumanCase,
                   NULL,
                   b.idfInvestigatedByPerson,
                   a.idfInvestigatedByPerson,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfInvestigatedByPerson <> b.idfInvestigatedByPerson)
                  OR (
                         a.idfInvestigatedByPerson IS NOT NULL
                         AND b.idfInvestigatedByPerson IS NULL
                     )
                  OR (
                         a.idfInvestigatedByPerson IS NULL
                         AND b.idfInvestigatedByPerson IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578420000000, --idfsYNTestsConducted
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNTestsConducted,
                   a.idfsYNTestsConducted,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNTestsConducted <> b.idfsYNTestsConducted)
                  OR (
                         a.idfsYNTestsConducted IS NOT NULL
                         AND b.idfsYNTestsConducted IS NULL
                     )
                  OR (
                         a.idfsYNTestsConducted IS NULL
                         AND b.idfsYNTestsConducted IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014650000000, --idfSoughtCareFacility
                   a.idfHumanCase,
                   NULL,
                   b.idfSoughtCareFacility,
                   a.idfSoughtCareFacility,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfSoughtCareFacility <> b.idfSoughtCareFacility)
                  OR (
                         a.idfSoughtCareFacility IS NOT NULL
                         AND b.idfSoughtCareFacility IS NULL
                     )
                  OR (
                         a.idfSoughtCareFacility IS NULL
                         AND b.idfSoughtCareFacility IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014660000000, --idfsNonNotifiableDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.idfsNonNotifiableDiagnosis,
                   a.idfsNonNotifiableDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsNonNotifiableDiagnosis <> b.idfsNonNotifiableDiagnosis)
                  OR (
                         a.idfsNonNotifiableDiagnosis IS NOT NULL
                         AND b.idfsNonNotifiableDiagnosis IS NULL
                     )
                  OR (
                         a.idfsNonNotifiableDiagnosis IS NULL
                         AND b.idfsNonNotifiableDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014670000000, --idfsNotCollectedReason
                   a.idfHumanCase,
                   NULL,
                   b.idfsNotCollectedReason,
                   a.idfsNotCollectedReason,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsNotCollectedReason <> b.idfsNotCollectedReason)
                  OR (
                         a.idfsNotCollectedReason IS NOT NULL
                         AND b.idfsNotCollectedReason IS NULL
                     )
                  OR (
                         a.idfsNotCollectedReason IS NULL
                         AND b.idfsNotCollectedReason IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665410000000, --idfHumanCase
                   a.idfHumanCase,
                   NULL,
                   b.idfHumanCase,
                   a.idfHumanCase,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHumanCase <> b.idfHumanCase)
                  OR (
                         a.idfHumanCase IS NOT NULL
                         AND b.idfHumanCase IS NULL
                     )
                  OR (
                         a.idfHumanCase IS NULL
                         AND b.idfHumanCase IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665420000000, --datEnteredDate
                   a.idfHumanCase,
                   NULL,
                   b.datEnteredDate,
                   a.datEnteredDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datEnteredDate <> b.datEnteredDate)
                  OR (
                         a.datEnteredDate IS NOT NULL
                         AND b.datEnteredDate IS NULL
                     )
                  OR (
                         a.datEnteredDate IS NULL
                         AND b.datEnteredDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665430000000, --strCaseID
                   a.idfHumanCase,
                   NULL,
                   b.strCaseID,
                   a.strCaseID,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strCaseID <> b.strCaseID)
                  OR (
                         a.strCaseID IS NOT NULL
                         AND b.strCaseID IS NULL
                     )
                  OR (
                         a.strCaseID IS NULL
                         AND b.strCaseID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665440000000, --idfsCaseProgressStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsCaseProgressStatus,
                   a.idfsCaseProgressStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsCaseProgressStatus <> b.idfsCaseProgressStatus)
                  OR (
                         a.idfsCaseProgressStatus IS NOT NULL
                         AND b.idfsCaseProgressStatus IS NULL
                     )
                  OR (
                         a.idfsCaseProgressStatus IS NULL
                         AND b.idfsCaseProgressStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665450000000, --strSampleNotes
                   a.idfHumanCase,
                   NULL,
                   b.strSampleNotes,
                   a.strSampleNotes,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSampleNotes <> b.strSampleNotes)
                  OR (
                         a.strSampleNotes IS NOT NULL
                         AND b.strSampleNotes IS NULL
                     )
                  OR (
                         a.strSampleNotes IS NULL
                         AND b.strSampleNotes IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665460000000, --uidOfflineCaseID
                   a.idfHumanCase,
                   NULL,
                   b.uidOfflineCaseID,
                   a.uidOfflineCaseID,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.uidOfflineCaseID <> b.uidOfflineCaseID)
                  OR (
                         a.uidOfflineCaseID IS NOT NULL
                         AND b.uidOfflineCaseID IS NULL
                     )
                  OR (
                         a.uidOfflineCaseID IS NULL
                         AND b.uidOfflineCaseID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51389570000000, --datFinalCaseClassificationDate
                   a.idfHumanCase,
                   NULL,
                   b.datFinalCaseClassificationDate,
                   a.datFinalCaseClassificationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFinalCaseClassificationDate <> b.datFinalCaseClassificationDate)
                  OR (
                         a.datFinalCaseClassificationDate IS NOT NULL
                         AND b.datFinalCaseClassificationDate IS NULL
                     )
                  OR (
                         a.datFinalCaseClassificationDate IS NULL
                         AND b.datFinalCaseClassificationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51523420000000, --idfHospital
                   a.idfHumanCase,
                   NULL,
                   b.idfHospital,
                   a.idfHospital,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHospital <> b.idfHospital)
                  OR (
                         a.idfHospital IS NOT NULL
                         AND b.idfHospital IS NULL
                     )
                  OR (
                         a.idfHospital IS NULL
                         AND b.idfHospital IS NOT NULL
                     );

        --Date Audit Create Entry For Any Changes Made (End)
        END

        UPDATE dbo.tlbHuman
        SET idfCurrentResidenceAddress = @CaseGeoLocationID
        WHERE idfHuman = @idfHuman;

        --Temp solution for correct DateTime2 json dates, when they are coming in at Min value
        SET @SamplesParameters = REPLACE(@SamplesParameters, '"0001-01-01T00:00:00"', 'null');
        SET @TestsParameters = REPLACE(@TestsParameters, '"0001-01-01T00:00:00"', 'null');
        SET @AntiviralTherapiesParameters = REPLACE(@AntiviralTherapiesParameters, '"0001-01-01T00:00:00"', 'null');
        SET @VaccinationsParameters = REPLACE(@VaccinationsParameters, '"0001-01-01T00:00:00"', 'null');

        ----set AntiviralTherapies for this idfHumanCase
        If @AntiviralTherapiesParameters IS NOT NULL
        BEGIN
            DECLARE @OutbreakAntimicrobialTemp TABLE
            (
                antibioticID BIGINT NULL,
                idfHumanCase BIGINT NULL,
                idfAntimicrobialTherapy BIGINT NULL,
                strAntimicrobialTherapyName NVARCHAR(200) NULL,
                strDosage NVARCHAR(200) NULL,
                datFirstAdministeredDate DATETIME2 NULL,
                rowAction CHAR(1) NULL
            );

            INSERT INTO @OutbreakAntimicrobialTemp
            SELECT *
            FROM
                OPENJSON(@AntiviralTherapiesParameters)
                WITH
                (
                    antibioticID BIGINT,
                    idfHumanCase BIGINT,
                    idfAntimicrobialTherapy BIGINT,
                    strAntimicrobialTherapyName NVARCHAR(200),
                    strDosage NVARCHAR(200),
                    datFirstAdministeredDate DATETIME2,
                    rowAction CHAR(1)
                );

            DECLARE @Antimicrobials NVARCHAR(MAX) = NULL;

            SET @Antimicrobials =
            (
                SELECT idfAntimicrobialTherapy,
                       @idfHumanCase AS idfHumanCase,
                       datFirstAdministeredDate,
                       strAntimicrobialTherapyName,
                       strDosage,
                       rowAction
                FROM @OutbreakAntimicrobialTemp
                FOR JSON PATH
            );

            EXECUTE dbo.USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET @idfHumanCase,
                                                                  @Antimicrobials,
                                                                  @outbreakCall = 1,
                                                                  @User = @User;
        END

        If @VaccinationsParameters IS NOT NULL
        BEGIN
            DECLARE @VaccinationsParametersTemp TABLE
            (
                vaccinationID BIGINT NULL,
                humanDiseaseReportVaccinationUID BIGINT NULL,
                idfHumanCase BIGINT NULL,
                vaccinationName NVARCHAR(200) NULL,
                vaccinationDate DATETIME2 NULL,
                rowAction CHAR(1) NULL,
                intRowStatus INT NULL
            );

            INSERT INTO @VaccinationsParametersTemp
            SELECT *
            FROM
                OPENJSON(@VaccinationsParameters)
                WITH
                (
                    vaccinationID BIGINT,
                    humanDiseaseReportVaccinationUID BIGINT,
                    idfHumanCase BIGINT,
                    vaccinationName NVARCHAR(200),
                    vaccinationDate DATETIME2,
                    rowAction NVARCHAR(1),
                    intRowStatus INT
                );

            DECLARE @Vaccinations NVARCHAR(MAX) = NULL
            SET @Vaccinations =
            (
                SELECT vaccinationID,
                       humanDiseaseReportVaccinationUID,
                       @idfHumanCase AS idfHumanCase,
                       vaccinationName,
                       vaccinationDate,
                       rowAction,
                       intRowStatus
                FROM @VaccinationsParametersTemp
                FOR JSON PATH
            );

            EXECUTE dbo.USSP_HUMAN_DISEASE_VACCINATIONS_SET @idfHumanCase,
                                                            @Vaccinations,
                                                            @outbreakCall = 1,
                                                            @User = @User;
        END


        --set Samples for this idfHumanCase	
        If @SamplesParameters IS NOT NULL
        BEGIN
            EXECUTE dbo.USSP_OMM_HUMAN_SAMPLES_SET @idfHumanActual,
                                                   @idfHumanCase = @idfHumanCase,
                                                   @SamplesParameters = @SamplesParameters,
                                                   @User = @User,
                                                   @TestsParameters = @TestsParameters,
                                                   @idfsFinalDiagnosis = @idfsFinalDiagnosis;
        END

        -- update tlbHuman IF datDateofDeath is provided.
        IF @datDateofDeath IS NOT NULL
        BEGIN
            UPDATE dbo.tlbHuman
            SET datDateofDeath = @datDateofDeath
            WHERE idfHuman = @idfHuman;
        END

        IF @@TRANCOUNT > 0
            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT = 1
            ROLLBACK;

        THROW;
    END CATCH
END

