-- =============================================
-- Author:		Steven Verner
-- Create date: 03/02/2022
-- Description:	Inserts a delete event into the tauDataAuditDetailDelete table when a record is soft deleted
-- =============================================
CREATE PROCEDURE [dbo].[USP_GBL_DataAuditEvent_Delete] 
	-- Add the parameters for the stored procedure here
	 @userName nvarchar(256)
	,@JSONUpdates NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @idfUserID BIGINT
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	DECLARE @event BIGINT 
	DECLARE @Input TABLE(idfObjectTable bigint, idfColumn bigint, idfObject bigint, idfObjectDetail bigint, strValue nvarchar(4000))

	BEGIN TRY 

		SELECT @idfUserID = idfUserID FROM aspnetUsers WHERE username = @userName

		-- Get the current event id for this user from the local context table...
		EXEC USSP_GBL_DataAuditEvent_GET @idfUserID, @event OUTPUT

				-- insert json
		INSERT INTO @input
		SELECT idfObjectTable,idfColumn,idfObject,idfObjectDetail, strValue
		FROM OPENJSON(@JSONUpdates)
		WITH(
			idfObjectTable BIGINT,
			idfColumn BIGINT,
			idfObject BIGINT,
			idfObjectDetail BIGINT,
			strValue NVARCHAR(4000) )

		-- Insert statements for procedure here
		INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail )
		SELECT @event, i.idfObjectTable, i.idfObject, i.idfObjectDetail
		FROM @Input i 

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

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
	END CATCH
END
