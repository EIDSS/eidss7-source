

--=====================================================================================================
-- Created by:				Joan Li
-- Last modified date:		06/20/2017
-- Mod History:				Joan Li		06/20/2017: Created based on V6 fn_HumanCase_SelectList :  V7 USP73
-- 							Mark Wilson	11/9/2020  E7 standards
--
--   Function called by SP ; get data from: tlbGeoLocation;tlbGeoLocationTranslation
/*
----testing code:
----related fact data from
-- select * from FN_GBL_GIS_GeoLocationTranslation('en-US')
*/
--=====================================================================================================

CREATE FUNCTION [dbo].[FN_GBL_GIS_GeoLocationTranslation]
(
	@LangID  NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN(

SELECT
			gl.idfGeoLocation, 
			ISNULL(glt.strTextString, gl.strAddressString) AS [name],
			CASE
				WHEN	ISNULL(gl.blnForeignAddress, 1) = 0
					THEN	gl.strAddressString
				ELSE	gl.strForeignAddress
			END AS [strDefault],
			CASE
				WHEN	ISNULL(gl.idfsGeoLocationType, 0) = 10036001 -- Address 
						AND ISNULL(gl.blnForeignAddress, 1) = 0
					THEN	ISNULL(glt.strShortAddressString, gl.strShortAddressString)
				ELSE	N''
			END AS [strShortAddressString],
			CASE
				WHEN	ISNULL(gl.idfsGeoLocationType, 0) = 10036001 -- Address 
						AND ISNULL(gl.blnForeignAddress, 1) = 0
					THEN	gl.strShortAddressString
				ELSE	N''
			END AS [strDefaultShortAddressString]
			

FROM dbo.tlbGeoLocation AS gl 
LEFT JOIN dbo.tlbGeoLocationTranslation AS glt ON glt.idfGeoLocation = gl.idfGeoLocation AND glt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)

WHERE gl.intRowStatus = 0
)

