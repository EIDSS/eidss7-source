-- ================================================================================================
-- Name: USP_GBL_USER_PREFERENCE_SET
--
-- Description:	Inserts or updates user preferences by module.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     10/27/2018 Initial release.
-- Stephen Long     08/24/2020 Added module constant ID parameter to allow null, and removed ID 
--                             from suppress select table.  Add audit user name parameter.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_USER_PREFERENCE_SET] (
	@UserPreferenceID BIGINT = NULL,
	@UserID BIGINT,
	@ModuleConstantID BIGINT = NULL,
	@PreferenceDetail XML, 
	@AuditUserName NVARCHAR(200)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnCode INT = 0,
			@ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
		DECLARE @SuppressSelect TABLE (
			ReturnCode INT,
			ReturnMessage NVARCHAR(MAX)
			);

		BEGIN TRANSACTION;

		IF @UserPreferenceID IS NULL
		BEGIN
			INSERT INTO @SuppressSelect
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'UserPreference',
				@idfsKey = @UserPreferenceID OUTPUT;

			INSERT INTO dbo.UserPreference (
				UserPreferenceUID,
				idfUserID,
				ModuleConstantID,
				PreferenceDetail,
				intRowStatus,
				AuditCreateUser,
				AuditCreateDTM
				)
			VALUES (
				@UserPreferenceID,
				@UserID,
				@ModuleConstantID,
				@PreferenceDetail,
				0,
				@AuditUserName,
				GETDATE()
				);
		END
		ELSE
		BEGIN
			UPDATE dbo.UserPreference
			SET idfUserID = @UserID,
				PreferenceDetail = @PreferenceDetail,
				AuditUpdateUser = @AuditUserName,
				AuditUpdateDTM = GETDATE()
			WHERE UserPreferenceUID = @UserPreferenceID;
		END;

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

		SELECT @ReturnCode ReturnCode,
			@ReturnMessage ReturnMessage,
			@UserPreferenceID UserPreferenceID;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
