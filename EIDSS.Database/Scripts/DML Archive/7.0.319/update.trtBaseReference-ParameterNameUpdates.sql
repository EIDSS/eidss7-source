/*
Author:			Doug Albanese
Date:			11/30/2022
Description:	Data clean up of content that is prepended to parameters names. Came from EIDSS 6.1 that way and shouldn't have been.
*/

DECLARE @ParameterNameChanges AS TABLE(
   idfsParameter	 BIGINT,
   strDefault		 NVARCHAR(MAX),
   strTextString	 NVARCHAR(MAX)
)

INSERT INTO @ParameterNameChanges (idfsParameter, strDefault, strTextString)
SELECT
   p.idfsParameter,
   trim(substring(b.strDefault, charindex(':',b.strDefault)+1,LEN(b.strDefault))) AS strDefault,
   trim(substring(snt.strTextString, charindex(':',snt.strTextString)+1,LEN(snt.strTextString))) AS strTextString
FROM
   ffParameter P
INNER JOIN trtBaseReference b
on b.idfsBaseReference = p.idfsParameter
INNER JOIN trtStringNameTranslation snt
on snt.idfsBaseReference = b.idfsBaseReference
where
   b.strDefault LIKE '%:%' AND 
   b.strDefault  NOT LIKE '%:' AND
   (b.strDefault LIKE 'Additional clinical sign%' OR
   b.strDefault LIKE 'Test Quality Control%' OR
   b.strDefault LIKE 'HCS %') AND
   snt.idfsLanguage = 10049003

UPDATE trtBaseReference
SET trtBaseReference.strDefault = PNC.strDefault
FROM 
   @ParameterNameChanges PNC
WHERE
   PNC.idfsParameter = trtBaseReference.idfsBaseReference

UPDATE trtStringNameTranslation
SET trtStringNameTranslation.strTextString = PNC.strTextString
FROM 
   @ParameterNameChanges PNC
WHERE
   PNC.idfsParameter = trtStringNameTranslation.idfsBaseReference




