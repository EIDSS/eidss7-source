

--*************************************************************************
-- Name 				: report.USP_REP_Languages_GET
-- Description			: List of Spacific Languages
--						  - used in Reports to select languages
--          
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--	Mark Wilson		03April2020	   Updated to use E7 artifacts
--
-- Testing code:
--
-- EXEC report.USP_REP_Languages_GET 'az-Latn-AZ'
-- EXEC report.USP_REP_Languages_GET 'en-US'
-- EXEC report.USP_REP_Languages_GET 'ru-RU'
--*************************************************************************



CREATE PROCEDURE  [Report].[USP_REP_Languages_GET]
	 @strLanguage	NVARCHAR(50)
AS
BEGIN
	SELECT 
		idfsReference AS idfsLanguage,
		l.name +' ('+ l.strDefault +')' AS [Language],
		r.strBaseReferenceCode AS [LangID]
	FROM report.FN_GBL_ReferenceRepair_GET(@strLanguage, 19000049) l
	JOIN dbo.trtBaseReference r ON r.idfsBaseReference=l.idfsReference
	JOIN trtLanguageToCP ltc ON	l.idfsReference = ltc.idfsLanguage
	WHERE ltc.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
END




