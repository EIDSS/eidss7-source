

--*************************************************************
-- Name 				: report.USP_GBL_LKUP_BaseRef_GetList 
-- Description			: List filered values from tlbBaseReferene table
--          
-- Author               : Maheshwar D Deo
-- Revision History
--		Name		Date		Change Detail
-- Maheshwar Deo	05/27/2018	Fixed issue with script when parameter @intHACode is 0
-- Maheshwar Deo	05/30/2018	Fixed issue with script for second table
-- Srini Goli		04/08/2020  Modified foe Reports, added emplty row for Reports.
--					08/09/2021  Modified the code based on dbo.USP_GBL_BASE_REFERENCE_GETList Procedure
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
-- NOTE: Created based on [dbo].[USP_GBL_LKUP_BaseRef_GetList] From Application database
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Diagnoses Groups', 2 
--Human Abberation Analysis
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Diagnosis', 2  
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Case Report Type', 2  --Report Type
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Case Classification', 2 
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Organization Type', 2 
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Human Gender', 2 
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Statistical Period Type', 0  --Time Unit
--ILI Abbaration Analysis Report
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Age Groups', 2  --Age Groups
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Basic Syndromic Surveillance - Aggregate Columns'
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Organization Abbreviation', 2  --Hospital
--Veterinary Abberation Analysis
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Case type', 96  --LiveStock and Avain
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Organization Abbreviation', 96  --Hospital
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Diagnosis', 32 for LiveStock, 64 for Avian, 96 for both 
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Case Classification', 96
-- EXEC report.USP_GBL_LKUP_BaseRef_GetList 'en', 'Case Report Type', 96  --Report Type
--*************************************************************

CREATE PROCEDURE [Report].[USP_GBL_LKUP_BaseRef_GetList] 
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
			0 as idfsBaseReference,
			0 as idfsReferenceType,
			'' as strBaseReferenceCode,
			'' as strDefault,
			'' [name],
			0 as intHACode,
			0 as intOrder,
			0 as intRowStatus,
			0 as blnSystem,
			0 as intDefaultHACode,
			'' AS strHACode 
		UNION ALL
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
			intOrder,
			[name]

	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;


