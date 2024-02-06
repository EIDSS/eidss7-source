
--*************************************************************
-- Name 				: report.FN_REP_AddressSharedString
-- Description			: Returns idfsLanguage  
--						
-- Author               : Mark Wilson
-- Revision History
--
--		Name       Date       Change Detail
--
-- Testing code:
--
-- SELECT report.FN_REP_AddressSharedString('en', 1)
-- SELECT report.FN_REP_AddressSharedString('en', 76) 
--
--*************************************************************

CREATE FUNCTION [Report].[FN_REP_AddressSharedString]
(
	@LangID NVARCHAR(50), 
	@GeoLocation BIGINT
)
RETURNS NVARCHAR(1000)
AS
	BEGIN
	declare @Country nvarchar(200)
	declare @Region nvarchar(200)
	declare @Rayon nvarchar(200)
	declare @PostCode nvarchar(200)
	declare @SettlementType nvarchar(200)
	declare @Settlement nvarchar(200)
	declare @Street nvarchar(200)
	declare @House nvarchar(200)
	declare @Bilding nvarchar(200)
	declare @Appartment nvarchar(200)
	declare @type nvarchar(200)
	DECLARE @blnForeignAddress	bit
	DECLARE @strForeignAddress	nvarchar(200)

	SELECT		@Country	= ISNULL(rfCountry.[name], ''),
				@Region		= ISNULL(rfRegion.[name], ''),
				@Rayon		= ISNULL(rfRayon.[name], ''),
				@PostCode	= ISNULL(tLocation.strPostCode, ''),
				@SettlementType = ISNULL(rfSettlementType.[name], ''),
				@Settlement = ISNULL(rfSettlement.[name], ''),
				@Street		= ISNULL(tLocation.strStreetName, ''),
				@House		= ISNULL(tLocation.strHouse, ''),
				@Bilding	= ISNULL(tLocation.strBuilding, ''),
				@Appartment = ISNULL(tLocation.strApartment, ''),
				@blnForeignAddress = ISNULL(tLocation.blnForeignAddress, 0),
				@strForeignAddress =  ISNULL(tLocation.strForeignAddress,N'')

	FROM
	(  
		dbo.tlbGeoLocationShared tLocation
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID, 19000001 /*'rftCountry'*/) rfCountry 
				ON	rfCountry.idfsReference = tLocation.idfsCountry
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID, 19000003 /*'rftRegion'*/)  rfRegion 
				ON	rfRegion.idfsReference = tLocation.idfsRegion
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID, 19000002 /*'rftRayon'*/)   rfRayon 
				ON	rfRayon.idfsReference = tLocation.idfsRayon
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID, 19000004 /*'rftSettlement'*/) rfSettlement
				ON	rfSettlement.idfsReference = tLocation.idfsSettlement
	)
	LEFT JOIN	
	(
					gisSettlement 
		INNER JOIN  FN_GBL_GIS_Reference(@LangID, 19000005 /*'rftSettlementType'*/) rfSettlementType 
				ON	rfSettlementType.idfsReference = gisSettlement.idfsSettlementType
	)	
		ON	gisSettlement.idfsSettlement = tLocation.idfsSettlement
	 WHERE	tLocation.idfGeoLocationShared = @GeoLocation
	   AND  tLocation.intRowStatus = 0

	RETURN	report.FN_REP_CreateAddressString(
						@Country,
						@Region,
						@Rayon,
						@PostCode,
						@SettlementType,
						@Settlement,
						@Street,
						@House,
						@Bilding,
						@Appartment,
						@blnForeignAddress,
						@strForeignAddress)

	END
