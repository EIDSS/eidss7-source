-- =============================================
-- Author:		Steven Verner
-- Create date: 02/28/2022
-- Description:	Inserts update events in the tauDataAuditDetailUpdate table.
-- =============================================
CREATE PROCEDURE USP_GBL_DataAuditEvent_Update
	-- Add the parameters for the stored procedure here
	 @idfUserID BIGINT
	,@JSONUpdates NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @returnMsg					VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode					BIGINT = 0;
	DECLARE @event BIGINT 

	BEGIN TRY
		-- If the json object is null, there's nothing to do...
		IF(@JSONUpdates IS NULL ) RETURN 0

		-- Get the current event id for this user from the local context table...
		EXEC USSP_GBL_DataAuditEvent_GET @idfUserID, @event OUTPUT
	
		-- insert the update records to the data audit update table...
		INSERT INTO tauDataAuditDetailUpdate(idfDataAuditEvent,idfObjectTable, idfColumn,idfObject,idfObjectDetail, strNewValue )
		SELECT @event, idfObjectTable,idfColumn,idfObject,idfObjectDetail, strValue
		FROM OPENJSON(@JSONUpdates)
		WITH(
			idfObjectTable BIGINT,
			idfColumn BIGINT,
			idfObject BIGINT,
			idfObjectDetail BIGINT,
			strValue NVARCHAR(4000) )

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
