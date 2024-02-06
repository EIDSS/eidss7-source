/****** Object:  StoredProcedure [dbo].[USP_DAS_MYNOTIFICATIONS_GETList]    Script Date: 5/6/2019 6:00:08 PM ******/

-- ================================================================================================
-- Name: USP_DAS_MYNOTIFICATIONS_GETList
--
-- Description: Returns a list of human disease reports based on the language and user.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- ----------------------------------------------------------------
-- Ricky Moss         11/19/2018 Initial Release
-- Ricky Moss         11/30/2018 Removed reference type id variables and return code
-- Ricky Moss         05/06/2018 Added Pagination
-- Stephen Long       01/24/2020 Cleaned up stored procedure, and corrected joins for person 
--                               investigated by.
-- Leo Tracchia			02/18/2022 Added pagination logic for radzen components
-- Leo Tracchia			02/28/2022 Added HumanID field to return
-- Testing Code:
-- exec USP_DAS_MYNOTIFICATIONS_GETList 'en', 55465230000000, 1, 10, 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_MYNOTIFICATIONS_GETList] (
	@LanguageID NVARCHAR(50),
	@PersonID BIGINT,
	--@PaginationSet INT = 1,
	--@PageSize INT = 10,
	--@MaxPagesPerFetch INT = 10
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'DateEntered',
	@sortOrder NVARCHAR(4) = 'asc'  
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	DECLARE @firstRec INT
    DECLARE @lastRec INT

	DECLARE @tempNotifications TABLE( 
		HumanCaseID bigint,
		HumanID bigint,
		ReportID nvarchar(2000),
		DateEntered datetime,
		PersonName nvarchar(2000),
		DiseaseName nvarchar(2000), 
		DateOfDisease datetime,
		[Classification] nvarchar(2000),		
		InvestigatedBy nvarchar(2000)		
	)

    SET @firstRec = (@pageNo-1)* @pagesize
    SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
	
		INSERT INTO @tempNotifications

		SELECT hc.idfHumanCase as 'HumanCaseID',
			hc.idfHuman as 'HumanID',
			hc.strCaseId AS 'ReportID',
			hc.datEnteredDate as 'DateEntered',
			ISNULL(LEFT(h.strFirstName, 1), '') + ISNULL(LEFT(h.strLastName, 1), N'') AS 'PersonName',
			ISNULL(finalDiagnosis.name, tentativeDiagnosis.name) AS 'DiseaseName',
			hc.datTentativeDiagnosisDate AS 'DateOfDisease',
			ISNULL(finalCaseClassification.name, initialCaseClassification.name) AS 'Classification',
			ISNULL(investigatedBy.strFamilyName, N'') + ISNULL(' ' + investigatedBy.strFirstName, '') + ISNULL(' ' + investigatedBy.strSecondName, '') AS 'InvestigatedBy'
		FROM dbo.tlbHumanCase hc
		LEFT JOIN dbo.tlbHuman AS h
			ON h.idfHuman = hc.idfHuman
				AND h.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) tentativeDiagnosis
			ON tentativediagnosis.idfsReference = hc.idfsFinalDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) finalDiagnosis
			ON finalDiagnosis.idfsReference = hc.idfsFinalDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) initialCaseClassification
			ON initialCaseClassification.idfsReference = hc.idfsInitialCaseStatus
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) finalCaseClassification
			ON finalCaseClassification.idfsReference = hc.idfsFinalCaseStatus
		LEFT JOIN dbo.tlbPerson AS investigatedBy
			ON investigatedBy.idfPerson = hc.idfInvestigatedByPerson
				AND investigatedBy.intRowStatus = 0
		WHERE hc.intRowStatus = 0
			AND hc.datEnteredDate IS NOT NULL
			AND idfInvestigatedByPerson = @PersonID;
		
		--ORDER BY hc.datEnteredDate OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS
		--FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;

		--SELECT @ReturnCode,
		--	@ReturnMessage;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'HumanCaseID' AND @SortOrder = 'asc' THEN HumanCaseID END ASC,
				CASE WHEN @sortColumn = 'HumanCaseID' AND @SortOrder = 'desc' THEN HumanCaseID END DESC,

				CASE WHEN @sortColumn = 'HumanID' AND @SortOrder = 'asc' THEN HumanID END ASC,
				CASE WHEN @sortColumn = 'HumanID' AND @SortOrder = 'desc' THEN HumanID END DESC,

				CASE WHEN @sortColumn = 'ReportID' AND @SortOrder = 'asc' THEN ReportID END ASC,
				CASE WHEN @sortColumn = 'ReportID' AND @SortOrder = 'desc' THEN ReportID END DESC,

				CASE WHEN @sortColumn = 'DateEntered' AND @SortOrder = 'asc' THEN DateEntered END ASC,
				CASE WHEN @sortColumn = 'DateEntered' AND @SortOrder = 'desc' THEN DateEntered END DESC,

				CASE WHEN @sortColumn = 'PersonName' AND @SortOrder = 'asc' THEN PersonName END ASC,
				CASE WHEN @sortColumn = 'PersonName' AND @SortOrder = 'desc' THEN PersonName END DESC,

				CASE WHEN @sortColumn = 'DiseaseName' AND @SortOrder = 'asc' THEN DiseaseName END ASC,
				CASE WHEN @sortColumn = 'DiseaseName' AND @SortOrder = 'desc' THEN DiseaseName END DESC,

				CASE WHEN @sortColumn = 'DateOfDisease' AND @SortOrder = 'asc' THEN DateOfDisease END ASC,
				CASE WHEN @sortColumn = 'DateOfDisease' AND @SortOrder = 'desc' THEN DateOfDisease END DESC,

				CASE WHEN @sortColumn = 'Classification' AND @SortOrder = 'asc' THEN [Classification] END ASC,
				CASE WHEN @sortColumn = 'Classification' AND @SortOrder = 'asc' THEN [Classification] END ASC,

				CASE WHEN @sortColumn = 'InvestigatedBy' AND @SortOrder = 'desc' THEN InvestigatedBy END DESC,
				CASE WHEN @sortColumn = 'InvestigatedBy' AND @SortOrder = 'asc' THEN InvestigatedBy END ASC
			
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				HumanCaseID,
				HumanID,
				ReportID,
				DateEntered,
				PersonName,
				DiseaseName,
				DateOfDisease,
				[Classification],
				InvestigatedBy						
			FROM @tempNotifications
		)	
			SELECT
			TotalRowCount,
			HumanCaseID,
			HumanID,
			ReportID,
			DateEntered,
			PersonName,
			DiseaseName,
			DateOfDisease,
			[Classification],
			InvestigatedBy				
			,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
			,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

		OPTION (RECOMPILE);
	END TRY

	BEGIN CATCH
		--SET @ReturnCode = ERROR_NUMBER();
		--SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,
		--	@ReturnMessage;

		THROW;
	END CATCH;
END
