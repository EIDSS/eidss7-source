-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_Aggregate] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_InsertRecords_Aggregate] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#AggrCaseFiltered') is null
create table	#AggrCaseFiltered
(	[idfID]					bigint not null identity(1,1),
	[idfAggrCase]			bigint not null,
	[idfSiteGroup]			bigint not null,
	[idfAggrCaseFiltered]	bigint null,
	primary key	(
		[idfAggrCase] asc,
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
		N'Aggr' + @guid,
		cf.idfAggrCase,
		cf.idfSiteGroup
from	#AggrCaseFiltered cf
where	cf.idfAggrCaseFiltered is null

insert into	dbo.tflAggrCaseFiltered
(	idfAggrCaseFiltered,
	idfAggrCase,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfAggrCase,
			cf.idfSiteGroup
from		#AggrCaseFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'Aggr' + @guid
			and nId.idfKey1 = cf.idfAggrCase
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflAggrCaseFiltered cf_ex
on			cf_ex.idfAggrCaseFiltered = nId.[NewID]
where		cf_ex.idfAggrCaseFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for Aggregate Reports and Actions: ' + cast(@InsertedRecords as varchar(20))
