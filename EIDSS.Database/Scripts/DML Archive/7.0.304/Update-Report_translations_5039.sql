/*
Author:			Srini Goli
Date:			10/17/2022
Description:	Report labels updates.
*/
--== Disease ==

DECLARE @LangID NVARCHAR(200)
SET @LangID='en-US'
UPDATE RT SET strResourceString=N'Form ID'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800091
AND RSTR.idfsReportTextID=5

SET @LangID='en-US'
UPDATE R SET strResourceName=N'Form ID'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800091
AND RSTR.idfsReportTextID=5

SET @LangID='ka-GE'
UPDATE RT SET strResourceString=N'ფორმის ID'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800091
AND RSTR.idfsReportTextID=5

SET @LangID='ru-RU'
UPDATE RT SET strResourceString=N'Инд.№ формы'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800091
AND RSTR.idfsReportTextID=5
GO
