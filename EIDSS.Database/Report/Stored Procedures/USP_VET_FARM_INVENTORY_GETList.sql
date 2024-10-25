
-- ================================================================================================
-- Name: Report.USP_VET_FARM_INVENTORY_GETList
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
-- Srini Goli		08/18/2022 Developed base on [dbo].[USP_VET_FARM_INVENTORY_GETList] for LiveStock Report to get Farm/Herd/Species details

-- ================================================================================================
CREATE PROCEDURE [Report].[USP_VET_FARM_INVENTORY_GETList]
(
    @LanguageID NVARCHAR(50),
    @DiseaseReportID BIGINT = NULL
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

	DECLARE  @MonitoringSessionID BIGINT = NULL,
			@FarmID BIGINT = NULL,
			@FarmMasterID BIGINT = NULL

    BEGIN TRY

	   --Get this from dbo.USP_VET_DISEASE_REPORT_GETDetail
	   SELECT @FarmID = vc.idfFarm --AS FarmID,
               ,@FarmMasterID = f.idfFarmActual --AS FarmMasterID,
               --f.strFarmCode --AS EIDSSFarmID,
               ,@MonitoringSessionID=  vc.idfParentMonitoringSession --AS ParentMonitoringSessionID,
               --ms.strMonitoringSessionID AS EIDSSParentMonitoringSessionID
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = vc.idfFarm
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = vc.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
        WHERE vc.idfVetCase = @DiseaseReportID

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