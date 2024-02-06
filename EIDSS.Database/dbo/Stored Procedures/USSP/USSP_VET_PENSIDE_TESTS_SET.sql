-- ================================================================================================
-- Name: USSP_VET_PENSIDE_TESTS_SET
--
-- Description:	Inserts or updates penside test for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/07/2022 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_PENSIDE_TESTS_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @PensideTestID BIGINT OUTPUT,
    @SampleID BIGINT,
    @PensideTestResultTypeID BIGINT = NULL,
    @PensideTestNameTypeID BIGINT = NULL,
    @TestedByPersonID BIGINT = NULL,
    @TestedByOrganizationID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @TestDate DATETIME = NULL,
    @PensideTestCategoryTypeID BIGINT = NULL,
    @RowStatus INT,
    @RowAction INT
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = NULL,
        @ObjectTableID BIGINT = 75680000000; -- tlbPensideTest
DECLARE @PensideTestsAfterEdit TABLE
(
    PensideTestID BIGINT,
    SampleID BIGINT,
    PensideTestResultTypeID BIGINT,
    PensideTestNameTypeID BIGINT,
    TestedByPersonID BIGINT,
    TestedByOfficeID BIGINT,
    DiseaseID BIGINT,
    TestDate DATETIME,
    PensideTestCategoryTypeID BIGINT
);
DECLARE @PensideTestsBeforeEdit TABLE
(
    PensideTestID BIGINT,
    SampleID BIGINT,
    PensideTestResultTypeID BIGINT,
    PensideTestNameTypeID BIGINT,
    TestedByPersonID BIGINT,
    TestedByOfficeID BIGINT,
    DiseaseID BIGINT,
    TestDate DATETIME,
    PensideTestCategoryTypeID BIGINT
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

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbPensideTest',
                                              @idfsKey = @PensideTestID OUTPUT;

            INSERT INTO dbo.tlbPensideTest
            (
                idfPensideTest,
                idfMaterial,
                idfsPensideTestResult,
                idfsPensideTestName,
                intRowStatus,
                rowguid,
                idfTestedByPerson,
                idfTestedByOffice,
                idfsDiagnosis,
                datTestDate,
                idfsPensideTestCategory,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@PensideTestID,
             @SampleID,
             @PensideTestResultTypeID,
             @PensideTestNameTypeID,
             @RowStatus,
             NEWID(),
             @TestedByPersonID,
             @TestedByOrganizationID,
             @DiseaseID,
             @TestDate,
             @PensideTestCategoryTypeID,
             NULL,
             NULL,
             10519001,
             '[{"idfPensideTest":' + CAST(@PensideTestID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
             GETDATE()
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
             @PensideTestID,
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
            INSERT INTO @PensideTestsBeforeEdit
            (
                PensideTestID,
                SampleID,
                PensideTestResultTypeID,
                PensideTestNameTypeID,
                TestedByPersonID,
                TestedByOfficeID,
                DiseaseID,
                TestDate,
                PensideTestCategoryTypeID
            )
            SELECT idfPensideTest,
                   idfMaterial,
                   idfsPensideTestResult,
                   idfsPensideTestName,
                   idfTestedByPerson,
                   idfTestedByOffice,
                   idfsDiagnosis,
                   datTestDate,
                   idfsPensideTestCategory
            FROM dbo.tlbPensideTest
            WHERE idfPensideTest = @PensideTestID;
            -- End data audit

            UPDATE dbo.tlbPensideTest
            SET idfMaterial = @SampleID,
                idfsPensideTestResult = @PensideTestResultTypeID,
                idfsPensideTestName = @PensideTestNameTypeID,
                intRowStatus = @RowStatus,
                idfTestedByPerson = @TestedByPersonID,
                idfTestedByOffice = @TestedByOrganizationID,
                idfsDiagnosis = @DiseaseID,
                datTestDate = @TestDate,
                idfsPensideTestCategory = @PensideTestCategoryTypeID,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfPensideTest = @PensideTestID;

            -- Data audit
            INSERT INTO @PensideTestsAfterEdit
            (
                PensideTestID,
                SampleID,
                PensideTestResultTypeID,
                PensideTestNameTypeID,
                TestedByPersonID,
                TestedByOfficeID,
                DiseaseID,
                TestDate,
                PensideTestCategoryTypeID
            )
            SELECT idfPensideTest,
                   idfMaterial,
                   idfsPensideTestResult,
                   idfsPensideTestName,
                   idfTestedByPerson,
                   idfTestedByOffice,
                   idfsDiagnosis,
                   datTestDate,
                   idfsPensideTestCategory
            FROM dbo.tlbPensideTest
            WHERE idfPensideTest = @PensideTestID;

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
                       4575130000000,
                       a.PensideTestID,
                       NULL,
                       b.SampleID,
                       a.SampleID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
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
                       80240000000,
                       a.PensideTestID,
                       NULL,
                       b.PensideTestResultTypeID,
                       a.PensideTestResultTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
                WHERE (a.PensideTestResultTypeID <> b.PensideTestResultTypeID)
                      OR (
                             a.PensideTestResultTypeID IS NOT NULL
                             AND b.PensideTestResultTypeID IS NULL
                         )
                      OR (
                             a.PensideTestResultTypeID IS NULL
                             AND b.PensideTestResultTypeID IS NOT NULL
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
                       49545450000000,
                       a.PensideTestID,
                       NULL,
                       b.PensideTestNameTypeID,
                       a.PensideTestNameTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
                WHERE (a.PensideTestNameTypeID <> b.PensideTestNameTypeID)
                      OR (
                             a.PensideTestNameTypeID IS NOT NULL
                             AND b.PensideTestNameTypeID IS NULL
                         )
                      OR (
                             a.PensideTestNameTypeID IS NULL
                             AND b.PensideTestNameTypeID IS NOT NULL
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
                       4578630000000,
                       a.PensideTestID,
                       NULL,
                       b.TestedByPersonID,
                       a.TestedByPersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
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
                       4575150000000,
                       a.PensideTestID,
                       NULL,
                       b.TestedByOfficeID,
                       a.TestedByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
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
                       4575160000000,
                       a.PensideTestID,
                       NULL,
                       b.DiseaseID,
                       a.DiseaseID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
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
                       4575170000000,
                       a.PensideTestID,
                       NULL,
                       b.TestDate,
                       a.TestDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
                WHERE (a.TestDate <> b.TestDate)
                      OR (
                             a.TestDate IS NOT NULL
                             AND b.TestDate IS NULL
                         )
                      OR (
                             a.TestDate IS NULL
                             AND b.TestDate IS NOT NULL
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
                       4578380000000,
                       a.PensideTestID,
                       NULL,
                       b.PensideTestCategoryTypeID,
                       a.PensideTestCategoryTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @PensideTestsAfterEdit AS a
                    FULL JOIN @PensideTestsBeforeEdit AS b
                        ON a.PensideTestID = b.PensideTestID
                WHERE (a.PensideTestCategoryTypeID <> b.PensideTestCategoryTypeID)
                      OR (
                             a.PensideTestCategoryTypeID IS NOT NULL
                             AND b.PensideTestCategoryTypeID IS NULL
                         )
                      OR (
                             a.PensideTestCategoryTypeID IS NULL
                             AND b.PensideTestCategoryTypeID IS NOT NULL
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
                (@DataAuditEventid, @ObjectTableID, @PensideTestID, @AuditUserName, @EIDSSObjectID);
            END
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
