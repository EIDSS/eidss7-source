

-- ================================================================================================
-- Name: Added NULL Elevation parm to USSP_GBL_ADDRESS_SET
--
-- Description: Inserts or updates an address record as described in use case SYSUC07.
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name				Date		Change Detail
-- ---------------	----------	--------------------------------------------------------------------
-- Stephen Long		04/21/2019	Fixed the check for location shared versus location on the 
--								update portion.
-- Stephen Long		12/26/2019	Added dbo prefix to function calls and replaced with v7 calls.
-- Stephen Long		06/04/2020	Added postal code set call and transaction logic.
-- Stephen Long		06/16/2021	Replaced country, region, rayon and settlement ID's with location ID 
--								to support location hierarchy.
-- Stephen Long		08/05/2021	Added audit user name.
-- Mark Wilson		09/13/2021	Added additional fields to tlbGeolocation and tlbGeoLocationShared
-- Mark Wilson		09/22/2021	standardized and updated calls to USSPs
-- Mark Wilson		10/06/2021	Added Elevation.
-- Mark Wilson		10/18/2021	added back write of Country, Region, Rayon, Settlement.
-- Mark Wilson		10/19/2021	changed to USSP.
-- Steven Verner	07/06/2022  Updated location select statement to select from flattened location hierarchy table.

-- Testing code:
/*

DECLARE	@return_value int,
		@ReturnCode int,
		@ReturnMessage nvarchar(max)

EXEC	@return_value = [dbo].[USSP_GBL_ADDRESS_SET]
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
CREATE PROCEDURE [dbo].[USSP_GBL_ADDRESS_SET]
(
	@GeolocationID BIGINT = NULL OUTPUT,
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
DECLARE @PostalCodeID BIGINT;
DECLARE @StreetID BIGINT;
DECLARE @AdminLevel INT = NULL;
DECLARE @LocationNode HIERARCHYID = NULL;
SELECT 
	@LocationNode = node
FROM dbo.gisLocation WHERE idfsLocation = @LocationID

BEGIN
	BEGIN TRY

		IF @AuditUserName = ''
			SET @AuditUserName = SUSER_NAME()

		SET @ReturnCode = 0;
		SET @ReturnMessage = 'SUCCESS';

		BEGIN TRANSACTION;

		IF @ForeignAddressIndicator = 0
		BEGIN
			-- Determine if the location ID passed in is at the settlement level.
			SELECT 
				@AdminLevel = node.GetLevel() 
			FROM dbo.gisLocation
			WHERE idfsLocation = @LocationID;

			DECLARE @idfsAdminLevel1 BIGINT, -- country
					@idfsAdminLevel2 BIGINT, -- region
					@idfsAdminLevel3 BIGINT, -- rayon
					@idfsAdminLevel4 BIGINT -- settlement

			
			--SELECT
	
			--	@idfsAdminLevel1 = a1.idfsLocation,
			--	@idfsAdminLevel2 = a2.idfsLocation,
			--	@idfsAdminLevel3 = a3.idfsLocation,
			--	@idfsAdminLevel4 = a4.idfsLocation

			--FROM dbo.gisLocation L 
			--INNER JOIN dbo.gisLocation a1 ON (L.node.IsDescendantOf(a1.node) = 1 OR a1.idfsLocation = @locationID) AND a1.node.GetLevel() = 1
			--LEFT JOIN dbo.gisLocation a2 ON (L.node.IsDescendantOf(a2.node) = 1 OR a2.idfsLocation = @locationID) AND a2.node.GetLevel() = 2
			--LEFT JOIN dbo.gisLocation a3 ON (L.node.IsDescendantOf(a3.node) = 1 OR a3.idfsLocation = @locationID) AND a3.node.GetLevel() = 3
			--LEFT JOIN dbo.gisLocation a4 ON (L.node.IsDescendantOf(a4.node) = 1 OR a4.idfsLocation = @locationID) AND a4.node.GetLevel() = 4

			--WHERE L.idfsLocation = @LocationID

			SELECT @idfsAdminLevel1 = fglhf.AdminLevel1ID, @idfsAdminLevel2 = fglhf.AdminLevel2ID, @idfsAdminLevel3 = fglhf.AdminLevel3ID, @idfsAdminLevel4 = adminlevel4ID 
			FROM dbo.FN_GBL_LocationHierarchy_Flattened('EN-us') fglhf
			WHERE fglhf.idfsLocation = @LocationID

			-- If it is a settlement level, then determine if the street name and/or postal code 
			-- needs to be added to the appropriate tables for inclusion in the street or postal 
			-- code drop downs.
			IF @AdminLevel = 4
			BEGIN
				IF @StreetName IS NOT NULL
				BEGIN
					EXECUTE dbo.USSP_GBL_STREET_SET 
						@StreetName = @StreetName,
						@idfsLocation = @LocationID,
						@AuditUserName = @AuditUserName,
						@idfStreet = @StreetID OUTPUT

				END

				IF @PostalCodeString IS NOT NULL
				BEGIN
					EXECUTE dbo.USSP_GBL_POSTAL_CODE_SET 
						@strPostCode = @PostalCodeString,
						@idfsLocation = @LocationID,
						@AuditUserName = @AuditUserName,
						@idfPostalCode = @PostalCodeID OUTPUT
				END
			
			END
		
		END

		IF (EXISTS (SELECT * FROM dbo.tlbGeoLocation WHERE idfGeoLocation = @GeolocationID)	AND (ISNULL(@GeolocationSharedIndicator, 0) <> 1))
		BEGIN
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

		END
		ELSE IF EXISTS (
				SELECT *
				FROM dbo.tlbGeoLocationShared
				WHERE idfGeoLocationShared = @GeolocationID
				)
		BEGIN
			UPDATE dbo.tlbGeoLocationShared
			SET 
				idfsResidentType = @ResidentTypeID,
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

		END
		ELSE IF ISNULL(@GeolocationSharedIndicator, 0) <> 1
		BEGIN
			
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				@tableName = 'tlbGeoLocation',
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
			(
				@GeolocationID,
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
				0,
				NEWID(),
				10519001,
				'[{"idfGeoLocation":' + CAST(@GeolocationID AS NVARCHAR(300)) + '}]',
				@AuditUserName,
				GETDATE(),
				@AuditUserName,
				GETDATE()
			);

		END

		ELSE

		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				@tableName = 'tlbGeoLocationShared',
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
			(
				@GeolocationID,
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
				0,
				NEWID(),
				10519001,
				'[{"idfGeoLocationShared":' + CAST(@GeolocationID AS NVARCHAR(300)) + '}]',
				@AuditUserName,
				GETDATE(),
				@AuditUserName,
				GETDATE()
			);
		END

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage;

		THROW;
	END CATCH

END
