-- ================================================================================================
-- Name: USSP_GBL_TESTS_SET
--
-- Description:	Inserts or updates laboratory and field test records for various use cases.
--
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Stephen Long        11/21/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long        11/29/2022 Added delete data audit logic.
-- Stephen Long        12/09/2022 Added EIDSSObjectID parameter to insert for strObject.
-- Stephen Long        01/09/2023 Added check to not update test fields when non-laboratory test is 
--                                false; only done from the laboratory module.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_TESTS_SET]
(
    @TestID BIGINT OUTPUT,
    @TestNameTypeID BIGINT = NULL,
    @TestCategoryTypeID BIGINT = NULL,
    @TestResultTypeID BIGINT = NULL,
    @TestStatusTypeID BIGINT,
    @DiseaseID BIGINT,
    @SampleID BIGINT = NULL,
    @BatchTestID BIGINT = NULL,
    @ObservationID BIGINT,
    @TestNumber INT = NULL,
    @Comments NVARCHAR(500) = NULL,
    @RowStatus INT = NULL,
    @StartedDate DATETIME = NULL,
    @ResultDate DATETIME = NULL,
    @TestedByOrganizationID BIGINT = NULL,
    @TestedByPersonID BIGINT = NULL,
    @ResultEnteredByOrganizationID BIGINT = NULL,
    @ResultEnteredByPersonID BIGINT = NULL,
    @ValidatedByOrganizationID BIGINT = NULL,
    @ValidatedByPersonID BIGINT = NULL,
    @ReadOnlyIndicator BIT,
    @NonLaboratoryTestIndicator BIT,
    @ExternalTestIndicator BIT = NULL,
    @PerformedByOrganizationID BIGINT = NULL,
    @ReceivedDate DATETIME = NULL,
    @ContactPerson NVARCHAR(200) = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @VectorSessionID BIGINT = NULL,
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @RowAction CHAR
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = @TestID,
        @ObjectTableID BIGINT = 75740000000; -- tlbTesting
DECLARE @TestBeforeEdit TABLE
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
    Note NVARCHAR(500),
    StartedDate DATETIME,
    ConcludedDate DATETIME,
    TestedByOfficeID BIGINT,
    TestedByPersonID BIGINT,
    ResultEnteredByOfficeID BIGINT,
    ResultEnteredByPersonID BIGINT,
    ValidatedByOfficeID BIGINT,
    ValidatedByPersonID BIGINT,
    ReadOnlyIndicator BIT,
    NonLaboratoryTestIndicator BIT,
    ExternalTestIndicator BIT,
    PerformedByOfficeID BIGINT,
    ReceivedDate DATETIME,
    ContactPerson NVARCHAR(200),
    RowStatus INT
);
DECLARE @TestAfterEdit TABLE
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
    Note NVARCHAR(500),
    StartedDate DATETIME,
    ConcludedDate DATETIME,
    TestedByOfficeID BIGINT,
    TestedByPersonID BIGINT,
    ResultEnteredByOfficeID BIGINT,
    ResultEnteredByPersonID BIGINT,
    ValidatedByOfficeID BIGINT,
    ValidatedByPersonID BIGINT,
    ReadOnlyIndicator BIT,
    NonLaboratoryTestIndicator BIT,
    ExternalTestIndicator BIT,
    PerformedByOfficeID BIGINT,
    ReceivedDate DATETIME,
    ContactPerson NVARCHAR(200),
    RowStatus INT
);
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        IF @RowAction = 'I'
           OR @RowAction = '1' -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTesting', @TestID OUTPUT;

            INSERT INTO dbo.tlbTesting
            (
                idfTesting,
                idfsTestName,
                idfsTestCategory,
                idfsTestResult,
                idfsTestStatus,
                idfsDiagnosis,
                idfMaterial,
                idfBatchTest,
                idfObservation,
                intTestNumber,
                strNote,
                intRowStatus,
                datStartedDate,
                datConcludedDate,
                idfTestedByOffice,
                idfTestedByPerson,
                idfResultEnteredByOffice,
                idfResultEnteredByPerson,
                idfValidatedByOffice,
                idfValidatedByPerson,
                blnReadOnly,
                blnNonLaboratoryTest,
                blnExternalTest,
                idfPerformedByOffice,
                datReceivedDate,
                strContactPerson,
                idfMonitoringSession,
                idfVector,
                idfHumanCase,
                idfVetCase,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@TestID,
             @TestNameTypeID,
             @TestCategoryTypeID,
             @TestResultTypeID,
             @TestStatusTypeID,
             @DiseaseID,
             @SampleID,
             @BatchTestID,
             @ObservationID,
             @TestNumber,
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
             @ContactPerson,
             @MonitoringSessionID,
             @VectorSessionID,
             @HumanDiseaseReportID,
             @VeterinaryDiseaseReportID,
             @AuditUserName,
             10519001,
             '[{"idfTesting":' + CAST(@TestID AS NVARCHAR(300)) + '}]'
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
             @TestID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
        -- End data audit
        END
        ELSE
        BEGIN
            INSERT INTO @TestBeforeEdit
            (
                TestID,
                TestNameTypeID,
                TestCategoryTypeID,
                TestResultTypeID,
                TestStatusTypeID,
                DiseaseID,
                SampleID,
                BatchTestID,
                ObservationID,
                TestNumber,
                Note,
                StartedDate,
                ConcludedDate,
                TestedByOfficeID,
                TestedByPersonID,
                ResultEnteredByOfficeID,
                ResultEnteredByPersonID,
                ValidatedByOfficeID,
                ValidatedByPersonID,
                ReadOnlyIndicator,
                NonLaboratoryTestIndicator,
                ExternalTestIndicator,
                PerformedByOfficeID,
                ReceivedDate,
                ContactPerson,
                RowStatus
            )
            SELECT idfTesting,
                   idfsTestName,
                   idfsTestCategory,
                   idfsTestResult,
                   idfsTestStatus,
                   idfsDiagnosis,
                   idfMaterial,
                   idfBatchTest,
                   idfObservation,
                   intTestNumber,
                   strNote,
                   datStartedDate,
                   datConcludedDate,
                   idfTestedByOffice,
                   idfTestedByPerson,
                   idfResultEnteredByOffice,
                   idfResultEnteredByPerson,
                   idfValidatedByOffice,
                   idfValidatedByPerson,
                   blnReadOnly,
                   blnNonLaboratoryTest,
                   blnExternalTest,
                   idfPerformedByOffice,
                   datReceivedDate,
                   strContactPerson,
                   intRowStatus
            FROM dbo.tlbTesting
            WHERE idfTesting = @TestID;

            IF @NonLaboratoryTestIndicator = 1
            BEGIN
                UPDATE dbo.tlbTesting
                SET idfsTestName = @TestNameTypeID,
                    idfsTestCategory = @TestCategoryTypeID,
                    idfsTestResult = @TestResultTypeID,
                    idfsTestStatus = @TestStatusTypeID,
                    idfsDiagnosis = @DiseaseID,
                    idfMaterial = @SampleID,
                    idfBatchTest = @BatchTestID,
                    idfObservation = @ObservationID,
                    intTestNumber = @TestNumber,
                    strNote = @Comments,
                    intRowStatus = @RowStatus,
                    datStartedDate = @StartedDate,
                    datConcludedDate = @ResultDate,
                    idfTestedByOffice = @TestedByOrganizationID,
                    idfTestedByPerson = @TestedByPersonID,
                    idfResultEnteredByOffice = @ResultEnteredByOrganizationID,
                    idfResultEnteredByPerson = @ResultEnteredByPersonID,
                    idfValidatedByOffice = @ValidatedByOrganizationID,
                    idfValidatedByPerson = @ValidatedByPersonID,
                    blnReadOnly = @ReadOnlyIndicator,
                    blnNonLaboratoryTest = @NonLaboratoryTestIndicator,
                    blnExternalTest = @ExternalTestIndicator,
                    idfPerformedByOffice = @PerformedByOrganizationID,
                    datReceivedDate = @ReceivedDate,
                    strContactPerson = @ContactPerson,
                    idfMonitoringSession = @MonitoringSessionID,
                    idfVector = @VectorSessionID,
                    idfHumanCase = @HumanDiseaseReportID,
                    idfVetCase = @VeterinaryDiseaseReportID,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfTesting = @TestID;
            END
            ELSE
            BEGIN
                UPDATE dbo.tlbTesting
                SET idfsTestName = @TestNameTypeID,
                    idfsTestCategory = @TestCategoryTypeID,
                    idfsTestResult = @TestResultTypeID,
                    idfsTestStatus = @TestStatusTypeID,
                    idfsDiagnosis = @DiseaseID,
                    idfMaterial = @SampleID,
                    idfBatchTest = @BatchTestID,
                    idfObservation = @ObservationID,
                    intTestNumber = @TestNumber,
                    strNote = @Comments,
                    intRowStatus = @RowStatus,
                    datStartedDate = @StartedDate,
                    datConcludedDate = @ResultDate,
                    idfTestedByOffice = @TestedByOrganizationID,
                    idfTestedByPerson = @TestedByPersonID,
                    idfResultEnteredByOffice = @ResultEnteredByOrganizationID,
                    idfResultEnteredByPerson = @ResultEnteredByPersonID,
                    blnReadOnly = @ReadOnlyIndicator,
                    blnExternalTest = @ExternalTestIndicator,
                    idfPerformedByOffice = @PerformedByOrganizationID,
                    datReceivedDate = @ReceivedDate,
                    strContactPerson = @ContactPerson,
                    idfMonitoringSession = @MonitoringSessionID,
                    idfVector = @VectorSessionID,
                    idfHumanCase = @HumanDiseaseReportID,
                    idfVetCase = @VeterinaryDiseaseReportID,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE()
                WHERE idfTesting = @TestID;
            END

            INSERT INTO @TestAfterEdit
            (
                TestID,
                TestNameTypeID,
                TestCategoryTypeID,
                TestResultTypeID,
                TestStatusTypeID,
                DiseaseID,
                SampleID,
                BatchTestID,
                ObservationID,
                TestNumber,
                Note,
                StartedDate,
                ConcludedDate,
                TestedByOfficeID,
                TestedByPersonID,
                ResultEnteredByOfficeID,
                ResultEnteredByPersonID,
                ValidatedByOfficeID,
                ValidatedByPersonID,
                ReadOnlyIndicator,
                NonLaboratoryTestIndicator,
                ExternalTestIndicator,
                PerformedByOfficeID,
                ReceivedDate,
                ContactPerson,
                RowStatus
            )
            SELECT idfTesting,
                   idfsTestName,
                   idfsTestCategory,
                   idfsTestResult,
                   idfsTestStatus,
                   idfsDiagnosis,
                   idfMaterial,
                   idfBatchTest,
                   idfObservation,
                   intTestNumber,
                   strNote,
                   datStartedDate,
                   datConcludedDate,
                   idfTestedByOffice,
                   idfTestedByPerson,
                   idfResultEnteredByOffice,
                   idfResultEnteredByPerson,
                   idfValidatedByOffice,
                   idfValidatedByPerson,
                   blnReadOnly,
                   blnNonLaboratoryTest,
                   blnExternalTest,
                   idfPerformedByOffice,
                   datReceivedDate,
                   strContactPerson,
                   intRowStatus
            FROM dbo.tlbTesting
            WHERE idfTesting = @TestID;

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
                       49545430000000,
                       a.TestID,
                       NULL,
                       b.TestNameTypeID,
                       a.TestNameTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestNameTypeID <> b.TestNameTypeID)
                      OR (
                             a.TestNameTypeID IS NOT NULL
                             AND b.TestNameTypeID IS NULL
                         )
                      OR (
                             a.TestNameTypeID IS NULL
                             AND b.TestNameTypeID IS NOT NULL
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
                       49545440000000,
                       a.TestID,
                       NULL,
                       b.TestCategoryTypeID,
                       a.TestCategoryTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestCategoryTypeID <> b.TestCategoryTypeID)
                      OR (
                             a.TestCategoryTypeID IS NOT NULL
                             AND b.TestCategoryTypeID IS NULL
                         )
                      OR (
                             a.TestCategoryTypeID IS NULL
                             AND b.TestCategoryTypeID IS NOT NULL
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
                       80510000000,
                       a.TestID,
                       NULL,
                       b.TestResultTypeID,
                       a.TestResultTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestResultTypeID <> b.TestResultTypeID)
                      OR (
                             a.TestResultTypeID IS NOT NULL
                             AND b.TestResultTypeID IS NULL
                         )
                      OR (
                             a.TestResultTypeID IS NULL
                             AND b.TestResultTypeID IS NOT NULL
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
                       4572510000000,
                       a.TestID,
                       NULL,
                       b.TestStatusTypeID,
                       a.TestStatusTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestStatusTypeID <> b.TestStatusTypeID)
                      OR (
                             a.TestStatusTypeID IS NOT NULL
                             AND b.TestStatusTypeID IS NULL
                         )
                      OR (
                             a.TestStatusTypeID IS NULL
                             AND b.TestStatusTypeID IS NOT NULL
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
                       4572520000000,
                       a.TestID,
                       NULL,
                       b.DiseaseID,
                       a.DiseaseID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
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
                       4576430000000,
                       a.TestID,
                       NULL,
                       b.SampleID,
                       a.SampleID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.SampleID <> b.SampleID)
                      OR (
                             a.SampleID IS NOT NULL
                             AND b.SampleID IS NULL
                         )
                      OR (
                             a.SampleID IS NULL
                             AND b.SampleID IS NOT NULL
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
                       80470000000,
                       a.TestID,
                       NULL,
                       b.BatchTestID,
                       a.BatchTestID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.BatchTestID <> b.BatchTestID)
                      OR (
                             a.BatchTestID IS NOT NULL
                             AND b.BatchTestID IS NULL
                         )
                      OR (
                             a.BatchTestID IS NULL
                             AND b.BatchTestID IS NOT NULL
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
                       80500000000,
                       a.TestID,
                       NULL,
                       b.ObservationID,
                       a.ObservationID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ObservationID <> b.ObservationID)
                      OR (
                             a.ObservationID IS NOT NULL
                             AND b.ObservationID IS NULL
                         )
                      OR (
                             a.ObservationID IS NULL
                             AND b.ObservationID IS NOT NULL
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
                       80540000000,
                       a.TestID,
                       NULL,
                       b.TestNumber,
                       a.TestNumber,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestNumber <> b.TestNumber)
                      OR (
                             a.TestNumber IS NOT NULL
                             AND b.TestNumber IS NULL
                         )
                      OR (
                             a.TestNumber IS NULL
                             AND b.TestNumber IS NOT NULL
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
                       4572540000000,
                       a.TestID,
                       NULL,
                       b.Note,
                       a.Note,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
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
                       4578540000000,
                       a.TestID,
                       NULL,
                       b.StartedDate,
                       a.StartedDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.StartedDate <> b.StartedDate)
                      OR (
                             a.StartedDate IS NOT NULL
                             AND b.StartedDate IS NULL
                         )
                      OR (
                             a.StartedDate IS NULL
                             AND b.StartedDate IS NOT NULL
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
                       4578550000000,
                       a.TestID,
                       NULL,
                       b.ConcludedDate,
                       a.ConcludedDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ConcludedDate <> b.ConcludedDate)
                      OR (
                             a.ConcludedDate IS NOT NULL
                             AND b.ConcludedDate IS NULL
                         )
                      OR (
                             a.ConcludedDate IS NULL
                             AND b.ConcludedDate IS NOT NULL
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
                       4578560000000,
                       a.TestID,
                       NULL,
                       b.TestedByOfficeID,
                       a.TestedByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestedByOfficeID <> b.TestedByOfficeID)
                      OR (
                             a.TestedByOfficeID IS NOT NULL
                             AND b.TestedByOfficeID IS NULL
                         )
                      OR (
                             a.TestedByOfficeID IS NULL
                             AND b.TestedByOfficeID IS NOT NULL
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
                       4578570000000,
                       a.TestID,
                       NULL,
                       b.TestedByPersonID,
                       a.TestedByPersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.TestedByPersonID <> b.TestedByPersonID)
                      OR (
                             a.TestedByPersonID IS NOT NULL
                             AND b.TestedByPersonID IS NULL
                         )
                      OR (
                             a.TestedByPersonID IS NULL
                             AND b.TestedByPersonID IS NOT NULL
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
                       4578580000000,
                       a.TestID,
                       NULL,
                       b.ResultEnteredByOfficeID,
                       a.ResultEnteredByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ResultEnteredByOfficeID <> b.ResultEnteredByOfficeID)
                      OR (
                             a.ResultEnteredByOfficeID IS NOT NULL
                             AND b.ResultEnteredByOfficeID IS NULL
                         )
                      OR (
                             a.ResultEnteredByOfficeID IS NULL
                             AND b.ResultEnteredByOfficeID IS NOT NULL
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
                       4578590000000,
                       a.TestID,
                       NULL,
                       b.ResultEnteredByPersonID,
                       a.ResultEnteredByPersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ResultEnteredByPersonID <> b.ResultEnteredByPersonID)
                      OR (
                             a.ResultEnteredByPersonID IS NOT NULL
                             AND b.ResultEnteredByPersonID IS NULL
                         )
                      OR (
                             a.ResultEnteredByPersonID IS NULL
                             AND b.ResultEnteredByPersonID IS NOT NULL
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
                       4578600000000,
                       a.TestID,
                       NULL,
                       b.ValidatedByOfficeID,
                       a.ValidatedByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ValidatedByOfficeID <> b.ValidatedByOfficeID)
                      OR (
                             a.ValidatedByOfficeID IS NOT NULL
                             AND b.ValidatedByOfficeID IS NULL
                         )
                      OR (
                             a.ValidatedByOfficeID IS NULL
                             AND b.ValidatedByOfficeID IS NOT NULL
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
                       4578610000000,
                       a.TestID,
                       NULL,
                       b.ValidatedByPersonID,
                       a.ValidatedByPersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ValidatedByPersonID <> b.ValidatedByPersonID)
                      OR (
                             a.ValidatedByPersonID IS NOT NULL
                             AND b.ValidatedByPersonID IS NULL
                         )
                      OR (
                             a.ValidatedByPersonID IS NULL
                             AND b.ValidatedByPersonID IS NOT NULL
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
                       4578740000000,
                       a.TestID,
                       NULL,
                       b.ReadOnlyIndicator,
                       a.ReadOnlyIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
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
                       4578760000000,
                       a.TestID,
                       NULL,
                       b.NonLaboratoryTestIndicator,
                       a.NonLaboratoryTestIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.NonLaboratoryTestIndicator <> b.NonLaboratoryTestIndicator)
                      OR (
                             a.NonLaboratoryTestIndicator IS NOT NULL
                             AND b.NonLaboratoryTestIndicator IS NULL
                         )
                      OR (
                             a.NonLaboratoryTestIndicator IS NULL
                             AND b.NonLaboratoryTestIndicator IS NOT NULL
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
                       50815850000000,
                       a.TestID,
                       NULL,
                       b.ExternalTestIndicator,
                       a.ExternalTestIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ExternalTestIndicator <> b.ExternalTestIndicator)
                      OR (
                             a.ExternalTestIndicator IS NOT NULL
                             AND b.ExternalTestIndicator IS NULL
                         )
                      OR (
                             a.ExternalTestIndicator IS NULL
                             AND b.ExternalTestIndicator IS NOT NULL
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
                       50815860000000,
                       a.TestID,
                       NULL,
                       b.PerformedByOfficeID,
                       a.PerformedByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.PerformedByOfficeID <> b.PerformedByOfficeID)
                      OR (
                             a.PerformedByOfficeID IS NOT NULL
                             AND b.PerformedByOfficeID IS NULL
                         )
                      OR (
                             a.PerformedByOfficeID IS NULL
                             AND b.PerformedByOfficeID IS NOT NULL
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
                       50815870000000,
                       a.TestID,
                       NULL,
                       b.ReceivedDate,
                       a.ReceivedDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ReceivedDate <> b.ReceivedDate)
                      OR (
                             a.ReceivedDate IS NOT NULL
                             AND b.ReceivedDate IS NULL
                         )
                      OR (
                             a.ReceivedDate IS NULL
                             AND b.ReceivedDate IS NOT NULL
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
                       50815880000000,
                       a.TestID,
                       NULL,
                       b.ContactPerson,
                       a.ContactPerson,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                WHERE (a.ContactPerson <> b.ContactPerson)
                      OR (
                             a.ContactPerson IS NOT NULL
                             AND b.ContactPerson IS NULL
                         )
                      OR (
                             a.ContactPerson IS NULL
                             AND b.ContactPerson IS NOT NULL
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
                       a.TestID,
                       NULL,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestAfterEdit AS a
                    FULL JOIN @TestBeforeEdit AS b
                        ON a.TestID = b.TestID
                where a.RowStatus = 0
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
                (@DataAuditEventid, @ObjectTableID, @TestID, @AuditUserName, @EIDSSObjectID);
            END
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
