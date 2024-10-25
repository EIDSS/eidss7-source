-- ================================================================================================
-- Name: USP_VET_ANIMAL_GETList
--
-- Description:	Get animal list for the livestock veterinary disease enter and edit use cases, 
-- the veterinary active surveillance session edit use case, and the livestock veterinary 
-- disease report deduplication use case.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/02/2018 Initial release.
-- Stephen Long     04/18/2019 Updated for API.
-- Stephen Long     06/19/2019 Corrected vet case join to use farm ID.
-- Stephen Long     07/02/2019 Added distinct to cover for multiple samples with the same animal.
-- Ann Xiong		11/22/2019 Added Species, ClinicalSigns to select list.
-- Stephen Long     04/24/2020 Added clinical signs indicator to the model.
-- Stephen Long     12/28/2020 Optimized query for better performance; removed unused parameters.
-- Stephen Long     11/24/2021 Added pagination and sorting.
-- Stephen Long     01/12/2022 Split out into two portions for disease report and session for 
--                             better performance.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_ANIMAL_GETList]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'EIDSSAnimalID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @DiseaseReportID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FirstRec INT = (@PageNumber - 1) * @PageSize,
                @LastRec INT = (@PageNumber * @PageSize + 1),
                @TotalRowCount INT;

        IF @DiseaseReportID IS NOT NULL
        BEGIN
            SET @TotalRowCount =
            (
                SELECT COUNT(*)
                FROM dbo.tlbAnimal a
                    INNER JOIN dbo.tlbSpecies s
                        ON s.idfSpecies = a.idfSpecies
                           AND s.intRowStatus = 0
                    INNER JOIN dbo.tlbHerd h
                        ON h.idfHerd = s.idfHerd
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbVetCase vc
                        ON vc.idfFarm = h.idfFarm
                           AND vc.intRowStatus = 0
                WHERE a.intRowStatus = 0
                      AND vc.idfVetCase = @DiseaseReportID
            );

            SELECT AnimalID,
                   SexTypeID,
                   SexTypeName,
                   ConditionTypeID,
                   ConditionTypeName,
                   AgeTypeID,
                   AgeTypeName,
                   SpeciesID,
                   SpeciesTypeName,
                   ObservationID,
                   AnimalDescription,
                   EIDSSAnimalID,
                   AnimalName,
                   Color,
                   RowStatus,
                   HerdID,
                   EIDSSHerdID,
                   Species,
                   ClinicalSigns,
                   ClinicalSignsIndicator,
                   RowAction,
                   [RowCount],
                   TotalRowCount,
                   CurrentPage,
                   TotalPages
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                       WHEN @SortColumn = 'EIDSSHerdID'
                                                            AND @SortOrder = 'ASC' THEN
                                                           h.strHerdCode
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'EIDSSHerdID'
                                                            AND @SortOrder = 'DESC' THEN
                                                           h.strHerdCode
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
                                                       WHEN @SortColumn = 'Species'
                                                            AND @SortOrder = 'ASC' THEN
                                                           'Herd ' + h.strHerdCode + ' - ' + speciesType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'Species'
                                                            AND @SortOrder = 'DESC' THEN
                                                           'Herd ' + h.strHerdCode + ' - ' + speciesType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'AgeTypeName'
                                                            AND @SortOrder = 'ASC' THEN
                                                           ageType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'AgeTypeName'
                                                            AND @SortOrder = 'DESC' THEN
                                                           ageType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'SexTypeName'
                                                            AND @SortOrder = 'ASC' THEN
                                                           sexType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'SexTypeName'
                                                            AND @SortOrder = 'DESC' THEN
                                                           sexType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'Status'
                                                            AND @SortOrder = 'ASC' THEN
                                                           conditionType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'Status'
                                                            AND @SortOrder = 'DESC' THEN
                                                           conditionType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'Note'
                                                            AND @SortOrder = 'ASC' THEN
                                                           a.strDescription
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'Note'
                                                            AND @SortOrder = 'DESC' THEN
                                                           a.strDescription
                                                   END DESC
                                         ) AS RowNum,
                       a.idfAnimal AS AnimalID,
                       a.idfsAnimalGender AS SexTypeID,
                       sexType.name AS SexTypeName,
                       a.idfsAnimalCondition AS ConditionTypeID,
                       conditionType.name AS ConditionTypeName,
                       a.idfsAnimalAge AS AgeTypeID,
                       ageType.name AS AgeTypeName,
                       a.idfSpecies AS SpeciesID,
                       speciesType.name AS SpeciesTypeName,
                       a.idfObservation AS ObservationID,
                       a.strDescription AS AnimalDescription,
                       a.strAnimalCode AS EIDSSAnimalID,
                       a.strName AS AnimalName,
                       a.strColor AS Color,
                       a.intRowStatus AS RowStatus,
                       h.idfHerd AS HerdID,
                       h.strHerdCode AS EIDSSHerdID,
                       'Herd ' + h.strHerdCode + ' - ' + speciesType.name AS Species,
                       CASE
                           WHEN a.idfObservation IS NULL THEN
                               'Yes'
                           ELSE
                               'No'
                       END AS ClinicalSigns,
                       a.idfsYNClinicalSigns AS ClinicalSignsIndicator,
                       0 AS RowAction,
                       COUNT(*) OVER () AS [RowCount],
                       @TotalRowCount AS TotalRowCount,
                       CurrentPage = @PageNumber,
                       TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
                FROM dbo.tlbAnimal a
                    INNER JOIN dbo.tlbSpecies s
                        ON s.idfSpecies = a.idfSpecies
                           AND s.intRowStatus = 0
                    INNER JOIN dbo.tlbHerd h
                        ON h.idfHerd = s.idfHerd
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbVetCase vc
                        ON vc.idfFarm = h.idfFarm
                           AND vc.intRowStatus = 0
                    INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                        ON speciesType.idfsReference = s.idfsSpeciesType
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000005) ageType
                        ON ageType.idfsReference = a.idfsAnimalAge
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000006) conditionType
                        ON conditionType.idfsReference = a.idfsAnimalCondition
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000007) sexType
                        ON sexType.idfsReference = a.idfsAnimalGender
                WHERE a.intRowStatus = 0
                      AND vc.idfVetCase = @DiseaseReportID
                GROUP BY a.idfAnimal,
                         a.idfsAnimalGender,
                         sexType.name,
                         a.idfsAnimalCondition,
                         conditionType.name,
                         a.idfsAnimalAge,
                         ageType.name,
                         a.idfSpecies,
                         speciesType.name,
                         a.idfObservation,
                         a.strDescription,
                         a.strAnimalCode,
                         a.strName,
                         a.strColor,
                         a.intRowStatus,
                         h.idfHerd,
                         h.strHerdCode,
                         a.idfsYNClinicalSigns
            ) AS x
            WHERE RowNum > @FirstRec
                  AND RowNum < @LastRec
            ORDER BY RowNum;
        END
        ELSE
        BEGIN
            SET @TotalRowCount =
            (
                SELECT COUNT(*)
                FROM dbo.tlbAnimal a
                    INNER JOIN dbo.tlbMaterial m
                        ON m.idfAnimal = a.idfAnimal
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbSpecies s
                        ON s.idfSpecies = a.idfSpecies
                           AND s.intRowStatus = 0
                    LEFT JOIN dbo.tlbHerd h
                        ON h.idfHerd = s.idfHerd
                           AND h.intRowStatus = 0
                WHERE a.intRowStatus = 0
                      AND m.idfMonitoringSession = @MonitoringSessionID
            );

            SELECT AnimalID,
                   SexTypeID,
                   SexTypeName,
                   ConditionTypeID,
                   ConditionTypeName,
                   AgeTypeID,
                   AgeTypeName,
                   SpeciesID,
                   SpeciesTypeName,
                   ObservationID,
                   AnimalDescription,
                   EIDSSAnimalID,
                   AnimalName,
                   Color,
                   RowStatus,
                   HerdID,
                   EIDSSHerdID,
                   Species,
                   ClinicalSigns,
                   ClinicalSignsIndicator,
                   RowAction,
                   [RowCount],
                   TotalRowCount,
                   CurrentPage,
                   TotalPages
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                       WHEN @SortColumn = 'EIDSSHerdID'
                                                            AND @SortOrder = 'ASC' THEN
                                                           h.strHerdCode
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'EIDSSHerdID'
                                                            AND @SortOrder = 'DESC' THEN
                                                           h.strHerdCode
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
                                                       WHEN @SortColumn = 'Species'
                                                            AND @SortOrder = 'ASC' THEN
                                                           'Herd ' + h.strHerdCode + ' - ' + speciesType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'Species'
                                                            AND @SortOrder = 'DESC' THEN
                                                           'Herd ' + h.strHerdCode + ' - ' + speciesType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'AgeTypeName'
                                                            AND @SortOrder = 'ASC' THEN
                                                           ageType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'AgeTypeName'
                                                            AND @SortOrder = 'DESC' THEN
                                                           ageType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'SexTypeName'
                                                            AND @SortOrder = 'ASC' THEN
                                                           sexType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'SexTypeName'
                                                            AND @SortOrder = 'DESC' THEN
                                                           sexType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'Status'
                                                            AND @SortOrder = 'ASC' THEN
                                                           conditionType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'Status'
                                                            AND @SortOrder = 'DESC' THEN
                                                           conditionType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @SortColumn = 'Note'
                                                            AND @SortOrder = 'ASC' THEN
                                                           a.strDescription
                                                   END ASC,
                                                   CASE
                                                       WHEN @SortColumn = 'Note'
                                                            AND @SortOrder = 'DESC' THEN
                                                           a.strDescription
                                                   END DESC
                                         ) AS RowNum,
                       a.idfAnimal AS AnimalID,
                       a.idfsAnimalGender AS SexTypeID,
                       sexType.name AS SexTypeName,
                       a.idfsAnimalCondition AS ConditionTypeID,
                       conditionType.name AS ConditionTypeName,
                       a.idfsAnimalAge AS AgeTypeID,
                       ageType.name AS AgeTypeName,
                       a.idfSpecies AS SpeciesID,
                       speciesType.name AS SpeciesTypeName,
                       a.idfObservation AS ObservationID,
                       a.strDescription AS AnimalDescription,
                       a.strAnimalCode AS EIDSSAnimalID,
                       a.strName AS AnimalName,
                       a.strColor AS Color,
                       a.intRowStatus AS RowStatus,
                       h.idfHerd AS HerdID,
                       h.strHerdCode AS EIDSSHerdID,
                       'Herd ' + h.strHerdCode + ' - ' + speciesType.name AS Species,
                       CASE
                           WHEN a.idfObservation IS NULL THEN
                               'Yes'
                           ELSE
                               'No'
                       END AS ClinicalSigns,
                       a.idfsYNClinicalSigns AS ClinicalSignsIndicator,
                       0 AS RowAction,
                       COUNT(*) OVER () AS [RowCount],
                       @TotalRowCount AS TotalRowCount,
                       CurrentPage = @PageNumber,
                       TotalPages = (@TotalRowCount / @PageSize) + IIF(COUNT(*) % @PageSize > 0, 1, 0)
                FROM dbo.tlbAnimal a
                    INNER JOIN dbo.tlbMaterial m
                        ON m.idfAnimal = a.idfAnimal
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbSpecies s
                        ON s.idfSpecies = a.idfSpecies
                           AND s.intRowStatus = 0
                    LEFT JOIN dbo.tlbHerd h
                        ON h.idfHerd = s.idfHerd
                           AND h.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                        ON speciesType.idfsReference = s.idfsSpeciesType
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000005) ageType
                        ON ageType.idfsReference = a.idfsAnimalAge
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000006) conditionType
                        ON conditionType.idfsReference = a.idfsAnimalCondition
                    LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000007) sexType
                        ON sexType.idfsReference = a.idfsAnimalGender
                WHERE a.intRowStatus = 0
                      AND m.idfMonitoringSession = @MonitoringSessionID
                GROUP BY a.idfAnimal,
                         a.idfsAnimalGender,
                         sexType.name,
                         a.idfsAnimalCondition,
                         conditionType.name,
                         a.idfsAnimalAge,
                         ageType.name,
                         a.idfSpecies,
                         speciesType.name,
                         a.idfObservation,
                         a.strDescription,
                         a.strAnimalCode,
                         a.strName,
                         a.strColor,
                         a.intRowStatus,
                         h.idfHerd,
                         h.strHerdCode,
                         a.idfsYNClinicalSigns
            ) AS x
            WHERE RowNum > @FirstRec
                  AND RowNum < @LastRec
            ORDER BY RowNum;
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
