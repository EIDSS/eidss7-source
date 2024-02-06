-- ================================================================================================
-- Name: USP_VET_FARM_INVENTORY_GETList
--
-- Description:	Get farm, herd/flock, species list as a flattened structure for the veterinary 
-- disease and monitoring session enter and edit use cases.
--
-- Do not include paging and sorting for this stored procedure as it is displayed in a hierarchical 
-- fashion in the user interface.
--
-- Farm 1
--  Flock or Herd 1
--   Species 1
--   Species 2
--  Flock or Herd 2
--   Species 3
-- Farm 2 ...
--
-- 10012003 = Livestock disease report (otherwise it is Avian)
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/10/2019 Initial release.
-- Stephen Long     04/23/2019 Updated where clause on farm snapshot insert/selects to no longer 
--                             left join veterinary disease report as not needed.
-- Stephen Long     07/20/2019 No longer retrieve herds/flocks/species records from farm master.
-- Ann Xiong		11/21/2019 Added Species to select list.
-- Ann Xiong		12/17/2019 Updated script for both Livestock and Avian (IF NOT @FarmID IS 
--                             NULL).
-- Stephen Long     10/08/2020 Split out total animal quantity to account for farms that are both 
--                             avian and livestock, so the correct counts will show on the two 
--                             different veterinary disease reports.
-- Stephen Long     12/29/2020 Changed function for reference data to handle inactive records.
-- Stephen Long     11/29/2021 Added select field names to last sql statement to work with POCO.
-- Stephen Long     01/12/2022 Added total row count, current page and total pages to the query.
-- Stephen Long     01/17/2022 Removed the words 'Farm' and 'Herd'; needs to be localized.
-- Stephen Long     06/16/2022 Added outbreak case status type ID for species records.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_FARM_INVENTORY_GETList]
(
    @LanguageID NVARCHAR(50),
    @DiseaseReportID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @FarmID BIGINT = NULL,
    @FarmMasterID BIGINT = NULL,
    @EIDSSFarmID NVARCHAR(200) = NULL
)
AS
BEGIN
    DECLARE @FarmInventory TABLE
    (
        RecordID INT IDENTITY PRIMARY KEY,
        RecordType VARCHAR(10),
        FarmID BIGINT NULL,
        FarmMasterID BIGINT NULL,
        FlockOrHerdID BIGINT NULL,
        FlockOrHerdMasterID BIGINT NULL,
        SpeciesID BIGINT NULL,
        SpeciesMasterID BIGINT NULL,
        SpeciesTypeID BIGINT NULL,
        SpeciesTypeName NVARCHAR(200) NULL,
        EIDSSFarmID NVARCHAR(200) NULL,
        EIDSSFlockOrHerdID NVARCHAR(200) NULL,
        StartOfSignsDate DATETIME NULL,
        AverageAge NVARCHAR(200) NULL,
        SickAnimalQuantity INT NULL,
        TotalAnimalQuantity INT NULL,
        DeadAnimalQuantity INT NULL,
        ObservationID BIGINT NULL,
        Note NVARCHAR(2000) NULL,
        OutbreakCaseStatusTypeID BIGINT NULL, 
        RowStatus INT NULL,
        RowAction INT
    );

    BEGIN TRY
        IF NOT @MonitoringSessionID IS NULL
        BEGIN
            INSERT INTO @FarmInventory
            SELECT 'Farm',
                   f.idfFarm,
                   f.idfFarmActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   'Farm ' + CONVERT(NVARCHAR, f.strFarmCode),
                   -- show in herd code as well, for the proper sorting on the UI grid display.
                   NULL,
                   NULL,
                   0,
                   (COALESCE(NULLIF(RTRIM(LTRIM(f.intLivestockTotalAnimalQty)), ''), 0)
                    + COALESCE(NULLIF(RTRIM(LTRIM(f.intAvianTotalAnimalQty)), ''), 0)
                   ) AS intTotalAnimalQty,
                   0,
                   NULL,
                   NULL,
                   NULL, 
                   f.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbFarm f
            WHERE f.idfMonitoringSession = @MonitoringSessionID
                  AND f.intRowStatus = 0
            UNION
            SELECT 'Farm',
                   f.idfFarm,
                   f.idfFarmActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   'Farm ' + CONVERT(NVARCHAR, f.strFarmCode),
                   -- show in herd code as well, for the proper sorting on the UI grid display.
                   NULL,
                   NULL,
                   0,
                   (COALESCE(NULLIF(RTRIM(LTRIM(f.intLivestockTotalAnimalQty)), ''), 0)
                    + COALESCE(NULLIF(RTRIM(LTRIM(f.intAvianTotalAnimalQty)), ''), 0)
                   ) AS intTotalAnimalQty,
                   0,
                   NULL,
                   NULL,
                   NULL, 
                   f.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbFarm f
                INNER JOIN dbo.tlbMonitoringSessionSummary AS mss
                    ON mss.idfFarm = f.idfFarm
                       AND mss.intRowStatus = 0
            WHERE mss.idfMonitoringSession = @MonitoringSessionID
                  AND f.intRowStatus = 0;

            INSERT INTO @FarmInventory
            SELECT 'Herd',
                   h.idfFarm,
                   f.idfFarmActual,
                   h.idfHerd,
                   h.idfHerdActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   'Herd ' + h.strHerdCode,
                   NULL,
                   NULL,
                   h.intSickAnimalQty,
                   h.intTotalAnimalQty,
                   h.intDeadAnimalQty,
                   NULL,
                   h.strNote,
                   NULL, 
                   h.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbHerd h
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = f.idfMonitoringSession
                       AND ms.intRowStatus = 0
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND h.intRowStatus = 0
            UNION
            SELECT 'Herd',
                   h.idfFarm,
                   f.idfFarmActual,
                   h.idfHerd,
                   h.idfHerdActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   'Herd ' + h.strHerdCode,
                   NULL,
                   NULL,
                   h.intSickAnimalQty,
                   h.intTotalAnimalQty,
                   h.intDeadAnimalQty,
                   NULL,
                   h.strNote,
                   NULL, 
                   h.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbHerd h
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                INNER JOIN dbo.tlbMonitoringSessionSummary mss
                    ON mss.idfFarm = f.idfFarm
                       AND mss.intRowStatus = 0
            WHERE mss.idfMonitoringSession = @MonitoringSessionID
                  AND h.intRowStatus = 0;

            INSERT INTO @FarmInventory
            SELECT 'Species',
                   h.idfFarm,
                   f.idfFarmActual,
                   s.idfHerd,
                   h.idfHerdActual,
                   s.idfSpecies,
                   s.idfSpeciesActual,
                   s.idfsSpeciesType,
                   speciesType.name AS SpeciesTypeName,
                   f.strFarmCode,
                   'Herd ' + h.strHerdCode,
                   s.datStartOfSignsDate,
                   s.strAverageAge,
                   s.intSickAnimalQty,
                   s.intTotalAnimalQty,
                   s.intDeadAnimalQty,
                   s.idfObservation,
                   s.strNote,
                   s.idfsOutbreakCaseStatus,
                   s.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbSpecies s
                INNER JOIN dbo.tlbHerd h
                    ON h.idfHerd = s.idfHerd
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                INNER JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = f.idfMonitoringSession
                       AND ms.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                    ON speciesType.idfsReference = s.idfsSpeciesType
            WHERE ms.idfMonitoringSession = @MonitoringSessionID
                  AND s.intRowStatus = 0
            UNION
            SELECT 'Species',
                   h.idfFarm,
                   f.idfFarmActual,
                   s.idfHerd,
                   h.idfHerdActual,
                   s.idfSpecies,
                   s.idfSpeciesActual,
                   s.idfsSpeciesType,
                   speciesType.name AS SpeciesTypeName,
                   f.strFarmCode,
                   'Herd ' + h.strHerdCode,
                   s.datStartOfSignsDate,
                   s.strAverageAge,
                   s.intSickAnimalQty,
                   s.intTotalAnimalQty,
                   s.intDeadAnimalQty,
                   s.idfObservation,
                   s.strNote,
                   s.idfsOutbreakCaseStatus, 
                   s.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbSpecies s
                INNER JOIN dbo.tlbHerd h
                    ON h.idfHerd = s.idfHerd
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                INNER JOIN dbo.tlbMonitoringSessionSummary mss
                    ON mss.idfFarm = f.idfFarm
                       AND mss.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                    ON speciesType.idfsReference = s.idfsSpeciesType
            WHERE mss.idfMonitoringSession = @MonitoringSessionID
                  AND s.intRowStatus = 0;
        END;

        IF NOT @FarmID IS NULL
        BEGIN
            INSERT INTO @FarmInventory
            SELECT 'Farm',
                   f.idfFarm,
                   f.idfFarmActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   f.strFarmCode,
                   -- show in herd code as well, for the proper sorting on the UI grid display.
                   NULL,
                   NULL,
                   (CASE
                        WHEN vc.idfsCaseType = '10012003' THEN
                            COALESCE(NULLIF(RTRIM(LTRIM(f.intLivestockSickAnimalQty)), ''), 0)
                        ELSE
                            COALESCE(NULLIF(RTRIM(LTRIM(f.intAvianSickAnimalQty)), ''), 0)
                    END
                   ) AS SickAnimalQty,
                   (CASE
                        WHEN vc.idfsCaseType = '10012003' THEN
                            COALESCE(NULLIF(RTRIM(LTRIM(f.intLivestockTotalAnimalQty)), ''), 0)
                        ELSE
                            COALESCE(NULLIF(RTRIM(LTRIM(f.intAvianTotalAnimalQty)), ''), 0)
                    END
                   ) AS TotalAnimalQty,
                   (CASE
                        WHEN vc.idfsCaseType = '10012003' THEN
                            COALESCE(NULLIF(RTRIM(LTRIM(f.intLivestockDeadAnimalQty)), ''), 0)
                        ELSE
                            COALESCE(NULLIF(RTRIM(LTRIM(f.intAvianDeadAnimalQty)), ''), 0)
                    END
                   ) AS DeadAnimalQty,
                   NULL,
                   NULL,
                   NULL, 
                   f.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbFarm f
                LEFT JOIN dbo.tlbVetCase AS vc
                    ON vc.idfFarm = f.idfFarm
                       AND vc.intRowStatus = 0
            WHERE f.idfFarm = @FarmID
                  AND f.intRowStatus = 0
                  AND (vc.idfVetCase = @DiseaseReportID OR @DiseaseReportID IS NULL);

            INSERT INTO @FarmInventory
            SELECT 'Herd',
                   h.idfFarm,
                   f.idfFarmActual,
                   h.idfHerd,
                   h.idfHerdActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   h.strHerdCode,
                   NULL,
                   NULL,
                   COALESCE(NULLIF(RTRIM(LTRIM(h.intSickAnimalQty)), ''), 0),
                   COALESCE(NULLIF(RTRIM(LTRIM(h.intTotalAnimalQty)), ''), 0),
                   COALESCE(NULLIF(RTRIM(LTRIM(h.intDeadAnimalQty)), ''), 0),
                   NULL,
                   h.strNote,
                   NULL, 
                   h.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbHerd h
                LEFT JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                LEFT JOIN dbo.tlbVetCase vc
                    ON vc.idfFarm = f.idfFarm
                       AND vc.intRowStatus = 0
            WHERE f.idfFarm = @FarmID
                  AND h.intRowStatus = 0
                  AND (vc.idfVetCase = @DiseaseReportID OR @DiseaseReportID IS NULL);

            INSERT INTO @FarmInventory
            SELECT 'Species',
                   h.idfFarm,
                   f.idfFarmActual,
                   s.idfHerd,
                   h.idfHerdActual,
                   s.idfSpecies,
                   s.idfSpeciesActual,
                   s.idfsSpeciesType,
                   speciesType.name AS SpeciesTypeName,
                   f.strFarmCode,
                   h.strHerdCode,
                   s.datStartOfSignsDate,
                   s.strAverageAge,
                   COALESCE(NULLIF(RTRIM(LTRIM(s.intSickAnimalQty)), ''), 0),
                   COALESCE(NULLIF(RTRIM(LTRIM(s.intTotalAnimalQty)), ''), 0),
                   COALESCE(NULLIF(RTRIM(LTRIM(s.intDeadAnimalQty)), ''), 0),
                   s.idfObservation,
                   s.strNote,
                   s.idfsOutbreakCaseStatus, 
                   s.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbSpecies s
                LEFT JOIN dbo.tlbHerd h
                    ON h.idfHerd = s.idfHerd
                       AND h.intRowStatus = 0
                LEFT JOIN dbo.tlbFarm f
                    ON f.idfFarm = h.idfFarm
                       AND f.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                    ON speciesType.idfsReference = s.idfsSpeciesType
            WHERE f.idfFarm = @FarmID
                  AND s.intRowStatus = 0;
        END
        ELSE IF NOT @FarmMasterID IS NULL
        BEGIN
            INSERT INTO @FarmInventory
            SELECT 'Farm',
                   NULL,
                   f.idfFarmActual,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   f.strFarmCode,
                   'Farm ' + f.strFarmCode,
                   -- show in herd code as well, for the proper sorting on the UI grid display.
                   NULL,
                   NULL,
                   0,
                   0,
                   0,
                   NULL,
                   NULL,
                   NULL, 
                   f.intRowStatus,
                   0 AS RowAction
            FROM dbo.tlbFarmActual f
            WHERE f.idfFarmActual = @FarmMasterID
                  AND f.intRowStatus = 0;
        END

        SELECT RecordID,
               RecordType,
               FarmID,
               FarmMasterID,
               FlockOrHerdID,
               FlockOrHerdMasterID,
               SpeciesID,
               SpeciesMasterID,
               SpeciesTypeID,
               SpeciesTypeName,
               EIDSSFarmID,
               EIDSSFlockOrHerdID,
               StartOfSignsDate,
               AverageAge,
               SickAnimalQuantity,
               TotalAnimalQuantity,
               DeadAnimalQuantity,
               ObservationID,
               Note,
               OutbreakCaseStatusTypeID, 
               RowStatus,
               RowAction,
               (
                   SELECT COUNT(*) FROM @FarmInventory
               ) AS TotalRowCount,
               1 AS CurrentPage,
               1 AS TotalPages
        FROM @FarmInventory
        ORDER BY FarmID,
                 FlockOrHerdID,
                 SpeciesID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
