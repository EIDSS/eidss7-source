-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_VDR] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_InsertRecords_VDR] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

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

declare	@guid nvarchar(128) = cast(newid() as nvarchar(36))

insert into	dbo.tflNewID
(	strTableName,
	idfKey1,
	idfKey2
)
select	top (@MaxNumberOfNewFiltrationRecords)
		N'VC' + @guid,
		cf.idfVetCase,
		cf.idfSiteGroup
from	#VCFiltered cf
where	cf.idfVetCaseFiltered is null

insert into	dbo.tflVetCaseFiltered
(	idfVetCaseFiltered,
	idfVetCase,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfVetCase,
			cf.idfSiteGroup
from		#VCFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'VC' + @guid
			and nId.idfKey1 = cf.idfVetCase
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflVetCaseFiltered cf_ex
on			cf_ex.idfVetCaseFiltered = nId.[NewID]
where		cf_ex.idfVetCaseFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for VDRs: ' + cast(@InsertedRecords as varchar(20))
