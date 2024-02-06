-- ================================================================================================
-- Name: USSP_GBL_COPY_GEOLOCATION_SET
--
-- Description:	If record with @GeoLocationIDCopy doesn't exist, new record with this ID is 
-- created. If original location record doesn't exist the empty record with @GeoLocationIDCopy is 
-- created.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Stephen Long        11/18/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long        11/28/2022 Changed column identifier for idfsLocation.
-- Stephen Long        03/14/2023 Fix on geo-location copy ID; added default of null and added 
--                                source system values on insert statements for geo-location.
--                                Removed geo-location shared as this is never copied in EIDSS7.
--                                Added geo-location data audit event.
-- Stephen Long        04/05/2023 Removed return code and return message.
--
--Example of a call of procedure:
--DECLARE @RC int
--DECLARE @GeoLocationID bigint
--DECLARE @GeoLocationIDCopy bigint
--SET @GeoLocationID = 123890000000
--SET @GeoLocationIDCopy = 1

--EXECUTE @RC = USSP_GBL_COPY_GEOLOCATION_SET
--   @GeoLocationID
--  ,@GeoLocationIDCopy
--  ,1

-- delete dbo.tflGeoLocationFiltered WHERE idfGeoLocation = 1
-- delete dbo.tlbGeoLocation WHERE idfGeoLocation = 1
-- delete dbo.tlbGeoLocationShared WHERE idfGeoLocationShared = 1
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_GBL_COPY_GEOLOCATION_SET]
(
    @GeoLocationID BIGINT,
    @GeoLocationIDCopy BIGINT,
    @GlobalCopyAsDefaultIndicator BIT = 0,
    @DataAuditEventID BIGINT = NULL,
    @AuditUserName NVARCHAR(200) = NULL,
    @ReturnCode INT = 0 OUTPUT,
    @ReturnMsg NVARCHAR(MAX) = 'SUCCESS' OUTPUT
)
AS
DECLARE @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @DataAuditEventGeoLocationID BIGINT = NULL,
        @ObjectID BIGINT = @GeoLocationID,
        @ObjectGeoLocationTableID BIGINT = 75580000000; -- tlbGeoLocation
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
BEGIN
    BEGIN TRY
        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @GeoLocationIDCopy
        )
        BEGIN
            INSERT INTO dbo.tlbGeoLocation
            (
                idfGeoLocation,
                idfsGroundType,
                idfsGeoLocationType,
                idfsCountry,
                idfsRegion,
                idfsRayon,
                idfsSettlement,
                strDescription,
                dblDistance,
                dblLatitude,
                dblLongitude,
                dblAccuracy,
                dblAlignment,
                strApartment,
                strBuilding,
                strStreetName,
                strHouse,
                strPostCode,
                idfsResidentType,
                idfsLocation,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            SELECT @GeoLocationIDCopy,
                   idfsGroundType,
                   idfsGeoLocationType,
                   idfsCountry,
                   idfsRegion,
                   idfsRayon,
                   idfsSettlement,
                   strDescription,
                   dblDistance,
                   dblLatitude,
                   dblLongitude,
                   dblAccuracy,
                   dblAlignment,
                   strApartment,
                   strBuilding,
                   strStreetName,
                   strHouse,
                   strPostCode,
                   idfsResidentType,
                   idfsLocation,
                   10519001,
                   '[{"idfGeoLocation":' + CAST(@GeoLocationIDCopy AS NVARCHAR(300)) + '}]',
                   @AuditUserName
            FROM dbo.tlbGeoLocationShared
            WHERE idfGeoLocationShared = @GeoLocationID;

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
             @GeoLocationIDCopy,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectGeoLocationTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );

            -- Add data audit event for the geo-location object type
            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      10016001, -- Create data audit event type
                                                      10017025, -- Geolocation data audit object type
                                                      @GeoLocationIDCopy,
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
             @GeoLocationIDCopy,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectGeoLocationTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName
            );
        -- End data audit
        END
        ELSE
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

            UPDATE new
            SET idfsGroundType = old.idfsGroundType,
                idfsGeoLocationType = old.idfsGeoLocationType,
                idfsCountry = old.idfsCountry,
                idfsRegion = old.idfsRegion,
                idfsRayon = old.idfsRayon,
                idfsSettlement = old.idfsSettlement,
                strDescription = old.strDescription,
                dblDistance = old.dblDistance,
                dblLatitude = old.dblLatitude,
                dblLongitude = old.dblLongitude,
                dblAccuracy = old.dblAccuracy,
                dblAlignment = old.dblAlignment,
                strApartment = old.strApartment,
                strBuilding = old.strBuilding,
                strStreetName = old.strStreetName,
                strHouse = old.strHouse,
                strPostCode = old.strPostCode,
                idfsResidentType = old.idfsResidentType,
                idfsLocation = old.idfsLocation
            FROM dbo.tlbGeoLocation old
                INNER JOIN dbo.tlbGeoLocation new
                    ON new.idfGeoLocation = @GeoLocationIDCopy
                       AND (
                               ISNULL(new.idfsGroundType, 0) != ISNULL(old.idfsGroundType, 0)
                               OR ISNULL(new.idfsGeoLocationType, 0) != ISNULL(old.idfsGeoLocationType, 0)
                               OR ISNULL(new.idfsCountry, 0) != ISNULL(old.idfsCountry, 0)
                               OR ISNULL(new.idfsRegion, 0) != ISNULL(old.idfsRegion, 0)
                               OR ISNULL(new.idfsRayon, 0) != ISNULL(old.idfsRayon, 0)
                               OR ISNULL(new.idfsSettlement, 0) != ISNULL(old.idfsSettlement, 0)
                               OR ISNULL(new.strDescription, '') != ISNULL(old.strDescription, '')
                               OR ISNULL(new.dblDistance, 0) != ISNULL(old.dblDistance, 0)
                               OR ISNULL(new.dblLatitude, 0) != ISNULL(old.dblLatitude, 0)
                               OR ISNULL(new.dblLongitude, 0) != ISNULL(old.dblLongitude, 0)
                               OR ISNULL(new.dblAccuracy, 0) != ISNULL(old.dblAccuracy, 0)
                               OR ISNULL(new.dblAlignment, 0) != ISNULL(old.dblAlignment, 0)
                               OR ISNULL(new.strApartment, '') != ISNULL(old.strApartment, '')
                               OR ISNULL(new.strBuilding, '') != ISNULL(old.strBuilding, '')
                               OR ISNULL(new.strStreetName, '') != ISNULL(old.strStreetName, '')
                               OR ISNULL(new.strHouse, '') != ISNULL(old.strHouse, '')
                               OR ISNULL(new.strPostCode, '') != ISNULL(old.strPostCode, '')
                               OR ISNULL(new.idfsResidentType, 0) != ISNULL(old.idfsResidentType, 0)
                               OR ISNULL(new.idfsLocation, 0) != ISNULL(old.idfsLocation, 0)
                           )
            WHERE old.idfGeoLocation = @GeoLocationID;

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
                                                      10016003, -- Create data audit event type
                                                      10017025, -- Geolocation data audit object type
                                                      @GeoLocationIDCopy,
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
    END TRY
    BEGIN CATCH
        THROW;

    END CATCH
END
