-- =========================================================================================
-- NAME: [USP_CONF_USER_GRIDS_SET]
-- DESCRIPTION: RETURNS Grid Configurations For Users
-- AUTHOR: LAMONT MITCHELL	

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- LAMONT MITCHELL	5/6/2022	Initial Release
--
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_USER_GRIDS_SET]
(
	@idfUserID BIGINT,
	@idfsSite  BIGINT, 
	@ColumnDefinition NVARCHAR(MAX), 
	@GridID NVARCHAR(200),
	@intRowStatus INT NULL
)
AS
DECLARE @returnCode					INT = 0  
DECLARE	@returnMsg					NVARCHAR(max) = 'SUCCESS' 
DECLARE @SupressSelect TABLE (returnCode INT, returnMessage VARCHAR(200))
DECLARE @idfGridId BIGINT
BEGIN TRY
	BEGIN
	IF EXISTS (SELECT * FROM [dbo].[tlbGridDefinition] WHERE GridID = @GridID AND idfUserID = @idfUserID)
		BEGIN
			
		UPDATE	[dbo].[tlbGridDefinition] 
		SET		intRowStatus = @intRowStatus,
				ColumnDefinition = @ColumnDefinition
		WHERE	GridID = @GridID

		END
	ELSE
		BEGIN
		EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbGridDefinition'
				,@idfGridId OUTPUT;
		
			INSERT INTO [dbo].[tlbGridDefinition]
			(
			 [idfGrid], [idfUserID], [idfsSite], [ColumnDefinition], [GridID], [rowguid], [intRowStatus]

			)
			VALUES
			(
			@idfGridId,@idfUserID, @idfsSite, @ColumnDefinition, @GridID, NEWID(), 1
			)
		END		
	END
		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
END TRY
BEGIN CATCH
		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = ERROR_MESSAGE();
		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
	--THROW;
END CATCH


