
------------------------------------------------------------------------------------------------------------
--
-- populate idfsLocation
--
------------------------------------------------------------------------------------------------------------

UPDATE T
SET T.idfsLocation = S.idfsLocation
FROM dbo.tlbOutbreak T
INNER JOIN dbo.tlbGeoLocation S ON S.idfGeoLocation = T.idfGeoLocation

