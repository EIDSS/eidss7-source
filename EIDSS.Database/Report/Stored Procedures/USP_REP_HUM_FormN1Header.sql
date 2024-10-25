
--*************************************************************************
-- Name 				: report.USP_REP_HUM_FormN1Header
-- Description			: This procedure returns Header (Page 1) for Form N1 for both A4 ans A3 Format Reports
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:

--January - March, 2014  Baku, Yasamal(Baku)
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, 'January','March', 1344330000000, 1344440000000, null

--January - March, 2014  Shahbuz, Nakhichevan AR
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, 'January','March', 1344350000000, 1345100000000, null

--January, 2014  Air Transport CHE
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, 'January','January', null, null, 867

--2014  Air Transport CHE
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, '','', null, null, 867

-- 2014  Baku, Nizami (Baku)
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, '','', 1344330000000, 1344390000000, null

-- 2014  Ordubad, Nakhichevan AR
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, '','', 1344350000000, 1345120000000, null

-- 2014  Absheron  -- other!!
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, '','', 1344340000000, 1344490000000, null

-- 2014  Other rayons   -- rayon IS NULL
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, '','', 1344340000000, null, null

-- 2014  Azerbaijan
EXEC report.USP_REP_HUM_FormN1Header 'en', 2014, '','', null, null, null

*/ 
 
CREATE PROCEDURE [Report].[USP_REP_HUM_FormN1Header]
	@LangID			AS VARCHAR(36),
	@Year			AS INT, 
	@strStartMonth	AS NVARCHAR(100) = NULL,
	@strEndMonth	AS NVARCHAR(100) = NULL,
	@RegionID		AS BIGINT = NULL,
	@RayonID		AS BIGINT = NULL,
	@OrganizationID	AS BIGINT = NULL,
	@SiteID			AS BIGINT = NULL
	
AS
BEGIN

	DECLARE @idfSiteInfoOffice BIGINT
	DECLARE @CountryID BIGINT
	DECLARE @Address NVARCHAR(1000)

	DECLARE @strParameters NVARCHAR(1000)
	DECLARE @strOrganizationName  NVARCHAR(1000)
	DECLARE @strTransportOrganizationName  NVARCHAR(1000)
	DECLARE @strRegion  NVARCHAR(1000)
	DECLARE @strRayon	NVARCHAR(1000)
	DECLARE @strCountry NVARCHAR(1000)

	SET @strStartMonth = CASE WHEN @strStartMonth = '' THEN NULL ELSE @strStartMonth END
	SET @strEndMonth = CASE WHEN @strEndMonth = '' THEN NULL ELSE @strEndMonth END
  
  	SELECT 
				@idfSiteInfoOffice = tstSite.idfOffice,
				@strOrganizationName = rftCountry.[name]
	FROM		report.FN_GBL_GIS_ReferenceRepair_GET(@LangID,19000001) rftCountry 
		INNER JOIN	gisCountry  
		ON			rftCountry.idfsReference = gisCountry.idfsCountry 
		JOIN		tstCustomizationPackage tcpac 
		ON			tcpac.idfsCountry =  gisCountry.idfsCountry
		INNER JOIN	tstSite   
		ON			tstSite.idfCustomizationPackage = tcpac.idfCustomizationPackage  
		INNER JOIN	report.FN_GBL_ReferenceRepair_GET(@LangID, 19000085) rftSiteType  
		ON			tstSite.idfsSiteType = rftSiteType.idfsReference  
		INNER JOIN	report.FN_REP_InstitutionRepair(@LangID) as rftInstitution
		ON			tstSite.idfOffice = rftInstitution.idfOffice  
		LEFT JOIN	tlbGeoLocationShared   
		ON			rftInstitution.idfLocation = tlbGeoLocationShared.idfGeoLocationShared  
	WHERE		tstSite.idfsSite = isnull(@SiteID, report.FN_SiteID_GET()) 
	
	SELECT 
				@Address = report.FN_REP_AddressSharedString(@LangID, o.idfLocation)
	FROM		tlbOffice o
	WHERE		@idfSiteInfoOffice = o.idfOffice

	SET	@CountryID = 170000000

	SELECT @strTransportOrganizationName =  i.[name]
	FROM tstSite   
		INNER JOIN	report.FN_REP_InstitutionRepair(@LangID) AS i  
		ON			tstSite.idfOffice = i.idfOffice  
	WHERE		tstSite.idfsSite = @OrganizationID
	
	SELECT @strRegion = [name] 
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003 /*rftRegion*/) 
	WHERE idfsReference = @RegionID
		
	SELECT @strRayon = [name] 
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002 /*rftRayon*/)  
	WHERE idfsReference = @RayonID
		
	SELECT @strCountry = [name] 
	FROM report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*rftCountry*/) 
	WHERE idfsReference = @CountryID
	
	
	SET @strParameters = 
		CASE 
			WHEN isnull(@strStartMonth, N'') <> isnull(@strEndMonth, N'')
				THEN isnull(@strStartMonth + isnull(' - ' + @strEndMonth, '') +  ', ', '') /*+ cast(@Year as VARCHAR(4)) + CHAR(13) + CHAR(10)*/
				ELSE isnull(@strStartMonth + ', ', '')			
		END + cast(@Year AS VARCHAR(4)) + CHAR(13) + CHAR(10) +	
		CASE 
			WHEN @OrganizationID is not null 
				THEN isnull(@strTransportOrganizationName, '') 
				ELSE 
					CASE WHEN @RegionID = 1344330000000 -- Baku
							THEN @strRegion + isnull(', ' + @strRayon, '')
						 WHEN @RegionID = 1344340000000 -- other
							THEN isnull(@strRayon, @strRegion)
						  WHEN @RegionID = 1344350000000 -- Nakhichevan AR
							THEN  isnull(@strRayon + ', ', '') + @strRegion 
						 ELSE @strCountry
					END 
		END
		
 
	SELECT
	    @strParameters AS strParameters,
	    @strOrganizationName  AS strOrganizationName,
	    @Address AS strOrganizationAddress

END


