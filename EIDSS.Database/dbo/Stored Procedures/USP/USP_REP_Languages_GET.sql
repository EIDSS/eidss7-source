






--*************************************************************************
-- Name 				: dbo.USP_REP_Languages_GET
-- Description			: List of Report supporting Languages
--						  - used in Reports to select languages
--          
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--
-- Testing code:
--
-- EXEC dbo.USP_REP_Languages_GET 'az-Latn-AZ'
-- EXEC dbo.USP_REP_Languages_GET 'en-US'
-- EXEC dbo.USP_REP_Languages_GET 'ru'
--*************************************************************************



CREATE PROCEDURE  [dbo].[USP_REP_Languages_GET]
	 @strLanguage	NVARCHAR(50)
AS
BEGIN

   SELECT 
		idfsReference AS idfsLanguage,
		l.name +' ('+ l.strDefault +')' AS [Language],
		r.strBaseReferenceCode AS [LangID]
	FROM dbo.FN_GBL_REFERENCE_GETList(@strLanguage, 19000049) l
	JOIN dbo.trtBaseReference r ON r.idfsBaseReference=l.idfsReference
	JOIN trtLanguageToCP ltc ON	l.idfsReference = ltc.idfsLanguage
	WHERE ltc.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()

END






