-- ================================================================================================
-- Name: USSP_GBL_SAMPLES_SET
--
-- Description:	Inserts or updates sample records for various non-laboratory module use cases.
--
--	Revision History:
--	Name               Date       Change Detail
--	------------------ ---------- ----------------------------------------------------------------
-- Stephen Long        11/21/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long        11/29/2022 Added delete data audit logic.
-- Stephen Long        11/30/2022 Added check for non-null sample ID when row action set to insert.
-- Stephen Long        12/09/2022 Added EIDSSObjectID parameter to insert for strObject.
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_SAMPLES_SET]
(
    @AuditUserName NVARCHAR(200) = NULL,
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL, 
    @SampleID BIGINT OUTPUT,
    @SampleTypeID BIGINT,
    @RootSampleID BIGINT = NULL,
    @ParentSampleID BIGINT = NULL,
    @HumanID BIGINT = NULL,
    @SpeciesID BIGINT = NULL,
    @AnimalID BIGINT = NULL,
    @VectorID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @VectorSessionID BIGINT = NULL,
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @CollectionDate DATETIME = NULL,
    @CollectedByPersonID BIGINT = NULL,
    @CollectedByOrganizationID BIGINT = NULL,
    @SentDate DATETIME = NULL,
    @SentToOrganizationID BIGINT = NULL,
    @EIDSSLocalFieldSampleID NVARCHAR(200) = NULL,
    @SiteID BIGINT,
    @EnteredDate DATETIME = NULL,
    @ReadOnlyIndicator BIT,
    @SampleStatusTypeID BIGINT = NULL,
    @Comments NVARCHAR(500) = NULL,
    @CurrentSiteID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @BirdStatusTypeID BIGINT = NULL,
    @RowStatus INT,
    @RowAction CHAR
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = @SampleID,
        @ObjectTableID BIGINT = 75620000000; -- tlbMaterial
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
    RowStatus INT
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
    RowStatus INT
);
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data Audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        --Local/field sample EIDSS ID. Only system assign when user leaves blank.
        IF @EIDSSLocalFieldSampleID IS NULL
           OR @EIDSSLocalFieldSampleID = ''
        BEGIN
            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Sample Field Barcode',
                                               @NextNumberValue = @EIDSSLocalFieldSampleID OUTPUT,
                                               @InstallationSite = NULL;
        END;

        IF @RowAction = 'I'
           OR @RowAction = '1' -- Insert
        BEGIN
            IF @SampleID IS NOT NULL
            BEGIN
                SET @SampleID = NULL;
            END
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbMaterial',
                                              @idfsKey = @SampleID OUTPUT;

            INSERT INTO dbo.tlbMaterial
            (
                idfMaterial,
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
                idfVectorSurveillanceSession,
                idfVector,
                idfsSampleStatus,
                datEnteringDate,
                strNote,
                idfsSite,
                intRowStatus,
                rowguid,
                idfSendToOffice,
                blnReadOnly,
                idfsBirdStatus,
                idfHumanCase,
                idfVetCase,
                idfsCurrentSite,
                SourceSystemNameID,
                SourceSystemKeyValue,
                DiseaseID,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM,
                TestUnassignedIndicator,
                TestCompletedIndicator,
                TransferIndicator
            )
            VALUES
            (@SampleID,
             @SampleTypeID,
             @SampleID,
             @ParentSampleID,
             @HumanID,
             @SpeciesID,
             @AnimalID,
             @MonitoringSessionID,
             @CollectedByPersonID,
             @CollectedByOrganizationID,
             NULL,
             @CollectionDate,
             @SentDate,
             @EIDSSLocalFieldSampleID,
             @VectorSessionID,
             @VectorID,
             @SampleStatusTypeID,
             GETDATE(),
             @Comments,
             @SiteID,
             0  ,
             NEWID(),
             @SentToOrganizationID,
             @ReadOnlyIndicator,
             @BirdStatusTypeID,
             @HumanDiseaseReportID,
             @VeterinaryDiseaseReportID,
             @CurrentSiteID,
             10519001,
             '[{"idfMaterial":' + CAST(@SampleID AS NVARCHAR(300)) + '}]',
             @DiseaseID,
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
             GETDATE(),
             1  ,
             0  ,
             0
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
             @SampleID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
        -- End data audit
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
                RowStatus
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
                   intRowStatus
            FROM dbo.tlbMaterial
            WHERE idfMaterial = @SampleID;

            UPDATE dbo.tlbMaterial
            SET idfsSampleType = @SampleTypeID,
                idfHuman = @HumanID,
                idfSpecies = @SpeciesID,
                idfAnimal = @AnimalID,
                idfMonitoringSession = @MonitoringSessionID,
                idfFieldCollectedByPerson = @CollectedByPersonID,
                idfFieldCollectedByOffice = @CollectedByOrganizationID,
                datFieldCollectionDate = @CollectionDate,
                datFieldSentDate = @SentDate,
                strFieldBarcode = @EIDSSLocalFieldSampleID,
                idfVectorSurveillanceSession = @VectorSessionID,
                idfVector = @VectorID,
                strNote = @Comments,
                idfsSite = @SiteID,
                intRowStatus = @RowStatus,
                idfSendToOffice = @SentToOrganizationID,
                blnReadOnly = @ReadOnlyIndicator,
                idfHumanCase = @HumanDiseaseReportID,
                idfVetCase = @VeterinaryDiseaseReportID,
                DiseaseID = @DiseaseID,
                idfsBirdStatus = @BirdStatusTypeID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfMaterial = @SampleID;

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
                RowStatus
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
                   intRowStatus
            FROM dbo.tlbMaterial
            WHERE idfMaterial = @SampleID;

            IF @RowStatus = 0
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
                SELECT @DataAuditEventID,
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
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
                       @ObjectTableID,
                       a.SampleID,
                       NULL,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SampleAfterEdit AS a
                    FULL JOIN @SampleBeforeEdit AS b
                        ON a.SampleID = b.SampleID
                WHERE a.RowStatus = 0
                      AND b.RowStatus = 1;
            END
            ELSE
            BEGIN
                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                VALUES
                (@DataAuditEventID, @ObjectTableID, @SampleID, @AuditUserName, @EIDSSObjectID);
            END
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
