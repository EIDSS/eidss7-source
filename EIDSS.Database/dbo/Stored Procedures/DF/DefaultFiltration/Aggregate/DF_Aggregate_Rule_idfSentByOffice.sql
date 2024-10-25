-- Examples:
/*
	EXEC [dbo].[DF_Aggregate_Rule_idfSentByOffice]
	EXEC [dbo].[DF_Aggregate_Rule_idfSentByOffice] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_Aggregate_Rule_idfSentByOffice] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_Aggregate_Rule_idfSentByOffice] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
)
AS

if Object_ID('tempdb..#cfrAggrCase') is null
create table	#cfrAggrCase
(	[idfAggrCase]					bigint not null primary key,
	[idfsSite]						bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfSentByOffice]				bigint null,
	[idfEnteredByOffice]			bigint null,
	[idfsAggrCaseRayon]				bigint null
)

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
	insert into	#AggrCaseFiltered
	(	idfAggrCase,
		idfSiteGroup
	)
	select distinct
				aggr.idfAggrCase,
				s.idfSiteGroup
	from		#cfrAggrCase aggr
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = aggr.idfSentByOffice
	left join	#AggrCaseFiltered aggrf_ex
	on			aggrf_ex.idfAggrCase = aggr.idfAggrCase
				and aggrf_ex.idfSiteGroup = s.idfSiteGroup
	where		aggrf_ex.idfID is null
end
else begin
	insert into	#AggrCaseFiltered
	(	idfAggrCase,
		idfSiteGroup
	)
	select distinct
				aggr.idfAggrCase,
				s.idfSiteGroup
	from		dbo.tlbAggrCase aggr with (nolock)
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = aggr.idfSentByOffice
	left join	#AggrCaseFiltered aggrf_ex
	on			aggrf_ex.idfAggrCase = aggr.idfAggrCase
				and aggrf_ex.idfSiteGroup = s.idfSiteGroup
	where		(	aggr.idfsAggrCaseType = @CalculateHumanData * 10102001 /*Human Aggregate Case*/
					or aggr.idfsAggrCaseType = @CalculateVetData * 10502002 /*Vet Aggregate Case*/
					or aggr.idfsAggrCaseType = @CalculateVetData * 10502003 /*Vet Aggregate Action*/
				)
				and aggrf_ex.idfID is null
end
