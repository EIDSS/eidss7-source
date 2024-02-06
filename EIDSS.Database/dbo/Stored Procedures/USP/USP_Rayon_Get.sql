
--*************************************************************
-- Name 				: USP_Rayon_Get
-- Description			: Returns list of Rayons/translations
--                        Displays all Rayons or Rayons in the RegionID passed
--						
-- Author               : Mark Wilson - Nov 2019
-- Revision History
--
-- Testing code:
-- 
--exec dbo.USP_Rayon_Get 'en', 37130000000
--exec dbo.USP_Rayon_Get 'ru'
--exec dbo.USP_Rayon_Get 'ka', 37020000000

CREATE PROCEDURE [dbo].[USP_Rayon_Get]
(
	@LangID AS NVARCHAR(50),
	@RegionID BIGINT = NULL -- optional parameter
)
AS
SELECT	
	Rayon.idfsRayon AS idfsRayon, 
	RT.[name] AS strRayonName, 
	RT.LongName AS strRayonExtendedName, 
	Rayon.strCode AS strRayonCode, 
	Rayon.idfsCountry, 
	Rayon.intRowStatus,
	CT.[name] AS strCountryName

FROM dbo.gisRayon Rayon
INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) CT ON CT.idfsReference = Rayon.idfsCountry
INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000002) RT ON RT.idfsReference = Rayon.idfsRayon-- Rayon = 19000002

WHERE Rayon.idfsCountry = ISNULL(dbo.FN_GBL_CurrentCountry_GET(), Rayon.idfsCountry)
AND (Rayon.idfsRegion = @RegionID OR @RegionID IS NULL)

ORDER BY RT.[name]

