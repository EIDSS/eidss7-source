-- ===============================================================================================================
-- Name: USP_ADMIN_EMPLOYEEGROUP_SET_TEMP
-- Description: Add or reactivates a relationship between an employee and employee group
-- Author: Ricky Moss
--
-- History of changes
--
-- Name					Date			Change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			12/02/2019		Initial Release
-- Ricky Moss			03/25/2019		Added EmployeeGroupName when checking for duplicate and refactored the 
--                                      query checking for duplicates
-- Stephen Long         05/19/2020 Updated existing default and name queries to use top 1 as the name was 
--                                 returning duplicates causing a subquery error.
-- Ann Xiong            01/27/2021 Modified to pass 10023001 (Employee Group) instead of 10023002 (Person) 
--                                 as idfsEmployeeType when insert new Employee Group to tlbEmployee.
-- Mandar				07/09/2021 Fixed an issue when creating a new user group.
-- Ann Xiong            10/28/2021 Modified to return ReturnMessage instead of RetunMessage.
-- Stephen Long         03/14/2022 Removed insert suppress select on base reference set; causing nested insert 
--                                 exec on USP_ADMIN_SITE_SET call.
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET_TEMP -500, 1, 'Test 1204-7', 'Test 1204-7', 'Test Role on December 4',  'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET_TEMP NULL, 1, 'Test 1205', 'Test 1205', 'Test Role on December 5',  'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET_TEMP NULL, 1, 'Test 1212-1', 'Test 1212-1', 'Test Role on December 12',  'en', NULL
-- ===============================================================================================================
CREATE   PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_SET_TEMP] (
	@langId NVARCHAR(50),
	@idfEmployeeGroup BIGINT,
	@idfsSite BIGINT,
	@strDefault NVARCHAR(200),
	@strName NVARCHAR(200),
	@strDescription NVARCHAR(200),
	@strEmployees NVARCHAR(MAX), -- Comma seperated list of employees or user groups to be deleted as BIGINT
	@rolesandfunctions NVARCHAR(MAX),
	@roleID BIGINT,
	@strDashboardObject NVARCHAR(1000),
	@user NVARCHAR(50)
	)
AS
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(50) = 'SUCCESS'
DECLARE @idfsEmployeeGroupName BIGINT
DECLARE @idfEmployee BIGINT
DECLARE @SupressSelect TABLE (
	retrunCode INT,
	returnMessage VARCHAR(200)
	)
DECLARE @existingDefault BIGINT
DECLARE @existingName BIGINT

BEGIN
	BEGIN TRY
		SELECT @existingDefault = (
				SELECT TOP 1 idfsReference
				FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000022)
				WHERE strDefault = @strDefault
				)

		SELECT @existingName = (
				SELECT TOP 1 idfsReference
				FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000022)
				WHERE [name] = @strName
				)

		IF (
				@existingDefault IS NOT NULL
				OR @existingName IS NOT NULL
				)
			SELECT @idfsEmployeeGroupName = (
					SELECT TOP 1 idfsEmployeeGroupName
					FROM dbo.tlbEmployeeGroup
					WHERE idfsEmployeeGroupName IN (
							@existingDefault,
							@existingName
							)
					)

		IF (
				@existingDefault IS NOT NULL
				AND @existingDefault <> @idfsEmployeeGroupName
				AND @idfsEmployeeGroupName IS NOT NULL
				)
			OR (
				@existingDefault IS NOT NULL
				AND @idfsEmployeeGroupName IS NULL
				)
			OR (
				@existingName IS NOT NULL
				AND @existingName <> @idfsEmployeeGroupName
				AND @idfsEmployeeGroupName IS NOT NULL
				)
			OR (
				@existingName IS NOT NULL
				AND @idfEmployeeGroup IS NULL
				)
		BEGIN
			SELECT @idfEmployeeGroup = (
					SELECT TOP 1 idfEmployeeGroup
					FROM dbo.tlbEmployeeGroup
					WHERE strName = @strName
					)

			SELECT @returnMsg = 'DOES EXIST'
		END
		ELSE IF @idfEmployeeGroup IS NOT NULL
		BEGIN
			SELECT @idfsEmployeeGroupName = (
					SELECT idfsEmployeeGroupName
					FROM dbo.tlbEmployeeGroup
					WHERE idfEmployeeGroup = @idfEmployeeGroup
					)

			UPDATE dbo.trtBaseReference
			SET strDefault = @strDefault
			WHERE idfsBaseReference = @idfsEmployeeGroupName

			UPDATE dbo.tlbEmployeeGroup
			SET strName = @strDefault,
				strDescription = @strDescription
			WHERE idfEmployeeGroup = @idfEmployeeGroup
		END
		ELSE
		BEGIN
			SET @idfEmployeeGroup = (
					SELECT MIN(idfEmployee) - 1
					FROM dbo.tlbEmployee
					)
			
			--INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_BaseReference_SET
				@ReferenceID=@idfsEmployeeGroupName OUTPUT, 
				@ReferenceType=19000022, 
				@LangID=@LangID, 
				@DefaultName=@strDefault, 
				@NationalName=@strName, 
				@HACode=226, 
				@Order=0, 
				@System=0;

			INSERT INTO dbo.tlbEmployee (
				idfEmployee,
				idfsEmployeeType,
				idfsSite,
				intRowStatus
				)
			VALUES (
				@idfEmployeeGroup,
				10023001,
				@idfsSite,
				0
				)

			INSERT INTO dbo.tlbEmployeeGroup (
				idfEmployeeGroup,
				idfsEmployeeGroupName,
				idfsSite,
				strName,
				strDescription,
				intRowStatus
				)
			VALUES (
				@idfEmployeeGroup,
				@idfsEmployeeGroupName,
				@idfsSite,
				@strName,
				@strDescription,
				0
				)
		END

		-- Call USP_ADMIN_USERGROUPTOEMPLOYEE_SET
		EXEC USP_ADMIN_USERGROUPTOEMPLOYEE_SET @idfEmployeeGroup, @strEmployees,@user

		--Call USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
		EXEC USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET @rolesandfunctions,@user

		--Call  USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
		EXEC USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET @roleID,@strDashboardObject, @user

		SELECT @returnCode 'ReturnCode',
			@returnMsg 'ReturnMessage',
			@idfEmployeeGroup 'idfEmployeeGroup',
			@idfsEmployeeGroupName 'idfsEmployeeGroupName'
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END

		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage;
	END CATCH
END
