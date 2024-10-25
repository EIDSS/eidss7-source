-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_VSS] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_VSS] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#VSSFiltered') is null
create table	#VSSFiltered
(	[idfID]									bigint not null identity(1,1),
	[idfVectorSurveillanceSession]			bigint not null,
	[idfOutbreak]							bigint null,
	[idfSiteGroup]							bigint not null,
	[idfVectorSurveillanceSessionFiltered]	bigint null,
	primary key	(
		[idfVectorSurveillanceSession] asc,
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
		N'VSS' + @guid,
		cf.idfVectorSurveillanceSession,
		cf.idfSiteGroup
from	#VSSFiltered cf
where	cf.idfVectorSurveillanceSessionFiltered is null

insert into	dbo.tflVectorSurveillanceSessionFiltered
(	idfVectorSurveillanceSessionFiltered,
	idfVectorSurveillanceSession,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfVectorSurveillanceSession,
			cf.idfSiteGroup
from		#VSSFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'VSS' + @guid
			and nId.idfKey1 = cf.idfVectorSurveillanceSession
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflVectorSurveillanceSessionFiltered cf_ex
on			cf_ex.idfVectorSurveillanceSessionFiltered = nId.[NewID]
where		cf_ex.idfVectorSurveillanceSessionFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for Vector Surveillance Sessions: ' + cast(@InsertedRecords as varchar(20))
