
--=====================================================================================================
-- Name: USP_REF_VECTORTYPEREFERENCE_GETList
-- Description:	Returns a list of active vector types
--
-- Author:		Philip Shaffer
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Philip Shaffer	2018/09/26 Initial release
-- Ricky Moss		2018/10/01 Modified USP_REF_VECTORTYPEREFERENCE from EIDSS 7.0
-- Ricky Moss		2019/01/11 Remove return codes
-- Ricky Moss		2019/01/28 Removed deprecated stored procedures
-- Ricky Moss		2020/04/10 Change order to name
-- Ricky Moss		2020/05/04 Add Search parameter
-- Steven Verner	03/22/2021 Added paging

-- Test Code:
-- exec USP_REF_VECTORTYPEREFERENCE_GETList 'en', 'ti';
-- 
--=====================================================================================================


CREATE PROCEDURE [dbo].[USP_REF_VECTORTYPEREFERENCE_GETList]
(		
	 @langID  NVARCHAR(50)
	,@strSearchVectorType NVARCHAR(50)
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
			idfsVectorType bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			strCode nvarchar(50), 
			[bitCollectionByPool] bit,
			intOrder int,
			intRowStatus int)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		IF( @advancedSearch IS NOT NULL )
			INSERT INTO @T
			SELECT
			vt.idfsVectorType,
			br.strDefault as strDefault,
			br.[name] as strName,	
			vt.[strCode],
			vt.[bitCollectionByPool],
			br.[intOrder],
			vt.[intRowStatus]
			FROM dbo.[trtVectorType] as vt -- Vector Type
			INNER JOIN FN_GBL_Reference_GETList(@LangID, 19000140) AS br
			ON vt.idfsVectorType = br.idfsReference AND vt.intRowStatus = 0
			WHERE 
				CAST( idfsVectorType AS VARCHAR(20)) LIKE + '%' + @advancedSearch + '%' OR
				strDefault LIKE '&' + @advancedSearch + '%' OR 
				[name] LIKE '%' + @advancedSearch + '%' OR 
				strCode LIKE '%' + @advancedSearch + '%'
			ORDER BY
				br.strDefault;
		ELSE IF( @strSearchVectorType IS NULL)
			INSERT INTO @T
			SELECT
				vt.idfsVectorType,
				br.strDefault as strDefault,
				br.[name] as strName,	
				vt.[strCode],
				vt.[bitCollectionByPool],
				br.[intOrder],
				vt.[intRowStatus]
			FROM dbo.[trtVectorType] as vt -- Vector Type
			INNER JOIN FN_GBL_Reference_GETList(@LangID, 19000140) AS br
			ON vt.idfsVectorType = br.idfsReference AND vt.intRowStatus = 0
	
			ORDER BY
				br.strDefault;
		ELSE
			INSERT INTO @T
			SELECT
				vt.idfsVectorType,
				br.strDefault as strDefault,
				br.[name] as strName,	
				vt.[strCode],
				vt.[bitCollectionByPool],
				br.[intOrder],
				vt.[intRowStatus]
	
			FROM dbo.[trtVectorType] as vt -- Vector Type
			INNER JOIN FN_GBL_Reference_GETList(@LangID, 19000140) AS br
			ON vt.idfsVectorType = br.idfsReference AND vt.intRowStatus = 0
			WHERE strDefault LIKE '&' + @strSearchVectorType + '%' OR [name] LIKE '%' + @strSearchVectorType + '%' OR strCode LIKE '%' + @strSearchVectorType + '%'
			ORDER BY
				br.strDefault;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsVectorType' AND @SortOrder = 'asc' THEN idfsVectorType END ASC,
				CASE WHEN @sortColumn = 'idfsVectorType' AND @SortOrder = 'desc' THEN idfsVectorType END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'asc' THEN strCode END ASC,
				CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'desc' THEN strcode END DESC,
				CASE WHEN @sortColumn = 'bitCollectionByPool' AND @SortOrder = 'asc' THEN bitCollectionByPool END ASC,
				CASE WHEN @sortColumn = 'bitCollectionByPool' AND @SortOrder = 'desc' THEN bitCollectionByPool END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC,
				CASE WHEN @sortColumn = 'intRowStatus' AND @SortOrder = 'asc' THEN intRowStatus END ASC,
				CASE WHEN @sortColumn = 'intRowStatus' AND @SortOrder = 'desc' THEN intRowStatus END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsVectorType,
				strDefault,
				strName,	
				strCode,
				bitCollectionByPool,
				intOrder,
				intRowStatus
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfsVectorType,
				strDefault,
				strName,	
				strCode,
				bitCollectionByPool,
				intOrder,
				intRowStatus,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

END TRY
BEGIN CATCH
	THROW;
END CATCH

END
