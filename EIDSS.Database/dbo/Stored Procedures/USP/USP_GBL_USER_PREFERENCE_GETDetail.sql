
-- ================================================================================================
-- Name: USP_GBL_USER_PREFERENCE_GETDetail
--
-- Description: Get details for User preference.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Manickandan Govindaraan    08/21/2020 Initial release for new API.
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_GBL_USER_PREFERENCE_GETDetail]
(
	@UserID									BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT TOP 1 UserPreferenceUID AS UserPreferenceUID,
					idfuserId as UserID,
					 PreferenceDetail.value('(/UserPreferences)[1]', 'nvarchar(max)')  AS preferenceDetail
		FROM   UserPreference WHERE idfUserID = @UserID
					AND intRowStatus = 0 and ModuleConstantID is NULL

		
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END

