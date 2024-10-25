-- Examples:
/*
	EXEC [dbo].[DF_HDR_FillList]
	EXEC [dbo].[DF_HDR_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_HDR_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_HDR_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000
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

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

declare @i int
declare	@N	int

-- Fill in HDRs meeting date criteria if any
if @StartDate is not null
insert into	#cfrHC
(	[idfHumanCase]
)
select		top (@MaxNumberOfProcessedObjects)
			hc.[idfHumanCase]
from		dbo.tlbHumanCase hc with (nolock)
left join	#cfrHC cfrhc
on			cfrhc.idfHumanCase = hc.idfHumanCase
where		hc.datModificationForArchiveDate >= @StartDate
			and cfrhc.idfHumanCase is null

-- Add chains of deduplicated HDRs and update attributes of the predefined HDRs or those HDRs, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin

	set @N = 1
	set @i = 0

	while @N > 0 and @i < 10 /*length of the chain of deduplications*/
	begin
		insert into	#cfrHC
		(	[idfHumanCase]
		)
		select		distinct top (@MaxNumberOfProcessedObjects)
					hc_dupl.[idfHumanCase]
		from		#cfrHC cfrhc
		inner join	dbo.tlbHumanCase hc with (nolock)
		on			hc.idfHumanCase = cfrhc.idfHumanCase
		inner join	dbo.tlbHumanCase hc_dupl with (nolock)
		on			hc_dupl.idfDeduplicationResultCase = hc.idfHumanCase
		left join	#cfrHC cfrhc_ex
		on			cfrhc_ex.idfHumanCase = hc_dupl.[idfHumanCase]
		where		cfrhc_ex.idfHumanCase is null
		set @N = @@ROWCOUNT

		insert into	#cfrHC
		(	[idfHumanCase]
		)
		select		distinct top (@MaxNumberOfProcessedObjects)
					hc_dupl.[idfHumanCase]
		from		#cfrHC cfrhc
		inner join	dbo.tlbHumanCase hc with (nolock)
		on			hc.idfHumanCase = cfrhc.idfHumanCase
		inner join	dbo.tlbHumanCase hc_dupl with (nolock)
		on			hc_dupl.idfHumanCase = hc.idfDeduplicationResultCase
		left join	#cfrHC cfrhc_ex
		on			cfrhc_ex.idfHumanCase = hc_dupl.[idfHumanCase]
		where		cfrhc_ex.idfHumanCase is null
		set @N = @N + @@ROWCOUNT

		set @i = @i + 1
	end

	update		cfrhc
	set			[idfHuman] = hc.[idfHuman],
				[idfsSite] = hc.[idfsSite],
				[idfOutbreak] = hc.[idfOutbreak],
				[idfParentMonitoringSession] = hc.[idfParentMonitoringSession],
				[idfDeduplicationResultCase] = hc.[idfDeduplicationResultCase],
				[idfSentByOffice] = hc.[idfSentByOffice],
				[idfReceivedByOffice] = hc.[idfReceivedByOffice],
				[idfInvestigatedByOffice] = hc.[idfInvestigatedByOffice],
				[idfSoughtCareFacility] = hc.[idfSoughtCareFacility],
				[idfHospital] = hc.[idfHospital],
				[idfExposureLocation] = hc.[idfPointGeoLocation],
				[idfCRAddress] = h.idfCurrentResidenceAddress
	from		#cfrHC cfrhc
	join		dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase
	left join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = hc.idfHuman

	update		cfrhc
	set			[idfsExposureLocRayon] = ld.Level3ID
	from		#cfrHC cfrhc
	join		dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = cfrhc.[idfExposureLocation]
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	where		gl.blnForeignAddress = 0

	update		cfrhc
	set			[idfsCRARayon] = ld.Level3ID
	from		#cfrHC cfrhc
	join		dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = cfrhc.[idfCRAddress]
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	where		gl.blnForeignAddress = 0
end

-- Create a tree of deduplicated HDRs that shall fall under calculation of filtration records
exec [dbo].[DF_HDR_FillDeduplicationChain] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate