-- ================================================================================================
-- Name: USP_ADMIN_ACCESS_RULE_GETList		
-- 
-- Description: Returns a list of access rules for configurable site filtration.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/11/2020 Initial release.
-- Stephen Long     11/25/2020 Added new permission fields to the query.
-- Stephen Long     12/18/2020 Added bordering area rule indicator field to the query.
-- Stephen Long     12/27/2020 Added reciprocal rule indicator field to the query.
-- Stephen Long     03/18/2021 Added default rule indicator and administrative level type ID.
-- Stephen Long     03/22/2021 Added updated paging logic and changed to administrative levels.
-- Stephen Long     01/09/2022 Added create permission indicator.
-- Stephen Long     03/15/2022 Added duplicate check parameters.
-- Stephen Long     03/16/2022 Changed receiving actor duplicate check parameters from bigint to 
--                             varchar(max).
-- Stephen Long     06/03/2022 Changed access rule name to pull from base reference.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACCESS_RULE_GETList] @LanguageID NVARCHAR(50)
	,@Page INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'AccessRuleID'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@AccessRuleID BIGINT = NULL
	,@AccessRuleName NVARCHAR(MAX) = NULL
	,@BorderingAreaRuleIndicator BIT = 0
	,@DefaultRuleIndicator BIT = 0
	,@ReciprocalRuleIndicator BIT = 0
	,@AccessToPersonalDataPermissionIndicator BIT = 0
	,@AccessToGenderAndAgeDataPermissionIndicator BIT = 0
	,@CreatePermissionIndicator BIT = NULL
	,@DeletePermissionIndicator BIT = NULL
	,@ReadPermissionIndicator BIT = 0
	,@WritePermissionIndicator BIT = NULL
	,@GrantingActorSiteCode NVARCHAR(50) = NULL
	,@GrantingActorSiteHASCCode NVARCHAR(50) = NULL
	,@GrantingActorSiteName NVARCHAR(200) = NULL
	,@GrantingActorAdministrativeLevelID BIGINT = NULL
	,@ReceivingActorSiteCode NVARCHAR(50) = NULL
	,@ReceivingActorSiteHASCCode NVARCHAR(50) = NULL
	,@ReceivingActorSiteName NVARCHAR(200) = NULL
	,@ReceivingActorAdministrativeLevelID BIGINT = NULL
	,@GrantingActorSiteGroupID BIGINT = NULL
	,@GrantingActorSiteID BIGINT = NULL
	,@ReceivingActorSiteGroups VARCHAR(MAX) = NULL
	,@ReceivingActorSites VARCHAR(MAX) = NULL
	,@ReceivingActorUserGroups VARCHAR(MAX) = NULL
	,@ReceivingActorUsers VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @GrantingActorAdministrativeLevelNode AS HIERARCHYID
			,@ReceivingActorAdministrativeLevelNode AS HIERARCHYID;

		IF @GrantingActorAdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @GrantingActorAdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @GrantingActorAdministrativeLevelID;
		END;

		IF @ReceivingActorAdministrativeLevelID IS NOT NULL
		BEGIN
			SELECT @ReceivingActorAdministrativeLevelNode = node
			FROM dbo.gisLocation
			WHERE idfsLocation = @ReceivingActorAdministrativeLevelID;
		END;

		DECLARE @Results TABLE (ID BIGINT NOT NULL);

		INSERT INTO @Results
		SELECT a.AccessRuleID
		FROM dbo.AccessRule a
        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000537) accessRuleName
            ON accessRuleName.idfsReference = a.AccessRuleID
		LEFT JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = a.AccessRuleID
			AND ara.intRowStatus = 0
		LEFT JOIN dbo.tstSite grantingActorSite ON grantingActorSite.idfsSite = a.GrantingActorSiteID
			AND grantingActorSite.intRowStatus = 0
		LEFT JOIN dbo.tflSiteGroup grantingActorSiteGroup ON grantingActorSiteGroup.idfSiteGroup = a.GrantingActorSiteGroupID
			AND grantingActorSiteGroup.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice grantingActorSiteOffice ON grantingActorSiteOffice.idfOffice = grantingActorSite.idfOffice
			AND grantingActorSiteOffice.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared grantingActorSiteLocation ON grantingActorSiteOffice.idfLocation = grantingActorSiteLocation.idfGeoLocationShared
			AND grantingActorSiteLocation.intRowStatus = 0
		LEFT JOIN dbo.tstSite receivingActorSite ON receivingActorSite.idfsSite = ara.ActorSiteID
			AND receivingActorSite.intRowStatus = 0
		LEFT JOIN dbo.tflSiteGroup receivingActorSiteGroup ON receivingActorSiteGroup.idfSiteGroup = ara.ActorSiteGroupID
			AND receivingActorSiteGroup.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice receivingActorSiteOffice ON receivingActorSiteOffice.idfOffice = receivingActorSiteOffice.idfOffice
			AND receivingActorSiteOffice.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared receivingActorSiteLocation ON receivingActorSiteOffice.idfLocation = receivingActorSiteLocation.idfGeoLocationShared
			AND receivingActorSiteLocation.intRowStatus = 0
		WHERE a.intRowStatus = 0
			AND (
				a.AccessRuleID = @AccessRuleID
				OR @AccessRuleID IS NULL
				)
			AND (
				a.DefaultRuleIndicator = @DefaultRuleIndicator
				OR @DefaultRuleIndicator = 0
				)
			AND (
				a.BorderingAreaRuleIndicator = @BorderingAreaRuleIndicator
				OR @BorderingAreaRuleIndicator = 0
				)
			AND (
				a.ReciprocalRuleIndicator = @ReciprocalRuleIndicator
				OR @ReciprocalRuleIndicator = 0
				)
			AND (
				a.ReadPermissionIndicator = @ReadPermissionIndicator
				OR @ReadPermissionIndicator = 0
				)
			AND (
				a.AccessToPersonalDataPermissionIndicator = @AccessToPersonalDataPermissionIndicator
				OR @AccessToPersonalDataPermissionIndicator = 0
				)
			AND (
				a.AccessToGenderAndAgeDataPermissionIndicator = @AccessToGenderAndAgeDataPermissionIndicator
				OR @AccessToGenderAndAgeDataPermissionIndicator = 0
				)
			AND (
				a.CreatePermissionIndicator = @CreatePermissionIndicator
				OR @CreatePermissionIndicator = 0
				)
			AND (
				a.WritePermissionIndicator = @WritePermissionIndicator
				OR @WritePermissionIndicator = 0
				)
			AND (
				a.DeletePermissionIndicator = @DeletePermissionIndicator
				OR @DeletePermissionIndicator = 0
				)
			AND (
				grantingActorSiteLocation.idfsLocation = @GrantingActorAdministrativeLevelID
				OR @GrantingActorAdministrativeLevelID IS NULL
				)
			AND (
				receivingActorSiteLocation.idfsLocation = @ReceivingActorAdministrativeLevelID
				OR @ReceivingActorAdministrativeLevelID IS NULL
				)
			AND (
				accessRuleName.name LIKE '%' + @AccessRuleName + '%'
				OR @AccessRuleName IS NULL
				)
			AND (
				grantingActorSite.strSiteID LIKE @GrantingActorSiteCode + '%'
				OR @GrantingActorSiteCode IS NULL
				)
			AND (
				grantingActorSite.strSiteName LIKE @GrantingActorSiteName + '%'
				OR @GrantingActorSiteName IS NULL
				)
			AND (
				grantingActorSite.strHASCsiteID LIKE @GrantingActorSiteHASCCode + '%'
				OR @GrantingActorSiteHASCCode IS NULL
				)
			AND (
				receivingActorSite.strSiteID LIKE @ReceivingActorSiteCode + '%'
				OR @ReceivingActorSiteCode IS NULL
				)
			AND (
				receivingActorSite.strSiteName LIKE @ReceivingActorSiteName + '%'
				OR @ReceivingActorSiteName IS NULL
				)
			AND (
				receivingActorSite.strHASCsiteID LIKE @ReceivingActorSiteHASCCode + '%'
				OR @ReceivingActorSiteHASCCode IS NULL
				)
			AND (
				a.GrantingActorSiteGroupID = @GrantingActorSiteGroupID 
				OR @GrantingActorSiteGroupID IS NULL
				)
			AND (
				a.GrantingActorSiteID = @GrantingActorSiteID 
				OR @GrantingActorSiteID IS NULL
				)
			AND (
				ara.ActorSiteGroupID IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@ReceivingActorSiteGroups, NULL, ',')) 
				OR @ReceivingActorSiteGroups IS NULL
				)
			AND (
				ara.ActorSiteID IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@ReceivingActorSites, NULL, ',')) 
				OR @ReceivingActorSites IS NULL
				)
			AND (
				ara.ActorEmployeeGroupID IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@ReceivingActorUserGroups, NULL, ',')) 
				OR @ReceivingActorUserGroups IS NULL
				)
			AND (
				ara.ActorUserID IN (SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@ReceivingActorUsers, NULL, ','))
				OR @ReceivingActorUsers IS NULL
				)
		GROUP BY a.AccessRuleID;

		WITH paging
		AS (
			SELECT ID
				,c = COUNT(*) OVER ()
			FROM @Results res
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ID
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000537) accessRuleName
                ON accessRuleName.idfsReference = a.AccessRuleID
			LEFT JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = a.AccessRuleID
				AND ara.intRowStatus = 0
			LEFT JOIN dbo.tstSite grantingActorSite ON grantingActorSite.idfsSite = a.GrantingActorSiteID
				AND grantingActorSite.intRowStatus = 0
			LEFT JOIN dbo.tflSiteGroup grantingActorSiteGroup ON grantingActorSiteGroup.idfSiteGroup = a.GrantingActorSiteGroupID
				AND grantingActorSiteGroup.intRowStatus = 0
			LEFT JOIN dbo.tlbOffice grantingActorSiteOffice ON grantingActorSiteOffice.idfOffice = grantingActorSite.idfOffice
				AND grantingActorSiteOffice.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocationShared grantingActorSiteLocation ON grantingActorSiteOffice.idfLocation = grantingActorSiteLocation.idfGeoLocationShared
				AND grantingActorSiteLocation.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = grantingActorSiteLocation.idfsLocation
			ORDER BY CASE 
					WHEN @SortColumn = 'AccessRuleID'
						AND @SortOrder = 'ASC'
						THEN a.AccessRuleID
					END ASC
				,CASE 
					WHEN @SortColumn = 'AccessRuleID'
						AND @SortOrder = 'DESC'
						THEN a.AccessRuleID
					END DESC
				,CASE 
					WHEN @SortColumn = 'AccessRuleName'
						AND @SortOrder = 'ASC'
						THEN accessRuleName.name
					END ASC
				,CASE 
					WHEN @SortColumn = 'AccessRuleName'
						AND @SortOrder = 'DESC'
						THEN accessRuleName.name
					END DESC
				,CASE 
					WHEN @SortColumn = 'DefaultRuleIndicator'
						AND @SortOrder = 'ASC'
						THEN DefaultRuleIndicator
					END ASC
				,CASE 
					WHEN @SortColumn = 'DefaultRuleIndicator'
						AND @SortOrder = 'DESC'
						THEN DefaultRuleIndicator
					END DESC
				,CASE 
					WHEN @SortColumn = 'BorderingAreaRuleIndicator'
						AND @SortOrder = 'ASC'
						THEN BorderingAreaRuleIndicator
					END ASC
				,CASE 
					WHEN @SortColumn = 'BorderingAreaRuleIndicator'
						AND @SortOrder = 'DESC'
						THEN BorderingAreaRuleIndicator
					END DESC
				,CASE 
					WHEN @SortColumn = 'ReciprocalRuleIndicator'
						AND @SortOrder = 'ASC'
						THEN ReciprocalRuleIndicator
					END ASC
				,CASE 
					WHEN @SortColumn = 'ReciprocalRuleIndicator'
						AND @SortOrder = 'DESC'
						THEN ReciprocalRuleIndicator
					END DESC
				,CASE 
					WHEN @SortColumn = 'GrantingActorName'
						AND @SortOrder = 'ASC'
						THEN (
								CASE 
									WHEN grantingActorSiteGroup.strSiteGroupName IS NOT NULL
										THEN grantingActorSiteGroup.strSiteGroupName
									ELSE grantingActorSite.strSiteName
									END
								)
					END ASC
				,CASE 
					WHEN @SortColumn = 'GrantingActorName'
						AND @SortOrder = 'DESC'
						THEN (
								CASE 
									WHEN grantingActorSiteGroup.strSiteGroupName IS NOT NULL
										THEN grantingActorSiteGroup.strSiteGroupName
									ELSE grantingActorSite.strSiteName
									END
								)
					END DESC
				,CASE 
					WHEN @SortColumn = 'GrantingSiteAdministrativeLevel1Name'
						AND @SortOrder = 'ASC'
						THEN lh.AdminLevel2Name
					END ASC
				,CASE 
					WHEN @SortColumn = 'GrantingSiteAdministrativeLevel1Name'
						AND @SortOrder = 'DESC'
						THEN lh.AdminLevel2Name
					END DESC
				,CASE 
					WHEN @SortColumn = 'GrantingSiteAdministrativeLevel2Name'
						AND @SortOrder = 'ASC'
						THEN lh.AdminLevel3Name
					END ASC
				,CASE 
					WHEN @SortColumn = 'GrantingSiteAdministrativeLevel2Name'
						AND @SortOrder = 'DESC'
						THEN lh.AdminLevel3Name
					END DESC OFFSET @PageSize * (@Page - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
			)
		SELECT a.AccessRuleID
			,accessRuleName.name AS AccessRuleName 
			,a.DefaultRuleIndicator
			,a.BorderingAreaRuleIndicator
			,a.ReciprocalRuleIndicator
			,(
				CASE 
					WHEN grantingActorSiteGroup.strSiteGroupName IS NOT NULL
						THEN grantingActorSiteGroup.strSiteGroupName
					ELSE grantingActorSite.strSiteName
					END
				) AS GrantingActorName
			,lh.AdminLevel2Name AS GrantingSiteAdministrativeLevel1Name
			,lh.AdminLevel3Name AS GrantingSiteAdministrativeLevel2Name
			,c AS RecordCount
			,(
				SELECT COUNT(AccessRuleID)
				FROM dbo.AccessRule
				WHERE intRowStatus = 0
				) AS TotalRowCount
			,TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
			,CurrentPage = @Page
		FROM @Results res
		INNER JOIN paging ON paging.ID = res.ID
		INNER JOIN dbo.AccessRule a ON a.AccessRuleID = res.ID
        INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000537) accessRuleName
            ON accessRuleName.idfsReference = a.AccessRuleID
		LEFT JOIN dbo.AccessRuleActor ara ON ara.AccessRuleID = a.AccessRuleID
			AND ara.intRowStatus = 0
		LEFT JOIN dbo.tstSite grantingActorSite ON grantingActorSite.idfsSite = a.GrantingActorSiteID
			AND grantingActorSite.intRowStatus = 0
		LEFT JOIN dbo.tflSiteGroup grantingActorSiteGroup ON grantingActorSiteGroup.idfSiteGroup = a.GrantingActorSiteGroupID
			AND grantingActorSiteGroup.intRowStatus = 0
		LEFT JOIN dbo.tlbOffice grantingActorSiteOffice ON grantingActorSiteOffice.idfOffice = grantingActorSite.idfOffice
			AND grantingActorSiteOffice.intRowStatus = 0
		LEFT JOIN dbo.tlbGeoLocationShared grantingActorSiteLocation ON grantingActorSiteOffice.idfLocation = grantingActorSiteLocation.idfGeoLocationShared
			AND grantingActorSiteLocation.intRowStatus = 0
		--LEFT OUTER JOIN dbo.gisLocation g ON g.idfsLocation = grantingActorSiteLocation.idfsLocation
        LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
            ON lh.idfsLocation = grantingActorSiteLocation.idfsLocation
		GROUP BY a.AccessRuleID
			,accessRuleName.name
			,a.DefaultRuleIndicator
			,a.BorderingAreaRuleIndicator
			,a.ReciprocalRuleIndicator
			,grantingActorSiteGroup.strSiteGroupName
			,grantingActorSite.strSiteName
			,lh.AdminLevel2Name
			,lh.AdminLevel3Name
			,paging.c
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
