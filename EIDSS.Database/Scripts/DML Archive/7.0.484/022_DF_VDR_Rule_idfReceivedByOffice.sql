-- Examples:
/*
	EXEC [dbo].[DF_VDR_Rule_idfReceivedByOffice]
	EXEC [dbo].[DF_VDR_Rule_idfReceivedByOffice] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_VDR_Rule_idfReceivedByOffice] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_VDR_Rule_idfReceivedByOffice] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

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
	insert into	#VCFiltered
	(	idfVetCase,
		idfMonitoringSession,
		idfOutbreak,
		idfSiteGroup
	)
	select distinct
				vc.idfVetCase,
				vc.idfParentMonitoringSession,
				vc.idfOutbreak,
				s.idfSiteGroup
	from		#cfrVC vc
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = vc.idfReceivedByOffice
	left join	#VCFiltered vcf_ex
	on			vcf_ex.idfVetCase = vc.idfVetCase
				and vcf_ex.idfSiteGroup = s.idfSiteGroup
	where		vcf_ex.idfID is null
end
else begin
	insert into	#VCFiltered
	(	idfVetCase,
		idfMonitoringSession,
		idfOutbreak,
		idfSiteGroup
	)
	select distinct
				vc.idfVetCase,
				vc.idfParentMonitoringSession,
				vc.idfOutbreak,
				s.idfSiteGroup
	from		dbo.tlbVetCase vc with (nolock)
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = vc.idfReceivedByOffice
	left join	#VCFiltered vcf_ex
	on			vcf_ex.idfVetCase = vc.idfVetCase
				and vcf_ex.idfSiteGroup = s.idfSiteGroup
	where		vcf_ex.idfID is null
end
