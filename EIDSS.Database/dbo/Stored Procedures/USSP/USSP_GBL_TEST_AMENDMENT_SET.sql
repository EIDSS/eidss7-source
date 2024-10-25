-- ================================================================================================
-- Name: USSP_GBL_TEST_AMENDMENT_SET
--
-- Description:	Inserts or updates test amendment records for various use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/01/2018 Initial release.
-- Stephen Long     03/30/2020 Added set of audit update time and user on record inserts/updates.
-- Stephen Long     09/24/2021 Removed language parameter as it is not needed.
-- Stephen Long     02/21/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_TEST_AMENDMENT_SET]
(
    @TestAmendmentID BIGINT OUTPUT,
    @TestID BIGINT,
    @AmendedByOrganizationID BIGINT = NULL,
    @AmendedByPersonID BIGINT = NULL,
    @AmendedDate DATETIME,
    @OldTestResultTypeID BIGINT = NULL,
    @NewTestResultTypeID BIGINT = NULL,
    @OldNote NVARCHAR(500) = NULL,
    @NewNote NVARCHAR(500) = NULL,
    @ReasonForAmendment NVARCHAR(500) = NULL,
    @RowStatus INT,
    @RecordAction NCHAR,
    @AuditUserName NVARCHAR(200),
    @EIDSSLaboratorySampleID NVARCHAR(200), 
    @DataAuditEventID BIGINT 
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Data audit
        DECLARE @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = 10017053,
                @ObjectTableTestAmendmentHistoryID BIGINT = 4578430000000, -- tlbTestAmendmentHistory
                @EIDSSObjectID NVARCHAR(200);
        DECLARE @TestAmendmentHistoryBeforeEdit TABLE
        (
            TestAmendmentID BIGINT,
            TestID BIGINT,
            AmendedByOrganizationID BIGINT,
            AmendedByPersonID BIGINT,
            AmendedDate DATETIME,
            OldTestResultTypeID BIGINT,
            NewTestResultTypeID BIGINT,
            OldNote NVARCHAR(500),
            NewNote NVARCHAR(500),
            ReasonForAmendment NVARCHAR(500),
            RowStatus INT
        );
        DECLARE @TestAmendmentHistoryAfterEdit TABLE
        (
            TestAmendmentID BIGINT,
            TestID BIGINT,
            AmendedByOrganizationID BIGINT,
            AmendedByPersonID BIGINT,
            AmendedDate DATETIME,
            OldTestResultTypeID BIGINT,
            NewTestResultTypeID BIGINT,
            OldNote NVARCHAR(500),
            NewNote NVARCHAR(500),
            ReasonForAmendment NVARCHAR(500),
            RowStatus INT
        );

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        SET @EIDSSObjectID = @EIDSSLaboratorySampleID;
        -- End data audit

        IF @RecordAction = 1
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTestAmendmentHistory',
                                              @TestAmendmentID OUTPUT;

            INSERT INTO dbo.tlbTestAmendmentHistory
            (
                idfTestAmendmentHistory,
                idfTesting,
                idfAmendByOffice,
                idfAmendByPerson,
                datAmendmentDate,
                idfsOldTestResult,
                idfsNewTestResult,
                strOldNote,
                strNewNote,
                strReason,
                intRowStatus,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@TestAmendmentID,
             @TestID,
             @AmendedByOrganizationID,
             @AmendedByPersonID,
             @AmendedDate,
             @OldTestResultTypeID,
             @NewTestResultTypeID,
             @OldNote,
             @NewNote,
             @ReasonForAmendment,
             @RowStatus,
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
             @ObjectTableTestAmendmentHistoryID,
             @TestAmendmentID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableTestAmendmentHistoryID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSObjectID
            );
        -- End data audit
        END
        ELSE
        BEGIN
            INSERT INTO @TestAmendmentHistoryBeforeEdit
            SELECT idfTestAmendmentHistory,
                   idfTesting,
                   idfAmendByOffice,
                   idfAmendByPerson,
                   datAmendmentDate,
                   idfsOldTestResult,
                   idfsNewTestResult,
                   strOldNote,
                   strNewNote,
                   strReason,
                   intRowStatus
            FROM dbo.tlbTestAmendmentHistory
            WHERE idfTestAmendmentHistory = @TestAmendmentID;

            UPDATE dbo.tlbTestAmendmentHistory
            SET idfTesting = @TestID,
                idfAmendByOffice = @AmendedByOrganizationID,
                idfAmendByPerson = @AmendedByPersonID,
                datAmendmentDate = @AmendedDate,
                idfsOldTestResult = @OldTestResultTypeID,
                idfsNewTestResult = @NewTestResultTypeID,
                strOldNote = @OldNote,
                strNewNote = @NewNote,
                strReason = @ReasonForAmendment,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfTestAmendmentHistory = @TestAmendmentID;

            INSERT INTO @TestAmendmentHistoryAfterEdit
            SELECT idfTestAmendmentHistory,
                   idfTesting,
                   idfAmendByOffice,
                   idfAmendByPerson,
                   datAmendmentDate,
                   idfsOldTestResult,
                   idfsNewTestResult,
                   strOldNote,
                   strNewNote,
                   strReason,
                   intRowStatus
            FROM dbo.tlbTestAmendmentHistory
            WHERE idfTestAmendmentHistory = @TestAmendmentID;

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
                   @ObjectTableTestAmendmentHistoryID,
                   4578450000000,
                   a.TestAmendmentID,
                   NULL,
                   b.TestID,
                   a.TestID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.TestID <> b.TestID)
                  OR (
                         a.TestID IS NOT NULL
                         AND b.TestID IS NULL
                     )
                  OR (
                         a.TestID IS NULL
                         AND b.TestID IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578460000000,
                   a.TestAmendmentID,
                   NULL,
                   b.AmendedByOrganizationID,
                   a.AmendedByOrganizationID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.AmendedByOrganizationID <> b.AmendedByOrganizationID)
                  OR (
                         a.AmendedByOrganizationID IS NOT NULL
                         AND b.AmendedByOrganizationID IS NULL
                     )
                  OR (
                         a.AmendedByOrganizationID IS NULL
                         AND b.AmendedByOrganizationID IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578470000000,
                   a.TestAmendmentID,
                   NULL,
                   b.AmendedByPersonID,
                   a.AmendedByPersonID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.AmendedByPersonID <> b.AmendedByPersonID)
                  OR (
                         a.AmendedByPersonID IS NOT NULL
                         AND b.AmendedByPersonID IS NULL
                     )
                  OR (
                         a.AmendedByPersonID IS NULL
                         AND b.AmendedByPersonID IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578480000000,
                   a.TestAmendmentID,
                   NULL,
                   b.AmendedDate,
                   a.AmendedDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.AmendedDate <> b.AmendedDate)
                  OR (
                         a.AmendedDate IS NOT NULL
                         AND b.AmendedDate IS NULL
                     )
                  OR (
                         a.AmendedDate IS NULL
                         AND b.AmendedDate IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578490000000,
                   a.TestAmendmentID,
                   NULL,
                   b.OldTestResultTypeID,
                   a.OldTestResultTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.OldTestResultTypeID <> b.OldTestResultTypeID)
                  OR (
                         a.OldTestResultTypeID IS NOT NULL
                         AND b.OldTestResultTypeID IS NULL
                     )
                  OR (
                         a.OldTestResultTypeID IS NULL
                         AND b.OldTestResultTypeID IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578500000000,
                   a.TestAmendmentID,
                   NULL,
                   b.NewTestResultTypeID,
                   a.NewTestResultTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.NewTestResultTypeID <> b.NewTestResultTypeID)
                  OR (
                         a.NewTestResultTypeID IS NOT NULL
                         AND b.NewTestResultTypeID IS NULL
                     )
                  OR (
                         a.NewTestResultTypeID IS NULL
                         AND b.NewTestResultTypeID IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578510000000,
                   a.TestAmendmentID,
                   NULL,
                   b.OldNote,
                   a.OldNote,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.OldNote <> b.OldNote)
                  OR (
                         a.OldNote IS NOT NULL
                         AND b.OldNote IS NULL
                     )
                  OR (
                         a.OldNote IS NULL
                         AND b.OldNote IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578520000000,
                   a.TestAmendmentID,
                   NULL,
                   b.NewNote,
                   a.NewNote,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.NewNote <> b.NewNote)
                  OR (
                         a.NewNote IS NOT NULL
                         AND b.NewNote IS NULL
                     )
                  OR (
                         a.NewNote IS NULL
                         AND b.NewNote IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   4578530000000,
                   a.TestAmendmentID,
                   NULL,
                   b.ReasonForAmendment,
                   a.ReasonForAmendment,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit a
                FULL JOIN @TestAmendmentHistoryBeforeEdit b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE (a.ReasonForAmendment <> b.ReasonForAmendment)
                  OR (
                         a.ReasonForAmendment IS NOT NULL
                         AND b.ReasonForAmendment IS NULL
                     )
                  OR (
                         a.ReasonForAmendment IS NULL
                         AND b.ReasonForAmendment IS NOT NULL
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
                   @ObjectTableTestAmendmentHistoryID,
                   a.TestAmendmentID,
                   NULL,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @TestAmendmentHistoryAfterEdit AS a
                FULL JOIN @TestAmendmentHistoryBeforeEdit AS b
                    ON a.TestAmendmentID = b.TestAmendmentID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
