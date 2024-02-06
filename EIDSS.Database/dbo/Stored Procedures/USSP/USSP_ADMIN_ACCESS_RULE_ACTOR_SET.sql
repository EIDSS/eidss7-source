-- ================================================================================================
-- Name: USSP_ADMIN_ACCESS_RULE_ACTOR_SET
--
-- Description:	Inserts or updates access rule actors for configurable site filtration of the 
-- administration module.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		11/11/2020 Initial release.
-- Stephen Long     12/27/2020 Added granting actor indicator.
-- Stephen Long     04/19/2021 Removed language ID and audit user name as not needed.
-- Stephen Long     03/14/2022 Changed row action to an int.
-- Stephen Long     03/16/2022 Corrected row action check from 0 to 1.
-- Mark Wilson		06/03/2022 Added Audit fields
-- Stephen Long     12/16/2022 Changed user name from 100 to 200.
-- Stephen Long     03/14/2023 Added reciprocal rule insert for granting actor, and data audit 
--                             logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_ADMIN_ACCESS_RULE_ACTOR_SET]
(
    @AccessRuleActorID BIGINT OUTPUT,
    @AccessRuleID BIGINT,
    @GrantingActorIndicator BIT = 0,
    @ActorSiteGroupID BIGINT = NULL,
    @ActorSiteID BIGINT = NULL,
    @ActorEmployeeGroupID BIGINT = NULL,
    @ActorUserID BIGINT = NULL,
    @RowStatus INT,
    @RowAction INT,
    @AuditUser NVARCHAR(200),
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
                @ObjectID BIGINT = NULL,
                @ObjectTableAccessRuleActorID BIGINT = 53577790000011; -- AccessRuleActor
        DECLARE @AccessRuleActorBeforeEdit TABLE
        (
            AccessRuleActorID BIGINT,
            AccessRuleID BIGINT,
            ActorSiteGroupID BIGINT,
            ActorSiteID BIGINT,
            ActorEmployeeGroupID BIGINT,
            ActorUserID BIGINT,
            GrantingActorIndicator BIT,
            RowStatus INT
        );
        DECLARE @AccessRuleActorAfterEdit TABLE
        (
            AccessRuleActorID BIGINT,
            AccessRuleID BIGINT,
            ActorSiteGroupID BIGINT,
            ActorSiteID BIGINT,
            ActorEmployeeGroupID BIGINT,
            ActorUserID BIGINT,
            GrantingActorIndicator BIT,
            RowStatus INT
        );

        SET @AuditUser = ISNULL(@AuditUser, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo;
        -- End data audit

        IF @RowAction = 1 -- Insert
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'AccessRuleActor',
                                              @idfsKey = @AccessRuleActorID OUTPUT;

            INSERT INTO dbo.AccessRuleActor
            (
                AccessRuleActorID,
                AccessRuleID,
                GrantingActorIndicator,
                ActorSiteGroupID,
                ActorSiteID,
                ActorEmployeeGroupID,
                ActorUserID,
                intRowStatus,
                AuditCreateUser,
                AuditCreateDTM,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@AccessRuleActorID,
             @AccessRuleID,
             @GrantingActorIndicator,
             @ActorSiteGroupID,
             @ActorSiteID,
             @ActorEmployeeGroupID,
             @ActorUserID,
             @RowStatus,
             @AuditUser,
             GETDATE(),
             10519001,
             '[{"AccessRuleActorID":' + CAST(@AccessRuleActorID AS NVARCHAR(24)) + '}]'
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
             @ObjectTableAccessRuleActorID,
             @AccessRuleActorID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableAccessRuleActorID AS NVARCHAR(300)) + '}]',
             @AuditUser,
             NULL
            );
        -- End data audit
        END
        ELSE
        BEGIN
            -- Data audit
            INSERT INTO @AccessRuleActorBeforeEdit
            SELECT AccessRuleActorID,
                   AccessRuleID,
                   ActorSiteGroupID,
                   ActorSiteID,
                   ActorEmployeeGroupID,
                   ActorUserID,
                   GrantingActorIndicator, 
                   intRowStatus
            FROM dbo.AccessRuleActor
            WHERE AccessRuleActorID = @AccessRuleActorID;
            -- End data audit

            UPDATE dbo.AccessRuleActor
            SET AccessRuleID = @AccessRuleID,
                GrantingActorIndicator = @GrantingActorIndicator,
                ActorSiteGroupID = @ActorSiteGroupID,
                ActorSiteID = @ActorSiteID,
                ActorEmployeeGroupID = @ActorEmployeeGroupID,
                ActorUserID = @ActorUserID,
                intRowStatus = @RowStatus,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUser
            WHERE AccessRuleActorID = @AccessRuleActorID;

            -- Data audit
            INSERT INTO @AccessRuleActorAfterEdit
            SELECT AccessRuleActorID,
                   AccessRuleID,
                   ActorSiteGroupID,
                   ActorSiteID,
                   ActorEmployeeGroupID,
                   ActorUserID,
                   GrantingActorIndicator, 
                   intRowStatus
            FROM dbo.AccessRuleActor
            WHERE AccessRuleActorID = @AccessRuleActorID;

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
                       @ObjectTableAccessRuleActorID,
                       51586990000112,
                       a.AccessRuleActorID,
                       NULL,
                       b.ActorSiteGroupID,
                       a.ActorSiteGroupID,
                       @AuditUser,
                       NULL
                FROM @AccessRuleActorAfterEdit AS a
                    FULL JOIN @AccessRuleActorBeforeEdit AS b
                        ON a.AccessRuleActorID = b.AccessRuleActorID
                WHERE (a.ActorSiteGroupID <> b.ActorSiteGroupID)
                      OR (
                             a.ActorSiteGroupID IS NOT NULL
                             AND b.ActorSiteGroupID IS NULL
                         )
                      OR (
                             a.ActorSiteGroupID IS NULL
                             AND b.ActorSiteGroupID IS NOT NULL
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
                       @ObjectTableAccessRuleActorID,
                       51586990000113,
                       a.AccessRuleActorID,
                       NULL,
                       b.ActorSiteID,
                       a.ActorSiteID,
                       @AuditUser,
                       NULL
                FROM @AccessRuleActorAfterEdit AS a
                    FULL JOIN @AccessRuleActorBeforeEdit AS b
                        ON a.AccessRuleActorID = b.AccessRuleActorID
                WHERE (a.ActorSiteID <> b.ActorSiteID)
                      OR (
                             a.ActorSiteID IS NOT NULL
                             AND b.ActorSiteID IS NULL
                         )
                      OR (
                             a.ActorSiteID IS NULL
                             AND b.ActorSiteID IS NOT NULL
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
                       @ObjectTableAccessRuleActorID,
                       51586990000114,
                       a.AccessRuleActorID,
                       NULL,
                       b.ActorEmployeeGroupID,
                       a.ActorEmployeeGroupID,
                       @AuditUser,
                       NULL
                FROM @AccessRuleActorAfterEdit AS a
                    FULL JOIN @AccessRuleActorBeforeEdit AS b
                        ON a.AccessRuleActorID = b.AccessRuleActorID
                WHERE (a.ActorEmployeeGroupID <> b.ActorEmployeeGroupID)
                      OR (
                             a.ActorEmployeeGroupID IS NOT NULL
                             AND b.ActorEmployeeGroupID IS NULL
                         )
                      OR (
                             a.ActorEmployeeGroupID IS NULL
                             AND b.ActorEmployeeGroupID IS NOT NULL
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
                       @ObjectTableAccessRuleActorID,
                       51586990000115,
                       a.AccessRuleActorID,
                       NULL,
                       b.ActorUserID,
                       a.ActorUserID,
                       @AuditUser,
                       NULL
                FROM @AccessRuleActorAfterEdit AS a
                    FULL JOIN @AccessRuleActorBeforeEdit AS b
                        ON a.AccessRuleActorID = b.AccessRuleActorID
                WHERE (a.ActorUserID <> b.ActorUserID)
                      OR (
                             a.ActorUserID IS NOT NULL
                             AND b.ActorUserID IS NULL
                         )
                      OR (
                             a.ActorUserID IS NULL
                             AND b.ActorUserID IS NOT NULL
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
                       @ObjectTableAccessRuleActorID,
                       51586990000117,
                       a.AccessRuleActorID,
                       NULL,
                       b.GrantingActorIndicator,
                       a.GrantingActorIndicator,
                       @AuditUser,
                       NULL
                FROM @AccessRuleActorAfterEdit AS a
                    FULL JOIN @AccessRuleActorBeforeEdit AS b
                        ON a.AccessRuleActorID = b.AccessRuleActorID
                WHERE (a.GrantingActorIndicator <> b.GrantingActorIndicator)
                      OR (
                             a.GrantingActorIndicator IS NOT NULL
                             AND b.GrantingActorIndicator IS NULL
                         )
                      OR (
                             a.GrantingActorIndicator IS NULL
                             AND b.GrantingActorIndicator IS NOT NULL
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
                SELECT @DataAuditEventID,
                       @ObjectTableAccessRuleActorID,
                       @AccessRuleID,
                       @AuditUser,
                       NULL;
            END
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
