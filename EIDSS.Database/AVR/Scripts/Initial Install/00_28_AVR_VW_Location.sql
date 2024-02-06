USE [AVRDEV_EIDSS7_GG_ARCHIVE_MOA]
GO

/****** Object:  View [dbo].[AVR_VW_Location]    Script Date: 2/8/2023 8:10:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	Alter VIEW [dbo].[AVR_VW_Location]
	as
	SELECT gi.Level2ID as idfsRegion,
	    h.idfCurrentResidenceAddress,
       gl.intRowStatus,
	   gi.idfsLanguage as idfsLanguage,
	   gl.idfsSettlement,
	   gl.idfsRayon,
	   gl.dblLatitude,
	   gl.dblLongitude,
	   gl.idfsCountry,
	   gl.idfsGeoLocationType,
	   gl.blnForeignAddress,
	   gl.strForeignAddress,
	   gl.idfGeoLocation
FROM dbo.tlbGeoLocation gl		
LEFT JOIN dbo.gisLocationDenormalized gi
	ON gl.idfsLocation = gi.idfsLocation
LEFT JOIN  FN_GBL_AVR_LocationHierarchy_Flattened() g
      ON g.idfsLocation = gl.idfsLocation
left join tlbHuman h
     on gl.idfGeoLocation = h.idfCurrentResidenceAddress AND gl.intRowStatus = 0

GO


