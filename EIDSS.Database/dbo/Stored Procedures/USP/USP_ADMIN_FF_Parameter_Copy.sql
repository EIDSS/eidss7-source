

-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameter_Copy
-- Description: Copies a parameter to a given destination.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	6/16/2020	Initial release for new section copy function.
-- Doug Albanese	07/26/2021	Correction of language change, and added required langid.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Parameter_Copy] (
	@LangId						NVARCHAR(50)
	,@idfsParameterSource		BIGINT = NULL
	,@idfsSectionDestination	BIGINT = NULL
	,@idfsFormTypeDestination	BIGINT = NULL
	,@User						NVARCHAR(100) = NULL
	)
AS
BEGIN
	BEGIN TRY
		BEGIN
		
			DECLARE 
			@returnCode BIGINT = 0,
			@returnMsg  NVARCHAR(MAX) = 'Success'

			DECLARE @idfsParameterNew						BIGINT = NULL
			DECLARE @idfsParameterType						BIGINT = NULL
			DECLARE @idfsEditor								BIGINT = NULL
			DECLARE @intHACode								INT = 0	
			DECLARE @intOrder								INT = 0
			DECLARE @strNote								NVARCHAR(1000) = NULL
			DECLARE @DefaultName							NVARCHAR(400) = NULL
			DECLARE @NationalName							NVARCHAR(600) = NULL
			DECLARE @DefaultLongName						NVARCHAR(400) = NULL
			DECLARE @NationalLongName						NVARCHAR(600) = NULL
			DECLARE @idfsParameterCaption					BIGINT  = NULL
			DECLARE @langid_int								INT

			--Set Default language, so that any record that doesn't end up in the translation table means it is automatically English
			SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangId);
			
			--Grab the data for the parameter that needs to be copied
			SELECT
				@idfsParameterType = p.idfsParameterType,							
				@idfsEditor = p.idfsEditor,								
				@intHACode = p.intHACode,									
				@intOrder = p.intOrder,									
				@strNote = p.strNote,									
				@DEfaultName = ISNULL(B2.[strDefault], ''),
				@DefaultLongName = ISNULL(B1.[strDefault], ''),
				@NationalName = ISNULL(SNT2.[strTextString], B2.[strDefault]),
				@NationalLongName = ISNULL(SNT1.[strTextString], B1.[strDefault]),
				@idfsParameterCaption = p.idfsParameterCaption	
			FROM
				ffParameter p
			INNER JOIN dbo.trtBaseReference B1
			ON B1.[idfsBaseReference] = P.[idfsParameter]
				AND B1.[intRowStatus] = 0
			LEFT JOIN dbo.trtBaseReference B2
			ON B2.[idfsBaseReference] = P.[idfsParameterCaption]
				AND B2.[intRowStatus] = 0
			LEFT JOIN dbo.trtStringNameTranslation SNT1
			ON (SNT1.[idfsBaseReference] = P.[idfsParameter]
				AND SNT1.[idfsLanguage] = @langid_int)
				AND SNT1.[intRowStatus] = 0
			LEFT JOIN dbo.trtStringNameTranslation SNT2
			ON (SNT2.[idfsBaseReference] = P.[idfsParameterCaption]
				AND SNT2.[idfsLanguage] = @langid_int)
				AND SNT2.[intRowStatus] = 0				
			WHERE
				p.idfsParameter = @idfsParameterSource

			--Create a new ID for the new copy to be made
			--EXEC	dbo.USP_GBL_NEXTKEYID_GET 'ffParameter', @idfsParameterNew OUTPUT;
			exec USP_ADMIN_FF_BaseReference_SET  @idfsParameterNew OUTPUT, @ReferenceType = 19000066, @LangId = @LangId, @DefaultName = @DefaultName, @NationalName = @NationalName

			--Create a copy of the parameter selected
			EXEC USP_ADMIN_FF_Parameters_SET 
				@langid=@langid,
				@idfsParameter = @idfsParameterNew,
				@idfsSection = @idfsSectionDestination,
				@idfsFormType = @idfsFormTypeDestination,
				@idfsParameterType = @idfsParameterType,
				@idfsEditor = @idfsEditor,
				@intHACode = @intHACode,
				@intOrder = @intOrder,
				@strNote = @strNote,
				@DefaultName = @DefaultName,
				@NationalName = @NationalName,
				@DefaultLongName = @DefaultLongName,
				@NationalLongName = @NationalLongName,
				@idfsParameterCaption = @idfsParameterCaption,
				@User = @User,
				@intRowStatus = 0
		END

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage, @idfsParameterNew As idfsParameter

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		--SET @returnCode = ERROR_NUMBER();
		--SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		THROW;
	END CATCH

	WrapUp:

	RETURN
END
