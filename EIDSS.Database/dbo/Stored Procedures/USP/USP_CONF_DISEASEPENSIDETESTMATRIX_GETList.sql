-- =========================================================================================
-- NAME: USP_CONF_DISEASEPENSIDETESTMATRIX_GETList
-- DESCRIPTION: Returns a list of disease to penside test relationships

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		02/25/2019	Initial Release
--
-- exec USP_CONF_DISEASEPENSIDETESTMATRIX_GETList 'en'
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASEPENSIDETESTMATRIX_GETList]
(
	 @LangID NVARCHAR(10)
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strPensideTestName' 
	,@sortOrder NVARCHAR(4) = 'asc')
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfPensideTestForDisease bigint,
			idfsPensideTestName bigint,
			strPensideTestName nvarchar(2000),
			idfsDiagnosis bigint,
			strDisease nvarchar(2000)
		)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT 
			 idfPensideTestForDisease
			,idfsPensideTestName
			,ptdbr.name as strPensideTestName
			,ptd.idfsDiagnosis
			,dbr.name as strDisease 
		FROM trtPensideTestForDisease ptd
		JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000104) ptdbr ON ptd.idfsPensideTestName = ptdbr.idfsReference
		JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) dbr ON ptd.idfsDiagnosis = dbr.idfsReference
		WHERE ptd.intRowStatus = 0
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfPensideTestForDisease' AND @SortOrder = 'asc' THEN idfPensideTestForDisease END ASC,
				CASE WHEN @sortColumn = 'idfPensideTestForDisease' AND @SortOrder = 'desc' THEN idfPensideTestForDisease END DESC,
				CASE WHEN @sortColumn = 'idfsPensideTestName' AND @SortOrder = 'asc' THEN idfsPensideTestName END ASC,
				CASE WHEN @sortColumn = 'idfsPensideTestName' AND @SortOrder = 'desc' THEN idfsPensideTestName END DESC,
				CASE WHEN @sortColumn = 'strPensideTestName' AND @SortOrder = 'asc' THEN strPensideTestName END ASC,
				CASE WHEN @sortColumn = 'strPensideTestName' AND @SortOrder = 'desc' THEN strPensideTestName END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strDisease' AND @SortOrder = 'asc' THEN strDisease END ASC,
				CASE WHEN @sortColumn = 'strDisease' AND @SortOrder = 'desc' THEN strDisease END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfPensideTestForDisease,
				idfsPensideTestName,
				strPensideTestName,
				idfsDiagnosis, 
				strDisease
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfPensideTestForDisease,
				idfsPensideTestName,
				strPensideTestName,
				idfsDiagnosis, 
				strDisease,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
