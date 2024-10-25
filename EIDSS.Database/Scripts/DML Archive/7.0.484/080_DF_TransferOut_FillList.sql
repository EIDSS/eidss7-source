-- Examples:
/*
	EXEC [dbo].[DF_TransferOut_FillList]
	EXEC [dbo].[DF_TransferOut_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_TransferOut_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_TransferOut_FillList] 
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

if Object_ID('tempdb..#cfrTransferOut') is null
create table	#cfrTransferOut
(	[idfTransferOut]				bigint not null primary key,
	[idfsSite]						bigint null,
	[idfSendFromOffice]				bigint null,
	[idfSendToOffice]				bigint null
)

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in Transfer Out Acts meeting date criteria if any
if @StartDate is not null
insert into	#cfrTransferOut
(	[idfTransferOut]
)
select		top (@MaxNumberOfProcessedObjects)
			tOut.idfTransferOut
from		dbo.tlbTransferOUT tOut with (nolock)
left join	#cfrTransferOut cfrtOut
on			cfrtOut.idfTransferOut = tOut.idfTransferOut
where		tOut.datModificationForArchiveDate >= @StartDate
			and cfrtOut.idfTransferOut is null

if @UsePredefinedData = 1 or @StartDate is not null
begin
	-- Fill in Transfer Out Acts including samples of predefined HDRs or those HDRs, which meet date criterion if any
	if @CalculateHumanData = 1
	insert into	#cfrTransferOut
	(	[idfTransferOut]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				tOut.idfTransferOut
	from		dbo.tlbTransferOUT tOut with (nolock)
	inner join	dbo.tlbTransferOutMaterial tOutM with (nolock)
	on			tOutM.idfTransferOut = tOut.idfTransferOut
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = tOutM.idfMaterial
	inner join	#cfrHC hc
	on			hc.idfHumanCase = m.idfHumanCase
	left join	#cfrTransferOut cfrtOut
	on			cfrtOut.idfTransferOut = tOut.idfTransferOut
	where		cfrtOut.idfTransferOut is null

	-- Fill in Transfer Out Acts including samples of predefined VDRs or those VDRs, which meet date criterion if any
	if @CalculateVetData = 1
	insert into	#cfrTransferOut
	(	[idfTransferOut]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				tOut.idfTransferOut
	from		dbo.tlbTransferOUT tOut with (nolock)
	inner join	dbo.tlbTransferOutMaterial tOutM with (nolock)
	on			tOutM.idfTransferOut = tOut.idfTransferOut
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = tOutM.idfMaterial
	inner join	#cfrVC vc
	on			vc.idfVetCase = m.idfVetCase
	left join	#cfrTransferOut cfrtOut
	on			cfrtOut.idfTransferOut = tOut.idfTransferOut
	where		cfrtOut.idfTransferOut is null

	-- Fill in Transfer Out Acts including samples of predefined Active Surveillance Sessions or those Active Surveillance Sessions, which meet date criterion if any
	if @CalculateHumanData = 1 or @CalculateVetData = 1
	insert into	#cfrTransferOut
	(	[idfTransferOut]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				tOut.idfTransferOut
	from		dbo.tlbTransferOUT tOut with (nolock)
	inner join	dbo.tlbTransferOutMaterial tOutM with (nolock)
	on			tOutM.idfTransferOut = tOut.idfTransferOut
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = tOutM.idfMaterial
	inner join	#cfrMS ms
	on			ms.idfMonitoringSession = m.idfMonitoringSession
	left join	#cfrTransferOut cfrtOut
	on			cfrtOut.idfTransferOut = tOut.idfTransferOut
	where		cfrtOut.idfTransferOut is null

	-- Fill in Transfer Out Acts including samples of predefined Vector Surveillance Sessions or those Vector Surveillance Sessions, which meet date criterion if any
	if @CalculateVSSData = 1
	insert into	#cfrTransferOut
	(	[idfTransferOut]
	)
	select		distinct top (@MaxNumberOfProcessedObjects)
				tOut.idfTransferOut
	from		dbo.tlbTransferOUT tOut with (nolock)
	inner join	dbo.tlbTransferOutMaterial tOutM with (nolock)
	on			tOutM.idfTransferOut = tOut.idfTransferOut
	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = tOutM.idfMaterial
	inner join	#cfrVSS vss
	on			vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession
	left join	#cfrTransferOut cfrtOut
	on			cfrtOut.idfTransferOut = tOut.idfTransferOut
	where		cfrtOut.idfTransferOut is null

	-- Update attributes of the predefined Transfer Out Acts or those Transfer Out Acts, which meet date criterion
	update		cfrtOut
	set			[idfsSite] = tOut.[idfsSite],
				[idfSendFromOffice] = tOut.[idfSendFromOffice],
				[idfSendToOffice] = tOut.[idfSendToOffice]
	from		#cfrTransferOut cfrtOut
	join		dbo.tlbTransferOUT tOut with (nolock)
	on			tOut.idfTransferOut = cfrtOut.idfTransferOut
end

