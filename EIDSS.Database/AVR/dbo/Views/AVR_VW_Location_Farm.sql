CREATE VIEW [AVR_VW_Location_Farm]
    as

    SELECT   
       gls.strPostCode,
       gf.AdminLevel2ID ,
       gls.intRowStatus,
       gf.idfsLanguage as idfsLanguage,
       gf.AdminLevel4ID,
       gf.AdminLevel3ID,
       gls.dblLatitude,
       gls.dblLongitude,
       gf.AdminLevel1ID,
       gls.idfsGeoLocationType,
       gls.blnForeignAddress,
       gls.strForeignAddress,
       gf.idfsLocation,
       gls.idfGeoLocationShared
FROM dbo.tlbGeoLocationShared gls
    LEFT JOIN FN_GBL_AVR_LocationHierarchy_Flattened() gf
        on gf.idfsLocation = gls.idfsLocation  AND gls.intRowStatus = 0

