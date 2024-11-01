SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_GETDetail
--
-- Description:	Get disease detail (one record) for the veterinary edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/18/2019 Initial release.
-- Stephen Long     04/29/2019 Added connected disease report fields for use case VUC11 and VUC12.
-- Stephen Long     05/26/2019 Added farm epidemiological observation ID to select list.
-- Stephen Long     10/02/2019 Adjusted for changes to the person select list function.
-- Ann Xiong		12/05/2019 Added YNTestConducted, OIECode, ReportCategoryTypeID, 
--                             ReportCategoryTypeName to select list.
-- Stephen Long     02/14/2020 Added connected disease report ID and EIDSS report ID to the query.
-- Stephen Long     11/29/2021 Removed return code and message for POCO.
-- Stephen Long     12/07/2021 Added farm and farm owner fields.
-- Stephen Long     01/12/2022 Added street and postal code ID's to the query.
-- Stephen Long     01/19/2022 Added farm master ID and farm owner ID to the query.
-- Stephen Long     01/24/2022 Changed country ID and name to administrative level 0 to match use 
--                             case.
-- Stephen Long     04/28/2022 Added received by organization and person identifiers.
-- Doug Albanese    07/26/2022 Add field FarmEpidemiologicalTemplateID, to correctly identify a 
--                             form that has been answered
-- Stephen Long     05/16/2023 Fix for item 5584.
-- Stephen Long     06/07/2023 Fix for 4597 and 4598.
-- Stephen Long     07/05/2023 Fix on site permission deletion query.
-- ================================================================================================
CREATE or ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_GETDetail]
(
    @LanguageID AS NVARCHAR(50),
    @DiseaseReportID AS BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = null,
    @UserEmployeeID BIGINT = null,
    @ApplyFiltrationIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SiteID BIGINT = (
                                     SELECT idfsSite
                                     FROM dbo.tlbVetCase
                                     WHERE idfVetCase = @DiseaseReportID
                                 );
    DECLARE @RelatedToIdentifiers TABLE 
    (
        ID BIGINT NOT NULL, 
        ReportID NVARCHAR(200) NOT NULL
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

    DECLARE @CaseOutbreakSessionImportedIndicator INT = (
                                                            SELECT CASE
                                                                       WHEN idfOutbreak IS NOT NULL
                                                                            AND (strCaseID IS NOT NULL OR LegacyCaseID IS NOT NULL) THEN
                                                                           1
                                                                       ELSE
                                                                           0
                                                                   END
                                                            FROM dbo.tlbVetCase
                                                            WHERE idfVetCase = @DiseaseReportID
                                                        );

    BEGIN TRY
    IF @UserSiteID = @SiteID OR @ApplyFiltrationIndicator = 0
        BEGIN
            INSERT INTO @Results
            SELECT @DiseaseReportID,
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
                ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL
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

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0,
                    @AdministrativeLevelTypeID INT,
                    @OrganizationAdministrativeLevelID BIGINT,
                    @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
            DECLARE @DefaultAccessRules TABLE
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

            --
            -- Report data shall be available to all sites of the same administrative level 
            -- specified in the rule.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537009;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537009;

                SELECT @OrganizationAdministrativeLevelID = CASE
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
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tstSite s
                        ON v.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND (
                              g.Level1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfFarm = v.idfFarm
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND (
                              g.Level1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );
            END;

            --
            -- Report data shall be available to all sites' organizations connected to the particular report.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537010;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Investigated and reported by organizations
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND (
                              v.idfInvestigatedByOffice = @UserOrganizationID
                              OR v.idfReportedByOffice = @UserOrganizationID
                          );

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVetCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = m.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND m.idfVetCase = @DiseaseReportID
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfVetCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVetCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = m.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND m.idfVetCase = @DiseaseReportID
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfVetCase,
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
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537011;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbOutbreak o
                        ON v.idfVetCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537011
                WHERE v.idfVetCase = @DiseaseReportID                  
                      AND o.idfsSite = @UserSiteID
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
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND sgs.idfsSite = v.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
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
            WHERE v.idfVetCase = @DiseaseReportID                  
                  AND a.GrantingActorSiteID = v.idfsSite;

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
                        SELECT v.idfVetCase
                        FROM dbo.tlbVetCase v
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT v.idfVetCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND v.idfVetCase = @DiseaseReportID
              AND oa.idfActor = egm.idfEmployeeGroup;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT v.idfVetCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND v.idfVetCase = @DiseaseReportID
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT v.idfVetCase
                        FROM dbo.tlbVetCase v
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1 -- Deny permission
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
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vc.idfVetCase = @DiseaseReportID
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
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vc.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE vc.idfVetCase = @DiseaseReportID
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
        WHERE vc.idfVetCase = @DiseaseReportID
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = res.ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = vc.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
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

        IF @CaseOutbreakSessionImportedIndicator = 1
        BEGIN
            DECLARE @RelatedToDiseaseReportID BIGINT = @DiseaseReportID,
                    @ConnectedDiseaseReportID BIGINT;

            INSERT INTO @RelatedToIdentifiers
            SELECT idfVetCase, 
                   strCaseID
            FROM dbo.tlbVetCase 
            WHERE idfVetCase = @DiseaseReportID;

            WHILE EXISTS (SELECT * FROM dbo.VetDiseaseReportRelationship WHERE VetDiseaseReportID = @RelatedToDiseaseReportID)
            BEGIN
                INSERT INTO @RelatedToIdentifiers
                SELECT RelatedToVetDiseaseReportID, 
                       strCaseID
                FROM dbo.VetDiseaseReportRelationship  
                     INNER JOIN dbo.tlbVetCase ON idfVetCase = RelatedToVetDiseaseReportID
                WHERE VetDiseaseReportID = @RelatedToDiseaseReportID;

                SET @RelatedToDiseaseReportID = (SELECT RelatedToVetDiseaseReportID FROM dbo.VetDiseaseReportRelationship WHERE VetDiseaseReportID = @RelatedToDiseaseReportID);
            END
        END

        SELECT vc.idfVetCase AS DiseaseReportID,
               vc.idfFarm AS FarmID,
               f.idfFarmActual AS FarmMasterID,
               f.strFarmCode AS EIDSSFarmID,
               CASE
                   WHEN f.strNationalName IS NULL THEN
                       f.strInternationalName
                   WHEN f.strNationalName = '' THEN
                       f.strInternationalName
                   ELSE
                       f.strNationalName
               END AS FarmName,
               lh.AdminLevel1ID AS FarmAddressAdministrativeLevel0ID,
               lh.AdminLevel1Name AS FarmAddressAdministrativeLevel0Name,
               lh.AdminLevel2ID AS FarmAddressAdministrativeLevel1ID,
               lh.AdminLevel2Name AS FarmAddressAdministrativeLevel1Name,
               lh.AdminLevel3ID AS FarmAddressAdministrativeLevel2ID,
               lh.AdminLevel3Name AS FarmAddressAdministrativeLevel2Name,
               lh.AdminLevel4ID AS FarmAddressAdministrativeLevel3ID,
               lh.AdminLevel4Name AS FarmAddressAdministrativeLevel3Name,
               farmSettlementType.idfsReference AS FarmAddressSettlementTypeID,
               farmSettlementType.name AS FarmAddressSettlementTypeName,
               farmSettlement.idfsReference AS FarmAddressSettlementID,
               farmSettlement.name AS FarmAddressSettlementName,
               st.idfStreet AS FarmAddressStreetID,
               glFarm.strStreetName AS FarmAddressStreetName,
               glFarm.strBuilding AS FarmAddressBuilding,
               glFarm.strApartment AS FarmAddressApartment,
               glFarm.strHouse AS FarmAddressHouse,
               pc.idfPostalCode AS FarmAddressPostalCodeID,
               glFarm.strPostCode AS FarmAddressPostalCode,
               glFarm.dblLatitude AS FarmAddressLatitude,
               glFarm.dblLongitude AS FarmAddressLongitude,
               h.idfHuman AS FarmOwnerID,
               h.strPersonID AS EIDSSFarmOwnerID,
               h.strFirstName AS FarmOwnerFirstName,
               h.strLastName AS FarmOwnerLastName,
               h.strSecondName AS FarmOwnerSecondName,
               f.strContactPhone AS Phone,
               f.strEmail AS Email,
               vc.idfsFinalDiagnosis AS DiseaseID,
               disease.name AS DiseaseName,
               vc.idfPersonEnteredBy AS EnteredByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personEnteredBy.strFamilyName,
                                            personEnteredBy.strFirstName,
                                            personEnteredBy.strSecondName
                                        ) AS EnteredByPersonName,
               vc.idfPersonReportedBy AS ReportedByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personReportedBy.strFamilyName,
                                            personReportedBy.strFirstName,
                                            personReportedBy.strSecondName
                                        ) AS ReportedByPersonName,
               vc.idfPersonInvestigatedBy AS InvestigatedByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personInvestigatedBy.strFamilyName,
                                            personInvestigatedBy.strFirstName,
                                            personInvestigatedBy.strSecondName
                                        ) AS InvestigatedByPersonName,
               f.idfObservation AS FarmEpidemiologicalObservationID,
               vc.idfObservation AS ControlMeasuresObservationID,
               vc.idfsSite AS SiteID,
               s.strSiteName AS SiteName,
               vc.datReportDate AS ReportDate,
               vc.datAssignedDate AS AssignedDate,
               vc.datInvestigationDate AS InvestigationDate,
               vc.datFinalDiagnosisDate AS DiagnosisDate,
               vc.strFieldAccessionID AS EIDSSFieldAccessionID,
               vc.idfsYNTestsConducted AS TestsConductedIndicator,
               vc.intRowStatus AS RowStatus,
               vc.idfReportedByOffice AS ReportedByOrganizationID,
               reportedByOrganization.name AS ReportedByOrganizationName,
               vc.idfInvestigatedByOffice AS InvestigatedByOrganizationID,
               investigatedByOrganization.name AS InvestigatedByOrganizationName,
               vc.idfReceivedByOffice AS ReceivedByOrganizationID, 
               vc.idfReceivedByPerson AS ReceivedByPersonID, 
               vc.idfsCaseReportType AS ReportTypeID,
               reportType.name AS ReportTypeName,
               vc.idfsCaseClassification AS ClassificationTypeID,
               classificationType.name AS ClassificationTypeName,
               vc.idfOutbreak AS OutbreakID,
               o.strOutbreakID AS EIDSSOutbreakID,
               vc.datEnteredDate AS EnteredDate,
               vc.strCaseID AS EIDSSReportID,
               vc.LegacyCaseID AS LegacyID,
               vc.idfsCaseProgressStatus AS ReportStatusTypeID,
               reportStatusType.name AS ReportStatusTypeName,
               vc.datModificationForArchiveDate AS ModifiedDate,
               vc.idfParentMonitoringSession AS ParentMonitoringSessionID,
               ms.strMonitoringSessionID AS EIDSSParentMonitoringSessionID,
               relatedTo.RelatedToVetDiseaseReportID AS RelatedToVeterinaryDiseaseReportID,
               relatedToReport.strCaseID AS RelatedToVeterinaryDiseaseEIDSSReportID,
               connectedTo.VetDiseaseReportID AS ConnectedDiseaseReportID,
               connectedToReport.strCaseID AS ConnectedDiseaseEIDSSReportID,
               testConductedType.name AS YNTestConducted,
               d.strOIECode AS OIECode,
               vc.idfsCaseType AS ReportCategoryTypeID,
               caseType.name AS ReportCategoryTypeName,
			   ffo.idfsFormTemplate AS FarmEpidemiologicalTemplateID, 
			   vc.strSummaryNotes as Comments,
               (SELECT STRING_AGG(ID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
               FROM @RelatedToIdentifiers) AS RelatedToIdentifiers,
               (SELECT STRING_AGG(ReportID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
               FROM @RelatedToIdentifiers) AS RelatedToReportIdentifiers,
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
            INNER JOIN dbo.tlbVetCase vc 
                ON vc.idfVetCase = res.ID 
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = vc.idfFarm
            INNER JOIN dbo.tstSite s
                ON s.idfsSite = vc.idfsSite
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000012) caseType
                ON caseType.idfsReference = vc.idfsCaseType
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
                   AND h.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation glFarm
                ON glFarm.idfGeoLocation = f.idfFarmAddress
                   AND glFarm.intRowStatus = 0
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = glFarm.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = glFarm.idfsLocation
            LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) AS farmSettlement
                ON g.node.IsDescendantOf(farmSettlement.node) = 1
            LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) farmSettlementType
                ON farmSettlementType.idfsReference = farmSettlement.idfsType
            LEFT JOIN dbo.tlbStreet st
                ON st.strStreetName = glFarm.strStreetName
            LEFT JOIN dbo.tlbPostalCode pc
                ON pc.strPostCode = glFarm.strPostCode
            LEFT JOIN dbo.tlbPerson personInvestigatedBy
                ON personInvestigatedBy.idfPerson = vc.idfPersonInvestigatedBy
            LEFT JOIN dbo.tlbPerson personEnteredBy
                ON personEnteredBy.idfPerson = vc.idfPersonEnteredBy
            LEFT JOIN dbo.tlbPerson personReportedBy
                ON personReportedBy.idfPerson = vc.idfPersonReportedBy
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = vc.idfsFinalDiagnosis
            LEFT JOIN dbo.trtDiagnosis d
                ON d.idfsDiagnosis = vc.idfsFinalDiagnosis
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) classificationType
                ON classificationType.idfsReference = vc.idfsCaseClassification
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000111) reportStatusType
                ON reportStatusType.idfsReference = vc.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000144) reportType
                ON reportType.idfsReference = vc.idfsCaseReportType
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000100) testConductedType
                ON testConductedType.idfsReference = vc.idfsYNTestsConducted
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) reportedByOrganization
                ON reportedByOrganization.idfOffice = vc.idfReportedByOffice
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) investigatedByOrganization
                ON investigatedByOrganization.idfOffice = vc.idfInvestigatedByOffice
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = vc.idfOutbreak
                   AND o.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = vc.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.VetDiseaseReportRelationship relatedTo
                ON relatedTo.VetDiseaseReportID = vc.idfVetCase
                   AND relatedTo.intRowStatus = 0
                   AND relatedTo.RelationshipTypeID = 10503001
            LEFT JOIN dbo.tlbVetCase relatedToReport
                ON relatedToReport.idfVetCase = relatedTo.RelatedToVetDiseaseReportID
                   AND relatedToReport.intRowStatus = 0
            LEFT JOIN dbo.VetDiseaseReportRelationship connectedTo
                ON connectedTo.RelatedToVetDiseaseReportID = vc.idfVetCase
                   AND connectedTo.intRowStatus = 0
                   AND connectedTo.RelationshipTypeID = 10503001
            LEFT JOIN dbo.tlbVetCase connectedToReport
                ON connectedToReport.idfVetCase = connectedTo.VetDiseaseReportID
                   AND connectedToReport.intRowStatus = 0
			LEFT JOIN dbo.tlbObservation ffo
				ON ffo.idfObservation = f.idfObservation
        WHERE vc.idfVetCase = @DiseaseReportID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
