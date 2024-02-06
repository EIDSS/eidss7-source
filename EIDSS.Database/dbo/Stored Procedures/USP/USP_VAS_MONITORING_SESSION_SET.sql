-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_SET
--
-- Description:	Inserts or updates veterinary surveillance session for the veterinary active surveillance 
-- session use cases.
--                      
-- Revision History:
-- Name					Date       Change Detail
-- ---------------		---------- -------------------------------------------------------------------
-- Mike Kornegay		02/02/2022 Initial release. (Copied from USP_VET_DISEASE_REPORT_SET).
-- Mike Kornegay		02/14/2022 Correct problem with saving actions - retrieve monitoring session id first.
-- Mike Kornegay		02/15/2022 Removed @SpeciesTypeID because this was the same as @ReportTypeID
-- Mike Kornegay		02/16/2022 Added back the animals temp to add or update animals 
--							  before samples are written.
-- Mike Kornegay		02/26/2022 Fixed FlockOrHerd section not passing the FarmID.
-- Mike Kornegay		03/08/2022 Removed MonitoringSessionID from samples - should come from new or update key
--							  and added @LocationID
-- Mike Kornegay		03/11/2022 Refactored Aggregate Info sections.
-- Mike Kornegay		03/18/2022 Corrected parameters for USSP_VCT_MONITORING_SESSION_SUMMARY_SET.
-- Mike Kornegay		03/19/2022 Corrected issue with farm copy for aggregate farms and saving of aggregate diseases.
-- Mike Kornegay		03/21/2022 Corrected defect in reading aggregate summary temp table.
-- Mani Govindarajan	05/26/2022 Disassociate MonitoringSession with Farm in tlbFarm Table  search for comment -- disassociate farm with session
-- Mike Kornegay		06/02/2022 Add notifications save routine.
-- Mike Kornegay		06/13/2022 Changed references for @ReportTypeID to point to the new SessionCategoryID fields.
-- Stephen Long         07/06/2022 Updates for site alerts to call new stored procedure.
-- Mike Kornegay		07/08/2022 Correct logic for removing aggregate farms from monitoring session.
-- Mike Kornegay		08/18/2022 Added logic for storing multiple diseases per sample.
-- Mike Kornegay        08/19/2022 Correct error on SampleToDisease temp table.
-- Mike Kornegay		09/05/2022 Fixed error where MonitoringSessionToDiagnosisID was not set correctly.
-- Mike Kornegay		09/30/2022 Add saving of idfsMonitoringSessionSpeciesType and correct farm save for new type.
-- Mike Kornegay		10/07/2022 Defect #5140 - EIDSSLocalOrFieldSampleID not generating correctly.
-- Mike Kornegay		11/01/2022 Correct iteration on EIDSSLocalOrFieldSampleID.
-- Leo Tracchia			12/07/2022 added logic for data auditing 
-- Leo Tracchia			12/15/2022 added additional audit logic for new parameters in GBL procs
-- Mike Kornegay		12/20/2022 corrected parameter list for USSP_GBL_TESTS_SET.
-- Stephen Long         01/16/2023 Fix for data audit on the event set.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_SET]
(
    @MonitoringSessionID BIGINT = NULL,
    @SessionID NVARCHAR(200) = NULL,
    @SessionStartDate DATETIME = NULL,
    @SessionEndDate DATETIME = NULL,
    @SessionStatusTypeID BIGINT = NULL,
    @SessionCategoryID BIGINT = NULL,
    @SiteID BIGINT = NULL,
    @LegacySessionID NVARCHAR(200) = NULL,
    @CountryID BIGINT = NULL,
    @RegionID BIGINT = NULL,
    @RayonID BIGINT = NULL,
    @SettlementID BIGINT = NULL,
    @CampaignKey BIGINT = NULL,
    @CampaignID NVARCHAR(200) = NULL,
    @DateEntered DATETIME = NULL,
    @EnteredByPersonID BIGINT = NULL,
    @RowStatus INT,
    @ReportTypeID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @FlocksOrHerds NVARCHAR(MAX) = NULL,
    @DiseaseSpeciesSamples NVARCHAR(MAX) = NULL,
    @Species NVARCHAR(MAX) = NULL,
    @Animals NVARCHAR(MAX) = NULL,
    @Farms NVARCHAR(MAX) = NULL,
    @Samples NVARCHAR(MAX) = NULL,
	@SamplesToDiseases NVARCHAR(MAX) = NULL,
    @LaboratoryTests NVARCHAR(MAX) = NULL,
    @LaboratoryTestInterpretations NVARCHAR(MAX) = NULL,
    @Actions NVARCHAR(MAX) = NULL,
    @AggregateSummaryInfo NVARCHAR(MAX) = NULL,
    @AggregateSummaryDiseases NVARCHAR(MAX) = NULL,
    @FarmsAggregate NVARCHAR(MAX) = NULL,
    @FlocksOrHerdsAggregate NVARCHAR(MAX) = NULL,
    @SpeciesAggregate NVARCHAR(MAX) = NULL,
    @DiseaseReports NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @UserID BIGINT,
    @LocationID BIGINT = NULL,
	@LinkLocalOrFieldSampleIDToReportID BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0;
        DECLARE @ReturnMessage NVARCHAR(MAX) = N'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );
        DECLARE @RowAction INT = NULL,
                @RowID BIGINT,
				@ChildRowID BIGINT,
				@Iteration INT = 0,
                @NewFarmOwnerID BIGINT = NULL,
                @FarmID BIGINT = NULL,
                @FarmMasterID BIGINT = NULL,
                @FarmOwnerID BIGINT = NULL,
                @Latitude FLOAT = NULL,
                @Longitude FLOAT = NULL,
                @FlockOrHerdID BIGINT = NULL,
                @FlockOrHerdMasterID BIGINT = NULL,
                @EIDSSFlockOrHerdID NVARCHAR(200) = NULL,
                @SickAnimalQuantity INT = NULL,
                @TotalAnimalQuantity INT = NULL,
                @DeadAnimalQuantity INT = NULL,
                @Comments NVARCHAR(2000) = NULL,
                @SpeciesID BIGINT = NULL,
                @SpeciesMasterID BIGINT = NULL,
                @InternalSpeciesTypeID BIGINT = NULL,
                @StartOfSignsDate DATETIME = NULL,
                @AverageAge NVARCHAR(200) = NULL,
                @ObservationID BIGINT = NULL,
                @AnimalID BIGINT = NULL,
                @SexTypeID BIGINT = NULL,
                @DiseaseID BIGINT = NULL,
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
                @SpeciesTypeID BIGINT = NULL,
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
                @TestMonitoringSesssionID BIGINT = NULL,
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
                @EventLoginSiteId BIGINT = NULL,
                @MonitoringSessionActionID BIGINT = NULL,
                @MonitoringSessionActionStatusTypeID BIGINT = NULL,
                @MonitoringSessionActionTypeID BIGINT = NULL,
                @MonitoringSessionToDiagnosis BIGINT = NULL,
                @MonitoringSessionSummaryID BIGINT = NULL,
				@MonitoringSessionToMaterialID BIGINT = NULL,
                @ActionDate DATETIME = NULL,
                @SampledAnimalsQuantity INT = NULL,
                @SamplesQuantity INT = NULL,
                @PositiveAnimalsQuantity INT = NULL,
                @Order INT = NULL;


        DECLARE @DiseaseSpeciesSampleTemp TABLE
        (
            MonitoringSessionToDiagnosisID BIGINT NOT NULL,
            DiseaseID BIGINT NOT NULL,
            [Order] INT NOT NULL,
            SpeciesTypeID BIGINT NULL,
            SampleTypeID BIGINT NULL,
            RowStatus INT NULL,
            RowAction INT NULL
        );
        DECLARE @FarmsTemp TABLE
        (
            FarmMasterID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            TotalAnimalQuantity INT NULL,
            Latitude FLOAT NULL,
            Longitude FLOAT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @FlocksOrHerdsTemp TABLE
        (
            FlockOrHerdID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            FarmMasterID BIGINT NULL,
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
            RelatedToObservationID BIGINT NULL
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
        DECLARE @SamplesTemp TABLE
        (
            SampleID BIGINT NOT NULL,
            SampleTypeID BIGINT NULL,
            RootSampleID BIGINT NULL,
            ParentSampleID BIGINT NULL,
            SpeciesID BIGINT NULL,
            AnimalID BIGINT NULL,
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
            FarmID BIGINT NULL,
            FarmMasterID BIGINT NULL,
            FarmOwnerID BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
		DECLARE @SamplesToDiseasesTemp TABLE
        (
            MonitoringSessionToMaterialID BIGINT NOT NULL,
            MonitoringSessionID BIGINT NOT NULL,
			SampleID BIGINT NOT NULL,
			SampleTypeID BIGINT NULL,
            DiseaseID BIGINT NOT NULL,
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
        DECLARE @ActionsTemp TABLE
        (
            MonitoringSessionActionID BIGINT NOT NULL,
            MonitoringSessionActionStatusTypeID BIGINT NULL,
            MonitoringSessionActionTypeID BIGINT NULL,
            EnteredByPersonID BIGINT NULL,
            ActionDate DATETIME NULL,
            Comments NVARCHAR(1000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @AggregateSummaryInfoTemp TABLE
        (
            MonitoringSessionSummaryID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            FarmMasterID BIGINT NULL,
            SpeciesID BIGINT NULL,
            AnimalSexID BIGINT NULL,
            SampleAnimalsQty INT NULL,
            SamplesQty INT NULL,
            CollectionDate DATETIME NULL,
            CollectedByPersonID BIGINT NULL,
            PositiveAnimalsQty INT NULL,
            DiseaseID BIGINT NULL,
            SampleTypeID BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @AggregateSummaryDiseasesTemp TABLE
        (
            MonitoringSessionSummaryID BIGINT NULL,
            DiseaseID BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @FarmsAggregateTemp TABLE
        (
            FarmMasterID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            TotalAnimalQuantity INT NULL,
            Latitude FLOAT NULL,
            Longitude FLOAT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @FlocksOrHerdsAggregateTemp TABLE
        (
            FlockOrHerdID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            FarmMasterID BIGINT NULL,
            FlockOrHerdMasterID BIGINT NULL,
            EIDSSFlockOrHerdID NVARCHAR(200) NULL,
            SickAnimalQuantity INT NULL,
            TotalAnimalQuantity INT NULL,
            DeadAnimalQuantity INT NULL,
            RowStatus INT NULL,
            RowAction INT NULL
        );
        DECLARE @SpeciesAggregateTemp TABLE
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
            RelatedToObservationID BIGINT NULL
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

        BEGIN TRANSACTION;

        INSERT INTO @DiseaseSpeciesSampleTemp
        SELECT *
        FROM
            OPENJSON(@DiseaseSpeciesSamples)
            WITH
            (
                MonitoringSessionToDiagnosisID BIGINT,
                DiseaseID BIGINT,
                [Order] INT,
                SpeciesTypeID BIGINT,
                SampleTypeID BIGINT,
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @FarmsTemp
        SELECT *
        FROM
            OPENJSON(@Farms)
            WITH
            (
                FarmMasterID BIGINT,
                FarmID BIGINT,
                TotalAnimalQuantity INT,
                Latitude FLOAT,
                Longitude FLOAT,
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @FlocksOrHerdsTemp
        SELECT *
        FROM
            OPENJSON(@FlocksOrHerds)
            WITH
            (
                FlockOrHerdID BIGINT,
                FarmID BIGINT,
                FarmMasterID BIGINT,
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
                RelatedToObservationID BIGINT
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
                FarmID BIGINT,
                FarmMasterID BIGINT,
                FarmOwnerID BIGINT,
                RowStatus INT,
                RowAction INT
            );

		SET @Iteration = (SELECT COUNT(*) FROM dbo.tlbMaterial WHERE idfMonitoringSession = @MonitoringSessionID);

		INSERT INTO @SamplesToDiseasesTemp
		SELECT *
		FROM
			OPENJSON(@SamplesToDiseases)
			WITH
			(
				MonitoringSessionToMaterialID BIGINT,
				MonitoringSessionID BIGINT,
				SampleID BIGINT,
				SampleTypeID BIGINT,
				DiseaseID BIGINT,
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
        INSERT INTO @ActionsTemp
        SELECT *
        FROM
            OPENJSON(@Actions)
            WITH
            (
                MonitoringSessionActionID BIGINT,
                MonitoringSessionActionStatusTypeID BIGINT,
                MonitoringSessionActionTypeID BIGINT,
                EnteredByPersonID BIGINT,
                ActionDate DATETIME,
                Comments NVARCHAR(1000),
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @AggregateSummaryInfoTemp
        SELECT *
        FROM
            OPENJSON(@AggregateSummaryInfo)
            WITH
            (
                MonitoringSessionSummaryID BIGINT,
                FarmID BIGINT,
                FarmMasterID BIGINT,
                SpeciesID BIGINT,
                AnimalSexID BIGINT,
                SampleAnimalsQty INT,
                SamplesQty INT,
                CollectionDate DATETIME,
                CollectedByPersonID BIGINT,
                PositiveAnimalsQty INT,
                DiseaseID BIGINT,
                SampleTypeID BIGINT,
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @AggregateSummaryDiseasesTemp
        SELECT *
        FROM
            OPENJSON(@AggregateSummaryDiseases)
            WITH
            (
                MonitoringSessionSummaryID BIGINT,
                DiseaseID BIGINT,
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @FarmsAggregateTemp
        SELECT *
        FROM
            OPENJSON(@FarmsAggregate)
            WITH
            (
                FarmMasterID BIGINT,
                FarmID BIGINT,
                TotalAnimalQuantity INT,
                Latitude FLOAT,
                Longitude FLOAT,
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @FlocksOrHerdsAggregateTemp
        SELECT *
        FROM
            OPENJSON(@FlocksOrHerdsAggregate)
            WITH
            (
                FlockOrHerdID BIGINT,
                FarmID BIGINT,
                FarmMasterID BIGINT,
                FlockOrHerdMasterID BIGINT,
                EIDSSFlockOrHerdID NVARCHAR(200),
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                RowStatus INT,
                RowAction INT
            );
        INSERT INTO @SpeciesAggregateTemp
        SELECT *
        FROM
            OPENJSON(@SpeciesAggregate)
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
                RelatedToObservationID BIGINT
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

		--Data Audit--

		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017062; --select * from trtBaseReference where strDefault = 'Veterinary Active Surveillance Session'
		DECLARE @idfObject bigint = @MonitoringSessionID;
		DECLARE @idfObjectTable_tlbMonitoringSession bigint = 707040000000;	--select * from tauTable where strName = 'tlbMonitoringSession'	 
		DECLARE @idfDataAuditEvent bigint = NULL;		

		DECLARE @tlbMonitoringSession_BeforeEdit TABLE
		(
			idfMonitoringSession bigint,
			idfsMonitoringSessionStatus bigint,
            idfsCountry bigint,
            idfsRegion bigint,
            idfsRayon bigint,
            idfsSettlement bigint,
            idfPersonEnteredBy bigint,
            idfCampaign bigint,
            idfsSite bigint,
            datEnteredDate datetime,
            strMonitoringSessionID nvarchar(50),
            intRowStatus int,
            datStartDate datetime,
            datEndDate datetime,
            SessionCategoryID bigint,
            LegacySessionID varchar(50),            
            idfsLocation bigint,
			idfsMonitoringSessionSpeciesType bigint
		)		

		DECLARE @tlbMonitoringSession_AfterEdit TABLE
		(
			idfMonitoringSession bigint,
			idfsMonitoringSessionStatus bigint,
            idfsCountry bigint,
            idfsRegion bigint,
            idfsRayon bigint,
            idfsSettlement bigint,
            idfPersonEnteredBy bigint,
            idfCampaign bigint,
            idfsSite bigint,
            datEnteredDate datetime,
            strMonitoringSessionID nvarchar(50),
            intRowStatus int,
            datStartDate datetime,
            datEndDate datetime,
            SessionCategoryID bigint,
            LegacySessionID varchar(50),            
            idfsLocation bigint,
			idfsMonitoringSessionSpeciesType bigint
		)		
		
		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo

		--Data Audit--

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbMonitoringSession
            WHERE idfMonitoringSession = @MonitoringSessionID
                  AND intRowStatus = 0
        )
        BEGIN

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbMonitoringSession',
                                              @MonitoringSessionID OUTPUT;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET 'Vet Active Surveillance Session',
                                               @SessionID OUTPUT,                                               
											   NULL;
			--Data Audit--	

				-- tauDataAuditEvent Event Type - Create 
				set @idfsDataAuditEventType = 10016001;
			
				-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @MonitoringSessionID, @idfObjectTable_tlbMonitoringSession, @idfDataAuditEvent OUTPUT

			--Data Audit--

            INSERT INTO dbo.tlbMonitoringSession
            (
                [idfMonitoringSession],
                [idfsMonitoringSessionStatus],
                [idfsCountry],
                [idfsRegion],
                [idfsRayon],
                [idfsSettlement],
                [idfPersonEnteredBy],
                [idfCampaign],
                [idfsSite],
                [datEnteredDate],
                [strMonitoringSessionID],
                [intRowStatus],
                [datStartDate],
                [datEndDate],
                [SessionCategoryID],
                [LegacySessionID],
                [AuditCreateUser],
                [SourceSystemNameID],
                [SourceSystemKeyValue],
                [idfsLocation],
				[idfsMonitoringSessionSpeciesType]
            )
            VALUES
				(@MonitoringSessionID,
				 @SessionStatusTypeID,
				 @CountryID,
				 @RegionID,
				 @RayonID,
				 @SettlementID,
				 @EnteredByPersonID,
				 @CampaignKey,
				 @SiteID,
				 @DateEntered,
				 @SessionID,
				 0  ,
				 @SessionStartDate,
				 @SessionEndDate,
				 @SessionCategoryID,
				 @LegacySessionID,
				 @AuditUserName,
				 10519001,
				 '[{"idfMonitoringSessionID":' + CAST(@MonitoringSessionID AS NVARCHAR(300)) + '}]',
				 @LocationID,
				 @ReportTypeID
            );

			--Data Audit--							

				INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_tlbMonitoringSession, @MonitoringSessionID)
			
			--Data Audit--

            UPDATE @EventsTemp
            SET ObjectId = @MonitoringSessionID
            WHERE ObjectId = 0;

        END
        ELSE
        BEGIN

			--DataAudit-- 
				
				--  tauDataAuditEvent  Event Type - Edit 
				set @idfsDataAuditEventType = 10016003;
			
				-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_tlbMonitoringSession, @idfDataAuditEvent OUTPUT

			--DataAudit-- 

			INSERT INTO @tlbMonitoringSession_BeforeEdit (
				idfMonitoringSession,
				idfsMonitoringSessionStatus,
				idfsCountry,
				idfsRegion,
				idfsRayon,
				idfsSettlement,
				idfPersonEnteredBy,
				idfCampaign,
				idfsSite,
				datEnteredDate,
				strMonitoringSessionID,
				intRowStatus,
				datStartDate,
				datEndDate,
				SessionCategoryID,
				LegacySessionID,
				idfsLocation,
				idfsMonitoringSessionSpeciesType)
			SELECT 
				idfMonitoringSession,
				idfsMonitoringSessionStatus,
				idfsCountry,
				idfsRegion,
				idfsRayon,
				idfsSettlement,
				idfPersonEnteredBy,
				idfCampaign,
				idfsSite,
				datEnteredDate,
				strMonitoringSessionID,
				intRowStatus,
				datStartDate,
				datEndDate,
				SessionCategoryID,
				LegacySessionID,
				idfsLocation,
				idfsMonitoringSessionSpeciesType
				FROM [tlbMonitoringSession] WHERE idfMonitoringSession = @MonitoringSessionID;

            UPDATE [dbo].[tlbMonitoringSession]
            SET [idfsMonitoringSessionStatus] = @SessionStatusTypeID,
                [idfsCountry] = @CountryID,
                [idfsRegion] = @RegionID,
                [idfsRayon] = @RayonID,
                [idfsSettlement] = @SettlementID,
                [idfPersonEnteredBy] = @EnteredByPersonID,
                [idfCampaign] = @CampaignKey,
                [idfsSite] = @SiteID,
                [datEnteredDate] = @DateEntered,
                [strMonitoringSessionID] = @SessionID,
                [intRowStatus] = 0,
                [datStartDate] = @SessionStartDate,
                [datEndDate] = @SessionEndDate,
                [SessionCategoryID] = @SessionCategoryID,
                [LegacySessionID] = @LegacySessionID,
                [AuditUpdateUser] = @AuditUserName,
                [idfsLocation] = @LocationID,
				[idfsMonitoringSessionSpeciesType] = @ReportTypeID
            WHERE idfMonitoringSession = @MonitoringSessionID

			INSERT INTO @tlbMonitoringSession_AfterEdit (
				idfMonitoringSession,
				idfsMonitoringSessionStatus,
				idfsCountry,
				idfsRegion,
				idfsRayon,
				idfsSettlement,
				idfPersonEnteredBy,
				idfCampaign,
				idfsSite,
				datEnteredDate,
				strMonitoringSessionID,
				intRowStatus,
				datStartDate,
				datEndDate,
				SessionCategoryID,
				LegacySessionID,
				idfsLocation,
				idfsMonitoringSessionSpeciesType)
			SELECT 
				idfMonitoringSession,
				idfsMonitoringSessionStatus,
				idfsCountry,
				idfsRegion,
				idfsRayon,
				idfsSettlement,
				idfPersonEnteredBy,
				idfCampaign,
				idfsSite,
				datEnteredDate,
				strMonitoringSessionID,
				intRowStatus,
				datStartDate,
				datEndDate,
				SessionCategoryID,
				LegacySessionID,
				idfsLocation,
				idfsMonitoringSessionSpeciesType
				FROM [tlbMonitoringSession] WHERE idfMonitoringSession = @MonitoringSessionID;

			--idfsMonitoringSessionStatus
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707060000000,
				a.idfMonitoringSession,
				null,
				a.idfsMonitoringSessionStatus,
				b.idfsMonitoringSessionStatus 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfsMonitoringSessionStatus <> b.idfsMonitoringSessionStatus) 
				or(a.idfsMonitoringSessionStatus is not null and b.idfsMonitoringSessionStatus is null)
				or(a.idfsMonitoringSessionStatus is null and b.idfsMonitoringSessionStatus is not null)

			--idfsCountry
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707070000000,
				a.idfMonitoringSession,
				null,
				a.idfsCountry,
				b.idfsCountry 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfsCountry <> b.idfsCountry) 
				or(a.idfsCountry is not null and b.idfsCountry is null)
				or(a.idfsCountry is null and b.idfsCountry is not null)

			--idfsRegion
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707080000000,
				a.idfMonitoringSession,
				null,
				a.idfsRegion,
				b.idfsRegion 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfsRegion <> b.idfsRegion) 
				or(a.idfsRegion is not null and b.idfsRegion is null)
				or(a.idfsRegion is null and b.idfsRegion is not null)

			--idfsRayon
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707090000000,
				a.idfMonitoringSession,
				null,
				a.idfsRayon,
				b.idfsRayon 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfsRayon <> b.idfsRayon) 
				or(a.idfsRayon is not null and b.idfsRayon is null)
				or(a.idfsRayon is null and b.idfsRayon is not null)

			--idfsSettlement
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707100000000,
				a.idfMonitoringSession,
				null,
				a.idfsSettlement,
				b.idfsSettlement 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfsSettlement <> b.idfsSettlement) 
				or(a.idfsSettlement is not null and b.idfsSettlement is null)
				or(a.idfsSettlement is null and b.idfsSettlement is not null)

			--idfPersonEnteredBy
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707110000000,
				a.idfMonitoringSession,
				null,
				a.idfPersonEnteredBy,
				b.idfPersonEnteredBy 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfPersonEnteredBy <> b.idfPersonEnteredBy) 
				or(a.idfPersonEnteredBy is not null and b.idfPersonEnteredBy is null)
				or(a.idfPersonEnteredBy is null and b.idfPersonEnteredBy is not null)

			--idfCampaign
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707120000000,
				a.idfMonitoringSession,
				null,
				a.idfCampaign,
				b.idfCampaign 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.idfCampaign <> b.idfCampaign) 
				or(a.idfCampaign is not null and b.idfCampaign is null)
				or(a.idfCampaign is null and b.idfCampaign is not null)

			--datEnteredDate
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707130000000,
				a.idfMonitoringSession,
				null,
				a.datEnteredDate,
				b.datEnteredDate 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.datEnteredDate <> b.datEnteredDate) 
				or(a.datEnteredDate is not null and b.datEnteredDate is null)
				or(a.datEnteredDate is null and b.datEnteredDate is not null)

			--strMonitoringSessionID
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				707140000000,
				a.idfMonitoringSession,
				null,
				a.strMonitoringSessionID,
				b.strMonitoringSessionID 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.strMonitoringSessionID <> b.strMonitoringSessionID) 
				or(a.strMonitoringSessionID is not null and b.strMonitoringSessionID is null)
				or(a.strMonitoringSessionID is null and b.strMonitoringSessionID is not null)

			--datStartDate
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				4578670000000,
				a.idfMonitoringSession,
				null,
				a.datStartDate,
				b.datStartDate 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.datStartDate <> b.datStartDate) 
				or(a.datStartDate is not null and b.datStartDate is null)
				or(a.datStartDate is null and b.datStartDate is not null)

			--datEndDate
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, 
				idfObjectTable, 
				idfColumn, 
				idfObject, 
				idfObjectDetail, 
				strOldValue, 
				strNewValue)
			select 
				@idfDataAuditEvent,
				@idfObjectTable_tlbMonitoringSession, 
				4578680000000,
				a.idfMonitoringSession,
				null,
				a.datEndDate,
				b.datEndDate 
			from @tlbMonitoringSession_BeforeEdit a  inner join @tlbMonitoringSession_AfterEdit b on a.idfMonitoringSession = b.idfMonitoringSession
			where (a.datEndDate <> b.datEndDate) 
				or(a.datEndDate is not null and b.datEndDate is null)
				or(a.datEndDate is null and b.datEndDate is not null)

        END;

        WHILE EXISTS (SELECT * FROM @DiseaseSpeciesSampleTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionToDiagnosisID,
				@MonitoringSessionToDiagnosis = MonitoringSessionToDiagnosisID,
                @DiseaseID = DiseaseID,
                @SpeciesTypeID = SpeciesTypeID,
                @SampleTypeID = SampleTypeID,
                @Order = [Order],
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @DiseaseSpeciesSampleTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VAS_MONITORING_SESSION_TO_DIAGNOSIS_SPECIES_SAMPLE_SET @MonitoringSessionToDiagnosis OUTPUT,
																					@idfDataAuditEvent,
                                                                                    @MonitoringSessionID,
                                                                                    @DiseaseID,
                                                                                    @SpeciesTypeID,
                                                                                    @SampleTypeID,
                                                                                    @Order,
                                                                                    @RowStatus,
                                                                                    @RowAction,
                                                                                    @AuditUserName;

            DELETE FROM @DiseaseSpeciesSampleTemp
            WHERE MonitoringSessionToDiagnosisID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @FarmsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FarmMasterID,
                @FarmMasterID = FarmMasterID,
                @FarmID = FarmID,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @Latitude = Latitude,
                @Longitude = Longitude,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FarmsTemp;



            IF @ReportTypeID = 129909620007069 --Avian
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_FARM_COPY @AuditUserName,
                                               @RowID,
                                               @TotalAnimalQuantity,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               @Latitude,
                                               @Longitude,
                                               @MonitoringSessionID,
                                               NULL,
                                               @FarmOwnerID,
                                               @FarmID OUTPUT,
                                               @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;

                UPDATE @FlocksOrHerdsTemp
                SET FarmID = @FarmID
                WHERE FarmMasterID = @RowID;

                UPDATE @SamplesTemp
                SET FarmID = @FarmID
                WHERE FarmMasterID = @RowID;

            END
            ELSE --Livestock
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_FARM_COPY @AuditUserName,
                                               @RowID,
                                               NULL,
                                               NULL,
                                               NULL,
                                               @TotalAnimalQuantity,
                                               NULL,
                                               NULL,
                                               @Latitude,
                                               @Longitude,
                                               @MonitoringSessionID,
                                               NULL,
                                               @FarmOwnerID,
                                               @FarmID OUTPUT,
                                               @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;

                UPDATE @FlocksOrHerdsTemp
                SET FarmID = @FarmID
                WHERE FarmMasterID = @RowID;

                UPDATE @SamplesTemp
                SET FarmID = @FarmID
                WHERE FarmMasterID = @RowID;
            END

            -- disassociate farm with session 
            if ((@MonitoringSessionID IS NOT NULL) AND (@RowStatus = 1))
            BEGIN
                UPDATE dbo.tlbFarm
                set idfMonitoringSession = null
                where idfFarm = @FarmID
                      and idfMonitoringSession = @MonitoringSessionID;
            END;


            DELETE FROM @FarmsTemp
            WHERE FarmMasterID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @FlocksOrHerdsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FlockOrHerdID,
                @FlockOrHerdID = FlockOrHerdID,
                @FarmID = FarmID,
                @FarmMasterID = FarmMasterID,
                @FlockOrHerdMasterID = FlockOrHerdMasterID,
                @EIDSSFlockOrHerdID = EIDSSFlockOrHerdID,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FlocksOrHerdsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_HERD_SET @AuditUserName,
										  @idfDataAuditEvent,
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
                @Comments = Comments,
                @ObservationID = ObservationID,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @RelatedToSpeciesID = RelatedToSpeciesID,
                @RelatedToObservationID = RelatedToObservationID
            FROM @SpeciesTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_SPECIES_SET @AuditUserName,
											 @idfDataAuditEvent,
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
                                             @Comments,
                                             @RowStatus,
                                             @RowAction;

            UPDATE @AnimalsTemp
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

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_ANIMAL_SET @AuditUserName,
											@idfDataAuditEvent,
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
                @CollectedByPersonID = CollectedByPersonID,
                @CollectedByOrganizationID = CollectedByOrganizationID,
                @CollectionDate = CollectionDate,
                @SentDate = SentDate,
                @EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
                @SampleStatusTypeID = SampleStatusTypeID,
                @FarmID = FarmID,
                @FarmMasterID = FarmMasterID,
                @DiseaseID = DiseaseID,
                @DateEntered = EnteredDate,
                @Comments = Comments,
                @SiteID = SiteID,
                @CurrentSiteID = CurrentSiteID,
                @RowStatus = RowStatus,
                @SentToOrganizationID = SentToOrganizationID,
                @BirdStatusTypeID = BirdStatusTypeID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @RowAction = RowAction
            FROM @SamplesTemp;

			--Format the EIDSSLocalOrFieldSampleID according to system preferences.
			IF (
				@EIDSSLocalOrFieldSampleID IS NULL
				OR @EIDSSLocalOrFieldSampleID = ''
               )
               AND @LinkLocalOrFieldSampleIDToReportID = 1
            BEGIN
                SET @Iteration = @Iteration + 1;
                IF @Iteration < 10
                BEGIN
                    SET @EIDSSLocalOrFieldSampleID = @SessionID + '-0' + CONVERT(NVARCHAR(4), @Iteration);
                END
                ELSE
                BEGIN
                    SET @EIDSSLocalOrFieldSampleID = @SessionID + '-' + CONVERT(NVARCHAR(4), @Iteration);
                END;
            END;

			INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_SAMPLES_SET @AuditUserName,
											@idfDataAuditEvent,
											@MonitoringSessionID,
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
                                            NULL,
                                            @CollectionDate,
                                            @CollectedByPersonID,
                                            @CollectedByOrganizationID,
                                            @SentDate,
                                            @SentToOrganizationID,
                                            @EIDSSLocalOrFieldSampleID,
                                            @SiteID,
                                            @DateEntered,
                                            @ReadOnlyIndicator,
                                            @SampleStatusTypeID,
                                            @Comments,
                                            @CurrentSiteID,
                                            @DiseaseID,
                                            @BirdStatusTypeID,
                                            @RowStatus,
                                            @RowAction;
		       	   		 
            UPDATE @LaboratoryTestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

			UPDATE @SamplesToDiseasesTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            DELETE FROM @SamplesTemp
            WHERE SampleID = @RowID;
        END;

		WHILE EXISTS (SELECT * FROM @SamplesToDiseasesTemp)
		BEGIN
			SELECT TOP 1
				@RowID = MonitoringSessionToMaterialID,
				@MonitoringSessionToMaterialID = MonitoringSessionToMaterialID,
				@MonitoringSessionID = @MonitoringSessionID,
				@SampleID = SampleID,
				@SampleTypeID = SampleTypeID,
				@DiseaseID = DiseaseID,
				@RowAction = RowAction,
				@RowStatus = RowStatus
			FROM @SamplesToDiseasesTemp;

			--insert or update the diseases for this sample
			INSERT INTO @SuppressSelect
			EXECUTE dbo.USSP_VAS_SAMPLE_TO_DISEASE_SET
										@AuditUserName,
										@idfDataAuditEvent,
                                        @MonitoringSessionToMaterialID,
										@MonitoringSessionID,
										@SampleID,
										@DiseaseID,
                                        @SampleTypeID,
                                        @RowStatus,
                                        @RowAction;

			DELETE FROM @SamplesToDiseasesTemp
			WHERE MonitoringSessionToMaterialID = @RowID;
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
            FROM @LaboratoryTestsTemp;

            --If record is being soft-deleted, then check if the test record was originally created 
            --in the laboaratory module.  If it was, then disassociate the test record from the 
            --veterinary surveillance session, so that the test record remains in the laboratory module 
            --for further action.
            IF @RowStatus = 1
               AND @NonLaboratoryTestIndicator = 0
            BEGIN
                SET @RowStatus = 0;
                SET @TestMonitoringSesssionID = NULL;
            END
            ELSE
            BEGIN
                SET @TestMonitoringSesssionID = @MonitoringSessionID;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TESTS_SET 
                                          @TestID OUTPUT,
                                          @TestNameTypeID,
                                          @TestCategoryTypeID,
                                          @TestResultTypeID,
                                          @TestStatusTypeID,
                                          @DiseaseID,
                                          @SampleID,
                                          NULL,
                                          NULL,
                                          NULL,
                                          @Comments,
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
                                          @MonitoringSessionID,
                                          NULL,
                                          NULL,
                                          NULL,
                                          @AuditUserName,
										  @idfDataAuditEvent,
										  @MonitoringSessionID,
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
														 @idfDataAuditEvent,
														 @MonitoringSessionID,
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

            DELETE FROM @LaboratoryTestInterpretationsTemp
            WHERE TestInterpretationID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @ActionsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionActionID,
                @MonitoringSessionActionTypeID = MonitoringSessionActionTypeID,
                @MonitoringSessionActionStatusTypeID = MonitoringSessionActionStatusTypeID,
                @EnteredByPersonID = EnteredByPersonID,
                @ActionDate = ActionDate,
                @Comments = Comments,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @ActionsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VAS_MONITORING_SESSION_ACTION_SET @MonitoringSessionActionID,
															   @idfDataAuditEvent,
                                                               @MonitoringSessionID,
                                                               @EnteredByPersonID,
                                                               @MonitoringSessionActionTypeID,
                                                               @MonitoringSessionActionStatusTypeID,
                                                               @ActionDate,
                                                               @Comments,
                                                               @RowStatus,
                                                               @RowAction,
                                                               @AuditUserName;

            DELETE FROM @ActionsTemp
            WHERE MonitoringSessionActionID = @RowID;
        END;

        /* Aggregate Information Section */

        WHILE EXISTS (SELECT * FROM @FarmsAggregateTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FarmMasterID,
                @FarmMasterID = FarmMasterID,
                @FarmID = FarmID,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @Latitude = Latitude,
                @Longitude = Longitude,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FarmsAggregateTemp;

            IF @ReportTypeID = 129909620007069 --Avian
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_FARM_COPY @AuditUserName,
                                               @RowID,
                                               @TotalAnimalQuantity,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               @Latitude,
                                               @Longitude,
                                               NULL,
                                               NULL,
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
                EXECUTE dbo.USSP_VET_FARM_COPY @AuditUserName,
                                               @RowID,
                                               NULL,
                                               NULL,
                                               NULL,
                                               @TotalAnimalQuantity,
                                               NULL,
                                               NULL,
                                               @Latitude,
                                               @Longitude,
                                               NULL,
                                               NULL,
                                               @FarmOwnerID,
                                               @FarmID OUTPUT,
                                               @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;

            END

            UPDATE @FlocksOrHerdsAggregateTemp
            SET FarmID = @FarmID
            WHERE FarmMasterID = @RowID;

            UPDATE @AggregateSummaryInfoTemp
            SET FarmID = @FarmID
            WHERE FarmMasterID = @RowID;

			/*farm is being removed from aggregate monitoring session*/
			IF ((@MonitoringSessionID IS NOT NULL) AND (@RowStatus = 1))
			BEGIN
				UPDATE dbo.tlbFarm 
				SET  idfMonitoringSession = null
					,intRowStatus = @RowStatus
				WHERE idfFarm = @FarmID;
			END;

            DELETE FROM @FarmsAggregateTemp
            WHERE FarmMasterID = @RowID;

        END;

        WHILE EXISTS (SELECT * FROM @FlocksOrHerdsAggregateTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FlockOrHerdID,
                @FlockOrHerdID = FlockOrHerdID,
                @FarmID = FarmID,
                @FarmMasterID = FarmMasterID,
                @FlockOrHerdMasterID = FlockOrHerdMasterID,
                @EIDSSFlockOrHerdID = EIDSSFlockOrHerdID,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FlocksOrHerdsAggregateTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_HERD_SET @AuditUserName,
										  @idfDataAuditEvent,
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

            UPDATE @SpeciesAggregateTemp
            SET FlockOrHerdID = @FlockOrHerdID
            WHERE FlockOrHerdID = @RowID;

            DELETE FROM @FlocksOrHerdsAggregateTemp
            WHERE FLockOrHerdID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @SpeciesAggregateTemp)
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
                @Comments = Comments,
                @ObservationID = ObservationID,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @RelatedToSpeciesID = RelatedToSpeciesID,
                @RelatedToObservationID = RelatedToObservationID
            FROM @SpeciesAggregateTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_SPECIES_SET @AuditUserName,
											 @idfDataAuditEvent,
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
                                             @Comments,
                                             @RowStatus,
                                             @RowAction;

            UPDATE @AggregateSummaryInfoTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            DELETE FROM @SpeciesAggregateTemp
            WHERE SpeciesID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @AggregateSummaryInfoTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionSummaryID,
                @MonitoringSessionSummaryID = MonitoringSessionSummaryID,
                @SpeciesID = SpeciesID,
                @SampledAnimalsQuantity = SampleAnimalsQty,
                @SamplesQuantity = SamplesQty,
                @CollectionDate = CollectionDate,
                @CollectedByPersonID = CollectedByPersonID,
                @PositiveAnimalsQuantity = PositiveAnimalsQty,
                @SexTypeID = AnimalSexID,
                @FarmID = FarmID,
                @FarmMasterID = FarmMasterID,
                @DiseaseID = DiseaseID,
                @SampleTypeID = SampleTypeID,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @AggregateSummaryInfoTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VCT_MONITORING_SESSION_SUMMARY_SET @MonitoringSessionSummaryID OUTPUT,
																@idfDataAuditEvent,
                                                                @MonitoringSessionID,
                                                                @FarmID,
                                                                @SpeciesID,
                                                                @SexTypeID,
                                                                @SampledAnimalsQuantity,
                                                                @SamplesQuantity,
                                                                @CollectionDate,
                                                                @PositiveAnimalsQuantity,
                                                                @RowStatus,
                                                                @DiseaseID,
                                                                @SampleTypeID,
                                                                @RowAction,
                                                                @AuditUserName;

            UPDATE @AggregateSummaryDiseasesTemp
            SET MonitoringSessionSummaryID = @MonitoringSessionSummaryID
            WHERE MonitoringSessionSummaryID = @RowID

            DELETE FROM @AggregateSummaryInfoTemp
            WHERE MonitoringSessionSummaryID = @RowID;

            PRINT @RowID
        END;

        WHILE EXISTS (SELECT * FROM @AggregateSummaryDiseasesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = MonitoringSessionSummaryID,
                @MonitoringSessionSummaryID = MonitoringSessionSummaryID,
                @DiseaseID = DiseaseID,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @AggregateSummaryDiseasesTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VCT_MONITORING_SESSION_SUMMARY_DIAGNOSIS_SET @MonitoringSessionSummaryID,
																		  @idfDataAuditEvent,
                                                                          @RowStatus,
                                                                          @DiseaseID,
                                                                          @RowAction,
                                                                          @AuditUserName;


            DELETE FROM @AggregateSummaryDiseasesTemp
            WHERE @MonitoringSessionSummaryID = @RowID;
        END;

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
                                             @AuditUserName, 
                                             @idfDataAuditEvent,
                                             @SessionID;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @MonitoringSessionID SessionKey,
               @SessionID SessionID;
    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END