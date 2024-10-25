
-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameters_GET
-- Description: Gets list of the Parameters.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru	11/28/2018	Initial release for new API.
-- Doug Albanese	05/17/2021	Changed INNER Join to LEFT Join to pull parameters from ffParameterDesignOption table.
-- Doug Albanese	05/17/2021	Coalesce values for non ffParameterDesignOption entries.
-- Doug Albanese	05/19/2021	Corrected situation to pull parameters for sectionless association
-- Mark Wilson		09/30/2021	added @idfsLanguage and changed FN_GBL_ReferenceRepair_GET
-- Doug Albanese	03/30/2022	Removed the MatrixColumn grab, since its ID wasn't compatible with idfParameter
--	Doug Albanese	05/09/2022	Problem with returning parameters and sections
--	Doug Albanese	07/20/2022	Further refining to elminate bad ffParameterDesignOption records
--	Doug Albanese	07/20/2022	Removed the join to ffParameterDesignOption, because that information 
--								isn't really needed and causing duplicatiosn that can't be resolved.
-- ================================================================================================
/*

exec dbo.USP_ADMIN_FF_Parameters_GET 'en-US', null, 10034022

*/
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Parameters_GET]
(
	@LangID NVARCHAR(50) = NULL
	,@idfsSection BIGINT = NULL
	,@idfsFormType BIGINT = NULL
	,@SectionIDs NVARCHAR(MAX) = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID)

	IF @SectionIDs IS NULL
		BEGIN
			SET @SectionIDs = @idfsSection
		END

	--IF (@LangID IS NULL) SET @LangID = 'en';
	
	DECLARE @SearchType VARCHAR(50)

	IF @idfsFormType IS NOT NULL
	BEGIN
		SET @SearchType = 'Form'
	END

	BEGIN TRY
	
		SELECT P.[idfsParameter]
			   ,P.[idfsSection] -- null
			   ,P.[idfsFormType] 
			   --,COALESCE(FPRO.[intScheme],0) AS intScheme -- 0
			   ,P.[idfsParameterType] -- string const
			   ,ISNULL(FR1.[name],FR1.[strDefault]) AS [ParameterTypeName]  --   
			   ,P.[idfsEditor] --,P.[intControlType] -- text box
			   ,P.[idfsParameterCaption] -- null
			   ,P.[intOrder] -- intorder from stub
			   ,ISNULL(P.[strNote], '') AS [strNote] -- null
			   ,ISNULL(P.[intHACode], -1) AS [intHACode] -- null
			   --,COALESCE(FPRO.[intLabelSize],0) AS [intLabelSize] -- 0
			   --,COALESCE(FPRO.[intTop],0) AS [intTop] -- 0
			   --,COALESCE(FPRO.[intLeft],0) AS [intLeft]-- 0
			   --,COALESCE(FPRO.[intWidth],0) AS [intWidth] -- to column new field
			   --,COALESCE(FPRO.[intHeight],0) AS [intHeight] -- 0
			   --,FPRO.[idfsFormTemplate] -- null    
			   ,P.[intRowStatus] --0
			   ,ISNULL(B2.[strDefault], '') AS [DefaultName]
			   ,ISNULL(B1.[strDefault], '') AS [DefaultLongName]
			   ,ISNULL(SNT2.[strTextString], B2.[strDefault]) AS [NationalName]
			   ,ISNULL(SNT1.[strTextString], B1.[strDefault]) AS [NationalLongName]
			   ,@LangID AS [langid]
			   ,1 AS [IsRealParameter]
		FROM [dbo].[ffParameter] P
		INNER JOIN dbo.trtBaseReference B1
		ON B1.[idfsBaseReference] = P.[idfsParameter]
		   AND B1.[intRowStatus] = 0
		--LEFT JOIN dbo.ffParameterDesignOption FPRO ON P.[idfsParameter] = FPRO.[idfsParameter] AND FPRO.idfsLanguage = @idfsLanguage
		--   AND FPRO.[intRowStatus] = 0 AND FPRO.idfsFormTemplate IS NOT NULL
		LEFT JOIN dbo.trtBaseReference B2
		ON B2.[idfsBaseReference] = P.[idfsParameterCaption]
		   AND B2.[intRowStatus] = 0
		LEFT JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000071 /*'rftParameterType'*/) FR1
		ON FR1.[idfsReference] = P.[idfsParameterType]
		LEFT JOIN dbo.trtStringNameTranslation SNT1
		ON (SNT1.[idfsBaseReference] = P.[idfsParameter]
			AND SNT1.[idfsLanguage] = @idfsLanguage)
		   AND SNT1.[intRowStatus] = 0
		LEFT JOIN dbo.trtStringNameTranslation SNT2
		ON (SNT2.[idfsBaseReference] = P.[idfsParameterCaption]
			AND SNT2.[idfsLanguage] = @idfsLanguage)
		   AND SNT2.[intRowStatus] = 0
		WHERE ((@idfsSection IS NULL AND P.idfsSection IS NULL) OR (P.idfsSection IN (SELECT CAST(value AS BIGINT) AS idfsSection FROM FN_GBL_SYS_SplitList(@SectionIDs,0,','))))
			  AND (P.idfsFormType = @idfsFormType OR @idfsFormType IS NULL)
			  --AND (FPRO.idfsFormTemplate IS NULL)	
			  AND (P.intRowStatus = 0)
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END

