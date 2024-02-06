-- ================================================================================================
-- Name: USP_LAB_TEST_AMENDMENT_GETList
--
-- Description:	Get test amendment history list for the various lab use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/11/2018 Initial release.
-- Stephen Long     01/25/2019 Removed preceeding ; on CATCH.
-- Stephen Long     03/01/2019 Added return code and return message.
-- Stephen Long     01/22/2020 Cleaned up stored procedure.
-- Stephen Long     09/25/2021 Removed return code and message in the catch portion to work with 
--                             POCO.
-- Stephen Long     11/06/2021 Added new pagination and dynamic sorting.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TEST_AMENDMENT_GETList]
		@LanguageID = N'en-US',
		@TestID = 1,
		@PageNumber = 1,
		@PageSize = 10,
		@SortColumn = 'ReasonForAmendment',
		@SortOrder = 'ASC'

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_TEST_AMENDMENT_GETList] (
	@LanguageID NVARCHAR(50)
	,@TestID BIGINT
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'AmendmentDate'
	,@SortOrder NVARCHAR(4) = 'DESC'
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS'
		,@ReturnCode INT = 0
		,@FirstRec INT = (@PageNumber - 1) * @PageSize
		,@LastRec INT = (@PageNumber * @PageSize + 1)
		,@TotalRowCount INT = (
			SELECT COUNT(*)
			FROM dbo.tlbTestAmendmentHistory
			WHERE intRowStatus = 0
				AND idfTesting = @TestID
			);

	BEGIN TRY
		SELECT AmendmentHistoryID
			,AmendedByOrganizationName
			,AmendedByPersonName
			,AmendmentDate
			,OriginalTestResultTypeName
			,ChangedTestResultTypeName
			,ReasonForAmendment
			,[RowCount]
			,TotalRowCount
			,CurrentPage
			,TotalPages
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @SortColumn = 'AmendedByOrganizationName'
								AND @SortOrder = 'ASC'
								THEN amendedByOrganization.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'AmendedByOrganizationName'
								AND @SortOrder = 'DESC'
								THEN amendedByOrganization.name
							END DESC
						,CASE 
							WHEN @SortColumn = 'AmendedByPersonName'
								AND @SortOrder = 'ASC'
								THEN ISNULL(amendedByPerson.strFamilyName, N'') + ISNULL(' ' + amendedByPerson.strFirstName, '') + ISNULL(' ' + amendedByPerson.strSecondName, '')
							END ASC
						,CASE 
							WHEN @SortColumn = 'AmendedByPersonName'
								AND @SortOrder = 'DESC'
								THEN ISNULL(amendedByPerson.strFamilyName, N'') + ISNULL(' ' + amendedByPerson.strFirstName, '') + ISNULL(' ' + amendedByPerson.strSecondName, '')
							END DESC
						,CASE 
							WHEN @SortColumn = 'AmendmentDate'
								AND @SortOrder = 'ASC'
								THEN tah.datAmendmentDate
							END ASC
						,CASE 
							WHEN @SortColumn = 'AmendmentDate'
								AND @SortOrder = 'DESC'
								THEN tah.datAmendmentDate
							END DESC
						,CASE 
							WHEN @SortColumn = 'OriginalTestResultTypeName'
								AND @SortOrder = 'ASC'
								THEN originalTestResult.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'OriginalTestResultTypeName'
								AND @SortOrder = 'DESC'
								THEN originalTestResult.name
							END DESC
						,CASE 
							WHEN @SortColumn = 'ChangedTestResultTypeName'
								AND @SortOrder = 'ASC'
								THEN changedTestResult.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'ChangedTestResultTypeName'
								AND @SortOrder = 'DESC'
								THEN changedTestResult.name
							END DESC
						,CASE 
							WHEN @SortColumn = 'ReasonForAmendment'
								AND @SortOrder = 'ASC'
								THEN tah.strReason
							END ASC
						,CASE 
							WHEN @SortColumn = 'ReasonForAmendment'
								AND @SortOrder = 'DESC'
								THEN tah.strReason
							END DESC
					) AS RowNum
				,tah.idfTestAmendmentHistory AS AmendmentHistoryID
				,amendedByOrganization.name AS AmendedByOrganizationName
				,ISNULL(amendedByPerson.strFamilyName, N'') + ISNULL(' ' + amendedByPerson.strFirstName, '') + ISNULL(' ' + amendedByPerson.strSecondName, '') AS AmendedByPersonName
				,tah.datAmendmentDate AS AmendmentDate
				,originalTestResult.name AS OriginalTestResultTypeName
				,changedTestResult.name AS ChangedTestResultTypeName
				,tah.strReason AS ReasonForAmendment
				,COUNT(*) OVER () AS [RowCount]
				,@TotalRowCount AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
			FROM dbo.tlbTestAmendmentHistory tah
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) originalTestResult ON originalTestResult.idfsReference = tah.idfsOldTestResult
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) changedTestResult ON changedTestResult.idfsReference = tah.idfsNewTestResult
			LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) amendedByOrganization ON amendedByOrganization.idfOffice = tah.idfAmendByOffice
				AND amendedByOrganization.intRowStatus = 0
			LEFT JOIN dbo.tlbPerson amendedByPerson ON amendedByPerson.idfPerson = tah.idfAmendByPerson
			WHERE tah.idfTesting = @TestID
				AND tah.intRowStatus = 0
			GROUP BY tah.idfTestAmendmentHistory
				,tah.datAmendmentDate
				,originalTestResult.name
				,changedTestResult.name
				,amendedByOrganization.name
				,amendedByPerson.strFamilyName
				,amendedByPerson.strFirstName
				,amendedByPerson.strSecondName
				,tah.strReason
			) AS x
		WHERE RowNum > @FirstRec
			AND RowNum < @LastRec
		ORDER BY RowNum;

		--SELECT @ReturnCode ,@ReturnMessage;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
