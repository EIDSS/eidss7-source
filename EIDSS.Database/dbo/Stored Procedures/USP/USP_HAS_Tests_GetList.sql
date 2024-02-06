--=====================================================================================================
-- Name: USP_HAS_Tests_GetList
-- Author:		Doug Albanese
-- Description:	Returns a list of "Tests"
--
--							
-- Revision History:
--	Name             Date		Change Detail
--	---------------- ----------	-----------------------------------------------
--	Doug Albanese	12/20/2021	Initial Release
--	Doug Albanese	12/21/2021	Refactored for filtering and paging
--	Doug Albanese	01/25/2022	Added missing first and last record number for page
--	Doug Albanese	01/29/2022	Added idfTesting as "ID" for detail return
--	Doug Albanese	01/29/2022	Added other missing fields that are used to support the displaying of the details
--	Doug Albanese	02/02/2022	Added idfMaterial as SampleID on return
--	Doug Albanese	02/03/2022	Fixed the person id return problem.
--	Doug Albanese	06/06/2022	Added HumanMasterId for use with "Linked" disease reports
--	Doug Albanese	06/15/2022	Changed TESTCATEGORY from inner to left join
--	Doug Albanese	06/16/2022	Added intRowStatus check
--	Stephen Long    07/12/2022  Added original test result type ID for site alerts.
--	Doug Albanese	07/18/2022	Added idfHumanCase so that the connected link can be disabled
--  Doug Albanese	 10/17/2022	 Added "Indicative" to provide information on logic to remove "Connected" link for HDRs
-- Doug Albanese	 10/17/2022	 Performance improvement
--	Test Code:
--	EXEC USP_HAS_Tests_GetList @LanguageId='en', @idfMonitoringSession = 404
-- 
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_Tests_GetList]
(
	@LanguageId				NVARCHAR(50),
	@idfMonitoringSession	BIGINT,
	@advancedSearch			NVARCHAR(100) = NULL,
	@pageNo					INT = 1,
	@pageSize				INT = 10 ,
	@sortColumn				NVARCHAR(30) = 'ResultDate',
	@sortOrder				NVARCHAR(4) = 'DESC'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		DECLARE @Results TABLE (
			ID					BIGINT,
			LabSampleID			NVARCHAR(200),
			FieldSampleID		NVARCHAR(200),
			SampleType			NVARCHAR(200),
			SampleTypeID		BIGINT,
			SampleID			BIGINT,
			PersonID			BIGINT,
			HumanMasterID		BIGINT,
			EIDSSPersonID		NVARCHAR(200),
			TestName			NVARCHAR(200),
			TestNameID			BIGINT,
			Diagnosis			NVARCHAR(200),
			DiseaseID			BIGINT,
			TestCategory		NVARCHAR(200),
			TestCategoryID		BIGINT,
			TestResult			NVARCHAR(200),
			TestResultID		BIGINT,
			OriginalTestResultTypeID BIGINT, 
			TestStatus			NVARCHAR(200),
			TestStatusID		BIGINT,
			ResultDate			DATETIME,
			HumanCaseID			BIGINT,
			Indicative			BIT
		)

		INSERT INTO @Results
		SELECT
			T.idfTesting				AS ID,
			M.strBarcode				AS LabSampleID,
			M.strFieldBarcode			AS FieldSampleID,
			S.name						AS SampleType,
			S.idfsReference				AS SampleTypeID,
			M.idfMaterial				AS SampleID,
			M.idfHuman					AS PersonID,
			HA.idfHumanActual			AS HumanMasterID,
			HAI.EIDSSPersonID			AS EIDSSPersonID,
			TESTNAME.name				AS TestName,
			T.idfsTestName				AS TestNameID,
			DISEASE.name				AS Diagnosis,
			DISEASE.idfsReference		AS DiseaseID,
			TESTCATEGORY.name			AS TestCategory,
			TESTCATEGORY.idfsReference	AS TestCategoryID,
			TESTRESULT.name				AS TestResult,
			TESTRESULT.idfsReference	AS TestResultID,
			t.idfsTestResult            AS OriginalTestResultTypeID, 
			TESTSTATUS.name				AS TestStatus,
			TESTSTATUS.idfsReference	AS TestStatusID,
			T.datConcludedDate			AS ResultDate,
			T.idfHumanCase				AS HumanCaseID,
			TTR.blnIndicative		    AS Indicative
		FROM
			dbo.tlbTesting T
		INNER JOIN dbo.tlbMaterial M
			ON M.idfMaterial = T.idfMaterial
		INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageId, 19000087) S
			ON S.idfsReference = M.idfsSampleType
		INNER JOIN dbo.tlbHuman H
			ON H.idfHuman = M.idfHuman
		INNER JOIN dbo.tlbHumanActual HA
			ON HA.idfHumanActual = H.idfHumanActual
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000097) TESTNAME
			ON TESTNAME.idfsReference = T.idfsTestName
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000095) TESTCATEGORY
			ON TESTCATEGORY.idfsReference = T.idfsTestCategory
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000096) TESTRESULT
			ON TESTRESULT.idfsReference = T.idfsTestResult
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000001) TESTSTATUS
			ON TESTSTATUS.idfsReference = T.idfsTestStatus
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000019) DISEASE
			ON DISEASE.idfsReference = t.idfsDiagnosis
		INNER JOIN dbo.HumanActualAddlInfo HAI
			ON HAI.HumanActualAddlInfoUID = HA.idfHumanActual
		INNER JOIN dbo.trtTestTypeToTestResult TTR
	  		ON TTR.idfsTestName = T.idfsTestName AND TTR.idfsTestResult = T.idfsTestResult
		WHERE
			M.idfMonitoringSession = @idfMonitoringSession AND
			T.intRowStatus = 0;

		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @SortColumn = 'ID' AND @SortOrder = 'ASC' THEN ID END ASC
				,CASE WHEN @SortColumn = 'ID' AND @SortOrder = 'DESC' THEN ID END DESC
				,CASE WHEN @SortColumn = 'LabSampleID' AND @SortOrder = 'ASC' THEN LabSampleID END ASC
				,CASE WHEN @SortColumn = 'LabSampleID' AND @SortOrder = 'DESC' THEN LabSampleID END DESC
				,CASE WHEN @SortColumn = 'FieldSampleID' AND @SortOrder = 'ASC' THEN FieldSampleID END ASC
				,CASE WHEN @SortColumn = 'FieldSampleID' AND @SortOrder = 'DESC' THEN FieldSampleID END DESC
				,CASE WHEN @SortColumn = 'SampleType' AND @SortOrder = 'ASC' THEN SampleType END ASC
				,CASE WHEN @SortColumn = 'SampleType' AND @SortOrder = 'DESC' THEN SampleType END DESC
				,CASE WHEN @SortColumn = 'PersonID' AND @SortOrder = 'ASC' THEN PersonID END ASC
				,CASE WHEN @SortColumn = 'PersonID' AND @SortOrder = 'DESC' THEN PersonID END DESC
				,CASE WHEN @SortColumn = 'TestName' AND @SortOrder = 'ASC' THEN TestName END ASC
				,CASE WHEN @SortColumn = 'TestName' AND @SortOrder = 'DESC' THEN TestName END DESC
				,CASE WHEN @SortColumn = 'Diagnosis' AND @SortOrder = 'ASC' THEN Diagnosis END ASC
				,CASE WHEN @SortColumn = 'Diagnosis' AND @SortOrder = 'DESC' THEN Diagnosis END DESC
				,CASE WHEN @SortColumn = 'TestCategory' AND @SortOrder = 'ASC' THEN TestCategory END ASC
				,CASE WHEN @SortColumn = 'TestCategory' AND @SortOrder = 'DESC' THEN TestCategory END DESC
				,CASE WHEN @SortColumn = 'TestResult' AND @SortOrder = 'ASC' THEN TestResult END ASC
				,CASE WHEN @SortColumn = 'TestResult' AND @SortOrder = 'DESC' THEN TestResult END DESC
				,CASE WHEN @SortColumn = 'TestStatus' AND @SortOrder = 'ASC' THEN TestStatus END ASC
				,CASE WHEN @SortColumn = 'TestStatus' AND @SortOrder = 'DESC' THEN TestStatus END DESC
				,CASE WHEN @SortColumn = 'ResultDate' AND @SortOrder = 'ASC' THEN ResultDate END ASC
				,CASE WHEN @SortColumn = 'ResultDate' AND @SortOrder = 'DESC' THEN ResultDate END DESC
				--,IIF( @sortColumn = 'intOrder',intOrder,intOrder) ASC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				ID,
				LabSampleID,
				FieldSampleID,
				SampleType,
				SampleTypeID,
				SampleID,
				PersonID,
				HumanMasterID,
				EIDSSPersonID,
				TestName,
				TestNameID,
				Diagnosis,
				DiseaseID,
				TestCategory,
				TestCategoryID,
				TestResult,
				TestResultID,
				OriginalTestResultTypeID, 
				TestStatus,
				TestStatusID,
				ResultDate,
				HumanCaseID,
			    Indicative
			FROM @Results
		)
		SELECT
				TotalRowCount, 
				ID,
				LabSampleID,
				FieldSampleID,
				SampleType,
				SampleTypeID,
				SampleID,
				PersonID,
				HumanMasterID,
				EIDSSPersonID,
				TestName,
				TestNameID,
				Diagnosis,
				DiseaseID,
				TestCategory,
				TestCategoryID,
				TestResult,
				TestResultID,
				OriginalTestResultTypeID, 
				TestStatus,
				TestStatusID,
				ResultDate,
				HumanCaseID,
			    Indicative,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec;

	END TRY
	BEGIN CATCH
		
	END CATCH
END

