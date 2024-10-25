
-- ================================================================================================
-- Name: USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_GETLIST
--
-- Description:	Returns list of report disease group to disease matrices given a custom report type 
-- and report disease group.
--				
-- Author:		Ricky Moss
--
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Ricky Moss		03/25/2018	Initial Release
-- Stephen Long     12/26/2019	Replaced 'en' with @LangID on reference call.
-- Leo Tracchia		07/22/2021	Added idfDiagnosisToGroupForReportType field to return
--
-- Test Code:
-- exec USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_GETLIST 'en', 55540680000323, 53352780000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_GETLIST] (
	 @langId NVARCHAR(50)
	,@idfsCustomReportType BIGINT
	,@idfsReportDiagnosisGroup BIGINT
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strDiagnosis' 
	,@sortOrder NVARCHAR(4) = 'asc'	)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfDiagnosisToGroupForReportType bigint,
			idfsCustomReportType bigint,
			strCustomReportType nvarchar(2000),
			idfsDiagnosis bigint,
			strDiagnosis nvarchar(2000),
			idfsUsingType bigint,
			strUsingType nvarchar(2000),
			strAccessoryCode nvarchar(4000),
			idfsReportDiagnosisGroup bigint,
			strReportDiagnosisGroup nvarchar(2000),
			strIsDelete nvarchar(10)
		)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
			SELECT dgrt.idfDiagnosisToGroupForReportType,
				dgrt.idfsCustomReportType,
				crtbr.name AS strCustomReportType,
				dgrt.idfsDiagnosis,
				dbr.name AS strDiagnosis,
				d.idfsUsingType,
				utbr.name AS strUsingType,
				dbo.FN_GBL_HACodeNames_ToCSV(@langId, dbr.intHACode) AS strAccessoryCode,
				dgrt.idfsReportDiagnosisGroup,
				rdgbr.name AS strReportDiagnosisGroup,
				CASE 
					WHEN dgrt.intRowStatus = 0
						THEN 'No'
					ELSE 'Yes'
					END AS strIsDelete
			FROM dbo.trtDiagnosisToGroupForReportType dgrt 
			JOIN dbo.trtDiagnosis d ON dgrt.idfsDiagnosis = d.idfsDiagnosis
			JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000019) dbr ON d.idfsDiagnosis = dbr.idfsReference
			JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000020) utbr ON d.idfsUsingType = utbr.idfsReference
			JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000129) crtbr ON dgrt.idfsCustomReportType = crtbr.idfsReference
			JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000130) rdgbr ON dgrt.idfsReportDiagnosisGroup = rdgbr.idfsReference
			WHERE dgrt.idfsCustomReportType = @idfsCustomReportType AND dgrt.idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
			;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strDiagnosis' AND @SortOrder = 'asc' THEN strDiagnosis END ASC,
				CASE WHEN @sortColumn = 'strDiagnosis' AND @SortOrder = 'desc' THEN strDiagnosis END DESC,
				CASE WHEN @sortColumn = 'strUsingType' AND @SortOrder = 'asc' THEN strUsingType END ASC,
				CASE WHEN @sortColumn = 'strUsingType' AND @SortOrder = 'desc' THEN strUsingType END DESC,
				CASE WHEN @sortColumn = 'strAccessoryCode' AND @SortOrder = 'asc' THEN strAccessoryCode END ASC,
				CASE WHEN @sortColumn = 'strAccessoryCode' AND @SortOrder = 'desc' THEN strAccessoryCode END DESC,
				CASE WHEN @sortColumn = 'strIsDelete' AND @SortOrder = 'asc' THEN strIsDelete END ASC,
				CASE WHEN @sortColumn = 'strIsDelete' AND @SortOrder = 'desc' THEN strIsDelete END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfDiagnosisToGroupForReportType,
				strDiagnosis,
				strUsingType,
				strAccessoryCode,
				strIsDelete
			FROM @T
		)

			SELECT
				TotalRowCount, 
				idfDiagnosisToGroupForReportType,
				strDiagnosis,
				strUsingType,
				strAccessoryCode,
				strIsDelete,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
