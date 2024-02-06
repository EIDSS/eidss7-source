-- ================================================================================================
-- Name: USP_LAB_SET
--
-- Description:	Inserts or updates samples, tests, test amendments, test interpretations, 
-- transfers, batches and approvals for the laboratory module use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     07/19/2018 Initial release.
-- Stephen Long		10/31/2018 Added the test amendments and transfers - LUC03 and LUC07.
-- Stephen Long		01/24/2019 Added box place availabilities parameter and updates.
-- Stephen Long     02/06/2019 Removed UserPreferenceID parameter; retrieved in the stored 
--                             procedure.  Replace temporary sample ID with the database ID 
--                             on new sample record that was also marked as a favorite. 
-- Stephen Long     02/09/2019 Corrected the JSON table name for EIDSSFieldSampleID to EIDSSLocal 
--                             FieldSampleID.
-- Stephen Long     02/19/2019 Modified for removed parameters from USSP_GBL_BATCH_TEST_SET and 
--                             added parameter to USSP_LAB_TRANSFER_SET.  Removed test 
--                             interpretation parameter.
-- Stephen Long     03/10/2019 Changed temp table field names for test amendement to sync up with 
--                             the API parameter names (LUC07).
-- Stephen Long     03/20/2019 Added row action on the batch test select from JSON variable. 
--                             Added check on Favorites parameter to only process if not null.
-- Stephen Long     04/17/2019 Update to use human master ID when registering new samples, and 
--                             copy over to human (similiar to how human disease report works).
-- Stephen Long     07/09/2019 Added human master ID parameter for call to sample set.
-- Stephen Long     08/29/2019 Corrected root sample ID on call to USSP_LAB_SAMPLE_SET.
-- Stephen Long     03/30/2020 Added audit user name parameter.
-- Stephen Long     04/20/2020 Changes for LUC10 vector type and species type ID's additions.
-- Stephen Long     10/28/2020 Changed row action from nchar to char.
-- Stephen Long     09/24/2021 Removed language parameter as it is not needed.
-- Stephen Long     01/03/2022 Changed login site to NVARCHAR(20).
-- Stephen Long     01/07/2022 Added copy of human actual to human stored procedure call.
-- Stephen Long     01/25/2022 Added logic to add farm, herd and species for samples having no
--                             disease report or monitoring session association.
-- Stephen Long     03/10/2022 Changed note to comment on samples table variable.
-- Stephen Long     03/25/2022 Updated suppress select table variables for adding of vet samples.
-- Stephen Long     03/29/2022 Fix on suppress select of species.
-- Stephen Long     03/30/2022 Fix on suppress select of human copy.
-- Stephen Long     04/20/2022 Changed observation ID on batch test table variable to nullable.
-- Stephen Long     05/18/2022 Added notification processing on new transfer records.
-- Stephen Long     05/24/2022 Fix to check vector ID less than zero and not -1.
-- Stephen Long     07/06/2022 Updates for site alerts to call new stored procedure.
-- Stephen Long     10/10/2022 Added monitoring session ID check when farm or human master ID is 
--                             not null for registering new samples.
-- Stephen Long     10/11/2022 Added insert to tlbMonitoringSessionToMaterial to pick up the 
--                             correct disease on an active surveillance session.
-- Stephen Long     10/18/2022 Fix to account for human active surveillance session diseases and 
--                             transferred samples for an active surveillance session.
-- Leo Tracchia		10/21/2022 Fix for properly deleting tests for human disease report DevOps 
--                             defect 5006.
-- Stephen Long     10/21/2022 Added veterinary disease report, monitoring session and vector 
--                             identifiers to the USSP_LAB_TEST_SET call.
-- Stephen Long     12/14/2022 Added null data audit event to call of herd and species set.
-- Stephen Long     12/17/2022 Fix to call of USSP_VET_SPECIES_SET for outbreak status type; 
--                             passing null.
-- Stephen Long     01/03/2023 Fix to call of USSP_AS_SAMPLE_TO_DISEASE_SET for data audit logic; 
--                             passing null.
-- Stephen Long     02/20/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SET]
(
    @Samples NVARCHAR(MAX) = NULL,
    @BatchTests NVARCHAR(MAX) = NULL,
    @Tests NVARCHAR(MAX) = NULL,
    @TestAmendments NVARCHAR(MAX) = NULL,
    @Transfers NVARCHAR(MAX) = NULL,
    @FreezerBoxLocationAvailabilities NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @UserID BIGINT,
    @Favorites XML = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @KeyId BIGINT = 0,
                                                               -- Data audit
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectTypeRepositorySchemeID BIGINT = 10017044,       -- Repository Scheme
        @ObjectTableFreezerSubdivisionID BIGINT = 75570000000; -- tlbFreezerSubdivision
-- End data audit
DECLARE @SuppressSelect TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX),
    ID BIGINT NULL
);
DECLARE @SuppressSelect2 TABLE
(
    ReturnCode INT,
    ReturnMessage NVARCHAR(MAX)
);
DECLARE @RowID BIGINT,
        @RowStatus INT,
        @RowAction INT,
        @SampleID BIGINT,
        @SampleTypeID BIGINT,
        @RootSampleID BIGINT = NULL,
        @ParentSampleID BIGINT = NULL,
        @HumanMasterID BIGINT = NULL,
        @HumanID BIGINT = NULL,
        @FarmMasterID BIGINT = NULL,
        @FarmID BIGINT = NULL,
        @SpeciesID BIGINT = NULL,
        @AnimalID BIGINT = NULL,
        @VectorID BIGINT = NULL,
        @MonitoringSessionID BIGINT = NULL,
        @VectorSessionID BIGINT = NULL,
        @HumanDiseaseReportID BIGINT = NULL,
        @VeterinaryDiseaseReportID BIGINT = NULL,
        @FunctionalAreaID BIGINT = NULL,
        @FreezerSubdivisionID BIGINT = NULL,
        @StorageBoxPlace NVARCHAR(200) = NULL,
        @CollectionDate DATETIME2 = NULL,
        @CollectedByPersonID BIGINT = NULL,
        @CollectedByOrganizationID BIGINT = NULL,
        @SentDate DATETIME2 = NULL,
        @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
        @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
        @EnteredDate DATETIME2 = NULL,
        @OutOfRepositoryDate DATETIME2 = NULL,
        @MarkedForDispositionByPersonID BIGINT = NULL,
        @SentToOrganizationID BIGINT = NULL,
        @SiteID BIGINT = NULL,
        @CurrentSiteID BIGINT = NULL,
        @SampleKindTypeID BIGINT = NULL,
        @ReadOnlyIndicator BIT = NULL,
        @AccessionDate DATETIME2 = NULL,
        @AccessionConditionTypeID BIGINT = NULL,
        @AccessionByPersonID BIGINT = NULL,
        @SampleStatusTypeID BIGINT = NULL,
        @PreviousSampleStatusTypeID BIGINT = NULL,
        @AccessionComment NVARCHAR(200) = NULL,
        @DestructionMethodTypeID BIGINT = NULL,
        @DestructionDate DATETIME2 = NULL,
        @DestroyedByPersonID BIGINT = NULL,
        @Note NVARCHAR(500) = NULL,
        @Comment NVARCHAR(500) = NULL,
        @BatchTestID BIGINT,
        @TestNameTypeID BIGINT = NULL,
        @BatchStatusTypeID BIGINT = NULL,
        @PerformedByOrganizationID BIGINT = NULL,
        @PerformedByPersonID BIGINT = NULL,
        @ValidatedByOrganizationID BIGINT = NULL,
        @ValidatedByPersonID BIGINT = NULL,
        @ObservationID BIGINT = NULL,
        @PerformedDate DATETIME2 = NULL,
        @ValidationDate DATETIME2 = NULL,
        @EIDSSBatchTestID NVARCHAR(200) = NULL,
        @ResultEnteredByPersonID BIGINT = NULL,
        @ResultEnteredByOrganizationID BIGINT = NULL,
        @TestRequested NVARCHAR(200) = NULL,
        @TestID BIGINT,
        @TestCategoryTypeID BIGINT = NULL,
        @TestResultTypeID BIGINT = NULL,
        @TestStatusTypeID BIGINT,
        @PreviousTestStatusTypeID BIGINT = NULL,
        @TestNumber INT = NULL,
        @StartedDate DATETIME2 = NULL,
        @ConcludedDate DATETIME2 = NULL,
        @TestedByPersonID BIGINT = NULL,
        @TestedByOrganizationID BIGINT = NULL,
        @NonLaboratoryTestIndicator BIT,
        @ExternalTestIndicator BIT = NULL,
        @ReceivedDate DATETIME2 = NULL,
        @ContactPersonName NVARCHAR(200) = NULL,
        @DiseaseID BIGINT = NULL,
        @FavoriteIndicator INT = NULL,
        @TestAmendmentID BIGINT,
        @AmendedByOrganizationID BIGINT = NULL,
        @AmendedByPersonID BIGINT = NULL,
        @AmendmentDate DATETIME2 = NULL,
        @OldTestResultTypeID BIGINT = NULL,
        @ChangedTestResultTypeID BIGINT = NULL,
        @OldNote NVARCHAR(500) = NULL,
        @ChangedNote NVARCHAR(500) = NULL,
        @ReasonForAmendment NVARCHAR(500),
        @TransferID BIGINT,
        @EIDSSTransferID NVARCHAR(200) = NULL,
        @TransferStatusTypeID BIGINT = NULL,
        @TransferredFromOrganizationID BIGINT = NULL,
        @TransferredToOrganizationID BIGINT = NULL,
        @SentByPersonID BIGINT = NULL,
        @TransferDate DATETIME2 = NULL,
        @BoxPlaceAvailability NVARCHAR(MAX),
        @EventId BIGINT,
        @EventTypeId BIGINT = NULL,
        @EventSiteId BIGINT = NULL,
        @EventObjectId BIGINT = NULL,
        @EventUserId BIGINT = NULL,
        @EventDiseaseId BIGINT = NULL,
        @EventLocationId BIGINT = NULL,
        @EventInformationString NVARCHAR(MAX) = NULL,
        @EventLoginSiteId BIGINT = NULL,
        @NewHumanID BIGINT = NULL,
        @VectorTypeID BIGINT = NULL,
        @SpeciesTypeID BIGINT = NULL,
        @EIDSSVectorID NVARCHAR(50) = NULL,
        @EIDSSFreezerSubdivisionID NVARCHAR(200) = NULL,
        @FavoritesString VARCHAR(MAX);
DECLARE @SamplesTemp TABLE
(
    SampleID BIGINT NOT NULL,
    SampleTypeID BIGINT NOT NULL,
    RootSampleID BIGINT NULL,
    ParentSampleID BIGINT NULL,
    HumanMasterID BIGINT NULL,
    HumanID BIGINT NULL,
    FarmMasterID BIGINT NULL,
    FarmID BIGINT NULL,
    SpeciesID BIGINT NULL,
    AnimalID BIGINT NULL,
    MonitoringSessionID BIGINT NULL,
    CollectedByPersonID BIGINT NULL,
    CollectedByOrganizationID BIGINT NULL,
    MainTestID BIGINT NULL,
    CollectionDate DATETIME2 NULL,
    SentDate DATETIME2 NULL,
    EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL,
    VectorSessionID BIGINT NULL,
    VectorID BIGINT NULL,
    FreezerSubdivisionID BIGINT NULL,
    StorageBoxPlace NVARCHAR(200) NULL,
    SampleStatusTypeID BIGINT NULL,
    PreviousSampleStatusTypeID BIGINT NULL,
    FunctionalAreaID BIGINT NULL,
    DestroyedByPersonID BIGINT NULL,
    EnteredDate DATETIME2 NULL,
    DestructionDate DATETIME2 NULL,
    EIDSSLaboratorySampleID NVARCHAR(200) NULL,
    Comment NVARCHAR(500) NULL,
    SiteID BIGINT NULL,
    RowStatus INT NOT NULL,
    SentToOrganizationID BIGINT NULL,
    ReadOnlyIndicator BIT NOT NULL,
    BirdStatusTypeID BIGINT NULL,
    HumanDiseaseReportID BIGINT NULL,
    VeterinaryDiseaseReportID BIGINT NULL,
    AccessionDate DATETIME2 NULL,
    AccessionConditionTypeID BIGINT NULL,
    AccessionComment NVARCHAR(200) NULL,
    AccessionByPersonID BIGINT NULL,
    DestructionMethodTypeID BIGINT NULL,
    CurrentSiteID BIGINT NULL,
    SampleKindTypeID BIGINT NULL,
    MarkedForDispositionByPersonID BIGINT NULL,
    OutOfRepositoryDate DATETIME2 NULL,
    DiseaseID BIGINT NULL,
    VectorTypeID BIGINT NULL,
    SpeciesTypeID BIGINT NULL,
    FavoriteIndicator BIT NOT NULL,
    RowAction INT NULL
);
DECLARE @BatchTestsTemp TABLE
(
    BatchTestID BIGINT NOT NULL,
    TestNameTypeID BIGINT NULL,
    BatchStatusTypeID BIGINT NULL,
    PerformedByOrganizationID BIGINT NULL,
    PerformedByPersonID BIGINT NULL,
    ValidatedByOrganizationID BIGINT NULL,
    ValidatedByPersonID BIGINT NULL,
    ObservationID BIGINT NULL,
    SiteID BIGINT NOT NULL,
    PerformedDate DATETIME2 NULL,
    ValidationDate DATETIME2 NULL,
    EIDSSBatchTestID NVARCHAR(200) NULL,
    RowStatus INT NOT NULL,
    ResultEnteredByPersonID BIGINT NULL,
    ResultEnteredByOrganizationID BIGINT NULL,
    RowAction INT NULL
);
DECLARE @TestsTemp TABLE
(
    TestID BIGINT NOT NULL,
    TestNameTypeID BIGINT NULL,
    TestCategoryTypeID BIGINT NULL,
    TestResultTypeID BIGINT NULL,
    TestStatusTypeID BIGINT NOT NULL,
    PreviousTestStatusTypeID BIGINT NULL,
    DiseaseID BIGINT NOT NULL,
    SampleID BIGINT NULL,
    EIDSSLaboratorySampleID NVARCHAR(200) NOT NULL,
    BatchTestID BIGINT NULL,
    ObservationID BIGINT NULL,
    TestNumber INT NULL,
    Note NVARCHAR(500) NULL,
    RowStatus INT NOT NULL,
    StartedDate DATETIME2 NULL,
    ConcludedDate DATETIME2 NULL,
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
    HumanDiseaseReportID BIGINT NULL,
    VeterinaryDiseaseReportID BIGINT NULL,
    MonitoringSessionID BIGINT NULL,
    VectorID BIGINT NULL,
    RowAction INT NULL
);
DECLARE @TestAmendmentsTemp TABLE
(
    TestAmendmentID BIGINT NOT NULL,
    TestID BIGINT NOT NULL,
    AmendedByOrganizationID BIGINT NULL,
    AmendedByPersonID BIGINT NULL,
    AmendmentDate DATETIME2 NULL,
    OldTestResultTypeID BIGINT NULL,
    ChangedTestResultTypeID BIGINT NULL,
    OldNote NVARCHAR(500) NULL,
    ChangedNote NVARCHAR(500) NULL,
    ReasonForAmendment NVARCHAR(500) NOT NULL,
    RowStatus INT NOT NULL,
    RowAction INT NULL,
    EIDSSLaboratorySampleID NVARCHAR(200) NOT NULL,
    DataAuditEventID BIGINT NULL
);
DECLARE @TransfersTemp TABLE
(
    TransferID BIGINT NOT NULL,
    SampleID BIGINT NOT NULL,
    EIDSSTransferID NVARCHAR(200) NULL,
    TransferStatusTypeID BIGINT NULL,
    TransferredFromOrganizationID BIGINT NULL,
    TransferredToOrganizationID BIGINT NULL,
    SentByPersonID BIGINT NULL,
    TransferDate DATETIME2 NULL,
    PurposeOfTransfer NVARCHAR(200) NULL,
    SiteID BIGINT NOT NULL,
    TestRequested NVARCHAR(200) NULL,
    RowStatus INT NOT NULL,
    RowAction INT NULL
);
DECLARE @FreezerBoxLocationAvailabilitiesTemp TABLE
(
    FreezerSubdivisionID BIGINT NOT NULL,
    BoxPlaceAvailability NVARCHAR(MAX) NOT NULL,
    EIDSSFreezerSubdivisionID NVARCHAR(200) NULL
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
DECLARE @FreezerSubdivisionBeforeEdit TABLE
(
    FreezerSubdivisionID BIGINT,
    BoxPlaceAvailability NVARCHAR(4000)
);
DECLARE @FreezerSubdivisionAfterEdit TABLE
(
    FreezerSubdivisionID BIGINT,
    BoxPlaceAvailability NVARCHAR(4000)
);
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

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
                HumanMasterID BIGINT,
                HumanID BIGINT,
                FarmMasterID BIGINT,
                FarmID BIGINT,
                SpeciesID BIGINT,
                AnimalID BIGINT,
                MonitoringSessionID BIGINT,
                CollectedByPersonID BIGINT,
                CollectedByOrganizationID BIGINT,
                MainTestID BIGINT,
                CollectionDate DATETIME2,
                SentDate DATETIME2,
                EIDSSLocalOrFieldSampleID NVARCHAR(200),
                VectorSessionID BIGINT,
                VectorID BIGINT,
                FreezerSubdivisionID BIGINT,
                StorageBoxPlace NVARCHAR(200),
                SampleStatusTypeID BIGINT,
                PreviousSampleStatusTypeID BIGINT,
                FunctionalAreaID BIGINT,
                DestroyedByPersonID BIGINT,
                EnteredDate DATETIME2,
                DestructionDate DATETIME2,
                EIDSSLaboratorySampleID NVARCHAR(200),
                Comment NVARCHAR(500),
                SiteID BIGINT,
                RowStatus INT,
                SentToOrganizationID BIGINT,
                ReadOnlyIndicator BIT,
                BirdStatusTypeID BIGINT,
                HumanDiseaseReportID BIGINT,
                VeterinaryDiseaseReportID BIGINT,
                AccessionDate DATETIME2,
                AccessionConditionTypeID BIGINT,
                AccessionComment NVARCHAR(200),
                AccessionByPersonID BIGINT,
                DestructionMethodTypeID BIGINT,
                CurrentSiteID BIGINT,
                SampleKindTypeID BIGINT,
                MarkedForDispositionByPersonID BIGINT,
                OutOfRepositoryDate DATETIME2,
                DiseaseID BIGINT,
                VectorTypeID BIGINT,
                SpeciesTypeID BIGINT,
                FavoriteIndicator BIT,
                RowAction INT
            );

        INSERT INTO @BatchTestsTemp
        SELECT *
        FROM
            OPENJSON(@BatchTests)
            WITH
            (
                BatchTestID BIGINT,
                TestNameTypeID BIGINT,
                BatchStatusTypeID BIGINT,
                PerformedByOrganizationID BIGINT,
                PerformedByPersonID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                ObservationID BIGINT,
                SiteID BIGINT,
                PerformedDate DATETIME2,
                ValidationDate DATETIME2,
                EIDSSBatchTestID NVARCHAR(200),
                RowStatus INT,
                ResultEnteredByPersonID BIGINT,
                ResultEnteredByOrganizationID BIGINT,
                RowAction INT
            );

        INSERT INTO @TestsTemp
        SELECT *
        FROM
            OPENJSON(@Tests)
            WITH
            (
                TestID BIGINT,
                TestNameTypeID BIGINT,
                TestCategoryTypeID BIGINT,
                TestResultTypeID BIGINT,
                TestStatusTypeID BIGINT,
                PreviousTestStatusTypeID BIGINT,
                DiseaseID BIGINT,
                SampleID BIGINT,
                EIDSSLaboratorySampleID NVARCHAR(200),
                BatchTestID BIGINT,
                ObservationID BIGINT,
                TestNumber INT,
                Note NVARCHAR(500),
                RowStatus INT,
                StartedDate DATETIME2,
                ConcludedDate DATETIME2,
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
                HumanDiseaseReportID BIGINT,
                VeterinaryDiseaseReportID BIGINT,
                MonitoringSessionID BIGINT,
                VectorID BIGINT,
                RowAction INT
            );

        INSERT INTO @TestAmendmentsTemp
        SELECT *
        FROM
            OPENJSON(@TestAmendments)
            WITH
            (
                TestAmendmentID BIGINT,
                TestID BIGINT,
                AmendedByOrganizationID BIGINT,
                AmendedByPersonID BIGINT,
                AmendmentDate DATETIME2,
                OldTestResultTypeID BIGINT,
                ChangedTestResultTypeID BIGINT,
                OldNote NVARCHAR(500),
                ChangedNote NVARCHAR(500),
                ReasonForAmendment NVARCHAR(500),
                RowStatus INT,
                RowAction INT,
                EIDSSLaboratorySampleID NVARCHAR(200), 
                DataAuditEventID BIGINT
            );

        INSERT INTO @TransfersTemp
        SELECT *
        FROM
            OPENJSON(@Transfers)
            WITH
            (
                TransferID BIGINT,
                SampleID BIGINT,
                EIDSSTransferID NVARCHAR(200),
                TransferStatusTypeID BIGINT,
                TransferredFromOrganizationID BIGINT,
                TransferredToOrganizationID BIGINT,
                SentByPersonID BIGINT,
                TransferDate DATETIME2,
                PurposeOfTransfer NVARCHAR(200),
                SiteID BIGINT,
                TestRequested NVARCHAR(200),
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @FreezerBoxLocationAvailabilitiesTemp
        SELECT *
        FROM
            OPENJSON(@FreezerBoxLocationAvailabilities)
            WITH
            (
                FreezerSubdivisionID BIGINT,
                BoxPlaceAvailability NVARCHAR(MAX), 
                EIDSSFreezerSubdivisionID NVARCHAR(200) 
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

        SET @FavoritesString = CONVERT(NVARCHAR(MAX), @Favorites, 1);

        WHILE EXISTS (SELECT * FROM @SamplesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SampleID,
                @SampleID = SampleID,
                @SampleTypeID = SampleTypeID,
                @RootSampleID = RootSampleID,
                @ParentSampleID = ParentSampleID,
                @HumanMasterID = HumanMasterID,
                @HumanID = HumanID,
                @FarmMasterID = FarmMasterID,
                @FarmID = FarmID,
                @SpeciesID = SpeciesID,
                @AnimalID = AnimalID,
                @VectorID = VectorID,
                @MonitoringSessionID = MonitoringSessionID,
                @VectorSessionID = VectorSessionID,
                @HumanDiseaseReportID = HumanDiseaseReportID,
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID,
                @CollectionDate = CollectionDate,
                @CollectedByPersonID = CollectedByPersonID,
                @CollectedByOrganizationID = CollectedByOrganizationID,
                @SentDate = SentDate,
                @SentToOrganizationID = SentToOrganizationID,
                @EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
                @EIDSSLaboratorySampleID = EIDSSLaboratorySampleID,
                @SiteID = SiteID,
                @FunctionalAreaID = FunctionalAreaID,
                @FreezerSubdivisionID = FreezerSubdivisionID,
                @StorageBoxPlace = StorageBoxPlace,
                @EnteredDate = EnteredDate,
                @OutOfRepositoryDate = OutOfRepositoryDate,
                @DestructionDate = DestructionDate,
                @DestructionMethodTypeID = DestructionMethodTypeID,
                @DestroyedByPersonID = DestroyedByPersonID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @AccessionDate = AccessionDate,
                @AccessionConditionTypeID = AccessionConditionTypeID,
                @AccessionByPersonID = AccessionByPersonID,
                @SampleStatusTypeID = SampleStatusTypeID,
                @PreviousSampleStatusTypeID = PreviousSampleStatusTypeID,
                @AccessionComment = AccessionComment,
                @Comment = Comment,
                @CurrentSiteID = CurrentSiteID,
                @SampleKindTypeID = SampleKindTypeID,
                @MarkedForDispositionByPersonID = MarkedForDispositionByPersonID,
                @DiseaseID = DiseaseID,
                @VectorTypeID = VectorTypeID,
                @SpeciesTypeID = SpeciesTypeID,
                @FavoriteIndicator = FavoriteIndicator,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @SamplesTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_LAB_SAMPLE_SET @SampleID OUTPUT,
                                            @SampleTypeID,
                                            @RootSampleID,
                                            @ParentSampleID,
                                            @HumanMasterID,
                                            @HumanID,
                                            @FarmMasterID,
                                            @FarmID,
                                            @SpeciesID,
                                            @AnimalID,
                                            @VectorID,
                                            @VectorTypeID,
                                            @SpeciesTypeID,
                                            @EIDSSVectorID,
                                            @MonitoringSessionID,
                                            @VectorSessionID,
                                            @HumanDiseaseReportID,
                                            @VeterinaryDiseaseReportID,
                                            @CollectionDate,
                                            @CollectedByPersonID,
                                            @CollectedByOrganizationID,
                                            @SentDate,
                                            @SentToOrganizationID,
                                            @EIDSSLocalOrFieldSampleID,
                                            @EIDSSLaboratorySampleID,
                                            @SiteID,
                                            @FunctionalAreaID,
                                            @FreezerSubdivisionID,
                                            @StorageBoxPlace,
                                            @EnteredDate,
                                            @OutOfRepositoryDate,
                                            @MarkedForDispositionByPersonID,
                                            @DestructionDate,
                                            @DestructionMethodTypeID,
                                            @DestroyedByPersonID,
                                            @ReadOnlyIndicator,
                                            @AccessionDate,
                                            @AccessionConditionTypeID,
                                            @AccessionByPersonID,
                                            @SampleStatusTypeID,
                                            @PreviousSampleStatusTypeID,
                                            @AccessionComment,
                                            @Comment,
                                            @CurrentSiteID,
                                            @SampleKindTypeID,
                                            @DiseaseID,
                                            @RowStatus,
                                            @RowAction,
                                            @AuditUserName;

            UPDATE @TestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            UPDATE @TransfersTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            IF @FavoriteIndicator = 1
                SELECT @FavoritesString = REPLACE(@FavoritesString, @RowID, @SampleID);

            --POCO does not like the XML modify command; used string and replace for now.
            --SELECT @Favorites = @Favorites.modify('replace value of (/Favorites/Favorite/@SampleID[.=sql:variable("@RowID")])[1] with sql:variable("@SampleID")');
            IF @SampleID <> @RootSampleID
               AND (
                       @RowAction = 4
                       OR @RowAction = 5
                   )
            BEGIN
                DECLARE @TransferIDTemp AS BIGINT;

                SELECT @TransferIDTemp = tro.idfTransferOut
                FROM dbo.tlbTransferOutMaterial tom
                    INNER JOIN dbo.tlbTransferOUT tro
                        ON tro.idfTransferOut = tom.idfTransferOut
                WHERE tom.idfMaterial = @RootSampleID;

                UPDATE dbo.tlbTransferOUT
                SET idfsTransferStatus = 10001001,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfTransferOut = @TransferIDTemp;
            END;

            DELETE FROM @SamplesTemp
            WHERE SampleID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @BatchTestsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = BatchTestID,
                @BatchTestID = BatchTestID,
                @TestNameTypeID = TestNameTypeID,
                @BatchStatusTypeID = BatchStatusTypeID,
                @PerformedByOrganizationID = PerformedByOrganizationID,
                @PerformedByPersonID = PerformedByPersonID,
                @ValidatedByOrganizationID = ValidatedByOrganizationID,
                @ValidatedByPersonID = ValidatedByPersonID,
                @ObservationID = ObservationID,
                @SiteID = SiteID,
                @PerformedDate = PerformedDate,
                @ValidationDate = ValidationDate,
                @EIDSSBatchTestID = EIDSSBatchTestID,
                @RowStatus = RowStatus,
                @ResultEnteredByPersonID = ResultEnteredByPersonID,
                @ResultEnteredByOrganizationID = ResultEnteredByOrganizationID,
                @RowAction = RowAction
            FROM @BatchTestsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_BATCH_TEST_SET @BatchTestID OUTPUT,
                                                @TestNameTypeID,
                                                @BatchStatusTypeID,
                                                @PerformedByOrganizationID,
                                                @PerformedByPersonID,
                                                @ValidatedByOrganizationID,
                                                @ValidatedByPersonID,
                                                @ObservationID,
                                                @SiteID,
                                                @PerformedDate,
                                                @ValidationDate,
                                                @EIDSSBatchTestID,
                                                @RowStatus,
                                                @ResultEnteredByPersonID,
                                                @ResultEnteredByOrganizationID,
                                                @RowAction,
                                                @AuditUserName;

            UPDATE @TestsTemp
            SET BatchTestID = @BatchTestID
            WHERE BatchTestID = @RowID;

            DELETE FROM @BatchTestsTemp
            WHERE BatchTestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @TestsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = TestID,
                @TestID = TestID,
                @TestNameTypeID = TestNameTypeID,
                @TestCategoryTypeID = TestCategoryTypeID,
                @TestResultTypeID = TestResultTypeID,
                @TestStatusTypeID = TestStatusTypeID,
                @PreviousTestStatusTypeID = PreviousTestStatusTypeID,
                @DiseaseID = DiseaseID,
                @SampleID = SampleID,
                @EIDSSLaboratorySampleID = EIDSSLaboratorySampleID,
                @BatchTestID = BatchTestID,
                @ObservationID = ObservationID,
                @TestNumber = TestNumber,
                @Note = Note,
                @RowStatus = RowStatus,
                @StartedDate = StartedDate,
                @ConcludedDate = ConcludedDate,
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
                @HumanDiseaseReportID = HumanDiseaseReportID,
                @VeterinaryDiseaseReportID = VeterinaryDiseaseReportID,
                @MonitoringSessionID = MonitoringSessionID,
                @VectorID = VectorID,
                @RowAction = RowAction
            FROM @TestsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_LAB_TEST_SET @TestID,
                                          @TestNameTypeID,
                                          @TestCategoryTypeID,
                                          @TestResultTypeID,
                                          @TestStatusTypeID,
                                          @PreviousTestStatusTypeID,
                                          @DiseaseID,
                                          @SampleID,
                                          @EIDSSLaboratorySampleID,
                                          @BatchTestID,
                                          @ObservationID,
                                          @TestNumber,
                                          @Note,
                                          @RowStatus,
                                          @StartedDate,
                                          @ConcludedDate,
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
                                          @HumanDiseaseReportID,
                                          @VeterinaryDiseaseReportID,
                                          @MonitoringSessionID,
                                          @VectorID,
                                          @RowAction,
                                          @AuditUserName, 
                                          @DataAuditEventID OUTPUT;

            UPDATE @TestAmendmentsTemp
            SET TestID = @TestID, 
                DataAuditEventID = @DataAuditEventID
            WHERE TestID = @RowID;

            DELETE FROM @TestsTemp
            WHERE TestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @TestAmendmentsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = TestAmendmentID,
                @TestAmendmentID = TestAmendmentID,
                @TestID = TestID,
                @AmendedByOrganizationID = AmendedByOrganizationID,
                @AmendedByPersonID = AmendedByPersonID,
                @AmendmentDate = AmendmentDate,
                @OldTestResultTypeID = OldTestResultTypeID,
                @ChangedTestResultTypeID = ChangedTestResultTypeID,
                @OldNote = OldNote,
                @ChangedNote = ChangedNote,
                @ReasonForAmendment = ReasonForAmendment,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @EIDSSLaboratorySampleID = EIDSSLaboratorySampleID
            FROM @TestAmendmentsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TEST_AMENDMENT_SET @TestAmendmentID,
                                                    @TestID,
                                                    @AmendedByOrganizationID,
                                                    @AmendedByPersonID,
                                                    @AmendmentDate,
                                                    @OldTestResultTypeID,
                                                    @ChangedTestResultTypeID,
                                                    @OldNote,
                                                    @ChangedNote,
                                                    @ReasonForAmendment,
                                                    @RowStatus,
                                                    @RowAction,
                                                    @AuditUserName,
                                                    @EIDSSLaboratorySampleID, 
                                                    @DataAuditEventID;

            DELETE FROM @TestAmendmentsTemp
            WHERE TestAmendmentID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @TransfersTemp)
        BEGIN
            SELECT TOP 1
                @RowID = TransferID,
                @TransferID = TransferID,
                @SampleID = SampleID,
                @EIDSSTransferID = EIDSSTransferID,
                @TransferStatusTypeID = TransferStatusTypeID,
                @TransferredFromOrganizationID = TransferredFromOrganizationID,
                @TransferredToOrganizationID = TransferredToOrganizationID,
                @SentByPersonID = SentByPersonID,
                @TransferDate = TransferDate,
                @Note = PurposeOfTransfer,
                @SiteID = SiteID,
                @TestRequested = TestRequested,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @TransfersTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_LAB_TRANSFER_SET @TransferID,
                                              @SampleID,
                                              @EIDSSTransferID,
                                              @TransferStatusTypeID,
                                              @TransferredFromOrganizationID,
                                              @TransferredToOrganizationID,
                                              @SentByPersonID,
                                              @TransferDate,
                                              @Note,
                                              @SiteID,
                                              @TestRequested,
                                              @RowStatus,
                                              @RowAction,
                                              @AuditUserName;

            IF @RowAction = 1
            BEGIN
                UPDATE @EventsTemp
                SET ObjectId = @TransferID
                WHERE ObjectId = @RowID;
            END;

            DELETE FROM @TransfersTemp
            WHERE TransferID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @FreezerBoxLocationAvailabilitiesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FreezerSubdivisionID,
                @FreezerSubdivisionID = FreezerSubdivisionID,
                @BoxPlaceAvailability = BoxPlaceAvailability,
                @EIDSSFreezerSubdivisionID = EIDSSFreezerSubdivisionID
            FROM @FreezerBoxLocationAvailabilitiesTemp;

            -- Data audit
            INSERT INTO @FreezerSubdivisionBeforeEdit
            SELECT idfSubdivision,
                   BoxPlaceAvailability
            FROM dbo.tlbFreezerSubdivision
            WHERE idfSubdivision = @FreezerSubdivisionID;
            -- End data audit

            UPDATE dbo.tlbFreezerSubdivision
            SET BoxPlaceAvailability = @BoxPlaceAvailability,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfSubdivision = @FreezerSubdivisionID;

            -- Data audit
            INSERT INTO @FreezerSubdivisionAfterEdit
            SELECT idfSubdivision,
                   BoxPlaceAvailability
            FROM dbo.tlbFreezerSubdivision
            WHERE idfSubdivision = @FreezerSubdivisionID;

            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeRepositorySchemeID,
                                                      @FreezerSubdivisionID,
                                                      @ObjectTableFreezerSubdivisionID,
                                                      @EIDSSFreezerSubdivisionID,
                                                      @DataAuditEventID OUTPUT;

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
                   @ObjectTableFreezerSubdivisionID,
                   51586990000041,
                   a.FreezerSubdivisionID,
                   NULL,
                   b.BoxPlaceAvailability,
                   a.BoxPlaceAvailability,
                   @AuditUserName,
                   @EIDSSFreezerSubdivisionID
            FROM @FreezerSubdivisionAfterEdit a
                FULL JOIN @FreezerSubdivisionBeforeEdit b
                    ON a.FreezerSubdivisionID = b.FreezerSubdivisionID
            WHERE (a.BoxPlaceAvailability <> b.BoxPlaceAvailability)
                  OR (
                         a.BoxPlaceAvailability IS NOT NULL
                         AND b.BoxPlaceAvailability IS NULL
                     )
                  OR (
                         a.BoxPlaceAvailability IS NULL
                         AND b.BoxPlaceAvailability IS NOT NULL
                     );
            -- End data audit

            DELETE FROM @FreezerBoxLocationAvailabilitiesTemp
            WHERE FreezerSubdivisionID = @RowID;
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

            INSERT INTO @SuppressSelect2
            EXECUTE dbo.USP_ADMIN_EVENT_SET @EventId,
                                            @EventTypeId,
                                            @EventUserId,
                                            @EventObjectId,
                                            @EventDiseaseId,
                                            @EventSiteId,
                                            @EventInformationString,
                                            @EventLoginSiteId,
                                            @EventLocationId,
                                            @AuditUserName;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        IF @Favorites IS NOT NULL
        BEGIN
            DECLARE @UserPreferenceID AS BIGINT;

            SELECT @UserPreferenceID =
            (
                SELECT UserPreferenceUID
                FROM dbo.UserPreference
                WHERE idfUserID = @UserID
                      AND ModuleConstantID = 10508006
                      AND intRowStatus = 0
            );

            IF @UserPreferenceID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET N'UserPreference',
                                                  @UserPreferenceID OUTPUT;

                INSERT INTO dbo.UserPreference
                (
                    UserPreferenceUID,
                    idfUserID,
                    ModuleConstantID,
                    PreferenceDetail,
                    intRowStatus,
                    AuditCreateUser,
                    AuditCreateDTM
                )
                VALUES
                (@UserPreferenceID, @UserID, 10508006, @FavoritesString, 0, @AuditUserName, GETDATE());
            END
            ELSE
            BEGIN
                UPDATE dbo.UserPreference
                SET idfUserID = @UserID,
                    PreferenceDetail = @FavoritesString,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE UserPreferenceUID = @UserPreferenceID;
            END
        END;

        IF @@TRANCOUNT > 0
            COMMIT;

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @KeyId AS KeyId,
               'Labratory' AS KeyName;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH;
END;
