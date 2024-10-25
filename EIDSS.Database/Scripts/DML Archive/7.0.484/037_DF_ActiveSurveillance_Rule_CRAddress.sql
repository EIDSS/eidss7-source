-- Examples:
/*
	EXEC [dbo].[DF_ActiveSurveillance_Rule_CRAddress]
	EXEC [dbo].[DF_ActiveSurveillance_Rule_CRAddress] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_ActiveSurveillance_Rule_CRAddress] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_ActiveSurveillance_Rule_CRAddress] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrMS') is null
create table	#cfrMS
(	[idfMonitoringSession]			bigint not null primary key,
	[idfsSite]						bigint null,
	[idfsMSRayon]					bigint null
)

if Object_ID('tempdb..#MSFiltered') is null
create table	#MSFiltered
(	[idfID]							bigint not null identity(1,1),
	[idfMonitoringSession]			bigint not null,
	[idfSiteGroup]					bigint not null,
	[idfMonitoringSessionFiltered]	bigint null,
	primary key	(
		[idfMonitoringSession] asc,
		[idfSiteGroup] asc
				)
)

if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)


if @UsePredefinedData = 1 or @StartDate is not null
begin
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				s.idfSiteGroup
	from		#cfrMS ms
	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfMonitoringSession = ms.idfMonitoringSession
	inner join	dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	inner join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsRayon = ld.Level3ID
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = s.idfSiteGroup
	where		msf_ex.idfID is null
end
else begin
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				s.idfSiteGroup
	from		dbo.tlbMonitoringSession ms with (nolock)
	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfMonitoringSession = ms.idfMonitoringSession
	inner join	dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	inner join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsRayon = ld.Level3ID
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = s.idfSiteGroup
	where		msf_ex.idfID is null
end
