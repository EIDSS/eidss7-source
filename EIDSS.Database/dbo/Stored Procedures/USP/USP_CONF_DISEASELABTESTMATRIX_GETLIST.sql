-- ================================================================================================
-- Name: USP_CONF_DISEASELABTESTMATRIX_GETLIST
--
-- Description: Returns a list of Disease to lab test matrices given a language
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name               Date       Description of Change
-- ------------------ ---------- -----------------------------------------------------------------
-- Ricky Moss         04/08/2019 Initial Release
-- Stephen Long       03/23/2020 Added order by and added procedure to TFS.
--
-- Testing Code:
-- EXEC USP_CONF_DISEASELABTESTMATRIX_GETLIST 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASELABTESTMATRIX_GETLIST] (

	 @langId NVARCHAR(10)
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strDisease' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfTestForDisease bigint,
			idfsDiagnosis bigint,
			strDisease nvarchar(2000),
			idfsTestName bigint,
			strTestName nvarchar(2000),
			idfsTestCategory bigint,
			strTestCategory nvarchar(2000),
			idfsSampleType bigint,
			strSampleType nvarchar(2000)
			)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT td.idfTestForDisease,
			td.idfsDiagnosis,
			dbr.name AS strDisease,
			td.idfsTestName,
			tbr.name AS strTestName,
			td.idfsTestCategory,
			tcbr.name AS strTestCategory,
			idfsSampleType,
			stbr.name AS strSampleType
		FROM dbo.trtTestForDisease td
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000019) dbr
			ON td.idfsDiagnosis = dbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000097) tbr
			ON td.idfsTestName = tbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000095) tcbr
			ON td.idfsTestCategory = tcbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000087) stbr
			ON td.idfsSampleType = stbr.idfsReference
		WHERE intRowStatus = 0 
		ORDER BY strDisease, strTestName;
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfTestForDisease' AND @SortOrder = 'asc' THEN idfTestForDisease END ASC,
				CASE WHEN @sortColumn = 'idfTestForDisease' AND @SortOrder = 'desc' THEN idfTestForDisease END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strDisease' AND @SortOrder = 'asc' THEN strDisease END ASC,
				CASE WHEN @sortColumn = 'strDisease' AND @SortOrder = 'desc' THEN strDisease END DESC,
				CASE WHEN @sortColumn = 'idfsTestName' AND @SortOrder = 'asc' THEN idfsTestName END ASC,
				CASE WHEN @sortColumn = 'idfsTestName' AND @SortOrder = 'desc' THEN idfsTestName END DESC,
				CASE WHEN @sortColumn = 'strTestName' AND @SortOrder = 'asc' THEN strTestName END ASC,
				CASE WHEN @sortColumn = 'strTestName' AND @SortOrder = 'desc' THEN strTestName END DESC,
				CASE WHEN @sortColumn = 'idfsTestCategory' AND @SortOrder = 'asc' THEN idfsTestCategory END ASC,
				CASE WHEN @sortColumn = 'idfsTestCategory' AND @SortOrder = 'desc' THEN idfsTestCategory END DESC,
				CASE WHEN @sortColumn = 'strTestCategory' AND @SortOrder = 'asc' THEN strTestCategory END ASC,
				CASE WHEN @sortColumn = 'strTestCategory' AND @SortOrder = 'desc' THEN strTestCategory END DESC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'asc' THEN idfsSampleType END ASC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'desc' THEN idfsSampleType END DESC,
				CASE WHEN @sortColumn = 'strSampleType' AND @SortOrder = 'asc' THEN strSampleType END ASC,
				CASE WHEN @sortColumn = 'strSampleType' AND @SortOrder = 'desc' THEN strSampleType END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfTestForDisease,
				idfsDiagnosis,
				strDisease,
				idfsTestName,
				strTestName,
				idfsTestCategory,
				strTestCategory,
				idfsSampleType,
				strSampleType
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfTestForDisease,
				idfsDiagnosis,
				strDisease,
				idfsTestName,
				strTestName,
				idfsTestCategory,
				strTestCategory,
				idfsSampleType,
				strSampleType,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
