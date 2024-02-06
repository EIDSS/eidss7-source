

-- ================================================================================================
-- Name: USP_ADMIN_FF_MatrixSeed_SET
--
-- Description: Save the flex form matrix parameters.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Stephen Long    08/19/2019 Initial release.  Temp stored procecure to be used for scripting 
--                            matrix data for veterinary aggregate matrices for GG - GAT 
--                            remediation.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_MatrixSeed_SET] 
(
	@idfsSection BIGINT   
    ,@idfsFormType BIGINT
	,@idfsFormTemplate BIGINT
	,@idfsEditMode BIGINT = NULL
    ,@idfsParameterType BIGINT
	,@idfsEditor BIGINT
	,@intHACode INT	= 0
	,@intOrder INT = 0
	,@strNote NVARCHAR(1000)
    ,@DefaultName NVARCHAR(400)
    ,@NationalName NVARCHAR(600) = NULL
    ,@DefaultLongName NVARCHAR(400) = NULL
    ,@NationalLongName NVARCHAR(600) = NULL
    ,@LangID NVARCHAR(50) = NULL   
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success', 
	    @idfsParameter BIGINT = 0,
	    @idfsParameterCaption BIGINT  = 0

	BEGIN TRY
		IF (@idfsParameter IS NULL)
			SET @idfsParameter = 0;
		IF (@idfsParameterCaption IS NULL)
			SET @idfsParameterCaption = 0;
		IF (@idfsParameter <= 0)
			EXEC dbo.usp_sysGetNewID @idfsParameter OUTPUT
		IF (@idfsParameterCaption <= 0)
			EXEC dbo.usp_sysGetNewID @idfsParameterCaption OUTPUT
	
		EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameter OUTPUT, 19000066/*'rftParameter'*/,@LangID, @DefaultLongName, @NationalLongName, 0
		EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterCaption OUTPUT, 19000070 /*'rftParameterToolTip'*/,@LangID, @DefaultName, @NationalName, 0
		
		IF NOT EXISTS (SELECT TOP 1 1
					   FROM dbo.ffParameter
					   WHERE idfsParameter = @idfsParameter)
			BEGIN
				INSERT INTO [dbo].[ffParameter]
					(
			   			[idfsParameter]
						,[idfsSection]
						,[idfsFormType]						
						,[idfsParameterType]
						,[idfsEditor]
						,[idfsParameterCaption]
						,[intHACode]
						,[strNote]
						,[intOrder]					
					)
				VALUES
					(
						@idfsParameter
						,@idfsSection
						,@idfsFormType						
						,@idfsParameterType
						,@idfsEditor
						,@idfsParameterCaption
						,@intHACode
						,@strNote
						,@intOrder
					)
			END 
		ELSE 
			BEGIN
				UPDATE [dbo].[ffParameter]
				SET [idfsSection] = @idfsSection
					,[idfsFormType] = @idfsFormType
					,[idfsParameterType] = @idfsParameterType
					,[idfsEditor] = @idfsEditor
					,[idfsParameterCaption] = @idfsParameterCaption
					,[intHACode] = @intHACode
					,[strNote] = @strNote
					,[intOrder] = @intOrder
					,[intRowStatus] = 0
				WHERE [idfsParameter] = @idfsParameter
			END
	
		IF (@idfsEditMode IS NULL)
			SET @idfsEditMode = 10068001;
	
		IF (@intOrder IS NULL)
			SET @intOrder = 0;	

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
					)
				VALUES
					(
           				@idfsParameter
           				,@idfsFormTemplate
						,@idfsEditMode	
						,0			
					)          
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffParameterForTemplate]
				SET [idfsEditMode] = @idfsEditMode
					,[blnFreeze] = 0
					,[intRowStatus] = 0
 				WHERE [idfsParameter] = @idfsParameter
					  AND [idfsFormTemplate] = @idfsFormTemplate 						
			END
	
		-----------------------------------
		EXEC dbo.[USP_ADMIN_FF_ParameterDesignOptions_SET] 
			 @idfsParameter
			 ,@idfsFormTemplate
			 ,0
			 ,0
			 ,0
			 ,0			
			 ,0
			 ,0
			 ,@intOrder
			 ,@LangID
		
		SELECT @returnCode, @returnMsg
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			THROW;
	END CATCH
END
