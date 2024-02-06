-- ================================================================================================
-- Name: USSP_VET_DISEASE_REPORT_LOG_SET
--
-- Description:	Inserts or updates veterinary "case" log for the avian and livestock veterinary 
-- disease report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     04/17/2019 Removed strMaintenanceFlag.
-- Stephen Long     01/19/2022 Remove language ID and changed row action data type.
-- Stephen Long     12/07/2022 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_DISEASE_REPORT_LOG_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @CaseLogID BIGINT OUTPUT,
    @LogStatusTypeID BIGINT = NULL,
    @DiseaseReportID BIGINT = NULL,
    @PersonID BIGINT = NULL,
    @LogDate DATETIME = NULL,
    @ActionRequired NVARCHAR(200) = NULL,
    @Comments NVARCHAR(1000) = NULL,
    @RowStatus INT,
    @RowAction INT
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75810000000; -- tlbVetCaseLog
DECLARE @CaseLogsAfterEdit TABLE
(
    CaseLogID BIGINT,
    CaseLogStatusTypeID BIGINT,
    DiseaseReportID BIGINT,
    PersonID BIGINT,
    CaseLogDate DATETIME,
    ActionRequired NVARCHAR(200),
    Note NVARCHAR(1000)
);
DECLARE @CaseLogsBeforeEdit TABLE
(
    CaseLogID BIGINT,
    CaseLogStatusTypeID BIGINT,
    DiseaseReportID BIGINT,
    PersonID BIGINT,
    CaseLogDate DATETIME,
    ActionRequired NVARCHAR(200),
    Note NVARCHAR(1000)
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

        IF @RowAction = 1
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbVetCaseLog', @CaseLogID OUTPUT;

            INSERT INTO dbo.tlbVetCaseLog
            (
                idfVetCaseLog,
                idfsCaseLogStatus,
                idfVetCase,
                idfPerson,
                datCaseLogDate,
                strActionRequired,
                strNote,
                intRowStatus,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@CaseLogID,
             @LogStatusTypeID,
             @DiseaseReportID,
             @PersonID,
             @LogDate,
             @ActionRequired,
             @Comments,
             @RowStatus,
             @AuditUserName,
             10519001,
             '[{"idfVetCaseLog":' + CAST(@CaseLogID AS NVARCHAR(300)) + '}]'
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
             @CaseLogID,
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
            -- Data audit
            INSERT INTO @CaseLogsBeforeEdit
            (
                CaseLogID,
                CaseLogStatusTypeID,
                DiseaseReportID,
                PersonID,
                CaseLogDate,
                ActionRequired,
                Note
            )
            SELECT idfVetCaseLog,
                   idfsCaseLogStatus,
                   idfVetCase,
                   idfPerson,
                   datCaseLogDate,
                   strActionRequired,
                   strNote
            FROM dbo.tlbVetCaseLog
            WHERE idfVetCaseLog = @CaseLogID;
            -- End data audit

            UPDATE dbo.tlbVetCaseLog
            SET idfsCaseLogStatus = @LogStatusTypeID,
                idfVetCase = @DiseaseReportID,
                idfPerson = @PersonID,
                datCaseLogDate = @LogDate,
                strActionRequired = @ActionRequired,
                strNote = @Comments,
                intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName
            WHERE idfVetCaseLog = @CaseLogID;

            -- Data audit
            INSERT INTO @CaseLogsAfterEdit
            (
                CaseLogID,
                CaseLogStatusTypeID,
                DiseaseReportID,
                PersonID,
                CaseLogDate,
                ActionRequired,
                Note
            )
            SELECT idfVetCaseLog,
                   idfsCaseLogStatus,
                   idfVetCase,
                   idfPerson,
                   datCaseLogDate,
                   strActionRequired,
                   strNote
            FROM dbo.tlbVetCaseLog
            WHERE idfVetCaseLog = @CaseLogID;

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
                       4578020000000,
                       a.CaseLogID,
                       NULL,
                       b.CaseLogStatusTypeID,
                       a.CaseLogStatusTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @CaseLogsAfterEdit AS a
                    FULL JOIN @CaseLogsBeforeEdit AS b
                        ON a.CaseLogID = b.CaseLogID
                WHERE (a.CaseLogStatusTypeID <> b.CaseLogStatusTypeID)
                      OR (
                             a.CaseLogStatusTypeID IS NOT NULL
                             AND b.CaseLogStatusTypeID IS NULL
                         )
                      OR (
                             a.CaseLogStatusTypeID IS NULL
                             AND b.CaseLogStatusTypeID IS NOT NULL
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
                       4578030000000,
                       a.CaseLogID,
                       NULL,
                       b.DiseaseReportID,
                       a.DiseaseReportID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @CaseLogsAfterEdit AS a
                    FULL JOIN @CaseLogsBeforeEdit AS b
                        ON a.CaseLogID = b.CaseLogID
                WHERE (a.DiseaseReportID <> b.DiseaseReportID)
                      OR (
                             a.DiseaseReportID IS NOT NULL
                             AND b.DiseaseReportID IS NULL
                         )
                      OR (
                             a.DiseaseReportID IS NULL
                             AND b.DiseaseReportID IS NOT NULL
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
                       81050000000,
                       a.CaseLogID,
                       NULL,
                       b.PersonID,
                       a.PersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @CaseLogsAfterEdit AS a
                    FULL JOIN @CaseLogsBeforeEdit AS b
                        ON a.CaseLogID = b.CaseLogID
                WHERE (a.PersonID <> b.PersonID)
                      OR (
                             a.PersonID IS NOT NULL
                             AND b.PersonID IS NULL
                         )
                      OR (
                             a.PersonID IS NULL
                             AND b.PersonID IS NOT NULL
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
                       81040000000,
                       a.CaseLogID,
                       NULL,
                       b.CaseLogDate,
                       a.CaseLogDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @CaseLogsAfterEdit AS a
                    FULL JOIN @CaseLogsBeforeEdit AS b
                        ON a.CaseLogID = b.CaseLogID
                WHERE (a.CaseLogDate <> b.CaseLogDate)
                      OR (
                             a.CaseLogDate IS NOT NULL
                             AND b.CaseLogDate IS NULL
                         )
                      OR (
                             a.CaseLogDate IS NULL
                             AND b.CaseLogDate IS NOT NULL
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
                       4578040000000,
                       a.CaseLogID,
                       NULL,
                       b.ActionRequired,
                       a.ActionRequired,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @CaseLogsAfterEdit AS a
                    FULL JOIN @CaseLogsBeforeEdit AS b
                        ON a.CaseLogID = b.CaseLogID
                WHERE (a.ActionRequired <> b.ActionRequired)
                      OR (
                             a.ActionRequired IS NOT NULL
                             AND b.ActionRequired IS NULL
                         )
                      OR (
                             a.ActionRequired IS NULL
                             AND b.ActionRequired IS NOT NULL
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
                       81060000000,
                       a.CaseLogID,
                       NULL,
                       b.Note,
                       a.Note,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @CaseLogsAfterEdit AS a
                    FULL JOIN @CaseLogsBeforeEdit AS b
                        ON a.CaseLogID = b.CaseLogID
                WHERE (a.Note <> b.Note)
                      OR (
                             a.Note IS NOT NULL
                             AND b.Note IS NULL
                         )
                      OR (
                             a.Note IS NULL
                             AND b.Note IS NOT NULL
                         );
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
                (@DataAuditEventid, @ObjectTableID, @CaseLogID, @AuditUserName, @EIDSSObjectID);
            END
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
