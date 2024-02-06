


-- ================================================================================================
-- Name: USP_ADMIN_USR_GROUPMEMBER_SET
--
-- Description: Insert/update an employee's group memberships (roles).
--          
-- Author: Maheshwar Deo
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    10/03/2019 Added intRowStatus parameter.
-- Steven Verner   12/10/2019 Modified to accept an array of roles (@idfEmployeeGroups)	as a comma seperated list!
-- Ann Xiong       10/09/2020 Modified to fix the FOREIGN KEY constraint conflict error when pass '' as @idfEmployeeGroups
-- Jason Li		   10/22/2020 Modified to fix Not delete on unsiged user groups 
-- Mark Wilson	   10/28/2020 rewrote to make more universal 
--
-- Testing code: 
/*
	EXEC USP_ADMIN_USR_GROUPMEMBER_SET '-509',-428, 0
	EXEC USP_ADMIN_USR_GROUPMEMBER_SET '-538,-537,-536,-511,-501', -430

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_USR_GROUPMEMBER_SET] (
	@idfEmployeeGroups VARCHAR(1000), -- Comma seperated list of roles as BIGINT
	@idfEmployee BIGINT, -- required for insert
	@intRowStatus INT = 0
	)
AS
DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
DECLARE @NewEmployeeGroups TABLE  (idfEmployeeGroup BIGINT)
DECLARE @CurrentEmployeeGroups TABLE  (idfEmployeeGroup BIGINT)

BEGIN
	BEGIN TRY
		INSERT INTO @NewEmployeeGroups
		SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@idfEmployeeGroups,0,',')

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


