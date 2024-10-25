/*Author:        Stephen Long
Date:            03/15/2023
Description:     Update site group type ID and location ID for 5430.
*/
UPDATE dbo.tflSiteGroup SET idfsSiteGroupType = 10524000 WHERE strSiteGroupName LIKE 'Border%' AND idfsSiteGroupType IS NULL;

UPDATE dbo.tflSiteGroup SET idfsSiteGroupType = 10524001 WHERE strSiteGroupName NOT LIKE 'Border%' AND idfsSiteGroupType IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37060000000 WHERE idfSiteGroup = 4350000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37080000000 WHERE idfSiteGroup = 4360000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37070000000 WHERE idfSiteGroup = 4370000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37100000000 WHERE idfSiteGroup = 4380000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37090000000 WHERE idfSiteGroup = 4390000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37040000000 WHERE idfSiteGroup = 4400000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37030000000 WHERE idfSiteGroup = 4410000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37120000000 WHERE idfSiteGroup = 4420000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37110000000 WHERE idfSiteGroup = 4430000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37050000000 WHERE idfSiteGroup = 4440000000 AND idfsLocation IS NULL;

UPDATE dbo.tflSiteGroup SET idfsLocation = 37130000000 WHERE idfSiteGroup = 4450000000 AND idfsLocation IS NULL;

-- Update site groups that have the same name as a site with the same site code/ID.  Uses associated site's office address lowest location.
-- This needs to be confirmed as this is an educated guess.
UPDATE dbo.tflSiteGroup 
SET idfsLocation = g.idfsLocation
FROM dbo.tflSiteGroup sg
    INNER JOIN dbo.tstSite s 
	    ON s.strSiteID = sg.strSiteGroupName 
	INNER JOIN dbo.tlbOffice o 
	    ON o.idfOffice = s.idfOffice  
	INNER JOIN dbo.tlbGeoLocationShared g 
	    ON g.idfGeoLocationShared = o.idfLocation
WHERE sg.intRowStatus = 0 
    AND sg.idfsLocation IS NULL;

-- Update site groups that have the a central site using the associated site's office address lowest location.
-- This needs to be confirmed as this is an educated guess.
UPDATE dbo.tflSiteGroup 
SET idfsLocation = g.idfsLocation
FROM dbo.tflSiteGroup sg
    INNER JOIN dbo.tstSite s 
	    ON s.idfsSite = sg.idfsCentralSite
	INNER JOIN dbo.tlbOffice o 
	    ON o.idfOffice = s.idfOffice  
	INNER JOIN dbo.tlbGeoLocationShared g 
	    ON g.idfGeoLocationShared = o.idfLocation
WHERE sg.intRowStatus = 0 
    AND sg.idfsLocation IS NULL;