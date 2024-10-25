-- Examples:
/*
	EXEC [dbo].[DF_CFRule_VDR]
*/
-- Prerequisites: Calculated default filtration rules for VDRs
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_CFRule_VDR] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#VCFiltered') is null
create table	#VCFiltered
(	[idfID]					bigint not null identity(1,1),
	[idfVetCase]			bigint not null,
	[idfMonitoringSession]	bigint null,
	[idfOutbreak]			bigint null,
	[idfSiteGroup]			bigint not null,
	[idfVetCaseFiltered]	bigint null,
	primary key	(
		[idfVetCase] asc,
		[idfSiteGroup] asc
				)
)

-- Unidirectional configurable filtration rules
insert into #VCFiltered
(
	idfVetCase,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			vcf.idfVetCase,
			sg_rec.idfSiteGroup
from		#VCFiltered vcf
inner join	dbo.tflSiteGroupRelation sg_rel with (nolock)
on			sg_rel.idfSenderSiteGroup = vcf.idfSiteGroup
inner join	dbo.tflSiteGroup sg_rec with (nolock)
on			sg_rec.idfSiteGroup = sg_rel.idfReceiverSiteGroup
			and sg_rec.intRowStatus = 0
left join	#VCFiltered vcf_ex
on			vcf_ex.idfVetCase = vcf.idfVetCase 
			and	vcf_ex.idfSiteGroup = sg_rec.idfSiteGroup
where		vcf_ex.idfVetCase is null	

-- Border Area Rules
insert into #VCFiltered
(
	idfVetCase,
	idfSiteGroup
)
select distinct top(@MaxNumberOfNewFiltrationRecords)
			vcf.idfVetCase,
			sg_central.idfSiteGroup
from		#VCFiltered vcf
inner join	dbo.tflSiteGroup sg with (nolock)
on			sg.idfSiteGroup = vcf.idfSiteGroup
inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
on			s_to_sg.idfSiteGroup = sg.idfSiteGroup
inner join	dbo.tflSiteGroup sg_central with (nolock)
on			sg_central.idfsCentralSite = s_to_sg.idfsSite
			and sg_central.intRowStatus = 0
left join	#VCFiltered vcf_ex
on			vcf_ex.idfVetCase = vcf.idfVetCase 
			and	vcf_ex.idfSiteGroup = sg_central.idfSiteGroup
where		vcf_ex.idfVetCase is null	

set XACT_ABORT off
set nocount off
