
-- ================================================================================================
-- Name: USP_ADMIN_FF_SectionDesignOptions_SET
--
-- Description: Save the Section Design Options 
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru	11/28/2018	Initial release for new API.
-- Stephen Long		08/19/2019	Added corresponding begin transaction.
-- Doug Albanese	10/20/2020	Added Auditing Information
-- Doug Albanese	01/15/2021	Converted the EIDSS 6.1 "New Key" to EIDSS 7
-- Doug Albanese	07/09/2021	Corrected a null issue with idfsLanguage
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_SectionDesignOptions_SET] (
	@idfsSection			BIGINT,
	@idfsFormTemplate		BIGINT,
	@intLeft				INT,
	@intTop					INT,
	@intWidth				INT,
	@intHeight				INT,
	@intCaptionHeight		INT,
	@LangID					NVARCHAR(50),
	@intOrder				INT,
	@User					NVARCHAR(50) = ''
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@LangID IS NULL)
		SET @LangID = 'en';

	DECLARE @langid_int BIGINT,
		@LangID_intEN BIGINT,
		@idfSectionDesignOption BIGINT,
		@idfSectionDesignOptionEN BIGINT,
		@returnCode BIGINT = 0,
		@returnMsg NVARCHAR(MAX) = 'Success'

	BEGIN TRY
		BEGIN TRANSACTION;

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);
		SET @LangID_intEN = dbo.FN_GBL_LanguageCode_GET('en-US');

		IF (@idfsFormTemplate IS NULL)
		BEGIN
			SELECT @idfSectionDesignOption = [idfSectionDesignOption]
			FROM dbo.ffSectionDesignOption
			WHERE [idfsSection] = @idfsSection
				AND idfsFormTemplate IS NULL
				AND [idfsLanguage] = @langid_int
				AND intRowStatus = 0
		END
		ELSE
		BEGIN
			SELECT @idfSectionDesignOption = [idfSectionDesignOption]
			FROM dbo.ffSectionDesignOption
			WHERE [idfsSection] = @idfsSection
				AND [idfsFormTemplate] = @idfsFormTemplate
				AND [idfsLanguage] = @langid_int
				AND intRowStatus = 0
		END

		IF (@idfSectionDesignOption IS NULL)
		BEGIN

		
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffSectionDesignOption', @idfSectionDesignOption OUTPUT;
			--EXEC dbo.[usp_sysGetNewID] @idfSectionDesignOption OUTPUT

			INSERT [dbo].[ffSectionDesignOption] (
				[idfSectionDesignOption],
				[intLeft],
				[intTop],
				[intWidth],
				[intHeight],
				[intCaptionHeight],
				[idfsSection],
				[idfsLanguage],
				[idfsFormTemplate],
				[intOrder],
				AuditCreateDTM,
				AuditCreateUser
				)
			VALUES (
				@idfSectionDesignOption,
				@intLeft,
				@intTop,
				@intWidth,
				@intHeight,
				@intCaptionHeight,
				@idfsSection,
				@langid_int,
				@idfsFormTemplate,
				@intOrder,
				GETDATE(),
				@User
				)

			IF (@LangID <> 'en-US')
			BEGIN
				IF (@idfsFormTemplate IS NULL)
				BEGIN
					SELECT @idfSectionDesignOptionEN = [idfSectionDesignOption]
					FROM dbo.ffSectionDesignOption
					WHERE [idfsSection] = @idfsSection
						AND idfsFormTemplate IS NULL
						AND [idfsLanguage] = @LangID_intEN
						AND intRowStatus = 0
				END
				ELSE
				BEGIN
					SELECT @idfSectionDesignOptionEN = [idfSectionDesignOption]
					FROM dbo.ffSectionDesignOption
					WHERE [idfsSection] = @idfsSection
						AND [idfsFormTemplate] = @idfsFormTemplate
						AND [idfsLanguage] = @LangID_intEN
						AND intRowStatus = 0
				END

				IF (@idfSectionDesignOptionEN IS NULL)
				BEGIN
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffSectionDesignOption', @idfSectionDesignOptionEN OUTPUT;
					--EXEC dbo.[usp_sysGetNewID] @idfSectionDesignOptionEN OUTPUT

					INSERT [dbo].[ffSectionDesignOption] (
						[idfSectionDesignOption],
						[intLeft],
						[intTop],
						[intWidth],
						[intHeight],
						[intCaptionHeight],
						[idfsSection],
						[idfsLanguage],
						[idfsFormTemplate],
						[intOrder],
						AuditCreateDTM,
						AuditCreateUser
						)
					VALUES (
						@idfSectionDesignOptionEN,
						@intLeft,
						@intTop,
						@intWidth,
						@intHeight,
						@intCaptionHeight,
						@idfsSection,
						@LangID_intEN,
						@idfsFormTemplate,
						@intOrder,
						GETDATE(),
						@User
						)
				END
			END
		END
		ELSE
		BEGIN
			UPDATE [dbo].[ffSectionDesignOption]
			SET [intLeft] = @intLeft,
				[intTop] = @intTop,
				[intWidth] = @intWidth,
				[intHeight] = @intHeight,
				[intCaptionHeight] = @intCaptionHeight,
				[intOrder] = @intOrder,
				[intRowStatus] = 0,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
			WHERE [idfSectionDesignOption] = @idfSectionDesignOption
		END

		SELECT @returnCode,
			@returnMsg

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
END
