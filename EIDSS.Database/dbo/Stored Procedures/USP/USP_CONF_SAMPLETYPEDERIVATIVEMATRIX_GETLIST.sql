
-- =============================================================================================================================
-- Name: USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLIST
--
-- Description: Returns a list of sample type derivative types with properties.
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------------------------------
-- Ricky Moss         07/10/2019 Initial Release
-- Stephen Long       12/26/2019 Replaced 'en' with @LangID on reference call.
-- Ann Xiong          04/19/2021 Added paging
-- Ann Xiong		  06/25/2021 Modified to return no record when idfsSampleType is NULL
--
-- USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLIST 'en'
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLIST] 
(
	@langId NVARCHAR(50)
	,@idfsSampleType BIGINT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strSampleType' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfDerivativeForSampleType bigint,
			idfsSampleType bigint,
			strSampleType nvarchar(2000), 
			idfsDerivativeType bigint,
			strDerivative nvarchar(2000))
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT	idfDerivativeForSampleType,
				idfsSampleType,
				sbr.name AS strSampleType,
				idfsDerivativeType,
				dbr.name AS strDerivative
		FROM	dbo.trtDerivativeForSampleType dst
				JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000087) sbr
					ON dst.idfsSampleType = sbr.idfsReference
				JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000087) dbr
					ON dst.idfsDerivativeType = dbr.idfsReference
		WHERE	dst.intRowStatus = 0
				AND (
						(dst.idfsSampleType = @idfsSampleType)
						--OR (@idfsSampleType IS NULL)
					)
		ORDER BY sbr.name,
				dbr.name;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfDerivativeForSampleType' AND @SortOrder = 'asc' THEN idfDerivativeForSampleType END ASC,
				CASE WHEN @sortColumn = 'idfDerivativeForSampleType' AND @SortOrder = 'desc' THEN idfDerivativeForSampleType END DESC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'asc' THEN idfsSampleType END ASC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'desc' THEN idfsSampleType END DESC,
				CASE WHEN @sortColumn = 'strSampleType' AND @SortOrder = 'asc' THEN strSampleType END ASC,
				CASE WHEN @sortColumn = 'strSampleType' AND @SortOrder = 'desc' THEN strSampleType END DESC,
				CASE WHEN @sortColumn = 'idfsDerivativeType' AND @SortOrder = 'asc' THEN idfsDerivativeType END ASC,
				CASE WHEN @sortColumn = 'idfsDerivativeType' AND @SortOrder = 'desc' THEN idfsDerivativeType END DESC,
				CASE WHEN @sortColumn = 'strDerivative' AND @SortOrder = 'asc' THEN strDerivative END ASC,
				CASE WHEN @sortColumn = 'strDerivative' AND @SortOrder = 'desc' THEN strDerivative END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfDerivativeForSampleType,
				idfsSampleType,
				strSampleType,
				idfsDerivativeType, 
				strDerivative
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfDerivativeForSampleType,
				idfsSampleType,
				strSampleType,
				idfsDerivativeType, 
				strDerivative,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
