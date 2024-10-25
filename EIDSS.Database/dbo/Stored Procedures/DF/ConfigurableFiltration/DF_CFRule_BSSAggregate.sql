-- Examples:
/*
	EXEC [dbo].[DF_CFRule_BSSAggregate]
*/
-- Prerequisites: Calculated default filtration rules for ILI Aggregate Forms
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CFRule_BSSAggregate] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#BSSAggrFiltered') is null
create table	#BSSAggrFiltered
(	[idfID]													bigint not null identity(1,1),
	[idfAggregateHeader]									bigint not null,
	[idfSiteGroup]											bigint not null,
	[idfBasicSyndromicSurveillanceAggregateHeaderFiltered]	bigint null,
	primary key	(
		[idfAggregateHeader] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #BSSAggrFiltered
(
	idfAggregateHeader,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			bssaggrf.idfAggregateHeader,
			sg_rec.idfSiteGroup
from		#BSSAggrFiltered bssaggrf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = bssaggrf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#BSSAggrFiltered bssaggrf_ex
on			bssaggrf_ex.idfAggregateHeader = bssaggrf.idfAggregateHeader 
			and	bssaggrf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		bssaggrf_ex.idfAggregateHeader is null	

-- Border Area Rules
insert into #BSSAggrFiltered
(
	idfAggregateHeader,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			bssaggrf.idfAggregateHeader,
			sg_central.idfSiteGroup
from		#BSSAggrFiltered bssaggrf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = bssaggrf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#BSSAggrFiltered bssaggrf_ex
on			bssaggrf_ex.idfAggregateHeader = bssaggrf.idfAggregateHeader 
			and	bssaggrf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		bssaggrf_ex.idfAggregateHeader is null	

set XACT_ABORT off
set nocount off
