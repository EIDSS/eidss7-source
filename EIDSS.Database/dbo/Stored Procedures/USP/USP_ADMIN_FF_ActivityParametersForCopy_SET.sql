-- ================================================================================================
-- Name: USP_ADMIN_FF_ActivityParameters_SET
--
-- Description: Set the answers for a flex form AS an activity for that parameter
--          
-- Revision History:
-- Name             Date       Change
-- ---------------- ---------- --------------------------------------------------------------------
-- Doug Albanese	12/30/2022	 Nested Inserts are messing with this process. So I'm creating a "copy" version to work with the copy of a flex form
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ActivityParametersForCopy_SET]
(
    @idfObservation BIGINT = NULL,
    @idfsFormTemplate BIGINT,
    @answers NVARCHAR(MAX),
    @User NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnCode BIGINT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'Success',
                                                                   -- added for case compares
            @TextBox BIGINT = 10067008,
            @TextBoxTotal BIGINT = 10067010,
            @TextBoxSum BIGINT = 10067011,
            @MemoBox BIGINT = 10067006,
            @DateControl BIGINT = 10067003,
            @DateTimeControl BIGINT = 10067004,
            @UpDown BIGINT = 10067009,
            @ComboBox BIGINT = 10067002,
            @RadioButton BIGINT = 217210000000,
            @CheckBoxDeclare BIGINT = 10067001,
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @DataAuditEventID BIGINT = NULL,
            @DataAuditEventTypeID BIGINT = NULL,
            @ObjectID BIGINT = NULL,
            @ObjectObservationTableID BIGINT = 75640000000,        -- tlbObservation
            @ObjectActivityParametersTableID BIGINT = 75410000000; -- tlbActivityParameters
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(MAX)
    );
    DECLARE @ActivityParametersBeforeEdit TABLE
    (
        ActivityParametersID BIGINT,
        ParameterID BIGINT,
        ObservationID BIGINT,
        RowID BIGINT NULL,
        AnswerValue SQL_VARIANT NULL,
        RowStatus INT
    );
    DECLARE @ActivityParametersAfterEdit TABLE
    (
        ActivityParametersID BIGINT,
        ParameterID BIGINT,
        ObservationID BIGINT,
        RowID BIGINT NULL,
        AnswerValue SQL_VARIANT NULL,
        RowStatus INT
    );

    BEGIN TRY
        DECLARE @idfActivityParameters BIGINT,
                @idfsParameter BIGINT,
                @answer_SV SQL_VARIANT,
                @answer NVARCHAR(4000),
                @idfsEditor BIGINT,
                @idfRow BIGINT;
        DECLARE @tAnswers TABLE
        (
            idfsParameter BIGINT NULL,
            idfsEditor BIGINT NULL,
            answer NVARCHAR(4000),
            idfRow BIGINT NULL
        );

        INSERT INTO @tAnswers
        SELECT idfsParameter,
               idfsEditor,
               answer,
               idfRow
        FROM
            OPENJSON(@answers)
            WITH
            (
                idfsParameter BIGINT,
                idfsEditor BIGINT,
                answer NVARCHAR(4000),
                idfRow BIGINT
            );

        IF @idfObservation IS NULL
        BEGIN
            --INSERT INTO @SuppressSelect
            EXEC USP_GBL_NEXTKEYID_GET 'tlbObservation', @idfObservation OUTPUT;
        END

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.tlbObservation
            WHERE idfObservation = @idfObservation
        )
        BEGIN
            INSERT INTO dbo.tlbObservation
            (
                idfObservation,
                idfsFormTemplate,
                intRowStatus,
                rowguid,
                idfsSite,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@idfObservation,
             @idfsFormTemplate,
             0  ,
             NEWID(),
             dbo.FN_GBL_SITEID_GET(),
             10519001,
             '[{"idfObservation":' + CAST(@idfObservation AS NVARCHAR(100)) + '}]',
             @User,
             GETDATE(),
             @User,
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
                AuditCreateUser
            )
            VALUES
            (NULL,
             @ObjectObservationTableID,
             @idfObservation,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectObservationTableID AS NVARCHAR(300)) + '}]',
             @User
            );
        -- End data audit
        END

        WHILE EXISTS (SELECT * FROM @tAnswers)
        BEGIN
            SELECT TOP 1
                @idfsParameter = idfsParameter,
                @answer = answer,
                @idfsEditor = idfsEditor,
                @idfRow = idfRow
            FROM @tAnswers;
            IF @idfsEditor = @TextBox
                SET @answer_SV = CAST(@answer AS NVARCHAR);
            IF @idfsEditor = @TextBoxTotal
                SET @answer_SV = CAST(@answer AS NVARCHAR);
            IF @idfsEditor = @TextBoxSum
                SET @answer_SV = CAST(@answer AS NVARCHAR);
            IF @idfsEditor = @MemoBox
                SET @answer_SV = CAST(@answer AS NVARCHAR);
            IF @idfsEditor = @DateControl
                SET @answer_SV = CAST(@answer AS DATETIME);
            IF @idfsEditor = @DateTimeControl
                SET @answer_SV = CAST(@answer AS DATETIME);
            IF @idfsEditor = @UpDown
                SET @answer_SV = CAST(@answer AS BIGINT);
            IF @idfsEditor = @ComboBox
                SET @answer_SV = CAST(@answer AS BIGINT);
            IF @idfsEditor = @RadioButton
                SET @answer_SV = CAST(@answer AS BIGINT);
            IF @idfsEditor = @CheckBoxDeclare
                SET @answer_SV = CAST(@answer AS BIT);

            SET ROWCOUNT 1;
            DELETE FROM @tAnswers;
            SET ROWCOUNT 0;

            IF @answer_SV <> ''
            BEGIN
                IF (
                       (@answer_SV IS NULL)
                       OR (LEN(CAST(@answer_SV AS NVARCHAR(4000))) = 0)
                   )
                BEGIN
                    --INSERT INTO @SuppressSelect
                    EXEC dbo.USP_ADMIN_FF_ActivityParameters_DEL @idfsParameter,
                                                                 @idfObservation,
                                                                 @idfRow;
                END
                ELSE
                BEGIN
                    IF NOT EXISTS
                    (
                        SELECT TOP 1 1
                        FROM dbo.tlbActivityParameters
                        WHERE idfsParameter = @idfsParameter
                              AND idfObservation = @idfObservation
                              AND idfRow = @idfRow
                    )
                    BEGIN
                        --INSERT INTO @SuppressSelect
                        EXEC USP_GBL_NEXTKEYID_GET 'tlbActivityParameters',
                                                   @idfActivityParameters OUTPUT;

                        INSERT INTO dbo.tlbActivityParameters
                        (
                            idfActivityParameters,
                            idfsParameter,
                            idfObservation,
                            idfRow,
                            varValue,
                            intRowStatus,
                            rowguid,
                            SourceSystemNameID,
                            SourceSystemKeyValue,
                            AuditCreateUser,
                            AuditCreateDTM,
                            AuditUpdateUser,
                            AuditUpdateDTM
                        )
                        VALUES
                        (@idfActivityParameters,
                         @idfsParameter,
                         @idfObservation,
                         @idfRow,
                         @answer_SV,
                         0  ,
                         NEWID(),
                         10519001,
                         '[{"idfActivityParameters":' + CAST(@idfActivityParameters AS NVARCHAR(100)) + '}]',
                         @User,
                         GETDATE(),
                         @User,
                         GETDATE()
                        );

                        -- Data audit
                        INSERT INTO dbo.tauDataAuditDetailCreate
                        (
                            idfDataAuditEvent,
                            idfObjectTable,
                            idfObject,
                            idfObjectDetail,
                            SourceSystemNameID,
                            SourceSystemKeyValue,
                            AuditCreateUser
                        )
                        VALUES
                        (NULL,
                         @ObjectActivityParametersTableID,
                         @idfActivityParameters,
                         @idfObservation,
                         10519001,
                         '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                         + CAST(@ObjectActivityParametersTableID AS NVARCHAR(300)) + '}]',
                         @User
                        );
                    -- End data audit
                    END
                    ELSE
                    BEGIN
                        SET @User = ISNULL(@User, 'System');

                        DELETE FROM @ActivityParametersAfterEdit;
                        DELETE FROM @ActivityParametersBeforeEdit;

                        -- Data audit
                        -- Get and set user and site identifiers
                        SELECT @AuditUserID = userInfo.UserId,
                               @AuditSiteID = userInfo.SiteId
                        FROM dbo.FN_UserSiteInformation(@User) userInfo;

                        INSERT INTO @ActivityParametersBeforeEdit
                        (
                            ActivityParametersID,
                            ParameterID,
                            ObservationID,
                            RowID,
                            AnswerValue,
                            RowStatus
                        )
                        SELECT idfActivityParameters,
                               idfsParameter,
                               idfObservation,
                               idfRow,
                               varValue,
                               intRowStatus
                        FROM dbo.tlbActivityParameters
                        WHERE idfsParameter = @idfsParameter
                              AND idfObservation = @idfObservation 
                              AND idfRow = @idfRow;

                        UPDATE dbo.tlbActivityParameters
                        SET varValue = @answer_SV,
                            intRowStatus = 0,
                            AuditUpdateUser = @User,
                            AuditUpdateDTM = GETDATE()
                        WHERE idfsParameter = @idfsParameter
                              AND idfObservation = @idfObservation
                              AND idfRow = @idfRow;

                        INSERT INTO @ActivityParametersAfterEdit
                        (
                            ActivityParametersID,
                            ParameterID,
                            ObservationID,
                            RowID,
                            AnswerValue,
                            RowStatus
                        )
                        SELECT idfActivityParameters,
                               idfsParameter,
                               idfObservation,
                               idfRow,
                               varValue,
                               intRowStatus
                        FROM dbo.tlbActivityParameters
                        WHERE idfsParameter = @idfsParameter
                              AND idfObservation = @idfObservation
                              AND idfRow = @idfRow;

                        INSERT INTO dbo.tauDataAuditDetailUpdate
                        (
                            idfDataAuditEvent,
                            idfObjectTable,
                            idfColumn,
                            idfObject,
                            idfObjectDetail,
                            strOldValue,
                            strNewValue,
                            AuditCreateUser
                        )
                        SELECT NULL,
                               @ObjectActivityParametersTableID,
                               78180000000,
                               a.ActivityParametersID,
                               @idfObservation,
                               b.ParameterID,
                               a.ParameterID,
                               @User
                        FROM @ActivityParametersAfterEdit AS a
                            FULL JOIN @ActivityParametersBeforeEdit AS b
                                ON a.ActivityParametersID = b.ActivityParametersID
                        WHERE (a.ParameterID <> b.ParameterID)
                              OR (
                                     a.ParameterID IS NOT NULL
                                     AND b.ParameterID IS NULL
                                 )
                              OR (
                                     a.ParameterID IS NULL
                                     AND b.ParameterID IS NOT NULL
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
                            AuditCreateUser
                        )
                        SELECT NULL,
                               @ObjectActivityParametersTableID,
                               78170000000,
                               a.ActivityParametersID,
                               @idfObservation,
                               b.ObservationID,
                               a.ObservationID,
                               @User
                        FROM @ActivityParametersAfterEdit AS a
                            FULL JOIN @ActivityParametersBeforeEdit AS b
                                ON a.ActivityParametersID = b.ActivityParametersID
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
                            AuditCreateUser
                        )
                        SELECT NULL,
                               @ObjectActivityParametersTableID,
                               4576590000000,
                               a.ActivityParametersID,
                               @idfObservation,
                               b.RowID,
                               a.RowID,
                               @User
                        FROM @ActivityParametersAfterEdit AS a
                            FULL JOIN @ActivityParametersBeforeEdit AS b
                                ON a.ActivityParametersID = b.ActivityParametersID
                        WHERE (a.RowID <> b.RowID)
                              OR (
                                     a.RowID IS NOT NULL
                                     AND b.RowID IS NULL
                                 )
                              OR (
                                     a.RowID IS NULL
                                     AND b.RowID IS NOT NULL
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
                            AuditCreateUser
                        )
                        SELECT NULL,
                               @ObjectActivityParametersTableID,
                               78190000000,
                               a.ActivityParametersID,
                               @idfObservation,
                               b.AnswerValue,
                               a.AnswerValue,
                               @User
                        FROM @ActivityParametersAfterEdit AS a
                            FULL JOIN @ActivityParametersBeforeEdit AS b
                                ON a.ActivityParametersID = b.ActivityParametersID
                        WHERE (a.AnswerValue <> b.AnswerValue)
                              OR (
                                     a.AnswerValue IS NOT NULL
                                     AND b.AnswerValue IS NULL
                                 )
                              OR (
                                     a.AnswerValue IS NULL
                                     AND b.AnswerValue IS NOT NULL
                                 );

                        INSERT INTO dbo.tauDataAuditDetailRestore
                        (
                            idfDataAuditEvent,
                            idfObjectTable,
                            idfObject,
                            idfObjectDetail,
                            AuditCreateUser
                        )
                        SELECT NULL,
                               @ObjectActivityParametersTableID,
                               a.ActivityParametersID,
                               @idfObservation,
                               @User
                        FROM @ActivityParametersAfterEdit AS a
                            FULL JOIN @ActivityParametersBeforeEdit AS b
                                ON a.ActivityParametersID = b.ActivityParametersID
                        WHERE a.RowStatus = 0
                              AND b.RowStatus = 1;
                    END
                END
            END
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @idfObservation AS idfObservation;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
