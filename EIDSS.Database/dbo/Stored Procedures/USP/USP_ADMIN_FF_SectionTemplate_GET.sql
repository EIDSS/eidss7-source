
-- ================================================================================================
-- Name: USP_ADMIN_FF_SectionTemplate_GET
-- Description: Return the section Template
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Doug Albanese	6/8/2020	Change to pick up data that was cut off by mis use of intRowStatus
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_SectionTemplate_GET] (
	@idfsSection BIGINT = NULL
	,@idfsFormTemplate BIGINT = NULL
	,@LangID NVARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @langid_int BIGINT
		,@returnCode BIGINT
		,@returnMsg NVARCHAR(MAX)

	BEGIN TRY
		IF (@LangID IS NULL)
			SET @LangID = 'en';
		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);

		SELECT ST.[idfsSection]
			,S.[idfsParentSection]
			,S.[idfsFormType]
			,ST.[idfsFormTemplate]
			,T.strDefault AS TemplateName
			,ST.[blnFreeze] AS [blnFreeze]
			,S.[blnFixedRowSet]
			,B.[strDefault] AS [DefaultName]
			,ISNULL(SNT.[strTextString], B.[strDefault]) AS [NationalName]
			,S.blnGrid
			,SDO.intOrder AS [intOrder]
			,CAST(CASE 
					WHEN dbo.FN_ADMIN_FF_DesignLanguageForParameter_GET(@LangID, ST.[idfsSection], @idfsFormTemplate) = @langid_int
						THEN 1
					ELSE 0
					END AS BIT) AS [blnIsRealStruct]
			,S.idfsMatrixType
		FROM [dbo].[ffSectionForTemplate] ST
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000033) T ON T.idfsReference = ST.idfsFormTemplate
		LEFT JOIN dbo.ffSectionDesignOption SDO ON ST.idfsSection = SDO.idfsSection
			AND ST.idfsFormTemplate = SDO.idfsFormTemplate
			AND SDO.idfsLanguage = dbo.fnFFGetDesignLanguageForSection(@LangID, ST.[idfsSection], @idfsFormTemplate)
		INNER JOIN dbo.ffSection S ON ST.idfsSection = S.idfsSection
			AND S.[intRowStatus] = 0
		INNER JOIN dbo.trtBaseReference B ON B.[idfsBaseReference] = S.[idfsSection]
			AND B.[intRowStatus] = 0
		LEFT JOIN dbo.trtStringNameTranslation SNT ON (
				SNT.[idfsBaseReference] = S.[idfsSection]
				AND SNT.idfsLanguage = @langid_int
				)
			AND SNT.[intRowStatus] = 0
		WHERE (
				(ST.[idfsFormTemplate] = @idfsFormTemplate)
				OR (@idfsFormTemplate IS NULL)
				)
			AND (
				(
					ST.[idfsSection] = @idfsSection
					OR @idfsSection IS NULL
					)
				)
			AND (ST.[intRowStatus] = 0)
		ORDER BY [NationalName]
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
