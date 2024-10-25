-- ================================================================================================
-- Name: USP_AS_CAMPAIGN_GETList
--
-- Description: Gets data for active surveillance campaign search for the human module.
--          
-- Revision History:
-- Name                    Date       Change Detail
-- ----------------------- ---------- ------------------------------------------------------------
-- Stephen Long            07/06/2019 Initial release.
-- Stephen Long            01/26/2020 Added site list parameter for site filtration.
-- Ann Xiong		       02/19/2020 Added script to search by Region and Rayon
-- Stephen Long            05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long            06/18/2020 Added where criteria to the query when no site filtration is 
--                                    required.
-- Stephen Long            07/07/2020 Added trim to EIDSS identifier like criteria.
-- Stephen Long            11/18/2020 Added site ID to the query.
-- Stephen Long            11/27/2020 Added configurable site filtration rules.
-- Stephen Long            12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long            12/14/2020 Corrected where criteria on site list in the final query.
-- Stephen Long            12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long            12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long            04/08/2021 Added updated pagination and location hierarchy.
-- Mark Wilson		       08/10/2021 Added join to tlbCampaignToDiagnosis to pull diagnosis
-- Mark Wilson		       08/26/2021 Added Select Distinct to remove dupes
-- Mark Wilson		       08/27/2021 Added @CampaignTypeID to total count
-- Mark Wilson		       02/22/2022 Renamed from USP_HAS_CAMPAIGN_GETList and added 
--                                    @CampaignCategoryID to support both human and vet campaigns
-- Mark Wilson             02/23/2022 removed parm @AdministrativeLevelID, redo paging and sorting
-- Manickandan Govindrajan 05/12/2022 Fixed the start and End date condition
-- Stephen Long            01/09/2023 Updated for site filtration queries.
-- Stephen Long            06/30/2023 Fix to joins and campaign start date range where criteria.
-- Stephen Long            07/05/2023 Fix on site permission deletion query.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AS_CAMPAIGN_GETList]
(
    @LanguageID AS NVARCHAR(50),
    @CampaignID AS NVARCHAR(200) = NULL,
    @LegacyCampaignID AS NVARCHAR(200) = NULL,
    @CampaignName AS NVARCHAR(200) = NULL,
    @CampaignTypeID AS BIGINT = NULL,
    @CampaignStatusTypeID AS BIGINT = NULL,
    @CampaignCategoryID AS BIGINT,
    @StartDateFrom AS DATETIME = NULL,
    @StartDateTo AS DATETIME = NULL,
    @DiseaseID AS BIGINT = NULL,
    @UserSiteID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'CampaignID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @Page INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
    DECLARE @firstRec INT
    DECLARE @lastRec INT

    IF @pagesize = 0
    BEGIN
        SET @pagesize = 1;
    END

    SET @firstRec = (@page - 1) * @pagesize
    SET @lastRec = (@page * @pageSize + 1)
    BEGIN TRY
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

        INSERT INTO @Results
        SELECT DISTINCT
            c.idfCampaign,
            1,
            1,
            1,
            1,
            1
        FROM dbo.tlbCampaign c
            LEFT JOIN dbo.tlbCampaignToDiagnosis cd
                ON cd.idfCampaign = c.idfCampaign
        WHERE c.intRowStatus = 0
              AND c.CampaignCategoryID = @CampaignCategoryID
              AND (
                      (
                          c.idfsSite = @UserSiteID
                          AND @ApplySiteFiltrationIndicator = 1
                      )
                      OR (
                             (@UserSiteID IS NULL)
                             OR (@ApplySiteFiltrationIndicator = 0)
                         )
                  )
              AND (
                      c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'
                      OR @CampaignName IS NULL
                  )
              AND (
                      c.idfsCampaignType = @CampaignTypeID
                      OR @CampaignTypeID IS NULL
                  )
              AND (
                      c.idfsCampaignStatus = @CampaignStatusTypeID
                      OR @CampaignStatusTypeID IS NULL
                  )
              AND (
                      cd.idfsDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      (c.datCampaignDateStart
              BETWEEN @StartDateFrom AND DATEADD(DAY, 1, @StartDateTo)
                      )
                      OR (
                             @StartDateFrom IS NULL
                             OR @StartDateTo IS NULL
                         )
                  )
              AND (
                      c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                      OR @CampaignID IS NULL
                  )
              AND (
                      c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%'
                      OR @LegacyCampaignID IS NULL
                  );

        -- =======================================================================================
        -- CONFIGURABLE FILTRATION RULES
        -- 
        -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the non-configurable rules.
        -- =======================================================================================
        IF @ApplySiteFiltrationIndicator = 1
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

            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = c.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = c.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = c.idfsSite
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
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = c.idfsSite
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
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE c.intRowStatus = 0
                  AND sgs.idfsSite = c.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteID = c.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
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
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteID = c.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT c.idfCampaign,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbCampaign c
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
            WHERE c.intRowStatus = 0
                  AND a.GrantingActorSiteID = c.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT DISTINCT
                f.ID,
                f.ReadPermissionIndicator,
                f.AccessToPersonalDataPermissionIndicator,
                f.AccessToGenderAndAgeDataPermissionIndicator,
                f.WritePermissionIndicator,
                f.DeletePermissionIndicator
            FROM @FilteredResults f
                INNER JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = f.ID
                LEFT JOIN dbo.tlbCampaignToDiagnosis cd
                    ON cd.idfCampaign = c.idfCampaign
                       AND cd.intRowStatus = 0
            WHERE c.CampaignCategoryID = @CampaignCategoryID -- Human/Veterinary Active Surveillance Campaign
                  AND (
                          c.strCampaignName LIKE '%' + TRIM(@CampaignName) + '%'
                          OR @CampaignName IS NULL
                      )
                  AND (
                          c.idfsCampaignType = @CampaignTypeID
                          OR @CampaignTypeID IS NULL
                      )
                  AND (
                          c.idfsCampaignStatus = @CampaignStatusTypeID
                          OR @CampaignStatusTypeID IS NULL
                      )
                  AND (
                          cd.idfsDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          (c.datCampaignDateStart
                  BETWEEN @StartDateFrom AND DATEADD(DAY, 1, @StartDateTo)
                          )
                          OR (
                                 @StartDateFrom IS NULL
                                 OR @StartDateTo IS NULL
                             )
                      )
                  AND (
                          c.strCampaignID LIKE '%' + TRIM(@CampaignID) + '%'
                          OR @CampaignID IS NULL
                      )
                  AND (
                          c.LegacyCampaignID LIKE '%' + TRIM(@LegacyCampaignID) + '%'
                          OR @LegacyCampaignID IS NULL
                      )
                  AND f.ID NOT IN (
                                      SELECT ID FROM @Results
                                  );
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
                        SELECT c.idfCampaign
                        FROM dbo.tlbCampaign c
                            INNER JOIN dbo.tlbCampaignToDiagnosis cd
                                ON cd.idfCampaign = c.idfCampaign
                                   AND cd.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = cd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE c.intRowStatus = 0
                              AND oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT DISTINCT
            c.idfCampaign,
            1,
            1,
            1,
            1,
            1
        FROM dbo.tlbCampaign c
            INNER JOIN dbo.tlbCampaignToDiagnosis cd
                ON cd.idfCampaign = c.idfCampaign
                   AND cd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = cd.idfsDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND c.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbCampaign C
                ON C.idfCampaign = ID
            INNER JOIN dbo.tlbCampaignToDiagnosis cd
                ON cd.idfCampaign = C.idfCampaign
                   AND cd.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = cd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT DISTINCT
            c.idfCampaign,
            1,
            1,
            1,
            1,
            1
        FROM dbo.tlbCampaign c
            INNER JOIN dbo.tlbCampaignToDiagnosis cd
                ON cd.idfCampaign = c.idfCampaign
                   AND cd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = cd.idfsDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND c.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT c.idfCampaign
                        FROM dbo.tlbCampaign c
                            INNER JOIN dbo.tlbCampaignToDiagnosis cd
                                ON cd.idfCampaign = c.idfCampaign
                                   AND cd.intRowStatus = 0
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = cd.idfsDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE c.intRowStatus = 0
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
            SELECT c.idfCampaign
            FROM dbo.tlbCampaign c
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = c.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE c.intRowStatus = 0
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
        SELECT DISTINCT
            c.idfCampaign,
            (
                SELECT Permission
                FROM @UserGroupSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059003
            ),
            (
                SELECT Permission
                FROM @UserGroupSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059006
            ),
            (
                SELECT Permission
                FROM @UserGroupSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059007
            ),
            (
                SELECT Permission
                FROM @UserGroupSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059004
            ),
            (
                SELECT Permission
                FROM @UserGroupSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059002
            )
        FROM dbo.tlbCampaign c
        WHERE c.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = c.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = c.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT DISTINCT
            c.idfCampaign,
            (
                SELECT Permission
                FROM @UserSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059003
            ),
            (
                SELECT Permission
                FROM @UserSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059006
            ),
            (
                SELECT Permission
                FROM @UserSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059007
            ),
            (
                SELECT Permission
                FROM @UserSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059004
            ),
            (
                SELECT Permission
                FROM @UserSitePermissions
                WHERE SiteID = c.idfsSite
                      AND PermissionTypeID = 10059002
            )
        FROM dbo.tlbCampaign c
            INNER JOIN dbo.tlbCampaignToDiagnosis cd
                ON cd.idfCampaign = c.idfCampaign
                   AND cd.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = c.idfsSite
                   AND oa.intRowStatus = 0
        WHERE c.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = c.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbCampaign c
                ON c.idfCampaign = ID
            INNER JOIN @UserSitePermissions usp
                ON usp.SiteID = c.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
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

        WITH paging
        AS (SELECT DISTINCT
                c.idfCampaign,
                (
                    SELECT dbo.FN_GBL_Campaign_Disease_Names_GET(C.idfCampaign, @LanguageID)
                ) AS DiseaseList,
                SpeciesList = STUFF(
                                       (
                                           SELECT ', ' + speciesType.name
                                           FROM dbo.tlbCampaignToDiagnosis CD
                                               INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) AS speciesType
                                                   ON speciesType.idfsReference = CD.idfsSpeciesType
                                           WHERE CD.idfCampaign = c.idfCampaign
                                           GROUP BY speciesType.name
                                           FOR XML PATH(''), TYPE
                                       ).value('.[1]', 'NVARCHAR(MAX)'),
                                       1,
                                       2,
                                       ''
                                   ),
                SampleTypesList = STUFF(
                                           (
                                               SELECT ', ' + sampleType.name
                                               FROM dbo.tlbCampaignToDiagnosis CD
                                                   INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) AS sampleType
                                                       ON sampleType.idfsReference = CD.idfsSampleType
                                               WHERE CD.idfCampaign = c.idfCampaign
                                               GROUP BY sampleType.name
                                               FOR XML PATH(''), TYPE
                                           ).value('.[1]', 'NVARCHAR(MAX)'),
                                           1,
                                           2,
                                           ''
                                       ),
                campaignType.name AS CampaignTypeName,
                campaignStatus.name AS CampaignStatus,
                c.strCampaignID,
                c.strCampaignName,
                c.datCampaignDateStart,
                c.idfsSite,
                c.datCampaignDateEnd,
                c.strCampaignAdministrator,
                c.AuditCreateDTM,
                c.CampaignCategoryID
            FROM @FinalResults res
                INNER JOIN dbo.tlbCampaign c
                    ON c.idfCampaign = res.ID
                LEFT JOIN dbo.tlbCampaignToDiagnosis cd
                    ON cd.idfCampaign = c.idfCampaign
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000115) campaignStatus
                    ON c.idfsCampaignStatus = campaignStatus.idfsReference
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000116) campaignType
                    ON c.idfsCampaignType = campaignType.idfsReference
           ),
             paging_final
        AS (SELECT DISTINCT
                paging.idfCampaign,
                paging.DiseaseList,
                paging.SpeciesList,
                paging.SampleTypesList,
                paging.CampaignTypeName,
                paging.CampaignStatus,
                paging.strCampaignID,
                paging.strCampaignName,
                paging.datCampaignDateStart,
                paging.idfsSite,
                paging.datCampaignDateEnd,
                paging.strCampaignAdministrator,
                paging.AuditCreateDTM,
                paging.CampaignCategoryID,
                c = COUNT(*) OVER (),
                ROW_NUMBER() OVER (ORDER BY CASE
                                                WHEN @SortColumn = 'CampaignID'
                                                     AND @SortOrder = 'ASC' THEN
                                                    paging.strCampaignID
                                            END ASC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignID'
                                                     AND @SortOrder = 'DESC' THEN
                                                    paging.strCampaignID
                                            END DESC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignName'
                                                     AND @SortOrder = 'ASC' THEN
                                                    paging.strCampaignName
                                            END ASC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignName'
                                                     AND @SortOrder = 'DESC' THEN
                                                    paging.strCampaignName
                                            END DESC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignTypeName'
                                                     AND @SortOrder = 'ASC' THEN
                                                    paging.CampaignTypeName
                                            END ASC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignTypeName'
                                                     AND @SortOrder = 'DESC' THEN
                                                    paging.CampaignTypeName
                                            END DESC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignStatusTypeName'
                                                     AND @SortOrder = 'ASC' THEN
                                                    paging.CampaignStatus
                                            END ASC,
                                            CASE
                                                WHEN @SortColumn = 'CampaignStatusTypeName'
                                                     AND @SortOrder = 'DESC' THEN
                                                    paging.CampaignStatus
                                            END DESC,
                                            CASE
                                                WHEN @SortColumn = '"CampaignStartDate'
                                                     AND @SortOrder = 'ASC' THEN
                                                    paging.datCampaignDateStart
                                            END ASC,
                                            CASE
                                                WHEN @SortColumn = '"CampaignStartDate'
                                                     AND @SortOrder = 'DESC' THEN
                                                    paging.datCampaignDateStart
                                            END DESC,
                                            CASE
                                                WHEN @SortColumn = 'DiseaseName'
                                                     AND @SortOrder = 'ASC' THEN
                                                    paging.DiseaseList
                                            END ASC,
                                            CASE
                                                WHEN @SortColumn = 'DiseaseName'
                                                     AND @SortOrder = 'DESC' THEN
                                                    paging.DiseaseList
                                            END DESC
                                  ) AS RowNo
            FROM paging
           )
        SELECT p.idfCampaign AS CampaignKey,
               p.strCampaignID AS CampaignID,
               p.CampaignTypeName,
               p.CampaignStatus AS CampaignStatusTypeName,
               p.DiseaseList,
               p.SpeciesList,
               p.SampleTypesList,
               p.datCampaignDateStart AS CampaignStartDate,
               p.datCampaignDateEnd AS CampaignEndDate,
               p.strCampaignName AS CampaignName,
               p.strCampaignAdministrator AS CampaignAdministrator,
               p.AuditCreateDTM AS EnteredDate,
               p.idfsSite AS SiteID,
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
               END AS DeletePermissionIndicator,
               p.c AS TotalRowCount,
               (
                   SELECT COUNT(*)
                   FROM dbo.tlbCampaign
                   WHERE intRowStatus = 0
                         AND CampaignCategoryID = @CampaignCategoryID -- Human/Veterinary Active Surveillance Campaign
                         AND idfsCampaignType = @CampaignTypeID
               ) AS TotalCount,
               CurrentPage = @Page,
               TotalPages = (p.c / @PageSize) + IIF(p.c % @PageSize > 0, 1, 0)
        FROM paging_final p
            INNER JOIN @FinalResults res
                ON p.idfCampaign = res.ID
        ORDER BY p.RowNo OFFSET @PageSize * (@Page - 1) ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
