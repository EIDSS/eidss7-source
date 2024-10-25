
-- ================================================================================================
-- Name: USP_ADMIN_FF_Rules_GETList
-- Description: Returns the list of rules for hte template.
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Doug Albanese   10/06/2020 Initial release for new API.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Rules_GETList]
(
	@LangID						NVARCHAR(50) = NULL	
	,@idfsFunctionParameter		BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	IF (@LangID IS NULL)
		SET @LangID = 'en';

	BEGIN TRY

		select 
			r.idfsRule,
			RN.name AS RuleName
			--r.idfsRuleMessage,
			--RM.name As RuleMessage
	
		from 
			ffParameterForFunction pff
		LEFT JOIN ffRule R
			ON R.idfsRule = pff.idfsRule
		LEFT JOIN trtBaseReference brn
			ON brn.idfsBaseReference = r.idfsRule
		--LEFT JOIN trtBaseReference brm
		--	ON brm.idfsBaseReference = r.idfsRuleMessage
		LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangId, 19000029) RN
			ON RN.idfsReference = R.idfsRule
		--LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangId, 19000032) RM
		--	ON RM.idfsReference = R.idfsRuleMessage
		where 
			pff.idfsParameter = @idfsFunctionParameter AND
			pff.intRowStatus = 0
   
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END


