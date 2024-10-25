

--*************************************************************
-- Name 				: USP_GBL_LKUP_BaseRef_GetList
-- Description			: List filered values from tlbBaseReferene table
--          
-- Author               : Maheshwar D Deo
-- Revision History
--		Name		Date		Change Detail
-- Maheshwar Deo	05/27/2018	Fixed issue with script when parameter @intHACode is 0
-- Maheshwar Deo	05/30/2018	Fixed issue with script for second table
--
--@intHACode Code List
--0		None
--2		Human
--4		Exophyte
--8		Plant
--16	Soil
--32	Livestock
--64	Avian
--128	Vector
--256	Syndromic
--510	All	
--
-- Testing code:
-- Exec USP_GBL_LKUP_BaseRef_GetList 'EN', 'Diagnosis', 2
--*************************************************************

CREATE PROCEDURE [dbo].[USP_GBL_LKUP_BaseRef_GetList] 
(
	@LangID				NVARCHAR(50)		
	,@ReferenceTypeName VARCHAR(400)	= NULL
	,@intHACode			BIGINT			= 0		--None 
)
AS

	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	DECLARE @HAList TABLE(
		intHACode INT

	)

	IF @intHACode IS NOT NULL
	INSERT INTO @HAList
	(
	    intHACode
	)
	SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax)

	BEGIN TRY

		SELECT 
			br.idfsBaseReference,
			br.idfsReferenceType,
			br.strBaseReferenceCode,
			br.strDefault,
			ISNULL(s.strTextString, br.strDefault) AS [name],
			br.intHACode,
			br.intOrder,
			br.intRowStatus,
			br.blnSystem,
			rt.intDefaultHACode,
			CASE WHEN ISNULL(@intHACode,0) = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode 

		FROM dbo.trtBaseReference br
		INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
		LEFT JOIN dbo.trtHACodeList HA ON HA.intHACode = br.intHACode
		LEFT JOIN dbo.trtBaseReference HAR ON HAR.idfsBaseReference = HA.idfsCodeName
		
		WHERE ((EXISTS 
				(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
				INTERSECT 
				SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
				OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
		AND	br.intRowStatus = 0	
		AND rt.strReferenceTypeName = IIF(@ReferenceTypeName IS NOT NULL, @ReferenceTypeName, rt.strReferenceTypeName )
		
		ORDER BY 
			br.intOrder,
			[name]

	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;

