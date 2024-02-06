-- ================================================================================================
-- Name: USP_VCTS_VSSESSION_NEW_GetDetail
--
-- Description: Get Vector Surveillance Session data for session id
--          
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Harold Pryor     04/23/2018 Initial Creation
-- Harold Pryor     06/07/2018 Updated to return idfsGeoLocationType
-- Doug Albanese	03-10-2020 Changes Defect 6212
-- Doug Albanese	10-16-2020 Added Outbreak's EIDSS ID
-- Doug Albanese	11-20-2020 Added dblAlignment (Direction)
-- Lamont Mitchell	11-11-2021 Added AdminLevels
-- Lamont Mitchell  12-12-2021 Added Location Hiarchy and missing fields, renamed SP added the 
--                             work New to identify the new SP
-- Mike Kornegay	10-05-2022 Correct idfsSite to pull from the tlbVectorSurveillanceSession and 
--                             not tlbGeoLocation.
-- Stephen Long     06-15-2023 Added filtration rules.
-- Stephen Long     07/05/2023 Fix on site permission deletion query.
--
-- Testing code:
-- EXEC USP_VCTS_VSSESSION_GetDetail(1, 'en-US')
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VCTS_VSSESSION_New_GetDetail]
(
    @idfVectorSurveillanceSession AS BIGINT,
    @LangID AS NVARCHAR(50),
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplyFiltrationIndicator BIT = 0
)
AS
BEGIN
    DECLARE @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID),
            @SiteID BIGINT = (
                                 SELECT idfsSite
                                 FROM dbo.tlbVectorSurveillanceSession
                                 WHERE idfVectorSurveillanceSession = @idfVectorSurveillanceSession
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
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                             ));
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

    BEGIN TRY
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

        IF @UserSiteID = @SiteID
           OR @ApplyFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT @idfVectorSurveillanceSession,
                   1,
                   1,
                   1,
                   1,
                   1;
        END
        ELSE
        BEGIN
            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                                     ));
            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply non-configurable filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0, 
                    @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator BIT NOT NULL,
                AccessToPersonalDataPermissionIndicator BIT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
                WritePermissionIndicator BIT NOT NULL,
                DeletePermissionIndicator BIT NOT NULL,
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

            --
            -- Session data shall be available to all sites' organizations connected to the particular 
            -- session.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537019;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Collected and identified by organizations for any vectors/pools
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbVector v
                        ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                      AND (
                              v.idfCollectedByOffice = @UserOrganizationID
                              OR v.idfIdentifiedByOffice = @UserOrganizationID
                          );

                -- Collected by and sent to organizations for any samples
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVectorSurveillanceSession),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE m.intRowStatus = 0
                      AND m.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Tested by organization for any laboratory test
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVectorSurveillanceSession),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbTesting t
                        ON t.idfMaterial = m.idfMaterial
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE m.intRowStatus = 0
                      AND m.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                      AND t.idfTestedByOffice = @UserOrganizationID
                GROUP BY m.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Tested by organization for any field test
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVectorSurveillanceSession),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbPensideTest p
                        ON p.idfMaterial = m.idfMaterial
                           AND p.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537019
                WHERE m.intRowStatus = 0
                      AND m.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                      AND p.idfTestedByOffice = @UserOrganizationID
                GROUP BY m.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Sent to organizations for any sample transfers
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537021;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT MAX(vss.idfVectorSurveillanceSession),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbMaterial m
                        ON vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial toutm
                        ON m.idfMaterial = toutm.idfMaterial
                           AND toutm.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT tout
                        ON toutm.idfTransferOut = tout.idfTransferOut
                           AND tout.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537021
                WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                      AND tout.idfSendToOffice = @UserOrganizationID
                GROUP BY vss.idfVectorSurveillanceSession,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Session data shall be available to all sites of the same administrative level.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537018;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537018;

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
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the session was created.
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tstSite s
                        ON vss.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
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
                          );

                -- Administrative level specified in the rule of the session location, if completed
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = vss.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
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
                          );

                -- Administrative level specified in the rule of any vector location, if completed.
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbVector v
                        ON v.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = v.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
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
                          );

                -- Administration level specified in the rule of the location of any session summary record, if completed.
                INSERT INTO @FilteredResults
                SELECT vss.idfVectorSurveillanceSession,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVectorSurveillanceSession vss
                    INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                        ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                           AND vsss.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = vsss.idfGeoLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537018
                WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
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
                          );
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the non-configurable rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
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
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = vss.idfsSite
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
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND sgs.idfsSite = vss.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteID = vss.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
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
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteID = vss.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT vss.idfVectorSurveillanceSession,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVectorSurveillanceSession vss
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
            WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
                  AND a.GrantingActorSiteID = vss.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT vss.idfVectorSurveillanceSession
                        FROM dbo.tlbVectorSurveillanceSession vss
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                                   AND vsss.intRowStatus = 0
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                                   AND vssd.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = vssd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE vss.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVectorSurveillanceSession vss
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vssd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
              AND oa.idfActor = egm.idfEmployeeGroup;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vssd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVectorSurveillanceSession vss
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                   AND vsss.intRowStatus = 0
            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                   AND vssd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vssd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
              AND oa.idfActor = @UserEmployeeID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT vss.idfVectorSurveillanceSession
                        FROM dbo.tlbVectorSurveillanceSession vss
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummary vsss
                                ON vsss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
                                   AND vsss.intRowStatus = 0
                            INNER JOIN dbo.tlbVectorSurveillanceSessionSummaryDiagnosis vssd
                                ON vsss.idfsVSSessionSummary = vssd.idfsVSSessionSummary
                                   AND vssd.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = vssd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE vss.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = @UserEmployeeID
                    );

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
            SELECT vss.idfVectorSurveillanceSession
            FROM dbo.tlbVectorSurveillanceSession vss
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vss.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vss.intRowStatus = 0
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
        SELECT vss.idfVectorSurveillanceSession,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVectorSurveillanceSession vss
        WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vss.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vss.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vss.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVectorSurveillanceSession vss
        WHERE vss.idfVectorSurveillanceSession = @idfVectorSurveillanceSession
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vss.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = vss.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission

        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
        GROUP BY ID;

        SELECT vss.idfVectorSurveillanceSession,
               vss.strSessionID,
               ISNULL([dbo].[FN_VCTS_VSSESSION_VECTORTYPENAMES_GET](vss.idfVectorSurveillanceSession, @LangID), '') AS [strVectors],
               ISNULL([dbo].[FN_VCTS_VSSESSION_VECTORTYPEIDS_GET](vss.idfVectorSurveillanceSession), '') AS [strVectorTypeIds],
               ISNULL([dbo].[FN_VCTS_VSSESSION_DIAGNOSESNAMES_GET](vss.idfVectorSurveillanceSession, @LangID), '') AS [strDiagnoses],
               ISNULL([dbo].[FN_VCTS_VSSESSION_DIAGNOSESIDS_GET](vss.idfVectorSurveillanceSession, @LangID), '') AS [strDiagnosesIDs],
               vss.strFieldSessionID,
               VSStatus.name strVSStatus,
               vss.idfsVectorSurveillanceStatus,
               vss.intCollectionEffort,
               vss.strDescription,
               vss.datStartDate,
               vss.datCloseDate,
               o.idfOutbreak,
               vss.idfLocation as idfGeoLocation,
               g.AdminLevel1Name strCountry,
               gl.idfsCountry,
               g.AdminLevel2Name strRegion,
               g.AdminLevel2ID idfsRegion,
               g.AdminLevel3Name strRayon,
               g.AdminLevel3ID idfsRayon,
               g.AdminLevel4ID idfsSettlement,
               g.AdminLevel4Name strSettlement,
               gl.dblLatitude,
               gl.dblLongitude,
               vss.idfsSite,
               gl.strForeignAddress,
               gl.idfsGroundType,
               gl.dblDistance,
               gl.idfsGeoLocationType,
               gl.idfsLocation,
               gl.strStreetName,
               gl.strHouse,
               gl.strBuilding,
               gl.strApartment,
               gl.strAddressString,
               gl.strPostCode,
               gl.dblAccuracy,
               gl.strDescription LocationDescription,
               o.strOutbreakID,
               o.datStartDate OutbreakStartDate,
               gl.dblAlignment As dblDirection,
               g.AdminLevel1ID AdminLevel0Value,
               g.AdminLevel1Name AS AdminLevel0Text,
               g.AdminLevel2ID AS AdminLevel1Value,
               g.AdminLevel2Name AS AdminLevel1Text,
               g.AdminLevel3ID AS AdminLevel2Value,
               g.AdminLevel3Name AS AdminLevel2Text,
               g.AdminLevel4ID AS AdminLevel3Value,
               g.AdminLevel4Name AS AdminLevel3Text,
               g.AdminLevel5ID AS AdminLevel4Value,
               g.AdminLevel5Name AS AdminLevel4Text,
               g.AdminLevel6ID AS AdminLevel5Value,
               g.AdminLevel6Name AS AdminLevel5Text,
               g.AdminLevel7ID AS AdminLevel6Value,
               g.AdminLevel7Name AS AdminLevel6Text,
               CASE
                   WHEN res.ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN res.AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN res.WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN res.DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN res.DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN res.DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN res.DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, res.DeletePermissionIndicator)
               END AS DeletePermissionIndicator
        FROM @FinalResults res
            INNER JOIN dbo.tlbVectorSurveillanceSession Vss 
                ON Vss.idfVectorSurveillanceSession = res.ID 
            LEFT JOIN dbo.tlbGeoLocation gl
                ON Vss.idfLocation = gl.idfGeoLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) g
                ON g.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.tlbOutbreak O
                ON O.idfOutbreak = VSS.idfOutbreak
            Left JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000133) VSStatus
                On Vss.idfsVectorSurveillanceStatus = VSStatus.idfsReference
        WHERE idfVectorSurveillanceSession = @idfVectorSurveillanceSession;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END

