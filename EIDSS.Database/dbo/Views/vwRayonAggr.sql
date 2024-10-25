
--##SUMMARY SELECTs the list of rayons for aggregate cases. Include virtual rayons. 
--##SUMMARY It is used IN fnAggregateCaseList and IN spRayon_SELECTLookup

--##REMARKS Author: Zurin M.
--##REMARKS CREATE date: 28.08.2013

--##RETURNS Doesn't use

/*
--Example of view call:

SELECT * FROM  dbo.vwRayonAggr
*/
CREATE VIEW [dbo].[vwRayonAggr]
AS 
SELECT	
	b.idfsGISBaseReference AS idfsRayon, 
	ISNULL(c.strTextString, b.strDefault) AS strRayonName, 
	gisRayon.idfsRegion, 
	gisRayon.idfsCountry,
	b.intRowStatus,
	c.idfsLanguage,
	ISNULL(gds.idfsParent, b.idfsGISBaseReference) AS idfsParent

FROM dbo.gisBaseReference AS b 
LEFT JOIN dbo.gisStringNameTranslation AS c ON b.idfsGISBaseReference = c.idfsGISBaseReference
JOIN gisRayon ON b.idfsGISBaseReference = gisRayon.idfsRayon
JOIN gisCOUNTry ON gisRayon.idfsCountry = gisCOUNTry.idfsCountry
LEFT JOIN gisDistrictSubdistrict gds ON gds.idfsGeoObject = gisRayon.idfsRayon

WHERE gisRayon.idfsCountry = dbo.fnCurrentCOUNTry()
AND	b.idfsGISReferenceType = 19000002--'rftRayon'

UNION ALL

SELECT
	rayon.idfsGISBaseReference AS idfsRayon, 
	ISNULL(c.strTextString, rayon.strDefault) AS strRayonName, 
	region.idfsGISBaseReference AS idfsRegion,
	dbo.fnCurrentCOUNTry() AS idfsCountry, 
	rayon.intRowStatus,
	c.idfsLanguage,
	gds.idfsParent
FROM dbo.gisBaseReference AS rayon
LEFT JOIN dbo.gisStringNameTranslation AS c ON rayon.idfsGISBaseReference = c.idfsGISBaseReference
CROSS JOIN dbo.gisBaseReference AS region  --'rftAggrRegion'
LEFT JOIN gisDistrictSubdistrict gds ON gds.idfsGeoObject = rayon.idfsGISBaseReference

WHERE dbo.fnCurrentCOUNTry() = 170000000	
AND rayon.idfsGISReferenceType =  19000021--'rftAggrRayon'
AND region.idfsGISReferenceType =19000020  --'rftAggrRegion'

