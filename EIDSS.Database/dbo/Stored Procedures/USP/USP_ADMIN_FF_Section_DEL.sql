

-- ================================================================================================
-- Name: USP_ADMIN_FF_Section_DEL
-- Description: Delete the section.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    11/28/2018 Initial release for new API.
-- Doug Albanese	05/05/2021	Corrected the return values for ReturnCode and ReturnMessage to match the application APIPostResponseModel
-- Doug Albanese	05/24/2021	Removed the test on checking against a "Parent Section"
-- Doug Albanese	03/25/2022	Found the use of an EIDSS 6.1 procedure. Replaced with new SQL
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Section_DEL] 
(
	@idfsSection BIGINT	
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	--DECLARE
	--	@ErrorMessage NVARCHAR(400),
	--	@returnCode BIGINT = 0,
	--	@returnMsg  NVARCHAR(MAX) = 'Success' 
	
	BEGIN TRY	
		BEGIN TRANSACTION
	
		--DECLARE @SuppressSelect TABLE (
		--	ReturnCode INT
		--	,ReturnMessage VARCHAR(200)
		--);

		--IF (@ErrorMessage IS NOT NULL)
		--	THROW 52000, @ErrorMessage, 1 
	
		IF EXISTS(SELECT TOP 1 1
				  FROM dbo.ffSection
				  WHERE idfsParentSection = @idfsSection)
			BEGIN
				DECLARE @sect_id BIGINT
				DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT [idfsSection]
					FROM dbo.ffSection
					WHERE idfsParentSection = @idfsSection
						  AND [intRowStatus] = 0
					OPEN curs
				FETCH NEXT FROM curs INTO @sect_id
			
				WHILE @@FETCH_STATUS = 0
					BEGIN
						--INSERT INTO @SuppressSelect
						EXEC dbo.USP_ADMIN_FF_Section_DEL @sect_id
						FETCH NEXT FROM curs INTO @sect_id
					END
			
				CLOSE curs
				DEALLOCATE curs
			END
		
		IF EXISTS(SELECT TOP 1 1
				  FROM dbo.ffParameter
				  WHERE idfsSection = @idfsSection)
			BEGIN
				DECLARE @param_id BIGINT
				DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT [idfsParameter]
					FROM dbo.ffParameter
					WHERE idfsSection = @idfsSection
						  AND [intRowStatus] = 0
				OPEN curs
			FETCH NEXT FROM curs INTO @param_id
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					--INSERT INTO @SuppressSelect
					EXEC dbo.USP_ADMIN_FF_Section_DEL @param_id
					FETCH NEXT FROM curs INTO @param_id
				END
			
			CLOSE curs
			DEALLOCATE curs
		END
		
		IF EXISTS(SELECT TOP 1 1
				  FROM dbo.ffParameter
				  WHERE idfsSection = @idfsSection)
			BEGIN
				DECLARE @de_id BIGINT
				DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR SELECT DISTINCT idfDecorElement
					FROM dbo.ffDecorElement
					WHERE idfsSection = @idfsSection
						  AND [intRowStatus] = 0
				OPEN curs
			FETCH NEXT FROM curs INTO @de_id
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					--INSERT INTO @SuppressSelect
					EXEC dbo.USP_ADMIN_FF_Label_DEL @de_id

					--INSERT INTO @SuppressSelect
					EXEC dbo.USP_ADMIN_FF_Line_DEL @de_id

					FETCH NEXT FROM curs INTO @de_id
				END
			
			CLOSE curs
			DEALLOCATE curs
		END
	
		IF EXISTS(SELECT TOP 1 1
				  FROM dbo.ffSectionForTemplate
				  WHERE idfsSection = @idfsSection)
			BEGIN
				DECLARE @st_id BIGINT
				DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
					FOR SELECT DISTINCT idfsFormTemplate
						FROM dbo.ffSectionForTemplate
						WHERE idfsSection = @idfsSection
							  AND [intRowStatus] = 0
					OPEN curs
				FETCH NEXT FROM curs INTO @st_id
			
				WHILE @@FETCH_STATUS = 0
					BEGIN
						--INSERT INTO @SuppressSelect
						EXEC dbo.USP_ADMIN_FF_SectionTemplate_DEL @idfsSection, @st_id

						FETCH NEXT FROM curs INTO @st_id
					END
			
				CLOSE curs
				DEALLOCATE curs
			END
	
		UPDATE
			ffSection
		SET
			intRowStatus = 1
		WHERE
			idfsSection = @idfsSection
		
		UPDATE
			trtBaseReference
		SET
			intRowStatus = 1
		WHERE
			idfsBaseReference = @idfsSection
		
		--SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

		COMMIT TRANSACTION;
	END TRY 
	BEGIN CATCH   
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
END
