-- Examples:
/*
	EXEC [dbo].[DF_Aggregate_FillList]
	EXEC [dbo].[DF_Aggregate_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_Aggregate_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_Aggregate_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
)
AS

if Object_ID('tempdb..#cfrAggrCase') is null
create table	#cfrAggrCase
(	[idfAggrCase]					bigint not null primary key,
	[idfsSite]						bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfSentByOffice]				bigint null,
	[idfEnteredByOffice]			bigint null,
	[idfsAggrCaseRayon]				bigint null
)

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in Human/Veterinary Aggregate Reports and Actions meeting date criteria if any
if @StartDate is not null
insert into	#cfrAggrCase
(	[idfAggrCase]
)
select		top (@MaxNumberOfProcessedObjects)
			aggr.idfAggrCase
from		dbo.tlbAggrCase aggr with (nolock)
left join	#cfrAggrCase cfraggr
on			cfraggr.idfAggrCase = aggr.idfAggrCase
where		aggr.datModificationForArchiveDate >= @StartDate
			and (	aggr.idfsAggrCaseType = @CalculateHumanData * 10102001 /*Human Aggregate Case*/
					or aggr.idfsAggrCaseType = @CalculateVetData * 10502002 /*Vet Aggregate Case*/
					or aggr.idfsAggrCaseType = @CalculateVetData * 10502003 /*Vet Aggregate Action*/
				)
			and cfraggr.idfAggrCase is null

-- Update attributes of the predefined Human/Veterinary Aggregate Reports and Actions or those Human/Veterinary Aggregate Reports and Actions, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	update		cfraggr
	set			[idfsSite] = aggr.[idfsSite],
				[idfReceivedByOffice] = aggr.[idfReceivedByOffice],
				[idfSentByOffice] = aggr.[idfSentByOffice],
				[idfEnteredByOffice] = aggr.[idfEnteredByOffice],
				[idfsAggrCaseRayon] = ld.Level3ID
	from		#cfrAggrCase cfraggr
	join		dbo.tlbAggrCase aggr with (nolock)
	on			aggr.idfAggrCase = cfraggr.idfAggrCase
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = aggr.idfsAdministrativeUnit
				and ld.idfsLanguage = 10049003 /*en-US*/
end

