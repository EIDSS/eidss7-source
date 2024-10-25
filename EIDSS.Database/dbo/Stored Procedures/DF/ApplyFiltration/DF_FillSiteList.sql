-- Examples:
/*
	EXEC [dbo].[DF_FillSiteList]
	EXEC [dbo].[DF_FillSiteList] @UsePredefinedData=0
	EXEC [dbo].[DF_FillSiteList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_FillSiteList] 
(
	@UsePredefinedData		bit = 0
)
AS



if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)



if @UsePredefinedData = 0
begin
	insert into	#SitesToCalculateFiltrationRecords (strSiteID)
	select		s.strSiteID
	from		dbo.tstSite s with (nolock)
	left join	#SitesToCalculateFiltrationRecords s_to_cfr
	on			s_to_cfr.strSiteID = s.strSiteID collate Cyrillic_General_CI_AS
	where		s.intRowStatus = 0
				and s_to_cfr.idfID is null

end

update		s_to_cfr
set			s_to_cfr.idfsSite = siteInfo.idfsSite,
			s_to_cfr.idfOffice = siteInfo.idfOffice,
			s_to_cfr.idfsRayon = siteInfo.idfsRayon,
			s_to_cfr.idfSiteGroup = siteInfo.idfSiteGroup
from		#SitesToCalculateFiltrationRecords s_to_cfr
cross apply	
(	select top 1
				s.idfsSite, o.idfOffice, ld.Level3ID as idfsRayon, sg.idfSiteGroup
	from		dbo.tstSite s with (nolock)
	inner join	dbo.tlbOffice o with (nolock)
	on			o.idfOffice = s.idfOffice
				and o.intRowStatus = 0
	left join	dbo.tlbGeoLocationShared gls with (nolock)
	on			gls.idfGeoLocationShared = o.idfLocation
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gls.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
		inner join	dbo.tflSiteGroup sg
		on			sg.idfSiteGroup = s_to_sg.idfSiteGroup
					and sg.idfsCentralSite is null
					and sg.idfsRayon is null
					and sg.intRowStatus = 0
	on			s_to_sg.idfsSite = s.idfsSite
	where		s.strSiteID = s_to_cfr.strSiteID collate Cyrillic_General_CI_AS
				and s.intRowStatus = 0
				and s.idfsSiteType = 10085007 /*TLVL*/
	order by	s.idfsSite desc, sg.idfSiteGroup asc
) siteInfo


delete from #SitesToCalculateFiltrationRecords
where idfSiteGroup is null
