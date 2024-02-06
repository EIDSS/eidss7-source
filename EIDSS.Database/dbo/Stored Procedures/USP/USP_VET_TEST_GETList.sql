-- ================================================================================================
-- Name: USP_VET_TEST_GETList
--
-- Description:	Gets laboratory field test records for the disease report use cases.
--                      
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Stephen Long             11/30/2021 Initial release.
-- Stephen Long             01/12/2022 Added order by cases and updated pagination logic.
-- Stephen Long             01/24/2022 Added original test result type for SAUC55/56 to determine 
--                                     which notification to log when result is new verses amended.
-- Mike Kornegay			02/02/2022 Added sent date from material table
-- Stephen Long             02/02/2022 Added root sample ID to the query.
-- Stephen Long             01/04/2023 Added check for deleted test status.
-- Stephen Long             03/15/2023 Changed inner joins on material table to left as veterinary 
--                                     disease report does not require a sample selection.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_TEST_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'TestNameTypeName',
    @SortOrder NVARCHAR(4) = 'ASC',
    @DiseaseReportID BIGINT
)
AS
BEGIN
    DECLARE @firstRec INT = (@PageNumber - 1) * @PageSize,
            @lastRec INT = (@PageNumber * @PageSize + 1);

    DECLARE @Results TABLE (ID BIGINT);

    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO @Results
        SELECT t.idfTesting
        FROM dbo.tlbTesting t
        WHERE t.intRowStatus = 0
              AND t.idfVetCase = @DiseaseReportID
              AND t.idfMaterial IS NULL
              AND t.idfsTestStatus <> 10001007; -- Deleted

        INSERT INTO @Results
        SELECT t.idfTesting
        FROM dbo.tlbTesting t
            INNER JOIN dbo.tlbMaterial m
                ON m.idfMaterial = t.idfMaterial
                   AND t.idfMaterial IS NOT NULL
                   AND m.intRowStatus = 0
        WHERE t.intRowStatus = 0
              AND m.idfVetCase = @DiseaseReportID
              AND t.idfsTestStatus <> 10001007 -- Deleted;

        SELECT TestID,
               TestNameTypeID,
               TestNameTypeName,
               TestCategoryTypeID,
               TestCategoryTypeName,
               TestResultTypeID,
               OriginalTestResultTypeID,
               TestResultTypeName,
               TestStatusTypeID,
               TestStatusTypeName,
               DiseaseID,
               DiseaseName,
               SampleID,
               RootSampleID,
               EIDSSLocalOrFieldSampleID,
               EIDSSLaboratorySampleID,
               SampleTypeName,
               SpeciesID,
               SpeciesTypeName,
               AnimalID,
               EIDSSAnimalID,
               BatchTestID,
               ObservationID,
               TestNumber,
               Comments,
               StartedDate,
               ResultDate,
               SentDate,
               TestedByOrganizationID,
               TestedByPersonID,
               TestedByPersonName,
               ResultEnteredByOrganizationID,
               ResultEnteredByPersonID,
               ResultEnteredByPersonName,
               ValidatedByOrganizationID,
               ValidatedByPersonID,
               ValidatedByPersonName,
               ReadOnlyIndicator,
               NonLaboratoryTestIndicator,
               ExternalTestIndicator,
               PerformedByOrganizationID,
               ReceivedDate,
               ContactPersonName,
               FarmID,
               EIDSSFarmID,
               RowStatus,
               Species,
               IsTestResultIndicative,
               MonitoringSessionID,
               HumanDiseaseReportID,
               VeterinaryDiseaseReportID,
               VectorID,
               RowAction,
               TotalRowCount,
               CurrentPage,
               TotalPages
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       m.strFieldBarcode
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       m.strFieldBarcode
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSAnimalID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       a.strAnimalCode
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSAnimalID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       a.strAnimalCode
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       diagnosis.Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       diagnosis.Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'TestNameTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       testNameType.Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'TestNameTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       testNameType.Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Comments'
                                                        AND @SortOrder = 'ASC' THEN
                                                       t.strNote
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Comments'
                                                        AND @SortOrder = 'DESC' THEN
                                                       t.strNote
                                               END DESC
                                     ) AS RowNum,
                   t.idfTesting AS TestID,
                   t.idfsTestName AS TestNameTypeID,
                   testNameType.name AS TestNameTypeName,
                   t.idfsTestCategory AS TestCategoryTypeID,
                   testCategoryType.name AS TestCategoryTypeName,
                   t.idfsTestResult AS TestResultTypeID,
                   t.idfsTestResult AS OriginalTestResultTypeID,
                   testResultType.name AS TestResultTypeName,
                   t.idfsTestStatus AS TestStatusTypeID,
                   testStatusType.name AS TestStatusTypeName,
                   t.idfsDiagnosis AS DiseaseID,
                   diagnosis.Name AS DiseaseName,
                   t.idfMaterial AS SampleID,
                   m.idfRootMaterial AS RootSampleID,
                   m.strFieldBarCode AS EIDSSLocalOrFieldSampleID,
                   CASE
                       WHEN t.blnNonLaboratoryTest = 1 THEN
                           ''
                       ELSE
                           m.strBarCode
                   END AS EIDSSLaboratorySampleID,
                   sampleType.name AS SampleTypeName,
                   s.idfSpecies AS SpeciesID,
                   speciesType.name AS SpeciesTypeName,
                   a.idfAnimal AS AnimalID,
                   a.strAnimalCode AS EIDSSAnimalID,
                   t.idfBatchTest AS BatchTestID,
                   t.idfObservation AS ObservationID,
                   t.intTestNumber AS TestNumber,
                   t.strNote AS Comments,
                   t.datStartedDate AS StartedDate,
                   t.datConcludedDate AS ResultDate,
                   m.datFieldSentDate AS SentDate,
                   t.idfTestedByOffice AS TestedByOrganizationID,
                   t.idfTestedByPerson AS TestedByPersonID,
                   ISNULL(testedByPerson.strFamilyName, N'') + ISNULL(' ' + testedByPerson.strFirstName, '')
                   + ISNULL(' ' + testedByPerson.strSecondName, '') AS TestedByPersonName,
                   t.idfResultEnteredByOffice AS ResultEnteredByOrganizationID,
                   t.idfResultEnteredByPerson AS ResultEnteredByPersonID,
                   ISNULL(resultEnteredByPerson.strFamilyName, N'')
                   + ISNULL(' ' + resultEnteredByPerson.strFirstName, '')
                   + ISNULL(' ' + resultEnteredByPerson.strSecondName, '') AS ResultEnteredByPersonName,
                   t.idfValidatedByOffice AS ValidatedByOrganizationID,
                   t.idfValidatedByPerson AS ValidatedByPersonID,
                   ISNULL(validatedByPerson.strFamilyName, N'') + ISNULL(' ' + validatedByPerson.strFirstName, '')
                   + ISNULL(' ' + validatedByPerson.strSecondName, '') AS ValidatedByPersonName,
                   t.blnReadOnly AS ReadOnlyIndicator,
                   t.blnNonLaboratoryTest AS NonLaboratoryTestIndicator,
                   t.blnExternalTest AS ExternalTestIndicator,
                   t.idfPerformedByOffice AS PerformedByOrganizationID,
                   t.datReceivedDate AS ReceivedDate,
                   t.strContactPerson AS ContactPersonName,
                   f.idfFarm AS FarmID,
                   f.strFarmCode AS EIDSSFarmID,
                   t.intRowStatus AS RowStatus,
                   (CASE
                        WHEN vc.idfsCaseType = 10012003 THEN
                            'Herd ' + h.strHerdCode + ' - ' + speciesType.name
                        ELSE
                            'Flock ' + h.strHerdCode + ' - ' + speciesType.name
                    END
                   ) AS Species,
                   ttr.blnIndicative AS IsTestResultIndicative,
                   t.idfMonitoringSession AS MonitoringSessionID,
                   t.idfHumanCase AS HumanDiseaseReportID,
                   t.idfVetCase AS VeterinaryDiseaseReportID,
                   t.idfVector AS VectorID,
                   0 AS RowAction,
                   COUNT(*) OVER () AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (COUNT(*) OVER () / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM @Results res
                INNER JOIN dbo.tlbTesting t
                    ON t.idfTesting = res.ID
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = t.idfMaterial
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
                LEFT JOIN dbo.tlbVetCase vc
                    ON vc.idfVetCase = m.idfVetCase
                       AND vc.intRowStatus = 0
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000001) testStatusType
                    ON testStatusType.idfsReference = t.idfsTestStatus
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) diagnosis
                    ON diagnosis.idfsReference = t.idfsDiagnosis
                LEFT JOIN dbo.tlbSpecies s
                    ON s.idfSpecies = m.idfSpecies
                       AND s.intRowStatus = 0
                LEFT JOIN dbo.tlbHerd h
                    ON h.idfHerd = s.idfHerd
                       AND h.intRowStatus = 0
                LEFT JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                    ON speciesType.idfsReference = s.idfsSpeciesType
                LEFT JOIN dbo.tlbAnimal a
                    ON a.idfAnimal = m.idfAnimal
                       AND a.intRowStatus = 0
                LEFT JOIN dbo.tlbPerson testedByPerson
                    ON testedByPerson.idfPerson = t.idfTestedByPerson
                       AND testedByPerson.intRowStatus = 0
                LEFT JOIN dbo.tlbPerson resultEnteredByPerson
                    ON resultEnteredByPerson.idfPerson = t.idfResultEnteredByPerson
                       AND resultEnteredByPerson.intRowStatus = 0
                LEFT JOIN dbo.tlbPerson validatedByPerson
                    ON validatedByPerson.idfPerson = t.idfValidatedByPerson
                       AND validatedByPerson.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000097) testNameType
                    ON testNameType.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000095) testCategoryType
                    ON testCategoryType.idfsReference = t.idfsTestCategory
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) testResultType
                    ON testResultType.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.trtTestTypeToTestResult ttr
                    ON ttr.idfsTestName = t.idfsTestName
                       AND ttr.idfsTestResult = t.idfsTestResult
                       AND ttr.intRowStatus = 0
            GROUP BY t.idfTesting,
                     t.idfsTestName,
                     testNameType.name,
                     t.idfsTestCategory,
                     testCategoryType.name,
                     t.idfsTestResult,
                     testResultType.name,
                     t.idfsTestStatus,
                     testStatusType.name,
                     t.idfsDiagnosis,
                     diagnosis.Name,
                     t.idfMaterial,
                     m.idfRootMaterial,
                     m.strFieldBarCode,
                     m.strBarCode,
                     sampleType.name,
                     s.idfSpecies,
                     speciesType.name,
                     a.idfAnimal,
                     a.strAnimalCode,
                     t.idfBatchTest,
                     t.idfObservation,
                     t.intTestNumber,
                     t.strNote,
                     t.datStartedDate,
                     t.datConcludedDate,
                     m.datFieldSentDate,
                     t.idfTestedByOffice,
                     t.idfTestedByPerson,
                     testedByPerson.strFamilyName,
                     testedByPerson.strFirstName,
                     testedByPerson.strSecondName,
                     t.idfResultEnteredByOffice,
                     t.idfResultEnteredByPerson,
                     resultEnteredByPerson.strFamilyName,
                     resultEnteredByPerson.strFirstName,
                     resultEnteredByPerson.strSecondName,
                     t.idfValidatedByOffice,
                     t.idfValidatedByPerson,
                     validatedByPerson.strFamilyName,
                     validatedByPerson.strFirstName,
                     validatedByPerson.strSecondName,
                     t.blnReadOnly,
                     t.blnNonLaboratoryTest,
                     t.blnExternalTest,
                     t.idfPerformedByOffice,
                     t.datReceivedDate,
                     t.strContactPerson,
                     f.idfFarm,
                     f.strFarmCode,
                     t.intRowStatus,
                     vc.idfsCaseType,
                     h.strHerdCode,
                     speciesType.name,
                     ttr.blnIndicative,
                     t.idfMonitoringSession,
                     t.idfHumanCase,
                     t.idfVetCase,
                     t.idfVector
        ) AS x
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
