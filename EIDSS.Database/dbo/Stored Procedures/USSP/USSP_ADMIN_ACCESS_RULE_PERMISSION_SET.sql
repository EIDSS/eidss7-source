-- ================================================================================================
-- Name: USSP_ADMIN_ACCESS_PERMISSION_SET
--
-- Description:	Inserts or updates access rule permissions for configurable site filtration of the 
-- administration module.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long		11/11/2020 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_ADMIN_ACCESS_RULE_PERMISSION_SET] (
	@LanguageID NVARCHAR(50)
	,@AccessRulePermissionID BIGINT OUTPUT
	,@AccessRuleID BIGINT
	,@AccessPermissionID BIGINT
	,@RowStatus INT
	,@RecordAction CHAR(1)
	,@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @RecordAction = 'I'
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'AccessRulePermission'
				,@idfsKey = @AccessRulePermissionID OUTPUT;

			INSERT INTO dbo.AccessRulePermission (
				AccessRulePermissionID
				,AccessRuleID
				,AccessPermissionID
				,intRowStatus
				,AuditCreateUser
				)
			VALUES (
				@AccessRulePermissionID
				,@AccessRuleID
				,@AccessPermissionID
				,@RowStatus
				,@AuditUserName
				);
		END;
		ELSE
		BEGIN
			UPDATE dbo.AccessRulePermission
			SET AccessRuleID = @AccessRuleID
				,AccessPermissionID = @AccessPermissionID
				,intRowStatus = @RowStatus
				,AuditUpdateUser = @AuditUserName
				,AuditUpdateDTM = GETDATE()
			WHERE AccessRulePermissionID = @AccessRulePermissionID;
		END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
