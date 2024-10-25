-- Examples:
/*
	EXEC [dbo].[DF_CFRule_VSS]
*/
-- Prerequisites: Calculated default filtration rules for Vector Surveillance Sessions
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_CFRule_VSS] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#VSSFiltered') is null
create table	#VSSFiltered
(	[idfID]									bigint not null identity(1,1),
	[idfVectorSurveillanceSession]			bigint not null,
	[idfOutbreak]							bigint null,
	[idfSiteGroup]							bigint not null,
	[idfVectorSurveillanceSessionFiltered]	bigint null,
	primary key	(
		[idfVectorSurveillanceSession] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #VSSFiltered
(
	idfVectorSurveillanceSession,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			vssf.idfVectorSurveillanceSession,
			sg_rec.idfSiteGroup
from		#VSSFiltered vssf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = vssf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#VSSFiltered vssf_ex
on			vssf_ex.idfVectorSurveillanceSession = vssf.idfVectorSurveillanceSession 
			and	vssf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		vssf_ex.idfVectorSurveillanceSession is null	

-- Border Area Rules
insert into #VSSFiltered
(
	idfVectorSurveillanceSession,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			vssf.idfVectorSurveillanceSession,
			sg_central.idfSiteGroup
from		#VSSFiltered vssf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = vssf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#VSSFiltered vssf_ex
on			vssf_ex.idfVectorSurveillanceSession = vssf.idfVectorSurveillanceSession 
			and	vssf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		vssf_ex.idfVectorSurveillanceSession is null	

set XACT_ABORT off
set nocount off
