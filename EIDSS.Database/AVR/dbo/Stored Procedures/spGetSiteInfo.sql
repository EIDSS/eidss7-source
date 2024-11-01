--##SUMMARY This procedure returns site, country and organization information related with current site.

--##REMARKS Author: Zurin M.
--##REMARKS Create date: 05.11.2009

--##REMARKS Updated: Zolotareva N.
--##REMARKS Update date: 25.11.2011 
--##REMARKS Changed tlbGeoLocation to tlbGeoLocationShared


--##RETURNS Don't use


/*
--Example of a call of procedure:

exec dbo.[spGetSiteInfo] 'en'
*/


CREATE PROCEDURE [dbo].[spGetSiteInfo](
	@LangID NVARCHAR(10) --##PARAM LanguageID - language ID for localized strings
	)
AS
BEGIN
declare @idfsRealSiteID bigint
declare @idfsRealSiteType bigint
declare	@strRealSitePrefix nvarchar(200)
select		@idfsRealSiteID = cast(tstLocalSiteOptions.strValue as bigint)
from		tstLocalSiteOptions
where		tstLocalSiteOptions.strName='SiteID'

select		@idfsRealSiteType = cast(tstLocalSiteOptions.strValue as bigint)
from		tstLocalSiteOptions
where		tstLocalSiteOptions.strName='SiteType'

SELECT		@idfsRealSiteType = 
				case
					when @idfsRealSiteType is null 
						then s.idfsSiteType 
					else @idfsRealSiteType 
				end,
			@strRealSitePrefix = 
				case 
					when	len(isnull(s.strHASCsiteID,N'')) > 2
							and len(isnull(s.strHASCsiteID, N'')) >= 2
							and s.strHASCsiteID like left(c.strHASC, 2) + N'%' collate Cyrillic_General_CI_AS
						then right(s.strHASCsiteID, len(s.strHASCsiteID) - 2)
					else s.strHASCsiteID
				end
FROM		tstSite s
join		tstCustomizationPackage cp
on			cp.idfCustomizationPackage = s.idfCustomizationPackage
left join	gisCountry c
on			c.idfsCountry = cp.idfsCountry
WHERE		idfsSite = @idfsRealSiteID-- and intRowStatus = 0

SELECT dbo.fnGisReference.idfsReference as idfsCountry,   
  dbo.fnGisReference.[name] as strCountryName,  
  gisCountry.strHASC as strHASCCountry,  
  CAST(ISNULL(tlbGeoLocationShared.idfsRegion, -1) as bigint) as idfsRegion,  
  CAST(ISNULL(tlbGeoLocationShared.idfsRayon, -1) as bigint) as idfsRayon,  
  tstSite.idfsSite,  
  @idfsRealSiteID as idfsRealSiteID,
  @idfsRealSiteType as idfsRealSiteType,
  tstSite.strHASCsiteID,  
  tstSite.strSiteName,  
  tstSite.strSiteID,  
  tstSite.idfsSiteType,  
  dbo.fnReference.name as strSiteTypeName,  
  tstSite.idfOffice,  
  fnInstitution.[name] As strOrganizationName,
  tstSite.idfCustomizationPackage,
  cast(1 as bigint)/*dbo.fnPermissionSite()*/ as idfsPermissionSite,
  @strRealSitePrefix as strRealSitePrefix
FROM dbo.fnGisReference(@LangID,19000001) --'rftCountry'  
inner join gisCountry  
on  dbo.fnGisReference.idfsReference = gisCountry.idfsCountry 
JOIN tstCustomizationPackage tcpac ON
	tcpac.idfsCountry = gisCountry.idfsCountry
inner join tstSite   
on  tstSite.idfCustomizationPackage = tcpac.idfCustomizationPackage
inner join dbo.fnReference(@LangID, 19000085) --rftSiteType  
on  tstSite.idfsSiteType = fnReference.idfsReference  
inner join dbo.fnInstitution(@LangID)   
on  tstSite.idfOffice = fnInstitution.idfOffice  
Left OUTER JOIN tlbGeoLocationShared   
on  fnInstitution.idfLocation = tlbGeoLocationShared.idfGeoLocationShared  
where tstSite.idfsSite = dbo.fnSiteID()  
  

END

GO
