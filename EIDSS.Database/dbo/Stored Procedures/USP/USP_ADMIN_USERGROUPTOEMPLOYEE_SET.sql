
-- ================================================================================================
-- Name: USP_ADMIN_USERGROUPTOEMPLOYEE_SET

-- Description: Assign employee or an existing user group to the  user group.

-- Author: Ricky Moss
--
-- Change Log:
--
-- Name					Date       Change
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss			12/02/2019 Initial release
-- Ricky Moss			12/12/2019 Data type change of idfEmployeeGroup parameter.
-- Ann Xiong			06/18/2021 Modified to return ReturnCode and ReturnMessage	
-- Ann Xiong			03/21/2021 Modified to delete employees from the tlbEmployeeGroupMember table if those employees exist in the tlbEmployeeGroupMember table but not in @strEmployees		
-- Ann Xiong			04/25/2023 Implemented Data Audit and added parameter @idfDataAuditEvent	
-- 
-- Testing Code:
-- exec USP_ADMIN_USERGROUPTOEMPLOYEE_SET -497, '-452,-508', NULL
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_USERGROUPTOEMPLOYEE_SET] (
	@idfEmployeeGroup BIGINT,
	@strEmployees NVARCHAR(MAX), -- Comma seperated list of employees or user groups to be deleted as BIGINT
	@idfDataAuditEvent BIGINT = NULL,
	@user NVARCHAR(50)
	)
AS
DECLARE @returnCode INT = 0,
	@returnMessage VARCHAR(MAX) = 'SUCCESS';

DECLARE @tempEmployeeList TABLE (idfEmployee  BIGINT NOT NULL);
DECLARE @idfEmployee BIGINT;
DECLARE @tempEmployeeListToDelete TABLE (idfEmployee  BIGINT NOT NULL);
DECLARE @tempEmployeeListOld TABLE (idfEmployee  BIGINT NOT NULL);

		--Data Audit--
		DECLARE @idfUserId BIGINT = NULL;
		DECLARE @idfSiteId BIGINT = NULL;
		DECLARE @idfsDataAuditEventType bigint = NULL;
		DECLARE @idfsObjectType bigint = 10017058; 					-- User Group --
		DECLARE @idfObject bigint = @idfEmployeeGroup;
		DECLARE @idfObjectTable_tlbEmployeeGroupMember bigint = 75540000000;
		--DECLARE @idfDataAuditEvent BIGINT = NULL;

		-- Get and Set UserId and SiteId
		SELECT @idfUserId = userInfo.UserId, @idfSiteId = UserInfo.SiteId FROM dbo.FN_UserSiteInformation(@user) userInfo
		--Data Audit--

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF COALESCE(@strEmployees, '') = ''
				Set @strEmployees = null

			INSERT @tempEmployeeList
			SELECT VALUE AS idfEmployee
			FROM STRING_SPLIT(@strEmployees, ',');

			INSERT @tempEmployeeListOld
			SELECT idfEmployee
			FROM dbo.tlbEmployeeGroupMember
			WHERE idfEmployeeGroup = @idfEmployeeGroup AND intRowStatus = 0;

			INSERT @tempEmployeeListToDelete
			SELECT idfEmployee
			FROM @tempEmployeeListOld
			WHERE idfEmployee NOT IN ( SELECT idfEmployee FROM @tempEmployeeList);

			-- Delete employees from the tlbEmployeeGroupMember table if those employees exist in the tlbEmployeeGroupMember table but not in @strEmployees		
			WHILE (SELECT COUNT(*) FROM @tempEmployeeListToDelete) > 0
			BEGIN
				SET @idfEmployee = (SELECT TOP 1 idfEmployee FROM @tempEmployeeListToDelete)
					BEGIN
						UPDATE dbo.tlbEmployeeGroupMember
						SET intRowStatus = 1
						WHERE idfEmployeeGroup = @idfEmployeeGroup
						AND idfEmployee = @idfEmployee

        				IF @idfDataAuditEvent IS NOT NULL
        				BEGIN 
						--Data Audit--
						INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
							SELECT @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroupMember, @idfEmployeeGroup, @idfEmployee
						--Data Audit--
						END
					END
				DELETE FROM @tempEmployeeListToDelete WHERE idfEmployee = @idfEmployee
			END

			WHILE (SELECT COUNT(*) FROM @tempEmployeeList) > 0
			BEGIN
				SET @idfEmployee = (SELECT TOP 1 idfEmployee FROM @tempEmployeeList)

				-- Validate if employee is not already part of the current user group
				IF NOT EXISTS (
								SELECT * FROM dbo.tlbEmployeeGroupMember 
								WHERE idfEmployeeGroup = @idfEmployeeGroup
								AND idfEmployee = @idfEmployee
							)
					BEGIN
						-- If employee is not already a part of user group, insert a new record 
						INSERT INTO dbo.tlbEmployeeGroupMember
						(
							idfEmployeeGroup,
							idfEmployee,
							intRowStatus,
							rowguid
						)
						VALUES (
							@idfEmployeeGroup,
							@idfEmployee,
							0,
							NEWID()
							);

        				IF @idfDataAuditEvent IS NOT NULL
        				BEGIN 
						--Data Audit--
						INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
									values ( @idfDataAuditEvent, @idfObjectTable_tlbEmployeeGroupMember, @idfEmployeeGroup, @idfEmployee)
						--Data Audit--
						END
					END
				ELSE IF EXISTS (
								SELECT * FROM dbo.tlbEmployeeGroupMember 
								WHERE idfEmployeeGroup = @idfEmployeeGroup
								AND idfEmployee = @idfEmployee
							)
					-- If employee is already part of the user group, make membership 'active'
					BEGIN
						--Data Audit--
						DECLARE @intRowStatusOld INT = NULL;
 						SELECT @intRowStatusOld = intRowStatus FROM dbo.tlbEmployeeGroupMember WHERE idfEmployeeGroup = @idfEmployeeGroup AND idfEmployee = @idfEmployee;
 						--Data Audit--

						UPDATE dbo.tlbEmployeeGroupMember
						SET intRowStatus = 0
						WHERE idfEmployeeGroup = @idfEmployeeGroup
						AND idfEmployee = @idfEmployee

        				IF @idfDataAuditEvent IS NOT NULL
        				BEGIN 
						--Data Audit--
						insert into dbo.tauDataAuditDetailUpdate(
									idfDataAuditEvent, idfObjectTable, idfColumn, 
									idfObject, idfObjectDetail, 
									strOldValue, strNewValue)
						select		@idfDataAuditEvent,@idfObjectTable_tlbEmployeeGroupMember, 51586990000121,
									@idfEmployeeGroup,@idfEmployee,
									@intRowStatusOld,0
						WHERE		(@intRowStatusOld <> 0)
						--Data Audit--
						END
					END

				-- Delete record processed from the temporary table
				DELETE FROM @tempEmployeeList WHERE idfEmployee = @idfEmployee
			END

			IF @@TRANCOUNT > 0 
			  COMMIT

			SELECT @returnCode AS 'ReturnCode',	@returnMessage AS 'ReturnMessage';

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END

		SET @returnMessage = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();
		SET @returnCode = ERROR_NUMBER();

		SELECT @returnCode AS ReturnCode, @returnMessage AS ReturnMessage;
	END CATCH
END