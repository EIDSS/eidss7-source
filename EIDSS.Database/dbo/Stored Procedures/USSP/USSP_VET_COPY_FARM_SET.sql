-- ================================================================================================
-- Name: USSP_VET_COPY_FARM_SET
--
-- Description:	Get farm actual detail and copies to the farm table.  This includes the associated 
-- child records for the farm address and the farm owner (human table).
--
-- This is typically called from the veterinary disease report set stored procedure.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/07/2022 Initial release with data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_VET_COPY_FARM_SET]
(
    @AuditUserName NVARCHAR(200),
    @DataAuditEventID BIGINT = NULL,
    @EIDSSObjectID NVARCHAR(200) = NULL,
    @FarmMasterID BIGINT,
    @AvianTotalAnimalQuantity INT = NULL,
    @AvianSickAnimalQuantity INT = NULL,
    @AvianDeadAnimalQuantity INT = NULL,
    @LivestockTotalAnimalQuantity INT = NULL,
    @LivestockSickAnimalQuantity INT = NULL,
    @LivestockDeadAnimalQuantity INT = NULL,
    @Latitude FLOAT = NULL,
    @Longitude FLOAT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @ObservationID BIGINT = NULL,
    @FarmOwnerID BIGINT = NULL,
    @FarmID BIGINT = NULL OUTPUT,
    @NewFarmOwnerID BIGINT = NULL OUTPUT
)
AS
DECLARE @FarmAddressID BIGINT,
        @RootFarmAddressID BIGINT,
        @HumanID BIGINT,
        @HumanMasterID BIGINT,
        @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'Vet Farm Copy Success',
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventTypeID BIGINT = NULL,
        @ObjectID BIGINT = @FarmMasterID,
        @ObjectTableID BIGINT = 75550000000,            -- tlbFarm
        @ObjectGeoLocationTableID BIGINT = 75580000000; -- tlbGeoLocation

DECLARE @FarmAfterEdit TABLE
(
    FarmID BIGINT,
    FarmActualID BIGINT,
    MonitoringSessionID BIGINT,
    AvianFarmTypeID BIGINT,
    AvianProductionTypeID BIGINT,
    FarmCategoryTypeID BIGINT,
    OwnershipStructureTypeID BIGINT,
    MovementPatternTypeID BIGINT,
    IntendedUseTypeID BIGINT,
    GrazingPatternTypeID BIGINT,
    LivestockProductionTypeID BIGINT,
    HumanActualID BIGINT,
    FarmAddressID BIGINT,
    InternationalName NVARCHAR(200),
    NationalName NVARCHAR(200),
    EIDSSFarmID NVARCHAR(200),
    Fax NVARCHAR(200),
    Email NVARCHAR(200),
    ContactPhone NVARCHAR(200),
    LivestockTotalAnimalQuantity INT,
    AvianTotalAnimalQuantity INT,
    LivestockSickAnimalQuantity INT,
    AvianSickAnimalQuantity INT,
    LivestockDeadAnimalQuantity INT,
    AvianDeadAnimalQuantity INT,
    BuidingsQuantity INT,
    BirdsPerBuildingQuantity INT,
    Note NVARCHAR(2000),
    AccessoryCode INT,
    ModificationDate DATETIME
);
DECLARE @FarmBeforeEdit TABLE
(
    FarmID BIGINT,
    FarmActualID BIGINT,
    MonitoringSessionID BIGINT,
    AvianFarmTypeID BIGINT,
    AvianProductionTypeID BIGINT,
    FarmCategoryTypeID BIGINT,
    OwnershipStructureTypeID BIGINT,
    MovementPatternTypeID BIGINT,
    IntendedUseTypeID BIGINT,
    GrazingPatternTypeID BIGINT,
    LivestockProductionTypeID BIGINT,
    HumanActualID BIGINT,
    FarmAddressID BIGINT,
    InternationalName NVARCHAR(200),
    NationalName NVARCHAR(200),
    EIDSSFarmID NVARCHAR(200),
    Fax NVARCHAR(200),
    Email NVARCHAR(200),
    ContactPhone NVARCHAR(200),
    LivestockTotalAnimalQuantity INT,
    AvianTotalAnimalQuantity INT,
    LivestockSickAnimalQuantity INT,
    AvianSickAnimalQuantity INT,
    LivestockDeadAnimalQuantity INT,
    AvianDeadAnimalQuantity INT,
    BuidingsQuantity INT,
    BirdsPerBuildingQuantity INT,
    Note NVARCHAR(2000),
    AccessoryCode INT,
    ModificationDate DATETIME
);
DECLARE @GeoLocationBeforeEdit TABLE
(
    GeoLocationID BIGINT,
    Latitude FLOAT,
    Longitude FLOAT
);
DECLARE @GeoLocationAfterEdit TABLE
(
    GeoLocationID BIGINT,
    Latitude FLOAT,
    Longitude FLOAT
);
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        SELECT @RootFarmAddressID = idfFarmAddress,
               @HumanMasterID = idfHumanActual
        FROM dbo.tlbFarmActual
        WHERE idfFarmActual = @FarmMasterID;

        IF NOT EXISTS (SELECT * FROM dbo.tlbFarm WHERE idfFarm = @FarmID)
        BEGIN
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbFarm',
                                              @idfsKey = @FarmID OUTPUT;

            SET @FarmOwnerID = NULL;
        END
        ELSE
        BEGIN
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
        END;

        -- Get new farm address identifier.
        SET @FarmAddressID = NULL;

        SELECT @FarmAddressID = idfFarmAddress
        FROM dbo.tlbFarm
        WHERE idfFarm = @FarmID;

        IF @FarmAddressID IS NULL
           AND @RootFarmAddressID IS NOT NULL
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbGeoLocation',
                                              @idfsKey = @FarmAddressID OUTPUT;

            -- Copy address from root farm.
            EXECUTE dbo.USSP_GBL_COPY_GEOLOCATION_SET @RootFarmAddressID,
                                                      @FarmAddressID,
                                                      0,
                                                      @DataAuditEventID,
                                                      @AuditUserName,
                                                      @ReturnCode,
                                                      @ReturnMessage;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy farm address.';

                SELECT @ReturnCode,
                       @ReturnMessage;

                RETURN;
            END
        END

        IF @FarmOwnerID IS NULL
           AND NOT @HumanMasterID IS NULL
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbHuman',
                                              @idfsKey = @NewFarmOwnerID OUTPUT;

            -- Copy root human actual to human snapshot for the farm owner.
            EXECUTE dbo.USSP_HUM_COPY_HUMAN_SET @HumanMasterID,
                                                @DataAuditEventID,
                                                @AuditUserName,
                                                @NewFarmOwnerID,
                                                @ReturnCode,
                                                @ReturnMessage;

            SET @FarmOwnerID = @NewFarmOwnerID;

            IF @ReturnCode <> 0
            BEGIN
                SET @ReturnMessage = 'Failed to copy human (farm owner).';

                SELECT @ReturnCode,
                       @ReturnMessage;

                RETURN;
            END
        END

        IF EXISTS (SELECT * FROM dbo.tlbFarm WHERE idfFarm = @FarmID)
        BEGIN
            INSERT INTO @FarmBeforeEdit
            (
                FarmID,
                FarmActualID,
                MonitoringSessionID,
                AvianFarmTypeID,
                AvianProductionTypeID,
                FarmCategoryTypeID,
                OwnershipStructureTypeID,
                MovementPatternTypeID,
                IntendedUseTypeID,
                GrazingPatternTypeID,
                LivestockProductionTypeID,
                HumanActualID,
                FarmAddressID,
                InternationalName,
                NationalName,
                EIDSSFarmID,
                Fax,
                Email,
                ContactPhone,
                LivestockTotalAnimalQuantity,
                AvianTotalAnimalQuantity,
                LivestockSickAnimalQuantity,
                AvianSickAnimalQuantity,
                LivestockDeadAnimalQuantity,
                AvianDeadAnimalQuantity,
                BuidingsQuantity,
                BirdsPerBuildingQuantity,
                Note,
                AccessoryCode,
                ModificationDate
            )
            SELECT idfFarm,
                   idfFarmActual,
                   idfMonitoringSession,
                   idfsAvianFarmType,
                   idfsAvianProductionType,
                   idfsFarmCategory,
                   idfsOwnershipStructure,
                   idfsMovementPattern,
                   idfsIntendedUse,
                   idfsGrazingPattern,
                   idfsLivestockProductionType,
                   idfHuman,
                   idfFarmAddress,
                   strInternationalName,
                   strNationalName,
                   strFarmCode,
                   strFax,
                   strEmail,
                   strContactPhone,
                   intLivestockTotalAnimalQty,
                   intAvianTotalAnimalQty,
                   intLivestockSickAnimalQty,
                   intAvianSickAnimalQty,
                   intLivestockDeadAnimalQty,
                   intAvianDeadAnimalQty,
                   intBuidings,
                   intBirdsPerBuilding,
                   strNote,
                   intHACode,
                   datModificationDate
            FROM dbo.tlbFarm
            WHERE idfFarm = @FarmID;

            UPDATE dbo.tlbFarm
            SET intLivestockTotalAnimalQty = @LivestockTotalAnimalQuantity,
                intAvianTotalAnimalQty = @AvianTotalAnimalQuantity,
                intLivestockSickAnimalQty = COALESCE(@LivestockSickAnimalQuantity, f.intLivestockSickAnimalQty),
                intAvianSickAnimalQty = COALESCE(@AvianSickAnimalQuantity, f.intAvianSickAnimalQty),
                intLivestockDeadAnimalQty = COALESCE(@LivestockDeadAnimalQuantity, f.intLivestockDeadAnimalQty),
                intAvianDeadAnimalQty = COALESCE(@AvianDeadAnimalQuantity, f.intAvianDeadAnimalQty),
                idfMonitoringSession = @MonitoringSessionID,
                idfObservation = @ObservationID,
                datModificationDate = GETDATE(),
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            FROM dbo.tlbFarm f
                INNER JOIN dbo.tlbFarmActual fa
                    ON fa.idfFarmActual = f.idfFarmActual
            WHERE f.idfFarm = @FarmID;

            INSERT INTO @FarmAfterEdit
            (
                FarmID,
                FarmActualID,
                MonitoringSessionID,
                AvianFarmTypeID,
                AvianProductionTypeID,
                FarmCategoryTypeID,
                OwnershipStructureTypeID,
                MovementPatternTypeID,
                IntendedUseTypeID,
                GrazingPatternTypeID,
                LivestockProductionTypeID,
                HumanActualID,
                FarmAddressID,
                InternationalName,
                NationalName,
                EIDSSFarmID,
                Fax,
                Email,
                ContactPhone,
                LivestockTotalAnimalQuantity,
                AvianTotalAnimalQuantity,
                LivestockSickAnimalQuantity,
                AvianSickAnimalQuantity,
                LivestockDeadAnimalQuantity,
                AvianDeadAnimalQuantity,
                BuidingsQuantity,
                BirdsPerBuildingQuantity,
                Note,
                AccessoryCode,
                ModificationDate
            )
            SELECT idfFarm,
                   idfFarmActual,
                   idfMonitoringSession,
                   idfsAvianFarmType,
                   idfsAvianProductionType,
                   idfsFarmCategory,
                   idfsOwnershipStructure,
                   idfsMovementPattern,
                   idfsIntendedUse,
                   idfsGrazingPattern,
                   idfsLivestockProductionType,
                   idfHuman,
                   idfFarmAddress,
                   strInternationalName,
                   strNationalName,
                   strFarmCode,
                   strFax,
                   strEmail,
                   strContactPhone,
                   intLivestockTotalAnimalQty,
                   intAvianTotalAnimalQty,
                   intLivestockSickAnimalQty,
                   intAvianSickAnimalQty,
                   intLivestockDeadAnimalQty,
                   intAvianDeadAnimalQty,
                   intBuidings,
                   intBirdsPerBuilding,
                   strNote,
                   intHACode,
                   datModificationDate
            FROM dbo.tlbFarm
            WHERE idfFarm = @FarmID;

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572170000000,
                   a.FarmID,
                   NULL,
                   b.FarmActualID,
                   a.FarmActualID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.FarmActualID <> b.FarmActualID)
                  OR (
                         a.FarmActualID IS NOT NULL
                         AND b.FarmActualID IS NULL
                     )
                  OR (
                         a.FarmActualID IS NULL
                         AND b.FarmActualID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572180000000,
                   a.FarmID,
                   NULL,
                   b.MonitoringSessionID,
                   a.MonitoringSessionID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.MonitoringSessionID <> b.MonitoringSessionID)
                  OR (
                         a.MonitoringSessionID IS NOT NULL
                         AND b.MonitoringSessionID IS NULL
                     )
                  OR (
                         a.MonitoringSessionID IS NULL
                         AND b.MonitoringSessionID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572810000000,
                   a.FarmID,
                   NULL,
                   b.AvianFarmTypeID,
                   a.AvianFarmTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.AvianFarmTypeID <> b.AvianFarmTypeID)
                  OR (
                         a.AvianFarmTypeID IS NOT NULL
                         AND b.AvianFarmTypeID IS NULL
                     )
                  OR (
                         a.AvianFarmTypeID IS NULL
                         AND b.AvianFarmTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572820000000,
                   a.FarmID,
                   NULL,
                   b.AvianProductionTypeID,
                   a.AvianProductionTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.AvianProductionTypeID <> b.AvianProductionTypeID)
                  OR (
                         a.AvianProductionTypeID IS NOT NULL
                         AND b.AvianProductionTypeID IS NULL
                     )
                  OR (
                         a.AvianProductionTypeID IS NULL
                         AND b.AvianProductionTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572830000000,
                   a.FarmID,
                   NULL,
                   b.FarmCategoryTypeID,
                   a.FarmCategoryTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.FarmCategoryTypeID <> b.FarmCategoryTypeID)
                  OR (
                         a.FarmCategoryTypeID IS NOT NULL
                         AND b.FarmCategoryTypeID IS NULL
                     )
                  OR (
                         a.FarmCategoryTypeID IS NULL
                         AND b.FarmCategoryTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572840000000,
                   a.FarmID,
                   NULL,
                   b.OwnershipStructureTypeID,
                   a.OwnershipStructureTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.OwnershipStructureTypeID <> b.OwnershipStructureTypeID)
                  OR (
                         a.OwnershipStructureTypeID IS NOT NULL
                         AND b.OwnershipStructureTypeID IS NULL
                     )
                  OR (
                         a.OwnershipStructureTypeID IS NULL
                         AND b.OwnershipStructureTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572850000000,
                   a.FarmID,
                   NULL,
                   b.MovementPatternTypeID,
                   a.MovementPatternTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.MovementPatternTypeID <> b.MovementPatternTypeID)
                  OR (
                         a.MovementPatternTypeID IS NOT NULL
                         AND b.MovementPatternTypeID IS NULL
                     )
                  OR (
                         a.MovementPatternTypeID IS NULL
                         AND b.MovementPatternTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572860000000,
                   a.FarmID,
                   NULL,
                   b.IntendedUseTypeID,
                   a.IntendedUseTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.IntendedUseTypeID <> b.IntendedUseTypeID)
                  OR (
                         a.IntendedUseTypeID IS NOT NULL
                         AND b.IntendedUseTypeID IS NULL
                     )
                  OR (
                         a.IntendedUseTypeID IS NULL
                         AND b.IntendedUseTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572870000000,
                   a.FarmID,
                   NULL,
                   b.GrazingPatternTypeID,
                   a.GrazingPatternTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.GrazingPatternTypeID <> b.GrazingPatternTypeID)
                  OR (
                         a.GrazingPatternTypeID IS NOT NULL
                         AND b.GrazingPatternTypeID IS NULL
                     )
                  OR (
                         a.GrazingPatternTypeID IS NULL
                         AND b.GrazingPatternTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572880000000,
                   a.FarmID,
                   NULL,
                   b.LivestockProductionTypeID,
                   a.LivestockProductionTypeID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.LivestockProductionTypeID <> b.LivestockProductionTypeID)
                  OR (
                         a.LivestockProductionTypeID IS NOT NULL
                         AND b.LivestockProductionTypeID IS NULL
                     )
                  OR (
                         a.LivestockProductionTypeID IS NULL
                         AND b.LivestockProductionTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572890000000,
                   a.FarmID,
                   NULL,
                   b.HumanActualID,
                   a.HumanActualID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.HumanActualID <> b.HumanActualID)
                  OR (
                         a.HumanActualID IS NOT NULL
                         AND b.HumanActualID IS NULL
                     )
                  OR (
                         a.HumanActualID IS NULL
                         AND b.HumanActualID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572900000000,
                   a.FarmID,
                   NULL,
                   b.FarmAddressID,
                   a.FarmAddressID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.FarmAddressID <> b.FarmAddressID)
                  OR (
                         a.FarmAddressID IS NOT NULL
                         AND b.FarmAddressID IS NULL
                     )
                  OR (
                         a.FarmAddressID IS NULL
                         AND b.FarmAddressID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572920000000,
                   a.FarmID,
                   NULL,
                   b.InternationalName,
                   a.InternationalName,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.InternationalName <> b.InternationalName)
                  OR (
                         a.InternationalName IS NOT NULL
                         AND b.InternationalName IS NULL
                     )
                  OR (
                         a.InternationalName IS NULL
                         AND b.InternationalName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572930000000,
                   a.FarmID,
                   NULL,
                   b.NationalName,
                   a.NationalName,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.NationalName <> b.NationalName)
                  OR (
                         a.NationalName IS NOT NULL
                         AND b.NationalName IS NULL
                     )
                  OR (
                         a.NationalName IS NULL
                         AND b.NationalName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572940000000,
                   a.FarmID,
                   NULL,
                   b.EIDSSFarmID,
                   a.EIDSSFarmID,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.EIDSSFarmID <> b.EIDSSFarmID)
                  OR (
                         a.EIDSSFarmID IS NOT NULL
                         AND b.EIDSSFarmID IS NULL
                     )
                  OR (
                         a.EIDSSFarmID IS NULL
                         AND b.EIDSSFarmID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572950000000,
                   a.FarmID,
                   NULL,
                   b.Fax,
                   a.Fax,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.Fax <> b.Fax)
                  OR (
                         a.Fax IS NOT NULL
                         AND b.Fax IS NULL
                     )
                  OR (
                         a.Fax IS NULL
                         AND b.Fax IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572960000000,
                   a.FarmID,
                   NULL,
                   b.Email,
                   a.Email,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.Email <> b.Email)
                  OR (
                         a.Email IS NOT NULL
                         AND b.Email IS NULL
                     )
                  OR (
                         a.Email IS NULL
                         AND b.Email IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4572970000000,
                   a.FarmID,
                   NULL,
                   b.ContactPhone,
                   a.ContactPhone,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.ContactPhone <> b.ContactPhone)
                  OR (
                         a.ContactPhone IS NOT NULL
                         AND b.ContactPhone IS NULL
                     )
                  OR (
                         a.ContactPhone IS NULL
                         AND b.ContactPhone IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573010000000,
                   a.FarmID,
                   NULL,
                   b.LivestockTotalAnimalQuantity,
                   a.LivestockTotalAnimalQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.LivestockTotalAnimalQuantity <> b.LivestockTotalAnimalQuantity)
                  OR (
                         a.LivestockTotalAnimalQuantity IS NOT NULL
                         AND b.LivestockTotalAnimalQuantity IS NULL
                     )
                  OR (
                         a.LivestockTotalAnimalQuantity IS NULL
                         AND b.LivestockTotalAnimalQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573020000000,
                   a.FarmID,
                   NULL,
                   b.AvianTotalAnimalQuantity,
                   a.AvianTotalAnimalQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.AvianTotalAnimalQuantity <> b.AvianTotalAnimalQuantity)
                  OR (
                         a.AvianTotalAnimalQuantity IS NOT NULL
                         AND b.AvianTotalAnimalQuantity IS NULL
                     )
                  OR (
                         a.AvianTotalAnimalQuantity IS NULL
                         AND b.AvianTotalAnimalQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573030000000,
                   a.FarmID,
                   NULL,
                   b.LivestockSickAnimalQuantity,
                   a.LivestockSickAnimalQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.LivestockSickAnimalQuantity <> b.LivestockSickAnimalQuantity)
                  OR (
                         a.LivestockSickAnimalQuantity IS NOT NULL
                         AND b.LivestockSickAnimalQuantity IS NULL
                     )
                  OR (
                         a.LivestockSickAnimalQuantity IS NULL
                         AND b.LivestockSickAnimalQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573040000000,
                   a.FarmID,
                   NULL,
                   b.AvianSickAnimalQuantity,
                   a.AvianSickAnimalQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.AvianSickAnimalQuantity <> b.AvianSickAnimalQuantity)
                  OR (
                         a.AvianSickAnimalQuantity IS NOT NULL
                         AND b.AvianSickAnimalQuantity IS NULL
                     )
                  OR (
                         a.AvianSickAnimalQuantity IS NULL
                         AND b.AvianSickAnimalQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573050000000,
                   a.FarmID,
                   NULL,
                   b.LivestockDeadAnimalQuantity,
                   a.LivestockDeadAnimalQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.LivestockDeadAnimalQuantity <> b.LivestockDeadAnimalQuantity)
                  OR (
                         a.LivestockDeadAnimalQuantity IS NOT NULL
                         AND b.LivestockDeadAnimalQuantity IS NULL
                     )
                  OR (
                         a.LivestockDeadAnimalQuantity IS NULL
                         AND b.LivestockDeadAnimalQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573060000000,
                   a.FarmID,
                   NULL,
                   b.AvianDeadAnimalQuantity,
                   a.AvianDeadAnimalQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.AvianDeadAnimalQuantity <> b.AvianDeadAnimalQuantity)
                  OR (
                         a.AvianDeadAnimalQuantity IS NOT NULL
                         AND b.AvianDeadAnimalQuantity IS NULL
                     )
                  OR (
                         a.AvianDeadAnimalQuantity IS NULL
                         AND b.AvianDeadAnimalQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573070000000,
                   a.FarmID,
                   NULL,
                   b.BuidingsQuantity,
                   a.BuidingsQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.BuidingsQuantity <> b.BuidingsQuantity)
                  OR (
                         a.BuidingsQuantity IS NOT NULL
                         AND b.BuidingsQuantity IS NULL
                     )
                  OR (
                         a.BuidingsQuantity IS NULL
                         AND b.BuidingsQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573080000000,
                   a.FarmID,
                   NULL,
                   b.BirdsPerBuildingQuantity,
                   a.BirdsPerBuildingQuantity,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.BirdsPerBuildingQuantity <> b.BirdsPerBuildingQuantity)
                  OR (
                         a.BirdsPerBuildingQuantity IS NOT NULL
                         AND b.BirdsPerBuildingQuantity IS NULL
                     )
                  OR (
                         a.BirdsPerBuildingQuantity IS NULL
                         AND b.BirdsPerBuildingQuantity IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4573090000000,
                   a.FarmID,
                   NULL,
                   b.Note,
                   a.Note,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.Note <> b.Note)
                  OR (
                         a.Note IS NOT NULL
                         AND b.Note IS NULL
                     )
                  OR (
                         a.Note IS NULL
                         AND b.Note IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51389490000000,
                   a.FarmID,
                   NULL,
                   b.AccessoryCode,
                   a.AccessoryCode,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.AccessoryCode <> b.AccessoryCode)
                  OR (
                         a.AccessoryCode IS NOT NULL
                         AND b.AccessoryCode IS NULL
                     )
                  OR (
                         a.AccessoryCode IS NULL
                         AND b.AccessoryCode IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51389500000000,
                   a.FarmID,
                   NULL,
                   b.ModificationDate,
                   a.ModificationDate,
                   @AuditUserName,
                   @EIDSSObjectID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmID = b.FarmID
            WHERE (a.ModificationDate <> b.ModificationDate)
                  OR (
                         a.ModificationDate IS NOT NULL
                         AND b.ModificationDate IS NULL
                     )
                  OR (
                         a.ModificationDate IS NULL
                         AND b.ModificationDate IS NOT NULL
                     );
        END
        ELSE
        BEGIN
            INSERT INTO dbo.tlbFarm
            (
                idfFarm,
                idfFarmActual,
                idfMonitoringSession,
                idfsFarmCategory,
                idfsOwnershipStructure,
                idfHuman,
                idfFarmAddress,
                strNationalName,
                strFarmCode,
                strFax,
                strEmail,
                strContactPhone,
                intLivestockTotalAnimalQty,
                intAvianTotalAnimalQty,
                intLivestockSickAnimalQty,
                intAvianSickAnimalQty,
                intLivestockDeadAnimalQty,
                intAvianDeadAnimalQty,
                strNote,
                rowguid,
                intRowStatus,
                intHACode,
                idfObservation,
                datModificationDate,
                strMaintenanceFlag,
                strReservedAttribute,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            SELECT @FarmID,
                   @FarmMasterID,
                   @MonitoringSessionID,
                   idfsFarmCategory,
                   idfsOwnershipStructure,
                   @FarmOwnerID,
                   @FarmAddressID,
                   strNationalName,
                   strFarmCode,
                   strFax,
                   strEmail,
                   strContactPhone,
                   @LivestockTotalAnimalQuantity,
                   @AvianTotalAnimalQuantity,
                   @LivestockSickAnimalQuantity,
                   @AvianSickAnimalQuantity,
                   @LivestockDeadAnimalQuantity,
                   @AvianDeadAnimalQuantity,
                   strNote,
                   NEWID(),
                   0,
                   NULL,
                   @ObservationID,
                   GETDATE(),
                   NULL,
                   NULL,
                   10519001,
                   '[{"idfFarm":' + CAST(@FarmID AS NVARCHAR(300)) + '}]',
                   @AuditUserName,
                   GETDATE(),
                   @AuditUserName,
                   GETDATE()
            FROM dbo.tlbFarmActual
            WHERE idfFarmActual = @FarmMasterID;

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @FarmID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );
        -- End data audit
        END;

        IF @FarmAddressID IS NOT NULL
        BEGIN
            -- Data audit
            INSERT INTO @GeoLocationBeforeEdit
            (
                GeoLocationID,
                Latitude,
                Longitude
            )
            SELECT idfGeoLocation,
                   dblLatitude,
                   dblLongitude
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @FarmAddressID;
            -- End data audit

            UPDATE dbo.tlbGeoLocation
            SET dblLatitude = @Latitude,
                dblLongitude = @Longitude,
                AuditUpdateUser = @AuditUserName
            WHERE idfGeoLocation = @FarmAddressID;

            -- Data audit
            INSERT INTO @GeoLocationAfterEdit
            (
                GeoLocationID,
                Latitude,
                Longitude
            )
            SELECT idfGeoLocation,
                   dblLatitude,
                   dblLongitude
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @FarmAddressID;

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectGeoLocationTableID,
                   79120000000,
                   a.GeoLocationID,
                   NULL,
                   b.Latitude,
                   a.Latitude,
                   @AuditUserName
            FROM @GeoLocationAfterEdit AS a
                FULL JOIN @GeoLocationBeforeEdit AS b
                    ON a.GeoLocationID = b.GeoLocationID
            WHERE (a.Latitude <> b.Latitude)
                  OR (
                         a.Latitude IS NOT NULL
                         AND b.Latitude IS NULL
                     )
                  OR (
                         a.Latitude IS NULL
                         AND b.Latitude IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser
            )
            SELECT @DataAuditEventID,
                   @ObjectGeoLocationTableID,
                   79130000000,
                   a.GeoLocationID,
                   NULL,
                   b.Longitude,
                   a.Longitude,
                   @AuditUserName
            FROM @GeoLocationAfterEdit AS a
                FULL JOIN @GeoLocationBeforeEdit AS b
                    ON a.GeoLocationID = b.GeoLocationID
            WHERE (a.Longitude <> b.Longitude)
                  OR (
                         a.Longitude IS NOT NULL
                         AND b.Longitude IS NULL
                     )
                  OR (
                         a.Longitude IS NULL
                         AND b.Longitude IS NOT NULL
                     );
        -- End data audit
        END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
