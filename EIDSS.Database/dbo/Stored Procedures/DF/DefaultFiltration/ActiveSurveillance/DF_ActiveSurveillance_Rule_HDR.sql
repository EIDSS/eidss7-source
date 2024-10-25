-- Examples:
/*
	EXEC [dbo].[DF_ActiveSurveillance_Rule_HDR]
	EXEC [dbo].[DF_ActiveSurveillance_Rule_HDR] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_ActiveSurveillance_Rule_HDR] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_ActiveSurveillance_Rule_HDR] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

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

	-- In case of predefined list of HDRs, add newly calculated records for those HDRs, which are linked to Active Surveillance Session
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				hcf.idfSiteGroup
	from		#HCFiltered hcf
	join		dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = hcf.idfMonitoringSession
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = hcf.idfSiteGroup
				)
				and msf_ex.idfID is null

	-- In case of predefined list of HDRs, add existing records for those HDRs, which are linked to Active Surveillance Session
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				hcf.idfSiteGroup
	from		dbo.tlbHumanCase hc with (nolock)
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = hc.idfParentMonitoringSession
	inner join	dbo.tflHumanCaseFiltered hcf with (nolock)
	on			hcf.idfHumanCase = hc.idfHumanCase
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = hcf.idfSiteGroup
				)
				and msf_ex.idfID is null

	-- Add newly calculated records of HDRs linked to predefined Active Surveillance Sessions
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				hcf.idfSiteGroup
	from		dbo.tlbHumanCase hc with (nolock)
	inner join	#cfrMS ms with (nolock)
	on			ms.idfMonitoringSession = hc.idfParentMonitoringSession
	inner join	#HCFiltered hcf
	on			hcf.idfHumanCase = hc.idfHumanCase
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = hcf.idfSiteGroup
				)
				and msf_ex.idfID is null


	-- Add existing records of HDRs linked to predefined Active Surveillance Sessions
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				hcf.idfSiteGroup
	from		dbo.tlbHumanCase hc with (nolock)
	inner join	#cfrMS ms with (nolock)
	on			ms.idfMonitoringSession = hc.idfParentMonitoringSession
	inner join	dbo.tflHumanCaseFiltered hcf with (nolock)
	on			hcf.idfHumanCase = hc.idfHumanCase
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = hcf.idfSiteGroup
				)
				and msf_ex.idfID is null
end
else begin
	-- Add newly calculated records of HDRs linked to Active Surveillance Sessions
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				hcf.idfSiteGroup
	from		dbo.tlbHumanCase hc with (nolock)
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = hc.idfParentMonitoringSession
	inner join	#HCFiltered hcf
	on			hcf.idfHumanCase = hc.idfHumanCase
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = hcf.idfSiteGroup
				)
				and msf_ex.idfID is null


	-- Add existing records of HDRs linked to Active Surveillance Sessions
	insert into	#MSFiltered
	(	idfMonitoringSession,
		idfSiteGroup
	)
	select distinct
				ms.idfMonitoringSession,
				hcf.idfSiteGroup
	from		dbo.tlbHumanCase hc with (nolock)
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = hc.idfParentMonitoringSession
	inner join	dbo.tflHumanCaseFiltered hcf with (nolock)
	on			hcf.idfHumanCase = hc.idfHumanCase
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = hcf.idfSiteGroup
				)
				and msf_ex.idfID is null
end
