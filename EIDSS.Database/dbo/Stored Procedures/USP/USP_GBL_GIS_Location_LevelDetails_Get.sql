--*************************************************************************************************
-- Name: USP_GBL_GIS_Location_Levels_Get
--
-- Description: To get the available levels
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 02/25/2021 Initial release.
-- Mark Wilson 07/16/2021 updated to use dbo artifacts
-- Mani 01/20/2022 Added order by

-- Testing code
/*
Exec [dbo].[USP_GBL_GIS_Location_LevelDetails_Get] 'en-US'
Exec [dbo].[USP_GBL_GIS_Location_LevelDetails_Get] 'en-US'

*/
-- ************************************************************************************************

CREATE PROCEDURE [dbo].[USP_GBL_GIS_Location_LevelDetails_Get](@LangID NVARCHAR(50))
AS
BEGIN
DECLARE @CountryNode HIERARCHYID
SELECT @CountryNode = node FROM gisLocation WHERE idfsLocation = dbo.FN_GBL_CURRENTCOUNTRY_GET()	
	
SELECT
			l.node.GetLevel() as Level,
			br.idfsGISReferenceType, 
			ISNULL(lang.Name,rt.strGISReferenceTypeName) as strGISReferenceTypeName,
			br.idfsGISBaseReference AS idfsReference,
			ISNULL(snt.strTextString, br.strDefault) [Name],
			--l.Node,
			l.node.ToString() strNode,
			strHASC,
			strCode
		FROM dbo.gisBaseReference AS br 
		INNER JOIN dbo.gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		INNER JOIN dbo.gisLocation l ON l.idfsLocation = br.idfsGISBaseReference
		INNER JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000003) lang ON lang.strDefault=rt.strGISReferenceTypeName
WHERE  l.node.IsDescendantOf(@CountryNode) = 1 and br.intRowStatus=0 and rt.intRowStatus =0
order by name
END



