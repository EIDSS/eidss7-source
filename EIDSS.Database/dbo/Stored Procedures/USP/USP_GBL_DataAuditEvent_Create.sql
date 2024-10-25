-- =============================================
-- Author:		Steven Verner
-- Create date: 02/28/2022
-- Description:	Creates the "Create" audit event.  This SP is called when a new record is created in any table that being tracked for auditing
-- =============================================
CREATE PROCEDURE [dbo].[USP_GBL_DataAuditEvent_Create] 
	-- Add the parameters for the stored procedure here
	 @idfDataAuditEvent BIGINT
	,@idfObjectTable BIGINT
	,@idfObject BIGINT
	,@idfObjectDetail BIGINT 
AS
BEGIN
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;

	SET NOCOUNT ON;

	BEGIN TRY
	
		INSERT INTO dbo.tauDataAuditDetailCreate( idfDataAuditEvent, idfObjectTable, 
			idfObject, idfObjectDetail)
		VALUES( @idfDataAuditEvent,@idfObjectTable,@idfObject,@idfObjectDetail )

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage';
	END TRY
	BEGIN CATCH
		SET @returnCode = ERROR_NUMBER()
		SET @returnMsg = 
		'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
		+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
		+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
		+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
		+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
		+ ' ErrorMessage: '+ ERROR_MESSAGE()

		SELECT @returnCode, @returnMsg
	END CATCH
END
