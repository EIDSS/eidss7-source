-- ================================================================================================
-- Name: USSP_LAB_SAMPLE_SET
--
-- Description:	Inserts or updates sample records for various laboratory module use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/08/2018 Initial release.
-- Stephen Long		01/24/2019 Added storage box place to support the location in the freezer 
--                             subdivision.  Changed freezer ID to freezer subdivision ID.
-- Stephen Long     01/30/2019 Added disease ID parameter and to insert/update statements.
-- Stephen Long     02/21/2019 Added root sample ID and sample kind type ID.
-- Stephen Long     03/08/2019 Added row action 'D' for aliquot/derivative, so new lab sample ID 
--                             is not created, rather a number or country decides on a customized 
--                             method.
-- Stephen Long     03/28/2019 Added parameter @EIDSSLaboratorySampleID for aliquots/derivatives. 
--                             These are assigned in the EIDSS application from the derived off of
--                             the original (parent) sample ID.
-- Stephen Long     04/16/2019 Added copy of human master to human for new sample records.
-- Stephen Long     07/09/2019 Added human master ID parameter.  Updated human copy call.
-- Stephen Long     08/29/2019 Corrected root sample ID on insert portion.
-- Stephen Long     11/05/2019 Set root sample ID to sample ID when aliquot/derivative action.
-- Stephen Long     03/11/2020 Changed entered date to use GETDATE on insert.
-- Stephen Long     03/17/2020 Added logic to process transferred out sample's status.
-- Stephen Long     03/18/2020 Added logic to mark transfer final when sample accessioned in or 
--                             rejected at the receiving laboratory.
-- Stephen Long     03/30/2020 Added set of audit update time and user on record inserts/updates.
--                             Removed setting of root sample ID to sample ID of parent when 
--                             aliquot/derivative row action.  Root sample ID set to parent sample 
--                             ID in the application.
-- Stephen Long     04/17/2020 Renamed original sample ID to parent sample ID to be inline with the
--                             business terminology. Root is more along the line of original.  Also
--                             changed not to set the parent sample ID unless it is an aliquot/
--                             derivative which is handled in the app.
-- Stephen Long     05/05/2020 Removed update of transfer sample out record.  Handled in the 
--                             application.
-- Stephen Long     07/06/2020 Add set of lab module source indicator.
-- Stephen Long     09/03/2020 Removal of laboratory sample ID next number get call for 
--                             samples being accessioned and saved.  The laboratory sample ID get
--                             call has been moved to occur prior to save.
-- Stephen Long     09/24/2021 Removed language ID parameter as it is not needed.
-- Stephen Long     01/07/2022 Removed copy human actual to human; moved to parent stored 
--                             procedure.
-- Stephen Long     01/31/2022 Added source system name and key value update on insert.
-- Stephen Long     05/23/2022 Commented out update of disease ID; should never happen in the lab 
--                             module.
-- Stephen Long     10/01/2022 Changed to set EIDSS lab sample ID on a rejected sample.  Business 
--                             requirement retained from 6.1.
-- Stephen Long     01/03/2023 Added update to specimen collected field on human disease report 
--                             when a sample is added.
-- Stephen Long     02/07/2023 Fix to not populate strBarcode when sample is rejected.
-- Stephen Long     02/20/2023 Added data audit logic for SAUC30 and 31.
-- Stephen Long     03/28/2023 Fixed test completed and unassigned indicator.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_LAB_SAMPLE_SET]
(
    @SampleID BIGINT OUTPUT,
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
    @VectorTypeID BIGINT = NULL,
    @SpeciesTypeID BIGINT = NULL,
    @EIDSSVectorID NVARCHAR(50) = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @VectorSessionID BIGINT = NULL,
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @CollectionDate DATETIME = NULL,
    @CollectedByPersonID BIGINT = NULL,
    @CollectedByOrganizationID BIGINT = NULL,
    @SentDate DATETIME = NULL,
    @SentToOrganizationID BIGINT = NULL,
    @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
    @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
    @SiteID BIGINT,
    @FunctionalAreaID BIGINT = NULL,
    @FreezerSubdivisionID BIGINT = NULL,
    @StorageBoxPlace NVARCHAR(200) = NULL,
    @EnteredDate DATETIME = NULL,
    @OutOfRepositoryDate DATETIME = NULL,
    @MarkedForDispositionByPersonID BIGINT = NULL,
    @DestructionDate DATETIME = NULL,
    @DestructionMethodTypeID BIGINT = NULL,
    @DestroyedByPersonID BIGINT = NULL,
    @ReadOnlyIndicator BIT,
    @AccessionDate DATETIME = NULL,
    @AccessionConditionTypeID BIGINT = NULL,
    @AccessionByPersonID BIGINT = NULL,
    @SampleStatusTypeID BIGINT = NULL,
    @PreviousSampleStatusTypeID BIGINT = NULL,
    @AccessionComment NVARCHAR(200) = NULL,
    @Note NVARCHAR(500) = NULL,
    @CurrentSiteID BIGINT = NULL,
    @SampleKindTypeID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @RowStatus INT,
    @RowAction INT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @MonitoringSessionToMaterialID BIGINT = NULL,
                                                                       -- Data audit
                @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                @DataAuditEventID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = NULL,
                @ObjectID BIGINT = NULL,
                @ObjectTableSampleID BIGINT = 75620000000,             -- tlbMaterial
                @ObjectTableVectorID BIGINT = 4575310000000,           -- tlbVector
                @ObjectTableTransferOutID BIGINT = 75770000000,        -- tlbTransferOUT, 
                @ObjectTableHumanDiseaseReportID BIGINT = 75610000000, -- tlbHumanCase,
                @ObjectTableHumanID BIGINT = 75600000000,              -- tlbHuman
                @ObjectTableFarmID BIGINT = 75550000000,               -- tlbFarm
                @EIDSSObjectID NVARCHAR(200);
        -- End data audit

        DECLARE @SampleBeforeEdit TABLE
        (
            SampleID BIGINT,
            SampleTypeID BIGINT,
            RootSampleID BIGINT,
            ParentSampleID BIGINT,
            HumanID BIGINT,
            SpeciesID BIGINT,
            AnimalID BIGINT,
            MonitoringSessionID BIGINT,
            FieldCollectedByPersonID BIGINT,
            FieldCollectedByOfficeID BIGINT,
            MainTestID BIGINT,
            FieldCollectionDate DATETIME,
            FieldSentDate DATETIME,
            FieldBarcodeID NVARCHAR(200),
            CalculatedCaseID NVARCHAR(200),
            CalculatedHumanName NVARCHAR(700),
            VectorSurveillanceSessionID BIGINT,
            VectorID BIGINT,
            SubdivisionID BIGINT,
            SampleStatusTypeID BIGINT,
            DepartmentID BIGINT,
            DestroyedByPersonID BIGINT,
            EnteringDate DATETIME,
            DestructionDate DATETIME,
            BarcodeID NVARCHAR(200),
            Note NVARCHAR(500),
            SendToOfficeID BIGINT,
            ReadOnlyIndicator BIT,
            BirdStatusTypeID BIGINT,
            HumanDiseaseReportID BIGINT,
            VeterinaryDiseaseReportID BIGINT,
            AccessionDate DATETIME,
            AccessionConditionTypeID BIGINT,
            Condition NVARCHAR(200),
            AccessionByPersonID BIGINT,
            DestructionMethodTypeID BIGINT,
            CurrentSiteID BIGINT,
            SampleKindTypeID BIGINT,
            AccessionIndicator INT,
            ShowInCaseOrSessionIndicator INT,
            ShowInLabListIndicator INT,
            ShowInDispositionListIndicator INT,
            ShowInAccessionInFormIndicator INT,
            MarkedForDispositionByPersonID BIGINT,
            OutOfRepositoryDate DATETIME,
            SampleStatusDate DATETIME,
            RowStatus INT,
            StorageBoxPlace NVARCHAR(200),
            PreviousSampleStatusTypeID BIGINT,
            DiseaseID BIGINT,
            LabModuleSourceIndicator BIT,
            TestUnassignedIndicator BIT,
            TestCompletedIndicator BIT,
            TransferIndicator BIT
        );
        DECLARE @SampleAfterEdit TABLE
        (
            SampleID BIGINT,
            SampleTypeID BIGINT,
            RootSampleID BIGINT,
            ParentSampleID BIGINT,
            HumanID BIGINT,
            SpeciesID BIGINT,
            AnimalID BIGINT,
            MonitoringSessionID BIGINT,
            FieldCollectedByPersonID BIGINT,
            FieldCollectedByOfficeID BIGINT,
            MainTestID BIGINT,
            FieldCollectionDate DATETIME,
            FieldSentDate DATETIME,
            FieldBarcodeID NVARCHAR(200),
            CalculatedCaseID NVARCHAR(200),
            CalculatedHumanName NVARCHAR(700),
            VectorSurveillanceSessionID BIGINT,
            VectorID BIGINT,
            SubdivisionID BIGINT,
            SampleStatusTypeID BIGINT,
            DepartmentID BIGINT,
            DestroyedByPersonID BIGINT,
            EnteringDate DATETIME,
            DestructionDate DATETIME,
            BarcodeID NVARCHAR(200),
            Note NVARCHAR(500),
            SendToOfficeID BIGINT,
            ReadOnlyIndicator BIT,
            BirdStatusTypeID BIGINT,
            HumanDiseaseReportID BIGINT,
            VeterinaryDiseaseReportID BIGINT,
            AccessionDate DATETIME,
            AccessionConditionTypeID BIGINT,
            Condition NVARCHAR(200),
            AccessionByPersonID BIGINT,
            DestructionMethodTypeID BIGINT,
            CurrentSiteID BIGINT,
            SampleKindTypeID BIGINT,
            AccessionIndicator INT,
            ShowInCaseOrSessionIndicator INT,
            ShowInLabListIndicator INT,
            ShowInDispositionListIndicator INT,
            ShowInAccessionInFormIndicator INT,
            MarkedForDispositionByPersonID BIGINT,
            OutOfRepositoryDate DATETIME,
            SampleStatusDate DATETIME,
            RowStatus INT,
            StorageBoxPlace NVARCHAR(200),
            PreviousSampleStatusTypeID BIGINT,
            DiseaseID BIGINT,
            LabModuleSourceIndicator BIT,
            TestUnassignedIndicator BIT,
            TestCompletedIndicator BIT,
            TransferIndicator BIT
        );
        DECLARE @TransferBeforeEdit TABLE
        (
            TransferID BIGINT,
            TransferStatusTypeID BIGINT
        );
        DECLARE @TransferAfterEdit TABLE
        (
            TransferID BIGINT,
            TransferStatusTypeID BIGINT
        );
        DECLARE @HumanDiseaseReportBeforeEdit TABLE
        (
            HumanDiseaseReportID BIGINT,
            SpecimenCollectedTypeID BIGINT NULL
        );
        DECLARE @HumanDiseaseReportAfterEdit TABLE
        (
            HumanDiseaseReportID BIGINT,
            SpecimenCollectedTypeID BIGINT NULL
        );
        DECLARE @FarmBeforeEdit TABLE
        (
            FarmID BIGINT,
            MonitoringSessionID BIGINT NULL
        );
        DECLARE @FarmAfterEdit TABLE
        (
            FarmID BIGINT,
            MonitoringSessionID BIGINT NULL
        );
        DECLARE @HumanBeforeEdit TABLE
        (
            HumanID BIGINT,
            MonitoringSessionID BIGINT NULL
        );
        DECLARE @HumanAfterEdit TABLE
        (
            HumanID BIGINT,
            MonitoringSessionID BIGINT NULL
        );

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        -- Data audit
        IF @RowAction = 1 -- Standard insert
           OR @RowAction = 5 -- Insert and accession (LUC01)
           OR @RowAction = 6 -- Create aliquot/derivative and accession (LUC02)
           OR @RowAction = 7 -- Create transfer in sample and do not accession (LUC03)
        BEGIN
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            --Local/field sample EIDSS ID. Only system assign when user leaves blank.
            IF @RowAction = 1
            BEGIN
                IF @EIDSSLocalOrFieldSampleID IS NULL
                   OR @EIDSSLocalOrFieldSampleID = ''
                BEGIN
                    EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Sample Field Barcode',
                                                       @NextNumberValue = @EIDSSLocalOrFieldSampleID OUTPUT,
                                                       @InstallationSite = NULL;
                END
            END

            IF @RowAction = 5
            BEGIN
                SET @ObjectTypeID = 10017001; -- Accession In
            END

            IF @RowAction = 6
            BEGIN
                IF @SampleKindTypeID = 12675410000000 -- Aliquot
                BEGIN
                    SET @ObjectTypeID = 10017008; -- Aliquot
                END
                ELSE
                BEGIN
                    SET @ObjectTypeID = 10017017; -- Derivative
                END
            END

            IF @RowAction = 7
            BEGIN
                SET @ObjectTypeID = 10017056; -- Sample Transfer
            END

            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbMaterial',
                                              @idfsKey = @SampleID OUTPUT;

            IF @EIDSSLaboratorySampleID IS NULL
            BEGIN
                SET @EIDSSObjectID = @EIDSSLocalOrFieldSampleID;
            END
            ELSE
            BEGIN
                SET @EIDSSObjectID = @EIDSSLaboratorySampleID;
            END

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @SampleID,
                                                      @ObjectTableSampleID,
                                                      @EIDSSObjectID,
                                                      @DataAuditEventID OUTPUT;
        END
        -- End data audit

        IF @RowAction = 1
           OR @RowAction = 5
        BEGIN
            IF @FarmMasterID IS NOT NULL -- Registering new veterinary sample with either no disease report or possibly no monitoring session.
            BEGIN
                IF @FarmID IS NULL
                BEGIN
                    DECLARE @NewFarmOwnerID BIGINT,
                            @FlockOrHerdID BIGINT;

                    EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                       @DataAuditEventID,
                                                       @EIDSSLaboratorySampleID,
                                                       @FarmMasterID,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       @HumanMasterID,
                                                       @FarmID OUTPUT,
                                                       @NewFarmOwnerID OUTPUT;

                    IF @MonitoringSessionID IS NOT NULL -- New farm added to the veterinary active surveillance session.
                    BEGIN
                        INSERT INTO @FarmBeforeEdit
                        SELECT idfFarm,
                               idfMonitoringSession
                        FROM dbo.tlbFarm
                        WHERE idfFarm = @FarmID;

                        UPDATE dbo.tlbFarm
                        SET idfMonitoringSession = @MonitoringSessionID
                        WHERE idfFarm = @FarmID;

                        INSERT INTO @FarmAfterEdit
                        SELECT idfFarm,
                               idfMonitoringSession
                        FROM dbo.tlbFarm
                        WHERE idfFarm = @FarmID;

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
                               @ObjectTableFarmID,
                               4572180000000,
                               a.FarmID,
                               NULL,
                               b.MonitoringSessionID,
                               a.MonitoringSessionID,
                               @AuditUserName,
                               @EIDSSObjectID
                        FROM @FarmAfterEdit a
                            FULL JOIN @FarmBeforeEdit b
                                ON a.FarmID = b.FarmID
                        WHERE (a.MonitoringSessionID <> b.MonitoringSessionID)
                              OR (
                                     a.MonitoringSessionID IS NOT NULL
                                     AND b.MonitoringSessionID IS NULL
                                 )
                              OR (
                                     a.MonitoringSessionID IS NULL
                                     AND b.MonitoringSessionID IS NOT NULL
                                 );
                    END

                    SET @HumanID = @NewFarmOwnerID;
                    SET @HumanMasterID = NULL;
                END

                IF @SpeciesID IS NULL -- Adding new flock or herd and species to an existing farm.
                BEGIN
                    EXECUTE dbo.USSP_VET_FLOCK_HERD_SET @AuditUserName,
                                                        @DataAuditEventID,
                                                        @EIDSSLaboratorySampleID,
                                                        @FlockOrHerdID OUTPUT,
                                                        NULL,
                                                        @FarmID,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        0,
                                                        1;

                    EXECUTE dbo.USSP_VET_SPECIES_SET @AuditUserName,
                                                     @DataAuditEventID,
                                                     @SpeciesID OUTPUT,
                                                     NULL,
                                                     @SpeciesTypeID,
                                                     @FlockOrHerdID,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     0,
                                                     1,
                                                     NULL;
                END
            END
            ELSE
            BEGIN
                IF @HumanMasterID IS NOT NULL -- Registering new human sample with either no disease report or possibly no active surveillance session.
                BEGIN
                    EXECUTE dbo.USSP_HUM_COPY_HUMAN_SET @HumanMasterID,
                                                        @DataAuditEventID,
                                                        @AuditUserName,
                                                        @HumanID OUTPUT,
                                                        @ReturnCode OUTPUT,
                                                        @ReturnMessage OUTPUT;

                    IF @MonitoringSessionID IS NOT NULL -- New person added to the human active surveillance session.
                    BEGIN
                        INSERT INTO @HumanBeforeEdit
                        SELECT idfHuman,
                               idfMonitoringSession
                        FROM dbo.tlbHuman
                        WHERE idfHuman = @HumanID;

                        UPDATE dbo.tlbHuman
                        SET idfMonitoringSession = @MonitoringSessionID
                        WHERE idfHuman = @HumanID;

                        INSERT INTO @HumanAfterEdit
                        SELECT idfHuman,
                               idfMonitoringSession
                        FROM dbo.tlbHuman
                        WHERE idfHuman = @HumanID;

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
                               @ObjectTableHumanID,
                               51586990000027,
                               a.HumanID,
                               NULL,
                               b.MonitoringSessionID,
                               a.MonitoringSessionID,
                               @AuditUserName,
                               @EIDSSObjectID
                        FROM @HumanAfterEdit a
                            FULL JOIN @HumanBeforeEdit b
                                ON a.HumanID = b.HumanID
                        WHERE (a.MonitoringSessionID <> b.MonitoringSessionID)
                              OR (
                                     a.MonitoringSessionID IS NOT NULL
                                     AND b.MonitoringSessionID IS NULL
                                 )
                              OR (
                                     a.MonitoringSessionID IS NULL
                                     AND b.MonitoringSessionID IS NOT NULL
                                 );
                    END
                END
            END
        END;

        IF @VectorID < 0
           AND @SpeciesTypeID IS NOT NULL
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbVector', @VectorID OUTPUT;

            EXECUTE dbo.USP_GBL_NextNumber_GET 'Vector Surveillance Vector',
                                               @EIDSSVectorID OUTPUT,
                                               NULL;

            INSERT INTO dbo.tlbVector
            (
                idfVector,
                strVectorID,
                idfCollectedByOffice,
                idfCollectedByPerson,
                datCollectionDateTime,
                idfsVectorType,
                idfsVectorSubType,
                intQuantity,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@VectorID,
             @EIDSSVectorID,
             @CollectedByOrganizationID,
             @CollectedByPersonID,
             @CollectionDate,
             @VectorTypeID,
             @SpeciesTypeID,
             1  ,
             0  ,
             GETDATE(),
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
             @ObjectTableVectorID,
             @VectorID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableVectorID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSVectorID
            );
        -- End data audit
        END;

        IF @RowAction = 1 -- Standard insert
           OR @RowAction = 5 -- Insert and accession (LUC01)
           OR @RowAction = 6 -- Create aliquot/derivative and accession (LUC02)
           OR @RowAction = 7 -- Create transfer in sample and do not accession (LUC03)
        BEGIN
            IF @RowAction <> 6
               AND @RowAction <> 7
            BEGIN
                SET @RootSampleID = @SampleID;
            END

            INSERT INTO dbo.tlbMaterial
            (
                idfMaterial,
                idfsSampleType,
                idfRootMaterial,
                idfParentMaterial,
                idfHuman,
                idfSpecies,
                idfAnimal,
                idfVector,
                idfMonitoringSession,
                idfVectorSurveillanceSession,
                idfHumanCase,
                idfVetCase,
                datFieldCollectionDate,
                idfFieldCollectedByPerson,
                idfFieldCollectedByOffice,
                datFieldSentDate,
                idfSendToOffice,
                strFieldBarcode,
                strBarcode,
                idfsSite,
                idfInDepartment,
                idfSubdivision,
                StorageBoxPlace,
                datEnteringDate,
                datOutOfRepositoryDate,
                idfMarkedForDispositionByPerson,
                datDestructionDate,
                idfsDestructionMethod,
                idfDestroyedByPerson,
                blnReadOnly,
                datAccession,
                idfsAccessionCondition,
                idfAccesionByPerson,
                idfsSampleStatus,
                strCondition,
                strNote,
                idfsCurrentSite,
                idfsSampleKind,
                PreviousSampleStatusID,
                DiseaseID,
                LabModuleSourceIndicator,
                intRowStatus,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                TestCompletedIndicator, 
                TestUnassignedIndicator
            )
            VALUES
            (@SampleID,
             @SampleTypeID,
             @RootSampleID,
             @ParentSampleID,
             @HumanID,
             @SpeciesID,
             @AnimalID,
             @VectorID,
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
             GETDATE(),
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
             @AccessionComment,
             @Note,
             @CurrentSiteID,
             @SampleKindTypeID,
             @PreviousSampleStatusTypeID,
             @DiseaseID,
             1  ,
             0  ,
             10519001,
             '[{"idfMaterial":' + CAST(@SampleID AS NVARCHAR(300)) + '}]',
             @AuditUserName, 
             0, 
             1
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
             @ObjectTableSampleID,
             @SampleID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableSampleID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSLaboratorySampleID
            );
            -- End data audit

            IF @HumanDiseaseReportID IS NOT NULL
            BEGIN
                INSERT INTO @HumanDiseaseReportBeforeEdit
                SELECT idfHumanCase,
                       idfsYNSpecimenCollected
                FROM dbo.tlbHumanCase
                WHERE idfHumanCase = @HumanDiseaseReportID;

                UPDATE dbo.tlbHumanCase
                SET idfsYNSpecimenCollected = 10100001,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfHumanCase = @HumanDiseaseReportID;

                INSERT INTO @HumanDiseaseReportAfterEdit
                SELECT idfHumanCase,
                       idfsYNSpecimenCollected
                FROM dbo.tlbHumanCase
                WHERE idfHumanCase = @HumanDiseaseReportID;

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
                       @ObjectTableHumanDiseaseReportID,
                       79760000000,
                       a.HumanDiseaseReportID,
                       NULL,
                       b.SpecimenCollectedTypeID,
                       a.SpecimenCollectedTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanDiseaseReportAfterEdit a
                    FULL JOIN @HumanDiseaseReportBeforeEdit b
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
            END

            IF (
                   @RowAction = 1 -- Register new sample
                   OR @RowAction = 5 -- Insert accession
               )
               AND @MonitoringSessionID IS NOT NULL
            BEGIN
                EXECUTE dbo.USSP_AS_SAMPLE_TO_DISEASE_SET @AuditUserName,
                                                          @DataAuditEventID,
                                                          0,
                                                          @MonitoringSessionID,
                                                          @SampleID,
                                                          @DiseaseID,
                                                          @SampleTypeID,
                                                          0,
                                                          1;
            END
            ELSE IF @RowAction = 7
                    AND @MonitoringSessionID IS NOT NULL -- Transfer a sample (creates a new sample record)
            BEGIN
                DECLARE @SamplesToDiseaseRowID BIGINT;
                DECLARE @SamplesToDiseasesTemp TABLE
                (
                    MonitoringSessionToMaterialID BIGINT NOT NULL,
                    MonitoringSessionID BIGINT NULL,
                    SampleID BIGINT NOT NULL,
                    SampleTypeID BIGINT NULL,
                    DiseaseID BIGINT NOT NULL
                );

                INSERT INTO @SamplesToDiseasesTemp
                SELECT idfMonitoringSessionToMaterial,
                       idfMonitoringSession,
                       idfMaterial,
                       idfsSampleType,
                       idfsDisease
                FROM dbo.tlbMonitoringSessionToMaterial
                WHERE idfMaterial = @RootSampleID
                      AND intRowStatus = 0;

                WHILE EXISTS (SELECT * FROM @SamplesToDiseasesTemp)
                BEGIN
                    SELECT TOP 1
                        @SamplesToDiseaseRowID = MonitoringSessionToMaterialID,
                        @MonitoringSessionToMaterialID = MonitoringSessionToMaterialID,
                        @DiseaseID = DiseaseID
                    FROM @SamplesToDiseasesTemp;

                    EXECUTE dbo.USSP_AS_SAMPLE_TO_DISEASE_SET @AuditUserName,
                                                              @DataAuditEventID,
                                                              @MonitoringSessionToMaterialID,
                                                              @MonitoringSessionID,
                                                              @SampleID,
                                                              @DiseaseID,
                                                              @SampleTypeID,
                                                              0,
                                                              1;

                    DELETE FROM @SamplesToDiseasesTemp
                    WHERE MonitoringSessionToMaterialID = @SamplesToDiseaseRowID;
                END;
            END
        END;
        ELSE
        BEGIN
            INSERT INTO @SampleBeforeEdit
            (
                SampleID,
                SampleTypeID,
                RootSampleID,
                ParentSampleID,
                HumanID,
                SpeciesID,
                AnimalID,
                MonitoringSessionID,
                FieldCollectedByPersonID,
                FieldCollectedByOfficeID,
                MainTestID,
                FieldCollectionDate,
                FieldSentDate,
                FieldBarcodeID,
                CalculatedCaseID,
                CalculatedHumanName,
                VectorSurveillanceSessionID,
                VectorID,
                SubdivisionID,
                SampleStatusTypeID,
                DepartmentID,
                DestroyedByPersonID,
                EnteringDate,
                DestructionDate,
                BarcodeID,
                Note,
                SendToOfficeID,
                ReadOnlyIndicator,
                BirdStatusTypeID,
                HumanDiseaseReportID,
                VeterinaryDiseaseReportID,
                AccessionDate,
                AccessionConditionTypeID,
                Condition,
                AccessionByPersonID,
                DestructionMethodTypeID,
                CurrentSiteID,
                SampleKindTypeID,
                AccessionIndicator,
                ShowInCaseOrSessionIndicator,
                ShowInLabListIndicator,
                ShowInDispositionListIndicator,
                ShowInAccessionInFormIndicator,
                MarkedForDispositionByPersonID,
                OutOfRepositoryDate,
                SampleStatusDate,
                RowStatus,
                StorageBoxPlace,
                PreviousSampleStatusTypeID,
                DiseaseID,
                LabModuleSourceIndicator,
                TestUnassignedIndicator,
                TestCompletedIndicator,
                TransferIndicator
            )
            SELECT idfMaterial,
                   idfsSampleType,
                   idfRootMaterial,
                   idfParentMaterial,
                   idfHuman,
                   idfSpecies,
                   idfAnimal,
                   idfMonitoringSession,
                   idfFieldCollectedByPerson,
                   idfFieldCollectedByOffice,
                   idfMainTest,
                   datFieldCollectionDate,
                   datFieldSentDate,
                   strFieldBarcode,
                   strCalculatedCaseID,
                   strCalculatedHumanName,
                   idfVectorSurveillanceSession,
                   idfVector,
                   idfSubdivision,
                   idfsSampleStatus,
                   idfInDepartment,
                   idfDestroyedByPerson,
                   datEnteringDate,
                   datDestructionDate,
                   strBarcode,
                   strNote,
                   idfSendToOffice,
                   blnReadOnly,
                   idfsBirdStatus,
                   idfHumanCase,
                   idfVetCase,
                   datAccession,
                   idfsAccessionCondition,
                   strCondition,
                   idfAccesionByPerson,
                   idfsDestructionMethod,
                   idfsCurrentSite,
                   idfsSampleKind,
                   blnAccessioned,
                   blnShowInCaseOrSession,
                   blnShowInLabList,
                   blnShowInDispositionList,
                   blnShowInAccessionInForm,
                   idfMarkedForDispositionByPerson,
                   datOutOfRepositoryDate,
                   datSampleStatusDate,
                   intRowStatus,
                   StorageBoxPlace,
                   PreviousSampleStatusID,
                   DiseaseID,
                   LabModuleSourceIndicator,
                   TestUnassignedIndicator,
                   TestCompletedIndicator,
                   TransferIndicator
            FROM dbo.tlbMaterial
            WHERE idfMaterial = @SampleID;

            IF @RowAction = 4 -- Update and accession (LUC01)
            BEGIN
                SET @ObjectTypeID = 10017001; -- Accession In
            END
            ELSE IF @RowAction = 8 -- Sample Transfer
                    OR @RowAction = 9
            BEGIN
                SET @ObjectTypeID = 10017056; -- Sample Transfer
            END
            ELSE IF @RowAction = 10 -- Sample Destruction
            BEGIN
                SET @ObjectTypeID = 10017060; -- Sample Destruction
            END
            ELSE
            BEGIN
                SET @ObjectTypeID = 10017045; -- Sample
            END

            -- Data audit
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            IF @EIDSSLaboratorySampleID IS NULL
            BEGIN
                SET @EIDSSObjectID = @EIDSSLocalOrFieldSampleID;
            END
            ELSE
            BEGIN
                SET @EIDSSObjectID = @EIDSSLaboratorySampleID;
            END

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @SampleID,
                                                      @ObjectTableSampleID,
                                                      @EIDSSObjectID,
                                                      @DataAuditEventID OUTPUT;
            -- End data audit

            -- Sample is being accessioned, so get the next lab sample code allowing the user the option to print the barcode.
            IF @RowAction = 4
               OR @RowAction = 8 -- Update and accession (LUC01)
            BEGIN
                -- Transferred in sample accessioned in, so update the transfer record's transfer status type ID to final. 
                IF @RowAction = 8
                BEGIN
                    INSERT INTO @TransferBeforeEdit
                    SELECT t.idfTransferOut,
                           t.idfsTransferStatus
                    FROM dbo.tlbTransferOUT t
                        INNER JOIN dbo.tlbTransferOutMaterial tom
                            ON tom.idfTransferOut = t.idfTransferOut
                    WHERE tom.idfMaterial = @RootSampleID;

                    UPDATE t
                    SET t.idfsTransferStatus = 10001001,
                        --Final
                        t.AuditUpdateUser = @AuditUserName,
                        t.AuditUpdateDTM = GETDATE()
                    FROM dbo.tlbTransferOUT t
                        INNER JOIN dbo.tlbTransferOutMaterial tom
                            ON tom.idfTransferOut = t.idfTransferOut
                    WHERE tom.idfMaterial = @RootSampleID;

                    INSERT INTO @TransferAfterEdit
                    SELECT t.idfTransferOut,
                           t.idfsTransferStatus
                    FROM dbo.tlbTransferOUT t
                        INNER JOIN dbo.tlbTransferOutMaterial tom
                            ON tom.idfTransferOut = t.idfTransferOut
                    WHERE tom.idfMaterial = @RootSampleID;

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
                           @ObjectTableTransferOutID,
                           4577940000000,
                           a.TransferID,
                           NULL,
                           b.TransferStatusTypeID,
                           a.TransferStatusTypeID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @TransferAfterEdit a
                        FULL JOIN @TransferBeforeEdit b
                            ON a.TransferID = b.TransferID
                    WHERE (a.TransferStatusTypeID <> b.TransferStatusTypeID)
                          OR (
                                 a.TransferStatusTypeID IS NOT NULL
                                 AND b.TransferStatusTypeID IS NULL
                             )
                          OR (
                                 a.TransferStatusTypeID IS NULL
                                 AND b.TransferStatusTypeID IS NOT NULL
                             );
                END;

                UPDATE dbo.tlbMaterial
                SET idfsSampleType = @SampleTypeID,
                    idfRootMaterial = @RootSampleID,
                    idfParentMaterial = @ParentSampleID,
                    idfHuman = @HumanID,
                    idfSpecies = @SpeciesID,
                    idfAnimal = @AnimalID,
                    idfMonitoringSession = @MonitoringSessionID,
                    idfFieldCollectedByPerson = @CollectedByPersonID,
                    idfFieldCollectedByOffice = @CollectedByOrganizationID,
                    datFieldCollectionDate = @CollectionDate,
                    datFieldSentDate = @SentDate,
                    strFieldBarcode = @EIDSSLocalOrFieldSampleID,
                    idfVectorSurveillanceSession = @VectorSessionID,
                    idfVector = @VectorID,
                    idfSubdivision = @FreezerSubdivisionID,
                    StorageBoxPlace = @StorageBoxPlace,
                    idfsSampleStatus = @SampleStatusTypeID,
                    idfInDepartment = @FunctionalAreaID,
                    idfDestroyedByPerson = @DestroyedByPersonID,
                    datEnteringDate = @EnteredDate,
                    datDestructionDate = @DestructionDate,
                    strBarcode = @EIDSSLaboratorySampleID,
                    strNote = @Note,
                    idfsSite = @SiteID,
                    idfsCurrentSite = @CurrentSiteID,
                    idfsSampleKind = @SampleKindTypeID,
                    intRowStatus = @RowStatus,
                    idfSendToOffice = @SentToOrganizationID,
                    blnReadOnly = @ReadOnlyIndicator,
                    idfHumanCase = @HumanDiseaseReportID,
                    idfVetCase = @VeterinaryDiseaseReportID,
                    datAccession = @AccessionDate,
                    idfsAccessionCondition = @AccessionConditionTypeID,
                    strCondition = @AccessionComment,
                    idfAccesionByPerson = @AccessionByPersonID,
                    idfsDestructionMethod = @DestructionMethodTypeID,
                    idfMarkedForDispositionByPerson = @MarkedForDispositionByPersonID,
                    datOutOfRepositoryDate = @OutOfRepositoryDate,
                    PreviousSampleStatusID = @PreviousSampleStatusTypeID,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE(), 
                    TestCompletedIndicator = 0, 
                    TestUnassignedIndicator = 1
                WHERE idfMaterial = @SampleID;
            END
            ELSE
            BEGIN
                -- Transferred in sample rejected, so update the transferred out sample's status to transferred out. 
                IF @RowAction = 9
                BEGIN
                    UPDATE dbo.tlbMaterial
                    SET idfsSampleStatus = 10015010, -- Transferred Out
                        AuditUpdateUser = @AuditUserName,
                        AuditUpdateDTM = GETDATE()
                    WHERE idfMaterial = @RootSampleID;

                    INSERT INTO @TransferBeforeEdit
                    SELECT t.idfTransferOut,
                           t.idfsTransferStatus
                    FROM dbo.tlbTransferOUT t
                        INNER JOIN dbo.tlbTransferOutMaterial tom
                            ON tom.idfTransferOut = t.idfTransferOut
                    WHERE tom.idfMaterial = @RootSampleID;

                    UPDATE t
                    SET t.idfsTransferStatus = 10001001, -- Final
                        t.AuditUpdateUser = @AuditUserName,
                        t.AuditUpdateDTM = GETDATE()
                    FROM dbo.tlbTransferOUT t
                        INNER JOIN dbo.tlbTransferOutMaterial tom
                            ON tom.idfTransferOut = t.idfTransferOut
                    WHERE tom.idfMaterial = @RootSampleID;

                    INSERT INTO @TransferAfterEdit
                    SELECT t.idfTransferOut,
                           t.idfsTransferStatus
                    FROM dbo.tlbTransferOUT t
                        INNER JOIN dbo.tlbTransferOutMaterial tom
                            ON tom.idfTransferOut = t.idfTransferOut
                    WHERE tom.idfMaterial = @RootSampleID;

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
                           @ObjectTableTransferOutID,
                           4577940000000,
                           a.TransferID,
                           NULL,
                           b.TransferStatusTypeID,
                           a.TransferStatusTypeID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @TransferAfterEdit a
                        FULL JOIN @TransferBeforeEdit b
                            ON a.TransferID = b.TransferID
                    WHERE (a.TransferStatusTypeID <> b.TransferStatusTypeID)
                          OR (
                                 a.TransferStatusTypeID IS NOT NULL
                                 AND b.TransferStatusTypeID IS NULL
                             )
                          OR (
                                 a.TransferStatusTypeID IS NULL
                                 AND b.TransferStatusTypeID IS NOT NULL
                             );
                END;

                IF @RowAction = 2
                   AND @AccessionConditionTypeID = 10108003 -- Rejected
                BEGIN
                    UPDATE dbo.tlbMaterial
                    SET idfsSampleType = @SampleTypeID,
                        idfRootMaterial = @RootSampleID,
                        idfParentMaterial = @ParentSampleID,
                        idfHuman = @HumanID,
                        idfSpecies = @SpeciesID,
                        idfAnimal = @AnimalID,
                        idfMonitoringSession = @MonitoringSessionID,
                        idfFieldCollectedByPerson = @CollectedByPersonID,
                        idfFieldCollectedByOffice = @CollectedByOrganizationID,
                        datFieldCollectionDate = @CollectionDate,
                        datFieldSentDate = @SentDate,
                        strFieldBarcode = @EIDSSLocalOrFieldSampleID,
                        idfVectorSurveillanceSession = @VectorSessionID,
                        idfVector = @VectorID,
                        idfSubdivision = @FreezerSubdivisionID,
                        StorageBoxPlace = @StorageBoxPlace,
                        idfsSampleStatus = @SampleStatusTypeID,
                        idfInDepartment = @FunctionalAreaID,
                        idfDestroyedByPerson = @DestroyedByPersonID,
                        datEnteringDate = @EnteredDate,
                        datDestructionDate = @DestructionDate,
                        strNote = @Note,
                        idfsSite = @SiteID,
                        idfsCurrentSite = @CurrentSiteID,
                        idfsSampleKind = @SampleKindTypeID,
                        intRowStatus = @RowStatus,
                        idfSendToOffice = @SentToOrganizationID,
                        blnReadOnly = @ReadOnlyIndicator,
                        idfHumanCase = @HumanDiseaseReportID,
                        idfVetCase = @VeterinaryDiseaseReportID,
                        datAccession = @AccessionDate,
                        idfsAccessionCondition = @AccessionConditionTypeID,
                        strCondition = @AccessionComment,
                        idfAccesionByPerson = @AccessionByPersonID,
                        idfsDestructionMethod = @DestructionMethodTypeID,
                        idfMarkedForDispositionByPerson = @MarkedForDispositionByPersonID,
                        datOutOfRepositoryDate = @OutOfRepositoryDate,
                        PreviousSampleStatusID = @PreviousSampleStatusTypeID,
                        AuditUpdateUser = @AuditUserName,
                        AuditUpdateDTM = GETDATE(), 
                        TestCompletedIndicator = 0,
                        TestUnassignedIndicator = 1
                    WHERE idfMaterial = @SampleID;
                END
                ELSE
                BEGIN
                    UPDATE dbo.tlbMaterial
                    SET idfsSampleType = @SampleTypeID,
                        idfRootMaterial = @RootSampleID,
                        idfParentMaterial = @ParentSampleID,
                        idfHuman = @HumanID,
                        idfSpecies = @SpeciesID,
                        idfAnimal = @AnimalID,
                        idfMonitoringSession = @MonitoringSessionID,
                        idfFieldCollectedByPerson = @CollectedByPersonID,
                        idfFieldCollectedByOffice = @CollectedByOrganizationID,
                        datFieldCollectionDate = @CollectionDate,
                        datFieldSentDate = @SentDate,
                        strFieldBarcode = @EIDSSLocalOrFieldSampleID,
                        idfVectorSurveillanceSession = @VectorSessionID,
                        idfVector = @VectorID,
                        idfSubdivision = @FreezerSubdivisionID,
                        StorageBoxPlace = @StorageBoxPlace,
                        idfsSampleStatus = @SampleStatusTypeID,
                        idfInDepartment = @FunctionalAreaID,
                        idfDestroyedByPerson = @DestroyedByPersonID,
                        datEnteringDate = @EnteredDate,
                        datDestructionDate = @DestructionDate,
                        strNote = @Note,
                        idfsSite = @SiteID,
                        idfsCurrentSite = @CurrentSiteID,
                        idfsSampleKind = @SampleKindTypeID,
                        intRowStatus = @RowStatus,
                        idfSendToOffice = @SentToOrganizationID,
                        blnReadOnly = @ReadOnlyIndicator,
                        idfHumanCase = @HumanDiseaseReportID,
                        idfVetCase = @VeterinaryDiseaseReportID,
                        datAccession = @AccessionDate,
                        idfsAccessionCondition = @AccessionConditionTypeID,
                        strCondition = @AccessionComment,
                        idfAccesionByPerson = @AccessionByPersonID,
                        idfsDestructionMethod = @DestructionMethodTypeID,
                        idfMarkedForDispositionByPerson = @MarkedForDispositionByPersonID,
                        datOutOfRepositoryDate = @OutOfRepositoryDate,
                        PreviousSampleStatusID = @PreviousSampleStatusTypeID,
                        AuditUpdateUser = @AuditUserName,
                        AuditUpdateDTM = GETDATE()
                    WHERE idfMaterial = @SampleID;
                END
            END

            INSERT INTO @SampleAfterEdit
            (
                SampleID,
                SampleTypeID,
                RootSampleID,
                ParentSampleID,
                HumanID,
                SpeciesID,
                AnimalID,
                MonitoringSessionID,
                FieldCollectedByPersonID,
                FieldCollectedByOfficeID,
                MainTestID,
                FieldCollectionDate,
                FieldSentDate,
                FieldBarcodeID,
                CalculatedCaseID,
                CalculatedHumanName,
                VectorSurveillanceSessionID,
                VectorID,
                SubdivisionID,
                SampleStatusTypeID,
                DepartmentID,
                DestroyedByPersonID,
                EnteringDate,
                DestructionDate,
                BarcodeID,
                Note,
                SendToOfficeID,
                ReadOnlyIndicator,
                BirdStatusTypeID,
                HumanDiseaseReportID,
                VeterinaryDiseaseReportID,
                AccessionDate,
                AccessionConditionTypeID,
                Condition,
                AccessionByPersonID,
                DestructionMethodTypeID,
                CurrentSiteID,
                SampleKindTypeID,
                AccessionIndicator,
                ShowInCaseOrSessionIndicator,
                ShowInLabListIndicator,
                ShowInDispositionListIndicator,
                ShowInAccessionInFormIndicator,
                MarkedForDispositionByPersonID,
                OutOfRepositoryDate,
                SampleStatusDate,
                RowStatus,
                StorageBoxPlace,
                PreviousSampleStatusTypeID,
                DiseaseID,
                LabModuleSourceIndicator,
                TestUnassignedIndicator,
                TestCompletedIndicator,
                TransferIndicator
            )
            SELECT idfMaterial,
                   idfsSampleType,
                   idfRootMaterial,
                   idfParentMaterial,
                   idfHuman,
                   idfSpecies,
                   idfAnimal,
                   idfMonitoringSession,
                   idfFieldCollectedByPerson,
                   idfFieldCollectedByOffice,
                   idfMainTest,
                   datFieldCollectionDate,
                   datFieldSentDate,
                   strFieldBarcode,
                   strCalculatedCaseID,
                   strCalculatedHumanName,
                   idfVectorSurveillanceSession,
                   idfVector,
                   idfSubdivision,
                   idfsSampleStatus,
                   idfInDepartment,
                   idfDestroyedByPerson,
                   datEnteringDate,
                   datDestructionDate,
                   strBarcode,
                   strNote,
                   idfSendToOffice,
                   blnReadOnly,
                   idfsBirdStatus,
                   idfHumanCase,
                   idfVetCase,
                   datAccession,
                   idfsAccessionCondition,
                   strCondition,
                   idfAccesionByPerson,
                   idfsDestructionMethod,
                   idfsCurrentSite,
                   idfsSampleKind,
                   blnAccessioned,
                   blnShowInCaseOrSession,
                   blnShowInLabList,
                   blnShowInDispositionList,
                   blnShowInAccessionInForm,
                   idfMarkedForDispositionByPerson,
                   datOutOfRepositoryDate,
                   datSampleStatusDate,
                   intRowStatus,
                   StorageBoxPlace,
                   PreviousSampleStatusID,
                   DiseaseID,
                   LabModuleSourceIndicator,
                   TestUnassignedIndicator,
                   TestCompletedIndicator,
                   TransferIndicator
            FROM dbo.tlbMaterial
            WHERE idfMaterial = @SampleID;

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
                   @ObjectTableSampleID,
                   49545390000000,
                   a.SampleID,
                   NULL,
                   b.SampleTypeID,
                   a.SampleTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SampleTypeID <> b.SampleTypeID)
                  OR (
                         a.SampleTypeID IS NOT NULL
                         AND b.SampleTypeID IS NULL
                     )
                  OR (
                         a.SampleTypeID IS NULL
                         AND b.SampleTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545400000000,
                   a.SampleID,
                   NULL,
                   b.RootSampleID,
                   a.RootSampleID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.RootSampleID <> b.RootSampleID)
                  OR (
                         a.RootSampleID IS NOT NULL
                         AND b.RootSampleID IS NULL
                     )
                  OR (
                         a.RootSampleID IS NULL
                         AND b.RootSampleID IS NOT NULL
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
                   @ObjectTableSampleID,
                   79970000000,
                   a.SampleID,
                   NULL,
                   b.ParentSampleID,
                   a.ParentSampleID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.ParentSampleID <> b.ParentSampleID)
                  OR (
                         a.ParentSampleID IS NOT NULL
                         AND b.ParentSampleID IS NULL
                     )
                  OR (
                         a.ParentSampleID IS NULL
                         AND b.ParentSampleID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4572430000000,
                   a.SampleID,
                   NULL,
                   b.HumanID,
                   a.HumanID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
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
            SELECT @DataAuditEventID,
                   @ObjectTableSampleID,
                   4572440000000,
                   a.SampleID,
                   NULL,
                   b.SpeciesID,
                   a.SpeciesID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SpeciesID <> b.SpeciesID)
                  OR (
                         a.SpeciesID IS NOT NULL
                         AND b.SpeciesID IS NULL
                     )
                  OR (
                         a.SpeciesID IS NULL
                         AND b.SpeciesID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4572450000000,
                   a.SampleID,
                   NULL,
                   b.AnimalID,
                   a.AnimalID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.AnimalID <> b.AnimalID)
                  OR (
                         a.AnimalID IS NOT NULL
                         AND b.AnimalID IS NULL
                     )
                  OR (
                         a.AnimalID IS NULL
                         AND b.AnimalID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4572470000000,
                   a.SampleID,
                   NULL,
                   b.MonitoringSessionID,
                   a.MonitoringSessionID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.MonitoringSessionID <> b.MonitoringSessionID)
                  OR (
                         a.MonitoringSessionID IS NOT NULL
                         AND b.MonitoringSessionID IS NULL
                     )
                  OR (
                         a.MonitoringSessionID IS NULL
                         AND b.MonitoringSessionID IS NOT NULL
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
                   @ObjectTableSampleID,
                   79950000000,
                   a.SampleID,
                   NULL,
                   b.FieldCollectedByPersonID,
                   a.FieldCollectedByPersonID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.FieldCollectedByPersonID <> b.FieldCollectedByPersonID)
                  OR (
                         a.FieldCollectedByPersonID IS NOT NULL
                         AND b.FieldCollectedByPersonID IS NULL
                     )
                  OR (
                         a.FieldCollectedByPersonID IS NULL
                         AND b.FieldCollectedByPersonID IS NOT NULL
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
                   @ObjectTableSampleID,
                   79940000000,
                   a.SampleID,
                   NULL,
                   b.FieldCollectedByOfficeID,
                   a.FieldCollectedByOfficeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.FieldCollectedByOfficeID <> b.FieldCollectedByOfficeID)
                  OR (
                         a.FieldCollectedByOfficeID IS NOT NULL
                         AND b.FieldCollectedByOfficeID IS NULL
                     )
                  OR (
                         a.FieldCollectedByOfficeID IS NULL
                         AND b.FieldCollectedByOfficeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545410000000,
                   a.SampleID,
                   NULL,
                   b.MainTestID,
                   a.MainTestID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.MainTestID <> b.MainTestID)
                  OR (
                         a.MainTestID IS NOT NULL
                         AND b.MainTestID IS NULL
                     )
                  OR (
                         a.MainTestID IS NULL
                         AND b.MainTestID IS NOT NULL
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
                   @ObjectTableSampleID,
                   79920000000,
                   a.SampleID,
                   NULL,
                   b.FieldCollectionDate,
                   a.FieldCollectionDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.FieldCollectionDate <> b.FieldCollectionDate)
                  OR (
                         a.FieldCollectionDate IS NOT NULL
                         AND b.FieldCollectionDate IS NULL
                     )
                  OR (
                         a.FieldCollectionDate IS NULL
                         AND b.FieldCollectionDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   79930000000,
                   a.SampleID,
                   NULL,
                   b.FieldSentDate,
                   a.FieldSentDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.FieldSentDate <> b.FieldSentDate)
                  OR (
                         a.FieldSentDate IS NOT NULL
                         AND b.FieldSentDate IS NULL
                     )
                  OR (
                         a.FieldSentDate IS NULL
                         AND b.FieldSentDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   80030000000,
                   a.SampleID,
                   NULL,
                   b.FieldBarcodeID,
                   a.FieldBarcodeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.FieldBarcodeID <> b.FieldBarcodeID)
                  OR (
                         a.FieldBarcodeID IS NOT NULL
                         AND b.FieldBarcodeID IS NULL
                     )
                  OR (
                         a.FieldBarcodeID IS NULL
                         AND b.FieldBarcodeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4572480000000,
                   a.SampleID,
                   NULL,
                   b.CalculatedCaseID,
                   a.CalculatedCaseID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.CalculatedCaseID <> b.CalculatedCaseID)
                  OR (
                         a.CalculatedCaseID IS NOT NULL
                         AND b.CalculatedCaseID IS NULL
                     )
                  OR (
                         a.CalculatedCaseID IS NULL
                         AND b.CalculatedCaseID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4572490000000,
                   a.SampleID,
                   NULL,
                   b.CalculatedHumanName,
                   a.CalculatedHumanName,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.CalculatedHumanName <> b.CalculatedHumanName)
                  OR (
                         a.CalculatedHumanName IS NOT NULL
                         AND b.CalculatedHumanName IS NULL
                     )
                  OR (
                         a.CalculatedHumanName IS NULL
                         AND b.CalculatedHumanName IS NOT NULL
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
                   @ObjectTableSampleID,
                   4575190000000,
                   a.SampleID,
                   NULL,
                   b.VectorSurveillanceSessionID,
                   a.VectorSurveillanceSessionID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.VectorSurveillanceSessionID <> b.VectorSurveillanceSessionID)
                  OR (
                         a.VectorSurveillanceSessionID IS NOT NULL
                         AND b.VectorSurveillanceSessionID IS NULL
                     )
                  OR (
                         a.VectorSurveillanceSessionID IS NULL
                         AND b.VectorSurveillanceSessionID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4575200000000,
                   a.SampleID,
                   NULL,
                   b.VectorID,
                   a.VectorID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.VectorID <> b.VectorID)
                  OR (
                         a.VectorID IS NOT NULL
                         AND b.VectorID IS NULL
                     )
                  OR (
                         a.VectorID IS NULL
                         AND b.VectorID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576340000000,
                   a.SampleID,
                   NULL,
                   b.SubdivisionID,
                   a.SubdivisionID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SubdivisionID <> b.SubdivisionID)
                  OR (
                         a.SubdivisionID IS NOT NULL
                         AND b.SubdivisionID IS NULL
                     )
                  OR (
                         a.SubdivisionID IS NULL
                         AND b.SubdivisionID IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545420000000,
                   a.SampleID,
                   NULL,
                   b.SampleStatusTypeID,
                   a.SampleStatusTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SampleStatusTypeID <> b.SampleStatusTypeID)
                  OR (
                         a.SampleStatusTypeID IS NOT NULL
                         AND b.SampleStatusTypeID IS NULL
                     )
                  OR (
                         a.SampleStatusTypeID IS NULL
                         AND b.SampleStatusTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576360000000,
                   a.SampleID,
                   NULL,
                   b.DepartmentID,
                   a.DepartmentID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.DepartmentID <> b.DepartmentID)
                  OR (
                         a.DepartmentID IS NOT NULL
                         AND b.DepartmentID IS NULL
                     )
                  OR (
                         a.DepartmentID IS NULL
                         AND b.DepartmentID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576370000000,
                   a.SampleID,
                   NULL,
                   b.DestroyedByPersonID,
                   a.DestroyedByPersonID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.DestroyedByPersonID <> b.DestroyedByPersonID)
                  OR (
                         a.DestroyedByPersonID IS NOT NULL
                         AND b.DestroyedByPersonID IS NULL
                     )
                  OR (
                         a.DestroyedByPersonID IS NULL
                         AND b.DestroyedByPersonID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576390000000,
                   a.SampleID,
                   NULL,
                   b.EnteringDate,
                   a.EnteringDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.EnteringDate <> b.EnteringDate)
                  OR (
                         a.EnteringDate IS NOT NULL
                         AND b.EnteringDate IS NULL
                     )
                  OR (
                         a.EnteringDate IS NULL
                         AND b.EnteringDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576400000000,
                   a.SampleID,
                   NULL,
                   b.DestructionDate,
                   a.DestructionDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.DestructionDate <> b.DestructionDate)
                  OR (
                         a.DestructionDate IS NOT NULL
                         AND b.DestructionDate IS NULL
                     )
                  OR (
                         a.DestructionDate IS NULL
                         AND b.DestructionDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576410000000,
                   a.SampleID,
                   NULL,
                   b.BarcodeID,
                   a.BarcodeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.BarcodeID <> b.BarcodeID)
                  OR (
                         a.BarcodeID IS NOT NULL
                         AND b.BarcodeID IS NULL
                     )
                  OR (
                         a.BarcodeID IS NULL
                         AND b.BarcodeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4576420000000,
                   a.SampleID,
                   NULL,
                   b.Note,
                   a.Note,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
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
            SELECT @DataAuditEventID,
                   @ObjectTableSampleID,
                   4578720000000,
                   a.SampleID,
                   NULL,
                   b.SendToOfficeID,
                   a.SendToOfficeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SendToOfficeID <> b.SendToOfficeID)
                  OR (
                         a.SendToOfficeID IS NOT NULL
                         AND b.SendToOfficeID IS NULL
                     )
                  OR (
                         a.SendToOfficeID IS NULL
                         AND b.SendToOfficeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   4578730000000,
                   a.SampleID,
                   NULL,
                   b.ReadOnlyIndicator,
                   a.ReadOnlyIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.ReadOnlyIndicator <> b.ReadOnlyIndicator)
                  OR (
                         a.ReadOnlyIndicator IS NOT NULL
                         AND b.ReadOnlyIndicator IS NULL
                     )
                  OR (
                         a.ReadOnlyIndicator IS NULL
                         AND b.ReadOnlyIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   12014480000000,
                   a.SampleID,
                   NULL,
                   b.BirdStatusTypeID,
                   a.BirdStatusTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.BirdStatusTypeID <> b.BirdStatusTypeID)
                  OR (
                         a.BirdStatusTypeID IS NOT NULL
                         AND b.BirdStatusTypeID IS NULL
                     )
                  OR (
                         a.BirdStatusTypeID IS NULL
                         AND b.BirdStatusTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   12665570000000,
                   a.SampleID,
                   NULL,
                   b.HumanDiseaseReportID,
                   a.HumanDiseaseReportID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.HumanDiseaseReportID <> b.HumanDiseaseReportID)
                  OR (
                         a.HumanDiseaseReportID IS NOT NULL
                         AND b.HumanDiseaseReportID IS NULL
                     )
                  OR (
                         a.HumanDiseaseReportID IS NULL
                         AND b.HumanDiseaseReportID IS NOT NULL
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
                   @ObjectTableSampleID,
                   12665580000000,
                   a.SampleID,
                   NULL,
                   b.VeterinaryDiseaseReportID,
                   a.VeterinaryDiseaseReportID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.VeterinaryDiseaseReportID <> b.VeterinaryDiseaseReportID)
                  OR (
                         a.VeterinaryDiseaseReportID IS NOT NULL
                         AND b.VeterinaryDiseaseReportID IS NULL
                     )
                  OR (
                         a.VeterinaryDiseaseReportID IS NULL
                         AND b.VeterinaryDiseaseReportID IS NOT NULL
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
                   @ObjectTableSampleID,
                   12666880000000,
                   a.SampleID,
                   NULL,
                   b.AccessionDate,
                   a.AccessionDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.AccessionDate <> b.AccessionDate)
                  OR (
                         a.AccessionDate IS NOT NULL
                         AND b.AccessionDate IS NULL
                     )
                  OR (
                         a.AccessionDate IS NULL
                         AND b.AccessionDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   12666890000000,
                   a.SampleID,
                   NULL,
                   b.AccessionConditionTypeID,
                   a.AccessionConditionTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.AccessionConditionTypeID <> b.AccessionConditionTypeID)
                  OR (
                         a.AccessionConditionTypeID IS NOT NULL
                         AND b.AccessionConditionTypeID IS NULL
                     )
                  OR (
                         a.AccessionConditionTypeID IS NULL
                         AND b.AccessionConditionTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   12666900000000,
                   a.SampleID,
                   NULL,
                   b.Condition,
                   a.Condition,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.Condition <> b.Condition)
                  OR (
                         a.Condition IS NOT NULL
                         AND b.Condition IS NULL
                     )
                  OR (
                         a.Condition IS NULL
                         AND b.Condition IS NOT NULL
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
                   @ObjectTableSampleID,
                   12666910000000,
                   a.SampleID,
                   NULL,
                   b.AccessionByPersonID,
                   a.AccessionByPersonID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.AccessionByPersonID <> b.AccessionByPersonID)
                  OR (
                         a.AccessionByPersonID IS NOT NULL
                         AND b.AccessionByPersonID IS NULL
                     )
                  OR (
                         a.AccessionByPersonID IS NULL
                         AND b.AccessionByPersonID IS NOT NULL
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
                   @ObjectTableSampleID,
                   12675260000000,
                   a.SampleID,
                   NULL,
                   b.DestructionMethodTypeID,
                   a.DestructionMethodTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.DestructionMethodTypeID <> b.DestructionMethodTypeID)
                  OR (
                         a.DestructionMethodTypeID IS NOT NULL
                         AND b.DestructionMethodTypeID IS NULL
                     )
                  OR (
                         a.DestructionMethodTypeID IS NULL
                         AND b.DestructionMethodTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545560000000,
                   a.SampleID,
                   NULL,
                   b.CurrentSiteID,
                   a.CurrentSiteID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.CurrentSiteID <> b.CurrentSiteID)
                  OR (
                         a.CurrentSiteID IS NOT NULL
                         AND b.CurrentSiteID IS NULL
                     )
                  OR (
                         a.CurrentSiteID IS NULL
                         AND b.CurrentSiteID IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545570000000,
                   a.SampleID,
                   NULL,
                   b.SampleKindTypeID,
                   a.SampleKindTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SampleKindTypeID <> b.SampleKindTypeID)
                  OR (
                         a.SampleKindTypeID IS NOT NULL
                         AND b.SampleKindTypeID IS NULL
                     )
                  OR (
                         a.SampleKindTypeID IS NULL
                         AND b.SampleKindTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545580000000,
                   a.SampleID,
                   NULL,
                   b.AccessionIndicator,
                   a.AccessionIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.AccessionIndicator <> b.AccessionIndicator)
                  OR (
                         a.AccessionIndicator IS NOT NULL
                         AND b.AccessionIndicator IS NULL
                     )
                  OR (
                         a.AccessionIndicator IS NULL
                         AND b.AccessionIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545590000000,
                   a.SampleID,
                   NULL,
                   b.ShowInCaseOrSessionIndicator,
                   a.ShowInCaseOrSessionIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.ShowInCaseOrSessionIndicator <> b.ShowInCaseOrSessionIndicator)
                  OR (
                         a.ShowInCaseOrSessionIndicator IS NOT NULL
                         AND b.ShowInCaseOrSessionIndicator IS NULL
                     )
                  OR (
                         a.ShowInCaseOrSessionIndicator IS NULL
                         AND b.ShowInCaseOrSessionIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545600000000,
                   a.SampleID,
                   NULL,
                   b.ShowInLabListIndicator,
                   a.ShowInLabListIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.ShowInLabListIndicator <> b.ShowInLabListIndicator)
                  OR (
                         a.ShowInLabListIndicator IS NOT NULL
                         AND b.ShowInLabListIndicator IS NULL
                     )
                  OR (
                         a.ShowInLabListIndicator IS NULL
                         AND b.ShowInLabListIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545620000000,
                   a.SampleID,
                   NULL,
                   b.ShowInDispositionListIndicator,
                   a.ShowInDispositionListIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.ShowInDispositionListIndicator <> b.ShowInDispositionListIndicator)
                  OR (
                         a.ShowInDispositionListIndicator IS NOT NULL
                         AND b.ShowInDispositionListIndicator IS NULL
                     )
                  OR (
                         a.ShowInDispositionListIndicator IS NULL
                         AND b.ShowInDispositionListIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   49545610000000,
                   a.SampleID,
                   NULL,
                   b.ShowInAccessionInFormIndicator,
                   a.ShowInAccessionInFormIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.ShowInAccessionInFormIndicator <> b.ShowInAccessionInFormIndicator)
                  OR (
                         a.ShowInAccessionInFormIndicator IS NOT NULL
                         AND b.ShowInAccessionInFormIndicator IS NULL
                     )
                  OR (
                         a.ShowInAccessionInFormIndicator IS NULL
                         AND b.ShowInAccessionInFormIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   51523600000000,
                   a.SampleID,
                   NULL,
                   b.MarkedForDispositionByPersonID,
                   a.MarkedForDispositionByPersonID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.MarkedForDispositionByPersonID <> b.MarkedForDispositionByPersonID)
                  OR (
                         a.MarkedForDispositionByPersonID IS NOT NULL
                         AND b.MarkedForDispositionByPersonID IS NULL
                     )
                  OR (
                         a.MarkedForDispositionByPersonID IS NULL
                         AND b.MarkedForDispositionByPersonID IS NOT NULL
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
                   @ObjectTableSampleID,
                   51528570000000,
                   a.SampleID,
                   NULL,
                   b.OutOfRepositoryDate,
                   a.OutOfRepositoryDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.OutOfRepositoryDate <> b.OutOfRepositoryDate)
                  OR (
                         a.OutOfRepositoryDate IS NOT NULL
                         AND b.OutOfRepositoryDate IS NULL
                     )
                  OR (
                         a.OutOfRepositoryDate IS NULL
                         AND b.OutOfRepositoryDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   51528580000000,
                   a.SampleID,
                   NULL,
                   b.SampleStatusDate,
                   a.SampleStatusDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.SampleStatusDate <> b.SampleStatusDate)
                  OR (
                         a.SampleStatusDate IS NOT NULL
                         AND b.SampleStatusDate IS NULL
                     )
                  OR (
                         a.SampleStatusDate IS NULL
                         AND b.SampleStatusDate IS NOT NULL
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
                   @ObjectTableSampleID,
                   51586990000034,
                   a.SampleID,
                   NULL,
                   b.StorageBoxPlace,
                   a.StorageBoxPlace,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.StorageBoxPlace <> b.StorageBoxPlace)
                  OR (
                         a.StorageBoxPlace IS NOT NULL
                         AND b.StorageBoxPlace IS NULL
                     )
                  OR (
                         a.StorageBoxPlace IS NULL
                         AND b.StorageBoxPlace IS NOT NULL
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
                   @ObjectTableSampleID,
                   51586990000033,
                   a.SampleID,
                   NULL,
                   b.PreviousSampleStatusTypeID,
                   a.PreviousSampleStatusTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.PreviousSampleStatusTypeID <> b.PreviousSampleStatusTypeID)
                  OR (
                         a.PreviousSampleStatusTypeID IS NOT NULL
                         AND b.PreviousSampleStatusTypeID IS NULL
                     )
                  OR (
                         a.PreviousSampleStatusTypeID IS NULL
                         AND b.PreviousSampleStatusTypeID IS NOT NULL
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
                   @ObjectTableSampleID,
                   51586990000035,
                   a.SampleID,
                   NULL,
                   b.DiseaseID,
                   a.DiseaseID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
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
                   @ObjectTableSampleID,
                   51586990000036,
                   a.SampleID,
                   NULL,
                   b.LabModuleSourceIndicator,
                   a.LabModuleSourceIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.LabModuleSourceIndicator <> b.LabModuleSourceIndicator)
                  OR (
                         a.LabModuleSourceIndicator IS NOT NULL
                         AND b.LabModuleSourceIndicator IS NULL
                     )
                  OR (
                         a.LabModuleSourceIndicator IS NULL
                         AND b.LabModuleSourceIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   51586990000037,
                   a.SampleID,
                   NULL,
                   b.TestUnassignedIndicator,
                   a.TestUnassignedIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.TestUnassignedIndicator <> b.TestUnassignedIndicator)
                  OR (
                         a.TestUnassignedIndicator IS NOT NULL
                         AND b.TestUnassignedIndicator IS NULL
                     )
                  OR (
                         a.TestUnassignedIndicator IS NULL
                         AND b.TestUnassignedIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   51586990000038,
                   a.SampleID,
                   NULL,
                   b.TestCompletedIndicator,
                   a.TestCompletedIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.TestCompletedIndicator <> b.TestCompletedIndicator)
                  OR (
                         a.TestCompletedIndicator IS NOT NULL
                         AND b.TestCompletedIndicator IS NULL
                     )
                  OR (
                         a.TestCompletedIndicator IS NULL
                         AND b.TestCompletedIndicator IS NOT NULL
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
                   @ObjectTableSampleID,
                   51586990000039,
                   a.SampleID,
                   NULL,
                   b.TransferIndicator,
                   a.TransferIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE (a.TransferIndicator <> b.TransferIndicator)
                  OR (
                         a.TransferIndicator IS NOT NULL
                         AND b.TransferIndicator IS NULL
                     )
                  OR (
                         a.TransferIndicator IS NULL
                         AND b.TransferIndicator IS NOT NULL
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
            SELECT @DataAuditEventID,
                   @ObjectTableSampleID,
                   a.SampleID,
                   NULL,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit AS a
                FULL JOIN @SampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
