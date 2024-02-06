-- ================================================================================================
-- Name: USP_GBL_SITE_GROUP_GETList		
-- 
-- Description: Returns a list of site groups.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/29/2019 Initial release.
-- Stephen Long     12/12/2019 Added central site ID to query.
-- Stephen Long     12/29/2019 Added distinct to account for site to site group join.
-- Stephen Long     06/24/2021 Added new pagination method and leading wild card on EIDSS site ID.
-- Stephen Long     06/27/2021 Removed unneeded fields and the site to site group join and 
--                             distinct; added gisLocation join.
-- Stephen Long     07/28/2021 Corrected administrative level name field.
-- Stephen Long     07/28/2022 Added site group type id where criteria.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Stephen Long     03/15/2023 Added group by.
-- Stephen Long     03/16/2023 Fixed total row count.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_SITE_GROUP_GETList]
    @LanguageID NVARCHAR(50),
    @SiteGroupTypeID BIGINT NULL,
    @SiteGroupName NVARCHAR(40) NULL,
    @AdministrativeLevelID BIGINT NULL,
    @CentralSiteID BIGINT NULL,
    @SiteID BIGINT NULL,
    @EIDSSSiteID NVARCHAR(36) NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'SiteGroupName',
    @SortOrder NVARCHAR(4) = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        DECLARE @AdministrativeLevelNode AS HIERARCHYID;

        IF @AdministrativeLevelID IS NOT NULL
        BEGIN
            SELECT @AdministrativeLevelNode = node
            FROM dbo.gisLocation
            WHERE idfsLocation = @AdministrativeLevelID;
        END;

        WITH paging
        AS (SELECT sg.idfSiteGroup,
                   c = COUNT(*) OVER ()
            FROM dbo.tflSiteGroup sg
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = sg.idfsLocation
                LEFT JOIN dbo.gisStringNameTranslation snt
                    ON snt.idfsGISBaseReference = g.idfsLocation
                       AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                LEFT JOIN dbo.tflSiteToSiteGroup ssg
                    ON ssg.idfSiteGroup = sg.idfSiteGroup
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000524) siteGroupType
                    ON siteGroupType.idfsReference = sg.idfsSiteGroupType
            WHERE sg.intRowStatus = 0
                  AND (
                          sg.idfsCentralSite = @CentralSiteID
                          OR @CentralSiteID IS NULL
                      )
                  AND (
                          sg.idfsLocation = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          ssg.idfsSite = @SiteID
                          OR @SiteID IS NULL
                      )
                  AND (
                          sg.idfsSiteGroupType = @SiteGroupTypeID
                          OR @SiteGroupTypeID IS NULL
                      )
                  AND (
                          ssg.strSiteID LIKE '%' + @EIDSSSiteID + '%'
                          OR @EIDSSSiteID IS NULL
                      )
                  AND (
                          sg.strSiteGroupName LIKE '%' + @SiteGroupName + '%'
                          OR @SiteGroupName IS NULL
                      )
        GROUP BY sg.idfSiteGroup,
                 sg.strSiteGroupName,
                 --s.strTextString,
                 --b.strDefault,
                 sg.strSiteGroupDescription,
                 siteGroupType.name
            ORDER BY CASE
                         WHEN @SortColumn = 'SiteGroupName'
                              AND @SortOrder = 'ASC' THEN
                             sg.strSiteGroupName
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'SiteGroupName'
                              AND @SortOrder = 'DESC' THEN
                             sg.strSiteGroupName
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'SiteGroupTypeName'
                              AND @SortOrder = 'ASC' THEN
                             siteGroupType.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'SiteGroupTypeName'
                              AND @SortOrder = 'DESC' THEN
                             siteGroupType.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'SiteGroupDescription'
                              AND @SortOrder = 'ASC' THEN
                             sg.strSiteGroupDescription
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'SiteGroupDescription'
                              AND @SortOrder = 'DESC' THEN
                             sg.strSiteGroupDescription
                     END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
           )
        SELECT sg.idfSiteGroup AS SiteGroupID,
               siteGroupType.name AS SiteGroupTypeName,
               sg.strSiteGroupName AS SiteGroupName,
               ISNULL(s.strTextString, b.strDefault) AS AdministrativeLevelName,
               sg.strSiteGroupDescription AS SiteGroupDescription,
               c AS [RowCount],
               (
                   SELECT COUNT(*) FROM dbo.tflSiteGroup WHERE intRowStatus = 0
               ) AS TotalRowCount,
               CurrentPage = @PageNumber,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
        FROM dbo.tflSiteGroup sg
            INNER JOIN paging
                ON paging.idfSiteGroup = sg.idfSiteGroup
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = sg.idfsLocation
            LEFT OUTER JOIN dbo.gisBaseReference b
                ON b.idfsGISBaseReference = g.idfsLocation
            LEFT JOIN dbo.gisStringNameTranslation s
                ON s.idfsGISBaseReference = g.idfsLocation
                   AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000524) siteGroupType
                ON siteGroupType.idfsReference = sg.idfsSiteGroupType
        GROUP BY sg.idfSiteGroup,
                 sg.strSiteGroupName,
                 s.strTextString,
                 b.strDefault,
                 sg.strSiteGroupDescription,
                 siteGroupType.name,
                 c;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
