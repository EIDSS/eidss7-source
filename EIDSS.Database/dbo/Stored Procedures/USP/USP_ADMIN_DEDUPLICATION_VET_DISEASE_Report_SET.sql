


-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_VET_DISEASE_Report_SET
--
-- Description:	Deduplication for Livestock and Avian disease report record.
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		17May2022	Initial release
-- Mark Wilson		19May2022	Added Testing, Penside Tests, Interpretations and CaseLogs
-- Ann Xiong		7/26/2022	Replaced "@Notifications = @Notifications" with "@Events = @Notifications" to fix the error "@Notifications is not a parameter for procedure USP_VET_DISEASE_REPORT_SET."
-- Ann Xiong		12/21/2022	Modified to pass parameter '@AuditUserName' when call USP_VET_DISEASE_REPORT_DEL
-- Ann Xiong		03/07/2023  Implemented Data Audit
-- Ann Xiong	    03/09/2023  Modified to pass parameter '@DataAuditEventID' when call USP_VET_DISEASE_REPORT_SET and USP_VET_DISEASE_REPORT_DEL
-- Ann Xiong		03/17/2023	Fixed a few issues when UPDATE dbo.tlbMaterial and UPDATE dbo.tlbVaccination
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_VET_DISEASE_Report_SET]
(
	@SurvivorVeterinaryDiseaseReportID BIGINT,
	@SupersededVeterinaryDiseaseReportID BIGINT,
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
	@Notifications NVARCHAR(MAX) = NULL,
	@UserID BIGINT,
	@LinkLocalOrFieldSampleIDToReportID BIT = 0,
	@OutbreakCaseIndicator BIT = 0,
	@OutbreakCaseReportUID BIGINT = NULL,
	@OutbreakCaseStatusTypeID BIGINT = NULL,
	@OutbreakCaseQuestionnaireObservationID BIGINT = NULL,
	@PrimaryCaseIndicator BIT = 0
)
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @ReturnCode INT = 0;
		DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

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
        DECLARE @NotificationsTemp TABLE
        (
            NotificationID BIGINT NOT NULL,
            NotificationTypeID BIGINT NULL,
            UserID BIGINT NULL,
            NotificationObjectID BIGINT NULL,
            NotificationObjectTypeID BIGINT NULL,
            TargetUserID BIGINT NULL,
            TargetSiteID BIGINT NULL,
            TargetSiteTypeID BIGINT NULL,
            SiteID BIGINT NULL,
            Payload NVARCHAR(MAX) NULL,
            LoginSite NVARCHAR(20) NULL
        );

		--Data Audit--
		declare @idfsDataAuditEventType bigint = NULL;
		declare @idfsObjectType bigint = 10017086;                         -- Veterinary Disease Report deduplication
		declare @idfObject bigint = @SurvivorVeterinaryDiseaseReportID;
		declare @idfDataAuditEvent bigint= NULL;
		declare @idfObjectTable_tlbVetCase bigint = 75800000000;
		declare @idfObjectTable_tlbMaterial bigint = 75620000000;
		declare @idfObjectTable_tlbTesting bigint = 75740000000;
		declare @idfObjectTable_tlbTestValidation bigint = 75750000000;
		declare @idfObjectTable_tlbVetCaseLog bigint = 75810000000;
		declare @idfObjectTable_tlbPensideTest bigint = 75680000000;
		declare @idfObjectTable_tlbVaccination bigint = 75790000000;

		--Data Audit--

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

        INSERT INTO @NotificationsTemp
        SELECT *
        FROM
            OPENJSON(@Notifications)
            WITH
            (
                NotificationID BIGINT,
                NotificationTypeID BIGINT,
                UserID BIGINT,
                NotificationObjectID BIGINT,
                NotificationObjectTypeID BIGINT,
                TargetUserID BIGINT,
                TargetSiteID BIGINT,
                TargetSiteTypeID BIGINT,
                SiteID BIGINT,
                Payload NVARCHAR(MAX),
                LoginSite BIGINT
            );

        -- Data audit

		--  tauDataAuditEvent  Event Type- Edit 
		set @idfsDataAuditEventType =10016003;
		-- insert record into tauDataAuditEvent - 
		EXEC USSP_GBL_DataAuditEvent_GET @UserID, @SiteID, @idfsDataAuditEventType,@idfsObjectType,@SurvivorVeterinaryDiseaseReportID, @idfObjectTable_tlbVetCase, @idfDataAuditEvent OUTPUT

		DECLARE @SampleID BIGINT = NULL,
				@VeterinaryDiseaseReportID BIGINT = NULL,
				@TestID BIGINT = NULL,
				@TestValidationID BIGINT = NULL,
				@VetCaseLogID BIGINT = NULL,
				@PensideTestID BIGINT = NULL,
				@VaccinationID BIGINT = NULL
        -- End data audit

----------------------------------------------------------------------------------------------------------------
-- SET the Survivor Disease Report
		EXEC dbo.USP_VET_DISEASE_REPORT_SET 
			@DiseaseReportID = @SurvivorVeterinaryDiseaseReportID,
		    @EIDSSReportID = @EIDSSReportID,
		    @FarmID = @FarmID,
		    @FarmMasterID = @FarmMasterID,
		    @FarmOwnerID = @FarmOwnerID,
		    @MonitoringSessionID = @MonitoringSessionID,
		    @OutbreakID = @OutbreakID,
		    @RelatedToDiseaseReportID = @RelatedToDiseaseReportID,
		    @EIDSSFieldAccessionID = @EIDSSFieldAccessionID,
		    @DiseaseID = @DiseaseID,
		    @EnteredByPersonID = @EnteredByPersonID,
		    @ReportedByOrganizationID = @ReportedByOrganizationID,
		    @ReportedByPersonID = @ReportedByPersonID,
		    @InvestigatedByOrganizationID = @InvestigatedByOrganizationID,
		    @InvestigatedByPersonID = @InvestigatedByPersonID,
		    @ReceivedByOrganizationID = @ReceivedByOrganizationID,
		    @ReceivedByPersonID = @ReceivedByPersonID,
		    @SiteID = @SiteID,
		    @DiagnosisDate = @DiagnosisDate,
		    @EnteredDate = @EnteredDate,
		    @ReportDate = @ReportDate,
		    @AssignedDate = @AssignedDate,
		    @InvestigationDate = @InvestigationDate,
		    @RowStatus = @RowStatus,
		    @ReportTypeID = @ReportTypeID,
		    @ClassificationTypeID = @ClassificationTypeID,
		    @StatusTypeID = @StatusTypeID,
		    @ReportCategoryTypeID = @ReportCategoryTypeID,
		    @FarmTotalAnimalQuantity = @FarmTotalAnimalQuantity,
		    @FarmSickAnimalQuantity = @FarmSickAnimalQuantity,
		    @FarmDeadAnimalQuantity = @FarmDeadAnimalQuantity,
		    @FarmLatitude = @FarmLatitude,
		    @FarmLongitude = @FarmLongitude,
		    @FarmEpidemiologicalObservationID = @FarmEpidemiologicalObservationID,
		    @ControlMeasuresObservationID = @ControlMeasuresObservationID,
		    @TestsConductedIndicator = @TestsConductedIndicator,
			@DataAuditEventID = @idfDataAuditEvent,
		    @AuditUserName = @AuditUserName,
		    @FlocksOrHerds = @FlocksOrHerds,
		    @Species = @Species,
		    @Animals = @Animals,
		    @Vaccinations = @Vaccinations,
		    @Samples = @Samples,
		    @PensideTests = @PensideTests,
		    @LaboratoryTests = @LaboratoryTests,
		    @LaboratoryTestInterpretations = @LaboratoryTestInterpretations,
		    @CaseLogs = @CaseLogs,
		    @ClinicalInformation = @ClinicalInformation,
		    @Contacts = @Contacts,
		    @CaseMonitorings = @CaseMonitorings,
		    @Events = @Notifications,
		    @UserID = @UserID,
		    @LinkLocalOrFieldSampleIDToReportID = @LinkLocalOrFieldSampleIDToReportID,
		    @OutbreakCaseIndicator = @OutbreakCaseIndicator,
		    @OutbreakCaseReportUID = @OutbreakCaseReportUID,
		    @OutbreakCaseStatusTypeID = @OutbreakCaseStatusTypeID,
		    @OutbreakCaseQuestionnaireObservationID = @OutbreakCaseQuestionnaireObservationID,
		    @PrimaryCaseIndicator = @PrimaryCaseIndicator

----------------------------------------------------------------------------------------------------------------
-- delete the Superseded disease report
		EXEC dbo.USP_VET_DISEASE_REPORT_DEL
			@DiseaseReportID = @SupersededVeterinaryDiseaseReportID,
			@DeduplicationIndicator = 1, -- deduplication
			@DataAuditEventID = @idfDataAuditEvent,
			@AuditUserName = @AuditUserName

	
----------------------------------------------------------------------------------------------------------------
-- Superseded disease report samples that go with survivor disease report
        -- data audit
		DECLARE @SampleIDsTemp TABLE
        (
            SampleID BIGINT NOT NULL
        );
        INSERT INTO @SampleIDsTemp
        SELECT idfMaterial
        FROM dbo.tlbMaterial
		WHERE idfVetCase = @SupersededVeterinaryDiseaseReportID
		AND idfMaterial IN (SELECT SampleID FROM @SamplesTemp)
        -- End data audit

		UPDATE dbo.tlbMaterial
		SET idfVetCase = @SurvivorVeterinaryDiseaseReportID
		WHERE idfVetCase = @SupersededVeterinaryDiseaseReportID
		AND idfMaterial IN (SELECT SampleID FROM @SamplesTemp)

        -- data audit
        WHILE EXISTS (SELECT * FROM @SampleIDsTemp)
        BEGIN

            SELECT TOP 1
                @SampleID = SampleID
            FROM @SampleIDsTemp;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tlbMaterial, 12665580000000,
					@SampleID,null,
					@SupersededVeterinaryDiseaseReportID,@SurvivorVeterinaryDiseaseReportID

            END

            DELETE FROM @SampleIDsTemp
            WHERE SampleID = @SampleID;
        END

        -- End data audit

----------------------------------------------------------------------------------------------------------------
-- remove tests associated with samples that aren't associated with survivor disease report
		UPDATE dbo.tlbTesting
		SET intRowStatus = 1
		WHERE idfMaterial IN (SELECT 
								idfMaterial 
							  FROM dbo.tlbMaterial 
							  WHERE (idfVetCase = @SurvivorVeterinaryDiseaseReportID OR idfVetCase = @SupersededVeterinaryDiseaseReportID) 
							  AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp))

        -- End data audit
		DECLARE @TestToRemoveSampleIDsTemp TABLE
        (
            SampleID BIGINT NOT NULL,
            TestID BIGINT NOT NULL
        );
        INSERT INTO @TestToRemoveSampleIDsTemp
        SELECT idfMaterial, idfTesting 
	    FROM dbo.tlbTesting
		WHERE idfMaterial IN (SELECT 
								idfMaterial 
							  FROM dbo.tlbMaterial 
							  WHERE (idfVetCase = @SurvivorVeterinaryDiseaseReportID OR idfVetCase = @SupersededVeterinaryDiseaseReportID) 
							  AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp))

        WHILE EXISTS (SELECT * FROM @TestToRemoveSampleIDsTemp)
        BEGIN
            SELECT TOP 1
                @SampleID = SampleID,
                @TestID = TestID
            FROM @TestToRemoveSampleIDsTemp;
            BEGIN
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbTesting, @TestID
            END

            DELETE FROM @TestToRemoveSampleIDsTemp
            WHERE TestID = @TestID;
        END
        -- End data audit

----------------------------------------------------------------------------------------------------------------
-- remove test interpretations associated with samples that aren't associated with survivor disease report
		UPDATE dbo.tlbTestValidation
		SET intRowStatus = 1
		WHERE idfTesting IN (SELECT 
								idfTesting 
							 FROM dbo.tlbTesting 
							 WHERE idfMaterial IN
							 (SELECT idfMaterial
							  FROM dbo.tlbMaterial 
							  WHERE (idfVetCase = @SurvivorVeterinaryDiseaseReportID OR idfVetCase = @SupersededVeterinaryDiseaseReportID) 
							  AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp)))

        -- End data audit

		DECLARE @TestValidationIDsTemp TABLE
        (
            TestValidationID BIGINT NOT NULL,
            TestID BIGINT NOT NULL
        );
        INSERT INTO @TestValidationIDsTemp
        SELECT idfTestValidation, idfTesting 
	    FROM dbo.tlbTestValidation
		WHERE idfTesting IN (SELECT 
									idfTesting 
							 FROM dbo.tlbTesting 
							 WHERE idfMaterial IN
							 (SELECT idfMaterial
							  FROM dbo.tlbMaterial 
							  WHERE (idfVetCase = @SurvivorVeterinaryDiseaseReportID OR idfVetCase = @SupersededVeterinaryDiseaseReportID) 
							  AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp)))

        WHILE EXISTS (SELECT * FROM @TestValidationIDsTemp)
        BEGIN
            SELECT TOP 1
                @TestValidationID = TestValidationID,
                @TestID = TestID
            FROM @TestValidationIDsTemp;
            BEGIN
				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbTestValidation, @TestValidationID
            END

            DELETE FROM @TestValidationIDsTemp
            WHERE TestValidationID = @TestValidationID;
        END
        -- End data audit
----------------------------------------------------------------------------------------------------------------
-- remove case Logs not associated with survivor disease report
		UPDATE dbo.tlbVetCaseLog
		SET intRowStatus = 1
		WHERE idfVetCase = @SupersededVeterinaryDiseaseReportID

        -- End data audit

		DECLARE @VetCaseLogIDsTemp TABLE
        (
            VetCaseLogID BIGINT NOT NULL,
            VeterinaryDiseaseReportID BIGINT NOT NULL
        );
        INSERT INTO @VetCaseLogIDsTemp
        SELECT idfVetCaseLog, idfVetCase
	    FROM dbo.tlbVetCaseLog
	    WHERE idfVetCase = @SupersededVeterinaryDiseaseReportID

        WHILE EXISTS (SELECT * FROM @VetCaseLogIDsTemp)
        BEGIN
            SELECT TOP 1
                @VetCaseLogID = VetCaseLogID,
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID
            FROM @VetCaseLogIDsTemp;
            BEGIN
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbVetCaseLog, @VetCaseLogID

            END

            DELETE FROM @VetCaseLogIDsTemp
            WHERE VetCaseLogID = @VetCaseLogID;
        END
        -- End data audit

----------------------------------------------------------------------------------------------------------------
-- remove penside tests associated with samples that aren't associated with survivor disease report
		UPDATE dbo.tlbPensideTest
		SET intRowStatus = 1
		WHERE idfMaterial IN (SELECT 
								idfMaterial 
							  FROM dbo.tlbMaterial 
							  WHERE (idfVetCase = @SurvivorVeterinaryDiseaseReportID OR idfVetCase = @SupersededVeterinaryDiseaseReportID) 
							  AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp))

        -- End data audit

		DECLARE @PensideTestIDsTemp TABLE
        (
            PensideTestID BIGINT NOT NULL,
            SampleID BIGINT NOT NULL
        );
        INSERT INTO @PensideTestIDsTemp
        SELECT idfPensideTest, idfMaterial
	    FROM dbo.tlbPensideTest
		WHERE idfMaterial IN (SELECT 
								idfMaterial 
							  FROM dbo.tlbMaterial 
							  WHERE (idfVetCase = @SurvivorVeterinaryDiseaseReportID OR idfVetCase = @SupersededVeterinaryDiseaseReportID) 
							  AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp))

        WHILE EXISTS (SELECT * FROM @PensideTestIDsTemp)
        BEGIN
            SELECT TOP 1
                @PensideTestID = PensideTestID,
                @SampleID = SampleID
            FROM @PensideTestIDsTemp;
            BEGIN
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_tlbPensideTest, @PensideTestID
			-- End data audit

            END

            DELETE FROM @PensideTestIDsTemp
            WHERE PensideTestID = @PensideTestID;
        END
        -- End data audit

-- disease report samples that are no longer needed
        -- data audit
		DECLARE @NotNeededSampleIDsTemp TABLE
        (
            SampleID BIGINT NOT NULL,
            VeterinaryDiseaseReportID BIGINT NULL
        );
        INSERT INTO @NotNeededSampleIDsTemp
        SELECT idfMaterial, idfVetCase
        FROM dbo.tlbMaterial
		WHERE (idfVetCase = @SupersededVeterinaryDiseaseReportID OR idfVetCase = @SurvivorVeterinaryDiseaseReportID)
		AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp)	
        -- End data audit

		UPDATE dbo.tlbMaterial
		SET idfVetCase = NULL
		WHERE (idfVetCase = @SupersededVeterinaryDiseaseReportID OR idfVetCase = @SurvivorVeterinaryDiseaseReportID)
		AND idfMaterial NOT IN (SELECT SampleID FROM @SamplesTemp)		

        -- data audit
        WHILE EXISTS (SELECT * FROM @NotNeededSampleIDsTemp)
        BEGIN
            SELECT TOP 1
                @SampleID = SampleID,
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID
            FROM @NotNeededSampleIDsTemp;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tlbMaterial, 12665580000000,
					@SampleID,null,
					@VeterinaryDiseaseReportID,NULL
            END

            DELETE FROM @NotNeededSampleIDsTemp
            WHERE SampleID = @SampleID;
        END

        -- End data audit

----------------------------------------------------------------------------------------------------------------
-- Superseded disease report vaccinations that go with survivor disease report
        -- data audit
		DECLARE @VaccinationIDsTemp TABLE
        (
            VaccinationID BIGINT NOT NULL,
            VeterinaryDiseaseReportID BIGINT NULL
        );
        INSERT INTO @VaccinationIDsTemp
        SELECT idfVaccination, idfVetCase
        FROM dbo.tlbVaccination 
        WHERE idfVetCase = @SupersededVeterinaryDiseaseReportID
			AND idfVaccination IN (SELECT VaccinationID FROM @VaccinationsTemp)
        -- End data audit

		UPDATE dbo.tlbVaccination
		SET idfVetCase = @SurvivorVeterinaryDiseaseReportID
		WHERE idfVetCase = @SupersededVeterinaryDiseaseReportID
		AND idfVaccination IN (SELECT VaccinationID FROM @VaccinationsTemp)

        -- data audit
        WHILE EXISTS (SELECT * FROM @VaccinationIDsTemp)
        BEGIN
            SELECT TOP 1
                @VaccinationID = VaccinationID,
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID
            FROM @VaccinationIDsTemp ;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tlbVaccination, 4577960000000,
					@VaccinationID,null,
					@VeterinaryDiseaseReportID,@SurvivorVeterinaryDiseaseReportID
            END

            DELETE FROM @VaccinationIDsTemp
            WHERE VaccinationID = @VaccinationID;
        END

        -- End data audit

-- disease report vaccinations that are no longer needed
        -- data audit
		DECLARE @NotNeededVaccinationIDsTemp TABLE
        (
            VaccinationID BIGINT NOT NULL,
            VeterinaryDiseaseReportID BIGINT NULL
        );
        INSERT INTO @NotNeededVaccinationIDsTemp
        SELECT idfVaccination, idfVetCase
        FROM dbo.tlbVaccination 
        WHERE (idfVetCase = @SupersededVeterinaryDiseaseReportID OR idfVetCase = @SurvivorVeterinaryDiseaseReportID)
		AND idfVaccination NOT IN (SELECT VaccinationID FROM @VaccinationsTemp)		
        -- End data audit

		UPDATE dbo.tlbVaccination
		SET idfVetCase = NULL
		WHERE (idfVetCase = @SupersededVeterinaryDiseaseReportID OR idfVetCase = @SurvivorVeterinaryDiseaseReportID)
		AND idfVaccination NOT IN (SELECT VaccinationID FROM @VaccinationsTemp)		

        -- data audit
        WHILE EXISTS (SELECT * FROM @NotNeededVaccinationIDsTemp)
        BEGIN
            SELECT TOP 1
                @VaccinationID = VaccinationID,
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID
            FROM @NotNeededVaccinationIDsTemp;
            BEGIN
				insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
				select @idfDataAuditEvent,@idfObjectTable_tlbVaccination, 4577960000000,
					@VaccinationID,null,
					@VeterinaryDiseaseReportID,NULL

            END

            DELETE FROM @NotNeededVaccinationIDsTemp
            WHERE VaccinationID = @VaccinationID;
        END

        -- End data audit
		 			 		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END
