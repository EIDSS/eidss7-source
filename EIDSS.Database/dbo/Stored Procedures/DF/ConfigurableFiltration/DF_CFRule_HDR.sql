-- Examples:
/*
	EXEC [dbo].[DF_CFRule_HDR]
*/
-- Prerequisites: Calculated default filtration rules for HDRs
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CFRule_HDR] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

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

-- Unidirectional configurable filtration rules
insert into #HCFiltered
(
	idfHumanCase,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			hcf.idfHumanCase,
			sg_rec.idfSiteGroup
from		#HCFiltered hcf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = hcf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#HCFiltered hcf_ex
on			hcf_ex.idfHumanCase = hcf.idfHumanCase 
			and	hcf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		hcf_ex.idfHumanCase is null	

-- Border Area Rules
insert into #HCFiltered
(
	idfHumanCase,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			hcf.idfHumanCase,
			sg_central.idfSiteGroup
from		#HCFiltered hcf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = hcf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#HCFiltered hcf_ex
on			hcf_ex.idfHumanCase = hcf.idfHumanCase 
			and	hcf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		hcf_ex.idfHumanCase is null	

set XACT_ABORT off
set nocount off
