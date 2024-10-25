-- Examples:
/*
	EXEC [dbo].[DF_BSSAggregate_Rule_idfHospital]
	EXEC [dbo].[DF_BSSAggregate_Rule_idfHospital] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BSSAggregate_Rule_idfHospital] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BSSAggregate_Rule_idfHospital] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrBSSAggr') is null
create table	#cfrBSSAggr
(	[idfAggregateHeader]			bigint not null primary key,
	[idfsSite]						bigint null
)

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

if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)


if @UsePredefinedData = 1 or @StartDate is not null
begin
	insert into	#BSSAggrFiltered
	(	idfAggregateHeader,
		idfSiteGroup
	)
	select distinct
				bssaggr.idfAggregateHeader,
				s.idfSiteGroup
	from		#cfrBSSAggr bssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateDetail bssaggr_row with (nolock)
	on			bssaggr_row.idfAggregateHeader = bssaggr.idfAggregateHeader
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = bssaggr_row.idfHospital
	left join	#BSSAggrFiltered bssaggrf_ex
	on			bssaggrf_ex.idfAggregateHeader = bssaggr.idfAggregateHeader
				and bssaggrf_ex.idfSiteGroup = s.idfSiteGroup
	where		bssaggrf_ex.idfID is null
end
else begin
	insert into	#BSSAggrFiltered
	(	idfAggregateHeader,
		idfSiteGroup
	)
	select distinct
				bssaggr.idfAggregateHeader,
				s.idfSiteGroup
	from		dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateDetail bssaggr_row with (nolock)
	on			bssaggr_row.idfAggregateHeader = bssaggr.idfAggregateHeader
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = bssaggr_row.idfHospital
	left join	#BSSAggrFiltered bssaggrf_ex
	on			bssaggrf_ex.idfAggregateHeader = bssaggr.idfAggregateHeader
				and bssaggrf_ex.idfSiteGroup = s.idfSiteGroup
	where		bssaggrf_ex.idfID is null
end
