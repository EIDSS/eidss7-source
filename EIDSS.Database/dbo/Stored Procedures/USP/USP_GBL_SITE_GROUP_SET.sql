-- ================================================================================================
-- Name: USP_GBL_SITE_GROUP_SET
--
-- Description:	Inserts or updates an EIDSS site group.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/02/2019 Initial release.
-- Stephen Long     12/28/2019 Added sites temp table and call of stored procedure to set.
-- Stephen Long     06/19/2021 Changed rayon to administrative level, and renamed central site ID 
--                             to central site key.
-- Stephen Long     06/27/2021 Fixed length on EIDSS site ID; changed from 100 to 36.
-- Stephen Long     07/10/2021 Changed from idfsRayon to idfsLocation.
-- Stephen Long     07/26/2021 Changed administrative level ID parameter to location ID.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_SITE_GROUP_SET] (
	@LanguageID NVARCHAR(50)
	,@SiteGroupID BIGINT
	,@LocationID BIGINT = NULL
	,@SiteGroupName NVARCHAR(40)
	,@SiteGroupTypeID BIGINT = NULL
	,@CentralSiteID BIGINT = NULL
	,@SiteGroupDescription NVARCHAR(100) = NULL
	,@RowStatus INT
	,@AuditUserName NVARCHAR(200)
	,@Sites NVARCHAR(MAX)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnCode INT = 0
			,@ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
		DECLARE @SuppressSelect TABLE (
			ReturnCode INT
			,ReturnMessage NVARCHAR(MAX)
			);
		DECLARE @RowAction CHAR(1) = NULL
			,@RowID BIGINT = NULL
			,@SiteID BIGINT = NULL
			,@EIDSSSiteID NVARCHAR(36) = NULL
			,@SiteToSiteGroupID BIGINT = NULL;
		DECLARE @SitesTemp TABLE (
			SiteToSiteGroupID BIGINT NOT NULL
			,SiteID BIGINT NOT NULL
			,EIDSSSiteID NVARCHAR(36) NOT NULL
			,RowAction CHAR(1) NULL
			);

		BEGIN TRANSACTION;

		INSERT INTO @SitesTemp
		SELECT *
		FROM OPENJSON(@Sites) WITH (
				SiteToSiteGroupID BIGINT
				,SiteID BIGINT
				,EIDSSSiteID NVARCHAR(36)
				,RowAction CHAR(1)
				);

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tflSiteGroup
				WHERE idfSiteGroup = @SiteGroupID
					AND intRowStatus = 0
				)
		BEGIN
			INSERT INTO @SuppressSelect
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tflSiteGroup'
				,@idfsKey = @SiteGroupID OUTPUT;

			INSERT INTO dbo.tflSiteGroup (
				idfSiteGroup
				,idfsLocation
				,strSiteGroupName
				,idfsCentralSite
				,idfsSiteGroupType
				,strSiteGroupDescription
				,intRowStatus
				,AuditCreateUser
				,AuditCreateDTM
				)
			VALUES (
				@SiteGroupID
				,@LocationID
				,@SiteGroupName
				,@CentralSiteID
				,@SiteGroupTypeID
				,@SiteGroupDescription
				,0
				,@AuditUserName
				,GETDATE()
				);
		END
		ELSE
		BEGIN
			UPDATE dbo.tflSiteGroup
			SET idfsLocation = @LocationID
				,strSiteGroupName = @SiteGroupName
				,idfsCentralSite = @CentralSiteID
				,idfsSiteGroupType = @SiteGroupTypeID
				,strSiteGroupDescription = @SiteGroupDescription
				,intRowStatus = @RowStatus
				,AuditUpdateUser = @AuditUserName
				,AuditUpdateDTM = GETDATE()
			WHERE idfSiteGroup = @SiteGroupID;
		END;

		WHILE EXISTS (
				SELECT *
				FROM @SitesTemp
				)
		BEGIN
			SELECT TOP 1 @RowID = SiteToSiteGroupID
				,@SiteToSiteGroupID = SiteToSiteGroupID
				,@SiteID = SiteID
				,@EIDSSSiteID = EIDSSSiteID
				,@RowAction = RowAction
			FROM @SitesTemp;

			INSERT INTO @SuppressSelect
			EXECUTE dbo.USSP_GBL_SITE_GROUP_SITES_SET @LanguageID
				,@SiteToSiteGroupID OUTPUT
				,@SiteGroupID
				,@SiteID
				,@EIDSSSiteID
				,@AuditUserName
				,@RowAction;

			DELETE
			FROM @SitesTemp
			WHERE SiteToSiteGroupID = @RowID;
		END;

		IF @@TRANCOUNT > 0
			COMMIT;

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage
			,@SiteGroupID KeyId
			,'SiteGroupID' KeyIdName
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH
END
