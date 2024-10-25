
-- ================================================================================================
-- Name: USP_ADMIN_FF_Template_GetDetail
-- Description: Obtain details for a Template
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	02/11/2020	Initial release for new API.
-- Doug Albanese	07/14/2021	Added DefaultName for consumption by needed processes
--	Doug Albanese	05/27/2022	Removed RollBack, since this is just a detail call
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Template_GetDetail] 
(
    @LangID NVARCHAR(50)
	,@idfsFormTemplate BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		@langid_int BIGINT, 
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX) 

	--IF (@LangID IS NULL)
	--	SET @LangID = 'en';	

	SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);

	BEGIN TRY
			
		SELECT
	        FT.idfsFormTemplate
			,FT2.strDefault AS FormTemplate
			,FT2.strDefault AS DefaultName
			,ISNULL(SNT.strTextString, FT2.strDefault) AS NationalName
			,FT.idfsFormType			   
			,FT.strNote
			,FT.blnUNI
		FROM 
			ffFormTemplate FT
		INNER JOIN		dbo.trtBaseReference B
		ON B.idfsBaseReference = FT.idfsFormTemplate
			AND B.intRowStatus = 0
		INNER JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000033) FT2
		ON				FT2.idfsReference = FT.idfsFormTemplate
		LEFT JOIN dbo.trtStringNameTranslation SNT
		ON SNT.[idfsBaseReference] = FT.[idfsFormTemplate]
		   AND SNT.idfsLanguage = @langid_int
		   AND SNT.[intRowStatus] = 0
		WHERE
			idfsFormTemplate = @idfsFormTemplate
	
		--SELECT @returnCode, @returnMsg
		
	END TRY 
	BEGIN CATCH   
		--IF @@TRANCOUNT > 0
		--	ROLLBACK TRANSACTION;
	
		--THROW;
	END CATCH;
END
