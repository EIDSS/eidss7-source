-- ================================================================================================
-- Name: USP_ADMIN_ACCESS_RULE_SET
--
-- Description:	Inserts or updates access rules for configurable site filtration.
--                      
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- -------------------------------------------------------------------
-- Stephen Long    11/11/2020 Initial release.
-- Stephen Long    11/23/2020 Correction on USSP_ADMIN_ACCESS_RULE_ACTOR_SET call.
-- Stephen Long    11/25/2020 Added permission indicator parameters and insert/updates.
-- Stephen Long    12/18/2020 Added bordering area rule indicator.
-- Stephen Long    12/27/2020 Added reciprocal rule indicator.
-- Stephen Long    03/18/2021 Added default rule and administrative level type ID parameters.
-- Stephen Long    06/17/2021 Changed to key ID and key name for API save response model.
-- Stephen Long    01/09/2022 Added create permission indicator.
-- Stephen Long    03/16/2022 Changed row action from char to int.
-- Stephen Long    03/18/2022 Changed size of access rule name from 200 to max.
-- Stephen Long    07/15/2022 Comment out access rule name field; need to add base reference 
--                            logic for the name.
-- Stephen Long    12/16/2022 Fix to add audit user name parameter.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACCESS_RULE_SET]
(
    @AccessRuleID BIGINT = NULL,
    @AccessRuleName NVARCHAR(MAX),
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
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT = 0;
        DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @RowAction CHAR = NULL,
                @RowID BIGINT = NULL,
                @AccessRuleActorID BIGINT = NULL,
                @GrantingActorIndicator BIT = NULL,
                @ActorSiteGroupID BIGINT = NULL,
                @ActorSiteID BIGINT = NULL,
                @ActorEmployeeGroupID BIGINT = NULL,
                @ActorUserID BIGINT = NULL;
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

        BEGIN TRANSACTION;

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

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.AccessRule
            WHERE AccessRuleID = @AccessRuleID
                  AND intRowStatus = 0
        )
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'AccessRule', @AccessRuleID OUTPUT;

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
             @AuditUserName,
             10519002,
			'[{"AccessRuleID":' + CAST(@AccessRuleID AS NVARCHAR(24)) + '}]'
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.AccessRule
            SET DefaultRuleIndicator = @DefaultRuleIndicator,
                BorderingAreaRuleIndicator = @BorderingAreaRuleIndicator,
                @ReciprocalRuleIndicator = @ReciprocalRuleIndicator,
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
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE AccessRuleID = @AccessRuleID;
        END;

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
            EXECUTE dbo.USSP_ADMIN_ACCESS_RULE_ACTOR_SET @AccessRuleActorID OUTPUT,
                                                         @AccessRuleID,
                                                         @GrantingActorIndicator,
                                                         @ActorSiteGroupID,
                                                         @ActorSiteID,
                                                         @ActorEmployeeGroupID,
                                                         @ActorUserID,
                                                         @RowStatus,
                                                         @RowAction,
                                                         @AuditUserName;

            DELETE FROM @ActorsTemp
            WHERE AccessRuleActorID = @RowID;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @AccessRuleID KeyId,
               'AccessRuleID' KeyIdName;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @AccessRuleID KeyId,
               'AccessRuleID' KeyIdName;
        THROW;
    END CATCH
END