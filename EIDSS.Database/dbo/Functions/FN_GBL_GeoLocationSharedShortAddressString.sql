
--*************************************************************
-- Name 				: FN_GBL_GeoLocationSharedShortAddressString
-- Description			: Returns representation of short address string of shared geolocation record.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--
-- Testing code:
/*
--Example of function call:

DECLARE @GeoLocation BIGINT = 177
SELECT dbo.FN_GBL_GeoLocationSharedShortAddressString (
   'en'
  ,@GeoLocation
  ,null)

*/

CREATE FUNCTION [dbo].[FN_GBL_GeoLocationSharedShortAddressString] 
(
	@LangID  NVARCHAR(50),
	@GeoLocation BIGINT,   -- geolocation record ID
	@GeoLocationType BIGINT = NULL -- desired Type of geolocation string. If NULL, the idfsGeoLocationType value of geolocation record is used 
)  
RETURNS NVARCHAR(1000)
AS 
BEGIN
	DECLARE @PostalCode			NVARCHAR(200)
	DECLARE @Street				NVARCHAR(200)
	DECLARE @House				NVARCHAR(200)
	DECLARE @Building			NVARCHAR(200)
	DECLARE @Appartment			NVARCHAR(200)
	DECLARE @blnForeignAddress	BIT

	SELECT	
		@GeoLocationType = ISNULL(@GeoLocationType, LS.idfsGeoLocationType),
		@PostalCode =  ISNULL(LS.strPostCode,N''),
		@Street =  ISNULL(LS.strStreetName,N''),
		@House =  ISNULL(LS.strHouse,N''),
		@Building =  ISNULL(LS.strBuilding,N''),
		@Appartment =  ISNULL(LS.strApartment,N''),
		@blnForeignAddress = ISNULL(LS.blnForeignAddress, 0)
	FROM dbo.tlbGeoLocationShared LS
	WHERE LS.idfGeoLocationShared = @GeoLocation

	IF	ISNULL(@GeoLocationType, 0) <> 10036001
		SET	@blnForeignAddress = 1

	RETURN dbo.FN_GBL_CreateShortAddressString 
	(
	  @PostalCode,
	  @Street,
	  @House,
	  @Building,
	  @Appartment,
	  @blnForeignAddress
	)
END


