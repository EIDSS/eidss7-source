-- ================================================================================================
-- Name: USSP_GBL_BATCH_TEST_SET
--
-- Description:	Inserts or updates batch test records for various use cases.
--
-- Revision History:
-- Name  Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/22/2018 Initial release.
-- Stephen Long     02/19/2019 Remove positive control, negative control and reagent lot numbers 
--                             to match use case.  Increased test requested from 100 to 200 and 
--                             made nvarchar.
-- Stephen Long     03/28/2019 Updated get next number call to use the name instead of the ID.
-- Stephen Long     03/30/2020 Added set of audit update time and user on record inserts/updates.
-- Stephen Long     02/21/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_BATCH_TEST_SET]
(
    @BatchTestID BIGINT OUTPUT,
    @TestNameTypeID BIGINT = NULL,
    @BatchStatusTypeID BIGINT = NULL,
    @PerformedByOrganizationID BIGINT = NULL,
    @PerformedByPersonID BIGINT = NULL,
    @ValidatedByOrganizationID BIGINT = NULL,
    @ValidatedByPersonID BIGINT = NULL,
    @ObservationID BIGINT,
    @SiteID BIGINT,
    @PerformedDate DATETIME = NULL,
    @ValidationDate DATETIME = NULL,
    @EIDSSBatchTestID NVARCHAR(200) = NULL,
    @RowStatus INT,
    @ResultEnteredByPersonID BIGINT = NULL,
    @ResultEnteredByOrganizationID BIGINT = NULL,
    @RowAction INT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Data audit
        DECLARE @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                @DataAuditEventID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = 10017012,
                @ObjectTableBatchTestID BIGINT = 75480000000; -- tlbBatchTest
        DECLARE @BatchTestBeforeEdit TABLE
        (
            BatchTestID BIGINT,
            TestNameTypeID BIGINT,
            BatchStatusTypeID BIGINT,
            PerformedByOrganizationID BIGINT,
            PerformedByPersonID BIGINT,
            ValidatedByOrganizationID BIGINT,
            ValidatedByPersonID BIGINT,
            ObservationID BIGINT,
            PerformedDate DATETIME,
            ValidationDate DATETIME,
            EIDSSBatchTestID NVARCHAR(200),
            RowStatus INT,
            ResultEnteredByPersonID BIGINT,
            ResultEnteredByOrganizationID BIGINT
        );
        DECLARE @BatchTestAfterEdit TABLE
        (
            BatchTestID BIGINT,
            TestNameTypeID BIGINT,
            BatchStatusTypeID BIGINT,
            PerformedByOrganizationID BIGINT,
            PerformedByPersonID BIGINT,
            ValidatedByOrganizationID BIGINT,
            ValidatedByPersonID BIGINT,
            ObservationID BIGINT,
            PerformedDate DATETIME,
            ValidationDate DATETIME,
            EIDSSBatchTestID NVARCHAR(200),
            RowStatus INT,
            ResultEnteredByPersonID BIGINT,
            ResultEnteredByOrganizationID BIGINT
        );

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        IF @RowAction = 1
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbBatchTest',
                                              @idfsKey = @BatchTestID OUTPUT;

            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Batch Test Barcode',
                                               @NextNumberValue = @EIDSSBatchTestID OUTPUT,
                                               @InstallationSite = @SiteID;

            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @BatchTestID,
                                                      @ObjectTableBatchTestID,
                                                      @EIDSSBatchTestID,
                                                      @DataAuditEventID OUTPUT;

            INSERT INTO dbo.tlbBatchTest
            (
                idfBatchTest,
                idfsTestName,
                idfsBatchStatus,
                idfPerformedByOffice,
                idfPerformedByPerson,
                idfValidatedByOffice,
                idfValidatedByPerson,
                idfObservation,
                idfsSite,
                datPerformedDate,
                datValidatedDate,
                strBarcode,
                intRowStatus,
                idfResultEnteredByPerson,
                idfResultEnteredByOffice,
                AuditCreateUser
            )
            VALUES
            (@BatchTestID,
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
             @ObjectTableBatchTestID,
             @BatchTestID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableBatchTestID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSBatchTestID
            );
        -- End data audit
        END;
        ELSE
        BEGIN
            INSERT INTO @BatchTestBeforeEdit
            SELECT idfBatchTest,
                   idfsTestName,
                   idfsBatchStatus,
                   idfPerformedByOffice,
                   idfPerformedByPerson,
                   idfValidatedByOffice,
                   idfValidatedByPerson,
                   idfObservation,
                   datPerformedDate,
                   datValidatedDate,
                   strBarcode,
                   intRowStatus,
                   idfResultEnteredByPerson,
                   idfResultEnteredByOffice
            FROM dbo.tlbBatchTest
            WHERE idfBatchTest = @BatchTestID;

            UPDATE dbo.tlbBatchTest
            SET idfsTestName = @TestNameTypeID,
                idfsBatchStatus = @BatchStatusTypeID,
                idfPerformedByOffice = @PerformedByOrganizationID,
                idfPerformedByPerson = @PerformedByPersonID,
                idfValidatedByOffice = @ValidatedByOrganizationID,
                idfValidatedByPerson = @ValidatedByPersonID,
                idfObservation = @ObservationID,
                idfsSite = @SiteID,
                datPerformedDate = @PerformedDate,
                datValidatedDate = @ValidationDate,
                strBarcode = @EIDSSBatchTestID,
                intRowStatus = @RowStatus,
                idfResultEnteredByPerson = @ResultEnteredByPersonID,
                idfResultEnteredByOffice = @ResultEnteredByOrganizationID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfBatchTest = @BatchTestID;

            INSERT INTO @BatchTestAfterEdit
            SELECT idfBatchTest,
                   idfsTestName,
                   idfsBatchStatus,
                   idfPerformedByOffice,
                   idfPerformedByPerson,
                   idfValidatedByOffice,
                   idfValidatedByPerson,
                   idfObservation,
                   datPerformedDate,
                   datValidatedDate,
                   strBarcode,
                   intRowStatus,
                   idfResultEnteredByPerson,
                   idfResultEnteredByOffice
            FROM dbo.tlbBatchTest
            WHERE idfBatchTest = @BatchTestID;

            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @BatchTestID,
                                                      @ObjectTableBatchTestID,
                                                      @EIDSSBatchTestID,
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
                   @ObjectTableBatchTestID,
                   78370000000,
                   a.BatchTestID,
                   NULL,
                   b.ValidationDate,
                   a.ValidationDate,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.ValidationDate <> b.ValidationDate)
                  OR (
                         a.ValidationDate IS NOT NULL
                         AND b.ValidationDate IS NULL
                     )
                  OR (
                         a.ValidationDate IS NULL
                         AND b.ValidationDate IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   78390000000,
                   a.BatchTestID,
                   NULL,
                   b.ObservationID,
                   a.ObservationID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
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
                   @ObjectTableBatchTestID,
                   78410000000,
                   a.BatchTestID,
                   NULL,
                   b.ValidatedByOrganizationID,
                   a.ValidatedByOrganizationID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.ValidatedByOrganizationID <> b.ValidatedByOrganizationID)
                  OR (
                         a.ValidatedByOrganizationID IS NOT NULL
                         AND b.ValidatedByOrganizationID IS NULL
                     )
                  OR (
                         a.ValidatedByOrganizationID IS NULL
                         AND b.ValidatedByOrganizationID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   78420000000,
                   a.BatchTestID,
                   NULL,
                   b.ValidatedByPersonID,
                   a.ValidatedByPersonID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
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
                   @ObjectTableBatchTestID,
                   4577820000000,
                   a.BatchTestID,
                   NULL,
                   b.BatchStatusTypeID,
                   a.BatchStatusTypeID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.BatchStatusTypeID <> b.BatchStatusTypeID)
                  OR (
                         a.BatchStatusTypeID IS NOT NULL
                         AND b.BatchStatusTypeID IS NULL
                     )
                  OR (
                         a.BatchStatusTypeID IS NULL
                         AND b.BatchStatusTypeID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   4577830000000,
                   a.BatchTestID,
                   NULL,
                   b.PerformedByOrganizationID,
                   a.PerformedByOrganizationID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.PerformedByOrganizationID <> b.PerformedByOrganizationID)
                  OR (
                         a.PerformedByOrganizationID IS NOT NULL
                         AND b.PerformedByOrganizationID IS NULL
                     )
                  OR (
                         a.PerformedByOrganizationID IS NULL
                         AND b.PerformedByOrganizationID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   4577840000000,
                   a.BatchTestID,
                   NULL,
                   b.PerformedByPersonID,
                   a.PerformedByPersonID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.PerformedByPersonID <> b.PerformedByPersonID)
                  OR (
                         a.PerformedByPersonID IS NOT NULL
                         AND b.PerformedByPersonID IS NULL
                     )
                  OR (
                         a.PerformedByPersonID IS NULL
                         AND b.PerformedByPersonID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   4577850000000,
                   a.BatchTestID,
                   NULL,
                   b.PerformedDate,
                   a.PerformedDate,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.PerformedDate <> b.PerformedDate)
                  OR (
                         a.PerformedDate IS NOT NULL
                         AND b.PerformedDate IS NULL
                     )
                  OR (
                         a.PerformedDate IS NULL
                         AND b.PerformedDate IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   4577860000000,
                   a.BatchTestID,
                   NULL,
                   b.EIDSSBatchTestID,
                   a.EIDSSBatchTestID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.EIDSSBatchTestID <> b.EIDSSBatchTestID)
                  OR (
                         a.EIDSSBatchTestID IS NOT NULL
                         AND b.EIDSSBatchTestID IS NULL
                     )
                  OR (
                         a.EIDSSBatchTestID IS NULL
                         AND b.EIDSSBatchTestID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   6617390000000,
                   a.BatchTestID,
                   NULL,
                   b.ResultEnteredByPersonID,
                   a.ResultEnteredByPersonID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
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
                   @ObjectTableBatchTestID,
                   6617400000000,
                   a.BatchTestID,
                   NULL,
                   b.ResultEnteredByOrganizationID,
                   a.ResultEnteredByOrganizationID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.ResultEnteredByOrganizationID <> b.ResultEnteredByOrganizationID)
                  OR (
                         a.ResultEnteredByOrganizationID IS NOT NULL
                         AND b.ResultEnteredByOrganizationID IS NULL
                     )
                  OR (
                         a.ResultEnteredByOrganizationID IS NULL
                         AND b.ResultEnteredByOrganizationID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   49545490000000,
                   a.BatchTestID,
                   NULL,
                   b.TestNameTypeID,
                   a.TestNameTypeID,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit a
                FULL JOIN @BatchTestBeforeEdit b
                    ON a.BatchTestID = b.BatchTestID
            WHERE (a.TestNameTypeID <> b.TestNameTypeID)
                  OR (
                         a.TestNameTypeID IS NOT NULL
                         AND b.TestNameTypeID IS NULL
                     )
                  OR (
                         a.TestNameTypeID IS NULL
                         AND b.TestNameTypeID IS NOT NULL
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
                   @ObjectTableBatchTestID,
                   a.BatchTestID,
                   NULL,
                   @AuditUserName,
                   @EIDSSBatchTestID
            FROM @BatchTestAfterEdit AS a
                FULL JOIN @BatchTestBeforeEdit AS b
                    ON a.BatchTestID = b.BatchTestID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;