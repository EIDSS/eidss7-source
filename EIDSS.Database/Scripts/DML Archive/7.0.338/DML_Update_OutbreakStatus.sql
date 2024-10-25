-------------------------------------------------------------------------------------------
--
-- script to disable all E6 Outbreak Status with value of 'Not and Outbreak
-- and assign new value to all Outbreaks that used them
--
-------------------------------------------------------------------------------------------
DECLARE @idfsBaseReference BIGINT
DECLARE @E6NotAnOutbreak TABLE
(    idfsBaseReference BIGINT
)
INSERT INTO @E6NotAnOutbreak
(    idfsBaseReference
)
SELECT idfsBaseReference
FROM dbo.trtBaseReference
WHERE idfsReferenceType = 19000063
AND strDefault = 'Not an Outbreak'
AND SourceSystemNameID = 10519002
SELECT * FROM dbo.tlbOutbreak WHERE idfsOutbreakStatus IN (SELECT idfsBaseReference FROM @E6NotAnOutbreak)
DECLARE @E7NotAnOutbreak BIGINT = 10063503 -- E7 not an outbreak
UPDATE dbo.trtBaseReference
SET intRowStatus = 1
WHERE idfsBaseReference in (SELECT * FROM @E6NotAnOutbreak)-- Execute this to update any EIDSS6 records with new EIDSS7 'Not an Outbreak' value.
UPDATE dbo.tlbOutbreak
SET idfsOutbreakStatus = @E7NotAnOutbreak
WHERE idfsOutbreakStatus IN (SELECT idfsBaseReference FROM @E6NotAnOutbreak)SELECT * FROM dbo.tlbOutbreak WHERE idfsOutbreakStatus IN (SELECT idfsBaseReference FROM @E6NotAnOutbreak)
SELECT * FROM dbo.tlbOutbreak WHERE idfsOutbreakStatus = @E7NotAnOutbreak

