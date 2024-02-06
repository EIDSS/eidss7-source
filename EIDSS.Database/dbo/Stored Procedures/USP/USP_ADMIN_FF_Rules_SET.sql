

-- ================================================================================================
-- Name: USP_ADMIN_FF_Rules_SET
-- Description: Save the Rules
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Doug Albanese	10/1/2020	Changes to get this SP up to date with standards
-- Doug Albanese	10/2/2020	Added Source and Destination Parameters for Function and Action storage
-- Doug Albanese	10/2/2020	Added idfsRuleAction
-- Doug Albanese	10/2/2020	Added remote calls to SP to save Function and Actions for Rule
-- Doug Albanese	10/20/2020	Added Auditing Information
-- Doug Albanese	10/29/2020	Added "Fill with value" for newly added action
-- Doug Albanese	10/30/2020	Added Compare Value for new function rule
-- Doug Albanese	01/15/2021	Modification to allow use as a function. Additionally, parameter added for use with Template Copy
-- Doug Albanese	01/18/2021	Made further corrections to allow use by the Template copy procedure.
-- Doug Albanese	03/16/2022	Refactored to work with EF generation
--	Doug Albanese	06/10/2022	Correction for null Parameter IDs, when use via the USP_AdMIN_Template_Copy SP
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Rules_SET] 
(	
	@idfsFormTemplate					BIGINT
	,@idfsCheckPoint					BIGINT
    ,@idfsRuleFunction					BIGINT = NULL
	,@idfsRuleAction					BIGINT = NULL
    ,@DefaultName						VARCHAR(200)
    ,@NationalName						NVARCHAR(300)
    ,@MessageText						VARCHAR(200)
    ,@MessageNationalText				VARCHAR(300)   
    ,@blnNot							BIT
    ,@LangID							NVARCHAR(50) = NULL
	,@idfsRule							BIGINT = NULL
	,@idfsRuleMessage					BIGINT   
	,@idfsFunctionParameter				BIGINT 
	,@idfsActionParameter				BIGINT
	,@User								NVARCHAR(50) = ''
	,@strFillValue						NVARCHAR(50) = NULL
	,@intRowStatus						INT = 0
	,@strCompareValue					NVARCHAR(50) = NULL
	,@FunctionCall						INT = 0
	,@CopyOnly							INT = 0
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @returnCode BIGINT = 0
	DECLARE @returnMsg  NVARCHAR(MAX) = 'Success' 
	DECLARE @idfParameterForFunction BIGINT = -1
	DECLARE @idfParameterForAction BIGINT = -1

	BEGIN TRY
		BEGIN TRANSACTION;

		IF (@idfsRuleFunction IS NULL) RETURN;
		--IF (@LangID IS NULL) SET @LangID = 'en';
		IF (@idfsRule < 0)  SET @idfsRule = NULL
		IF (@idfsRuleMessage < 0) SET @idfsRuleMessage = NULL

		--Create or Update the base Rule
		Declare @SupressSelect table
		( retrunCode int,
			returnMsg varchar(200)
		)

		IF @CopyOnly = 0
			BEGIN
				INSERT INTO @SupressSelect
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsRule OUTPUT,19000029,@LangID, @DefaultName, @NationalName, 0
				INSERT INTO @SupressSelect
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsRuleMessage OUTPUT, 19000032, @LangID, @MessageText, @MessageNationalText, 0
			END
		
		IF NOT EXISTS (SELECT TOP 1 1 
					   FROM dbo.ffRule 
					   WHERE [idfsRule] = @idfsRule)
			BEGIN
				INSERT INTO [dbo].[ffRule]
					(
			   			[idfsRule]
						,[idfsRuleMessage]
						,[idfsFormTemplate]
						,[idfsCheckPoint]
						,[idfsRuleFunction]
						,[intRowStatus]
						,[blnNot]
						,AuditCreateDTM
						,AuditCreateUser
					)
				VALUES
					(
			   			@idfsRule
						,@idfsRuleMessage
						,@idfsFormTemplate
						,@idfsCheckPoint	
						,@idfsRuleFunction
						,0
						,@blnNot
						,GETDATE()
						,@User
					)
			END
		ELSE
			BEGIN
	         	UPDATE [dbo].[ffRule]
				SET [idfsRuleMessage] = @idfsRuleMessage			
					,[idfsFormTemplate] = @idfsFormTemplate 				
					,[idfsCheckPoint] = @idfsCheckPoint
					,[idfsRuleFunction] = @idfsRuleFunction
					,[blnNot] = @blnNot
					,[intRowStatus] = @intRowStatus
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
				WHERE [idfsRule] = @idfsRule

				SELECT @idfParameterForFunction = idfParameterForFunction FROM ffParameterForFunction WHERE idfsRule = @idfsRule AND idfsParameter = @idfsFunctionParameter
				SELECT @idfParameterForAction = idfParameterForAction FROM ffParameterForAction WHERE idfsRule = @idfsRule AND idfsParameter = @idfsActionParameter
			END

		IF @idfParameterForFunction IS NOT NULL AND @idfsFunctionParameter IS NOT NULL
			BEGIN
				IF @FunctionCall = 0
					BEGIN
			
						--Create or Update the Function for the Parameter being configured.
						--INSERT INTO @SupressSelect
						EXEC USP_ADMIN_FF_RuleParameterForFunction_SET @idfParameterForFunction = @idfParameterForFunction, @idfsParameter = @idfsFunctionParameter, @idfsFormTemplate = @idfsFormTemplate, @idfsRule = @idfsRule, @intOrder = 0, @FunctionCall = 1, @User = @User, @intRowStatus = @intRowStatus,@strCompareValue = @strCompareValue
				
						--INSERT INTO @SupressSelect
						EXEC USP_ADMIN_FF_RuleParameterForAction_SET @idfParameterForAction = @idfParameterForAction, @idfsRule = @idfsRule, @idfsFormTemplate = @idfsFormTemplate, @idfsParameter = @idfsActionParameter, @idfsRuleAction = @idfsRuleAction, @FunctionCall = 1, @User = @User, @strFillValue = @strFillValue, @intRowStatus = @intRowStatus
					END
				ELSE
					BEGIN
						--Create or Update the Function for the Parameter being configured.
						--INSERT INTO @SupressSelect
						EXEC USP_ADMIN_FF_RuleParameterForFunction_SET @idfParameterForFunction = @idfParameterForFunction, @idfsParameter = @idfsFunctionParameter, @idfsFormTemplate = @idfsFormTemplate, @idfsRule = @idfsRule, @intOrder = 0, @FunctionCall = 1, @User = @User, @intRowStatus = @intRowStatus,@strCompareValue = @strCompareValue
						--Create or Update the Action for the Parameter being configured.
						--INSERT INTO @SupressSelect
						EXEC USP_ADMIN_FF_RuleParameterForAction_SET @idfParameterForAction = @idfParameterForAction, @idfsRule = @idfsRule, @idfsFormTemplate = @idfsFormTemplate, @idfsParameter = @idfsActionParameter, @idfsRuleAction = @idfsRuleAction, @FunctionCall = 1, @User = @User, @strFillValue = @strFillValue, @intRowStatus = @intRowStatus
					END
			END

		IF @CopyOnly = 0
			BEGIN
				SELECT @returnCode As ReturnCode, @returnMsg AS ReturnMsg, @idfsRule AS idfsRule
			END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
