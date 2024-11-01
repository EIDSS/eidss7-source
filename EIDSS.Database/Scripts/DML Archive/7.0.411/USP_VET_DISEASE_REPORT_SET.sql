SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_SET
--
-- Description:	Inserts or updates veterinary "case" for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- -------------------------------------------------------------------
-- Stephen Long    04/02/2018 Initial release.
-- Stephen Long    04/17/2019 Updated for API; use case updates.
-- Stephen Long    04/23/2019 Added updates for herd master and species master if new ones are 
--                            added to the farm during disease report creation.
-- Stephen Long    04/29/2019 Added related to veterinary disease report fields for use case VUC11 
--                            and VUC12.
-- Stephen Long    05/26/2019 Made corrections to farm copy observation ID and species table 
--                            observation ID for flexible form saving.
-- Stephen Long    06/01/2019 Made corrections to JSON for herds and species parameters.
-- Stephen Long    06/10/2019 Added farm owner ID output parameter to USSP_VET_FARM_COPY call.
-- Stephen Long    06/19/2019 Added diagnosis date and tests conducted indicator parameters.
-- Stephen Long    06/22/2019 Added read only indicator parameter for sample set - sample import.
-- Stephen Long    06/24/2019 Update to match new parameter for USSP_VET_FARM_COPY call.
-- Stephen Long    07/26/2019 Corrected farm counts (total, sick and dead).
-- Stephen Long    09/14/2019 Corrected root sample ID/parent sample ID on sample update call.
-- Stephen Long    10/01/2019 Added monitoring session ID parameter to farm copy for the sceanrio 
--                            where a disease report is tied to a monitoring session.
-- Stephen Long    12/23/2019 Added farm latitude and longitude parameters.
-- Stephen Long    02/05/2020 Updated sample set to account for the current site ID when samples 
--                            are imported from the laboratory module.
-- Stephen Long    02/16/2020 Add logic to copy activity parameters, and add observation record for 
--                            connected disease reports.
-- Stephen Long    04/21/2020 Added additional check on clinical signs when related disease report.
-- Stephen Long    04/24/2020 Added clinical signs indicator for the animal set call.
-- Stephen Long    08/12/2020 Corrected status on report log from status type to log status type.
-- Stephen Long    08/25/2020 Added observation ID set for the update of the vet case table.
-- Stephen Long    09/18/2020 Check for null related to observation ID
-- Stephen Long    12/20/2020 Updated USSP_GBL_TEST_SET call with four new parameters.
-- Stephen Long    11/29/2021 Removed language ID and added audit user name to USSP calls.
-- Stephen Long    01/19/2022 Added missing audit user name on ussp calls, and added events.
-- Stephen Long    01/22/2022 Made disease ID nullable on SamplesTemp table variable.
-- Stephen Long    01/24/2022 Added link local or field sample ID to report ID parameter.
-- Stephen Long    01/28/2022 Removed herd actual and species actual, no longer used.
-- Stephen Long    02/18/2022 Added lab module source indicator check on sample set.
-- Stephen Long    03/08/2022 Set notification object ID after saving disease report.
-- Stephen Long    04/12/2022 Added outbreak veterinary case parameters and logic.
-- Stephen Long    04/27/2022 Added additional outbreak case parameters: status type and case 
--                            questionnaire observation ID.
-- Stephen Long    05/09/2022 Bug fix on item 4199 - local/field sample ID iteration.
-- Stephen Long    06/16/2022 Added status type ID to species set.
-- Stephen Long    07/06/2022 Updates for site alerts to call new stored procedure.
-- Stephen Long    09/15/2022 Added note parameter to event set call.  Temporarily removed!
-- Stephen Long    12/07/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long    12/09/2022 Changed object type ID reference for veterinary disease report, 
--                            and added EIDSS object ID to samples, tests and test 
--                            interpretations calls.
-- Stephen Long    12/14/2022 Fix to observation ID when adding a connected disease report; site 
--                            identifier was not picked up from the original record.
-- Stephen Long    12/17/2022 Fix to importing sample when the disease report has not been saved.
-- Stephwn Long    12/19/2022 Added connected disease laboratory test ID to the list of output.
-- Stephen Long    02/03/2023 Changed to data audit call with strMainObject.
-- Stephen Long    03/08/2023 Fix to call data audit set and pass EIDSS report ID.
-- Ann Xiong	   03/09/2023 Added @DataAuditEventID parameter
-- Stephen Long    05/16/2023 Fix for item 5584.
-- Olga Mirnaya    01/22/2023 Modify processing of comments including input parameter for Summary Notes of VDR.
-- ================================================================================================
CREATE or ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_SET]
(
    @DiseaseReportID BIGINT,
    @EIDSSReportID NVARCHAR(200) = NULL,
    @FarmID BIGINT,
    @FarmMasterID BIGINT,
    @FarmOwnerID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @OutbreakID BIGINT = NULL,
    @RelatedToDiseaseReportID BIGINT = NULL,
    @EIDSSFieldAccessionID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT,
    @EnteredByPersonID BIGINT = NULL,
    @ReportedByOrganizationID BIGINT = NULL,
    @ReportedByPersonID BIGINT = NULL,
    @InvestigatedByOrganizationID BIGINT = NULL,
    @InvestigatedByPersonID BIGINT = NULL,
    @ReceivedByOrganizationID BIGINT = NULL,
    @ReceivedByPersonID BIGINT = NULL,
    @SiteID BIGINT,
    @DiagnosisDate DATETIME = NULL,
    @EnteredDate DATETIME = NULL,
    @ReportDate DATETIME = NULL,
    @AssignedDate DATETIME = NULL,
    @InvestigationDate DATETIME = NULL,
    @RowStatus INT,
    @ReportTypeID BIGINT = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @StatusTypeID BIGINT = NULL,
    @ReportCategoryTypeID BIGINT,
    @FarmTotalAnimalQuantity INT = NULL,
    @FarmSickAnimalQuantity INT = NULL,
    @FarmDeadAnimalQuantity INT = NULL,
    @FarmLatitude FLOAT = NULL,
    @FarmLongitude FLOAT = NULL,
    @FarmEpidemiologicalObservationID BIGINT = NULL,
    @ControlMeasuresObservationID BIGINT = NULL,
    @TestsConductedIndicator BIGINT = NULL,
    @DataAuditEventID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @FlocksOrHerds NVARCHAR(MAX) = NULL,
    @Species NVARCHAR(MAX) = NULL,
    @Animals NVARCHAR(MAX) = NULL,
    @Vaccinations NVARCHAR(MAX) = NULL,
    @Samples NVARCHAR(MAX) = NULL,
    @PensideTests NVARCHAR(MAX) = NULL,
    @LaboratoryTests NVARCHAR(MAX) = NULL,
    @LaboratoryTestInterpretations NVARCHAR(MAX) = NULL,
    @CaseLogs NVARCHAR(MAX) = NULL,
    @ClinicalInformation NVARCHAR(MAX) = NULL,
    @Contacts NVARCHAR(MAX) = NULL,
    @CaseMonitorings NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @UserID BIGINT,
    @LinkLocalOrFieldSampleIDToReportID BIT = 0,
    @OutbreakCaseIndicator BIT = 0,
    @OutbreakCaseReportUID BIGINT = NULL,
    @OutbreakCaseStatusTypeID BIGINT = NULL,
    @OutbreakCaseQuestionnaireObservationID BIGINT = NULL,
    @PrimaryCaseIndicator BIT = 0,
	@Comments NVARCHAR(2000) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT
            = 0,
                @ReturnMessage NVARCHAR(MAX) = N'SUCCESS',
                @ConnectedDiseaseReportLaboratoryTestID BIGINT = NULL,
                @RowAction INT = NULL,
                @RowID BIGINT,
                @Iteration INT = 0,
                @NewFarmOwnerID BIGINT = NULL,
                @FlockOrHerdID BIGINT = NULL,
                @FlockOrHerdMasterID BIGINT = NULL,
                @EIDSSFlockOrHerdID NVARCHAR(200) = NULL,
                @SickAnimalQuantity INT = NULL,
                @TotalAnimalQuantity INT = NULL,
                @DeadAnimalQuantity INT = NULL,
                @SpeciesID BIGINT = NULL,
                @SpeciesMasterID BIGINT = NULL,
                @SpeciesTypeID BIGINT = NULL,
                @StartOfSignsDate DATETIME = NULL,
                @AverageAge NVARCHAR(200) = NULL,
                @ObservationID BIGINT = NULL,
                @OutbreakSpeciesCaseStatusTypeID BIGINT = NULL,
                @AnimalID BIGINT = NULL,
                @SexTypeID BIGINT = NULL,
                @ConditionTypeID BIGINT = NULL,
                @AgeTypeID BIGINT = NULL,
                @EIDSSAnimalID NVARCHAR(200) = NULL,
                @AnimalName NVARCHAR(200) = NULL,
                @Color NVARCHAR(200) = NULL,
                @AnimalDescription NVARCHAR(200) = NULL,
                @ClinicalSignsIndicator BIGINT = NULL,
                @VaccinationID BIGINT,
                @VaccinationTypeID BIGINT = NULL,
                @RouteTypeID BIGINT = NULL,
                @VaccinationDate DATETIME = NULL,
                @Manufacturer NVARCHAR(200) = NULL,
                @LotNumber NVARCHAR(200) = NULL,
                @NumberVaccinated INT = NULL,
                @SampleID BIGINT,
                @SampleTypeID BIGINT = NULL,
                @RootSampleID BIGINT = NULL,
                @ParentSampleID BIGINT = NULL,
                @CollectedByPersonID BIGINT = NULL,
                @CollectedByOrganizationID BIGINT = NULL,
                @CollectionDate DATETIME = NULL,
                @SentDate DATETIME = NULL,
                @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
                @SampleStatusTypeID BIGINT = NULL,
                @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
                @SentToOrganizationID BIGINT = NULL,
                @ReadOnlyIndicator BIT = NULL,
                @CurrentSiteID BIGINT = NULL,
                @BirdStatusTypeID BIGINT = NULL,
                @PensideTestID BIGINT = NULL,
                @PensideTestResultTypeID BIGINT = NULL,
                @PensideTestNameTypeID BIGINT = NULL,
                @TestedByPersonID BIGINT = NULL,
                @TestedByOrganizationID BIGINT = NULL,
                @TestDate DATETIME = NULL,
                @PensideTestCategoryTypeID BIGINT = NULL,
                @TestID BIGINT = NULL,
                @TestNameTypeID BIGINT = NULL,
                @TestCategoryTypeID BIGINT = NULL,
                @TestResultTypeID BIGINT = NULL,
                @TestStatusTypeID BIGINT,
                @BatchTestID BIGINT = NULL,
                @StartedDate DATETIME = NULL,
                @ResultDate DATETIME = NULL,
                @ResultEnteredByOrganizationID BIGINT = NULL,
                @ResultEnteredByPersonID BIGINT = NULL,
                @ValidatedByOrganizationID BIGINT = NULL,
                @ValidatedByPersonID BIGINT = NULL,
                @NonLaboratoryTestIndicator BIT,
                @ExternalTestIndicator BIT = NULL,
                @PerformedByOrganizationID BIGINT = NULL,
                @ReceivedDate DATETIME = NULL,
                @ContactPersonName NVARCHAR(200) = NULL,
                @TestDiseaseReportID BIGINT = NULL,
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
                @CaseLogID BIGINT,
                @LogStatusTypeID BIGINT = NULL,
                @LoggedByPersonID BIGINT = NULL,
                @LogDate DATETIME = NULL,
                @ActionRequired NVARCHAR(200) = NULL,
                @VeterinaryDiseaseReportRelationshipID BIGINT = NULL,
                @RelatedToSpeciesID BIGINT = NULL,
                @RelatedToAnimalID BIGINT = NULL,
                @RelatedToObservationID BIGINT = NULL,
                @FormTemplateID BIGINT,
                @ObservationSiteID BIGINT,
                @ActivityID BIGINT = NULL,
                @ActivityIDNew BIGINT = NULL,
                @ParameterID BIGINT = NULL,
                @ParameterValue SQL_VARIANT = NULL,
                @ParameterRowID BIGINT = NULL,
                @EventId BIGINT,
                @EventTypeId BIGINT = NULL,
                @EventSiteId BIGINT = NULL,
                @EventObjectId BIGINT = NULL,
                @EventUserId BIGINT = NULL,
                @EventDiseaseId BIGINT = NULL,
                @EventLocationId BIGINT = NULL,
                @EventInformationString NVARCHAR(MAX) = NULL,
                @EventNote NVARCHAR(MAX) = NULL,
                @EventLoginSiteId BIGINT = NULL,
                                                                                           -- Data audit
                @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                --@DataAuditEventID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = 10017085,                                           -- Veterinary disease report
                @ObjectID BIGINT = @DiseaseReportID,
                @ObjectTableID BIGINT = 75800000000,                                       -- tlbVetCase
                @ObjectVeterinaryDiseaseReportRelationshipTableID BIGINT = 53577790000004, -- VetDiseaseReportRelationship
                @ObjectObservationTableID BIGINT = 75640000000,                            -- tlbObservation
                @ObjectActivityParametersTableID BIGINT = 75410000000,                     -- tlbActivityParameters
                                                                                           -- End data audit
                @LabModuleSourceIndicator INT = 0,
                @SampleDiseaseReportID BIGINT = NULL,
                @EIDSSCaseID NVARCHAR(200) = NULL,
				
				@SpeciesComments NVARCHAR(2000) = NULL,
				@VaccinationComments NVARCHAR(2000) = NULL,
				@SampleComments NVARCHAR(2000) = NULL,
				@TestComments NVARCHAR(2000) = NULL,
				@CaseLogComments NVARCHAR(2000) = NULL;
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );
        DECLARE @FlocksOrHerdsTemp TABLE
        (
            FlockOrHerdID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            FlockOrHerdMasterID BIGINT NULL,
            EIDSSFlockOrHerdID NVARCHAR(200) NULL,
            SickAnimalQuantity INT NULL,
            TotalAnimalQuantity INT NULL,
            DeadAnimalQuantity INT NULL,
            RowStatus INT NULL,
            RowAction INT NULL
        );
        DECLARE @SpeciesTemp TABLE
        (
            SpeciesID BIGINT NOT NULL,
            SpeciesMasterID BIGINT NULL,
            FlockOrHerdID BIGINT NOT NULL,
            SpeciesTypeID BIGINT NOT NULL,
            SickAnimalQuantity INT NULL,
            TotalAnimalQuantity INT NULL,
            DeadAnimalQuantity INT NULL,
            StartOfSignsDate DATETIME NULL,
            AverageAge NVARCHAR(200) NULL,
            ObservationID BIGINT NULL,
            Comments NVARCHAR(2000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL,
            RelatedToSpeciesID BIGINT NULL,
            RelatedToObservationID BIGINT NULL,
            OutbreakCaseStatusTypeID BIGINT NULL
        );
        DECLARE @AnimalsTemp TABLE
        (
            AnimalID BIGINT NOT NULL,
            SexTypeID BIGINT NULL,
            ConditionTypeID BIGINT NULL,
            AgeTypeID BIGINT NULL,
            SpeciesID BIGINT NULL,
            ObservationID BIGINT NULL,
            EIDSSAnimalID NVARCHAR(200) NULL,
            AnimalName NVARCHAR(200) NULL,
            Color NVARCHAR(200) NULL,
            AnimalDescription NVARCHAR(200) NULL,
            ClinicalSignsIndicator BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL,
            RelatedToAnimalID BIGINT NULL,
            RelatedToObservationID BIGINT NULL
        );
        DECLARE @VaccinationsTemp TABLE
        (
            VaccinationID BIGINT NOT NULL,
            SpeciesID BIGINT NULL,
            VaccinationTypeID BIGINT NULL,
            RouteTypeID BIGINT NULL,
            DiseaseID BIGINT NULL,
            VaccinationDate DATETIME NULL,
            Manufacturer NVARCHAR(200) NULL,
            LotNumber NVARCHAR(200) NULL,
            NumberVaccinated INT NULL,
            Comments NVARCHAR(2000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @SamplesTemp TABLE
        (
            SampleID BIGINT NOT NULL,
            SampleTypeID BIGINT NULL,
            RootSampleID BIGINT NULL,
            ParentSampleID BIGINT NULL,
            SpeciesID BIGINT NULL,
            AnimalID BIGINT NULL,
            VeterinaryDiseaseReportID BIGINT NULL,
            MonitoringSessionID BIGINT NULL,
            SampleStatusTypeID BIGINT NULL,
            CollectionDate DATETIME NULL,
            CollectedByOrganizationID BIGINT NULL,
            CollectedByPersonID BIGINT NULL,
            SentDate DATETIME NULL,
            SentToOrganizationID BIGINT NULL,
            EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL,
            Comments NVARCHAR(200) NULL,
            SiteID BIGINT NOT NULL,
            CurrentSiteID BIGINT NULL,
            EnteredDate DATETIME NULL,
            DiseaseID BIGINT NULL,
            BirdStatusTypeID BIGINT NULL,
            ReadOnlyIndicator BIT NULL,
            LabModuleSourceIndicator INT NOT NULL,
            FarmID BIGINT NULL,
            FarmOwnerID BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @PensideTestsTemp TABLE
        (
            PensideTestID BIGINT NOT NULL,
            SampleID BIGINT NOT NULL,
            PensideTestNameTypeID BIGINT NULL,
            PensideTestResultTypeID BIGINT NULL,
            PensideTestCategoryTypeID BIGINT NULL,
            TestedByPersonID BIGINT NULL,
            TestedByOrganizationID BIGINT NULL,
            DiseaseID BIGINT NULL,
            TestDate DATETIME NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @LaboratoryTestsTemp TABLE
        (
            TestID BIGINT NOT NULL,
            TestNameTypeID BIGINT NULL,
            TestCategoryTypeID BIGINT NULL,
            TestResultTypeID BIGINT NULL,
            TestStatusTypeID BIGINT NOT NULL,
            DiseaseID BIGINT NOT NULL,
            SampleID BIGINT NULL,
            BatchTestID BIGINT NULL,
            ObservationID BIGINT NULL,
            TestNumber INT NULL,
            Comments NVARCHAR NULL,
            StartedDate DATETIME NULL,
            ResultDate DATETIME NULL,
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
            ReceivedDate DATETIME NULL,
            ContactPersonName NVARCHAR(200) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @LaboratoryTestInterpretationsTemp TABLE
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
        DECLARE @CaseLogsTemp TABLE
        (
            CaseLogID BIGINT NOT NULL,
            LogStatusTypeID BIGINT NULL,
            LoggedByPersonID BIGINT NULL,
            LogDate DATETIME NULL,
            ActionRequired NVARCHAR(200) NULL,
            Comments NVARCHAR(1000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @ClinicalInformationTemp TABLE
        (
            langId NVARCHAR(200) NULL,
            HerdID BIGINT NOT NULL,
            Herd NVARCHAR(200) NULL,
            ClinicalSignsIndicator BIGINT NOT NULL,
            SpeciesTypeID BIGINT NULL,
            SpeciesTypeName NVARCHAR(200) NULL,
            StatusTypeID BIGINT NULL,
            InvestigationPerformedTypeID BIGINT NULL
        );
        DECLARE @ActivityParametersTemp TABLE
        (
            ActivityID BIGINT NOT NULL,
            ParameterID BIGINT NOT NULL,
            ParameterValue SQL_VARIANT NULL,
            ParameterRowID BIGINT NOT NULL
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
            InformationString NVARCHAR(MAX) NULL,
            Note NVARCHAR(MAX) NULL
        );
        DECLARE @VeterinaryDiseaseReportAfterEdit TABLE
        (
            DiseaseReportID BIGINT,
            FarmID BIGINT,
            DiseaseID BIGINT,
            PersonEnteredByID BIGINT,
            PersonReportedByID BIGINT,
            PersonInvestigatedByID BIGINT,
            ObservationID BIGINT,
            ReportDate DATETIME,
            AssignedDate DATETIME,
            InvestigationDate DATETIME,
            FinalDiagnosisDate DATETIME,
            FieldAccessionID NVARCHAR(200),
            YNTestsConductedTypeID BIGINT,
            ReportedByOfficeID BIGINT,
            InvestigatedByOfficeID BIGINT,
            CaseReportTypeID BIGINT,
            CaseClassificationTypeID BIGINT,
            OutbreakID BIGINT,
            EnteredDate DATETIME,
            EIDSSReportID NVARCHAR(200),
            CaseProgressStatusTypeID BIGINT,
            ParentMonitoringSessionID BIGINT,
            CaseTypeID BIGINT,
            ReceivedByOfficeID BIGINT,
            ReceivedByPersonID BIGINT
        );
        DECLARE @VeterinaryDiseaseReportBeforeEdit TABLE
        (
            DiseaseReportID BIGINT,
            FarmID BIGINT,
            DiseaseID BIGINT,
            PersonEnteredByID BIGINT,
            PersonReportedByID BIGINT,
            PersonInvestigatedByID BIGINT,
            ObservationID BIGINT,
            ReportDate DATETIME,
            AssignedDate DATETIME,
            InvestigationDate DATETIME,
            FinalDiagnosisDate DATETIME,
            FieldAccessionID NVARCHAR(200),
            YNTestsConductedTypeID BIGINT,
            ReportedByOfficeID BIGINT,
            InvestigatedByOfficeID BIGINT,
            CaseReportTypeID BIGINT,
            CaseClassificationTypeID BIGINT,
            OutbreakID BIGINT,
            EnteredDate DATETIME,
            EIDSSReportID NVARCHAR(200),
            CaseProgressStatusTypeID BIGINT,
            ParentMonitoringSessionID BIGINT,
            CaseTypeID BIGINT,
            ReceivedByOfficeID BIGINT,
            ReceivedByPersonID BIGINT
        );

        BEGIN TRANSACTION;

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        -- Predetermine the outbreak report ID for the upcoming section
        SELECT @OutbreakCaseReportUID = OutbreakCaseReportUID
        FROM dbo.OutbreakCaseReport
        WHERE idfVetCase = @DiseaseReportID;

        INSERT INTO @FlocksOrHerdsTemp
        SELECT *
        FROM
            OPENJSON(@FlocksOrHerds)
            WITH
            (
                FlockOrHerdID BIGINT,
                FarmID BIGINT,
                FlockOrHerdMasterID BIGINT,
                EIDSSFlockOrHerdID NVARCHAR(200),
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @SpeciesTemp
        SELECT *
        FROM
            OPENJSON(@Species)
            WITH
            (
                SpeciesID BIGINT,
                SpeciesMasterID BIGINT,
                FlockOrHerdID BIGINT,
                SpeciesTypeID BIGINT,
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                StartOfSignsDate DATETIME,
                AverageAge NVARCHAR(200),
                ObservationID BIGINT,
                Comments NVARCHAR(2000),
                RowStatus INT,
                RowAction INT,
                RelatedToSpeciesID BIGINT,
                RelatedToObservationID BIGINT,
                OutbreakCaseStatusTypeID BIGINT
            );

        INSERT INTO @AnimalsTemp
        SELECT *
        FROM
            OPENJSON(@Animals)
            WITH
            (
                AnimalID BIGINT,
                SexTypeID BIGINT,
                ConditionTypeID BIGINT,
                AgeTypeID BIGINT,
                SpeciesID BIGINT,
                ObservationID BIGINT,
                EIDSSAnimalID NVARCHAR(200),
                AnimalName NVARCHAR(200),
                Color NVARCHAR(200),
                AnimalDescription NVARCHAR(200),
                ClinicalSignsIndicator BIGINT,
                RowStatus INT,
                RowAction INT,
                RelatedToAnimalID BIGINT,
                RelatedToObservationID BIGINT
            );

        INSERT INTO @VaccinationsTemp
        SELECT *
        FROM
            OPENJSON(@Vaccinations)
            WITH
            (
                VaccinationID BIGINT,
                SpeciesID BIGINT,
                VaccinationTypeID BIGINT,
                RouteTypeID BIGINT,
                DiseaseID BIGINT,
                VaccinationDate DATETIME2,
                Manufacturer NVARCHAR(200),
                LotNumber NVARCHAR(200),
                NumberVaccinated INT,
                Comments NVARCHAR(2000),
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @SamplesTemp
        SELECT *
        FROM
            OPENJSON(@Samples)
            WITH
            (
                SampleID BIGINT,
                SampleTypeID BIGINT,
                RootSampleID BIGINT,
                ParentSampleID BIGINT,
                SpeciesID BIGINT,
                AnimalID BIGINT,
                VeterinaryDiseaseReportID BIGINT,
                MonitoringSessionID BIGINT,
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
                EnteredDate DATETIME2,
                DiseaseID BIGINT,
                BirdStatusTypeID BIGINT,
                ReadOnlyIndicator BIT,
                LabModuleSourceIndicator INT,
                FarmID BIGINT,
                FarmOwnerID BIGINT,
                RowStatus INT,
                RowAction INT
            );

        SET @Iteration =
        (
            SELECT COUNT(*) FROM dbo.tlbMaterial WHERE idfVetCase = @DiseaseReportID
        );

        INSERT INTO @PensideTestsTemp
        SELECT *
        FROM
            OPENJSON(@PensideTests)
            WITH
            (
                PensideTestID BIGINT,
                SampleID BIGINT,
                PensideTestNameTypeID BIGINT,
                PensideTestResultTypeID BIGINT,
                PensideTestCategoryTypeID BIGINT,
                TestedByPersonID BIGINT,
                TestedByOrganizationID BIGINT,
                DiseaseID BIGINT,
                TestDate DATETIME2,
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @LaboratoryTestsTemp
        SELECT *
        FROM
            OPENJSON(@LaboratoryTests)
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
                RowAction INT
            );

        INSERT INTO @LaboratoryTestInterpretationsTemp
        SELECT *
        FROM
            OPENJSON(@LaboratoryTestInterpretations)
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

        INSERT INTO @CaseLogsTemp
        SELECT *
        FROM
            OPENJSON(@CaseLogs)
            WITH
            (
                CaseLogID BIGINT,
                LogStatusTypeID BIGINT,
                LoggedByPersonID BIGINT,
                LogDate DATETIME2,
                ActionRequired NVARCHAR(200),
                Comments NVARCHAR(1000),
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @ClinicalInformationTemp
        SELECT *
        FROM
            OPENJSON(@ClinicalInformation)
            WITH
            (
                langId NVARCHAR(200),
                HerdID BIGINT,
                Herd NVARCHAR(200),
                ClinicalSignsTypeID BIGINT,
                SpeciesTypeID BIGINT,
                SpeciesTypeName NVARCHAR(200),
                StatusTypeID BIGINT,
                InvestigationPerformedTypeID BIGINT
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
                InformationString NVARCHAR(MAX),
                Note NVARCHAR(MAX)
            );

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbVetCase
            WHERE idfVetCase = @DiseaseReportID
                  AND intRowStatus = 0
        )
        BEGIN
            -- Get next key value
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbVetCase', @DiseaseReportID OUTPUT;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET 'Vet Disease Report',
                                               @EIDSSReportID OUTPUT,
                                               NULL;

            -- Data audit
        	IF @DataAuditEventID IS NULL
        	BEGIN 
				SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @DiseaseReportID,
                                                      @ObjectTableID,
                                                      @EIDSSReportID, 
                                                      @DataAuditEventID OUTPUT;
            END
            -- End data audit

            IF @ReportCategoryTypeID = 10012004 --Avian
            BEGIN
                UPDATE dbo.tlbFarmActual
                SET intAvianTotalAnimalQty = @FarmTotalAnimalQuantity,
                    intAvianSickAnimalQty = @FarmSickAnimalQuantity,
                    intAvianDeadAnimalQty = @FarmDeadAnimalQuantity,
                    AuditUpdateUser = @AuditUserName
                WHERE idfFarmActual = @FarmMasterID;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   NULL,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END
            ELSE --Livestock
            BEGIN
                UPDATE dbo.tlbFarmActual
                SET intLivestockTotalAnimalQty = @FarmTotalAnimalQuantity,
                    intLivestockSickAnimalQty = @FarmSickAnimalQuantity,
                    intLivestockDeadAnimalQty = @FarmDeadAnimalQuantity,
                    AuditUpdateUser = @AuditUserName
                WHERE idfFarmActual = @FarmMasterID;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   NULL,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END

            IF @OutbreakCaseIndicator = 1 AND @OutbreakCaseReportUID IS NULL
            BEGIN
               SET @EIDSSReportID = NULL; -- Do not set an EIDSS report identifier when the case is created in the outbreak session instead of imported.
            END

            INSERT INTO dbo.tlbVetCase
            (
                idfVetCase,
                idfFarm,
                idfsFinalDiagnosis,
                idfPersonEnteredBy,
                idfPersonReportedBy,
                idfPersonInvestigatedBy,
                idfObservation,
                idfsSite,
                datReportDate,
                datAssignedDate,
                datInvestigationDate,
                datFinalDiagnosisDate,
                strTestNotes,
                strSummaryNotes,
                strClinicalNotes,
                strFieldAccessionID,
                idfsYNTestsConducted,
                intRowStatus,
                idfReportedByOffice,
                idfInvestigatedByOffice,
                idfsCaseReportType,
                strDefaultDisplayDiagnosis,
                idfsCaseClassification,
                idfOutbreak,
                datEnteredDate,
                strCaseID,
                idfsCaseProgressStatus,
                strSampleNotes,
                datModificationForArchiveDate,
                idfParentMonitoringSession,
                idfsCaseType,
                idfReceivedByOffice,
                idfReceivedByPerson,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@DiseaseReportID,
             @FarmID,
             @DiseaseID,
             @EnteredByPersonID,
             @ReportedByPersonID,
             @InvestigatedByPersonID,
             @ControlMeasuresObservationID,
             @SiteID,
             @ReportDate,
             @AssignedDate,
             @InvestigationDate,
             @DiagnosisDate,
             NULL,
			 @Comments,
             NULL,
             @EIDSSFieldAccessionID,
             @TestsConductedIndicator,
             @RowStatus,
             @ReportedByOrganizationID,
             @InvestigatedByOrganizationID,
             @ReportTypeID,
             NULL,
             @ClassificationTypeID,
             @OutbreakID,
             @EnteredDate,
             @EIDSSReportID,
             @StatusTypeID,
             NULL,
             NULL,
             @MonitoringSessionID,
             @ReportCategoryTypeID,
             @ReceivedByOrganizationID,
             @ReceivedByPersonID,
             @AuditUserName,
             10519001,
             '[{"idfVetCase":' + CAST(@DiseaseReportID AS NVARCHAR(300)) + '}]'
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
             @DiseaseReportID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSReportID
            );

            -- Update data audit event ID on tlbObservation and tlbActivityParameters
            -- for flexible forms saved outside this DB transaction.
            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @EIDSSReportID
            WHERE idfObject = @FarmEpidemiologicalObservationID
                  AND idfDataAuditEvent IS NULL;

            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @EIDSSReportID
            WHERE idfObject = @ControlMeasuresObservationID
                  AND idfDataAuditEvent IS NULL;
            -- End data audit

            UPDATE @EventsTemp
            SET ObjectId = @DiseaseReportID,
                Note = REPLACE(Note, 'diseaseReportID=0', 'diseaseReportID=' + CAST(@DiseaseReportID AS NVARCHAR(300)))
            WHERE ObjectId = 0;

            -- Update imported samples from laboratory
            UPDATE @SamplesTemp 
            SET VeterinaryDiseaseReportID = @DiseaseReportID
            WHERE VeterinaryDiseaseReportID = 0
                  AND LabModuleSourceIndicator = 1;
        END
        ELSE
        BEGIN
            -- Data audit
        	IF @DataAuditEventID IS NULL
        	BEGIN 
				SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @DiseaseReportID,
                                                      @ObjectTableID,
                                                      @EIDSSReportID, 
                                                      @DataAuditEventID OUTPUT;
            END
            -- End data audit

            IF @ReportCategoryTypeID = 10012004 --Avian
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   @MonitoringSessionID,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END
            ELSE --Livestock
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   @MonitoringSessionID,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END
            -- Data audit
            INSERT INTO @VeterinaryDiseaseReportBeforeEdit
            (
                DiseaseReportID,
                FarmID,
                DiseaseID,
                PersonEnteredByID,
                PersonReportedByID,
                PersonInvestigatedByID,
                ObservationID,
                ReportDate,
                AssignedDate,
                InvestigationDate,
                FinalDiagnosisDate,
                FieldAccessionID,
                YNTestsConductedTypeID,
                ReportedByOfficeID,
                InvestigatedByOfficeID,
                CaseReportTypeID,
                CaseClassificationTypeID,
                OutbreakID,
                EnteredDate,
                EIDSSReportID,
                CaseProgressStatusTypeID,
                ParentMonitoringSessionID,
                CaseTypeID,
                ReceivedByOfficeID,
                ReceivedByPersonID
            )
            SELECT idfVetCase,
                   idfFarm,
                   idfsFinalDiagnosis,
                   idfPersonEnteredBy,
                   idfPersonReportedBy,
                   idfPersonInvestigatedBy,
                   idfObservation,
                   datReportDate,
                   datAssignedDate,
                   datInvestigationDate,
                   datFinalDiagnosisDate,
                   strFieldAccessionID,
                   idfsYNTestsConducted,
                   idfReportedByOffice,
                   idfInvestigatedByOffice,
                   idfsCaseReportType,
                   idfsCaseClassification,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   idfParentMonitoringSession,
                   idfsCaseType,
                   idfReceivedByOffice,
                   idfReceivedByPerson
            FROM dbo.tlbVetCase
            WHERE idfVetCase = @DiseaseReportID;
            -- End data audit

            UPDATE dbo.tlbVetCase
            SET idfFarm = @FarmID,
                idfsFinalDiagnosis = @DiseaseID,
                idfPersonEnteredBy = @EnteredByPersonID,
                idfPersonReportedBy = @ReportedByPersonID,
                idfPersonInvestigatedBy = @InvestigatedByPersonID,
                idfReceivedByPerson = @ReceivedByPersonID,
                idfObservation = @ControlMeasuresObservationID,
                idfsSite = @SiteID,
                datReportDate = @ReportDate,
                datAssignedDate = @AssignedDate,
                datInvestigationDate = @InvestigationDate,
                datFinalDiagnosisDate = @DiagnosisDate,
                strTestNotes = NULL,
                strSummaryNotes = @Comments,
                strClinicalNotes = NULL,
                strFieldAccessionID = @EIDSSFieldAccessionID,
                idfsYNTestsConducted = @TestsConductedIndicator,
                intRowStatus = @RowStatus,
                idfReportedByOffice = @ReportedByOrganizationID,
                idfInvestigatedByOffice = @InvestigatedByOrganizationID,
                idfReceivedByOffice = @ReceivedByOrganizationID,
                idfsCaseReportType = @ReportTypeID,
                idfsCaseClassification = @ClassificationTypeID,
                idfOutbreak = @OutbreakID,
                datEnteredDate = @EnteredDate,
                strCaseID = @EIDSSReportID,
                idfsCaseProgressStatus = @StatusTypeID,
                strSampleNotes = NULL,
                idfParentMonitoringSession = @MonitoringSessionID,
                idfsCaseType = @ReportCategoryTypeID,
                AuditUpdateUser = @AuditUserName
            WHERE idfVetCase = @DiseaseReportID;

            -- Data audit
            INSERT INTO @VeterinaryDiseaseReportAfterEdit
            (
                DiseaseReportID,
                FarmID,
                DiseaseID,
                PersonEnteredByID,
                PersonReportedByID,
                PersonInvestigatedByID,
                ObservationID,
                ReportDate,
                AssignedDate,
                InvestigationDate,
                FinalDiagnosisDate,
                FieldAccessionID,
                YNTestsConductedTypeID,
                ReportedByOfficeID,
                InvestigatedByOfficeID,
                CaseReportTypeID,
                CaseClassificationTypeID,
                OutbreakID,
                EnteredDate,
                EIDSSReportID,
                CaseProgressStatusTypeID,
                ParentMonitoringSessionID,
                CaseTypeID,
                ReceivedByOfficeID,
                ReceivedByPersonID
            )
            SELECT idfVetCase,
                   idfFarm,
                   idfsFinalDiagnosis,
                   idfPersonEnteredBy,
                   idfPersonReportedBy,
                   idfPersonInvestigatedBy,
                   idfObservation,
                   datReportDate,
                   datAssignedDate,
                   datInvestigationDate,
                   datFinalDiagnosisDate,
                   strFieldAccessionID,
                   idfsYNTestsConducted,
                   idfReportedByOffice,
                   idfInvestigatedByOffice,
                   idfsCaseReportType,
                   idfsCaseClassification,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   idfParentMonitoringSession,
                   idfsCaseType,
                   idfReceivedByOffice,
                   idfReceivedByPerson
            FROM dbo.tlbVetCase
            WHERE idfVetCase = @DiseaseReportID;

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
                   4575810000000,
                   a.DiseaseReportID,
                   NULL,
                   b.FarmID,
                   a.FarmID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.FarmID <> b.FarmID)
                  OR (
                         a.FarmID IS NOT NULL
                         AND b.FarmID IS NULL
                     )
                  OR (
                         a.FarmID IS NULL
                         AND b.FarmID IS NOT NULL
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
                   80940000000,
                   a.DiseaseReportID,
                   NULL,
                   b.DiseaseID,
                   a.DiseaseID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.DiseaseID <> b.DiseaseID)
                  OR (
                         a.DiseaseID IS NOT NULL
                         AND b.DiseaseID IS NULL
                     )
                  OR (
                         a.DiseaseID IS NULL
                         AND b.DiseaseID IS NOT NULL
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
                   80910000000,
                   a.DiseaseReportID,
                   NULL,
                   b.PersonEnteredByID,
                   a.PersonEnteredByID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
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
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80930000000,
                   a.DiseaseReportID,
                   NULL,
                   b.PersonReportedByID,
                   a.PersonReportedByID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.PersonReportedByID <> b.PersonReportedByID)
                  OR (
                         a.PersonReportedByID IS NOT NULL
                         AND b.PersonReportedByID IS NULL
                     )
                  OR (
                         a.PersonReportedByID IS NULL
                         AND b.PersonReportedByID IS NOT NULL
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
                   80920000000,
                   a.DiseaseReportID,
                   NULL,
                   b.PersonInvestigatedByID,
                   a.PersonInvestigatedByID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.PersonInvestigatedByID <> b.PersonInvestigatedByID)
                  OR (
                         a.PersonInvestigatedByID IS NOT NULL
                         AND b.PersonInvestigatedByID IS NULL
                     )
                  OR (
                         a.PersonInvestigatedByID IS NULL
                         AND b.PersonInvestigatedByID IS NOT NULL
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
                   4566320000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ObservationID,
                   a.ObservationID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ObservationID <> b.ObservationID)
                  OR (
                         a.ObservationID IS NOT NULL
                         AND b.ObservationID IS NULL
                     )
                  OR (
                         a.ObservationID IS NULL
                         AND b.ObservationID IS NOT NULL
                     )

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
                   80870000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ReportDate,
                   a.ReportDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ReportDate <> b.ReportDate)
                  OR (
                         a.ReportDate IS NOT NULL
                         AND b.ReportDate IS NULL
                     )
                  OR (
                         a.ReportDate IS NULL
                         AND b.ReportDate IS NOT NULL
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
                   80850000000,
                   a.DiseaseReportID,
                   NULL,
                   b.AssignedDate,
                   a.AssignedDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.AssignedDate <> b.AssignedDate)
                  OR (
                         a.AssignedDate IS NOT NULL
                         AND b.AssignedDate IS NULL
                     )
                  OR (
                         a.AssignedDate IS NULL
                         AND b.AssignedDate IS NOT NULL
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
                   4566330000000,
                   a.DiseaseReportID,
                   NULL,
                   b.InvestigationDate,
                   a.InvestigationDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.InvestigationDate <> b.InvestigationDate)
                  OR (
                         a.InvestigationDate IS NOT NULL
                         AND b.InvestigationDate IS NULL
                     )
                  OR (
                         a.InvestigationDate IS NULL
                         AND b.InvestigationDate IS NOT NULL
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
                   80860000000,
                   a.DiseaseReportID,
                   NULL,
                   b.FinalDiagnosisDate,
                   a.FinalDiagnosisDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
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
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4566340000000,
                   a.DiseaseReportID,
                   NULL,
                   b.FieldAccessionID,
                   a.FieldAccessionID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.FieldAccessionID <> b.FieldAccessionID)
                  OR (
                         a.FieldAccessionID IS NOT NULL
                         AND b.FieldAccessionID IS NULL
                     )
                  OR (
                         a.FieldAccessionID IS NULL
                         AND b.FieldAccessionID IS NOT NULL
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
                   4578870000000,
                   a.DiseaseReportID,
                   NULL,
                   b.YNTestsConductedTypeID,
                   a.YNTestsConductedTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.YNTestsConductedTypeID <> b.YNTestsConductedTypeID)
                  OR (
                         a.YNTestsConductedTypeID IS NOT NULL
                         AND b.YNTestsConductedTypeID IS NULL
                     )
                  OR (
                         a.YNTestsConductedTypeID IS NULL
                         AND b.YNTestsConductedTypeID IS NOT NULL
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
                   6618090000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ReportedByOfficeID,
                   a.ReportedByOfficeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ReportedByOfficeID <> b.ReportedByOfficeID)
                  OR (
                         a.ReportedByOfficeID IS NOT NULL
                         AND b.ReportedByOfficeID IS NULL
                     )
                  OR (
                         a.ReportedByOfficeID IS NULL
                         AND b.ReportedByOfficeID IS NOT NULL
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
                   6618100000000,
                   a.DiseaseReportID,
                   NULL,
                   b.InvestigatedByOfficeID,
                   a.InvestigatedByOfficeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
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
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   6618120000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseReportTypeID,
                   a.CaseReportTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseReportTypeID <> b.CaseReportTypeID)
                  OR (
                         a.CaseReportTypeID IS NOT NULL
                         AND b.CaseReportTypeID IS NULL
                     )
                  OR (
                         a.CaseReportTypeID IS NULL
                         AND b.CaseReportTypeID IS NOT NULL
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
                   12665470000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseClassificationTypeID,
                   a.CaseClassificationTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseClassificationTypeID <> b.CaseClassificationTypeID)
                  OR (
                         a.CaseClassificationTypeID IS NOT NULL
                         AND b.CaseClassificationTypeID IS NULL
                     )
                  OR (
                         a.CaseClassificationTypeID IS NULL
                         AND b.CaseClassificationTypeID IS NOT NULL
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
                   12665490000000,
                   a.DiseaseReportID,
                   NULL,
                   b.OutbreakID,
                   a.OutbreakID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
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
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665500000000,
                   a.DiseaseReportID,
                   NULL,
                   b.EnteredDate,
                   a.EnteredDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
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
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665510000000,
                   a.DiseaseReportID,
                   NULL,
                   b.EIDSSReportID,
                   a.EIDSSReportID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.EIDSSReportID <> b.EIDSSReportID)
                  OR (
                         a.EIDSSReportID IS NOT NULL
                         AND b.EIDSSReportID IS NULL
                     )
                  OR (
                         a.EIDSSReportID IS NULL
                         AND b.EIDSSReportID IS NOT NULL
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
                   12665520000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseProgressStatusTypeID,
                   a.CaseProgressStatusTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
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
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665540000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ParentMonitoringSessionID,
                   a.ParentMonitoringSessionID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ParentMonitoringSessionID <> b.ParentMonitoringSessionID)
                  OR (
                         a.ParentMonitoringSessionID IS NOT NULL
                         AND b.ParentMonitoringSessionID IS NULL
                     )
                  OR (
                         a.ParentMonitoringSessionID IS NULL
                         AND b.ParentMonitoringSessionID IS NOT NULL
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
                   12665560000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseTypeID,
                   a.CaseTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseTypeID <> b.CaseTypeID)
                  OR (
                         a.CaseTypeID IS NOT NULL
                         AND b.CaseTypeID IS NULL
                     )
                  OR (
                         a.CaseTypeID IS NULL
                         AND b.CaseTypeID IS NOT NULL
                     );
        END;

        -- VUC11 and VUC12 - connected disease report logic.
        IF @RelatedToDiseaseReportID IS NOT NULL
        BEGIN
            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.VetDiseaseReportRelationship
                WHERE VetDiseaseReportID = @DiseaseReportID
                      AND intRowStatus = 0
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'VetDiseaseReportRelationship',
                                                  @VeterinaryDiseaseReportRelationshipID OUTPUT;

                INSERT INTO dbo.VetDiseaseReportRelationship
                (
                    VetDiseaseReportRelnUID,
                    VetDiseaseReportID,
                    RelatedToVetDiseaseReportID,
                    RelationshipTypeID,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser
                )
                VALUES
                (@VeterinaryDiseaseReportRelationshipID,
                 @DiseaseReportID,
                 @RelatedToDiseaseReportID,
                 10503001,
                 0  ,
                 10519001,
                 '[{"VetDiseaseReportRelnUID":' + CAST(@VeterinaryDiseaseReportRelationshipID AS NVARCHAR(300))
                 + ',"VetDiseaseReportID":' + CAST(@DiseaseReportID AS NVARCHAR(300)) + '}]',
                 @AuditUserName
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
                 @ObjectVeterinaryDiseaseReportRelationshipTableID,
                 @VeterinaryDiseaseReportRelationshipID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectVeterinaryDiseaseReportRelationshipTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSReportID
                );
            -- End data audit
            END;
        END;

        -- An outbreak reference via a case must be created in order to tie the disease report to the outbreak session.
        IF @OutbreakCaseIndicator = 1
        BEGIN
            IF @OutbreakCaseReportUID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
                                               @OutbreakCaseReportUID OUTPUT;

                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NextNumber_GET 'Vet Outbreak Case',
                                                @EIDSSCaseID OUTPUT,
                                                NULL;

                INSERT INTO dbo.OutbreakCaseReport
                (
                    OutbreakCaseReportUID,
                    idfOutbreak,
                    strOutbreakCaseID,
                    idfHumanCase,
                    idfVetCase,
                    OutbreakCaseObservationId,
                    OutbreakCaseStatusId,
                    OutbreakCaseClassificationID,
                    IsPrimaryCaseFlag,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM,
                    AuditUpdateUser,
                    AuditUpdateDTM
                )
                VALUES
                (@OutbreakCaseReportUID,
                 @OutbreakID,
                 @EIDSSCaseID,
                 NULL,
                 @DiseaseReportID,
                 @OutbreakCaseQuestionnaireObservationID,
                 @OutbreakCaseStatusTypeID,
                 @ClassificationTypeID,
                 @PrimaryCaseIndicator,
                 0  ,
                 10519001,
                 '[{"OutBreakCaseReportUID":' + CAST(@OutbreakCaseReportUID AS NVARCHAR(300)) + ',"idfOutbreak":'
                 + CAST(@OutbreakID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE(),
                 @AuditUserName,
                 GETDATE()
                );
            END
            ELSE
            BEGIN
                UPDATE dbo.OutbreakCaseReport
                SET OutbreakCaseStatusId = @OutbreakCaseStatusTypeID,
                    OutbreakCaseClassificationID = @ClassificationTypeID,
                    IsPrimaryCaseFlag = @PrimaryCaseIndicator,
                    intRowStatus = 0,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE(),
                    OutbreakCaseObservationID = @OutbreakCaseQuestionnaireObservationID
                WHERE OutbreakCaseReportUID = @OutbreakCaseReportUID;
            END
        END

        WHILE EXISTS (SELECT * FROM @FlocksOrHerdsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FlockOrHerdID,
                @FlockOrHerdID = FlockOrHerdID,
                @FlockOrHerdMasterID = FlockOrHerdMasterID,
                @EIDSSFlockOrHerdID = EIDSSFlockOrHerdID,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FlocksOrHerdsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_FLOCK_HERD_SET @AuditUserName,
                                                @DataAuditEventID,
                                                @EIDSSReportID,
                                                @FlockOrHerdID OUTPUT,
                                                @FlockOrHerdMasterID,
                                                @FarmID,
                                                @EIDSSFlockOrHerdID,
                                                @SickAnimalQuantity,
                                                @TotalAnimalQuantity,
                                                @DeadAnimalQuantity,
                                                NULL,
                                                @RowStatus,
                                                @RowAction;

            UPDATE @SpeciesTemp
            SET FlockOrHerdID = @FlockOrHerdID
            WHERE FlockOrHerdID = @RowID;

            DELETE FROM @FlocksOrHerdsTemp
            WHERE FLockOrHerdID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @SpeciesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SpeciesID,
                @SpeciesID = SpeciesID,
                @SpeciesMasterID = SpeciesMasterID,
                @SpeciesTypeID = SpeciesTypeID,
                @FlockOrHerdID = FlockOrHerdID,
                @StartOfSignsDate = StartOfSignsDate,
                @AverageAge = AverageAge,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @SpeciesComments = Comments,
                @ObservationID = ObservationID,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @RelatedToSpeciesID = RelatedToSpeciesID,
                @RelatedToObservationID = RelatedToObservationID,
                @OutbreakSpeciesCaseStatusTypeID = OutbreakCaseStatusTypeID
            FROM @SpeciesTemp;

            -- VUC11 and VUC12 - connected disease report logic for clinical species investigations.
            IF @RelatedToDiseaseReportID IS NOT NULL
               AND @RowAction = 1 -- Insert
            BEGIN
                IF @RelatedToObservationID IS NOT NULL
                BEGIN
                    SELECT @FormTemplateID = idfsFormTemplate,
                           @ObservationSiteID = idfsSite
                    FROM dbo.tlbObservation
                    WHERE idfObservation = @RelatedToObservationID;

                    SET @ObservationID = -1;

                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USSP_GBL_OBSERVATION_SET @ObservationID OUTPUT,
                                                         @FormTemplateID,
                                                         @ObservationSiteID,
                                                         0,
                                                         1, 
                                                         @AuditUserName, 
                                                         @DataAuditEventID, 
                                                         @EIDSSReportID;

                    UPDATE @SpeciesTemp
                    SET ObservationID = @ObservationID
                    WHERE SpeciesMasterID = @SpeciesMasterID;

                    INSERT INTO @ActivityParametersTemp
                    SELECT idfActivityParameters,
                           idfsParameter,
                           varValue,
                           idfRow
                    FROM dbo.tlbActivityParameters
                    WHERE idfObservation = @RelatedToObservationID;

                    WHILE EXISTS (SELECT * FROM @ActivityParametersTemp)
                    BEGIN
                        SELECT TOP 1
                            @ActivityID = ActivityID,
                            @ParameterID = ParameterID,
                            @ParameterValue = ParameterValue,
                            @ParameterRowID = ParameterRowID
                        FROM @ActivityParametersTemp;

                        INSERT INTO @SuppressSelect
                        EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbActivityParameters',
                                                          @ActivityIDNew OUTPUT;

                        INSERT INTO dbo.tlbActivityParameters
                        (
                            idfActivityParameters,
                            idfsParameter,
                            idfObservation,
                            varValue,
                            idfRow,
                            intRowStatus,
                            SourceSystemNameID,
                            SourceSystemKeyValue,
                            AuditCreateUser,
                            AuditCreateDTM
                        )
                        VALUES
                        (@ActivityIDNew,
                         @ParameterID,
                         @ObservationID,
                         @ParameterValue,
                         @ParameterRowID,
                         0  ,
                         10519001,
                         '[{"idfActivityParameters":' + CAST(@ActivityIDNew AS NVARCHAR(300)) + '}]',
                         @AuditUserName,
                         GETDATE()
                        );

                        -- Data audit
                        INSERT INTO dbo.tauDataAuditDetailCreate
                        (
                            idfDataAuditEvent,
                            idfObjectTable,
                            idfObject,
                            idfObjectDetail,
                            SourceSystemNameID,
                            SourceSystemKeyValue,
                            AuditCreateUser
                        )
                        VALUES
                        (@DataAuditEventID,
                         @ObjectActivityParametersTableID,
                         @ActivityIDNew,
                         @ObservationID,
                         10519001,
                         '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                         + CAST(@ObjectActivityParametersTableID AS NVARCHAR(300)) + '}]',
                         @AuditUserName
                        );
                        -- End data audit

                        DELETE FROM @ActivityParametersTemp
                        WHERE ActivityID = @ActivityID;
                    END;
                END;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_SPECIES_WITH_AUDITING_SET @AuditUserName,
                                                           @DataAuditEventID,
                                                           @EIDSSReportID,
                                                           @SpeciesID OUTPUT,
                                                           @SpeciesMasterID,
                                                           @SpeciesTypeID,
                                                           @FlockOrHerdID,
                                                           @ObservationID,
                                                           @StartOfSignsDate,
                                                           @AverageAge,
                                                           @SickAnimalQuantity,
                                                           @TotalAnimalQuantity,
                                                           @DeadAnimalQuantity,
                                                           @SpeciesComments,
                                                           @RowStatus,
                                                           @RowAction,
                                                           @OutbreakSpeciesCaseStatusTypeID;

            UPDATE @AnimalsTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            UPDATE @VaccinationsTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            UPDATE @SamplesTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            DELETE FROM @SpeciesTemp
            WHERE SpeciesID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @AnimalsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = AnimalID,
                @AnimalID = AnimalID,
                @SexTypeID = SexTypeID,
                @ConditionTypeID = ConditionTypeID,
                @AgeTypeID = AgeTypeID,
                @SpeciesID = SpeciesID,
                @ObservationID = ObservationID,
                @AnimalDescription = AnimalDescription,
                @EIDSSAnimalID = EIDSSAnimalID,
                @AnimalName = AnimalName,
                @Color = Color,
                @ClinicalSignsIndicator = ClinicalSignsIndicator,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @AnimalsTemp;

            -- VUC11 and VUC12 - connected disease report logic for clinical signs.
            IF @RelatedToDiseaseReportID IS NOT NULL
               AND @RowAction = 1 -- Insert
               AND @ObservationID IS NOT NULL
            BEGIN
                SELECT @FormTemplateID = idfsFormTemplate,
                       @ObservationSiteID = idfsSite
                FROM dbo.tlbObservation
                WHERE idfObservation = @ObservationID;

                DELETE FROM @ActivityParametersTemp;

                INSERT INTO @ActivityParametersTemp
                SELECT idfActivityParameters,
                       idfsParameter,
                       varValue,
                       idfRow
                FROM dbo.tlbActivityParameters
                WHERE idfObservation = @ObservationID;

                SET @ObservationID = -1;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_OBSERVATION_SET @ObservationID OUTPUT,
                                                     @FormTemplateID,
                                                     @ObservationSiteID,
                                                     0,
                                                     1, 
                                                     @AuditUserName, 
                                                     @DataAuditEventID, 
                                                     @EIDSSReportID;

                UPDATE @AnimalsTemp
                SET ObservationID = @ObservationID
                WHERE AnimalID = @RowID;


                WHILE EXISTS (SELECT * FROM @ActivityParametersTemp)
                BEGIN
                    SELECT TOP 1
                        @ActivityID = ActivityID,
                        @ParameterID = ParameterID,
                        @ParameterValue = ParameterValue,
                        @ParameterRowID = ParameterRowID
                    FROM @ActivityParametersTemp;

                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbActivityParameters',
                                                      @ActivityIDNew OUTPUT;

                    INSERT INTO dbo.tlbActivityParameters
                    (
                        idfActivityParameters,
                        idfsParameter,
                        idfObservation,
                        varValue,
                        idfRow,
                        intRowStatus,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser,
                        AuditCreateDTM
                    )
                    VALUES
                    (@ActivityIDNew,
                     @ParameterID,
                     @ObservationID,
                     @ParameterValue,
                     @ParameterRowID,
                     0  ,
                     10519001,
                     '[{"idfActivityParameters":' + CAST(@ActivityIDNew AS NVARCHAR(300)) + '}]',
                     @AuditUserName,
                     GETDATE()
                    );

                    -- Data audit
                    INSERT INTO dbo.tauDataAuditDetailCreate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        idfObjectDetail,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser
                    )
                    VALUES
                    (@DataAuditEventID,
                     @ObjectActivityParametersTableID,
                     @ActivityIDNew,
                     @ObservationID,
                     10519001,
                     '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                     + CAST(@ObjectActivityParametersTableID AS NVARCHAR(300)) + '}]',
                     @AuditUserName
                    );
                    -- End data audit

                    DELETE FROM @ActivityParametersTemp
                    WHERE ActivityID = @ActivityID;
                END;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_ANIMALS_SET @AuditUserName,
                                             @DataAuditEventID,
                                             @EIDSSReportID,
                                             @AnimalID OUTPUT,
                                             @SexTypeID,
                                             @ConditionTypeID,
                                             @AgeTypeID,
                                             @SpeciesID,
                                             @ObservationID,
                                             @AnimalDescription,
                                             @EIDSSAnimalID,
                                             @AnimalName,
                                             @Color,
                                             @ClinicalSignsIndicator,
                                             @RowStatus,
                                             @RowAction;

            UPDATE @SamplesTemp
            SET AnimalID = @AnimalID
            WHERE AnimalID = @RowID;

            DELETE FROM @AnimalsTemp
            WHERE AnimalID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @VaccinationsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = VaccinationID,
                @VaccinationID = VaccinationID,
                @SpeciesID = SpeciesID,
                @VaccinationTypeID = VaccinationTypeID,
                @RouteTypeID = RouteTypeID,
                @DiseaseID = DiseaseID,
                @VaccinationDate = VaccinationDate,
                @Manufacturer = Manufacturer,
                @LotNumber = LotNumber,
                @NumberVaccinated = NumberVaccinated,
                @VaccinationComments = Comments,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @VaccinationsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_VACCINATIONS_SET @AuditUserName,
                                                  @DataAuditEventID,
                                                  @EIDSSReportID,
                                                  @VaccinationID OUTPUT,
                                                  @DiseaseReportID,
                                                  @SpeciesID,
                                                  @VaccinationTypeID,
                                                  @RouteTypeID,
                                                  @DiseaseID,
                                                  @VaccinationDate,
                                                  @Manufacturer,
                                                  @LotNumber,
                                                  @NumberVaccinated,
                                                  @VaccinationComments,
                                                  @RowStatus,
                                                  @RowAction;

            DELETE FROM @VaccinationsTemp
            WHERE VaccinationID = @RowID;
        END;

        IF @Contacts IS NOT NULL
            EXEC dbo.USSP_OMM_CONTACT_SET NULL,
                                          @Contacts,
                                          @User = @AuditUserName,
                                          @OutBreakCaseReportUID = @OutbreakCaseReportUID,
                                          @FunctionCall = 1;

        WHILE EXISTS (SELECT * FROM @SamplesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SampleID,
                @SampleID = SampleID,
                @SampleTypeID = SampleTypeID,
                @RootSampleID = RootSampleID,
                @ParentSampleID = ParentSampleID,
                @SpeciesID = SpeciesID,
                @AnimalID = AnimalID,
                @SampleDiseaseReportID = VeterinaryDiseaseReportID,
                @MonitoringSessionID = MonitoringSessionID,
                @CollectedByPersonID = CollectedByPersonID,
                @CollectedByOrganizationID = CollectedByOrganizationID,
                @CollectionDate = CollectionDate,
                @SentDate = SentDate,
                @EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
                @SampleStatusTypeID = SampleStatusTypeID,
                @EnteredDate = EnteredDate,
                @SampleComments = Comments,
                @SiteID = SiteID,
                @CurrentSiteID = CurrentSiteID,
                @RowStatus = RowStatus,
                @SentToOrganizationID = SentToOrganizationID,
                @BirdStatusTypeID = BirdStatusTypeID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @LabModuleSourceIndicator = LabModuleSourceIndicator,
                @RowAction = RowAction
            FROM @SamplesTemp;

            IF (
                   @EIDSSLocalOrFieldSampleID IS NULL
                   OR @EIDSSLocalOrFieldSampleID = ''
               )
               AND @LinkLocalOrFieldSampleIDToReportID = 1
            BEGIN
                SET @Iteration = @Iteration + 1;
                IF @Iteration < 10
                BEGIN
                    SET @EIDSSLocalOrFieldSampleID = @EIDSSReportID + '-0' + CONVERT(NVARCHAR(4), @Iteration);
                END
                ELSE
                BEGIN
                    SET @EIDSSLocalOrFieldSampleID = @EIDSSReportID + '-' + CONVERT(NVARCHAR(4), @Iteration);
                END;
            END;

            -- Check if sample is being de-linked, so use sample disease report ID passed in from 
            -- sample record instead of parent disease report ID.
            IF @LabModuleSourceIndicator = 0
            BEGIN
                SET @SampleDiseaseReportID = @DiseaseReportID;
            END

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_SAMPLES_SET @AuditUserName,
                                             @DataAuditEventID,
                                             @EIDSSReportID,
                                             @SampleID OUTPUT,
                                             @SampleTypeID,
                                             @RootSampleID,
                                             @ParentSampleID,
                                             @FarmOwnerID,
                                             @SpeciesID,
                                             @AnimalID,
                                             NULL,
                                             @MonitoringSessionID,
                                             NULL,
                                             NULL,
                                             @SampleDiseaseReportID,
                                             @CollectionDate,
                                             @CollectedByPersonID,
                                             @CollectedByOrganizationID,
                                             @SentDate,
                                             @SentToOrganizationID,
                                             @EIDSSLocalOrFieldSampleID,
                                             @SiteID,
                                             @EnteredDate,
                                             @ReadOnlyIndicator,
                                             @SampleStatusTypeID,
                                             @SampleComments,
                                             @CurrentSiteID,
                                             @DiseaseID,
                                             @BirdStatusTypeID,
                                             @RowStatus,
                                             @RowAction;

            UPDATE @PensideTestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            UPDATE @LaboratoryTestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            DELETE FROM @SamplesTemp
            WHERE SampleID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @PensideTestsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = PensideTestID,
                @PensideTestID = PensideTestID,
                @SampleID = SampleID,
                @PensideTestResultTypeID = PensideTestResultTypeID,
                @PensideTestNameTypeID = PensideTestNameTypeID,
                @RowStatus = RowStatus,
                @TestedByPersonID = TestedByPersonID,
                @TestedByOrganizationID = TestedByOrganizationID,
                @DiseaseID = DiseaseID,
                @TestDate = TestDate,
                @PensideTestCategoryTypeID = PensideTestCategoryTypeID,
                @RowAction = RowAction
            FROM @PensideTestsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_PENSIDE_TESTS_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @PensideTestID OUTPUT,
                                                   @SampleID,
                                                   @PensideTestResultTypeID,
                                                   @PensideTestNameTypeID,
                                                   @TestedByPersonID,
                                                   @TestedByOrganizationID,
                                                   @DiseaseID,
                                                   @TestDate,
                                                   @PensideTestCategoryTypeID,
                                                   @RowStatus,
                                                   @RowAction;

            DELETE FROM @PensideTestsTemp
            WHERE PensideTestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @LaboratoryTestsTemp)
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
                @TestComments = Comments,
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
            FROM @LaboratoryTestsTemp;

            --If record is being soft-deleted, then check if the test record was originally created 
            --in the laboaratory module.  If it was, then disassociate the test record from the 
            --veterinary disease report, so that the test record remains in the laboratory module 
            --for further action.
            IF @RowStatus = 1
               AND @NonLaboratoryTestIndicator = 0
            BEGIN
                SET @RowStatus = 0;
                SET @TestDiseaseReportID = NULL;
            END
            ELSE
            BEGIN
                SET @TestDiseaseReportID = @DiseaseReportID;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TESTS_SET @TestID OUTPUT,
                                           @TestNameTypeID,
                                           @TestCategoryTypeID,
                                           @TestResultTypeID,
                                           @TestStatusTypeID,
                                           @DiseaseID,
                                           @SampleID,
                                           NULL,
                                           NULL,
                                           NULL,
                                           @TestComments,
                                           @RowStatus,
                                           @StartedDate,
                                           @ResultDate,
                                           @TestedByOrganizationID,
                                           @TestedByPersonID,
                                           @ResultEnteredByOrganizationID,
                                           @ResultEnteredByPersonID,
                                           @ValidatedByOrganizationID,
                                           @ValidatedByPersonID,
                                           @ReadOnlyIndicator,
                                           @NonLaboratoryTestIndicator,
                                           @ExternalTestIndicator,
                                           @PerformedByOrganizationID,
                                           @ReceivedDate,
                                           @ContactPersonName,
                                           NULL,
                                           NULL,
                                           NULL,
                                           @TestDiseaseReportID,
                                           @AuditUserName,
                                           @DataAuditEventID,
                                           @EIDSSReportID,
                                           @RowAction;

            UPDATE @LaboratoryTestInterpretationsTemp
            SET TestID = @TestID
            WHERE TestID = @RowID;

            DELETE FROM @LaboratoryTestsTemp
            WHERE TestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @LaboratoryTestInterpretationsTemp)
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
            FROM @LaboratoryTestInterpretationsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TEST_INTERPRETATIONS_SET @AuditUserName,
                                                          @DataAuditEventID,
                                                          @EIDSSReportID, 
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

            IF @ReportSessionCreatedIndicator = 1 AND @RowAction = 1
            BEGIN
                SET @ConnectedDiseaseReportLaboratoryTestID = @TestID;
            END

            DELETE FROM @LaboratoryTestInterpretationsTemp
            WHERE TestInterpretationID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @CaseLogsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = CaseLogID,
                @CaseLogID = CaseLogID,
                @LogStatusTypeID = LogStatusTypeID,
                @LoggedByPersonID = LoggedByPersonID,
                @LogDate = LogDate,
                @ActionRequired = ActionRequired,
                @CaseLogComments = Comments,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @CaseLogsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_DISEASE_REPORT_LOG_SET @AuditUserName,
                                                        @DataAuditEventID,
                                                        @EIDSSReportID,
                                                        @CaseLogID,
                                                        @LogStatusTypeID,
                                                        @DiseaseReportID,
                                                        @LoggedByPersonID,
                                                        @LogDate,
                                                        @ActionRequired,
                                                        @CaseLogComments,
                                                        @RowStatus,
                                                        @RowAction;

            DELETE FROM @CaseLogsTemp
            WHERE CaseLogID = @RowID;
        END;

        IF @CaseMonitorings IS NOT NULL
        BEGIN
            EXEC dbo.USSP_OMM_CASE_MONITORING_SET @CaseMonitorings = @CaseMonitorings,
                                                  @VeterinaryDiseaseReportID = @DiseaseReportID,
                                                  @User = @AuditUserName;
        END

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
                @EventNote = Note,
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
                                             @AuditUserName,
                                             @DataAuditEventID,
                                             @EIDSSReportID;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @DiseaseReportID DiseaseReportID,
               @EIDSSReportID EIDSSReportID,
               @OutbreakCaseReportUID CaseID,
               @EIDSSCaseID EIDSSCaseID, 
               @ConnectedDiseaseReportLaboratoryTestID ConnectedDiseaseReportLaboratoryTestID;
    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
