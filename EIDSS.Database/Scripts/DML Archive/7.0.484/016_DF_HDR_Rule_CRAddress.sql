-- Examples:
/*
	EXEC [dbo].[DF_HDR_Rule_CRAddress]
	EXEC [dbo].[DF_HDR_Rule_CRAddress] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_HDR_Rule_CRAddress] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_HDR_Rule_CRAddress] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrHC') is null
create table	#cfrHC
(	[idfHumanCase]					bigint not null primary key,
	[idfHuman]						bigint null,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfParentMonitoringSession]	bigint null,
	[idfDeduplicationResultCase]	bigint null,
	[idfSentByOffice]				bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfInvestigatedByOffice]		bigint null,
	[idfSoughtCareFacility]			bigint null,
	[idfHospital]					bigint null,
	[idfExposureLocation]			bigint null,
	[idfCRAddress]					bigint null,
	[idfsExposureLocRayon]			bigint null,
	[idfsCRARayon]					bigint null
)

if Object_ID('tempdb..#HCFiltered') is null
create table	#HCFiltered
(	[idfID]					bigint not null identity(1,1),
	[idfHumanCase]			bigint not null,
	[idfMonitoringSession]	bigint null,
	[idfOutbreak]			bigint null,
	[idfSiteGroup]			bigint not null,
	[idfHumanCaseFiltered]	bigint null,
	primary key	(
		[idfHumanCase] asc,
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
	insert into	#HCFiltered
	(	idfHumanCase,
		idfMonitoringSession,
		idfOutbreak,
		idfSiteGroup
	)
	select distinct
				hc.idfHumanCase,
				hc.idfParentMonitoringSession,
				hc.idfOutbreak,
				s.idfSiteGroup
	from		#cfrHC hc
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsRayon = hc.idfsCRARayon
	left join	#HCFiltered hcf_ex
	on			hcf_ex.idfHumanCase = hc.idfHumanCase
				and hcf_ex.idfSiteGroup = s.idfSiteGroup
	where		hcf_ex.idfID is null
end
else begin
	insert into	#HCFiltered
	(	idfHumanCase,
		idfMonitoringSession,
		idfOutbreak,
		idfSiteGroup
	)
	select distinct
				hc.idfHumanCase,
				hc.idfParentMonitoringSession,
				hc.idfOutbreak,
				s.idfSiteGroup
	from		tlbHumanCase hc with (nolock)
	inner join	tlbHuman h with (nolock)
	on			h.idfHuman = hc.idfHuman
	inner join	tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	inner join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsRayon = ld.Level3ID
	left join	#HCFiltered hcf_ex
	on			hcf_ex.idfHumanCase = hc.idfHumanCase
				and hcf_ex.idfSiteGroup = s.idfSiteGroup
	where		hcf_ex.idfID is null
end
