-- Examples:
/*
	EXEC [dbo].[DF_BatchTest_Rule_idfsSite]
	EXEC [dbo].[DF_BatchTest_Rule_idfsSite] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BatchTest_Rule_idfsSite] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BatchTest_Rule_idfsSite] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
)
AS

if Object_ID('tempdb..#cfrBatchTest') is null
create table	#cfrBatchTest
(	[idfBatchTest]					bigint not null primary key,
	[idfsSite]						bigint null
)

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
	insert into	#BatchTestFiltered
	(	idfBatchTest,
		idfSiteGroup
	)
	select distinct
				bt.idfBatchTest,
				s.idfSiteGroup
	from		#cfrBatchTest bt
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsSite = bt.idfsSite
	left join	#BatchTestFiltered btf_ex
	on			btf_ex.idfBatchTest = bt.idfBatchTest
				and btf_ex.idfSiteGroup = s.idfSiteGroup
	where		btf_ex.idfID is null
end
else begin
	insert into	#BatchTestFiltered
	(	idfBatchTest,
		idfSiteGroup
	)
	select distinct
				bt.idfBatchTest,
				s.idfSiteGroup
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsSite = bt.idfsSite
	left join	#BatchTestFiltered btf_ex
	on			btf_ex.idfBatchTest = bt.idfBatchTest
				and btf_ex.idfSiteGroup = s.idfSiteGroup
	where		btf_ex.idfID is null
end
