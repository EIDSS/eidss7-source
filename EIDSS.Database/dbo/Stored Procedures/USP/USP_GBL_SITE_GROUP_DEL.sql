-- ================================================================================================
-- Name: USP_GBL_SITE_GROUP_DEL
--
-- Description:	Sets a site group record to "inactive".
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/02/2019 Initial release.
-- Stephen Long     06/19/2021 Cleaned up formatting of stored procedure.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_SITE_GROUP_DEL] (
	@LanguageID NVARCHAR(50) = NULL
	,@SiteGroupID BIGINT
	,@UserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnCode INT = 0
			,@ReturnMessage NVARCHAR(MAX) = 'SUCCESS'
			,@SiteCount AS INT = 0;

		BEGIN TRANSACTION;

		SELECT @SiteCount = COUNT(*)
		FROM dbo.tflSiteToSiteGroup
		WHERE idfSiteGroup = @SiteGroupID;

		IF @SiteCount = 0
		BEGIN
			UPDATE dbo.tflSiteGroup
			SET intRowStatus = 1
				,AuditUpdateDTM = GETDATE()
			WHERE idfSiteGroup = @SiteGroupID;
		END
		ELSE
		BEGIN
			SET @ReturnCode = 1;
			SET @ReturnMessage = 'Unable to delete this record as it contains dependent child objects.';
		END;

		IF @@TRANCOUNT > 0
			AND @ReturnCode = 0
			COMMIT;

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage;

		THROW;
	END CATCH
END
