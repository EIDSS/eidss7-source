
-- ================================================================================================
-- Name: USP_ADMIN_FF_RuleParameterForAction_SET
-- Description: Save theRule Parameter for Action
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	10/2/2020	Updated SP to latest standards
-- Doug Albanese	10/20/2020	Added Audit Information
-- Doug Albanese	10/29/2020	Added "Fill with value" for newly added action
-- Doug Albanese	10/29/2020	Added Soft delete (intRowStatus)
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_RuleParameterForAction_SET] 
(		
	@idfsRule					BIGINT
    ,@idfsFormTemplate			BIGINT
	,@idfsParameter				BIGINT
    ,@idfsRuleAction			BIGINT
	,@idfParameterForAction		BIGINT = -1
	,@FunctionCall				INT = 0
	,@User						NVARCHAR(50) = ''
	,@strFillValue				NVARCHAR(50) = ''
	,@intRowStatus				INT = 0
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

		IF (@idfParameterForAction < 0)
			INSERT INTO @SupressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'ffParameterForAction', @idfParameterForAction OUTPUT;
	
		IF NOT EXISTS (SELECT TOP 1 1 
					   FROM dbo.ffParameterForAction
					   WHERE [idfParameterForAction] = @idfParameterForAction)
			BEGIN
		 
				INSERT INTO [dbo].[ffParameterForAction]
					(
		   				[idfParameterForAction]
						,[idfsRule]
						,[idfsFormTemplate]
						,[idfsParameter]
						,[idfsRuleAction]
						,AuditCreateDTM
						,AuditCreateUser
						,strFillValue
						,intRowStatus
					)
				VALUES
					(
			   			@idfParameterForAction
						,@idfsRule
						,@idfsFormTemplate
						,@idfsParameter
						,@idfsRuleAction
						,GETDATE()
						,@User
						,@strFillValue
						,0
					)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffParameterForAction]
				SET [idfsRuleAction] = @idfsRuleAction
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
					,strFillValue = @strFillValue
					,intRowStatus = @intRowStatus
				WHERE [idfParameterForAction] = @idfParameterForAction
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
