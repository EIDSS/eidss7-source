-- ================================================================================================
-- Name: USSP_ADMIN_OBJECT_ACCESS_SET
--
-- Description:	Inserts or updates object access records for use case SAUC29.
--                      
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- -------------------------------------------------------------------
-- Stephen Long    12/21/2022 Initial release.
-- Stephen Long    12/27/2022 Added delete logic.
-- Stephen Long    03/14/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_ADMIN_OBJECT_ACCESS_SET]
(
    @ObjectAccessID BIGINT = NULL,
    @ObjectOperationTypeID BIGINT = NULL,
    @ObjectTypeID BIGINT = NULL,
    @ObjectID BIGINT = NULL,
    @ActorID BIGINT = NULL,
    @SiteID BIGINT = NULL,
    @PermissionTypeID INT = NULL,
    @RowStatus INT = NULL,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
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

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

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
        ELSE IF @RowStatus = 1
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
        ELSE
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

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
