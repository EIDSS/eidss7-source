

--*************************************************************
-- Name 				: FN_GBL_LocationHierarchy_ReferenceRepair_GET
-- Description			: The FUNCTION returns all the reference values 
--          
-- Author               : Mark Wilson - 07 NOV 2019
-- Revision History
-- Name        Date       Change Detail
--
-- Testing code:
-- SELECT * FROM dbo.FN_GBL_LocationHierarchy_ReferenceRepair_GET('en',19000002)
--*************************************************************
-- SELECT all reference values - with deleted values

CREATE FUNCTION [dbo].[FN_GBL_LocationHierarchy_ReferenceRepair_GET](@LangID  NVARCHAR(50), @type BIGINT)
RETURNS TABLE
AS
RETURN
(

	SELECT
		br.idfsGISBaseReference AS idfsReference, 
		ISNULL(snt.strTextString, br.strDefault) AS [name],
		br.idfsGISReferenceType, 
		br.strDefault, 
		ISNULL(snt.strTextString, br.strDefault) AS LongName,
		br.intOrder,
		CASE L.node.GetLevel()	WHEN 1 THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + L.strHASC + N')', N'')	-- rftCountry
								WHEN 2 THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + L.strHASC + N')', N'') -- rftRegion
								WHEN 3 THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + L.strHASC + N')', N'') -- rftRayon
								WHEN 4 THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + CAST(S.dblLatitude AS NVARCHAR) + N'; ' + CAST(s.dblLongitude AS NVARCHAR) + N')', N'')-- rftSettlement
				   ELSE	ISNULL(snt.strTextString, br.strDefault) 
		END AS ExtendedName,
		br.intRowStatus

	FROM dbo.gisBaseReference AS br 
	LEFT JOIN dbo.gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	LEFT JOIN dbo.gisLocation L ON L.idfsLocation = br.idfsGISBaseReference
	LEFT JOIN dbo.gisSettlement S ON S.idfsSettlement = L.idfsLocation
	WHERE br.idfsGISReferenceType = @type 
)
