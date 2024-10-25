-- ================================================================================================
-- Name:USP_ADMIN_ORG_GETList_DD
--
-- Description: Returns a list of organizations.
--          
-- Original Author: Mandar Kulkarni
-- Modified By: Michael V. Brown
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
-- Michael Brown    03/11/2022 Created for filling Institution (organizations) Dropdown.
-- 
-- Testing Code:
-- EXEC USP_ADMIN_ORG_GETList 'en-US', 1, 10, 'AbbreviatedName', 'ASC', null, null, 2, null, '780000000', null, 0
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ORG_GETList_DD] (
	@LanguageID NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 9999
	,@SortColumn NVARCHAR(30) = 'AbbreviatedName'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@OrganizationKey BIGINT = NULL
	,@AbbreviatedName NVARCHAR(100) = NULL
	,@AccessoryCode INT = NULL
	,@AdministrativeLevelID BIGINT = NULL
	,@OrganizationTypeID BIGINT = NULL
	,@ShowForeignOrganizationsIndicator BIT = 0	
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @AdministrativeLevelNode AS HIERARCHYID
			,@firstRec INT
			,@lastRec INT
			,@TotalRowCount INT = (SELECT COUNT(*)
					FROM dbo.tlbOffice
					WHERE intRowStatus = 0
					);

		SET @firstRec = (@PageNumber - 1) * @PageSize;
		SET @lastRec = (@PageNumber * @PageSize + 1);

		IF @AdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @AdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @AdministrativeLevelID;
		END;
		
		SELECT OrganizationKey
			,AbbreviatedName
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @SortColumn = 'AbbreviatedName'
								AND @SortOrder = 'ASC'
								THEN ISNULL(strNameTran2.strTextString, baseRef2.strDefault)
							END ASC
						,CASE 
							WHEN @SortColumn = 'AbbreviatedName'
								AND @SortOrder = 'DESC'
								THEN ISNULL(strNameTran2.strTextString, baseRef2.strDefault)
							END DESC
						,IIF(@SortColumn = 'Order', ISNULL(strNameTran1.strTextString, baseRef1.strDefault), NULL) ASC
					) AS RowNum
				,office.idfOffice AS OrganizationKey
				,office.strOrganizationID AS OrganizationID
				,ISNULL(strNameTran2.strTextString, baseRef2.strDefault) AS AbbreviatedName
				,baseRef2.intOrder AS [Order]
				,organizationType.name AS OrganizationTypeName
				,office.intHACode AS AccessoryCode
				,office.idfsSite AS SiteID
				,office.intRowStatus AS RowStatus
				,COUNT(*) OVER () AS [RowCount]
				,@TotalRowCount AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
			FROM dbo.tlbOffice office
			LEFT OUTER JOIN dbo.tlbGeoLocationShared globLocShare ON office.idfLocation = globLocShare.idfGeoLocationShared
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = globLocShare.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT OUTER JOIN dbo.trtBaseReference AS baseRef1 ON office.idfsOfficeName = baseRef1.idfsBaseReference
			LEFT JOIN dbo.trtStringNameTranslation AS strNameTran1 ON baseRef1.idfsBaseReference = strNameTran1.idfsBaseReference
				AND strNameTran1.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			LEFT OUTER JOIN dbo.trtBaseReference AS baseRef2 ON office.idfsOfficeAbbreviation = baseRef2.idfsBaseReference
			LEFT JOIN dbo.trtStringNameTranslation AS strNameTran2 ON baseRef2.idfsBaseReference = strNameTran2.idfsBaseReference
				AND strNameTran2.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000504) organizationType ON office.OrganizationTypeID = organizationType.idfsReference
			WHERE office.intRowStatus = 0
				AND (
					office.idfOffice = @OrganizationKey
					OR @OrganizationKey IS NULL
					)
				AND (
					(
						baseRef2.strDefault LIKE '%' + @AbbreviatedName + '%'
						OR strNameTran2.strTextString LIKE '%' + @AbbreviatedName + '%'
						)
					OR @AbbreviatedName IS NULL
					)				
				AND (
					g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
					OR @AdministrativeLevelID IS NULL
					)
				AND (
					EXISTS (
						SELECT *
						FROM [dbo].[FN_GBL_SplitHACode](@AccessoryCode, 510)
						
						INTERSECT
						
						SELECT *
						FROM [dbo].[FN_GBL_SplitHACode](ISNULL(office.intHACode, 1), 510)
						)
					OR @AccessoryCode IS NULL
					)
				AND (
					organizationType.idfsReference = @OrganizationTypeID
					OR @OrganizationTypeID IS NULL
					)
				AND globLocShare.blnForeignAddress = @ShowForeignOrganizationsIndicator
			GROUP BY office.idfOffice
				,office.idfsSite
				,office.intRowStatus
				,baseRef1.intOrder
				,baseRef2.intOrder
				,office.intHACode
				,strNameTran1.strTextString
				,baseRef1.strDefault
				,strNameTran2.strTextString
				,baseRef2.strDefault
				,office.strOrganizationID
				,organizationType.name
				,LH.AdminLevel1Name
				,LH.AdminLevel2Name
				,LH.AdminLevel3Name
			) AS x
		WHERE RowNum > @firstRec
			AND RowNum < @lastRec
		ORDER BY RowNum;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
