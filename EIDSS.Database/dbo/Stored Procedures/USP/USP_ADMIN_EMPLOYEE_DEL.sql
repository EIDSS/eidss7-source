-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEE_DEL	
-- 
-- Description:  Delete an Employee record.
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     	09/25/2020 Initial release.
-- Ann Xiong     	10/29/2020 Modified to correctly delete Non-User Employee.
-- Stephen Long     07/05/2022 Corrected spelling of event subscription table, and corrected call 
--                             to event subscription soft-delete.
--
-- Testing Code:
-- EXEC USP_ADMIN_EMPLOYEE_DEL '14'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEE_DEL]
( 
		@idfPerson			BIGINT
)
AS
BEGIN
	DECLARE @returnMsg				NVARCHAR(MAX) = 'SUCCESS'
	DECLARE @returnCode				BIGINT = 0 
	DECLARE @aspNetUserId			NVARCHAR(128)
	DECLARE @idfsEmployeeCategory	BIGINT

	BEGIN TRY  	
	BEGIN TRANSACTION

	SELECT @idfsEmployeeCategory = (SELECT idfsEmployeeCategory FROM dbo.tlbEmployee  WHERE idfEmployee = @idfPerson)
	SELECT @aspNetUserId = (SELECT Id FROM dbo.AspNetUsers WHERE idfUserID = (SELECT idfUserID FROM dbo.tstUserTable WHERE idfPerson = @idfPerson))
	IF @aspNetUserId IS NOT NULL and @idfsEmployeeCategory = 10526001
	--Delete User Employee with multiple organizations
		BEGIN
			UPDATE	dbo.tlbPerson 
			SET		intRowStatus = 1 
			WHERE	idfPerson in 
					(	SELECT	ut.idfPerson 
						FROM	dbo.tstUserTable ut
								LEFT JOIN 	dbo.EmployeeToInstitution ei
								ON	ut.idfUserID = ei.idfUserID
						WHERE	ei.aspNetUserId = @aspNetUserId)

			UPDATE	dbo.tlbEmployee 
			SET		intRowStatus = 1 
			WHERE	idfEmployee in 
					(	SELECT	ut.idfPerson 
						FROM	dbo.tstUserTable ut
								LEFT JOIN 	dbo.EmployeeToInstitution ei
								ON	ut.idfUserID = ei.idfUserID
						WHERE	ei.aspNetUserId = @aspNetUserId)

			UPDATE	dbo.tlbEmployeeGroupMember 
			SET		intRowStatus = 1 
			WHERE	idfEmployee in 
					(	SELECT	ut.idfPerson 
						FROM	dbo.tstUserTable ut
								LEFT JOIN 	dbo.EmployeeToInstitution ei
								ON	ut.idfUserID = ei.idfUserID
						WHERE	ei.aspNetUserId = @aspNetUserId)

			UPDATE dbo.tstUserTable SET intRowStatus = 1 WHERE idfUserID in (SELECT idfUserID FROM dbo.EmployeeToInstitution where aspNetUserId = @aspNetUserId)

			UPDATE	dbo.EmployeeToInstitution 
			SET		intRowStatus = 1
			WHERE	aspNetUserId = @aspNetUserId

			UPDATE dbo.AspNetUsers SET blnDisabled = 1 WHERE Id = @aspNetUserId

			UPDATE dbo.EventSubscription SET intRowStatus = 1, AuditUpdateDTM = GETDATE() WHERE idfUserID IN (SELECT idfUserID FROM dbo.EmployeeToInstitution where aspNetUserId = @aspNetUserId)
		END
	ELSE
	--Delete Non-User Employee
		BEGIN
			UPDATE dbo.tlbPerson SET intRowStatus = 1 WHERE idfPerson = @idfPerson
			UPDATE dbo.tlbEmployee SET intRowStatus = 1 WHERE idfEmployee = @idfPerson
			UPDATE dbo.tstUserTable SET intRowStatus = 1 WHERE idfPerson = @idfPerson
			UPDATE dbo.EventSubscription SET intRowStatus = 1 WHERE idfUserId = @aspNetUserId
		END

		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
	END TRY  
	BEGIN CATCH 
		BEGIN
			SET	@returnCode = ERROR_NUMBER();
			SET	@returnMsg = 
						'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
						+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
						+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
						+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
						+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
						+ ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
		END
	END CATCH;
END
