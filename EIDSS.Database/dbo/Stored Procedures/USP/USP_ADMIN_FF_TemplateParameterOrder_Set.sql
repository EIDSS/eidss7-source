
-- ================================================================================================
-- Name: USP_ADMIN_FF_TemplateParameterOrder_Set
-- Description: Changes the order of a parameter
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	04/07/2020	Initial release for new API.
-- Doug Albanese	10/20/2020	Added Auditing Information
-- Doug Albanese	05/19/2021	Added language to capture correct version of the design options
-- Doug Albanese	10/28/2021	Added a new number method for when intOrder's are the same
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_TemplateParameterOrder_Set] (
	@langId						NVARCHAR(50),
	@idfsFormTemplate			BIGINT,
	@idfsCurrentParameter		BIGINT,
	@idfsDestinationParameter	BIGINT,
	@Direction					INT,
	@User						NVARCHAR(50) = ''
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE		@langid_int				BIGINT
				,@returnCode			BIGINT = 0
				,@returnMsg				NVARCHAR(MAX) = 'Success' 

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @CurrentOrder		INT
		DECLARE @DestinationOrder	INT

		SET @langid_int = dbo.fnGetLanguageCode(@LangID);	

		SET @CurrentOrder = (
			SELECT 
				intOrder
			FROM 
				ffParameterDesignOption 
			WHERE 
				idfsParameter = @idfsCurrentParameter AND 
				idfsFormTemplate = @idfsFormTemplate AND
				intRowStatus = 0 AND
				idfsLanguage = @langid_int
			)
		
		SET @DestinationOrder = (
			SELECT 
				intOrder 
			FROM 
				ffParameterDesignOption 
			WHERE 
				idfsParameter = @idfsDestinationParameter AND 
				idfsFormTemplate = @idfsFormTemplate AND
				intRowStatus = 0 AND
				idfsLanguage = @langid_int
			)

		IF @CurrentOrder = @DestinationOrder
			BEGIN
				IF @Direction = 0 --Up
					BEGIN
						SET @DestinationOrder = @DestinationOrder - 1
					END
				ELSE
					BEGIN
						SET @DestinationOrder = @DestinationOrder + 1
					END
			END

		--Swap the order
		UPDATE ffParameterDesignOption
		SET 
			intOrder = @DestinationOrder,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @User
		WHERE
			idfsParameter = @idfsCurrentParameter AND 
			idfsFormTemplate = @idfsFormTemplate

		UPDATE ffParameterDesignOption
		SET 
			intOrder = @CurrentOrder,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @User
		WHERE
			idfsParameter = @idfsDestinationParameter AND 
			idfsFormTemplate = @idfsFormTemplate

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
