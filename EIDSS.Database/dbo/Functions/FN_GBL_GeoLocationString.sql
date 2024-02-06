

--*************************************************************
-- Name 				: FN_GBL_GeoLocationString
-- Description			: Returns text representation of geolocation record.
-- Author               : Joan Li
-- Revision History
--		Name			Date			Change Detail
--		Joan Li			10/24/2017		convert from v6: FN_GBL_GeoLocationString
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--		Mark Wilson		07/22/2021	remove use of 'en'
--
-- Testing code:
/* 
	DECLARE @GeoLocation BIGINT = 1310000240
	SELECT dbo.FN_GBL_GeoLocationString ( 'en-US', @GeoLocation,NULL)
	SELECT dbo.FN_GBL_GeoLocationString ( 'az-Latn-AZ', @GeoLocation,NULL)

*/
--*************************************************************


CREATE        FUNCTION [dbo].[FN_GBL_GeoLocationString] 
(
	@LangID				NVARCHAR(50),	--##PARAM @LangID - lanquage ID
	@GeoLocation		BIGINT,			--##PARAM @GeoLocation - geolocation record ID
	@GeoLocationType	BIGINT = NULL	--##PARAM @GeoLocationType - desired Type of geolocation string. If NULL, the idfsGeoLocationType value of geolocation record is used 
)

RETURNS NVARCHAR(1000)
AS 
BEGIN
	DECLARE 
		 @Country				NVARCHAR(200)
		,@Region				NVARCHAR(200)
		,@Rayon					NVARCHAR(200)
		,@Latitude				NVARCHAR(200)
		,@Longitude				NVARCHAR(200)
		,@PostalCode			NVARCHAR(200)
		,@SettlementType		NVARCHAR(200)
		,@Settlement			NVARCHAR(200)
		,@Street				NVARCHAR(200)
		,@House					NVARCHAR(200)
		,@Building				NVARCHAR(200)
		,@Appartment			NVARCHAR(200)
		,@ResidentType			NVARCHAR(200)
		,@Alignment				NVARCHAR(200)
		,@Distance				NVARCHAR(200)
		,@blnForeignAddress		BIT
		,@strForeignAddress		NVARCHAR(200)

	SELECT	
		@GeoLocationType = ISNULL(@GeoLocationType, L.idfsGeoLocationType),
		@Country =  ISNULL(LR.Country,N''),
		@Region =  ISNULL(LR.Region,N''),
		@Rayon =  ISNULL(LR.Rayon,N''),
		@Latitude =  REPLACE(CAST(ISNULL(L.dblLatitude ,N'') AS DECIMAL(8, 5)), '0.00000', N'0'),
		@Longitude =  REPLACE(CAST(ISNULL(L.dblLongitude ,N'') AS DECIMAL(8, 5)), '0.00000', N'0'),
		@PostalCode =  ISNULL(L.strPostCode,N''),
		@SettlementType =  ISNULL(LR.SettlementType,N''),
		@Settlement =  ISNULL(LR.Settlement,N''),
		@Street =  ISNULL(L.strStreetName,N''),
		@House =  ISNULL(L.strHouse,N''),
		@Building =  ISNULL(L.strBuilding,N''),
		@Appartment =  ISNULL(L.strApartment,N''),
		@Alignment =  ISNULL(L.dblAlignment,N''),
		@Distance =  ISNULL(L.dblDistance,N''),
		@blnForeignAddress = ISNULL(L.blnForeignAddress, 0),
		@strForeignAddress =  ISNULL(L.strForeignAddress,N'')

	FROM dbo.tlbGeoLocation L
	INNER JOIN dbo.FN_GBL_GeoLocationAsRow(@LangID) LR ON L.idfGeoLocation = LR.idfGeoLocation
	WHERE	L.idfGeoLocation = @GeoLocation
	RETURN 
		dbo.FN_GBL_CreateGeoLocationString 
		(
		   @LangID
		  ,@GeoLocationType
		  ,@Country
		  ,@Region
		  ,@Rayon
		  ,@Latitude
		  ,@Longitude
		  ,@PostalCode
		  ,@SettlementType
		  ,@Settlement
		  ,@Street
		  ,@House
		  ,@Building
		  ,@Appartment
		  ,@Alignment
		  ,@Distance
		  ,@blnForeignAddress
		  ,@strForeignAddress
		)
END

