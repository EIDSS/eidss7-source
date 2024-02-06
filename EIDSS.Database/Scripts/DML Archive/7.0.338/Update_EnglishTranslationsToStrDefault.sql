---------------------------------------------------------------------------------------------------------------
--
-- This script ensures all English Translations match the strDefault value of idfsBaseReference
--
---------------------------------------------------------------------------------------------------------------

UPDATE T
SET T.strTextString = S.strDefault
FROM dbo.trtStringNameTranslation T
INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfsBaseReference
WHERE T.idfsLanguage = 10049003 -- English

