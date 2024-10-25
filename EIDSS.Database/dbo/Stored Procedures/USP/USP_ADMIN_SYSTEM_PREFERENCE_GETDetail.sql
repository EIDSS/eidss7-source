
-- ================================================================================================
-- Name: USP_ADMIN_SYSTEM_PREFERENCE_GETDetail
--
-- Description: Get details for System preference.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Ann Xiong    10/29/2019 Initial release for new API.
-- Ann Xiong    11/08/2019 Added 'WHERE intRowStatus = 0'
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEM_PREFERENCE_GETDetail]

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT = 0 
	DECLARE	@ReturnMsg NVARCHAR(max) = 'SUCCESS' 

	--BEGIN TRY

		--BEGIN TRANSACTION
				SELECT TOP 1 SystemPreferenceUID AS SystemPreferenceID,
							PreferenceDetail
				FROM 		dbo.SystemPreference
				WHERE		intRowStatus = 0

			--IF @@TRANCOUNT > 0 
			--	COMMIT TRANSACTION;
			
			--SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMsg'
	--END TRY
	--BEGIN CATCH

		--IF @@TRANCOUNT > 0
		--	ROLLBACK TRANSACTION;

		--SET @ReturnCode = ERROR_NUMBER()
		--SET @ReturnMsg = 'ErrorNumber: ' + convert(varchar, ERROR_NUMBER() ) 
		--					+ ' ErrorSeverity: ' + convert(varchar, ERROR_SEVERITY() )
		--	   				+ ' ErrorState: ' + convert(varchar,ERROR_STATE())
		--	   				+ ' ErrorProcedure: ' + isnull(ERROR_PROCEDURE() ,'')
		--	   				+ ' ErrorLine: ' +  convert(varchar,isnull(ERROR_LINE() ,''))
		--	   				+ ' ErrorMessage: '+ ERROR_MESSAGE()

		--SELECT @ReturnCode 'ReturnCode', @ReturnMsg 'ReturnMsg'

	--END CATCH
END

