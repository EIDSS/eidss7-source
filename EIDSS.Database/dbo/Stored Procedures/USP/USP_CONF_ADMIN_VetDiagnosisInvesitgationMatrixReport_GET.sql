


CREATE PROCEDURE [dbo].[USP_CONF_ADMIN_VetDiagnosisInvesitgationMatrixReport_GET] 
/*******************************************************
NAME						: [USP_CONF_ADMIN_VetDiagnosisInvesitgationMatrixReport_GET]		


Description					: Retreives List of Vet Investigation Diagnosisis  Matrix  by version

Author						: Lamont Mitchell

Revision History
		
Name					Date			Change Detail
Lamont Mitchell			03/4/19			Initial Created
Mark Wilson				04/13/21		Added Translation
Mark Wilson				10/28/21		Added FN_GBL_ReferenceRepair joins

/* Test code

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_CONF_ADMIN_VetDiagnosisInvesitgationMatrixReport_GET]
		@idfVersion = 115299280001057,
		@LangID = N'en-US'

SELECT	'Return Value' = @return_value

*/

*******************************************************/
 (
	@idfVersion BIGINT,
	@LangID NVARCHAR(24),
	@pageNo INT = 1,
	@pageSize INT = 10,
	@sortColumn NVARCHAR(30) = 'intNumRow',
	@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	DECLARE @firstRec INT
	DECLARE @lastRec INT
	DECLARE @t TABLE( 
		intNumRow bigint, 
		idfAggrDiagnosticActionMTX bigint,
		idfsDiagnosticAction bigint,
		strInvestigationType nvarchar(2000),
		idfsSpeciesType bigint,
		strSpeciesTypeName nvarchar(2000),
		idfsDiagnosis bigint,		
		strDiagnosisName nvarchar(2000),
		strOIECode nvarchar(4000))	
	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY 
		INSERT INTO @t
		SELECT	 
			mtx.intNumRow,
			mtx.idfAggrDiagnosticActionMTX as idfAggrDiagnosticActionMTX,
			mtx.idfsDiagnosticAction, -- Investigation Type	Id	
			DI.[name] AS strDiagnosticInvestigation, -- Investigation Type	Name
			mtx.idfsSpeciesType, -- SpeciesTypeId			
			ST.[name], -- Species Type Name
			mtx.idfsDiagnosis, -- Diagnosis Id			
			D.[name], -- Diagnosis Name
			D.strOIECode -- ICD Code
		FROM dbo.tlbAggrDiagnosticActionMTX mtx
		
		INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 96, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- use 96 for Vet (Livestock = 32, Avain = 64), 10020002 for Aggregate cases
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) ST ON ST.idfsReference = mtx.idfsSpeciesType
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000021) DI ON DI.idfsReference = mtx.idfsDiagnosticAction
	
		WHERE mtx.intRowStatus = 0 
		AND mtx.idfVersion = @idfVersion;
	
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'intNumRow' AND @SortOrder = 'asc' THEN intNumRow END ASC,
				CASE WHEN @sortColumn = 'intNumRow' AND @SortOrder = 'desc' THEN intNumRow END DESC,
				
				CASE WHEN @sortColumn = 'idfAggrDiagnosticActionMTX' AND @SortOrder = 'asc' THEN idfAggrDiagnosticActionMTX END ASC,
				CASE WHEN @sortColumn = 'idfAggrDiagnosticActionMTX' AND @SortOrder = 'desc' THEN idfAggrDiagnosticActionMTX END DESC,

				CASE WHEN @sortColumn = 'idfsDiagnosticAction' AND @SortOrder = 'asc' THEN idfsDiagnosticAction END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosticAction' AND @SortOrder = 'desc' THEN idfsDiagnosticAction END DESC,

				CASE WHEN @sortColumn = 'strInvestigationType' AND @SortOrder = 'asc' THEN strInvestigationType END ASC,
				CASE WHEN @sortColumn = 'strInvestigationType' AND @SortOrder = 'desc' THEN strInvestigationType END DESC,
				
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'asc' THEN idfsSpeciesType END ASC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'desc' THEN idfsSpeciesType END DESC,

				CASE WHEN @sortColumn = 'strSpeciesTypeName' AND @SortOrder = 'asc' THEN strSpeciesTypeName END ASC,
				CASE WHEN @sortColumn = 'strSpeciesTypeName' AND @SortOrder = 'desc' THEN strSpeciesTypeName END DESC,

				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				
				CASE WHEN @sortColumn = 'strDiagnosisName' AND @SortOrder = 'asc' THEN strDiagnosisName END ASC,
				CASE WHEN @sortColumn = 'strDiagnosisName' AND @SortOrder = 'desc' THEN strDiagnosisName END DESC,
				
				CASE WHEN @sortColumn = 'strOIECode' AND @SortOrder = 'asc' THEN strOIECode END ASC,
				CASE WHEN @sortColumn = 'strOIECode' AND @SortOrder = 'desc' THEN strOIECode END DESC

		) AS ROWNUM,
		COUNT(*) OVER () AS 
			TotalRowCount, 
			intNumRow,
			idfAggrDiagnosticActionMTX,
			idfsDiagnosticAction,	
			strInvestigationType,			
			idfsSpeciesType,
			strSpeciesTypeName,
			idfsDiagnosis,					
			strDiagnosisName,
			strOIECode
			FROM @T
		)

			SELECT
			TotalRowCount, 
			intNumRow,
			idfAggrDiagnosticActionMTX,
			idfsDiagnosticAction,
			strInvestigationType,	
			idfsSpeciesType,
			strSpeciesTypeName,
			idfsDiagnosis,						
			strDiagnosisName,
			strOIECode,
			TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
			CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
		 

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
