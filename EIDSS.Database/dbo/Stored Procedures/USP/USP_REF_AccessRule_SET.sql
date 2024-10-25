-- ================================================================================================
-- Name: USP_REF_AccessRule_SET
--
-- Description:	Inserts or updates an access rule for configurable filtration.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		06/03/2022 Initial release.
-- Stephen Long     06/04/2022 Correction on reference type ID, and changed to use API save 
--                             response model with key ID and key name.
-- Stephen Long     12/28/2022 Fix to source system key value ID.
-- Stephen Long     03/14/2023 Added reciprocal rule insert for granting actor, and data audit 
--                             logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_AccessRule_SET]
(
    @AccessRuleID BIGINT = NULL,
    @AccessRuleName VARCHAR(200),
    @strNationalName NVARCHAR(200),
    @LangId NVARCHAR(50),
    @intOrder INT = NULL,
    @BorderingAreaRuleIndicator BIT = 0,
    @DefaultRuleIndicator BIT = 0,
    @ReciprocalRuleIndicator BIT = 0,
    @GrantingActorSiteGroupID BIGINT = NULL,
    @GrantingActorSiteID BIGINT = NULL,
    @AccessToPersonalDataPermissionIndicator BIT = 0,
    @AccessToGenderAndAgeDataPermissionIndicator BIT = 0,
    @CreatePermissionIndicator BIT = 0,
    @DeletePermissionIndicator BIT = 0,
    @ReadPermissionIndicator BIT = 0,
    @WritePermissionIndicator BIT = 0,
    @AdministrativeLevelTypeID BIGINT = NULL,
    @RowStatus INT = 0,
    @ReceivingActors NVARCHAR(MAX) = NULL,
    @AuditUser NVARCHAR(200)
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
            @RowAction CHAR = NULL,
            @RowID BIGINT = NULL,
            @AccessRuleActorID BIGINT = NULL,
            @GrantingActorIndicator BIT = NULL,
            @ActorSiteGroupID BIGINT = NULL,
            @ActorSiteID BIGINT = NULL,
            @ActorEmployeeGroupID BIGINT = NULL,
            @ActorUserID BIGINT = NULL,
                                                                  -- Data audit
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @DataAuditEventID BIGINT = NULL,
            @DataAuditEventTypeID BIGINT = NULL,
            @ObjectTypeID BIGINT = 10017015,                      -- Data access data audit object type
            @ObjectID BIGINT = NULL,
            @ObjectTableAccessRuleID BIGINT = 53577790000010;     -- AccessRule
    DECLARE @AccessRuleBeforeEdit TABLE
    (
        AccessRuleID BIGINT,
        DefaultRuleIndicator BIT,
        BorderingAreaRuleIndicator BIT,
        ReciprocalRuleIndicator BIT,
        GrantingActorSiteGroupID BIGINT,
        GrantingActorSiteID BIGINT,
        ReadPermissionIndicator BIT,
        AccessToPersonalDataPermissionIndicator BIT,
        AccessToGenderAndAgeDataPermissionIndicator BIT,
        CreatePermissionIndicator BIT,
        WritePermissionIndicator BIT,
        DeletePermissionIndicator BIT,
        AdministrativeLevelTypeID BIGINT,
        RowStatus INT
    );
    DECLARE @AccessRuleAfterEdit TABLE
    (
        AccessRuleID BIGINT,
        DefaultRuleIndicator BIT,
        BorderingAreaRuleIndicator BIT,
        ReciprocalRuleIndicator BIT,
        GrantingActorSiteGroupID BIGINT,
        GrantingActorSiteID BIGINT,
        ReadPermissionIndicator BIT,
        AccessToPersonalDataPermissionIndicator BIT,
        AccessToGenderAndAgeDataPermissionIndicator BIT,
        CreatePermissionIndicator BIT,
        WritePermissionIndicator BIT,
        DeletePermissionIndicator BIT,
        AdministrativeLevelTypeID BIGINT,
        RowStatus INT
    );
    -- End data audit
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(200)
    );

    DECLARE @ActorsTemp TABLE
    (
        AccessRuleActorID BIGINT NOT NULL,
        GrantingActorIndicator BIT NOT NULL,
        ActorSiteGroupID BIGINT NULL,
        ActorSiteID BIGINT NULL,
        ActorEmployeeGroupID BIGINT NULL,
        ActorUserID BIGINT NULL,
        RowStatus INT NOT NULL,
        RowAction INT NULL
    );

    INSERT INTO @ActorsTemp
    SELECT *
    FROM
        OPENJSON(@ReceivingActors)
        WITH
        (
            AccessRuleActorID BIGINT,
            GrantingActorIndicator BIT,
            ActorSiteGroupID BIGINT,
            ActorSiteID BIGINT,
            ActorEmployeeGroupID BIGINT,
            ActorUserID BIGINT,
            RowStatus INT,
            RowAction INT
        );

    DECLARE @DuplicateDefault INT
        = 0, -- Updated to capture 0 or 1. 1 indicates a duplicate and will not execute the set.
            @intOrderNew INT = (
                                   SELECT MAX(intOrder) + 10
                                   FROM dbo.trtBaseReference
                                   WHERE idfsReferenceType = 19000537
                               );

    SET @AuditUser = ISNULL(@AuditUser, '');

    -- Data audit
    -- Get and set user and site identifiers
    SELECT @AuditUserID = userInfo.UserId,
           @AuditSiteID = userInfo.SiteId
    FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo;

    -- Set intOrder if it was passed as null
    IF @intOrder IS NULL
    BEGIN
        SET @intOrder = @intOrderNew;
    END

    BEGIN TRY
        IF @AccessRuleID IS NULL
        BEGIN -- This is an insert.  Check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE strDefault = @AccessRuleName
                      AND idfsReferenceType = 19000537
                      AND intRowStatus = 0
            )
            BEGIN
                SET @DuplicateDefault = 1;
            END
        END
        ELSE
        BEGIN -- This is an update.  Check if the strDefault is a duplicate
            IF EXISTS
            (
                SELECT *
                FROM dbo.trtBaseReference
                WHERE idfsBaseReference <> @AccessRuleID
                      AND strDefault = @AccessRuleName
                      AND idfsReferenceType = 19000537
                      AND intRowStatus = 0
            )
            BEGIN
                SET @DuplicateDefault = 1;
            END
        END

        IF @DuplicateDefault = 1 -- No need to go any further, as the strDefault is a duplicate.
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
        END
        ELSE -- There is no duplicate, so continue.
        BEGIN
            -- Data audit
            IF EXISTS (SELECT * FROM dbo.AccessRule WHERE AccessRuleID = @AccessRuleID)
            BEGIN
                SET @DataAuditEventTypeID = 10016003; -- Edit data audit event type
            END
            ELSE
            BEGIN
                SET @DataAuditEventTypeID = 10016001; -- Create data audit event type
            END
            -- End data audit

            EXECUTE dbo.USP_GBL_BaseReference_SET @ReferenceID = @AccessRuleID OUTPUT,
                                                  @ReferenceType = 19000537,
                                                  @LangID = @LangID,
                                                  @DefaultName = @AccessRuleName,
                                                  @NationalName = @strNationalName,
                                                  @HACode = NULL,
                                                  @Order = @intOrder,
                                                  @System = 0,
                                                  @User = @AuditUser

            -- Data audit
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @AccessRuleID,
                                                      @ObjectTableAccessRuleID,
                                                      NULL,
                                                      @DataAuditEventID OUTPUT;
            -- End data audit

            IF EXISTS (SELECT * FROM dbo.AccessRule WHERE AccessRuleID = @AccessRuleID) -- there is a record, so update it
            BEGIN
                -- Data audit
                INSERT INTO @AccessRuleBeforeEdit
                SELECT AccessRuleID,
                       DefaultRuleIndicator,
                       BorderingAreaRuleIndicator,
                       ReciprocalRuleIndicator,
                       GrantingActorSiteGroupID,
                       GrantingActorSiteID,
                       ReadPermissionIndicator,
                       AccessToPersonalDataPermissionIndicator,
                       AccessToGenderAndAgeDataPermissionIndicator,
                       CreatePermissionIndicator,
                       WritePermissionIndicator,
                       DeletePermissionIndicator,
                       AdministrativeLevelTypeID,
                       intRowStatus
                FROM dbo.AccessRule
                WHERE AccessRuleID = @AccessRuleID;
                -- End data audit

                UPDATE dbo.AccessRule
                SET DefaultRuleIndicator = @DefaultRuleIndicator,
                    BorderingAreaRuleIndicator = @BorderingAreaRuleIndicator,
                    ReciprocalRuleIndicator = @ReciprocalRuleIndicator,
                    GrantingActorSiteGroupID = @GrantingActorSiteGroupID,
                    GrantingActorSiteID = @GrantingActorSiteID,
                    ReadPermissionIndicator = @ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator = @AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator = @AccessToGenderAndAgeDataPermissionIndicator,
                    CreatePermissionIndicator = @CreatePermissionIndicator,
                    WritePermissionIndicator = @WritePermissionIndicator,
                    DeletePermissionIndicator = @DeletePermissionIndicator,
                    AdministrativeLevelTypeID = @AdministrativeLevelTypeID,
                    intRowStatus = @RowStatus,
                    AuditUpdateUser = @AuditUser,
                    AuditUpdateDTM = GETDATE()
                WHERE AccessRuleID = @AccessRuleID;

                -- Data audit
                INSERT INTO @AccessRuleAfterEdit
                SELECT AccessRuleID,
                       DefaultRuleIndicator,
                       BorderingAreaRuleIndicator,
                       ReciprocalRuleIndicator,
                       GrantingActorSiteGroupID,
                       GrantingActorSiteID,
                       ReadPermissionIndicator,
                       AccessToPersonalDataPermissionIndicator,
                       AccessToGenderAndAgeDataPermissionIndicator,
                       CreatePermissionIndicator,
                       WritePermissionIndicator,
                       DeletePermissionIndicator,
                       AdministrativeLevelTypeID,
                       intRowStatus
                FROM dbo.AccessRule
                WHERE AccessRuleID = @AccessRuleID;

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
                           @ObjectTableAccessRuleID,
                           51586990000099,
                           a.AccessRuleID,
                           NULL,
                           b.GrantingActorSiteGroupID,
                           a.GrantingActorSiteGroupID,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.GrantingActorSiteGroupID <> b.GrantingActorSiteGroupID)
                          OR (
                                 a.GrantingActorSiteGroupID IS NOT NULL
                                 AND b.GrantingActorSiteGroupID IS NULL
                             )
                          OR (
                                 a.GrantingActorSiteGroupID IS NULL
                                 AND b.GrantingActorSiteGroupID IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000100,
                           a.AccessRuleID,
                           NULL,
                           b.GrantingActorSiteID,
                           a.GrantingActorSiteID,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.GrantingActorSiteID <> b.GrantingActorSiteID)
                          OR (
                                 a.GrantingActorSiteID IS NOT NULL
                                 AND b.GrantingActorSiteID IS NULL
                             )
                          OR (
                                 a.GrantingActorSiteID IS NULL
                                 AND b.GrantingActorSiteID IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000102,
                           a.AccessRuleID,
                           NULL,
                           b.ReadPermissionIndicator,
                           a.ReadPermissionIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.ReadPermissionIndicator <> b.ReadPermissionIndicator)
                          OR (
                                 a.ReadPermissionIndicator IS NOT NULL
                                 AND b.ReadPermissionIndicator IS NULL
                             )
                          OR (
                                 a.ReadPermissionIndicator IS NULL
                                 AND b.ReadPermissionIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000103,
                           a.AccessRuleID,
                           NULL,
                           b.AccessToPersonalDataPermissionIndicator,
                           a.AccessToPersonalDataPermissionIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.AccessToPersonalDataPermissionIndicator <> b.AccessToPersonalDataPermissionIndicator)
                          OR (
                                 a.AccessToPersonalDataPermissionIndicator IS NOT NULL
                                 AND b.AccessToPersonalDataPermissionIndicator IS NULL
                             )
                          OR (
                                 a.AccessToPersonalDataPermissionIndicator IS NULL
                                 AND b.AccessToPersonalDataPermissionIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000104,
                           a.AccessRuleID,
                           NULL,
                           b.AccessToGenderAndAgeDataPermissionIndicator,
                           a.AccessToGenderAndAgeDataPermissionIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.AccessToGenderAndAgeDataPermissionIndicator <> b.AccessToGenderAndAgeDataPermissionIndicator)
                          OR (
                                 a.AccessToGenderAndAgeDataPermissionIndicator IS NOT NULL
                                 AND b.AccessToGenderAndAgeDataPermissionIndicator IS NULL
                             )
                          OR (
                                 a.AccessToGenderAndAgeDataPermissionIndicator IS NULL
                                 AND b.AccessToGenderAndAgeDataPermissionIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000105,
                           a.AccessRuleID,
                           NULL,
                           b.WritePermissionIndicator,
                           a.WritePermissionIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.WritePermissionIndicator <> b.WritePermissionIndicator)
                          OR (
                                 a.WritePermissionIndicator IS NOT NULL
                                 AND b.WritePermissionIndicator IS NULL
                             )
                          OR (
                                 a.WritePermissionIndicator IS NULL
                                 AND b.WritePermissionIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000106,
                           a.AccessRuleID,
                           NULL,
                           b.DeletePermissionIndicator,
                           a.DeletePermissionIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.DeletePermissionIndicator <> b.DeletePermissionIndicator)
                          OR (
                                 a.DeletePermissionIndicator IS NOT NULL
                                 AND b.DeletePermissionIndicator IS NULL
                             )
                          OR (
                                 a.DeletePermissionIndicator IS NULL
                                 AND b.DeletePermissionIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000107,
                           a.AccessRuleID,
                           NULL,
                           b.BorderingAreaRuleIndicator,
                           a.BorderingAreaRuleIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.BorderingAreaRuleIndicator <> b.BorderingAreaRuleIndicator)
                          OR (
                                 a.BorderingAreaRuleIndicator IS NOT NULL
                                 AND b.BorderingAreaRuleIndicator IS NULL
                             )
                          OR (
                                 a.BorderingAreaRuleIndicator IS NULL
                                 AND b.BorderingAreaRuleIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000108,
                           a.AccessRuleID,
                           NULL,
                           b.ReciprocalRuleIndicator,
                           a.ReciprocalRuleIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.ReciprocalRuleIndicator <> b.ReciprocalRuleIndicator)
                          OR (
                                 a.ReciprocalRuleIndicator IS NOT NULL
                                 AND b.ReciprocalRuleIndicator IS NULL
                             )
                          OR (
                                 a.ReciprocalRuleIndicator IS NULL
                                 AND b.ReciprocalRuleIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000109,
                           a.AccessRuleID,
                           NULL,
                           b.DefaultRuleIndicator,
                           a.DefaultRuleIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.DefaultRuleIndicator <> b.DefaultRuleIndicator)
                          OR (
                                 a.DefaultRuleIndicator IS NOT NULL
                                 AND b.DefaultRuleIndicator IS NULL
                             )
                          OR (
                                 a.DefaultRuleIndicator IS NULL
                                 AND b.DefaultRuleIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000110,
                           a.AccessRuleID,
                           NULL,
                           b.AdministrativeLevelTypeID,
                           a.AdministrativeLevelTypeID,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.AdministrativeLevelTypeID <> b.AdministrativeLevelTypeID)
                          OR (
                                 a.AdministrativeLevelTypeID IS NOT NULL
                                 AND b.AdministrativeLevelTypeID IS NULL
                             )
                          OR (
                                 a.AdministrativeLevelTypeID IS NULL
                                 AND b.AdministrativeLevelTypeID IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           51586990000111,
                           a.AccessRuleID,
                           NULL,
                           b.CreatePermissionIndicator,
                           a.CreatePermissionIndicator,
                           @AuditUser,
                           NULL
                    FROM @AccessRuleAfterEdit AS a
                        FULL JOIN @AccessRuleBeforeEdit AS b
                            ON a.AccessRuleID = b.AccessRuleID
                    WHERE (a.CreatePermissionIndicator <> b.CreatePermissionIndicator)
                          OR (
                                 a.CreatePermissionIndicator IS NOT NULL
                                 AND b.CreatePermissionIndicator IS NULL
                             )
                          OR (
                                 a.CreatePermissionIndicator IS NULL
                                 AND b.CreatePermissionIndicator IS NOT NULL
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
                           @ObjectTableAccessRuleID,
                           @AccessRuleID,
                           @AuditUser,
                           NULL;
                END
            END
            ELSE -- There is no record, so insert it.
            BEGIN
                INSERT INTO dbo.AccessRule
                (
                    AccessRuleID,
                    DefaultRuleIndicator,
                    BorderingAreaRuleIndicator,
                    ReciprocalRuleIndicator,
                    GrantingActorSiteGroupID,
                    GrantingActorSiteID,
                    ReadPermissionIndicator,
                    AccessToPersonalDataPermissionIndicator,
                    AccessToGenderAndAgeDataPermissionIndicator,
                    CreatePermissionIndicator,
                    WritePermissionIndicator,
                    DeletePermissionIndicator,
                    AdministrativeLevelTypeID,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser,
                    SourceSystemNameID,
                    SourceSystemKeyValue
                )
                VALUES
                (@AccessRuleID,
                 @DefaultRuleIndicator,
                 @BorderingAreaRuleIndicator,
                 @ReciprocalRuleIndicator,
                 @GrantingActorSiteGroupID,
                 @GrantingActorSiteID,
                 @ReadPermissionIndicator,
                 @AccessToPersonalDataPermissionIndicator,
                 @AccessToGenderAndAgeDataPermissionIndicator,
                 @CreatePermissionIndicator,
                 @WritePermissionIndicator,
                 @DeletePermissionIndicator,
                 @AdministrativeLevelTypeID,
                 @RowStatus,
                 GETDATE(),
                 @AuditUser,
                 10519001,
                 '[{"AccessRuleID":' + CAST(@AccessRuleID AS NVARCHAR(24)) + '}]'
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
                 @ObjectTableAccessRuleID,
                 @AccessRuleID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectTableAccessRuleID AS NVARCHAR(300)) + '}]',
                 @AuditUser,
                 NULL
                );
                -- End data audit

                IF @ReciprocalRuleIndicator = 1
                BEGIN
                    DECLARE @TempID BIGINT = 0;
                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USSP_ADMIN_ACCESS_RULE_ACTOR_SET @TempID OUTPUT,
                                                                 @AccessRuleID,
                                                                 1,
                                                                 @GrantingActorSiteGroupID,
                                                                 @GrantingActorSiteID,
                                                                 NULL,
                                                                 NULL,
                                                                 0,
                                                                 1,
                                                                 @AuditUser, 
                                                                 @DataAuditEventID;
                END
            END

            WHILE EXISTS (SELECT * FROM @ActorsTemp)
            BEGIN
                SELECT TOP 1
                    @RowID = AccessRuleActorID,
                    @AccessRuleActorID = AccessRuleActorID,
                    @GrantingActorIndicator = GrantingActorIndicator,
                    @ActorSiteGroupID = ActorSiteGroupID,
                    @ActorSiteID = ActorSiteID,
                    @ActorEmployeeGroupID = ActorEmployeeGroupID,
                    @ActorUserID = ActorUserID,
                    @RowStatus = RowStatus,
                    @RowAction = RowAction
                FROM @ActorsTemp;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_ADMIN_ACCESS_RULE_ACTOR_SET @AccessRuleActorID = @AccessRuleActorID OUTPUT,
                                                             @AccessRuleID = @AccessRuleID,
                                                             @GrantingActorIndicator = @GrantingActorIndicator,
                                                             @ActorSiteGroupID = @ActorSiteGroupID,
                                                             @ActorSiteID = @ActorSiteID,
                                                             @ActorEmployeeGroupID = @ActorEmployeeGroupID,
                                                             @ActorUserID = @ActorUserID,
                                                             @RowStatus = @RowStatus,
                                                             @RowAction = @RowAction,
                                                             @AuditUser = @AuditUser, 
                                                             @DataAuditEventID = @DataAuditEventID;

                DELETE FROM @ActorsTemp
                WHERE AccessRuleActorID = @RowID;
            END;
        END

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @AccessRuleID KeyId,
               'AccessRuleID' KeyIdName;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
