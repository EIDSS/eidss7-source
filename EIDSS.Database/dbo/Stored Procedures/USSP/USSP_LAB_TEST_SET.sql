-- ================================================================================================
-- Name: USSP_LAB_TEST_SET
--
-- Description:	Inserts or updates test records for various laboratory module use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		01/24/2019 Initial release.
-- Stephen Long     02/01/2019 Added null to the observation ID parameter.
-- Stephen Long     03/30/2020 Added set of audit update time and user on record inserts/updates.
-- Stephen Long     10/28/2020 Changed record action from nchar to char.
-- Stephen Long     02/11/2021 Add logic to set test unassigned and test completed indicators.
-- Stephen Long     09/24/2021 Removed language ID parameter as it is not needed.
-- Stephen Long     01/31/2022 Added source system name and key value update on insert.
-- Leo Tracchia		10/21/2022 Fix for properly deleting tests for human disease report DevOps 
--                  defect 5006.
-- Stephen Long     10/21/2022 Added veterinary disease report, monitoring session and vector 
--                             identifiers to the USSP_LAB_TEST_SET call.
-- Stephen Long     01/04/2023 Added update to tests conducted field on human and veterinary 
--                             disease report when a test is added or deleted.
-- Stephen Long     02/21/2023 Added data audit logic for SAUC30 and 31.
-- Stephen Long     03/28/2023 Fix to set sample test unassigned and test completed indicators 
--                             after the test record is saved.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_LAB_TEST_SET]
(
    @TestID BIGINT,
    @TestNameTypeID BIGINT = NULL,
    @TestCategoryTypeID BIGINT = NULL,
    @TestResultTypeID BIGINT = NULL,
    @TestStatusTypeID BIGINT,
    @PreviousTestStatusTypeID BIGINT = NULL,
    @DiseaseID BIGINT,
    @SampleID BIGINT = NULL,
    @EIDSSLaboratorySampleID NVARCHAR(200),
    @BatchTestID BIGINT = NULL,
    @ObservationID BIGINT = NULL,
    @TestNumber INT = NULL,
    @Note NVARCHAR(500) = NULL,
    @RowStatus INT = NULL,
    @StartedDate DATETIME = NULL,
    @ConcludedDate DATETIME = NULL,
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
    @HumanDiseaseReportID BIGINT = NULL,
    @VeterinaryDiseaseReportID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @VectorID BIGINT = NULL,
    @RowAction INT,
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @TestAssignedCount AS INT = 0,
                                                                            -- Data audit
                @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = 10017053,
                @ObjectID BIGINT = NULL,
                @ObjectTableSampleID BIGINT = 75620000000,                  -- tlbMaterial
                @ObjectTableTestID BIGINT = 75740000000,                    -- tlbTesting
                @ObjectTableHumanDiseaseReportID BIGINT = 75610000000,      -- tlbHumanCase,
                @ObjectTableVeterinaryDiseaseReportID BIGINT = 75800000000, -- tlbVetCase
                @EIDSSObjectID NVARCHAR(200);
        -- End data audit

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
            RowStatus INT,
            PreviousTestStatusTypeID BIGINT,
            MonitoringSessionID BIGINT,
            HumanDiseaseReportID BIGINT,
            VeterinaryDiseaseReportID BIGINT,
            VectorID BIGINT
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
            RowStatus INT,
            PreviousTestStatusTypeID BIGINT,
            MonitoringSessionID BIGINT,
            HumanDiseaseReportID BIGINT,
            VeterinaryDiseaseReportID BIGINT,
            VectorID BIGINT
        );
        DECLARE @SampleBeforeEdit TABLE
        (
            SampleID BIGINT,
            TestUnassignedIndicator BIT,
            TestCompletedIndicator BIT
        );
        DECLARE @SampleAfterEdit TABLE
        (
            SampleID BIGINT,
            TestUnassignedIndicator BIT,
            TestCompletedIndicator BIT
        );
        DECLARE @HumanDiseaseReportBeforeEdit TABLE
        (
            HumanDiseaseReportID BIGINT,
            TestsConductedTypeID BIGINT NULL
        );
        DECLARE @HumanDiseaseReportAfterEdit TABLE
        (
            HumanDiseaseReportID BIGINT,
            TestsConductedTypeID BIGINT NULL
        );
        DECLARE @VeterinaryDiseaseReportBeforeEdit TABLE
        (
            VeterinaryDiseaseReportID BIGINT,
            TestsConductedTypeID BIGINT NULL
        );
        DECLARE @VeterinaryDiseaseReportAfterEdit TABLE
        (
            VeterinaryDiseaseReportID BIGINT,
            TestsConductedTypeID BIGINT NULL
        );

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        SET @EIDSSObjectID = @EIDSSLaboratorySampleID;

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbTesting',
                                              @idfsKey = @TestID OUTPUT;

            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @TestID,
                                                      @ObjectTableTestID,
                                                      @EIDSSObjectID,
                                                      @DataAuditEventID OUTPUT;
        END
        ELSE
        BEGIN
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @TestID,
                                                      @ObjectTableTestID,
                                                      @EIDSSObjectID,
                                                      @DataAuditEventID OUTPUT;
        END
        -- End data audit

        IF @RowAction = 1 -- Insert
        BEGIN
            INSERT INTO dbo.tlbTesting
            (
                idfTesting,
                idfsTestName,
                idfsTestCategory,
                idfsTestResult,
                idfsTestStatus,
                PreviousTestStatusID,
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
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                idfHumanCase,
                idfVetCase,
                idfMonitoringSession,
                idfVector
            )
            VALUES
            (@TestID,
             @TestNameTypeID,
             @TestCategoryTypeID,
             @TestResultTypeID,
             @TestStatusTypeID,
             @PreviousTestStatusTypeID,
             @DiseaseID,
             @SampleID,
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
             @ContactPerson,
             10519001,
             '[{"idfTesting":' + CAST(@TestID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @HumanDiseaseReportID,
             @VeterinaryDiseaseReportID,
             @MonitoringSessionID,
             @VectorID
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
             @ObjectTableTestID,
             @TestID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableTestID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
            -- End data audit

            IF @HumanDiseaseReportID IS NOT NULL
            BEGIN
                INSERT INTO @HumanDiseaseReportBeforeEdit
                SELECT idfHumanCase,
                       idfsYNTestsConducted
                FROM dbo.tlbHumanCase
                WHERE idfHumanCase = @HumanDiseaseReportID;

                UPDATE dbo.tlbHumanCase
                SET idfsYNTestsConducted = 10100001, -- Yes
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfHumanCase = @HumanDiseaseReportID;

                INSERT INTO @HumanDiseaseReportAfterEdit
                SELECT idfHumanCase,
                       idfsYNTestsConducted
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
                       4578420000000,
                       a.HumanDiseaseReportID,
                       NULL,
                       b.TestsConductedTypeID,
                       a.TestsConductedTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @HumanDiseaseReportAfterEdit a
                    FULL JOIN @HumanDiseaseReportBeforeEdit b
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
            END
            ELSE IF @VeterinaryDiseaseReportID IS NOT NULL
            BEGIN
                INSERT INTO @VeterinaryDiseaseReportBeforeEdit
                SELECT idfVetCase,
                       idfsYNTestsConducted
                FROM dbo.tlbVetCase
                WHERE idfVetCase = @VeterinaryDiseaseReportID;

                UPDATE dbo.tlbVetCase
                SET idfsYNTestsConducted = 10100001, -- Yes
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfVetCase = @VeterinaryDiseaseReportID;

                INSERT INTO @VeterinaryDiseaseReportAfterEdit
                SELECT idfVetCase,
                       idfsYNTestsConducted
                FROM dbo.tlbVetCase
                WHERE idfVetCase = @VeterinaryDiseaseReportID;

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
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
                       @ObjectTableVeterinaryDiseaseReportID,
                       4578870000000,
                       a.VeterinaryDiseaseReportID,
                       NULL,
                       b.TestsConductedTypeID,
                       a.TestsConductedTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @VeterinaryDiseaseReportAfterEdit a
                    FULL JOIN @VeterinaryDiseaseReportBeforeEdit b
                        ON a.VeterinaryDiseaseReportID = b.VeterinaryDiseaseReportID
                WHERE (a.TestsConductedTypeID <> b.TestsConductedTypeID)
                      OR (
                             a.TestsConductedTypeID IS NOT NULL
                             AND b.TestsConductedTypeID IS NULL
                         )
                      OR (
                             a.TestsConductedTypeID IS NULL
                             AND b.TestsConductedTypeID IS NOT NULL
                         );
            END
        END;
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
                RowStatus,
                PreviousTestStatusTypeID,
                MonitoringSessionID,
                HumanDiseaseReportID,
                VeterinaryDiseaseReportID,
                VectorID
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
                   intRowStatus,
                   PreviousTestStatusID,
                   idfMonitoringSession,
                   idfHumanCase,
                   idfVetCase,
                   idfVector
            FROM dbo.tlbTesting
            WHERE idfTesting = @TestID;

            UPDATE dbo.tlbTesting
            SET idfsTestName = @TestNameTypeID,
                idfsTestCategory = @TestCategoryTypeID,
                idfsTestResult = @TestResultTypeID,
                idfsTestStatus = @TestStatusTypeID,
                PreviousTestStatusID = @PreviousTestStatusTypeID,
                idfsDiagnosis = @DiseaseID,
                idfMaterial = @SampleID,
                idfBatchTest = @BatchTestID,
                idfObservation = @ObservationID,
                intTestNumber = @TestNumber,
                strNote = @Note,
                intRowStatus = @RowStatus,
                datStartedDate = @StartedDate,
                datConcludedDate = @ConcludedDate,
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
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE(),
                idfHumanCase = @HumanDiseaseReportID,
                idfVetCase = @VeterinaryDiseaseReportID,
                idfMonitoringSession = @MonitoringSessionID,
                idfVector = @VectorID
            WHERE idfTesting = @TestID;

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
                RowStatus,
                PreviousTestStatusTypeID,
                MonitoringSessionID,
                HumanDiseaseReportID,
                VeterinaryDiseaseReportID,
                VectorID
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
                   intRowStatus,
                   PreviousTestStatusID,
                   idfMonitoringSession,
                   idfHumanCase,
                   idfVetCase,
                   idfVector
            FROM dbo.tlbTesting
            WHERE idfTesting = @TestID;

            IF @HumanDiseaseReportID IS NOT NULL
               AND @TestStatusTypeID = 10001007 -- Deleted
            BEGIN
                IF
                (
                    SELECT COUNT(*)
                    FROM dbo.tlbTesting
                    WHERE idfHumanCase = @HumanDiseaseReportID
                          AND (
                                  intRowStatus = 0
                                  AND idfsTestStatus <> 10001007
                              )
                ) = 0
                BEGIN
                    INSERT INTO @HumanDiseaseReportBeforeEdit
                    SELECT idfHumanCase,
                           idfsYNTestsConducted
                    FROM dbo.tlbHumanCase
                    WHERE idfHumanCase = @HumanDiseaseReportID;

                    UPDATE dbo.tlbHumanCase
                    SET idfsYNTestsConducted = 10100002, -- No
                        AuditUpdateDTM = GETDATE(),
                        AuditUpdateUser = @AuditUserName
                    WHERE idfHumanCase = @HumanDiseaseReportID;

                    INSERT INTO @HumanDiseaseReportAfterEdit
                    SELECT idfHumanCase,
                           idfsYNTestsConducted
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
                           4578420000000,
                           a.HumanDiseaseReportID,
                           NULL,
                           b.TestsConductedTypeID,
                           a.TestsConductedTypeID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @HumanDiseaseReportAfterEdit a
                        FULL JOIN @HumanDiseaseReportBeforeEdit b
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
                END
            END
            ELSE IF @VeterinaryDiseaseReportID IS NOT NULL
                    AND @TestStatusTypeID = 10001007 -- Deleted
            BEGIN
                IF
                (
                    SELECT COUNT(*)
                    FROM dbo.tlbTesting
                    WHERE idfVetCase = @VeterinaryDiseaseReportID
                          AND (
                                  intRowStatus = 0
                                  AND idfsTestStatus <> 10001007
                              )
                ) = 0
                BEGIN
                    INSERT INTO @VeterinaryDiseaseReportBeforeEdit
                    SELECT idfVetCase,
                           idfsYNTestsConducted
                    FROM dbo.tlbVetCase
                    WHERE idfVetCase = @VeterinaryDiseaseReportID;

                    UPDATE dbo.tlbVetCase
                    SET idfsYNTestsConducted = 10100002, -- No
                        AuditUpdateDTM = GETDATE(),
                        AuditUpdateUser = @AuditUserName
                    WHERE idfVetCase = @VeterinaryDiseaseReportID;

                    INSERT INTO @VeterinaryDiseaseReportAfterEdit
                    SELECT idfVetCase,
                           idfsYNTestsConducted
                    FROM dbo.tlbVetCase
                    WHERE idfVetCase = @VeterinaryDiseaseReportID;

                    INSERT INTO dbo.tauDataAuditDetailUpdate
                    (
                        idfDataAuditEvent,
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
                           @ObjectTableVeterinaryDiseaseReportID,
                           4578870000000,
                           a.VeterinaryDiseaseReportID,
                           NULL,
                           b.TestsConductedTypeID,
                           a.TestsConductedTypeID,
                           @AuditUserName,
                           @EIDSSObjectID
                    FROM @VeterinaryDiseaseReportAfterEdit a
                        FULL JOIN @VeterinaryDiseaseReportBeforeEdit b
                            ON a.VeterinaryDiseaseReportID = b.VeterinaryDiseaseReportID
                    WHERE (a.TestsConductedTypeID <> b.TestsConductedTypeID)
                          OR (
                                 a.TestsConductedTypeID IS NOT NULL
                                 AND b.TestsConductedTypeID IS NULL
                             )
                          OR (
                                 a.TestsConductedTypeID IS NULL
                                 AND b.TestsConductedTypeID IS NOT NULL
                             );
                END
            END

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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
                   @ObjectTableTestID,
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

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
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
                   @ObjectTableTestID,
                   51586990000032,
                   a.TestID,
                   NULL,
                   b.PreviousTestStatusTypeID,
                   a.PreviousTestStatusTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAfterEdit AS a
                FULL JOIN @TestBeforeEdit AS b
                    ON a.TestID = b.TestID
            WHERE (a.PreviousTestStatusTypeID <> b.PreviousTestStatusTypeID)
                  OR (
                         a.PreviousTestStatusTypeID IS NOT NULL
                         AND b.PreviousTestStatusTypeID IS NULL
                     )
                  OR (
                         a.PreviousTestStatusTypeID IS NULL
                         AND b.PreviousTestStatusTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
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
                   @ObjectTableTestID,
                   51586990000028,
                   a.TestID,
                   NULL,
                   b.MonitoringSessionID,
                   a.MonitoringSessionID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAfterEdit AS a
                FULL JOIN @TestBeforeEdit AS b
                    ON a.TestID = b.TestID
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
                   @ObjectTableTestID,
                   51586990000029,
                   a.TestID,
                   NULL,
                   b.HumanDiseaseReportID,
                   a.HumanDiseaseReportID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAfterEdit AS a
                FULL JOIN @TestBeforeEdit AS b
                    ON a.TestID = b.TestID
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
                   @ObjectTableTestID,
                   51586990000030,
                   a.TestID,
                   NULL,
                   b.VeterinaryDiseaseReportID,
                   a.VeterinaryDiseaseReportID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAfterEdit AS a
                FULL JOIN @TestBeforeEdit AS b
                    ON a.TestID = b.TestID
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
                   @ObjectTableTestID,
                   51586990000031,
                   a.TestID,
                   NULL,
                   b.VectorID,
                   a.VectorID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAfterEdit AS a
                FULL JOIN @TestBeforeEdit AS b
                    ON a.TestID = b.TestID
            WHERE (a.VectorID <> b.VectorID)
                  OR (
                         a.VectorID IS NOT NULL
                         AND b.VectorID IS NULL
                     )
                  OR (
                         a.VectorID IS NULL
                         AND b.VectorID IS NOT NULL
                     );
        END;

        IF @TestStatusTypeID = 10001003 -- In Progress
           OR @TestStatusTypeID = 10001004 -- Preliminary
        BEGIN
            INSERT INTO @SampleBeforeEdit
            SELECT idfMaterial,
                   TestUnassignedIndicator,
                   TestCompletedIndicator
            FROM dbo.tlbMaterial
            WHERE idfMaterial = @SampleID;

            UPDATE dbo.tlbMaterial
            SET TestUnassignedIndicator = 0,
                TestCompletedIndicator = 0
            WHERE idfMaterial = @SampleID;

            INSERT INTO @SampleAfterEdit
            SELECT idfMaterial,
                   TestUnassignedIndicator,
                   TestCompletedIndicator
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
                   51586990000037,
                   a.SampleID,
                   NULL,
                   b.TestUnassignedIndicator,
                   a.TestUnassignedIndicator,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @SampleAfterEdit a
                FULL JOIN @SampleBeforeEdit b
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
            FROM @SampleAfterEdit a
                FULL JOIN @SampleBeforeEdit b
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
        END;
        ELSE IF @TestStatusTypeID = 10001001 -- Final
                OR @TestStatusTypeID = 10001006 -- Amended
        BEGIN
            SELECT @TestAssignedCount = COUNT(idfTesting)
            FROM dbo.tlbTesting
            WHERE idfMaterial = @SampleID
                  AND intRowStatus = 0
                  AND idfsTestStatus IN ( 10001003, 10001004 );

            IF @TestAssignedCount = 0
            BEGIN
                INSERT INTO @SampleBeforeEdit
                SELECT idfMaterial,
                       TestUnassignedIndicator,
                       TestCompletedIndicator
                FROM dbo.tlbMaterial
                WHERE idfMaterial = @SampleID;

                UPDATE dbo.tlbMaterial
                SET TestCompletedIndicator = 1,
                    TestUnassignedIndicator = 0
                WHERE idfMaterial = @SampleID;

                INSERT INTO @SampleAfterEdit
                SELECT idfMaterial,
                       TestUnassignedIndicator,
                       TestCompletedIndicator
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
                       51586990000037,
                       a.SampleID,
                       NULL,
                       b.TestUnassignedIndicator,
                       a.TestUnassignedIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SampleAfterEdit a
                    FULL JOIN @SampleBeforeEdit b
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
                FROM @SampleAfterEdit a
                    FULL JOIN @SampleBeforeEdit b
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
            END
            ELSE
            BEGIN
                INSERT INTO @SampleBeforeEdit
                SELECT idfMaterial,
                       TestUnassignedIndicator,
                       TestCompletedIndicator
                FROM dbo.tlbMaterial
                WHERE idfMaterial = @SampleID;

                UPDATE dbo.tlbMaterial
                SET TestCompletedIndicator = 0,
                    TestUnassignedIndicator = 1
                WHERE idfMaterial = @SampleID;

                INSERT INTO @SampleAfterEdit
                SELECT idfMaterial,
                       TestUnassignedIndicator,
                       TestCompletedIndicator
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
                       51586990000037,
                       a.SampleID,
                       NULL,
                       b.TestUnassignedIndicator,
                       a.TestUnassignedIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @SampleAfterEdit a
                    FULL JOIN @SampleBeforeEdit b
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
                FROM @SampleAfterEdit a
                    FULL JOIN @SampleBeforeEdit b
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
            END;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;