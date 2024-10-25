
--*************************************************************************
-- Name 				: USP_GBL_REP_LOCATION_GETLIST
-- Description			: This procedure returns geo information related with current site.
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
--Example of a call of procedure:
--exec USP_GBL_REP_LOCATION_GETLIST 'ru', 1

--exec USP_GBL_REP_LOCATION_GETLIST 'ru', 1, 869

--SELECT *
-- 	FROM report.FN_GBL_GIS_ReferenceRepair_GET('en', 19000020) frr

--SELECT *
-- 	FROM report.FN_GBL_GIS_ReferenceRepair_GET('en', 19000021) frr

--*************************************************************************
CREATE PROCEDURE [Report].[USP_GBL_REP_LOCATION_GETLIST]
	@LangID varchar(36),
	@IsCHE bit = 0,
	@SiteID bigint = NULL
AS
BEGIN

	IF @SiteID	is NULL
	set @SiteID = dbo.FN_GBL_SiteID_GET()
	
	IF @IsCHE = 1 AND EXISTS (SELECT * FROM report.FN_GBL_GIS_ReferenceRepair_GET('en', 19000021) WHERE idfsReference = @SiteID)
		SELECT		
				tcp1.idfsCountry,
				CHERegion.idfsReference AS idfsRegion, 
				CHERayon.idfsReference	AS idfsRayon, 
				NULL					AS idfsSettlement, 
				country.[name]			AS strCountry,
				CHERegion.[name]		AS strRegion,
				CHERayon.[name]			AS strRayon,
				NULL					AS strSettlement
		FROM 	tstSite					AS st
		JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET('en', 19000020) CHERegion ON 1=1
		JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET('en', 19000021) CHERayon	ON st.idfsSite = CHERayon.idfsReference
		JOIN tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = st.idfCustomizationPackage
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000001 /*'rftCountry'*/) AS  country ON	country.idfsReference = tcp1.idfsCountry
		WHERE st.idfsSite = @SiteID
	ELSE
 		SELECT		loc.idfsCountry,
					loc.idfsRegion, 
					loc.idfsRayon, 
					loc.idfsSettlement, 
					country.[name]	AS strCountry,
					region.[name]		AS strRegion,
					rayon.[name]		AS strRayon,
					settlement.[name]	AS strSettlement
		FROM 		tstSite					AS st
		 LEFT JOIN	dbo.FN_GBL_Institution(@LangID) AS	inst ON	st.idfOffice = inst.idfOffice
		 LEFT JOIN	dbo.tlbGeoLocationShared	AS loc ON	inst.idfLocation = loc.idfGeoLocationShared
 		 LEFT JOIN	dbo.FN_GBL_GIS_Reference(@LangID, 19000001 /*'rftCountry'*/)AS  country ON	country.idfsReference = loc.idfsCountry
		 LEFT JOIN	dbo.FN_GBL_GIS_Reference(@LangID, 19000003 /*'rftRegion'*/) AS  region 	ON	region.idfsReference = loc.idfsRegion
		 LEFT JOIN	dbo.FN_GBL_GIS_Reference(@LangID, 19000002 /*'rftRayon'*/)  AS rayon 	ON	rayon.idfsReference = loc.idfsRayon
		 LEFT JOIN	dbo.FN_GBL_GIS_Reference(@LangID, 19000004 /*'rftSettlement'*/) AS settlement ON	settlement.idfsReference = loc.idfsSettlement
		WHERE	st.idfsSite = @SiteID
END

