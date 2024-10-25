

-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameters_SET
-- Description: Save the Parameters
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	2/26/2020	Rework to get Eidss 6 items out
-- Doug Albanese	10/20/2020	Added Audit information
-- Doug Albanese	01/14/2021	Added a parameter to indicate use from the Copy Template procedure.
-- Doug Albanese	01/14/2021	Correct the output to show...depending on the CopyOnly parameter value
-- Doug Albanese	05/03/2021	Corrected the return values for ReturnCode and ReturnMessage to match the application APIPostResponseModel
-- Doug Albanese	07/08/2021	Removed CopyOnly, that was used to prevent supression that confused the old POCO generation
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Parameters_SET] 
(
    @LangID										NVARCHAR(50)
	,@idfsSection								BIGINT = NULL
    ,@idfsFormType								BIGINT = NULL
    ,@idfsParameterType							BIGINT = NULL
	,@idfsEditor								BIGINT = NULL
	,@intHACode									INT = 0	
	,@intOrder									INT = 0
	,@strNote									NVARCHAR(1000) = NULL
    ,@DefaultName								NVARCHAR(400) = NULL
    ,@NationalName								NVARCHAR(600) = NULL
    ,@DefaultLongName							NVARCHAR(400) = NULL
    ,@NationalLongName							NVARCHAR(600) = NULL
	,@idfsParameter								BIGINT = NULL
	,@idfsParameterCaption						BIGINT  = NULL
	,@User										NVARCHAR(100) = NULL
	,@intRowStatus								INT = 0
	,@CopyOnly									INT = 0				--For use by USP_ADMIN_FF_Copy_Template only
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success'

	BEGIN TRY
		
		IF @CopyOnly = 0
			BEGIN
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameter OUTPUT, 19000066/*'rftParameter'*/,@LangID, @DefaultLongName, @NationalLongName, 0
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterCaption OUTPUT, 19000070 /*'rftParameterToolTip'*/,@LangID, @DefaultName, @NationalName, 0
			END
		
		IF NOT EXISTS (SELECT TOP 1 idfsParameter
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
						,intRowStatus
						,AuditCreateUser
						,AuditCreateDTM		
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
						,0
						,@User
						,GETDATE()
					)
			END 
		ELSE 
			BEGIN
				UPDATE [dbo].[ffParameter]
				SET 
					[idfsParameterType] = @idfsParameterType
					,[idfsEditor] = @idfsEditor
					,[idfsParameterCaption] = @idfsParameterCaption
					,[intHACode] = @intHACode
					,[strNote] = @strNote
					,[intOrder] = @intOrder
					,[intRowStatus] = @intRowStatus
					,AuditUpdateUser = @User
					,AuditUpdateDTM = GETDATE()
				WHERE [idfsParameter] = @idfsParameter
			END
	
		--IF @CopyOnly = 0
			--BEGIN
				SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage, @idfsParameter as idfsParameter, @idfsParameterCaption as idfsParameterCaption 
			--END
		

		
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			THROW;
	END CATCH
END
