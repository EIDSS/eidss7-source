
-- ================================================================================================
-- Name: USP_ADMIN_FF_TemplateRules_GETList
-- Description: Returns the list of rules for hte template.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	10/12/2020	Initial release for new API.
-- Doug Albanese	10/29/2020	Added "Fill with value" for newly added action
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_TemplateRules_GETList]
(
	@LangID					NVARCHAR(50) = 'en'	
	,@idfsFormTemplate		BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT 
			r.idfsRule,
			r.idfsCheckPoint,
			r.idfsRuleFunction,
			r.blnNot,
			pff.idfParameterForFunction,
			pff.idfsParameter							AS FunctionParameter,
			STRING_AGG(pfa.idfsRuleAction ,',')			AS ActionRules,
			STRING_AGG(pfa.idfsParameter,',')			AS ActionParameters,
			pfa.strFillValue,
			mt.name										AS MessageText
		FROM 
			ffRule r
		INNER JOIN ffParameterForFunction pff
		ON pff.idfsRule = r.idfsRule and pff.intRowStatus = 0
		INNER JOIN ffParameterForAction pfa
		ON pfa.idfsRule = pff.idfsRule and pfa.intRowStatus = 0
		INNER JOIN FN_GBL_Reference_GETList(@LangID,19000032) mt
		ON mt.idfsReference = r.idfsRuleMessage

		WHERE
			r.idfsFormTemplate = @idfsFormTemplate AND
			r.intRowStatus = 0
		GROUP BY
			r.idfsRule,
			r.idfsCheckPoint,
			r.idfsRuleFunction,
			r.blnNot,
			pff.idfsParameter,
			pff.idfParameterForFunction,
			pff.idfsParameter,
			pfa.strFillValue,
			mt.name

   
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END


