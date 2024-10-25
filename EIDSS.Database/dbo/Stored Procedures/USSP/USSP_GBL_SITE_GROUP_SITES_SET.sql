
-- ================================================================================================
-- Name: USSP_GBL_SITE_GROUP_SITES_SET
--
-- Description:	Inserts or updates sites for a site group.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/28/2019 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_SITE_GROUP_SITES_SET] (
	@LanguageID NVARCHAR(50),
	@SiteToSiteGroupID BIGINT OUTPUT,
	@SiteGroupID BIGINT,
	@SiteID BIGINT,
	@EIDSSSiteID NVARCHAR(100),
	@AuditUserName NVARCHAR(200),
	@RowAction CHAR(1)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @RowAction = 'I'
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tflSiteToSiteGroup',
				@SiteToSiteGroupID OUTPUT;

			INSERT INTO dbo.tflSiteToSiteGroup (
				idfSiteToSiteGroup,
				idfSiteGroup,
				idfsSite,
				strSiteID,
				AuditCreateDTM,
				AuditCreateUser
				)
			VALUES (
				@SiteToSiteGroupID,
				@SiteGroupID,
				@SiteID,
				@EIDSSSiteID,
				GETDATE(),
				@AuditUserName
				);
		END
		ELSE IF @RowAction = 'U'
		BEGIN
			UPDATE dbo.tflSiteToSiteGroup
			SET idfSiteGroup = @SiteGroupID,
				idfsSite = @SiteID,
				strSiteID = @EIDSSSiteID,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @AuditUserName
			WHERE idfSiteToSiteGroup = @SiteToSiteGroupID;
		END
		ELSE IF @RowAction = 'D'
		BEGIN
			DELETE
			FROM dbo.tflSiteToSiteGroup
			WHERE idfSiteToSiteGroup = @SiteToSiteGroupID;
		END
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
