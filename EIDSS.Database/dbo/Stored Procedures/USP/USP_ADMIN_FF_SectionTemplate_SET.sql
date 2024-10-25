
-- ================================================================================================
-- Name: USP_ADMIN_FF_SectionTemplate_SET
--
-- Description: Save the section template. 
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru	11/28/2018	Initial release for new API.
-- Stephen Long		08/19/2019	Added corresponding begin transaction.
-- Doug Albanese	10/20/2020	Added Auditing Information
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_SectionTemplate_SET] (
	@idfsSection			BIGINT,
	@idfsFormTemplate		BIGINT,
	@blnFreeze				BIT = NULL,
	@LangID					NVARCHAR(50) = NULL,
	@intLeft				INT = NULL,
	@intTop					INT = NULL,
	@intWidth				INT = NULL,
	@intHeight				INT = NULL,
	@intCaptionHeight		INT = NULL,
	@intOrder				INT = NULL,
	@User					NVARCHAR(50) = ''
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @langid_int BIGINT,
		@returnCode BIGINT = 0,
		@returnMsg NVARCHAR(MAX) = 'Success'

	BEGIN TRY
		BEGIN TRANSACTION;

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);

		IF (@blnFreeze IS NULL)
			SET @blnFreeze = 0;

		IF (@intLeft IS NULL)
			SET @intLeft = 0;

		IF (@intTop IS NULL)
			SET @intTop = 0;

		IF (@intWidth IS NULL)
			SET @intWidth = 0;

		IF (@intHeight IS NULL)
			SET @intHeight = 0;

		IF (@intOrder IS NULL)
			SET @intOrder = 0;

		IF (@intCaptionHeight IS NULL)
			SET @intCaptionHeight = 23;--default

		IF NOT EXISTS (
				SELECT TOP 1 1
				FROM [dbo].[ffSectionForTemplate]
				WHERE [idfsSection] = @idfsSection
					AND [idfsFormTemplate] = @idfsFormTemplate
				)
		BEGIN
			INSERT INTO [dbo].[ffSectionForTemplate] (
				[idfsSection],
				[idfsFormTemplate],
				[blnFreeze],
				[intRowStatus],
				AuditCreateDTM,
				AuditCreateUser
				)
			VALUES (
				@idfsSection,
				@idfsFormTemplate,
				@blnFreeze,
				0,
				GETDATE(),
				@User
				)
		END
		ELSE
		BEGIN
			UPDATE [dbo].[ffSectionForTemplate]
			SET [blnFreeze] = @blnFreeze,
				[intRowStatus] = 0,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE [idfsSection] = @idfsSection
				AND [idfsFormTemplate] = @idfsFormTemplate
		END

		-----------------------------------
		EXEC dbo.[USP_ADMIN_FF_SectionDesignOptions_SET] 
			@idfsSection,
			@idfsFormTemplate,
			@intLeft,
			@intTop,
			@intWidth,
			@intHeight,
			@intCaptionHeight,
			@LangID,
			@intOrder,
			@User 

		SELECT @returnCode,
			@returnMsg

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
