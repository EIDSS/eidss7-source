
-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_STATUS_SET		
-- 
-- Description:  Delete an employee's organization by updating intRowStatus in tlbEmployee and child tables such as tlbPerson, tlbEMployeeGroupMemeber, tlbEmployeeTo Institution, tstUserTable to 1.
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     		09/15/2020	Initial release.
-- Ann Xiong     		09/15/2020	Updated	EmployeeToInstitution with the correct idfUserID
-- Minal Shah		    08/2-/2021 Changed the SP to update Active Flag 
--
-- Testing Code:
-- EXEC USP_ADMIN_EMP_ORGANIZATION_STATUS_SET -294, 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_STATUS_SET]
( 
	@idfPerson	BIGINT =NULL
	,@intRowStatus 	INT = 1
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS'
	DECLARE @returnCode BIGINT = 0 
	DECLARE @idfUserID BIGINT

	BEGIN TRY  	
	BEGIN TRANSACTION

		SELECT @idfUserID = (	SELECT idfUserID 
								FROM AspNetUsers 
								WHERE idfUserID = 
									(	SELECT ut.idfUserID 
										FROM	dbo.tstUserTable ut
												LEFT JOIN 	dbo.EmployeeToInstitution ei
												ON	ut.idfUserID = ei.idfUserID
										WHERE	ut.idfPerson  = @idfPerson
												AND ei.IsDefault = 1
									   )
				     )
	
		IF @idfUserID IS NOT NULL
		BEGIN
			SELECT @returnCode = @idfUserID
			SELECT @returnMsg = 'CANNOT delete the organization record that has “Default” flag selected'
		END
		ELSE
		BEGIN
			UPDATE tlbPerson SET intRowStatus = @intRowStatus WHERE idfPerson = @idfPerson
			UPDATE tlbEmployee SET intRowStatus = @intRowStatus WHERE idfEmployee = @idfPerson
			UPDATE tlbEmployeeGroupMember SET intRowStatus = @intRowStatus WHERE idfEmployee = @idfPerson
			UPDATE tstUserTable SET intRowStatus = @intRowStatus WHERE idfPerson = @idfPerson

			UPDATE	EmployeeToInstitution 
			SET		intRowStatus = @intRowStatus 
			WHERE	idfUserID = 
									(	SELECT ut.idfUserID 
										FROM	dbo.tstUserTable ut
												LEFT JOIN 	dbo.EmployeeToInstitution ei
												ON	ut.idfUserID = ei.idfUserID
										WHERE	ut.idfPerson  = @idfPerson
									   )
		--END

		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
		END
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
