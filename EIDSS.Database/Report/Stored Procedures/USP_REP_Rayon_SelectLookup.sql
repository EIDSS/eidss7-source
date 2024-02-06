
--*************************************************************************
-- Name 				: report.USP_REP_Rayon_SelectLookup
-- Description			: Get the List of Rayons based on the selection of Regions
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--		
-- Testing code:
--
--EXEC report.USP_REP_Rayon_SelectLookup 'en', null, null
--EXEC report.USP_REP_Rayon_SelectLookup 'en' , '37020000000,37030000000', NULL
--EXEC report.USP_REP_Rayon_SelectLookup 'en' , 37020000000, NULL
--*************************************************************************

CREATE PROCEDURE [Report].[USP_REP_Rayon_SelectLookup]
	@LangID AS NVARCHAR(50),
	@RegionID AS NVARCHAR(MAX) = NULL ,
	@ID AS BIGINT = NULL

AS

IF @RegionID='0' SET @RegionID = NULL
	
DECLARE @RegionIDTable	TABLE
		(
				idfsRegoin BIGINT		
		)	
	
INSERT INTO @RegionIDTable 
SELECT CAST([Value] AS BIGINT) FROM report.FN_GBL_SYS_SplitList(@RegionID,1,',')

SELECT 
	0 as idfsRayon
	,'' as strRayonName
	,'' as strRayonExtendedName
	,0 idfsRegion
	,0 idfsCountry
	,0 intRowStatus
	,'' as strRegionExtendedName
	,'' as strCountryName,
	'' as strCountryExtendedName 
UNION ALL
SELECT	
	rayon.idfsReference as idfsRayon
	,rayon.[name] as strRayonName
	,rayon.[ExtendedName] as strRayonExtendedName
	,gisRayon.idfsRegion
	,gisRayon.idfsCountry
	,rayon.intRowStatus
	,region.ExtendedName as strRegionExtendedName
	,country.name as strCountryName,
	 country.[ExtendedName] as strCountryExtendedName 
FROM dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000002) rayon--'rftRayon' 
JOIN gisRayon ON	rayon.idfsReference = gisRayon.idfsRayon 
JOIN gisCountry	ON	gisRayon.idfsCountry = gisCountry.idfsCountry
JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000003) region ON region.idfsReference = gisRayon.idfsRegion
JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000001) country ON country.idfsReference = gisRayon.idfsCountry
WHERE	
	(@RegionID IS NULL OR gisRayon.idfsRegion IN (SELECT idfsRegoin FROM @RegionIDTable))
	AND (@ID IS NULL OR @ID = idfsRayon)
	and gisRayon.idfsCountry in (select distinct strvalue from tstGlobalSiteOptions where strName = 'CustomizationCountry')
ORDER BY strRayonName

