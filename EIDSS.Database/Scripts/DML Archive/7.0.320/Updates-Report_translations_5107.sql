/*
Author:			Srini Goli
Date:			12/1/2022
Description:	Report labels updates.
*/
--Disease Updates
DECLARE @LangID NVARCHAR(200)
SET @LangID='en-US'
UPDATE RT SET strResourceString=N'Disease'
--SELECT		RSTR.idfsReportTextID,RT.strResourceString,RST.strTextString, R.strResourceName
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=37

SET @LangID='en-US'
UPDATE R SET strResourceName=N'Disease'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=37

SET @LangID='ka-GE'
UPDATE RT SET strResourceString=N'დაავადება'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=37

SET @LangID='ru-RU'
UPDATE RT SET strResourceString=N'Заболевание'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=37

--Aggregate Information Updates
SET @LangID='en-US'
UPDATE RT SET strResourceString=N'Aggregate Information'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=33

SET @LangID='en-US'
UPDATE R SET strResourceName=N'Aggregate Information'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=33

SET @LangID='ka-GE'
UPDATE RT SET strResourceString=N'აგრეგირებული ინფორმაცია'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=33

SET @LangID='ru-RU'
UPDATE RT SET strResourceString=N'Агрегированная информация' 
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=33


--Detailed Information Updates
SET @LangID='en-US'
UPDATE RT SET strResourceString=N'Detailed Information'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=20

SET @LangID='en-US'
UPDATE R SET strResourceName=N'Detailed Information'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=20

SET @LangID='ka-GE'
UPDATE RT SET strResourceString=N'გადადით დეტალურ ინფორმაციაზე'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=20

SET @LangID='ru-RU'
UPDATE RT SET strResourceString=N'Подробная информация'
FROM dbo.trtResourceSetToResource RSTR
INNER JOIN dbo.trtResourceSet RS ON RS.idfsResourceSet = RSTR.idfsResourceSet
LEFT JOIN dbo.trtResourceSetTranslation RST ON RST.idfsResourceSet = RSTR.idfsResourceSet AND RST.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
LEFT JOIN dbo.trtResource R ON R.idfsResource = RSTR.idfsResource
LEFT JOIN dbo.trtResourceTranslation RT ON RT.idfsResource = RSTR.idfsResource AND RT.idfsLanguage =report.FN_GBL_LanguageCode_GET(@LangID)
WHERE RSTR.idfsResourceSet=800086
AND RSTR.idfsReportTextID=20
