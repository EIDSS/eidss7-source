
UPDATE dbo.trtStringNameTranslation
SET strTextString = N'ფერმის'
WHERE idfsBaseReference IN (10506025,10506115)
AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')