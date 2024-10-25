
-- ================================================================================================
-- Name: USP_VET_PENSIDE_TEST_GETList
--
-- Description:	Get penside test list for the avian and livestock veterinary disease enter and edit 
-- use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     04/18/2019 Updated for API.
-- Ann Xiong		12/17/2019 Added Species to select list.
-- Stephen Long     12/29/2020 Optimized query; removed unneeded fields and joins.
-- Stephen Long     11/24/2021 Added pagination and sorting.
-- Stephen Long     01/24/2022 Added original test result type for SAUC55/56 to determine which 
--                             notification to log when result is new verses amended.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_PENSIDE_TEST_GETList] (
	@LanguageID NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'TestNameTypeName'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@DiseaseReportID BIGINT = NULL
	,@SampleID BIGINT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize
			,@LastRec INT = (@PageNumber * @PageSize + 1)
			,@TotalRowCount INT = (
				SELECT COUNT(*)
				FROM dbo.tlbPensideTest pt
				INNER JOIN dbo.tlbMaterial m ON m.idfMaterial = pt.idfMaterial
					AND m.intRowStatus = 0
				LEFT JOIN dbo.tlbVetCase vc ON vc.idfVetCase = m.idfVetCase
					AND vc.intRowStatus = 0
				WHERE pt.intRowStatus = 0
					AND (
						vc.idfVetCase = @DiseaseReportID
						OR @DiseaseReportID IS NULL
						)
					AND (
						pt.idfMaterial = @SampleID
						OR @SampleID IS NULL
						)
				);

		SELECT PensideTestID
			,SampleID
			,EIDSSLocalOrFieldSampleID
			,SampleTypeName
			,SpeciesID
			,SpeciesTypeName
			,AnimalID
			,EIDSSAnimalID
			,PensideTestResultTypeID
			,OriginalPensideTestResultTypeID 
			,PensideTestResultTypeName
			,PensideTestNameTypeID
			,PensideTestNameTypeName
			,RowStatus
			,TestedByPersonID
			,TestedByPersonName
			,TestedByOrganizationID
			,DiseaseID
			,DiseaseIDC10Code
			,TestDate
			,PensideTestCategoryTypeID
			,PensideTestCategoryTypeName
			,Species
			,RowAction
			,[RowCount]
			,TotalRowCount
			,CurrentPage
			,TotalPages
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @SortColumn = 'TestNameTypeName'
								AND @SortOrder = 'ASC'
								THEN testNameType.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'TestNameTypeName'
								AND @SortOrder = 'DESC'
								THEN testNameType.name
							END DESC
						,CASE 
							WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
								AND @SortOrder = 'ASC'
								THEN m.strFieldBarCode
							END ASC
						,CASE 
							WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
								AND @SortOrder = 'DESC'
								THEN m.strFieldBarCode
							END DESC
						,CASE 
							WHEN @SortColumn = 'SampleTypeName'
								AND @SortOrder = 'ASC'
								THEN sampleType.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'SampleTypeName'
								AND @SortOrder = 'DESC'
								THEN sampleType.name
							END DESC
						,CASE 
							WHEN @SortColumn = 'EIDSSAnimalID'
								AND @SortOrder = 'ASC'
								THEN a.strAnimalCode
							END ASC
						,CASE 
							WHEN @SortColumn = 'EIDSSAnimalID'
								AND @SortOrder = 'DESC'
								THEN a.strAnimalCode
							END DESC
						,CASE 
							WHEN @SortColumn = 'TestResultTypeName'
								AND @SortOrder = 'ASC'
								THEN testResultType.name
							END ASC
						,CASE 
							WHEN @SortColumn = 'TestResultTypeName'
								AND @SortOrder = 'DESC'
								THEN testResultType.name
							END DESC
					) AS RowNum
				,pt.idfPensideTest AS PensideTestID
				,pt.idfMaterial AS SampleID
				,m.strFieldBarCode AS EIDSSLocalOrFieldSampleID
				,sampleType.name AS SampleTypeName
				,s.idfSpecies AS SpeciesID
				,speciesType.name AS SpeciesTypeName
				,a.idfAnimal AS AnimalID
				,a.strAnimalCode AS EIDSSAnimalID
				,pt.idfsPensideTestResult AS PensideTestResultTypeID
				,pt.idfsPensideTestResult AS OriginalPensideTestResultTypeID 
				,testResultType.name AS PensideTestResultTypeName
				,pt.idfsPensideTestName AS PensideTestNameTypeID
				,testNameType.name AS PensideTestNameTypeName
				,pt.intRowStatus AS RowStatus
				,pt.idfTestedByPerson AS TestedByPersonID
				,ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'') + ISNULL(' ' + p.strSecondName, N'') AS TestedByPersonName
				,pt.idfTestedByOffice AS TestedByOrganizationID
				,pt.idfsDiagnosis AS DiseaseID
				,d.strIDC10 AS DiseaseIDC10Code
				,pt.datTestDate AS TestDate
				,pt.idfsPensideTestCategory AS PensideTestCategoryTypeID
				,testCategoryType.name AS PensideTestCategoryTypeName
				,(
					CASE 
						WHEN vc.idfsCaseType = '10012003'
							THEN 'Herd ' + h.strHerdCode + ' - ' + speciesType.name
						ELSE 'Flock ' + h.strHerdCode + ' - ' + speciesType.name
						END
					) AS Species
				,0 AS RowAction
				,COUNT(*) OVER () AS [RowCount]
				,@TotalRowCount AS TotalRowCount
				,CurrentPage = @PageNumber
				,TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
			FROM dbo.tlbPensideTest pt
			INNER JOIN dbo.tlbMaterial m ON m.idfMaterial = pt.idfMaterial
				AND m.intRowStatus = 0
			LEFT JOIN dbo.tlbSpecies s ON s.idfSpecies = m.idfSpecies
				AND s.intRowStatus = 0
			LEFT JOIN FN_GBL_Repair(@LanguageID, 19000086) speciesType ON speciesType.idfsReference = s.idfsSpeciesType
			LEFT JOIN dbo.tlbAnimal a ON a.idfAnimal = m.idfAnimal
				AND a.intRowStatus = 0
			LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType ON sampleType.idfsReference = m.idfsSampleType
			LEFT JOIN dbo.tlbVetCase vc ON vc.idfVetCase = m.idfVetCase
				AND vc.intRowStatus = 0
			LEFT JOIN dbo.tlbPerson p ON p.idfPerson = pt.idfTestedByPerson
				AND p.intRowStatus = 0
			LEFT JOIN FN_GBL_Repair(@LanguageID, 19000105) testResultType ON testResultType.idfsReference = pt.idfsPensideTestResult
			LEFT JOIN FN_GBL_Repair(@LanguageID, 19000104) testNameType ON testNameType.idfsReference = pt.idfsPensideTestName
			LEFT JOIN FN_GBL_Repair(@LanguageID, 19000134) testCategoryType ON testCategoryType.idfsReference = pt.idfsPensideTestCategory
			LEFT JOIN dbo.trtDiagnosis d ON d.idfsDiagnosis = pt.idfsDiagnosis
				AND d.intRowStatus = 0
			LEFT JOIN dbo.tlbHerd h ON h.idfHerd = s.idfHerd
				AND h.intRowStatus = 0
			WHERE pt.intRowStatus = 0
				AND (
					vc.idfVetCase = @DiseaseReportID
					OR @DiseaseReportID IS NULL
					)
				AND (
					pt.idfMaterial = @SampleID
					OR @SampleID IS NULL
					)
					GROUP BY 
					pt.idfPensideTest
				,pt.idfMaterial
				,m.strFieldBarCode
				,sampleType.name
				,s.idfSpecies
				,speciesType.name
				,a.idfAnimal
				,a.strAnimalCode
				,pt.idfsPensideTestResult
				,testResultType.name
				,pt.idfsPensideTestName
				,testNameType.name
				,pt.intRowStatus
				,pt.idfTestedByPerson
				,p.strFamilyName
				,p.strFirstName
				,p.strSecondName
				,pt.idfTestedByOffice
				,pt.idfsDiagnosis
				,d.strIDC10
				,pt.datTestDate
				,pt.idfsPensideTestCategory
				,testCategoryType.name
				,h.strHerdCode
				,vc.idfsCaseType
			) AS x
		WHERE RowNum > @FirstRec
			AND RowNum < @LastRec
		ORDER BY RowNum;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
