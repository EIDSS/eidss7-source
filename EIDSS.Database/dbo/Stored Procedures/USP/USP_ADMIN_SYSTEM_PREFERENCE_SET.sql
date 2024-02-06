-- ================================================================================================
-- Name: USP_ADMIN_SYSTEM_PREFERENCE_SET
--
-- Description:	Inserts or updates System preferences.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong        10/29/2019 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEM_PREFERENCE_SET]
(
	@SystemPreferenceID						BIGINT = NULL,
	@PreferenceDetail						NVARCHAR(MAX) = NULL
)
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON;

    BEGIN TRY
		DECLARE @ReturnCode					INT = 0,
				@ReturnMessage				NVARCHAR(2048) = 'SUCCESS';

		DECLARE @SupressSelect		TABLE
		(
			ReturnCode			INT,
			ReturnMessage		VARCHAR(2048)
		);

		BEGIN TRANSACTION

		IF	@SystemPreferenceID IS NULL 
		BEGIN
			INSERT INTO		@SupressSelect
			EXECUTE			dbo.USP_GBL_NEXTKEYID_GET 'SystemPreference', @SystemPreferenceID OUTPUT;

			INSERT INTO		dbo.SystemPreference
			(
						SystemPreferenceUID, 
						PreferenceDetail, 
						intRowStatus, 
						AuditCreateUser, 
						AuditCreateDTM
			)
			VALUES
			(
						@SystemPreferenceID,
						@PreferenceDetail,
						0, 
						'srvcEIDSS', 
						GETDATE()
			)
		END
		ELSE
		BEGIN
			UPDATE		dbo.SystemPreference
			SET			PreferenceDetail = @PreferenceDetail, 
						AuditUpdateUser = 'srvcEIDSS', 
						AuditUpdateDTM = GETDATE()
			WHERE		SystemPreferenceUID = @SystemPreferenceID;
		END;

		IF @@TRANCOUNT > 0 
			COMMIT;

		SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage, @SystemPreferenceID SystemPreferenceID;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;

		THROW;
	END CATCH
END

