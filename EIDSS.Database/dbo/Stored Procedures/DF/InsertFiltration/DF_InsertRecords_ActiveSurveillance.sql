-- Examples:
/*
	declare @MaxNumberOfNewFiltrationRecords int = 1000, @InsertedRecords int
	EXEC [dbo].[DF_InsertRecords_ActiveSurveillance] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@InsertedRecords=@InsertedRecords output
	select @InsertedRecords
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_ActiveSurveillance] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@InsertedRecords					int output
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if Object_ID('tempdb..#MSFiltered') is null
create table	#MSFiltered
(	[idfID]							bigint not null identity(1,1),
	[idfMonitoringSession]			bigint not null,
	[idfSiteGroup]					bigint not null,
	[idfMonitoringSessionFiltered]	bigint null,
	primary key	(
		[idfMonitoringSession] asc,
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
		N'MS' + @guid,
		cf.idfMonitoringSession,
		cf.idfSiteGroup
from	#MSFiltered cf
where	cf.idfMonitoringSessionFiltered is null

insert into	dbo.tflMonitoringSessionFiltered
(	idfMonitoringSessionFiltered,
	idfMonitoringSession,
	idfSiteGroup
)
select		nId.[NewID],
			cf.idfMonitoringSession,
			cf.idfSiteGroup
from		#MSFiltered cf
join		dbo.tflNewID nId
on			nId.strTableName = N'MS' + @guid
			and nId.idfKey1 = cf.idfMonitoringSession
			and nId.idfKey2 = cf.idfSiteGroup
left join	dbo.tflMonitoringSessionFiltered cf_ex
on			cf_ex.idfMonitoringSessionFiltered = nId.[NewID]
where		cf_ex.idfMonitoringSessionFiltered is null
set @InsertedRecords = @@ROWCOUNT
print	'Newly calculated filtration records inserted for Active Surveillance Sessions: ' + cast(@InsertedRecords as varchar(20))
