-- ===========================================================================================================================================
-- NAME: USP_CONF_DISEASESAMPLETYPEMATRIX_GETLIST
-- DESCRIPTION: Returns a list of disease to sample type matrices given a language filtered by disease
-- AUTHOR: Lamont Mitchell
--
-- REVISION HISTORY
--
-- Name:				Date			Description of Change
-- ----------------------------------------------------------
-- Ricky Moss			10/19/21	Initial Release
--
-- EXEC USP_CONF_DISEASESAMPLETYPEMATRIX_GETLIST 'en'
-- ===========================================================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASESAMPLETYPEMATRIX_BY_DISEASE_GETLIST]
(
	 @langId NVARCHAR(50),
	 @idfsDiagnosis bigint
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strSampleType' 
	,@sortOrder NVARCHAR(4) = 'asc')
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			 idfMaterialForDisease bigint
			,idfsDiagnosis bigint
			,strDisease nvarchar(2000)
			,idfsSampleType bigint
			,strSampleType nvarchar(2000)
		)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT 
			 idfMaterialForDisease
			,idfsDiagnosis
			,dbr.name AS strDisease
			,idfsSampleType
			,stbr.name AS strSampleType 
		FROM trtMaterialForDisease md
		JOIN FN_GBL_Reference_GETList(@langId, 19000019) dbr
		ON md.idfsDiagnosis = dbr.idfsReference
		JOIN FN_GBL_Reference_List_GET(@langId, 19000087) stbr
		ON md.idfsSampleType = stbr.idfsReference
		WHERE intRowStatus = 0
		and idfsDiagnosis =  @idfsDiagnosis
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfMaterialForDisease' AND @SortOrder = 'asc' THEN idfMaterialForDisease END ASC,
				CASE WHEN @sortColumn = 'idfMaterialForDisease' AND @SortOrder = 'desc' THEN idfMaterialForDisease END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strDisease' AND @SortOrder = 'asc' THEN strDisease END ASC,
				CASE WHEN @sortColumn = 'strDisease' AND @SortOrder = 'desc' THEN strDisease END DESC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'asc' THEN idfsSampleType END ASC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'desc' THEN idfsSampleType END DESC,
				CASE WHEN @sortColumn = 'strSampleType' AND @SortOrder = 'asc' THEN strSampleType END ASC,
				CASE WHEN @sortColumn = 'strSampleType' AND @SortOrder = 'desc' THEN strSampleType END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfMaterialForDisease,
				idfsDiagnosis,
				strDisease,
				idfsSampleType, 
				strSampleType
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfMaterialForDisease,
				idfsDiagnosis,
				strDisease,
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
