
--*************************************************************************
-- Name 				: report.USP_REP_Settlement_SelectLookup
-- Description			: To Get the Settlements List 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_Settlement_SelectLookup 'en'
EXEC report.USP_REP_Settlement_SelectLookup 'en', 3260000000

*/
CREATE PROCEDURE [Report].[USP_REP_Settlement_SelectLookup]
	@LangID As nvarchar(50),  --##PARAM @LangID - language ID
	@RayonID as bigint = NULL,   --##PARAM @idfsRayon - settlement rayon. If NULL is passed, entire list of settlements is returned
	@ID as bigint = NULL   --##PARAM @ID - ID of specific settlement. If not null, returns only this specific settlement, in other case entire list is returned
AS
SELECT	
	0 AS idfsSettlement 
	,'' AS strSettlementName
	,'' AS strSettlementExtendedName
UNION ALL
SELECT	
	settlement.idfsReference AS idfsSettlement 
	,settlement.name + ' - ' + settlementType.[name] AS strSettlementName
	,settlement.ExtendedName AS strSettlementExtendedName
	--,gisSettlement.idfsRayon,
	--gisSettlement.idfsRegion,
	--gisSettlement.idfsCountry,
	--settlementType.name as strSettlementType,
	--settlement.intRowStatus,
	--country.name as strCountryName,
	--region.ExtendedName as strRegionExtendedName,
	--rayon.ExtendedName as strRayonExtendedName,
	--gisSettlement.intElevation
FROM dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000004) settlement
INNER JOIN 	gisSettlement ON settlement.idfsReference = gisSettlement.idfsSettlement 
join tstCustomizationPackage tcpac ON tcpac.idfsCountry = gisSettlement.idfsCountry
inner join tstSite ON tstSite.idfCustomizationPackage=tcpac.idfCustomizationPackage AND tstSite.idfsSite=dbo.FN_GBL_SITEID_GET()
left join dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000005) settlementType ON settlementType.idfsReference = gisSettlement.idfsSettlementType
left join dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000003) region ON region.idfsReference = gisSettlement.idfsRegion
left join dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000002) rayon ON rayon.idfsReference = gisSettlement.idfsRayon
left join dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000001) country ON country.idfsReference = gisSettlement.idfsCountry

WHERE	
( @RayonID IS NULL OR gisSettlement.idfsRayon = @RayonID )
	AND ( (NOT @RayonID IS NULL)OR  (@ID IS NULL) OR (gisSettlement.idfsSettlement = @ID) )
ORDER BY strSettlementName




