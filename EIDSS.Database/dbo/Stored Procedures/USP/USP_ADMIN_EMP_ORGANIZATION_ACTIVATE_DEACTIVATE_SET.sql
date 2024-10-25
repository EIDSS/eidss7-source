
-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_STATUS_SET		
-- 
-- Description:  Delete an employee's organization by updating intRowStatus in tlbEmployee and child tables such as tlbPerson, tlbEMployeeGroupMemeber, tlbEmployeeTo Institution, tstUserTable to 1.
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Minal Shah     		08/20/2021	Initial release.

--
-- Testing Code:
-- EXEC [USP_ADMIN_EMP_ORGANIZATION_ACTIVATE_DEACTIVATE_SET] -294, 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_ACTIVATE_DEACTIVATE_SET]
( 
	@idfPerson	BIGINT =NULL
	,@active 	BIT = 0
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS'
	DECLARE @returnCode BIGINT = 0 
	DECLARE @idfUserID BIGINT

	BEGIN TRY  	
	BEGIN TRANSACTION
			UPDATE	EmployeeToInstitution 
			SET		Active = @active 
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
