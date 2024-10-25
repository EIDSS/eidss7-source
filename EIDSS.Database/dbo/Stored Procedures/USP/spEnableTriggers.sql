
--PRINT 'Created Stored procedure to Enable triggers and constraints.....'

CREATE PROCEDURE [dbo].[spEnableTriggers]
@returnMessage		NVARCHAR(MAX) OUTPUT,
@returnCode			BIGINT  OUTPUT
AS


BEGIN TRY
	DECLARE @TriggerName AS VARCHAR(500), @TableName AS VARCHAR(500)
 
	-- Cursor to disable all triggers in the source Database 

	DECLARE EnableSourceTriggerNConstraints CURSOR FOR
	  SELECT TRG.name AS TriggerName, TBL.NAME
	  FROM   sys.triggers TRG
			 INNER JOIN sys.tables TBL
					 ON TBL.OBJECT_ID = TRG.parent_id 
			 INNER JOIN sys.schemas schm 
					ON schm.schema_id = tbl.schema_id
	WHERE schm.name = 'dbo'

	OPEN EnableSourceTriggerNConstraints

	FETCH NEXT FROM EnableSourceTriggerNConstraints INTO @TriggerName,@TableName

	WHILE @@FETCH_STATUS = 0
	  BEGIN
		  DECLARE @SQL VARCHAR(MAX)=NULL
		  SET @SQL='ALTER TABLE ' + @TableName +  ' CHECK CONSTRAINT ALL'
		  EXEC (@SQL)
		  -- Disable the triggers
		  SET @SQL='ALTER TABLE ' + @TableName +  ' ENABLE TRIGGER ' + @TriggerName
		  EXEC (@SQL)
--		  PRINT @SQL
		  FETCH NEXT FROM EnableSourceTriggerNConstraints INTO @TriggerName, @TableName
	  END

	-- Close and disalloacte defined cursor 
	CLOSE EnableSourceTriggerNConstraints 
	DEALLOCATE EnableSourceTriggerNConstraints

SELECT @returnMessage = N'Success', @returnCode = 0

END TRY
BEGIN CATCH
	-- Close and disalloacte defined cursor 
	CLOSE DisableTargetTriggersNConstraints 
	DEALLOCATE DisableTargetTriggersNConstraints

	SET @returnCode = ERROR_NUMBER();
	SET @returnMessage = 
		N'ErrorNumber: ' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+ N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + COALESCE(ERROR_PROCEDURE(), N' spEnableTriggers')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();

	SELECT @returnCode, @returnMessage

END CATCH

GO


