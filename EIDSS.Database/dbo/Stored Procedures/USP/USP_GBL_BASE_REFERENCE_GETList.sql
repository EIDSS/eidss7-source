--*************************************************************************************************
-- Name: USP_GBL_BASE_REFERENCE_GETList
--
-- Description: List filered values from tlbBaseReference table.
--          
-- Revision History:
-- Name							Date		Change Detail
-- ---------------				----------	--------------------------------------------------------------------
-- Stephen Long					06/29/2019	Initial release.
-- Manickandan Govindarajan		11/24/2020	The IF query is getting the intHACode from basereference table but the
--											IntHACode is 0 for multiple records ex: 19000040 refrencetype
--											Updated the code to get intHACode from trtHACodeList table. It will help to filter in the app
--
-- Mark Wilson					12/16/2020  Updated to accept null HACode (when HACode is unnecessary)
-- Steven Verner				10/21/2022	Removed duplicate base reference types where there currently is an editor for those types
--											Like Age Group, Case Classification,etc.
--											This change fixes bugs 3865,4757,4756,4755,4750...
-- Doug Albanese				9/15/2023	Adding "Editor Settings" to the result of data.

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
/*
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Nationality List', 0
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Case Status', 64
	Exec USP_GBL_BASE_REFERENCE_GETList 'EN', 'Diagnosis', 2
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Personal ID Type', 0
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Patient Location Type', 2
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Organization Type', 482
	EXEC USP_GBL_BASE_REFERENCE_GETList 'en','Human Age Type', 2

*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_BASE_REFERENCE_GETList] 
(
	@LangID	NVARCHAR(50),
	@ReferenceTypeName VARCHAR(400) = NULL,
	@intHACode	BIGINT = NULL 
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	DECLARE @HAList TABLE(
		intHACode INT

	)

	DECLARE @trtBaseReference TABLE (
	    idfsBaseReference	  BIGINT,
		idfsReferenceType	  BIGINT,
		strBaseReferenceCode  NVARCHAR(200),
		strDefault			  NVARCHAR(200),
		[name]				  NVARCHAR(200),
		intHACode			  INT,
		intOrder			  INT,
		intRowStatus		  INT,
		blnSystem			  BIT,
		intDefaultHACode	  BIGINT,
		strHACode			  NVARCHAR(200),
		EditorSettings		  BIGINT
	)

	IF @intHACode IS NOT NULL
	INSERT INTO @HAList
	(
	    intHACode
	)
	SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax)

	BEGIN TRY
		INSERT INTO @trtBaseReference
		SELECT 
			br.idfsBaseReference,
			br.idfsReferenceType,
			br.strBaseReferenceCode,
			strDefault = CASE WHEN @ReferenceTypeName = 'Disease' THEN
				(SELECT TOP 1 ISNULL(sg.strTextString, brg.strDefault)FROM trtDiagnosisToDiagnosisGroup dg
				INNER Join dbo.trtBaseReference brg ON dg.idfsDiagnosisGroup = brg.idfsBaseReference
				LEFT JOIN dbo.trtStringNameTranslation AS sg ON brg.idfsBaseReference = sg.idfsBaseReference AND sg.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
				WHERE dg.idfsDiagnosis = br.idfsBaseReference AND brg.strDefault IS NOT NULL)
			ELSE br.strDefault END,
			ISNULL(s.strTextString, br.strDefault) AS [name],
			br.intHACode,
			br.intOrder,
			br.intRowStatus,
			br.blnSystem,
			rt.intDefaultHACode,
			CASE WHEN ISNULL(@intHACode,0) = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode,
			EditorSettings
		FROM dbo.trtBaseReference br
		INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
		LEFT JOIN dbo.trtHACodeList HA ON HA.intHACode = br.intHACode
		LEFT JOIN dbo.trtBaseReference HAR ON HAR.idfsBaseReference = HA.idfsCodeName
		
		WHERE 
			br.idfsBaseReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
												 19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
												 19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
												 19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,19000147,
												 19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
												 19000140)
			AND	
			br.intRowStatus = 0	
			AND
		((EXISTS 
				(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
				INTERSECT 
				SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
				OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
		AND rt.strReferenceTypeName = IIF(@ReferenceTypeName IS NOT NULL, @ReferenceTypeName, rt.strReferenceTypeName )
		
		ORDER BY 
			br.intOrder,
			[name]

		 UPDATE @trtBaseReference
		 SET EditorSettings = RT.EditorSettings
		 FROM trtReferenceType RT
		 WHERE RT.idfsReferenceType = idfsBaseReference

		 SELECT
			idfsBaseReference,
			idfsReferenceType,
			strBaseReferenceCode,
			strDefault,
			[name],
			intHACode,
			intOrder,
			intRowStatus,
			blnSystem,
			intDefaultHACode,
			strHACode,
			EditorSettings
		 FROM
			@trtBaseReference
	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;
