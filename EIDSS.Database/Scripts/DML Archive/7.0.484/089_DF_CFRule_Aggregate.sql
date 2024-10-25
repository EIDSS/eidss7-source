-- Examples:
/*
	EXEC [dbo].[DF_CFRule_Aggregate]
*/
-- Prerequisites: Calculated default filtration rules for Aggregate Reports and Actions
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_CFRule_Aggregate] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#AggrCaseFiltered') is null
create table	#AggrCaseFiltered
(	[idfID]					bigint not null identity(1,1),
	[idfAggrCase]			bigint not null,
	[idfSiteGroup]			bigint not null,
	[idfAggrCaseFiltered]	bigint null,
	primary key	(
		[idfAggrCase] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #AggrCaseFiltered
(
	idfAggrCase,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			aggrf.idfAggrCase,
			sg_rec.idfSiteGroup
from		#AggrCaseFiltered aggrf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = aggrf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#AggrCaseFiltered aggrf_ex
on			aggrf_ex.idfAggrCase = aggrf.idfAggrCase 
			and	aggrf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		aggrf_ex.idfAggrCase is null	

-- Border Area Rules
insert into #AggrCaseFiltered
(
	idfAggrCase,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			aggrf.idfAggrCase,
			sg_central.idfSiteGroup
from		#AggrCaseFiltered aggrf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = aggrf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#AggrCaseFiltered aggrf_ex
on			aggrf_ex.idfAggrCase = aggrf.idfAggrCase 
			and	aggrf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		aggrf_ex.idfAggrCase is null	

set XACT_ABORT off
set nocount off
