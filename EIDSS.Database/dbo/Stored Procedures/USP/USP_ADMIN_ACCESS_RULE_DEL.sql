-- ================================================================================================
-- Name: USP_ADMIN_ACCESS_RULE_DEL
-- 
-- Description: Soft deletes an access rule for configurable site filtration.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/12/2021 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ACCESS_RULE_DEL] (@AccessRuleID BIGINT = NULL)
AS
DECLARE @ChildTableCount INT = 0
	,@ReturnMessage VARCHAR(MAX) = 'SUCCESS'
	,@ReturnCode BIGINT = 0;

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		SELECT @ChildTableCount = (
				SELECT COUNT(AccessRuleID)
				FROM dbo.AccessRuleActor
				WHERE AccessRuleID = @AccessRuleID
				);

		IF @ChildTableCount > 0
		BEGIN
			SELECT @ReturnCode = - 1;

			SELECT @ReturnMessage = 'IN USE';
		END
		ELSE
		BEGIN
			UPDATE dbo.AccessRule
			SET intRowStatus = 1
			WHERE AccessRuleID = @AccessRuleID;
		END

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT @ReturnCode AS ReturnCode
			,@ReturnMessage AS ReturnMessage;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
