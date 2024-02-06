-- =============================================================================
-- Name:		EXEC USP_CONF_VECTORTYPESAMPLETYPEMATRIX_GETLIST
-- Description:	Returns a list of vector type to sample type matrices given a language and vector type id
-- Author:		Ricky Moss
--
-- Revision History:
-- Name:			Date:		Revision:
-- _____________________________________________________________________________
-- Ricky Moss		04/01/2019	Initial Release
-- Minal Shah	    05/14/2021  Added Sorting and Paging
--
-- EXEC USP_CONF_VECTORTYPESAMPLETYPEMATRIX_GETLIST 'en', 6619340000000
-- =============================================================================
CREATE PROCEDURE [dbo].[USP_CONF_VECTORTYPESAMPLETYPEMATRIX_GETLIST]
(
	@langId NVARCHAR(50),
	@idfsVectorType BIGINT,
	@pageNo INT = 1,
	@pageSize INT = 10, 
	@sortColumn NVARCHAR(30) = 'strSampleTypeName',
	@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
	DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfSampleTypeForVectorType bigint, 
			idfsVectorType bigint, 
			strVectorTypeName nvarchar(2000), 
			idfsSampleType nvarchar(2000),
			strSampleTypeName nvarchar(2000)
			)

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		INSERT INTO @T
		SELECT idfSampleTypeForVectorType, idfsVectorType, vtbr.name AS strVectorTypeName, idfsSampleType, stbr.name AS strSampleTypeName from trtSampleTypeForVectorType stvt
		JOIN FN_GBL_Reference_GETList(@langId, 19000087) stbr
		ON stvt.idfsSampleType = stbr.idfsReference
		JOIN FN_GBL_Reference_GETList(@langId, 19000140) vtbr
		ON stvt.idfsVectorType = vtbr.idfsReference
		WHERE stvt.intRowStatus = 0 AND idfsVectorType = @idfsVectorType;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strSampleTypeName' AND @SortOrder = 'asc' THEN strSampleTypeName END ASC,
				CASE WHEN @sortColumn = 'strSampleTypeName' AND @SortOrder = 'desc' THEN strSampleTypeName END DESC
			) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfSampleTypeForVectorType,
				idfsVectorType, 
				strVectorTypeName, 
				idfsSampleType,
				strSampleTypeName
			FROM @T
		)
		SELECT
				TotalRowCount,
				idfSampleTypeForVectorType, 
				idfsVectorType, 
				strVectorTypeName, 
				idfsSampleType,
				strSampleTypeName, 		 
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
