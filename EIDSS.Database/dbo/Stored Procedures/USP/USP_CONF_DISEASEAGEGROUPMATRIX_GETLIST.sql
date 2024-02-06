-- =========================================================================================
-- NAME: USP_CONF_DISEASEAGEGROUPMATRIX_GETLIST
-- DESCRIPTION: Returns a list of disease to age group relationships

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		03/06/2019	Initial Release
-- Steven Verner	05/16/2021	Paging Enabled
--
-- exec USP_CONF_DISEASEAGEGROUPMATRIX_GETLIST'en', 780170000000
-- exec USP_CONF_DISEASEAGEGROUPMATRIX_GETLIST'en', 780171000000
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASEAGEGROUPMATRIX_GETLIST]
(
	 @LangId NVARCHAR(10)
	,@idfsDiagnosis BIGINT
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'intOrder' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			 idfDiagnosisAgeGroupToDiagnosis bigint
			,idfsDiagnosis bigint
			,strDiseaseDefault nvarchar(2000)
			,strDiseaseName nvarchar(2000)
			,idfsDiagnosisAgeGroup bigint
			,strAgeGroupDefault nvarchar(2000)
			,strAgeGroupName   nvarchar(2000)
			,intOrder int
		)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT 
			 idfDiagnosisAgeGroupToDiagnosis
			,idfsDiagnosis
			,dbr.strDefault AS strDiseaseDefault
			,dbr.name as strDiseaseName
			,dagd.idfsDiagnosisAgeGroup
			,dagbr.strDefault as strAgeGroupDefault
			,dagbr.name as strAgeGroupName
			,dagbr.intOrder
		FROM trtDiagnosisAgeGroupToDiagnosis dagd
		JOIN dbo.FN_GBL_ReferenceRepair(@LangId, 19000019) dbr ON dagd.idfsDiagnosis = dbr.idfsReference AND dagd.intRowStatus = 0
		JOIN dbo.FN_GBL_ReferenceRepair(@LangId, 19000146) dagbr ON dagd.idfsDiagnosisAgeGroup = dagbr.idfsReference AND dagd.intRowStatus = 0
		--JOIN dbo.trtBaseReference br ON br.idfsBaseReference = dagd.idfsDiagnosisAgeGroup
		WHERE dagd.idfsDiagnosis = @idfsDiagnosis
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfDiagnosisAgeGroupToDiagnosis' AND @SortOrder = 'asc' THEN idfDiagnosisAgeGroupToDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfDiagnosisAgeGroupToDiagnosis' AND @SortOrder = 'desc' THEN idfDiagnosisAgeGroupToDiagnosis END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strDiseaseDefault' AND @SortOrder = 'asc' THEN strDiseaseDefault END ASC,
				CASE WHEN @sortColumn = 'strDiseaseDefault' AND @SortOrder = 'desc' THEN strDiseaseDefault END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosisAgeGroup' AND @SortOrder = 'asc' THEN idfsDiagnosisAgeGroup END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosisAgeGroup' AND @SortOrder = 'desc' THEN idfsDiagnosisAgeGroup END DESC,
				CASE WHEN @sortColumn = 'strAgeGroupDefault' AND @SortOrder = 'asc' THEN strAgeGroupDefault END ASC,
				CASE WHEN @sortColumn = 'strAgeGroupDefault' AND @SortOrder = 'desc' THEN strAgeGroupDefault END DESC,
				CASE WHEN @sortColumn = 'strAgeGroupName' AND @SortOrder = 'asc' THEN strAgeGroupName END ASC,
				CASE WHEN @sortColumn = 'strAgeGroupName' AND @SortOrder = 'desc' THEN strAgeGroupName END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				 TotalRowCount
				,idfDiagnosisAgeGroupToDiagnosis 
				,idfsDiagnosis 
				,strDiseaseDefault
				,strDiseaseName 
				,idfsDiagnosisAgeGroup
				,strAgeGroupDefault
				,strAgeGroupName
				,intOrder
			FROM @T
		)

			SELECT
				TotalRowCount
				,idfDiagnosisAgeGroupToDiagnosis 
				,idfsDiagnosis 
				,strDiseaseDefault
				,strDiseaseName 
				,idfsDiagnosisAgeGroup
				,strAgeGroupDefault
				,strAgeGroupName
				,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
				,CurrentPage = @pageNo 
				,intOrder
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 


	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
