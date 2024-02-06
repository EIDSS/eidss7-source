

CREATE PROCEDURE [dbo].[USP_CONF_ADMIN_ProphylacticMatrixReportGet_GET] 
/*******************************************************
NAME						: [USP_CONF_ADMIN_ProphylacticMatrixReportGet_GET]		


Description					: Retreives List of Vet Prophylactic Diagnosisis  Matrix  by version

Author						: Lamont Mitchell

Revision History
		
Name						Date				Change Detail
Lamont Mitchell				03/4/19				Initial Created
Mark Wilson					10/27/2021			Added @LangID and join to FN_GBL_Reference

/* Test code

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_CONF_ADMIN_ProphylacticMatrixReportGet_GET]
		@idfVersion = 115299280001053,
		@LangID = N'en-US'

SELECT	'Return Value' = @return_value

*/
*******************************************************/
(
	@idfVersion BIGINT,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
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
		intNumRow int,
		idfAggrProphylacticActionMTX bigint,
		idfsSpeciesType bigint,
		idfsDiagnosis bigint,
		idfsProphilacticAction bigint,
		strActionCode nvarchar(2000),
		strDefault nvarchar(2000), 
		strOIECode nvarchar(2000)
	)
	
	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)

	INSERT INTO @T
	SELECT	 
			mtx.intNumRow,
			mtx.idfAggrProphylacticActionMTX as idfAggrProphylacticActionMTX,
			mtx.idfsSpeciesType,
			mtx.idfsDiagnosis,
			mtx.idfsProphilacticAction,
			pa.strActionCode,
			D.[name] AS strProphilacticAction,
			d.strOIECode

	FROM dbo.tlbAggrProphylacticActionMTX mtx
	INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 96, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- 2 = Human, use 10020002 for Aggregate cases
	INNER JOIN dbo.trtProphilacticAction PA ON PA.idfsProphilacticAction = mtx.idfsProphilacticAction AND PA.intRowStatus = 0
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000074) P ON P.idfsReference = mtx.idfsProphilacticAction AND PA.intRowStatus = 0
	INNER JOIN dbo.tlbAggrMatrixVersionHeader amvh ON amvh.intRowStatus = 0 and amvh.idfVersion = mtx.idfVersion and mtx.idfVersion = @idfVersion 
	WHERE mtx.intRowStatus = 0 
	AND mtx.idfVersion = @idfVersion;

	WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'intNumRow' AND @SortOrder = 'asc' THEN intNumRow END ASC,
				CASE WHEN @sortColumn = 'intNumRow' AND @SortOrder = 'desc' THEN intNumRow END DESC,
				CASE WHEN @sortColumn = 'idfAggrProphylacticActionMTX' AND @SortOrder = 'asc' THEN idfAggrProphylacticActionMTX END ASC,
				CASE WHEN @sortColumn = 'idfAggrProphylacticActionMTX' AND @SortOrder = 'desc' THEN idfAggrProphylacticActionMTX END DESC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'asc' THEN idfsSpeciesType END ASC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'desc' THEN idfsSpeciesType END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'idfsProphilacticAction' AND @SortOrder = 'asc' THEN idfsProphilacticAction END ASC,
				CASE WHEN @sortColumn = 'idfsProphilacticAction' AND @SortOrder = 'desc' THEN idfsProphilacticAction END DESC,
				CASE WHEN @sortColumn = 'strActionCode' AND @SortOrder = 'asc' THEN strActionCode END ASC,
				CASE WHEN @sortColumn = 'strActionCode' AND @SortOrder = 'desc' THEN strActionCode END DESC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
				CASE WHEN @sortColumn = 'strOIECode' AND @SortOrder = 'asc' THEN strOIECode END ASC,
				CASE WHEN @sortColumn = 'strOIECode' AND @SortOrder = 'desc' THEN strOIECode END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				intNumRow,
				idfAggrProphylacticActionMTX,
				idfsSpeciesType,
				idfsDiagnosis,
				idfsProphilacticAction,
				strActionCode,
				strDefault, 
				strOIECode
			FROM @T
		)

			SELECT
				TotalRowCount, 
				intNumRow,
				idfAggrProphylacticActionMTX,
				idfsSpeciesType,
				idfsDiagnosis,
				idfsProphilacticAction,
				strActionCode,
				strDefault, 
				strOIECode,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

		 

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
