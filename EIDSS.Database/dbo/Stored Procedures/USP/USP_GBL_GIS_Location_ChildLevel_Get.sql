-- *************************************************************************************************
-- Name: USP_GBL_GIS_Location_Level_Get
--
-- Description: To get the Administrative Child Level List for the selected Parent List.
--
-- Revision History:
-- Name				Date		Change Detail
-- ---------------	----------	--------------------------------------------------------------------
-- Srini Goli		03/31/2021	Initial release.
-- Mark Wilson		10/04/2021	Changed to dbo functions
--  Mani			01/20/2022	added order by
--  Mani			01/05/2023 added introwstatus =0 condition
-- Testing code:
/*
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'en-US', 0										-- If You select zero(Nothing) in parenet level return zero
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'en-US' 											-- Administrative Level 1 --Region --Default Setup Country
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'en-US','170000000'								-- Administrative Level 1 --Region --Default Setup Country
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'ru-RU', '1344330000000'							-- Administrative Level 2 --Rayon
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'en-US', '1344330000000,1344340000000'			-- Administrative Level 2 --Rayon
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'az-Latn-AZ', 1344490000000							-- Administrative Level 3 --Settlement
EXEC USP_GBL_GIS_Location_ChildLevel_Get 'en-US', 1344490000000							-- Administrative Level 3 --Settlement

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************

CREATE PROCEDURE [dbo].[USP_GBL_GIS_Location_ChildLevel_Get]
(
	@LangID NVARCHAR(10),
	@Parent_idfsReference AS NVARCHAR(MAX) = NULL
)
AS
	DECLARE @CountryNode HIERARCHYID,
			@ParentNode HIERARCHYID,
			@Country_idfsLocation AS BIGINT
			
	DECLARE @Parent_idfsReferenceTable	TABLE
		(
				idfsReference BIGINT		
		)

	DECLARE @Parent_NodeTable	TABLE
			(
					node HIERARCHYID		
			)
	SELECT	
		@CountryNode = node,
		@Country_idfsLocation=idfsLocation 
	FROM dbo.gisLocation 
	WHERE idfsLocation = dbo.FN_GBL_CURRENTCOUNTRY_GET() and intRowStatus=0
	
	IF (@Parent_idfsReference IS NULL) SET @Parent_idfsReference = CAST(@Country_idfsLocation AS NVARCHAR(50))
		

	INSERT INTO @Parent_idfsReferenceTable 
	SELECT CAST([Value] AS BIGINT) FROM dbo.FN_GBL_SYS_SplitList(@Parent_idfsReference,1,',')

	INSERT INTO @Parent_nodeTable 
	SELECT l.node AS ParentNode
	FROM dbo.gisLocation l
	INNER JOIN dbo.gisBaseReference br ON br.idfsGISBaseReference=l.idfsLocation
	WHERE idfsGISBaseReference IN (SELECT idfsReference FROM @Parent_idfsReferenceTable) and br.intRowStatus=0
	
	IF @Parent_idfsReference='0' 
		SELECT TOP 1
			l.node.GetLevel() AS Level,
			br.idfsGISReferenceType, 
			ISNULL(lang.Name,rt.strGISReferenceTypeName) AS strGISReferenceTypeName,
			br.idfsGISBaseReference AS idfsReference,
			ISNULL(snt.strTextString, br.strDefault) [Name],
			--l.Node,
			l.node.ToString() strNode,
			l.strHASC,
			l.strCode,
			l.idfsType LevelType

		FROM dbo.gisBaseReference AS br 
		INNER JOIN dbo.gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		INNER JOIN dbo.gisLocation l ON l.idfsLocation = br.idfsGISBaseReference
		INNER JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000003) lang ON lang.strDefault=rt.strGISReferenceTypeName
		WHERE 1=2 and  br.intRowStatus=0 and rt.intRowStatus =0
	ELSE
		SELECT
			l.node.GetLevel() AS Level,
			br.idfsGISReferenceType, 
			ISNULL(lang.Name,rt.strGISReferenceTypeName) AS strGISReferenceTypeName,
			br.idfsGISBaseReference AS idfsReference,
			ISNULL(snt.strTextString, br.strDefault) [Name],
			--l.Node,
			l.node.ToString() strNode,
			l.strHASC,
			l.strCode,
			l.idfsType LevelType
		FROM dbo.gisBaseReference AS br 
		INNER JOIN dbo.gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		INNER JOIN dbo.gisLocation l ON l.idfsLocation = br.idfsGISBaseReference
		INNER JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000003) lang ON lang.strDefault=rt.strGISReferenceTypeName
		INNER JOIN @Parent_nodeTable pn  ON pn.node=l.node.GetAncestor(1)
		where  br.intRowStatus=0 and rt.intRowStatus =0
		ORDER BY Name


