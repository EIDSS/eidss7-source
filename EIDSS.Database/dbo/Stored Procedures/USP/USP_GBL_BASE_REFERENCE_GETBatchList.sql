


--*************************************************************************************************
-- Name: USP_GBL_BASE_REFERENCE_GETList
--
-- Description: List filered values from tlbBaseReference table.
--          
-- Revision History:
-- Name				Date		Change Detail
-- Doug Albanese	02/08/2021	New bulk listing procedure.
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
CREATE PROCEDURE [dbo].[USP_GBL_BASE_REFERENCE_GETBatchList] 
(
	@LangID					NVARCHAR(50),
	@ReferenceTypeNames		NVARCHAR(MAX) = NULL,
	@intHACodes				NVARCHAR(MAX) = NULL
)
AS




	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	
	DECLARE @intHACode			INT
	DECLARE @ReferenceTypeName	NVARCHAR(MAX)

	DECLARE @FinalResults TABLE (
		idfsBaseReference		BIGINT,
		strReferenceType		NVARCHAR(MAX),
		[name]					NVARCHAR(MAX),
		intHACode				INT
	)

	DECLARE @tHAList TABLE(
		intHACode INT
	)

	DECLARE @tReferenceTypeName TABLE (
		ReferenceTypeName	NVARCHAR(400)
	)
	
	IF @ReferenceTypeNames IS NOT NULL
		BEGIN
			INSERT INTO @tReferenceTypeName (ReferenceTypeName) 
			SELECT 
				CAST([Value] AS NVARCHAR) AS ReferenceTypeName 
			FROM 
				dbo.FN_GBL_SYS_SplitList(@ReferenceTypeNames,'',',')
		END
	
	IF @intHACodes IS NOT NULL
		BEGIN
			INSERT INTO @tHAList (intHACode)
			SELECT 
				CAST([Value] AS INT) AS intHACode
			FROM 
				dbo.FN_GBL_SYS_SplitList(@intHACodes,'',',')
		END

	BEGIN TRY
		WHILE EXISTS(SELECT 1 FROM @tHAList)
			BEGIN
			
				SELECT
					TOP 1
					@ReferenceTypeName = ReferenceTypeName
				FROM
					@tReferenceTypeName

				SELECT
					TOP 1
					@intHACode = intHACode
				FROM
					@tHAList

				INSERT INTO @FinalResults
				SELECT 
					br.idfsBaseReference,
					@ReferenceTypeName AS strReferenceType,
					ISNULL(s.strTextString, br.strDefault) AS [name],
					br.intHACode
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
				AND rt.strReferenceTypeName = @ReferenceTypeName
				AND	br.intRowStatus = 0	
		
				ORDER BY 
					br.intOrder,
					[name]
			
				SET ROWCOUNT 1

				DELETE FROM @tReferenceTypeName
				DELETE FROM @tHAList

				SET ROWCOUNT 0

			END

		SELECT
			COALESCE(idfsBaseReference,0) AS idfsBaseReference,
			COALESCE(strReferenceType,'') AS strReferenceType,
			COALESCE([name],'') AS [name],
			COALESCE(intHACode,0) AS intHACode
		FROM
			@FinalResults

	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;


	WrapUp:

	RETURN
