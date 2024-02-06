

-- ============================================================================
-- Name: USP_REF_SPECIESTYPE_GETList
-- Description:	Get the Species Type for reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss       10/11/2018 Initial release.
-- Ricky Moss		12/12/2018	Removed return code, HA Code list and reference id variables
-- Ricky Moss		01/27/2019	Replaced deprecating reference function
-- Ricky Moss		08/15/2019	add in
-- Ricky Moss		10/02/2019  added strHACode
-- Ricky Moss		05/12/2020  added search parameter
-- Steven Verner	03/20/2021	Added paging.
-- Doug Albanese	08/03/2021	Removed unneccesarry ording, and added a CTE expression to cover for a second column of sorting on intOrder
--
-- exec USP_REF_SPECIESTYPE_GETList 'en-us', 'b'
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_SPECIESTYPE_GETList] 
(
	 @langID AS NVARCHAR(50),
	 @strSpeciesType AS NVARCHAR(50) = NULL
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strName' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsSpeciesType bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			strCode nvarchar(50), 
			intHACode int,
			strHACode nvarchar(4000), 
			strHACodeNames nvarchar(4000), 
			intOrder int)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		-- 
		IF ( @advancedSearch IS NOT NULL )
		BEGIN
		INSERT INTO @T
			SELECT * FROM
			(
				SELECT 
				tst.idfsSpeciesType
				,sl.strDefault
				,sl.[name] AS strName
				,tst.strCode
				,sl.intHACode
				,dbo.FN_GBL_HACode_ToCSV(@LangID, sl.intHACode) as [strHACode]
				,dbo.FN_GBL_HACodeNames_ToCSV(@LangID, sl.[intHACode]) AS [strHACodeNames]
				,sl.intOrder
			FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) sl 
			INNER JOIN trtSpeciesType tst 
			ON tst.idfsSpeciesType = sl.idfsReference
			WHERE (sl.intHACode IS NULL OR sl.intHACode > 0)
				AND TST.intRowStatus = 0
			) AS S
			WHERE (	
				CAST( idfsSpeciesType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR
				strDefault LIKE '%' + @advancedSearch + '%' OR 
				strName LIKE '%' + @advancedSearch + '%' OR 
				strCode LIKE '%' + @advancedSearch + '%' OR 
				CAST( intHACode AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR
				strHACodeNames LIKE '%' + @advancedSearch + '%')
			--ORDER BY strName
		END ELSE IF @strSpeciesType IS NULL
		BEGIN
			INSERT INTO @T
			SELECT 
				tst.idfsSpeciesType
				,sl.strDefault
				,sl.[name] AS strName
				,tst.strCode
				,sl.intHACode
				,dbo.FN_GBL_HACode_ToCSV(@LangID, sl.intHACode) as [strHACode]
				,dbo.FN_GBL_HACodeNames_ToCSV(@LangID, sl.[intHACode]) AS [strHACodeNames]
				,sl.intOrder
			FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) sl 
			INNER JOIN trtSpeciesType tst 
			ON tst.idfsSpeciesType = sl.idfsReference
			WHERE (sl.intHACode IS NULL 
				OR sl.intHACode > 0)
				AND TST.intRowStatus = 0
			--ORDER BY sl.[name] 
		END ELSE IF( @strSpeciesType IS NOT NULL )
		BEGIN
			INSERT INTO @T
			SELECT * FROM
			(
				SELECT 
				tst.idfsSpeciesType
				,sl.strDefault
				,sl.[name] AS strName
				,tst.strCode
				,sl.intHACode
				,dbo.FN_GBL_HACode_ToCSV(@LangID, sl.intHACode) as [strHACode]
				,dbo.FN_GBL_HACodeNames_ToCSV(@LangID, sl.[intHACode]) AS [strHACodeNames]
				,sl.intOrder
			FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) sl 
			INNER JOIN trtSpeciesType tst 
			ON tst.idfsSpeciesType = sl.idfsReference
			WHERE (sl.intHACode IS NULL OR sl.intHACode > 0)
				AND TST.intRowStatus = 0
			) AS S
			WHERE (strName LIKE '%' + @strSpeciesType + '%' OR strDefault LIKE '%' + @strSpeciesType + '%' OR strCode LIKE '%' + @strSpeciesType + '%' OR strHACodeNames LIKE '%' + @strSpeciesType + '%')
			--ORDER BY strName
		END;

		
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'asc' THEN idfsSpeciesType END ASC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'desc' THEN idfsSpeciesType END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'asc' THEN strCode END ASC,
				CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'desc' THEN strcode END DESC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'asc' THEN intHACode END ASC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'desc' THEN intHACode END DESC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'asc' THEN strHACode END ASC,
				CASE WHEN @sortColumn = 'strHACode' AND @SortOrder = 'desc' THEN strHACode END DESC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'asc' THEN strHACodeNames END ASC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'desc' THEN strHACodeNames END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC
				,IIF( @sortColumn = 'intOrder',intOrder,intOrder) ASC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsSpeciesType,
				strDefault,
				strName,	
				strCode,
				intHACode,
				strHACode,
				strHACodeNames,
				intOrder
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfsSpeciesType,
				strDefault,
				strName,	
				strCode,
				intHACode,
				strHACode,
				strHACodeNames,
				intOrder,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
