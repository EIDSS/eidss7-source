-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_HDR] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_HDR] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#HCFiltered') is null
create table	#HCFiltered
(	[idfID]					bigint not null identity(1,1),
	[idfHumanCase]			bigint not null,
	[idfMonitoringSession]	bigint null,
	[idfOutbreak]			bigint null,
	[idfSiteGroup]			bigint not null,
	[idfHumanCaseFiltered]	bigint null,
	primary key	(
		[idfHumanCase] asc,
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
		N'HC' + @guid,
		cf.idfHumanCase,
		cf.idfSiteGroup
from	#HCFiltered cf
where	cf.idfHumanCaseFiltered is null

insert into	dbo.tflHumanCaseFiltered
(	idfHumanCaseFiltered,
	idfHumanCase,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfHumanCase,
			cf.idfSiteGroup
from		#HCFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'HC' + @guid
			and nId.idfKey1 = cf.idfHumanCase
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflHumanCaseFiltered cf_ex
on			cf_ex.idfHumanCaseFiltered = nId.[NewID]
where		cf_ex.idfHumanCaseFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for HDRs: ' + cast(@InsertedRecords as varchar(20))
