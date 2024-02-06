
-- ================================================================================================
-- Name: [USP_ADMIN_CHILDTABLESUSAGE_GET]
--
-- Description: Get record count from referred Child Tables records based on Base Reference Key Field 
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Manickandan Govindarajan    09/10/2020 Initial release for new API.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_CHILDTABLESUSAGE_GET]
	@idfsBaseReference							BIGINT,
	@idfsReferenceType							BIGINT,
	@IsDesigning								BIT = 1
AS
	DECLARE 
	@strChildTableColumnName NVARCHAR(100),
	@RecCount INT = 0,
	@strSQLString NVARCHAR(MAX),
	@strTableName NVARCHAR(200),
	@strColumName NVARCHAR(200),
	@Result NVARCHAR(10),
	@returnMsg VARCHAR(MAX) = 'SUCCESS',
	@returnCode BIGINT = 0;
	DECLARE @SupressSelect TABLE (
		retrunCode INT,
		returnMessage VARCHAR(200)
		)
	
	SET NOCOUNT ON;

	BEGIN TRY

		-- FOR POCO GENERATION!!!
		IF @IsDesigning = 1
		BEGIN
			SET FMTONLY ON

			SELECT CAST('POCO' AS NVARCHAR(10)) AS asResult

			SET FMTONLY OFF

			GOTO WrapUp
		END

		IF OBJECT_ID('tempdb..#TempChildTableList') IS NOT NULL 
			DROP TABLE #TempChildTableList;

		SELECT @strChildTableColumnName = strChildTableColumnName FROM dbo.trtReferenceType
			WHERE idfsReferenceType = @idfsReferenceType

		SELECT 
			t.name as TableWithForeignKey, 
			c.name as ForeignKeyColumn 
		INTO #TempChildTableList
		FROM 
			sys.foreign_key_columns as fk
		INNER JOIN 
			sys.tables as t on fk.parent_object_id = t.object_id
		INNER JOIN
			sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
		WHERE 
			fk.referenced_object_id = (SELECT object_id 
									   FROM sys.tables 
									   WHERE name = 'trtBaseReference')
		AND c.name = @strChildTableColumnName
		ORDER BY
			TableWithForeignKey

		WHILE EXISTS (SELECT TableWithForeignKey FROM #TempChildTableList)
		BEGIN
			SELECT TOP 1 @strTableName = TableWithForeignKey,
						@strColumName = ForeignKeyColumn
			FROM #TempChildTableList

			SET @strSQLString = 'SELECT @RecCount = COUNT(*) FROM ' + @strTableName + ' WHERE ' + @strColumName + ' =  @idfsBaseReference and intRowStatus=0'

			EXECUTE sp_executesql @strSQLString, N'@idfsBaseReference BIGINT,@RecCount int OUTPUT', @idfsBaseReference = @idfsBaseReference, @RecCount= @RecCount OUTPUT

			IF @RecCount > 0 
				BEGIN
					PRINT 'Record can not be deleted'
					set @Result = 1 ;
					BREAK;
				END
			ELSE 
				set @Result = 0 ;
				set @strTableName='';

			DELETE TOP (1) FROM #TempChildTableList
		END

		select @Result as asResult

		--SELECT @returnCode,
		--	@returnMsg;

	END TRY

	BEGIN CATCH
		BEGIN
			SET @returnCode = ERROR_NUMBER();
			SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode,
				@returnMsg;
		END
	END CATCH

	IF OBJECT_ID('tempdb..#TempChildTableList') IS NOT NULL
		DROP TABLE #TempChildTableList;

	WrapUp:

	RETURN
