-- =============================================
-- Author:		Steven Verner
-- Create date: 02/28/2022
-- Description:	
-- Create an entry into the tauDataAuditDetailCreate table if one doesn't exist or updates an audit 
-- event in the tauDataAuditDetailUpdate table.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GBL_DataAuditEvent_SET]
	-- Add the parameters for the stored procedure here
	 @userName nvarchar(2576)
	,@idfSiteId  BIGINT =NULL
	,@JSONUpdates NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @idfDataAuditEvent BIGINT 
	DECLARE @returnMsg	VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode	BIGINT = 0;
	DECLARE @idfUserID BIGINT
	DECLARE @siteID BIGINT 
	DECLARE @strValue SQL_VARIANT
	DECLARE @strOldValue SQL_VARIANT
	DECLARE @ID INT 
	DECLARE @max INT
	DECLARE @idfsObjectType BIGINT
	DECLARE @idfsDataAuditEventType BIGINT
	DECLARE @idfObject BIGINT
	DECLARE @idfObjectTable BIGINT
	DECLARE @idfColumn BIGINT


	DECLARE @Input TABLE( 
		 ID INT IDENTITY(1,1)
		,idfsObjectType BIGINT	
		,idfsDataAuditEventType BIGINT
		,idfsObjectTable BIGINT
		,idfColumn BIGINT
		,idfObject BIGINT
		,idfObjectDetail BIGINT
		,strValue nvarchar(4000))

	BEGIN TRY

		SELECT @idfUserID = a.idfUserId, @siteID = lcc.idfsSite --, @event = lcc.idfDataAuditEvent
		FROM aspnetusers a 
		LEFT JOIN tstLocalConnectionContext lcc ON lcc.idfUserID = a.idfUserID
		WHERE a.username = @username

		-- If the json object is null, there's nothing to do...
		IF(@JSONUpdates IS NULL ) RETURN 0

		-- insert json
		INSERT INTO @input
		SELECT idfsObjectType, idfEventType, idfsObjectTable,idfColumn,idfObject,idfObjectDetail, AuditValue
		FROM OPENJSON(@JSONUpdates)
		WITH(
			idfsObjectType BIGINT,
			idfEventType BIGINT,
			idfsObjectTable BIGINT,
			idfColumn BIGINT,
			idfObject BIGINT,
			idfObjectDetail BIGINT,
			AuditValue NVARCHAR(4000) )

			select top 1 
			@idfsObjectType = idfsObjectType ,
			@idfsDataAuditEventType = idfsDataAuditEventType,
			@idfObjectTable=idfsObjectTable,
			@idfObject=idfObject
			from @input

		-- Get the current event id for this user from the local context table...
		EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@siteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable, @idfDataAuditEvent OUTPUT
		
		SET @ID = 1	
		SELECT @Max = COUNT(*) FROM @Input

		WHILE ( @ID <= @Max )
		BEGIN
			SELECT 
				 @idfsObjectType = idfsObjectType
				,@idfsDataAuditEventType = idfsDataAuditEventType
				,@idfObject = idfObject
				,@idfObjectTable = idfsObjectTable
				,@strValue = strValue
				,@idfColumn  = idfColumn
			FROM @Input
			WHERE ID =@ID
			
			IF @idfsDataAuditEventType = 10016001
			BEGIN
				-- Create the audit create record if it isn't already there...
				--IF( NOT EXISTS(
				--	SELECT idfDataAuditEvent 
				--	FROM tauDataAuditDetailCreate ac
				--	WHERE ac.idfDataAuditEvent = @idfDataAuditEvent AND ac.idfObjectTable = @idfObjectTable AND ac.idfObject = @idfObject))

					INSERT INTO dbo.tauDataAuditDetailCreate( idfDataAuditEvent, idfObjectTable, idfObject)
					VALUES( @idfDataAuditEvent, @idfObjectTable, @idfObject )
			END
			
			IF @idfsDataAuditEventType = 10016003
			BEGIN
				---- Old value...
				--SELECT TOP 1 @strOldValue = strNewValue
				--FROM tauDataAuditDetailUpdate 
				--WHERE idfObjectTable = @idfObjectTable AND idfObject = @idfObject AND IdfColumn = @idfColumn
				--ORDER BY AuditCreateDTM DESC

				-- Create the update record...
				INSERT INTO tauDataAuditDetailUpdate(idfDataAuditEvent,idfObjectTable, idfColumn,idfObject,strOldValue, strNewValue )
				VALUES(@idfDataAuditEvent,@idfObjectTable, @idfColumn, @idfObject, @strOldValue, @strValue)
			END

			SELECT @ID = @ID+1

		END

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