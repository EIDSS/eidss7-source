-- Examples:
/*
	EXEC [dbo].[DF_BSS_Rule_CRAddress]
	EXEC [dbo].[DF_BSS_Rule_CRAddress] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BSS_Rule_CRAddress] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_BSS_Rule_CRAddress] 
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
	on			s.idfsRayon = bss.idfsCRARayon
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
	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = bss.idfHuman
	inner join	dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	inner join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsRayon = ld.Level3ID
	left join	#BSSFiltered bssf_ex
	on			bssf_ex.idfBasicSyndromicSurveillance = bss.idfBasicSyndromicSurveillance
				and bssf_ex.idfSiteGroup = s.idfSiteGroup
	where		bssf_ex.idfID is null
end
