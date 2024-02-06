

-- ============================================================================
-- Name: USP_REF_AGE_GROUP_GETList
-- Description:	Returns are
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		09/25/2018	Initial release.
-- Ricky Moss		10/03/2018	Update field name from idfsDiagnosisAgeGroup to idfsAgeGroup
-- Ricky Moss		12/19/2018	Removed returns codes and id variables
-- Steven Verner	03/23/2021  Added paging
-- Mark Wilson		08/02/2021  removed E6 function
-- Mike Kornegay	03/15/2022	Removed advanced search against idfBaseReference and idfsReferenceType
--								as this will produce unexpected results for users when searching since fields
--								are not visible.
--
/*

EXEC USP_REF_AGEGROUP_GETList 'en-US'
EXEC USP_REF_AGEGROUP_GETList 'az-Latn-AZ'

*/
-- ============================================================================

CREATE PROCEDURE [dbo].[USP_REF_AGEGROUP_GETList]
(
	 @langID NVARCHAR(50) = NULL
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strName' 
	,@sortOrder NVARCHAR(4) = 'asc')
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsAgeGroup bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			intOrder int,
			intLowerBoundary int,
			intUpperBoundary int,
			idfsAgeType bigint,
			AgeTypeName nvarchar(2000)
			)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		IF( @advancedSearch IS NOT NULL)
		INSERT INTO @T
			SELECT * FROM
			(
			SELECT 
				DAG.[idfsDiagnosisAgeGroup] AS idfsAgeGroup
				,DAGName.strDefault AS [strDefault]
				,ISNULL(DAGName.[name], DAGName.strDefault) AS [strName]
				,ISNULL(DAGName.intOrder, 0) AS [intOrder]
				,DAG.[intLowerBoundary]
				,DAG.[intUpperBoundary]
				,DAG.[idfsAgeType]
				,ISNULL(AgeTypeName.[name], AgeTypeName.strDefault) AS [AgeTypeName]
			FROM [dbo].[trtDiagnosisAgeGroup] DAG
			INNER Join dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000146) DAGName ON DAG.idfsDiagnosisAgeGroup = DAGName.idfsReference
			INNER Join dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000042) AgeTypeName ON DAG.idfsAgeType = AgeTypeName.idfsReference
			LEFT JOIN trtBaseReference tbr ON
				tbr.idfsBaseReference = DAG.idfsDiagnosisAgeGroup
				AND tbr.idfsReferenceType = 19000146
				AND (
						tbr.blnSystem = 1 
						AND (ISNULL(tbr.strBaseReferenceCode, '') LIKE '%CDCAgeGroup%' OR ISNULL(tbr.strBaseReferenceCode, '') LIKE '%WHOAgeGroup%')
					)
				AND tbr.intRowStatus = 0
			WHERE DAG.intRowStatus = 0
				AND tbr.idfsBaseReference IS NULL
			) AS a 
			WHERE 
			--CAST(idfsAgeGroup AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR
			strDefault LIKE '%' + @advancedSearch + '%' OR
			strName LIKE '%' + @advancedSearch + '%' OR
			--idfsAgeType LIKE '%' + @advancedSearch + '%' OR
			AgeTypeName LIKE '%' + @advancedSearch + '%'
			ORDER BY intOrder
		ELSE
			INSERT INTO @T
			SELECT 
				DAG.[idfsDiagnosisAgeGroup] AS idfsAgeGroup
				,DAGName.strDefault AS [strDefault]
				,ISNULL(DAGName.[name], DAGName.strDefault) AS [strName]
				,ISNULL(DAGName.intOrder, 0) AS [intOrder]
				,DAG.[intLowerBoundary]
				,DAG.[intUpperBoundary]
				,DAG.[idfsAgeType]
				,ISNULL(AgeTypeName.[name], AgeTypeName.strDefault) AS [AgeTypeName]
			FROM [dbo].[trtDiagnosisAgeGroup] DAG
			INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000146) DAGName ON DAG.idfsDiagnosisAgeGroup = DAGName.idfsReference
			INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000042) AgeTypeName ON DAG.idfsAgeType = AgeTypeName.idfsReference
			LEFT JOIN trtBaseReference tbr ON
				tbr.idfsBaseReference = DAG.idfsDiagnosisAgeGroup
				AND tbr.idfsReferenceType = 19000146
				AND (
						tbr.blnSystem = 1 
						AND (ISNULL(tbr.strBaseReferenceCode, '') LIKE '%CDCAgeGroup%' OR ISNULL(tbr.strBaseReferenceCode, '') LIKE '%WHOAgeGroup%')
					)
				AND tbr.intRowStatus = 0
			WHERE DAG.intRowStatus = 0
				AND tbr.idfsBaseReference IS NULL
			ORDER BY DAGName.intOrder;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfsAgeGroup' AND @SortOrder = 'asc' THEN idfsAgeGroup END ASC,
				CASE WHEN @sortColumn = 'idfsAgeGroup' AND @SortOrder = 'desc' THEN idfsAgeGroup END DESC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC,
				CASE WHEN @sortColumn = 'intLowerBoundary' AND @SortOrder = 'asc' THEN intLowerBoundary END ASC,
				CASE WHEN @sortColumn = 'intLowerBoundary' AND @SortOrder = 'desc' THEN intLowerBoundary END DESC,
				CASE WHEN @sortColumn = 'intUpperBoundary' AND @SortOrder = 'asc' THEN intUpperBoundary END ASC,
				CASE WHEN @sortColumn = 'intUpperBoundary' AND @SortOrder = 'desc' THEN intUpperBoundary END DESC,
				CASE WHEN @sortColumn = 'idfsAgeType' AND @SortOrder = 'asc' THEN idfsAgeType END ASC,
				CASE WHEN @sortColumn = 'idfsAgeType' AND @SortOrder = 'desc' THEN idfsAgeType END DESC,
				CASE WHEN @sortColumn = 'AgeTypeName' AND @SortOrder = 'asc' THEN AgeTypeName END ASC,
				CASE WHEN @sortColumn = 'AgeTypeName' AND @SortOrder = 'desc' THEN AgeTypeName END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsAgeGroup,
				strDefault,
				strName,	
				intOrder,
				intLowerBoundary,
				intUpperBoundary,
				idfsAgeType,
				AgeTypeName
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfsAgeGroup,
				strDefault,
				strName,	
				intOrder,
				intLowerBoundary,
				intUpperBoundary,
				idfsAgeType,
				AgeTypeName,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
