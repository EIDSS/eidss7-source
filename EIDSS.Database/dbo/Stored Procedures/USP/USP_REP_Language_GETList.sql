


--*************************************************************************
-- Name 				: dbo.USP_REP_Language_GETList
-- Description			: List of Specific Languages
--						  - used in Reports to select languages
--          
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--
-- Testing code:
--
-- EXEC dbo.USP_REP_Language_GETList 'ru-RU'
-- EXEC dbo.USP_REP_Language_GETList 'en_US'
--*************************************************************************
CREATE PROCEDURE [dbo].[USP_REP_Language_GETList] @LanguageID NVARCHAR(50)
AS
BEGIN
SELECT 
		idfsReference AS BaseReferenceID,
		l.name +' ('+ l.strDefault +')' AS LanguageName,
		r.strBaseReferenceCode AS LanguageID
	FROM dbo.FN_GBL_REFERENCE_GETList(@LanguageID, 19000049) l
	JOIN dbo.trtBaseReference r ON r.idfsBaseReference=l.idfsReference
	JOIN trtLanguageToCP ltc ON	l.idfsReference = ltc.idfsLanguage
	WHERE ltc.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
	
END

