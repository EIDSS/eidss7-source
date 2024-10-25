
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTemplate_DEL
-- Description: Delete the Parameter Template
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru	11/28/2018	Initial release for new API.
-- Doug Albanese	4/2/2020	Alterations to delete the records by intRowStatus, rather than physically
-- Doug Albanese	05/05/2021	Corrected the return values for ReturnCode and ReturnMessage to match the application APIPostResponseModel
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTemplate_DEL] (
	@idfsParameter BIGINT
	,@idfsFormTemplate BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @langid_int BIGINT
		,@returnCode BIGINT = 0
		,@returnMsg NVARCHAR(MAX) = 'Success'

	BEGIN TRY
		DECLARE @Used	BIGINT = 0

		DECLARE @USP_ADMIN_FF_ParameterInUse_Results TABLE(
			Used		INT
		)

		INSERT INTO @USP_ADMIN_FF_ParameterInUse_Results
		EXEC USP_ADMIN_FF_ParameterInUse @idfsParameter = @idfsFormTemplate

		SELECT TOP 1 @Used = COALESCE(Used,0) FROM @USP_ADMIN_FF_ParameterInUse_Results

		IF @Used = 0
			BEGIN
				UPDATE ffParameterDesignOption
				SET intRowStatus = 1
				WHERE idfsParameter = @idfsParameter
					AND idfsFormTemplate = @idfsFormTemplate

				UPDATE ffParameterForTemplate
				SET intRowStatus = 1
				WHERE idfsParameter = @idfsParameter
					AND idfsFormTemplate = @idfsFormTemplate
			END

		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage, @Used As Used

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
