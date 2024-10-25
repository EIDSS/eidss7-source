
--*************************************************************************************************
-- Name: FN_GBL_GIS_ReferenceRepair_GET
--
-- Description: 
--
-- Revision History:
-- Name Date Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli 04/10/2021 Initial release.

-- Testing code:
/*
 SELECT * FROM report.FN_GBL_GIS_ReferenceRepair_GET('en',19000001) --Country
 SELECT * FROM report.FN_GBL_GIS_ReferenceRepair_GET('en',19000003)	--Region
 SELECT * FROM report.FN_GBL_GIS_ReferenceRepair_GET('en',19000002) --Rayon
 SELECT * FROM report.FN_GBL_GIS_ReferenceRepair_GET('en',19000004) --Settlement

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************


CREATE FUNCTION [Report].[FN_GBL_GIS_ReferenceRepair_GET](@LangID  NVARCHAR(50), @type BIGINT)
RETURNS @GIS_ReferenceRepair TABLE
	(
        idfsReference BIGINT,
        node HIERARCHYID,
        [name] NVARCHAR(255),
        idfsGISReferenceType BIGINT,
        strDefault NVARCHAR(200),
        LongName NVARCHAR(255),
        intOrder INT,
        ExtendedName NVARCHAR(200),
        intRowStatus INT
    )
AS
BEGIN
     DECLARE @CountryNode HIERARCHYID,
			 @SettlementRefType BIGINT

	SELECT @CountryNode = node FROM gisLocation WHERE idfsLocation = dbo.FN_GBL_CURRENTCOUNTRY_GET()	
	SELECT @SettlementRefType = idfsGISReferenceType from dbo.gisReferenceType where strGISReferenceTypeName='Settlement'
	
	INSERT INTO @GIS_ReferenceRepair
	SELECT
		br.idfsGISBaseReference AS idfsReference, 
		L.node,
		ISNULL(snt.strTextString, br.strDefault) AS [name],
		br.idfsGISReferenceType, 
		br.strDefault, 
		ISNULL(snt.strTextString, br.strDefault) AS LongName,
		br.intOrder,
		CASE @type WHEN	@SettlementRefType THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + CAST(L.dblLatitude AS NVARCHAR) + N'; ' + CAST(L.dblLongitude AS NVARCHAR) + N')', N'')-- rftSettlement/Administrative Level 4
				   ELSE	ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + L.strHASC + N')', N'') 
		END AS ExtendedName,
		br.intRowStatus

	FROM dbo.gisBaseReference AS br 
	INNER JOIN dbo.gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
    INNER JOIN dbo.gisLocation l ON l.idfsLocation = br.idfsGISBaseReference
	INNER JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
	WHERE rt.idfsGISReferenceType =@type and l.node.IsDescendantOf(@CountryNode) = 1
                                                     
	RETURN
END


