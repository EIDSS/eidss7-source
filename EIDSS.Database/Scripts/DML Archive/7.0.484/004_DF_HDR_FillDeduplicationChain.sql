-- Examples:
/*
	EXEC [dbo].[DF_HDR_FillDeduplicationChain]
	EXEC [dbo].[DF_HDR_FillDeduplicationChain] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_HDR_FillDeduplicationChain] @UsePredefinedData=1
*/
-- Prerequisites: in case of @UsePredefinedData=1 or specified @StartDate, list of predefined HDRs or those HDRs that meet date criteria shall be pre-filled.
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_HDR_FillDeduplicationChain] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrHC') is null
create table	#cfrHC
(	[idfHumanCase]					bigint not null primary key,
	[idfHuman]						bigint null,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfParentMonitoringSession]	bigint null,
	[idfDeduplicationResultCase]	bigint null,
	[idfSentByOffice]				bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfInvestigatedByOffice]		bigint null,
	[idfSoughtCareFacility]			bigint null,
	[idfHospital]					bigint null,
	[idfExposureLocation]			bigint null,
	[idfCRAddress]					bigint null,
	[idfsExposureLocRayon]			bigint null,
	[idfsCRARayon]					bigint null

)

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


declare @i int
declare	@N	int

-- Add chain of deduplication HDRs and update attributes of the predefined HDRs or those HDRs, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	set @i = 0

	insert into	#cfrHCDeduplicationChain
	(	[idfRootSurvivorHC],
		[intLevel],
		[idfLevelSurvivorHC],
		[idfLevelSupersededHC],
		[idfLevelSupersededParentMS],
		[idfLevelSupersededOutbreak]
	)
	select		distinct
				hc_survivor_root.idfHumanCase,
				@i,
				null,
				hc_survivor_root.idfHumanCase,
				hc_survivor_root.idfParentMonitoringSession,
				hc_survivor_root.idfOutbreak
	from		#cfrHC hc_survivor_root
	left join	#cfrHC hc_survivor_level
	on			hc_survivor_level.idfHumanCase = hc_survivor_root.idfDeduplicationResultCase
	left join	#cfrHCDeduplicationChain cfrhcdc_ex
	on			cfrhcdc_ex.idfRootSurvivorHC = hc_survivor_root.idfHumanCase
				and cfrhcdc_ex.idfLevelSupersededHC = hc_survivor_root.idfHumanCase
	where		hc_survivor_level.idfHumanCase is null
				and exists
					(	select	1
						from	#cfrHC hc_superseded_level
						where	hc_superseded_level.idfDeduplicationResultCase = hc_survivor_root.idfHumanCase
					)
				and cfrhcdc_ex.idfRootSurvivorHC is null
	set @N = @@ROWCOUNT

	while @N > 0 and @i < 20 /*length of the chain of deduplications*/
	begin
		set @i = @i + 1

		insert into	#cfrHCDeduplicationChain
		(	[idfRootSurvivorHC],
			[intLevel],
			[idfLevelSurvivorHC],
			[idfLevelSupersededHC],
			[idfLevelSupersededParentMS],
			[idfLevelSupersededOutbreak]
		)
		select		distinct
					hc_survivor_level.idfRootSurvivorHC,
					@i,
					hc_superseded_level.idfDeduplicationResultCase,
					hc_superseded_level.idfHumanCase,
					hc_superseded_level.idfParentMonitoringSession,
					hc_superseded_level.idfOutbreak
		from		#cfrHCDeduplicationChain hc_survivor_level
		join		#cfrHC hc_superseded_level
		on			hc_superseded_level.idfDeduplicationResultCase = hc_survivor_level.idfLevelSupersededHC
		left join	#cfrHCDeduplicationChain cfrhcdc_ex
		on			cfrhcdc_ex.idfRootSurvivorHC = hc_survivor_level.idfRootSurvivorHC
					and cfrhcdc_ex.idfLevelSupersededHC = hc_superseded_level.idfHumanCase
		where		hc_survivor_level.intLevel = @i - 1
					and cfrhcdc_ex.idfRootSurvivorHC is null
		set @N = @@ROWCOUNT
	end
end
else begin
	set @i = 0

	insert into	#cfrHCDeduplicationChain
	(	[idfRootSurvivorHC],
		[intLevel],
		[idfLevelSurvivorHC],
		[idfLevelSupersededHC],
		[idfLevelSupersededParentMS],
		[idfLevelSupersededOutbreak]
	)
	select		distinct
				hc_survivor_root.idfHumanCase,
				@i,
				null,
				hc_survivor_root.idfHumanCase,
				hc_survivor_root.idfParentMonitoringSession,
				hc_survivor_root.idfOutbreak
	from		tlbHumanCase hc_survivor_root with (nolock)
	left join	tlbHumanCase hc_survivor_level with (nolock)
	on			hc_survivor_level.idfHumanCase = hc_survivor_root.idfDeduplicationResultCase
	left join	#cfrHCDeduplicationChain cfrhcdc_ex
	on			cfrhcdc_ex.idfRootSurvivorHC = hc_survivor_root.idfHumanCase
				and cfrhcdc_ex.idfLevelSupersededHC = hc_survivor_root.idfHumanCase
	where		hc_survivor_level.idfHumanCase is null
				and exists
					(	select	1
						from	tlbHumanCase hc_superseded_level with (nolock)
						where	hc_superseded_level.idfDeduplicationResultCase = hc_survivor_root.idfHumanCase
					)
				and cfrhcdc_ex.idfRootSurvivorHC is null
	set @N = @@ROWCOUNT

	while @N > 0 and @i < 20 /*length of the chain of deduplications*/
	begin
		set @i = @i + 1

		insert into	#cfrHCDeduplicationChain
		(	[idfRootSurvivorHC],
			[intLevel],
			[idfLevelSurvivorHC],
			[idfLevelSupersededHC],
			[idfLevelSupersededParentMS],
			[idfLevelSupersededOutbreak]
		)
		select		distinct
					hc_survivor_level.idfRootSurvivorHC,
					@i,
					hc_superseded_level.idfDeduplicationResultCase,
					hc_superseded_level.idfHumanCase,
					hc_superseded_level.idfParentMonitoringSession,
					hc_superseded_level.idfOutbreak
		from		#cfrHCDeduplicationChain hc_survivor_level
		join		tlbHumanCase hc_superseded_level with (nolock)
		on			hc_superseded_level.idfDeduplicationResultCase = hc_survivor_level.idfLevelSupersededHC
		left join	#cfrHCDeduplicationChain cfrhcdc_ex
		on			cfrhcdc_ex.idfRootSurvivorHC = hc_survivor_level.idfRootSurvivorHC
					and cfrhcdc_ex.idfLevelSupersededHC = hc_superseded_level.idfHumanCase
		where		hc_survivor_level.intLevel = @i - 1
					and cfrhcdc_ex.idfRootSurvivorHC is null
		set @N = @@ROWCOUNT
	end
end
