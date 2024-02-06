-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTemplate_SET
-- Description: Save the Parameter Template
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese    11/28/2018	Initial release for new API.
-- Doug Albanese	01/20/2023	Removal of "function Call" suppression
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTemplateForCopy_SET] 
(
	@idfsParameter BIGINT
	,@idfsFormTemplate BIGINT
	,@LangID NVARCHAR(50) = NULL
	,@idfsEditMode BIGINT = NULL
	,@intLeft INT = NULL
	,@intTop INT = NULL
	,@intWidth INT = NULL
	,@intHeight INT = NULL
	,@intScheme INT = NULL
	,@intLabelSize INT = NULL
	,@intOrder INT = NULL
	,@blnFreeze BIT = NULL
	,@User NVARCHAR(50) = ''
	,@CopyOnly INT = 0
	,@FunctionCall INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' 

	BEGIN TRY
		DECLARE @SupressSelect TABLE
		( 
			retrunCode INT,
			returnMsg NVARCHAR(200)
		)

		IF (@idfsEditMode IS NULL) SET @idfsEditMode = 10068001
		IF (@intLeft IS NULL) SET @intLeft = 0
		IF (@intTop IS NULL) SET @IntTop = 0
		IF (@intWidth IS NULL) SET @intWidth = 0
		IF (@intHeight IS NULL) SET @intHeight = 0
		IF (@intScheme IS NULL)	 SET @intScheme = 0
		IF (@blnFreeze IS NULL) SET @blnFreeze = 0
		
		IF (@intLabelSize IS NULL)
			BEGIN 
				IF (@intScheme = 0 OR @intScheme = 1)
					BEGIN
						SET @intLabelSize = @intWidth / 2
					END
			END
		ELSE
			BEGIN
				SET @intLabelSize = @intWidth
			END

		IF (@intOrder IS NULL) SET @intOrder = 0
			
		IF NOT EXISTS (SELECT TOP 1 1
					   FROM [dbo].[ffParameterForTemplate]
					   WHERE [idfsParameter] = @idfsParameter
							 AND [idfsFormTemplate] = @idfsFormTemplate)
			BEGIN
				INSERT INTO [dbo].[ffParameterForTemplate]
					(
           				[idfsParameter]
           				,[idfsFormTemplate]			  	   
						,[idfsEditMode]		
						,[blnFreeze]
						,AuditCreateDTM
						,AuditCreateUser
					)
				VALUES
					(
           				@idfsParameter
           				,@idfsFormTemplate
						,@idfsEditMode	
						,@blnFreeze	
						,GETDATE()
						,@User	
					)          
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffParameterForTemplate]
				SET [idfsEditMode] = @idfsEditMode
					,[blnFreeze] = @blnFreeze
					,[intRowStatus] = 0
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
 				WHERE [idfsParameter] = @idfsParameter
					  AND [idfsFormTemplate] = @idfsFormTemplate 						
			END

		IF @FunctionCall = 1
			BEGIN
				--INSERT INTO @SupressSelect
				EXEC dbo.[USP_ADMIN_FF_ParameterDesignOptions_SET] 
					 @idfsParameter
					 ,@idfsFormTemplate
					 ,@intLeft
					 ,@intTop
					 ,@intWidth
					 ,@intHeight			
					 ,@intScheme
					 ,@intLabelSize
					 ,@intOrder
					 ,@LangID
					 ,@User
					 ,1
			END
		ELSE
			BEGIN
				--INSERT INTO @SupressSelect
				EXEC dbo.[USP_ADMIN_FF_ParameterDesignOptions_SET] 
					 @idfsParameter
					 ,@idfsFormTemplate
					 ,@intLeft
					 ,@intTop
					 ,@intWidth
					 ,@intHeight			
					 ,@intScheme
					 ,@intLabelSize
					 ,@intOrder
					 ,@LangID
					 ,@User
					 ,@CopyOnly
			END

		IF @CopyOnly = 0
			BEGIN
				SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage
			END

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
