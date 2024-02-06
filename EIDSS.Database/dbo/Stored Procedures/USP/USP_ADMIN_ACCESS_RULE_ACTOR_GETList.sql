-- ================================================================================================
-- Name: USP_ADMIN_ACCESS_RULE_ACTOR_GETList
--
-- Description:	Get actor list for a specific access rule ID.  Used in rules for configurable site 
-- filtration of the administration module.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/12/2020 Initial release.
-- Stephen Long     11/24/2020 Fix on actor ID order - person, employee group, site and site group.
-- Stephen Long     04/19/2021 Added pagination and sorting.
-- Stephen Long     06/09/2021 Added distinct to the select list.
-- Stephen Long     07/01.2021 Added site ID parameter.
-- Stephen Long     01/09/2022 Added create permission indicator.
-- Stephen Long     02/13/2022 Added internal actors to the query for site.
-- Stephen Long     03/16/2022 Added actor type ID.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACCESS_RULE_ACTOR_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'ActorName',
    @SortOrder NVARCHAR(4) = 'ASC',
    @AccessRuleID BIGINT = NULL,
    @SiteID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FirstRecord INT,
                @LastRecord INT,
                @TotalRowCount INT = 0;
        DECLARE @Results TABLE
        (
            AccessRuleActorID BIGINT NOT NULL,
            AccessRuleID BIGINT NULL,
            ActorTypeID BIGINT NOT NULL, 
            ActorTypeName VARCHAR(MAX) NOT NULL,
            ActorName NVARCHAR(MAX) NULL,
            ActorSiteGroupID BIGINT NULL,
            SiteGroupName NVARCHAR(MAX) NULL,
            ActorSiteID BIGINT NULL,
            SiteName NVARCHAR(MAX) NULL,
            ActorEmployeeGroupID BIGINT NULL,
            EmployeeGroupName NVARCHAR(MAX) NULL,
            ActorUserID BIGINT NULL,
            UserName NVARCHAR(MAX) NULL,
            AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
            AccessToPersonalDataPermissionIndicator BIT NOT NULL,
            CreatePermissionIndicator BIT NOT NULL,
            DeletePermissionIndicator BIT NOT NULL,
            ReadPermissionIndicator BIT NOT NULL,
            WritePermissionIndicator BIT NOT NULL,
            RowStatus INT NOT NULL,
            ExternalActorIndicator BIT NOT NULL
        );

        IF @AccessRuleID IS NULL
        BEGIN
            INSERT INTO @Results
            SELECT ara.AccessRuleActorID,
                   ara.AccessRuleID,
                   CASE
                       WHEN ara.ActorUserID IS NOT NULL THEN
                           10023002
                       WHEN ara.ActorEmployeeGroupID IS NOT NULL THEN
                           10023001
                       WHEN ara.ActorSiteGroupID IS NOT NULL THEN
                           4
                       WHEN ara.ActorSiteID IS NOT NULL THEN
                           3
                   END AS ActorTypeID,
                   CASE
                       WHEN ara.ActorUserID IS NOT NULL THEN
                           'Person'
                       WHEN ara.ActorEmployeeGroupID IS NOT NULL THEN
                           'Employee Group'
                       WHEN ara.ActorSiteGroupID IS NOT NULL THEN
                           'Site Group'
                       WHEN ara.ActorSiteID IS NOT NULL THEN
                           'Site'
                       ELSE
                           'Undetermined'
                   END AS ActorTypeName,
                   CASE
                       WHEN ara.ActorUserID IS NOT NULL THEN
                           dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
                       WHEN ara.ActorEmployeeGroupID IS NOT NULL THEN
                           employeeGroup.name
                       WHEN ara.ActorSiteGroupID IS NOT NULL THEN
                           sg.strSiteGroupName
                       WHEN ara.ActorSiteID IS NOT NULL THEN
                           s.strSiteName
                       ELSE
                           'Undetermined'
                   END AS ActorName,
                   ara.ActorSiteGroupID,
                   sg.strSiteGroupName AS SiteGroupName,
                   ara.ActorSiteID,
                   s.strSiteName AS SiteName,
                   ara.ActorEmployeeGroupID,
                   employeeGroup.name AS EmployeeGroupName,
                   ara.ActorUserID,
                   dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) AS UserFullName,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.CreatePermissionIndicator,
                   ar.DeletePermissionIndicator,
                   ar.ReadPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ara.intRowStatus AS RowStatus,
                   1 AS ExternalActorIndicator
            FROM dbo.AccessRuleActor ara
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                INNER JOIN dbo.tstSite s
                    ON s.idfsSite = ar.GrantingActorSiteID
                       AND s.intRowStatus = 0
                LEFT JOIN dbo.tflSiteGroup sg
                    ON sg.idfSiteGroup = ara.ActorSiteGroupID
                       AND sg.intRowStatus = 0
                LEFT JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfEmployeeGroup = ara.ActorEmployeeGroupID
                       AND eg.intRowStatus = 0
                LEFT JOIN FN_GBL_ReferenceRepair(@LanguageID, 19000022) employeeGroup
                    ON employeeGroup.idfsReference = eg.idfsEmployeeGroupName
                LEFT JOIN dbo.tstUserTable u
                    ON u.idfUserID = ara.ActorUserID
                       AND u.intRowStatus = 0
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = u.idfPerson
                       AND p.intRowStatus = 0
            WHERE ara.intRowStatus = 0
                  AND ar.GrantingActorSiteID = @SiteID;

            INSERT INTO @Results
            SELECT eg.idfEmployeeGroup AS AccessRuleActorID,
                   NULL AS AccessRuleID,
                   10023001 AS ActorTypeID, 
                   'Employee Group' AS ActorTypeName,
                   employeeGroup.name AS ActorName,
                   NULL AS ActorSiteGroupID,
                   NULL AS SiteGroupName,
                   eg.idfsSite AS SiteID,
                   s.strSiteName AS SiteName,
                   eg.idfEmployeeGroup AS EmployeeGroupID,
                   employeeGroup.name AS EmployeeGroupName,
                   NULL AS ActorUserID,
                   NULL AS UserFullName,
                   1 AS AccessToGenderAndAgeDataPermissionIndicator,
                   1 AS AccessToPersonalDataPermissionIndicator,
                   1 AS CreatePermissionIndicator,
                   1 AS DeletePermissionIndicator,
                   1 AS ReadPermissionIndicator,
                   1 AS WritePermissionIndicator,
                   eg.intRowStatus AS RowStatus,
                   0 AS ExternalActorIndicator
            FROM dbo.tlbEmployeeGroup eg
                INNER JOIN dbo.tstSite s
                    ON s.idfsSite = eg.idfsSite
                       AND s.intRowStatus = 0
                INNER JOIN FN_GBL_ReferenceRepair(@LanguageID, 19000022) employeeGroup
                    ON employeeGroup.idfsReference = eg.idfsEmployeeGroupName
            WHERE eg.intRowStatus = 0
                  AND eg.idfsSite = @SiteID;

            INSERT INTO @Results
            SELECT e.idfEmployee AS AccessRuleActorID,
                   NULL AS AccessRuleID,
                   10023002 AS ActorTypeID, 
                   'Employee' AS ActorTypeName,
                   dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) AS ActorName,
                   NULL AS ActorSiteGroupID,
                   NULL AS SiteGroupName,
                   e.idfsSite AS SiteID,
                   s.strSiteName AS SiteName,
                   NULL AS EmployeeGroupID,
                   NULL AS EmployeeGroupName,
                   u.idfUserID AS ActorUserID,
                   dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) AS UserFullName,
                   1 AS AccessToGenderAndAgeDataPermissionIndicator,
                   1 AS AccessToPersonalDataPermissionIndicator,
                   1 AS CreatePermissionIndicator,
                   1 AS DeletePermissionIndicator,
                   1 AS ReadPermissionIndicator,
                   1 AS WritePermissionIndicator,
                   e.intRowStatus AS RowStatus,
                   0 AS ExternalActorIndicator
            FROM dbo.tlbEmployee e
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = e.idfEmployee
                       AND u.intRowStatus = 0
                INNER JOIN dbo.tlbPerson p
                    ON p.idfPerson = u.idfPerson
                       AND p.intRowStatus = 0
                INNER JOIN dbo.tstSite s
                    ON s.idfsSite = e.idfsSite
                       AND s.intRowStatus = 0
            WHERE e.intRowStatus = 0
                  AND e.idfsSite = @SiteID;
        END
        ELSE
        BEGIN
            INSERT @Results
            SELECT ara.AccessRuleActorID,
                   ara.AccessRuleID,
                   CASE
                       WHEN ara.ActorUserID IS NOT NULL THEN
                           10023002
                       WHEN ara.ActorEmployeeGroupID IS NOT NULL THEN
                           10023001
                       WHEN ara.ActorSiteGroupID IS NOT NULL THEN
                           4
                       WHEN ara.ActorSiteID IS NOT NULL THEN
                           3
                   END AS ActorTypeID,
                   CASE
                       WHEN ara.ActorUserID IS NOT NULL THEN
                           'Person'
                       WHEN ara.ActorEmployeeGroupID IS NOT NULL THEN
                           'Employee Group'
                       WHEN ara.ActorSiteGroupID IS NOT NULL THEN
                           'Site Group'
                       WHEN ara.ActorSiteID IS NOT NULL THEN
                           'Site'
                       ELSE
                           'Undetermined'
                   END AS ActorTypeName,
                   CASE
                       WHEN ara.ActorUserID IS NOT NULL THEN
                           dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
                       WHEN ara.ActorEmployeeGroupID IS NOT NULL THEN
                           employeeGroup.name
                       WHEN ara.ActorSiteGroupID IS NOT NULL THEN
                           sg.strSiteGroupName
                       WHEN ara.ActorSiteID IS NOT NULL THEN
                           s.strSiteName
                       ELSE
                           'Undetermined'
                   END AS ActorName,
                   ara.ActorSiteGroupID,
                   sg.strSiteGroupName AS SiteGroupName,
                   ara.ActorSiteID,
                   s.strSiteName AS SiteName,
                   ara.ActorEmployeeGroupID,
                   employeeGroup.name AS EmployeeGroupName,
                   ara.ActorUserID,
                   dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) AS UserFullName,
                   ar.AccessToGenderAndAgeDataPermissionIndicator,
                   ar.AccessToPersonalDataPermissionIndicator,
                   ar.CreatePermissionIndicator,
                   ar.DeletePermissionIndicator,
                   ar.ReadPermissionIndicator,
                   ar.WritePermissionIndicator,
                   ara.intRowStatus AS RowStatus,
                   1 AS ExternalActorIndicator
            FROM dbo.AccessRuleActor ara
                INNER JOIN dbo.AccessRule ar
                    ON ar.AccessRuleID = ara.AccessRuleID
                LEFT JOIN dbo.tflSiteGroup sg
                    ON sg.idfSiteGroup = ara.ActorSiteGroupID
                       AND sg.intRowStatus = 0
                LEFT JOIN dbo.tstSite s
                    ON s.idfsSite = ara.ActorSiteID
                       AND s.intRowStatus = 0
                LEFT JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfEmployeeGroup = ara.ActorEmployeeGroupID
                       AND eg.intRowStatus = 0
                LEFT JOIN FN_GBL_ReferenceRepair(@LanguageID, 19000022) employeeGroup
                    ON employeeGroup.idfsReference = eg.idfsEmployeeGroupName
                LEFT JOIN dbo.tstUserTable u
                    ON u.idfUserID = ara.ActorUserID
                       AND u.intRowStatus = 0
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = u.idfPerson
                       AND p.intRowStatus = 0
            WHERE ara.intRowStatus = 0
                  AND ara.AccessRuleID = @AccessRuleID;
        END;

        SET @FirstRecord = (@PageNumber - 1) * @PageSize;
        SET @LastRecord = (@PageNumber * @PageSize + 1);
        SET @TotalRowCount =
        (
            SELECT COUNT(*) FROM @Results
        );

        SELECT AccessRuleActorID,
               AccessRuleID,
               ActorTypeID, 
               ActorTypeName,
               ActorName,
               ActorSiteGroupID,
               SiteGroupName,
               ActorSiteID,
               SiteName,
               ActorEmployeeGroupID,
               EmployeeGroupName,
               ActorUserID,
               UserName,
               AccessToGenderAndAgeDataPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               CreatePermissionIndicator,
               DeletePermissionIndicator,
               ReadPermissionIndicator,
               WritePermissionIndicator,
               RowStatus,
               ExternalActorIndicator,
               RowAction,
               [RowCount],
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ActorName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       CASE
                                                           WHEN ActorUserID IS NOT NULL THEN
                                                               UserName
                                                           WHEN ActorEmployeeGroupID IS NOT NULL THEN
                                                               EmployeeGroupName
                                                           WHEN ActorSiteGroupID IS NOT NULL THEN
                                                               SiteGroupName
                                                           WHEN ActorSiteID IS NOT NULL THEN
                                                               SiteName
                                                           ELSE
                                                               'Undetermined'
                                                       END
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ActorName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       CASE
                                                           WHEN ActorUserID IS NOT NULL THEN
                                                               UserName
                                                           WHEN ActorEmployeeGroupID IS NOT NULL THEN
                                                               EmployeeGroupName
                                                           WHEN ActorSiteGroupID IS NOT NULL THEN
                                                               SiteGroupName
                                                           WHEN ActorSiteID IS NOT NULL THEN
                                                               SiteName
                                                           ELSE
                                                               'Undetermined'
                                                       END
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ActorTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       CASE
                                                           WHEN ActorUserID IS NOT NULL THEN
                                                               'Person'
                                                           WHEN ActorEmployeeGroupID IS NOT NULL THEN
                                                               'Employee Group'
                                                           WHEN ActorSiteGroupID IS NOT NULL THEN
                                                               'Site Group'
                                                           WHEN ActorSiteID IS NOT NULL THEN
                                                               'Site'
                                                           ELSE
                                                               'Undetermined'
                                                       END
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ActorTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       CASE
                                                           WHEN ActorUserID IS NOT NULL THEN
                                                               'Person'
                                                           WHEN ActorEmployeeGroupID IS NOT NULL THEN
                                                               'Employee Group'
                                                           WHEN ActorSiteGroupID IS NOT NULL THEN
                                                               'Site Group'
                                                           WHEN ActorSiteID IS NOT NULL THEN
                                                               'Site'
                                                           ELSE
                                                               'Undetermined'
                                                       END
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SiteName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       SiteName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SiteName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       SiteName
                                               END DESC
                                     ) AS RowNum,
                   AccessRuleActorID,
                   AccessRuleID,
                   ActorTypeID, 
                   ActorTypeName,
                   ActorName,
                   ActorSiteGroupID,
                   SiteGroupName,
                   ActorSiteID,
                   SiteName,
                   ActorEmployeeGroupID,
                   EmployeeGroupName,
                   ActorUserID,
                   UserName,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   CreatePermissionIndicator,
                   DeletePermissionIndicator,
                   ReadPermissionIndicator,
                   WritePermissionIndicator,
                   RowStatus,
                   ExternalActorIndicator,
                   0 AS RowAction,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM @Results
            GROUP BY AccessRuleActorID,
                     AccessRuleID,
                     ActorTypeID, 
                     ActorTypeName,
                     ActorName,
                     ActorSiteGroupID,
                     SiteGroupName,
                     ActorSiteID,
                     SiteName,
                     ActorEmployeeGroupID,
                     EmployeeGroupName,
                     ActorUserID,
                     UserName,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     CreatePermissionIndicator,
                     DeletePermissionIndicator,
                     ReadPermissionIndicator,
                     WritePermissionIndicator,
                     RowStatus,
                     ExternalActorIndicator
        ) AS x
        WHERE RowNum > @FirstRecord
              AND RowNum < @LastRecord
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
