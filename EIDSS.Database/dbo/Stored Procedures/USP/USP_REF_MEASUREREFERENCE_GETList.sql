-- ============================================================================
-- Name: USP_REF_MEASUREREFERENCE_GETList
-- Description:	Get the measure references for reference listings.
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		10/22/2018 Initial release.
-- Ricky Moss		01/18/2019 Removed return codes
-- Ricky Moss	    04/10/2020 Returns nothing when improper action is provided
-- Steven Verner	03/23/2021 Added paging
-- Leo Tracchia		08/03/2021 Added logic for searching on sanitary measure type	
-- Leo Tracchia		08/11/2021 Fixed sorting to be by intOrder, then National value

-- exec USP_REF_MEASUREREFERENCE_GETList 'en', 19000079
-- exec USP_REF_MEASUREREFERENCE_GETList 'en', 19000074
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_MEASUREREFERENCE_GETList]
(
  @LangID nvarchar(50)
 ,@idfsActionList BIGINT
 ,@pageNo INT = 1
 ,@pageSize INT = 10 
 ,@sortColumn NVARCHAR(30) = 'intOrder' 
 ,@sortOrder NVARCHAR(4) = 'asc'
 ,@advancedSearch NVARCHAR(100) = NULL
)

 AS
 BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsAction bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			strActionCode nvarchar(200),
			intOrder int)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		IF(@advancedSearch IS NOT NULL)
			BEGIN
				IF @idfsActionList = 19000074
					BEGIN
						INSERT INTO @T
							SELECT pa.idfsProphilacticAction as idfsAction
							  ,pabr.strDefault
							  ,pabr.[name] AS [strName]
							  ,pa.strActionCode AS strActionCode 
							  ,pabr.intOrder
							FROM trtProphilacticAction pa
							INNER JOIN FN_GBL_Reference_GETList(@LangID, 19000074) pabr ON
								pa.idfsProphilacticAction = pabr.idfsReference and pa.intRowStatus = 0
							WHERE 
								CAST(pa.idfsProphilacticAction AS VARCHAR(20)) LIKE + '%' + @advancedSearch + '%' OR
								pabr.strDefault LIKE + '%' + @advancedSearch + '%' OR
								pabr.name LIKE + '%' + @advancedSearch + '%' OR
								pa.strActionCode LIKE + '%' + @advancedSearch + '%'
							ORDER BY pabr.intOrder, pabr.[name]
					END
				ELSE IF @idfsActionList = 19000079
					BEGIN
						INSERT INTO @T
							SELECT sa.idfsSanitaryAction as idfsAction
							  ,sabr.strDefault
							  ,sabr.[name] AS [strName]
							  ,sa.strActionCode AS strActionCode 
							  ,sabr.intOrder
							FROM trtSanitaryAction sa
							INNER JOIN FN_GBL_Reference_GETList(@LangID, 19000079) sabr ON
								sa.idfsSanitaryAction = sabr.idfsReference and sa.intRowStatus = 0
							WHERE 
								CAST(sa.idfsSanitaryAction AS VARCHAR(20)) LIKE + '%' + @advancedSearch + '%' OR
								sabr.strDefault LIKE + '%' + @advancedSearch + '%' OR
								sabr.name LIKE + '%' + @advancedSearch + '%' OR
								sa.strActionCode LIKE + '%' + @advancedSearch + '%'
							ORDER BY sabr.intOrder, sabr.[name]
					END
			END		 
		ELSE IF @idfsActionList = 19000074
			BEGIN
				INSERT INTO @T
					SELECT pa.idfsProphilacticAction as idfsAction
					  ,pabr.strDefault
					  ,pabr.[name] AS [strName]
					  ,pa.strActionCode AS strActionCode 
					  ,pabr.intOrder
					FROM trtProphilacticAction pa
					INNER JOIN FN_GBL_Reference_GETList(@LangID, 19000074) pabr ON
						pa.idfsProphilacticAction = pabr.idfsReference and pa.intRowStatus = 0
					ORDER BY pabr.intOrder, pabr.[name]
			END 
		ELSE IF @idfsActionList = 19000079
			BEGIN
				INSERT INTO @T
					SELECT sa.idfsSanitaryAction as idfsAction
					  ,sabr.strDefault
					  ,sabr.[name] AS [strName]
					  ,sa.strActionCode AS strActionCode 
					  ,sabr.intOrder
					FROM trtSanitaryAction sa
					INNER JOIN FN_GBL_ReferenceRepair(@LangID, 19000079) sabr ON
						sa.idfsSanitaryAction = sabr.idfsReference and sa.intRowStatus = 0
					ORDER BY sabr.intOrder, sabr.[name]
			END;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsAction' AND @SortOrder = 'asc' THEN idfsAction END ASC,
				CASE WHEN @sortColumn = 'idfsAction' AND @SortOrder = 'desc' THEN idfsAction END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strActionCode' AND @SortOrder = 'asc' THEN strActionCode END ASC,
				CASE WHEN @sortColumn = 'strActionCode' AND @SortOrder = 'desc' THEN strActionCode END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsAction,
				strDefault,
				strName,	
				strActionCode,
				intOrder
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfsAction,
				strDefault,
				strName,	
				strActionCode,
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
