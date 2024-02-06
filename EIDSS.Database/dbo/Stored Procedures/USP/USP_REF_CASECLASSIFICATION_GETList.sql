
-- ================================================================================================
-- Name: USP_REF_CaseClassification_GETList
--
-- Description:	Get the Case Classification for reference listings.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/25/2018 Initial release.
-- Ricky Moss		12/19/2018 Removed return codes.
-- Stephen Long     12/26/2019 Replaced 'en' with @LangID on reference call.
-- Steven Verner	03/22/2021 Added paging
-- Ann Xiong		07/14/2021  Fixed default sorting order.
-- Ann Xiong		08/05/2021	Updated default sorting order.

-- exec USP_REF_CASECLASSIFICATION_GETList 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_CASECLASSIFICATION_GETList] 
(
	 @langID NVARCHAR(50) = NULL
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'intOrder' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsCaseClassification bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			intOrder int,
			blnInitialHumanCaseClassification bit,
			blnFinalHumanCaseClassification bit,
			intHACode int,
			strHACode nvarchar(4000), 
			strHACodeNames nvarchar(4000)
			)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		IF( @advancedSearch IS NOT NULL )
			INSERT INTO @T
			SELECT * FROM 
				(
				SELECT CC.idfsCaseClassification,
					CCName.strDefault AS [strDefault],
					ISNULL(CCName.name, CCName.strDefault) AS [strName],
					ISNULL(CCName.intOrder, 0) AS [intOrder],
					ISNULL(CC.blnInitialHumanCaseClassification, CAST(0 AS BIT)) AS blnInitialHumanCaseClassification,
					ISNULL(CC.blnFinalHumanCaseClassification, CAST(0 AS BIT)) AS blnFinalHumanCaseClassification,
					CCName.intHACode,
					dbo.FN_GBL_HACode_ToCSV(@LangID, CCName.intHACode) AS [strHACode],
					dbo.FN_GBL_HACodeNames_ToCSV(@LangID, CCName.intHACode) AS [strHACodeNames]
				FROM dbo.trtCaseClassification CC
				INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011) CCName
					ON CC.idfsCaseClassification = CCName.idfsReference
				LEFT JOIN dbo.trtHACodeList HACodeList
					ON CCName.intHACode = HACodeList.intHACode
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000040) HACodes
					ON HACodeList.idfsCodeName = HACodes.idfsReference
				WHERE CC.intRowStatus = 0
				) AS I
				WHERE 
					CAST( idfsCaseClassification AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR
					strDefault LIKE '%' + @advancedSearch + '%' OR
					intHACode LIKE '%' + @advancedSearch + '%' OR
					strHACode LIKE '%' + @advancedSearch + '%' OR
					strHACodeNames LIKE '%' + @advancedSearch + '%' 
				--ORDER BY intOrder, strDefault
		ELSE
			INSERT INTO @T
			SELECT CC.idfsCaseClassification,
				CCName.strDefault AS [strDefault],
				ISNULL(CCName.name, CCName.strDefault) AS [strName],
				ISNULL(CCName.intOrder, 0) AS [intOrder],
				ISNULL(CC.blnInitialHumanCaseClassification, CAST(0 AS BIT)) AS blnInitialHumanCaseClassification,
				ISNULL(CC.blnFinalHumanCaseClassification, CAST(0 AS BIT)) AS blnFinalHumanCaseClassification,
				CCName.intHACode,
				dbo.FN_GBL_HACode_ToCSV(@LangID, CCName.intHACode) AS [strHACode],
				dbo.FN_GBL_HACodeNames_ToCSV(@LangID, CCName.intHACode) AS [strHACodeNames]
			FROM dbo.trtCaseClassification CC
			INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011) CCName
				ON CC.idfsCaseClassification = CCName.idfsReference
			LEFT JOIN dbo.trtHACodeList HACodeList
				ON CCName.intHACode = HACodeList.intHACode
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000040) HACodes
				ON HACodeList.idfsCodeName = HACodes.idfsReference
			WHERE CC.intRowStatus = 0
			--ORDER BY CCName.intOrder,
			--	strDefault
			;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsCaseClassification' AND @SortOrder = 'asc' THEN idfsCaseClassification END ASC,
				CASE WHEN @sortColumn = 'idfsCaseClassification' AND @SortOrder = 'desc' THEN idfsCaseClassification END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'asc' THEN intHACode END ASC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'desc' THEN intHACode END DESC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'asc' THEN strHACode END ASC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'desc' THEN strHACode END DESC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'asc' THEN strHACodeNames END ASC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'desc' THEN strHACodeNames END DESC
				,IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsCaseClassification,
				strDefault,
				strName,	
				intOrder,
				blnInitialHumanCaseClassification,
				blnFinalHumanCaseClassification,
				intHACode,
				strHACode,
				strHACodeNames
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfsCaseClassification,
				strDefault,
				strName,	
				intOrder,
				blnInitialHumanCaseClassification,
				blnFinalHumanCaseClassification,
				intHACode,
				strHACode,
				strHACodeNames,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
