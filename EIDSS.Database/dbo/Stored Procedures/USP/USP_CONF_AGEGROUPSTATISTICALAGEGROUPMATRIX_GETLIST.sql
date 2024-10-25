-- =================================================================================================================
-- Name:		USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_GETLIST
-- Description:	Returns a list of vector type to field test matrices given a language and age group id
-- Author:		Ricky Moss
--
-- Revision History:
-- Name:			Date:		Revision:
-- --------------- -----------  ---------------------------------------------
-- Ricky Moss		04/03/2019	Initial Release
-- Mike Korengay	05/14/2021	Add paging and sorting
--
-- EXEC USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_GETLIST 'en', 15300001100
-- EXEC USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_GETLIST 'en', 51529290000000
-- =================================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_GETLIST]
(
	@langId NVARCHAR(10)
	,@idfsDiagnosisAgeGroup BIGINT
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strStatisticalAgeGroupName' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfDiagnosisAgeGroupToStatisticalAgeGroup bigint, 
			idfsDiagnosisAgeGroup bigint, 
			strDiagnosisAgeGroupName nvarchar(2000), 
			idfsStatisticalAgeGroup bigint,
			strStatisticalAgeGroupName nvarchar(2000)
		)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		INSERT INTO @t
			SELECT 
				idfDiagnosisAgeGroupToStatisticalAgeGroup, 
				idfsDiagnosisAgeGroup, 
				dagbr.name as strDiagnosisAgeGroupName, 
				idfsStatisticalAgeGroup, 
				sagbr.name as strStatisticalAgeGroupName 
			FROM trtDiagnosisAgeGroupToStatisticalAgeGroup dagsag
			JOIN FN_GBL_Reference_GETList(@langId, 19000146) dagbr
			ON dagsag.idfsDiagnosisAgeGroup = dagbr.idfsReference
			JOIN FN_GBL_Reference_GETList(@langId, 19000145) sagbr
			ON dagsag.idfsStatisticalAgeGroup = sagbr.idfsReference
			WHERE 
				dagsag.intRowStatus = 0 
				AND idfsDiagnosisAgeGroup = @idfsDiagnosisAgeGroup
		;
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strStatisticalAgeGroupName' AND @SortOrder = 'asc' THEN strStatisticalAgeGroupName END ASC,
				CASE WHEN @sortColumn = 'strStatisticalAgeGroupName' AND @SortOrder = 'desc' THEN strStatisticalAgeGroupName END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfDiagnosisAgeGroupToStatisticalAgeGroup,
				idfsDiagnosisAgeGroup,
				strDiagnosisAgeGroupName,	
				idfsStatisticalAgeGroup,
				strStatisticalAgeGroupName
			FROM @T
		)
			SELECT
				TotalRowCount, 
				idfDiagnosisAgeGroupToStatisticalAgeGroup,
				idfsDiagnosisAgeGroup,
				strDiagnosisAgeGroupName,	
				idfsStatisticalAgeGroup,
				strStatisticalAgeGroupName,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
