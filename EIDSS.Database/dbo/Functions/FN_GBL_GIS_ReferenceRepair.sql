--*************************************************************
-- Name 				: FN_GBL_GIS_ReferenceRepair
-- Description			: The FUNCTION returns GIS the reference values for given reference type and language
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- SELECT * FROM FN_GBL_ReferenceRepair('ru',19000040)
--*************************************************************
CREATE          FUNCTION [dbo].[FN_GBL_GIS_ReferenceRepair](@LangID  NVARCHAR(50), @type BIGINT)
RETURNS table
AS
RETURN(

SELECT
			b.idfsGISBASeReference AS idfsReference, 
			ISNULL(c.strTextString, b.strDefault) AS [name],
			b.idfsGISReferenceType, 
			b.strDefault, 
			ISNULL(c.strTextString, b.strDefault) AS LongName,
			b.intOrder,
			b.intRowStatus

FROM		dbo.gisBASeReference AS b 
LEFT JOIN	dbo.gisStringNameTranslation AS c 
ON			b.idfsGISBASeReference = c.idfsGISBASeReference AND c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

WHERE		b.idfsGISReferenceType = @type
)











