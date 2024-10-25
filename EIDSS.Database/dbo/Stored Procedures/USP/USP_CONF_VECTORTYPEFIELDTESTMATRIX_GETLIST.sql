-- =============================================================================
-- Name:		USP_CONF_VECTORTYPEFIELDTESTMATRIX_GETLIST
-- Description:	Returns a list of vector type to field test matrices given a language and vector type id
-- Author:		Ricky Moss
--
-- Revision History:
-- Name:			Date:		Revision:
-- _____________________________________________________________________________
-- Ricky Moss		04/02/2019	Initial Release
-- Minal Shah	    05/14/2021  Added Sorting and Pagin
-- EXEC USP_CONF_VECTORTYPEFIELDTESTMATRIX_GETLIST 'en', 6619340000000
-- EXEC USP_CONF_VECTORTYPEFIELDTESTMATRIX_GETLIST 'en', 6619360000000
-- =============================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPEFIELDTESTMATRIX_GETLIST]
(
	@langId NVARCHAR(10),
	@idfsVectorType BIGINT,
	@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strPensideTestName' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfPensideTestTypeForVectorType bigint, 
			idfsVectorType bigint, 
			strVectorTypeName nvarchar(2000), 
			idfsPensideTestName nvarchar(2000),
			strPensideTestName nvarchar(2000)
			)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		INSERT INTO @T
		SELECT idfPensideTestTypeForVectorType, idfsVectorType, vtbr.name AS strVectorTypeName, idfsPensideTestName, ptnbr.name AS strPensideTestName FROM trtPensideTestTypeForVectorType ptvt
		JOIN FN_GBL_Reference_GETList(@langId, 19000104) ptnbr
		ON ptvt.idfsPensideTestName = ptnbr.idfsReference
		JOIN FN_GBL_Reference_GETList(@langId, 19000140) vtbr
		ON ptvt.idfsVectorType = vtbr.idfsReference
		WHERE ptvt.intRowStatus = 0 AND idfsVectorType = @idfsVectorType; 

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strPensideTestName' AND @SortOrder = 'asc' THEN strPensideTestName END ASC,
				CASE WHEN @sortColumn = 'strPensideTestName' AND @SortOrder = 'desc' THEN strPensideTestName END DESC
			) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfPensideTestTypeForVectorType,
				idfsVectorType, 
				strVectorTypeName, 
				idfsPensideTestName,
				strPensideTestName
			FROM @T
		)
		SELECT
				TotalRowCount,
				idfPensideTestTypeForVectorType, 
				idfsVectorType, 
				strVectorTypeName, 
				idfsPensideTestName,
				strPensideTestName, 		 
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
