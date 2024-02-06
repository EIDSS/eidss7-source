
-- ================================================================================================
-- Name: USP_ADMIN_FF_Section_Copy
-- Description: Copies a section to a given destination.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	6/15/2020	Initial release for new section copy function.
-- Doug Albanese	5/21/2021	Added Auditing user
-- Doug Albanese	7/04/2021	Rewrote to accomodoate for new call
-- Doug Albanese	7/30/2021	Rewrote again to correct errors from previous attempt
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Section_Copy] (
	@IsDesigning					BIT = 1
	,@idfsSectionSource				BIGINT = NULL
	,@idfsSectionDestination		BIGINT = NULL
	,@idfsFormTypeDestination		BIGINT = NULL
	,@User							NVARCHAR(50) = ''
	)
AS
BEGIN
	DECLARE @returnCode				INT = 0;
	DECLARE @returnMsg				NVARCHAR(MAX) = 'SUCCESS';

	DECLARE @idfsSection			BIGINT
	DECLARE @idfsSectionNew			BIGINT
	DECLARE @idfsSections			TABLE (idfsSection BIGINT)
	DECLARE @idfsSectionsNew		TABLE (idfsSection BIGINT)
	DECLARE @idfsParentSection		BIGINT = NULL
	DECLARE @Sections				TABLE (idfsSection BIGINT,idfsParentSection BIGINT, idfsSectionNew BIGINT, idfsParentSectionNew BIGINT)
	
	DECLARE @Parameters				TABLE (idfsParameter BIGINT, idfsSection BIGINT, idfsSectionNew BIGINT, idfsParameterNew BIGINT)
	DECLARE @idfsParameter			BIGINT
	DECLARE @idfsParentSectionNew	BIGINT
	
	DECLARE @idfsParameters			TABLE (idfsParameter BIGINT, idfsParameterNew BIGINT)

	DECLARE @DefaultName			NVARCHAR(400) = NULL
	DECLARE @NationalName			NVARCHAR(600) = NULL
	DECLARE @LangID					NVARCHAR(50) = NULL
	DECLARE @idfsLanguage			BIGINT
	DECLARE @intOrder				INT = 0
	DECLARE @blnGrid				BIT = 0
	DECLARE @blnFixedRowset			BIT = 0
	DECLARE @idfsMatrixType			BIGINT = NULL
	DECLARE @intRowStatus			INT = 0
	DECLARE @idfsFormType			BIGINT
	DECLARE @idfsParameterSource	BIGINT

	DECLARE @SectionDetails TABLE (
		idfsSection			BIGINT,
		idfsParentSection	BIGINT,
		idfsFormType		BIGINT,
		rowGuid				UNIQUEIDENTIFIER,
		intRowStatus		INT,
		DefaultName			NVARCHAR(MAX),
		NationalName		NVARCHAR(MAX),
		HasParameters		BIT,
		HasNestedSections	BIT,
		blnGrid				BIT,
		blnFixedRowSet		BIT,
		intOrder			INT,
		LangId				NVARCHAR(50),
		idfsMatrixType		BIGINT
	)

	DECLARE @ReturnSectionDetails TABLE (
		ReturnCode			INT, 
		ReturnMessage		NVARCHAR(MAX), 
		idfsSection			BIGINT
	)

	BEGIN TRY
		BEGIN
			-- Create initial entry for the selected section source
			INSERT INTO @Sections (idfsSection, idfsParentSectionNew) 
			VALUES (@idfsSectionSource, @idfsSectionDestination)
			
			IF (@idfsSectionDestination IS NOT NULL)
				BEGIN
					SELECT 
						@idfsFormTypeDestination = idfsFormType
					FROM
						ffSection
					WHERE
						idfsSection = @idfsSectionDestination
				END

			WHILE EXISTS (SELECT idfsSection FROM @Sections WHERE idfsSectionNew IS NULL)
				BEGIN
					
					SELECT
						TOP 1 @idfsSection = idfsSection,
						@idfsSectionDestination = idfsParentSectionNew
					FROM
						@Sections
					WHERE
						idfsSectionNew IS NULL

					SET @idfsSectionNew = NULL

					DELETE FROM @SectionDetails
					
					--Discover the original details of the section being copied.
					INSERT INTO @SectionDetails
					EXEC USP_ADMIN_FF_Sections_GET @idfsSection = @idfsSection
					
					--Transfer the details to variables for inserting
					SELECT
						@idfsFormType			= idfsFormType,
						@DefaultName			= DefaultName,
						@NationalName			= NationalName,
						@blnGrid				= blnGrid,
						@blnFixedRowSet			= blnFixedRowSet,
						@intOrder				= intOrder,
						@idfsMatrixType			= idfsMatrixType,
						@LangId					= langid
					FROM
						@SectionDetails
					
					EXEC dbo.USSP_GBL_BaseReference_SET @idfsSectionNew OUTPUT
					,19000101
					,@LangID
					,@DefaultName
					,@NationalName
					,0

					IF @idfsSectionDestination IS NULL
						BEGIN
							SET @idfsFormType = @idfsFormTypeDestination
						END
					
					--Create a new record, based off of a new idfsSection value
					INSERT INTO @ReturnSectionDetails
					EXEC USP_ADMIN_FF_Sections_SET
						@idfsSection			= @idfsSectionNew,
						@idfsParentSection		= @idfsSectionDestination,
						@idfsFormType			= @idfsFormType,
						@DefaultName			= @DefaultName,
						@NationalName			= @NationalName,
						@blnGrid				= @blnGrid,
						@blnFixedRowSet			= @blnFixedRowSet,
						@intOrder				= @intOrder,
						@idfsMatrixType			= @idfsMatrixType,
						@intRowStatus			= 0,
						@User					= @User,
						@LangId					= @LangId

					INSERT INTO @Parameters (idfsParameter, idfsSection, idfsSectionNew)
					SELECT idfsParameter, @idfsSection, @idfsSectionNew FROM ffParameter WHERE idfsSection = @idfsSection AND intRowStatus = 0
					
					UPDATE 
						@Sections
					SET 
						idfsSectionNew = @idfsSectionNew
					WHERE 
						idfsSection = @idfsSection
					
					INSERT INTO @Sections (idfsSection, idfsParentSectionNew)
					SELECT idfsSection, @idfsSectionNew FROM ffSection WHERE idfsParentSection = @idfsSection AND intRowStatus = 0 AND intRowStatus = 0
					
				END
			
			WHILE EXISTS(SELECT TOP 1 idfsParameter FROM @Parameters WHERE idfsParameterNew IS NULL)
				BEGIN
					SELECT
						TOP 1 @idfsParameter = idfsParameter,
							@idfsSectionNew = idfsSectionNew
					FROM
						@Parameters
					WHERE
						idfsParameterNew IS NULL


					EXEC USP_ADMIN_FF_Parameter_Copy @LangId=@LangID, @idfsParameterSource = @idfsParameter, @idfsSectionDestination = @idfsSectionNew, @idfsFormTypeDestination = @idfsFormTypeDestination
					
					UPDATE @Parameters
					SET idfsParameterNew = 0
					WHERE idfsParameter = @idfsParameter
					
				END
		END
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		--SET @returnCode = ERROR_NUMBER();
		--SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

	END CATCH

END
