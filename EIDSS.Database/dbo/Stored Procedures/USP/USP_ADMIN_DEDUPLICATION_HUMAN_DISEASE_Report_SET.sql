-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_HUMAN_DISEASE_Report_SET
--
-- Description:	Deduplication for Livestock and Avian disease report record.
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		25May2022	Initial release
-- Mark Wilson		10Jun2022	update to 
-- Stephen Long     07/06/2022 Updates for site alerts to call new stored procedure.
-- Ann Xiong		11/14/2022	Updated to pass correct parameters to USP_HUM_HUMAN_DISEASE_DEL.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_HUMAN_DISEASE_Report_SET]
(
    @SupersededDiseaseReportID BIGINT,
    @LanguageID NVARCHAR(50),
    @SurvivorDiseaseReportID BIGINT,
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
    @idfsYNSpecificVaccinationAdministered BIGINT = NULL, --  tlbHumanCase.idfsYNSpecIFicVaccinationAdministered
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
    @idfParentMonitoringSession BIGINT = NULL
)
AS

BEGIN --Proc variables
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
DECLARE @RowID BIGINT = NULL,
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
        @EventId BIGINT,
        @EventTypeId BIGINT = NULL,
        @EventSiteId BIGINT = NULL,
        @EventObjectId BIGINT = NULL,
        @EventUserId BIGINT = NULL,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = NULL,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = NULL,
        @MonitoringSessionActionID BIGINT,
        @ActionTypeID BIGINT,
        @ActionStatusTypeID BIGINT,
        @ActionDate DATETIME = NULL,
        @Comments NVARCHAR(500) = NULL,
        @DiseaseID BIGINT,
        @idfMonitoringSessionToDiagnosis BIGINT,
        @DateEntered DATETIME = GETDATE(),
        @DeleteID BIGINT = @SupersededDiseaseReportID,
        @SaveID BIGINT = @SurvivorDiseaseReportID
SET @AuditUser = ISNULL(@AuditUser, '')
END
BEGIN --Data Audit variables
declare @idfUserId BIGINT =NULL;
declare @idfSiteId BIGINT = NULL;
declare @idfsDataAuditEventType bigint =NULL;
-- Get and Set UserId and SiteId
select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUser) userInfo
END
BEGIN --Declare Temp tables
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
DECLARE @SamplesTemp2 TABLE (SampleID BIGINT NOT NULL);

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
DECLARE @EventsTemp2 TABLE (EventId BIGINT NOT NULL);

DECLARE @AntiViralTemp TABLE (idfAntimicrobialTherapy BIGINT);
INSERT INTO @AntiViralTemp
(
    idfAntimicrobialTherapy
)
SELECT idfAntimicrobialTherapy
FROM
    OPENJSON(@AntiviralTherapiesParameters)
    WITH
    (
        idfAntimicrobialTherapy BIGINT
    );

DECLARE @ContactsTemp TABLE (ContactedCasePersonId BIGINT NOT NULL);
INSERT INTO @ContactsTemp
(
    ContactedCasePersonId
)
SELECT ContactedCasePersonId
FROM
    OPENJSON(@ContactsParameters)
    WITH
    (
        ContactedCasePersonId BIGINT
    );
END

DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage VARCHAR(200)
);
 
BEGIN TRY --Main logic
	BEGIN --Insert temp tables with JSON data
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
    INSERT INTO @SamplesTemp2
    SELECT SampleID
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
    INSERT INTO @EventsTemp2
    SELECT EventId
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

    DECLARE @VaccinationsTemp TABLE (humanDiseaseReportVaccinationUID BIGINT NOT NULL);
    INSERT INTO @VaccinationsTemp
    SELECT *
    FROM
        OPENJSON(@VaccinationsParameters)
        WITH
        (
            humanDiseaseReportVaccinationUID BIGINT
        )
	END

    BEGIN TRANSACTION

    DECLARE @SupressSELECT TABLE
    (
        retrunCode INT,
        returnMessage VARCHAR(200)
    )
    DECLARE @SupressSELECTHumanCase TABLE
    (
        retrunCode INT,
        returnMessage VARCHAR(200) --,
    -- idfHumanCase BIGINT
    )
    DECLARE @SupressSELECTHuman TABLE
    (
        retrunCode INT,
        returnMessage VARCHAR(200),
        idfHuman BIGINT
    )
    DECLARE @SupressSELECTGeoLocation TABLE
    (
        returnCode INT,
        returnMsg VARCHAR(200),
        idfGeoLocation BIGINT
    )		
    SET @DiseaseID = @idfsFinalDiagnosis
    DECLARE @HumanDiseasereportRelnUID BIGINT
    DECLARE @COPYHUMANACTUALTOHUMAN_ReturnCode INT = 0
		 
    -- Create a human record FROM Human Actual if not already present
    IF @idfHumanActual IS NOT NULL -- AND @idfHumanCase IS  NULL
    BEGIN	
		--Data Audit - Start
		--Variables
		DECLARE @idfsObjectTypeHuman bigint = 10017079;
		DECLARE @idfObjectHuman bigint = @idfHuman;
		DECLARE @idfObjectHumanTable bigint = 75600000000;
		DECLARE @tlbHuman_BeforeEdit TABLE
		(
			idfHuman BIGINT,idfHumanActual BIGINT,idfsOccupationType BIGINT,idfsNationality BIGINT,idfsHumanGender BIGINT,datDateofBirth DATETIME,datDateOfDeath DATETIME,
			strLastName NVARCHAR(200),strSecondName NVARCHAR(200),strFirstName NVARCHAR(200),strRegistrationPhone NVARCHAR(200),strEmployerName NVARCHAR(200),strHomePhone NVARCHAR(200),
			strWorkPhone NVARCHAR(200),idfsPersonIDType BIGINT,strPersonID NVARCHAR(200),datModIFicationDate DATETIME,
			idfCurrentResidenceAddress BIGINT,idfEmployerAddress BIGINT,idfRegistrationAddress BIGINT 
		)
		DECLARE @tlbHuman_AfterEdit TABLE
		(
			idfHuman BIGINT,idfHumanActual BIGINT,idfsOccupationType BIGINT,idfsNationality BIGINT,idfsHumanGender BIGINT,datDateofBirth DATETIME,datDateOfDeath DATETIME,
			strLastName NVARCHAR(200),strSecondName NVARCHAR(200),strFirstName NVARCHAR(200),strRegistrationPhone NVARCHAR(200),strEmployerName NVARCHAR(200),strHomePhone NVARCHAR(200),
			strWorkPhone NVARCHAR(200),idfsPersonIDType BIGINT,strPersonID NVARCHAR(200),datModIFicationDate DATETIME,
			idfCurrentResidenceAddress BIGINT,idfEmployerAddress BIGINT,idfRegistrationAddress BIGINT 
		)
		DECLARE @idfDataAuditEventHuman bigint= NULL; 

		--Find Insert/Update/Delete
		IF @idfHuman IS NULL
		BEGIN
			set @idfsDataAuditEventType = 10016001; --Insert
		END 
		ELSE 
		BEGIN 
			set @idfsDataAuditEventType = 10016003; --Update
		END

		--Get values before edit
		IF @idfsDataAuditEventType = 10016003
		BEGIN 
			--Get values before edit			
			insert into @tlbHuman_BeforeEdit
			(idfHuman,idfHumanActual,idfsOccupationType,idfsNationality,idfsHumanGender,datDateofBirth,datDateOfDeath,strLastName,strSecondName,strFirstName,strRegistrationPhone,
			strEmployerName,strHomePhone,strWorkPhone,idfsPersonIDType,strPersonID,datModIFicationDate,idfCurrentResidenceAddress,idfEmployerAddress,idfRegistrationAddress)
			select idfHuman,idfHumanActual,idfsOccupationType,idfsNationality,idfsHumanGender,datDateofBirth,datDateOfDeath,strLastName,strSecondName,strFirstName,strRegistrationPhone,
			strEmployerName,strHomePhone,strWorkPhone,idfsPersonIDType,strPersonID,datModIFicationDate,idfCurrentResidenceAddress,idfEmployerAddress,idfRegistrationAddress
			from dbo.tlbHuman
			WHERE idfHuman = @idfHuman AND intRowStatus = 0 
		END
		--Data Audit - End

        INSERT INTO @SupressSELECTHumanCase
        EXEC dbo.USP_HUM_COPYHUMANACTUALTOHUMAN @idfHumanActual,
                                                @idfHuman OUTPUT,
                                                @returnCode OUTPUT,
                                                @returnMsg OUTPUT
																	
		--Data Audit - Start
		--Get values After edit
		IF @idfsDataAuditEventType = 10016003
		BEGIN
			--Get values after edit			
			insert into @tlbHuman_AfterEdit
			(idfHuman,idfHumanActual,idfsOccupationType,idfsNationality,idfsHumanGender,datDateofBirth,datDateOfDeath,strLastName,strSecondName,strFirstName,strRegistrationPhone,
			strEmployerName,strHomePhone,strWorkPhone,idfsPersonIDType,strPersonID,datModIFicationDate,idfCurrentResidenceAddress,idfEmployerAddress,idfRegistrationAddress)
			select idfHuman,idfHumanActual,idfsOccupationType,idfsNationality,idfsHumanGender,datDateofBirth,datDateOfDeath,strLastName,strSecondName,strFirstName,strRegistrationPhone,
			strEmployerName,strHomePhone,strWorkPhone,idfsPersonIDType,strPersonID,datModIFicationDate,idfCurrentResidenceAddress,idfEmployerAddress,idfRegistrationAddress
			from dbo.tlbHuman
			WHERE idfHuman = @idfHuman AND intRowStatus = 0 
		END

		SET @idfObjectHuman = @idfHuman 
		IF @idfsDataAuditEventType = 10016001
		BEGIN 
			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeHuman,@idfObjectHuman, @idfObjectHumanTable, @idfDataAuditEventHuman OUTPUT

			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
				values ( @idfDataAuditEventHuman, @idfObjectHumanTable, @idfObjectHuman)
		END
		ELSE IF @idfsDataAuditEventType = 10016003			
		BEGIN
			IF EXISTS 
			(
				select *
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman  
				where (ISNULL(a.idfsOccupationType,'') <> ISNULL(b.idfsOccupationType,'')) OR (ISNULL(a.idfsNationality,'') <> ISNULL(b.idfsNationality,'')) OR 
					(ISNULL(a.idfsHumanGender,'') <> ISNULL(b.idfsHumanGender,'')) OR (ISNULL(a.datDateofBirth,'') <> ISNULL(b.datDateofBirth,'')) OR 
					(ISNULL(a.datDateOfDeath,'') <> ISNULL(b.datDateOfDeath,'')) OR (ISNULL(a.strLastName,'') <> ISNULL(b.strLastName,'')) OR 
					(ISNULL(a.strSecondName,'') <> ISNULL(b.strSecondName,'')) OR (ISNULL(a.strFirstName,'') <> ISNULL(b.strFirstName,'')) OR 
					(ISNULL(a.strRegistrationPhone,'') <> ISNULL(b.strRegistrationPhone,'')) OR (ISNULL(a.strEmployerName,'') <> ISNULL(b.strEmployerName,'')) OR 
					(ISNULL(a.strHomePhone,'') <> ISNULL(b.strHomePhone,'')) OR (ISNULL(a.strWorkPhone,'') <> ISNULL(b.strWorkPhone,'')) OR 
					(ISNULL(a.idfsPersonIDType,'') <> ISNULL(b.idfsPersonIDType,'')) OR (ISNULL(a.strPersonID,'') <> ISNULL(b.strPersonID,'')) OR 
					(ISNULL(a.datModIFicationDate,'') <> ISNULL(b.datModIFicationDate,'')) OR (ISNULL(a.idfCurrentResidenceAddress,'') <> ISNULL(b.idfCurrentResidenceAddress,'')) OR 
					(ISNULL(a.idfEmployerAddress,'') <> ISNULL(b.idfEmployerAddress,'')) OR (ISNULL(a.idfRegistrationAddress,'') <> ISNULL(b.idfRegistrationAddress,''))  
			)
			BEGIN
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeHuman,@idfObjectHuman, @idfObjectHumanTable, @idfDataAuditEventHuman OUTPUT

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79410000000,@idfObjectHuman,null,a.idfsOccupationType,b.idfsOccupationType 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfsOccupationType,'') <> ISNULL(b.idfsOccupationType,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79400000000,@idfObjectHuman,null,a.idfsNationality,b.idfsNationality 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfsNationality,'') <> ISNULL(b.idfsNationality,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79390000000,@idfObjectHuman,null,a.idfsHumanGender,b.idfsHumanGender 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfsHumanGender,'') <> ISNULL(b.idfsHumanGender,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79330000000,@idfObjectHuman,null,a.datDateofBirth,b.datDateofBirth 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.datDateofBirth,'') <> ISNULL(b.datDateofBirth,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79340000000,@idfObjectHuman,null,a.datDateOfDeath,b.datDateOfDeath 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.datDateOfDeath,'') <> ISNULL(b.datDateOfDeath,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79450000000,@idfObjectHuman,null,a.strLastName,b.strLastName 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strLastName,'') <> ISNULL(b.strLastName,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79470000000,@idfObjectHuman,null,a.strSecondName,b.strSecondName 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strSecondName,'') <> ISNULL(b.strSecondName,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79430000000,@idfObjectHuman,null,a.strFirstName,b.strFirstName 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strFirstName,'') <> ISNULL(b.strFirstName,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79460000000,@idfObjectHuman,null,a.strRegistrationPhone,b.strRegistrationPhone 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strRegistrationPhone,'') <> ISNULL(b.strRegistrationPhone,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79420000000,@idfObjectHuman,null,a.strEmployerName,b.strEmployerName 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strEmployerName,'') <> ISNULL(b.strEmployerName,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79440000000,@idfObjectHuman,null,a.strHomePhone,b.strHomePhone 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strHomePhone,'') <> ISNULL(b.strHomePhone,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79480000000,@idfObjectHuman,null,a.strWorkPhone,b.strWorkPhone 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strWorkPhone,'') <> ISNULL(b.strWorkPhone,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,12014460000000,@idfObjectHuman,null,a.idfsPersonIDType,b.idfsPersonIDType 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfsPersonIDType,'') <> ISNULL(b.idfsPersonIDType,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,12014470000000,@idfObjectHuman,null,a.strPersonID,b.strPersonID 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.strPersonID,'') <> ISNULL(b.strPersonID,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,51389540000000,@idfObjectHuman,null,a.datModIFicationDate,b.datModIFicationDate 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.datModIFicationDate,'') <> ISNULL(b.datModIFicationDate,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79350000000,@idfObjectHuman,null,a.idfCurrentResidenceAddress,b.idfCurrentResidenceAddress 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfCurrentResidenceAddress,'') <> ISNULL(b.idfCurrentResidenceAddress,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79360000000,@idfObjectHuman,null,a.idfEmployerAddress,b.idfEmployerAddress 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfEmployerAddress,'') <> ISNULL(b.idfEmployerAddress,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventHuman,@idfObjectHumanTable,79380000000,@idfObjectHuman,null,a.idfRegistrationAddress,b.idfRegistrationAddress 
				from @tlbHuman_BeforeEdit a  inner join @tlbHuman_AfterEdit b on a.idfHuman = b.idfHuman 
				where (ISNULL(a.idfRegistrationAddress,'') <> ISNULL(b.idfRegistrationAddress,'')) 
			END
		END										
		--Data Audit - End

        IF @returnCode <> 0
        BEGIN
            RETURN
        END
    END 
		
	--Audit - ToDo - Location - insert
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
		--Data Audit - Location - Start
		--Variables
		DECLARE @idfsObjectTypeLocation bigint = 10017079;
		DECLARE @idfObjectLocation bigint = @idfPointGeoLocation;
		DECLARE @idfObjectLocationTable bigint = 75600000000;
		DECLARE @tlbLocation_BeforeEdit TABLE
		(
			idfGeoLocation BIGINT,idfsGroundType BIGINT,idfsGeoLocationType BIGINT,idfsCountry BIGINT,idfsRegion BIGINT,idfsRayon BIGINT,
			idfsSettlement BIGINT,idfsLocation BIGINT,strDescription NVARCHAR(200),dblDistance FLOAT,dblLatitude FLOAT,dblLongitude FLOAT,
			dblAccuracy FLOAT,dblAlignment FLOAT,strForeignAddress NVARCHAR(200), blnForeignAddress BIT,dblElevation FLOAT
		)
		DECLARE @tlbLocation_AfterEdit TABLE
		(
			idfGeoLocation BIGINT,idfsGroundType BIGINT,idfsGeoLocationType BIGINT,idfsCountry BIGINT,idfsRegion BIGINT,idfsRayon BIGINT,
			idfsSettlement BIGINT,idfsLocation BIGINT,strDescription NVARCHAR(200),dblDistance FLOAT,dblLatitude FLOAT,dblLongitude FLOAT,
			dblAccuracy FLOAT,dblAlignment FLOAT,strForeignAddress NVARCHAR(200), blnForeignAddress BIT,dblElevation FLOAT
		)
		DECLARE @idfDataAuditEventLocation bigint= NULL; 

		--Find Insert/Update/Delete
		IF @idfPointGeoLocation IS NULL
		BEGIN
			set @idfsDataAuditEventType = 10016001; --Insert
		END 
		ELSE 
		BEGIN 
			set @idfsDataAuditEventType = 10016003; --Update
		END 
			
		--Get values before edit
		IF @idfsDataAuditEventType = 10016003
		BEGIN 
			--Get values before edit			
			insert into @tlbLocation_BeforeEdit
			(idfGeoLocation,idfsGroundType,idfsGeoLocationType,idfsCountry,idfsRegion,idfsRayon,idfsSettlement,idfsLocation,strDescription,
			dblDistance,dblLatitude,dblLongitude,dblAccuracy,dblAlignment,strForeignAddress,blnForeignAddress,dblElevation)
			select idfGeoLocation,idfsGroundType,idfsGeoLocationType,idfsCountry,idfsRegion,idfsRayon,idfsSettlement,idfsLocation,strDescription,
			dblDistance,dblLatitude,dblLongitude,dblAccuracy,dblAlignment,strForeignAddress,blnForeignAddress,dblElevation
			from dbo.tlbGeoLocation
			WHERE idfGeoLocation = @idfPointGeoLocation --AND intRowStatus = 0 
		END
		--Data Audit - End
			
        -- Set geo location 
        IF @idfPointGeoLocation IS NULL
        BEGIN
            INSERT INTO @SupressSELECT
            EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbGeoLocation',
                                            @idfsKey = @idfPointGeoLocation OUTPUT
        END
        BEGIN
            INSERT INTO @SupressSELECTGeoLocation
            EXECUTE [dbo].[USP_HUMAN_DISEASE_GEOLOCATION_SET] @idfPointGeoLocation,
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
                                                                @AuditUser
        END

		--Data Audit - Start
		--Get values After edit
		IF @idfsDataAuditEventType = 10016003
		BEGIN
			--Get values after edit			
			insert into @tlbLocation_AfterEdit
			(idfGeoLocation,idfsGroundType,idfsGeoLocationType,idfsCountry,idfsRegion,idfsRayon,idfsSettlement,idfsLocation,strDescription,
			dblDistance,dblLatitude,dblLongitude,dblAccuracy,dblAlignment,strForeignAddress,blnForeignAddress,dblElevation)
			select idfGeoLocation,idfsGroundType,idfsGeoLocationType,idfsCountry,idfsRegion,idfsRayon,idfsSettlement,idfsLocation,strDescription,
			dblDistance,dblLatitude,dblLongitude,dblAccuracy,dblAlignment,strForeignAddress,blnForeignAddress,dblElevation
			from dbo.tlbGeoLocation
			WHERE idfGeoLocation = @idfPointGeoLocation --AND intRowStatus = 0
		END

		SET @idfObjectLocation = @idfPointGeoLocation 
		IF @idfsDataAuditEventType = 10016001
		BEGIN 
			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeLocation,@idfObjectLocation, @idfObjectLocationTable, @idfDataAuditEventLocation OUTPUT

			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
				values ( @idfDataAuditEventLocation, @idfObjectLocationTable, @idfObjectLocation)
		END
		ELSE IF @idfsDataAuditEventType = 10016003			
		BEGIN
			IF EXISTS 
			(
				select *
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsGroundType,'') <> ISNULL(b.idfsGroundType,'')) OR (ISNULL(a.idfsGeoLocationType,'') <> ISNULL(b.idfsGeoLocationType,'')) OR 
					(ISNULL(a.idfsCountry,'') <> ISNULL(b.idfsCountry,'')) OR (ISNULL(a.idfsRegion,'') <> ISNULL(b.idfsRegion,'')) OR 
					(ISNULL(a.idfsRayon,'') <> ISNULL(b.idfsRayon,'')) OR (ISNULL(a.idfsSettlement,'') <> ISNULL(b.idfsSettlement,'')) OR 
					(ISNULL(a.idfsLocation,'') <> ISNULL(b.idfsLocation,'')) OR (ISNULL(a.strDescription,'') <> ISNULL(b.strDescription,'')) OR 
					(ISNULL(a.dblDistance,'') <> ISNULL(b.dblDistance,'')) OR (ISNULL(a.dblLatitude,'') <> ISNULL(b.dblLatitude,'')) OR 
					(ISNULL(a.dblLongitude,'') <> ISNULL(b.dblLongitude,'')) OR (ISNULL(a.dblAccuracy,'') <> ISNULL(b.dblAccuracy,'')) OR 
					(ISNULL(a.dblAlignment,'') <> ISNULL(b.dblAlignment,'')) OR (ISNULL(a.strForeignAddress,'') <> ISNULL(b.strForeignAddress,'')) OR 
					(ISNULL(a.blnForeignAddress,'') <> ISNULL(b.blnForeignAddress,'')) OR (ISNULL(a.dblElevation,'') <> ISNULL(b.dblElevation,'')) 
			)
			BEGIN
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeLocation,@idfObjectLocation
					, @idfObjectLocationTable, @idfDataAuditEventLocation OUTPUT

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsGroundType,b.idfsGroundType 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsGroundType,'') <> ISNULL(b.idfsGroundType,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsGeoLocationType,b.idfsGeoLocationType 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsGeoLocationType,'') <> ISNULL(b.idfsGeoLocationType,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsCountry,b.idfsCountry 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsCountry,'') <> ISNULL(b.idfsCountry,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsRegion,b.idfsRegion 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsRegion,'') <> ISNULL(b.idfsRegion,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsRayon,b.idfsRayon 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsRayon,'') <> ISNULL(b.idfsRayon,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsSettlement,b.idfsSettlement 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsSettlement,'') <> ISNULL(b.idfsSettlement,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.idfsLocation,b.idfsLocation 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.idfsLocation,'') <> ISNULL(b.idfsLocation,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.strDescription,b.strDescription 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.strDescription,'') <> ISNULL(b.strDescription,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.dblDistance,b.dblDistance 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.dblDistance,'') <> ISNULL(b.dblDistance,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.dblLatitude,b.dblLatitude 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.dblLatitude,'') <> ISNULL(b.dblLatitude,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.dblLongitude,b.dblLongitude 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.dblLongitude,'') <> ISNULL(b.dblLongitude,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.dblAlignment,b.dblAlignment 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.dblAlignment,'') <> ISNULL(b.dblAlignment,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.strForeignAddress,b.strForeignAddress 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.strForeignAddress,'') <> ISNULL(b.strForeignAddress,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.blnForeignAddress,b.blnForeignAddress 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.blnForeignAddress,'') <> ISNULL(b.blnForeignAddress,''))

				insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
				select @idfDataAuditEventLocation,@idfObjectLocationTable,79410000000,@idfObjectLocation,null,a.dblElevation,b.dblElevation 
				from @tlbLocation_BeforeEdit a  inner join @tlbLocation_AfterEdit b on a.idfGeoLocation = b.idfGeoLocation 
				where (ISNULL(a.dblElevation,'') <> ISNULL(b.dblElevation,'')) 
			END
		END										
		--Data Audit - End
    END
		
	--HumanCase
	BEGIN
		--Data Audit - HumanCase - Start
		--Variables
		DECLARE @idfsObjectTypeHumanCase bigint = 10017079;
		DECLARE @idfObjectHumanCase bigint = @SaveID;
		DECLARE @idfObjectHumanCaseTable bigint = 75610000000;
		DECLARE @tlbHumanCase_BeforeEdit TABLE
		(
			strCaseId NVARCHAR(200),idfsTentativeDiagnosis BIGINT,idfsFinalDiagnosis BIGINT,datTentativeDiagnosisDate DATETIME,datFinalDiagnosisDate DATETIME,datNotIFicationDate DATETIME,
			idfsFinalState BIGINT,idfSentByOffice BIGINT,strSentByFirstName NVARCHAR(200),strSentByPatronymicName NVARCHAR(200),strSentByLastName NVARCHAR(200),idfSentByPerson BIGINT,
			idfReceivedByOffice BIGINT,strReceivedByFirstName NVARCHAR(200),strReceivedByPatronymicName NVARCHAR(200),strReceivedByLastName NVARCHAR(200),idfReceivedByPerson BIGINT,
			strLocalIdentifier NVARCHAR(200),idfsHospitalizationStatus BIGINT,idfHospital BIGINT,strCurrentLocation NVARCHAR(200),datOnSetDate DATETIME,idfsInitialCaseStatus BIGINT,
			idfsYNPreviouslySoughtCare BIGINT,datFirstSoughtCareDate DATETIME,idfSoughtCareFacility BIGINT,idfsNonNotIFiableDiagnosis BIGINT,idfsYNHospitalization BIGINT,
			datHospitalizationDate DATETIME,datDischargeDate DATETIME,strHospitalizationPlace NVARCHAR(200),idfsYNAntimicrobialTherapy BIGINT,strClinicalNotes NVARCHAR(2000),
			idfsYNSpecificVaccinationAdministered BIGINT,idfInvestigatedByOffice BIGINT,datInvestigationStartDate DATETIME,idfsYNRelatedToOutbreak BIGINT,idfOutbreak BIGINT,
			idfsYNExposureLocationKnown BIGINT,idfPointGeoLocation BIGINT,datExposureDate DATETIME,strNote NVARCHAR(2000),idfsFinalCaseStatus BIGINT,idfsOutcome BIGINT,
			idfsCaseProgressStatus BIGINT,datModificationDate DATETIME,idfsYNSpecimenCollected BIGINT,idfsYNTestsConducted BIGINT,DiseaseReportTypeID BIGINT,blnClinicalDiagBasis BIT,
			blnLabDiagBasis BIT,blnEpiDiagBasis BIT,datFinalCaseClassificationDate DATETIME,strsummarynotes NVARCHAR(2000),idfEpiObservation BIGINT,idfCSObservation BIGINT,
			strEpidemiologistsName NVARCHAR(2000),idfsNotCollectedReason BIGINT,strNotCollectedReason NVARCHAR(200),idfsHumanAgeType BIGINT,intPatientAge INT,datCompletionPaperFormDate DATETIME,
			idfInvestigatedByPerson BIGINT,idfPersonEnteredBy BIGINT,idfsSite BIGINT,idfHumanCase BIGINT
		)
		DECLARE @tlbHumanCase_AfterEdit TABLE
		(
			strCaseId NVARCHAR(200),idfsTentativeDiagnosis BIGINT,idfsFinalDiagnosis BIGINT,datTentativeDiagnosisDate DATETIME,datFinalDiagnosisDate DATETIME,datNotIFicationDate DATETIME,
			idfsFinalState BIGINT,idfSentByOffice BIGINT,strSentByFirstName NVARCHAR(200),strSentByPatronymicName NVARCHAR(200),strSentByLastName NVARCHAR(200),idfSentByPerson BIGINT,
			idfReceivedByOffice BIGINT,strReceivedByFirstName NVARCHAR(200),strReceivedByPatronymicName NVARCHAR(200),strReceivedByLastName NVARCHAR(200),idfReceivedByPerson BIGINT,
			strLocalIdentifier NVARCHAR(200),idfsHospitalizationStatus BIGINT,idfHospital BIGINT,strCurrentLocation NVARCHAR(200),datOnSetDate DATETIME,idfsInitialCaseStatus BIGINT,
			idfsYNPreviouslySoughtCare BIGINT,datFirstSoughtCareDate DATETIME,idfSoughtCareFacility BIGINT,idfsNonNotIFiableDiagnosis BIGINT,idfsYNHospitalization BIGINT,
			datHospitalizationDate DATETIME,datDischargeDate DATETIME,strHospitalizationPlace NVARCHAR(200),idfsYNAntimicrobialTherapy BIGINT,strClinicalNotes NVARCHAR(2000),
			idfsYNSpecificVaccinationAdministered BIGINT,idfInvestigatedByOffice BIGINT,datInvestigationStartDate DATETIME,idfsYNRelatedToOutbreak BIGINT,idfOutbreak BIGINT,
			idfsYNExposureLocationKnown BIGINT,idfPointGeoLocation BIGINT,datExposureDate DATETIME,strNote NVARCHAR(2000),idfsFinalCaseStatus BIGINT,idfsOutcome BIGINT,
			idfsCaseProgressStatus BIGINT,datModificationDate DATETIME,idfsYNSpecimenCollected BIGINT,idfsYNTestsConducted BIGINT,DiseaseReportTypeID BIGINT,blnClinicalDiagBasis BIT,
			blnLabDiagBasis BIT,blnEpiDiagBasis BIT,datFinalCaseClassificationDate DATETIME,strsummarynotes NVARCHAR(2000),idfEpiObservation BIGINT,idfCSObservation BIGINT,
			strEpidemiologistsName NVARCHAR(2000),idfsNotCollectedReason BIGINT,strNotCollectedReason NVARCHAR(200),idfsHumanAgeType BIGINT,intPatientAge INT,datCompletionPaperFormDate DATETIME,
			idfInvestigatedByPerson BIGINT,idfPersonEnteredBy BIGINT,idfsSite BIGINT,idfHumanCase BIGINT
		)
		DECLARE @idfDataAuditEventHumanCase bigint= NULL; 
		set @idfsDataAuditEventType = 10016003;
		--Get values before edit			
		insert into @tlbHumanCase_BeforeEdit
		(strCaseId,idfsTentativeDiagnosis,idfsFinalDiagnosis,datTentativeDiagnosisDate,datFinalDiagnosisDate,datNotIFicationDate,idfsFinalState,idfSentByOffice,strSentByFirstName
		,strSentByPatronymicName,strSentByLastName,idfSentByPerson,idfReceivedByOffice,strReceivedByFirstName,strReceivedByPatronymicName,strReceivedByLastName,idfReceivedByPerson,strLocalIdentifier 
		,idfsHospitalizationStatus,idfHospital,strCurrentLocation,datOnSetDate,idfsInitialCaseStatus,idfsYNPreviouslySoughtCare,datFirstSoughtCareDate,idfSoughtCareFacility
		,idfsNonNotIFiableDiagnosis,idfsYNHospitalization,datHospitalizationDate,datDischargeDate,strHospitalizationPlace,idfsYNAntimicrobialTherapy,strClinicalNotes
		,idfsYNSpecificVaccinationAdministered,idfInvestigatedByOffice,datInvestigationStartDate,idfsYNRelatedToOutbreak,idfOutbreak,idfsYNExposureLocationKnown,idfPointGeoLocation,datExposureDate
		,strNote,idfsFinalCaseStatus,idfsOutcome,idfsCaseProgressStatus,datModificationDate,idfsYNSpecimenCollected,idfsYNTestsConducted,DiseaseReportTypeID,blnClinicalDiagBasis
		,blnLabDiagBasis,blnEpiDiagBasis,datFinalCaseClassificationDate,strsummarynotes,idfEpiObservation,idfCSObservation,strEpidemiologistsName,idfsNotCollectedReason,strNotCollectedReason
		,idfsHumanAgeType,intPatientAge,datCompletionPaperFormDate,idfInvestigatedByPerson,idfPersonEnteredBy,idfsSite,idfHumanCase)
		select strCaseId,idfsTentativeDiagnosis,idfsFinalDiagnosis,datTentativeDiagnosisDate,datFinalDiagnosisDate,datNotIFicationDate,idfsFinalState,idfSentByOffice,strSentByFirstName
		,strSentByPatronymicName,strSentByLastName,idfSentByPerson,idfReceivedByOffice,strReceivedByFirstName,strReceivedByPatronymicName,strReceivedByLastName,idfReceivedByPerson,strLocalIdentifier 
		,idfsHospitalizationStatus,idfHospital,strCurrentLocation,datOnSetDate,idfsInitialCaseStatus,idfsYNPreviouslySoughtCare,datFirstSoughtCareDate,idfSoughtCareFacility
		,idfsNonNotIFiableDiagnosis,idfsYNHospitalization,datHospitalizationDate,datDischargeDate,strHospitalizationPlace,idfsYNAntimicrobialTherapy,strClinicalNotes
		,idfsYNSpecificVaccinationAdministered,idfInvestigatedByOffice,datInvestigationStartDate,idfsYNRelatedToOutbreak,idfOutbreak,idfsYNExposureLocationKnown,idfPointGeoLocation,datExposureDate
		,strNote,idfsFinalCaseStatus,idfsOutcome,idfsCaseProgressStatus,datModificationDate,idfsYNSpecimenCollected,idfsYNTestsConducted,DiseaseReportTypeID,blnClinicalDiagBasis
		,blnLabDiagBasis,blnEpiDiagBasis,datFinalCaseClassificationDate,strsummarynotes,idfEpiObservation,idfCSObservation,strEpidemiologistsName,idfsNotCollectedReason,strNotCollectedReason
		,idfsHumanAgeType,intPatientAge,datCompletionPaperFormDate,idfInvestigatedByPerson,idfPersonEnteredBy,idfsSite,idfHumanCase
		from dbo.tlbHumanCase 
		WHERE idfHumanCase = @SaveID AND intRowStatus = 0
		--Data Audit - End
		 
		BEGIN --Update Survivor report data
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
				idfsYNSpecificVaccinationAdministered = @idfsYNSpecificVaccinationAdministered,
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
				AuditUpdateDTM = GETDATE(),
				idfParentMonitoringSession = @idfParentMonitoringSession
			WHERE idfHumanCase = @SaveID
					AND intRowStatus = 0
		END
		 
		--Data Audit - Start
		--Get values before edit			
		insert into @tlbHumanCase_AfterEdit
		(strCaseId,idfsTentativeDiagnosis,idfsFinalDiagnosis,datTentativeDiagnosisDate,datFinalDiagnosisDate,datNotIFicationDate,idfsFinalState,idfSentByOffice,strSentByFirstName
		,strSentByPatronymicName,strSentByLastName,idfSentByPerson,idfReceivedByOffice,strReceivedByFirstName,strReceivedByPatronymicName,strReceivedByLastName,idfReceivedByPerson,strLocalIdentifier 
		,idfsHospitalizationStatus,idfHospital,strCurrentLocation,datOnSetDate,idfsInitialCaseStatus,idfsYNPreviouslySoughtCare,datFirstSoughtCareDate,idfSoughtCareFacility
		,idfsNonNotIFiableDiagnosis,idfsYNHospitalization,datHospitalizationDate,datDischargeDate,strHospitalizationPlace,idfsYNAntimicrobialTherapy,strClinicalNotes
		,idfsYNSpecificVaccinationAdministered,idfInvestigatedByOffice,datInvestigationStartDate,idfsYNRelatedToOutbreak,idfOutbreak,idfsYNExposureLocationKnown,idfPointGeoLocation,datExposureDate
		,strNote,idfsFinalCaseStatus,idfsOutcome,idfsCaseProgressStatus,datModificationDate,idfsYNSpecimenCollected,idfsYNTestsConducted,DiseaseReportTypeID,blnClinicalDiagBasis
		,blnLabDiagBasis,blnEpiDiagBasis,datFinalCaseClassificationDate,strsummarynotes,idfEpiObservation,idfCSObservation,strEpidemiologistsName,idfsNotCollectedReason,strNotCollectedReason
		,idfsHumanAgeType,intPatientAge,datCompletionPaperFormDate,idfInvestigatedByPerson,idfPersonEnteredBy,idfsSite,idfHumanCase)
		select strCaseId,idfsTentativeDiagnosis,idfsFinalDiagnosis,datTentativeDiagnosisDate,datFinalDiagnosisDate,datNotIFicationDate,idfsFinalState,idfSentByOffice,strSentByFirstName
		,strSentByPatronymicName,strSentByLastName,idfSentByPerson,idfReceivedByOffice,strReceivedByFirstName,strReceivedByPatronymicName,strReceivedByLastName,idfReceivedByPerson,strLocalIdentifier 
		,idfsHospitalizationStatus,idfHospital,strCurrentLocation,datOnSetDate,idfsInitialCaseStatus,idfsYNPreviouslySoughtCare,datFirstSoughtCareDate,idfSoughtCareFacility
		,idfsNonNotIFiableDiagnosis,idfsYNHospitalization,datHospitalizationDate,datDischargeDate,strHospitalizationPlace,idfsYNAntimicrobialTherapy,strClinicalNotes
		,idfsYNSpecificVaccinationAdministered,idfInvestigatedByOffice,datInvestigationStartDate,idfsYNRelatedToOutbreak,idfOutbreak,idfsYNExposureLocationKnown,idfPointGeoLocation,datExposureDate
		,strNote,idfsFinalCaseStatus,idfsOutcome,idfsCaseProgressStatus,datModificationDate,idfsYNSpecimenCollected,idfsYNTestsConducted,DiseaseReportTypeID,blnClinicalDiagBasis
		,blnLabDiagBasis,blnEpiDiagBasis,datFinalCaseClassificationDate,strsummarynotes,idfEpiObservation,idfCSObservation,strEpidemiologistsName,idfsNotCollectedReason,strNotCollectedReason
		,idfsHumanAgeType,intPatientAge,datCompletionPaperFormDate,idfInvestigatedByPerson,idfPersonEnteredBy,idfsSite,idfHumanCase
		from dbo.tlbHumanCase 
		WHERE idfHumanCase = @SaveID AND intRowStatus = 0
		IF EXISTS 
		(
			select *
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase  
			where (ISNULL(a.strCaseId,'') <> ISNULL(b.strCaseId,'')) OR (ISNULL(a.idfsTentativeDiagnosis,'') <> ISNULL(b.idfsTentativeDiagnosis,'')) OR 
				(ISNULL(a.idfsFinalDiagnosis,'') <> ISNULL(b.idfsFinalDiagnosis,'')) OR (ISNULL(a.datTentativeDiagnosisDate,'') <> ISNULL(b.datTentativeDiagnosisDate,'')) OR 
				(ISNULL(a.datFinalDiagnosisDate,'') <> ISNULL(b.datFinalDiagnosisDate,'')) OR (ISNULL(a.datNotIFicationDate,'') <> ISNULL(b.datNotIFicationDate,'')) OR 
				(ISNULL(a.idfsFinalState,'') <> ISNULL(b.idfsFinalState,'')) OR (ISNULL(a.idfSentByOffice,'') <> ISNULL(b.idfSentByOffice,'')) OR 
				(ISNULL(a.strSentByFirstName,'') <> ISNULL(b.strSentByFirstName,'')) OR (ISNULL(a.strSentByPatronymicName,'') <> ISNULL(b.strSentByPatronymicName,'')) OR 
				(ISNULL(a.strSentByLastName,'') <> ISNULL(b.strSentByLastName,'')) OR (ISNULL(a.idfSentByPerson,'') <> ISNULL(b.idfSentByPerson,'')) OR 
				(ISNULL(a.idfReceivedByOffice,'') <> ISNULL(b.idfReceivedByOffice,'')) OR (ISNULL(a.strReceivedByFirstName,'') <> ISNULL(b.strReceivedByFirstName,'')) OR 
				(ISNULL(a.strReceivedByPatronymicName,'') <> ISNULL(b.strReceivedByPatronymicName,'')) OR (ISNULL(a.strReceivedByLastName,'') <> ISNULL(b.strReceivedByLastName,'')) OR 
				(ISNULL(a.idfReceivedByPerson,'') <> ISNULL(b.idfReceivedByPerson,'')) OR (ISNULL(a.strLocalIdentifier,'') <> ISNULL(b.strLocalIdentifier,'')) OR 
				(ISNULL(a.idfsHospitalizationStatus,'') <> ISNULL(b.idfsHospitalizationStatus,'')) OR (ISNULL(a.idfHospital,'') <> ISNULL(b.idfHospital,''))OR 
				(ISNULL(a.strCurrentLocation,'') <> ISNULL(b.strCurrentLocation,'')) OR (ISNULL(a.datOnSetDate,'') <> ISNULL(b.datOnSetDate,''))OR 
				(ISNULL(a.idfsInitialCaseStatus,'') <> ISNULL(b.idfsInitialCaseStatus,'')) OR (ISNULL(a.idfsYNPreviouslySoughtCare,'') <> ISNULL(b.idfsYNPreviouslySoughtCare,''))OR 
				(ISNULL(a.datFirstSoughtCareDate,'') <> ISNULL(b.datFirstSoughtCareDate,'')) OR (ISNULL(a.idfSoughtCareFacility,'') <> ISNULL(b.idfSoughtCareFacility,''))OR 
				(ISNULL(a.idfsNonNotIFiableDiagnosis,'') <> ISNULL(b.idfsNonNotIFiableDiagnosis,'')) OR (ISNULL(a.idfsYNHospitalization,'') <> ISNULL(b.idfsYNHospitalization,''))OR 
				(ISNULL(a.datHospitalizationDate,'') <> ISNULL(b.datHospitalizationDate,'')) OR (ISNULL(a.datDischargeDate,'') <> ISNULL(b.datDischargeDate,''))OR 
				(ISNULL(a.strHospitalizationPlace,'') <> ISNULL(b.strHospitalizationPlace,'')) OR (ISNULL(a.idfsYNAntimicrobialTherapy,'') <> ISNULL(b.idfsYNAntimicrobialTherapy,''))OR 
				(ISNULL(a.strClinicalNotes,'') <> ISNULL(b.strClinicalNotes,'')) OR (ISNULL(a.idfsYNSpecificVaccinationAdministered,'') <> ISNULL(b.idfsYNSpecificVaccinationAdministered,''))OR 
				(ISNULL(a.idfInvestigatedByOffice,'') <> ISNULL(b.idfInvestigatedByOffice,'')) OR (ISNULL(a.datInvestigationStartDate,'') <> ISNULL(b.datInvestigationStartDate,''))OR 
				(ISNULL(a.idfsYNRelatedToOutbreak,'') <> ISNULL(b.idfsYNRelatedToOutbreak,'')) OR (ISNULL(a.idfOutbreak,'') <> ISNULL(b.idfOutbreak,''))OR 
				(ISNULL(a.idfsYNExposureLocationKnown,'') <> ISNULL(b.idfsYNExposureLocationKnown,'')) OR (ISNULL(a.idfPointGeoLocation,'') <> ISNULL(b.idfPointGeoLocation,'')) OR 
				(ISNULL(a.datExposureDate,'') <> ISNULL(b.datExposureDate,'')) OR (ISNULL(a.strNote,'') <> ISNULL(b.strNote,'')) OR (ISNULL(a.idfsFinalCaseStatus,'') <> ISNULL(b.idfsFinalCaseStatus,'')) OR 
				(ISNULL(a.idfsOutcome,'') <> ISNULL(b.idfsOutcome,'')) OR (ISNULL(a.idfsCaseProgressStatus,'') <> ISNULL(b.idfsCaseProgressStatus,''))OR 
				(ISNULL(a.datModificationDate,'') <> ISNULL(b.datModificationDate,'')) OR (ISNULL(a.idfsYNSpecimenCollected,'') <> ISNULL(b.idfsYNSpecimenCollected,''))OR 
				(ISNULL(a.idfsYNTestsConducted,'') <> ISNULL(b.idfsYNTestsConducted,'')) OR (ISNULL(a.DiseaseReportTypeID,'') <> ISNULL(b.DiseaseReportTypeID,''))OR 
				(ISNULL(a.blnClinicalDiagBasis,'') <> ISNULL(b.blnClinicalDiagBasis,'')) OR (ISNULL(a.blnLabDiagBasis,'') <> ISNULL(b.blnLabDiagBasis,''))OR 
				(ISNULL(a.blnEpiDiagBasis,'') <> ISNULL(b.blnEpiDiagBasis,'')) OR (ISNULL(a.datFinalCaseClassificationDate,'') <> ISNULL(b.datFinalCaseClassificationDate,''))OR 
				(ISNULL(a.strsummarynotes,'') <> ISNULL(b.strsummarynotes,'')) OR (ISNULL(a.idfEpiObservation,'') <> ISNULL(b.idfEpiObservation,''))OR 
				(ISNULL(a.idfCSObservation,'') <> ISNULL(b.idfCSObservation,'')) OR (ISNULL(a.strEpidemiologistsName,'') <> ISNULL(b.strEpidemiologistsName,''))OR 
				(ISNULL(a.idfsNotCollectedReason,'') <> ISNULL(b.idfsNotCollectedReason,'')) OR (ISNULL(a.strNotCollectedReason,'') <> ISNULL(b.strNotCollectedReason,'')) OR 
				(ISNULL(a.idfsHumanAgeType,'') <> ISNULL(b.idfsHumanAgeType,'')) OR (ISNULL(a.intPatientAge,'') <> ISNULL(b.intPatientAge,'')) OR 
				(ISNULL(a.datCompletionPaperFormDate,'') <> ISNULL(b.datCompletionPaperFormDate,'')) OR (ISNULL(a.idfInvestigatedByPerson,'') <> ISNULL(b.idfInvestigatedByPerson,'')) OR 
				(ISNULL(a.idfPersonEnteredBy,'') <> ISNULL(b.idfPersonEnteredBy,'')) OR (ISNULL(a.idfsSite,'') <> ISNULL(b.idfsSite,''))
		)
		BEGIN
			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeHumanCase,@idfObjectHumanCase, @idfObjectHumanCaseTable, @idfDataAuditEventHumanCase OUTPUT

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,12665430000000,@idfObjectHumanCase,null,a.strCaseId,b.strCaseId 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strCaseId,'') <> ISNULL(b.strCaseId,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79720000000,@idfObjectHumanCase,null,a.idfsTentativeDiagnosis,b.idfsTentativeDiagnosis 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsTentativeDiagnosis,'') <> ISNULL(b.idfsTentativeDiagnosis,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79660000000,@idfObjectHumanCase,null,a.idfsFinalDiagnosis,b.idfsFinalDiagnosis 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsFinalDiagnosis,'') <> ISNULL(b.idfsFinalDiagnosis,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79600000000,@idfObjectHumanCase,null,a.datTentativeDiagnosisDate,b.datTentativeDiagnosisDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datTentativeDiagnosisDate,'') <> ISNULL(b.datTentativeDiagnosisDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855740000000,@idfObjectHumanCase,null,a.datNotIFicationDate,b.datNotIFicationDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datNotIFicationDate,'') <> ISNULL(b.datNotIFicationDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79560000000,@idfObjectHumanCase,null,a.datFinalDiagnosisDate,b.datFinalDiagnosisDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datFinalDiagnosisDate,'') <> ISNULL(b.datFinalDiagnosisDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79670000000,@idfObjectHumanCase,null,a.idfsFinalState,b.idfsFinalState 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsFinalState,'') <> ISNULL(b.idfsFinalState,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855700000000,@idfObjectHumanCase,null,a.idfSentByOffice,b.idfSentByOffice 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfSentByOffice,'') <> ISNULL(b.idfSentByOffice,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79880000000,@idfObjectHumanCase,null,a.strSentByFirstName,b.strSentByFirstName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strSentByFirstName,'') <> ISNULL(b.strSentByFirstName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79900000000,@idfObjectHumanCase,null,a.strSentByPatronymicName,b.strSentByPatronymicName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strSentByPatronymicName,'') <> ISNULL(b.strSentByPatronymicName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,4578390000000,@idfObjectHumanCase,null,a.idfSentByPerson,b.idfSentByPerson 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfSentByPerson,'') <> ISNULL(b.idfSentByPerson,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79890000000,@idfObjectHumanCase,null,a.strSentByLastName,b.strSentByLastName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strSentByLastName,'') <> ISNULL(b.strSentByLastName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79640000000,@idfObjectHumanCase,null,a.idfReceivedByOffice,b.idfReceivedByOffice 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfReceivedByOffice,'') <> ISNULL(b.idfReceivedByOffice,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79850000000,@idfObjectHumanCase,null,a.strReceivedByFirstName,b.strReceivedByFirstName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strReceivedByFirstName,'') <> ISNULL(b.strReceivedByFirstName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79870000000,@idfObjectHumanCase,null,a.strReceivedByPatronymicName,b.strReceivedByPatronymicName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strReceivedByPatronymicName,'') <> ISNULL(b.strReceivedByPatronymicName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79860000000,@idfObjectHumanCase,null,a.strReceivedByLastName,b.strReceivedByLastName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strReceivedByLastName,'') <> ISNULL(b.strReceivedByLastName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,4578400000000,@idfObjectHumanCase,null,a.idfReceivedByPerson,b.idfReceivedByPerson 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfReceivedByPerson,'') <> ISNULL(b.idfReceivedByPerson,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79820000000,@idfObjectHumanCase,null,a.strLocalIdentifier,b.strLocalIdentifier 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strLocalIdentifier,'') <> ISNULL(b.strLocalIdentifier,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79680000000,@idfObjectHumanCase,null,a.idfsHospitalizationStatus,b.idfsHospitalizationStatus 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsHospitalizationStatus,'') <> ISNULL(b.idfsHospitalizationStatus,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,51523420000000,@idfObjectHumanCase,null,a.idfHospital,b.idfHospital 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfHospital,'') <> ISNULL(b.idfHospital,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79790000000,@idfObjectHumanCase,null,a.strCurrentLocation,b.strCurrentLocation 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strCurrentLocation,'') <> ISNULL(b.strCurrentLocation,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855760000000,@idfObjectHumanCase,null,a.datOnSetDate,b.datOnSetDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datOnSetDate,'') <> ISNULL(b.datOnSetDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79700000000,@idfObjectHumanCase,null,a.idfsInitialCaseStatus,b.idfsInitialCaseStatus 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsInitialCaseStatus,'') <> ISNULL(b.idfsInitialCaseStatus,''))

			--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			--select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,49545390000000,@idfObjectHumanCase,null,a.idfsYNPreviouslySoughtCare,b.idfsYNPreviouslySoughtCare 
			--from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			--where (ISNULL(a.idfsYNPreviouslySoughtCare,'') <> ISNULL(b.idfsYNPreviouslySoughtCare,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855750000000,@idfObjectHumanCase,null,a.datFirstSoughtCareDate,b.datFirstSoughtCareDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datFirstSoughtCareDate,'') <> ISNULL(b.datFirstSoughtCareDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,12014650000000,@idfObjectHumanCase,null,a.idfSoughtCareFacility,b.idfSoughtCareFacility 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfSoughtCareFacility,'') <> ISNULL(b.idfSoughtCareFacility,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,12014660000000,@idfObjectHumanCase,null,a.idfsNonNotIFiableDiagnosis,b.idfsNonNotIFiableDiagnosis 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsNonNotIFiableDiagnosis,'') <> ISNULL(b.idfsNonNotIFiableDiagnosis,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79740000000,@idfObjectHumanCase,null,a.idfsYNHospitalization,b.idfsYNHospitalization 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsYNHospitalization,'') <> ISNULL(b.idfsYNHospitalization,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79570000000,@idfObjectHumanCase,null,a.datHospitalizationDate,b.datHospitalizationDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datHospitalizationDate,'') <> ISNULL(b.datHospitalizationDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79530000000,@idfObjectHumanCase,null,a.datDischargeDate,b.datDischargeDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datDischargeDate,'') <> ISNULL(b.datDischargeDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79810000000,@idfObjectHumanCase,null,a.strHospitalizationPlace,b.strHospitalizationPlace 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strHospitalizationPlace,'') <> ISNULL(b.strHospitalizationPlace,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79730000000,@idfObjectHumanCase,null,a.idfsYNAntimicrobialTherapy,b.idfsYNAntimicrobialTherapy 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsYNAntimicrobialTherapy,'') <> ISNULL(b.idfsYNAntimicrobialTherapy,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855770000000,@idfObjectHumanCase,null,a.strClinicalNotes,b.strClinicalNotes 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strClinicalNotes,'') <> ISNULL(b.strClinicalNotes,''))

			--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			--select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,49545390000000,@idfObjectHumanCase,null,a.idfsYNSpecificVaccinationAdministered,b.idfsYNSpecificVaccinationAdministered 
			--from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			--where (ISNULL(a.idfsYNSpecificVaccinationAdministered,'') <> ISNULL(b.idfsYNSpecificVaccinationAdministered,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79620000000,@idfObjectHumanCase,null,a.idfInvestigatedByOffice,b.idfInvestigatedByOffice 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfInvestigatedByOffice,'') <> ISNULL(b.idfInvestigatedByOffice,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79580000000,@idfObjectHumanCase,null,a.datInvestigationStartDate,b.datInvestigationStartDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datInvestigationStartDate,'') <> ISNULL(b.datInvestigationStartDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79750000000,@idfObjectHumanCase,null,a.idfsYNRelatedToOutbreak,b.idfsYNRelatedToOutbreak 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsYNRelatedToOutbreak,'') <> ISNULL(b.idfsYNRelatedToOutbreak,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,12665410000000,@idfObjectHumanCase,null,a.idfOutbreak,b.idfOutbreak 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfOutbreak,'') <> ISNULL(b.idfOutbreak,''))

			--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			--select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,49545390000000,@idfObjectHumanCase,null,a.idfsYNExposureLocationKnown,b.idfsYNExposureLocationKnown 
			--from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			--where (ISNULL(a.idfsYNExposureLocationKnown,'') <> ISNULL(b.idfsYNExposureLocationKnown,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79630000000,@idfObjectHumanCase,null,a.idfPointGeoLocation,b.idfPointGeoLocation 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfPointGeoLocation,'') <> ISNULL(b.idfPointGeoLocation,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79540000000,@idfObjectHumanCase,null,a.datExposureDate,b.datExposureDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datExposureDate,'') <> ISNULL(b.datExposureDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79840000000,@idfObjectHumanCase,null,a.strNote,b.strNote 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strNote,'') <> ISNULL(b.strNote,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855690000000,@idfObjectHumanCase,null,a.idfsFinalCaseStatus,b.idfsFinalCaseStatus 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsFinalCaseStatus,'') <> ISNULL(b.idfsFinalCaseStatus,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79710000000,@idfObjectHumanCase,null,a.idfsOutcome,b.idfsOutcome 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsOutcome,'') <> ISNULL(b.idfsOutcome,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,12665440000000,@idfObjectHumanCase,null,a.idfsCaseProgressStatus,b.idfsCaseProgressStatus 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsCaseProgressStatus,'') <> ISNULL(b.idfsCaseProgressStatus,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79590000000,@idfObjectHumanCase,null,a.datModificationDate,b.datModificationDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datModificationDate,'') <> ISNULL(b.datModificationDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79760000000,@idfObjectHumanCase,null,a.idfsYNSpecimenCollected,b.idfsYNSpecimenCollected 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsYNSpecimenCollected,'') <> ISNULL(b.idfsYNSpecimenCollected,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,4578420000000,@idfObjectHumanCase,null,a.idfsYNTestsConducted,b.idfsYNTestsConducted 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsYNTestsConducted,'') <> ISNULL(b.idfsYNTestsConducted,''))

			--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			--select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,49545390000000,@idfObjectHumanCase,null,a.DiseaseReportTypeID,b.DiseaseReportTypeID 
			--from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			--where (ISNULL(a.DiseaseReportTypeID,'') <> ISNULL(b.DiseaseReportTypeID,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79490000000,@idfObjectHumanCase,null,a.blnClinicalDiagBasis,b.blnClinicalDiagBasis 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.blnClinicalDiagBasis,'') <> ISNULL(b.blnClinicalDiagBasis,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79510000000,@idfObjectHumanCase,null,a.blnLabDiagBasis,b.blnLabDiagBasis 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.blnLabDiagBasis,'') <> ISNULL(b.blnLabDiagBasis,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79500000000,@idfObjectHumanCase,null,a.blnEpiDiagBasis,b.blnEpiDiagBasis 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.blnEpiDiagBasis,'') <> ISNULL(b.blnEpiDiagBasis,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,51389570000000,@idfObjectHumanCase,null,a.datFinalCaseClassificationDate,b.datFinalCaseClassificationDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datFinalCaseClassificationDate,'') <> ISNULL(b.datFinalCaseClassificationDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855780000000,@idfObjectHumanCase,null,a.strsummarynotes,b.strsummarynotes 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strsummarynotes,'') <> ISNULL(b.strsummarynotes,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855710000000,@idfObjectHumanCase,null,a.idfEpiObservation,b.idfEpiObservation 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfEpiObservation,'') <> ISNULL(b.idfEpiObservation,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,855720000000,@idfObjectHumanCase,null,a.idfCSObservation,b.idfCSObservation 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfCSObservation,'') <> ISNULL(b.idfCSObservation,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79800000000,@idfObjectHumanCase,null,a.strEpidemiologistsName,b.strEpidemiologistsName 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strEpidemiologistsName,'') <> ISNULL(b.strEpidemiologistsName,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,12014670000000,@idfObjectHumanCase,null,a.idfsNotCollectedReason,b.idfsNotCollectedReason 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsNotCollectedReason,'') <> ISNULL(b.idfsNotCollectedReason,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79830000000,@idfObjectHumanCase,null,a.strNotCollectedReason,b.strNotCollectedReason 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.strNotCollectedReason,'') <> ISNULL(b.strNotCollectedReason,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79690000000,@idfObjectHumanCase,null,a.idfsHumanAgeType,b.idfsHumanAgeType 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfsHumanAgeType,'') <> ISNULL(b.idfsHumanAgeType,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79770000000,@idfObjectHumanCase,null,a.intPatientAge,b.intPatientAge 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.intPatientAge,'') <> ISNULL(b.intPatientAge,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,79520000000,@idfObjectHumanCase,null,a.datCompletionPaperFormDate,b.datCompletionPaperFormDate 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.datCompletionPaperFormDate,'') <> ISNULL(b.datCompletionPaperFormDate,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,4578410000000,@idfObjectHumanCase,null,a.idfInvestigatedByPerson,b.idfInvestigatedByPerson 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfInvestigatedByPerson,'') <> ISNULL(b.idfInvestigatedByPerson,''))

			insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,4577910000000,@idfObjectHumanCase,null,a.idfPersonEnteredBy,b.idfPersonEnteredBy 
			from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			where (ISNULL(a.idfPersonEnteredBy,'') <> ISNULL(b.idfPersonEnteredBy,''))

			--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
			--select @idfDataAuditEventHumanCase,@idfObjectHumanCaseTable,49545390000000,@idfObjectHumanCase,null,a.idfsSite,b.idfsSite 
			--from @tlbHumanCase_BeforeEdit a  inner join @tlbHumanCase_AfterEdit b on a.idfHumanCase = b.idfHumanCase 
			--where (ISNULL(a.idfsSite,'') <> ISNULL(b.idfsSite,''))
		END
		--Data Audit - End
	END
	
    --Set Samples for this idfHumanCase	
    IF @SamplesParameters IS NOT NULL
    BEGIN
		--Data Audit - Samples - Start
		--Variables
		DECLARE @idfsObjectTypeSamples bigint = 10017079;
		DECLARE @idfObjectSamples bigint = NULL;
		DECLARE @idfObjectSamplesTable bigint = 75620000000;
		DECLARE @tlbSamples_BeforeEdit TABLE
		(
			idfMaterial BIGINT,
			idfsSampleType BIGINT,
			idfHuman BIGINT,
			idfSpecies BIGINT,
			idfAnimal BIGINT,
			idfMonitoringSession BIGINT,
			idfFieldCollectedByPerson BIGINT,
			idfFieldCollectedByOffice BIGINT,
			datFieldCollectionDate DATETIME,
			datFieldSentDate DATETIME,
			strFieldBarcode NVARCHAR(200),
			idfVectorSurveillanceSession BIGINT,
			idfVector BIGINT,
			strNote NVARCHAR(500),
			idfsSite BIGINT,
			idfSendToOffice BIGINT,
			blnReadOnly BIT,
			idfHumanCase BIGINT,
			idfVetCase BIGINT,
			DiseaseID BIGINT,
			idfsBirdStatus BIGINT
		)
		DECLARE @tlbSamples_AfterEdit TABLE
		(
			idfMaterial BIGINT,
			idfsSampleType BIGINT,
			idfHuman BIGINT,
			idfSpecies BIGINT,
			idfAnimal BIGINT,
			idfMonitoringSession BIGINT,
			idfFieldCollectedByPerson BIGINT,
			idfFieldCollectedByOffice BIGINT,
			datFieldCollectionDate DATETIME,
			datFieldSentDate DATETIME,
			strFieldBarcode NVARCHAR(200),
			idfVectorSurveillanceSession BIGINT,
			idfVector BIGINT,
			strNote NVARCHAR(500),
			idfsSite BIGINT,
			idfSendToOffice BIGINT,
			blnReadOnly BIT,
			idfHumanCase BIGINT,
			idfVetCase BIGINT,
			DiseaseID BIGINT,
			idfsBirdStatus BIGINT
		) 
		DECLARE @idfDataAuditEventSamples bigint= NULL; 
		--Data Audit - End

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
				
			--Data Audit - Start
			--Find Insert/Update/Delete
			IF @RowAction = 1
			BEGIN
				set @idfsDataAuditEventType = 10016001; --Insert
			END
			ELSE IF @RowAction <> 1 and @RowStatus = 1
			BEGIN  
				set @idfsDataAuditEventType = 10016002; --Delete
			END
			ELSE 
			BEGIN 
				set @idfsDataAuditEventType = 10016003; --Update
			END
			--Get values before edit
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				insert into @tlbSamples_BeforeEdit
				(idfMaterial,idfsSampleType,idfHuman,idfSpecies,idfAnimal,idfMonitoringSession,idfFieldCollectedByPerson,idfFieldCollectedByOffice
				,datFieldCollectionDate,datFieldSentDate,strFieldBarcode,idfVectorSurveillanceSession,idfVector,strNote,idfsSite,idfSendToOffice,blnReadOnly 
				,idfHumanCase,idfVetCase,DiseaseID,idfsBirdStatus)
				select idfMaterial,idfsSampleType,idfHuman,idfSpecies,idfAnimal,idfMonitoringSession,idfFieldCollectedByPerson,idfFieldCollectedByOffice
				,datFieldCollectionDate,datFieldSentDate,strFieldBarcode,idfVectorSurveillanceSession,idfVector,strNote,idfsSite,idfSendToOffice,blnReadOnly 
				,idfHumanCase,idfVetCase,DiseaseID,idfsBirdStatus
				from tlbMaterial 
				where idfMaterial = @SampleID;
			END
			--Data Audit - End

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_SAMPLE_SET @AuditUserName = @AuditUser,
                                            @SampleID = @SampleID OUTPUT,
                                            @SampleTypeID = @SampleTypeID,
                                            @RootSampleID = NULL,
                                            @ParentSampleID = NULL,
                                            @HumanID = @idfHuman,
                                            @SpeciesID = NULL,
                                            @AnimalID = NULL,
                                            @VectorID = NULL,
                                            @MonitoringSessionID = NULL,
                                            @VectorSessionID = NULL,
                                            @HumanDiseaseReportID = @SaveID,
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
												
			--Data Audit - Start
			--Get values After edit
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				insert into @tlbSamples_AfterEdit
				(idfMaterial,idfsSampleType,idfHuman,idfSpecies,idfAnimal,idfMonitoringSession,idfFieldCollectedByPerson,idfFieldCollectedByOffice
				,datFieldCollectionDate,datFieldSentDate,strFieldBarcode,idfVectorSurveillanceSession,idfVector,strNote,idfsSite,idfSendToOffice,blnReadOnly 
				,idfHumanCase,idfVetCase,DiseaseID,idfsBirdStatus)
				select idfMaterial,idfsSampleType,idfHuman,idfSpecies,idfAnimal,idfMonitoringSession,idfFieldCollectedByPerson,idfFieldCollectedByOffice
				,datFieldCollectionDate,datFieldSentDate,strFieldBarcode,idfVectorSurveillanceSession,idfVector,strNote,idfsSite,idfSendToOffice,blnReadOnly 
				,idfHumanCase,idfVetCase,DiseaseID,idfsBirdStatus
				from tlbMaterial 
				where idfMaterial = @SampleID;
			END 

			SET @idfObjectSamples = @SampleID 
			IF @idfsDataAuditEventType =10016001
			Begin
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeSamples,@idfObjectSamples, @idfObjectSamplesTable, @idfDataAuditEventSamples OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEventSamples, @idfObjectSamplesTable, @idfObjectSamples)
			END
			ELSE IF @idfsDataAuditEventType =10016002
			BEGIN
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeSamples,@idfObjectSamples, @idfObjectSamplesTable, @idfDataAuditEventSamples OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject) VALUES (@idfDataAuditEventSamples, @idfObjectSamplesTable, @idfObjectSamples)
			END
			ELSE IF @idfsDataAuditEventType =10016003
			BEGIN
				IF EXISTS 
				(
					select *
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial  
					where (ISNULL(a.idfsSampleType,'') <> ISNULL(b.idfsSampleType,'')) OR (ISNULL(a.idfHuman,'') <> ISNULL(b.idfHuman,'')) OR 
						(ISNULL(a.idfSpecies,'') <> ISNULL(b.idfSpecies,'')) OR (ISNULL(a.idfAnimal,'') <> ISNULL(b.idfAnimal,'')) OR 
						(ISNULL(a.idfMonitoringSession,'') <> ISNULL(b.idfMonitoringSession,'')) OR (ISNULL(a.idfFieldCollectedByPerson,'') <> ISNULL(b.idfFieldCollectedByPerson,'')) OR 
						(ISNULL(a.idfFieldCollectedByOffice,'') <> ISNULL(b.idfFieldCollectedByOffice,'')) OR (ISNULL(a.datFieldCollectionDate,'') <> ISNULL(b.datFieldCollectionDate,'')) OR 
						(ISNULL(a.datFieldSentDate,'') <> ISNULL(b.datFieldSentDate,'')) OR (ISNULL(a.strFieldBarcode,'') <> ISNULL(b.strFieldBarcode,'')) OR 
						(ISNULL(a.idfVectorSurveillanceSession,'') <> ISNULL(b.idfVectorSurveillanceSession,'')) OR (ISNULL(a.idfVector,'') <> ISNULL(b.idfVector,'')) OR 
						(ISNULL(a.strNote,'') <> ISNULL(b.strNote,'')) OR (ISNULL(a.idfsSite,'') <> ISNULL(b.idfsSite,'')) OR 
						(ISNULL(a.idfSendToOffice,'') <> ISNULL(b.idfSendToOffice,'')) OR (ISNULL(a.blnReadOnly,'') <> ISNULL(b.blnReadOnly,'')) OR 
						(ISNULL(a.idfHumanCase,'') <> ISNULL(b.idfHumanCase,'')) OR (ISNULL(a.idfVetCase,'') <> ISNULL(b.idfVetCase,'')) OR 
						(ISNULL(a.DiseaseID,'') <> ISNULL(b.DiseaseID,'')) OR (ISNULL(a.idfsBirdStatus,'') <> ISNULL(b.idfsBirdStatus,''))
				)
				BEGIN
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeSamples,@idfObjectSamples, @idfObjectSamplesTable, @idfDataAuditEventSamples OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,49545390000000,@idfObjectSamples,null,a.idfsSampleType,b.idfsSampleType 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfsSampleType,'') <> ISNULL(b.idfsSampleType,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4572430000000,@idfObjectSamples,null,a.idfHuman,b.idfHuman 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfHuman,'') <> ISNULL(b.idfHuman,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4572440000000,@idfObjectSamples,null,a.idfSpecies,b.idfSpecies 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfSpecies,'') <> ISNULL(b.idfSpecies,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4572450000000,@idfObjectSamples,null,a.idfAnimal,b.idfAnimal 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfAnimal,'') <> ISNULL(b.idfAnimal,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4572470000000,@idfObjectSamples,null,a.idfMonitoringSession,b.idfMonitoringSession 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfMonitoringSession,'') <> ISNULL(b.idfMonitoringSession,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,79950000000,@idfObjectSamples,null,a.idfFieldCollectedByPerson,b.idfFieldCollectedByPerson 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfFieldCollectedByPerson,'') <> ISNULL(b.idfFieldCollectedByPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,79940000000,@idfObjectSamples,null,a.idfFieldCollectedByOffice,b.idfFieldCollectedByOffice 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfFieldCollectedByOffice,'') <> ISNULL(b.idfFieldCollectedByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,79920000000,@idfObjectSamples,null,a.datFieldCollectionDate,b.datFieldCollectionDate 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.datFieldCollectionDate,'') <> ISNULL(b.datFieldCollectionDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,79930000000,@idfObjectSamples,null,a.datFieldSentDate,b.datFieldSentDate 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.datFieldSentDate,'') <> ISNULL(b.datFieldSentDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,80030000000,@idfObjectSamples,null,a.strFieldBarcode,b.strFieldBarcode 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.strFieldBarcode,'') <> ISNULL(b.strFieldBarcode,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4575190000000,@idfObjectSamples,null,a.idfVectorSurveillanceSession,b.idfVectorSurveillanceSession 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfVectorSurveillanceSession,'') <> ISNULL(b.idfVectorSurveillanceSession,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4575200000000,@idfObjectSamples,null,a.idfVector,b.idfVector 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfVector,'') <> ISNULL(b.idfVector,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4576420000000,@idfObjectSamples,null,a.strNote,b.strNote 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.strNote,'') <> ISNULL(b.strNote,''))

					--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					--select @idfDataAuditEventSamples,@idfObjectSamplesTable,49545430000000,@idfObjectSamples,null,a.idfsSite,b.idfsSite 
					--from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					--where (ISNULL(a.idfsSite,'') <> ISNULL(b.idfsSite,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4578720000000,@idfObjectSamples,null,a.idfSendToOffice,b.idfSendToOffice 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfSendToOffice,'') <> ISNULL(b.idfSendToOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,4578730000000,@idfObjectSamples,null,a.blnReadOnly,b.blnReadOnly 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.blnReadOnly,'') <> ISNULL(b.blnReadOnly,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,12665570000000,@idfObjectSamples,null,a.idfHumanCase,b.idfHumanCase 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfHumanCase,'') <> ISNULL(b.idfHumanCase,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,12665580000000,@idfObjectSamples,null,a.idfVetCase,b.idfVetCase 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfVetCase,'') <> ISNULL(b.idfVetCase,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,51586990000035,@idfObjectSamples,null,a.DiseaseID,b.DiseaseID 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.DiseaseID,'') <> ISNULL(b.DiseaseID,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventSamples,@idfObjectSamplesTable,12014480000000,@idfObjectSamples,null,a.idfsBirdStatus,b.idfsBirdStatus 
					from @tlbSamples_BeforeEdit a  inner join @tlbSamples_AfterEdit b on a.idfMaterial = b.idfMaterial 
					where (ISNULL(a.idfsBirdStatus,'') <> ISNULL(b.idfsBirdStatus,''))
				END
			END
			--Data Audit - End

            UPDATE @TestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID

            DELETE FROM @SamplesTemp
            WHERE SampleID = @RowID
        END
    END
		
    --Set Tests for this idfHumanCase	
    IF @TestsParameters IS NOT NULL
    BEGIN		
		--Data Audit - Tests - Start
		-- Variables
		DECLARE @idfsObjectTypeTests bigint = 10017079;
		DECLARE @idfObjectTests bigint = NULL;
		DECLARE @idfObjectTestsTable bigint = 75740000000;
		DECLARE @tlbTests_BeforeEdit TABLE
		(
			idfTesting BIGINT,
			idfsTestName BIGINT,
			idfsTestCategory BIGINT,
			idfsTestResult BIGINT,
			idfsTestStatus BIGINT,
			idfsDiagnosis BIGINT,
			idfMaterial BIGINT,
			idfBatchTest BIGINT,
			idfObservation BIGINT,
			intTestNumber INT,
			strNote NVARCHAR(500),
			intRowStatus INT,
			datStartedDate DATETIME,
			datConcludedDate DATETIME,
			idfTestedByOffice BIGINT,
			idfTestedByPerson BIGINT,
			idfResultEnteredByOffice BIGINT,
			idfResultEnteredByPerson BIGINT,
			idfValidatedByOffice BIGINT,
			idfValidatedByPerson BIGINT,
			blnReadOnly BIT,
			blnNonLaboratoryTest BIT,
			blnExternalTest BIT,
			idfPerformedByOffice BIGINT,
			datReceivedDate DATETIME,
			strContactPerson NVARCHAR(200),
			idfMonitoringSession BIGINT,
			idfVector BIGINT,
			idfHumanCase BIGINT,
			idfVetCase BIGINT
		)
		DECLARE @tlbTests_AfterEdit TABLE
		(
			idfTesting BIGINT,
			idfsTestName BIGINT,
			idfsTestCategory BIGINT,
			idfsTestResult BIGINT,
			idfsTestStatus BIGINT,
			idfsDiagnosis BIGINT,
			idfMaterial BIGINT,
			idfBatchTest BIGINT,
			idfObservation BIGINT,
			intTestNumber INT,
			strNote NVARCHAR(500),
			intRowStatus INT,
			datStartedDate DATETIME,
			datConcludedDate DATETIME,
			idfTestedByOffice BIGINT,
			idfTestedByPerson BIGINT,
			idfResultEnteredByOffice BIGINT,
			idfResultEnteredByPerson BIGINT,
			idfValidatedByOffice BIGINT,
			idfValidatedByPerson BIGINT,
			blnReadOnly BIT,
			blnNonLaboratoryTest BIT,
			blnExternalTest BIT,
			idfPerformedByOffice BIGINT,
			datReceivedDate DATETIME,
			strContactPerson NVARCHAR(200),
			idfMonitoringSession BIGINT,
			idfVector BIGINT,
			idfHumanCase BIGINT,
			idfVetCase BIGINT
		)
		DECLARE @idfDataAuditEventTests bigint= NULL; 
		--Data Audit - End
	
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
				
            --If record is being soft-deleted, then check if the test record was originally created 
            --in the laboaratory module.  If it was, then disassociate the test record from the 
            --human monitoring session, so that the test record remains in the laboratory module 
            --for further action.
            IF @RowStatus = 1
                AND @NonLaboratoryTestIndicator = 0
            BEGIN
                SET @RowStatus = 0;
            END
            ELSE
            BEGIN
                SET @TestHumanCaseID = @TestHumanCaseId
            END;
				
			--Data Audit - Start
			--Find Insert/Update/Delete
			IF @RowAction = 1
			BEGIN
				set @idfsDataAuditEventType = 10016001; --Insert
			END
			ELSE IF @RowAction <> 1 and @RowStatus = 1
			BEGIN  
				set @idfsDataAuditEventType = 10016002; --Delete
			END
			ELSE 
			BEGIN 
				set @idfsDataAuditEventType = 10016003; --Update
			END
			--Get values before edit
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				insert into @tlbTests_BeforeEdit
				(idfTesting,idfsTestName,idfsTestCategory,idfsTestResult,idfsTestStatus,idfsDiagnosis,idfMaterial,idfBatchTest,idfObservation,intTestNumber,strNote,intRowStatus
				,datStartedDate,datConcludedDate,idfTestedByOffice,idfTestedByPerson,idfResultEnteredByOffice,idfResultEnteredByPerson,idfValidatedByOffice
				,idfValidatedByPerson,blnReadOnly,blnNonLaboratoryTest,blnExternalTest,idfPerformedByOffice,datReceivedDate,strContactPerson
				,idfMonitoringSession,idfVector,idfHumanCase,idfVetCase)
				select idfTesting,idfsTestName,idfsTestCategory,idfsTestResult,idfsTestStatus,idfsDiagnosis,idfMaterial,idfBatchTest,idfObservation,intTestNumber,strNote,intRowStatus
				,datStartedDate,datConcludedDate,idfTestedByOffice,idfTestedByPerson,idfResultEnteredByOffice,idfResultEnteredByPerson,idfValidatedByOffice
				,idfValidatedByPerson,blnReadOnly,blnNonLaboratoryTest,blnExternalTest,idfPerformedByOffice,datReceivedDate,strContactPerson
				,idfMonitoringSession,idfVector,idfHumanCase,idfVetCase
				from tlbTesting 
				where idfTesting = @TestID
			END
			--Data Audit - End

            --Set Tests for this idfHumanCase
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TEST_SET @LanguageID = @LanguageID,
                                            @TestID = @TestID OUTPUT,
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
                                            @MonitoringSessionID = NULL,
                                            @VectorSessionID = NULL,
                                            @HumanDiseaseReportID = @SaveID,
                                            @VeterinaryDiseaseReportID = NULL,
                                            @AuditUserName = @AuditUser,
                                            @RowAction = @RowAction;
						  
			--Data Audit - Start
			--Get values After edit
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				insert into @tlbTests_AfterEdit
				(idfTesting,idfsTestName,idfsTestCategory,idfsTestResult,idfsTestStatus,idfsDiagnosis,idfMaterial,idfBatchTest,idfObservation,intTestNumber,strNote,intRowStatus
				,datStartedDate,datConcludedDate,idfTestedByOffice,idfTestedByPerson,idfResultEnteredByOffice,idfResultEnteredByPerson,idfValidatedByOffice
				,idfValidatedByPerson,blnReadOnly,blnNonLaboratoryTest,blnExternalTest,idfPerformedByOffice,datReceivedDate,strContactPerson
				,idfMonitoringSession,idfVector,idfHumanCase,idfVetCase)
				select idfTesting,idfsTestName,idfsTestCategory,idfsTestResult,idfsTestStatus,idfsDiagnosis,idfMaterial,idfBatchTest,idfObservation,intTestNumber,strNote,intRowStatus
				,datStartedDate,datConcludedDate,idfTestedByOffice,idfTestedByPerson,idfResultEnteredByOffice,idfResultEnteredByPerson,idfValidatedByOffice
				,idfValidatedByPerson,blnReadOnly,blnNonLaboratoryTest,blnExternalTest,idfPerformedByOffice,datReceivedDate,strContactPerson
				,idfMonitoringSession,idfVector,idfHumanCase,idfVetCase
				from tlbTesting 
				where idfTesting = @TestID
			END 

			SET @idfObjectTests = @TestID 
			IF @idfsDataAuditEventType =10016001
			Begin
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeTests,@idfObjectTests, @idfObjectTestsTable, @idfDataAuditEventTests OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEventTests, @idfObjectTestsTable, @idfObjectTests)
			END
			ELSE IF @idfsDataAuditEventType =10016002
			BEGIN
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeTests,@idfObjectTests, @idfObjectTestsTable, @idfDataAuditEventTests OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject) VALUES (@idfDataAuditEventTests, @idfObjectTestsTable, @idfObjectTests)
			END
			ELSE IF @idfsDataAuditEventType =10016003
			BEGIN
				IF EXISTS 
				(
					select *
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting  
					where (ISNULL(a.idfsTestName,'') <> ISNULL(b.idfsTestName,'')) OR (ISNULL(a.idfsTestCategory,'') <> ISNULL(b.idfsTestCategory,'')) OR 
						(ISNULL(a.idfsTestResult,'') <> ISNULL(b.idfsTestResult,'')) OR (ISNULL(a.idfsTestStatus,'') <> ISNULL(b.idfsTestStatus,'')) OR 
						(ISNULL(a.idfsDiagnosis,'') <> ISNULL(b.idfsDiagnosis,'')) OR (ISNULL(a.idfMaterial,'') <> ISNULL(b.idfMaterial,'')) OR 
						(ISNULL(a.idfBatchTest,'') <> ISNULL(b.idfBatchTest,'')) OR (ISNULL(a.idfObservation,'') <> ISNULL(b.idfObservation,'')) OR 
						(ISNULL(a.intTestNumber,'') <> ISNULL(b.intTestNumber,'')) OR (ISNULL(a.strNote,'') <> ISNULL(b.strNote,'')) OR 
						(ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,'')) OR (ISNULL(a.datStartedDate,'') <> ISNULL(b.datStartedDate,'')) OR 
						(ISNULL(a.datConcludedDate,'') <> ISNULL(b.datConcludedDate,'')) OR (ISNULL(a.idfTestedByOffice,'') <> ISNULL(b.idfTestedByOffice,'')) OR 
						(ISNULL(a.idfTestedByPerson,'') <> ISNULL(b.idfTestedByPerson,'')) OR (ISNULL(a.idfResultEnteredByOffice,'') <> ISNULL(b.idfResultEnteredByOffice,'')) OR 
						(ISNULL(a.idfResultEnteredByPerson,'') <> ISNULL(b.idfResultEnteredByPerson,'')) OR (ISNULL(a.idfValidatedByOffice,'') <> ISNULL(b.idfValidatedByOffice,'')) OR 
						(ISNULL(a.idfValidatedByPerson,'') <> ISNULL(b.idfValidatedByPerson,'')) OR (ISNULL(a.blnReadOnly,'') <> ISNULL(b.blnReadOnly,'')) OR 
						(ISNULL(a.blnNonLaboratoryTest,'') <> ISNULL(b.blnNonLaboratoryTest,'')) OR (ISNULL(a.blnExternalTest,'') <> ISNULL(b.blnExternalTest,'')) OR 
						(ISNULL(a.idfPerformedByOffice,'') <> ISNULL(b.idfPerformedByOffice,'')) OR (ISNULL(a.datReceivedDate,'') <> ISNULL(b.datReceivedDate,'')) OR 
						(ISNULL(a.strContactPerson,'') <> ISNULL(b.strContactPerson,'')) OR (ISNULL(a.idfMonitoringSession,'') <> ISNULL(b.idfMonitoringSession,'')) OR 
						(ISNULL(a.idfVector,'') <> ISNULL(b.idfVector,'')) OR (ISNULL(a.idfHumanCase,'') <> ISNULL(b.idfHumanCase,'')) OR (ISNULL(a.idfVetCase,'') <> ISNULL(b.idfVetCase,''))
				)
				BEGIN
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeTests,@idfObjectTests, @idfObjectTestsTable, @idfDataAuditEventTests OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,49545430000000,@idfObjectTests,null,a.idfsTestName,b.idfsTestName 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfsTestName,'') <> ISNULL(b.idfsTestName,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,49545440000000,@idfObjectTests,null,a.idfsTestCategory,b.idfsTestCategory 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfsTestCategory,'') <> ISNULL(b.idfsTestCategory,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,80510000000,@idfObjectTests,null,a.idfsTestResult,b.idfsTestResult 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfsTestResult,'') <> ISNULL(b.idfsTestResult,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4572510000000,@idfObjectTests,null,a.idfsTestStatus,b.idfsTestStatus 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfsTestStatus,'') <> ISNULL(b.idfsTestStatus,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4572520000000,@idfObjectTests,null,a.idfsDiagnosis,b.idfsDiagnosis 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfsDiagnosis,'') <> ISNULL(b.idfsDiagnosis,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4576430000000,@idfObjectTests,null,a.idfMaterial,b.idfMaterial 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfMaterial,'') <> ISNULL(b.idfMaterial,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,80470000000,@idfObjectTests,null,a.idfBatchTest,b.idfBatchTest 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfBatchTest,'') <> ISNULL(b.idfBatchTest,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,80500000000,@idfObjectTests,null,a.idfObservation,b.idfObservation 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfObservation,'') <> ISNULL(b.idfObservation,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,80540000000,@idfObjectTests,null,a.intTestNumber,b.intTestNumber 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.intTestNumber,'') <> ISNULL(b.intTestNumber,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4572540000000,@idfObjectTests,null,a.strNote,b.strNote 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.strNote,'') <> ISNULL(b.strNote,''))

					--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					--select @idfDataAuditEventTests,@idfObjectTestsTable,51586990000032,@idfObjectTests,null,a.intRowStatus,b.intRowStatus 
					--from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					--where (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578540000000,@idfObjectTests,null,a.datStartedDate,b.datStartedDate 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.datStartedDate,'') <> ISNULL(b.datStartedDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578550000000,@idfObjectTests,null,a.datConcludedDate,b.datConcludedDate 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.datConcludedDate,'') <> ISNULL(b.datConcludedDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578560000000,@idfObjectTests,null,a.idfTestedByOffice,b.idfTestedByOffice 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfTestedByOffice,'') <> ISNULL(b.idfTestedByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578570000000,@idfObjectTests,null,a.idfTestedByPerson,b.idfTestedByPerson 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfTestedByPerson,'') <> ISNULL(b.idfTestedByPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578580000000,@idfObjectTests,null,a.idfResultEnteredByOffice,b.idfResultEnteredByOffice 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfResultEnteredByOffice,'') <> ISNULL(b.idfResultEnteredByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578590000000,@idfObjectTests,null,a.idfResultEnteredByPerson,b.idfResultEnteredByPerson 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfResultEnteredByPerson,'') <> ISNULL(b.idfResultEnteredByPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578600000000,@idfObjectTests,null,a.idfValidatedByOffice,b.idfValidatedByOffice 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfValidatedByOffice,'') <> ISNULL(b.idfValidatedByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578610000000,@idfObjectTests,null,a.idfValidatedByPerson,b.idfValidatedByPerson 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfValidatedByPerson,'') <> ISNULL(b.idfValidatedByPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578740000000,@idfObjectTests,null,a.blnReadOnly,b.blnReadOnly 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.blnReadOnly,'') <> ISNULL(b.blnReadOnly,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,4578760000000,@idfObjectTests,null,a.blnNonLaboratoryTest,b.blnNonLaboratoryTest 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.blnNonLaboratoryTest,'') <> ISNULL(b.blnNonLaboratoryTest,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,50815850000000,@idfObjectTests,null,a.blnExternalTest,b.blnExternalTest 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.blnExternalTest,'') <> ISNULL(b.blnExternalTest,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,50815860000000,@idfObjectTests,null,a.idfPerformedByOffice,b.idfPerformedByOffice 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfPerformedByOffice,'') <> ISNULL(b.idfPerformedByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,50815870000000,@idfObjectTests,null,a.datReceivedDate,b.datReceivedDate 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.datReceivedDate,'') <> ISNULL(b.datReceivedDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,50815880000000,@idfObjectTests,null,a.strContactPerson,b.strContactPerson 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.strContactPerson,'') <> ISNULL(b.strContactPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,51586990000028,@idfObjectTests,null,a.idfMonitoringSession,b.idfMonitoringSession 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfMonitoringSession,'') <> ISNULL(b.idfMonitoringSession,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,51586990000031,@idfObjectTests,null,a.idfVector,b.idfVector 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfVector,'') <> ISNULL(b.idfVector,''))

					--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					--select @idfDataAuditEventTests,@idfObjectTestsTable,51586790000001,@idfObjectTests,null,a.idfHumanCase,b.idfHumanCase 
					--from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					--where (ISNULL(a.idfHumanCase,'') <> ISNULL(b.idfHumanCase,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTests,@idfObjectTestsTable,51586990000030,@idfObjectTests,null,a.idfVetCase,b.idfVetCase 
					from @tlbTests_BeforeEdit a  inner join @tlbTests_AfterEdit b on a.idfTesting = b.idfTesting 
					where (ISNULL(a.idfVetCase,'') <> ISNULL(b.idfVetCase,''))
				END
			END
			--Data Audit - End

            UPDATE @TestsInterpretationParametersTemp
            SET TestID = @TestID
            WHERE TestID = @RowID

            DELETE FROM @TestsTemp
            WHERE TestID = @RowID;
        END;
    END

	BEGIN --Data Audit - No need.
    Declare @sampleCount int
    Set @sampleCount =
    (
        SELECT Count(*)
        FROM dbo.tlbMaterial
        WHERE intRowStatus = 0
                and idfHumanCase = @SurvivorDiseaseReportID
    )

    IF EXISTS
    (
        SELECT *
        FROM dbo.tlbHumanCase
        WHERE idfHumanCase = @SaveID
                AND idfsYNSpecimenCollected = 10100002
    )
    Begin
        UPDATE dbo.tlbMaterial
        SET intRowStatus = 1,
            AuditUpdateUser = @AuditUser
        WHERE idfHumanCase = @SaveID
    END
    ELSE IF EXISTS
    (
        SELECT *
        FROM dbo.tlbHumanCase
        WHERE idfHumanCase = @SaveID
                AND idfsYNSpecimenCollected = 10100003
    )
    BEGIN
        UPDATE dbo.tlbHumanCase
        SET idfsNotCollectedReason = NULL,
            AuditUpdateUser = @AuditUser
        WHERE idfHumanCase = @SaveID;

        UPDATE dbo.tlbMaterial
        SET intRowStatus = 1,
            AuditUpdateUser = @AuditUser
        WHERE idfHumanCase = @SaveID;
    END
    ELSE IF EXISTS
    (
        SELECT *
        FROM dbo.tlbHumanCase
        WHERE idfHumanCase = @SaveID
                AND idfsYNSpecimenCollected = 10100001
    )
    BEGIN
        UPDATE dbo.tlbHumanCase
        SET idfsNotCollectedReason = NULL,
            AuditUpdateUser = @AuditUser
        WHERE idfHumanCase = @SaveID
        IF (@sampleCount = 0)
        BEGIN
            UPDATE dbo.tlbHumanCase
            SET idfsYNSpecimenCollected = NULL,
                AuditUpdateUser = @AuditUser
            WHERE idfHumanCase = @SaveID
        END
    END
	END
		 
    --Set TestsInterpretation for this idfHumanCase
    IF @TestsInterpretationParameters IS NOT NULL
    BEGIN 
		--Data Audit - TestsInterpretation - Start
		-- Variables
		DECLARE @idfsObjectTypeTestInterpretations bigint = 10017079;
		DECLARE @idfObjectTestInterpretations bigint = NULL;
		DECLARE @idfObjectTestInterpretationsTable bigint = 75750000000;
		DECLARE @tlbTestInterpretations_BeforeEdit TABLE
		(
			idfTestValidation BIGINT,
			idfsDiagnosis BIGINT,
			idfsInterpretedStatus BIGINT,
			idfValidatedByOffice BIGINT,
			idfValidatedByPerson BIGINT,
			idfInterpretedByOffice BIGINT,
			idfInterpretedByPerson BIGINT,
			idfTesting BIGINT,
			blnValidateStatus BIT,
			blnCaseCreated BIT,
			strValidateComment NVARCHAR(200),
			strInterpretedComment NVARCHAR(200),
			datValidationDate DATETIME,
			datInterpretationDate DATETIME,
			intRowStatus INT,
			blnReadOnly BIT 
		)
		DECLARE @tlbTestInterpretations_AfterEdit TABLE
		(
			idfTestValidation BIGINT,
			idfsDiagnosis BIGINT,
			idfsInterpretedStatus BIGINT,
			idfValidatedByOffice BIGINT,
			idfValidatedByPerson BIGINT,
			idfInterpretedByOffice BIGINT,
			idfInterpretedByPerson BIGINT,
			idfTesting BIGINT,
			blnValidateStatus BIT,
			blnCaseCreated BIT,
			strValidateComment NVARCHAR(200),
			strInterpretedComment NVARCHAR(200),
			datValidationDate DATETIME,
			datInterpretationDate DATETIME,
			intRowStatus INT,
			blnReadOnly BIT
		)
		DECLARE @idfDataAuditEventTestInterpretations bigint= NULL; 
		--Data Audit - End
	
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
				
			--Data Audit - Start
			--Find Insert/Update/Delete
			IF @RowAction = 1
			BEGIN
				set @idfsDataAuditEventType = 10016001; --Insert
			END
			ELSE IF @RowAction <> 1 and @RowStatus = 1
			BEGIN  
				set @idfsDataAuditEventType = 10016002; --Delete
			END
			ELSE 
			BEGIN 
				set @idfsDataAuditEventType = 10016003; --Update
			END

			--Get values before edit
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				insert into @tlbTestInterpretations_BeforeEdit
				(idfTestValidation,idfsDiagnosis,idfsInterpretedStatus,idfValidatedByOffice,idfValidatedByPerson,idfInterpretedByOffice,idfInterpretedByPerson,idfTesting
				,blnValidateStatus,blnCaseCreated,strValidateComment,strInterpretedComment,datValidationDate,datInterpretationDate,intRowStatus,blnReadOnly)
				select idfTestValidation,idfsDiagnosis,idfsInterpretedStatus,idfValidatedByOffice,idfValidatedByPerson,idfInterpretedByOffice,idfInterpretedByPerson,idfTesting
				,blnValidateStatus,blnCaseCreated,strValidateComment,strInterpretedComment,datValidationDate,datInterpretationDate,intRowStatus,blnReadOnly
				from tlbTestValidation 
				where idfTestValidation = @TestInterpretationID
			END
			--Data Audit - End

            INSERT INTO @SuppressSelect
            EXEC dbo.USSP_GBL_TEST_INTERPRETATION_SET @AuditUserName = @AuditUser,
                                                        @TestInterpretationID = @TestInterpretationID OUTPUT,
                                                        @DiseaseID = @DiseaseID,
                                                        @InterpretedStatusTypeID = @InterpretedStatusTypeID,
                                                        @ValidatedByOrganizationID = @ValidatedByOrganizationID,
                                                        @ValidatedByPersonID = @ValidatedByPersonID,
                                                        @InterpretedByOrganizationID = @InterpretedByOrganizationID,
                                                        @InterpretedByPersonID = @InterpretedByPersonID,
                                                        @TestID = @TestID,
                                                        @ValidateStatusIndicator = @ValidatedStatusIndicator,
                                                        @ReportSessionCreatedIndicator = @ReportSessionCreatedIndicator,
                                                        @ValidationComment = @ValidatedComment,
                                                        @InterpretationComment = @InterpretedComment,
                                                        @ValidationDate = @ValidatedDate,
                                                        @InterpretationDate = @InterpretedDate,
                                                        @RowStatus = @RowStatus,
                                                        @ReadOnlyIndicator = @ReadOnlyIndicator,
                                                        @RowAction = @RowAction;

			--Data Audit - Start
			--Get values after edit
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				insert into @tlbTestInterpretations_AfterEdit
				(idfTestValidation,idfsDiagnosis,idfsInterpretedStatus,idfValidatedByOffice,idfValidatedByPerson,idfInterpretedByOffice,idfInterpretedByPerson,idfTesting
				,blnValidateStatus,blnCaseCreated,strValidateComment,strInterpretedComment,datValidationDate,datInterpretationDate,intRowStatus,blnReadOnly)
				select idfTestValidation,idfsDiagnosis,idfsInterpretedStatus,idfValidatedByOffice,idfValidatedByPerson,idfInterpretedByOffice,idfInterpretedByPerson,idfTesting
				,blnValidateStatus,blnCaseCreated,strValidateComment,strInterpretedComment,datValidationDate,datInterpretationDate,intRowStatus,blnReadOnly
				from tlbTestValidation 
				where idfTestValidation = @TestInterpretationID
			END 

			SET @idfObjectTestInterpretations = @TestID 
			IF @idfsDataAuditEventType =10016001
			Begin
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeTestInterpretations,@idfObjectTestInterpretations, 
					@idfObjectTestInterpretationsTable, @idfDataAuditEventTestInterpretations OUTPUT

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
					values ( @idfDataAuditEventTestInterpretations, @idfObjectTestInterpretationsTable, @idfObjectTestInterpretations)
			END
			ELSE IF @idfsDataAuditEventType =10016002
			BEGIN
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeTestInterpretations,@idfObjectTestInterpretations
					, @idfObjectTestInterpretationsTable, @idfDataAuditEventTestInterpretations OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject) 
				VALUES (@idfDataAuditEventTestInterpretations, @idfObjectTestInterpretationsTable, @idfObjectTestInterpretations)
			END
			ELSE IF @idfsDataAuditEventType =10016003
			BEGIN
				IF EXISTS 
				(
					select *
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation  
					where (ISNULL(a.idfsDiagnosis,'') <> ISNULL(b.idfsDiagnosis,'')) OR (ISNULL(a.idfsInterpretedStatus,'') <> ISNULL(b.idfsInterpretedStatus,'')) OR 
						(ISNULL(a.idfValidatedByOffice,'') <> ISNULL(b.idfValidatedByOffice,'')) OR (ISNULL(a.idfValidatedByPerson,'') <> ISNULL(b.idfValidatedByPerson,'')) OR 
						(ISNULL(a.idfInterpretedByOffice,'') <> ISNULL(b.idfInterpretedByOffice,'')) OR (ISNULL(a.idfInterpretedByPerson,'') <> ISNULL(b.idfInterpretedByPerson,'')) OR 
						(ISNULL(a.idfTesting,'') <> ISNULL(b.idfTesting,'')) OR (ISNULL(a.blnValidateStatus,'') <> ISNULL(b.blnValidateStatus,'')) OR 
						(ISNULL(a.blnCaseCreated,'') <> ISNULL(b.blnCaseCreated,'')) OR (ISNULL(a.strValidateComment,'') <> ISNULL(b.strValidateComment,'')) OR 
						(ISNULL(a.strInterpretedComment,'') <> ISNULL(b.strInterpretedComment,'')) OR (ISNULL(a.datValidationDate,'') <> ISNULL(b.datValidationDate,'')) OR 
						(ISNULL(a.datInterpretationDate,'') <> ISNULL(b.datInterpretationDate,'')) OR (ISNULL(a.intRowStatus,'') <> ISNULL(b.intRowStatus,'')) OR 
						(ISNULL(a.blnReadOnly,'') <> ISNULL(b.blnReadOnly,''))
				)
				BEGIN
					INSERT INTO @SuppressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectTypeTestInterpretations,@idfObjectTestInterpretations, 
						@idfObjectTestInterpretationsTable, @idfDataAuditEventTestInterpretations OUTPUT

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80580000000,@idfObjectTestInterpretations,null,a.idfsDiagnosis,b.idfsDiagnosis 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfsDiagnosis,'') <> ISNULL(b.idfsDiagnosis,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80590000000,@idfObjectTestInterpretations,null,a.idfsInterpretedStatus,b.idfsInterpretedStatus 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfsInterpretedStatus,'') <> ISNULL(b.idfsInterpretedStatus,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80610000000,@idfObjectTestInterpretations,null,a.idfValidatedByOffice,b.idfValidatedByOffice 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfValidatedByOffice,'') <> ISNULL(b.idfValidatedByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80620000000,@idfObjectTestInterpretations,null,a.idfValidatedByPerson,b.idfValidatedByPerson 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfValidatedByPerson,'') <> ISNULL(b.idfValidatedByPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80560000000,@idfObjectTestInterpretations,null,a.idfInterpretedByOffice,b.idfInterpretedByOffice 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfInterpretedByOffice,'') <> ISNULL(b.idfInterpretedByOffice,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80570000000,@idfObjectTestInterpretations,null,a.idfInterpretedByPerson,b.idfInterpretedByPerson 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfInterpretedByPerson,'') <> ISNULL(b.idfInterpretedByPerson,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80600000000,@idfObjectTestInterpretations,null,a.idfTesting,b.idfTesting 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.idfTesting,'') <> ISNULL(b.idfTesting,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80550000000,@idfObjectTestInterpretations,null,a.blnValidateStatus,b.blnValidateStatus 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.blnValidateStatus,'') <> ISNULL(b.blnValidateStatus,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,4572560000000,@idfObjectTestInterpretations,null,a.blnCaseCreated,b.blnCaseCreated 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.blnCaseCreated,'') <> ISNULL(b.blnCaseCreated,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80640000000,@idfObjectTestInterpretations,null,a.strValidateComment,b.strValidateComment 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.strValidateComment,'') <> ISNULL(b.strValidateComment,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,80630000000,@idfObjectTestInterpretations,null,a.strInterpretedComment,b.strInterpretedComment 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.strInterpretedComment,'') <> ISNULL(b.strInterpretedComment,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,4572570000000,@idfObjectTestInterpretations,null,a.datValidationDate,b.datValidationDate 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.datValidationDate,'') <> ISNULL(b.datValidationDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,4572580000000,@idfObjectTestInterpretations,null,a.datInterpretationDate,b.datInterpretationDate 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.datInterpretationDate,'') <> ISNULL(b.datInterpretationDate,''))

					insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn,idfObject, idfObjectDetail,strOldValue, strNewValue)
					select @idfDataAuditEventTestInterpretations,@idfObjectTestInterpretationsTable,6617410000000,@idfObjectTestInterpretations,null,a.blnReadOnly,b.blnReadOnly 
					from @tlbTestInterpretations_BeforeEdit a  inner join @tlbTestInterpretations_AfterEdit b on a.idfTestValidation = b.idfTestValidation 
					where (ISNULL(a.blnReadOnly,'') <> ISNULL(b.blnReadOnly,''))
				END
			END
			--Data Audit - End

            DELETE FROM @TestsInterpretationParametersTemp
            WHERE TestInterpretationID = @RowID;
        END;
    END

	--Data Audit - No need.
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
        EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                        @EventTypeId,
                                        @EventUserId,
                                        @EventObjectId,
                                        @EventDiseaseId,
                                        @EventSiteId,
                                        @EventInformationString,
                                        @EventLoginSiteId,
                                        @EventLocationId,
                                        @AuditUser;

        DELETE FROM @EventsTemp
        WHERE EventId = @EventId;
    END;

	BEGIN --Data Audit - No need. 
    --------set AntiviralTherapies for this idfHumanCase
    IF @AntiviralTherapiesParameters IS NOT NULL
    BEGIN

        EXEC dbo.USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET @idfHumanCase = @SaveID,
                                                            @AntiviralTherapiesParameters = @AntiviralTherapiesParameters,
                                                            @outbreakCall = 0,
                                                            @User = @AuditUser
    END
    --------set Vaccinations for this idfHumanCase
    IF @VaccinationsParameters IS NOT NULL
    BEGIN
        EXEC dbo.USSP_HUMAN_DISEASE_VACCINATIONS_DEDUP_SET @idfHumanCase = @SaveID,
                                                            @VaccinationsParameters = @VaccinationsParameters,
                                                            @outbreakCall = 0,
                                                            @User = @AuditUser
    END
	--------set Contacts for this idfHumanCase
    IF @ContactsParameters IS NOT NULL
    BEGIN
        EXEC dbo.USSP_GBL_CONTACT_DEDUP_SET @Contacts = @ContactsParameters,
                                            @SiteID = @CurrentSiteID,
                                            @AuditUSerName = @AuditUser,
                                            @idfHumanCase = @SaveID
    END
    ------ UPDATE tlbHuman IF datDateofDeath is provided.
    IF @datDateofDeath IS NOT NULL
    BEGIN
        UPDATE dbo.tlbHuman
        SET datDateofDeath = @datDateofDeath,
            AuditUpdateUser = @AuditUser
        WHERE idfHuman = @idfHuman
    END
    ----------------------------------------------------------------------------------------------------------------
    ------ delete the Superseded disease report
    BEGIN
        PRINT 'Delete superseded record'

        INSERT INTO @SuppressSelect
        (
            ReturnCode,
            ReturnMessage
        )
        EXEC dbo.USP_HUM_HUMAN_DISEASE_DEL @idfHumanCase = @SupersededDiseaseReportID,
				@idfUserID = @EventUserId,
				@idfSiteId = @idfsSite,
				@DeduplicationIndicator = 1 -- deduplication
    END;
    ----------------------------------------------------------------------------------------------------------------
    ------ remove tests associated with samples that aren't associated with survivor disease report
    UPDATE dbo.tlbTesting
    SET intRowStatus = 1,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE idfMaterial IN (
                                SELECT idfMaterial
                                FROM dbo.tlbMaterial
                                WHERE (
                                        idfHumanCase = @SaveID
                                        OR idfHumanCase = @DeleteID
                                    )
                                    AND idfMaterial NOT IN (
                                                                SELECT SampleID FROM @SamplesTemp2
                                                            )
                            )
    ----------------------------------------------------------------------------------------------------------------
    ------ remove test interpretations associated with samples that aren't associated with survivor disease report
    UPDATE dbo.tlbTestValidation
    SET intRowStatus = 1,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE idfTesting IN (
                            SELECT idfTesting
                            FROM dbo.tlbTesting
                            WHERE idfMaterial IN (
                                                        SELECT idfMaterial
                                                        FROM dbo.tlbMaterial
                                                        WHERE (
                                                                idfHumanCase = @SaveID
                                                                OR idfHumanCase = @DeleteID
                                                            )
                                                            AND idfMaterial NOT IN (
                                                                                        SELECT SampleID FROM @SamplesTemp2
                                                                                    )
                                                    )
                        )
    ----------------------------------------------------------------------------------------------------------------
    ------ remove penside tests associated with samples that aren't associated with survivor disease report
    UPDATE dbo.tlbPensideTest
    SET intRowStatus = 1,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE idfMaterial IN (
                                SELECT idfMaterial
                                FROM dbo.tlbMaterial
                                WHERE (
                                        idfHumanCase = @SaveID
                                        OR idfHumanCase = @DeleteID
                                    )
                                    AND idfMaterial NOT IN (
                                                                SELECT SampleID FROM @SamplesTemp2
                                                            )
                            )
    ------ disease report samples that are no longer needed
    UPDATE dbo.tlbMaterial
    SET idfHumanCase = NULL,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE (
                idfHumanCase = @SaveID
                OR idfHumanCase = @DeleteID
            )
            AND idfMaterial NOT IN (
                                        SELECT SampleID FROM @SamplesTemp2
                                    )
    ------ remove AntiMicrobialTherapy records from superseded report
    UPDATE dbo.tlbAntimicrobialTherapy
    SET intRowStatus = 1,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE (
                idfHumanCase = @SaveID
                OR idfHumanCase = @DeleteID
            )
            AND idfAntimicrobialTherapy NOT IN (
                                                    SELECT idfAntimicrobialTherapy FROM @AntiViralTemp
                                                )
    ------ remove vaccination records from superseded report
    UPDATE dbo.HumanDiseaseReportVaccination
    SET intRowStatus = 1,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE (
                idfHumanCase = @SaveID
                OR idfHumanCase = @DeleteID
            )
            AND humanDiseaseReportVaccinationUID NOT IN (
                                                            SELECT humanDiseaseReportVaccinationUID FROM @VaccinationsTemp
                                                        )
    ------ remove vaccination records from superseded report
    UPDATE dbo.tlbContactedCasePerson
    SET intRowStatus = 1,
        AuditUpdateUser = @AuditUser,
        AuditUpdateDTM = GETDATE()
    WHERE (
                idfHumanCase = @SaveID
                OR idfHumanCase = @DeleteID
            )
            AND idfContactedCasePerson NOT IN (
                                                SELECT ContactedCasePersonId FROM @ContactsTemp
                                            )
		
	END

    IF @@TRANCOUNT > 0
        COMMIT TRAN

    SELECT @ReturnCode AS ReturnCode,
            @ReturnMsg AS ReturnMessage,
            @SurvivorDiseaseReportID AS SurvivorDiseaseReportID,
            @strHumanCaseId AS strHumanCaseID,
            @HumanID AS idfHuman

END TRY
BEGIN CATCH
    SELECT @ReturnCode AS ReturnCode,
            @ReturnMsg AS ReturnMessage,
            @SurvivorDiseaseReportID AS SurvivorDiseaseReportID,
            @strHumanCaseId AS strHumanCaseID,
            @HumanID AS idfHuman
    IF @@Trancount > 0
        ROLLBACK TRAN;

    THROW;

END CATCH
 