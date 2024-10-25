-- Examples:
/*
	EXEC [dbo].[DF_CFRule_BSS]
*/
-- Prerequisites: Calculated default filtration rules for Basic Surveillance Sessions
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CFRule_BSS] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#BSSFiltered') is null
create table	#BSSFiltered
(	[idfID]									bigint not null identity(1,1),
	[idfBasicSyndromicSurveillance]			bigint not null,
	[idfSiteGroup]							bigint not null,
	[idfBasicSyndromicSurveillanceFiltered]	bigint null,
	primary key	(
		[idfBasicSyndromicSurveillance] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #BSSFiltered
(
	idfBasicSyndromicSurveillance,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			bssf.idfBasicSyndromicSurveillance,
			sg_rec.idfSiteGroup
from		#BSSFiltered bssf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = bssf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#BSSFiltered bssf_ex
on			bssf_ex.idfBasicSyndromicSurveillance = bssf.idfBasicSyndromicSurveillance 
			and	bssf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		bssf_ex.idfBasicSyndromicSurveillance is null	

-- Border Area Rules
insert into #BSSFiltered
(
	idfBasicSyndromicSurveillance,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			bssf.idfBasicSyndromicSurveillance,
			sg_central.idfSiteGroup
from		#BSSFiltered bssf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = bssf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#BSSFiltered bssf_ex
on			bssf_ex.idfBasicSyndromicSurveillance = bssf.idfBasicSyndromicSurveillance 
			and	bssf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		bssf_ex.idfBasicSyndromicSurveillance is null	

set XACT_ABORT off
set nocount off
