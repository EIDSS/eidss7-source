
-- ================================================================================================
-- Name: USP_OMM_FF_Template_Create
-- Description: Creates a template from scratch without answers. Can be from observation or determinant
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Doug Albanese   5/12/2020		Initial release for new API.
-- Doug Albanese	09/24/2020  Removed the duplication issue for tagging with an incrementing number
--	Doug Albanese	05/27/2022	Removed the return code and message, since it was being supressed by the calling SP
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_FF_Template_Create] (
	@langId								NVARCHAR(50),
	@idfObservation						BIGINT = NULL,
	@idfsFormType						BIGINT = NULL,
	@idfOutbreak						BIGINT,
	@idfsDiagnosisOrDiagnosisGroup		BIGINT = NULL,
	@User								NVARCHAR(50) = NULL,
	@idfsSite							BIGINT = NULL
)
AS
BEGIN
	DECLARE @returnCode					INT = 0;
	DECLARE @returnMsg					NVARCHAR(MAX) = 'SUCCESS';

	DECLARE @idfsFormTypeConverted		BIGINT = NULL
	DECLARE @idfsFormTemplate			BIGINT = NULL
	DECLARE @idfsFormTemplateNew		BIGINT = NULL
	DECLARE @DefaultName				NVARCHAR(200)
	DECLARE @NationalName				NVARCHAR(200)
	DECLARE @strNote					NVARCHAR(500)
	DECLARE @strOutbreakId				NVARCHAR(200)
	DECLARE @idfsParameter				BIGINT = NULL
	DECLARE	@idfsSection				BIGINT = NULL
	DECLARE @idfParameterDesignOption	BIGINT = NULL
	DECLARE @idfSectionDesignOption		BIGINT = NULL
	
	DECLARE @TemplateDetails As TABLE (
		idfsFormTemplate				BIGINT,
		FormTemplate					NVARCHAR(200),
		NationalName					NVARCHAR(200),
		idfsFormType					BIGINT,
		strNote							NVARCHAR(500),
		blnUNI							BIT
	)

	DECLARE @tmpTemplate AS TABLE(
		idfsFormTemplate				BIGINT,
		IsUNITemplate					BIT
	)

	DECLARE @returnValues AS TABLE (
		returnCode						NVARCHAR(200),
		returnMsg						NVARCHAR(200),
		idfsFormTemplate				BIGINT
	)

	DECLARE @parameters AS TABLE (
		idfsParameter					BIGINT
	)

	DECLARE @parameterOptions AS TABLE (
		idfsParameterDesignOption		BIGINT, 
		idfsParameter					BIGINT, 
		idfsLanguage					BIGINT, 
		idfsFormTemplate				BIGINT, 
		intLeft							INT, 
		intTop							INT, 
		intWidth						INT,
		intHeight						INT,
		intScheme						INT,
		intLabelSize					INT,
		intOrder						INT,
		intRowStatus					INT,
		AuditCreateUser					NVARCHAR(50),
		AuditCreateDTM					DATETIME
	)

	DECLARE @sections AS TABLE (
		idfsSection						BIGINT
	)

	Declare @SupressSelect table
	( 
		retrunCode int,
		returnMessage varchar(200)
	)

	BEGIN TRY 
		--Reverse engineering to get the Form Type so that we can determine what Outbreak Form Type should be associated
		IF @idfObservation IS NOT NULL
			BEGIN
				SELECT
					@idfsFormTemplate = idfsFormTemplate
				FROM
					tlbObservation
				WHERE
					idfObservation = @idfObservation
			END
		
		IF @idfsFormType IS NULL
			BEGIN
				SELECT 
					@idfsFormType = idfsFormType
				FROM
					ffFormTemplate
				WHERE
					idfsFormTemplate = @idfsFormTemplate
			END

		SET @idfsFormTypeConverted = CASE @idfsFormType
			WHEN 10034011 THEN 10034501 --Human EPI Investigation	-	Outbreak Human Case Questionnaire
			WHEN 10034015 THEN 10034502 --Livestock Farm EPI		-	Outbreak Livestock Case Questionnaire
			WHEN 10034007 THEN 10034503	--Avian Farm EPI			-	Outbreak Avian Case Questionnaire
			ELSE -1
		END
		------------------------------------------------------------------------------------------------------------------

		SELECT
			@strOutbreakId = strOutbreakId
		FROM
			tlbOutbreak
		WHERE
			idfOutbreak = @idfOutbreak
		
		--If no idfsFormType has been determined at this point, then we don't need to perform this operation, so exit
		IF @idfsFormTypeConverted <> -1
			BEGIN
				IF @idfsFormTemplate IS NULL
				BEGIN
					INSERT INTO @tmpTemplate
					EXECUTE USP_ADMIN_FF_ActualTemplate_GET 
							NULL,
							@idfsDiagnosisOrDiagnosisGroup,
							@idfsFormType

					SELECT 
						TOP 1 @idfsFormTemplate = idfsFormTemplate
					FROM 
						@tmpTemplate
				END
				--Create the template's shell
				INSERT INTO @TemplateDetails
				EXEC USP_ADMIN_FF_Template_GetDetail @Langid = @LangId, @idfsFormTemplate = @idfsFormTemplate
				
				SELECT
					TOP 1
					@idfsFormTemplate		= idfsFormTemplate,
					@DefaultName			= FormTemplate,
					@NationalName			= NationalName,
					@strNote				= strNote
				FROM
					@TemplateDetails

				SET @DefaultName = CONCAT(@DefaultName, ' (' , @strOutbreakId, ')')
				SET @NationalName = CONCAT(@NationalName, ' (' , @strOutbreakId, ')')

				------------------------------------------------------------------------------------------------------------------------------
				--INSERT INTO @returnValues
				--EXEC USP_ADMIN_FF_Template_SET 
				--		@idfsFormTemplate	= -1,
				--		@idfsFormType		= @idfsFormTypeConverted, 
				--		@DefaultName		= @DefaultName ,
				--		@NationalName		= @NationalName, 
				--		@strNote			= @strNote, 
				--		@LangId				= @LangId, 
				--		@blnUNI				= false,
				--		@FunctionCall		= 1		

				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference', @idfsFormTemplateNew OUTPUT;

				DECLARE @strDefault NVARCHAR(50)
				DECLARE @iCount AS INT
				DECLARE @FormType NVARCHAR(50)

				SELECT
					@FormType = strDefault
				FROM
					trtBaseReference
				WHERE
					idfsBaseReference = @idfsFormType

				SET @DefaultName = CONCAT(@FormType,' ' , @DefaultName)

				SELECT 
					@strDefault = strDefault
				FROM
					trtBaseReference
				WHERE
					strDefault = @DefaultName AND
					idfsReferenceType = 19000033

				--If Duplications exists, count them and append a numeric number
				IF @strDefault IS NULL
					BEGIN
						INSERT INTO @SupressSelect
						EXEC dbo.USP_GBL_BaseReference_SET
							@ReferenceID=@idfsFormTemplateNew OUTPUT, 
							@ReferenceType=19000033, 
							@LangID=@LangID, 
							@DefaultName=@DefaultName, 
							@NationalName=@NationalName, 
							@HACode=0, 
							@Order=0, 
							@System=0;
			
						INSERT INTO [dbo].[ffFormTemplate]
							(
	           					[idfsFormTemplate]
								,[idfsFormType]			   
								,[strNote]
								,[intRowStatus]
								,[blnUNI]
							)
						VALUES
							(
	           					@idfsFormTemplateNew
								,@idfsFormTypeConverted
								,@strNote
								,0
								,0
							)          
	
						--Get a collection of parameters associated with the non-outbreak related flex form
						INSERT INTO @parameters
						SELECT
							idfsParameter
						FROM
							ffParameterForTemplate
						WHERE
							idfsFormTemplate = @idfsFormTemplate
				
						--Enumerate the parameter collection and copy for the Outbreak related flex form type
						WHILE EXISTS (SELECT idfsParameter FROM @parameters)
						BEGIN
							SELECT
								TOP 1
								@idfsParameter = idfsParameter
							FROM
								@parameters

							INSERT INTO ffParameterForTemplate
								(idfsParameter, idfsFormTemplate, idfsEditMode, blnFreeze, intRowStatus, AuditCreateUser, AuditCreateDTM)
							VALUES
								(@idfsParameter, @idfsFormTemplateNew, 10068001, 0, 0, @User, GETDATE())
								select @idfsParameter, @idfsFormTemplateNew
					
							INSERT INTO @SupressSelect
							EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffParameterDesignOption', @idfParameterDesignOption OUTPUT;
					
							INSERT INTO ffParameterDesignOption
							(
								idfParameterDesignOption, 
								idfsParameter, 
								idfsLanguage, 
								idfsFormTemplate, 
								intLeft, 
								intTop, 
								intWidth, 
								intHeight, 
								intScheme, 
								intLabelSize, 
								intOrder, 
								intRowStatus, 
								AuditCreateUser,
								AuditCreateDTM
							)
							SELECT
								@idfParameterDesignOption, 
								idfsParameter, 
								idfsLanguage, 
								@idfsFormTemplateNew, 
								intLeft, 
								intTop, 
								intWidth, 
								intHeight, 
								intScheme, 
								intLabelSize, 
								intOrder, 
								0, 
								@User,
								GETDATE()
					
							FROM
								ffParameterDesignOption
							WHERE
								idfsParameter = @idfsParameter AND 
								idfsFormTemplate = @idfsFormTemplate

							SET ROWCOUNT 1
							DELETE FROM @parameters
							SET ROWCOUNT 0

						END

						--Get a collection of sections associated with the non-outbreak related flex form
						INSERT INTO @sections
						SELECT
							idfsSection
						FROM
							ffSectionForTemplate
						WHERE
							idfsFormTemplate = @idfsFormTemplate

						--Enumerate the parameter collection and copy for the Outbreak related flex form type
						WHILE EXISTS (SELECT idfsSection FROM @sections)
						BEGIN
							SELECT
								TOP 1
								@idfsSection = idfsSection
							FROM
								@sections

							INSERT INTO ffSectionForTemplate
								(idfsSection, idfsFormTemplate, blnFreeze, intRowStatus, AuditCreateUser, AuditCreateDTM)
							VALUES
								(@idfsSection, @idfsFormTemplateNew, 0, 0, @User, GETDATE())

							INSERT INTO @SupressSelect
							EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffSectionDesignOption', @idfSectionDesignOption OUTPUT;
					
							INSERT INTO ffSectionDesignOption
							(
								idfSectionDesignOption, 
								idfsSection, 
								idfsLanguage, 
								idfsFormTemplate, 
								intLeft, 
								intTop, 
								intWidth, 
								intHeight, 
								intOrder, 
								intRowStatus, 
								AuditCreateUser,
								AuditCreateDTM
							)
							SELECT
								@idfSectionDesignOption, 
								idfsSection, 
								idfsLanguage, 
								@idfsFormTemplateNew, 
								intLeft, 
								intTop, 
								intWidth, 
								intHeight, 
								intOrder, 
								0, 
								@User,
								GETDATE()
					
							FROM
								ffSectionDesignOption
							WHERE
								idfsSection = @idfsSection AND 
								idfsFormTemplate = @idfsFormTemplate

							SET ROWCOUNT 1
							DELETE FROM @sections
							SET ROWCOUNT 0
					
						END
					END
			END

		--SELECT	@returnCode as returnCode, @returnMsg as returnMsg
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			--ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		throw;
	END CATCH
END
