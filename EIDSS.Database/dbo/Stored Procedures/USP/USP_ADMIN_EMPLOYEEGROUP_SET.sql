-- ===============================================================================================================
-- Name: USP_ADMIN_EMPLOYEEGROUP_SET
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
-- Ann Xiong			02/23/2023 Fixed the issue "Subquery returned more than 1 value".
-- Ann Xiong			02/28/2023 Implemented Data Audit
-- Ann Xiong			03/01/2023 Fixed the issue of National Name not saved
-- Ann Xiong			04/25/2023	Added parameters @strEmployees, @rolesandfunctions, @strDashboardObject
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET -500, 1, 'Test 1204-7', 'Test 1204-7', 'Test Role on December 4',  'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET NULL, 1, 'Test 1205', 'Test 1205', 'Test Role on December 5',  'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_SET NULL, 1, 'Test 1212-1', 'Test 1212-1', 'Test Role on December 12',  'en', NULL
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_SET] (
	@idfEmployeeGroup BIGINT,
	@idfsSite BIGINT,
	@strDefault NVARCHAR(200),
	@strName NVARCHAR(200),
	@strDescription NVARCHAR(200),
	@langId NVARCHAR(50),
	@strEmployees NVARCHAR(MAX) = NULL, -- Comma seperated list of employees or user groups to be deleted as BIGINT
	@rolesandfunctions NVARCHAR(MAX) = NULL,
	@strDashboardObject NVARCHAR(1000) = NULL,
	@user NVARCHAR(200)
	)
AS
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(50) = 'SUCCESS'
DECLARE @idfsEmployeeGroupName BIGINT
DECLARE @idfEmployee BIGINT
DECLARE @SupressSelect TABLE (
	ReturnCode INT,
	ReturnMessage VARCHAR(200)
	)
DECLARE @existingDefault BIGINT
DECLARE @existingName BIGINT

		--Data Audit--
		declare @idfUserId BIGINT = NULL;
		declare @idfSiteId BIGINT = NULL;
		declare @idfsDataAuditEventType bigint = NULL;
		declare @idfsObjectType bigint = 10017058;                         -- User Group
		declare @idfObject bigint = @idfEmployeeGroup;
		declare @idfDataAuditEvent bigint= NULL;
		declare @idfObjectTable_tlbEmployee bigint = 75520000000;
		declare @idfObjectTable_tlbEmployeeGroup bigint = 75530000000;
		declare @idfObjectTable_trtBaseReference BIGINT = 75820000000;

		DECLARE @tlbEmployeeGroup_BeforeEdit TABLE
		(
			EmployeeGroupID BIGINT,
			strName varchar(200),
			strDescription varchar(200)
		);
		DECLARE @tlbEmployeeGroup_AfterEdit TABLE
		(
			EmployeeGroupID BIGINT,
			strName varchar(200),
			strDescription varchar(200)
		);
		DECLARE @trtBaseReference_BeforeEdit TABLE
		(
    		BaseReferenceID BIGINT,
    		DefaultValue NVARCHAR(2000)
		);
		DECLARE @trtBaseReference_AfterEdit TABLE
		(
    		BaseReferenceID BIGINT,
    		DefaultValue NVARCHAR(2000)
		);

		-- Get and Set UserId and SiteId
		select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@user) userInfo

		--Data Audit--

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

            -- Data audit
            INSERT INTO @trtBaseReference_BeforeEdit
            (
                BaseReferenceID,
                DefaultValue
            )
            SELECT idfsBaseReference,
                   strDefault
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @idfsEmployeeGroupName
            -- End data audit

			UPDATE dbo.trtBaseReference
			SET strDefault = @strDefault
			WHERE idfsBaseReference = @idfsEmployeeGroupName

            -- Data audit
            INSERT INTO @trtBaseReference_AfterEdit
            (
                BaseReferenceID,
                DefaultValue
            )
            SELECT idfsBaseReference,
                   strDefault
            FROM dbo.trtBaseReference
            WHERE idfsBaseReference = @idfsEmployeeGroupName

			--  tauDataAuditEvent  Event Type- Edit 
			set @idfsDataAuditEventType =10016003;
			-- insert record into tauDataAuditEvent - 
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfEmployeeGroup, @idfObjectTable_tlbEmployeeGroup, @idfDataAuditEvent OUTPUT

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue
            )
            SELECT @idfDataAuditEvent,
                   @idfObjectTable_trtBaseReference,
                   81120000000,
                   a.BaseReferenceID,
                   NULL,
                   b.DefaultValue,
                   a.DefaultValue
            FROM @trtBaseReference_AfterEdit AS a
                FULL JOIN @trtBaseReference_BeforeEdit AS b
                    ON a.BaseReferenceID = b.BaseReferenceID
            WHERE (a.DefaultValue <> b.DefaultValue)
                  OR (
                         a.DefaultValue IS NOT NULL
                         AND b.DefaultValue IS NULL
                     )
                  OR (
                         a.DefaultValue IS NULL
                         AND b.DefaultValue IS NOT NULL
                     );
            -- Data audit

			-- Data audit
            INSERT INTO @tlbEmployeeGroup_BeforeEdit
            (
                        EmployeeGroupID,
                           strName,
                           strDescription
            )
            SELECT	idfEmployeeGroup,
                           strName,
                           strDescription
           FROM dbo.tlbEmployeeGroup
		   WHERE idfEmployeeGroup = @idfEmployeeGroup
           -- End data audit

			UPDATE dbo.tlbEmployeeGroup
			SET strName = @strName,
				strDescription = @strDescription
			WHERE idfEmployeeGroup = @idfEmployeeGroup

			-- Data audit
            INSERT INTO @tlbEmployeeGroup_AfterEdit
            (
                        EmployeeGroupID,
                           strName,
                           strDescription
            )
            SELECT	idfEmployeeGroup,
                           strName,
                           strDescription
           FROM dbo.tlbEmployeeGroup
		   WHERE idfEmployeeGroup = @idfEmployeeGroup

		   insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbEmployeeGroup, 78710000000,
					a.EmployeeGroupID,null,
					a.strName,b.strName
			from @tlbEmployeeGroup_BeforeEdit a  inner join @tlbEmployeeGroup_AfterEdit b on a.EmployeeGroupID = b.EmployeeGroupID
			where (a.strName <> b.strName) 
					or(a.strName is not null and b.strName is null)
					or(a.strName is null and b.strName is not null)

			insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbEmployeeGroup, 78700000000,
					a.EmployeeGroupID,null,
					a.strDescription,b.strDescription
			from @tlbEmployeeGroup_BeforeEdit a  inner join @tlbEmployeeGroup_AfterEdit b on a.EmployeeGroupID = b.EmployeeGroupID
			where (a.strDescription <> b.strDescription) 
					or(a.strDescription is not null and b.strDescription is null)
					or(a.strDescription is null and b.strDescription is not null)

			--Data Audit--
		END
		ELSE
		BEGIN
			SET @idfEmployeeGroup = (
					SELECT MIN(idfEmployee) - 1
					FROM dbo.tlbEmployee
					)

			--Data Audit--
			-- tauDataAuditEvent Event Type - Create 
			set @idfsDataAuditEventType =10016001;
			-- insert record into tauDataAuditEvent - 
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfEmployeeGroup, @idfObjectTable_tlbEmployeeGroup, @idfDataAuditEvent OUTPUT
			--Data Audit--
			
			--INSERT INTO @SupressSelect
			--EXEC dbo.USP_GBL_BaseReference_SET
			--	@ReferenceID=@idfsEmployeeGroupName OUTPUT, 
			--	@ReferenceType=19000022, 
			--	@LangID=@LangID, 
			--	@DefaultName=@strDefault, 
			--	@NationalName=@strName, 
			--	@HACode=226, 
			--	@Order=0, 
			--	@System=0;

            EXECUTE dbo.USSP_GBL_BASE_REFERENCE_SET @idfsEmployeeGroupName OUTPUT,
                                                        19000022,
                                                        @LangID,
                                                        @strDefault,
                                                        @strName,
                                                        226,
                                                        0,
                                                        0,
                                                        @User,
                                                        @idfDataAuditEvent,
                                                        NULL;

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

			--Data Audit--
			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployee, @idfEmployeeGroup)
			--Data Audit--

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

			--Data Audit--
			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
						values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroup, @idfEmployeeGroup)
			--Data Audit--

			DECLARE @tempRSFA TABLE (
				RoleId BIGINT,
				SystemFunction BIGINT,
				Operation BIGINT,
				intRowStatus INT,
				intRowStatusForSystemFunction INT
				)

			INSERT INTO @tempRSFA
			SELECT *
			FROM OPENJSON(@rolesandfunctions) WITH (
				RoleId BIGINT,
				SystemFunction BIGINT,
				Operation BIGINT,
				intRowStatus INT,
				intRowStatusForSystemFunction INT
				)

            UPDATE @tempRSFA
            SET RoleId = @idfEmployeeGroup;

			SET @rolesandfunctions =
			(
				SELECT 
					RoleId,
					SystemFunction,
					Operation,
					intRowStatus,
					intRowStatusForSystemFunction
				FROM @tempRSFA
				FOR JSON PATH);
		END

		-- Call USP_ADMIN_USERGROUPTOEMPLOYEE_SET
		IF @strEmployees IS NOT NULL AND @strEmployees <> ''
		BEGIN
		INSERT INTO @SupressSelect
		EXEC dbo.USP_ADMIN_USERGROUPTOEMPLOYEE_SET
			@idfEmployeeGroup = @idfEmployeeGroup,
			@strEmployees = @strEmployees,
			@idfDataAuditEvent = @idfDataAuditEvent,
			@user = @user
		END

		--Call  USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
		IF @strDashboardObject IS NOT NULL
		BEGIN
		INSERT INTO @SupressSelect
		EXEC dbo.USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SET
			@roleID = @idfEmployeeGroup,
			@strDashboardObject = @strDashboardObject,
			@idfDataAuditEvent = @idfDataAuditEvent,
			@user = @user
		END

		--Call USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
		IF @rolesandfunctions IS NOT NULL
		BEGIN
		INSERT INTO @SupressSelect
			EXEC dbo.USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SET
				@rolesandfunctions = @rolesandfunctions,
				@idfDataAuditEvent = @idfDataAuditEvent,
				@user = @user
		END

		SELECT @returnCode 'ReturnCode',
			@returnMsg 'ReturnMessage',
			@idfEmployeeGroup 'idfEmployeeGroup',
			@idfsEmployeeGroupName 'idfsEmployeeGroupName'
	END TRY

	BEGIN CATCH
		THROW
	END CATCH
END