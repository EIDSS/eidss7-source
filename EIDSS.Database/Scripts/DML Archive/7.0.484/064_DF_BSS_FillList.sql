-- Examples:
/*
	EXEC [dbo].[DF_BSS_FillList]
	EXEC [dbo].[DF_BSS_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_BSS_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_BSS_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000
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

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in BSS Report meeting date criteria if any
if @StartDate is not null
insert into	#cfrBSS
(	[idfBasicSyndromicSurveillance]
)
select		top (@MaxNumberOfProcessedObjects)
			bss.idfBasicSyndromicSurveillance
from		dbo.tlbBasicSyndromicSurveillance bss with (nolock)
left join	#cfrBSS cfrbss
on			cfrbss.idfBasicSyndromicSurveillance = bss.idfBasicSyndromicSurveillance
where		bss.datModificationForArchiveDate >= @StartDate
			and cfrbss.idfBasicSyndromicSurveillance is null

-- Update attributes of the predefined BSS Reports or those BSS Reports, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	update		cfrbss
	set			[idfsSite] = bss.[idfsSite],
				[idfHuman] = bss.[idfHuman],
				[idfHospital] = bss.[idfHospital],
				[idfCRAddress] = h.idfCurrentResidenceAddress,
				[idfsCRARayon] = ld.Level3ID
	from		#cfrBSS cfrbss
	inner join	dbo.tlbBasicSyndromicSurveillance bss with (nolock)
	on			bss.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance
	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = bss.idfHuman
	left join	dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = h.idfCurrentResidenceAddress
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
end

