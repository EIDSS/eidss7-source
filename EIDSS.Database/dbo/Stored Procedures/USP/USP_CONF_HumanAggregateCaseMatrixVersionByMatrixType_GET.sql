/*******************************************************
NAME						: [USP_CONF_HumanAggregateCaseMatrixVersionByMatrixType_GET]		


Description					: Retreives Entries For Human Aggregate Case Matrix Version by matrixType

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					03/24/19							Initial Created
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_HumanAggregateCaseMatrixVersionByMatrixType_GET]
	
 @idfsMatrixType								BIGINT = NULL
,@pageNo INT = 1
,@pageSize INT = 10 
,@sortColumn NVARCHAR(30) = 'MatrixName' 
,@sortOrder NVARCHAR(4) = 'asc'

AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @firstRec INT
	DECLARE @lastRec INT
	DECLARE @t TABLE( 
		idfVersion bigint, 
		idfsMatrixType bigint,
		MatrixName nvarchar(200), 
		datStartDate datetime, 
		blnIsActive bit, 
		intRowStatus int, 
		rowguid uniqueidentifier, 
		blnIsDefault bit, 
		strMaintenanceFlag nvarchar(20), 
		strReservedAttribute nvarchar(max))

	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)


	INSERT INTO @t
	SELECT 
		idfVersion, 
		idfsMatrixType, 
		MatrixName, 
		datStartDate, 
		blnIsActive, 
		intRowStatus, 
		rowguid, 
		blnIsDefault, 
		strMaintenanceFlag, 
		strReservedAttribute
		FROM [dbo].[tlbAggrMatrixVersionHeader] 
		where  intRowStatus =0
		AND idfsMatrixType = @idfsMatrixType;
	
	WITH CTEResults AS
	(
		SELECT ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'idfVersion' AND @SortOrder = 'asc' THEN idfVersion END ASC,
			CASE WHEN @sortColumn = 'idfVersion' AND @SortOrder = 'desc' THEN idfVersion END DESC,
			CASE WHEN @sortColumn = 'idfsMatrixType' AND @SortOrder = 'asc' THEN idfsMatrixType END ASC,
			CASE WHEN @sortColumn = 'idfsMatrixType' AND @SortOrder = 'desc' THEN idfsMatrixType END DESC,
			CASE WHEN @sortColumn = 'MatrixName' AND @SortOrder = 'asc' THEN MatrixName END ASC,
			CASE WHEN @sortColumn = 'MatrixName' AND @SortOrder = 'desc' THEN MatrixName END DESC,
			CASE WHEN @sortColumn = 'datStartDate' AND @SortOrder = 'asc' THEN datStartDate END ASC,
			CASE WHEN @sortColumn = 'datStartDate' AND @SortOrder = 'desc' THEN datStartDate END DESC

			--CASE WHEN @sortColumn = 'blnIsActive' AND @SortOrder = 'asc' THEN blnIsActive END ASC,
			--CASE WHEN @sortColumn = 'blnIsActive' AND @SortOrder = 'desc' THEN blnIsActive END DESC,
			--CASE WHEN @sortColumn = 'intRowStatus' AND @SortOrder = 'asc' THEN intRowStatus END ASC,
			--CASE WHEN @sortColumn = 'intRowStatus' AND @SortOrder = 'desc' THEN intRowStatus END DESC,
			--CASE WHEN @sortColumn = 'rowguid' AND @SortOrder = 'asc' THEN rowguid END ASC,
			--CASE WHEN @sortColumn = 'rowguid' AND @SortOrder = 'desc' THEN rowguid END DESC,
			--CASE WHEN @sortColumn = 'blnIsDefault' AND @SortOrder = 'asc' THEN blnIsDefault END ASC,
			--CASE WHEN @sortColumn = 'blnIsDefault' AND @SortOrder = 'desc' THEN blnIsDefault END DESC,
			--CASE WHEN @sortColumn = 'strMaintenanceFlag' AND @SortOrder = 'asc' THEN strMaintenanceFlag END ASC,
			--CASE WHEN @sortColumn = 'strMaintenanceFlag' AND @SortOrder = 'desc' THEN strMaintenanceFlag END DESC




	) AS ROWNUM,
	COUNT(*) OVER () AS 
		TotalRowCount, 
		idfVersion, 
		idfsMatrixType, 
		MatrixName, 
		datStartDate, 
		blnIsActive, 
		intRowStatus, 
		rowguid, 
		blnIsDefault, 
		strMaintenanceFlag, 
		strReservedAttribute
		FROM @T
	)
		SELECT
		TotalRowCount, 
		idfVersion, 
		idfsMatrixType, 
		MatrixName, 
		datStartDate, 
		blnIsActive, 
		intRowStatus, 
		rowguid, 
		blnIsDefault, 
		strMaintenanceFlag, 
		strReservedAttribute,
		TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
		CurrentPage = @pageNo 
	FROM CTEResults
	WHERE RowNum > @firstRec AND RowNum < @lastRec 
	
	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END



