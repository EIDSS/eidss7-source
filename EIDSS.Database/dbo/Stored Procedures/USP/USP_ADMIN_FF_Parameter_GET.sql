-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameter_GET
-- Description: Gets list of the Parameters.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	2/10/2020	Initial release for single parameter grab for Flex Form Editor.
-- Doug Albanese	07/14/2021	Added Parameter Type for return
-- Doug Albanese	03/21/2023	Swapped out the language id function with the new method
-- ================================================================================================
/*
exec dbo.spFFGetParameters 'en', null, 10034012
*/
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Parameter_GET] (
	@LangID NVARCHAR(50) = NULL
	,@idfsParameter BIGINT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@LangID IS NULL)
		SET @LangID = 'en';

	DECLARE @langid_int BIGINT
		,@returnCode BIGINT
		,@returnMsg NVARCHAR(MAX)
	DECLARE @ParameterUsed AS BIT

	BEGIN TRY
		SET @langid_int =dbo.FN_GBL_LanguageCode_GET(@LangID)
		
		IF (EXISTS(SELECT TOP 1 1 
			FROM dbo.tlbActivityParameters
			WHERE [idfsParameter] = @idfsParameter))
		SET @ParameterUsed = 1;

		SELECT P.idfsEditor
			,ISNULL(E.strDefault, '') AS [Editor]
			,P.idfsParameterType
			,ISNULL(FR1.[name], FR1.[strDefault]) AS [ParameterTypeName]
			,ISNULL(B2.[strDefault], '') AS [DefaultName]
			,ISNULL(B1.[strDefault], '') AS [DefaultLongName]
			,ISNULL(SNT2.[strTextString], B2.[strDefault]) AS [NationalName]
			,ISNULL(SNT1.[strTextString], B1.[strDefault]) AS [NationalLongName],
			coalesce(@ParameterUsed,0) As ParameterUsed
		FROM [dbo].[ffParameter] P
		INNER JOIN dbo.trtBaseReference B1 ON B1.[idfsBaseReference] = P.[idfsParameter]
			AND B1.[intRowStatus] = 0
		LEFT JOIN dbo.trtBaseReference B2 ON B2.[idfsBaseReference] = P.[idfsParameterCaption]
			AND B2.[intRowStatus] = 0
		LEFT JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000071) FR1 ON FR1.[idfsReference] = P.[idfsParameterType]
		LEFT JOIN dbo.trtStringNameTranslation SNT1 ON (
				SNT1.[idfsBaseReference] = P.[idfsParameter]
				AND SNT1.[idfsLanguage] = @langid_int
				)
			AND SNT1.[intRowStatus] = 0
		LEFT JOIN dbo.trtStringNameTranslation SNT2 ON (
				SNT2.[idfsBaseReference] = P.[idfsParameterCaption]
				AND SNT2.[idfsLanguage] = @langid_int
				)
			AND SNT2.[intRowStatus] = 0
		LEFT JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000067) E ON E.idfsReference = P.idfsEditor
		WHERE P.idfsParameter = @idfsParameter
			AND P.intRowStatus = 0
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
