-- ================================================================================================
-- Name: USP_GBL_SAMPLE_IMPORT_GETList
--
-- Description:	Get sample list for the disease report import sample feature.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     08/12/2020 Initial release.
-- Stephen Long     10/14/2020 Added farm master ID and species type ID to the query.
-- Stephen Long     02/02/2021 Removed unneeded joins, and altering to work with POCO.
-- Stephen Long     01/19/2022 Added updated pagination and sorting logic.
-- Stephen Long     01/25/2022 Added farm master, species type and disease ID parameters.
-- Stephen Long     03/31/2022 Added lab sample ID to the where criteria.
-- Stephen Long     12/17/2022 Fix to not select samples that have already been imported.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_SAMPLE_IMPORT_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'EIDSSLocalOrFieldSampleID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @EIDSSLocalOrFieldSampleID NVARCHAR(200),
    @FarmMasterID BIGINT,
    @SpeciesTypeIDList VARCHAR(MAX),
    @DiseaseID BIGINT
)
AS
BEGIN
    DECLARE @FirstRec INT,
            @LastRec INT,
            @TotalRowCount INT = 0;
    DECLARE @Results TABLE (SampleID BIGINT NOT NULL);

    SET @FirstRec = (@PageNumber - 1) * @PageSize;
    SET @LastRec = (@PageNumber * @PageSize + 1);
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO @Results
        SELECT m.idfMaterial
        FROM dbo.tlbMaterial m
            LEFT JOIN dbo.tlbSpecies s
                ON s.idfSpecies = m.idfSpecies
                   AND s.intRowStatus = 0
            LEFT JOIN dbo.tlbHerd h
                ON h.idfHerd = s.idfHerd
                   AND h.intRowStatus = 0
            LEFT JOIN dbo.tlbFarm f
                ON f.idfFarm = h.idfFarm
                   AND f.intRowStatus = 0
        WHERE m.intRowStatus = 0
              AND m.idfVetCase IS NULL
              AND m.idfHumanCase IS NULL 
              AND m.DiseaseID = @DiseaseID
              AND f.idfFarmActual = @FarmMasterID
              AND s.idfsSpeciesType IN (
                                                SELECT CAST([Value] AS BIGINT)
                                                FROM dbo.FN_GBL_SYS_SplitList(@SpeciesTypeIDList, NULL, ',')
                                            )
              AND (m.strFieldBarcode LIKE '%' + @EIDSSLocalOrFieldSampleID + '%'
                   OR m.strBarcode LIKE '%' + @EIDSSLocalOrFieldSampleID + '%');

        SELECT SampleID,
               SampleTypeID,
               SampleTypeName,
               RootSampleID,
               OriginalSampleID,
               HumanID,
               SpeciesID,
               SpeciesTypeID,
               SpeciesTypeName,
               AnimalID,
               EIDSSAnimalID,
               AnimalGenderTypeID,
               AnimalGenderTypeName,
               AnimalAgeTypeID,
               AnimalAgeTypeName,
               AnimalColor,
               AnimalName,
               MonitoringSessionID,
               CollectedByPersonID,
               CollectedByPersonName,
               CollectedByOrganizationID,
               CollectedByOrganizationName,
               MainTestID,
               CollectionDate,
               SentDate,
               EIDSSLocalOrFieldSampleID,
               EIDSSReportOrSessionID,
               PatientOrFarmOwnerName,
               VectorSessionID,
               VectorID,
               FreezerID,
               SampleStatusTypeID,
               SampleStatusTypeName,
               FunctionalAreaID,
               FunctionalAreaName,
               DestroyedByPersonID,
               EnteredDate,
               DestructionDate,
               EIDSSLaboratorySampleID,
               Comments,
               SiteID,
               SentToOrganizationID,
               SentToOrganizationName,
               ReadOnlyIndicator,
               BirdStatusTypeID,
               BirdStatusTypeName,
               HumanDiseaseReportID,
               VeterinaryDiseaseReportID,
               AccessionDate,
               AccessionConditionTypeID,
               AccessionConditionTypeName,
               AccessionComment,
               AccessionByPersonID,
               DestructionMethodTypeID,
               CurrentSiteID,
               SampleKindTypeID,
               SampleKindTypeName,
               AccessionedIndicator,
               ShowInReportSessionListIndicator,
               ShowInLaboratoryListIndicator,
               ShowInDispositionListIndicator,
               ShowInAccessionListIndicator,
               MarkedForDispositionByPersonID,
               OutOfRepositoryDate,
               SampleStatusDate,
               DiseaseID,
               FarmID,
               FarmMasterID,
               EIDSSFarmID,
               Species,
               EIDSSLaboratoryOrLocalFieldSampleID,
               LabModuleSourceIndicator,
               RowStatus,
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
                                                   WHEN @SortColumn = 'SampleTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       sampleType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SampleTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       sampleType.name
                                               END DESC
                                     ) AS RowNum,
                   m.idfMaterial AS SampleID,
                   m.idfsSampleType AS SampleTypeID,
                   sampleType.name AS SampleTypeName,
                   m.idfRootMaterial AS RootSampleID,
                   m.idfParentMaterial AS OriginalSampleID,
                   m.idfHuman AS HumanID,
                   m.idfSpecies AS SpeciesID,
                   speciesType.idfsReference AS SpeciesTypeID,
                   speciesType.name AS SpeciesTypeName,
                   m.idfAnimal AS AnimalID,
                   a.strAnimalCode AS EIDSSAnimalID,
                   a.idfsAnimalGender AS AnimalGenderTypeID,
                   animalSexType.name AS AnimalGenderTypeName,
                   a.idfsAnimalAge AS AnimalAgeTypeID,
                   animalAgeType.name AS AnimalAgeTypeName,
                   a.strColor AS AnimalColor,
                   a.strName AS AnimalName,
                   m.idfMonitoringSession AS MonitoringSessionID,
                   m.idfFieldCollectedByPerson AS CollectedByPersonID,
                   ISNULL(collectedByPerson.strFamilyName, N'') + ISNULL(', ' + collectedByPerson.strFirstName, '')
                   + ISNULL(' ' + collectedByPerson.strSecondName, '') AS CollectedByPersonName,
                   m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
                   collectedByOrganization.name AS CollectedByOrganizationName,
                   m.idfMainTest AS MainTestID,
                   m.datFieldCollectionDate AS CollectionDate,
                   m.datFieldSentDate AS SentDate,
                   m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
                   m.strCalculatedCaseID AS EIDSSReportOrSessionID,
                   m.strCalculatedHumanName AS PatientOrFarmOwnerName,
                   m.idfVectorSurveillanceSession AS VectorSessionID,
                   m.idfVector AS VectorID,
                   m.idfSubdivision AS FreezerID,
                   m.idfsSampleStatus AS SampleStatusTypeID,
                   sampleStatusType.name AS SampleStatusTypeName,
                   m.idfInDepartment AS FunctionalAreaID,
                   functionalArea.name AS FunctionalAreaName,
                   m.idfDestroyedByPerson AS DestroyedByPersonID,
                   m.datEnteringDate AS EnteredDate,
                   m.datDestructionDate AS DestructionDate,
                   m.strBarcode AS EIDSSLaboratorySampleID,
                   m.strNote AS Comments,
                   m.idfsSite AS SiteID,
                   m.idfSendToOffice AS SentToOrganizationID,
                   sentToOrganization.name AS SentToOrganizationName,
                   m.blnReadOnly AS ReadOnlyIndicator,
                   m.idfsBirdStatus AS BirdStatusTypeID,
                   birdStatusType.name AS BirdStatusTypeName,
                   m.idfHumanCase AS HumanDiseaseReportID,
                   m.idfVetCase AS VeterinaryDiseaseReportID,
                   m.datAccession AS AccessionDate,
                   m.idfsAccessionCondition AS AccessionConditionTypeID,
                   accessionConditionType.name AS AccessionConditionTypeName,
                   m.strCondition AS AccessionComment,
                   m.idfAccesionByPerson AS AccessionByPersonID,
                   m.idfsDestructionMethod AS DestructionMethodTypeID,
                   m.idfsCurrentSite AS CurrentSiteID,
                   m.idfsSampleKind AS SampleKindTypeID,
                   sampleKindType.name AS SampleKindTypeName,
                   m.blnAccessioned AS AccessionedIndicator,
                   m.blnShowInCaseOrSession AS ShowInReportSessionListIndicator,
                   m.blnShowInLabList AS ShowInLaboratoryListIndicator,
                   m.blnShowInDispositionList AS ShowInDispositionListIndicator,
                   m.blnShowInAccessionInForm AS ShowInAccessionListIndicator,
                   m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
                   m.datOutOfRepositoryDate AS OutOfRepositoryDate,
                   m.datSampleStatusDate AS SampleStatusDate,
                   m.DiseaseID,
                   f.idfFarm AS FarmID,
                   f.idfFarmActual AS FarmMasterID,
                   f.strFarmCode AS EIDSSFarmID,
                   hd.strHerdCode + ' - ' + speciesType.name AS Species,
                   CASE
                       WHEN m.strBarcode IS NULL THEN
                           m.strFieldBarcode
                       ELSE
                           m.strBarcode
                   END AS EIDSSLaboratoryOrLocalFieldSampleID,
                   m.LabModuleSourceIndicator,
                   m.intRowStatus AS RowStatus,
                   0 AS RowAction,
                   COUNT(*) OVER () AS TotalRowCount,
                   CurrentPage = @PageNumber,
                   TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
            FROM @Results res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.SampleID
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
                LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) collectedByOrganization
                    ON collectedByOrganization.idfOffice = m.idfFieldCollectedByOffice
                LEFT JOIN dbo.tlbDepartment d
                    ON d.idfDepartment = m.idfInDepartment
                       AND d.intRowStatus = 0
                LEFT JOIN dbo.tlbOffice departmentOffice
                    ON departmentOffice.idfOffice = d.idfOrganization
                       AND departmentOffice.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000164) functionalArea
                    ON functionalArea.idfsReference = d.idfsDepartmentName
                LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) sentToOrganization
                    ON sentToOrganization.idfOffice = m.idfSendToOffice
                LEFT JOIN dbo.tlbPerson collectedByPerson
                    ON collectedByPerson.idfPerson = m.idfFieldCollectedByPerson
                       AND collectedByPerson.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000015) sampleStatusType
                    ON sampleStatusType.idfsReference = m.idfsSampleStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000006) birdStatusType
                    ON birdStatusType.idfsReference = m.idfsBirdStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000110) accessionConditionType
                    ON accessionConditionType.idfsReference = m.idfsAccessionCondition
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000158) sampleKindType
                    ON sampleKindType.idfsReference = m.idfsSampleKind
                LEFT JOIN dbo.tlbAnimal a
                    ON a.idfAnimal = m.idfAnimal
                       AND a.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000005) animalAgeType
                    ON animalAgeType.idfsReference = a.idfsAnimalAge
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000007) animalSexType
                    ON animalSexType.idfsReference = a.idfsAnimalGender
                LEFT JOIN dbo.tlbSpecies s
                    ON s.idfSpecies = CASE
                                          WHEN m.idfAnimal IS NULL THEN
                                              m.idfSpecies
                                          ELSE
                                              a.idfSpecies
                                      END
                       AND s.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                    ON speciesType.idfsReference = s.idfsSpeciesType
                LEFT JOIN dbo.tlbHerd hd
                    ON hd.idfHerd = s.idfHerd
                       AND hd.intRowStatus = 0
                LEFT JOIN dbo.tlbFarm f
                    ON f.idfFarm = hd.idfFarm
                       AND f.intRowStatus = 0
            GROUP BY m.idfMaterial,
                     m.idfsSampleType,
                     sampleType.name,
                     m.idfRootMaterial,
                     m.idfParentMaterial,
                     m.idfHuman,
                     m.idfSpecies,
                     speciesType.idfsReference,
                     speciesType.name,
                     m.idfAnimal,
                     a.strAnimalCode,
                     a.idfsAnimalGender,
                     animalSexType.name,
                     a.idfsAnimalAge,
                     animalAgeType.name,
                     a.strColor,
                     a.strName,
                     m.idfMonitoringSession,
                     m.idfFieldCollectedByPerson,
                     collectedByPerson.strFamilyName,
                     collectedByPerson.strFirstName,
                     collectedByPerson.strSecondName,
                     m.idfFieldCollectedByOffice,
                     collectedByOrganization.name,
                     m.idfMainTest,
                     m.datFieldCollectionDate,
                     m.datFieldSentDate,
                     m.strFieldBarcode,
                     m.strCalculatedCaseID,
                     m.strCalculatedHumanName,
                     m.idfVectorSurveillanceSession,
                     m.idfVector,
                     m.idfSubdivision,
                     m.idfsSampleStatus,
                     sampleStatusType.name,
                     m.idfInDepartment,
                     functionalArea.name,
                     m.idfDestroyedByPerson,
                     m.datEnteringDate,
                     m.datDestructionDate,
                     m.strBarcode,
                     m.strNote,
                     m.idfsSite,
                     m.intRowStatus,
                     m.idfSendToOffice,
                     sentToOrganization.name,
                     m.blnReadOnly,
                     m.idfsBirdStatus,
                     birdStatusType.name,
                     m.idfHumanCase,
                     m.idfVetCase,
                     m.datAccession,
                     m.idfsAccessionCondition,
                     accessionConditionType.name,
                     m.strCondition,
                     m.idfAccesionByPerson,
                     m.idfsDestructionMethod,
                     m.idfsCurrentSite,
                     m.idfsSampleKind,
                     sampleKindType.name,
                     m.blnAccessioned,
                     m.blnShowInCaseOrSession,
                     m.blnShowInLabList,
                     m.blnShowInDispositionList,
                     m.blnShowInAccessionInForm,
                     m.idfMarkedForDispositionByPerson,
                     m.datOutOfRepositoryDate,
                     m.datSampleStatusDate,
                     m.DiseaseID,
                     hd.strHerdCode,
                     f.idfFarm,
                     f.idfFarmActual,
                     f.strFarmCode,
                     m.LabModuleSourceIndicator
        ) AS x
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
