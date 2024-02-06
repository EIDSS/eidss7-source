-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_LOG_GETList
--
-- Description:	Get disease case log list for the veterinary disease edit/enter and other use 
-- cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/30/2021 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_CASE_LOG_GETList] (
	@LanguageID NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'ActionRequired'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@DiseaseReportID BIGINT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize
			,@LastRec INT = (@PageNumber * @PageSize + 1)
			,@TotalRowCount INT = (
				SELECT COUNT(*)
				FROM dbo.tlbVetCaseLog vcl
				WHERE vcl.intRowStatus = 0
					AND (
						vcl.idfVetCase = @DiseaseReportID
						OR @DiseaseReportID IS NULL
						)
				);

		SELECT DiseaseReportLogID
			,LogStatusTypeID
			,LogStatusTypeName
			,DiseaseReportID
			,EnteredByPersonID
			,EnteredByPersonName
			,LogDate
			,ActionRequired
			,Comments
			,RowStatus
			,RowAction
			,[RowCount]
			,TotalRowCount
			,CurrentPage
			,TotalPages
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @SortColumn = 'ActionRequired'
								AND @SortOrder = 'ASC'
								THEN vcl.strActionRequired
							END ASC
						,CASE 
							WHEN @SortColumn = 'ActionRequired'
								AND @SortOrder = 'DESC'
								THEN vcl.strActionRequired
							END DESC
						,CASE 
							WHEN @SortColumn = 'LogDate'
								AND @SortOrder = 'ASC'
								THEN vcl.datCaseLogDate
							END ASC
						,CASE 
							WHEN @SortColumn = 'LogDate'
								AND @SortOrder = 'DESC'
								THEN vcl.datCaseLogDate
							END DESC
						,CASE 
							WHEN @SortColumn = 'EnteredByPersonName'
								AND @SortOrder = 'ASC'
								THEN ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, N'') + ISNULL(' ' + p.strSecondName, N'')
							END ASC
						,CASE 
							WHEN @SortColumn = 'EnteredByPersonName'
								AND @SortOrder = 'DESC'
								THEN ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, N'') + ISNULL(' ' + p.strSecondName, N'')
							END DESC
						,CASE 
							WHEN @SortColumn = 'Comments'
								AND @SortOrder = 'ASC'
								THEN vcl.strNote
							END ASC
						,CASE 
							WHEN @SortColumn = 'Comments'
								AND @SortOrder = 'DESC'
								THEN vcl.strNote
							END DESC
						,CASE 
							WHEN @SortColumn = 'LogStatusTypeName'
								AND @SortOrder = 'ASC'
								THEN logStatusType.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'LogStatusTypeName'
								AND @SortOrder = 'DESC'
								THEN logStatusType.name
							END DESC
					) AS RowNum
				,vcl.idfVetCaseLog AS DiseaseReportLogID
				,vcl.idfsCaseLogStatus AS LogStatusTypeID
				,logStatusType.name AS LogStatusTypeName
				,vcl.idfVetCase AS DiseaseReportID
				,vcl.idfPerson AS EnteredByPersonID
				,ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, N'') + ISNULL(' ' + p.strSecondName, N'') AS EnteredByPersonName
				,vcl.datCaseLogDate AS LogDate
				,vcl.strActionRequired AS ActionRequired
				,vcl.strNote AS Comments
				,vcl.intRowStatus AS RowStatus
				,0 AS RowAction
				,COUNT(*) OVER () AS [RowCount]
				,@TotalRowCount AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
			FROM dbo.tlbVetCaseLog vcl
			LEFT JOIN dbo.tlbPerson p ON p.idfPerson = vcl.idfPerson
				AND p.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000103) logStatusType ON logStatusType.idfsReference = vcl.idfsCaseLogStatus
			WHERE vcl.intRowStatus = 0
				AND (
					vcl.idfVetCase = @DiseaseReportID
					OR @DiseaseReportID IS NULL
					)
			GROUP BY vcl.idfVetCaseLog
				,vcl.idfsCaseLogStatus
				,logStatusType.name
				,vcl.idfVetCase
				,vcl.idfPerson
				,p.strFamilyName
				,p.strFirstName
				,p.strSecondName
				,vcl.datCaseLogDate
				,vcl.strActionRequired
				,vcl.strNote
				,vcl.intRowStatus
			) AS x
		WHERE RowNum > @FirstRec
			AND RowNum < @LastRec
		ORDER BY RowNum;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
