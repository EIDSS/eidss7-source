SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_HUM_HUMAN_DISEASE_SET
--
-- Description:	Insert or update a human disease report record.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name                  Date       Change Detail
-- --------------------- ---------- --------------------------------------------------------------
-- JWJ	                 04/03/2018 Added new param to end for ReportStatus
-- Harold Pryor          08/01/2018 Added new @DiseaseReportTypeID input paramenter
-- Harold Pryor          11/30/2018 Added new @blnClinicalDiagBasis, @blnLabDiagBasis, 
--                                  @blnEpiDiagBasis input parameters for Basis of Diagnosis and 
--                                  new @DateofClassification input parameter 
-- Harold Pryor          12/05/2018	Added new @StartDateofInvestigation input parameter. Corrected 
--                                  @idfSoughtCareFacility input parameter spelling.	
-- Harold Pryor          12/06/2018	Removed updating Primary Key column for tlbHumanCase update.
-- Harold Pryor          12/13/2018	Removed @VaccinationName and @VaccinationDate input 
--                                  paramenters
-- Harold Pryor          12/21/2018	Changed @Sample as tlbHdrMaterialGetListSPType and @Tests as 
--                                  tlbHdrTestGetListSPType parameters and replaced as NVARCHAR
-- Harold Pryor          12/27/2018	Changed @Sample parameter to @SampleParameters and changed 
--                                  parameter @Tests to @TestsParameters. 
-- Lamont Mitchell       01/02/2018	Changed @idfHumanCase from OutputParameter and added to 
--                                  select statement
-- Harold Pryor          01/04/2018	Added new input paramters @AntiviralTherapiesParameters and 
--                                  @VaccinationsParameters	
-- Lamont Mitchell       01/11/2019	Suppressed Result Sets in ALL STORED PROCS
-- Harold Pryor          01/21/2019	Added @ContactsParameters input parameter 
-- Harold Pryor          01/27/2019	Added @strSummaryNotes input parameter
-- Harold Pryor          02/10/2019	Added @idfEpiObservation and @idfCSObservation	input 
--                                  paremeters for Flex Forms integration. 
-- Harold Pryor          03/22/2019	Updated to include @idfHuman and @DiseaseID to call to 
--                                  USSP_HUMAN_DISEASE_SAMPLES_SET stored proc 
-- Harold Pryor          04/08/2019	Updated to include @idfHumanCaseRelatedTo imput parameter for 
--                                  Changed Diagnosis Human Disease Report functionality
-- Harold Pryor          04/09/2019	For Smart key generation reference data change for V7 updated 
--                                  call to USP_GBL_NextNumber using a V6 strDocumentName ('Human 
--                                  Case').  Input parameter and replaced with V7 trDocumentName 
--                                  ('Human Disease Report') input parameter value instead.  
-- Harold Pryor          04/28/2019 Updated to properly save contacts 
-- Harold Pryor          05/28/2019 Updated to include paramter @idfHuman in call to 
--                                  USSP_HUMAN_DISEASE_CONTACT_SET
-- Harold Pryor          06/04/2019 Updated to include @strEpidemiologistsName input parameter
-- Harold Pryor          06/05/2019 Updated to include @idfsNotCollectedReason input parameter 
-- Harold Pryor          06/18/2019 Updated to include @idfsGeoLocationType input parameter
-- Harold Pryor          06/19/2019 Updated to include @intElevation and @strForeignAddress input 
--                                  parameters
-- Harold Pryor          06/19/2019 Updated to include @intLocationDirection input parameter
-- Lamont Mitchell       04/21/2020	UPDATEd tlbGeolocation Output Parameter
-- Lamont Mitchell       06/07/2020	Modified adding Connected Human disease Report
-- Lamont Mitchell       08/04/2020 Added property @idfInvestigatedByPerson and modified insert 
--                                  and update statments to include parameter
-- Lamont Mitchell       08/04/2000	Added SITE ID Property
-- Lamont Mitchell       11/02/2020	Added strNotCollectedReason to property list and add and 
--                                  update
-- Mandar Kulkani        01/18/2022	Removed two input parameters for relative latitude and 
--                                  longitude
-- Minal Shah            01/24/2022	Added strLocalIdentifier to the request
-- Minal Shah            04/04/2022	Added Site Alert Notifications
-- Doug Albanese         04/19/2022	Added tag to denote refactoring to Location Hierarchy
-- Doug Albanese         05/24/2022	Added idfParentMonitoringSession to connect a human active 
--                                  surveillance session to a disease report
-- Mark Wilson           06/02/2022	Set @AuditUser = ISNULL(@AuditUser, '') to make sure no nulls
-- Mark Wilson           06/08/2022	Defined all parameters for USSP_GBL_SAMPLE_SET
-- Stephen Long          07/06/2022 Updates for site alerts to call new stored procedure.
-- Doug Albanese         07/18/2022	Add @ConnectedTestId, so that HDR can make the association, 
--                                  after obtaining the new idfHumanCase value.
-- Doug Albanese         09/12/2022 Linked up the "Monitoring Session ID" to Samples and Tests
-- Doug Albanese         10/17/2022	Corrected the "Connected Test" to update all records for the 
--                                  existing monitoring session that have the same person and 
--                                  disease combination
-- Leo Tracchia          10/21/2022 Fix for properly deleting tests for human disease report 
--                                  DevOps defect 5006
-- Stephen Long          11/17/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long          11/28/2022 Added data audit for vaccinations, contacts and geolocation.
-- Stephen Long          11/29/2022 Added data audit for disease report relationship and flex 
--                                  forms.
-- Stephen Long          12/01/2022 Added EIDSS object ID; smart key that represents the parent 
--                                  object.
-- Stephen Long          12/09/2022 Changed object type ID reference for human disease report, 
--                                  and added EIDSS object ID to samples, tests and test 
--                                  interpretations calls.
-- Stephen Long          02/03/2023 Changed to data audit call with strMainObject.
--
-- Testing Code:
-- EXEC USP_HUM_HUMAN_DISEASE_SET  NULL,  27, NULL,  '(new)',784050000000
-- ================================================================================================
CREATE or ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_DISEASE_SET]
(
    @LanguageID NVARCHAR(50),
    @idfHumanCase BIGINT = NULL,                          -- tlbHumanCase.idfHumanCase Primary Key
    @idfHumanCaseRelatedTo BIGINT = NULL,
    @idfHuman BIGINT = NULL,                              -- tlbHumanCase.idfHuman
    @idfHumanActual BIGINT,                               -- tlbHumanActual.idfHumanActual
    @strHumanCaseId NVARCHAR(200) = '(new)',
    @idfsFinalDiagnosis BIGINT,                           -- tlbhumancase.idfsTentativeDiagnosis/idfsFinalDiagnosis
    @datDateOfDiagnosis DATETIME = NULL,                  --tlbHumanCase.datTentativeDiagnosisDate/datFinalDiagnosisDate
    @datNotificationDate DATETIME = NULL,                 --tlbHumanCase.DatNotIFicationDate
    @idfsFinalState BIGINT = NULL,                        --tlbHumanCase.idfsFinalState
    @strLocalIdentifier NVARCHAR(200) = NULL,
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
    @strAntibioticComments NVARCHAR(MAX) = NULL,          -- tlbHumanCase.strClinicalNotes , or strSummaryNotes
    @idfsYNSpecIFicVaccinationAdministered BIGINT = NULL, --  tlbHumanCase.idfsYNSpecIFicVaccinationAdministered
    @idfInvestigatedByOffice BIGINT = NULL,               -- tlbHumanCase.idfInvestigatedByOffice 
    @StartDateofInvestigation DATETIME = NULL,            -- tlbHumanCase.datInvestigationStartDate
    @idfsYNRelatedToOutbreak BIGINT = NULL,               -- tlbHumanCase.idfsYNRelatedToOutbreak
    @idfOutbreak BIGINT = NULL,                           --idfOutbreak  
    @idfsYNExposureLocationKnown BIGINT = NULL,           --tlbHumanCase.idfsYNExposureLocationKnown
    @idfPointGeoLocation BIGINT = NULL,                   --tlbHumanCase.idfPointGeoLocation
    @datExposureDate DATETIME = NULL,                     -- tlbHumanCase.datExposureDate 
    @idfsGeoLocationType BIGINT = NULL,                   --tlbGeolocation.idfsGeoLocationType
    @strLocationDescription NVARCHAR(MAX) = NULL,         --tlbGeolocation.Description
    @idfsLocationCountry BIGINT = NULL,                   --tlbGeolocation.idfsCountry 
    @idfsLocationRegion BIGINT = NULL,                    --tlbGeolocation.idfsRegion
    @idfsLocationRayon BIGINT = NULL,                     --tlbGeolocation.idfsRayon
    @idfsLocationSettlement BIGINT = NULL,                --tlbGeolocation.idfsSettlement
    @intLocationLatitude FLOAT = NULL,                    --tlbGeolocation.Latittude
    @intLocationLongitude FLOAT = NULL,                   --tlbGeolocation.Longitude
    @intElevation BIGINT = NULL,                          --GISSettlement.intElevation
    @idfsLocationGroundType BIGINT = NULL,                --tlbGeolocation.GroundType
    @intLocationDistance FLOAT = NULL,                    --tlbGeolocation.Distance
    @intLocationDirection FLOAT = NULL,                   --tlbGeolocation.Alignment	
    @strForeignAddress NVARCHAR(MAX) = NULL,              --tlbGeolocation.strForeignAddress 
    @strNote NVARCHAR(MAX) = NULL,                        --tlbhumancase.strNote
    @idfsFinalCaseStatus BIGINT = NULL,                   --tlbHuanCase.idfsFinalCaseStatus 
    @idfsOutcome BIGINT = NULL,                           -- --tlbHumanCase.idfsOutcome 
    @datDateofDeath DATETIME = NULL,                      -- tlbHumanCase.datDateOfDeath 
    @idfsCaseProgressStatus BIGINT = 10109001,            --	tlbHumanCase.reportStatus, default = In-process
    @idfPersonEnteredBy BIGINT = NULL,
    @strClinicalNotes NVARCHAR(2000) = NULL,
    @idfsYNSpecimenCollected BIGINT = NULL,
    @idfsYNTestsConducted BIGINT = NULL,
    @DiseaseReportTypeID BIGINT = NULL,
    @blnClinicalDiagBasis BIT = NULL,
    @blnLabDiagBasis BIT = NULL,
    @blnEpiDiagBasis BIT = NULL,
    @DateofClassification DATETIME = NULL,
    @strSummaryNotes NVARCHAR(MAX) = NULL,
    @idfEpiObservation BIGINT = NULL,
    @idfCSObservation BIGINT = NULL,
    @idfInvestigatedByPerson BIGINT = NULL,
    @strEpidemiologistsName NVARCHAR(MAX) = NULL,
    @idfsNotCollectedReason BIGINT = NULL,
    @strNotCollectedReason NVARCHAR(200) = NULL,
    @SamplesParameters NVARCHAR(MAX) = NULL,
    @TestsParameters NVARCHAR(MAX) = NULL,
    @TestsInterpretationParameters NVARCHAR(MAX) = NULL,
    @AntiviralTherapiesParameters NVARCHAR(MAX) = NULL,
    @VaccinationsParameters NVARCHAR(MAX) = NULL,
    @ContactsParameters NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @idfsHumanAgeType BIGINT = NULL,
    @intPatientAge INT = NULL,
    @datCompletionPaperFormDate DATETIME = NULL,
    @RowStatus INT,
    @idfsSite BIGINT = NULL,
    @AuditUser NVARCHAR(100) = '',
    @idfParentMonitoringSession BIGINT = NULL,
    @ConnectedTestId BIGINT = NULL
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @RowID BIGINT = NULL,
        @RowAction NCHAR = NULL,
        @OrderNumber INT,
        @SampleID BIGINT,
        @SampleTypeID BIGINT = NULL,
        @HumanID BIGINT,
        @HumanMasterID BIGINT = NULL,
        @CollectedByPersonID BIGINT = NULL,
        @CollectedByOrganizationID BIGINT = NULL,
        @CollectionDate DATETIME = NULL,
        @SentDate DATETIME = NULL,
        @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
        @SampleStatusTypeID BIGINT = NULL,
        @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
        @SentToOrganizationID BIGINT = NULL,
        @ReadOnlyIndicator BIT = NULL,
        @AccessionDate DATETIME = NULL,
        @AccessionConditionTypeID BIGINT = NULL,
        @AccessionComment NVARCHAR(200) = NULL,
        @AccessionByPersonID BIGINT = NULL,
        @CurrentSiteID BIGINT = NULL,
        @TestID BIGINT,
        @TestNameTypeID BIGINT = NULL,
        @TestCategoryTypeID BIGINT = NULL,
        @TestResultTypeID BIGINT = NULL,
        @TestStatusTypeID BIGINT,
        @BatchTestID BIGINT = NULL,
        @TestNumber INT = NULL,
        @StartedDate DATETIME2 = NULL,
        @ResultDate DATETIME2 = NULL,
        @TestedByPersonID BIGINT = NULL,
        @TestedByOrganizationID BIGINT = NULL,
        @ResultEnteredByOrganizationID BIGINT = NULL,
        @ResultEnteredByPersonID BIGINT = NULL,
        @ValidatedByOrganizationID BIGINT = NULL,
        @ValidatedByPersonID BIGINT = NULL,
        @NonLaboratoryTestIndicator BIT,
        @ExternalTestIndicator BIT = NULL,
        @PerformedByOrganizationID BIGINT = NULL,
        @ReceivedDate DATETIME2 = NULL,
        @ContactPersonName NVARCHAR(200) = NULL,
        @TestHumanCaseID BIGINT = NULL,
        @TestInterpretationID BIGINT,
        @InterpretedStatusTypeID BIGINT = NULL,
        @InterpretedByOrganizationID BIGINT = NULL,
        @InterpretedByPersonID BIGINT = NULL,
        @TestingInterpretations BIGINT,
        @ValidatedStatusIndicator BIT = NULL,
        @ReportSessionCreatedIndicator BIT = NULL,
        @ValidatedComment NVARCHAR(200) = NULL,
        @InterpretedComment NVARCHAR(200) = NULL,
        @ValidatedDate DATETIME = NULL,
        @InterpretedDate DATETIME = NULL,
                                                                              -- Site alerts/notifications
        @EventId BIGINT,
        @EventTypeId BIGINT = NULL,
        @EventSiteId BIGINT = NULL,
        @EventObjectId BIGINT = NULL,
        @EventUserId BIGINT = NULL,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = NULL,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = NULL,
                                                                              -- End site alerts/notifications
        @MonitoringSessionActionID BIGINT,
        @ActionTypeID BIGINT,
        @ActionStatusTypeID BIGINT,
        @ActionDate DATETIME = NULL,
        @Comments NVARCHAR(500) = NULL,
        @DiseaseID BIGINT,
        @idfMonitoringSessionToDiagnosis BIGINT,
        @DateEntered DATETIME = GETDATE(),
        @idfMaterial BIGINT,
                                                                              -- Data audit
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectTypeID BIGINT = 10017078,                                      -- Human disease report
        @ObjectID BIGINT = @idfHumanCase,
        @ObjectTableID BIGINT = 75610000000,                                  -- tlbHumanCase
        @ObjectHumanDiseaseReportRelationshipTableID BIGINT = 53577790000000, -- HumanDiseaseReportRelationship
        @ObjectObservationTableID BIGINT = 75640000000;                       -- tlbObservation
-- End data audit
DECLARE @SamplesTemp TABLE
(
    SampleID BIGINT NOT NULL,
    SampleTypeID BIGINT NULL,
    SampleStatusTypeID BIGINT NULL,
    CollectionDate DATETIME2 NULL,
    CollectedByOrganizationID BIGINT NULL,
    CollectedByPersonID BIGINT NULL,
    SentDate DATETIME2 NULL,
    SentToOrganizationID BIGINT NULL,
    EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL,
    Comments NVARCHAR(200) NULL,
    SiteID BIGINT NOT NULL,
    CurrentSiteID BIGINT NULL,
    DiseaseID BIGINT NULL,
    ReadOnlyIndicator BIT NULL,
    HumanID BIGINT NULL,
    HumanMasterID BIGINT NULL,
    RowStatus INT NOT NULL,
    RowAction CHAR(1) NULL
);
DECLARE @TestsTemp TABLE
(
    TestID BIGINT NOT NULL,
    TestNameTypeID BIGINT NULL,
    TestCategoryTypeID BIGINT NULL,
    TestResultTypeID BIGINT NULL,
    TestStatusTypeID BIGINT NOT NULL,
    DiseaseID BIGINT NULL,
    SampleID BIGINT NULL,
    BatchTestID BIGINT NULL,
    ObservationID BIGINT NULL,
    TestNumber INT NULL,
    Comments NVARCHAR NULL,
    StartedDate DATETIME2 NULL,
    ResultDate DATETIME2 NULL,
    TestedByOrganizationID BIGINT NULL,
    TestedByPersonID BIGINT NULL,
    ResultEnteredByOrganizationID BIGINT NULL,
    ResultEnteredByPersonID BIGINT NULL,
    ValidatedByOrganizationID BIGINT NULL,
    ValidatedByPersonID BIGINT NULL,
    ReadOnlyIndicator BIT NOT NULL,
    NonLaboratoryTestIndicator BIT NOT NULL,
    ExternalTestIndicator BIT NULL,
    PerformedByOrganizationID BIGINT NULL,
    ReceivedDate DATETIME2 NULL,
    ContactPersonName NVARCHAR(200) NULL,
    RowStatus INT NOT NULL,
    RowAction CHAR(1) NULL
);
DECLARE @TestsInterpretationParametersTemp TABLE
(
    TestInterpretationID BIGINT NOT NULL,
    DiseaseID BIGINT NULL,
    InterpretedStatusTypeID BIGINT NULL,
    ValidatedByOrganizationID BIGINT NULL,
    ValidatedByPersonID BIGINT NULL,
    InterpretedByOrganizationID BIGINT NULL,
    InterpretedByPersonID BIGINT NULL,
    TestID BIGINT NOT NULL,
    ValidatedStatusIndicator BIT NULL,
    ReportSessionCreatedIndicator BIT NULL,
    ValidatedComment NVARCHAR(200) NULL,
    InterpretedComment NVARCHAR(200) NULL,
    ValidatedDate DATETIME NULL,
    InterpretedDate DATETIME NULL,
    ReadOnlyIndicator BIT NOT NULL,
    RowStatus INT NOT NULL,
    RowAction INT NULL
);
DECLARE @EventsTemp TABLE
(
    EventId BIGINT NOT NULL,
    EventTypeId BIGINT NULL,
    UserId BIGINT NULL,
    SiteId BIGINT NULL,
    LoginSiteId BIGINT NULL,
    ObjectId BIGINT NULL,
    DiseaseId BIGINT NULL,
    LocationId BIGINT NULL,
    InformationString NVARCHAR(MAX) NULL
);
DECLARE @HumanDiseaseReportBeforeEdit TABLE
(
    HumanDiseaseReportID BIGINT,
    HumanID BIGINT,
    FinalStateTypeID BIGINT,
    HospitalizationStatusTypeID BIGINT,
    HumanAgeTypeID BIGINT,
    AntimicrobialTherapyTypeID BIGINT,
    HospitalizationTypeID BIGINT,
    SpecimenCollectedTypeID BIGINT,
    RelatedToOutbreakTypeID BIGINT,
    OutcomeID BIGINT,
    TentativeDiagnosisID BIGINT,
    FinalDiagnosisID BIGINT,
    InitialCaseStatusTypeID BIGINT,
    FinalCaseStatusTypeID BIGINT,
    SentByOfficeID BIGINT,
    ReceivedByOfficeID BIGINT,
    InvestigatedByOfficeID BIGINT,
    PointGeoLocationID BIGINT,
    EpiObservationID BIGINT,
    CSObservationID BIGINT,
    DeduplicationResultCaseID BIGINT,
    NotificationDate DATETIME,
    CompletionPaperFormDate DATETIME,
    FirstSoughtCareDate DATETIME,
    ModificationDate DATETIME,
    HospitalizationDate DATETIME,
    FacilityLastVisitDate DATETIME,
    ExposureDate DATETIME,
    DischargeDate DATETIME,
    OnSetDate DATETIME,
    InvestigationStartDate DATETIME,
    TentativeDiagnosisDate DATETIME,
    FinalDiagnosisDate DATETIME,
    Note NVARCHAR(2000),
    CurrentLocation NVARCHAR(200),
    HospitalizationPlace NVARCHAR(200),
    LocalIdentifier NVARCHAR(200),
    SoughtCareFacility NVARCHAR(200),
    SentByFirstName NVARCHAR(200),
    SentByPatronymicName NVARCHAR(200),
    SentByLastName NVARCHAR(200),
    ReceivedByFirstName NVARCHAR(200),
    ReceivedByPatronymicName NVARCHAR(200),
    ReceivedByLastName NVARCHAR(200),
    EpidemiologistsName NVARCHAR(200),
    NotCollectedReason NVARCHAR(200),
    ClinicalDiagnosis NVARCHAR(200),
    ClinicalNotes NVARCHAR(2000),
    SummaryNotes NVARCHAR(2000),
    PatientAge INT,
    ClinicalDiagBasisIndicator BIT,
    LabDiagBasisIndicator BIT,
    EpiDiagBasisIndicator BIT,
    PersonEnteredByID BIGINT,
    SentByPersonID BIGINT,
    ReceivedByPersonID BIGINT,
    InvestigatedByPersonID BIGINT,
    TestsConductedTypeID BIGINT,
    SoughtCareFacilityID BIGINT,
    NonNotifiableDiagnosisID BIGINT,
    NotCollectedReasonTypeID BIGINT,
    OutbreakID BIGINT,
    EnteredDate DATETIME,
    CaseID NVARCHAR(200),
    CaseProgressStatusTypeID BIGINT,
    SampleNotes NVARCHAR(1000),
    OfflineCaseID UNIQUEIDENTIFIER,
    FinalCaseClassificationDate DATETIME,
    HospitalID BIGINT,
    RowStatus INT
);
DECLARE @HumanDiseaseReportAfterEdit TABLE
(
    HumanDiseaseReportID BIGINT,
    HumanID BIGINT,
    FinalStateTypeID BIGINT,
    HospitalizationStatusTypeID BIGINT,
    HumanAgeTypeID BIGINT,
    AntimicrobialTherapyTypeID BIGINT,
    HospitalizationTypeID BIGINT,
    SpecimenCollectedTypeID BIGINT,
    RelatedToOutbreakTypeID BIGINT,
    OutcomeID BIGINT,
    TentativeDiagnosisID BIGINT,
    FinalDiagnosisID BIGINT,
    InitialCaseStatusTypeID BIGINT,
    FinalCaseStatusTypeID BIGINT,
    SentByOfficeID BIGINT,
    ReceivedByOfficeID BIGINT,
    InvestigatedByOfficeID BIGINT,
    PointGeoLocationID BIGINT,
    EpiObservationID BIGINT,
    CSObservationID BIGINT,
    DeduplicationResultCaseID BIGINT,
    NotificationDate DATETIME,
    CompletionPaperFormDate DATETIME,
    FirstSoughtCareDate DATETIME,
    ModificationDate DATETIME,
    HospitalizationDate DATETIME,
    FacilityLastVisitDate DATETIME,
    ExposureDate DATETIME,
    DischargeDate DATETIME,
    OnSetDate DATETIME,
    InvestigationStartDate DATETIME,
    TentativeDiagnosisDate DATETIME,
    FinalDiagnosisDate DATETIME,
    Note NVARCHAR(2000),
    CurrentLocation NVARCHAR(200),
    HospitalizationPlace NVARCHAR(200),
    LocalIdentifier NVARCHAR(200),
    SoughtCareFacility NVARCHAR(200),
    SentByFirstName NVARCHAR(200),
    SentByPatronymicName NVARCHAR(200),
    SentByLastName NVARCHAR(200),
    ReceivedByFirstName NVARCHAR(200),
    ReceivedByPatronymicName NVARCHAR(200),
    ReceivedByLastName NVARCHAR(200),
    EpidemiologistsName NVARCHAR(200),
    NotCollectedReason NVARCHAR(200),
    ClinicalDiagnosis NVARCHAR(200),
    ClinicalNotes NVARCHAR(2000),
    SummaryNotes NVARCHAR(2000),
    PatientAge INT,
    ClinicalDiagBasisIndicator BIT,
    LabDiagBasisIndicator BIT,
    EpiDiagBasisIndicator BIT,
    PersonEnteredByID BIGINT,
    SentByPersonID BIGINT,
    ReceivedByPersonID BIGINT,
    InvestigatedByPersonID BIGINT,
    TestsConductedTypeID BIGINT,
    SoughtCareFacilityID BIGINT,
    NonNotifiableDiagnosisID BIGINT,
    NotCollectedReasonTypeID BIGINT,
    OutbreakID BIGINT,
    EnteredDate DATETIME,
    CaseID NVARCHAR(200),
    CaseProgressStatusTypeID BIGINT,
    SampleNotes NVARCHAR(1000),
    OfflineCaseID UNIQUEIDENTIFIER,
    FinalCaseClassificationDate DATETIME,
    HospitalID BIGINT,
    RowStatus INT
);
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200)
);
DECLARE @SuppressSelectHumanCase TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200)
);
DECLARE @SuppressSelectHuman TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200),
    idfHuman BIGINT
);
DECLARE @SuppressSelectGeoLocation TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200),
    GeoLocationID BIGINT
);
DECLARE @ActivityParameters TABLE
(
    ActivityParameterID BIGINT,
    AnswerValue SQL_VARIANT
);
BEGIN
    BEGIN TRY
        SET @AuditUser = ISNULL(@AuditUser, '');

        SET @SamplesParameters = REPLACE(@SamplesParameters, '"0001-01-01T00:00:00"', 'null')

        INSERT INTO @SamplesTemp
        SELECT *
        FROM
            OPENJSON(@SamplesParameters)
            WITH
            (
                SampleID BIGINT,
                SampleTypeID BIGINT,
                SampleStatusTypeID BIGINT,
                CollectionDate DATETIME2,
                CollectedByOrganizationID BIGINT,
                CollectedByPersonID BIGINT,
                SentDate DATETIME2,
                SentToOrganizationID BIGINT,
                EIDSSLocalOrFieldSampleID NVARCHAR(200),
                Comments NVARCHAR(200),
                SiteID BIGINT,
                CurrentSiteID BIGINT,
                DiseaseID BIGINT,
                ReadOnlyIndicator BIT,
                HumanID BIGINT,
                HumanMasterID BIGINT,
                RowStatus INT,
                RowAction CHAR(1)
            );

        SET @TestsParameters = REPLACE(@TestsParameters, '"0001-01-01T00:00:00"', 'null')

        INSERT INTO @TestsTemp
        SELECT *
        FROM
            OPENJSON(@TestsParameters)
            WITH
            (
                TestID BIGINT,
                TestNameTypeID BIGINT,
                TestCategoryTypeID BIGINT,
                TestResultTypeID BIGINT,
                TestStatusTypeID BIGINT,
                DiseaseID BIGINT,
                SampleID BIGINT,
                BatchTestID BIGINT,
                ObservationID BIGINT,
                TestNumber INT,
                Comments NVARCHAR(500),
                StartedDate DATETIME2,
                ResultDate DATETIME2,
                TestedByOrganizationID BIGINT,
                TestedByPersonID BIGINT,
                ResultEnteredByOrganizationID BIGINT,
                ResultEnteredByPersonID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                ReadOnlyIndicator BIT,
                NonLaboratoryTestIndicator BIT,
                ExternalTestIndicator BIT,
                PerformedByOrganizationID BIGINT,
                ReceivedDate DATETIME2,
                ContactPersonName NVARCHAR(200),
                RowStatus INT,
                RowAction CHAR(1)
            );

        INSERT INTO @TestsInterpretationParametersTemp
        SELECT *
        FROM
            OPENJSON(@TestsInterpretationParameters)
            WITH
            (
                TestInterpretationID BIGINT,
                DiseaseID BIGINT,
                InterpretedStatusTypeID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                InterpretedByOrganizationID BIGINT,
                InterpretedByPersonID BIGINT,
                TestID BIGINT,
                ValidatedStatusIndicator BIT,
                ReportSessionCreatedIndicator BIT,
                ValidatedComment NVARCHAR(200),
                InterpretedComment NVARCHAR(200),
                ValidatedDate DATETIME2,
                InterpretedDate DATETIME2,
                ReadOnlyIndicator BIT,
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @EventsTemp
        SELECT *
        FROM
            OPENJSON(@Events)
            WITH
            (
                EventId BIGINT,
                EventTypeId BIGINT,
                UserId BIGINT,
                SiteId BIGINT,
                LoginSiteId BIGINT,
                ObjectId BIGINT,
                DiseaseId BIGINT,
                LocationId BIGINT,
                InformationString NVARCHAR(MAX)
            );

        BEGIN TRANSACTION

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo;
        -- End data audit

        IF @idfHumanCase IS NULL
        BEGIN
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            -- Get next key value
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbHumanCase', @idfHumanCase OUTPUT;

            -- Create a string ID for the disease report
            IF LEFT(ISNULL(@strHumanCaseID, '(new'), 4) = '(new'
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NextNumber_GET 'Human Disease Report',
                                                @strHumanCaseID OUTPUT,
                                                NULL; --N'AS Session'
            END
        END
        ELSE
        BEGIN
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
        END

        -- Data audit
        INSERT INTO @SuppressSelect
        EXEC dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                              @AuditSiteID,
                                              @DataAuditEventTypeID,
                                              @ObjectTypeID,
                                              @idfHumanCase,
                                              @ObjectTableID,
                                              @strHumanCaseID,
                                              @DataAuditEventID OUTPUT;
        -- End data audit

        SET @DiseaseID = @idfsFinalDiagnosis;

        DECLARE @HumanDiseasereportRelnUID BIGINT,
                @COPYHUMANACTUALTOHUMAN_ReturnCode INT = 0;

        -- Create a human record from human actual if not already present
        IF @idfHumanActual IS NOT NULL -- AND @idfHumanCase IS  NULL
        BEGIN
            INSERT INTO @SuppressSelectHumanCase
            EXEC dbo.USSP_HUM_COPY_HUMAN_SET @idfHumanActual,
                                             @DataAuditEventID,
                                             @AuditUser,
                                             @idfHuman OUTPUT,
                                             @ReturnCode OUTPUT,
                                             @ReturnMessage OUTPUT;
            IF @ReturnCode <> 0
            BEGIN
                RETURN;
            END
        END

        --TODO: Needs to be refactored to use Hierarchy
        -- Insert or update geolocation record if any of the information is provided
        IF @idfsLocationGroundType IS NOT NULL
           OR @idfsGeoLocationType IS NOT NULL
           OR @idfsLocationCountry IS NOT NULL
           OR @idfsLocationRegion IS NOT NULL
           OR @idfsLocationRayon IS NOT NULL
           OR @idfsLocationSettlement IS NOT NULL
           OR @strLocationDescription IS NOT NULL
           OR @intLocationLatitude IS NOT NULL
           OR @intLocationLongitude IS NOT NULL
           OR @intLocationDistance IS NOT NULL
           OR @intLocationDirection IS NOT NULL
           OR @strForeignAddress IS NOT NULL
           OR @intElevation IS NOT NULL
        BEGIN
            -- Set geo location 
            IF @idfPointGeoLocation IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGeoLocation',
                                               @idfPointGeoLocation OUTPUT;
            END

            BEGIN
                INSERT INTO @SuppressSelectGeoLocation
                EXEC dbo.USSP_HUM_DISEASE_GEOLOCATION_SET @idfPointGeoLocation,
                                                          @idfsLocationGroundType,
                                                          @idfsGeoLocationType,
                                                          @idfsLocationCountry,
                                                          @idfsLocationRegion,
                                                          @idfsLocationRayon,
                                                          @idfsLocationSettlement,
                                                          @strLocationDescription,
                                                          @intLocationLatitude,
                                                          @intLocationLongitude,
                                                          NULL,
                                                          @intLocationDistance,
                                                          @intLocationDirection,
                                                          @strForeignAddress,
                                                          1,
                                                          @intElevation,
                                                          @AuditUser,
                                                          @DataAuditEventID, 
                                                          @strHumanCaseID;
            END
        END

        IF NOT EXISTS
        (
            SELECT idfHumanCase
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase
                  AND intRowStatus = 0
        )
        BEGIN
            INSERT INTO dbo.tlbHumanCase
            (
                idfHumanCase,
                idfHuman,
                strCaseId,
                idfsFinalDiagnosis,
                datTentativeDiagnosisDate,
				datFinalDiagnosisDate,
                datNotIFicationDate,
                idfsFinalState,
                strLocalIdentifier,
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
                idfsYNSpecIFicVaccinationAdministered,
                idfInvestigatedByOffice,
                datInvestigationStartDate,
                idfsYNRelatedToOutbreak,
                idfOutbreak,
                idfPointGeoLocation,
                idfsYNExposureLocationKnown,
                datExposureDate,
                strNote,
                idfsFinalCaseStatus,
                idfsOutcome,
                intRowStatus,
                idfsCaseProgressStatus,
                datModificationDate,
                datEnteredDate,
                idfPersonEnteredBy,
                idfsYNSpecimenCollected,
                idfsYNTestsConducted,
                DiseaseReportTypeID,
                blnClinicalDiagBasis,
                blnLabDiagBasis,
                blnEpiDiagBasis,
                datFinalCaseClassificationDate,
                strsummarynotes,
                idfEpiObservation,
                idfCSObservation,
                idfInvestigatedByPerson,
                strEpidemiologistsName,
                idfsNotCollectedReason,
                strNotCollectedReason,
                idfsHumanAgeType,
                intPatientAge,
                datCompletionPaperFormDate,
                idfsSite,
                AuditCreateUser,
                idfParentMonitoringSession
            )
            VALUES
            (   @idfHumanCase,
                @idfHuman,
                @strHumanCaseId,
                @idfsFinalDiagnosis,
                @datDateOfDiagnosis,
                @datDateOfDiagnosis,
                @datNotificationDate,
                @idfsFinalState,
                @strLocalIdentifier,
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
                @idfsYNSpecIFicVaccinationAdministered,
                @idfInvestigatedByOffice,
                @StartDateofInvestigation,
                @idfsYNRelatedToOutbreak,
                @idfOutbreak,
                @idfPointGeoLocation,
                @idfsYNExposureLocationKnown,
                @datExposureDate,
                @strNote,
                @idfsFinalCaseStatus,
                @idfsOutcome,
                0,
                @idfsCaseProgressStatus,
                GETDATE(), --datModificationDate	
                GETDATE(), --datEnteredDate		
                @idfPersonEnteredBy,
                @idfsYNSpecimenCollected,
                @idfsYNTestsConducted,
                @DiseaseReportTypeID,
                @blnClinicalDiagBasis,
                @blnLabDiagBasis,
                @blnEpiDiagBasis,
                @DateofClassification,
                @strSummaryNotes,
                @idfEpiObservation,
                @idfCSObservation,
                @idfInvestigatedByPerson,
                @strEpidemiologistsName,
                @idfsNotCollectedReason,
                @strNotCollectedReason,
                @idfsHumanAgeType,
                @intPatientAge,
                @datCompletionPaperFormDate,
                @idfsSite,
                @AuditUser,
                @idfParentMonitoringSession
            );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser, 
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @idfHumanCase,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUser, 
             @strHumanCaseId
            );

            -- Update data audit event ID on tlbObservation and tlbActivityParameters
            -- for flexible forms saved outside this DB transaction.
            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @strHumanCaseId
            WHERE idfObject = @idfCSObservation
                  AND idfDataAuditEvent IS NULL;

            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @strHumanCaseId
            WHERE idfObject = @idfEpiObservation
                  AND idfDataAuditEvent IS NULL;

            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID, 
                strObject = @strHumanCaseId
            WHERE idfObjectDetail = @idfCSObservation
                  AND idfDataAuditEvent IS NULL;

            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @strHumanCaseId
            WHERE idfObjectDetail = @idfEpiObservation
                  AND idfDataAuditEvent IS NULL;
            -- End data audit

            DECLARE @RelatedToRoot BIGINT;

            IF @idfHumanCaseRelatedTo IS NOT NULL
            BEGIN
                -- Establish the root
                IF NOT EXISTS
                (
                    SELECT *
                    FROM dbo.HumanDiseaseReportRelationship
                    WHERE (HumanDiseaseReportID = @idfHumanCaseRelatedTo)
                          AND (RelatedToHumanDiseaseReportIdRoot IS NOT NULL)
                          AND (intRowStatus = 0)
                )
                BEGIN
                    SET @RelatedToRoot = @idfHumanCaseRelatedTo;
                END
                ELSE
                BEGIN
                    SELECT @RelatedToRoot = RelatedToHumanDiseaseReportIdRoot
                    FROM dbo.HumanDiseaseReportRelationship
                    WHERE (HumanDiseaseReportID = @idfHumanCaseRelatedTo)
                          AND (RelatedToHumanDiseaseReportIdRoot IS NOT NULL)
                          AND (intRowStatus = 0);
                END
                -- End establishing the root

                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'HumanDiseaseReportRelationship',
                                               @HumanDiseasereportRelnUID OUTPUT;

                INSERT INTO dbo.HumanDiseaseReportRelationship
                (
                    HumanDiseasereportRelnUID,
                    HumanDiseaseReportID,
                    RelateToHumanDiseaseReportID,
                    RelatedToHumanDiseaseReportIdRoot,
                    RelationshipTypeID,
                    intRowStatus,
                    AuditCreateUser,
                    AuditCreateDTM,
                    rowguid
                )
                VALUES
                (   @HumanDiseasereportRelnUID,
                    @idfHumanCase,
                    @idfHumanCaseRelatedTo,
                    @RelatedToRoot,
                    10503001, -- Linked Copy Parent
                    0,
                    @AuditUser,
                    GETDATE(),
                    NEWID()
                );

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailCreate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser, 
                    strObject
                )
                VALUES
                (@DataAuditEventID,
                 @ObjectHumanDiseaseReportRelationshipTableID,
                 @HumanDiseasereportRelnUID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectHumanDiseaseReportRelationshipTableID AS NVARCHAR(300)) + '}]',
                 @AuditUser, 
                 @strHumanCaseId
                );
            -- End data audit
            END
        END
        ELSE
        BEGIN
            INSERT INTO @HumanDiseaseReportBeforeEdit
            (
                HumanDiseaseReportID,
                HumanID,
                FinalStateTypeID,
                HospitalizationStatusTypeID,
                HumanAgeTypeID,
                AntimicrobialTherapyTypeID,
                HospitalizationTypeID,
                SpecimenCollectedTypeID,
                RelatedToOutbreakTypeID,
                OutcomeID,
                TentativeDiagnosisID,
                FinalDiagnosisID,
                InitialCaseStatusTypeID,
                FinalCaseStatusTypeID,
                SentByOfficeID,
                ReceivedByOfficeID,
                InvestigatedByOfficeID,
                PointGeoLocationID,
                EpiObservationID,
                CSObservationID,
                DeduplicationResultCaseID,
                NotificationDate,
                CompletionPaperFormDate,
                FirstSoughtCareDate,
                ModificationDate,
                HospitalizationDate,
                FacilityLastVisitDate,
                ExposureDate,
                DischargeDate,
                OnSetDate,
                InvestigationStartDate,
                TentativeDiagnosisDate,
                FinalDiagnosisDate,
                Note,
                CurrentLocation,
                HospitalizationPlace,
                LocalIdentifier,
                SoughtCareFacility,
                SentByFirstName,
                SentByPatronymicName,
                SentByLastName,
                ReceivedByFirstName,
                ReceivedByPatronymicName,
                ReceivedByLastName,
                EpidemiologistsName,
                NotCollectedReason,
                ClinicalDiagnosis,
                ClinicalNotes,
                SummaryNotes,
                PatientAge,
                ClinicalDiagBasisIndicator,
                LabDiagBasisIndicator,
                EpiDiagBasisIndicator,
                PersonEnteredByID,
                SentByPersonID,
                ReceivedByPersonID,
                InvestigatedByPersonID,
                TestsConductedTypeID,
                SoughtCareFacilityID,
                NonNotifiableDiagnosisID,
                NotCollectedReasonTypeID,
                OutbreakID,
                EnteredDate,
                CaseID,
                CaseProgressStatusTypeID,
                SampleNotes,
                OfflineCaseID,
                FinalCaseClassificationDate,
                HospitalID,
                RowStatus
            )
            SELECT idfHumanCase,
                   idfHuman,
                   idfsFinalState,
                   idfsHospitalizationStatus,
                   idfsHumanAgeType,
                   idfsYNAntimicrobialTherapy,
                   idfsYNHospitalization,
                   idfsYNSpecimenCollected,
                   idfsYNRelatedToOutbreak,
                   idfsOutcome,
                   idfsTentativeDiagnosis,
                   idfsFinalDiagnosis,
                   idfsInitialCaseStatus,
                   idfsFinalCaseStatus,
                   idfSentByOffice,
                   idfReceivedByOffice,
                   idfInvestigatedByOffice,
                   idfPointGeoLocation,
                   idfEpiObservation,
                   idfCSObservation,
                   idfDeduplicationResultCase,
                   datNotificationDate,
                   datCompletionPaperFormDate,
                   datFirstSoughtCareDate,
                   datModificationDate,
                   datHospitalizationDate,
                   datFacilityLastVisit,
                   datExposureDate,
                   datDischargeDate,
                   datOnSetDate,
                   datInvestigationStartDate,
                   datTentativeDiagnosisDate,
                   datFinalDiagnosisDate,
                   strNote,
                   strCurrentLocation,
                   strHospitalizationPlace,
                   strLocalIdentifier,
                   strSoughtCareFacility,
                   strSentByFirstName,
                   strSentByPatronymicName,
                   strSentByLastName,
                   strReceivedByFirstName,
                   strReceivedByPatronymicName,
                   strReceivedByLastName,
                   strEpidemiologistsName,
                   strNotCollectedReason,
                   strClinicalDiagnosis,
                   strClinicalNotes,
                   strSummaryNotes,
                   intPatientAge,
                   blnClinicalDiagBasis,
                   blnLabDiagBasis,
                   blnEpiDiagBasis,
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
                   idfHospital,
                   intRowStatus
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;

            UPDATE dbo.tlbHumanCase
            SET strCaseId = @strHumanCaseId,
                idfsTentativeDiagnosis = @idfsFinalDiagnosis,
                idfsFinalDiagnosis = @idfsFinalDiagnosis,
                datTentativeDiagnosisDate = @datDateOfDiagnosis,
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
                strLocalIdentifier = @strLocalIdentifier,
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
                idfsYNSpecIFicVaccinationAdministered = @idfsYNSpecIFicVaccinationAdministered,
                idfInvestigatedByOffice = @idfInvestigatedByOffice,
                datInvestigationStartDate = @StartDateofInvestigation,
                idfsYNRelatedToOutbreak = @idfsYNRelatedToOutbreak,
                idfOutbreak = @idfOutbreak,
                idfsYNExposureLocationKnown = @idfsYNExposureLocationKnown,
                idfPointGeoLocation = @idfPointGeoLocation,
                datExposureDate = @datExposureDate,
                strNote = @strNote,
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
                strEpidemiologistsName = @strEpidemiologistsName,
                idfsNotCollectedReason = @idfsNotCollectedReason,
                strNotCollectedReason = @strNotCollectedReason,
                idfsHumanAgeType = @idfsHumanAgeType,
                intPatientAge = @intPatientAge,
                datCompletionPaperFormDate = @datCompletionPaperFormDate,
                idfInvestigatedByPerson = @idfInvestigatedByPerson,
                idfPersonEnteredBy = @idfPersonEnteredBy,
                idfsSite = @idfsSite,
                AuditUpdateUser = @AuditUser,
                idfParentMonitoringSession = @idfParentMonitoringSession
            WHERE idfHumanCase = @idfHumanCase
                  AND intRowStatus = 0;

            INSERT INTO @HumanDiseaseReportAfterEdit
            (
                HumanDiseaseReportID,
                HumanID,
                FinalStateTypeID,
                HospitalizationStatusTypeID,
                HumanAgeTypeID,
                AntimicrobialTherapyTypeID,
                HospitalizationTypeID,
                SpecimenCollectedTypeID,
                RelatedToOutbreakTypeID,
                OutcomeID,
                TentativeDiagnosisID,
                FinalDiagnosisID,
                InitialCaseStatusTypeID,
                FinalCaseStatusTypeID,
                SentByOfficeID,
                ReceivedByOfficeID,
                InvestigatedByOfficeID,
                PointGeoLocationID,
                EpiObservationID,
                CSObservationID,
                DeduplicationResultCaseID,
                NotificationDate,
                CompletionPaperFormDate,
                FirstSoughtCareDate,
                ModificationDate,
                HospitalizationDate,
                FacilityLastVisitDate,
                ExposureDate,
                DischargeDate,
                OnSetDate,
                InvestigationStartDate,
                TentativeDiagnosisDate,
                FinalDiagnosisDate,
                Note,
                CurrentLocation,
                HospitalizationPlace,
                LocalIdentifier,
                SoughtCareFacility,
                SentByFirstName,
                SentByPatronymicName,
                SentByLastName,
                ReceivedByFirstName,
                ReceivedByPatronymicName,
                ReceivedByLastName,
                EpidemiologistsName,
                NotCollectedReason,
                ClinicalDiagnosis,
                ClinicalNotes,
                SummaryNotes,
                PatientAge,
                ClinicalDiagBasisIndicator,
                LabDiagBasisIndicator,
                EpiDiagBasisIndicator,
                PersonEnteredByID,
                SentByPersonID,
                ReceivedByPersonID,
                InvestigatedByPersonID,
                TestsConductedTypeID,
                SoughtCareFacilityID,
                NonNotifiableDiagnosisID,
                NotCollectedReasonTypeID,
                OutbreakID,
                EnteredDate,
                CaseID,
                CaseProgressStatusTypeID,
                SampleNotes,
                OfflineCaseID,
                FinalCaseClassificationDate,
                HospitalID,
                RowStatus
            )
            SELECT idfHumanCase,
                   idfHuman,
                   idfsFinalState,
                   idfsHospitalizationStatus,
                   idfsHumanAgeType,
                   idfsYNAntimicrobialTherapy,
                   idfsYNHospitalization,
                   idfsYNSpecimenCollected,
                   idfsYNRelatedToOutbreak,
                   idfsOutcome,
                   idfsTentativeDiagnosis,
                   idfsFinalDiagnosis,
                   idfsInitialCaseStatus,
                   idfsFinalCaseStatus,
                   idfSentByOffice,
                   idfReceivedByOffice,
                   idfInvestigatedByOffice,
                   idfPointGeoLocation,
                   idfEpiObservation,
                   idfCSObservation,
                   idfDeduplicationResultCase,
                   datNotificationDate,
                   datCompletionPaperFormDate,
                   datFirstSoughtCareDate,
                   datModificationDate,
                   datHospitalizationDate,
                   datFacilityLastVisit,
                   datExposureDate,
                   datDischargeDate,
                   datOnSetDate,
                   datInvestigationStartDate,
                   datTentativeDiagnosisDate,
                   datFinalDiagnosisDate,
                   strNote,
                   strCurrentLocation,
                   strHospitalizationPlace,
                   strLocalIdentifier,
                   strSoughtCareFacility,
                   strSentByFirstName,
                   strSentByPatronymicName,
                   strSentByLastName,
                   strReceivedByFirstName,
                   strReceivedByPatronymicName,
                   strReceivedByLastName,
                   strEpidemiologistsName,
                   strNotCollectedReason,
                   strClinicalDiagnosis,
                   strClinicalNotes,
                   strSummaryNotes,
                   intPatientAge,
                   blnClinicalDiagBasis,
                   blnLabDiagBasis,
                   blnEpiDiagBasis,
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
                   idfHospital,
                   intRowStatus
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;

            -- Data audit 
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser
            )
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   4577900000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HumanID,
                   a.HumanID,
                   @AuditUser
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HumanID <> b.HumanID)
                  OR (
                         a.HumanID IS NOT NULL
                         AND b.HumanID IS NULL
                     )
                  OR (
                         a.HumanID IS NULL
                         AND b.HumanID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79670000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FinalStateTypeID,
                   a.FinalStateTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FinalStateTypeID <> b.FinalStateTypeID)
                  OR (
                         a.FinalStateTypeID IS NOT NULL
                         AND b.FinalStateTypeID IS NULL
                     )
                  OR (
                         a.FinalStateTypeID IS NULL
                         AND b.FinalStateTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79680000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HospitalizationStatusTypeID,
                   a.HospitalizationStatusTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HospitalizationStatusTypeID <> b.HospitalizationStatusTypeID)
                  OR (
                         a.HospitalizationStatusTypeID IS NOT NULL
                         AND b.HospitalizationStatusTypeID IS NULL
                     )
                  OR (
                         a.HospitalizationStatusTypeID IS NULL
                         AND b.HospitalizationStatusTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79690000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HumanAgeTypeID,
                   a.HumanAgeTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HumanAgeTypeID <> b.HumanAgeTypeID)
                  OR (
                         a.HumanAgeTypeID IS NOT NULL
                         AND b.HumanAgeTypeID IS NULL
                     )
                  OR (
                         a.HumanAgeTypeID IS NULL
                         AND b.HumanAgeTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79730000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.AntimicrobialTherapyTypeID,
                   a.AntimicrobialTherapyTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.AntimicrobialTherapyTypeID <> b.AntimicrobialTherapyTypeID)
                  OR (
                         a.AntimicrobialTherapyTypeID IS NOT NULL
                         AND b.AntimicrobialTherapyTypeID IS NULL
                     )
                  OR (
                         a.AntimicrobialTherapyTypeID IS NULL
                         AND b.AntimicrobialTherapyTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79740000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HospitalizationTypeID,
                   a.HospitalizationTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HospitalizationTypeID <> b.HospitalizationTypeID)
                  OR (
                         a.HospitalizationTypeID IS NOT NULL
                         AND b.HospitalizationTypeID IS NULL
                     )
                  OR (
                         a.HospitalizationTypeID IS NULL
                         AND b.HospitalizationTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79760000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SpecimenCollectedTypeID,
                   a.SpecimenCollectedTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SpecimenCollectedTypeID <> b.SpecimenCollectedTypeID)
                  OR (
                         a.SpecimenCollectedTypeID IS NOT NULL
                         AND b.SpecimenCollectedTypeID IS NULL
                     )
                  OR (
                         a.SpecimenCollectedTypeID IS NULL
                         AND b.SpecimenCollectedTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79750000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.RelatedToOutbreakTypeID,
                   a.RelatedToOutbreakTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.RelatedToOutbreakTypeID <> b.RelatedToOutbreakTypeID)
                  OR (
                         a.RelatedToOutbreakTypeID IS NOT NULL
                         AND b.RelatedToOutbreakTypeID IS NULL
                     )
                  OR (
                         a.RelatedToOutbreakTypeID IS NULL
                         AND b.RelatedToOutbreakTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79710000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.OutcomeID,
                   a.OutcomeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.OutcomeID <> b.OutcomeID)
                  OR (
                         a.OutcomeID IS NOT NULL
                         AND b.OutcomeID IS NULL
                     )
                  OR (
                         a.OutcomeID IS NULL
                         AND b.OutcomeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79720000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.TentativeDiagnosisID,
                   a.TentativeDiagnosisID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.TentativeDiagnosisID <> b.TentativeDiagnosisID)
                  OR (
                         a.TentativeDiagnosisID IS NOT NULL
                         AND b.TentativeDiagnosisID IS NULL
                     )
                  OR (
                         a.TentativeDiagnosisID IS NULL
                         AND b.TentativeDiagnosisID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79660000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FinalDiagnosisID,
                   a.FinalDiagnosisID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FinalDiagnosisID <> b.FinalDiagnosisID)
                  OR (
                         a.FinalDiagnosisID IS NOT NULL
                         AND b.FinalDiagnosisID IS NULL
                     )
                  OR (
                         a.FinalDiagnosisID IS NULL
                         AND b.FinalDiagnosisID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79700000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.InitialCaseStatusTypeID,
                   a.InitialCaseStatusTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.InitialCaseStatusTypeID <> b.InitialCaseStatusTypeID)
                  OR (
                         a.InitialCaseStatusTypeID IS NOT NULL
                         AND b.InitialCaseStatusTypeID IS NULL
                     )
                  OR (
                         a.InitialCaseStatusTypeID IS NULL
                         AND b.InitialCaseStatusTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855690000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FinalCaseStatusTypeID,
                   a.FinalCaseStatusTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FinalCaseStatusTypeID <> b.FinalCaseStatusTypeID)
                  OR (
                         a.FinalCaseStatusTypeID IS NOT NULL
                         AND b.FinalCaseStatusTypeID IS NULL
                     )
                  OR (
                         a.FinalCaseStatusTypeID IS NULL
                         AND b.FinalCaseStatusTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855700000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SentByOfficeID,
                   a.SentByOfficeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SentByOfficeID <> b.SentByOfficeID)
                  OR (
                         a.SentByOfficeID IS NOT NULL
                         AND b.SentByOfficeID IS NULL
                     )
                  OR (
                         a.SentByOfficeID IS NULL
                         AND b.SentByOfficeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79640000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ReceivedByOfficeID,
                   a.ReceivedByOfficeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ReceivedByOfficeID <> b.ReceivedByOfficeID)
                  OR (
                         a.ReceivedByOfficeID IS NOT NULL
                         AND b.ReceivedByOfficeID IS NULL
                     )
                  OR (
                         a.ReceivedByOfficeID IS NULL
                         AND b.ReceivedByOfficeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79620000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.InvestigatedByOfficeID,
                   a.InvestigatedByOfficeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.InvestigatedByOfficeID <> b.InvestigatedByOfficeID)
                  OR (
                         a.InvestigatedByOfficeID IS NOT NULL
                         AND b.InvestigatedByOfficeID IS NULL
                     )
                  OR (
                         a.InvestigatedByOfficeID IS NULL
                         AND b.InvestigatedByOfficeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79630000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.PointGeoLocationID,
                   a.PointGeoLocationID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.PointGeoLocationID <> b.PointGeoLocationID)
                  OR (
                         a.PointGeoLocationID IS NOT NULL
                         AND b.PointGeoLocationID IS NULL
                     )
                  OR (
                         a.PointGeoLocationID IS NULL
                         AND b.PointGeoLocationID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855710000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.EpiObservationID,
                   a.EpiObservationID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.EpiObservationID <> b.EpiObservationID)
                  OR (
                         a.EpiObservationID IS NOT NULL
                         AND b.EpiObservationID IS NULL
                     )
                  OR (
                         a.EpiObservationID IS NULL
                         AND b.EpiObservationID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855720000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.CSObservationID,
                   a.CSObservationID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.CSObservationID <> b.CSObservationID)
                  OR (
                         a.CSObservationID IS NOT NULL
                         AND b.CSObservationID IS NULL
                     )
                  OR (
                         a.CSObservationID IS NULL
                         AND b.CSObservationID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855730000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.DeduplicationResultCaseID,
                   a.DeduplicationResultCaseID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.DeduplicationResultCaseID <> b.DeduplicationResultCaseID)
                  OR (
                         a.DeduplicationResultCaseID IS NOT NULL
                         AND b.DeduplicationResultCaseID IS NULL
                     )
                  OR (
                         a.DeduplicationResultCaseID IS NULL
                         AND b.DeduplicationResultCaseID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855740000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.NotificationDate,
                   a.NotificationDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.NotificationDate <> b.NotificationDate)
                  OR (
                         a.NotificationDate IS NOT NULL
                         AND b.NotificationDate IS NULL
                     )
                  OR (
                         a.NotificationDate IS NULL
                         AND b.NotificationDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79520000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.CompletionPaperFormDate,
                   a.CompletionPaperFormDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.CompletionPaperFormDate <> b.CompletionPaperFormDate)
                  OR (
                         a.CompletionPaperFormDate IS NOT NULL
                         AND b.CompletionPaperFormDate IS NULL
                     )
                  OR (
                         a.CompletionPaperFormDate IS NULL
                         AND b.CompletionPaperFormDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855750000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FirstSoughtCareDate,
                   a.FirstSoughtCareDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FirstSoughtCareDate <> b.FirstSoughtCareDate)
                  OR (
                         a.FirstSoughtCareDate IS NOT NULL
                         AND b.FirstSoughtCareDate IS NULL
                     )
                  OR (
                         a.FirstSoughtCareDate IS NULL
                         AND b.FirstSoughtCareDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79590000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ModificationDate,
                   a.ModificationDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ModificationDate <> b.ModificationDate)
                  OR (
                         a.ModificationDate IS NOT NULL
                         AND b.ModificationDate IS NULL
                     )
                  OR (
                         a.ModificationDate IS NULL
                         AND b.ModificationDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79570000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HospitalizationDate,
                   a.HospitalizationDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HospitalizationDate <> b.HospitalizationDate)
                  OR (
                         a.HospitalizationDate IS NOT NULL
                         AND b.HospitalizationDate IS NULL
                     )
                  OR (
                         a.HospitalizationDate IS NULL
                         AND b.HospitalizationDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79550000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FacilityLastVisitDate,
                   a.FacilityLastVisitDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FacilityLastVisitDate <> b.FacilityLastVisitDate)
                  OR (
                         a.FacilityLastVisitDate IS NOT NULL
                         AND b.FacilityLastVisitDate IS NULL
                     )
                  OR (
                         a.FacilityLastVisitDate IS NULL
                         AND b.FacilityLastVisitDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79540000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ExposureDate,
                   a.ExposureDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ExposureDate <> b.ExposureDate)
                  OR (
                         a.ExposureDate IS NOT NULL
                         AND b.ExposureDate IS NULL
                     )
                  OR (
                         a.ExposureDate IS NULL
                         AND b.ExposureDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79530000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.DischargeDate,
                   a.DischargeDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.DischargeDate <> b.DischargeDate)
                  OR (
                         a.DischargeDate IS NOT NULL
                         AND b.DischargeDate IS NULL
                     )
                  OR (
                         a.DischargeDate IS NULL
                         AND b.DischargeDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855760000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.OnSetDate,
                   a.OnSetDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.OnSetDate <> b.OnSetDate)
                  OR (
                         a.OnSetDate IS NOT NULL
                         AND b.OnSetDate IS NULL
                     )
                  OR (
                         a.OnSetDate IS NULL
                         AND b.OnSetDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79580000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.InvestigationStartDate,
                   a.InvestigationStartDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.InvestigationStartDate <> b.InvestigationStartDate)
                  OR (
                         a.InvestigationStartDate IS NOT NULL
                         AND b.InvestigationStartDate IS NULL
                     )
                  OR (
                         a.InvestigationStartDate IS NULL
                         AND b.InvestigationStartDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79600000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.TentativeDiagnosisDate,
                   a.TentativeDiagnosisDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.TentativeDiagnosisDate <> b.TentativeDiagnosisDate)
                  OR (
                         a.TentativeDiagnosisDate IS NOT NULL
                         AND b.TentativeDiagnosisDate IS NULL
                     )
                  OR (
                         a.TentativeDiagnosisDate IS NULL
                         AND b.TentativeDiagnosisDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79560000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FinalDiagnosisDate,
                   a.FinalDiagnosisDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FinalDiagnosisDate <> b.FinalDiagnosisDate)
                  OR (
                         a.FinalDiagnosisDate IS NOT NULL
                         AND b.FinalDiagnosisDate IS NULL
                     )
                  OR (
                         a.FinalDiagnosisDate IS NULL
                         AND b.FinalDiagnosisDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79840000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.Note,
                   a.Note,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.Note <> b.Note)
                  OR (
                         a.Note IS NOT NULL
                         AND b.Note IS NULL
                     )
                  OR (
                         a.Note IS NULL
                         AND b.Note IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79790000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.CurrentLocation,
                   a.CurrentLocation,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.CurrentLocation <> b.CurrentLocation)
                  OR (
                         a.CurrentLocation IS NOT NULL
                         AND b.CurrentLocation IS NULL
                     )
                  OR (
                         a.CurrentLocation IS NULL
                         AND b.CurrentLocation IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79810000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HospitalizationPlace,
                   a.HospitalizationPlace,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HospitalizationPlace <> b.HospitalizationPlace)
                  OR (
                         a.HospitalizationPlace IS NOT NULL
                         AND b.HospitalizationPlace IS NULL
                     )
                  OR (
                         a.HospitalizationPlace IS NULL
                         AND b.HospitalizationPlace IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79820000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.LocalIdentifier,
                   a.LocalIdentifier,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.LocalIdentifier <> b.LocalIdentifier)
                  OR (
                         a.LocalIdentifier IS NOT NULL
                         AND b.LocalIdentifier IS NULL
                     )
                  OR (
                         a.LocalIdentifier IS NULL
                         AND b.LocalIdentifier IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79910000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SoughtCareFacility,
                   a.SoughtCareFacility,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SoughtCareFacility <> b.SoughtCareFacility)
                  OR (
                         a.SoughtCareFacility IS NOT NULL
                         AND b.SoughtCareFacility IS NULL
                     )
                  OR (
                         a.SoughtCareFacility IS NULL
                         AND b.SoughtCareFacility IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79880000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SentByFirstName,
                   a.SentByFirstName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SentByFirstName <> b.SentByFirstName)
                  OR (
                         a.SentByFirstName IS NOT NULL
                         AND b.SentByFirstName IS NULL
                     )
                  OR (
                         a.SentByFirstName IS NULL
                         AND b.SentByFirstName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79900000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SentByPatronymicName,
                   a.SentByPatronymicName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SentByPatronymicName <> b.SentByPatronymicName)
                  OR (
                         a.SentByPatronymicName IS NOT NULL
                         AND b.SentByPatronymicName IS NULL
                     )
                  OR (
                         a.SentByPatronymicName IS NULL
                         AND b.SentByPatronymicName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79890000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SentByLastName,
                   a.SentByLastName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SentByLastName <> b.SentByLastName)
                  OR (
                         a.SentByLastName IS NOT NULL
                         AND b.SentByLastName IS NULL
                     )
                  OR (
                         a.SentByLastName IS NULL
                         AND b.SentByLastName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79850000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ReceivedByFirstName,
                   a.ReceivedByFirstName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ReceivedByFirstName <> b.ReceivedByFirstName)
                  OR (
                         a.ReceivedByFirstName IS NOT NULL
                         AND b.ReceivedByFirstName IS NULL
                     )
                  OR (
                         a.ReceivedByFirstName IS NULL
                         AND b.ReceivedByFirstName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79870000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ReceivedByPatronymicName,
                   a.ReceivedByPatronymicName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ReceivedByPatronymicName <> b.ReceivedByPatronymicName)
                  OR (
                         a.ReceivedByPatronymicName IS NOT NULL
                         AND b.ReceivedByPatronymicName IS NULL
                     )
                  OR (
                         a.ReceivedByPatronymicName IS NULL
                         AND b.ReceivedByPatronymicName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79860000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ReceivedByLastName,
                   a.ReceivedByLastName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ReceivedByLastName <> b.ReceivedByLastName)
                  OR (
                         a.ReceivedByLastName IS NOT NULL
                         AND b.ReceivedByLastName IS NULL
                     )
                  OR (
                         a.ReceivedByLastName IS NULL
                         AND b.ReceivedByLastName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79800000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.EpidemiologistsName,
                   a.EpidemiologistsName,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.EpidemiologistsName <> b.EpidemiologistsName)
                  OR (
                         a.EpidemiologistsName IS NOT NULL
                         AND b.EpidemiologistsName IS NULL
                     )
                  OR (
                         a.EpidemiologistsName IS NULL
                         AND b.EpidemiologistsName IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79830000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.NotCollectedReason,
                   a.NotCollectedReason,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.NotCollectedReason <> b.NotCollectedReason)
                  OR (
                         a.NotCollectedReason IS NOT NULL
                         AND b.NotCollectedReason IS NULL
                     )
                  OR (
                         a.NotCollectedReason IS NULL
                         AND b.NotCollectedReason IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79780000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ClinicalDiagnosis,
                   a.ClinicalDiagnosis,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ClinicalDiagnosis <> b.ClinicalDiagnosis)
                  OR (
                         a.ClinicalDiagnosis IS NOT NULL
                         AND b.ClinicalDiagnosis IS NULL
                     )
                  OR (
                         a.ClinicalDiagnosis IS NULL
                         AND b.ClinicalDiagnosis IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855770000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ClinicalNotes,
                   a.ClinicalNotes,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ClinicalNotes <> b.ClinicalNotes)
                  OR (
                         a.ClinicalNotes IS NOT NULL
                         AND b.ClinicalNotes IS NULL
                     )
                  OR (
                         a.ClinicalNotes IS NULL
                         AND b.ClinicalNotes IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   855780000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SummaryNotes,
                   a.SummaryNotes,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SummaryNotes <> b.SummaryNotes)
                  OR (
                         a.SummaryNotes IS NOT NULL
                         AND b.SummaryNotes IS NULL
                     )
                  OR (
                         a.SummaryNotes IS NULL
                         AND b.SummaryNotes IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79770000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.PatientAge,
                   a.PatientAge,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.PatientAge <> b.PatientAge)
                  OR (
                         a.PatientAge IS NOT NULL
                         AND b.PatientAge IS NULL
                     )
                  OR (
                         a.PatientAge IS NULL
                         AND b.PatientAge IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79490000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ClinicalDiagBasisIndicator,
                   a.ClinicalDiagBasisIndicator,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ClinicalDiagBasisIndicator <> b.ClinicalDiagBasisIndicator)
                  OR (
                         a.ClinicalDiagBasisIndicator IS NOT NULL
                         AND b.ClinicalDiagBasisIndicator IS NULL
                     )
                  OR (
                         a.ClinicalDiagBasisIndicator IS NULL
                         AND b.ClinicalDiagBasisIndicator IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79510000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.LabDiagBasisIndicator,
                   a.LabDiagBasisIndicator,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.LabDiagBasisIndicator <> b.LabDiagBasisIndicator)
                  OR (
                         a.LabDiagBasisIndicator IS NOT NULL
                         AND b.LabDiagBasisIndicator IS NULL
                     )
                  OR (
                         a.LabDiagBasisIndicator IS NULL
                         AND b.LabDiagBasisIndicator IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   79500000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.EpiDiagBasisIndicator,
                   a.EpiDiagBasisIndicator,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.EpiDiagBasisIndicator <> b.EpiDiagBasisIndicator)
                  OR (
                         a.EpiDiagBasisIndicator IS NOT NULL
                         AND b.EpiDiagBasisIndicator IS NULL
                     )
                  OR (
                         a.EpiDiagBasisIndicator IS NULL
                         AND b.EpiDiagBasisIndicator IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   4577910000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.PersonEnteredByID,
                   a.PersonEnteredByID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.PersonEnteredByID <> b.PersonEnteredByID)
                  OR (
                         a.PersonEnteredByID IS NOT NULL
                         AND b.PersonEnteredByID IS NULL
                     )
                  OR (
                         a.PersonEnteredByID IS NULL
                         AND b.PersonEnteredByID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   4578390000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SentByPersonID,
                   a.SentByPersonID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SentByPersonID <> b.SentByPersonID)
                  OR (
                         a.SentByPersonID IS NOT NULL
                         AND b.SentByPersonID IS NULL
                     )
                  OR (
                         a.SentByPersonID IS NULL
                         AND b.SentByPersonID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   4578400000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.ReceivedByPersonID,
                   a.ReceivedByPersonID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.ReceivedByPersonID <> b.ReceivedByPersonID)
                  OR (
                         a.ReceivedByPersonID IS NOT NULL
                         AND b.ReceivedByPersonID IS NULL
                     )
                  OR (
                         a.ReceivedByPersonID IS NULL
                         AND b.ReceivedByPersonID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   4578410000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.InvestigatedByPersonID,
                   a.InvestigatedByPersonID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.InvestigatedByPersonID <> b.InvestigatedByPersonID)
                  OR (
                         a.InvestigatedByPersonID IS NOT NULL
                         AND b.InvestigatedByPersonID IS NULL
                     )
                  OR (
                         a.InvestigatedByPersonID IS NULL
                         AND b.InvestigatedByPersonID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   4578420000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.TestsConductedTypeID,
                   a.TestsConductedTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.TestsConductedTypeID <> b.TestsConductedTypeID)
                  OR (
                         a.TestsConductedTypeID IS NOT NULL
                         AND b.TestsConductedTypeID IS NULL
                     )
                  OR (
                         a.TestsConductedTypeID IS NULL
                         AND b.TestsConductedTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12014650000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SoughtCareFacilityID,
                   a.SoughtCareFacilityID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SoughtCareFacilityID <> b.SoughtCareFacilityID)
                  OR (
                         a.SoughtCareFacilityID IS NOT NULL
                         AND b.SoughtCareFacilityID IS NULL
                     )
                  OR (
                         a.SoughtCareFacilityID IS NULL
                         AND b.SoughtCareFacilityID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12014660000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.NonNotifiableDiagnosisID,
                   a.NonNotifiableDiagnosisID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.NonNotifiableDiagnosisID <> b.NonNotifiableDiagnosisID)
                  OR (
                         a.NonNotifiableDiagnosisID IS NOT NULL
                         AND b.NonNotifiableDiagnosisID IS NULL
                     )
                  OR (
                         a.NonNotifiableDiagnosisID IS NULL
                         AND b.NonNotifiableDiagnosisID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12014670000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.NotCollectedReasonTypeID,
                   a.NotCollectedReasonTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.NotCollectedReasonTypeID <> b.NotCollectedReasonTypeID)
                  OR (
                         a.NotCollectedReasonTypeID IS NOT NULL
                         AND b.NotCollectedReasonTypeID IS NULL
                     )
                  OR (
                         a.NotCollectedReasonTypeID IS NULL
                         AND b.NotCollectedReasonTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12665410000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.OutbreakID,
                   a.OutbreakID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.OutbreakID <> b.OutbreakID)
                  OR (
                         a.OutbreakID IS NOT NULL
                         AND b.OutbreakID IS NULL
                     )
                  OR (
                         a.OutbreakID IS NULL
                         AND b.OutbreakID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12665420000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.EnteredDate,
                   a.EnteredDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.EnteredDate <> b.EnteredDate)
                  OR (
                         a.EnteredDate IS NOT NULL
                         AND b.EnteredDate IS NULL
                     )
                  OR (
                         a.EnteredDate IS NULL
                         AND b.EnteredDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12665430000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.CaseID,
                   a.CaseID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.CaseID <> b.CaseID)
                  OR (
                         a.CaseID IS NOT NULL
                         AND b.CaseID IS NULL
                     )
                  OR (
                         a.CaseID IS NULL
                         AND b.CaseID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12665440000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.CaseProgressStatusTypeID,
                   a.CaseProgressStatusTypeID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.CaseProgressStatusTypeID <> b.CaseProgressStatusTypeID)
                  OR (
                         a.CaseProgressStatusTypeID IS NOT NULL
                         AND b.CaseProgressStatusTypeID IS NULL
                     )
                  OR (
                         a.CaseProgressStatusTypeID IS NULL
                         AND b.CaseProgressStatusTypeID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12665450000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.SampleNotes,
                   a.SampleNotes,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.SampleNotes <> b.SampleNotes)
                  OR (
                         a.SampleNotes IS NOT NULL
                         AND b.SampleNotes IS NULL
                     )
                  OR (
                         a.SampleNotes IS NULL
                         AND b.SampleNotes IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   12665460000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.OfflineCaseID,
                   a.OfflineCaseID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.OfflineCaseID <> b.OfflineCaseID)
                  OR (
                         a.OfflineCaseID IS NOT NULL
                         AND b.OfflineCaseID IS NULL
                     )
                  OR (
                         a.OfflineCaseID IS NULL
                         AND b.OfflineCaseID IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   51389570000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.FinalCaseClassificationDate,
                   a.FinalCaseClassificationDate,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.FinalCaseClassificationDate <> b.FinalCaseClassificationDate)
                  OR (
                         a.FinalCaseClassificationDate IS NOT NULL
                         AND b.FinalCaseClassificationDate IS NULL
                     )
                  OR (
                         a.FinalCaseClassificationDate IS NULL
                         AND b.FinalCaseClassificationDate IS NOT NULL
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
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   51523420000000,
                   a.HumanDiseaseReportID,
                   NULL,
                   b.HospitalID,
                   a.HospitalID,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE (a.HospitalID <> b.HospitalID)
                  OR (
                         a.HospitalID IS NOT NULL
                         AND b.HospitalID IS NULL
                     )
                  OR (
                         a.HospitalID IS NULL
                         AND b.HospitalID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailRestore
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                idfObjectDetail,
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventId,
                   @ObjectTableID,
                   a.HumanDiseaseReportID,
                   NULL,
                   @AuditUser,
                   @strHumanCaseId
            FROM @HumanDiseaseReportAfterEdit AS a
                FULL JOIN @HumanDiseaseReportBeforeEdit AS b
                    ON a.HumanDiseaseReportID = b.HumanDiseaseReportID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;

            -- Update data audit event ID on tlbActivityParameters
            -- for flexible forms saved outside this DB transaction.
            UPDATE dbo.tauDataAuditDetailUpdate
            SET idfDataAuditEvent = @DataAuditEventID, 
                strObject = @strHumanCaseId 
            WHERE idfObjectDetail = @idfCSObservation
                  AND idfDataAuditEvent IS NULL;

            UPDATE dbo.tauDataAuditDetailUpdate
            SET idfDataAuditEvent = @DataAuditEventID, 
                strObject = @strHumanCaseId 
            WHERE idfObjectDetail = @idfEpiObservation
                  AND idfDataAuditEvent IS NULL;
        -- End data audit
        END

        -- Set samples
        IF @SamplesParameters IS NOT NULL
        BEGIN
            WHILE EXISTS (SELECT * FROM @SamplesTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = SampleID,
                    @SampleID = SampleID,
                    @SampleTypeID = SampleTypeID,
                    @CollectedByPersonID = CollectedByPersonID,
                    @CollectedByOrganizationID = CollectedByOrganizationID,
                    @CollectionDate = CAST(CollectionDate AS DATETIME),
                    @SentDate = CAST(SentDate AS DATETIME),
                    @EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
                    @SampleStatusTypeID = SampleStatusTypeID,
                    @Comments = Comments,
                    @idfsSite = SiteID,
                    @CurrentSiteID = CurrentSiteID,
                    @RowStatus = RowStatus,
                    @SentToOrganizationID = SentToOrganizationID,
                    @DiseaseID = DiseaseID,
                    @ReadOnlyIndicator = ReadOnlyIndicator,
                    @HumanID = HumanID,
                    @HumanMasterID = HumanMasterID,
                    @RowAction = RowAction
                FROM @SamplesTemp;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_SAMPLES_SET @AuditUserName = @AuditUser,
                                                 @DataAuditEventID = @DataAuditEventID,
                                                 @EIDSSObjectID = @strHumanCaseId,
                                                 @SampleID = @SampleID OUTPUT,
                                                 @SampleTypeID = @SampleTypeID,
                                                 @RootSampleID = NULL,
                                                 @ParentSampleID = NULL,
                                                 @HumanID = @idfHuman,
                                                 @SpeciesID = NULL,
                                                 @AnimalID = NULL,
                                                 @VectorID = NULL,
                                                 @MonitoringSessionID = @idfParentMonitoringSession,
                                                 @VectorSessionID = NULL,
                                                 @HumanDiseaseReportID = @idfHumanCase,
                                                 @VeterinaryDiseaseReportID = NULL,
                                                 @CollectionDate = @CollectionDate,
                                                 @CollectedByPersonID = @CollectedByPersonID,
                                                 @CollectedByOrganizationID = @CollectedByOrganizationID,
                                                 @SentDate = @SentDate,
                                                 @SentToOrganizationID = @SentToOrganizationID,
                                                 @EIDSSLocalFieldSampleID = @EIDSSLocalOrFieldSampleID,
                                                 @SiteID = @idfsSite,
                                                 @EnteredDate = @DateEntered,
                                                 @ReadOnlyIndicator = @ReadOnlyIndicator,
                                                 @SampleStatusTypeID = @SampleStatusTypeID,
                                                 @Comments = @Comments,
                                                 @CurrentSiteID = @CurrentSiteID,
                                                 @DiseaseID = @DiseaseID,
                                                 @BirdStatusTypeID = NULL,
                                                 @RowStatus = @RowStatus,
                                                 @RowAction = @RowAction

                UPDATE @TestsTemp
                SET SampleID = @SampleID
                WHERE SampleID = @RowID

                DELETE FROM @SamplesTemp
                WHERE SampleID = @RowID
            END
        END
        IF @TestsParameters IS NOT NULL
        BEGIN
            WHILE EXISTS (SELECT * FROM @TestsTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = TestID,
                    @TestID = TestID,
                    @TestNameTypeID = TestNameTypeID,
                    @TestCategoryTypeID = TestCategoryTypeID,
                    @TestResultTypeID = TestResultTypeID,
                    @TestStatusTypeID = TestStatusTypeID,
                    @DiseaseID = DiseaseID,
                    @SampleID = SampleID,
                    @Comments = Comments,
                    @RowStatus = RowStatus,
                    @StartedDate = StartedDate,
                    @ResultDate = ResultDate,
                    @TestedByOrganizationID = TestedByOrganizationID,
                    @TestedByPersonID = TestedByPersonID,
                    @ResultEnteredByOrganizationID = ResultEnteredByOrganizationID,
                    @ResultEnteredByPersonID = ResultEnteredByPersonID,
                    @ValidatedByOrganizationID = ValidatedByOrganizationID,
                    @ValidatedByPersonID = ValidatedByPersonID,
                    @ReadOnlyIndicator = ReadOnlyIndicator,
                    @NonLaboratoryTestIndicator = NonLaboratoryTestIndicator,
                    @ExternalTestIndicator = ExternalTestIndicator,
                    @PerformedByOrganizationID = PerformedByOrganizationID,
                    @ReceivedDate = ReceivedDate,
                    @ContactPersonName = ContactPersonName,
                    @RowAction = RowAction
                FROM @TestsTemp;

                -- If the record is being soft-@HumanDiseaseReportAfterEdit, then check if the test record was originally created 
                -- in the laboaratory module.  If it was, then disassociate the test record from the 
                -- human disease report, so that the test record remains in the laboratory module 
                -- for further action.
                SET @TestHumanCaseID = @idfHumanCase;

                -- If @HumanDiseaseReportAfterEdit and it's a disease report entered test, then just soft-delete the test.
                IF @RowStatus = 1
                   AND @NonLaboratoryTestIndicator = 1
                BEGIN
                    SET @RowStatus = 1;
                END

                -- If @HumanDiseaseReportAfterEdit and it's a laboratory module entered test, then just disassociate from the disease report.
                ELSE IF (@RowStatus = 1 AND @NonLaboratoryTestIndicator = 0)
                BEGIN
                    SET @RowStatus = 0;
                    SET @TestHumanCaseID = NULL;
                END;

                -- Set tests
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_TESTS_SET @TestID = @TestID OUTPUT,
                                               @TestNameTypeID = @TestNameTypeID,
                                               @TestCategoryTypeID = @TestCategoryTypeID,
                                               @TestResultTypeID = @TestResultTypeID,
                                               @TestStatusTypeID = @TestStatusTypeID,
                                               @DiseaseID = @DiseaseID,
                                               @SampleID = @SampleID,
                                               @BatchTestID = NULL,
                                               @ObservationID = NULL,
                                               @TestNumber = NULL,
                                               @Comments = @Comments,
                                               @RowStatus = @RowStatus,
                                               @StartedDate = @StartedDate,
                                               @ResultDate = @ResultDate,
                                               @TestedByOrganizationID = @TestedByOrganizationID,
                                               @TestedByPersonID = @TestedByPersonID,
                                               @ResultEnteredByOrganizationID = @ResultEnteredByOrganizationID,
                                               @ResultEnteredByPersonID = @ResultEnteredByPersonID,
                                               @ValidatedByOrganizationID = @ValidatedByOrganizationID,
                                               @ValidatedByPersonID = @ValidatedByPersonID,
                                               @ReadOnlyIndicator = @ReadOnlyIndicator,
                                               @NonLaboratoryTestIndicator = @NonLaboratoryTestIndicator,
                                               @ExternalTestIndicator = @ExternalTestIndicator,
                                               @PerformedByOrganizationID = @PerformedByOrganizationID,
                                               @ReceivedDate = @ReceivedDate,
                                               @ContactPerson = @ContactPersonName,
                                               @MonitoringSessionID = @idfParentMonitoringSession,
                                               @VectorSessionID = NULL,
                                               @HumanDiseaseReportID = @TestHumanCaseID,
                                               @VeterinaryDiseaseReportID = NULL,
                                               @AuditUserName = @AuditUser,
                                               @DataAuditEventID = @DataAuditEventID,
                                               @EIDSSObjectID = @strHumanCaseId,
                                               @RowAction = @RowAction;

                UPDATE @TestsInterpretationParametersTemp
                SET TestID = @TestID
                WHERE TestID = @RowID;

                DELETE FROM @TestsTemp
                WHERE TestID = @RowID;
            END;
        END

        DECLARE @SampleCount INT;
        SET @SampleCount =
        (
            SELECT Count(*)
            FROM dbo.tlbMaterial
            WHERE intRowStatus = 0
                  and idfHumanCase = @idfHumanCase
        );

        DECLARE @SampleToDeleteID BIGINT = NULL;
        DECLARE @SamplesToDelete TABLE (SampleID BIGINT);

        INSERT INTO @SamplesToDelete
        SELECT idfMaterial
        FROM dbo.tlbMaterial
        WHERE idfHumanCase = @idfHumanCase;

        DECLARE @BeforeNotCollectedReason BIGINT = (
                                                       SELECT idfsNotCollectedReason
                                                       FROM dbo.tlbHumanCase
                                                       WHERE idfHumanCase = @idfHumanCase
                                                   );

        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase
                  AND idfsYNSpecimenCollected = 10100002
        )
        BEGIN
            SET @ObjectTableID = 75620000000; -- tlbMaterial
            UPDATE dbo.tlbMaterial
            SET intRowStatus = 1,
                AuditUpdateUser = @AuditUser
            WHERE idfHumanCase = @idfHumanCase;

            WHILE EXISTS (SELECT * FROM @SamplesToDelete)
            BEGIN
                SELECT TOP 1
                    @SampleToDeleteID = SampleID
                FROM @SamplesToDelete;

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject, 
                    strObject
                )
                VALUES
                (@DataAuditEventid, @ObjectTableID, @SampleToDeleteID, @strHumanCaseId);
                -- End data audit

                DELETE FROM @SamplesToDelete
                WHERE SampleID = @SampleToDeleteID;
            END
        END
        ELSE IF EXISTS
        (
            SELECT *
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase
                  AND idfsYNSpecimenCollected = 10100003
        )
        BEGIN
            UPDATE dbo.tlbHumanCase
            SET idfsNotCollectedReason = NULL,
                AuditUpdateUser = @AuditUser
            WHERE idfHumanCase = @idfHumanCase;

            -- Data audit
            IF @BeforeNotCollectedReason IS NOT NULL
            BEGIN
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
                SELECT @DataAuditEventId,
                       @ObjectTableID,
                       12014670000000,
                       @idfHumanCase,
                       NULL,
                       @BeforeNotCollectedReason,
                       NULL,
                       @AuditUser, 
                       @strHumanCaseId;
            END
            -- End data audit

            SET @ObjectTableID = 75620000000; -- tlbMaterial
            UPDATE dbo.tlbMaterial
            SET intRowStatus = 1,
                AuditUpdateUser = @AuditUser
            WHERE idfHumanCase = @idfHumanCase;

            WHILE EXISTS (SELECT * FROM @SamplesToDelete)
            BEGIN
                SELECT TOP 1
                    @SampleToDeleteID = SampleID
                FROM @SamplesToDelete;

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject, 
                    strObject
                )
                VALUES
                (@DataAuditEventid, @ObjectTableID, @SampleToDeleteID, @strHumanCaseId);
                -- End data audit

                DELETE FROM @SamplesToDelete
                WHERE SampleID = @SampleToDeleteID;
            END
        END
        ELSE IF EXISTS
        (
            SELECT *
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase
                  AND idfsYNSpecimenCollected = 10100001
        )
        BEGIN
            UPDATE dbo.tlbHumanCase
            SET idfsNotCollectedReason = NULL,
                AuditUpdateUser = @AuditUser
            WHERE idfHumanCase = @idfHumanCase;

            -- Data audit
            IF @BeforeNotCollectedReason IS NOT NULL
            BEGIN
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
                SELECT @DataAuditEventId,
                       @ObjectTableID,
                       12014670000000,
                       @idfHumanCase,
                       NULL,
                       @BeforeNotCollectedReason,
                       NULL,
                       @AuditUser, 
                       @strHumanCaseId
            END
            -- End data audit

            IF (@SampleCount = 0)
            BEGIN
                DECLARE @BeforeSpecimenCollectedIndicator BIGINT = (
                                                                       SELECT idfsYNSpecimenCollected
                                                                       FROM dbo.tlbHumanCase
                                                                       WHERE idfHumanCase = @idfHumanCase
                                                                   );

                UPDATE dbo.tlbHumanCase
                SET idfsYNSpecimenCollected = NULL,
                    AuditUpdateUser = @AuditUser
                WHERE idfHumanCase = @idfHumanCase;

                -- Data audit
                IF @BeforeSpecimenCollectedIndicator IS NOT NULL
                BEGIN
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
                    SELECT @DataAuditEventId,
                           @ObjectTableID,
                           79760000000,
                           @idfHumanCase,
                           NULL,
                           @BeforeSpecimenCollectedIndicator,
                           NULL,
                           @AuditUser, 
                           @strHumanCaseId;
                END
            -- End data audit
            END
        END

        -- Set test interpretations
        IF @TestsInterpretationParameters IS NOT NULL
        BEGIN
            WHILE EXISTS (SELECT * FROM @TestsInterpretationParametersTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = TestInterpretationID,
                    @TestInterpretationID = TestInterpretationID,
                    @DiseaseID = DiseaseID,
                    @InterpretedStatusTypeID = InterpretedStatusTypeID,
                    @ValidatedByOrganizationID = ValidatedByOrganizationID,
                    @ValidatedByPersonID = ValidatedByPersonID,
                    @InterpretedByOrganizationID = InterpretedByOrganizationID,
                    @InterpretedByPersonID = InterpretedByPersonID,
                    @TestID = TestID,
                    @ValidatedStatusIndicator = ValidatedStatusIndicator,
                    @ReportSessionCreatedIndicator = ReportSessionCreatedIndicator,
                    @ValidatedComment = ValidatedComment,
                    @InterpretedComment = InterpretedComment,
                    @ValidatedDate = ValidatedDate,
                    @InterpretedDate = InterpretedDate,
                    @RowStatus = RowStatus,
                    @ReadOnlyIndicator = ReadOnlyIndicator,
                    @RowAction = RowAction
                FROM @TestsInterpretationParametersTemp;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_TEST_INTERPRETATIONS_SET @AuditUser,
                                                              @DataAuditEventID,
                                                              @strHumanCaseId,
                                                              @TestInterpretationID OUTPUT,
                                                              @DiseaseID,
                                                              @InterpretedStatusTypeID,
                                                              @ValidatedByOrganizationID,
                                                              @ValidatedByPersonID,
                                                              @InterpretedByOrganizationID,
                                                              @InterpretedByPersonID,
                                                              @TestID,
                                                              @ValidatedStatusIndicator,
                                                              @ReportSessionCreatedIndicator,
                                                              @ValidatedComment,
                                                              @InterpretedComment,
                                                              @ValidatedDate,
                                                              @InterpretedDate,
                                                              @RowStatus,
                                                              @ReadOnlyIndicator,
                                                              @RowAction;

                DELETE FROM @TestsInterpretationParametersTemp
                WHERE TestInterpretationID = @RowID;
            END;
        END

        -- Set events
        WHILE EXISTS (SELECT * FROM @EventsTemp)
        BEGIN
            SELECT TOP 1
                @EventId = EventId,
                @EventTypeId = EventTypeId,
                @EventUserId = UserId,
                @EventObjectId = ObjectId,
                @EventSiteId = SiteId,
                @EventDiseaseId = DiseaseId,
                @EventLocationId = LocationId,
                @EventInformationString = InformationString,
                @EventLoginSiteId = LoginSiteId
            FROM @EventsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_ADMIN_EVENT_SET @EventId,
                                             @EventTypeId,
                                             @EventUserId,
                                             @EventObjectId,
                                             @EventDiseaseId,
                                             @EventSiteId,
                                             @EventInformationString,
                                             @EventLoginSiteId,
                                             @EventLocationId,
                                             @AuditUser,
                                             @DataAuditEventID, 
                                             @strHumanCaseId;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        -- Set anti-viral therapies
        IF @AntiviralTherapiesParameters IS NOT NULL
        BEGIN
            EXEC dbo.USSP_HUM_ANTIVIRAL_THERAPIES_SET @idfHumanCase,
                                                      @AntiviralTherapiesParameters,
                                                      0,
                                                      @AuditUser,
                                                      @DataAuditEventID, 
                                                      @strHumanCaseId;
        END

        -- Set vaccinations
        IF @VaccinationsParameters IS NOT NULL
        BEGIN
            EXEC dbo.USSP_HUM_DISEASE_VACCINATION_SET @idfHumanCase,
                                                      @VaccinationsParameters,
                                                      0,
                                                      @AuditUser,
                                                      @DataAuditEventID, 
                                                      @strHumanCaseId;
        END

        -- Set contacts
        IF @ContactsParameters IS NOT NULL
        BEGIN
            EXEC USSP_GBL_CONTACTS_SET @ContactsParameters,
                                       @CurrentSiteID,
                                       @AuditUser,
                                       @DataAuditEventID,
                                       @idfHumanCase, 
                                       @strHumanCaseId;
        END

        -- Update the human record if a date of death is provided.
        IF @datDateofDeath IS NOT NULL
        BEGIN
            DECLARE @BeforeDateOfDeath DATETIME
                =   (
                        SELECT datDateOfDeath FROM dbo.tlbHuman WHERE @idfHuman = @idfHuman
                    );

            UPDATE dbo.tlbHuman
            SET datDateofDeath = @datDateofDeath,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUser
            WHERE idfHuman = @idfHuman;

            SET @ObjectTableID = 75600000000; -- tlbHuman

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateDTM,
                AuditCreateUser, 
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             79340000000,
             @idfHuman,
             NULL,
             @BeforeDateOfDeath,
             @datDateofDeath,
             GETDATE(),
             @AuditUser, 
             @strHumanCaseId
            );
        END

        -- Update the connected test record if a connected test ID is provided.
        IF @ConnectedTestId IS NOT NULL
        BEGIN
            SELECT @DiseaseID = T.idfsDiagnosis,
                   @HumanMasterID = HA.idfHumanActual,
                   @idfMaterial = T.idfMaterial
            FROM dbo.tlbTesting T
                INNER JOIN dbo.tlbMaterial M
                    ON M.idfMaterial = T.idfMaterial
                INNER JOIN dbo.tlbHuman H
                    ON H.idfHuman = M.idfHuman
                INNER JOIN dbo.tlbHumanActual HA
                    ON HA.idfHumanActual = H.idfHumanActual
            WHERE T.idfTesting = @ConnectedTestId;

            UPDATE dbo.tlbTesting
            SET dbo.tlbTesting.idfHumanCase = @idfHumanCase,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUser
            FROM dbo.tlbTesting T
                INNER JOIN dbo.tlbMaterial M
                    ON M.idfMaterial = T.idfMaterial
                INNER JOIN dbo.tlbHuman H
                    ON H.idfHuman = M.idfHuman
                INNER JOIN dbo.tlbHumanActual HA
                    ON HA.idfHumanActual = H.idfHumanActual
            WHERE T.idfsDiagnosis = @DiseaseID
                  AND HA.idfHumanActual = @HumanMasterID
                  AND T.idfMaterial = @idfMaterial;

            SET @ObjectTableID = 75740000000; -- tlbTesting

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateDTM,
                AuditCreateUser, 
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             51586790000001,
             @idfHuman,
             NULL,
             NULL,
             @idfHumanCase,
             GETDATE(),
             @AuditUser, 
             @strHumanCaseId
            );
        -- End data audit
        END

        IF @@TRANCOUNT > 0
            COMMIT TRAN;

        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage',
               @idfHumanCase 'idfHumanCase',
               @strHumanCaseID 'strHumanCaseID',
               @idfHuman 'idfHuman';
    END TRY
    BEGIN CATCH
        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage',
               @idfHumanCase 'idfHumanCase',
               @strHumanCaseID 'strHumanCaseID',
               @idfHuman 'idfHuman';

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END
