-- ================================================================================================
-- Name: USP_AGG_CASE_GETDETAIL
--
-- Description: Returns one aggregate disease report based on report type and ID.
--          
-- Author: Arnold Kennedy
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Arnold Kennedy   01/27/2019 Removed input parms except caseID
-- Stephen Long     07/08/2020 Added dbo prefix; formatted SQL.
-- Stephen Long     02/02/2021 Replaced v6.1 function calls with v7.
-- Ann Xiong	    08/23/2021 Updated to return strReceivedByPerson, strSentByPerson, and 
--                             strEnteredByPerson.
-- Ann Xiong	    09/07/2021 Updated to return idfsSite.
-- Mark Wilson		09/23/2021 re-wrote offices and locations
-- Mark Wilson		10/18/2021 add locationtype
-- Ann Xiong	    10/23/2021 Updated to return a new field strOrganization, a.idfOffice AS 
--                             Organization, and 10089005 AS idfsAreaType when a.idfOffice IS NOT 
--                             NULL
-- Stephen Long     11/03/2021 Changed sent by and received by organization to use abbreivated 
--                             name to match entries in the get list for the drop downs.
-- Ann Xiong	    11/09/2021 Updated "WHEN 2 THEN 10089002 WHEN 3 THEN 10089003" to "WHEN 2 THEN 
--                             10089003 WHEN 3 THEN 10089002"
-- Ann Xiong	    01/06/2022 Updated to return a new field idfVersion
-- Mike Kornegay	04/01/2022 Added idfDiagnosticVersionID, idfProphylacticVersionID, 
--                             idfSanitaryVersionID
-- Stephen Long     06/16/2023 Added filtration rules and permissions.
--
-- Testing code:
--
-- Legends
/*
	Case Type
	AggregateCase = 10102001
	VetAggregateCase = 10102002
	VetAggregateAction = 10102003

    Aggregate Case Type
    HumanAggregateCase = 10102001
    VetAggregateCase = 10102002
    VetAggregateAction = 10102003

	TEST Code

	exec USP_AGG_CASE_GETDETAIL 'en-US', @idfsAggrCaseType=10102001, @idfAggrCase = 422804240000882

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AGG_CASE_GETDETAIL]
(
    @LanguageID AS NVARCHAR(50),
    @idfsAggrCaseType AS BIGINT = NULL,
    @idfAggrCase AS BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplyFiltrationIndicator BIT = 0
)
AS
DECLARE @returnCode INT = 0;
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

BEGIN
    BEGIN TRY
        DECLARE @SiteID BIGINT = (
                                     SELECT idfsSite FROM dbo.tlbAggrCase WHERE idfAggrCase = @idfAggrCase
                                 ),
                @AdministrativeLevelNode AS HIERARCHYID;
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
            SELECT @idfAggrCase,
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
                    @AdministrativeLevelTypeID INT,
                    @OrganizationAdministrativeLevelID BIGINT = NULL,
                    @OrganizationAdministrativeSettlementID BIGINT = NULL;
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
            WHERE a.DefaultRuleIndicator = 1;

            --
            -- Human Aggregate Disease Report data shall be available to all sites' organizations 
            -- connected to the particular report.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537023;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Entered by and notification received by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT a.idfAggrCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbAggrCase a
                WHERE a.idfAggrCase = @idfAggrCase
                      AND (
                              a.idfEnteredByOffice = @UserOrganizationID
                              OR a.idfReceivedByOffice = @UserOrganizationID
                              OR a.idfSentByOffice = @UserOrganizationID
                          );
            END;

            --
            -- Human Aggregate Disease Report data shall be available to all sites of the same 
            -- administrative level specified in the rule.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537005;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537005;

                IF @OrganizationAdministrativeLevelID IS NULL
                BEGIN
                    SELECT @OrganizationAdministrativeLevelID = CASE
                                                                    WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                        lh.AdminLevel1ID
                                                                    WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                        lh.AdminLevel2ID
                                                                    WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                        lh.AdminLevel3ID
                                                                    WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                        lh.AdminLevel4ID
                                                                    WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                        lh.AdminLevel5ID
                                                                    WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                        lh.AdminLevel6ID
                                                                    WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                        lh.AdminLevel7ID
                                                                END
                    FROM dbo.tlbOffice o
                        INNER JOIN dbo.tlbGeoLocationShared l
                            ON l.idfGeoLocationShared = o.idfLocation
                        INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                            ON lh.idfsLocation = l.idfsLocation
                    WHERE o.idfOffice = @UserOrganizationID;

                    SELECT @OrganizationAdministrativeSettlementID = gs.idfsSettlement
                    FROM dbo.tlbOffice o
                        INNER JOIN dbo.tlbGeoLocationShared l
                            ON l.idfGeoLocationShared = o.idfLocation
                        INNER JOIN dbo.gisSettlement gs
                            ON gs.idfsSettlement = l.idfsLocation
                    WHERE o.idfOffice = @UserOrganizationID;
                END

                -- Administrative level specified in the rule of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfAggrCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbAggrCase ac
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537005
                    INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = ac.idfsAdministrativeUnit
                WHERE ac.idfAggrCase = @idfAggrCase
                      AND ac.idfsAggrCaseType = 10102001
                      AND (
                              lh.AdminLevel1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR lh.AdminLevel2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR lh.AdminLevel3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR lh.AdminLevel4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR lh.AdminLevel5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR lh.AdminLevel6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR lh.AdminLevel7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
                      AND ac.idfAggrCase NOT IN (
                                                    SELECT ID FROM @FilteredResults
                                                );

                -- Administrative level of the settlement of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfAggrCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbAggrCase ac
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537005
                WHERE ac.idfAggrCase = @idfAggrCase
                      AND ac.idfsAdministrativeUnit = @OrganizationAdministrativeSettlementID
                      AND (ac.idfAggrCase NOT IN (
                                                     SELECT ID FROM @FilteredResults
                                                 )
                          );
            END;

            --
            -- Veterinary Aggregate Disease/Action Report data shall be available to all sites' organizations 
            -- connected to the particular report.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537024;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Entered by and notification received by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT a.idfAggrCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbAggrCase a
                WHERE a.idfAggrCase = @idfAggrCase
                      AND (
                              a.idfEnteredByOffice = @UserOrganizationID
                              OR a.idfReceivedByOffice = @UserOrganizationID
                              OR a.idfSentByOffice = @UserOrganizationID
                          );
            END;

            --
            -- Veterinary Aggregate Disease/Action Report data shall be available to all sites of the same 
            -- administrative level specified in the rule.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537014;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537014;

                SELECT @OrganizationAdministrativeLevelID = CASE
                                                                WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                    lh.AdminLevel1ID
                                                                WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                    lh.AdminLevel2ID
                                                                WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                    lh.AdminLevel3ID
                                                                WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                    lh.AdminLevel4ID
                                                                WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                    lh.AdminLevel5ID
                                                                WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                    lh.AdminLevel6ID
                                                                WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                    lh.AdminLevel7ID
                                                            END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = l.idfsLocation
                WHERE o.idfOffice = @UserOrganizationID;

                SELECT @OrganizationAdministrativeSettlementID = gs.idfsSettlement
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisSettlement gs
                        ON gs.idfsSettlement = l.idfsLocation
                WHERE o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfAggrCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbAggrCase ac
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537014
                    INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = ac.idfsAdministrativeUnit
                WHERE ac.idfAggrCase = @idfAggrCase
                      AND ac.idfsAggrCaseType = 10102002
                      OR ac.idfAggrCase = 10102003
                         AND (
                                 lh.AdminLevel1ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 1
                                 OR lh.AdminLevel2ID = @OrganizationAdministrativeLevelID
                                    AND @AdministrativeLevelTypeID = 2
                                 OR lh.AdminLevel3ID = @OrganizationAdministrativeLevelID
                                    AND @AdministrativeLevelTypeID = 3
                                 OR lh.AdminLevel4ID = @OrganizationAdministrativeLevelID
                                    AND @AdministrativeLevelTypeID = 4
                                 OR lh.AdminLevel5ID = @OrganizationAdministrativeLevelID
                                    AND @AdministrativeLevelTypeID = 5
                                 OR lh.AdminLevel6ID = @OrganizationAdministrativeLevelID
                                    AND @AdministrativeLevelTypeID = 6
                                 OR lh.AdminLevel7ID = @OrganizationAdministrativeLevelID
                                    AND @AdministrativeLevelTypeID = 7
                             )
                         AND ac.idfAggrCase NOT IN (
                                                       SELECT ID FROM @FilteredResults
                                                   );

                -- Administrative level of the settlement of the report administrative unit.
                INSERT INTO @FilteredResults
                SELECT ac.idfAggrCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbAggrCase ac
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537014
                WHERE ac.idfAggrCase = @idfAggrCase
                      AND ac.idfsAdministrativeUnit = @OrganizationAdministrativeSettlementID
                      AND (ac.idfAggrCase NOT IN (
                                                     SELECT ID FROM @FilteredResults
                                                 )
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
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
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
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = ag.idfsSite
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
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND sgs.idfsSite = ag.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteID = ag.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
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
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteID = ag.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT ag.idfAggrCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbAggrCase ag
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
            WHERE ag.idfAggrCase = @idfAggrCase
                  AND a.GrantingActorSiteID = ag.idfsSite;

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
            SELECT ac.idfAggrCase
            FROM dbo.tlbAggrCase ac
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = ac.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE ac.intRowStatus = 0
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
        SELECT ac.idfAggrCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbAggrCase ac
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = ac.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ac.idfAggrCase = @idfAggrCase
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = egm.idfEmployeeGroup
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = ac.idfsSite
        )
        GROUP BY ac.idfAggrCase, 
                 ac.idfsSite;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbAggrCase ac
                ON ac.idfAggrCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = ac.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ac.idfAggrCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ac.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbAggrCase ac
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = ac.idfsSite
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND ac.idfAggrCase = @idfAggrCase
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = @UserEmployeeID
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = ac.idfsSite
        )
        GROUP BY ac.idfAggrCase, 
                 ac.idfsSite;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbAggrCase ac
                ON ac.idfAggrCase = res.ID
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = ac.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003; -- Read permission

        INSERT INTO @FinalResults
        SELECT res.ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
        GROUP BY res.ID;

        SELECT a.idfAggrCase,
               a.idfsAggrCaseType,
               a.idfsAdministrativeUnit,
               a.idfReceivedByOffice,
               RBON.[name] AS strReceivedByOffice,
               a.idfReceivedByPerson,
               a.idfSentByOffice,
               SBON.[name] AS strSentByOffice,
               a.idfSentByPerson,
               a.idfEnteredByOffice,
               EBON.[name] AS strEnteredByOffice,
               a.idfEnteredByPerson,
               a.datReceivedByDate,
               a.datSentByDate,
               a.datEnteredByDate,
               a.datStartDate,
               a.datFinishDate,
               a.strCaseID,
               CASE AUL.node.GetLevel()
                   WHEN 1 THEN
                       10089001
                   WHEN 2 THEN
                       10089003
                   WHEN 3 THEN
                       10089002
                   WHEN 4 THEN
                       CASE
                           WHEN a.idfOffice IS NULL THEN
                               10089004
                           ELSE
                               10089005
                       END
               END AS idfsAreaType,
               ISNULL(lh.AdminLevel1ID, '') AS idfsCountry,
               ISNULL(lh.AdminLevel1Name, '') AS strCountry,
               ISNULL(lh.AdminLevel2ID, '') AS idfsRegion,
               ISNULL(lh.AdminLevel2Name, '') AS strRegion,
               ISNULL(lh.AdminLevel3ID, '') AS idfsRayon,
               ISNULL(lh.AdminLevel3Name, '') AS strRayon,
               ISNULL(settlement.idfsReference, NULL) AS idfsSettlement,
               ISNULL(settlement.[name], NULL) AS strSettlement,
               settlement.idfsType AS idfsSettlementType,
               LocType.[name] AS strSettlementType,
               Period.idfsBaseReference AS idfsPeriodType,
               Period.strTextString AS strPeriodName,
               a.idfCaseObservation,
               a.idfDiagnosticObservation,
               a.idfProphylacticObservation,
               a.idfSanitaryObservation,
               DiagnosticObs.idfsFormTemplate AS idfsDiagnosticFormTemplate,
               ProphylacticObs.idfsFormTemplate AS idfsProphylacticFormTemplate,
               SanitaryObs.idfsFormTemplate AS idfsSanitaryFormTemplate,
               CaseObs.idfsFormTemplate AS idfsCaseFormTemplate,
               a.idfDiagnosticVersion AS idfDiagnosticVersionID,
               a.idfProphylacticVersion AS idfProphylacticVersionID,
               a.idfSanitaryVersion AS idfSanitaryVersionID,
               a.idfOffice AS Organization, -- ToDo: Get details on which organization to send
               dbo.FN_GBL_ConcatFullName(
                                            ReceivedByPerson.strFamilyName,
                                            ReceivedByPerson.strFirstName,
                                            ReceivedByPerson.strSecondName
                                        ) AS strReceivedByPerson,
               dbo.FN_GBL_ConcatFullName(
                                            EnteredByPerson.strFamilyName,
                                            EnteredByPerson.strFirstName,
                                            EnteredByPerson.strSecondName
                                        ) AS strEnteredByPerson,
               dbo.FN_GBL_ConcatFullName(
                                            SentByPerson.strFamilyName,
                                            SentByPerson.strFirstName,
                                            SentByPerson.strSecondName
                                        ) AS strSentByPerson,
               a.idfsSite,
               organizationAdminUnit.name AS strOrganization,
               a.idfVersion,
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
        FROM @FinalResults res
            INNER JOIN dbo.tlbAggrCase a
                ON a.idfAggrCase = res.ID
            LEFT JOIN dbo.tlbOffice RBO
                ON RBO.idfOffice = a.idfReceivedByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) RBON
                ON RBON.idfsReference = RBO.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbOffice EBO
                ON EBO.idfOffice = a.idfEnteredByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) EBON
                ON EBON.idfsReference = EBO.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbOffice SBO
                ON SBO.idfOffice = a.idfSentByOffice
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) SBON
                ON SBON.idfsReference = SBO.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbPerson ReceivedByPerson
                ON a.idfReceivedByPerson = ReceivedByPerson.idfPerson
            LEFT JOIN dbo.tlbPerson EnteredByPerson
                ON a.idfEnteredByPerson = EnteredByPerson.idfPerson
            LEFT JOIN dbo.tlbPerson SentByPerson
                ON a.idfSentByPerson = SentByPerson.idfPerson
       		INNER JOIN dbo.gisLocation AUL 
                ON AUL.idfsLocation = a.idfsAdministrativeUnit
            INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = a.idfsAdministrativeUnit
            LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlement
                ON settlement.idfsReference = a.idfsAdministrativeUnit
            LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) LocType
                ON LocType.idfsReference = settlement.idfsType
            LEFT JOIN dbo.trtStringNameTranslation Period
                ON Period.idfsBaseReference = CASE
                                                  WHEN DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 0 THEN
                                                      10091002 /*day*/
                                                  WHEN DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 6 THEN
                                                      10091004 /*week - use datediff with day because datediff with week will return incorrect result if first day of week in country differ from sunday*/
                                                  WHEN DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) = 0 THEN
                                                      10091001 /*month*/
                                                  WHEN DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) = 0 THEN
                                                      10091003 /*quarter*/
                                                  WHEN DATEDIFF(YEAR, a.datStartDate, a.datFinishDate) = 0 THEN
                                                      10091005 /*year*/
                                              END
                   AND Period.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
            LEFT JOIN dbo.tlbObservation CaseObs
                ON idfCaseObservation = CaseObs.idfObservation
            LEFT JOIN dbo.tlbObservation DiagnosticObs
                ON idfDiagnosticObservation = DiagnosticObs.idfObservation
            LEFT JOIN dbo.tlbObservation ProphylacticObs
                ON idfProphylacticObservation = ProphylacticObs.idfObservation
            LEFT JOIN dbo.tlbObservation SanitaryObs
                ON idfSanitaryObservation = SanitaryObs.idfObservation
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) organizationAdminUnit
                ON a.idfOffice = organizationAdminUnit.idfOffice
        WHERE (
                  @idfAggrCase IS NULL
                  OR a.idfAggrCase = @idfAggrCase
              )
              AND (CASE
                       WHEN @idfsAggrCaseType IS NULL THEN
                           1
                       WHEN ISNULL(a.idfsAggrCaseType, '') = @idfsAggrCaseType THEN
                           1
                       ELSE
                           0
                   END = 1
                  )
              AND (CASE
                       WHEN @idfAggrCase IS NULL THEN
                           1
                       WHEN ISNULL(a.idfAggrCase, '') = @idfAggrCase THEN
                           1
                       ELSE
                           0
                   END = 1
                  );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
