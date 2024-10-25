-- ================================================================================================
-- Name: USP_Admin_SystemFunction_PersonANDEmployeeGroup_GetList
--
-- Description: Returns a list of permissions given as list of roles
--
-- Author: Ricky Moss
--
-- Revision Log:
-- Name					Date       Description of Change
-- -------------------- ---------- ---------------------------------------------------------------
-- Mandar Kulkarni		06/15/2021 Initial Release
-- Stephen Long         07/18/2021 Added configurable filtration rules.
--
-- exec USP_Admin_SystemFunction_PersonANDEmployeeGroup_GetList 10094004, 'en', 741
-- ================================================================================================
CREATE  PROCEDURE [dbo].[USP_Admin_SystemFunction_PersonANDEmployeeGroup_GetList] (
	@SystemFunctionID BIGINT
	,@LangID NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(100) = 'Name'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@ActorTypeID AS BIGINT = NULL -- User or User Group
	,@Name AS NVARCHAR(200) = NULL
	,@OrganizationName AS NVARCHAR(200) = NULL
	,@Description AS NVARCHAR(200) = NULL
	,@UserSiteID BIGINT = NULL
	,@UserOrganizationID BIGINT
	,@UserEmployeeID BIGINT
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @T TABLE (
			idfEmployee BIGINT
			,idfsEmployeeType BIGINT
			,[EmployeeTypeName] NVARCHAR(255)
			,[Name] NVARCHAR(2000)
			,idfsOfficeAbbreviation NVARCHAR(255)
			,[OrganizationName] NVARCHAR(255)
			,strDescription NVARCHAR(255)
			)
		DECLARE @Results TABLE (
			ID BIGINT NOT NULL
			,ReadPermissionIndicator BIT NOT NULL
			,AccessToPersonalDataPermissionIndicator BIT NOT NULL
			,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
			,WritePermissionIndicator BIT NOT NULL
			,DeletePermissionIndicator BIT NOT NULL
			);

		SET @firstRec = (@PageNumber - 1) * @Pagesize;
		SET @lastRec = (@PageNumber * @PageSize + 1);

		INSERT INTO @Results
		SELECT e.idfEmployee
			,1
			,1
			,1
			,1
			,1
		FROM dbo.tlbEmployee e
		LEFT JOIN dbo.tlbPerson Person ON Person.idfPerson = e.idfEmployee
		LEFT JOIN dbo.tlbEmployeeGroup employeeGroup ON employeeGroup.idfEmployeeGroup = e.idfEmployee
		-- translated group name
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName ON GroupName.idfsReference = employeeGroup.idfsEmployeeGroupName
		--rftEmployeeType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000023) Actor ON Actor.idfsReference = e.idfsEmployeeType
		LEFT JOIN dbo.tlbOffice Office ON Person.idfInstitution = Office.idfOffice
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) OfficeName ON Office.idfsOfficeAbbreviation = OfficeName.idfsReference
		WHERE e.intRowStatus = 0
			AND (
				e.idfsSite = @UserSiteID
				OR @UserSiteID IS NULL
				)
			AND e.idfsEmployeeType IN (
				10023001
				,10023002
				) -- user or group
			AND (
				e.idfEmployee NOT IN (
					SELECT idfEmployee
					FROM dbo.LkupRoleSystemFunctionAccess lrsfa
					WHERE SystemFunctionID = @SystemFunctionID
						--AND intRowStatusForSystemFunction = 1
					)
				OR e.idfEmployee IN (
					SELECT idfEmployee
					FROM dbo.LkupRoleSystemFunctionAccess lrsfa
					WHERE SystemFunctionID = @SystemFunctionID
						AND intRowStatusForSystemFunction = 1
					)
				)
			AND (
				e.idfsEmployeeType = @ActorTypeID
				OR @ActorTypeID IS NULL
				)
			AND (
				Person.strFamilyName LIKE + '%' + @name + '%'
				OR Person.strFirstName LIKE + '%' + @name + '%'
				OR employeeGroup.strName LIKE '%' + @name + '%'
				OR @name IS NULL
				)
			AND (
				OfficeName.name LIKE '%' + @OrganizationName + '%'
				OR @OrganizationName IS NULL
				)
			AND (
				employeeGroup.strDescription LIKE '%' + @Description + '%'
				OR @Description IS NULL
				);

		IF @UserSiteID IS NOT NULL
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
			INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.tflSiteToSiteGroup AS userSiteGroup ON userSiteGroup.idfsSite = @UserSiteID
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.tlbEmployeeGroupMember AS egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.tflSiteToSiteGroup AS grantingSGS ON grantingSGS.idfsSite = e.idfsSite
			INNER JOIN dbo.tstUserTable AS u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteGroupID = sgs.idfSiteGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorSiteID = @UserSiteID
				AND ara.ActorEmployeeGroupID IS NULL
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.tlbEmployeeGroupMember AS egm ON egm.idfEmployee = @UserEmployeeID
				AND egm.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			INNER JOIN dbo.tstUserTable AS u ON u.idfPerson = @UserEmployeeID
				AND u.intRowStatus = 0
			INNER JOIN dbo.AccessRuleActor AS ara ON ara.ActorUserID = u.idfUserID
				AND ara.intRowStatus = 0
			INNER JOIN dbo.AccessRule AS a ON a.AccessRuleID = ara.AccessRuleID
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
			LEFT JOIN dbo.tlbPerson Person ON Person.idfPerson = e.idfEmployee
			LEFT JOIN dbo.tlbEmployeeGroup employeeGroup ON employeeGroup.idfEmployeeGroup = e.idfEmployee
			-- translated group name
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName ON GroupName.idfsReference = employeeGroup.idfsEmployeeGroupName
			--rftEmployeeType
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000023) Actor ON Actor.idfsReference = e.idfsEmployeeType
			LEFT JOIN dbo.tlbOffice Office ON Person.idfInstitution = Office.idfOffice
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) OfficeName ON Office.idfsOfficeAbbreviation = OfficeName.idfsReference
			WHERE e.intRowStatus = 0
				--AND e.idfsSite = @UserSiteID
				AND e.idfsEmployeeType IN (
					10023001
					,10023002
					) -- user or group
				AND (
					e.idfEmployee NOT IN (
						SELECT idfEmployee
						FROM dbo.LkupRoleSystemFunctionAccess lrsfa
						WHERE SystemFunctionID = @SystemFunctionID
						)
					OR e.idfEmployee IN (
						SELECT idfEmployee
						FROM dbo.LkupRoleSystemFunctionAccess lrsfa
						WHERE SystemFunctionID = @SystemFunctionID
							AND intRowStatusForSystemFunction = 1
						)
					)
				AND (
					e.idfsEmployeeType = @ActorTypeID
					OR @ActorTypeID IS NULL
					)
				AND (
					Person.strFamilyName LIKE + '%' + @name + '%'
					OR Person.strFirstName LIKE + '%' + @name + '%'
					OR employeeGroup.strName LIKE '%' + @name + '%'
					OR @name IS NULL
					)
				AND (
					OfficeName.name LIKE '%' + @OrganizationName + '%'
					OR @OrganizationName IS NULL
					)
				AND (
					employeeGroup.strDescription LIKE '%' + @Description + '%'
					OR @Description IS NULL
					)
			GROUP BY ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator;
		END;

		INSERT INTO @T
		SELECT Employee.idfEmployee
			,Employee.idfsEmployeeType
			,Actor.name AS [EmployeeTypeName]
			,ISNULL(GroupName.name, dbo.FN_GBL_ConcatFullName(Person.strFamilyName, Person.strFirstName, Person.strSecondName)) AS 'Name'
			,Office.idfsOfficeAbbreviation
			,OfficeName.name AS [OrganizationName]
			,EmployeeGroup.strDescription
		FROM @Results res
		INNER JOIN dbo.tlbEmployee Employee ON Employee.idfEmployee = res.ID
		LEFT JOIN dbo.tlbPerson Person ON Person.idfPerson = Employee.idfEmployee
		LEFT JOIN dbo.tlbEmployeeGroup employeeGroup ON employeeGroup.idfEmployeeGroup = Employee.idfEmployee
		-- translated group name
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName ON GroupName.idfsReference = employeeGroup.idfsEmployeeGroupName
		--rftEmployeeType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000023) Actor ON Actor.idfsReference = Employee.idfsEmployeeType
		LEFT JOIN dbo.tlbOffice Office ON Person.idfInstitution = Office.idfOffice
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) OfficeName ON Office.idfsOfficeAbbreviation = OfficeName.idfsReference;

		WITH CTEResults
		AS (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN (
									@sortColumn = 'ActorType'
									AND @SortOrder = 'asc'
									)
								THEN [EmployeeTypeName]
							END ASC
						,CASE 
							WHEN (
									@sortColumn = 'ActorType'
									AND @SortOrder = 'desc'
									)
								THEN [EmployeeTypeName]
							END DESC
						,CASE 
							WHEN (
									@sortColumn = 'Name'
									AND @SortOrder = 'asc'
									)
								THEN [Name]
							END ASC
						,CASE 
							WHEN (
									@sortColumn = 'Name'
									AND @SortOrder = 'desc'
									)
								THEN [Name]
							END DESC
						,CASE 
							WHEN (
									@sortColumn = 'OrganizationName'
									AND @SortOrder = 'asc'
									)
								THEN OrganizationName
							END ASC
						,CASE 
							WHEN (
									@sortColumn = 'OrganizationName'
									AND @SortOrder = 'desc'
									)
								THEN OrganizationName
							END DESC
						,CASE 
							WHEN (
									@sortColumn = 'Description'
									AND @SortOrder = 'asc'
									)
								THEN strDescription
							END ASC
						,CASE 
							WHEN (
									@sortColumn = 'Description'
									AND @SortOrder = 'desc'
									)
								THEN strDescription
							END DESC
					) AS ROWNUM
				,COUNT(*) OVER () AS TotalRowCount
				,idfEmployee
				,idfsEmployeeType
				,[EmployeeTypeName]
				,[Name]
				,idfsOfficeAbbreviation
				,[OrganizationName]
				,strDescription
			FROM @T
			)
		SELECT TotalRowCount
			,idfEmployee
			,idfsEmployeeType
			,[EmployeeTypeName]
			,[Name]
			,idfsOfficeAbbreviation
			,[OrganizationName]
			,strDescription
			,TotalPages = (TotalRowCount / @PageSize) + IIF(TotalRowCount % @PageSize > 0, 1, 0)
			,CurrentPage = @PageNumber
		FROM CTEResults
		WHERE RowNum > @firstRec
			AND RowNum < @lastRec;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
