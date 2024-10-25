-- ================================================================================================
-- Name:USP_ADMIN_ORG_GETList
--
-- Description: Returns a list of organizations.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/09/2019 Created a temp table to store string query for POCO
-- Ricky Moss		06/14/2019 Added Organization Type ID
-- Ricky Moss		09/13/2019 Added AuditCreateDTM field for descending order
-- Ricky Moss		11/14/2019 Added paging paging parameters
-- Doug Albanese	11/19/2019 Corrected the HACode usage
-- Lamont Mitchell	04/13/2020 ADDED NULL Check for pagesize,maxpageperfetch and paginationset
-- Ricky Moss	    05/12/2020 Added Translated Values of name and full name
-- Mark Wilson		06/05/2020 used INTERSECT function to compare @intHACode with intHACode of org
-- Ricky Moss		06/15/2020 Used intOrder and strDefaut as original search fields
-- Doug Albanese	12/22/2020 Added idfsCountry for searching.	
-- Doug Albanese	02/01/2021 Corrected the use of NULL, in the where clause
-- Doug Albanese	02/08/2021 Changed the WHERE clause to detect filter searches properly.
-- Stephen Long     04/21/2021 Changed for updated pagination and location hierarchy.
-- Stephen Long     06/07/2021 Fixed address string to include additional fields for postal code, 
--                             street, building, apartment and house.
-- Stephen Long     06/24/2021 Added is null check on create address string.
-- Stephen Long     06/30/2021 Fix to order by column name on abbreviated and full names.
-- Stephen Long     08/03/2021 Added default sort order by order then organization full name; 
--                             national or default.
-- Leo Tracchia		08/17/2021 Changed intHACode to pull from tlbOffice	
-- Stephen Long     10/15/2021 Fix on total pages calculation.
-- Stephen Long     12/06/2021 Changed over to location hierarchy flattened for admin levels.
-- Stephen Long     03/14/2022 Changed over to pull from institution repair function to match 
--                             organization lookup procedure.
-- Stephen Long     05/05/2023 Correction to use proper joins on abbreviated and full names.
-- Stephen Long     05/25/2023 Fixed location hierarchy joins.
--
-- Testing Code:
-- EXEC USP_ADMIN_ORG_GETList 'en', null, null, null, null, 2, null, null, null, 1, 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ORG_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'Order',
    @SortOrder NVARCHAR(4) = 'ASC',
    @OrganizationKey BIGINT = NULL,
    @OrganizationID NVARCHAR(100) = NULL,
    @AbbreviatedName NVARCHAR(100) = NULL,
    @FullName NVARCHAR(100) = NULL,
    @AccessoryCode INT = NULL,
    @SiteID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @OrganizationTypeID BIGINT = NULL,
    @ShowForeignOrganizationsIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @AdministrativeLevelNode AS HIERARCHYID,
                @firstRec INT = (@PageNumber - 1) * @PageSize,
                @lastRec INT = (@PageNumber * @PageSize + 1),
                @TotalRowCount INT = (
                                         SELECT COUNT(*) FROM dbo.tlbOffice WHERE intRowStatus = 0
                                     ), 
                @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);

        SELECT OrganizationKey,
               OrganizationID,
               AbbreviatedName,
               FullName,
               [Order],
               AddressString,
               OrganizationTypeName,
               AccessoryCode,
               SiteID,
               RowStatus,
               [RowCount],
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'AbbreviatedName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(abbreviatedName.name, abbreviatedName.strDefault)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AbbreviatedName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(abbreviatedName.name, abbreviatedName.strDefault)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'FullName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(fullName.name, fullName.strDefault)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FullName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(fullName.name, fullName.strDefault)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       o.strOrganizationID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       o.strOrganizationID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AddressString'
                                                        AND @SortOrder = 'ASC' THEN
                                                       dbo.FN_GBL_CreateAddressString(
                                                                                         ISNULL(g.Level1Name, ''),
                                                                                         ISNULL(g.Level2Name, ''),
                                                                                         ISNULL(g.Level3Name, ''),
                                                                                         ISNULL(gls.strPostCode, ''),
                                                                                         '',
                                                                                         '',
                                                                                         ISNULL(gls.strStreetName, ''),
                                                                                         ISNULL(gls.strHouse, ''),
                                                                                         ISNULL(gls.strBuilding, ''),
                                                                                         ISNULL(gls.strApartment, ''),
                                                                                         gls.blnForeignAddress,
                                                                                         ISNULL(
                                                                                                   gls.strForeignAddress,
                                                                                                   ''
                                                                                               )
                                                                                     )
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AddressString'
                                                        AND @SortOrder = 'DESC' THEN
                                                       dbo.FN_GBL_CreateAddressString(
                                                                                         ISNULL(g.Level1Name, ''),
                                                                                         ISNULL(g.Level2Name, ''),
                                                                                         ISNULL(g.Level3Name, ''),
                                                                                         ISNULL(gls.strPostCode, ''),
                                                                                         '',
                                                                                         '',
                                                                                         ISNULL(gls.strStreetName, ''),
                                                                                         ISNULL(gls.strHouse, ''),
                                                                                         ISNULL(gls.strBuilding, ''),
                                                                                         ISNULL(gls.strApartment, ''),
                                                                                         gls.blnForeignAddress,
                                                                                         ISNULL(
                                                                                                   gls.strForeignAddress,
                                                                                                   ''
                                                                                               )
                                                                                     )
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       organizationType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'OrganizationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       organizationType.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Order'
                                                        AND @SortOrder = 'ASC' THEN
                                                       abbreviatedName.intOrder
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Order'
                                                        AND @SortOrder = 'DESC' THEN
                                                       abbreviatedName.intOrder
                                               END DESC,
                                               IIF(@SortColumn = 'Order',
                                                   ISNULL(abbreviatedName.name, abbreviatedName.strDefault),
                                                   NULL) ASC
                                     ) AS RowNum,
                   o.idfOffice AS OrganizationKey,
                   o.strOrganizationID AS OrganizationID,
                   abbreviatedName.name AS AbbreviatedName,
                   fullName.name AS FullName,
                   abbreviatedName.intOrder AS [Order],
                   dbo.FN_GBL_CreateAddressString(
                                                     ISNULL(g.Level1Name, ''),
                                                     ISNULL(g.Level2Name, ''),
                                                     ISNULL(g.Level3Name, ''),
                                                     ISNULL(gls.strPostCode, ''),
                                                     '',
                                                     '',
                                                     ISNULL(gls.strStreetName, ''),
                                                     ISNULL(gls.strHouse, ''),
                                                     ISNULL(gls.strBuilding, ''),
                                                     ISNULL(gls.strApartment, ''),
                                                     gls.blnForeignAddress,
                                                     ISNULL(gls.strForeignAddress, '')
                                                 ) AS AddressString,
                   organizationType.name AS OrganizationTypeName,
                   o.intHACode AS AccessoryCode,
                   o.idfsSite AS SiteID,
                   o.intRowStatus AS RowStatus,
                   COUNT(*) OVER () AS [RowCount],
                   @TotalRowCount AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM dbo.tlbOffice o
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000046) fullName
                    ON fullName.idfsReference = o.idfsOfficeName
                       AND fullName.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) abbreviatedName
                    ON abbreviatedName.idfsReference = o.idfsOfficeAbbreviation
                       AND abbreviatedName.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocationShared gls
                    ON o.idfLocation = gls.idfGeoLocationShared
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = gls.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000504) organizationType
                    ON o.OrganizationTypeID = organizationType.idfsReference
            WHERE o.intRowStatus = 0
                  AND (
                          o.idfOffice = @OrganizationKey
                          OR @OrganizationKey IS NULL
                      )
                  AND (
                          o.strOrganizationID LIKE '%' + @OrganizationID + '%'
                          OR @OrganizationID IS NULL
                      )
                  AND (
                          (
                              abbreviatedName.strDefault LIKE '%' + @AbbreviatedName + '%'
                              OR abbreviatedName.name LIKE '%' + @AbbreviatedName + '%'
                          )
                          OR @AbbreviatedName IS NULL
                      )
                  AND (
                          (
                              fullName.strDefault LIKE '%' + @FullName + '%'
                              OR fullName.name LIKE '%' + @FullName + '%'
                          )
                          OR @FullName IS NULL
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND EXISTS
            (
                SELECT *
                FROM dbo.FN_GBL_SplitHACode(@AccessoryCode, 510)
                INTERSECT
                SELECT *
                FROM dbo.FN_GBL_SplitHACode(ISNULL(o.intHACode, 1), 510)
            )
                  AND (
                          o.idfsSite = @SiteID
                          OR @SiteID IS NULL
                      )
                  AND (
                          organizationType.idfsReference = @OrganizationTypeID
                          OR @OrganizationTypeID IS NULL
                      )
                  AND gls.blnForeignAddress = @ShowForeignOrganizationsIndicator
            GROUP BY o.idfOffice,
                     o.idfsSite,
                     o.intRowStatus,
                     abbreviatedName.intOrder,
                     o.intHACode,
                     abbreviatedName.strDefault,
                     fullName.strDefault,
                     abbreviatedName.name,
                     fullName.name,
                     o.strOrganizationID,
                     organizationType.name,
                     g.Level1Name,
                     g.Level2Name,
                     g.Level3Name,
                     gls.strApartment,
                     gls.blnForeignAddress,
                     gls.strForeignAddress,
                     gls.strBuilding,
                     gls.strHouse,
                     gls.strStreetName,
                     gls.strPostCode
        ) AS x
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
