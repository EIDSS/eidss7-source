

-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEE_TO_EMPLOYEEGROUP_SET
--
-- Description: Insert/update an employee's group memberships (roles).
--          
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- -- Testing code: exec USP_ADMIN_EMPLOYEE_GROUP_SET '-538,-537,-536,-511,-501',-430
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEE_TO_EMPLOYEEGROUP_SET] (
	@idfEmployeeGroups NVARCHAR(MAX), -- Comma seperated list of employee groups 
	@idfEmployee BIGINT

	)
AS
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
DECLARE @NewEmployeeGroups TABLE  (idfEmployeeGroup BIGINT)

BEGIN
	BEGIN TRY
		INSERT INTO @NewEmployeeGroups
		SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@idfEmployeeGroups,0,',')

		DECLARE @CurrentEmployeeGroups TABLE  (idfEmployeeGroup BIGINT)
		INSERT INTO @CurrentEmployeeGroups
		SELECT 
			idfEmployeeGroup
		FROM dbo.tlbEmployeeGroupMember
		WHERE idfEmployee = @idfEmployee
		AND intRowStatus = 0

		--
		-- remove any employee groups not in the list
		UPDATE dbo.tlbEmployeeGroupMember
		SET intRowStatus = 1
		WHERE idfEmployee = @idfEmployee
		AND idfEmployeeGroup IN (SELECT * FROM @CurrentEmployeeGroups)
		AND idfEmployeeGroup NOT IN (SELECT * FROM @NewEmployeeGroups)
		AND intRowStatus = 0

		-- insert new employee groups
		INSERT INTO dbo.tlbEmployeeGroupMember
		(
			idfEmployeeGroup,
			idfEmployee,
			intRowStatus,
			rowguid,
			strMaintenanceFlag,
			strReservedAttribute,
			SourceSystemNameID,
			SourceSystemKeyValue,
			AuditCreateUser,
			AuditCreateDTM,
			AuditUpdateUser,
			AuditUpdateDTM
		)
		SELECT 
			G.idfEmployeeGroup,
			@idfEmployee,
			0,
			NEWID(),
			NULL,
			NULL,
			10519001,
			NULL,
			'System',
			GETDATE(),
			'System',
			GETDATE()
		FROM @NewEmployeeGroups G
		WHERE G.idfEmployeeGroup NOT IN (SELECT idfEmployeeGroup FROM dbo.tlbEmployeeGroupMember WHERE idfEmployee = @idfEmployee)

		--
		-- update previously deleted groups
		UPDATE dbo.tlbEmployeeGroupMember
		SET intRowStatus = 0,
			AuditUpdateDTM = GETDATE() 

		WHERE idfEmployeeGroup IN (SELECT * FROM @NewEmployeeGroups)
		AND idfEmployee = @idfEmployee
		AND intRowStatus = 1

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END TRY

	BEGIN CATCH
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + 
						 ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + 
						 ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + 
						 ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + 
						 CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE()
		SET @returnCode = ERROR_NUMBER()

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage
	END CATCH
END


