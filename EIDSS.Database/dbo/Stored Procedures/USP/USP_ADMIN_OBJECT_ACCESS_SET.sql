-- ================================================================================================
-- Name: USP_ADMIN_OBJECT_ACCESS_SET
--
-- Description:	Inserts or updates object access records for use case SAUC62.
--                      
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- -------------------------------------------------------------------
-- Stephen Long    05/17/2020 Initial release.
-- Stephen Long    05/15/2021 Removed suppress select; EF does not need it.
-- Stephen Long    05/28/2021 Removed language ID as not needed for a set.
-- Stephen Long    03/14/2023 Added data audit for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_OBJECT_ACCESS_SET]
(
    @ObjectAccessRecords NVARCHAR(MAX) = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
                @RowAction CHAR = NULL,
                @RowID BIGINT = NULL,
                @ObjectAccessID BIGINT = NULL,
                @ObjectOperationTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = NULL,
                @ObjectID BIGINT = NULL,
                @ActorID BIGINT = NULL,
                @SiteID BIGINT = NULL,
                @PermissionTypeID INT = NULL,
                @RowStatus INT = NULL,
                @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                @DataAuditEventID BIGINT = NULL,
                @DataAuditObjectTypeID BIGINT = 10017015, -- Data access 
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTableID BIGINT = 76160000000;      -- tstObjectAccess
        DECLARE @ObjectAccessBeforeEdit TABLE
        (
            ObjectAccessID BIGINT,
            ObjectOperationTypeID BIGINT,
            ObjectTypeID BIGINT,
            ObjectID BIGINT,
            ActorID BIGINT,
            SiteID BIGINT,
            PermissionTypeID INT
        );
        DECLARE @ObjectAccessAfterEdit TABLE
        (
            ObjectAccessID BIGINT,
            ObjectOperationTypeID BIGINT,
            ObjectTypeID BIGINT,
            ObjectID BIGINT,
            ActorID BIGINT,
            SiteID BIGINT,
            PermissionTypeID INT
        );
        DECLARE @ObjectAccessRecordsTemp TABLE
        (
            ObjectAccessID BIGINT NOT NULL,
            ObjectOperationTypeID BIGINT NOT NULL,
            ObjectTypeID BIGINT NOT NULL,
            ObjectID BIGINT NOT NULL,
            ActorID BIGINT NOT NULL,
            SiteID BIGINT NOT NULL,
            PermissionTypeID INT NOT NULL,
            RowStatus INT NOT NULL,
            RowAction CHAR(1) NULL
        );

        BEGIN TRANSACTION;

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        INSERT INTO @ObjectAccessRecordsTemp
        SELECT *
        FROM
            OPENJSON(@ObjectAccessRecords)
            WITH
            (
                ObjectAccessID BIGINT,
                ObjectOperationTypeID BIGINT,
                ObjectTypeID BIGINT,
                ObjectID BIGINT,
                ActorID BIGINT,
                SiteID BIGINT,
                PermissionTypeID INT,
                RowStatus INT,
                RowAction CHAR(1)
            );

        WHILE EXISTS (SELECT * FROM @ObjectAccessRecordsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = ObjectAccessID,
                @ObjectAccessID = ObjectAccessID,
                @ObjectOperationTypeID = ObjectOperationTypeID,
                @ObjectTypeID = ObjectTypeID,
                @ObjectID = ObjectID,
                @ActorID = ActorID,
                @SiteID = SiteID,
                @PermissionTypeID = PermissionTypeID,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @ObjectAccessRecordsTemp;

            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.tstObjectAccess
                WHERE idfObjectAccess = @ObjectAccessID
                      AND intRowStatus = 0
            )
            BEGIN
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tstObjectAccess',
                                                  @ObjectAccessID OUTPUT;

                INSERT INTO dbo.tstObjectAccess
                (
                    idfObjectAccess,
                    idfsObjectOperation,
                    idfsObjectType,
                    idfsObjectID,
                    idfActor,
                    idfsOnSite,
                    intPermission,
                    intRowStatus, 
                    SourceSystemNameID,
                    SourceSystemKeyValue
                )
                VALUES
                (@ObjectAccessID,
                 @ObjectOperationTypeID,
                 @ObjectTypeID,
                 @ObjectID,
                 @ActorID,
                 @SiteID,
                 @PermissionTypeID,
                 @RowStatus, 
                 10519002,
                 '[{"idfObjectAccess":' + CAST(@ObjectAccessID AS NVARCHAR(24)) + '}]'
                );

                -- Data audit
                SET @DataAuditEventTypeID = 10016001; -- Create data audit event type
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @DataAuditObjectTypeID,
                                                          @ObjectAccessID,
                                                          @ObjectTableID,
                                                          NULL,
                                                          @DataAuditEventID OUTPUT;

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
                 @ObjectAccessID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 NULL
                );
            -- End data audit
            END
            ELSE IF @RowAction = 'D'
            BEGIN
                DELETE FROM dbo.tstObjectAccess
                WHERE idfObjectAccess = @ObjectAccessID;

                -- Data audit
                SET @DataAuditEventTypeID = 10016002; -- Delete data audit event type
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @DataAuditObjectTypeID,
                                                          @ObjectAccessID,
                                                          @ObjectTableID,
                                                          NULL,
                                                          @DataAuditEventID OUTPUT;

                INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableID,
                       @ObjectAccessID,
                       @AuditUserName,
                       NULL;
            -- End data audit
            END
            ELSE IF @RowAction = 'U'
            BEGIN
                -- Data audit
                SET @DataAuditEventTypeID = 10016003; -- Edit data audit event type
                EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                          @AuditSiteID,
                                                          @DataAuditEventTypeID,
                                                          @DataAuditObjectTypeID,
                                                          @ObjectAccessID,
                                                          @ObjectTableID,
                                                          NULL,
                                                          @DataAuditEventID OUTPUT;

                INSERT INTO @ObjectAccessBeforeEdit
                SELECT idfObjectAccess,
                       idfsObjectOperation,
                       idfsObjectType,
                       idfsObjectID,
                       idfActor,
                       idfsOnSite,
                       intPermission
                FROM dbo.tstObjectAccess
                WHERE idfObjectAccess = @ObjectAccessID;
                -- End data audit

                UPDATE dbo.tstObjectAccess
                SET idfsObjectOperation = @ObjectOperationTypeID,
                    idfsObjectType = @ObjectTypeID,
                    idfsObjectID = @ObjectID,
                    idfActor = @ActorID,
                    idfsOnSite = @SiteID,
                    intPermission = @PermissionTypeID,
                    intRowStatus = @RowStatus
                WHERE idfObjectAccess = @ObjectAccessID;

                -- Data audit
                INSERT INTO @ObjectAccessAfterEdit
                SELECT idfObjectAccess,
                       idfsObjectOperation,
                       idfsObjectType,
                       idfsObjectID,
                       idfActor,
                       idfsOnSite,
                       intPermission
                FROM dbo.tstObjectAccess
                WHERE idfObjectAccess = @ObjectAccessID;

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue
                )
                SELECT @DataAuditEventID,
                       76160000000,
                       82000000000,
                       a.ObjectAccessID,
                       NULL,
                       b.ObjectOperationTypeID,
                       a.ObjectOperationTypeID
                FROM @ObjectAccessAfterEdit AS a
                    FULL JOIN @ObjectAccessBeforeEdit AS b
                        ON a.ObjectAccessID = b.ObjectAccessID
                WHERE (a.ObjectOperationTypeID <> b.ObjectOperationTypeID)
                      OR (
                             a.ObjectOperationTypeID IS NOT NULL
                             AND b.ObjectOperationTypeID IS NULL
                         )
                      OR (
                             a.ObjectOperationTypeID IS NULL
                             AND b.ObjectOperationTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue
                )
                SELECT @DataAuditEventID,
                       76160000000,
                       82010000000,
                       a.ObjectAccessID,
                       NULL,
                       b.ObjectTypeID,
                       a.ObjectTypeID
                FROM @ObjectAccessAfterEdit AS a
                    FULL JOIN @ObjectAccessBeforeEdit AS b
                        ON a.ObjectAccessID = b.ObjectAccessID
                WHERE (a.ObjectTypeID <> b.ObjectTypeID)
                      OR (
                             a.ObjectTypeID IS NOT NULL
                             AND b.ObjectTypeID IS NULL
                         )
                      OR (
                             a.ObjectTypeID IS NULL
                             AND b.ObjectTypeID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue
                )
                SELECT @DataAuditEventID,
                       76160000000,
                       81990000000,
                       a.ObjectAccessID,
                       NULL,
                       b.ObjectID,
                       a.ObjectID
                FROM @ObjectAccessAfterEdit AS a
                    FULL JOIN @ObjectAccessBeforeEdit AS b
                        ON a.ObjectAccessID = b.ObjectAccessID
                WHERE (a.ObjectID <> b.ObjectID)
                      OR (
                             a.ObjectID IS NOT NULL
                             AND b.ObjectID IS NULL
                         )
                      OR (
                             a.ObjectID IS NULL
                             AND b.ObjectID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue
                )
                SELECT @DataAuditEventID,
                       76160000000,
                       81980000000,
                       a.ObjectAccessID,
                       NULL,
                       b.ActorID,
                       a.ActorID
                FROM @ObjectAccessAfterEdit AS a
                    FULL JOIN @ObjectAccessBeforeEdit AS b
                        ON a.ObjectAccessID = b.ObjectAccessID
                WHERE (a.ActorID <> b.ActorID)
                      OR (
                             a.ActorID IS NOT NULL
                             AND b.ActorID IS NULL
                         )
                      OR (
                             a.ActorID IS NULL
                             AND b.ActorID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue
                )
                SELECT @DataAuditEventID,
                       76160000000,
                       82020000000,
                       a.ObjectAccessID,
                       NULL,
                       b.SiteID,
                       a.SiteID
                FROM @ObjectAccessAfterEdit AS a
                    FULL JOIN @ObjectAccessBeforeEdit AS b
                        ON a.ObjectAccessID = b.ObjectAccessID
                WHERE (a.SiteID <> b.SiteID)
                      OR (
                             a.SiteID IS NOT NULL
                             AND b.SiteID IS NULL
                         )
                      OR (
                             a.SiteID IS NULL
                             AND b.SiteID IS NOT NULL
                         );

                INSERT INTO dbo.tauDataAuditDetailUpdate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfColumn,
                    idfObject,
                    idfObjectDetail,
                    strOldValue,
                    strNewValue
                )
                SELECT @DataAuditEventID,
                       76160000000,
                       82030000000,
                       a.ObjectAccessID,
                       NULL,
                       b.PermissionTypeID,
                       a.PermissionTypeID
                FROM @ObjectAccessAfterEdit AS a
                    FULL JOIN @ObjectAccessBeforeEdit AS b
                        ON a.ObjectAccessID = b.ObjectAccessID
                WHERE (a.PermissionTypeID <> b.PermissionTypeID)
                      OR (
                             a.PermissionTypeID IS NOT NULL
                             AND b.PermissionTypeID IS NULL
                         )
                      OR (
                             a.PermissionTypeID IS NULL
                             AND b.PermissionTypeID IS NOT NULL
                         );
            END

            DELETE FROM @ObjectAccessRecordsTemp
            WHERE ObjectAccessID = @RowID;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
