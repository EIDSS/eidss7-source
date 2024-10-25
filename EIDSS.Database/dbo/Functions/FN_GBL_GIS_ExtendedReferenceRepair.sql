

CREATE FUNCTION [dbo].[FN_GBL_GIS_ExtendedReferenceRepair](
	@LangID  NVARCHAR(50), 
	@type BIGINT
)  
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

   CASE @type  
   WHEN 19000001 -- rftCOUNTry
		THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + c.strHASC + N')', N'')  
   WHEN 19000003 -- rftRegion  
		THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + r.strHASC + N')', N'')  
   WHEN 19000002 -- rftRayon
		THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + rr.strHASC + N')', N'')    
   WHEN 19000004 -- rftSettlement 
		THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + CAST(s.dblLatitude AS NVARCHAR) + N'; ' + CAST(s.dblLongitude AS NVARCHAR) + N')', N'')   
   ELSE ISNULL(snt.strTextString, br.strDefault) END AS ExtendedName,  

   br.intRowStatus,  

   CASE @type  
   WHEN 19000001 -- rftCOUNTry  
		THEN c.idfsCountry
   WHEN 19000003 -- rftRegion  
		THEN r.idfsRegion
   WHEN 19000002 -- rftRayon  
		THEN ISNULL(gds.idfsParent, rr.idfsRayon)
   WHEN 19000004 -- rftSettlement  
		THEN s.idfsSettlement
   ELSE NULL END AS idfsParent
  
FROM gisBaseReference AS br   
LEFT JOIN gisStringNameTranslation AS snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)  
LEFT JOIN gisCOUNTry c ON @type = 19000001 AND c.idfsCountry = br.idfsGISBaseReference -- COUNTry
LEFT JOIN gisRegion r ON @type = 19000003 AND r.idfsRegion = br.idfsGISBaseReference -- rftRegion    
LEFT JOIN gisRayon rr ON @type = 19000002 AND rr.idfsRayon = br.idfsGISBaseReference -- rftRayon    
LEFT JOIN gisDistrictSubdistrict gds ON gds.idfsGeoObject = rr.idfsRayon
LEFT JOIN gisSettlement s ON @type = 19000004 AND s.idfsSettlement = br.idfsGISBaseReference -- rftSettlement  
      
WHERE  br.idfsGISReferenceType = @type   
)

