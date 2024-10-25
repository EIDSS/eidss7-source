
--=====================================================================================================
-- Created by:				Mark Wilson
-- Description:				06/21/2017: check usp_HumanCaseDeduplication_GetDetail call this  V7 USP77: 
--                          Selects data from these tables: tlbGeoLocation(triggers);gisSettlement(triggers);
--							02/03/2023: Updated by Srini Goli To Improve performance 60B Genral Report
/*
----testing code:
select * from report.FN_GBL_AdressAsRow('ka')
*/
--=====================================================================================================
CREATE FUNCTION [Report].[FN_GBL_AdressAsRow](@LangID NVARCHAR(50))
RETURNS TABLE
AS
RETURN(

SELECT		tlbGeoLocation.idfGeoLocation,
			ISNULL(Country.[name], '') AS Country,
			ISNULL(Region.[name], '') AS Region,
			ISNULL(Rayon.[name], '') AS Rayon,
			ISNULL(tlbGeoLocation.strPostCode, '') AS PostalCode,
			ISNULL(SettlementType.[name], '') AS SettlementType,
			ISNULL(Settlement.[name], '') AS Settlement,
			ISNULL(tlbGeoLocation.strStreetName, '') AS Street,
			ISNULL(tlbGeoLocation.strHouse, '') AS House,
			ISNULL(tlbGeoLocation.strBuilding, '') AS Building,
			ISNULL(tlbGeoLocation.strApartment, '') AS Appartment,
			blnForeignAddress,
			ISNULL(tlbGeoLocation.strForeignAddress, '') AS strForeignAddress


FROM		(
		tlbGeoLocation 

		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000001 ) Country ON Country.idfsReference = tlbGeoLocation.idfsCountry
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair(@LangID, 19000003) Region ON	Region.idfsReference = tlbGeoLocation.idfsRegion
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair(@LangID, 19000002) Rayon ON Rayon.idfsReference = tlbGeoLocation.idfsRayon
		LEFT JOIN	dbo.FN_GBL_GIS_ReferenceRepair(@LangID, 19000004) Settlement ON	Settlement.idfsReference = tlbGeoLocation.idfsSettlement

		LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000038) GroundType ON GroundType.idfsReference = tlbGeoLocation.idfsGroundType
	)
	LEFT JOIN	(
		gisSettlement 
		INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair(@LangID, 19000005) SettlementType	ON SettlementType.idfsReference = gisSettlement.idfsSettlementType
	)ON			gisSettlement.idfsSettlement = tlbGeoLocation.idfsSettlement

WHERE		tlbGeoLocation.intRowStatus = 0

)


GO

