-- ================================================================================================
-- Name: USP_ADMIN_SITE_GETList		
-- 
-- Description: Returns a list of sites.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/14/2022 Initial release.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SITE_GETList] @LanguageID NVARCHAR(50)
	,@SiteID BIGINT NULL
	,@EIDSSSiteID NVARCHAR(36) NULL
	,@SiteTypeID BIGINT NULL
	,@SiteName NVARCHAR(200) NULL
	,@HASCSiteID NVARCHAR(50) NULL
	,@OrganizationID BIGINT NULL
	,@AdministrativeLevelID BIGINT NULL
	,@SiteGroupID BIGINT = NULL
	,@AuditUserName NVARCHAR(512)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'SiteName'
	,@SortOrder NVARCHAR(4) = 'ASC'
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Results AS TABLE (
			SiteID BIGINT NOT NULL
			,SiteToSiteGroupID BIGINT NULL
			,SiteTypeName NVARCHAR(MAX) NULL
			,OrganizationName NVARCHAR(MAX) NULL
			,SiteName NVARCHAR(MAX) NULL
			,HASCSiteID NVARCHAR(MAX) NULL
			,EIDSSSiteID NVARCHAR(MAX) NULL
			,CountryName NVARCHAR(MAX) NULL
			,AdministrativeLevel2Name NVARCHAR(MAX) NULL
			,AdministrativeLevel3Name NVARCHAR(MAX) NULL
			,SettlementName NVARCHAR(MAX) NULL
			,RowSelectionIndicator BIT NOT NULL
			,[RowCount] INT NOT NULL
			,TotalRowCount INT NOT NULL
			,CurrentPage INT NOT NULL
			,TotalPages INT NOT NULL
			);
		DECLARE @AdministrativeLevelNode AS HIERARCHYID;

		IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
		END

		IF @AdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @AdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @AdministrativeLevelID;
		END;

		IF @SiteGroupID IS NULL
		BEGIN
			WITH paging
			AS (
				SELECT s.idfsSite
					,c = COUNT(*) OVER ()
				FROM dbo.tstSite s
				LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice
				LEFT OUTER JOIN dbo.tlbGeoLocationShared gls ON o.idfLocation = gls.idfGeoLocationShared
				LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gls.idfsLocation
				LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
				LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement ON settlement.idfsReference = gls.idfsLocation
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000085) siteType ON siteType.idfsReference = s.idfsSiteType
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) organizationAbbreviation ON organizationAbbreviation.idfsReference = o.idfsOfficeAbbreviation
				WHERE s.intRowStatus = 0
					AND (
						s.idfsSite = @SiteID
						OR @SiteID IS NULL
						)
					AND (
						s.idfsSiteType = @SiteTypeID
						OR @SiteTypeID IS NULL
						)
					AND (
						o.idfOffice = @OrganizationID
						OR @OrganizationID IS NULL
						)
					AND (
						g.node.IsDescendantOf(@AdministrativeLevelNode) = 1
						OR @AdministrativeLevelID IS NULL
						)
					AND (
						s.strSiteID LIKE '%' + @EIDSSSiteID + '%'
						OR @EIDSSSiteID IS NULL
						)
					AND (
						s.strSiteName LIKE '%' + @SiteName + '%'
						OR @SiteName IS NULL
						)
					AND (
						s.strHASCsiteID LIKE '%' + @HASCSiteID + '%'
						OR @HASCSiteID IS NULL
						)
				GROUP BY s.idfsSite
					,s.strSiteID
					,s.strHASCsiteID
					,s.strSiteName
					,o.idfOffice
					,g.node
					,s.idfsSiteType
					,siteType.name
					,organizationAbbreviation.name
				ORDER BY CASE 
						WHEN @SortColumn = 'SiteID'
							AND @SortOrder = 'ASC'
							THEN s.idfsSite
						END ASC
					,CASE 
						WHEN @SortColumn = 'SiteID'
							AND @SortOrder = 'DESC'
							THEN s.idfsSite
						END DESC
					,CASE 
						WHEN @SortColumn = 'EIDSSSiteID'
							AND @SortOrder = 'ASC'
							THEN s.strSiteID
						END ASC
					,CASE 
						WHEN @SortColumn = 'EIDSSSiteID'
							AND @SortOrder = 'DESC'
							THEN S.strSiteID
						END DESC
					,CASE 
						WHEN @SortColumn = 'SiteName'
							AND @SortOrder = 'ASC'
							THEN s.strSiteName
						END ASC
					,CASE 
						WHEN @SortColumn = 'SiteName'
							AND @SortOrder = 'DESC'
							THEN s.strSiteName
						END DESC
					,CASE 
						WHEN @SortColumn = 'SiteTypeName'
							AND @SortOrder = 'ASC'
							THEN siteType.name
						END ASC
					,CASE 
						WHEN @SortColumn = 'SiteTypeName'
							AND @SortOrder = 'DESC'
							THEN siteType.name
						END DESC
					,CASE 
						WHEN @SortColumn = 'HASCSiteID'
							AND @SortOrder = 'ASC'
							THEN s.strHASCsiteID
						END ASC
					,CASE 
						WHEN @SortColumn = 'HASCSiteID'
							AND @SortOrder = 'DESC'
							THEN s.strHASCsiteID
						END DESC
					,CASE 
						WHEN @SortColumn = 'OrganizationName'
							AND @SortOrder = 'ASC'
							THEN organizationAbbreviation.name
						END ASC
					,CASE 
						WHEN @SortColumn = 'OrganizationName'
							AND @SortOrder = 'DESC'
							THEN organizationAbbreviation.name
						END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
				)
			INSERT INTO @Results
			SELECT s.idfsSite AS SiteID
				,NULL AS SiteToSiteGroupID
				,siteType.name AS SiteTypeName
				,organizationAbbreviation.name AS OrganizationName
				,s.strSiteName AS SiteName
				,s.strHASCsiteID AS HASCSiteID
				,s.strSiteID AS EIDSSSiteID
				,LH.AdminLevel1Name AS CountryName
				,LH.AdminLevel2Name AS AdministrativeLevel2Name
				,LH.AdminLevel3Name AS AdministrativeLevel3Name
				,settlement.name AS SettlementName
				,0 AS RowSelectionIndicator
				,c AS [RowCount]
				,(
					SELECT COUNT(*)
					FROM dbo.tstSite
					WHERE intRowStatus = 0
					) AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
			FROM dbo.tstSite s
			INNER JOIN paging ON paging.idfsSite = s.idfsSite
			LEFT JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice
			LEFT OUTER JOIN dbo.tlbGeoLocationShared gls ON o.idfLocation = gls.idfGeoLocationShared
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gls.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement ON settlement.idfsReference = gls.idfsLocation
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000085) siteType ON siteType.idfsReference = s.idfsSiteType
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) organizationAbbreviation ON organizationAbbreviation.idfsReference = o.idfsOfficeAbbreviation;
		END
		ELSE
		BEGIN
			WITH paging
			AS (
				SELECT s.idfsSite
					,c = COUNT(*) OVER ()
				FROM dbo.tstSite s
				INNER JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice
				INNER JOIN dbo.tflSiteToSiteGroup ssg ON ssg.idfsSite = s.idfsSite
				LEFT OUTER JOIN dbo.tlbGeoLocationShared gls ON o.idfLocation = gls.idfGeoLocationShared
				LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gls.idfsLocation
				LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
				LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement ON settlement.idfsReference = gls.idfsLocation
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000085) siteType ON siteType.idfsReference = s.idfsSiteType
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) organizationAbbreviation ON organizationAbbreviation.idfsReference = o.idfsOfficeAbbreviation
				WHERE s.intRowStatus = 0
					AND ssg.idfSiteGroup = @SiteGroupID
				GROUP BY s.idfsSite
					,s.strSiteID
					,s.strHASCsiteID
					,s.strSiteName
					,o.idfOffice
					,g.node
					,s.idfsSiteType
					,siteType.name
					,ssg.idfSiteGroup
					,organizationAbbreviation.name
				ORDER BY CASE 
						WHEN @SortColumn = 'SiteID'
							AND @SortOrder = 'ASC'
							THEN s.idfsSite
						END ASC
					,CASE 
						WHEN @SortColumn = 'SiteID'
							AND @SortOrder = 'DESC'
							THEN s.idfsSite
						END DESC
					,CASE 
						WHEN @SortColumn = 'EIDSSSiteID'
							AND @SortOrder = 'ASC'
							THEN s.strSiteID
						END ASC
					,CASE 
						WHEN @SortColumn = 'EIDSSSiteID'
							AND @SortOrder = 'DESC'
							THEN S.strSiteID
						END DESC
					,CASE 
						WHEN @SortColumn = 'SiteName'
							AND @SortOrder = 'ASC'
							THEN s.strSiteName
						END ASC
					,CASE 
						WHEN @SortColumn = 'SiteName'
							AND @SortOrder = 'DESC'
							THEN s.strSiteName
						END DESC
					,CASE 
						WHEN @SortColumn = 'SiteTypeName'
							AND @SortOrder = 'ASC'
							THEN siteType.name
						END ASC
					,CASE 
						WHEN @SortColumn = 'SiteTypeName'
							AND @SortOrder = 'DESC'
							THEN siteType.name
						END DESC
					,CASE 
						WHEN @SortColumn = 'HASCSiteID'
							AND @SortOrder = 'ASC'
							THEN s.strHASCsiteID
						END ASC
					,CASE 
						WHEN @SortColumn = 'HASCSiteID'
							AND @SortOrder = 'DESC'
							THEN s.strHASCsiteID
						END DESC
					,CASE 
						WHEN @SortColumn = 'OrganizationName'
							AND @SortOrder = 'ASC'
							THEN organizationAbbreviation.name
						END ASC
					,CASE 
						WHEN @SortColumn = 'OrganizationName'
							AND @SortOrder = 'DESC'
							THEN organizationAbbreviation.name
						END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
				)
			INSERT INTO @Results
			SELECT s.idfsSite AS SiteID
				,ssg.idfSiteToSiteGroup AS SiteToSiteGroupID
				,siteType.name AS SiteTypeName
				,organizationAbbreviation.name AS OrganizationName
				,s.strSiteName AS SiteName
				,s.strHASCsiteID AS HASCSiteID
				,s.strSiteID AS EIDSSSiteID
				,LH.AdminLevel1Name AS CountryName
				,LH.AdminLevel2Name AS AdministrativeLevel2Name
				,LH.AdminLevel3Name AS AdministrativeLevel3Name
				,settlement.name AS SettlementName
				,0 AS RowSelectionIndicator
				,c AS [RowCount]
				,(
					SELECT COUNT(*)
					FROM dbo.tflSiteToSiteGroup
					WHERE idfSiteGroup = @SiteGroupID
					) AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
			FROM paging p
			INNER JOIN dbo.tstSite s ON s.idfsSite = p.idfsSite
			INNER JOIN dbo.tlbOffice o ON s.idfOffice = o.idfOffice
			INNER JOIN dbo.tflSiteToSiteGroup ssg ON ssg.idfsSite = p.idfsSite
			LEFT OUTER JOIN dbo.tlbGeoLocationShared gls ON o.idfLocation = gls.idfGeoLocationShared
			LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gls.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh ON lh.idfsLocation = g.idfsLocation
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement ON settlement.idfsReference = gls.idfsLocation
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000085) siteType ON siteType.idfsReference = s.idfsSiteType
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000045) organizationAbbreviation ON organizationAbbreviation.idfsReference = o.idfsOfficeAbbreviation
			WHERE ssg.idfSiteGroup = @SiteGroupID
		END

		SELECT SiteID
			,SiteToSiteGroupID
			,SiteTypeName
			,OrganizationName
			,SiteName
			,HASCSiteID
			,EIDSSSiteID
			,CountryName
			,AdministrativeLevel2Name
			,AdministrativeLevel3Name
			,SettlementName
			,RowSelectionIndicator
			,[RowCount]
			,TotalRowCount
			,CurrentPage
			,TotalPages
		FROM @Results;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
