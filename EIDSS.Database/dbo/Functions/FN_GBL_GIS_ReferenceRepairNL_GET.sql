

--*************************************************************************************************
-- Name: FN_GBL_GIS_ReferenceRepairNL_GET
--
-- Description: 
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Olga Mirnaya    10/10/2023 New version of the function FN_GBL_GIS_ReferenceRepair_GET 
--                            for better indexing

-- Testing code:
/*
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepairNL_GET('en-US',19000001) --Country
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepairNL_GET('en-US',19000003)	--Region
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepairNL_GET('en-US',19000002) --Rayon
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepairNL_GET('en-US',19000004) --Settlement

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************
CREATE FUNCTION [dbo].[FN_GBL_GIS_ReferenceRepairNL_GET]
(
	@LangID  NVARCHAR(50), 
	@type BIGINT
	
)
RETURNS TABLE
AS
	RETURN(

	SELECT
		l.idfsLocation AS idfsReference, 
		l.[node],
		ISNULL(snt.strTextString, br.strDefault) AS [name],
		br.idfsGISReferenceType, 
		br.strDefault, 
		ISNULL(snt.strTextString, br.strDefault) AS LongName,
		br.intOrder,
		CASE @type 
				WHEN 19000004 THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + CAST(L.dblLatitude AS NVARCHAR(100)) + N'; ' + CAST(L.dblLongitude AS NVARCHAR(100)) + N')', N'') 
				ELSE ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + L.strHASC + N')', N'') 
		END AS ExtendedName,
		br.intRowStatus,
		l.idfsType,
		l.nodeLevel
    FROM dbo.gisLocation l 
    JOIN dbo.gisBaseReference br ON br.idfsGISBaseReference = l.idfsLocation
    JOIN dbo.gisStringNameTranslation snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
    JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
    WHERE rt.idfsGISReferenceType = @type
		)
