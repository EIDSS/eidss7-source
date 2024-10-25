-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_BSSAggregate] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_BSSAggregate] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#BSSAggrFiltered') is null
create table	#BSSAggrFiltered
(	[idfID]													bigint not null identity(1,1),
	[idfAggregateHeader]									bigint not null,
	[idfSiteGroup]											bigint not null,
	[idfBasicSyndromicSurveillanceAggregateHeaderFiltered]	bigint null,
	primary key	(
		[idfAggregateHeader] asc,
		[idfSiteGroup] asc
				)
)

declare	@guid nvarchar(128) = cast(newid() as nvarchar(36))

insert into	dbo.tflNewID
(	strTableName,
	idfKey1,
	idfKey2
)
select	top (@MaxNumberOfNewFiltrationRecords)
		N'BSSAggr' + @guid,
		cf.idfAggregateHeader,
		cf.idfSiteGroup
from	#BSSAggrFiltered cf
where	cf.idfBasicSyndromicSurveillanceAggregateHeaderFiltered is null

insert into	dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered
(	idfBasicSyndromicSurveillanceAggregateHeaderFiltered,
	idfAggregateHeader,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfAggregateHeader,
			cf.idfSiteGroup
from		#BSSAggrFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'BSSAggr' + @guid
			and nId.idfKey1 = cf.idfAggregateHeader
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered cf_ex
on			cf_ex.idfBasicSyndromicSurveillanceAggregateHeaderFiltered = nId.[NewID]
where		cf_ex.idfBasicSyndromicSurveillanceAggregateHeaderFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for ILI Aggregate Forms: ' + cast(@InsertedRecords as varchar(20))
