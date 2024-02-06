-- ================================================================================================
-- Name: USP_GBL_TEST_INTERPRETATION_GETList
--
-- Description:	Gets test interpretation records for the veterinary disease reports and active 
-- surveillance session use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/03/2018 Initial release.
-- Stephen Long     04/18/2019 Updated for the API.
-- Stephen Long     06/26/2019 Added veterinary disease report identifiers.
-- Stephen Long     07/31/2019 Corrected sample type join.
-- Stephen Long     08/15/2019 Fix for bug 4623; interpreted and validated by names.
-- Stephen Long     09/11/2019 Fix for diagnosis reference; use test validation instead of test.
-- Stephen Long     10/11/2019 Removed active row status check on joins as historical records 
--                             would get inaccurate/missing results.
-- Ann Xiong		12/17/2019 Added Species to select list.
-- Stephen Long     04/21/2020 Added intRowStatus checks and corrected interpreted by and 
--                             validated by joins to use function.
-- Stephen Long     12/29/2020 Optimized query; removed unneeded fields and joins.
-- Stephen Long     11/30/2021 Removed test ID and added pagination and sorting parameters.
-- Stephen Long     01/12/2022 Added paging and sorting logic.
-- Mike Kornegay	01/24/2022 Added EIDSSReportID to get the string version of the linked disease report.
-- Stephen Long     01/29/2022 Added test to test result matrix and indicative indicator for 
--                             connected disease report.
-- Mike Kornegay	08/25/2022 Added FarmMasterID to get the idfFarmActual for use when creating linked disease reports.
-- Mike Kornegay	12/21/2022 Added idfsUsingType from disease to return list.
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_TEST_INTERPRETATION_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'TestNameTypeName',
    @SortOrder NVARCHAR(4) = 'ASC',
    @DiseaseReportID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL
)
AS
BEGIN
    DECLARE @firstRec INT,
            @lastRec INT;

    SET @firstRec = (@PageNumber - 1) * @PageSize;
    SET @lastRec = (@PageNumber * @PageSize + 1);

    SET NOCOUNT ON;

    BEGIN TRY
        IF @DiseaseReportID IS NOT NULL
        BEGIN
            SELECT TestInterpretationID,
                   DiseaseID,
                   DiseaseName,
				   DiseaseUsingType,
                   InterpretedStatusTypeID,
                   InterpretedStatusTypeName,
                   ValidatedByOrganizationID,
                   ValidatedByPersonID,
                   ValidatedByPersonName,
                   InterpretedByOrganizationID,
                   InterpretedByPersonID,
                   InterpretedByPersonName,
                   TestID,
                   ValidatedStatusIndicator,
                   ReportSessionCreatedIndicator,
                   ValidatedComment,
                   InterpretedComment,
                   ValidatedDate,
                   InterpretedDate,
                   ReadOnlyIndicator,
                   SampleID,
                   EIDSSLocalOrFieldSampleID,
                   EIDSSLaboratorySampleID,
                   SampleTypeName,
                   SpeciesID,
                   SpeciesTypeName,
                   Species,
                   AnimalID,
                   EIDSSAnimalID,
                   TestNameTypeID,
                   TestNameTypeName,
                   TestCategoryTypeID,
                   TestCategoryTypeName,
                   TestResultTypeID,
                   TestResultTypeName,
                   IndicativeIndicator, 
                   FarmID,
				   FarmMasterID,
                   EIDSSFarmID,
                   RowStatus,
                   DiseaseReportID,
				   EIDSSDiseaseReportID,
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
                                                   END DESC
                                         ) AS RowNum,
                       tv.idfTestValidation AS TestInterpretationID,
                       tv.idfsDiagnosis AS DiseaseID,
                       diagnosis.Name AS DiseaseName,
					   d.idfsUsingType AS DiseaseUsingType,
                       tv.idfsInterpretedStatus AS InterpretedStatusTypeID,
                       interpretedStatusType.name AS InterpretedStatusTypeName,
                       tv.idfValidatedByOffice AS ValidatedByOrganizationID,
                       tv.idfValidatedByPerson AS ValidatedByPersonID,
                       COALESCE(CONCAT(
                                          validatedByPerson.strFamilyName,
                                          CASE
                                              WHEN validatedByPerson.strFirstName IS NULL THEN
                                                  ''
                                              ELSE
                                                  ', '
                                          END,
                                          COALESCE(CONCAT(
                                                             validatedByPerson.strFirstName,
                                                             ' ',
                                                             validatedByPerson.strSecondName
                                                         ), validatedByPerson.strFirstName, validatedByPerson.strSecondName)
                                      ), validatedByPerson.strFamilyName, COALESCE(CONCAT(
                                                                                             validatedByPerson.strFirstName,
                                                                                             ' ',
                                                                                             validatedByPerson.strSecondName
                                                                                         ), validatedByPerson.strFirstName, validatedByPerson.strSecondName)) AS ValidatedByPersonName,
                       tv.idfInterpretedByOffice AS InterpretedByOrganizationID,
                       tv.idfInterpretedByPerson AS InterpretedByPersonID,
                       COALESCE(CONCAT(
                                          interpretedByPerson.strFamilyName,
                                          CASE
                                              WHEN interpretedByPerson.strFirstName IS NULL THEN
                                                  ''
                                              ELSE
                                                  ', '
                                          END,
                                          COALESCE(CONCAT(
                                                             interpretedByPerson.strFirstName,
                                                             ' ',
                                                             interpretedByPerson.strSecondName
                                                         ), interpretedByPerson.strFirstName, interpretedByPerson.strSecondName)
                                      ), interpretedByPerson.strFamilyName, COALESCE(CONCAT(
                                                                                               interpretedByPerson.strFirstName,
                                                                                               ' ',
                                                                                               interpretedByPerson.strSecondName
                                                                                           ), interpretedByPerson.strFirstName, interpretedByPerson.strSecondName)) AS InterpretedByPersonName,
                       tv.idfTesting AS TestID,
                       tv.blnValidateStatus AS ValidatedStatusIndicator,
                       tv.blnCaseCreated AS ReportSessionCreatedIndicator,
                       tv.strValidateComment AS ValidatedComment,
                       tv.strInterpretedComment AS InterpretedComment,
                       tv.datValidationDate AS ValidatedDate,
                       tv.datInterpretationDate AS InterpretedDate,
                       tv.blnReadOnly AS ReadOnlyIndicator,
                       t.idfMaterial AS SampleID,
                       m.strFieldBarCode AS EIDSSLocalOrFieldSampleID,
                       m.strBarCode AS EIDSSLaboratorySampleID,
                       sampleType.name AS SampleTypeName,
                       s.idfSpecies AS SpeciesID,
                       speciesType.name AS SpeciesTypeName,
                       'Herd/Flock ' + h.strHerdCode + ' - ' + speciesType.name AS Species,
                       a.idfAnimal AS AnimalID,
                       a.strAnimalCode AS EIDSSAnimalID,
                       t.idfsTestName AS TestNameTypeID,
                       testNameType.name AS TestNameTypeName,
                       t.idfsTestCategory AS TestCategoryTypeID,
                       testCategoryType.name AS TestCategoryTypeName,
                       t.idfsTestResult AS TestResultTypeID,
                       testResultType.name AS TestResultTypeName,
                       ttr.blnIndicative AS IndicativeIndicator, 
                       f.idfFarm AS FarmID,
					   f.idfFarmActual AS FarmMasterID,
                       f.strFarmCode AS EIDSSFarmID,
                       tv.intRowStatus AS RowStatus,
                       m.idfVetCase AS DiseaseReportID,
					   vc.strCaseID AS EIDSSDiseaseReportID,
                       0 AS RowAction,
			           COUNT(*) OVER () AS TotalRowCount,
			           CurrentPage = @PageNumber,
			           (COUNT(*) OVER () / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0) AS TotalPages
                FROM dbo.tlbTestValidation tv
                    INNER JOIN dbo.tlbTesting t
                        ON t.idfTesting = tv.idfTesting
                           AND t.intRowStatus = 0
                    INNER JOIN dbo.tlbMaterial m
                        ON m.idfMaterial = t.idfMaterial
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType
                        ON sampleType.idfsReference = m.idfsSampleType
                    LEFT JOIN dbo.trtTestTypeToTestResult ttr 
                        ON ttr.idfsTestName = t.idfsTestName 
                            AND ttr.idfsTestResult = t.idfsTestResult
                                AND ttr.intRowStatus = 0
                    LEFT JOIN dbo.tlbAnimal a
                        ON a.idfAnimal = m.idfAnimal
                           AND a.intRowStatus = 0
                    LEFT JOIN dbo.tlbSpecies s
                        ON s.idfSpecies = m.idfSpecies
                           AND s.intRowStatus = 0
                    LEFT JOIN dbo.tlbHerd h
                        ON h.idfHerd = s.idfHerd
                           AND h.intRowStatus = 0
                    LEFT JOIN dbo.tlbFarm f
                        ON f.idfFarm = h.idfFarm
                           AND f.intRowStatus = 0
                    LEFT JOIN dbo.tlbPerson interpretedByPerson
                        ON interpretedByPerson.idfPerson = tv.idfInterpretedByPerson
                           AND interpretedByPerson.intRowStatus = 0
                    LEFT JOIN dbo.tlbPerson validatedByPerson
                        ON validatedByPerson.idfPerson = tv.idfValidatedByPerson
                           AND validatedByPerson.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000106) interpretedStatusType
                        ON interpretedStatusType.idfsReference = tv.idfsInterpretedStatus
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) diagnosis
                        ON diagnosis.idfsReference = tv.idfsDiagnosis
					INNER JOIN dbo.trtDiagnosis d
						ON d.idfsDiagnosis = diagnosis.idfsReference
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                        ON speciesType.idfsReference = s.idfsSpeciesType
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000097) testNameType
                        ON testNameType.idfsReference = t.idfsTestName
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000095) testCategoryType
                        ON testCategoryType.idfsReference = t.idfsTestCategory
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) testResultType
                        ON testResultType.idfsReference = t.idfsTestResult
					LEFT JOIN dbo.tlbVetCase vc
						ON vc.idfVetCase = m.idfVetCase
						AND vc.intRowStatus = 0
                WHERE tv.intRowStatus = 0
                      AND m.idfVetCase = @DiseaseReportID
                GROUP BY tv.idfTestValidation,
                       tv.idfsDiagnosis,
                       diagnosis.Name,
					   d.idfsUsingType,
                       tv.idfsInterpretedStatus,
                       interpretedStatusType.name,
                       tv.idfValidatedByOffice,
                       tv.idfValidatedByPerson,
                       validatedByPerson.strFamilyName,
                       validatedByPerson.strFirstName,
                       validatedByPerson.strSecondName,
                       tv.idfInterpretedByOffice,
                       tv.idfInterpretedByPerson,
                       interpretedByPerson.strFamilyName,
                       interpretedByPerson.strFirstName,
                       interpretedByPerson.strSecondName,
                       tv.idfTesting,
                       tv.blnValidateStatus,
                       tv.blnCaseCreated,
                       tv.strValidateComment,
                       tv.strInterpretedComment,
                       tv.datValidationDate,
                       tv.datInterpretationDate,
                       tv.blnReadOnly,
                       t.idfMaterial,
                       m.strFieldBarCode,
                       m.strBarCode,
                       sampleType.name,
                       s.idfSpecies,
                       speciesType.name,
                       h.strHerdCode,
                       a.idfAnimal,
                       a.strAnimalCode,
                       t.idfsTestName,
                       testNameType.name,
                       t.idfsTestCategory,
                       testCategoryType.name,
                       t.idfsTestResult,
                       testResultType.name,
                       ttr.blnIndicative, 
                       f.idfFarm,
					   f.idfFarmActual,
                       f.strFarmCode,
                       tv.intRowStatus,
                       m.idfVetCase,
					   vc.strCaseID
            ) AS x
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec
            ORDER BY RowNum;
        END
        ELSE
        BEGIN
            SELECT TestInterpretationID,
                   DiseaseID,
                   DiseaseName,
				   DiseaseUsingType,
                   InterpretedStatusTypeID,
                   InterpretedStatusTypeName,
                   ValidatedByOrganizationID,
                   ValidatedByPersonID,
                   ValidatedByPersonName,
                   InterpretedByOrganizationID,
                   InterpretedByPersonID,
                   InterpretedByPersonName,
                   TestID,
                   ValidatedStatusIndicator,
                   ReportSessionCreatedIndicator,
                   ValidatedComment,
                   InterpretedComment,
                   ValidatedDate,
                   InterpretedDate,
                   ReadOnlyIndicator,
                   SampleID,
                   EIDSSLocalOrFieldSampleID,
                   EIDSSLaboratorySampleID,
                   SampleTypeName,
                   SpeciesID,
                   SpeciesTypeName,
                   Species,
                   AnimalID,
                   EIDSSAnimalID,
                   TestNameTypeID,
                   TestNameTypeName,
                   TestCategoryTypeID,
                   TestCategoryTypeName,
                   TestResultTypeID,
                   TestResultTypeName,
                   IndicativeIndicator, 
                   FarmID,
				   FarmMasterID,
                   EIDSSFarmID,
                   RowStatus,
                   DiseaseReportID,
				   EIDSSDiseaseReportID,
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
                                                   END DESC
                                         ) AS RowNum,
                       tv.idfTestValidation AS TestInterpretationID,
                       tv.idfsDiagnosis AS DiseaseID,
                       diagnosis.Name AS DiseaseName,
					   d.idfsUsingType AS DiseaseUsingType,
                       tv.idfsInterpretedStatus AS InterpretedStatusTypeID,
                       interpretedStatusType.name AS InterpretedStatusTypeName,
                       tv.idfValidatedByOffice AS ValidatedByOrganizationID,
                       tv.idfValidatedByPerson AS ValidatedByPersonID,
                       COALESCE(CONCAT(
                                          validatedByPerson.strFamilyName,
                                          CASE
                                              WHEN validatedByPerson.strFirstName IS NULL THEN
                                                  ''
                                              ELSE
                                                  ', '
                                          END,
                                          COALESCE(CONCAT(
                                                             validatedByPerson.strFirstName,
                                                             ' ',
                                                             validatedByPerson.strSecondName
                                                         ), validatedByPerson.strFirstName, validatedByPerson.strSecondName)
                                      ), validatedByPerson.strFamilyName, COALESCE(CONCAT(
                                                                                             validatedByPerson.strFirstName,
                                                                                             ' ',
                                                                                             validatedByPerson.strSecondName
                                                                                         ), validatedByPerson.strFirstName, validatedByPerson.strSecondName)) AS ValidatedByPersonName,
                       tv.idfInterpretedByOffice AS InterpretedByOrganizationID,
                       tv.idfInterpretedByPerson AS InterpretedByPersonID,
                       COALESCE(CONCAT(
                                          interpretedByPerson.strFamilyName,
                                          CASE
                                              WHEN interpretedByPerson.strFirstName IS NULL THEN
                                                  ''
                                              ELSE
                                                  ', '
                                          END,
                                          COALESCE(CONCAT(
                                                             interpretedByPerson.strFirstName,
                                                             ' ',
                                                             interpretedByPerson.strSecondName
                                                         ), interpretedByPerson.strFirstName, interpretedByPerson.strSecondName)
                                      ), interpretedByPerson.strFamilyName, COALESCE(CONCAT(
                                                                                               interpretedByPerson.strFirstName,
                                                                                               ' ',
                                                                                               interpretedByPerson.strSecondName
                                                                                           ), interpretedByPerson.strFirstName, interpretedByPerson.strSecondName)) AS InterpretedByPersonName,
                       tv.idfTesting AS TestID,
                       tv.blnValidateStatus AS ValidatedStatusIndicator,
                       tv.blnCaseCreated AS ReportSessionCreatedIndicator,
                       tv.strValidateComment AS ValidatedComment,
                       tv.strInterpretedComment AS InterpretedComment,
                       tv.datValidationDate AS ValidatedDate,
                       tv.datInterpretationDate AS InterpretedDate,
                       tv.blnReadOnly AS ReadOnlyIndicator,
                       t.idfMaterial AS SampleID,
                       m.strFieldBarCode AS EIDSSLocalOrFieldSampleID,
                       m.strBarCode AS EIDSSLaboratorySampleID,
                       sampleType.name AS SampleTypeName,
                       s.idfSpecies AS SpeciesID,
                       speciesType.name AS SpeciesTypeName,
                       'Herd/Flock ' + h.strHerdCode + ' - ' + speciesType.name AS Species,
                       a.idfAnimal AS AnimalID,
                       a.strAnimalCode AS EIDSSAnimalID,
                       t.idfsTestName AS TestNameTypeID,
                       testNameType.name AS TestNameTypeName,
                       t.idfsTestCategory AS TestCategoryTypeID,
                       testCategoryType.name AS TestCategoryTypeName,
                       t.idfsTestResult AS TestResultTypeID,
                       testResultType.name AS TestResultTypeName,
                       ttr.blnIndicative AS IndicativeIndicator, 
                       f.idfFarm AS FarmID,
					   f.idfFarmActual AS FarmMasterID,
                       f.strFarmCode AS EIDSSFarmID,
                       tv.intRowStatus AS RowStatus,
                       m.idfVetCase AS DiseaseReportID,
					   vc.strCaseID AS EIDSSDiseaseReportID,
                       0 AS RowAction,
			           COUNT(*) OVER () AS TotalRowCount,
			           CurrentPage = @PageNumber,
			           (COUNT(*) OVER () / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0) AS TotalPages
                FROM dbo.tlbTestValidation tv
                    INNER JOIN dbo.tlbTesting t
                        ON t.idfTesting = tv.idfTesting
                           AND t.intRowStatus = 0
                    INNER JOIN dbo.tlbMaterial m
                        ON m.idfMaterial = t.idfMaterial
                           AND m.intRowStatus = 0
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType
                        ON sampleType.idfsReference = m.idfsSampleType
                    LEFT JOIN dbo.trtTestTypeToTestResult ttr 
                        ON ttr.idfsTestName = t.idfsTestName 
                            AND ttr.idfsTestResult = t.idfsTestResult
                                AND ttr.intRowStatus = 0
                    LEFT JOIN dbo.tlbAnimal a
                        ON a.idfAnimal = m.idfAnimal
                           AND a.intRowStatus = 0
                    LEFT JOIN dbo.tlbSpecies s
                        ON s.idfSpecies = m.idfSpecies
                           AND s.intRowStatus = 0
                    LEFT JOIN dbo.tlbHerd h
                        ON h.idfHerd = s.idfHerd
                           AND h.intRowStatus = 0
                    LEFT JOIN dbo.tlbFarm f
                        ON f.idfFarm = h.idfFarm
                           AND f.intRowStatus = 0
                    LEFT JOIN dbo.tlbPerson interpretedByPerson
                        ON interpretedByPerson.idfPerson = tv.idfInterpretedByPerson
                           AND interpretedByPerson.intRowStatus = 0
                    LEFT JOIN dbo.tlbPerson validatedByPerson
                        ON validatedByPerson.idfPerson = tv.idfValidatedByPerson
                           AND validatedByPerson.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000106) interpretedStatusType
                        ON interpretedStatusType.idfsReference = tv.idfsInterpretedStatus
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) diagnosis
                        ON diagnosis.idfsReference = tv.idfsDiagnosis
					INNER JOIN dbo.trtDiagnosis d
						ON d.idfsDiagnosis = diagnosis.idfsReference
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                        ON speciesType.idfsReference = s.idfsSpeciesType
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000097) testNameType
                        ON testNameType.idfsReference = t.idfsTestName
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000095) testCategoryType
                        ON testCategoryType.idfsReference = t.idfsTestCategory
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000096) testResultType
                        ON testResultType.idfsReference = t.idfsTestResult
					LEFT JOIN dbo.tlbVetCase vc 
						ON vc.idfVetCase = m.idfVetCase
						AND vc.intRowStatus = 0
                WHERE tv.intRowStatus = 0
                      AND m.idfMonitoringSession = @MonitoringSessionID
                GROUP BY tv.idfTestValidation,
                       tv.idfsDiagnosis,
                       diagnosis.Name,
					   d.idfsUsingType,
                       tv.idfsInterpretedStatus,
                       interpretedStatusType.name,
                       tv.idfValidatedByOffice,
                       tv.idfValidatedByPerson,
                       validatedByPerson.strFamilyName,
                       validatedByPerson.strFirstName,
                       validatedByPerson.strSecondName,
                       tv.idfInterpretedByOffice,
                       tv.idfInterpretedByPerson,
                       interpretedByPerson.strFamilyName,
                       interpretedByPerson.strFirstName,
                       interpretedByPerson.strSecondName,
                       tv.idfTesting,
                       tv.blnValidateStatus,
                       tv.blnCaseCreated,
                       tv.strValidateComment,
                       tv.strInterpretedComment,
                       tv.datValidationDate,
                       tv.datInterpretationDate,
                       tv.blnReadOnly,
                       t.idfMaterial,
                       m.strFieldBarCode,
                       m.strBarCode,
                       sampleType.name,
                       s.idfSpecies,
                       speciesType.name,
                       h.strHerdCode,
                       a.idfAnimal,
                       a.strAnimalCode,
                       t.idfsTestName,
                       testNameType.name,
                       t.idfsTestCategory,
                       testCategoryType.name,
                       t.idfsTestResult,
                       testResultType.name,
                       ttr.blnIndicative, 
                       f.idfFarm,
					   f.idfFarmActual,
                       f.strFarmCode,
                       tv.intRowStatus,
                       m.idfVetCase,
					   vc.strCaseID
            ) AS x
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec
            ORDER BY RowNum;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
