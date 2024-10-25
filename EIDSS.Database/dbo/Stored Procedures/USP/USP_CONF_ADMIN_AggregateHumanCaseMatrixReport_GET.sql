

CREATE PROCEDURE [dbo].[USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GET] 
/*******************************************************
NAME						: [USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GET]		


Description					: Retreives List of Diseases For Human Aggregate Case Matrix Version by version

Author						: Lamont Mitchell

Revision History
		
	Name						Date					Change Detail
	Lamont Mitchell				03/4/19					Initial Created
	Mark Wilson					04/13/21				Added Translation
	Mark Wilson					10/28/21				removed default language

/* Example 

DECLARE
	@idfVersion BIGINT = 3021340000000,
	@pageNo INT = 1,
	@pageSize INT = 10,
	@sortColumn NVARCHAR(30) = 'intNumRow',
	@sortOrder NVARCHAR(4) = 'asc',
	@LangID NVARCHAR(24) = 'en-US'

EXEC dbo.USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GET @idfVersion, @pageNo, @pageSize,	@sortColumn, @sortOrder, @LangID

*/
*******************************************************/
(
	@idfVersion BIGINT,
	@pageNo INT = 1,
	@pageSize INT = 10,
	@sortColumn NVARCHAR(30) = 'intNumRow',
	@sortOrder NVARCHAR(4) = 'asc',
	@LangID NVARCHAR(100)
)
AS
BEGIN

	BEGIN TRY 
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE
		( 
			intNumRow INT,
			idfHumanCaseMtx BIGINT,
			idfsDiagnosis BIGINT,
			strDefault NVARCHAR(2000), 
			strIDC10 NVARCHAR(100)
		)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT	 
			mtx.intNumRow,
			mtx.idfAggrHumanCaseMTX,
			mtx.idfsDiagnosis,
			D.name AS strDefault,
			D.strIDC10

		FROM dbo.tlbAggrHumanCaseMTX mtx
		INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 2, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- 2 = Human, use 10020002 for Aggregate cases
		
		WHERE mtx.intRowStatus = 0 AND mtx.idfVersion = @idfVersion
		;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'intNumRow' AND @SortOrder = 'asc' THEN intNumRow END ASC,
				CASE WHEN @sortColumn = 'intNumRow' AND @SortOrder = 'desc' THEN intNumRow END DESC,
				CASE WHEN @sortColumn = 'idfHumanCaseMtx' AND @SortOrder = 'asc' THEN idfHumanCaseMtx END ASC,
				CASE WHEN @sortColumn = 'idfHumanCaseMtx' AND @SortOrder = 'desc' THEN idfHumanCaseMtx END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
				CASE WHEN @sortColumn = 'strIDC10' AND @SortOrder = 'asc' THEN strIDC10 END ASC,
				CASE WHEN @sortColumn = 'strIDC10' AND @SortOrder = 'desc' THEN strIDC10 END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				intNumRow,
				idfHumanCaseMtx,
				idfsDiagnosis,
				strDefault, 
				strIDC10
			FROM @T
		)

			SELECT
				TotalRowCount, 
				intNumRow,
				idfHumanCaseMtx,
				idfsDiagnosis,
				strDefault, 
				strIDC10,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
