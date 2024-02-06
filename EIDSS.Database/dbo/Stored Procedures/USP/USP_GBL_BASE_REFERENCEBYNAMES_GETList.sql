
--*************************************************************************************************
-- Name: [USP_GBL_BASE_REFERENCEBYNAMES_GETList]
--
-- Description: List filered values from tlbBaseReference table By one or Many reference Names.
--          
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Lamont Mitchel   08/08/2019 Initial release.
--
-- @intHACode Code List
-- 0	None
-- 2	Human
-- 4	Exophyte
-- 8	Plant
-- 16	Soil
-- 32	Livestock
-- 64	Avian
-- 128	Vector
-- 256	Syndromic
-- 510	All	
--
-- Testing code:
-- Exec USP_GBL_BaseRef_LKUP 'EN', 'Diagnosis', 128
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_BASE_REFERENCEBYNAMES_GETList] 
(
	@LangID	NVARCHAR(50)		
	,@ReferenceTypeName VARCHAR(400) = NULL
	,@intHACode	BIGINT = 0 -- None
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;

	BEGIN TRY

		SELECT 
			DISTINCT
			TOP 100 PERCENT
				br.idfsBaseReference
				,br.idfsReferenceType
				,br.strBaseReferenceCode
				,br.strDefault
				,ISNULL(s.strTextString, br.strDefault) AS [name]
				,br.intHACode
				,br.intOrder
				,br.intRowStatus
				,br.blnSystem
				,rt.intDefaultHACode
				,dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) AS strHACode,
				rt.strReferenceTypeName
			FROM dbo.trtBaseReference br
				INNER JOIN trtReferenceType AS rt 
					ON rt.idfsReferenceType = br.idfsReferenceType
						AND rt.strReferenceTypeName in ( Select value from STRING_SPLIT(@ReferenceTypeName,','))--AND	rt.strReferenceTypeName = CASE ISNULL(@ReferenceTypeName, '') WHEN '' THEN rt.strReferenceTypeName ELSE @ReferenceTypeName END
				LEFT JOIN trtStringNameTranslation AS s 
					ON br.idfsBaseReference = s.idfsBaseReference 
						AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
				INNER JOIN (SELECT intHACode FROM dbo.FN_GBL_SplitHACode(ISNULL(@intHACode, 0), @HACodeMax)) HACodeList 
					ON (HACodeList.intHACode IN (SELECT intHACode FROM dbo.FN_GBL_SplitHACode(ISNULL(br.intHACode, 0), @HACodeMax)) AND HACodeList.intHACode > 0)
				INNER JOIN trtHACodeList 
					ON HACodeList.intHACode = trtHACodeList.intHACode
			WHERE	
				ISNULL(br.intRowStatus, 0) = 0	
			ORDER BY 
			br.idfsReferenceType,
				br.intOrder
				,[name];
	END TRY  
	BEGIN CATCH 
		THROW;
	END CATCH;
