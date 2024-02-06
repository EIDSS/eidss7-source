-- =============================================
-- Author:		Steven L. Verner
-- Create date: 11/12/2022
-- Description:	Adds an entry into the PIN audit table when a user attempts to access the PIN system.
-- =============================================
CREATE PROCEDURE USP_PIN_Audit_Set 
	-- Add the parameters for the stored procedure here
	 @strPIN CHAR(11)
	,@idfUser BIGINT = NULL
	,@idfsSite BIGINT = NULL
	,@idfHumanCase BIGINT = NULL
	,@idfH0Form BIGINT = NULL
	,@datEIDSSAccessAttempt DATETIME
	,@datPINAccessAttempt DATETIME 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
	 @ReturnMsg NVARCHAR(MAX) = 'SUCCESS'
	,@ReturnCode BIGINT = 0
	,@idfPINAudit BIGINT = 0

	BEGIN TRY	
			BEGIN TRANSACTION

			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tauPINAuditEvent'
				,@idfPINAudit OUTPUT;

			INSERT INTO tauPINAuditEvent (
				 idfPINAuditEvent
				,strPIN
				,idfUserID
				,idfsSite
				,idfHumanCase
				,idfH0Form
				,datEIDSSAccessAttempt
				,datPINAccessAttempt)
			VALUES (
				 @idfPINAudit
				,@strPIN
				,@idfUser
				,@idfsSite
				,@idfHumanCase
				,@idfH0Form
				,@datEIDSSAccessAttempt
				,@datPINAccessAttempt
			)
			
			IF @@TRANCOUNT > 0
			 COMMIT;
			
			SELECT @ReturnCode AS ReturnCode, @ReturnMsg AS ReturnMessage

    END TRY
    BEGIN CATCH
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + 
						 ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + 
						 ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + 
						 ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + 
						 CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE()
		SET @returnCode = ERROR_NUMBER()
		SELECT @ReturnCode AS ReturnCode, @ReturnMsg AS ReturnMessage
    END CATCH
END
GO
