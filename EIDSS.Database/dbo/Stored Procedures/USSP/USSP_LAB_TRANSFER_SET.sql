-- ================================================================================================
-- Name: USSP_LAB_TRANSFER_SET
--
-- Description:	Inserts or updates transfer records for various use cases.
--
-- Revision History:
-- Name  Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/01/2018 Initial release.
-- Stephen Long     02/19/2019 Added test requested parameter to match use case.
-- Stephen Long     03/30/2020 Added set of audit update time and user on record inserts/updates.
-- Stephen Long     02/11/2021 Added logic to set transfer indicator.
-- Stephen Long     09/24/2021 Removed language ID parameter as it is not needed.
-- Stephen Long     01/31/2022 Added source system name and key value update on insert.
-- Stephen Long     02/22/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_LAB_TRANSFER_SET]
(
    @TransferID BIGINT OUTPUT,
    @SampleID BIGINT,
    @EIDSSTransferID NVARCHAR(200) = NULL,
    @TransferStatusTypeID BIGINT,
    @TransferredFromOrganizationID BIGINT = NULL,
    @TransferredToOrganizationID BIGINT = NULL,
    @SentByPersonID BIGINT = NULL,
    @TransferDate DATETIME = NULL,
    @Note NVARCHAR(200) = NULL,
    @SiteID BIGINT,
    @TestRequested NVARCHAR(200) = NULL,
    @RowStatus INT,
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
                @ObjectTypeID BIGINT = 10017056,                     -- Sample Transfer
                @ObjectTableTransferOutID BIGINT = 75770000000,      -- tlbTransferOUT
                @ObjectTableTransferSampleID BIGINT = 4576460000000, -- tlbTransferOutMaterial
                @ObjectTableSampleID BIGINT = 75620000000;           -- tlbMaterial
        DECLARE @TransferBeforeEdit TABLE
        (
            TransferID BIGINT,
            TransferStatusTypeID BIGINT,
            TransferredFromOrganizationID BIGINT,
            TransferredToOrganizationID BIGINT,
            SentByPersonID BIGINT,
            TransferDate DATETIME,
            Note NVARCHAR(200),
            EIDSSTransferID NVARCHAR(200),
            TestRequested NVARCHAR(200),
            RowStatus INT
        );
        DECLARE @TransferAfterEdit TABLE
        (
            TransferID BIGINT,
            TransferStatusTypeID BIGINT,
            TransferredFromOrganizationID BIGINT,
            TransferredToOrganizationID BIGINT,
            SentByPersonID BIGINT,
            TransferDate DATETIME,
            Note NVARCHAR(200),
            EIDSSTransferID NVARCHAR(200),
            TestRequested NVARCHAR(200),
            RowStatus INT
        );
        DECLARE @TransferSampleBeforeEdit TABLE
        (
            TransferID BIGINT,
            SampleID BIGINT,
            RowStatus INT
        );
        DECLARE @TransferSampleAfterEdit TABLE
        (
            TransferID BIGINT,
            SampleID BIGINT,
            RowStatus INT
        );
        DECLARE @SampleBeforeEdit TABLE
        (
            SampleID BIGINT,
            TransferIndicator BIT
        );
        DECLARE @SampleAfterEdit TABLE
        (
            SampleID BIGINT,
            TransferIndicator BIT
        );

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbTransferOut',
                                              @idfsKey = @TransferID OUTPUT;

            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Sample Transfer Barcode',
                                               @NextNumberValue = @EIDSSTransferID OUTPUT,
                                               @InstallationSite = NULL;

            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @TransferID,
                                                      @ObjectTableTransferOutID,
                                                      @EIDSSTransferID,
                                                      @DataAuditEventID OUTPUT;
        END
        ELSE
        BEGIN
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @TransferID,
                                                      @ObjectTableTransferOutID,
                                                      @EIDSSTransferID,
                                                      @DataAuditEventID OUTPUT;
        END
        -- End data audit

        IF @RowStatus = 0
        BEGIN
            IF @TransferStatusTypeID = 10001001 -- Final
            BEGIN
                -- Data audit
                INSERT INTO @SampleBeforeEdit
                SELECT idfMaterial,
                       TransferIndicator
                FROM dbo.tlbMaterial
                WHERE idfMaterial = @SampleID;
                -- End data audit

                UPDATE dbo.tlbMaterial
                SET TransferIndicator = 0
                WHERE idfMaterial = @SampleID;

                -- Data audit
                INSERT INTO @SampleAfterEdit
                SELECT idfMaterial,
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
                       51586990000039,
                       a.SampleID,
                       NULL,
                       b.TransferIndicator,
                       a.TransferIndicator,
                       @AuditUserName,
                       @EIDSSTransferID
                FROM @SampleAfterEdit a
                    FULL JOIN @SampleBeforeEdit b
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
            -- End data audit
            END
            ELSE
            BEGIN
                -- Data audit
                INSERT INTO @SampleBeforeEdit
                SELECT idfMaterial,
                       TransferIndicator
                FROM dbo.tlbMaterial
                WHERE idfMaterial = @SampleID;
                -- End data audit

                UPDATE dbo.tlbMaterial
                SET TransferIndicator = 1
                WHERE idfMaterial = @SampleID;

                -- Data audit
                INSERT INTO @SampleAfterEdit
                SELECT idfMaterial,
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
                       51586990000039,
                       a.SampleID,
                       NULL,
                       b.TransferIndicator,
                       a.TransferIndicator,
                       @AuditUserName,
                       @EIDSSTransferID
                FROM @SampleAfterEdit a
                    FULL JOIN @SampleBeforeEdit b
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
            -- End data audit
            END
        END
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @SampleBeforeEdit
            SELECT idfMaterial,
                   TransferIndicator
            FROM dbo.tlbMaterial
            WHERE idfMaterial = @SampleID;
            -- End data audit

            UPDATE dbo.tlbMaterial
            SET TransferIndicator = 0
            WHERE idfMaterial = @SampleID;

            -- Data audit
            INSERT INTO @SampleAfterEdit
            SELECT idfMaterial,
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
                   51586990000039,
                   a.SampleID,
                   NULL,
                   b.TransferIndicator,
                   a.TransferIndicator,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @SampleAfterEdit a
                FULL JOIN @SampleBeforeEdit b
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
        -- End data audit
        END;

        IF @RowAction = 1 -- Insert
        BEGIN
            INSERT INTO dbo.tlbTransferOUT
            (
                idfTransferOut,
                idfsTransferStatus,
                idfSendFromOffice,
                idfSendToOffice,
                idfSendByPerson,
                datSendDate,
                strNote,
                strBarcode,
                idfsSite,
                TestRequested,
                intRowStatus,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (@TransferID,
             @TransferStatusTypeID,
             @TransferredFromOrganizationID,
             @TransferredToOrganizationID,
             @SentByPersonID,
             @TransferDate,
             @Note,
             @EIDSSTransferID,
             @SiteID,
             @TestRequested,
             @RowStatus,
             10519001,
             '[{"idfTransferOut":' + CAST(@TransferID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );

            INSERT INTO dbo.tlbTransferOutMaterial
            (
                idfMaterial,
                idfTransferOut,
                intRowStatus,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (@SampleID,
             @TransferID,
             0  ,
             10519001,
             '[{"idfTransferOut":' + CAST(@TransferID AS NVARCHAR(300)) + ',"idfMaterial":'
             + CAST(@SampleID AS NVARCHAR(300)) + '}]',
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
             @ObjectTableTransferOutID,
             @TransferID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableTransferOutID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSTransferID
            );

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
             @ObjectTableTransferSampleID,
             @SampleID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableTransferSampleID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSTransferID
            );
        -- End data audit
        END;
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @TransferBeforeEdit
            SELECT idfTransferOut,
                   idfsTransferStatus,
                   idfSendFromOffice,
                   idfSendToOffice,
                   idfSendByPerson,
                   datSendDate,
                   strNote,
                   strBarcode,
                   TestRequested,
                   intRowStatus
            FROM dbo.tlbTransferOUT
            WHERE idfTransferOut = @TransferID;
            -- End data audit

            UPDATE dbo.tlbTransferOUT
            SET idfsTransferStatus = @TransferStatusTypeID,
                idfSendFromOffice = @TransferredFromOrganizationID,
                idfSendToOffice = @TransferredToOrganizationID,
                idfSendByPerson = @SentByPersonID,
                datSendDate = @TransferDate,
                strNote = @Note,
                strBarcode = @EIDSSTransferID,
                idfsSite = @SiteID,
                TestRequested = @TestRequested,
                intRowStatus = @RowStatus,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfTransferOut = @TransferID;

            -- Data audit
            INSERT INTO @TransferAfterEdit
            SELECT idfTransferOut,
                   idfsTransferStatus,
                   idfSendFromOffice,
                   idfSendToOffice,
                   idfSendByPerson,
                   datSendDate,
                   strNote,
                   strBarcode,
                   TestRequested,
                   intRowStatus
            FROM dbo.tlbTransferOUT
            WHERE idfTransferOut = @TransferID;

            INSERT INTO @TransferSampleBeforeEdit
            SELECT idfTransferOut,
                   idfMaterial, 
                   intRowStatus
            FROM dbo.tlbTransferOutMaterial
            WHERE idfTransferOut = @TransferID;
            -- End data audit

            UPDATE dbo.tlbTransferOutMaterial
            SET intRowStatus = @RowStatus,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfTransferOut = @TransferID;

            -- Data audit
            INSERT INTO @TransferSampleAfterEdit
            SELECT idfTransferOut,
                   idfMaterial, 
                   intRowStatus
            FROM dbo.tlbTransferOutMaterial
            WHERE idfTransferOut = @TransferID;

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
                   80720000000,
                   a.TransferID,
                   NULL,
                   b.TransferDate,
                   a.TransferDate,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
            WHERE (a.TransferDate <> b.TransferDate)
                  OR (
                         a.TransferDate IS NOT NULL
                         AND b.TransferDate IS NULL
                     )
                  OR (
                         a.TransferDate IS NULL
                         AND b.TransferDate IS NOT NULL
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
                   @ObjectTableTransferOutID,
                   80730000000,
                   a.TransferID,
                   NULL,
                   b.SentByPersonID,
                   a.SentByPersonID,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
            WHERE (a.SentByPersonID <> b.SentByPersonID)
                  OR (
                         a.SentByPersonID IS NOT NULL
                         AND b.SentByPersonID IS NULL
                     )
                  OR (
                         a.SentByPersonID IS NULL
                         AND b.SentByPersonID IS NOT NULL
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
                   @ObjectTableTransferOutID,
                   80740000000,
                   a.TransferID,
                   NULL,
                   b.TransferredFromOrganizationID,
                   a.TransferredFromOrganizationID,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
            WHERE (a.TransferredFromOrganizationID <> b.TransferredFromOrganizationID)
                  OR (
                         a.TransferredFromOrganizationID IS NOT NULL
                         AND b.TransferredFromOrganizationID IS NULL
                     )
                  OR (
                         a.TransferredFromOrganizationID IS NULL
                         AND b.TransferredFromOrganizationID IS NOT NULL
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
                   @ObjectTableTransferOutID,
                   80750000000,
                   a.TransferID,
                   NULL,
                   b.TransferredToOrganizationID,
                   a.TransferredToOrganizationID,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
            WHERE (a.TransferredToOrganizationID <> b.TransferredToOrganizationID)
                  OR (
                         a.TransferredToOrganizationID IS NOT NULL
                         AND b.TransferredToOrganizationID IS NULL
                     )
                  OR (
                         a.TransferredToOrganizationID IS NULL
                         AND b.TransferredToOrganizationID IS NOT NULL
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
                   @ObjectTableTransferOutID,
                   80770000000,
                   a.TransferID,
                   NULL,
                   b.Note,
                   a.Note,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
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
                   @ObjectTableTransferOutID,
                   4577940000000,
                   a.TransferID,
                   NULL,
                   b.TransferStatusTypeID,
                   a.TransferStatusTypeID,
                   @AuditUserName,
                   @EIDSSTransferID
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
                   4577950000000,
                   a.TransferID,
                   NULL,
                   b.EIDSSTransferID,
                   a.EIDSSTransferID,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
            WHERE (a.EIDSSTransferID <> b.EIDSSTransferID)
                  OR (
                         a.EIDSSTransferID IS NOT NULL
                         AND b.EIDSSTransferID IS NULL
                     )
                  OR (
                         a.EIDSSTransferID IS NULL
                         AND b.EIDSSTransferID IS NOT NULL
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
                   @ObjectTableTransferOutID,
                   51586990000040,
                   a.TransferID,
                   NULL,
                   b.TestRequested,
                   a.TestRequested,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit a
                FULL JOIN @TransferBeforeEdit b
                    ON a.TransferID = b.TransferID
            WHERE (a.TestRequested <> b.TestRequested)
                  OR (
                         a.TestRequested IS NOT NULL
                         AND b.TestRequested IS NULL
                     )
                  OR (
                         a.TestRequested IS NULL
                         AND b.TestRequested IS NOT NULL
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
                   @ObjectTableTransferOutID,
                   a.TransferID,
                   NULL,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferAfterEdit AS a
                FULL JOIN @TransferBeforeEdit AS b
                    ON a.TransferID = b.TransferID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;

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
                   @ObjectTableTransferSampleID,
                   a.SampleID,
                   NULL,
                   @AuditUserName,
                   @EIDSSTransferID
            FROM @TransferSampleAfterEdit AS a
                FULL JOIN @TransferSampleBeforeEdit AS b
                    ON a.SampleID = b.SampleID
            WHERE a.RowStatus = 0
                  AND b.RowStatus = 1;
        -- End data audit
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
