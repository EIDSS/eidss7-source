-- Examples:
/*
	EXEC [dbo].[DF_BatchTest_FillList]
	EXEC [dbo].[DF_BatchTest_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BatchTest_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BatchTest_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1,
	@CalculateVSSData					bit = 1
)
AS

if Object_ID('tempdb..#cfrHC') is null
create table	#cfrHC
(	[idfHumanCase]					bigint not null primary key,
	[idfHuman]						bigint null,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfParentMonitoringSession]	bigint null,
	[idfDeduplicationResultCase]	bigint null,
	[idfSentByOffice]				bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfInvestigatedByOffice]		bigint null,
	[idfSoughtCareFacility]			bigint null,
	[idfHospital]					bigint null,
	[idfExposureLocation]			bigint null,
	[idfCRAddress]					bigint null,
	[idfsExposureLocRayon]			bigint null,
	[idfsCRARayon]					bigint null
)

if Object_ID('tempdb..#cfrVC') is null
create table	#cfrVC
(	[idfVetCase]					bigint not null primary key,
	[idfFarm]						bigint null,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfParentMonitoringSession]	bigint null,
	[idfReportedByOffice]			bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfInvestigatedByOffice]		bigint null,
	[idfFarmAddress]				bigint null,
	[idfsFarmAddressRayon]			bigint null,
	[intRowStatus]					int null
)

if Object_ID('tempdb..#cfrMS') is null
create table	#cfrMS
(	[idfMonitoringSession]			bigint not null primary key,
	[idfsSite]						bigint null,
	[idfsMSRayon]					bigint null
)

if Object_ID('tempdb..#cfrVSS') is null
create table	#cfrVSS
(	[idfVectorSurveillanceSession]	bigint not null primary key,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfLocation]					bigint null,
	[idfsVSSRayon]					bigint null
)

if Object_ID('tempdb..#cfrBatchTest') is null
create table	#cfrBatchTest
(	[idfBatchTest]					bigint not null primary key,
	[idfsSite]						bigint null
)

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in Batch Tests meeting date criteria if any
if @StartDate is not null
insert into	#cfrBatchTest
(	[idfBatchTest]
)
select		top (@MaxNumberOfProcessedObjects)
			bt.idfBatchTest
from		dbo.tlbBatchTest bt with (nolock)
left join	#cfrBatchTest cfrbt
on			cfrbt.idfBatchTest = bt.idfBatchTest
where		bt.datModificationForArchiveDate >= @StartDate
			and cfrbt.idfBatchTest is null

if @UsePredefinedData = 1 or @StartDate is not null
begin
	-- Fill in Batch Tests connected to the tests of predefined HDRs or those HDRs, which meet date criterion if any
	if @CalculateHumanData = 1
	insert into	#cfrBatchTest
	(	[idfBatchTest]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				bt.idfBatchTest
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	#cfrHC hc
	on			hc.idfHumanCase = m.idfHumanCase
	left join	#cfrBatchTest cfrbt
	on			cfrbt.idfBatchTest = bt.idfBatchTest
	where		cfrbt.idfBatchTest is null

	-- Fill in Batch Tests connected to the tests of predefined VDRs or those VDRs, which meet date criterion if any
	if @CalculateVetData = 1
	insert into	#cfrBatchTest
	(	[idfBatchTest]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				bt.idfBatchTest
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	#cfrVC vc
	on			vc.idfVetCase = m.idfVetCase
	left join	#cfrBatchTest cfrbt
	on			cfrbt.idfBatchTest = bt.idfBatchTest
	where		cfrbt.idfBatchTest is null

	-- Fill in Batch Tests connected to the tests of predefined Active Surveillance Sessions or those Active Surveillance Sessions, which meet date criterion if any
	if @CalculateHumanData = 1 or @CalculateVetData = 1
	insert into	#cfrBatchTest
	(	[idfBatchTest]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				bt.idfBatchTest
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	#cfrMS ms
	on			ms.idfMonitoringSession = m.idfMonitoringSession
	left join	#cfrBatchTest cfrbt
	on			cfrbt.idfBatchTest = bt.idfBatchTest
	where		cfrbt.idfBatchTest is null

	-- Fill in Batch Tests connected to the tests of predefined Vector Surveillance Sessions or those Vector Surveillance Sessions, which meet date criterion if any
	if @CalculateVSSData = 1
	insert into	#cfrBatchTest
	(	[idfBatchTest]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				bt.idfBatchTest
	from		dbo.tlbBatchTest bt with (nolock)
	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial
	inner join	#cfrVSS vss
	on			vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
	left join	#cfrBatchTest cfrbt
	on			cfrbt.idfBatchTest = bt.idfBatchTest
	where		cfrbt.idfBatchTest is null

	-- Update attributes of the predefined Batch Tests or those Batch Tests, which meet date criterion
	update		cfrbt
	set			[idfsSite] = bt.[idfsSite]
	from		#cfrBatchTest cfrbt
	join		dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest
end

