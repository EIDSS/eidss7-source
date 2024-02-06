-- ================================================================================================
-- Name: USP_ILI_Aggregate_GetList
--
-- Description: Get ILI aggregate list for the ILI aggregate use cases
--          
-- Author: Arnold Kennedy
--
-- Revision History
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Arnold Kennedy   03/21/2019 Initial release.
-- Arnold Kennedy	04/16/2019 Updates for details added
-- Stephen Long     01/26/2020 Changed site ID to site list parameter for site filtration.
-- Ann Xiong		02/28/2020 Modified to get a list of rows instead of one single row from table 
--                             tlbBasicSyndromicSurveillanceAggregateDetail 
-- Ann Xiong		03/06/2020 Fixed NULL HospitalName
-- Stephen Long     11/29/2020 Added configurable site filtration rules.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     04/08/2021 Added updated pagination and location hierarchy.
-- Leo Tracchia		08/17/2021 Added LegacyFormID parameter for search and added distinct select
-- Leo Tracchia		03/11/2022 Added check for intRowStatus
-- Leo Tracchia		07/11/2022 Modified to return correct record counts for pagination
-- Leo Tracchia		07/20/2022 changed AggregateHeaderKey to bigint 
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Stephen Long     01/13/2023 Updated for site filtration queries.
-- Stephen Long     07/05/2023 Fix on site permission deletion query.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ILI_Aggregate_GetList]
(
    @LanguageID NVARCHAR(50),
    @FormID NVARCHAR(200),
    @LegacyFormID NVARCHAR(200),
    @AggregateHeaderID BIGINT = NULL,
    @HospitalID BIGINT = NULL,
    @StartDate DATETIME = NULL,
    @FinishDate DATETIME = NULL,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'FormID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @firstRec INT,
            @lastRec INT;

    IF @PageSize = 0
    BEGIN
        SET @PageSize = 1;
    END

    SET @firstRec = (@PageNumber - 1) * @PageSize;
    SET @lastRec = (@PageNumber * @PageSize + 1);

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

    DECLARE @TempResultsTable TABLE
    (
        AggregateHeaderKey BIGINT not null,
        FormID NVARCHAR(200),
        LegacyFormID NVARCHAR(200),
        DateEntered NVARCHAR(200),
        DateLastSaved NVARCHAR(200),
        UserName NVARCHAR(200),
        OrganizationName NVARCHAR(200),
        [Year] INT,
        [Week] INT,
        StartDate DATETIME,
        EndDate DATETIME,
        ILITablesList NVARCHAR(MAX),
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL,
        TotalCount INT,
        CurrentPage INT
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

        INSERT INTO @Results
        SELECT DISTINCT
            ah.idfAggregateHeader,
            1,
            1,
            1,
            1,
            1
        FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
            LEFT JOIN dbo.tlbBasicSyndromicSurveillanceAggregateDetail ad
                ON ah.idfAggregateHeader = ad.idfAggregateHeader
        WHERE ah.intRowStatus = 0
              AND (
                      @AggregateHeaderID IS NULL
                      OR ah.idfAggregateHeader = @AggregateHeaderID
                  )
              AND (
                      ah.strFormID LIKE '%' + @FormID + '%'
                      OR @FormID IS NULL
                  )
              AND (
                      ah.LegacyFormID LIKE '%' + @LegacyFormID + '%'
                      OR @LegacyFormID IS NULL
                  )
              AND (
                      ah.idfsSite = @UserSiteID
                      OR (@UserSiteID IS NULL)
                  )
              AND (
                      @HospitalID IS NULL
                      OR ad.idfHospital = @HospitalID
                  )
              AND (
                      (
                          (
                              @StartDate IS NOT NULL
                              AND @FinishDate IS NOT NULL
                          )
                          AND (
                                  ah.datStartDate >= @StartDate
                                  AND ah.datFinishDate <= @FinishDate
                              )
                      )
                      OR (
                             @StartDate IS NOT NULL
                             AND @FinishDate IS NULL
                             AND ah.datStartDate >= @StartDate
                         )
                      OR (
                             @StartDate IS NULL
                             AND @FinishDate IS NOT NULL
                             AND ah.datFinishDate <= @FinishDate
                         )
                      OR (
                             @StartDate IS NULL
                             AND @FinishDate IS NULL
                         )
                  );

        -- =======================================================================================
        -- CONFIGURABLE FILTRATION RULES
        -- 
        -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the default rules.
        -- =======================================================================================
        IF @ApplySiteFiltrationIndicator = 1
        BEGIN
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS
                    ON grantingSGS.idfsSite = ah.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS
                    ON grantingSGS.idfsSite = ah.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS
                    ON grantingSGS.idfsSite = ah.idfsSite
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
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS
                    ON grantingSGS.idfsSite = ah.idfsSite
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
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ah.intRowStatus = 0
                  AND sgs.idfsSite = ah.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteID = ah.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
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
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteID = ah.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @Results
            SELECT ah.idfAggregateHeader,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
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
            WHERE ah.intRowStatus = 0
                  AND a.GrantingActorSiteID = ah.idfsSite;
        END;

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
            SELECT ah.idfAggregateHeader
            FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = ah.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE ah.intRowStatus = 0
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
        SELECT ah.idfAggregateHeader,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = ah.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE ah.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = ah.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                ON ah.idfAggregateHeader = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = ah.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT ah.idfAggregateHeader,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = ah.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
        WHERE ah.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = ah.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                ON ah.idfAggregateHeader = res.ID
            INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = ah.idfsSite
        WHERE usp.Permission = 4 -- Deny permission
              AND usp.PermissionTypeID = 10059003; -- Read permission

        INSERT INTO @TempResultsTable
        SELECT DISTINCT
            ah.idfAggregateHeader AS AggregateHeaderKey,
            ah.strFormID AS FormID,
            ah.LegacyFormID,
            ah.datDateEntered AS DateEntered,
            ah.datDateLastSaved AS DateLastSaved,
            p.strFamilyName + ', ' + p.strFirstName AS UserName,
            br.strDefault AS OrganizationName,
            ah.intYear AS [Year],
            ah.intWeek AS [Week],
            ah.datStartDate AS StartDate,
            ah.datFinishDate AS EndDate,
            ILITablesList = STUFF(
                                     (
                                         SELECT ', ' + hr.strDefault
                                         FROM dbo.tlbBasicSyndromicSurveillanceAggregateDetail ad
                                             LEFT JOIN dbo.tlbOffice h
                                                 ON h.idfOffice = ad.idfHospital
                                             LEFT JOIN dbo.trtBaseReference hr
                                                 ON h.idfsOfficeName = hr.idfsBaseReference
                                         WHERE ad.idfAggregateHeader = ah.idfAggregateHeader
                                               AND ad.intRowStatus = 0
                                         GROUP BY hr.strDefault
                                         FOR XML PATH(''), TYPE
                                     ).value('.[1]', 'NVARCHAR(MAX)'),
                                     1,
                                     2,
                                     ''
                                 ),
            MAX(res.ReadPermissionIndicator),
            MAX(res.AccessToPersonalDataPermissionIndicator),
            MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
            MAX(res.WritePermissionIndicator),
            MAX(res.DeletePermissionIndicator),
            (
                SELECT COUNT(*)
                FROM dbo.tlbBasicSyndromicSurveillanceAggregateHeader
                WHERE intRowStatus = 0
            ) AS TotalCount,
            CurrentPage = @PageNumber
        FROM @Results res
            INNER JOIN dbo.tlbBasicSyndromicSurveillanceAggregateHeader ah
                ON ah.idfAggregateHeader = res.ID
            LEFT JOIN dbo.tlbPerson p
                ON p.idfPerson = ah.idfEnteredBy
            LEFT JOIN dbo.tlbOffice o
                ON o.idfOffice = p.idfInstitution
            LEFT JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = o.idfsOfficeAbbreviation
            LEFT JOIN dbo.tlbBasicSyndromicSurveillanceAggregateDetail ad
                ON ah.idfAggregateHeader = ad.idfAggregateHeader
            LEFT JOIN dbo.tlbOffice h
                ON h.idfOffice = ad.idfHospital
            LEFT JOIN dbo.trtBaseReference hr
                ON h.idfsOfficeName = hr.idfsBaseReference
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
        GROUP BY ah.idfAggregateHeader,
                 ah.strFormID,
                 ah.LegacyFormID,
                 ah.datDateEntered,
                 ah.datDateLastSaved,
                 p.strFamilyName,
                 p.strFirstName,
                 br.strDefault,
                 ah.intYear,
                 ah.intWeek,
                 ah.datStartDate,
                 ah.datFinishDate;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'FormID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       trt.FormID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FormID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       trt.FormID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'StartDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       trt.StartDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'StartDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       trt.StartDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EndDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       trt.EndDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EndDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       trt.EndDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'LegacyFormID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       trt.LegacyFormID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'LegacyFormID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       trt.LegacyFormID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ILITablesList'
                                                        AND @SortOrder = 'ASC' THEN
                                                       trt.ILITablesList
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ILITablesList'
                                                        AND @SortOrder = 'DESC' THEN
                                                       trt.ILITablesList
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   trt.AggregateHeaderKey,
                   trt.FormID,
                   trt.LegacyFormID,
                   trt.DateEntered,
                   trt.DateLastSaved,
                   trt.UserName,
                   trt.OrganizationName,
                   trt.[Year],
                   trt.[Week],
                   trt.StartDate,
                   trt.EndDate,
                   trt.ILITablesList,
                   trt.ReadPermissionIndicator,
                   trt.AccessToPersonalDataPermissionIndicator,
                   trt.AccessToGenderAndAgeDataPermissionIndicator,
                   trt.WritePermissionIndicator,
                   trt.DeletePermissionIndicator,
                   trt.TotalCount,
                   trt.CurrentPage
            FROM @TempResultsTable trt
           )
        SELECT res.ROWNUM,
               TotalRowCount,
               res.AggregateHeaderKey,
               res.FormID,
               res.LegacyFormID,
               res.DateEntered,
               res.DateLastSaved,
               res.UserName,
               res.OrganizationName,
               res.Year,
               res.Week,
               res.StartDate,
               res.EndDate,
               res.ILITablesList,
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
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @PageNumber
        FROM CTEResults res
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
