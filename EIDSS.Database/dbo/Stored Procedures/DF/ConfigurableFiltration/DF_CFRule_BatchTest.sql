-- Examples:
/*
	EXEC [dbo].[DF_CFRule_BatchTest]
*/
-- Prerequisites: Calculated default filtration rules for Batch Tests
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CFRule_BatchTest] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#BatchTestFiltered') is null
create table	#BatchTestFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfBatchTest]				bigint not null,
	[idfSiteGroup]				bigint not null,
	[idfBatchTestFiltered]	bigint null,
	primary key	(
		[idfBatchTest] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #BatchTestFiltered
(
	idfBatchTest,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			btf.idfBatchTest,
			sg_rec.idfSiteGroup
from		#BatchTestFiltered btf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = btf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#BatchTestFiltered btf_ex
on			btf_ex.idfBatchTest = btf.idfBatchTest 
			and	btf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		btf_ex.idfBatchTest is null	

-- Border Area Rules
insert into #BatchTestFiltered
(
	idfBatchTest,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			btf.idfBatchTest,
			sg_central.idfSiteGroup
from		#BatchTestFiltered btf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = btf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#BatchTestFiltered btf_ex
on			btf_ex.idfBatchTest = btf.idfBatchTest 
			and	btf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		btf_ex.idfBatchTest is null	

set XACT_ABORT off
set nocount off
