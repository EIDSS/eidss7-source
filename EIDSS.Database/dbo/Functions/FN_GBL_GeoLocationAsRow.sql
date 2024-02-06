





--*************************************************************
-- Name 				: FN_GBL_GeoLocationAsRow
-- Description			: all geolocation records converting geolocation fields into the text fields in the passed language..
--						  Standard scenario of this function using is joining with main list object on idfGeoLocation field
--			              and futher output of returned geolocation string parts using FN_GBL_CreateGeoLocationString function
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--		SV and MW		10/13/2021	re-worked to join gislocations and filter idfsLocation is null and return settlementtype
--		Mark Wilson		07/13/2022	updated to use FN_GBL_LocationHierarchy_Flattened
--
--*************************************************************
--Example of a call of procedure:
/*

select * from FN_GBL_GeoLocationAsRow ('ka-GE') where idfGeoLocation = 154081130001294
select * from FN_GBL_GeoLocationAsRow ('az-Latn-AZ')

*/
CREATE FUNCTION [dbo].[FN_GBL_GeoLocationAsRow]
(
	@LangID NVARCHAR(50) 
)
RETURNS TABLE
AS
RETURN
(

	SELECT		
		L.idfGeoLocation,
		L.idfsGeoLocationType,
		ISNULL(gisL.AdminLevel1Name, '') AS Country,
		ISNULL(gisL.AdminLevel2Name, '') AS Region,
		ISNULL(gisL.AdminLevel3Name, '') AS Rayon,
		ISNULL(LL.idfsType, '') AS SettlementType,
		ISNULL(gisL.AdminLevel4Name, '') AS Settlement,
		ISNULL(L.dblLatitude, '') AS Latitude,
		ISNULL(L.dblLongitude, '') AS Longitude,
		ISNULL(L.strDescription, '') AS Description,
		ISNULL(L.strPostCode, '') AS PostalCode,
		ISNULL(L.strStreetName, '') AS Street,
		ISNULL(L.strHouse, '') AS House,
		ISNULL(L.strBuilding, '') AS Building,
		ISNULL(L.strApartment, '') AS Appartment,
		ISNULL(L.dblAlignment, '') AS Alignment,
		ISNULL(L.dblDistance, '') AS Distance,
		ISNULL(GroundType.[name], '') AS GroundType,
		ISNULL(blnForeignAddress, 0) AS blnForeignAddress,
		ISNULL(L.strForeignAddress, '') AS strForeignAddress

	FROM  dbo.tlbGeoLocation l
	INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) gisL ON gisL.idfsLocation = l.idfsLocation
	INNER JOIN dbo.gisLocation LL ON LL.idfsLocation = l.idfsLocation
	LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000038) GroundType ON GroundType.idfsReference = l.idfsGroundType
	WHERE l.intRowStatus = 0 AND l.idfsLocation IS NOT NULL


)
