-- ================================================================================================
-- Name: USP_ADMIN_DEDUPLICATION_FARM_SET
--
-- Description:	Deduplication for farm record.
-- 
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		04/12/2022 Initial version
-- Ann Xiong		04/12/2022 Updated superseded disease reports with the Survivor Farm 
--                             information.
-- Mark Wilson		09/21/2022 Re-write to use FarmActual as source
-- Ann Xiong		09/30/2022 Updated superseded disease reports with the Survivor Farm Owner 
--                             information.
-- Stephen Long     03/14/2023 Added data audit logic for SAUC30 and 31.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEDUPLICATION_FARM_SET]
(
    @FarmMasterID BIGINT,
    @SupersededFarmMasterID BIGINT,
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
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @idfGeoLocationShared BIGINT = (
                                                   SELECT idfFarmAddress
                                                   FROM dbo.tlbFarmActual
                                                   WHERE idfFarmActual = @FarmMasterID
                                               ),
                                                                        -- Data audit
                @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                @DataAuditEventID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = 10016003,                -- Edit data audit event type
                @ObjectTypeID BIGINT = 10017076,                        -- Farm deduplication data audit object type
                @ObjectID BIGINT = NULL,
                @ObjectTableGeoLoationID BIGINT = 75580000000,          -- tlbGeolocation
                @ObjectTableGeoLocationSharedID BIGINT = 4572590000000, -- tlbGeolocationShared
                @ObjectTableFarmActualID BIGINT = 4572790000000,        -- tlbFarmActual
                @ObjectTableFarmID BIGINT = 75550000000,                -- tlbFarm
                @ObjectTableHumanID BIGINT = 75600000000,               -- tlbHuman
                @EIDSSObjectID NVARCHAR(200);
        -- End data audit
        DECLARE @Farm TABLE (idfFarm BIGINT);
        DECLARE @Location TABLE (idfGeoLocation BIGINT);
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
        DECLARE @GeoLocationBeforeEdit TABLE
        (
            GeoLocationID BIGINT,
            ResidentTypeID BIGINT,
            GroundTypeID BIGINT,
            GeoLocationTypeID BIGINT,
            LocationID BIGINT,
            PostalCode NVARCHAR(200),
            StreetName NVARCHAR(200),
            House NVARCHAR(200),
            Building NVARCHAR(200),
            Apartment NVARCHAR(200),
            AddressDescription NVARCHAR(200),
            Distance FLOAT,
            Latitude FLOAT,
            Longitude FLOAT,
            Accuracy FLOAT,
            Alignment FLOAT,
            ForeignAddressIndicator BIT,
            ForeignAddressString NVARCHAR(200),
            ShortAddressString NVARCHAR(2000)
        );
        DECLARE @GeoLocationAfterEdit TABLE
        (
            GeoLocationID BIGINT,
            ResidentTypeID BIGINT,
            GroundTypeID BIGINT,
            GeoLocationTypeID BIGINT,
            LocationID BIGINT,
            PostalCode NVARCHAR(200),
            StreetName NVARCHAR(200),
            House NVARCHAR(200),
            Building NVARCHAR(200),
            Apartment NVARCHAR(200),
            AddressDescription NVARCHAR(200),
            Distance FLOAT,
            Latitude FLOAT,
            Longitude FLOAT,
            Accuracy FLOAT,
            Alignment FLOAT,
            ForeignAddressIndicator BIT,
            ForeignAddressString NVARCHAR(200),
            ShortAddressString NVARCHAR(2000)
        );
        DECLARE @HumanBeforeEdit TABLE
        (
            HumanID BIGINT,
            HumanActualID BIGINT,
            OccupationTypeID BIGINT,
            NationalityTypeID BIGINT,
            GenderTypeID BIGINT,
            CurrentResidenceAddressID BIGINT,
            EmployerAddressID BIGINT,
            RegistrationAddressID BIGINT,
            DateOfBirth DATETIME,
            DateOfDeath DATETIME,
            LastName NVARCHAR(200),
            SecondName NVARCHAR(200),
            FirstName NVARCHAR(200),
            RegistrationPhone NVARCHAR(200),
            EmployerName NVARCHAR(200),
            HomePhone NVARCHAR(200),
            WorkPhone NVARCHAR(200),
            PersonIDType BIGINT,
            PersonID NVARCHAR(100),
            PermanentAddressAsCurrentIndicator BIT,
            EnteredDate DATETIME,
            ModificationDate DATETIME
        );
        DECLARE @HumanAfterEdit TABLE
        (
            HumanID BIGINT,
            HumanActualID BIGINT,
            OccupationTypeID BIGINT,
            NationalityTypeID BIGINT,
            GenderTypeID BIGINT,
            CurrentResidenceAddressID BIGINT,
            EmployerAddressID BIGINT,
            RegistrationAddressID BIGINT,
            DateOfBirth DATETIME,
            DateOfDeath DATETIME,
            LastName NVARCHAR(200),
            SecondName NVARCHAR(200),
            FirstName NVARCHAR(200),
            RegistrationPhone NVARCHAR(200),
            EmployerName NVARCHAR(200),
            HomePhone NVARCHAR(200),
            WorkPhone NVARCHAR(200),
            PersonIDType BIGINT,
            PersonID NVARCHAR(100),
            PermanentAddressAsCurrentIndicator BIT,
            EnteredDate DATETIME,
            ModificationDate DATETIME
        );

        SET @AuditUser = ISNULL(@AuditUser, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUser) userInfo;

        EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                  @AuditSiteID,
                                                  @DataAuditEventTypeID,
                                                  @ObjectTypeID,
                                                  @FarmMasterID,
                                                  @ObjectTableFarmActualID,
                                                  @EIDSSFarmID,
                                                  @DataAuditEventID OUTPUT;
        -- End data audit

        INSERT INTO @Farm
        (
            idfFarm
        )
        SELECT idfFarm
        FROM dbo.tlbFarm
        WHERE idfFarmActual = @FarmMasterID;

        INSERT INTO @Location
        (
            idfGeoLocation
        )
        SELECT idfFarmAddress
        FROM dbo.tlbFarm
        WHERE idfFarmActual = @SupersededFarmMasterID;

        --------------------------------------------------------------------------------------------------
        -- Update surviving farm address records
        --------------------------------------------------------------------------------------------------
        -- Farm master address update
        -- Data audit
        INSERT INTO @GeoLocationBeforeEdit
        (
            GeoLocationID,
            ResidentTypeID,
            GroundTypeID,
            GeoLocationTypeID,
            LocationID,
            PostalCode,
            StreetName,
            House,
            Building,
            Apartment,
            AddressDescription,
            Distance,
            Latitude,
            Longitude,
            Accuracy,
            Alignment,
            ForeignAddressIndicator,
            ForeignAddressString,
            ShortAddressString
        )
        SELECT idfGeoLocationShared,
               idfsResidentType,
               idfsGroundType,
               idfsGeoLocationType,
               idfsLocation,
               strPostCode,
               strStreetName,
               strHouse,
               strBuilding,
               strApartment,
               strDescription,
               dblDistance,
               dblLatitude,
               dblLongitude,
               dblAccuracy,
               dblAlignment,
               blnForeignAddress,
               strForeignAddress,
               strShortAddressString
        FROM dbo.tlbGeoLocationShared
        WHERE idfGeoLocationShared = @idfGeoLocationShared;
        -- End data audit

        UPDATE T
        SET T.idfsResidentType = S.idfsResidentType,
            T.idfsGroundType = S.idfsGroundType,
            T.idfsGeoLocationType = S.idfsGeoLocationType,
            T.idfsCountry = S.idfsCountry,
            T.idfsRegion = S.idfsRegion,
            T.idfsRayon = S.idfsRayon,
            T.idfsSettlement = S.idfsSettlement,
            T.idfsLocation = S.idfslocation,
            T.idfsSite = S.idfsSite,
            T.strPostCode = ISNULL(@FarmAddressPostalCode, S.strPostCode),
            T.strStreetName = ISNULL(@FarmAddressStreet, S.strStreetName),
            T.strHouse = ISNULL(@FarmAddressHouse, S.strHouse),
            T.strBuilding = ISNULL(@FarmAddressBuilding, S.strBuilding),
            T.strApartment = ISNULL(@FarmAddressApartment, S.strApartment),
            T.strDescription = S.strDescription,
            T.dblLongitude = ISNULL(@FarmAddressLongitude, S.dblLongitude),
            T.dblLatitude = ISNULL(@FarmAddressLatitude, S.dblLatitude),
            T.dblAccuracy = S.dblAccuracy,
            T.dblAlignment = S.dblAlignment,
            T.blnForeignAddress = ISNULL(@ForeignAddressIndicator, S.blnForeignAddress),
            T.strAddressString = S.strAddressString,
            T.strShortAddressString = S.strShortAddressString,
            T.AuditUpdateUser = @AuditUser,
            T.AuditUpdateDTM = GETDATE(),
            T.dblElevation = S.dblElevation
        FROM dbo.tlbGeoLocationShared T
            INNER JOIN dbo.tlbGeoLocationShared S
                ON S.idfGeoLocationShared = @idfGeoLocationShared
        WHERE T.idfGeoLocationShared = @idfGeoLocationShared;

        -- Data audit
        INSERT INTO @GeoLocationAfterEdit
        (
            GeoLocationID,
            ResidentTypeID,
            GroundTypeID,
            GeoLocationTypeID,
            LocationID,
            PostalCode,
            StreetName,
            House,
            Building,
            Apartment,
            AddressDescription,
            Distance,
            Latitude,
            Longitude,
            Accuracy,
            Alignment,
            ForeignAddressIndicator,
            ForeignAddressString,
            ShortAddressString
        )
        SELECT idfGeoLocationShared,
               idfsResidentType,
               idfsGroundType,
               idfsGeoLocationType,
               idfsLocation,
               strPostCode,
               strStreetName,
               strHouse,
               strBuilding,
               strApartment,
               strDescription,
               dblDistance,
               dblLatitude,
               dblLongitude,
               dblAccuracy,
               dblAlignment,
               blnForeignAddress,
               strForeignAddress,
               strShortAddressString
        FROM dbo.tlbGeoLocationShared
        WHERE idfGeoLocationShared = @idfGeoLocationShared;

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
               @ObjectTableGeoLocationSharedID,
               79200000000,
               a.GeoLocationID,
               NULL,
               b.ResidentTypeID,
               a.ResidentTypeID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ResidentTypeID <> b.ResidentTypeID)
              OR (
                     a.ResidentTypeID IS NOT NULL
                     AND b.ResidentTypeID IS NULL
                 )
              OR (
                     a.ResidentTypeID IS NULL
                     AND b.ResidentTypeID IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79170000000,
               a.GeoLocationID,
               NULL,
               b.GroundTypeID,
               a.GroundTypeID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.GroundTypeID <> b.GroundTypeID)
              OR (
                     a.GroundTypeID IS NOT NULL
                     AND b.GroundTypeID IS NULL
                 )
              OR (
                     a.GroundTypeID IS NULL
                     AND b.GroundTypeID IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79160000000,
               a.GeoLocationID,
               NULL,
               b.GeoLocationTypeID,
               a.GeoLocationTypeID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.GeoLocationTypeID <> b.GeoLocationTypeID)
              OR (
                     a.GeoLocationTypeID IS NOT NULL
                     AND b.GeoLocationTypeID IS NULL
                 )
              OR (
                     a.GeoLocationTypeID IS NULL
                     AND b.GeoLocationTypeID IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               51523700000000,
               a.GeoLocationID,
               NULL,
               b.LocationID,
               a.LocationID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.LocationID <> b.LocationID)
              OR (
                     a.LocationID IS NOT NULL
                     AND b.LocationID IS NULL
                 )
              OR (
                     a.LocationID IS NULL
                     AND b.LocationID IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79260000000,
               a.GeoLocationID,
               NULL,
               b.PostalCode,
               a.PostalCode,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.PostalCode <> b.PostalCode)
              OR (
                     a.PostalCode IS NOT NULL
                     AND b.PostalCode IS NULL
                 )
              OR (
                     a.PostalCode IS NULL
                     AND b.PostalCode IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79270000000,
               a.GeoLocationID,
               NULL,
               b.StreetName,
               a.StreetName,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.StreetName <> b.StreetName)
              OR (
                     a.StreetName IS NOT NULL
                     AND b.StreetName IS NULL
                 )
              OR (
                     a.StreetName IS NULL
                     AND b.StreetName IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79250000000,
               a.GeoLocationID,
               NULL,
               b.House,
               a.House,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.House <> b.House)
              OR (
                     a.House IS NOT NULL
                     AND b.House IS NULL
                 )
              OR (
                     a.House IS NULL
                     AND b.House IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79230000000,
               a.GeoLocationID,
               NULL,
               b.Building,
               a.Building,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Building <> b.Building)
              OR (
                     a.Building IS NOT NULL
                     AND b.Building IS NULL
                 )
              OR (
                     a.Building IS NULL
                     AND b.Building IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               4577890000000,
               a.GeoLocationID,
               NULL,
               b.Apartment,
               a.Apartment,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Apartment <> b.Apartment)
              OR (
                     a.Apartment IS NOT NULL
                     AND b.Apartment IS NULL
                 )
              OR (
                     a.Apartment IS NULL
                     AND b.Apartment IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79240000000,
               a.GeoLocationID,
               NULL,
               b.AddressDescription,
               a.AddressDescription,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.AddressDescription <> b.AddressDescription)
              OR (
                     a.AddressDescription IS NOT NULL
                     AND b.AddressDescription IS NULL
                 )
              OR (
                     a.AddressDescription IS NULL
                     AND b.AddressDescription IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79110000000,
               a.GeoLocationID,
               NULL,
               b.Distance,
               a.Distance,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Distance <> b.Distance)
              OR (
                     a.Distance IS NOT NULL
                     AND b.Distance IS NULL
                 )
              OR (
                     a.Distance IS NULL
                     AND b.Distance IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79120000000,
               a.GeoLocationID,
               NULL,
               b.Latitude,
               a.Latitude,
               @AuditUser
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
               @ObjectTableGeoLocationSharedID,
               79130000000,
               a.GeoLocationID,
               NULL,
               b.Longitude,
               a.Longitude,
               @AuditUser
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
               @ObjectTableGeoLocationSharedID,
               79090000000,
               a.GeoLocationID,
               NULL,
               b.Accuracy,
               a.Accuracy,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Accuracy <> b.Accuracy)
              OR (
                     a.Accuracy IS NOT NULL
                     AND b.Accuracy IS NULL
                 )
              OR (
                     a.Accuracy IS NULL
                     AND b.Accuracy IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               79100000000,
               a.GeoLocationID,
               NULL,
               b.Alignment,
               a.Alignment,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Alignment <> b.Alignment)
              OR (
                     a.Alignment IS NOT NULL
                     AND b.Alignment IS NULL
                 )
              OR (
                     a.Alignment IS NULL
                     AND b.Alignment IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               4578780000000,
               a.GeoLocationID,
               NULL,
               b.ForeignAddressIndicator,
               a.ForeignAddressIndicator,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ForeignAddressIndicator <> b.ForeignAddressIndicator)
              OR (
                     a.ForeignAddressIndicator IS NOT NULL
                     AND b.ForeignAddressIndicator IS NULL
                 )
              OR (
                     a.ForeignAddressIndicator IS NULL
                     AND b.ForeignAddressIndicator IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               4578790000000,
               a.GeoLocationID,
               NULL,
               b.ForeignAddressString,
               a.ForeignAddressString,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ForeignAddressString <> b.ForeignAddressString)
              OR (
                     a.ForeignAddressString IS NOT NULL
                     AND b.ForeignAddressString IS NULL
                 )
              OR (
                     a.ForeignAddressString IS NULL
                     AND b.ForeignAddressString IS NOT NULL
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
               @ObjectTableGeoLocationSharedID,
               51523680000000,
               a.GeoLocationID,
               NULL,
               b.ShortAddressString,
               a.ShortAddressString,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ShortAddressString <> b.ShortAddressString)
              OR (
                     a.ShortAddressString IS NOT NULL
                     AND b.ShortAddressString IS NULL
                 )
              OR (
                     a.ShortAddressString IS NULL
                     AND b.ShortAddressString IS NOT NULL
                 );
        -- End data audit

        -- Update farm master record

        -- Data audit
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
        -- End data audit

        UPDATE dbo.tlbFarmActual
        SET idfsAvianFarmType = ISNULL(@AvianFarmTypeID, idfsAvianFarmType),
            idfsAvianProductionType = ISNULL(@AvianProductionTypeID, idfsAvianProductionType),
            idfsFarmCategory = ISNULL(@FarmCategory, idfsFarmCategory),
            idfsOwnershipStructure = ISNULL(@OwnershipStructureTypeID, idfsOwnershipStructure),
            idfsMovementPattern = idfsMovementPattern,
            idfsIntendedUse = idfsIntendedUse,
            idfsGrazingPattern = idfsGrazingPattern,
            idfsLivestockProductionType = idfsLivestockProductionType,
            idfHumanActual = @FarmOwnerID,
            idfFarmAddress = @FarmAddressID,
            strInternationalName = strInternationalName,
            strNationalName = strNationalName,
            strFarmCode = strFarmCode,
            strFax = strFax,
            strEmail = strEmail,
            strContactPhone = strContactPhone,
            intBuidings = ISNULL(@NumberOfBuildings, intBuidings),
            intBirdsPerBuilding = ISNULL(@NumberOfBirdsPerBuilding, intBirdsPerBuilding),
            AuditUpdateUser = @AuditUser,
            AuditUpdateDTM = GETDATE()
        WHERE idfFarmActual = @FarmMasterID;

        -- Data audit
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
               @ObjectTableFarmActualID,
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
        -- End data audit

        -- Disable superseded farm master record
        UPDATE dbo.tlbFarmActual
        SET intRowStatus = 1,
            AuditUpdateUser = @AuditUser,
            AuditUpdateDTM = GETDATE()
        WHERE idfFarmActual = @SupersededFarmMasterID;

        -- Data audit
        INSERT INTO dbo.tauDataAuditDetailDelete
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    AuditCreateUser,
                    strObject
                )
                SELECT @DataAuditEventID,
                       @ObjectTableFarmActualID,
                       @SupersededFarmMasterID,
                       @AuditUser,
                       (SELECT strFarmCode FROM dbo.tlbFarmActual WHERE idfFarmActual = @SupersededFarmMasterID);
        -- End data audit

        --------------------------------------------------------------------------------------------------
        -- Update superseded farm address records
        --------------------------------------------------------------------------------------------------
        -- Data audit
        DELETE FROM @GeoLocationAfterEdit;
        DELETE FROM @GeoLocationBeforeEdit;

        INSERT INTO @GeoLocationBeforeEdit
        (
            GeoLocationID,
            ResidentTypeID,
            GroundTypeID,
            GeoLocationTypeID,
            LocationID,
            PostalCode,
            StreetName,
            House,
            Building,
            Apartment,
            AddressDescription,
            Distance,
            Latitude,
            Longitude,
            Accuracy,
            Alignment,
            ForeignAddressIndicator,
            ForeignAddressString,
            ShortAddressString
        )
        SELECT g.idfGeoLocation,
               g.idfsResidentType,
               g.idfsGroundType,
               g.idfsGeoLocationType,
               g.idfsLocation,
               g.strPostCode,
               g.strStreetName,
               g.strHouse,
               g.strBuilding,
               g.strApartment,
               g.strDescription,
               g.dblDistance,
               g.dblLatitude,
               g.dblLongitude,
               g.dblAccuracy,
               g.dblAlignment,
               g.blnForeignAddress,
               g.strForeignAddress,
               g.strShortAddressString
        FROM dbo.tlbGeoLocation g
        INNER JOIN dbo.tlbGeoLocationShared S
                ON S.idfGeoLocationShared = @idfGeoLocationShared
        WHERE g.idfGeoLocation IN (
                                      SELECT idfGeoLocation FROM @Location
                                  );
        -- End data audit

        UPDATE T
        SET T.idfsResidentType = S.idfsResidentType,
            T.idfsGroundType = S.idfsGroundType,
            T.idfsGeoLocationType = S.idfsGeoLocationType,
            T.idfsCountry = S.idfsCountry,
            T.idfsRegion = S.idfsRegion,
            T.idfsRayon = S.idfsRayon,
            T.idfsSettlement = S.idfsSettlement,
            T.idfsLocation = S.idfslocation,
            T.idfsSite = S.idfsSite,
            T.strPostCode = S.strPostCode,
            T.strStreetName = S.strStreetName,
            T.strHouse = S.strHouse,
            T.strBuilding = S.strBuilding,
            T.strApartment = S.strApartment,
            T.strDescription = S.strDescription,
            T.dblLongitude = S.dblLongitude,
            T.dblLatitude = S.dblLatitude,
            T.dblAccuracy = S.dblAccuracy,
            T.dblAlignment = S.dblAlignment,
            T.blnForeignAddress = S.blnForeignAddress,
            T.strAddressString = S.strAddressString,
            T.strShortAddressString = S.strShortAddressString,
            T.strMaintenanceFlag = S.strMaintenanceFlag,
            T.strReservedAttribute = S.strReservedAttribute,
            T.SourceSystemNameID = S.SourceSystemNameID,
            T.SourceSystemKeyValue = S.SourceSystemKeyValue,
            T.AuditCreateUser = S.AuditCreateUser,
            T.AuditCreateDTM = S.AuditCreateDTM,
            T.AuditUpdateUser = S.AuditUpdateUser,
            T.AuditUpdateDTM = S.AuditUpdateDTM,
            T.dblElevation = S.dblElevation
        FROM dbo.tlbGeoLocation T
            INNER JOIN dbo.tlbGeoLocationShared S
                ON S.idfGeoLocationShared = @idfGeoLocationShared
        WHERE T.idfGeoLocation IN (
                                      SELECT idfGeoLocation FROM @Location
                                  );

        -- Data audit
        INSERT INTO @GeoLocationAfterEdit
        (
            GeoLocationID,
            ResidentTypeID,
            GroundTypeID,
            GeoLocationTypeID,
            LocationID,
            PostalCode,
            StreetName,
            House,
            Building,
            Apartment,
            AddressDescription,
            Distance,
            Latitude,
            Longitude,
            Accuracy,
            Alignment,
            ForeignAddressIndicator,
            ForeignAddressString,
            ShortAddressString
        )
        SELECT g.idfGeoLocation,
               g.idfsResidentType,
               g.idfsGroundType,
               g.idfsGeoLocationType,
               g.idfsLocation,
               g.strPostCode,
               g.strStreetName,
               g.strHouse,
               g.strBuilding,
               g.strApartment,
               g.strDescription,
               g.dblDistance,
               g.dblLatitude,
               g.dblLongitude,
               g.dblAccuracy,
               g.dblAlignment,
               g.blnForeignAddress,
               g.strForeignAddress,
               g.strShortAddressString
        FROM dbo.tlbGeoLocation g
        INNER JOIN dbo.tlbGeoLocationShared S
                ON S.idfGeoLocationShared = @idfGeoLocationShared
        WHERE g.idfGeoLocation IN (
                                      SELECT idfGeoLocation FROM @Location
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
               @ObjectTableGeoLoationID,
               79200000000,
               a.GeoLocationID,
               NULL,
               b.ResidentTypeID,
               a.ResidentTypeID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ResidentTypeID <> b.ResidentTypeID)
              OR (
                     a.ResidentTypeID IS NOT NULL
                     AND b.ResidentTypeID IS NULL
                 )
              OR (
                     a.ResidentTypeID IS NULL
                     AND b.ResidentTypeID IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79170000000,
               a.GeoLocationID,
               NULL,
               b.GroundTypeID,
               a.GroundTypeID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.GroundTypeID <> b.GroundTypeID)
              OR (
                     a.GroundTypeID IS NOT NULL
                     AND b.GroundTypeID IS NULL
                 )
              OR (
                     a.GroundTypeID IS NULL
                     AND b.GroundTypeID IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79160000000,
               a.GeoLocationID,
               NULL,
               b.GeoLocationTypeID,
               a.GeoLocationTypeID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.GeoLocationTypeID <> b.GeoLocationTypeID)
              OR (
                     a.GeoLocationTypeID IS NOT NULL
                     AND b.GeoLocationTypeID IS NULL
                 )
              OR (
                     a.GeoLocationTypeID IS NULL
                     AND b.GeoLocationTypeID IS NOT NULL
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
               @ObjectTableGeoLoationID,
               51523700000000,
               a.GeoLocationID,
               NULL,
               b.LocationID,
               a.LocationID,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.LocationID <> b.LocationID)
              OR (
                     a.LocationID IS NOT NULL
                     AND b.LocationID IS NULL
                 )
              OR (
                     a.LocationID IS NULL
                     AND b.LocationID IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79260000000,
               a.GeoLocationID,
               NULL,
               b.PostalCode,
               a.PostalCode,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.PostalCode <> b.PostalCode)
              OR (
                     a.PostalCode IS NOT NULL
                     AND b.PostalCode IS NULL
                 )
              OR (
                     a.PostalCode IS NULL
                     AND b.PostalCode IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79270000000,
               a.GeoLocationID,
               NULL,
               b.StreetName,
               a.StreetName,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.StreetName <> b.StreetName)
              OR (
                     a.StreetName IS NOT NULL
                     AND b.StreetName IS NULL
                 )
              OR (
                     a.StreetName IS NULL
                     AND b.StreetName IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79250000000,
               a.GeoLocationID,
               NULL,
               b.House,
               a.House,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.House <> b.House)
              OR (
                     a.House IS NOT NULL
                     AND b.House IS NULL
                 )
              OR (
                     a.House IS NULL
                     AND b.House IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79230000000,
               a.GeoLocationID,
               NULL,
               b.Building,
               a.Building,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Building <> b.Building)
              OR (
                     a.Building IS NOT NULL
                     AND b.Building IS NULL
                 )
              OR (
                     a.Building IS NULL
                     AND b.Building IS NOT NULL
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
               @ObjectTableGeoLoationID,
               4577890000000,
               a.GeoLocationID,
               NULL,
               b.Apartment,
               a.Apartment,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Apartment <> b.Apartment)
              OR (
                     a.Apartment IS NOT NULL
                     AND b.Apartment IS NULL
                 )
              OR (
                     a.Apartment IS NULL
                     AND b.Apartment IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79240000000,
               a.GeoLocationID,
               NULL,
               b.AddressDescription,
               a.AddressDescription,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.AddressDescription <> b.AddressDescription)
              OR (
                     a.AddressDescription IS NOT NULL
                     AND b.AddressDescription IS NULL
                 )
              OR (
                     a.AddressDescription IS NULL
                     AND b.AddressDescription IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79110000000,
               a.GeoLocationID,
               NULL,
               b.Distance,
               a.Distance,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Distance <> b.Distance)
              OR (
                     a.Distance IS NOT NULL
                     AND b.Distance IS NULL
                 )
              OR (
                     a.Distance IS NULL
                     AND b.Distance IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79120000000,
               a.GeoLocationID,
               NULL,
               b.Latitude,
               a.Latitude,
               @AuditUser
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
               @ObjectTableGeoLoationID,
               79130000000,
               a.GeoLocationID,
               NULL,
               b.Longitude,
               a.Longitude,
               @AuditUser
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
               @ObjectTableGeoLoationID,
               79090000000,
               a.GeoLocationID,
               NULL,
               b.Accuracy,
               a.Accuracy,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Accuracy <> b.Accuracy)
              OR (
                     a.Accuracy IS NOT NULL
                     AND b.Accuracy IS NULL
                 )
              OR (
                     a.Accuracy IS NULL
                     AND b.Accuracy IS NOT NULL
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
               @ObjectTableGeoLoationID,
               79100000000,
               a.GeoLocationID,
               NULL,
               b.Alignment,
               a.Alignment,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.Alignment <> b.Alignment)
              OR (
                     a.Alignment IS NOT NULL
                     AND b.Alignment IS NULL
                 )
              OR (
                     a.Alignment IS NULL
                     AND b.Alignment IS NOT NULL
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
               @ObjectTableGeoLoationID,
               4578780000000,
               a.GeoLocationID,
               NULL,
               b.ForeignAddressIndicator,
               a.ForeignAddressIndicator,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ForeignAddressIndicator <> b.ForeignAddressIndicator)
              OR (
                     a.ForeignAddressIndicator IS NOT NULL
                     AND b.ForeignAddressIndicator IS NULL
                 )
              OR (
                     a.ForeignAddressIndicator IS NULL
                     AND b.ForeignAddressIndicator IS NOT NULL
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
               @ObjectTableGeoLoationID,
               4578790000000,
               a.GeoLocationID,
               NULL,
               b.ForeignAddressString,
               a.ForeignAddressString,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ForeignAddressString <> b.ForeignAddressString)
              OR (
                     a.ForeignAddressString IS NOT NULL
                     AND b.ForeignAddressString IS NULL
                 )
              OR (
                     a.ForeignAddressString IS NULL
                     AND b.ForeignAddressString IS NOT NULL
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
               @ObjectTableGeoLoationID,
               51523680000000,
               a.GeoLocationID,
               NULL,
               b.ShortAddressString,
               a.ShortAddressString,
               @AuditUser
        FROM @GeoLocationAfterEdit AS a
            FULL JOIN @GeoLocationBeforeEdit AS b
                ON a.GeoLocationID = b.GeoLocationID
        WHERE (a.ShortAddressString <> b.ShortAddressString)
              OR (
                     a.ShortAddressString IS NOT NULL
                     AND b.ShortAddressString IS NULL
                 )
              OR (
                     a.ShortAddressString IS NULL
                     AND b.ShortAddressString IS NOT NULL
                 );
        -- End data audit

        --------------------------------------------------------------------------------------------------
        -- Update superseded farm records
        --------------------------------------------------------------------------------------------------
        DELETE FROM @FarmAfterEdit;
        DELETE FROM @FarmBeforeEdit;

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
        SELECT f.idfFarmActual,
               f.idfsAvianFarmType,
               f.idfsAvianProductionType,
               f.idfsFarmCategory,
               f.idfsOwnershipStructure,
               f.idfsMovementPattern,
               f.idfsIntendedUse,
               f.idfsGrazingPattern,
               f.idfsLivestockProductionType,
               f.idfFarmAddress,
               f.strInternationalName,
               f.strNationalName,
               f.strFarmCode,
               f.strFax,
               f.strEmail,
               f.strContactPhone,
               f.intLivestockTotalAnimalQty,
               f.intAvianTotalAnimalQty,
               f.intLivestockSickAnimalQty,
               f.intAvianSickAnimalQty,
               f.intLivestockDeadAnimalQty,
               f.intAvianDeadAnimalQty,
               f.intBuidings,
               f.intBirdsPerBuilding,
               f.strNote,
               f.intHACode,
               f.datModificationDate
        FROM dbo.tlbFarm f
            INNER JOIN dbo.tlbFarmActual S
                ON S.idfFarmActual = @FarmMasterID
        WHERE f.idfFarmActual = @SupersededFarmMasterID;

        UPDATE T
        SET T.idfFarmActual = @FarmMasterID,
            T.idfsAvianFarmType = S.idfsAvianFarmType,
            T.idfsAvianProductionType = S.idfsAvianProductionType,
            T.idfsFarmCategory = S.idfsFarmCategory,
            T.idfsOwnershipStructure = S.idfsOwnershipStructure,
            T.idfsMovementPattern = S.idfsMovementPattern,
            T.idfsIntendedUse = S.idfsIntendedUse,
            T.idfsGrazingPattern = S.idfsGrazingPattern,
            T.idfsLivestockProductionType = S.idfsLivestockProductionType,
            T.strInternationalName = S.strInternationalName,
            T.strNationalName = S.strNationalName,
            T.strFarmCode = S.strFarmCode,
            T.strFax = S.strFax,
            T.strEmail = S.strEmail,
            T.strContactPhone = S.strContactPhone,
            T.intLivestockTotalAnimalQty = S.intLivestockTotalAnimalQty,
            T.intAvianTotalAnimalQty = S.intAvianTotalAnimalQty,
            T.intLivestockSickAnimalQty = S.intLivestockSickAnimalQty,
            T.intLivestockDeadAnimalQty = S.intLivestockDeadAnimalQty,
            T.intAvianDeadAnimalQty = S.intAvianDeadAnimalQty,
            T.intBuidings = S.intBuidings,
            T.intBirdsPerBuilding = S.intBirdsPerBuilding,
            T.strNote = S.strNote,
            T.intHACode = S.intHACode,
            T.datModificationDate = S.datModificationDate,
            T.datModificationForArchiveDate = GETDATE(),
            T.AuditUpdateUser = @AuditUser,
            T.AuditUpdateDTM = GETDATE()
        FROM dbo.tlbFarm T
            INNER JOIN dbo.tlbFarmActual S
                ON S.idfFarmActual = @FarmMasterID
        WHERE T.idfFarmActual = @SupersededFarmMasterID;

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
        SELECT f.idfFarmActual,
               f.idfsAvianFarmType,
               f.idfsAvianProductionType,
               f.idfsFarmCategory,
               f.idfsOwnershipStructure,
               f.idfsMovementPattern,
               f.idfsIntendedUse,
               f.idfsGrazingPattern,
               f.idfsLivestockProductionType,
               f.idfFarmAddress,
               f.strInternationalName,
               f.strNationalName,
               f.strFarmCode,
               f.strFax,
               f.strEmail,
               f.strContactPhone,
               f.intLivestockTotalAnimalQty,
               f.intAvianTotalAnimalQty,
               f.intLivestockSickAnimalQty,
               f.intAvianSickAnimalQty,
               f.intLivestockDeadAnimalQty,
               f.intAvianDeadAnimalQty,
               f.intBuidings,
               f.intBirdsPerBuilding,
               f.strNote,
               f.intHACode,
               f.datModificationDate
        FROM dbo.tlbFarm f
            INNER JOIN dbo.tlbFarmActual S
                ON S.idfFarmActual = @FarmMasterID
        WHERE f.idfFarmActual = @SupersededFarmMasterID;

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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
               @ObjectTableFarmID,
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
        -- End data audit

        --------------------------------------------------------------------------------------------------
        -- Update superseded human records
        --------------------------------------------------------------------------------------------------
        DECLARE @idfHumanActualSuperseded BIGINT = (
                                                       SELECT idfHumanActual
                                                       FROM dbo.tlbFarmActual
                                                       WHERE idfFarmActual = @SupersededFarmMasterID
                                                   );

        INSERT INTO @HumanBeforeEdit
        (
            HumanID,
            HumanActualID,
            OccupationTypeID,
            NationalityTypeID,
            GenderTypeID,
            CurrentResidenceAddressID,
            EmployerAddressID,
            RegistrationAddressID,
            DateOfBirth,
            DateOfDeath,
            LastName,
            SecondName,
            FirstName,
            RegistrationPhone,
            EmployerName,
            HomePhone,
            WorkPhone,
            PersonIDType,
            PersonID,
            PermanentAddressAsCurrentIndicator,
            EnteredDate,
            ModificationDate
        )
        SELECT h.idfHuman,
               h.idfHumanActual,
               h.idfsOccupationType,
               h.idfsNationality,
               h.idfsHumanGender,
               h.idfCurrentResidenceAddress,
               h.idfEmployerAddress,
               h.idfRegistrationAddress,
               h.datDateofBirth,
               h.datDateOfDeath,
               h.strLastName,
               h.strSecondName,
               h.strFirstName,
               h.strRegistrationPhone,
               h.strEmployerName,
               h.strHomePhone,
               h.strWorkPhone,
               h.idfsPersonIDType,
               h.strPersonID,
               h.blnPermantentAddressAsCurrent,
               h.datEnteredDate,
               h.datModificationDate
        FROM dbo.tlbHuman h
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = @FarmOwnerID
        WHERE h.idfHumanActual = @idfHumanActualSuperseded;

        UPDATE dbo.tlbHuman
        SET idfHumanActual = @FarmOwnerID,
            idfsOccupationType = ha.idfsOccupationType,
            idfsNationality = ha.idfsNationality,
            idfsHumanGender = ha.idfsHumanGender,
            datDateofBirth = ha.datDateofBirth,
            datDateOfDeath = ha.datDateOfDeath,
            strLastName = ha.strLastName,
            strSecondName = ha.strSecondName,
            strFirstName = ha.strFirstName,
            strRegistrationPhone = ha.strRegistrationPhone,
            strEmployerName = ha.strEmployerName,
            strHomePhone = ha.strHomePhone,
            strWorkPhone = ha.strWorkPhone,
            idfsPersonIDType = ha.idfsPersonIDType,
            strPersonID = ha.strPersonID,
            datModIFicationDate = ha.datModIFicationDate
        FROM dbo.tlbHuman h
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = @FarmOwnerID
        WHERE h.idfHumanActual = @idfHumanActualSuperseded;

        INSERT INTO @HumanAfterEdit
        (
            HumanID,
            HumanActualID,
            OccupationTypeID,
            NationalityTypeID,
            GenderTypeID,
            CurrentResidenceAddressID,
            EmployerAddressID,
            RegistrationAddressID,
            DateOfBirth,
            DateOfDeath,
            LastName,
            SecondName,
            FirstName,
            RegistrationPhone,
            EmployerName,
            HomePhone,
            WorkPhone,
            PersonIDType,
            PersonID,
            PermanentAddressAsCurrentIndicator,
            EnteredDate,
            ModificationDate
        )
        SELECT h.idfHuman,
               h.idfHumanActual,
               h.idfsOccupationType,
               h.idfsNationality,
               h.idfsHumanGender,
               h.idfCurrentResidenceAddress,
               h.idfEmployerAddress,
               h.idfRegistrationAddress,
               h.datDateofBirth,
               h.datDateOfDeath,
               h.strLastName,
               h.strSecondName,
               h.strFirstName,
               h.strRegistrationPhone,
               h.strEmployerName,
               h.strHomePhone,
               h.strWorkPhone,
               h.idfsPersonIDType,
               h.strPersonID,
               h.blnPermantentAddressAsCurrent,
               h.datEnteredDate,
               h.datModificationDate
        FROM dbo.tlbHuman h
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = @FarmOwnerID
        WHERE h.idfHumanActual = @idfHumanActualSuperseded;

        INSERT INTO dbo.tauDataAuditDetailUpdate
        (
            idfDataAuditEvent,
            idfObjectTable,
            idfColumn,
            idfObject,
            idfObjectDetail,
            strOldValue,
            strNewValue,
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               4572310000000,
               a.HumanID,
               NULL,
               b.HumanActualID,
               a.HumanActualID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79410000000,
               a.HumanID,
               NULL,
               b.OccupationTypeID,
               a.OccupationTypeID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.OccupationTypeID <> b.OccupationTypeID)
              OR (
                     a.OccupationTypeID IS NOT NULL
                     AND b.OccupationTypeID IS NULL
                 )
              OR (
                     a.OccupationTypeID IS NULL
                     AND b.OccupationTypeID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79400000000,
               a.HumanID,
               NULL,
               b.NationalityTypeID,
               a.NationalityTypeID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.NationalityTypeID <> b.NationalityTypeID)
              OR (
                     a.NationalityTypeID IS NOT NULL
                     AND b.NationalityTypeID IS NULL
                 )
              OR (
                     a.NationalityTypeID IS NULL
                     AND b.NationalityTypeID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79390000000,
               a.HumanID,
               NULL,
               b.GenderTypeID,
               a.GenderTypeID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.GenderTypeID <> b.GenderTypeID)
              OR (
                     a.GenderTypeID IS NOT NULL
                     AND b.GenderTypeID IS NULL
                 )
              OR (
                     a.GenderTypeID IS NULL
                     AND b.GenderTypeID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79350000000,
               a.HumanID,
               NULL,
               b.CurrentResidenceAddressID,
               a.CurrentResidenceAddressID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.CurrentResidenceAddressID <> b.CurrentResidenceAddressID)
              OR (
                     a.CurrentResidenceAddressID IS NOT NULL
                     AND b.CurrentResidenceAddressID IS NULL
                 )
              OR (
                     a.CurrentResidenceAddressID IS NULL
                     AND b.CurrentResidenceAddressID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79360000000,
               a.HumanID,
               NULL,
               b.EmployerAddressID,
               a.EmployerAddressID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.EmployerAddressID <> b.EmployerAddressID)
              OR (
                     a.EmployerAddressID IS NOT NULL
                     AND b.EmployerAddressID IS NULL
                 )
              OR (
                     a.EmployerAddressID IS NULL
                     AND b.EmployerAddressID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79380000000,
               a.HumanID,
               NULL,
               b.RegistrationAddressID,
               a.RegistrationAddressID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.RegistrationAddressID <> b.RegistrationAddressID)
              OR (
                     a.RegistrationAddressID IS NOT NULL
                     AND b.RegistrationAddressID IS NULL
                 )
              OR (
                     a.RegistrationAddressID IS NULL
                     AND b.RegistrationAddressID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79330000000,
               a.HumanID,
               NULL,
               b.DateOfBirth,
               a.DateOfBirth,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.DateOfBirth <> b.DateOfBirth)
              OR (
                     a.DateOfBirth IS NOT NULL
                     AND b.DateOfBirth IS NULL
                 )
              OR (
                     a.DateOfBirth IS NULL
                     AND b.DateOfBirth IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79340000000,
               a.HumanID,
               NULL,
               b.DateOfDeath,
               a.DateOfDeath,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.DateOfDeath <> b.DateOfDeath)
              OR (
                     a.DateOfDeath IS NOT NULL
                     AND b.DateOfDeath IS NULL
                 )
              OR (
                     a.DateOfDeath IS NULL
                     AND b.DateOfDeath IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79450000000,
               a.HumanID,
               NULL,
               b.LastName,
               a.LastName,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.LastName <> b.LastName)
              OR (
                     a.LastName IS NOT NULL
                     AND b.LastName IS NULL
                 )
              OR (
                     a.LastName IS NULL
                     AND b.LastName IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79470000000,
               a.HumanID,
               NULL,
               b.SecondName,
               a.SecondName,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.SecondName <> b.SecondName)
              OR (
                     a.SecondName IS NOT NULL
                     AND b.SecondName IS NULL
                 )
              OR (
                     a.SecondName IS NULL
                     AND b.SecondName IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79430000000,
               a.HumanID,
               NULL,
               b.FirstName,
               a.FirstName,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.FirstName <> b.FirstName)
              OR (
                     a.FirstName IS NOT NULL
                     AND b.FirstName IS NULL
                 )
              OR (
                     a.FirstName IS NULL
                     AND b.FirstName IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79460000000,
               a.HumanID,
               NULL,
               b.RegistrationPhone,
               a.RegistrationPhone,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.RegistrationPhone <> b.RegistrationPhone)
              OR (
                     a.RegistrationPhone IS NOT NULL
                     AND b.RegistrationPhone IS NULL
                 )
              OR (
                     a.RegistrationPhone IS NULL
                     AND b.RegistrationPhone IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79420000000,
               a.HumanID,
               NULL,
               b.EmployerName,
               a.EmployerName,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.EmployerName <> b.EmployerName)
              OR (
                     a.EmployerName IS NOT NULL
                     AND b.EmployerName IS NULL
                 )
              OR (
                     a.EmployerName IS NULL
                     AND b.EmployerName IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79440000000,
               a.HumanID,
               NULL,
               b.HomePhone,
               a.HomePhone,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.HomePhone <> b.HomePhone)
              OR (
                     a.HomePhone IS NOT NULL
                     AND b.HomePhone IS NULL
                 )
              OR (
                     a.HomePhone IS NULL
                     AND b.HomePhone IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               79480000000,
               a.HumanID,
               NULL,
               b.WorkPhone,
               a.WorkPhone,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.WorkPhone <> b.WorkPhone)
              OR (
                     a.WorkPhone IS NOT NULL
                     AND b.WorkPhone IS NULL
                 )
              OR (
                     a.WorkPhone IS NULL
                     AND b.WorkPhone IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               12014460000000,
               a.HumanID,
               NULL,
               b.PersonIDType,
               a.PersonIDType,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.PersonIDType <> b.PersonIDType)
              OR (
                     a.PersonIDType IS NOT NULL
                     AND b.PersonIDType IS NULL
                 )
              OR (
                     a.PersonIDType IS NULL
                     AND b.PersonIDType IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               12014470000000,
               a.HumanID,
               NULL,
               b.PersonID,
               a.PersonID,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.PersonID <> b.PersonID)
              OR (
                     a.PersonID IS NOT NULL
                     AND b.PersonID IS NULL
                 )
              OR (
                     a.PersonID IS NULL
                     AND b.PersonID IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               12675400000000,
               a.HumanID,
               NULL,
               b.PermanentAddressAsCurrentIndicator,
               a.PermanentAddressAsCurrentIndicator,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.PermanentAddressAsCurrentIndicator <> b.PermanentAddressAsCurrentIndicator)
              OR (
                     a.PermanentAddressAsCurrentIndicator IS NOT NULL
                     AND b.PermanentAddressAsCurrentIndicator IS NULL
                 )
              OR (
                     a.PermanentAddressAsCurrentIndicator IS NULL
                     AND b.PermanentAddressAsCurrentIndicator IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               51389530000000,
               a.HumanID,
               NULL,
               b.EnteredDate,
               a.EnteredDate,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.EnteredDate <> b.EnteredDate)
              OR (
                     a.EnteredDate IS NOT NULL
                     AND b.EnteredDate IS NULL
                 )
              OR (
                     a.EnteredDate IS NULL
                     AND b.EnteredDate IS NOT NULL
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
            AuditCreateDTM,
            AuditCreateUser
        )
        SELECT @DataAuditEventID,
               @ObjectTableHumanID,
               51389540000000,
               a.HumanID,
               NULL,
               b.ModificationDate,
               a.ModificationDate,
               GETDATE(),
               @AuditUser
        FROM @HumanAfterEdit AS a
            FULL JOIN @HumanBeforeEdit AS b
                ON a.HumanID = b.HumanID
        WHERE (a.ModificationDate <> b.ModificationDate)
              OR (
                     a.ModificationDate IS NOT NULL
                     AND b.ModificationDate IS NULL
                 )
              OR (
                     a.ModificationDate IS NULL
                     AND b.ModificationDate IS NOT NULL
                 );
        -- End data audit

        ----------------------------------------------------------------------------------------------------
        ---- replace Superseded farm ID with surviving Farm ID
        ----------------------------------------------------------------------------------------------------
        --		DECLARE	@idfFarmAddressSurvivor	BIGINT
        --		Select top 1 @idfFarmAddressSurvivor = idfFarmAddress
        --		FROM	dbo.tlbFarm
        --		WHERE	idfFarmActual = @FarmMasterID and intRowStatus = 0

        --		IF @idfFarmAddressSurvivor IS NULL
        --		BEGIN
        --			UPDATE	dbo.tlbFarm
        --			SET		idfFarmActual = @FarmMasterID,
        --					strFarmCode = @EIDSSFarmID,
        --					strNationalName = @FarmNationalName
        --			WHERE	idfFarmActual = @SupersededFarmMasterID
        --		END
        --		ELSE
        --		BEGIN
        --			UPDATE	dbo.tlbFarm
        --			SET		idfFarmActual = @FarmMasterID,
        --					strFarmCode = @EIDSSFarmID,
        --					strNationalName = @FarmNationalName,
        --					idfFarmAddress = @idfFarmAddressSurvivor
        --			WHERE	idfFarmActual = @SupersededFarmMasterID
        --		END;

        ----------------------------------------------------------------------------------------------------
        ---- soft delete the old Farm Master relate records
        ----------------------------------------------------------------------------------------------------
        --		EXEC dbo.USP_VET_FARM_MASTER_DEL 
        --			@FarmMasterID = @SupersededFarmMasterID,
        --			@DeduplicationIndicator = NULL -- bit

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