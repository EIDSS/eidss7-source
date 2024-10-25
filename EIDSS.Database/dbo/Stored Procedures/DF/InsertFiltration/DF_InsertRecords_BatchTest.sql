-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_BatchTest] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_BatchTest] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#BatchTestFiltered') is null
create table	#BatchTestFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfBatchTest]				bigint not null,
	[idfSiteGroup]				bigint not null,
	[idfBatchTestFiltered]	bigint null,
	primary key	(
		[idfBatchTest] asc,
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
		N'BT' + @guid,
		cf.idfBatchTest,
		cf.idfSiteGroup
from	#BatchTestFiltered cf
where	cf.idfBatchTestFiltered is null

insert into	dbo.tflBatchTestFiltered
(	idfBatchTestFiltered,
	idfBatchTest,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfBatchTest,
			cf.idfSiteGroup
from		#BatchTestFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'BT' + @guid
			and nId.idfKey1 = cf.idfBatchTest
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflBatchTestFiltered cf_ex
on			cf_ex.idfBatchTestFiltered = nId.[NewID]
where		cf_ex.idfBatchTestFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for Batch Tests: ' + cast(@InsertedRecords as varchar(20))
