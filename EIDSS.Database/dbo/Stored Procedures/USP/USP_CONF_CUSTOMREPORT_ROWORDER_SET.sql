-- =========================================================================================
-- NAME: USP_CONF_CUSTOMREPORT_ROWORDER_SET
-- DESCRIPTION: Saves a series of row orders when moving rows around in the custom report matrix

-- AUTHOR: Mike Kornegay	

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Mike Kornegay	08/18/2021	Initial Release
--
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_CUSTOMREPORT_ROWORDER_SET]
(
	@rows AS UDT_RowOrder READONLY
)
AS
DECLARE @returnCode					INT = 0  
DECLARE	@returnMsg					NVARCHAR(max) = 'SUCCESS' 
DECLARE @SupressSelect TABLE (returnCode INT, returnMessage VARCHAR(200))
BEGIN TRY
	BEGIN
		UPDATE	trtReportRows
		SET		intRowOrder = r.RowOrder
		FROM	@rows r
		WHERE	idfReportRows = r.KeyId
				
	END
		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
END TRY
BEGIN CATCH
	THROW;
END CATCH


