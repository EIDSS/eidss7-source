

--*************************************************************************************************
-- Name: USP_GBL_GIS_Location_CurrentLevel_Get
--
-- Description: To get the Administrative level List for the required level
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 03/31/2021 Initial release.
-- Mani 01/05/2023 added introwstatus =0 condition

-- Testing code:
/*
EXEC Report.USP_GBL_GIS_Location_CurrentLevel_Get 'az-1', 0						-- Administrative Level 0 --Country
EXEC Report.USP_GBL_GIS_Location_CurrentLevel_Get 'en-US', 1						-- Administrative Level 1 --Region
EXEC Report.USP_GBL_GIS_Location_CurrentLevel_Get 'en-US', 2						-- Administrative Level 2 --Rayon
EXEC Report.USP_GBL_GIS_Location_CurrentLevel_Get 'ru', 3					    -- Administrative Level 3 --Settlement

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************

CREATE PROCEDURE [Report].[USP_GBL_GIS_Location_CurrentLevel_Get]
(
	@LangID NVARCHAR(50),
	@CurrentLevel INT = 0
)
AS
	DECLARE @CountryNode HIERARCHYID,
			@idfsGISReferenceType BIGINT

	SELECT @CountryNode = node FROM gisLocation WHERE idfsLocation = dbo.FN_GBL_CURRENTCOUNTRY_GET()	   
	
	SELECT 
		0 as idfsReference
		,'' as [Name]
	UNION ALL
	SELECT
		br.idfsGISBaseReference AS idfsReference
		,ISNULL(snt.strTextString, br.strDefault) [Name]
	FROM dbo.gisBaseReference AS br 
	INNER JOIN dbo.gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	INNER JOIN dbo.gisLocation l ON l.idfsLocation = br.idfsGISBaseReference
	INNER JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
	WHERE l.node.GetAncestor(@CurrentLevel) = @CountryNode and br.intRowStatus =0 and rt.intRowStatus =0
	ORDER BY 2
