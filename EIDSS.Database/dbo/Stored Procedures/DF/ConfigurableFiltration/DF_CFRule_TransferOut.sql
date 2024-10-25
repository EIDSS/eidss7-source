-- Examples:
/*
	EXEC [dbo].[DF_CFRule_TransferOut]
*/
-- Prerequisites: Calculated default filtration rules for Transfer Out Acts
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CFRule_TransferOut] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#TransferOutFiltered') is null
create table	#TransferOutFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfTransferOut]			bigint not null,
	[idfSiteGroup]				bigint not null,
	[idfTransferOutFiltered]	bigint null,
	primary key	(
		[idfTransferOut] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #TransferOutFiltered
(
	idfTransferOut,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			tOutf.idfTransferOut,
			sg_rec.idfSiteGroup
from		#TransferOutFiltered tOutf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = tOutf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#TransferOutFiltered tOutf_ex
on			tOutf_ex.idfTransferOut = tOutf.idfTransferOut 
			and	tOutf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		tOutf_ex.idfTransferOut is null	

-- Border Area Rules
insert into #TransferOutFiltered
(
	idfTransferOut,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			tOutf.idfTransferOut,
			sg_central.idfSiteGroup
from		#TransferOutFiltered tOutf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = tOutf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#TransferOutFiltered tOutf_ex
on			tOutf_ex.idfTransferOut = tOutf.idfTransferOut 
			and	tOutf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		tOutf_ex.idfTransferOut is null	

set XACT_ABORT off
set nocount off
