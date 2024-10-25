
-- ================================================================================================
-- Name: USP_ADMIN_FF_Template_DEL
-- Description: Deletes the Template
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Doug Albanese	05/11/2020 Added corresponding BEGIN TRANSACTION
--	Doug Albanese	06/10/2022	Made corrections to allow supression of repeating records.
--	Doug Albanese	06/14/2022	Removed "Rules" from the copy process, because of EF generation requirements
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Template_DEL] 
(
	@LangId					NVARCHAR(50),
	@idfsFormTemplate		BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;	
	SET XACT_ABORT ON;
	
	DECLARE
		@ID BIGINT,
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' 	

	DECLARE @langid_int BIGINT

	SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);
	
	BEGIN TRY
		BEGIN TRANSACTION;

			Declare @SupressSelect1 table
			( RetrunCode int,
				ReturnMessage varchar(200),
				Used int
			)

			Declare @SupressSelect2 table
			( retrunCode int,
				returnMsg varchar(200)
			)
			
			INSERT INTO @SupressSelect1
			EXEC dbo.USP_ADMIN_FF_TemplateDesignOptions_DEL @idfsFormTemplate
		
			--DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
			--	FOR SELECT DISTINCT [idfsRule]
			--		FROM dbo.ffRule
			--		WHERE idfsFormTemplate = @idfsFormTemplate
			--		OPEN curs
			--	FETCH NEXT FROM curs INTO @ID
				
			--WHILE @@FETCH_STATUS = 0
			--	BEGIN
			--		INSERT INTO @SupressSelect1
			--		EXEC dbo.USP_ADMIN_FF_Rule_DEL @ID
			--		FETCH NEXT FROM curs INTO @ID
			--	END

			--CLOSE curs
			--DEALLOCATE curs 
	   
			DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT [idfsParameter]
					FROM dbo.ffParameterForTemplate
					WHERE idfsFormTemplate = @idfsFormTemplate
					OPEN curs
				FETCH NEXT FROM curs into @ID

			WHILE @@FETCH_STATUS = 0
				BEGIN
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
							WHERE idfsParameter = @ID
								AND idfsFormTemplate = @idfsFormTemplate

							UPDATE ffParameterForTemplate
							SET intRowStatus = 1
							WHERE idfsParameter = @ID
								AND idfsFormTemplate = @idfsFormTemplate
						END


					FETCH NEXT FROM curs INTO @ID
				END

			CLOSE curs
			DEALLOCATE curs	
	 
		   DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT [idfsSection]
					FROM dbo.ffSectionForTemplate
					WHERE idfsFormTemplate = @idfsFormTemplate
					OPEN curs
				FETCH NEXT FROM curs INTO @ID

			WHILE @@FETCH_STATUS = 0
				BEGIN
					DELETE FROM dbo.ffSectionDesignOption
						   WHERE idfsSection = @ID 
								 AND idfsFormTemplate = @idfsFormTemplate
								 AND idfsLanguage = @langid_int

					DELETE FROM dbo.ffSectionDesignOption
							WHERE idfsSection = @ID
									AND idfsFormTemplate = @idfsFormTemplate
				
					DELETE FROM dbo.ffSectionForTemplate
							WHERE idfsSection = @ID 
									AND idfsFormTemplate = @idfsFormTemplate

					FETCH NEXT FROM curs INTO @ID
				END

			CLOSE curs
			DEALLOCATE curs
	   
		   DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT DET.[idfDecorElement]
					FROM dbo.ffDecorElementText DET
					INNER JOIN dbo.ffDecorElement DE
					ON DE.idfDecorElement = DET.idfDecorElement
					WHERE idfsFormTemplate = @idfsFormTemplate
					OPEN curs
				FETCH NEXT FROM curs INTO @ID

			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO @SupressSelect1
					EXEC dbo.USP_ADMIN_FF_Label_DEL @ID
					FETCH NEXT FROM curs INTO @ID
				END

			CLOSE curs
			DEALLOCATE curs
	  
			DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT DEL.[idfDecorElement]
					FROM dbo.ffDecorElementLine DEL
					INNER JOIN dbo.ffDecorElement DE
					ON DE.idfDecorElement = DEL.idfDecorElement
					WHERE idfsFormTemplate = @idfsFormTemplate
					OPEN curs
				FETCH NEXT FROM curs INTO @ID

			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO @SupressSelect1
					EXEC dbo.USP_ADMIN_FF_Line_DEL @ID
					FETCH NEXT FROM curs INTO @ID
				END

			CLOSE curs
			DEALLOCATE curs
	
			DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT idfDeterminantValue FROM dbo.ffDeterminantValue						
					WHERE idfsFormTemplate = @idfsFormTemplate
					OPEN curs
				FETCH NEXT FROM curs INTO @ID

			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO @SupressSelect2
					EXEC dbo.USP_ADMIN_FF_TemplateDeterminantValues_DEL @ID
					FETCH NEXT FROM curs INTO @ID
				END

			CLOSE curs
			DEALLOCATE curs
		
			UPDATE 
				dbo.ffFormTemplate
			SET
				intRowStatus = 1
			WHERE 
				idfsFormTemplate = @idfsFormTemplate

			SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END


