

--*************************************************************
-- Name 				: FN_GBL_GeoLocationSharedAsRow
-- Description			: Returns representation of short address string of shared geolocation record.
-- Author               : Mark Wilson
-- Revision History
--		Name			Date			Change Detail
--		Mark Wilson		09/02/2020	Full conversion to E7 standards
--		SV and MW		10/13/2021	re-worked to join gislocations and filter idfsLocation is null and return settlementtype
--
--*************************************************************
--Example of a call of procedure:
/*

select * from FN_GBL_GeoLocationSharedAsRow ('en-US') where idfGeoLocationShared = 380000728
select * from FN_GBL_GeoLocationSharedAsRow ('az-Latn-AZ') where idfGeoLocationShared = 2120000785

*/
CREATE FUNCTION [dbo].[FN_GBL_GeoLocationSharedAsRow]
(
	@LangID NVARCHAR(50) --##PARAM @LangID  - language ID
)
RETURNS TABLE
AS
RETURN(

	SELECT		
		l.idfGeoLocationShared,
		l.idfsGeoLocationType,
		ISNULL(a1.[name], '') AS Country,
		ISNULL(a2.[name], '') AS Region,
		ISNULL(a3.[name], '') AS Rayon,
		ISNULL(LocationType.[name], '') AS SettlementType,
		ISNULL(a4.[name], '') AS Settlement,
		ISNULL(l.dblLatitude, '') AS Latitude,
		ISNULL(l.dblLongitude, '') AS Longitude,
		ISNULL(l.strDescription, '') AS Description,
		ISNULL(l.strPostCode, '') AS PostalCode,
		ISNULL(l.strStreetName, '') AS Street,
		ISNULL(l.strHouse, '') AS House,
		ISNULL(l.strBuilding, '') AS Building,
		ISNULL(l.strApartment, '') AS Appartment,
		ISNULL(l.dblAlignment, '') AS Alignment,
		ISNULL(l.dblDistance, '') AS Distance,
		ISNULL(GroundType.[name], '') AS GroundType


	FROM  dbo.tlbGeoLocationShared l
	INNER JOIN dbo.gisLocation gisL ON gisL.idfsLocation = l.idfsLocation
	INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) a1 ON gisl.node.IsDescendantOf(a1.node) = 1
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) a2 ON a2.node.GetAncestor(1) = a1.node AND gisl.node.IsDescendantOf(a2.node) = 1
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) a3 ON a3.node.GetAncestor(1) = a2.node AND gisl.node.IsDescendantOf(a3.node) = 1
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) a4 ON a4.node.GetAncestor(1) = a3.node AND gisl.node.IsDescendantOf(a4.node) = 1
	LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair(@LangID, 19000005) LocationType ON LocationType.idfsReference = a4.idfsType 
	LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000038) GroundType ON GroundType.idfsReference = l.idfsGroundType
	WHERE l.intRowStatus = 0 AND l.idfsLocation IS NOT NULL

	)
