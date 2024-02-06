
-- ================================================================================================
-- Name: USP_ADMIN_FF_RuleParameterForFunction_SET
-- Description: Saves the Rule Paramter For Functions
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	10/2/2020	Updated SP to latest standards
-- Doug Albanese	10/20/2020	Added Audit Information
-- Doug Albanese	10/29/2020	Added Soft delete (intRowStatus)
-- Doug Albanese	10/30/2020	Added Compare Value for new function rule
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_RuleParameterForFunction_SET] 
(	
     @idfsParameter				BIGINT
     ,@idfsFormTemplate			BIGINT
     ,@idfsRule					BIGINT
     ,@intOrder					INT 
	 ,@idfParameterForFunction	BIGINT = -1
	 ,@FunctionCall				INT = 0
	 ,@User						NVARCHAR(50) = ''
	 ,@intRowStatus				INT = 0
	 ,@strCompareValue			NVARCHAR(50) = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success'

	Declare @SupressSelect table
	( retrunCode int,
		returnMsg varchar(200)
	)

	BEGIN TRY
		BEGIN TRANSACTION;

		IF (@idfParameterForFunction < 0)
			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffParameterForFunction', @idfParameterForFunction OUTPUT;
		
		
		IF NOT EXISTS (SELECT TOP 1 1 
					   FROM dbo.ffParameterForFunction
					   WHERE [idfParameterForFunction] = @idfParameterForFunction)
			BEGIN
		 
				INSERT INTO [dbo].[ffParameterForFunction]
					(
		   				[idfParameterForFunction]
						,[idfsParameter]
						,[idfsFormTemplate]
						,[idfsRule]
						,[intOrder]
						,AuditCreateDTM
						,AuditCreateUser
						,intRowStatus
						,strCompareValue
					)
				VALUES
					(
			   			@idfParameterForFunction
						,@idfsParameter
						,@idfsFormTemplate
						,@idfsRule
						,@intOrder	
						,GETDATE()
						,@User
						,0
						,@strCompareValue
					)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffParameterForFunction]
				SET [intOrder] = @intOrder
					,[intRowStatus] = @intRowStatus
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
					,strCompareValue = @strCompareValue
				WHERE [idfParameterForFunction] = @idfParameterForFunction
			END

		IF @FunctionCall = 0
			BEGIN
				SELECT @returnCode as returnCode, @returnMsg as returnMsg
			END
		
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
