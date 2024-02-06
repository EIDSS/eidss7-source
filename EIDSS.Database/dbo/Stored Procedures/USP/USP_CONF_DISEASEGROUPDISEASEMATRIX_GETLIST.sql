--=====================================================================================================
-- Name: USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLIST
-- Description:	Returns a list of single diseases for a group of diseases
--							
-- Author:		Philip Shaffer
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		03/18/2018  Initial Release
-- Ann Xiong        04/27/2021 Added paging
--
-- Test Code:
-- exec USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLIST 'en', 51529030000000
-- exec USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLIST 'en', 51529040000000
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLIST]
(
	@LangId NVARCHAR(50),
	@idfsDiagnosisGroup BIGINT
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'idfsDiagnosis' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfDiagnosisToDiagnosisGroup bigint,
			idfsDiagnosisGroup bigint,
			strDefault nvarchar(2000), 
			idfsDiagnosis bigint,
			strDiseaseDefault nvarchar(2000),
			strDiseaseName nvarchar(2000), 
			strUsingType nvarchar(2000), 
			strHACodeNames nvarchar(2000), 
			intOrder int
			)
	
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT	ddg.idfDiagnosisToDiagnosisGroup, 
				ddg.idfsDiagnosisGroup, 
				dgbr.strDefault, 
				ddg.idfsDiagnosis, 
				dbr.strDefault as strDiseaseDefault, 
				dbr.name as strDiseaseName, 
				ut.name as strUsingType, 
			   dbo.FN_GBL_HACodeNames_ToCSV(@LangId, dbr.[intHACode]) AS [strHACodeNames], 
			   dbr.intOrder  
		FROM	trtDiagnosisToDiagnosisGroup ddg
				JOIN FN_GBL_Reference_GETList(@LangId, 19000019) dbr
					ON ddg.idfsDiagnosis = dbr.idfsReference
				JOIN trtDiagnosis d
					ON ddg.idfsDiagnosis = d.idfsDiagnosis
				JOIN dbo.FN_GBL_Reference_GETList(@LangId, 19000020) ut 
					ON d.idfsUsingType = ut.idfsReference
				JOIN dbo.FN_GBL_Reference_GETList(@LangId, 19000156) dgbr
					ON ddg.idfsDiagnosisGroup = dgbr.idfsReference
		WHERE	ddg.intRowStatus = 0 AND idfsDiagnosisGroup = @idfsDiagnosisGroup
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'idfDiagnosisToDiagnosisGroup' AND @SortOrder = 'asc' THEN idfDiagnosisToDiagnosisGroup END ASC,
				CASE WHEN @sortColumn = 'idfDiagnosisToDiagnosisGroup' AND @SortOrder = 'desc' THEN idfDiagnosisToDiagnosisGroup END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosisGroup' AND @SortOrder = 'asc' THEN idfsDiagnosisGroup END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosisGroup' AND @SortOrder = 'desc' THEN idfsDiagnosisGroup END DESC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strDiseaseDefault' AND @SortOrder = 'asc' THEN strDiseaseDefault END ASC,
				CASE WHEN @sortColumn = 'strDiseaseDefault' AND @SortOrder = 'desc' THEN strDiseaseDefault END DESC,
				CASE WHEN @sortColumn = 'strDiseaseName' AND @SortOrder = 'asc' THEN strDiseaseName END ASC,
				CASE WHEN @sortColumn = 'strDiseaseName' AND @SortOrder = 'desc' THEN strDiseaseName END DESC,
				CASE WHEN @sortColumn = 'strUsingType' AND @SortOrder = 'asc' THEN strUsingType END ASC,
				CASE WHEN @sortColumn = 'strUsingType' AND @SortOrder = 'desc' THEN strUsingType END DESC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'asc' THEN strHACodeNames END ASC,
				CASE WHEN @sortColumn = 'strHACodeNames' AND @SortOrder = 'desc' THEN strHACodeNames END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfDiagnosisToDiagnosisGroup,
				idfsDiagnosisGroup,
				strDefault,
				idfsDiagnosis, 
				strDiseaseDefault,
				strDiseaseName,
				strUsingType,
				strHACodeNames, 
				intOrder
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfDiagnosisToDiagnosisGroup,
				idfsDiagnosisGroup,
				strDefault,
				idfsDiagnosis, 
				strDiseaseDefault,
				strDiseaseName,
				strUsingType,
				strHACodeNames, 
				intOrder,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
