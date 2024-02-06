-- ================================================================================================
-- NAME: USP_CONF_TESTTOTESTRESULTMATRIX_GETLIST
-- DESCRIPTION: Returns a list of test to test result relationships
-- AUTHOR: Ricky Moss
-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		03/08/2019 Initial Release
-- Stephen Long     04/07/2020 Make test name nullable for the laboratory module; for performance 
--                             purposes bring all records in one call to, so app will not have to 
--                             make repeated calls loading grid views and call on each row as 
--                             results will vary with different test names.
-- Doug Albanese	4/16/2020  This SP was generated with two different possible output structures. 
--								This is wrong and both can't be picked up by POCO.
-- Ann Xiong		11/09/2022 Modified to return no record when idfsTestName is NULL
-- Stephen Long     11/15/2022 Rolling back prior change as other areas use this sproc with null. 
--                             Modified test name to test result matrix page to only call this 
--                             procedure when a test name has been selected.
--
-- exec USP_CONF_TESTTOTESTRESULTMATRIX_GETLIST 'en', 19000097, 803960000000
-- exec USP_CONF_TESTTOTESTRESULTMATRIX_GETLIST 'en', 190000104, 807510000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_TESTTOTESTRESULTMATRIX_GETLIST] (
	 @langId NVARCHAR(10)
	,@idfsTestResultRelation BIGINT
	,@idfsTestName BIGINT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strTestNameDefault' 
	,@sortOrder NVARCHAR(4) = 'asc'	)
AS
BEGIN
	DECLARE @firstRec INT
	DECLARE @lastRec INT
	DECLARE @t TABLE( 
		idfsTestName bigint,
		strTestNameDefault nvarchar(2000),
		strTestName nvarchar(2000),
		idfsTestResult bigint,
		strTestResultDefault nvarchar(2000),
		strTestResultName nvarchar(2000),
		blnIndicative bit
	)

	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		IF @idfsTestResultRelation = 19000097
			INSERT INTO @T
			SELECT idfsTestName,
				tnbr.strDefault AS strTestNameDefault,
				tnbr.name AS strTestName,
				idfsTestResult,
				trbr.strDefault AS strTestResultDefault,
				trbr.name AS strTestResultName,
				blnIndicative
			FROM dbo.trtTestTypeToTestResult ttr
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000097) tnbr
				ON ttr.idfsTestName = tnbr.idfsReference
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000096) trbr
				ON ttr.idfsTestResult = trbr.idfsReference
			WHERE ttr.intRowStatus = 0
				AND ((idfsTestName = @idfsTestName) 
				OR (@idfsTestName IS NULL)
				)
		ELSE
			INSERT INTO @T
			SELECT idfsPensideTestName,
				ptnbr.strDefault AS strTestNameDefault,
				ptnbr.name AS strTestName,
				idfsPensideTestResult as idfsTestResult,
				ptrbr.strDefault AS strTestResultDefault,
				ptrbr.name AS strTestResultName,
				blnIndicative
			FROM dbo.trtPensideTestTypeToTestResult pttr
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000104) ptnbr
				ON pttr.idfsPensideTestName = ptnbr.idfsReference
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000105) ptrbr
				ON pttr.idfsPensideTestResult = ptrbr.idfsReference
			WHERE pttr.intRowStatus = 0
				AND ((idfsPensideTestName = @idfsTestName) 
				OR (@idfsTestName IS NULL)
				)
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strTestNameDefault' AND @SortOrder = 'asc' THEN strTestNameDefault END ASC,
				CASE WHEN @sortColumn = 'strTestNameDefault' AND @SortOrder = 'desc' THEN strTestNameDefault END DESC,
				CASE WHEN @sortColumn = 'strTestResultDefault' AND @SortOrder = 'asc' THEN strTestResultDefault END ASC,
				CASE WHEN @sortColumn = 'strTestResultDefault' AND @SortOrder = 'desc' THEN strTestResultDefault END DESC,
				CASE WHEN @sortColumn = 'strTestResultName' AND @SortOrder = 'asc' THEN strTestResultName END ASC,
				CASE WHEN @sortColumn = 'strTestResultName' AND @SortOrder = 'desc' THEN strTestResultName END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsTestName,
				strTestNameDefault,
				strTestName,
				idfsTestResult, 
				strTestResultDefault,
				strTestResultName,
				blnIndicative
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfsTestName,
				strTestNameDefault,
				strTestName,
				idfsTestResult, 
				strTestResultDefault,
				strTestResultName,
				blnIndicative,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW
	END CATCH
END
