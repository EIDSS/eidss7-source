-- Examples:
/*
	EXEC [dbo].[DF_VDR_Rule_ConnectedChain]
*/
-- Prerequisites: VDR Connected chains shall be pre-filled.
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_VDR_Rule_ConnectedChain] 
AS

if Object_ID('tempdb..#cfrVCConnectedChain') is null
create table	#cfrVCConnectedChain
(	[idfRootPredecessorVC]			bigint not null,
	[intLevel]						bigint not null,
	[idfLevelPredecessorVC]			bigint null,
	[idfLevelSuccessorVC]			bigint not null,
	[idfLevelSuccessorParentMS]		bigint null,
	[idfLevelSuccessorOutbreak]		bigint null,
	primary key
	(	[idfRootPredecessorVC] asc,
		[idfLevelSuccessorVC] asc
	)
)

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

if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)


-- Add existing filtration records for the VDRS from connected chains
insert into	#VCFiltered
(	idfVetCase,
	idfMonitoringSession,
	idfOutbreak,
	idfSiteGroup
)
select distinct
			vc.idfLevelSuccessorVC,
			vc.idfLevelSuccessorParentMS,
			vc.idfLevelSuccessorOutbreak,
			sg.idfSiteGroup
from		#cfrVCConnectedChain vc
inner join	dbo.tflVetCaseFiltered tflvc with (nolock)
on			tflvc.idfVetCase = vc.idfLevelSuccessorVC
cross apply
(	select	top 1 s.idfSiteGroup
	from		#SitesToCalculateFiltrationRecords s
	where		s.idfSiteGroup = tflvc.idfSiteGroup
) sg
left join	#VCFiltered vcf_ex
on			vcf_ex.idfVetCase = vc.idfLevelSuccessorVC
			and vcf_ex.idfSiteGroup = sg.idfSiteGroup
where		vcf_ex.idfID is null


-- Connected VDRs will go to all sites, where at least one VDR from their chains is available

-- Copy filtration records from all successors to their roots
insert into	#VCFiltered
(	idfVetCase,
	idfMonitoringSession,
	idfOutbreak,
	idfSiteGroup
)
select distinct
			vc_root.idfRootPredecessorVC,
			vc_root.idfLevelSuccessorParentMS,
			vc_root.idfLevelSuccessorOutbreak,
			vcf_level.idfSiteGroup
from		#cfrVCConnectedChain vc_root
inner join	#cfrVCConnectedChain vc_level
on			vc_level.idfRootPredecessorVC = vc_root.idfRootPredecessorVC
			and vc_level.intLevel > 0
inner join	#VCFiltered vcf_level
on			vcf_level.idfVetCase = vc_level.idfLevelSuccessorVC

left join	#VCFiltered vcf_ex
on			vcf_ex.idfVetCase = vc_root.idfRootPredecessorVC
			and vcf_ex.idfSiteGroup = vcf_level.idfSiteGroup
where		vc_root.intLevel = 0
			and exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = vcf_level.idfSiteGroup
				)
			and vcf_ex.idfID is null

-- Copy filtration records from the roots back to all their successors
insert into	#VCFiltered
(	idfVetCase,
	idfMonitoringSession,
	idfOutbreak,
	idfSiteGroup
)
select distinct
			vc_level.idfLevelSuccessorVC,
			vc_level.idfLevelSuccessorParentMS,
			vc_level.idfLevelSuccessorOutbreak,
			vcf_root.idfSiteGroup
from		#cfrVCConnectedChain vc_root
inner join	#cfrVCConnectedChain vc_level
on			vc_level.idfRootPredecessorVC = vc_root.idfRootPredecessorVC
			and vc_level.intLevel > 0
inner join	#VCFiltered vcf_root
on			vcf_root.idfVetCase = vc_root.idfRootPredecessorVC
left join	#VCFiltered vcf_ex
on			vcf_ex.idfVetCase = vc_level.idfLevelSuccessorVC
			and vcf_ex.idfSiteGroup = vcf_root.idfSiteGroup
where		vc_root.intLevel = 0
			and exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = vcf_root.idfSiteGroup
				)
			and vcf_ex.idfID is null
