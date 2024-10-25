-- Examples:
/*
	EXEC [dbo].[DF_ActiveSurveillance_Rule_Sample_idfSendToOffice]
	EXEC [dbo].[DF_ActiveSurveillance_Rule_Sample_idfSendToOffice] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_ActiveSurveillance_Rule_Sample_idfSendToOffice] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_ActiveSurveillance_Rule_Sample_idfSendToOffice] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
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
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMonitoringSession = ms.idfMonitoringSession
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = m.idfSendToOffice
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
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMonitoringSession = ms.idfMonitoringSession
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = m.idfSendToOffice
	left join	#MSFiltered msf_ex
	on			msf_ex.idfMonitoringSession = ms.idfMonitoringSession
				and msf_ex.idfSiteGroup = s.idfSiteGroup
	where		(	ms.SessionCategoryID = @CalculateHumanData * 10502009 /*Veterinary Active Surveillance Session*/
					or ms.SessionCategoryID = @CalculateVetData * 10502001 /*Human Active Surveillance Session*/
					or (@CalculateVetData = 1 or ms.SessionCategoryID is null)
				)
				and msf_ex.idfID is null
end

