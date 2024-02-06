
-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_DEL	
-- 
-- Description: Delete organization from table EmployeeToInstitution.
--
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     		08/28/2020 	Initial release.
-- Ann Xiong     		09/15/2020 	Change Delete statements to update intRowStatus to 1
-- Ann Xiong     		10/09/2020  Changed from soft delete to hard delete
--
-- Testing Code:
-- EXEC USP_ADMIN_EMP_ORGANIZATION_DEL 14, 13
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_DEL]
( 
	@aspNetUserId NVARCHAR(128),
	@idfUserId BIGINT
)
AS
BEGIN
	DECLARE @returnMsg 	VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode 	BIGINT = 0;

	BEGIN TRY  
		BEGIN TRANSACTION

			DELETE 
			FROM	dbo.EmployeeToInstitution
			WHERE  	aspNetUserId = @aspNetUserId AND idfUserId = @idfUserId 

		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage
	END TRY  

	BEGIN CATCH  

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK

				SET @returnCode = ERROR_NUMBER();
				SET @returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()

				SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage
			END

	END CATCH; 
END





