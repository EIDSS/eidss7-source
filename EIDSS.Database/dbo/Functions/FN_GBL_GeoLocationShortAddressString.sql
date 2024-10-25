

--*************************************************************
-- Name 				: FN_GBL_GeoLocationShortAddressString
-- Description			: Returns representation of short address string of geolocation record.
--						: Exec USP_GBL_LKUP_BaseRef_GetList 'EN','Geo Location Type': get hard coded info
-- Author               : Joan Li
-- Revision History
--		Name			Date			Change Detail
--		Joan Li			10/24/2017		convert from v6: FN_GBL_GeoLocationShortAddressString
--
-- Testing code:
-- 
 /*

	DECLARE @GeoLocation BIGINT = 1762;
	DECLARE @GeoLocationType BIGINT = NULL;
	SELECT dbo.FN_GBL_GeoLocationShortAddressString ( 'en', @GeoLocation, @GeoLocationType)

 */
--*************************************************************


CREATE        FUNCTION [dbo].[FN_GBL_GeoLocationShortAddressString] 
(
	@LangID				NVARCHAR(50),	--##PARAM @LangID - lanquage ID
	@GeoLocation		BIGINT,			--##PARAM @GeoLocation - geolocation record ID
	@GeoLocationType	BIGINT = NULL	--##PARAM @GeoLocationType - desired Type of geolocation string. If NULL, the idfsGeoLocationType value of geolocation record is used 
)  
RETURNS NVARCHAR(1000)
AS 
BEGIN
	DECLARE 
	 @PostalCode			NVARCHAR(200)
	,@Street				NVARCHAR(200)
	,@House					NVARCHAR(200)
	,@Building				NVARCHAR(200)
	,@Appartment			NVARCHAR(200)
	,@blnForeignAddress		BIT
	,@l_GeoLocationType		NVARCHAR(200)


	-----JL: replace the hard coded 10036001: which is the idfsBaseReference from trtBaseReference table
	SELECT @l_GeoLocationType=(	SELECT 
									tb.idfsBaseReference 
								FROM dbo.trtBaseReference tb 
								INNER JOIN dbo.trtReferenceType tt ON tb.idfsReferenceType=tt.idfsReferenceType	AND tt.strReferenceTypeName IN ('Geo Location Type') AND tb.strDefault IN ('Foreign Address')
							  )

	SELECT	
		@GeoLocationType = ISNULL(@GeoLocationType, L.idfsGeoLocationType),
		@PostalCode =  ISNULL(L.strPostCode,N''),
		@Street =  ISNULL(L.strStreetName,N''),
		@House =  ISNULL(L.strHouse,N''),
		@Building =  ISNULL(L.strBuilding,N''),
		@Appartment =  ISNULL(L.strApartment,N''),
		@blnForeignAddress = ISNULL(L.blnForeignAddress, 0)
	FROM dbo.tlbGeoLocation L
	WHERE	L.idfGeoLocation = @GeoLocation

	IF	ISNULL(@GeoLocationType, 0) <> @l_GeoLocationType
		SET	@blnForeignAddress = 1

	RETURN dbo.FN_GBL_CreateShortAddressString 
	(
	  @PostalCode
	  ,@Street
	  ,@House
	  ,@Building
	  ,@Appartment
	  ,@blnForeignAddress
	)

END

















