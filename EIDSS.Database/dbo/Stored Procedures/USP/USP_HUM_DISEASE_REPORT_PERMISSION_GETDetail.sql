-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_PERMISSIONS_GETDetail
--
-- Description: List Human Disease Report
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name                    Date       Change Detail
-- ----------------------- ---------- ------------------------------------------------------------
-- Stephen Long            07/05/2023 Fix on site permission deletion query.
--
-- Testing code:
-- 
/* 
EXEC USP_HUM_DISEASE_GETDetail 'en-US', 71413
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_PERMISSION_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @RecordID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT
)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
                @ReturnCode INT = 0,
                @FiltrationSiteAdministrativeLevelID AS BIGINT,
                @SiteID BIGINT = (
                                     SELECT idfsSite
                                     FROM dbo.tlbHumanCase
                                     WHERE idfHumanCase = @RecordID
                                 );


        DECLARE @UserSitePermissions TABLE
        (
            SiteID BIGINT NOT NULL,
            PermissionTypeID BIGINT NOT NULL,
            Permission INT NOT NULL
        );
        DECLARE @UserGroupSitePermissions TABLE
        (
            SiteID BIGINT NOT NULL,
            PermissionTypeID BIGINT NOT NULL,
            Permission INT NOT NULL
        );
        DECLARE @Results TABLE
        (
            ID BIGINT NOT NULL,
            ReadPermissionIndicator INT NOT NULL,
            AccessToPersonalDataPermissionIndicator INT NOT NULL,
            AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
            WritePermissionIndicator INT NOT NULL,
            DeletePermissionIndicator INT NOT NULL
        );
        DECLARE @FinalResults TABLE
        (
            ID BIGINT NOT NULL,
            ReadPermissionIndicator INT NOT NULL,
            AccessToPersonalDataPermissionIndicator INT NOT NULL,
            AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
            WritePermissionIndicator INT NOT NULL,
            DeletePermissionIndicator INT NOT NULL
        );

        IF @UserSiteID <> @SiteID
        BEGIN
            INSERT INTO @UserGroupSitePermissions
            SELECT oa.idfsOnSite,
                   oa.idfsObjectOperation,
                   CASE
                       WHEN oa.intPermission = 2 THEN
                           3
                       ELSE
                           2
                   END
            FROM dbo.tstObjectAccess oa
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intRowStatus = 0
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = egm.idfEmployeeGroup;

            INSERT INTO @UserSitePermissions
            SELECT oa.idfsOnSite,
                   oa.idfsObjectOperation,
                   CASE
                       WHEN oa.intPermission = 2 THEN
                           5
                       ELSE
                           4
                   END
            FROM dbo.tstObjectAccess oa
            WHERE oa.intRowStatus = 0
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = @UserEmployeeID;

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537000;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537000;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tstSite s
                        ON h.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                           AND o.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report current residence address.
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbHuman hu
                        ON hu.idfHuman = h.idfHuman
                           AND hu.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = hu.idfCurrentResidenceAddress
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report location of exposure, 
                -- if corresponding field was filled in.
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfPointGeoLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
            END;

            -- Report data shall be available to all sites' organizations connected to the particular report.
            -- Notification sent by, notification received by, facility where the patient first sought 
            -- care, hospital, and the conducting investigation organizations.
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537001;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              h.idfSentByOffice = @UserOrganizationID
                              OR h.idfReceivedByOffice = @UserOrganizationID
                              OR h.idfSoughtCareFacility = @UserOrganizationID
                              OR h.idfHospital = @UserOrganizationID
                              OR h.idfInvestigatedByOffice = @UserOrganizationID
                          );

                -- Sample collected by and sent to organizations
                INSERT INTO @Results
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.idfHumanCase = @RecordID
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @Results
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.idfHumanCase = @RecordID
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537002;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbOutbreak o
                        ON h.idfHumanCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537002
                WHERE h.idfHumanCase = @RecordID
                      AND o.idfsSite = @UserSiteID;
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
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
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
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
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND sgs.idfsSite = h.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
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
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            ----
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
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
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteID = h.idfsSite;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.idfHumanCase = @RecordID
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.idfHumanCase = @RecordID
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = hc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.idfHumanCase = @RecordID
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = hc.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission
        END
        ELSE
        BEGIN
            INSERT INTO @Results 
            SELECT @RecordID, 
                   1,
                   1,
                   1,
                   1,
                   1;
        END

        -- Copy filtered results to final results
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        GROUP BY ID;

        SELECT @RecordID AS RecordID,
               @SiteID AS SiteID,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator
        FROM @FinalResults res;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        THROW;
    END CATCH
END