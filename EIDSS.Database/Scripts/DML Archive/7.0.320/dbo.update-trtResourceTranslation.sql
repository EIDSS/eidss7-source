/*
Author:			Doug Albanese
Date:			12/5/2022
Description:	Cleaning up bad and/or missing translations.
*/

--GG "Total" translation
UPDATE   trtResourceTranslation
set strResourceString = N'სულ'
where
   idfsResource in (
   	  765,
	  782,
	  783
   ) AND
   idfsLanguage = 10049004