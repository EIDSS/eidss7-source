
--*************************************************************************
-- Name 				: report.USP_REP_Region_SelectLookup
-- Description			: To Get the Region List 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_Region_SelectLookup 'en' 
EXEC report.USP_REP_Region_SelectLookup 'en' ,1344330000000
*/
    
CREATE PROCEDURE [Report].[USP_REP_Region_SelectLookup]
	@LangID AS NVARCHAR(50),
	@ID AS BIGINT = NULL
AS
	DECLARE @CountryID BIGINT
BEGIN

	SELECT	@CountryID= tcp1.idfsCountry
 	FROM	tstCustomizationPackage tcp1
	JOIN	tstSite s ON
		s.idfCustomizationPackage = tcp1.idfCustomizationPackage
 	INNER JOIN	tstLocalSiteOptions lso
 	ON		lso.strName = N'SiteID'
 			AND lso.strValue = CAST(s.idfsSite AS NVARCHAR(20))
 	
 	SELECT		
		0 AS idfsRegion, 
		'' AS strRegionName, 
		'' AS strRegionExtendedName, 
		'' AS strRegionCode, 
		0 AS idfsCountry, 
		0 AS intRowStatus,
		'' AS strCountryName
	UNION ALL
	SELECT	
		region.idfsReference AS idfsRegion, 
		region.[name] AS strRegionName, 
		region.[ExtendedName] AS strRegionExtendedName, 
		gisRegion.strCode AS strRegionCode, 
		gisRegion.idfsCountry, 
		region.intRowStatus,
		country.name AS strCountryName
	FROM dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000003) region--'rftRegion'
	INNER JOIN gisRegion ON idfsReference = gisRegion.idfsRegion 
	INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000001) country ON country.idfsReference = gisRegion.idfsCountry

	WHERE	
		gisRegion.idfsCountry = isnull(@CountryID, gisRegion.idfsCountry)
		AND (@ID IS NULL OR @ID = gisRegion.idfsRegion)
		AND gisRegion.idfsCountry IN (SELECT DISTINCT idfsCountry FROM tstSite)
	ORDER BY strRegionName
END

