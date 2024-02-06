
-- ================================================================================================
-- Name: USP_ADMIN_FF_Rule_GetDetails
-- Description: Returns the details for a single rule
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	10/07/2020	Initial release for new API.
-- Doug Albanese	01/15/2021	Removed Begin and Commit transaction, since tit is not really needed here.
-- Doug Albanese	03/17/2022	Refactored to align for correct "Action" data (IE Parameters used for action and the action taken)
--	Doug Albanese	05/17/2022	Corrected the output to be 
--	Doug Albanese	06/09/2022	Added the "Fill Value" for rules modal. Forced LangID to be required
--	Doug Albanese	06/10/2022	Spelling correction from FilleValue to FillValue
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Rule_GetDetails]
(
	@LangID			NVARCHAR(50)	
	,@idfsRule		BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE 
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX) 

	DECLARE	@FunctionParameters		VARCHAR(MAX)
	DECLARE	@ActionParameters		VARCHAR(MAX)
	DECLARE @idfsRuleAction			BIGINT

	BEGIN TRY

		--Gather all parameters that are assigned actions, for the given rule id
		--SELECT
		--	@FunctionParameters = STRING_AGG(p.idfsParameter,',')
		--FROM
		--	(
		--		SELECT
		--			 DISTINCT idfsParameter
		--		FROM
		--			ffParameterForFunction
		--		WHERE
		--			idfsRule = @idfsRule
		--	) AS P

		--Gather all parameters that are assigned actions, for the given rule id
		SELECT
			@ActionParameters = STRING_AGG(p.idfsParameter,',')
		FROM
			(
				SELECT
					 DISTINCT idfsParameter
				FROM
					ffParameterForAction
				WHERE
					idfsRule = @idfsRule
			) AS P

		--Get the details of the rule selected
		SELECT
			DISTINCT
			R.idfsRule,
			RN.strDefault		AS defaultRuleName,
			RN.name				AS RuleName,
			R.idfsRuleMessage,
			RM.strDefault		AS defaultRuleMessage,
			RM.name				AS RuleMessage,
			R.idfsCheckPoint,
			R.idfsRuleFunction,
			R.blnNot,
			PFA.idfsRuleAction	AS idfsRuleAction,
			@ActionParameters	AS strActionParameters,
			PFF.idfsParameter	AS idfsFunctionParameter,
			PFA.strFillValue	AS FillValue
		FROM
			ffRule R
		LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangId, 19000029) RN
			ON RN.idfsReference = R.idfsRule
		LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangId, 19000032) RM
			ON RM.idfsReference = R.idfsRuleMessage
		LEFT JOIN ffParameterForFunction PFF
			ON PFF.idfsRule = R.idfsRule
		LEFT JOIN ffParameterForAction PFA
			ON PFA.idfsRule = R.idfsRule
		WHERE
			R.idfsRule = @idfsRule
		
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END


