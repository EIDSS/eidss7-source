
--*************************************************************
-- Name 				: USP_Region_GET
-- Description			: Returns list of Regions/translations
--						
-- Author               : Mark Wilson - Nov 2019
-- Revision History
--
--
-- Testing code:
-- 
--exec dbo.USP_Region_GET 'en'
--exec dbo.USP_Region_GET 'ru'
--exec dbo.USP_Region_GET 'ka'

CREATE PROCEDURE [dbo].[USP_Region_Get]
(
	@LangID AS NVARCHAR(50)
)
AS
SELECT	
	RT.idfsReference AS idfsRegion, 
	RT.[name] AS strRegionName, 
	RT.LongName AS strRegionExtendedName, 
	R.strCode AS strRegionCode, 
	R.idfsCountry, 
	R.intRowStatus,
	CT.[name] AS strCountryName

FROM dbo.gisRegion R
INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) CT ON CT.idfsReference = R.idfsCountry  -- Country = 19000001
INNER JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000003) RT ON RT.idfsReference = R.idfsRegion-- Region = 19000003


WHERE	
	R.idfsCountry = ISNULL(dbo.FN_GBL_CurrentCountry_GET(), R.idfsCountry)
ORDER BY RT.[name]

