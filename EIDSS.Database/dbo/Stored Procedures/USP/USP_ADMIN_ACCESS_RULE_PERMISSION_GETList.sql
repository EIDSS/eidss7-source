-- ================================================================================================
-- Name: USP_ADMIN_ACCESS_RULE_PERMISSION_GETList
--
-- Description:	Get permission list for a specific access rule ID.  Used in rules for configurable 
-- site filtration of the administration module.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/12/2020 Initial release.
-- Stephen Long     11/23/2020 Remove intRowStatus check for permissions.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACCESS_RULE_PERMISSION_GETList] (
	@LanguageID NVARCHAR(50)
	,@AccessRuleID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
		DECLARE @ReturnCode BIGINT = 0;

		SELECT arp.AccessRulePermissionID
			,arp.AccessRuleID 
			,arp.AccessPermissionID
			,accessPermissionType.name AS AccessPermissionName
			,arp.intRowStatus AS RowStatus
			,'R' AS RowAction
		FROM dbo.AccessRulePermission arp
		LEFT JOIN FN_GBL_ReferenceRepair(@LanguageID, 19000059) AS accessPermissionType ON accessPermissionType.idfsReference = arp.AccessPermissionID
		WHERE arp.AccessRuleID = @AccessRuleID; --Get where intRowStatus is both zero or one 
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage;

		THROW;
	END CATCH;
END
