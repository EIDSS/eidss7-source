
--==============================================================================================================
-- NAME:					[USP_Admin_GetUserGoupAndUserList]
-- DESCRIPTION:				Returns a list of UserGroupAndUser list
-- AUTHOR:					Manickandan Govindarajan
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Manickandan Govindarajan			06/9/2021	Initial Release
--Manickandan Govindarajan			03/15/2022  Added to include Default Gorup -506 
--Manickandan Govindarajan	        03/17/2022  Removed the UserSiteID condition to bring all the users
--
-- EXEC [USP_Admin_UserGoupAndUser_GetList] 'en'

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_Admin_UserGoupAndUser_GetList]
		@LanguageId NVARCHAR(50),
		@Id BIGINT,
		@Name NVARCHAR(255) =NULL,
		@pageNo INT = 1,
		@pageSize INT = 10,
		@sortColumn NVARCHAR(30) = 'Name',
		@sortOrder NVARCHAR(4) = 'asc',
		@UserSiteID BIGINT = NULL,
		@UserOrganizationID BIGINT,
		@UserEmployeeID BIGINT
AS
BEGIN
	
	BEGIN TRY

	SET NOCOUNT ON;

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @T TABLE (
			id BIGINT
			,idfsEmployeeType BIGINT
			,Name NVARCHAR(255)
			,TypeName NVARCHAR(2000)
			)
		DECLARE @Results TABLE (
			ID BIGINT NOT NULL
			,ReadPermissionIndicator BIT NOT NULL
			,AccessToPersonalDataPermissionIndicator BIT NOT NULL
			,AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL
			,WritePermissionIndicator BIT NOT NULL
			,DeletePermissionIndicator BIT NOT NULL
			,INDEX IDX_ID(ID)
			);

		SET @firstRec = (@pageNo - 1) * @pageSize;
		SET @lastRec = (@pageNo * @pageSize + 1);

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
		JOIN (SELECT idfEmployee FROM dbo.LkupRoleSystemFunctionAccess WHERE SystemFunctionID = @id AND intRowStatusForSystemFunction =0 GROUP BY idfEmployee )  rsys
		ON e.idfEmployee= rsys.idfEmployee
		-- translated group name
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000022) GroupName ON GroupName.idfsReference = employeeGroup.idfsEmployeeGroupName
		--rftEmployeeType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000023) Actor ON Actor.idfsReference = e.idfsEmployeeType
		LEFT JOIN dbo.[FN_GBL_Institution](@LanguageId) ins ON ins.idfOffice = person.idfInstitution 
		WHERE e.intRowStatus = 0
		AND (
				e.idfsSite = @UserSiteID
				OR @UserSiteID IS NULL
				)



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
			WHERE e.intRowStatus = 0 AND e.idfsEmployeeType=10023002
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
			WHERE e.intRowStatus = 0 AND e.idfsEmployeeType=10023002
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
			WHERE e.intRowStatus = 0 AND e.idfsEmployeeType=10023001
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
			WHERE e.intRowStatus = 0  AND e.idfsEmployeeType=10023002
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
			WHERE e.intRowStatus = 0 AND e.idfsEmployeeType =10023002
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
			WHERE e.intRowStatus = 0 AND e.idfsEmployeeType= 10023002
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
			WHERE e.intRowStatus = 0 AND e.idfsEmployeeType= 10023001
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
			WHERE e.intRowStatus = 0  AND e.idfsEmployeeType=10023002
				AND a.GrantingActorSiteID = e.idfsSite;

			-- Copy filtered results to results and use search criteria
			INSERT INTO @Results
			SELECT ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator
			FROM @FilteredResults res
			INNER JOIN dbo.tlbEmployee e ON e.idfEmployee = res.ID
			LEFT JOIN dbo.tlbPerson Person ON Person.idfPerson = e.idfEmployee
			JOIN (select idfEmployee from dbo.LkupRoleSystemFunctionAccess where SystemFunctionID = @Id and intRowStatusForSystemFunction =0 group by idfEmployee )  rsys
			on e.idfEmployee= rsys.idfEmployee
			LEFT JOIN dbo.tlbEmployeeGroup employeeGroup ON employeeGroup.idfEmployeeGroup = e.idfEmployee
			-- translated group name
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000022) GroupName ON GroupName.idfsReference = employeeGroup.idfsEmployeeGroupName
			--rftEmployeeType
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000023) Actor ON Actor.idfsReference = e.idfsEmployeeType

			WHERE e.intRowStatus = 0
				
			GROUP BY ID
				,ReadPermissionIndicator
				,AccessToPersonalDataPermissionIndicator
				,AccessToGenderAndAgeDataPermissionIndicator
				,WritePermissionIndicator
				,DeletePermissionIndicator;
		END;

		INSERT INTO @T
		SELECT Employee.idfEmployee as id
			,Employee.idfsEmployeeType
			,ISNULL(GroupName.name, dbo.FN_GBL_ConcatFullName(Person.strFamilyName, Person.strFirstName, Person.strSecondName)) AS Name
			,Actor.name AS TypeName 
		FROM @Results res
		INNER JOIN dbo.tlbEmployee Employee ON Employee.idfEmployee = res.ID
		LEFT JOIN dbo.tlbPerson Person ON Person.idfPerson = Employee.idfEmployee
		LEFT JOIN dbo.tlbEmployeeGroup employeeGroup ON employeeGroup.idfEmployeeGroup = Employee.idfEmployee
		JOIN (select idfEmployee from dbo.LkupRoleSystemFunctionAccess where SystemFunctionID = @Id and intRowStatusForSystemFunction =0 group by idfEmployee )  rsys
		on employee.idfEmployee= rsys.idfEmployee
		-- translated group name
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000022) GroupName ON GroupName.idfsReference = employeeGroup.idfsEmployeeGroupName
		--rftEmployeeType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000023) Actor ON Actor.idfsReference = Employee.idfsEmployeeType
		WHERE 
		--(
		--	Employee.idfsSite = @UserSiteID
		--	OR @UserSiteID IS NULL OR ( Employee.idfsSite =1 AND Employee.idfEmployee=-506)
		--)
		--AND
		Employee.idfsEmployeeType IN (
			10023001
			,10023002
			) -- user or group
		AND (
			person.strFamilyName  LIKE '%' + @Name + '%'
			OR person.strFirstName  LIKE '%' + @Name + '%'
			OR person.strSecondName  LIKE '%' + @Name + '%'
			OR employeeGroup.strName  LIKE '%' + @Name + '%'
			OR employeeGroup.strDescription  LIKE '%' + @Name + '%'
			OR @Name IS NULL 
			OR @Name = ''
			); -- user name or user group name

		WITH CTEResults
		AS (
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN Name ='Default Role' and @sortColumn = 'Name' AND @SortOrder = 'asc'  THEN 0 ELSE 1 END , Name  ASC,
				CASE WHEN Name ='Default Role' and @sortColumn = 'Name' AND @SortOrder = 'desc'  THEN 0 ELSE 1 END , Name  DESC,
			    CASE WHEN Name ='Default Role' and @sortColumn = 'Type' AND @SortOrder = 'asc'  THEN 0 ELSE 1 END , TypeName  ASC,
				CASE WHEN Name ='Default Role' and @sortColumn = 'Type' AND @SortOrder = 'desc'  THEN 0 ELSE 1 END , TypeName  desc	
				) AS ROWNUM,
				COUNT(*) OVER () AS TotalRowCount,
				id, 
				idfsEmployeeType, 
				Name, 
				TypeName
			FROM @T
			)
		SELECT TotalRowCount
			,id
			,idfsEmployeeType
			,Name
			,TypeName
			,TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0)
			,CurrentPage = @pageNo
		FROM CTEResults
		WHERE RowNum > @firstRec
			AND RowNum < @lastRec;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
