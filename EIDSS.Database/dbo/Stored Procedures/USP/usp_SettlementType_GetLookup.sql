
--=====================================================================================================
-- Created by:				Joan Li
-- Last modified date:		06/07/2017
-- Last modified by:		Joan Li
-- Description:				06/07/2017:Created based on V6 spSettlementType_SelectLookup: rename for V7 USP49
--                          Select lookup data from tables: gisBaseReference;gisStringNameTranslation
--     
-- Testing code:
/*
----testing code:
exec usp_SettlementType_GetLookup 'en'
*/
-- Revision History:
-- Name					Date			Change Detail
-- ----------------		----------		-----------------------------------------------
-- Leo Tracchia			6/23/2022		added fields for translated string and order
-- Leo Tracchia			6/27/2022		added where for intRowStatus = 0
-- Mani Govindarajan    03/21/2023      Changed to FN_GBL_LanguageCode_GET

--=====================================================================================================

CREATE PROCEDURE [dbo].[usp_SettlementType_GetLookup]
	@LangID nvarchar(50) --##PARAM @LangID - language ID
AS
SELECT	
	gisBaseReference.idfsGISBaseReference AS idfsReference, 
	isnull(gisStringNameTranslation.strTextString, gisBaseReference.strDefault) AS [name],
	gisBaseReference.strDefault,
	gisBaseReference.intOrder,
	gisBaseReference.intRowStatus
FROM dbo.gisBaseReference 
LEFT JOIN gisStringNameTranslation  ON 
	gisBaseReference.idfsGISBaseReference = gisStringNameTranslation.idfsGISBaseReference
 	AND gisStringNameTranslation.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
	AND gisStringNameTranslation.intRowStatus = 0
WHERE	
	 gisBaseReference.idfsGISReferenceType = 19000005 --'SettlementType'
	 and gisBaseReference.intRowStatus = 0
ORDER BY intOrder, [name]
