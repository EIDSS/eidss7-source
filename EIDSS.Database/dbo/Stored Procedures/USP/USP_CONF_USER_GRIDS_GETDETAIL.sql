-- =========================================================================================
-- NAME: [USP_CONF_USER_GRIDS_GETDETAIL]
-- DESCRIPTION: RETURNS Grid Configurations For Users
-- AUTHOR: LAMONT MITCHELL	

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- LAMONT MITCHELL	5/6/2022	Initial Release
--
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_USER_GRIDS_GETDETAIL]
(
	@idfUserID BIGINT,
	@GridID  Varchar(200) 
	
)
AS
DECLARE @returnCode					INT = 0  
DECLARE	@returnMsg					NVARCHAR(max) = 'SUCCESS' 
DECLARE @SupressSelect TABLE (returnCode INT, returnMessage VARCHAR(200))
BEGIN TRY
	BEGIN
	
			SELECT
			  [idfUserID], [idfsSite], [ColumnDefinition], [GridID], [rowguid], [intRowStatus]
			  FROM 
			  [dbo].[tlbGridDefinition]  WHERE 
			 [idfUserID] = @idfUserID AND GridID = @GridID AND intRowStatus = 0
				
	END
		
END TRY
BEGIN CATCH
	THROW;
END CATCH


