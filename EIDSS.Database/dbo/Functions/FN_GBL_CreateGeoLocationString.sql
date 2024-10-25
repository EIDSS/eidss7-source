
--*************************************************************
-- Name 				: FN_GBL_CreateGeoLocationString
-- Description			: Creates text representation of geolocation depending on geolocation Type.
--						: Can be used in detail forms where there is no need to display multipe rows with geolocation string.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--
--*************************************************************

/*
--Example of a call of procedure:

SELECT dbo.FN_GBL_CreateGeoLocationString (
  'en'
  ,10036003 --'lctExactPoint'
  ,'Georgia' --@Country
  ,'Gali' --@Region
  ,'gg' --@Rayon
  ,'20' --@Latitude
  ,'30' --@Longitude
  ,N'' --@PostalCode
  ,N'' --@SettlementType
  ,N'sett' --@Settlement
  ,N'' --@Street
  ,N'' --@House
  ,N'' --@Building-
  ,N'' --@Appartment
  ,N'' --@Alignment
  ,N'' --@Distance
  ,0 --@blnForeignAddress
  ,N'' --@AddressString
)

*/


CREATE FUNCTION [dbo].[FN_GBL_CreateGeoLocationString]
(
	@LangID				NVARCHAR(50), --##PARAM @LangID  - language ID
	@GeoLocationType	BIGINT, --##PARAM @GeoLocationType  - Geolocation Type
	@Country			NVARCHAR(200), --##PARAM @Country  - Country name
	@Region				NVARCHAR(200), --##PARAM @Region  - Region name
	@Rayon				NVARCHAR(200), --##PARAM @Rayon  - Rayon name
	@Latitude			NVARCHAR(200), --##PARAM @Latitude  - Latitude
	@Longitude			NVARCHAR(200), --##PARAM @Longitude  - Longitude
	@PostalCode			NVARCHAR(200), --##PARAM @PostalCode  - Postal Code for address
	@SettlementType		NVARCHAR(200), --##PARAM @SettlementType  - Settlement Type for address
	@Settlement			NVARCHAR(200), --##PARAM @Settlement - Settlement name
	@Street				NVARCHAR(200), --##PARAM @Street  - Street name
	@House				NVARCHAR(200), --##PARAM @House  - Number of house
	@Building			NVARCHAR(200), --##PARAM @Building  - Number of building
	@Apartment			NVARCHAR(200), --##PARAM @Appartment  - Number of appartment
	@Alignment			NVARCHAR(200), --##PARAM @Alignment  - Azimuth of direction from nearest settlement for relative geolocation
	@Distance			NVARCHAR(200), --##PARAM @Distance  - Distance from nearest settlement for relative geolocation
	@blnForeignAddress	BIT,
	@strForeignAddress	NVARCHAR(200)
)
RETURNS NVARCHAR(1000)
AS
BEGIN

	DECLARE @TempStr NVARCHAR(1000)
	SELECT	
		@TempStr =
			CASE @GeoLocationType
				WHEN 10036003 --'lctExactPoint'
					THEN dbo.FN_GBL_CreateExactPointString	
						(
							@Country,
							@Region,
							@Rayon,
							@SettlementType,
							@Settlement,
							@Latitude,
							@Longitude
						)
				WHEN 10036004--'lctRelativePoint'
					THEN dbo.FN_GBL_CreateRelativePointString	
						(
							@LangID,
							@Country,
							@Region,
							@Rayon,
							@SettlementType,
							@Settlement,
							@Alignment,
							@Distance
						)
				WHEN 10036001 --'lctAddress'
					THEN dbo.FN_GBL_CreateAddressString	
						(
							@Country,
							@Region,
							@Rayon,
							@PostalCode,
							@SettlementType,
							@Settlement,
							@Street,
							@House,
							@Building,
							@Apartment,
							@blnForeignAddress,
							@strForeignAddress
						)
				ELSE NULL
			END -- CASE @GeoLocationType

	RETURN @TempStr

END

