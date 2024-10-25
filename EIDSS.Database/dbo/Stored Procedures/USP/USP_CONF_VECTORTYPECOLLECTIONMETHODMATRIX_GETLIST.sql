-- =========================================================================================
-- NAME: USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_GETLIST
-- DESCRIPTION: Returns a list of vector type to collection type relationships

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		03/04/2019	Initial Release
-- Minal Shah		05/17/2021  Added Sorting and Pagination
-- Lamont Mitchell	5/23/22 add IS NULL instead of  = NULL on line 57
-- exec USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_GETLIST 'en', 6619310000000
-- exec USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_GETLIST 'en', 6619330000000
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_GETLIST]
(
	@LangId NVARCHAR(10),
	@idfsVectorType BIGINT,
	@pageNo INT = 1,
	@pageSize INT = 10, 
	@sortColumn NVARCHAR(30) = 'strDefault', 
	@sortOrder NVARCHAR(4) = 'asc',
	@idfsCollectionMethod  BIGINT = null
)
AS
BEGIN
	BEGIN TRY
	DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfCollectionMethodForVectorType bigint, 
			idfsVectorType bigint, 
			strVectorTypeDefault nvarchar(2000), 
			strVectorTypeName nvarchar(2000),
			idfsCollectionMethod nvarchar(2000),
			strDefault nvarchar(2000),
			strName nvarchar(2000)
			)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		INSERT INTO @T
		SELECT idfCollectionMethodForVectorType, idfsVectorType, vbr.strDefault as strVectorTypeDefault, vbr.[name] as strVectorTypeName, idfsCollectionMethod, collbr.strDefault, collbr.[name] as strName  FROM trtCollectionMethodForVectorType AS cmvt
		JOIN FN_GBL_Reference_GETList(@LangId,19000135) AS collbr
		ON cmvt.idfsCollectionMethod = collbr.idfsReference AND cmvt.intRowStatus = 0
		JOIN FN_GBL_Reference_GETList(@LangId, 19000140) AS vbr
		ON cmvt.idfsVectorType = vbr.idfsReference
		WHERE idfsVectorType = @idfsVectorType AND (idfsCollectionMethod = @idfsCollectionMethod OR @idfsCollectionMethod is null)
		ORDER BY collbr.strDefault;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC
			) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfCollectionMethodForVectorType,
				idfsVectorType, 
				strVectorTypeDefault, 
				strVectorTypeName,
				idfsCollectionMethod,
				strDefault,
				strName
			FROM @T
		)
		SELECT
				TotalRowCount,
				idfCollectionMethodForVectorType, 
				idfsVectorType, 
				strVectorTypeDefault, 
				strVectorTypeName,
				idfsCollectionMethod,
				strDefault, 
				strName,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
