-- ================================================================================================
-- Name: USP_OMM_Session_GetList_AVR
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
--                             not to work well.
-- Stephen Long    06/03/2022 Updated to point default access rules to base reference.
-- Edgard Torres   11/17/2022 Modified version of USP_OMM_Session_GetList 
--							  to return comma delimeted SiteIDs 
--
-- exec [dbo].[USP_OMM_Session_GetList] @LanguageId= 'en-us', @UserSiteId = 0, @UserOrganizationID = 0, @UserEmployeeId = 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Session_GetList_AVR]
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
    @SortColumn NVARCHAR(30) = 'OutbreakID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10,
	@SiteIDs NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDateFrom IS NULL
       or @StartDateFrom = NULL
    BEGIN
        SET @StartDateFrom = CAST(CAST(CAST(0xD1BA AS BIGINT) * -1 AS DATETIME) AS DATE)
    END

    IF @StartDateTo IS NULL
       OR @StartDateTo = NULL
    BEGIN
        SET @StartDateTo = CAST(CAST(CAST(0x2D247f AS BIGINT) AS DATETIME) AS DATE)
    END

    DECLARE @firstRec INT
    DECLARE @lastRec INT
    SET @firstRec = (@PageNumber - 1) * @pagesize
    SET @lastRec = (@PageNumber * @pageSize + 1)

    DECLARE @AdministrativeLevelNode AS HIERARCHYID;
    DECLARE @RuleActiveStatus INT = 0;
    DECLARE @AdministrativeLevelTypeID INT;
    DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
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

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );
    DECLARE @FilteredResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID
                                                             ));
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );

    -- Set defaults for invalid passed parameters
    IF (@StartDateFrom IS NULL)
    BEGIN
        SET @StartDateFrom = DATEADD(day, -365, GETDATE())
    END

    IF (@StartDateTo IS NULL)
    BEGIN
        SET @StartDateTo = GETDATE()
    END

    BEGIN TRY
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
            -- NO SITE FILTRATION RULES APPLIED
            --
            -- For first and second level sites, do not apply any site filtration rules.
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
                    INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup -- DISEASE
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus --STATUS...
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND o.datStartDate
                      BETWEEN @StartDateFrom AND @StartDateTo
                      AND (
                              (o.OutbreakTypeID = CASE ISNULL(@OutbreakTypeID, '')
                                                      WHEN '' THEN
                                                          OutbreakTypeID
                                                      ELSE
                                                          @OutbreakTypeID
                                                  END
                              )
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              (o.idfsOutbreakStatus = CASE ISNULL(@OutbreakStatusTypeID, '')
                                                          WHEN '' THEN
                                                              idfsOutbreakStatus
                                                          ELSE
                                                              @OutbreakStatusTypeID
                                                      END
                              )
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              (o.idfsDiagnosisOrDiagnosisGroup = CASE ISNULL(@SearchDiagnosesGroup, '')
                                                                     WHEN '' THEN
                                                                         o.idfsDiagnosisOrDiagnosisGroup
                                                                     ELSE
                                                                         @SearchDiagnosesGroup
                                                                 END
                              )
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (strOutbreakID LIKE CASE ISNULL(@OutbreakID, '')
                                                  WHEN '' THEN
                                                      '%%'
                                                  ELSE
                                                      '%' + @OutbreakID + '%'
                                              END
                          );
            END
            ELSE
            BEGIN
                -- =======================================================================================
                -- CONFIGURABLE SITE FILTRATION RULES
                -- 
                -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
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
                    INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup -- DISEASE
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus --STATUS...
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID
                      AND o.datStartDate
                      BETWEEN @StartDateFrom AND @StartDateTo
                      AND (
                              (o.OutbreakTypeID = CASE ISNULL(@OutbreakTypeID, '')
                                                      WHEN '' THEN
                                                          OutbreakTypeID
                                                      ELSE
                                                          @OutbreakTypeID
                                                  END
                              )
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              (o.idfsOutbreakStatus = CASE ISNULL(@OutbreakStatusTypeID, '')
                                                          WHEN '' THEN
                                                              idfsOutbreakStatus
                                                          ELSE
                                                              @OutbreakStatusTypeID
                                                      END
                              )
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              (o.idfsDiagnosisOrDiagnosisGroup = CASE ISNULL(@SearchDiagnosesGroup, '')
                                                                     WHEN '' THEN
                                                                         o.idfsDiagnosisOrDiagnosisGroup
                                                                     ELSE
                                                                         @SearchDiagnosesGroup
                                                                 END
                              )
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (strOutbreakID LIKE CASE ISNULL(@OutbreakID, '')
                                                  WHEN '' THEN
                                                      '%%'
                                                  ELSE
                                                      '%' + @OutbreakID + '%'
                                              END
                          );

                -- =======================================================================================
                -- DEFAULT SITE FILTRATION RULES
                --
                -- Apply active default site filtration rules for third level sites.
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
                        INNER JOIN dbo.tlbGeoLocationShared AS l
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
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup -- DISEASE
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus --STATUS...
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND o.datStartDate
                      BETWEEN @StartDateFrom AND @StartDateTo
                      AND (
                              (o.OutbreakTypeID = CASE ISNULL(@OutbreakTypeID, '')
                                                      WHEN '' THEN
                                                          OutbreakTypeID
                                                      ELSE
                                                          @OutbreakTypeID
                                                  END
                              )
                              OR @OutbreakTypeID IS NULL
                          )
                      AND (
                              (o.idfsOutbreakStatus = CASE ISNULL(@OutbreakStatusTypeID, '')
                                                          WHEN '' THEN
                                                              idfsOutbreakStatus
                                                          ELSE
                                                              @OutbreakStatusTypeID
                                                      END
                              )
                              OR @OutbreakStatusTypeID IS NULL
                          )
                      AND (
                              g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              (o.idfsDiagnosisOrDiagnosisGroup = CASE ISNULL(@SearchDiagnosesGroup, '')
                                                                     WHEN '' THEN
                                                                         o.idfsDiagnosisOrDiagnosisGroup
                                                                     ELSE
                                                                         @SearchDiagnosesGroup
                                                                 END
                              )
                              OR @SearchDiagnosesGroup IS NULL
                          )
                      AND (strOutbreakID LIKE CASE ISNULL(@OutbreakID, '')
                                                  WHEN '' THEN
                                                      '%%'
                                                  ELSE
                                                      '%' + @OutbreakID + '%'
                                              END
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
                            WHERE oa.intPermission = 1
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
                  AND datStartDate
                  BETWEEN @StartDateFrom AND @StartDateTo
                  AND (
                          (OutbreakTypeID = CASE ISNULL(@OutbreakTypeID, '')
                                                WHEN '' THEN
                                                    OutbreakTypeID
                                                ELSE
                                                    @OutbreakTypeID
                                            END
                          )
                          OR @OutbreakTypeID IS NULL
                      )
                  AND (
                          (idfsOutbreakStatus = CASE ISNULL(@OutbreakStatusTypeID, '')
                                                    WHEN '' THEN
                                                        idfsOutbreakStatus
                                                    ELSE
                                                        @OutbreakStatusTypeID
                                                END
                          )
                          OR @OutbreakStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (o.idfsDiagnosisOrDiagnosisGroup = CASE ISNULL(@SearchDiagnosesGroup, '')
                                                                 WHEN '' THEN
                                                                     o.idfsDiagnosisOrDiagnosisGroup
                                                                 ELSE
                                                                     @SearchDiagnosesGroup
                                                             END
                          )
                          OR @SearchDiagnosesGroup IS NULL
                      )
                  AND (strOutbreakID LIKE CASE ISNULL(@OutbreakID, '')
                                              WHEN '' THEN
                                                  '%%'
                                              ELSE
                                                  '%' + @OutbreakID + '%'
                                          END
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
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
            WHERE oa.intPermission = 2 -- Allow permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND o.intRowStatus = 0
                  AND oa.idfActor = @UserEmployeeID
                  AND datStartDate
                  BETWEEN @StartDateFrom AND @StartDateTo
                  AND (
                          (OutbreakTypeID = CASE ISNULL(@OutbreakTypeID, '')
                                                WHEN '' THEN
                                                    OutbreakTypeID
                                                ELSE
                                                    @OutbreakTypeID
                                            END
                          )
                          OR @OutbreakTypeID IS NULL
                      )
                  AND (
                          (idfsOutbreakStatus = CASE ISNULL(@OutbreakStatusTypeID, '')
                                                    WHEN '' THEN
                                                        idfsOutbreakStatus
                                                    ELSE
                                                        @OutbreakStatusTypeID
                                                END
                          )
                          OR @OutbreakStatusTypeID IS NULL
                      )
                  AND (
                          g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          (o.idfsDiagnosisOrDiagnosisGroup = CASE ISNULL(@SearchDiagnosesGroup, '')
                                                                 WHEN '' THEN
                                                                     o.idfsDiagnosisOrDiagnosisGroup
                                                                 ELSE
                                                                     @SearchDiagnosesGroup
                                                             END
                          )
                          OR @SearchDiagnosesGroup IS NULL
                      )
                  AND (strOutbreakID LIKE CASE ISNULL(@OutbreakID, '')
                                              WHEN '' THEN
                                                  '%%'
                                              ELSE
                                                  '%' + @OutbreakID + '%'
                                          END
                      );

            DELETE FROM @Results
            WHERE ID IN (
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN dbo.tstObjectAccess oa
                                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                                       AND oa.intRowStatus = 0
                            WHERE intPermission = 1 -- Deny permission
                                  AND oa.idfsObjectType = 10060001 -- Disease
                                  AND idfActor = @UserEmployeeID
                        );
        END
        ELSE
        BEGIN
            -- ========================================================================================
            -- NO SITE FILTRATION RULES APPLIED
            --
            -- For first and second level sites, do not apply any site filtration rules.
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
                    -- DISEASE
                    INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup

                    --STATUS...
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.gisbasereference gbr
                        on gbr.idfsGISBaseReference = g.idfsLocation
                    INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                        ON LH.idfsLocation = g.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND (
                              strOutbreakID LIKE '%' + @QuickSearch + '%'
                              OR d.name LIKE '%' + @QuickSearch + '%'
                              OR os.strDefault LIKE '%' + @QuickSearch + '%'
                              OR ot.strDefault LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                              OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                          );
            END
            ELSE
            BEGIN
                -- =======================================================================================
                -- CONFIGURABLE SITE FILTRATION RULES
                -- 
                -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
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
                    -- DISEASE
                    INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                        ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup

                    --STATUS...
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.gisbasereference gbr
                        on gbr.idfsGISBaseReference = g.idfsLocation
                    INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                        ON LH.idfsLocation = g.idfsLocation
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID
                      AND (
                              strOutbreakID LIKE '%' + @QuickSearch + '%'
                              OR d.name LIKE '%' + @QuickSearch + '%'
                              OR os.strDefault LIKE '%' + @QuickSearch + '%'
                              OR ot.strDefault LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                              OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                          );

                -- =======================================================================================
                -- DEFAULT SITE FILTRATION RULES
                --
                -- Apply active default site filtration rules for third level sites.
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
                        INNER JOIN dbo.tlbGeoLocationShared AS l
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
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON o.idfGeoLocation = gl.idfGeoLocation
                    LEFT JOIN dbo.gisLocation g
                        ON g.idfsLocation = gl.idfsLocation
                    INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                        ON LH.idfsLocation = g.idfsLocation
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                        ON os.idfsReference = o.idfsOutbreakStatus
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                        ON ot.idfsReference = o.OutbreakTypeId
                WHERE o.intRowStatus = 0
                      AND (
                              strOutbreakID LIKE '%' + @QuickSearch + '%'
                              OR d.name LIKE '%' + @QuickSearch + '%'
                              OR os.strDefault LIKE '%' + @QuickSearch + '%'
                              OR ot.strDefault LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                              OR LH.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
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
                            WHERE oa.intPermission = 1
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
                INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus
                INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = g.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
            WHERE oa.intPermission = 2 -- Allow permission
                  AND o.intRowStatus = 0
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = egm.idfEmployeeGroup
                  AND (
                          strOutbreakID LIKE '%' + @QuickSearch + '%'
                          OR d.name LIKE '%' + @QuickSearch + '%'
                          OR os.strDefault LIKE '%' + @QuickSearch + '%'
                          OR ot.strDefault LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
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
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus
                INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = g.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
            WHERE oa.intPermission = 2 -- Allow permission
                  AND o.intRowStatus = 0
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
                  AND (
                          strOutbreakID LIKE '%' + @QuickSearch + '%'
                          OR d.name LIKE '%' + @QuickSearch + '%'
                          OR os.strDefault LIKE '%' + @QuickSearch + '%'
                          OR ot.strDefault LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel1Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel2Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel3Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel4Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel5Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel6Name LIKE '%' + @QuickSearch + '%'
                          OR LH.AdminLevel7Name LIKE '%' + @QuickSearch + '%'
                          OR o.datStartDate LIKE '%' + @QuickSearch + '%'
                      );

            DELETE FROM @Results
            WHERE ID IN (
                            SELECT o.idfOutbreak
                            FROM dbo.tlbOutbreak o
                                INNER JOIN dbo.tstObjectAccess oa
                                    ON oa.idfsObjectID = o.idfsDiagnosisOrDiagnosisGroup
                                       AND oa.intRowStatus = 0
                            WHERE intPermission = 1 -- Deny permission
                                  AND oa.idfsObjectType = 10060001 -- Disease
                                  AND idfActor = @UserEmployeeID
                        );
        END;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator
        FROM @Results res
        WHERE res.ReadPermissionIndicator = 1
        GROUP BY ID,
                 ReadPermissionIndicator,
                 AccessToPersonalDataPermissionIndicator,
                 AccessToGenderAndAgeDataPermissionIndicator,
                 WritePermissionIndicator,
                 DeletePermissionIndicator;

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
                                                       LH.AdminLevel1Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel1Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel1Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       LH.AdminLevel2Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel2Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel3Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       LH.AdminLevel3Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel3Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel3Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel4Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       LH.AdminLevel4Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel4Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel4Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel5Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       LH.AdminLevel5Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel5Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel5Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel6Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       LH.AdminLevel6Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel6Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel6Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel7Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       LH.AdminLevel7Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel7Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       LH.AdminLevel7Name
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
                                                   WHEN @SortColumn = 'INIT'
                                                        AND @SortOrder = 'DESC' THEN
                                                       os.name + ' ' + o.strOutbreakID
                                               END DESC
                                     ) AS ROWNUM,
                   ID,
                   c = COUNT(*) OVER ()
            FROM @FinalResults res
                INNER JOIN dbo.tlbOutbreak AS o
                    ON o.idfOutbreak = res.ID
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON o.idfGeoLocation = gl.idfGeoLocation
                LEFT JOIN dbo.gisLocation AS g
                    ON g.idfsLocation = gl.idfsLocation
                INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = g.idfsLocation
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) d
                    ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
                    ON os.idfsReference = o.idfsOutbreakStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
                    ON ot.idfsReference = o.OutbreakTypeId
           --            ORDER BY 
           ),

		   SITEID AS
		   (
			SELECT DISTINCT o.idfsSite AS SiteID
			FROM @FinalResults res
				INNER JOIN paging
					ON paging.ID = res.ID
				INNER JOIN dbo.tlbOutbreak o
					ON o.idfOutbreak = res.ID
				LEFT JOIN dbo.tlbGeoLocation gl
					ON o.idfGeoLocation = gl.idfGeoLocation
				INNER JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
					ON LH.idfsLocation = gl.idfsLocation
				INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) d
					ON d.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
				INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000063) os
					ON os.idfsReference = o.idfsOutbreakStatus
				LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000513) ot
					ON ot.idfsReference = o.OutbreakTypeId
			--WHERE RowNum > @firstRec
			--	  AND RowNum < @lastRec
			--ORDER BY paging.ROWNUM
		)

 
		SELECT @SiteIDs = STRING_AGG(CAST(SiteID AS NVARCHAR(24)), ',') 
		FROM SITEID

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END

GO
