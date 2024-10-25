
-- ================================================================================================
-- Name: dbo.FN_GBL_AddressString_Deny_Rights
--
-- Description: Create address string from geo information.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
/*
--Example of function call:
select * FROM dbo.tlbGeolocation
select dbo.FN_GBL_AddressString_Deny_Rights ('en-US', 2396550001291, 0)
*/

CREATE FUNCTION [dbo].[FN_GBL_AddressString_Deny_Rights]
	(
		@LangID NVARCHAR(50), 
		@GeoLocation BIGINT,
		@IsSettlement BIT
	)
RETURNS NVARCHAR(1000)
AS
	BEGIN
	DECLARE @Country NVARCHAR(200)
	DECLARE @Region NVARCHAR(200)
	DECLARE @Rayon NVARCHAR(200)
	DECLARE @Settlement NVARCHAR(200)
	DECLARE @blnForeignAddress	BIT

	SELECT		@Country	= ISNULL(rfCountry.[name], ''),
				@Region		= ISNULL(rfRegion.[name], ''),
				@Rayon		= ISNULL(rfRayon.[name], ''),
				@Settlement = ISNULL(rfSettlement.[name], ''),
				@blnForeignAddress = ISNULL(tLocation.blnForeignAddress, 0)

	FROM
	(  
		dbo.tlbGeoLocation tLocation
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000001) rfCountry ON	rfCountry.idfsReference = tLocation.idfsCountry
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000003) rfRegion ON rfRegion.idfsReference = tLocation.idfsRegion
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000002) rfRayon ON rfRayon.idfsReference = tLocation.idfsRayon
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000004) rfSettlement ON rfSettlement.idfsReference = tLocation.idfsSettlement
	)
	 WHERE	tLocation.idfGeoLocation = @GeoLocation
	   AND  tLocation.intRowStatus = 0
	   
	   
	IF (@IsSettlement = 1) 
	SET @Settlement = ''

	RETURN	dbo.FN_GBL_CreateAddressString(
						@Country,
						@Region,
						@Rayon,
						'',
						'',
						@Settlement,
						'*',
						'',
						'',
						'',
						@blnForeignAddress,
						'*')

	END

