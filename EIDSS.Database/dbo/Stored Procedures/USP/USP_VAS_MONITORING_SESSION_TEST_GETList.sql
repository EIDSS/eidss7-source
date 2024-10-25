-- ================================================================================================
-- Name: USP_VAS_MONITORING_SESSION_TEST_GETList
--
-- Description:	Gets laboratory field test records for the surveillance session use cases.
--                      
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Mike Kornegay            01/18/2022 Initial release (copied from USP_VET_TEST_GETList).
-- Stephen Long             07/12/2022 Added original test result type id.
-- Mike Kornegay			08/25/2022 Added FarmMasterID for linked disease reports.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VAS_MONITORING_SESSION_TEST_GETList] (
	@LanguageID NVARCHAR(50)
	,@PageNumber INT = 1
	,@PageSize INT = 10
	,@SortColumn NVARCHAR(30) = 'TestNameTypeName'
	,@SortOrder NVARCHAR(4) = 'ASC'
	,@MonitoringSessionID BIGINT
	)
AS
BEGIN
	DECLARE @firstRec INT
		,@lastRec INT;

	SET @firstRec = (@PageNumber - 1) * @PageSize;
	SET @lastRec = (@PageNumber * @PageSize + 1);

	SET NOCOUNT ON;

	BEGIN TRY
			SELECT TestID
			,TestNameTypeID
			,TestNameTypeName
			,TestCategoryTypeID
			,TestCategoryTypeName
			,TestResultTypeID
			,OriginalTestResultTypeID
			,TestResultTypeName
			,TestStatusTypeID
			,TestStatusTypeName
			,DiseaseID
			,DiseaseName
			,SampleID
			,EIDSSLocalOrFieldSampleID
			,EIDSSLaboratorySampleID
			,SampleTypeName
			,SpeciesID
			,SpeciesTypeName
			,AnimalID
			,EIDSSAnimalID
			,BatchTestID
			,ObservationID
			,TestNumber
			,Comments
			,StartedDate
			,ResultDate
			,TestedByOrganizationID
			,TestedByPersonID
			,TestedByPersonName
			,ResultEnteredByOrganizationID
			,ResultEnteredByPersonID
			,ResultEnteredByPersonName
			,ValidatedByOrganizationID
			,ValidatedByPersonID
			,ValidatedByPersonName
			,ReadOnlyIndicator
			,NonLaboratoryTestIndicator
			,ExternalTestIndicator
			,PerformedByOrganizationID
			,ReceivedDate
			,ContactPersonName
			,FarmID
			,FarmMasterID
			,EIDSSFarmID
			,RowStatus
			,Species
			,IsTestResultIndicative
			,MonitoringSessionID
			,HumanDiseaseReportID
			,VeterinaryDiseaseReportID
			,VectorID
			,RowAction
			,TotalRowCount
			,CurrentPage
			,TotalPages
			FROM ( 
				 SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
								AND @SortOrder = 'ASC'
								THEN m.strFieldBarcode
							END ASC
						,CASE 
							WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
								AND @SortOrder = 'DESC'
								THEN m.strFieldBarcode
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
							WHEN @SortColumn = 'DiseaseName'
								AND @SortOrder = 'ASC'
								THEN diagnosis.Name
							END ASC
						,CASE 
							WHEN @SortColumn = 'DiseaseName'
								AND @SortOrder = 'DESC'
								THEN diagnosis.Name
							END DESC
						,CASE 
							WHEN @SortColumn = 'TestNameTypeName'
								AND @SortOrder = 'ASC'
								THEN testNameType.Name
							END ASC
						,CASE 
							WHEN @SortColumn = 'TestNameTypeName'
								AND @SortOrder = 'DESC'
								THEN testNameType.Name
							END DESC
						,CASE 
							WHEN @SortColumn = 'Comments'
								AND @SortOrder = 'ASC'
								THEN t.strNote
							END ASC
						,CASE 
							WHEN @SortColumn = 'Comments'
								AND @SortOrder = 'DESC'
								THEN t.strNote
							END DESC
					) AS RowNum
			,t.idfTesting AS TestID
			,t.idfsTestName AS TestNameTypeID
			,testNameType.name AS TestNameTypeName
			,t.idfsTestCategory AS TestCategoryTypeID
			,testCategoryType.name AS TestCategoryTypeName
			,t.idfsTestResult AS TestResultTypeID
			,t.idfsTestResult AS OriginalTestResultTypeID 
			,testResultType.name AS TestResultTypeName
			,t.idfsTestStatus AS TestStatusTypeID
			,testStatusType.name AS TestStatusTypeName
			,t.idfsDiagnosis AS DiseaseID
			,diagnosis.Name AS DiseaseName
			,t.idfMaterial AS SampleID
			,m.strFieldBarCode AS EIDSSLocalOrFieldSampleID
			,CASE 
				WHEN t.blnNonLaboratoryTest = 1
					THEN ''
				ELSE m.strBarCode
				END AS EIDSSLaboratorySampleID
			,sampleType.name AS SampleTypeName
			,s.idfSpecies AS SpeciesID
			,speciesType.name AS SpeciesTypeName
			,a.idfAnimal AS AnimalID
			,a.strAnimalCode AS EIDSSAnimalID
			,t.idfBatchTest AS BatchTestID
			,t.idfObservation AS ObservationID
			,t.intTestNumber AS TestNumber
			,t.strNote AS Comments
			,t.datStartedDate AS StartedDate
			,t.datConcludedDate AS ResultDate
			,t.idfTestedByOffice AS TestedByOrganizationID
			,t.idfTestedByPerson AS TestedByPersonID
			,ISNULL(testedByPerson.strFamilyName, N'') + ISNULL(' ' + testedByPerson.strFirstName, '') + ISNULL(' ' + testedByPerson.strSecondName, '') AS TestedByPersonName
			,t.idfResultEnteredByOffice AS ResultEnteredByOrganizationID
			,t.idfResultEnteredByPerson AS ResultEnteredByPersonID
			,ISNULL(resultEnteredByPerson.strFamilyName, N'') + ISNULL(' ' + resultEnteredByPerson.strFirstName, '') + ISNULL(' ' + resultEnteredByPerson.strSecondName, '') AS ResultEnteredByPersonName
			,t.idfValidatedByOffice AS ValidatedByOrganizationID
			,t.idfValidatedByPerson AS ValidatedByPersonID
			,ISNULL(validatedByPerson.strFamilyName, N'') + ISNULL(' ' + validatedByPerson.strFirstName, '') + ISNULL(' ' + validatedByPerson.strSecondName, '') AS ValidatedByPersonName
			,t.blnReadOnly AS ReadOnlyIndicator
			,t.blnNonLaboratoryTest AS NonLaboratoryTestIndicator
			,t.blnExternalTest AS ExternalTestIndicator
			,t.idfPerformedByOffice AS PerformedByOrganizationID
			,t.datReceivedDate AS ReceivedDate
			,t.strContactPerson AS ContactPersonName
			,f.idfFarm AS FarmID
			,f.idfFarmActual AS FarmMasterID
			,f.strFarmCode AS EIDSSFarmID
			,t.intRowStatus AS RowStatus
			,(
				CASE 
					WHEN speciesType.idfsReference = 49558320000000
						THEN 'Herd ' + h.strHerdCode + ' - ' + speciesType.name
					ELSE 'Flock ' + h.strHerdCode + ' - ' + speciesType.name
					END
				) AS Species
			,ttr.blnIndicative AS IsTestResultIndicative
			,t.idfMonitoringSession AS MonitoringSessionID
			,t.idfHumanCase AS HumanDiseaseReportID
			,t.idfVetCase AS VeterinaryDiseaseReportID
			,t.idfVector AS VectorID
			,0 AS RowAction
			,COUNT(*) OVER () AS TotalRowCount
			,CurrentPage = @PageNumber
			,TotalPages = (COUNT(*) OVER () / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
		FROM dbo.tlbTesting t
		INNER JOIN dbo.tlbMaterial m ON m.idfMaterial = t.idfMaterial
			AND m.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType ON sampleType.idfsReference = m.idfsSampleType
		INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000001) testStatusType ON testStatusType.idfsReference = t.idfsTestStatus
		INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) diagnosis ON diagnosis.idfsReference = t.idfsDiagnosis
		LEFT JOIN dbo.tlbSpecies s ON s.idfSpecies = m.idfSpecies
			AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbHerd h ON h.idfHerd = s.idfHerd
			AND h.intRowStatus = 0
		LEFT JOIN dbo.tlbFarm f ON f.idfFarm = h.idfFarm
			AND f.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType ON speciesType.idfsReference = s.idfsSpeciesType
		LEFT JOIN dbo.tlbAnimal a ON a.idfAnimal = m.idfAnimal
			AND a.intRowStatus = 0
		LEFT JOIN dbo.tlbPerson testedByPerson ON testedByPerson.idfPerson = t.idfTestedByPerson
			AND testedByPerson.intRowStatus = 0
		LEFT JOIN dbo.tlbPerson resultEnteredByPerson ON resultEnteredByPerson.idfPerson = t.idfResultEnteredByPerson
			AND resultEnteredByPerson.intRowStatus = 0
		LEFT JOIN dbo.tlbPerson validatedByPerson ON validatedByPerson.idfPerson = t.idfValidatedByPerson
			AND validatedByPerson.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000097) testNameType ON testNameType.idfsReference = t.idfsTestName
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000095) testCategoryType ON testCategoryType.idfsReference = t.idfsTestCategory
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) testResultType ON testResultType.idfsReference = t.idfsTestResult
		LEFT JOIN dbo.trtTestTypeToTestResult ttr ON ttr.idfsTestName = t.idfsTestName
			AND ttr.idfsTestResult = t.idfsTestResult
			AND ttr.intRowStatus = 0
		WHERE t.intRowStatus = 0
			AND t.idfMonitoringSession = @MonitoringSessionID
		GROUP BY t.idfTesting
			,t.idfsTestName
			,testNameType.name
			,t.idfsTestCategory
			,testCategoryType.name
			,t.idfsTestResult
			,testResultType.name
			,t.idfsTestStatus
			,testStatusType.name
			,t.idfsDiagnosis
			,diagnosis.Name
			,t.idfMaterial
			,m.strFieldBarCode
			,m.strBarCode
			,sampleType.name
			,s.idfSpecies
			,speciesType.name
			,a.idfAnimal
			,a.strAnimalCode
			,t.idfBatchTest
			,t.idfObservation
			,t.intTestNumber
			,t.strNote
			,t.datStartedDate 
			,t.datConcludedDate
			,t.idfTestedByOffice
			,t.idfTestedByPerson
			,testedByPerson.strFamilyName
			,testedByPerson.strFirstName
			,testedByPerson.strSecondName
			,t.idfResultEnteredByOffice
			,t.idfResultEnteredByPerson
			,resultEnteredByPerson.strFamilyName
			,resultEnteredByPerson.strFirstName
			,resultEnteredByPerson.strSecondName
			,t.idfValidatedByOffice
			,t.idfValidatedByPerson
			,validatedByPerson.strFamilyName
			,validatedByPerson.strFirstName
			,validatedByPerson.strSecondName
			,t.blnReadOnly
			,t.blnNonLaboratoryTest
			,t.blnExternalTest
			,t.idfPerformedByOffice
			,t.datReceivedDate
			,t.strContactPerson
			,f.idfFarm
			,f.idfFarmActual
			,f.strFarmCode
			,t.intRowStatus
			,speciesType.idfsReference
			,h.strHerdCode
			,speciesType.name
			,ttr.blnIndicative
			,t.idfMonitoringSession
			,t.idfHumanCase
			,t.idfVetCase
			,t.idfVector) as x
		WHERE RowNum > @firstRec
			AND RowNum < @lastRec
		ORDER BY RowNum;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
