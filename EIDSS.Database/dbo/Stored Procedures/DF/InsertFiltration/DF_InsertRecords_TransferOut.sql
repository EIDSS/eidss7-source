-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_TransferOut] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_TransferOut] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#TransferOutFiltered') is null
create table	#TransferOutFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfTransferOut]			bigint not null,
	[idfSiteGroup]				bigint not null,
	[idfTransferOutFiltered]	bigint null,
	primary key	(
		[idfTransferOut] asc,
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
		N'tOut' + @guid,
		cf.idfTransferOut,
		cf.idfSiteGroup
from	#TransferOutFiltered cf
where	cf.idfTransferOutFiltered is null

insert into	dbo.tflTransferOutFiltered
(	idfTransferOutFiltered,
	idfTransferOut,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfTransferOut,
			cf.idfSiteGroup
from		#TransferOutFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'tOut' + @guid
			and nId.idfKey1 = cf.idfTransferOut
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflTransferOutFiltered cf_ex
on			cf_ex.idfTransferOutFiltered = nId.[NewID]
where		cf_ex.idfTransferOutFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for Transfer Out Acts: ' + cast(@InsertedRecords as varchar(20))
