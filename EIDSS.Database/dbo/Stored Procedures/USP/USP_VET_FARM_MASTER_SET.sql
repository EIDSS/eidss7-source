-- ================================================================================================
-- Name: USP_VET_FARM_MASTER_SET
--
-- Description:	Inserts and updates farm records.
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/05/2019 Initial release.
-- Stephen Long     04/23/2019 Added suppress select on herd and species stored procedure calls.
-- Stephen Long     05/24/2019 Correction on flock/herds and species parameters.
-- Mark Wilson		10/06/2021 Added Elevation (NULL) to USP_GBL_ADDRESS_SET
-- Mark Wilson		10/19/2021 USSP_GBL_ADDRESS_SET, updated all USSP calls to pass user, removed 
--                             unnecessary fields
-- Mani             02/09/2022 Added @SupressSelect to suppress the return for USSP_GBL_ADDRESS_SET
-- Stephen Long     12/06/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long     03/09/2023 Changed data audit call to USSP_GBL_DATA_AUDIT_EVENT_SET.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VET_FARM_MASTER_SET]
(
    @FarmMasterID BIGINT,
    @AvianFarmTypeID BIGINT = NULL,
    @AvianProductionTypeID BIGINT = NULL,
    @FarmCategory BIGINT = NULL,
    @FarmOwnerID BIGINT = NULL,
    @FarmNationalName NVARCHAR(200) = NULL,
    @FarmInterNationalName NVARCHAR(200) = NULL,
    @EIDSSFarmID NVARCHAR(200) = NULL,
    @OwnershipStructureTypeID BIGINT = NULL,
    @Fax NVARCHAR(200) = NULL,
    @Email NVARCHAR(200) = NULL,
    @Phone NVARCHAR(200) = NULL,
    @FarmAddressID BIGINT = NULL,
    @ForeignAddressIndicator BIT = 0,
    @FarmAddressIdfsLocation BIGINT = NULL,
    @FarmAddressStreet NVARCHAR(200) = NULL,
    @FarmAddressApartment NVARCHAR(200) = NULL,
    @FarmAddressBuilding NVARCHAR(200) = NULL,
    @FarmAddressHouse NVARCHAR(200) = NULL,
    @FarmAddressPostalCode NVARCHAR(200) = NULL,
    @FarmAddressLatitude FLOAT = NULL,
    @FarmAddressLongitude FLOAT = NULL,
    @NumberOfBuildings INT = NULL,
    @NumberOfBirdsPerBuilding INT = NULL,
    @HerdsOrFlocks NVARCHAR(MAX) = NULL,
    @Species NVARCHAR(MAX) = NULL,
    @AuditUser NVARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                                                   -- Data audit
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @DataAuditEventID BIGINT = NULL,
            @DataAuditEventTypeID BIGINT = NULL,
            @ObjectTypeID BIGINT = 10017020,       -- Farm
            @ObjectID BIGINT = @FarmMasterID,
            @ObjectTableID BIGINT = 4572790000000; -- tlbFarmActual

    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );
    DECLARE @HerdMasterID BIGINT,
            @EIDSSHerdID NVARCHAR(200) = NULL,
            @SickAnimalQuantity INT = NULL,
            @TotalAnimalQuantity INT = NULL,
            @DeadAnimalQuantity INT = NULL,
            @Note NVARCHAR(2000) = NULL,
            @RowAction CHAR(1) = NULL,
            @RowID BIGINT = NULL,
            @RowStatus INT = NULL,
            ---------------
            @SpeciesMasterID BIGINT,
            @SpeciesTypeID BIGINT,
            @StartOfSignsDate DATETIME = NULL,
            @AverageAge NVARCHAR(200) = NULL,
            @ObservationID BIGINT = NULL;

    DECLARE @HerdOrFlockMasterTemp TABLE
    (
        HerdMasterID BIGINT NOT NULL,
        EIDSSHerdID NVARCHAR(200) NULL,
        FarmMasterID BIGINT NOT NULL,
        SickAnimalQuantity INT NULL,
        TotalAnimalQuantity INT NULL,
        DeadAnimalQuantity INT NULL,
        RowStatus INT NULL,
        RowAction CHAR(1) NULL
    );
    DECLARE @SpeciesMasterTemp TABLE
    (
        SpeciesMasterID BIGINT NOT NULL,
        HerdMasterID BIGINT NOT NULL,
        SpeciesTypeID BIGINT NOT NULL,
        SickAnimalQuantity INT NULL,
        TotalAnimalQuantity INT NULL,
        DeadAnimalQuantity INT NULL,
        StartOfSignsDate DATETIME NULL,
        AverageAge NVARCHAR(200) NULL,
        ObservationID BIGINT NULL,
        RowStatus INT NULL,
        RowAction CHAR(1) NULL
    );
    DECLARE @FarmAfterEdit TABLE
    (
        FarmActualID BIGINT,
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
        FarmActualID BIGINT,
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
    BEGIN TRY
        BEGIN TRANSACTION;

        SET @AuditUser = ISNULL(@AuditUser, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo;
        -- End data audit

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbFarmActual
            WHERE idfFarmActual = @FarmMasterID
                  AND intRowStatus = 0
        )
        BEGIN
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = N'tlbFarmActual',
                                              @idfsKey = @FarmMasterID OUTPUT;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Farm',
                                               @NextNumberValue = @EIDSSFarmID OUTPUT,
                                               @InstallationSite = NULL;

            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type
        END
        ELSE
        BEGIN
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
        END

        INSERT INTO @SuppressSelect
        EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                  @AuditSiteID,
                                                  @DataAuditEventTypeID,
                                                  @ObjectTypeID,
                                                  @FarmMasterID,
                                                  @ObjectTableID,
                                                  @EIDSSFarmID, 
                                                  @DataAuditEventID OUTPUT;
        -- End data audit

        -- Set farm address 
        IF @FarmAddressIdfsLocation IS NOT NULL
            INSERT INTO @SuppressSelect
            EXEC dbo.USSP_GBL_ADDRESS_SET_WITH_AUDITING @FarmAddressID OUTPUT,
                                                        @DataAuditEventID,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        @FarmAddressIdfsLocation,
                                                        @FarmAddressApartment,
                                                        @FarmAddressBuilding,
                                                        @FarmAddressStreet,
                                                        @FarmAddressHouse,
                                                        @FarmAddressPostalCode,
                                                        NULL,
                                                        NULL,
                                                        @FarmAddressLatitude,
                                                        @FarmAddressLongitude,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        @ForeignAddressIndicator,
                                                        NULL,
                                                        1,
                                                        @AuditUser;

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbFarmActual
            WHERE idfFarmActual = @FarmMasterID
                  AND intRowStatus = 0
        )
        BEGIN
            INSERT INTO dbo.tlbFarmActual
            (
                idfFarmActual,
                idfsAvianFarmType,
                idfsAvianProductionType,
                idfsFarmCategory,
                idfsOwnershipStructure,
                idfsMovementPattern,
                idfsIntendedUse,
                idfsGrazingPattern,
                idfsLivestockProductionType,
                idfHumanActual,
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
                rowguid,
                intRowStatus,
                intHACode,
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
            VALUES
            (@FarmMasterID,
             @AvianFarmTypeID,
             @AvianProductionTypeID,
             @FarmCategory,
             @OwnershipStructureTypeID,
             NULL,
             NULL,
             NULL,
             NULL,
             @FarmOwnerID,
             @FarmAddressID,
             @FarmInterNationalName,
             @FarmNationalName,
             @EIDSSFarmID,
             @Fax,
             @Email,
             @Phone,
             0  ,
             0  ,
             0  ,
             0  ,
             0  ,
             0  ,
             @NumberOfBuildings,
             @NumberOfBirdsPerBuilding,
             NULL,
             NEWID(),
             0  ,
             NULL,
             GETDATE(),
             NULL,
             NULL,
             10519001,
             '[{"idfFarmActual":' + CAST(@FarmMasterID AS NVARCHAR(300)) + '}]',
             @AuditUser,
             GETDATE(),
             @AuditUser,
             GETDATE()
            );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @FarmMasterID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUser,
             @EIDSSFarmID
            );
        -- End data audit
        END
        ELSE
        BEGIN
            IF @EIDSSFarmID IS NULL
               OR @EIDSSFarmID = ''
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NextNumber_GET @ObjectName = N'Farm',
                                                   @NextNumberValue = @EIDSSFarmID OUTPUT,
                                                   @InstallationSite = NULL;
            END;

            INSERT INTO @FarmBeforeEdit
            (
                FarmActualID,
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
            SELECT idfFarmActual,
                   idfsAvianFarmType,
                   idfsAvianProductionType,
                   idfsFarmCategory,
                   idfsOwnershipStructure,
                   idfsMovementPattern,
                   idfsIntendedUse,
                   idfsGrazingPattern,
                   idfsLivestockProductionType,
                   idfHumanActual,
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
            FROM dbo.tlbFarmActual
            WHERE idfFarmActual = @FarmMasterID;

            UPDATE dbo.tlbFarmActual
            SET idfsAvianFarmType = @AvianFarmTypeID,
                idfsAvianProductionType = @AvianProductionTypeID,
                idfsFarmCategory = @FarmCategory,
                idfHumanActual = @FarmOwnerID,
                idfFarmAddress = @FarmAddressID,
                strNationalName = @FarmNationalName,
                strInternationalName = @FarmInterNationalName,
                strFarmCode = @EIDSSFarmID,
                idfsOwnershipStructure = @OwnershipStructureTypeID,
                strFax = @Fax,
                strEmail = @Email,
                strContactPhone = @Phone,
                datModificationDate = GETDATE(),
                intBuidings = @NumberOfBuildings,
                intBirdsPerBuilding = @NumberOfBirdsPerBuilding,
                AuditUpdateUser = @AuditUser,
                AuditUpdateDTM = GETDATE()
            WHERE idfFarmActual = @FarmMasterID;

            INSERT INTO @FarmAfterEdit
            (
                FarmActualID,
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
            SELECT idfFarmActual,
                   idfsAvianFarmType,
                   idfsAvianProductionType,
                   idfsFarmCategory,
                   idfsOwnershipStructure,
                   idfsMovementPattern,
                   idfsIntendedUse,
                   idfsGrazingPattern,
                   idfsLivestockProductionType,
                   idfHumanActual,
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
            FROM dbo.tlbFarmActual
            WHERE idfFarmActual = @FarmMasterID;

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
                   a.FarmActualID,
                   NULL,
                   b.AvianFarmTypeID,
                   a.AvianFarmTypeID, 
                   @AuditUser, 
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.AvianProductionTypeID,
                   a.AvianProductionTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.FarmCategoryTypeID,
                   a.FarmCategoryTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.OwnershipStructureTypeID,
                   a.OwnershipStructureTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.MovementPatternTypeID,
                   a.MovementPatternTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.IntendedUseTypeID,
                   a.IntendedUseTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.GrazingPatternTypeID,
                   a.GrazingPatternTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.LivestockProductionTypeID,
                   a.LivestockProductionTypeID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.HumanActualID,
                   a.HumanActualID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.FarmAddressID,
                   a.FarmAddressID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.InternationalName,
                   a.InternationalName,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.NationalName,
                   a.NationalName,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.EIDSSFarmID,
                   a.EIDSSFarmID,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.Fax,
                   a.Fax,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.Email,
                   a.Email,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.ContactPhone,
                   a.ContactPhone,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.LivestockTotalAnimalQuantity,
                   a.LivestockTotalAnimalQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.AvianTotalAnimalQuantity,
                   a.AvianTotalAnimalQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.LivestockSickAnimalQuantity,
                   a.LivestockSickAnimalQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.AvianSickAnimalQuantity,
                   a.AvianSickAnimalQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.LivestockDeadAnimalQuantity,
                   a.LivestockDeadAnimalQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.AvianDeadAnimalQuantity,
                   a.AvianDeadAnimalQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.BuidingsQuantity,
                   a.BuidingsQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.BirdsPerBuildingQuantity,
                   a.BirdsPerBuildingQuantity,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.Note,
                   a.Note,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.AccessoryCode,
                   a.AccessoryCode,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
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
                   a.FarmActualID,
                   NULL,
                   b.ModificationDate,
                   a.ModificationDate,
                   @AuditUser,
                   @EIDSSFarmID
            FROM @FarmAfterEdit AS a
                FULL JOIN @FarmBeforeEdit AS b
                    ON a.FarmActualID = b.FarmActualID
            WHERE (a.ModificationDate <> b.ModificationDate)
                  OR (
                         a.ModificationDate IS NOT NULL
                         AND b.ModificationDate IS NULL
                     )
                  OR (
                         a.ModificationDate IS NULL
                         AND b.ModificationDate IS NOT NULL
                     );
        END;

        INSERT INTO @HerdOrFlockMasterTemp
        SELECT *
        FROM
            OPENJSON(@HerdsOrFlocks)
            WITH
            (
                HerdMasterID BIGINT,
                EIDSSHerdID NVARCHAR(200),
                FarmMasterID BIGINT,
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                RowStatus INT,
                RowAction CHAR
            );

        INSERT INTO @SpeciesMasterTemp
        SELECT *
        FROM
            OPENJSON(@Species)
            WITH
            (
                SpeciesMasterID BIGINT,
                HerdMasterID BIGINT,
                SpeciesTypeID BIGINT,
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                StartOfSignsDate DATETIME,
                AverageAge NVARCHAR(200),
                ObservationID BIGINT,
                RowStatus INT,
                RowAction CHAR
            );

        ----  Process the herd
        WHILE EXISTS (SELECT * FROM @HerdOrFlockMasterTemp)
        BEGIN
            SELECT TOP 1
                @RowID = HerdMasterID,
                @HerdMasterID = HerdMasterID,
                @EIDSSHerdID = EIDSSHerdID,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @HerdOrFlockMasterTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_HERD_MASTER_SET @AuditUser = @AuditUser,
                                                 @HerdMasterID = @HerdMasterID OUTPUT,
                                                 @FarmMasterID = @FarmMasterID,
                                                 @EIDSSHerdID = @EIDSSHerdID OUTPUT,
                                                 @SickAnimalQuantity = @SickAnimalQuantity,
                                                 @TotalAnimalQuantity = @TotalAnimalQuantity,
                                                 @DeadAnimalQuantity = @DeadAnimalQuantity,
                                                 @Note = NULL,
                                                 @Rowstatus = @RowStatus,
                                                 @RowAction = @RowAction;

            IF @RowAction = 'I'
            BEGIN
                UPDATE @SpeciesMasterTemp
                SET HerdMasterID = @HerdMasterID
                WHERE HerdMasterID = @RowID;
            END

            DELETE FROM @HerdOrFlockMasterTemp
            WHERE HerdMasterID = @RowID;
        END;

        ----  Process the Species
        WHILE EXISTS (SELECT * FROM @SpeciesMasterTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SpeciesMasterID,
                @SpeciesMasterID = SpeciesMasterID,
                @SpeciesTypeID = SpeciesTypeID,
                @StartOfSignsDate = StartOfSignsDate,
                @AverageAge = AverageAge,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @ObservationID = ObservationID,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @SpeciesMasterTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_SPECIES_MASTER_SET @AuditUser = @AuditUser,
                                                    @SpeciesMasterID = @SpeciesMasterID OUTPUT,
                                                    @SpeciesTypeID = @SpeciesTypeID,
                                                    @HerdMasterID = @HerdMasterID,
                                                    @StartOfSignsDate = @StartOfSignsDate,
                                                    @AverageAge = @AverageAge,
                                                    @SickAnimalQuantity = @SickAnimalQuantity,
                                                    @TotalAnimalQuantity = @TotalAnimalQuantity,
                                                    @DeadAnimalQuantity = @DeadAnimalQuantity,
                                                    @Note = NULL,
                                                    @RowStatus = @RowStatus,
                                                    @RowAction = @RowAction;

            DELETE FROM @SpeciesMasterTemp
            WHERE SpeciesMasterID = @RowID;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @FarmMasterID SessionKey,
               @EIDSSFarmID SessionID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
