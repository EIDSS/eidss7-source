

--=====================================================================================================
-- Name: usp_Rayon_GetLookup
--
-- Description: Select lookup list of Rayons from 
--              tables: gisRayon; gisCountry; tstCustomizationPackage
--              Functions: fnGisExtendedReferenceRepair;fnGisReferenceRepair
--
-- renamed sp to usp_ by MCW

--exec usp_Rayon_GetLookup 'en', null, null
--exec usp_Rayon_GetLookup 'en' , 37020000000
--
-- Ann Xiong    2/22/2019 modified to return entire list of Rayons even when @ID IS not NULL.
-- Srini Goli   5/27/2020 modified to eliminate duplicate rayons
-- Mark Wilson  10/16/2020 updated to use E7 artifacts and standards.


CREATE PROCEDURE [dbo].[usp_Rayon_GetLookup]
	@LangID		AS NVARCHAR(50),
	@RegionID	AS BIGINT = NULL ,
	@ID			AS BIGINT = NULL

AS

SELECT	
		rayon.idfsReference AS idfsRayon,
		rayon.name AS strRayonName,
		rayon.LongName AS strRayonExtendedName,
		gisRayon.idfsRegion,
		gisRayon.idfsCountry,
		rayon.intRowStatus,
		region.LongName AS strRegionExtendedName,
		country.name AS strCountryName

FROM dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000002) rayon--'rftRayon' 
JOIN gisRayon ON rayon.idfsReference = gisRayon.idfsRayon 
JOIN gisCountry ON gisRayon.idfsCountry = gisCountry.idfsCountry
JOIN dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000003) region ON region.idfsReference = gisRayon.idfsRegion
JOIN dbo.FN_GBL_GIS_ReferenceRepair(@LangID,19000001) country ON country.idfsReference = gisRayon.idfsCountry

WHERE	
	gisRayon.idfsRegion = ISNULL(@RegionID, gisRayon.idfsRegion)
	AND ( (NOT @RegionID IS NULL) OR  (@ID IS NULL) OR (gisRayon.idfsRegion = @ID) )
	AND gisRayon.idfsCountry = dbo.FN_GBL_CurrentCountry_GET()

ORDER BY strRayonName

