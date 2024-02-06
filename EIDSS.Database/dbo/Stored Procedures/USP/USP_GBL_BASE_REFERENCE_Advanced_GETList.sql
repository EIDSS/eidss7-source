

--*************************************************************************************************
-- Name: USP_GBL_BASE_REFERENCE_Advanced_GETList
--
-- Description: List filered values from tlbBaseReference table.
--          
-- Revision History:
-- Name				Date       Change Detail
-- ---------------	---------- --------------------------------------------------------------------
-- Doug Albanese	06/29/2019 Initial release.
-- Mike Kornegay	12/06/2021 Added sort by intOrder and then by name
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
	Exec USP_GBL_BASE_REFERENCE_Advanced_GETList 'en-US', 'Nationality List', 0
	Exec USP_GBL_BASE_REFERENCE_Advanced_GETList 'en-US', 'Case Status', 64
	Exec USP_GBL_BASE_REFERENCE_Advanced_GETList 'en-US', 'Diagnosis', 2
	EXEC USP_GBL_BASE_REFERENCE_Advanced_GETList 'en-US','Personal ID Type', 0
	EXEC USP_GBL_BASE_REFERENCE_Advanced_GETList 'en-US','Patient Location Type', 2
	EXEC USP_GBL_BASE_REFERen-USCE_Advanced_GETList 'en-US','Organization Type', 482
	EXEC USP_GBL_BASE_REFERENCE_Advanced_GETList 'en-US','Human Age Type', 2

*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_BASE_REFERENCE_Advanced_GETList] 
(
	@LangID	NVARCHAR(50),
	@ReferenceTypeName VARCHAR(400) = NULL,
	@intHACode	BIGINT = NULL,
	@advancedSearch NVARCHAR(100) = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'strName',
	@sortOrder NVARCHAR(4) = 'asc'
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	DECLARE @HAList TABLE(
		intHACode INT
	)

	IF @intHACode IS NOT NULL
		BEGIN
			INSERT INTO @HAList	(intHACode)
			SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax)
		END

	DECLARE @firstRec INT
	DECLARE @lastRec INT

	DECLARE @t TABLE( 
		idfsBaseReference		BIGINT, 
		--idfsReferenceType		BIGINT, 
		--strBaseReferenceCode	NVARCHAR(200),
		--strDefault				NVARCHAR(2000), 
		strName					NVARCHAR(2000),
		--intHACode				INT,
		--strHACode				NVARCHAR(4000),
		--strHACodeNames			NVARCHAR(4000),
		intOrder				INT
	)

	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		IF( @advancedSearch IS NOT NULL )
			BEGIN
				INSERT INTO @T
				SELECT * FROM
				(
					SELECT 
						br.idfsBaseReference,
						--br.idfsReferenceType,
						--br.strBaseReferenceCode,
						--br.strDefault,
						ISNULL(s.strTextString, br.strDefault) AS strName,
						--br.intHACode,
						br.intOrder
						--br.intRowStatus,
						--br.blnSystem,
						--rt.intDefaultHACode,
						--CASE WHEN ISNULL(@intHACode,0) = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode 

					FROM dbo.trtBaseReference br
					INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
					LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
					--LEFT JOIN dbo.trtHACodeList HA ON HA.intHACode = br.intHACode
					--LEFT JOIN dbo.trtBaseReference HAR ON HAR.idfsBaseReference = HA.idfsCodeName
		
					WHERE ((EXISTS 
							(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
							INTERSECT 
							SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
							OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
					AND	br.intRowStatus = 0	
					AND rt.strReferenceTypeName = IIF(@ReferenceTypeName IS NOT NULL, @ReferenceTypeName, rt.strReferenceTypeName )
		
					--ORDER BY 
					--	br.intOrder,
					--	[name]
				) AS S
				WHERE 
					(
					  --strDefault LIKE '%' + @advancedSearch + '%' OR
					  strName LIKE '%' + @advancedSearch + '%'
					)
			END
		ELSE
			BEGIN
				INSERT INTO @T
				SELECT 
					br.idfsBaseReference,
					ISNULL(s.strTextString, br.strDefault) AS strName,
					br.intOrder
				FROM dbo.trtBaseReference br
				INNER JOIN dbo.trtReferenceType AS rt ON rt.idfsReferenceType = br.idfsReferenceType
				LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LangID)
		
				WHERE ((EXISTS 
						(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
						INTERSECT 
						SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
						OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
				AND	br.intRowStatus = 0	
				AND rt.strReferenceTypeName = IIF(@ReferenceTypeName IS NOT NULL, @ReferenceTypeName, rt.strReferenceTypeName )
			END;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC,
				IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfsBaseReference, 
				strName,
				intOrder
			FROM @T
		)

		SELECT
			TotalRowCount,
			idfsBaseReference, 
			strName,
			intOrder,
			TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
			CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	

	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;
