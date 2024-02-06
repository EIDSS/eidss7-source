
--*************************************************************
-- Name 				: FN_GBL_GeoLocationSharedString
-- Description			: Returns representation of short address string of shared geolocation record.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--
-- Testing code:

/*
--Example of function call:

DECLARE @GeoLocation BIGINT = 87
SELECT dbo.FN_GBL_GeoLocationSharedString 
(
   'en'
  ,@GeoLocation
  ,null
)

*/

CREATE FUNCTION [dbo].[FN_GBL_GeoLocationSharedString] 
(
	@LangID  NVARCHAR(50),  --##PARAM @LangID - lanquage ID
	@GeoLocation BIGINT,   --##PARAM @GeoLocation - geolocation record ID
	@GeoLocationType BIGINT = NULL
)   
RETURNS NVARCHAR(1000)
AS 
BEGIN
	DECLARE @Country			nvarchar(200)
	DECLARE @Region				nvarchar(200)
	DECLARE @Rayon				nvarchar(200)
	DECLARE @Latitude			nvarchar(200)
	DECLARE @Longitude			nvarchar(200)
	DECLARE @PostalCode			nvarchar(200)
	DECLARE @SettlementType		nvarchar(200)
	DECLARE @Settlement			nvarchar(200)
	DECLARE @Street				nvarchar(200)
	DECLARE @House				nvarchar(200)
	DECLARE @Building			NVARCHAR(200)
	DECLARE @Appartment			NVARCHAR(200)
	DECLARE @Alignment			NVARCHAR(200)
	DECLARE @Distance			NVARCHAR(200)
	DECLARE @blnForeignAddress	BIT
	DECLARE @strForeignAddress	NVARCHAR(200)

	SELECT	
		@GeoLocationType = ISNULL(@GeoLocationType, LS.idfsGeoLocationType),
		@Country =  ISNULL(GeoLocation.Country,N''),
		@Region =  ISNULL(GeoLocation.Region,N''),
		@Rayon =  ISNULL(GeoLocation.Rayon,N''),
		@Latitude =  REPLACE(CAST(ISNULL(LS.dblLatitude ,N'') AS DECIMAL(8, 5)), '0.00000', N'0'),
		@Longitude =  REPLACE(CAST(ISNULL(LS.dblLongitude ,N'') AS DECIMAL(8, 5)), '0.00000', N'0'),		
		@PostalCode =  ISNULL(LS.strPostCode,N''),
		@SettlementType =  ISNULL(GeoLocation.SettlementType,N''),
		@Settlement =  ISNULL(GeoLocation.Settlement,N''),
		@Street =  ISNULL(LS.strStreetName,N''),
		@House =  ISNULL(LS.strHouse,N''),
		@Building =  ISNULL(LS.strBuilding,N''),
		@Appartment =  ISNULL(LS.strApartment,N''),
		@Alignment =  ISNULL(LS.dblAlignment,N''),
		@Distance =  ISNULL(LS.dblDistance,N''),
		@blnForeignAddress = ISNULL(LS.blnForeignAddress, 0),
		@strForeignAddress =  ISNULL(LS.strForeignAddress,N'')
	FROM dbo.tlbGeoLocationShared LS 
	INNER JOIN FN_GBL_GeoLocationSharedAsRow(@LangID) AS GeoLocation ON LS.idfGeoLocationShared = GeoLocation.idfGeoLocationShared
	WHERE LS.idfGeoLocationShared = @GeoLocation
	RETURN dbo.FN_GBL_CreateGeoLocationString (
	   @LangID,
	   @GeoLocationType,
	   @Country,
	   @Region,
	   @Rayon,
	   @Latitude,
	   @Longitude,
	   @PostalCode,
	   @SettlementType,
	   @Settlement,
	   @Street,
	   @House,
	   @Building,
	   @Appartment,
	   @Alignment,
	   @Distance,
	   @blnForeignAddress,
	   @strForeignAddress)
END
