-- ================================================================================================
-- Name: USSP_GBL_ADDRESS_SET_WITH_AUDITING
--
-- Description: Inserts or updates an address record as described in use case SYSUC07.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name	           Date        Change Detail
-- --------------- ----------- -------------------------------------------------------------------
-- Stephen Long		04/21/2019 Fixed the check for location shared versus location on the 
--                             update portion.
-- Stephen Long		12/26/2019 Added dbo prefix to function calls and replaced with v7 calls.
-- Stephen Long		06/04/2020 Added postal code set call and transaction logic.
-- Stephen Long		06/16/2021 Replaced country, region, rayon and settlement ID's with location 
--                             ID to support location hierarchy.
-- Stephen Long		08/05/2021 Added audit user name.
-- Mark Wilson		09/13/2021 Added additional fields to tlbGeolocation and tlbGeoLocationShared
-- Mark Wilson		09/22/2021 Standardized and updated calls to USSPs
-- Mark Wilson		10/06/2021 Added Elevation.
-- Mark Wilson		10/18/2021 Added back write of Country, Region, Rayon, Settlement.
-- Mark Wilson		10/19/2021 Changed to USSP.
-- Steven Verner	07/06/2022 Updated location select statement to select from flattened location 
--                             hierarchy table.
-- Leo Tracchia		11/28/2022 Added statements for Audit logging - this is a copy of 
--                             USSP_GBL_ADDRESS_SET with auditing logic added .
-- Stephen Long     03/14/2023 Added geo-location data audit event.

-- Testing code:
/*

DECLARE	@return_value int,
		@ReturnCode int,
		@ReturnMessage nvarchar(max)

EXEC	@return_value = [dbo].[USSP_GBL_ADDRESS_SET_WITH_AUDITING]
		@LanguageID = 'en=US',
		@GeolocationID = NULL,
		@LocationID = 1347970000000,
		@Apartment = N'Bunny Apts',
		@Building = N'48',
		@StreetName = N'Broad Street',
		@PostalCodeString = N'30511',
		@Distance = 122.2,
		@Latitude = 125,
		@Longitude = 44,
		@Elevation = 1022,
		@ForeignAddressIndicator = 0,
		@GeolocationSharedIndicator = 0,
		@AuditUserName = N'Roscoe',
		@ReturnCode = @ReturnCode OUTPUT,
		@ReturnMessage = @ReturnMessage OUTPUT

SELECT	@GeolocationID as N'@GeolocationID',
		@ReturnCode as N'@ReturnCode',
		@ReturnMessage as N'@ReturnMessage'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_ADDRESS_SET_WITH_AUDITING]
(
    @GeolocationID BIGINT = NULL OUTPUT,
    @DataAuditEventID BIGINT = NULL,
    @ResidentTypeID BIGINT = NULL,
    @GroundTypeID BIGINT = NULL,
    @GeolocationTypeID BIGINT = 10036001,
    @LocationID BIGINT,
    @Apartment NVARCHAR(200) = NULL,
    @Building NVARCHAR(200) = NULL,
    @StreetName NVARCHAR(200) = NULL,
    @House NVARCHAR(200) = NULL,
    @PostalCodeString NVARCHAR(200) = NULL,
    @DescriptionString NVARCHAR(200) = NULL,
    @Distance FLOAT = NULL,
    @Latitude FLOAT = NULL,
    @Longitude FLOAT = NULL,
    @Elevation FLOAT = NULL,
    @Accuracy FLOAT = NULL,
    @Alignment FLOAT = NULL,
    @ForeignAddressIndicator BIT = 0,
    @ForeignAddressString NVARCHAR(200) = NULL,
    @GeolocationSharedIndicator BIT = 0,
    @AuditUserName NVARCHAR(200) = '',
    @ReturnCode INT = 0 OUTPUT,
    @ReturnMessage NVARCHAR(MAX) = 'SUCCESS' OUTPUT
)
AS
DECLARE @PostalCodeID BIGINT,
        @StreetID BIGINT,
        @AdminLevel INT = NULL,
        @LocationNode HIERARCHYID = NULL,
                                                                --Data Audit--
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @idfsDataAuditEventType BIGINT = NULL,
        @idfObject BIGINT = @GeolocationID,
        @ObjectGeoLocationSharedTableID BIGINT = 4572590000000, -- tlbGeoLocationShared
        @ObjectGeoLocationTableID BIGINT = 75580000000,         -- tlbGeoLocation
        @idfDataAuditEvent BIGINT = NULL,
        @DataAuditEventGeoLocationID BIGINT = NULL;
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
-- End data audit

SELECT @LocationNode = node
FROM dbo.gisLocation
WHERE idfsLocation = @LocationID;

BEGIN
    BEGIN TRY
        IF @AuditUserName = ''
            SET @AuditUserName = SUSER_NAME();

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        SET @ReturnCode = 0;
        SET @ReturnMessage = 'SUCCESS';

        BEGIN TRANSACTION;

        IF @ForeignAddressIndicator = 0
        BEGIN
            -- Determine if the location ID passed in is at the settlement level.
            SELECT @AdminLevel = node.GetLevel()
            FROM dbo.gisLocation
            WHERE idfsLocation = @LocationID;

            DECLARE @idfsAdminLevel1 BIGINT, -- country
                    @idfsAdminLevel2 BIGINT, -- region
                    @idfsAdminLevel3 BIGINT, -- rayon
                    @idfsAdminLevel4 BIGINT  -- settlement

            SELECT @idfsAdminLevel1 = fglhf.AdminLevel1ID,
                   @idfsAdminLevel2 = fglhf.AdminLevel2ID,
                   @idfsAdminLevel3 = fglhf.AdminLevel3ID,
                   @idfsAdminLevel4 = adminlevel4ID
            FROM dbo.FN_GBL_LocationHierarchy_Flattened('en-US') fglhf
            WHERE fglhf.idfsLocation = @LocationID;

            -- If it is a settlement level, then determine if the street name and/or postal code 
            -- needs to be added to the appropriate tables for inclusion in the street or postal 
            -- code drop downs.
            IF @AdminLevel = 4
            BEGIN
                IF @StreetName IS NOT NULL
                BEGIN
                    EXECUTE dbo.USSP_GBL_STREET_SET @StreetName = @StreetName,
                                                    @idfsLocation = @LocationID,
                                                    @AuditUserName = @AuditUserName,
                                                    @idfStreet = @StreetID OUTPUT;
                END

                IF @PostalCodeString IS NOT NULL
                BEGIN
                    EXECUTE dbo.USSP_GBL_POSTAL_CODE_SET @strPostCode = @PostalCodeString,
                                                         @idfsLocation = @LocationID,
                                                         @AuditUserName = @AuditUserName,
                                                         @idfPostalCode = @PostalCodeID OUTPUT;
                END
            END
        END

        IF (
               EXISTS
        (
            SELECT *
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @GeolocationID
        )
               AND (ISNULL(@GeolocationSharedIndicator, 0) <> 1)
           )
        BEGIN
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
            SELECT idfGeoLocation,
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
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @GeoLocationID;
            -- End data audit

            UPDATE dbo.tlbGeoLocation
            SET idfsResidentType = @ResidentTypeID,
                idfsGroundType = @GroundTypeID,
                idfsGeoLocationType = @GeolocationTypeID,
                idfsCountry = @idfsAdminLevel1,
                idfsRegion = @idfsAdminLevel2,
                idfsRayon = @idfsAdminLevel3,
                idfsSettlement = @idfsAdminLevel4,
                idfsLocation = @LocationID,
                strApartment = @Apartment,
                strDescription = @DescriptionString,
                dblDistance = @Distance,
                dblAccuracy = @Accuracy,
                dblAlignment = @Alignment,
                strBuilding = @Building,
                strStreetName = @StreetName,
                strHouse = @House,
                strPostCode = @PostalCodeString,
                blnForeignAddress = ISNULL(@ForeignAddressIndicator, 0),
                strForeignAddress = @ForeignAddressString,
                dblLatitude = @Latitude,
                dblLongitude = @Longitude,
                dblElevation = @Elevation,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfGeoLocation = @GeoLocationID

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
            SELECT idfGeoLocation,
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
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @GeoLocationID;

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
                   79200000000,
                   a.GeoLocationID,
                   NULL,
                   b.ResidentTypeID,
                   a.ResidentTypeID,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79170000000,
                   a.GeoLocationID,
                   NULL,
                   b.GroundTypeID,
                   a.GroundTypeID,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79160000000,
                   a.GeoLocationID,
                   NULL,
                   b.GeoLocationTypeID,
                   a.GeoLocationTypeID,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   51523700000000,
                   a.GeoLocationID,
                   NULL,
                   b.LocationID,
                   a.LocationID,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79260000000,
                   a.GeoLocationID,
                   NULL,
                   b.PostalCode,
                   a.PostalCode,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79270000000,
                   a.GeoLocationID,
                   NULL,
                   b.StreetName,
                   a.StreetName,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79250000000,
                   a.GeoLocationID,
                   NULL,
                   b.House,
                   a.House,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79230000000,
                   a.GeoLocationID,
                   NULL,
                   b.Building,
                   a.Building,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   4577890000000,
                   a.GeoLocationID,
                   NULL,
                   b.Apartment,
                   a.Apartment,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79240000000,
                   a.GeoLocationID,
                   NULL,
                   b.AddressDescription,
                   a.AddressDescription,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79110000000,
                   a.GeoLocationID,
                   NULL,
                   b.Distance,
                   a.Distance,
                   @AuditUserName
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
                   79090000000,
                   a.GeoLocationID,
                   NULL,
                   b.Accuracy,
                   a.Accuracy,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   79100000000,
                   a.GeoLocationID,
                   NULL,
                   b.Alignment,
                   a.Alignment,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   4578780000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressIndicator,
                   a.ForeignAddressIndicator,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   4578790000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressString,
                   a.ForeignAddressString,
                   @AuditUserName
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
                   @ObjectGeoLocationTableID,
                   51523680000000,
                   a.GeoLocationID,
                   NULL,
                   b.ShortAddressString,
                   a.ShortAddressString,
                   @AuditUserName
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

            -- Add data audit event for the geo-location object type
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      10016003, -- Edit data audit event type
                                                      10017025, -- Geo-location data audit object type
                                                      @GeoLocationID,
                                                      @ObjectGeoLocationTableID,
                                                      NULL,
                                                      @DataAuditEventGeoLocationID OUTPUT;

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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79200000000,
                   a.GeoLocationID,
                   NULL,
                   b.ResidentTypeID,
                   a.ResidentTypeID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79170000000,
                   a.GeoLocationID,
                   NULL,
                   b.GroundTypeID,
                   a.GroundTypeID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79160000000,
                   a.GeoLocationID,
                   NULL,
                   b.GeoLocationTypeID,
                   a.GeoLocationTypeID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   51523700000000,
                   a.GeoLocationID,
                   NULL,
                   b.LocationID,
                   a.LocationID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79260000000,
                   a.GeoLocationID,
                   NULL,
                   b.PostalCode,
                   a.PostalCode,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79270000000,
                   a.GeoLocationID,
                   NULL,
                   b.StreetName,
                   a.StreetName,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79250000000,
                   a.GeoLocationID,
                   NULL,
                   b.House,
                   a.House,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79230000000,
                   a.GeoLocationID,
                   NULL,
                   b.Building,
                   a.Building,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   4577890000000,
                   a.GeoLocationID,
                   NULL,
                   b.Apartment,
                   a.Apartment,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79240000000,
                   a.GeoLocationID,
                   NULL,
                   b.AddressDescription,
                   a.AddressDescription,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79110000000,
                   a.GeoLocationID,
                   NULL,
                   b.Distance,
                   a.Distance,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
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
            SELECT @DataAuditEventGeoLocationID,
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79090000000,
                   a.GeoLocationID,
                   NULL,
                   b.Accuracy,
                   a.Accuracy,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   79100000000,
                   a.GeoLocationID,
                   NULL,
                   b.Alignment,
                   a.Alignment,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   4578780000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressIndicator,
                   a.ForeignAddressIndicator,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   4578790000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressString,
                   a.ForeignAddressString,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationTableID,
                   51523680000000,
                   a.GeoLocationID,
                   NULL,
                   b.ShortAddressString,
                   a.ShortAddressString,
                   @AuditUserName
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
        END
        ELSE IF EXISTS
        (
            SELECT *
            FROM dbo.tlbGeoLocationShared
            WHERE idfGeoLocationShared = @GeolocationID
        )
        BEGIN
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
            WHERE idfGeoLocationShared = @GeolocationID;
            -- End data audit

            UPDATE dbo.tlbGeoLocationShared
            SET idfsResidentType = @ResidentTypeID,
                idfsGroundType = @GroundTypeID,
                idfsGeoLocationType = 10036001,
                idfsCountry = @idfsAdminLevel1,
                idfsRegion = @idfsAdminLevel2,
                idfsRayon = @idfsAdminLevel3,
                idfsSettlement = @idfsAdminLevel4,
                idfsLocation = @LocationID,
                strApartment = @Apartment,
                strDescription = @DescriptionString,
                dblDistance = @Distance,
                dblAccuracy = @Accuracy,
                dblAlignment = @Alignment,
                strBuilding = @Building,
                strStreetName = @StreetName,
                strHouse = @House,
                strPostCode = @PostalCodeString,
                blnForeignAddress = ISNULL(@ForeignAddressIndicator, 0),
                strForeignAddress = @ForeignAddressString,
                dblLatitude = @Latitude,
                dblLongitude = @Longitude,
                dblElevation = @Elevation,
                AuditUpdateUser = @AuditUserName,
                AuditUpdateDTM = GETDATE()
            WHERE idfGeoLocationShared = @GeolocationID

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
            WHERE idfGeoLocationShared = @GeolocationID;

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
                   @ObjectGeoLocationSharedTableID,
                   79200000000,
                   a.GeoLocationID,
                   NULL,
                   b.ResidentTypeID,
                   a.ResidentTypeID,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79170000000,
                   a.GeoLocationID,
                   NULL,
                   b.GroundTypeID,
                   a.GroundTypeID,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79160000000,
                   a.GeoLocationID,
                   NULL,
                   b.GeoLocationTypeID,
                   a.GeoLocationTypeID,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   51523700000000,
                   a.GeoLocationID,
                   NULL,
                   b.LocationID,
                   a.LocationID,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79260000000,
                   a.GeoLocationID,
                   NULL,
                   b.PostalCode,
                   a.PostalCode,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79270000000,
                   a.GeoLocationID,
                   NULL,
                   b.StreetName,
                   a.StreetName,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79250000000,
                   a.GeoLocationID,
                   NULL,
                   b.House,
                   a.House,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79230000000,
                   a.GeoLocationID,
                   NULL,
                   b.Building,
                   a.Building,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   4577890000000,
                   a.GeoLocationID,
                   NULL,
                   b.Apartment,
                   a.Apartment,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79240000000,
                   a.GeoLocationID,
                   NULL,
                   b.AddressDescription,
                   a.AddressDescription,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79110000000,
                   a.GeoLocationID,
                   NULL,
                   b.Distance,
                   a.Distance,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
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
                   @ObjectGeoLocationSharedTableID,
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
                   @ObjectGeoLocationSharedTableID,
                   79090000000,
                   a.GeoLocationID,
                   NULL,
                   b.Accuracy,
                   a.Accuracy,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   79100000000,
                   a.GeoLocationID,
                   NULL,
                   b.Alignment,
                   a.Alignment,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   4578780000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressIndicator,
                   a.ForeignAddressIndicator,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   4578790000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressString,
                   a.ForeignAddressString,
                   @AuditUserName
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
                   @ObjectGeoLocationSharedTableID,
                   51523680000000,
                   a.GeoLocationID,
                   NULL,
                   b.ShortAddressString,
                   a.ShortAddressString,
                   @AuditUserName
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

            -- Add data audit event for the geo-location object type
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      10016003, -- Edit data audit event type
                                                      10017025, -- Geo-location data audit object type
                                                      @GeolocationID,
                                                      @ObjectGeoLocationSharedTableID,
                                                      NULL,
                                                      @DataAuditEventGeoLocationID OUTPUT;

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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79200000000,
                   a.GeoLocationID,
                   NULL,
                   b.ResidentTypeID,
                   a.ResidentTypeID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79170000000,
                   a.GeoLocationID,
                   NULL,
                   b.GroundTypeID,
                   a.GroundTypeID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79160000000,
                   a.GeoLocationID,
                   NULL,
                   b.GeoLocationTypeID,
                   a.GeoLocationTypeID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   51523700000000,
                   a.GeoLocationID,
                   NULL,
                   b.LocationID,
                   a.LocationID,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79260000000,
                   a.GeoLocationID,
                   NULL,
                   b.PostalCode,
                   a.PostalCode,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79270000000,
                   a.GeoLocationID,
                   NULL,
                   b.StreetName,
                   a.StreetName,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79250000000,
                   a.GeoLocationID,
                   NULL,
                   b.House,
                   a.House,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79230000000,
                   a.GeoLocationID,
                   NULL,
                   b.Building,
                   a.Building,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   4577890000000,
                   a.GeoLocationID,
                   NULL,
                   b.Apartment,
                   a.Apartment,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79240000000,
                   a.GeoLocationID,
                   NULL,
                   b.AddressDescription,
                   a.AddressDescription,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79110000000,
                   a.GeoLocationID,
                   NULL,
                   b.Distance,
                   a.Distance,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79090000000,
                   a.GeoLocationID,
                   NULL,
                   b.Accuracy,
                   a.Accuracy,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   79100000000,
                   a.GeoLocationID,
                   NULL,
                   b.Alignment,
                   a.Alignment,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   4578780000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressIndicator,
                   a.ForeignAddressIndicator,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   4578790000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressString,
                   a.ForeignAddressString,
                   @AuditUserName
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
            SELECT @DataAuditEventGeoLocationID,
                   @ObjectGeoLocationSharedTableID,
                   51523680000000,
                   a.GeoLocationID,
                   NULL,
                   b.ShortAddressString,
                   a.ShortAddressString,
                   @AuditUserName
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
        END
        ELSE IF ISNULL(@GeolocationSharedIndicator, 0) <> 1
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbGeoLocation',
                                              @idfsKey = @GeolocationID OUTPUT;

            INSERT INTO dbo.tlbGeoLocation
            (
                idfGeoLocation,
                idfsResidentType,
                idfsGroundType,
                idfsGeoLocationType,
                idfsCountry,
                idfsRegion,
                idfsRayon,
                idfsSettlement,
                idfsLocation,
                strDescription,
                dblDistance,
                dblAccuracy,
                dblAlignment,
                strApartment,
                strBuilding,
                strStreetName,
                strHouse,
                strPostCode,
                blnForeignAddress,
                strForeignAddress,
                dblLatitude,
                dblLongitude,
                dblElevation,
                intRowStatus,
                rowguid,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@GeolocationID,
             @ResidentTypeID,
             @GroundTypeID,
             @GeolocationTypeID,
             @idfsAdminLevel1,
             @idfsAdminLevel2,
             @idfsAdminLevel3,
             @idfsAdminLevel4,
             @LocationID,
             @DescriptionString,
             @Distance,
             @Accuracy,
             @Alignment,
             @Apartment,
             @Building,
             @StreetName,
             @House,
             @PostalCodeString,
             ISNULL(@ForeignAddressIndicator, 0),
             @ForeignAddressString,
             @Latitude,
             @Longitude,
             @Elevation,
             0  ,
             NEWID(),
             10519001,
             '[{"idfGeoLocation":' + CAST(@GeolocationID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
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
                AuditCreateUser
            )
            VALUES
            (@DataAuditEventID,
             @ObjectGeoLocationTableID,
             @GeolocationID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectGeoLocationTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );

            -- Add data audit event for the geo-location object type
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      10016001, -- Create data audit event type
                                                      10017025, -- Geo-location data audit object type
                                                      @GeoLocationID,
                                                      @ObjectGeoLocationTableID,
                                                      NULL,
                                                      @DataAuditEventGeoLocationID OUTPUT;

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
            (@DataAuditEventGeoLocationID,
             @ObjectGeoLocationTableID,
             @GeolocationID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectGeoLocationTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );
        -- End data audit
        END
        ELSE
        BEGIN
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tlbGeoLocationShared',
                                              @idfsKey = @GeolocationID OUTPUT;

            INSERT INTO dbo.tlbGeoLocationShared
            (
                idfGeoLocationShared,
                idfsResidentType,
                idfsGroundType,
                idfsGeoLocationType,
                idfsCountry,
                idfsRegion,
                idfsRayon,
                idfsSettlement,
                idfsLocation,
                strDescription,
                dblDistance,
                dblAccuracy,
                dblAlignment,
                strApartment,
                strBuilding,
                strStreetName,
                strHouse,
                strPostCode,
                blnForeignAddress,
                strForeignAddress,
                dblLatitude,
                dblLongitude,
                dblElevation,
                intRowStatus,
                rowguid,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@GeolocationID,
             @ResidentTypeID,
             @GroundTypeID,
             @GeolocationTypeID,
             @idfsAdminLevel1,
             @idfsAdminLevel2,
             @idfsAdminLevel3,
             @idfsAdminLevel4,
             @LocationID,
             @DescriptionString,
             @Distance,
             @Accuracy,
             @Alignment,
             @Apartment,
             @Building,
             @StreetName,
             @House,
             @PostalCodeString,
             ISNULL(@ForeignAddressIndicator, 0),
             @ForeignAddressString,
             @Latitude,
             @Longitude,
             @Elevation,
             0  ,
             NEWID(),
             10519001,
             '[{"idfGeoLocationShared":' + CAST(@GeolocationID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             GETDATE(),
             @AuditUserName,
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
                AuditCreateUser
            )
            VALUES
            (@DataAuditEventID,
             @ObjectGeoLocationSharedTableID,
             @GeolocationID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectGeoLocationSharedTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );

            -- Add data audit event for the geo-location object type
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      10016001, -- Create data audit event type
                                                      10017025, -- Geo-location data audit object type
                                                      @GeoLocationID,
                                                      @ObjectGeoLocationSharedTableID,
                                                      NULL,
                                                      @DataAuditEventGeoLocationID OUTPUT;

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
            (@DataAuditEventGeoLocationID,
             @ObjectGeoLocationSharedTableID,
             @GeolocationID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectGeoLocationSharedTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );
        -- End data audit
        END

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage;

        THROW;
    END CATCH
END
