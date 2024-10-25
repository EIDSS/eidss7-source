-- Examples:
/*
	EXEC [dbo].[DF_CFRule_ActiveSurveillance]
*/
-- Prerequisites: Calculated default filtration rules for Active Surveillance Sessions
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_CFRule_ActiveSurveillance] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

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

-- Unidirectional configurable filtration rules
insert into #MSFiltered
(
	idfMonitoringSession,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			msf.idfMonitoringSession,
			sg_rec.idfSiteGroup
from		#MSFiltered msf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = msf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#MSFiltered msf_ex
on			msf_ex.idfMonitoringSession = msf.idfMonitoringSession 
			and	msf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		msf_ex.idfMonitoringSession is null	

-- Border Area Rules
insert into #MSFiltered
(
	idfMonitoringSession,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			msf.idfMonitoringSession,
			sg_central.idfSiteGroup
from		#MSFiltered msf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = msf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#MSFiltered msf_ex
on			msf_ex.idfMonitoringSession = msf.idfMonitoringSession 
			and	msf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		msf_ex.idfMonitoringSession is null	

set XACT_ABORT off
set nocount off
