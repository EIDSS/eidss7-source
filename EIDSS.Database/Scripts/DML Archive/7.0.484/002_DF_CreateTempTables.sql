-- Examples:
/*
	EXEC [dbo].[DF_CreateTempTables]
	EXEC [dbo].[DF_CreateTempTables] @UsePredefinedData=0
	EXEC [dbo].[DF_CreateTempTables] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_CreateTempTables] 
(
	@UsePredefinedData		bit = 0
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
if @UsePredefinedData = 0
truncate table #cfrHC


if Object_ID('tempdb..#cfrHCDeduplicationChain') is null
create table	#cfrHCDeduplicationChain
(	[idfRootSurvivorHC]				bigint not null,
	[intLevel]						bigint not null,
	[idfLevelSurvivorHC]			bigint null,
	[idfLevelSupersededHC]			bigint not null,
	[idfLevelSupersededParentMS]	bigint null,
	[idfLevelSupersededOutbreak]	bigint null,
	primary key
	(	[idfRootSurvivorHC] asc,
		[idfLevelSupersededHC] asc
	)
)
truncate table #cfrHCDeduplicationChain


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
truncate table #HCFiltered



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
if @UsePredefinedData = 0
truncate table #cfrVC


if Object_ID('tempdb..#cfrVCConnectedChain') is null
create table	#cfrVCConnectedChain
(	[idfRootPredecessorVC]			bigint not null,
	[intLevel]						bigint not null,
	[idfLevelPredecessorVC]			bigint null,
	[idfLevelSuccessorVC]			bigint not null,
	[idfLevelSuccessorParentMS]		bigint null,
	[idfLevelSuccessorOutbreak]		bigint null,
	primary key
	(	[idfRootPredecessorVC] asc,
		[idfLevelSuccessorVC] asc
	)
)
truncate table #cfrVCConnectedChain


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
truncate table #VCFiltered



if Object_ID('tempdb..#cfrMS') is null
create table	#cfrMS
(	[idfMonitoringSession]			bigint not null primary key,
	[idfsSite]						bigint null,
	[idfsMSRayon]					bigint null
)
if @UsePredefinedData = 0
truncate table #cfrMS

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
truncate table #MSFiltered



if Object_ID('tempdb..#cfrVSS') is null
create table	#cfrVSS
(	[idfVectorSurveillanceSession]	bigint not null primary key,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfLocation]					bigint null,
	[idfsVSSRayon]					bigint null
)
if @UsePredefinedData = 0
truncate table #cfrVSS

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
truncate table #VSSFiltered



if Object_ID('tempdb..#cfrOutbreak') is null
create table	#cfrOutbreak
(	[idfOutbreak]					bigint not null primary key,
	[idfsSite]						bigint null,
	[idfPrimaryCaseOrSession]		bigint null,
	[idfLocation]					bigint null,
	[idfsOutbreakRayon]				bigint null
)
if @UsePredefinedData = 0
truncate table #cfrOutbreak

if Object_ID('tempdb..#OutbreakFiltered') is null
create table	#OutbreakFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfOutbreak]				bigint not null,
	[idfPrimaryCaseOrSession]	bigint null,
	[idfSiteGroup]				bigint not null,
	[idfOutbreakFiltered]		bigint null,
	primary key	(
		[idfOutbreak] asc,
		[idfSiteGroup] asc
				)
)
truncate table #OutbreakFiltered



if Object_ID('tempdb..#cfrAggrCase') is null
create table	#cfrAggrCase
(	[idfAggrCase]					bigint not null primary key,
	[idfsSite]						bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfSentByOffice]				bigint null,
	[idfEnteredByOffice]			bigint null,
	[idfsAggrCaseRayon]				bigint null
)
if @UsePredefinedData = 0
truncate table #cfrAggrCase

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
truncate table #AggrCaseFiltered



if Object_ID('tempdb..#cfrTransferOut') is null
create table	#cfrTransferOut
(	[idfTransferOut]				bigint not null primary key,
	[idfsSite]						bigint null,
	[idfSendFromOffice]				bigint null,
	[idfSendToOffice]				bigint null
)
if @UsePredefinedData = 0
truncate table #cfrTransferOut

if Object_ID('tempdb..#TransferOutFiltered') is null
create table	#TransferOutFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfTransferOut]			bigint not null,
	[idfSiteGroup]				bigint not null,
	[idfTransferOutFiltered]	bigint null,
	primary key	(
		[idfTransferOut] asc,
		[idfSiteGroup] asc
				)
)
truncate table #TransferOutFiltered



if Object_ID('tempdb..#cfrBatchTest') is null
create table	#cfrBatchTest
(	[idfBatchTest]					bigint not null primary key,
	[idfsSite]						bigint null
)
if @UsePredefinedData = 0
truncate table #cfrBatchTest

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
truncate table #BatchTestFiltered


if Object_ID('tempdb..#cfrBSS') is null
create table	#cfrBSS
(	[idfBasicSyndromicSurveillance]	bigint not null primary key,
	[idfHuman]						bigint null,
	[idfsSite]						bigint null,
	[idfHospital]					bigint null,
	[idfCRAddress]					bigint null,
	[idfsCRARayon]					bigint null
)
if @UsePredefinedData = 0
truncate table #cfrBSS

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
truncate table #BSSFiltered



if Object_ID('tempdb..#cfrBSSAggr') is null
create table	#cfrBSSAggr
(	[idfAggregateHeader]			bigint not null primary key,
	[idfsSite]						bigint null
)
if @UsePredefinedData = 0
truncate table #cfrBSSAggr

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
truncate table #BSSAggrFiltered



if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)
if @UsePredefinedData = 0
truncate table #SitesToCalculateFiltrationRecords

