-- Examples:
/*
	EXEC [dbo].[DF_VDR_FillConnectedChain]
	EXEC [dbo].[DF_VDR_FillConnectedChain] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_VDR_FillConnectedChain] @UsePredefinedData=1
*/
-- Prerequisites: in case of @UsePredefinedData=1 or specified @StartDate, list of predefined VDRs or those VDRs that meet date criteria shall be pre-filled.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_VDR_FillConnectedChain] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrVC') is null
create table	#cfrVC
(	[idfVetCase]					bigint not null primary key,
	[idfFarm]						bigint null,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfParentMonitoringSession]	bigint null,
	[idfReportedByOffice]			bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfInvestigatedByOffice]		bigint null,
	[idfFarmAddress]				bigint null,
	[idfsFarmAddressRayon]			bigint null,
	[intRowStatus]					int null
)


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


declare @i int
declare	@N	int

-- Add chain of connected VDRs and update attributes of the predefined VDRs or those VDRs, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	set @i = 0

	insert into	#cfrVCConnectedChain
	(	[idfRootPredecessorVC],
		[intLevel],
		[idfLevelPredecessorVC],
		[idfLevelSuccessorVC],
		[idfLevelSuccessorParentMS],
		[idfLevelSuccessorOutbreak]
	)
	select		distinct
				vc_predecessor_root.idfVetCase,
				@i,
				null,
				vc_predecessor_root.idfVetCase,
				vc_predecessor_root.idfParentMonitoringSession,
				vc_predecessor_root.idfOutbreak
	from		#cfrVC vc_predecessor_root
	left join	#cfrVC vc_predecessor_level
		inner join	dbo.VetDiseaseReportRelationship vdr_rel_predecessor with (nolock)
		on			vdr_rel_predecessor.RelatedToVetDiseaseReportID = vc_predecessor_level.idfVetCase
					and vdr_rel_predecessor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
					and vdr_rel_predecessor.intRowStatus <= vc_predecessor_level.intRowStatus
	on			vdr_rel_predecessor.VetDiseaseReportID = vc_predecessor_root.idfVetCase
				and vdr_rel_predecessor.intRowStatus <= vc_predecessor_root.intRowStatus
	left join	#cfrVCConnectedChain cfrvccc_ex
	on			cfrvccc_ex.idfRootPredecessorVC = vc_predecessor_root.idfVetCase
				and cfrvccc_ex.idfLevelSuccessorVC = vc_predecessor_root.idfVetCase
	where		vc_predecessor_level.idfVetCase is null
				and exists
					(	select		1
						from		#cfrVC vc_successor_level
						inner join	dbo.VetDiseaseReportRelationship vdr_rel_successor with (nolock)
						on			vdr_rel_successor.VetDiseaseReportID = vc_successor_level.idfVetCase
									and vdr_rel_successor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
									and vdr_rel_successor.intRowStatus <= vc_successor_level.intRowStatus
									and vdr_rel_successor.intRowStatus <= vc_predecessor_root.intRowStatus
						where		vdr_rel_successor.RelatedToVetDiseaseReportID = vc_predecessor_root.idfVetCase
					)
				and cfrvccc_ex.idfRootPredecessorVC is null
	set @N = @@ROWCOUNT

	while @N > 0 and @i < 20 /*length of the chain of connected VDRs*/
	begin
		set @i = @i + 1

		insert into	#cfrVCConnectedChain
		(	[idfRootPredecessorVC],
			[intLevel],
			[idfLevelPredecessorVC],
			[idfLevelSuccessorVC],
			[idfLevelSuccessorParentMS],
			[idfLevelSuccessorOutbreak]
		)
		select		distinct
					vccc_level.idfRootPredecessorVC,
					@i,
					vc_level.idfVetCase,
					vc_successor_level.idfVetCase,
					vc_successor_level.idfParentMonitoringSession,
					vc_successor_level.idfOutbreak
		from		#cfrVCConnectedChain vccc_level
		inner join	#cfrVC vc_level
		on			vc_level.idfVetCase = vccc_level.idfLevelSuccessorVC
		inner join	dbo.VetDiseaseReportRelationship vdr_rel_successor with (nolock)
		on			vdr_rel_successor.RelatedToVetDiseaseReportID = vc_level.idfVetCase
					and vdr_rel_successor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
					and vdr_rel_successor.intRowStatus <= vc_level.intRowStatus
		inner join	#cfrVC vc_successor_level
		on			vc_successor_level.idfVetCase = vdr_rel_successor.VetDiseaseReportID
					and vdr_rel_successor.intRowStatus <= vc_successor_level.intRowStatus
		left join	#cfrVCConnectedChain cfrvccc_ex
		on			cfrvccc_ex.idfRootPredecessorVC = vccc_level.idfRootPredecessorVC
					and cfrvccc_ex.idfLevelSuccessorVC = vc_successor_level.idfVetCase
		where		vccc_level.intLevel = @i - 1
					and cfrvccc_ex.idfRootPredecessorVC is null
		set @N = @@ROWCOUNT
	end
end
else begin
	set @i = 0

	insert into	#cfrVCConnectedChain
	(	[idfRootPredecessorVC],
		[intLevel],
		[idfLevelPredecessorVC],
		[idfLevelSuccessorVC],
		[idfLevelSuccessorParentMS],
		[idfLevelSuccessorOutbreak]
	)
	select		distinct
				vc_predecessor_root.idfVetCase,
				@i,
				null,
				vc_predecessor_root.idfVetCase,
				vc_predecessor_root.idfParentMonitoringSession,
				vc_predecessor_root.idfOutbreak
	from		dbo.tlbVetCase vc_predecessor_root with (nolock)
	left join	dbo.tlbVetCase vc_predecessor_level with (nolock)
		inner join	dbo.VetDiseaseReportRelationship vdr_rel_predecessor with (nolock)
		on			vdr_rel_predecessor.RelatedToVetDiseaseReportID = vc_predecessor_level.idfVetCase
					and vdr_rel_predecessor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
					and vdr_rel_predecessor.intRowStatus <= vc_predecessor_level.intRowStatus
	on			vdr_rel_predecessor.VetDiseaseReportID = vc_predecessor_root.idfVetCase
				and vdr_rel_predecessor.intRowStatus <= vc_predecessor_root.intRowStatus
	left join	#cfrVCConnectedChain cfrvccc_ex
	on			cfrvccc_ex.idfRootPredecessorVC = vc_predecessor_root.idfVetCase
				and cfrvccc_ex.idfLevelSuccessorVC = vc_predecessor_root.idfVetCase
	where		vc_predecessor_level.idfVetCase is null
				and exists
					(	select		1
						from		dbo.tlbVetCase vc_successor_level with (nolock)
						inner join	dbo.VetDiseaseReportRelationship vdr_rel_successor with (nolock)
						on			vdr_rel_successor.VetDiseaseReportID = vc_successor_level.idfVetCase
									and vdr_rel_successor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
									and vdr_rel_successor.intRowStatus <= vc_successor_level.intRowStatus
									and vdr_rel_successor.intRowStatus <= vc_predecessor_level.intRowStatus
						where		vdr_rel_successor.RelatedToVetDiseaseReportID = vc_predecessor_root.idfVetCase
					)
				and cfrvccc_ex.idfRootPredecessorVC is null
	set @N = @@ROWCOUNT

	while @N > 0 and @i < 20 /*length of the chain of deduplications*/
	begin
		set @i = @i + 1

		insert into	#cfrVCConnectedChain
		(	[idfRootPredecessorVC],
			[intLevel],
			[idfLevelPredecessorVC],
			[idfLevelSuccessorVC],
			[idfLevelSuccessorParentMS],
			[idfLevelSuccessorOutbreak]
		)
		select		distinct
					vccc_level.idfRootPredecessorVC,
					@i,
					vc_level.idfVetCase,
					vc_successor_level.idfVetCase,
					vc_successor_level.idfParentMonitoringSession,
					vc_successor_level.idfOutbreak
		from		#cfrVCConnectedChain vccc_level
		inner join	dbo.tlbVetCase vc_level with (nolock)
		on			vc_level.idfVetCase = vccc_level.idfLevelSuccessorVC
		inner join	dbo.VetDiseaseReportRelationship vdr_rel_successor with (nolock)
		on			vdr_rel_successor.RelatedToVetDiseaseReportID = vc_level.idfVetCase
					and vdr_rel_successor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
					and vdr_rel_successor.intRowStatus <= vc_level.intRowStatus
		inner join	dbo.tlbVetCase vc_successor_level with (nolock)
		on			vc_successor_level.idfVetCase = vdr_rel_successor.VetDiseaseReportID
					and vdr_rel_successor.intRowStatus <= vc_successor_level.intRowStatus
		left join	#cfrVCConnectedChain cfrvccc_ex
		on			cfrvccc_ex.idfRootPredecessorVC = vccc_level.idfRootPredecessorVC
					and cfrvccc_ex.idfLevelSuccessorVC = vc_successor_level.idfVetCase
		where		vccc_level.intLevel = @i - 1
					and cfrvccc_ex.idfRootPredecessorVC is null
		set @N = @@ROWCOUNT
	end
end
