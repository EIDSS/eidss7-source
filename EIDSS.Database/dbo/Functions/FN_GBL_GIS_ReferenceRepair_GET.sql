

--*************************************************************************************************
-- Name: FN_GBL_GIS_ReferenceRepair_GET
--
-- Description: 
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Srini Goli      04/10/2021 Initial release.
-- Stephen Long    06/24/2021 Modified to bring back countries for foreign addresses.
-- SV and MCW	   10/12/2021 Updated to pull from gisLocation and join to gisBaseReference
--				              also removed CountryNode so that foreign addresses are returned
-- Testing code:
/*
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepair_GET('en-US',19000001) --Country
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepair_GET('en-US',19000003)	--Region
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepair_GET('en-US',19000002) --Rayon
 SELECT * FROM dbo.FN_GBL_GIS_ReferenceRepair_GET('en-US',19000004) --Settlement

 Administrative Levels 5, 6, and 7 have not been integrated.

*/
-- ************************************************************************************************
CREATE FUNCTION [dbo].[FN_GBL_GIS_ReferenceRepair_GET]
(
	@LangID  NVARCHAR(50), 
	@type BIGINT
	
)
RETURNS @GIS_ReferenceRepair TABLE
	(
        idfsReference BIGINT NOT NULL,
        node HIERARCHYID NOT NULL,
        [name] NVARCHAR(255) NULL,
        idfsGISReferenceType BIGINT NOT NULL,
        strDefault NVARCHAR(200) NOT NULL,
        LongName NVARCHAR(255) NULL,
        intOrder INT NULL,
        ExtendedName NVARCHAR(200) NULL,
        intRowStatus INT NULL,
        idfsType BIGINT NULL
    )
AS
BEGIN
     DECLARE @AdminLevel4 BIGINT

	SELECT @AdminLevel4 = idfsGISReferenceType FROM dbo.gisReferenceType WHERE idfsGISReferenceType = 19000004
	
	INSERT INTO @GIS_ReferenceRepair
	SELECT
		br.idfsGISBaseReference AS idfsReference, 
		L.node,
		ISNULL(snt.strTextString, br.strDefault) AS [name],
		br.idfsGISReferenceType, 
		br.strDefault, 
		ISNULL(snt.strTextString, br.strDefault) AS LongName,
		br.intOrder,
		CASE @type 
				WHEN @AdminLevel4 THEN ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + CAST(L.dblLatitude AS NVARCHAR(100)) + N'; ' + CAST(L.dblLongitude AS NVARCHAR(100)) + N')', N'') 
				ELSE ISNULL(snt.strTextString, br.strDefault) + ISNULL(N' (' + L.strHASC + N')', N'') 
		END AS ExtendedName,
		br.intRowStatus,
		l.idfsType
    FROM dbo.gisLocation l 
    JOIN dbo.gisBaseReference br ON br.idfsGISBaseReference = l.idfsLocation
    JOIN dbo.gisStringNameTranslation snt ON snt.idfsGISBaseReference = br.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
    JOIN dbo.gisReferenceType rt ON rt.idfsGISReferenceType = br.idfsGISReferenceType
    WHERE rt.idfsGISReferenceType = @type
                                                     
	RETURN
END


