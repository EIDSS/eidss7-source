-- ================================================================================================
-- Name: USSP_HUM_DISEASE_GEOLOCATION_SET
--
-- Description: Inserts or updates a geo-location record for a human associated with a human 
-- diease report.
--          
-- Author: Lamont Mitchell
--
-- Revision History:
-- Name                   Date       Change Detail
-- ---------------------- ---------- -------------------------------------------------------------
-- Stephen Long           11/18/2022 Initial release with data audit logic for SAUC30 and 31.
-- Stephen Long           12/01/2022 Added EIDSS object ID; smart key that represents the parent 
--                                   object. 
--
-- Testing code:

/*
--Example of a call of procedure:
DECLARE @idfGeoLocation BIGINT
DECLARE @idfsGroundType BIGINT
DECLARE @idfsGeoLocationType BIGINT
DECLARE @idfsCountry BIGINT
DECLARE @idfsRegion BIGINT
DECLARE @idfsRayon BIGINT
DECLARE @idfsSettlement BIGINT
DECLARE @strDescription NVARCHAR(200)
DECLARE @dblDistance FLOAT
DECLARE @dblLatitude FLOAT
DECLARE @dblLongitude FLOAT
DECLARE @dblAccuracy FLOAT
DECLARE @dblAlignment FLOAT
declare @blnGeoLocationShared bit

-- TODO: Set parameter values here.

EXECUTE dbo.USP_GBL_GEOLOCATION_SET
   @idfGeoLocation
  ,@idfsGroundType
  ,@idfsGeoLocationType
  ,@idfsCountry
  ,@idfsRegion
  ,@idfsRayon
  ,@idfsSettlement
  ,@strDescription
  ,@dblDistance
  ,@dblLatitude
  ,@dblLongitude
  ,@dblAccuracy
  ,@dblAlignment
  ,@blnGeoLocationShared
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_HUM_DISEASE_GEOLOCATION_SET]
(
    @GeoLocationID BIGINT,
    @GroundTypeID BIGINT,
    @GeoLocationTypeID BIGINT,
    @CountryID BIGINT,
    @RegionID BIGINT,
    @RayonID BIGINT,
    @SettlementID BIGINT,
    @Description NVARCHAR(200),
    @Latitude FLOAT,
    @Longitude FLOAT,
    @Accuracy FLOAT,
    @Distance FLOAT,
    @Alignment FLOAT,
    @ForeignAddressString NVARCHAR(200),
    @GeoLocationSharedIndicator BIT = 0,
    @Elevation FLOAT = NULL,
    @AuditUserName NVARCHAR(100) = '',
    @DataAuditEventID BIGINT = NULL, 
    @EIDSSObjectID NVARCHAR(200) = NULL 
)
AS
DECLARE @ReturnCode INT = 0,
        @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
        @AddressString NVARCHAR(MAX),
        @LocationID BIGINT = COALESCE(@SettlementID, @RayonID, @RegionID, @CountryID),
        @AuditUserID BIGINT = NULL,
        @AuditSiteID BIGINT = NULL,
        @ObjectID BIGINT = @GeoLocationID,
        @ObjectTableID BIGINT = 75580000000; -- tlbGeoLocation
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
        -- End data audit

        IF EXISTS
        (
            SELECT *
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @GeoLocationID
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
            SET idfsGroundType = @GroundTypeID,
                idfsGeoLocationType = @GeoLocationTypeID,
                idfsCountry = @CountryID,
                idfsRegion = @RegionID,
                idfsRayon = @RayonID,
                idfsSettlement = @SettlementID,
                idfsLocation = @LocationID,
                strDescription = @Description,
                dblDistance = @Distance,
                dblLatitude = @Latitude,
                dblLongitude = @Longitude,
                dblAccuracy = @Accuracy,
                dblAlignment = @Alignment,
                strForeignAddress = @ForeignAddressString,
                blnForeignAddress = CASE
                                        WHEN @GeoLocationTypeID = 10036001 THEN
                                            1
                                        ELSE
                                            0
                                    END,
                dblElevation = @Elevation,
                AuditUpdateUser = @AuditUserName, 
                AuditUpdateDTM = GETDATE() 
            WHERE idfGeoLocation = @GeoLocationID;

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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79170000000,
                   a.GeoLocationID,
                   NULL,
                   b.GroundTypeID,
                   a.GroundTypeID,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79160000000,
                   a.GeoLocationID,
                   NULL,
                   b.GeoLocationTypeID,
                   a.GeoLocationTypeID,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51523690000000,
                   a.GeoLocationID,
                   NULL,
                   b.LocationID,
                   a.LocationID,
                   @AuditUserName,
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79240000000,
                   a.GeoLocationID,
                   NULL,
                   b.AddressDescription,
                   a.AddressDescription,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79110000000,
                   a.GeoLocationID,
                   NULL,
                   b.Distance,
                   a.Distance,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79120000000,
                   a.GeoLocationID,
                   NULL,
                   b.Latitude,
                   a.Latitude,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79130000000,
                   a.GeoLocationID,
                   NULL,
                   b.Longitude,
                   a.Longitude,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79090000000,
                   a.GeoLocationID,
                   NULL,
                   b.Accuracy,
                   a.Accuracy,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79100000000,
                   a.GeoLocationID,
                   NULL,
                   b.Alignment,
                   a.Alignment,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578780000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressIndicator,
                   a.ForeignAddressIndicator,
                   @AuditUserName, 
                   @EIDSSObjectID
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
                AuditCreateUser, 
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578790000000,
                   a.GeoLocationID,
                   NULL,
                   b.ForeignAddressString,
                   a.ForeignAddressString,
                   @AuditUserName, 
                   @EIDSSObjectID
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
            -- End data audit
        END
        ELSE
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
                idfsLocation,
                strDescription,
                dblDistance,
                dblLatitude,
                dblLongitude,
                dblAccuracy,
                dblAlignment,
                strForeignAddress,
                blnForeignAddress,
                dblElevation,
                AuditCreateUser
            )
            VALUES
            (   @GeoLocationID,
                @GroundTypeID,
                @GeoLocationTypeID,
                @CountryID,
                @RegionID,
                @RayonID,
                @SettlementID,
                @LocationID,
                @Description,
                @Distance,
                @Latitude,
                @Longitude,
                @Accuracy,
                @Alignment,
                @ForeignAddressString,
                CASE
                    WHEN @GeoLocationTypeID = 10036001 THEN
                        1
                    ELSE
                        0
                END,
                @Elevation,
                @AuditUserName
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
             @GeoLocationID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName, 
             @EIDSSObjectID
            );
            -- End data audit
        END

        SELECT @ReturnCode,
               @ReturnMessage,
               @GeoLocationID;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        SELECT @ReturnCode,
               @ReturnMessage,
               @GeoLocationID;
    END CATCH
END
