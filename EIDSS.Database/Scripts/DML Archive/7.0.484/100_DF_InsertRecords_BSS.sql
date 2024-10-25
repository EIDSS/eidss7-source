-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_BSS] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_InsertRecords_BSS] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#BSSFiltered') is null
create table	#BSSFiltered
(	[idfID]									bigint not null identity(1,1),
	[idfBasicSyndromicSurveillance]			bigint not null,
	[idfSiteGroup]							bigint not null,
	[idfBasicSyndromicSurveillanceFiltered]	bigint null,
	primary key	(
		[idfBasicSyndromicSurveillance] asc,
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
		N'BSS' + @guid,
		cf.idfBasicSyndromicSurveillance,
		cf.idfSiteGroup
from	#BSSFiltered cf
where	cf.idfBasicSyndromicSurveillanceFiltered is null

insert into	dbo.tflBasicSyndromicSurveillanceFiltered
(	idfBasicSyndromicSurveillanceFiltered,
	idfBasicSyndromicSurveillance,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfBasicSyndromicSurveillance,
			cf.idfSiteGroup
from		#BSSFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'BSS' + @guid
			and nId.idfKey1 = cf.idfBasicSyndromicSurveillance
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflBasicSyndromicSurveillanceFiltered cf_ex
on			cf_ex.idfBasicSyndromicSurveillanceFiltered = nId.[NewID]
where		cf_ex.idfBasicSyndromicSurveillanceFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for Basic Syndromic Surveillance Sessions: ' + cast(@InsertedRecords as varchar(20))
