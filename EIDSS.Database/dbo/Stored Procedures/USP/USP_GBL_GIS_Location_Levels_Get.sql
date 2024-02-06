




--*************************************************************************************************
-- Name: USP_GBL_GIS_Location_Levels_Get
--
-- Description: To get the available levels
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 02/25/2021 Initial release.

-- Testing code
/*
Exec [dbo].[USP_GBL_GIS_Location_Levels_Get] 'en'
Exec [dbo].[USP_GBL_GIS_Location_Levels_Get] 'ru'
Exec [dbo].[USP_GBL_GIS_Location_Levels_Get] 'az-l'
*/
-- ************************************************************************************************

CREATE PROCEDURE [dbo].[USP_GBL_GIS_Location_Levels_Get] (@LangID AS NVARCHAR(10))
AS
BEGIN
DECLARE @CountryNode HIERARCHYID
SELECT @CountryNode = node FROM gisLocation WHERE idfsLocation = dbo.FN_GBL_CURRENTCOUNTRY_GET()	
	
SELECT DISTINCT
	l.node.GetLevel() AS Level,
	br.idfsGISReferenceType, 
	rt.strGISReferenceTypeName AS strDefault,
	ISNULL(lang.Name,rt.strGISReferenceTypeName) AS Name

FROM dbo.gisBaseReference AS br 
INNER JOIN dbo.gisLocation l ON l.idfsLocation = br.idfsGISBaseReference
INNER JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000003) lang ON lang.strDefault=rt.strGISReferenceTypeName
WHERE  l.node.IsDescendantOf(@CountryNode) = 1 and br.intRowStatus=0 and rt.intRowStatus =0
END


