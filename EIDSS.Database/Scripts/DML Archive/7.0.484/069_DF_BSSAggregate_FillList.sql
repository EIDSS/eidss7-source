-- Examples:
/*
	EXEC [dbo].[DF_BSSAggregate_FillList]
	EXEC [dbo].[DF_BSSAggregate_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BSSAggregate_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BSSAggregate_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000
)
AS

if Object_ID('tempdb..#cfrBSSAggr') is null
create table	#cfrBSSAggr
(	[idfAggregateHeader]			bigint not null primary key,
	[idfsSite]						bigint null
)

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in ILI Aggregate Form meeting date criteria if any
if @StartDate is not null
insert into	#cfrBSSAggr
(	[idfAggregateHeader]
)
select		top (@MaxNumberOfProcessedObjects)
			bssaaggr.idfAggregateHeader
from		dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaaggr with (nolock)
left join	#cfrBSSAggr cfrbssaggr
on			cfrbssaggr.idfAggregateHeader = bssaaggr.idfAggregateHeader
where		bssaaggr.datModificationForArchiveDate >= @StartDate
			and cfrbssaggr.idfAggregateHeader is null

-- Update attributes of the predefined ILI Aggregate Forms or those ILI Aggregate Forms, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	update		cfrbssaggr
	set			[idfsSite] = bssaaggr.[idfsSite]
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaaggr with (nolock)
	on			bssaaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader
end

