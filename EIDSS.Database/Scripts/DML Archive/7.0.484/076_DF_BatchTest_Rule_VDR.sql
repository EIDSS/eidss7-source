-- Examples:
/*
	EXEC [dbo].[DF_BatchTest_Rule_VDR]
	EXEC [dbo].[DF_BatchTest_Rule_VDR] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BatchTest_Rule_VDR] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BatchTest_Rule_VDR] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

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
	-- In case of predefined lists of VDRs and Batch Tests or specified date criterion, add newly calculated records for those VDRs, which include laboratory tests linked to the Batch Tests
	insert into	#BatchTestFiltered
	(	idfBatchTest,
		idfSiteGroup
	)
	select distinct
				bt.idfBatchTest,
				vcf.idfSiteGroup
	from		#cfrBatchTest bt
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	#VCFiltered vcf
	on			vcf.idfVetCase = m.idfVetCase
	left join	#BatchTestFiltered btf_ex
	on			btf_ex.idfBatchTest = bt.idfBatchTest
				and btf_ex.idfSiteGroup = vcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = vcf.idfSiteGroup
				)
				and btf_ex.idfID is null

	-- In case of predefined lists of VDRs and Batch Tests or specified date criterion, add existing records of those VDRs, which include laboratory tests linked to the Batch Tests
	insert into	#BatchTestFiltered
	(	idfBatchTest,
		idfSiteGroup
	)
	select distinct
				bt.idfBatchTest,
				vcf.idfSiteGroup
	from		#cfrBatchTest bt
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	dbo.tflVetCaseFiltered vcf with (nolock)
	on			vcf.idfVetCase = m.idfVetCase
	left join	#BatchTestFiltered btf_ex
	on			btf_ex.idfBatchTest = bt.idfBatchTest
				and btf_ex.idfSiteGroup = vcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = vcf.idfSiteGroup
				)
				and btf_ex.idfID is null
end
else begin
	-- Add newly calculated records for those VDRs, which include laboratory tests linked to the Batch Tests
	insert into	#BatchTestFiltered
	(	idfBatchTest,
		idfSiteGroup
	)
	select distinct
				bt.idfBatchTest,
				vcf.idfSiteGroup
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	#VCFiltered vcf
	on			vcf.idfVetCase = m.idfVetCase
	left join	#BatchTestFiltered btf_ex
	on			btf_ex.idfBatchTest = bt.idfBatchTest
				and btf_ex.idfSiteGroup = vcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = vcf.idfSiteGroup
				)
				and btf_ex.idfID is null


	-- Add existing records of those VDRs, which include laboratory tests linked to the Batch Tests
	insert into	#BatchTestFiltered
	(	idfBatchTest,
		idfSiteGroup
	)
	select distinct
				bt.idfBatchTest,
				vcf.idfSiteGroup
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	dbo.tflVetCaseFiltered vcf with (nolock)
	on			vcf.idfVetCase = m.idfVetCase
	left join	#BatchTestFiltered btf_ex
	on			btf_ex.idfBatchTest = bt.idfBatchTest
				and btf_ex.idfSiteGroup = vcf.idfSiteGroup
	where		exists
				(	select	1
					from	#SitesToCalculateFiltrationRecords s
					where	s.idfSiteGroup = vcf.idfSiteGroup
				)
				and btf_ex.idfID is null
end
