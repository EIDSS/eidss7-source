-- Examples:
/*
	EXEC [dbo].[DF_BSS_Rule_idfsSite]
	EXEC [dbo].[DF_BSS_Rule_idfsSite] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BSS_Rule_idfsSite] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BSS_Rule_idfsSite] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrBSS') is null
create table	#cfrBSS
(	[idfBasicSyndromicSurveillance]	bigint not null primary key,
	[idfHuman]						bigint null,
	[idfsSite]						bigint null,
	[idfHospital]					bigint null,
	[idfCRAddress]					bigint null,
	[idfsCRARayon]					bigint null
)

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
	insert into	#BSSFiltered
	(	idfBasicSyndromicSurveillance,
		idfSiteGroup
	)
	select distinct
				bss.idfBasicSyndromicSurveillance,
				s.idfSiteGroup
	from		#cfrBSS bss
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsSite = bss.idfsSite
	left join	#BSSFiltered bssf_ex
	on			bssf_ex.idfBasicSyndromicSurveillance = bss.idfBasicSyndromicSurveillance
				and bssf_ex.idfSiteGroup = s.idfSiteGroup
	where		bssf_ex.idfID is null
end
else begin
	insert into	#BSSFiltered
	(	idfBasicSyndromicSurveillance,
		idfSiteGroup
	)
	select distinct
				bss.idfBasicSyndromicSurveillance,
				s.idfSiteGroup
	from		dbo.tlbBasicSyndromicSurveillance bss with (nolock)
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsSite = bss.idfsSite
	left join	#BSSFiltered bssf_ex
	on			bssf_ex.idfBasicSyndromicSurveillance = bss.idfBasicSyndromicSurveillance
				and bssf_ex.idfSiteGroup = s.idfSiteGroup
	where		bssf_ex.idfID is null
end
