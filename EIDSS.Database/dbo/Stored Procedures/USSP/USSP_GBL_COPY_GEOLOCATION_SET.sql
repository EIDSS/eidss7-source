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
    PostalCode NVARCHAR(200) collate Cyrillic_General_CI_AS,
    StreetName NVARCHAR(200) collate Cyrillic_General_CI_AS,
    House NVARCHAR(200) collate Cyrillic_General_CI_AS,
    Building NVARCHAR(200) collate Cyrillic_General_CI_AS,
    Apartment NVARCHAR(200) collate Cyrillic_General_CI_AS,
    AddressDescription NVARCHAR(200) collate Cyrillic_General_CI_AS,
    Distance FLOAT,
    Latitude FLOAT,
    Longitude FLOAT,
    Accuracy FLOAT,
    Alignment FLOAT,
    ForeignAddressIndicator BIT,
    ForeignAddressString NVARCHAR(200) collate Cyrillic_General_CI_AS,
	AddressString NVARCHAR(2000) collate Cyrillic_General_CI_AS,
    ShortAddressString NVARCHAR(2000) collate Cyrillic_General_CI_AS
);
DECLARE @GeoLocationAfterEdit TABLE
(
    GeoLocationID BIGINT,
    ResidentTypeID BIGINT,
    GroundTypeID BIGINT,
    GeoLocationTypeID BIGINT,
    LocationID BIGINT,
    PostalCode NVARCHAR(200) collate Cyrillic_General_CI_AS,
    StreetName NVARCHAR(200) collate Cyrillic_General_CI_AS,
    House NVARCHAR(200) collate Cyrillic_General_CI_AS,
    Building NVARCHAR(200) collate Cyrillic_General_CI_AS,
    Apartment NVARCHAR(200) collate Cyrillic_General_CI_AS,
    AddressDescription NVARCHAR(200) collate Cyrillic_General_CI_AS,
    Distance FLOAT,
    Latitude FLOAT,
    Longitude FLOAT,
    Accuracy FLOAT,
    Alignment FLOAT,
    ForeignAddressIndicator BIT,
    ForeignAddressString NVARCHAR(200) collate Cyrillic_General_CI_AS,
	AddressString NVARCHAR(2000) collate Cyrillic_General_CI_AS,
    ShortAddressString NVARCHAR(2000) collate Cyrillic_General_CI_AS
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
            SELECT 1
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
				blnForeignAddress,
				strForeignAddress,
				strAddressString,
				strShortAddressString,
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
				   blnForeignAddress,
				   strForeignAddress,
				   strAddressString,
				   strShortAddressString,
                   10519001,
                   '[{"idfGeoLocation":' + CAST(@GeoLocationIDCopy AS NVARCHAR(300)) + '}]',
                   @AuditUserName
            FROM dbo.tlbGeoLocationShared
            WHERE idfGeoLocationShared = @GeoLocationID;

            -- Data audit
			if @DataAuditEventID is not null
			begin
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
			end
			else begin

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
			end
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
				AddressString,
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
				   strAddressString,
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
                idfsLocation = old.idfsLocation,
				blnForeignAddress = old.blnForeignAddress,
				strForeignAddress = old.strForeignAddress
            FROM dbo.tlbGeoLocation old
                INNER JOIN dbo.tlbGeoLocation new
                    ON new.idfGeoLocation = @GeoLocationIDCopy
                       AND (
                               (new.idfsGroundType is null and old.idfsGroundType is not null)
							   OR (new.idfsGroundType is not null and old.idfsGroundType is null)
							   OR (new.idfsGroundType <> old.idfsGroundType)

							   OR (new.idfsGeoLocationType is null and old.idfsGeoLocationType is not null)
							   OR (new.idfsGeoLocationType is not null and old.idfsGeoLocationType is null)
							   OR (new.idfsGeoLocationType <> old.idfsGeoLocationType)

							   OR (new.idfsCountry is null and old.idfsCountry is not null)
							   OR (new.idfsCountry is not null and old.idfsCountry is null)
							   OR (new.idfsCountry <> old.idfsCountry)

							   OR (new.idfsRegion is null and old.idfsRegion is not null)
							   OR (new.idfsRegion is not null and old.idfsRegion is null)
							   OR (new.idfsRegion <> old.idfsRegion)

							   OR (new.idfsRayon is null and old.idfsRayon is not null)
							   OR (new.idfsRayon is not null and old.idfsRayon is null)
							   OR (new.idfsRayon <> old.idfsRayon)

							   OR (new.idfsSettlement is null and old.idfsSettlement is not null)
							   OR (new.idfsSettlement is not null and old.idfsSettlement is null)
							   OR (new.idfsSettlement <> old.idfsSettlement)

							   OR (new.strDescription is null and old.strDescription is not null)
							   OR (new.strDescription is not null and old.strDescription is null)
							   OR (new.strDescription <> old.strDescription collate Cyrillic_General_CI_AS)

							   OR (new.dblDistance is null and old.dblDistance is not null)
							   OR (new.dblDistance is not null and old.dblDistance is null)
							   OR (new.dblDistance <> old.dblDistance)

							   OR (new.dblLatitude is null and old.dblLatitude is not null)
							   OR (new.dblLatitude is not null and old.dblLatitude is null)
							   OR (new.dblLatitude <> old.dblLatitude)

							   OR (new.dblLongitude is null and old.dblLongitude is not null)
							   OR (new.dblLongitude is not null and old.dblLongitude is null)
							   OR (new.dblLongitude <> old.dblLongitude)

							   OR (new.dblAccuracy is null and old.dblAccuracy is not null)
							   OR (new.dblAccuracy is not null and old.dblAccuracy is null)
							   OR (new.dblAccuracy <> old.dblAccuracy)

							   OR (new.dblAlignment is null and old.dblAlignment is not null)
							   OR (new.dblAlignment is not null and old.dblAlignment is null)
							   OR (new.dblAlignment <> old.dblAlignment)

							   OR (new.strApartment is null and old.strApartment is not null)
							   OR (new.strApartment is not null and old.strApartment is null)
							   OR (new.strApartment <> old.strApartment collate Cyrillic_General_CI_AS)

							   OR (new.strBuilding is null and old.strBuilding is not null)
							   OR (new.strBuilding is not null and old.strBuilding is null)
							   OR (new.strBuilding <> old.strBuilding collate Cyrillic_General_CI_AS)

							   OR (new.strStreetName is null and old.strStreetName is not null)
							   OR (new.strStreetName is not null and old.strStreetName is null)
							   OR (new.strStreetName <> old.strStreetName collate Cyrillic_General_CI_AS)

							   OR (new.strHouse is null and old.strHouse is not null)
							   OR (new.strHouse is not null and old.strHouse is null)
							   OR (new.strHouse <> old.strHouse collate Cyrillic_General_CI_AS)

							   OR (new.strPostCode is null and old.strPostCode is not null)
							   OR (new.strPostCode is not null and old.strPostCode is null)
							   OR (new.strPostCode <> old.strPostCode collate Cyrillic_General_CI_AS)

							   OR (new.idfsResidentType is null and old.idfsResidentType is not null)
							   OR (new.idfsResidentType is not null and old.idfsResidentType is null)
							   OR (new.idfsResidentType <> old.idfsResidentType)

							   OR (new.idfsLocation is null and old.idfsLocation is not null)
							   OR (new.idfsLocation is not null and old.idfsLocation is null)
							   OR (new.idfsLocation <> old.idfsLocation)

							   OR (new.blnForeignAddress is null and old.blnForeignAddress is not null)
							   OR (new.blnForeignAddress is not null and old.blnForeignAddress is null)
							   OR (new.blnForeignAddress <> old.blnForeignAddress)

							   OR (new.strForeignAddress is null and old.strForeignAddress is not null)
							   OR (new.strForeignAddress is not null and old.strForeignAddress is null)
							   OR (new.strForeignAddress <> old.strForeignAddress collate Cyrillic_General_CI_AS)
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
				AddressString,
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
				   strAddressString,
                   strShortAddressString
            FROM dbo.tlbGeoLocation
            WHERE idfGeoLocation = @GeoLocationID;


            -- Data audit
			if @DataAuditEventID is not null
			begin
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
			end
			else begin

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
		end
        -- End data audit
        END
    END TRY
    BEGIN CATCH
        THROW;

    END CATCH
END
