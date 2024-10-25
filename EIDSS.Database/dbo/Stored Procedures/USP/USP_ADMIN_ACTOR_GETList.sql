-- ================================================================================================
-- Name: USP_ADMIN_ACTOR_GETList
--
-- Description: Gets data for sites, site groups, users and user groups for use case SAUC62 and
-- configurable filtration user stories.
--          
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       05/13/2020 Initial release.
-- Stephen Long       11/10/2020 Added object access ID to the query.
-- Stephen Long       11/20/2020 Added search capability for site groups, sites and employee 
--                               groups for configurable site filtration.
-- Stephen Long       11/23/2020 Added actor name.
-- Stephen Long       11/24/2020 Corrected organization name for employee group type.
-- Ann Xiong          01/27/2021 Modified to return a list of Employee/Employee Group records for 
--                               disease filtration.
-- Ann Xiong          02/10/2021 Modified to return records when search by Name, Organization, and 
--                               Description.
-- Stephen Long       04/10/2021 Added pagination and sort logic.
-- Stephen Long       05/28/2021 Added disease filtration search indicator.
-- Stephen Long       06/09/2021 Added site filtration to filter search results.
-- Stephen Long       10/29/2021 Changed actor name on search results table to be nullable.
-- Michael Brown	  05/19/2021 Changed to assign the Family Name for the Actor Name Changed 
--								 And's to Or's at/around line 339
-- Stephen Long       12/15/2022 Modified to only return users when bringing back employee records.
--                               Non-users don't use EIDSS, so don't need to be included for 
--                               adding/denying permissions.  Fix on actor name search.
-- Stephen Long       12/20/2022 Changed employee group name to use base reference instead of name 
--                               on employee group table.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACTOR_GETList] (
	@LanguageID AS NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'ActorName'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@ActorTypeID AS BIGINT = NULL -- Site, Site Group, User or User Group
	,@ActorName AS NVARCHAR(200) = NULL
	,@OrganizationName AS NVARCHAR(200) = NULL
	,@UserGroupDescription AS NVARCHAR(200) = NULL
	,@DiseaseID AS BIGINT = NULL
	,@DiseaseFiltrationSearchIndicator AS BIT = 0
	,@UserSiteID BIGINT
	,@UserOrganizationID BIGINT
	,@UserEmployeeID BIGINT
	,@ApplySiteFiltrationIndicator BIT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
			
	BEGIN TRY
		DECLARE @Results TABLE (
			ID BIGINT NOT NULL
			,ReadPermissionIndicator BIT NOT NULL
			,AccessToPersonalDataPermissionIndicator BIT NOT NULL
			,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
			,WritePermissionIndicator BIT NOT NULL
			,DeletePermissionIndicator BIT NOT NULL
			);
		DECLARE @SearchResults TABLE (
			ActorID BIGINT NOT NULL
			,ActorTypeID BIGINT NOT NULL
			,ActorTypeName NVARCHAR(MAX) NOT NULL
			,ActorName NVARCHAR(MAX) NULL
			,ActorNameFirstLast NVARCHAR(MAX) NULL
			,OrganizationName NVARCHAR(MAX) NULL
			,EmployeeUserID BIGINT NULL
			,EmployeeSiteID BIGINT NULL
			,EmployeeSiteName NVARCHAR(MAX) NULL
			,UserGroupSiteID BIGINT NULL
			,UserGroupSiteName NVARCHAR(MAX) NULL
			,UserGroupDescription NVARCHAR(MAX) NULL
			,ObjectAccessID BIGINT NULL
			);
		DECLARE @FinalSearchResults TABLE (
			ActorID BIGINT NOT NULL
			,ActorTypeID BIGINT NOT NULL
			,ActorTypeName NVARCHAR(MAX) NOT NULL
			,ActorName NVARCHAR(MAX) NULL
			,ActorNameFirstLast NVARCHAR(MAX) NULL
			,OrganizationName NVARCHAR(MAX) NULL
			,EmployeeUserID BIGINT NULL
			,EmployeeSiteID BIGINT NULL
			,EmployeeSiteName NVARCHAR(MAX) NULL
			,UserGroupSiteID BIGINT NULL
			,UserGroupSiteName NVARCHAR(MAX) NULL
			,UserGroupDescription NVARCHAR(MAX) NULL
			,ObjectAccessID BIGINT NULL
			);

		SET NOCOUNT ON;

		IF @ApplySiteFiltrationIndicator = 1
		BEGIN
			DECLARE @FilteredResults TABLE (
				ID BIGINT NOT NULL
				,ReadPermissionIndicator BIT NOT NULL
				,AccessToPersonalDataPermissionIndicator BIT NOT NULL
				,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
				,WritePermissionIndicator BIT NOT NULL
				,DeletePermissionIndicator BIT NOT NULL
				,INDEX IDX_ID(ID)
				);

			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbEmployee e
			WHERE e.intRowStatus = 0
				AND e.idfsSite = @UserSiteID;

			-- =======================================================================================
			-- CONFIGURABLE SITE FILTRATION RULES
			-- 
			-- Apply configurable site filtration rules for use case SAUC34.
			-- =======================================================================================
			--
			-- Apply at the user's site group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup ON userSiteGroup.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's employee group level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			-- 
			-- Apply at the user's ID level, granted by a site group.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tflSiteToSiteGroup grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

			--
			-- Apply at the user's site group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tflSiteToSiteGroup sgs ON sgs.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND sgs.idfsSite = e.idfsSite;

			-- 
			-- Apply at the user's site level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteID = e.idfsSite;

			-- 
			-- Apply at the user's employee group level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tlbEmployeeGroupMember egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteID = e.idfsSite;

			-- 
			-- Apply at the user's ID level, granted by a site.
			--
			INSERT INTO @FilteredResults
			SELECT e.idfEmployee
				,a.ReadPermissionIndicator
				,a.AccessToPersonalDataPermissionIndicator
				,a.AccessToGenderAndAgeDataPermissionIndicator
				,a.WritePermissionIndicator
				,a.DeletePermissionIndicator
			FROM dbo.tlbEmployee e
			INNER JOIN dbo.tstUserTable u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule a ON a.AccessRuleID = ara.AccessRuleID
				AND a.intRowStatus = 0
				AND a.DefaultRuleIndicator = 0
			WHERE e.intRowStatus = 0
				AND a.GrantingActorSiteID = e.idfsSite;

			-- Copy filtered results to results and use search criteria
			INSERT INTO @Results
			SELECT ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator
			FROM @FilteredResults
			INNER JOIN dbo.tlbEmployee e ON e.idfEmployee = ID
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType ON e.idfsEmployeeType = actorType.idfsReference
			LEFT JOIN dbo.tlbPerson p ON p.idfPerson = e.idfEmployee
				AND p.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) organizationName ON p.idfInstitution = organizationName.idfOffice
			LEFT JOIN dbo.tlbEmployeeGroup eg ON e.idfEmployee = eg.idfEmployeeGroup
			LEFT JOIN dbo.tstSite employeeSite ON employeeSite.idfsSite = e.idfsSite
				AND employeeSite.intRowStatus = 0
			LEFT JOIN dbo.tstSite userGroupSite ON userGroupSite.idfsSite = eg.idfsSite
				AND userGroupSite.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000022) userGroupType ON eg.idfsEmployeeGroupName = userGroupType.idfsReference
			LEFT JOIN dbo.tstObjectAccess oa ON oa.idfActor = e.idfEmployee
				AND oa.intRowStatus = 0
				AND (
					oa.idfsObjectType = 10060001 -- Disease Record
					AND oa.idfsObjectOperation = 10059003 -- Read 
					AND @DiseaseID IS NOT NULL
					)
			WHERE (
					(
						-- User
						e.idfsEmployeeCategory = 10526001 -- User
						AND e.idfsEmployeeType = 10023002 -- User
						)
					OR (
						-- User Group
						e.idfsEmployeeCategory = 10526002 -- User
						AND e.idfsEmployeeType = 10023001 -- User Group
						AND eg.intRowStatus = 0
						)
					)
				AND (
					idfsEmployeeType = @ActorTypeID
					OR @ActorTypeID IS NULL
					)
				AND (
					oa.idfsObjectID = @DiseaseID
					OR @DiseaseID IS NULL
					)
				AND (
					organizationName.name LIKE '%' + @OrganizationName + '%'
					OR @OrganizationName IS NULL
					)
				AND (
					eg.strDescription LIKE '%' + @UserGroupDescription + '%'
					OR @UserGroupDescription IS NULL
					)
			GROUP BY ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator;
		END
		ELSE
		BEGIN
			INSERT INTO @Results
			SELECT DISTINCT e.idfEmployee
				,1
				,1
				,1
				,1
				,1
			FROM dbo.tlbEmployee e
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType ON e.idfsEmployeeType = actorType.idfsReference
			LEFT JOIN dbo.tlbPerson p ON p.idfPerson = e.idfEmployee
				AND p.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) organizationName ON p.idfInstitution = organizationName.idfOffice
			LEFT JOIN dbo.tlbEmployeeGroup eg ON e.idfEmployee = eg.idfEmployeeGroup
			LEFT JOIN dbo.tstSite employeeSite ON employeeSite.idfsSite = e.idfsSite
				AND employeeSite.intRowStatus = 0
			LEFT JOIN dbo.tstSite userGroupSite ON userGroupSite.idfsSite = eg.idfsSite
				AND userGroupSite.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000022) userGroupType ON eg.idfsEmployeeGroupName = userGroupType.idfsReference
			LEFT JOIN dbo.tstObjectAccess oa ON oa.idfActor = e.idfEmployee
				AND oa.intRowStatus = 0
				AND (
					oa.idfsObjectType = 10060001 -- Disease Record
					AND oa.idfsObjectOperation = 10059003 -- Read 
					AND @DiseaseID IS NOT NULL
					)
			WHERE e.intRowStatus = 0
				AND (
					(
						-- User
						e.idfsEmployeeCategory = 10526001 -- User
						AND e.idfsEmployeeType = 10023002 -- User
						)
					OR (
						-- User Group
						e.idfsEmployeeCategory = 10526002 -- User
						AND e.idfsEmployeeType = 10023001 -- User Group
						AND eg.intRowStatus = 0
						)
					)
				AND (
					idfsEmployeeType = @ActorTypeID
					OR @ActorTypeID IS NULL
					)
				AND (
					oa.idfsObjectID = @DiseaseID
					OR @DiseaseID IS NULL
					)
				AND (
					organizationName.name LIKE '%' + @OrganizationName + '%'
					OR @OrganizationName IS NULL
					)
				AND (
					eg.strDescription LIKE '%' + @UserGroupDescription + '%'
					OR @UserGroupDescription IS NULL
					);
		END;

		INSERT INTO @SearchResults (
			ActorID
			,ActorTypeID
			,ActorTypeName
			,ActorName
			,ActorNameFirstLast
			,OrganizationName
			,EmployeeUserID
			,EmployeeSiteID
			,EmployeeSiteName
			,UserGroupSiteID
			,UserGroupSiteName
			,UserGroupDescription
			,ObjectAccessID
			)
		SELECT DISTINCT e.idfEmployee AS ActorID
			,e.idfsEmployeeType AS ActorTypeID
			,actorType.name AS ActorTypeName
			,(
				CASE 
					WHEN e.idfsEmployeeType = 10023001 -- User Group
						THEN employeeGroupType.name
					ELSE dbo.FN_GBL_ConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName)
					END
				) AS ActorName
			,(
				CASE 
					WHEN e.idfsEmployeeType = 10023001 -- User Group
						THEN NULL
					ELSE p.strFirstName + ' ' + p.strFamilyName 
					END
				) AS ActorNameFirstLast
			,(
				CASE 
					WHEN e.idfsEmployeeType = 10023001 -- User Group
						THEN userGroupSite.strSiteName
					ELSE organizationName.name
					END
				) AS OrganizationName
			,u.idfUserID AS EmployeeUserID
			,employeeSite.idfsSite AS EmployeeSiteID
			,employeeSite.strSiteName AS EmployeeSiteName
			,userGroupSite.idfsSite AS UserGroupSiteID
			,userGroupSite.strSiteName AS UserGroupSiteName
			,eg.strDescription AS UserGroupDescription
			,oa.idfObjectAccess AS ObjectAccessID
		FROM @Results res
		INNER JOIN dbo.tlbEmployee e ON e.idfEmployee = res.ID
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000023) actorType ON e.idfsEmployeeType = actorType.idfsReference
		LEFT JOIN dbo.tlbPerson p ON p.idfPerson = e.idfEmployee
			AND p.intRowStatus = 0
		LEFT JOIN dbo.tstUserTable u ON u.idfPerson = p.idfPerson
			AND u.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) organizationName ON p.idfInstitution = organizationName.idfOffice
		LEFT JOIN dbo.tlbEmployeeGroup eg ON e.idfEmployee = eg.idfEmployeeGroup
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000022) employeeGroupType ON eg.idfsEmployeeGroupName = employeeGroupType.idfsReference
		LEFT JOIN dbo.tstSite employeeSite ON employeeSite.idfsSite = e.idfsSite
			AND employeeSite.intRowStatus = 0
		LEFT JOIN dbo.tstSite userGroupSite ON userGroupSite.idfsSite = eg.idfsSite
			AND userGroupSite.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000022) userGroupType ON eg.idfsEmployeeGroupName = userGroupType.idfsReference
		LEFT JOIN dbo.tstObjectAccess oa ON oa.idfActor = e.idfEmployee
			AND oa.idfsObjectID = @DiseaseID
			AND oa.intRowStatus = 0
			AND (
				oa.idfsObjectType = 10060001 -- Disease Record
				AND oa.idfsObjectOperation = 10059003 -- Read 
				AND @DiseaseID IS NOT NULL
				);

		IF @DiseaseFiltrationSearchIndicator = 0
		BEGIN
		    DECLARE @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_Get(@LanguageID);
			DECLARE @Site NVARCHAR(MAX) = (SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 549), 
			    @SiteGroup NVARCHAR(MAX) = (SELECT COALESCE(rt.strResourceString, r.strResourceName)
            FROM dbo.trtResource r
                LEFT JOIN dbo.trtResourceTranslation rt
                    ON rt.idfsResource = r.idfsResource
                       AND rt.idfsLanguage = @LanguageCode
                       AND rt.intRowStatus = 0
            WHERE r.idfsResource = 550);

			INSERT INTO @SearchResults
			SELECT s.idfSiteGroup AS ActorID
				,4 AS ActorTypeID
				,@SiteGroup AS ActorTypeName
				,s.strSiteGroupName AS ActorName
				,NULL AS ActorNameFirstLast
				,NULL AS OrganizationName
				,NULL AS EmployeeUserID
				,NULL AS EmployeeSiteID
				,NULL AS EmployeeSiteName
				,NULL AS UserGroupSiteID
				,NULL AS UserGroupSiteName
				,NULL AS UserGroupDescription
				,NULL AS ObjectAccessID
			FROM dbo.tflSiteGroup s
			WHERE s.intRowStatus = 0
				AND (
					@ActorTypeID = 4
					OR @ActorTypeID IS NULL
					)
				AND (
					s.strSiteGroupName LIKE '%' + @ActorName + '%'
					OR @ActorName IS NULL
					);

			INSERT INTO @SearchResults
			SELECT s.idfsSite AS ActorID
				,3 AS ActorTypeID
				,@Site AS ActorTypeName
				,s.strSiteName AS ActorName
				,NULL AS ActorNameFirstLast
				,organization.name AS OrganizationName
				,NULL AS EmployeeUserID
				,NULL AS EmployeeSiteID
				,NULL AS EmployeeSiteName
				,NULL AS UserGroupSiteID
				,NULL AS UserGroupSiteName
				,NULL AS UserGroupDescription
				,NULL AS ObjectAccessID
			FROM dbo.tstSite s
			LEFT JOIN dbo.FN_GBL_INSTITUTION(@LanguageID) organization ON organization.idfOffice = s.idfOffice
				AND organization.intRowStatus = 0
			WHERE s.intRowStatus = 0
				AND (
					@ActorTypeID = 3 -- Site
					OR @ActorTypeID IS NULL
					)
				AND (
					s.strSiteName LIKE '%' + @ActorName + '%'
					OR @ActorName IS NULL
					);
		END;

		INSERT INTO @FinalSearchResults
		SELECT * FROM @SearchResults
		WHERE ActorName LIKE + '%' + @ActorName + '%'
		       OR ActorNameFirstLast LIKE + '%' + @ActorName + '%' 
				OR @ActorName IS NULL;

		WITH paging
		AS (
			SELECT ActorID
				,c = COUNT(*) OVER ()
			FROM @FinalSearchResults res
			ORDER BY CASE 
					WHEN @SortColumn = 'ActorTypeName'
						AND @SortOrder = 'ASC'
						THEN ActorTypeName
					END ASC
				,CASE 
					WHEN @SortColumn = 'ActorTypeName'
						AND @SortOrder = 'DESC'
						THEN ActorTypeName
					END DESC
				,CASE 
					WHEN @SortColumn = 'ActorName'
						AND @SortOrder = 'ASC'
						THEN ActorName
					END ASC
				,CASE 
					WHEN @SortColumn = 'ActorName'
						AND @SortOrder = 'DESC'
						THEN ActorName
					END DESC
				,CASE 
					WHEN @SortColumn = 'OrganizationName'
						AND @SortOrder = 'ASC'
						THEN OrganizationName
					END ASC
				,CASE 
					WHEN @SortColumn = 'OrganizationName'
						AND @SortOrder = 'DESC'
						THEN OrganizationName
					END DESC
				,CASE 
					WHEN @SortColumn = 'UserGroupDescription'
						AND @SortOrder = 'ASC'
						THEN UserGroupDescription
					END ASC
				,CASE 
					WHEN @SortColumn = 'UserGroupDescription'
						AND @SortOrder = 'DESC'
						THEN UserGroupDescription
					END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
			)
		SELECT res.ActorID
			,ActorTypeID
			,ActorTypeName
			,ActorName
			,OrganizationName
			,EmployeeUserID
			,EmployeeSiteID
			,EmployeeSiteName
			,UserGroupSiteID
			,UserGroupSiteName
			,UserGroupDescription
			,ObjectAccessID
			,0 AS RowSelectionIndicator
			,c AS RecordCount
			,(
				(
					SELECT COUNT(*)
					FROM dbo.tlbEmployee
					WHERE intRowStatus = 0
					) + (
					SELECT COUNT(*)
					FROM dbo.tstSite
					WHERE intRowStatus = 0
						AND @DiseaseFiltrationSearchIndicator = 0
					) + (
					SELECT COUNT(*)
					FROM dbo.tflSiteGroup
					WHERE intRowStatus = 0
						AND @DiseaseFiltrationSearchIndicator = 0
					)
				) AS TotalRowCount
			,CurrentPage = @PageNumber
			,TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
		FROM @FinalSearchResults res
		INNER JOIN paging ON paging.ActorID = res.ActorID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
