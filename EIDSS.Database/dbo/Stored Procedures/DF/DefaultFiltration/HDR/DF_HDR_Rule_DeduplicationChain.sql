-- Examples:
/*
	EXEC [dbo].[DF_HDR_Rule_DeduplicationChain]
*/
-- Prerequisites: HDR Deduplication chains shall be pre-filled.
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_HDR_Rule_DeduplicationChain] 
AS

if Object_ID('tempdb..#cfrHCDeduplicationChain') is null
create table	#cfrHCDeduplicationChain
(	[idfRootSurvivorHC]				bigint not null,
	[intLevel]						bigint not null,
	[idfLevelSurvivorHC]			bigint null,
	[idfLevelSupersededHC]			bigint not null,
	[idfLevelSupersededParentMS]	bigint null,
	[idfLevelSupersededOutbreak]	bigint null,
	primary key
	(	[idfRootSurvivorHC] asc,
		[idfLevelSupersededHC] asc
	)
)

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

if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)


-- Add existing filtration records for the HDRS from deduplication chains
insert into	#HCFiltered
(	idfHumanCase,
	idfMonitoringSession,
	idfOutbreak,
	idfSiteGroup
)
select distinct
			hc.idfLevelSupersededHC,
			hc.idfLevelSupersededParentMS,
			hc.idfLevelSupersededOutbreak,
			sg.idfSiteGroup
from		#cfrHCDeduplicationChain hc
inner join	dbo.tflHumanCaseFiltered tflhc with (nolock)
on			tflhc.idfHumanCase = hc.idfLevelSupersededHC
cross apply
(	select	top 1 s.idfSiteGroup
	from		#SitesToCalculateFiltrationRecords s
	where		s.idfSiteGroup = tflhc.idfSiteGroup
) sg
left join	#HCFiltered hcf_ex
on			hcf_ex.idfHumanCase = hc.idfLevelSupersededHC
			and hcf_ex.idfSiteGroup = sg.idfSiteGroup
where		hcf_ex.idfID is null


declare @i int
select	@i = MAX([intLevel])
from	#cfrHCDeduplicationChain
-- Survivor HDRs will go to all sites, where Superseded HDRs from their chains are available
while @i > 0
begin
	insert into	#HCFiltered
	(	idfHumanCase,
		idfMonitoringSession,
		idfOutbreak,
		idfSiteGroup
	)
	select distinct
				hc_survivor.idfLevelSupersededHC,
				hc_survivor.idfLevelSupersededParentMS,
				hc_survivor.idfLevelSupersededOutbreak,
				hcf.idfSiteGroup
	from		#cfrHCDeduplicationChain hc_superseded
	inner join	#cfrHCDeduplicationChain hc_survivor
	on			hc_survivor.idfLevelSupersededHC = hc_superseded.idfLevelSurvivorHC
				and hc_survivor.idfRootSurvivorHC = hc_superseded.idfRootSurvivorHC
				and hc_survivor.intLevel + 1 = hc_superseded.intLevel
	inner join	#HCFiltered hcf
	on			hcf.idfHumanCase = hc_superseded.idfLevelSupersededHC
	left join	#HCFiltered hcf_ex
	on			hcf_ex.idfHumanCase = hc_survivor.idfLevelSupersededHC
				and hcf_ex.idfSiteGroup = hcf.idfSiteGroup
	where		hc_superseded.intLevel = @i
				and hcf_ex.idfID is null

	set @i = @i - 1
end
