-- ================================================================================================
-- Name: USP_OMM_Session_GetList
--
-- Description: Get a list of outbreak sessions for the outbreak module.
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Lamont Mitchell 01/09/2019 Removed ReturnCode and Return Message
-- Stephen Long	   01/13/2020 Changed from strDefault to name to pick up language translation.
-- Stephen Long	   01/26/2020 Added site list parameter for site filtration.
-- Stephen Long	   05/19/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long	   11/18/2020 Added site ID to the query.
-- Stephen Long	   11/27/2020 Added configurable site filtration rules.
-- Stephen Long	   12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long	   12/24/2020 Modified join on disease filtration default role rule.  Changed 
--                            function call to bring back inactive outbreak status and type to 
--                            handle v6.1 data that has been made obsolete.
-- Stephen Long	   12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long	   04/04/2021 Added updated pagination and location hierarchy.
-- Stephen Long	   08/16/2021 Added gisLocation and location joins where IsDescendent is called.
-- Doug Albanese   11/17/2021 Fixed the default range for returning Outbreak for the past year only.
-- Doug Albanese   12/03/2021 Integrated the new FN_GBL_LocationHierarchy_Flattened for use with 
--                             the Location Hierarchy
-- Stephen Long    03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Doug Albanese   05/16/2022 Corrected Date Range, when not passed. This causes other searches 
--                            not to work well.
-- Stephen Long    06/03/2022 Updated to point default access rules to base reference.
-- Doug Albanese   01/10/2023 Changed the default sorting to correctly sort for "Status" and then 
--                            "Start Date"
-- Stephen Long    01/11/2023 Updated for site filtration queries.
-- Doug Albanese   01/12/2023 Further correction on default sorting on initial load.
-- Stephen Long    01/14/2023 Fix on site filtration queries; added site permission table 
--                            variables.
-- Doug Albanese   01/25/2023 Added logic to exclude migration status in the base reference
-- Doug Albanese   01/25/2023 Included "intOrder" for Outbreak Status to correctly order the initial 
--                            listing of sessions
-- Doug Albanese   02/10/2023 Change the "Quick Search" to operate against "Name" instead of 
--                            "Default"
-- Doug Albanese   03/10/2023 Defect 5586: Migrated data, with foreign addresses, are not 
--                            searchable.
-- Doug Albanese   03/15/2023 Changes to swap out idfGeoLocation with idfsLocation
-- Stephen Long    04/03/2023 Fixes for bug #5511.
-- Stephen Long    07/05/2023 Fix on site permission deletion query.
--
-- exec [dbo].[USP_OMM_Session_GetList] @LanguageId = 'en-us', @UserSiteId = 0, @UserOrganizationID = 0, @UserEmployeeId = 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Session_GetList]
(
    @LanguageID NVARCHAR(50),
    @OutbreakID NVARCHAR(200) = NULL,
    @OutbreakTypeID BIGINT = NULL,
    @SearchDiagnosesGroup BIGINT = NULL,
    @StartDateFrom DATETIME = NULL,
    @StartDateTo DATETIME = NULL,
    @OutbreakStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @QuickSearch NVARCHAR(200) = '',
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'INIT',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @firstRec INT = (@PageNumber - 1) * @pagesize,
            @lastRec INT = (@PageNumber * @pageSize + 1),
            @AdministrativeLevelNode AS HIERARCHYID,
            @RuleActiveStatus INT = 0,
            @AdministrativeLevelTypeID INT,
            @OrganizationAdministrativeLevelNode HIERARCHYID;
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
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FilteredResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID)
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

        IF @AdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @AdministrativeLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @AdministrativeLevelID;
        END;

        IF @QuickSearch = ''
           OR @QuickSearch IS NULL
        BEGIN
            -- ========================================================================================
            -- NO CONFIGURABLE FILTRATION RULES APPLIED
            --
            -- For first and second level sites, do not apply any site configurable rules.
            -- ========================================================================================
            IF @ApplySiteFiltrationIndicator = 0
            BEGIN
                INSERT INTO @Results
                SELECT idfOutbreak,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          );
            END
            ELSE
            BEGIN
                -- =======================================================================================
                -- CONFIGURABLE FILTRATION RULES
                -- 
                -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
                -- overlap the default rules.
                -- =======================================================================================
                INSERT INTO @Results
                SELECT idfOutbreak,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          );

                -- =======================================================================================
                -- DEFAULT CONFIGURABLE FILTRATION RULES
                --
                -- Apply active default configurable filtration rules for third level sites.
                -- =======================================================================================
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
                WHERE AccessRuleID = 10537022;

                SELECT @RuleActiveStatus = ActiveIndicator
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537022;

                IF @RuleActiveStatus = 0
                BEGIN
                    SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                    FROM @DefaultAccessRules
                    WHERE AccessRuleID = 10537022;

                    SELECT @AdministrativeLevelNode
                        = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
                    FROM dbo.tlbOffice o
                        INNER JOIN dbo.tlbGeoLocationShared l
                            ON l.idfGeoLocationShared = o.idfLocation
                        INNER JOIN dbo.gisLocation g
                            ON g.idfsLocation = l.idfsLocation
                               AND g.intRowStatus = 0
                    WHERE o.idfOffice = @UserOrganizationID
                          AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

                    -- Administrative level specified in the rule of the site where the session was created.
                    INSERT INTO @FilteredResults
                    SELECT ob.idfOutbreak,
                           a.ReadPermissionIndicator,
                           a.AccessToPersonalDataPermissionIndicator,
                           a.AccessToGenderAndAgeDataPermissionIndicator,
                           a.WritePermissionIndicator,
                           a.DeletePermissionIndicator
                    FROM dbo.tlbOutbreak ob
                        INNER JOIN dbo.tstSite s
                            ON ob.idfsSite = s.idfsSite
                        INNER JOIN dbo.tlbOffice o
                            ON o.idfOffice = s.idfOffice
                               AND o.intRowStatus = 0
                        INNER JOIN dbo.tlbGeoLocationShared l
                            ON l.idfGeoLocationShared = o.idfLocation
                               AND l.intRowStatus = 0
                        INNER JOIN dbo.gisLocation g
                            ON g.idfsLocation = l.idfsLocation
                               AND g.intRowStatus = 0
                        INNER JOIN @DefaultAccessRules a
                            ON a.AccessRuleID = 10537022
                    WHERE ob.intRowStatus = 0
                          AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;
                END;

                --
                -- Apply at the user's site group level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
                    INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                        ON userSiteGroup.idfsSite = @UserSiteID
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                --
                -- Apply at the user's site level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteID = @UserSiteID
                           AND ara.ActorEmployeeGroupID IS NULL
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                -- 
                -- Apply at the user's employee group level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                -- 
                -- Apply at the user's ID level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                --
                -- Apply at the user's site group level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup sgs
                        ON sgs.idfsSite = @UserSiteID
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND sgs.idfsSite = o.idfsSite;

                -- 
                -- Apply at the user's site level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteID = @UserSiteID
                           AND ara.ActorEmployeeGroupID IS NULL
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteID = o.idfsSite;

                -- 
                -- Apply at the user's employee group level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteID = o.idfsSite;

                -- 
                -- Apply at the user's ID level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteID = o.idfsSite;

                -- Copy filtered results to results and use search criteria
                INSERT INTO @Results
                SELECT ID,
                       ReadPermissionIndicator,
                       AccessToPersonalDataPermissionIndicator,
                       AccessToGenderAndAgeDataPermissionIndicator,
                       WritePermissionIndicator,
                       DeletePermissionIndicator
                FROM @FilteredResults
                    INNER JOIN dbo.tlbOutbreak o
                        ON o.idfOutbreak = ID
                    INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          )
                GROUP BY ID,
                         ReadPermissionIndicator,
                         AccessToPersonalDataPermissionIndicator,
                         AccessToGenderAndAgeDataPermissionIndicator,
                         WritePermissionIndicator,
                         DeletePermissionIndicator;
            END;

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
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN dbo.tstObjectAccess oa
                                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                                       AND oa.intRowStatus = 0
                            WHERE o.intRowStatus = 0
                                  AND oa.intPermission = 1
                                  AND oa.idfsObjectType = 10060001 -- Disease
                                  AND oa.idfActor = -506 -- Default role
                        );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @Results
            SELECT o.idfOutbreak,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbOutbreak o
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND o.intRowStatus = 0
                  AND oa.idfActor = egm.idfEmployeeGroup
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          );

            DELETE res
            FROM @Results res
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = res.ID
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE o.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @Results
            SELECT o.idfOutbreak,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbOutbreak o
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                       AND oa.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND o.intRowStatus = 0
                  AND oa.idfActor = @UserEmployeeID
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          );

            DELETE FROM @Results
            WHERE ID IN (
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN dbo.tstObjectAccess oa
                                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                                       AND oa.intRowStatus = 0
                            WHERE o.intRowStatus = 0
                                  AND oa.intPermission = 1 -- Deny permission
                                  AND oa.idfsObjectType = 10060001 -- Disease
                                  AND idfActor = @UserEmployeeID
                        );

            -- =======================================================================================
            -- SITE FILTRATION RULES
            --
            -- Apply site filtration rules from use case SAUC29.
            -- =======================================================================================		
            -- 
            -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
            -- as all records have been pulled above with or without filtration rules applied.
            --
            DELETE FROM @Results
            WHERE EXISTS
            (
                SELECT o.idfOutbreak
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tstObjectAccess oa
                        ON oa.idfsObjectID = o.idfsSite
                           AND oa.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = @UserSiteID
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE o.intRowStatus = 0
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
            SELECT o.idfOutbreak,
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059003
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059006
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059007
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059004
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059002
                   )
            FROM dbo.tlbOutbreak o
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
            WHERE o.intRowStatus = 0
                  AND EXISTS
            (
                SELECT * FROM @UserGroupSitePermissions WHERE SiteID = o.idfsSite
            )
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          );

            DELETE res
            FROM @Results res
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = res.ID
                INNER JOIN @UserGroupSitePermissions ugsp
                    ON ugsp.SiteID = o.idfsSite
            WHERE ugsp.Permission = 2 -- Deny permission
                  AND ugsp.PermissionTypeID = 10059003; -- Read permission

            --
            -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @Results
            SELECT o.idfOutbreak,
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059003
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059006
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059007
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059004
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059002
                   )
            FROM dbo.tlbOutbreak o
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
            WHERE o.intRowStatus = 0
                  AND EXISTS
            (
                SELECT * FROM @UserSitePermissions WHERE SiteID = o.idfsSite
            )
                      AND (
                              (o.datStartDate BETWEEN @StartDateFrom AND @StartDateTo)
                              OR (@StartDateFrom IS NULL AND @StartDateTo IS NULL)
                          )
                      AND (
                              o.OutbreakTypeID = @OutbreakTypeID
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              o.idfsOutbreakStatus = @OutbreakStatusTypeID
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              o.idfsDiagnosisOrDiagnosisGroup = @SearchDiagnosesGroup
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (
                              o.strOutbreakID LIKE '%' + @OutbreakID + '%'
                              OR @OutbreakID IS NULL
                          );

            DELETE res
            FROM @Results res
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = res.ID
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = o.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003; -- Read permission
        END
        ELSE
        BEGIN
            -- ========================================================================================
            -- NO CONFIGURABLE FILTRATION RULES APPLIED
            --
            -- For first and second level sites, do not apply any configurable filtration rules.
            -- ========================================================================================
            IF @ApplySiteFiltrationIndicator = 0
            BEGIN
                INSERT INTO @Results
                SELECT idfOutbreak,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND (
                              strOutbreakID LIKE '%' + @QuickSearch + '%'
                              OR d.name LIKE '%' + @QuickSearch + '%'
                              OR os.name LIKE '%' + @QuickSearch + '%'
                              OR ot.name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                              OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                          );
            END
            ELSE
            BEGIN
                -- =======================================================================================
                -- CONFIGURABLE FILTRATION RULES
                -- 
                -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
                -- overlap the default rules.
                -- =======================================================================================
                INSERT INTO @Results
                SELECT idfOutbreak,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID
                      AND (
                              strOutbreakID LIKE '%' + @QuickSearch + '%'
                              OR d.name LIKE '%' + @QuickSearch + '%'
                              OR os.name LIKE '%' + @QuickSearch + '%'
                              OR ot.name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                              OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                          );

                -- =======================================================================================
                -- DEFAULT CONFIGURABLE FILTRATION RULES
                --
                -- Apply active default configurable filtration rules for third level sites.
                -- =======================================================================================
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
                WHERE AccessRuleID = 10537022;

                SELECT @RuleActiveStatus = ActiveIndicator
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537022;

                IF @RuleActiveStatus = 0
                BEGIN
                    SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                    FROM @DefaultAccessRules
                    WHERE AccessRuleID = 10537022;

                    SELECT @AdministrativeLevelNode
                        = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
                    FROM dbo.tlbOffice o
                        INNER JOIN dbo.tlbGeoLocationShared l
                            ON l.idfGeoLocationShared = o.idfLocation
                        INNER JOIN dbo.gisLocation g
                            ON g.idfsLocation = l.idfsLocation
                               AND g.intRowStatus = 0
                    WHERE o.idfOffice = @UserOrganizationID
                          AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

                    -- Administrative level specified in the rule of the site where the session was created.
                    INSERT INTO @FilteredResults
                    SELECT ob.idfOutbreak,
                           a.ReadPermissionIndicator,
                           a.AccessToPersonalDataPermissionIndicator,
                           a.AccessToGenderAndAgeDataPermissionIndicator,
                           a.WritePermissionIndicator,
                           a.DeletePermissionIndicator
                    FROM dbo.tlbOutbreak ob
                        INNER JOIN dbo.tstSite s
                            ON ob.idfsSite = s.idfsSite
                        INNER JOIN dbo.tlbOffice o
                            ON o.idfOffice = s.idfOffice
                               AND o.intRowStatus = 0
                        INNER JOIN dbo.tlbGeoLocationShared l
                            ON l.idfGeoLocationShared = o.idfLocation
                               AND l.intRowStatus = 0
                        INNER JOIN dbo.gisLocation g
                            ON g.idfsLocation = l.idfsLocation
                               AND g.intRowStatus = 0
                        INNER JOIN @DefaultAccessRules a
                            ON a.AccessRuleID = 10537022
                    WHERE ob.intRowStatus = 0
                          AND g.node.IsDescendantOf(@OrganizationAdministrativeLevelNode) = 1;
                END;

                --
                -- Apply at the user's site group level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
                    INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                        ON userSiteGroup.idfsSite = @UserSiteID
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                --
                -- Apply at the user's site level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteID = @UserSiteID
                           AND ara.ActorEmployeeGroupID IS NULL
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                -- 
                -- Apply at the user's employee group level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                -- 
                -- Apply at the user's ID level, granted by a site group.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                        ON grantingSGS.idfsSite = o.idfsSite
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

                --
                -- Apply at the user's site group level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tflSiteToSiteGroup sgs
                        ON sgs.idfsSite = @UserSiteID
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND sgs.idfsSite = o.idfsSite;

                -- 
                -- Apply at the user's site level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.AccessRuleActor ara
                        ON ara.ActorSiteID = @UserSiteID
                           AND ara.ActorEmployeeGroupID IS NULL
                           AND ara.intRowStatus = 0
                    INNER JOIN dbo.AccessRule a
                        ON a.AccessRuleID = ara.AccessRuleID
                           AND a.intRowStatus = 0
                           AND a.DefaultRuleIndicator = 0
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteID = o.idfsSite;

                -- 
                -- Apply at the user's employee group level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteID = o.idfsSite;

                -- 
                -- Apply at the user's ID level, granted by a site.
                --
                INSERT INTO @FilteredResults
                SELECT o.idfOutbreak,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbOutbreak o
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
                WHERE o.intRowStatus = 0
                      AND a.GrantingActorSiteID = o.idfsSite;

                -- Copy filtered results to results and use search criteria
                INSERT INTO @Results
                SELECT ID,
                       ReadPermissionIndicator,
                       AccessToPersonalDataPermissionIndicator,
                       AccessToGenderAndAgeDataPermissionIndicator,
                       WritePermissionIndicator,
                       DeletePermissionIndicator
                FROM @FilteredResults
                    INNER JOIN dbo.tlbOutbreak o
                        ON o.idfOutbreak = ID
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND (
                              strOutbreakID LIKE '%' + @QuickSearch + '%'
                              OR d.name LIKE '%' + @QuickSearch + '%'
                              OR os.name LIKE '%' + @QuickSearch + '%'
                              OR ot.name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                              OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                              OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                          )
                GROUP BY ID,
                         ReadPermissionIndicator,
                         AccessToPersonalDataPermissionIndicator,
                         AccessToGenderAndAgeDataPermissionIndicator,
                         WritePermissionIndicator,
                         DeletePermissionIndicator;
            END;

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
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN dbo.tstObjectAccess oa
                                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                                       AND oa.intRowStatus = 0
                            WHERE o.intRowStatus = 0
                                  AND oa.intPermission = 1
                                  AND oa.idfsObjectType = 10060001 -- Disease
                                  AND oa.idfActor = -506 -- Default role
                        );

            --
            -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
            -- Allows and denies will supersede level 0.
            --
            INSERT INTO @Results
            SELECT o.idfOutbreak,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbOutbreak o
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
            WHERE oa.intPermission = 2 -- Allow permission
                  AND o.intRowStatus = 0
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND (
                          strOutbreakID LIKE '%' + @QuickSearch + '%'
                          OR d.name LIKE '%' + @QuickSearch + '%'
                          OR os.name LIKE '%' + @QuickSearch + '%'
                          OR ot.name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                          OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                      );

            DELETE res
            FROM @Results res
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = res.ID
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup;

            --
            -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @Results
            SELECT o.idfOutbreak,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbOutbreak o
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
            WHERE oa.intPermission = 2 -- Allow permission
                  AND o.intRowStatus = 0
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND (
                          strOutbreakID LIKE '%' + @QuickSearch + '%'
                          OR d.name LIKE '%' + @QuickSearch + '%'
                          OR os.name LIKE '%' + @QuickSearch + '%'
                          OR ot.name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                          OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                      );

            DELETE FROM @Results
            WHERE ID IN (
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN dbo.tstObjectAccess oa
                                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                                       AND oa.intRowStatus = 0
                            WHERE o.intRowStatus = 0
                                  AND oa.intPermission = 1 -- Deny permission
                                  AND oa.idfsObjectType = 10060001 -- Disease
                                  AND idfActor = @UserEmployeeID
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
                SELECT o.idfOutbreak
                FROM dbo.tlbOutbreak o
                    INNER JOIN dbo.tstObjectAccess oa
                        ON oa.idfsObjectID = o.idfsSite
                           AND oa.intRowStatus = 0
                    INNER JOIN dbo.tlbEmployeeGroup eg
                        ON eg.idfsSite = @UserSiteID
                           AND eg.intRowStatus = 0
                    INNER JOIN dbo.trtBaseReference br
                        ON br.idfsBaseReference = eg.idfEmployeeGroup
                           AND br.intRowStatus = 0
                           AND br.blnSystem = 1
                WHERE o.intRowStatus = 0
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
            SELECT o.idfOutbreak,
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059003
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059006
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059007
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059004
                   ),
                   (
                       SELECT Permission
                       FROM @UserGroupSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059002
                   )
            FROM dbo.tlbOutbreak o
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
            WHERE o.intRowStatus = 0
                  AND EXISTS
            (
                SELECT * FROM @UserGroupSitePermissions WHERE SiteID = o.idfsSite
            )
                  AND (
                          strOutbreakID LIKE '%' + @QuickSearch + '%'
                          OR d.name LIKE '%' + @QuickSearch + '%'
                          OR os.name LIKE '%' + @QuickSearch + '%'
                          OR ot.name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                          OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                      );

            DELETE res
            FROM @Results res
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = res.ID
                INNER JOIN @UserGroupSitePermissions ugsp
                    ON ugsp.SiteID = o.idfsSite
            WHERE ugsp.Permission = 2 -- Deny permission
                  AND ugsp.PermissionTypeID = 10059003; -- Read permission

            --
            -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
            -- will supersede level 1.
            --
            INSERT INTO @Results
            SELECT o.idfOutbreak,
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059003
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059006
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059007
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059004
                   ),
                   (
                       SELECT Permission
                       FROM @UserSitePermissions
                       WHERE SiteID = o.idfsSite
                             AND PermissionTypeID = 10059002
                   )
            FROM dbo.tlbOutbreak o
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
            WHERE o.intRowStatus = 0
                  AND EXISTS
            (
                SELECT * FROM @UserSitePermissions WHERE SiteID = o.idfsSite
            )
                  AND (
                          strOutbreakID LIKE '%' + @QuickSearch + '%'
                          OR d.name LIKE '%' + @QuickSearch + '%'
                          OR os.name LIKE '%' + @QuickSearch + '%'
                          OR ot.name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                          OR lh.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                          OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                      );

            DELETE FROM @Results
            WHERE ID IN (
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN @UserSitePermissions usp
                                    ON usp.SiteID = o.idfsSite
                            WHERE usp.Permission = 4 -- Deny permission
                                  AND usp.PermissionTypeID = 10059003 -- Read permission
                        );
        END;

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
		
        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'OutbreakID'
                                                        AND @SortOrder = 'ASC' THEN
                                          (os.name + ' ' + o.strOutbreakID)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OutbreakID'
                                                        AND @SortOrder = 'DESC' THEN
                                               (os.name + ' ' + o.strOutbreakID)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OutbreakStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       os.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OutbreakStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       os.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OutbreakTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ot.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OutbreakTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ot.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel1Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel1Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel2Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel2Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel3Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel3Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel3Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel3Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel4Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel4Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel4Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel4Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel5Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel5Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel5Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel5Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel6Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel6Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel6Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel6Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel7Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel7Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel7Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel7Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       d.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       d.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'StartDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       o.datStartDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'StartDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       o.datStartDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'INIT' THEN
                                                       CAST(os.intOrder AS NVARCHAR) + ',' + CONVERT(NVARCHAR, o.datStartDate, 12) + ' DESC'
                                               END DESC
                                     ) AS ROWNUM,
                   ID,
                   c = COUNT(*) OVER ()
            FROM @FinalResults res
                INNER JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = res.ID
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
           )
        SELECT paging.ROWNUM,
               o.idfOutbreak,
               strOutbreakID AS OutbreakID,
               d.name AS DiseaseName,
               os.name AS OutbreakStatusTypeName,
               ot.name AS OutbreakTypeName,
               lh.AdminLevel1Name AS AdministrativeLevel1Name,
               lh.AdminLevel2Name AS AdministrativeLevel2Name,
               lh.AdminLevel3Name AS AdministrativeLevel3Name,
               lh.AdminLevel4Name AS AdministrativeLevel4Name,
               lh.AdminLevel5Name AS AdministrativeLevel5Name,
               lh.AdminLevel6Name AS AdministrativeLevel6Name,
               lh.AdminLevel7Name AS AdministrativeLevel7Name,
               o.datStartDate AS StartDate,
               o.idfsSite AS SiteID,
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
               END AS DeletePermissionIndicator,
               c AS RecordCount,
               (
                   SELECT COUNT(*) FROM dbo.tlbOutbreak WHERE intRowStatus = 0
               ) AS TotalCount,
               CurrentPage = @PageNumber,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
        FROM @FinalResults res
            INNER JOIN paging
                ON paging.ID = res.ID
            INNER JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = res.ID
            INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                ON os.idfsReference = o.idfsOutbreakStatus AND os.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
			LEFT JOIN FN_GBL_LocationHierarchy_Flattened (@LanguageID) lh
                ON lh.idfsLocation = o.idfsLocation
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                ON ot.idfsReference = o.OutbreakTypeId
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        ORDER BY paging.ROWNUM;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END