

--=================================================================================================
-- Name: report.USP_VET_ASSession_GET
--
-- Description: Returns Local reference with translations on corresponding language for AVR
--
-- Author: Mark Wilson
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		07/15/2022 initial release
--=================================================================================================
/*
--Example of function:
select * from dbo.FN_AVR_Local_Reference_GET('en-US')

*/

CREATE FUNCTION dbo.FN_AVR_Local_Reference_GET
(
	@LangID NVARCHAR(50)

)
RETURNS TABLE
AS
RETURN
(

	SELECT
		R.idflBaseReference,
		ISNULL(T.strTextString, ET.strTextString) AS strName,
		ET.strTextString AS strEnglishName

	FROM dbo.locBaseReference AS R 
	LEFT JOIN dbo.locStringNameTranslation AS ET ON R.idflBaseReference = ET.idflBaseReference AND ET.idfsLanguage = dbo.FN_GBL_LanguageCode_GET('en-US')
	LEFT JOIN dbo.locStringNameTranslation AS T ON R.idflBaseReference = T.idflBaseReference AND T.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

)