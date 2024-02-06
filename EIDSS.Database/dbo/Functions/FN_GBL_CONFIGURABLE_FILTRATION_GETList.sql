-- ================================================================================================
-- Name: FN_GBL_CONFIGURABLE_FILTRATION_GETList
--
-- Description: Returns a table of permissions based on configurable filtration rules. 
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       01/24/2023 Initial release
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_CONFIGURABLE_FILTRATION_GETList]
(
    @ObjectSiteID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT
)
RETURNS @T TABLE
(
    SiteID BIGINT NOT NULL, 
    ReadPermissionIndicator INT NOT NULL,
    AccessToPersonalDataPermissionIndicator INT NOT NULL,
    AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
    WritePermissionIndicator INT NOT NULL,
    DeletePermissionIndicator INT NOT NULL
)
AS
BEGIN
    --
    -- Apply at the user's site group level, granted by a site group.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup grantingSGS
        INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
            ON userSiteGroup.idfsSite = @UserSiteID
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.DefaultRuleIndicator = 0
    WHERE grantingSGS.idfsSite = @ObjectSiteID
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup userSiteGroup
        INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
            ON grantingSGS.idfsSite = @ObjectSiteID
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorSiteGroupID = grantingSGS.idfSiteGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE userSiteGroup.idfsSite = @UserSiteID
          AND a.GrantingActorSiteGroupID = userSiteGroup.idfSiteGroup;

    --
    -- Apply at the user's site level, granted by a site group.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup grantingSGS
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorSiteID = @UserSiteID
               AND ara.ActorEmployeeGroupID IS NULL
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.DefaultRuleIndicator = 0
    WHERE grantingSGS.idfsSite = @ObjectSiteID
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.AccessRuleActor ara
        INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
            ON grantingSGS.idfsSite = @UserSiteID
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE ara.ActorSiteID = @ObjectSiteID
          AND ara.ActorEmployeeGroupID IS NULL
          AND ara.intRowStatus = 0
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    -- 
    -- Apply at the user's employee group level, granted by a site group.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup grantingSGS
        INNER JOIN dbo.tlbEmployeeGroupMember egm
            ON egm.idfEmployee = @UserEmployeeID
               AND egm.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.DefaultRuleIndicator = 0
    WHERE grantingSGS.idfsSite = @ObjectSiteID
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup grantingSGS
        INNER JOIN dbo.tlbEmployeeGroup eg 
            ON eg.idfsSite = @ObjectSiteID 
               AND eg.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorEmployeeGroupID = eg.idfEmployeeGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE grantingSGS.idfsSite = @UserSiteID
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    -- 
    -- Apply at the user's ID level, granted by a site group.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup grantingSGS
        INNER JOIN dbo.tstUserTable u
            ON u.idfPerson = @UserEmployeeID
               AND u.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorUserID = u.idfUserID
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.DefaultRuleIndicator = 0
    WHERE grantingSGS.idfsSite = @ObjectSiteID
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup grantingSGS
        INNER JOIN dbo.tlbEmployee e 
            ON e.idfsSite = @ObjectSiteID
        INNER JOIN dbo.tstUserTable u
            ON u.idfPerson = e.idfEmployee 
               AND u.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorUserID = u.idfUserID
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE grantingSGS.idfsSite = @UserSiteID
          AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

    --
    -- Apply at the user's site group level, granted by a site.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup sgs
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorSiteGroupID = sgs.idfSiteGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.DefaultRuleIndicator = 0
    WHERE a.GrantingActorSiteID = @UserSiteID
          AND sgs.idfsSite = @ObjectSiteID;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tflSiteToSiteGroup sgs
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorSiteGroupID = sgs.idfSiteGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE sgs.idfsSite = @UserSiteID
          AND a.GrantingActorSiteID = @ObjectSiteID;

    -- 
    -- Apply at the user's site level, granted by a site.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.AccessRule a
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorSiteID = @UserSiteID
               AND ara.ActorEmployeeGroupID IS NULL
               AND ara.intRowStatus = 0
               AND a.AccessRuleID = ara.AccessRuleID
    WHERE a.intRowStatus = 0
          AND a.DefaultRuleIndicator = 0
          AND a.GrantingActorSiteID = @ObjectSiteID;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.AccessRuleActor ara
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE ara.ActorSiteID = @ObjectSiteID
          AND ara.ActorEmployeeGroupID IS NULL
          AND ara.intRowStatus = 0
          AND a.GrantingActorSiteID = @UserSiteID;

    -- 
    -- Apply at the user's employee group level, granted by a site.
    --
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.AccessRule a
        INNER JOIN dbo.tlbEmployeeGroupMember egm
            ON egm.idfEmployee = @UserEmployeeID
               AND egm.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
               AND ara.intRowStatus = 0
               AND a.AccessRuleID = ara.AccessRuleID
    WHERE a.intRowStatus = 0
          AND a.DefaultRuleIndicator = 0
          AND a.GrantingActorSiteID = @ObjectSiteID;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tlbEmployeeGroup eg
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorEmployeeGroupID = eg.idfEmployeeGroup
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE eg.idfsSite = @ObjectSiteID
          AND eg.intRowStatus = 0
          AND a.GrantingActorSiteID = @UserSiteID;

    -- 
    -- Apply at the user's ID level, granted by a site.
    ----
    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.AccessRule a
        INNER JOIN dbo.tstUserTable u
            ON u.idfPerson = @UserEmployeeID
               AND u.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorUserID = u.idfUserID
               AND ara.intRowStatus = 0
               AND a.AccessRuleID = ara.AccessRuleID
    WHERE a.intRowStatus = 0
          AND a.DefaultRuleIndicator = 0
          AND a.GrantingActorSiteID = @ObjectSiteID;

    INSERT INTO @T
    SELECT @ObjectSiteID, 
           a.ReadPermissionIndicator,
           a.AccessToPersonalDataPermissionIndicator,
           a.AccessToGenderAndAgeDataPermissionIndicator,
           a.WritePermissionIndicator,
           a.DeletePermissionIndicator
    FROM dbo.tlbEmployee e
        INNER JOIN dbo.tstUserTable u
            ON u.idfPerson = e.idfEmployee
               AND u.intRowStatus = 0
        INNER JOIN dbo.AccessRuleActor ara
            ON ara.ActorUserID = u.idfUserID
               AND ara.intRowStatus = 0
        INNER JOIN dbo.AccessRule a
            ON a.AccessRuleID = ara.AccessRuleID
               AND a.intRowStatus = 0
               AND a.ReciprocalRuleIndicator = 1
    WHERE e.idfsSite = @ObjectSiteID
          AND e.intRowStatus = 0
          AND a.GrantingActorSiteID = @UserSiteID;

    RETURN;
END