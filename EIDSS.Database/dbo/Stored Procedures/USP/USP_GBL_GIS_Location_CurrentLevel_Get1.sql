

--*************************************************************************************************
-- Name: USP_GBL_GIS_Location_CurrentLevel_Get
--
-- Description: To get the Administrative level List for the required level
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 03/31/2021 Initial release.
-- Mark Wilson 07/16/2021 updated to use dbo objects
-- Mani 01/20/2022 Added Order By
-- Testing code:
/*
EXEC USP_GBL_GIS_Location_CurrentLevel_Get 'ru', 1					-- Administrative Level 0 --Country
EXEC USP_GBL_GIS_Location_CurrentLevel_Get1 'en-US', 1,1					-- Administrative Level 1 --Region
EXEC USP_GBL_GIS_Location_CurrentLevel_Get 'ru', 2					-- Administrative Level 2 --Rayon
EXEC USP_GBL_GIS_Location_CurrentLevel_Get 'az-Latn-AZ', 3				-- Administrative Level 3 --Settlement

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************

CREATE PROCEDURE [dbo].[USP_GBL_GIS_Location_CurrentLevel_Get1]
(
	@LangID NVARCHAR(10),
	@CurrentLevel INT,
	@AllCountries BIT = 0
)
AS
	DECLARE @CountryNodes TABLE(CountryNode HIERARCHYID)
	DECLARE		@idfsGISReferenceType BIGINT

	IF @AllCountries=0
	BEGIN
		INSERT INTO @CountryNodes(CountryNode)
		SELECT node FROM gisLocation WHERE idfsLocation = dbo.FN_GBL_CURRENTCOUNTRY_GET()
	END
	ELSE
	BEGIN

	INSERT INTO @CountryNodes(CountryNode)
		SELECT node FROM gisLocation WHERE idfsLocation in  (SELECT  DISTINCT tcp1.idfsCountry
																FROM dbo.tstSite ts
																JOIN dbo.tstCustomizationPackage tcp1 
																ON tcp1.idfCustomizationPackage = ts.idfCustomizationPackage)
		
	END

	--SELECT CountryNode FROM @CountryNodes

	SELECT
			l.node.GetLevel() AS Level,
			br.idfsGISReferenceType, 
			ISNULL(lang.Name,rt.strGISReferenceTypeName) AS strGISReferenceTypeName,
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
	--WHERE l.node.GetLevel()=@CurrentLevel
	WHERE l.node.GetAncestor(@CurrentLevel) IN (SELECT CountryNode FROM @CountryNodes)
	ORDER BY Name

