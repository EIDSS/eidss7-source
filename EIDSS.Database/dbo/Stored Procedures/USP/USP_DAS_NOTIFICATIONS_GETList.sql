/****** Object:  StoredProcedure [dbo].[USP_DAS_NOTIFICATIONS_GETList]    Script Date: 5/6/2019 5:54:35 PM ******/
-- ================================================================================================
-- Name: USP_DAS_NOTIFICATIONS_GETList
--
-- Description: Returns a list of human disease reports based on the language and site list.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name					Date			Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Ricky Moss			11/19/2018 Initial Release
-- Ricky Moss			11/30/2018 Removed reference type id variable and return code
-- Ricky Moss			12/03/2018 Added Notified By Person field
-- Ricky Moss			05/06/2019 Added Pagination
-- Stephen Long         01/25/2020 Added site list parameter for site filtration.
-- Leo Tracchia			02/18/2022 Added pagination logic for radzen components
-- Testing Code:
-- exec USP_DAS_NOTIFICATIONS_GETList 'en', 1, 10, 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_NOTIFICATIONS_GETList] (
	@LanguageID NVARCHAR(50),
	@SiteList VARCHAR(MAX) = NULL,
	--@PaginationSet INT = 1,
	--@PageSize INT = 10,
	--@MaxPagesPerFetch INT = 10
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'DateEntered',
	@sortOrder NVARCHAR(4) = 'desc'  
	)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
	--	@ReturnCode BIGINT = 0;

	DECLARE @firstRec INT
    DECLARE @lastRec INT

	DECLARE @tempNotifications TABLE( 
		HumanCaseID BIGINT PRIMARY KEY NOT NULL,
		HumanID bigint,
		ReportID  nvarchar(2000),
		DateEntered datetime,
		PersonName nvarchar(2000),
		DiseaseName nvarchar(2000), 
		NotifyingOrganizationName nvarchar(2000),
		InpatientOrOutpatient nchar(1),
		NotifiedBy nvarchar(2000)		
	)

     SET @firstRec = (@pageNo-1)* @pagesize
     SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		DECLARE @siteListTable TABLE (idfsSiteId BIGINT PRIMARY KEY)
		INSERT INTO @siteListTable
		SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@siteList, NULL, ',')

	INSERT INTO @tempNotifications

		SELECT hc.idfHumanCase as 'HumanCaseID',
			hc.idfHuman as 'HumanID',
			hc.strCaseId AS 'ReportID',
			hc.datEnteredDate as 'DateEntered',
			--dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName,'') as 'PersonName',
			ISNULL(LEFT(h.strFirstName, 1), '') + ISNULL(LEFT(h.strLastName, 1), N'') AS 'PersonName',
			finalDiagnosis.Name AS 'DiseaseName',
			hospital.FullName AS 'NotifyingOrganizationName',
			CASE hc.idfsYNHospitalization
				WHEN 10100001
					THEN 'I'
				ELSE 'O'
				END AS 'InpatientOrOutpatient',
			dbo.FN_GBL_ConcatFullName(personEnteredBy.strFamilyName, personEnteredBy.strFirstName,'')
		FROM dbo.tlbHumanCase hc
		LEFT JOIN dbo.tlbHuman AS h ON h.idfHuman = hc.idfHuman AND h.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) finalDiagnosis
			ON hc.idfsFinalDiagnosis = Finaldiagnosis.idfsReference 
		LEFT JOIN dbo.tlbPerson AS personEnteredBy
			ON hc.idfPersonEnteredBy  = personEnteredBy.idfPerson AND personEnteredBy.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_INSTITUTION(@LanguageID) hospital
			ON hc.idfHospital = hospital.idfOffice 
		WHERE hc.intRowStatus = 0
			AND hc.datEnteredDate IS NOT NULL
			AND (hc.idfsSite IN (SELECT * FROM @siteListTable)OR (@SiteList IS NULL))
			AND hc.idfInvestigatedByPerson is null;			
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

				CASE WHEN @sortColumn = 'NotifyingOrganizationName' AND @SortOrder = 'asc' THEN NotifyingOrganizationName END ASC,
				CASE WHEN @sortColumn = 'NotifyingOrganizationName' AND @SortOrder = 'desc' THEN NotifyingOrganizationName END DESC,

				CASE WHEN @sortColumn = 'InpatientOrOutpatient' AND @SortOrder = 'asc' THEN InpatientOrOutpatient END ASC,
				CASE WHEN @sortColumn = 'InpatientOrOutpatient' AND @SortOrder = 'asc' THEN InpatientOrOutpatient END ASC,

				CASE WHEN @sortColumn = 'NotifiedBy' AND @SortOrder = 'desc' THEN NotifiedBy END DESC,
				CASE WHEN @sortColumn = 'NotifiedBy' AND @SortOrder = 'asc' THEN NotifiedBy END ASC
			
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				HumanCaseID,
				HumanID,
				ReportID,
				DateEntered,
				PersonName,
				DiseaseName,
				NotifyingOrganizationName,
				InpatientOrOutpatient,
				NotifiedBy						
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
			NotifyingOrganizationName,
			InpatientOrOutpatient,
			NotifiedBy						
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
