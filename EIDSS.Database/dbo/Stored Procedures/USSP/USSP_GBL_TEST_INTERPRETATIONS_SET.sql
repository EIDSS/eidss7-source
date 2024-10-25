-- ================================================================================================
-- Name: USSP_GBL_TEST_INTERPRETATIONS_SET
--
-- Description:	Inserts or updates test interpretation records for various use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/21/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long     11/29/2022 Added delete data audit logic.
-- Stephen Long     12/09/2022 Added EIDSSObjectID parameter to insert for strObject.
-- Stephen Long     02/06/2023 Removed print statement.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_TEST_INTERPRETATIONS_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @TestInterpretationID BIGINT OUTPUT,
    @DiseaseID BIGINT,
    @InterpretedStatusTypeID BIGINT = NULL,
    @ValidatedByOrganizationID BIGINT = NULL,
    @ValidatedByPersonID BIGINT = NULL,
    @InterpretedByOrganizationID BIGINT = NULL,
    @InterpretedByPersonID BIGINT = NULL,
    @TestID BIGINT,
    @ValidateStatusIndicator BIT = NULL,
    @ReportSessionCreatedIndicator BIT = NULL,
    @ValidationComment NVARCHAR(200) = NULL,
    @InterpretationComment NVARCHAR(200) = NULL,
    @ValidationDate DATETIME = NULL,
    @InterpretationDate DATETIME = NULL,
    @RowStatus INT,
    @ReadOnlyIndicator BIT,
    @RowAction INT
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = @TestInterpretationID,
        @ObjectTableID BIGINT = 75750000000; -- tlbTestValidation
DECLARE @TestInterpretationBeforeEdit TABLE
(
    TestInterpretationID BIGINT,
    DiseaseID BIGINT,
    InterpretedStatusTypeID BIGINT,
    ValidatedByOfficeID BIGINT,
    ValidatedByPersonID BIGINT,
    InterpretedByOfficeID BIGINT,
    InterpretedByPersonID BIGINT,
    TestID BIGINT,
    ValidateStatusIndicator BIT,
    CaseCreatedIndicator BIT,
    ValidateComment NVARCHAR(200),
    InterpretedComment NVARCHAR(200),
    ValidationDate DATETIME,
    InterpretationDate DATETIME,
    ReadOnlyIndicator BIT,
    RowStatus INT
);
DECLARE @TestInterpretationAfterEdit TABLE
(
    TestInterpretationID BIGINT,
    DiseaseID BIGINT,
    InterpretedStatusTypeID BIGINT,
    ValidatedByOfficeID BIGINT,
    ValidatedByPersonID BIGINT,
    InterpretedByOfficeID BIGINT,
    InterpretedByPersonID BIGINT,
    TestID BIGINT,
    ValidateStatusIndicator BIT,
    CaseCreatedIndicator BIT,
    ValidateComment NVARCHAR(200),
    InterpretedComment NVARCHAR(200),
    ValidationDate DATETIME,
    InterpretationDate DATETIME,
    ReadOnlyIndicator BIT,
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

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbTestValidation',
                                              @TestInterpretationID OUTPUT;

            INSERT INTO dbo.tlbTestValidation
            (
                idfTestValidation,
                idfsDiagnosis,
                idfsInterpretedStatus,
                idfValidatedByOffice,
                idfValidatedByPerson,
                idfInterpretedByOffice,
                idfInterpretedByPerson,
                idfTesting,
                blnValidateStatus,
                blnCaseCreated,
                strValidateComment,
                strInterpretedComment,
                datValidationDate,
                datInterpretationDate,
                intRowStatus,
                blnReadOnly,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@TestInterpretationID,
             @DiseaseID,
             @InterpretedStatusTypeID,
             @ValidatedByOrganizationID,
             @ValidatedByPersonID,
             @InterpretedByOrganizationID,
             @InterpretedByPersonID,
             @TestID,
             @ValidateStatusIndicator,
             @ReportSessionCreatedIndicator,
             @ValidationComment,
             @InterpretationComment,
             @ValidationDate,
             @InterpretationDate,
             @RowStatus,
             @ReadOnlyIndicator,
             @AuditUserName,
             10519001,
             '[{"idfTestValidation":' + CAST(@TestInterpretationID AS NVARCHAR(300)) + '}]'
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
             @TestInterpretationID,
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
            INSERT INTO @TestInterpretationBeforeEdit
            (
                TestInterpretationID,
                DiseaseID,
                InterpretedStatusTypeID,
                ValidatedByOfficeID,
                ValidatedByPersonID,
                InterpretedByOfficeID,
                InterpretedByPersonID,
                TestID,
                ValidateStatusIndicator,
                CaseCreatedIndicator,
                ValidateComment,
                InterpretedComment,
                ValidationDate,
                InterpretationDate,
                ReadOnlyIndicator,
                RowStatus
            )
            SELECT idfTestValidation,
                   idfsDiagnosis,
                   idfsInterpretedStatus,
                   idfValidatedByOffice,
                   idfValidatedByPerson,
                   idfInterpretedByOffice,
                   idfInterpretedByPerson,
                   idfTesting,
                   blnValidateStatus,
                   blnCaseCreated,
                   strValidateComment,
                   strInterpretedComment,
                   datValidationDate,
                   datInterpretationDate,
                   blnReadOnly,
                   intRowStatus
            FROM dbo.tlbTestValidation
            WHERE idfTestValidation = @TestInterpretationID;

            UPDATE dbo.tlbTestValidation
            SET idfsDiagnosis = @DiseaseID,
                idfsInterpretedStatus = @InterpretedStatusTypeID,
                idfValidatedByOffice = @ValidatedByOrganizationID,
                idfValidatedByPerson = @ValidatedByPersonID,
                idfInterpretedByOffice = @InterpretedByOrganizationID,
                idfInterpretedByPerson = @InterpretedByPersonID,
                idfTesting = @TestID,
                blnValidateStatus = @ValidateStatusIndicator,
                blnCaseCreated = @ReportSessionCreatedIndicator,
                strValidateComment = @ValidationComment,
                strInterpretedComment = @InterpretationComment,
                datValidationDate = @ValidationDate,
                datInterpretationDate = @InterpretationDate,
                intRowStatus = @RowStatus,
                blnReadOnly = @ReadOnlyIndicator,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfTestValidation = @TestInterpretationID;

            INSERT INTO @TestInterpretationAfterEdit
            (
                TestInterpretationID,
                DiseaseID,
                InterpretedStatusTypeID,
                ValidatedByOfficeID,
                ValidatedByPersonID,
                InterpretedByOfficeID,
                InterpretedByPersonID,
                TestID,
                ValidateStatusIndicator,
                CaseCreatedIndicator,
                ValidateComment,
                InterpretedComment,
                ValidationDate,
                InterpretationDate,
                ReadOnlyIndicator,
                RowStatus
            )
            SELECT idfTestValidation,
                   idfsDiagnosis,
                   idfsInterpretedStatus,
                   idfValidatedByOffice,
                   idfValidatedByPerson,
                   idfInterpretedByOffice,
                   idfInterpretedByPerson,
                   idfTesting,
                   blnValidateStatus,
                   blnCaseCreated,
                   strValidateComment,
                   strInterpretedComment,
                   datValidationDate,
                   datInterpretationDate,
                   blnReadOnly,
                   intRowStatus
            FROM dbo.tlbTestValidation
            WHERE idfTestValidation = @TestInterpretationID;

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
                       80580000000,
                       a.TestInterpretationID,
                       NULL,
                       b.DiseaseID,
                       a.DiseaseID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
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
                       80590000000,
                       a.TestInterpretationID,
                       NULL,
                       b.InterpretedStatusTypeID,
                       a.InterpretedStatusTypeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.InterpretedStatusTypeID <> b.InterpretedStatusTypeID)
                      OR (
                             a.InterpretedStatusTypeID IS NOT NULL
                             AND b.InterpretedStatusTypeID IS NULL
                         )
                      OR (
                             a.InterpretedStatusTypeID IS NULL
                             AND b.InterpretedStatusTypeID IS NOT NULL
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
                       80610000000,
                       a.TestInterpretationID,
                       NULL,
                       b.ValidatedByOfficeID,
                       a.ValidatedByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
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
                       80620000000,
                       a.TestInterpretationID,
                       NULL,
                       b.ValidatedByPersonID,
                       a.ValidatedByPersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
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
                       80560000000,
                       a.TestInterpretationID,
                       NULL,
                       b.InterpretedByOfficeID,
                       a.InterpretedByOfficeID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.InterpretedByOfficeID <> b.InterpretedByOfficeID)
                      OR (
                             a.InterpretedByOfficeID IS NOT NULL
                             AND b.InterpretedByOfficeID IS NULL
                         )
                      OR (
                             a.InterpretedByOfficeID IS NULL
                             AND b.InterpretedByOfficeID IS NOT NULL
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
                       80570000000,
                       a.TestInterpretationID,
                       NULL,
                       b.InterpretedByPersonID,
                       a.InterpretedByPersonID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.InterpretedByPersonID <> b.InterpretedByPersonID)
                      OR (
                             a.InterpretedByPersonID IS NOT NULL
                             AND b.InterpretedByPersonID IS NULL
                         )
                      OR (
                             a.InterpretedByPersonID IS NULL
                             AND b.InterpretedByPersonID IS NOT NULL
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
                       80600000000,
                       a.TestInterpretationID,
                       NULL,
                       b.TestID,
                       a.TestID,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
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
                       @ObjectTableID,
                       80550000000,
                       a.TestInterpretationID,
                       NULL,
                       b.ValidateStatusIndicator,
                       a.ValidateStatusIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.ValidateStatusIndicator <> b.ValidateStatusIndicator)
                      OR (
                             a.ValidateStatusIndicator IS NOT NULL
                             AND b.ValidateStatusIndicator IS NULL
                         )
                      OR (
                             a.ValidateStatusIndicator IS NULL
                             AND b.ValidateStatusIndicator IS NOT NULL
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
                       4572560000000,
                       a.TestInterpretationID,
                       NULL,
                       b.CaseCreatedIndicator,
                       a.CaseCreatedIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.CaseCreatedIndicator <> b.CaseCreatedIndicator)
                      OR (
                             a.CaseCreatedIndicator IS NOT NULL
                             AND b.CaseCreatedIndicator IS NULL
                         )
                      OR (
                             a.CaseCreatedIndicator IS NULL
                             AND b.CaseCreatedIndicator IS NOT NULL
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
                       80640000000,
                       a.TestInterpretationID,
                       NULL,
                       b.ValidateComment,
                       a.ValidateComment,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.ValidateComment <> b.ValidateComment)
                      OR (
                             a.ValidateComment IS NOT NULL
                             AND b.ValidateComment IS NULL
                         )
                      OR (
                             a.ValidateComment IS NULL
                             AND b.ValidateComment IS NOT NULL
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
                       80630000000,
                       a.TestInterpretationID,
                       NULL,
                       b.InterpretedComment,
                       a.InterpretedComment,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.InterpretedComment <> b.InterpretedComment)
                      OR (
                             a.InterpretedComment IS NOT NULL
                             AND b.InterpretedComment IS NULL
                         )
                      OR (
                             a.InterpretedComment IS NULL
                             AND b.InterpretedComment IS NOT NULL
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
                       4572570000000,
                       a.TestInterpretationID,
                       NULL,
                       b.ValidationDate,
                       a.ValidationDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
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
                       @ObjectTableID,
                       4572580000000,
                       a.TestInterpretationID,
                       NULL,
                       b.InterpretationDate,
                       a.InterpretationDate,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.InterpretationDate <> b.InterpretationDate)
                      OR (
                             a.InterpretationDate IS NOT NULL
                             AND b.InterpretationDate IS NULL
                         )
                      OR (
                             a.InterpretationDate IS NULL
                             AND b.InterpretationDate IS NOT NULL
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
                       6617410000000,
                       a.TestInterpretationID,
                       NULL,
                       b.ReadOnlyIndicator,
                       a.ReadOnlyIndicator,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
                WHERE (a.ReadOnlyIndicator <> b.ReadOnlyIndicator)
                      OR (
                             a.ReadOnlyIndicator IS NOT NULL
                             AND b.ReadOnlyIndicator IS NULL
                         )
                      OR (
                             a.ReadOnlyIndicator IS NULL
                             AND b.ReadOnlyIndicator IS NOT NULL
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
                       a.TestInterpretationID,
                       NULL,
                       @AuditUserName,
                       @EIDSSObjectID
                FROM @TestInterpretationAfterEdit AS a
                    FULL JOIN @TestInterpretationBeforeEdit AS b
                        ON a.TestInterpretationID = b.TestInterpretationID
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
                (@DataAuditEventid, @ObjectTableID, @TestInterpretationID, @AuditUserName, @EIDSSObjectID);
            END
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
