-- Examples:
/*
	EXEC [dbo].[DF_VSS_FillList]
	EXEC [dbo].[DF_VSS_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_VSS_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_VSS_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000
)
AS

if Object_ID('tempdb..#cfrVSS') is null
create table	#cfrVSS
(	[idfVectorSurveillanceSession]	bigint not null primary key,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfLocation]					bigint null,
	[idfsVSSRayon]					bigint null
)

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in Vector Surveillance Sessions meeting date criteria if any
if @StartDate is not null
insert into	#cfrVSS
(	[idfVectorSurveillanceSession]
)
select		top (@MaxNumberOfProcessedObjects)
			vss.idfVectorSurveillanceSession
from		dbo.tlbVectorSurveillanceSession vss with (nolock)
left join	#cfrVSS cfrvss
on			cfrvss.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
where		vss.datModificationForArchiveDate >= @StartDate
			and cfrvss.idfVectorSurveillanceSession is null

-- Update attributes of the predefined Vector Surveillance Sessions or those Vector Surveillance Sessions, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	update		cfrvss
	set			[idfsSite] = vss.[idfsSite],
				[idfOutbreak] = vss.[idfOutbreak],
				[idfLocation] = gl.idfGeoLocation,
				[idfsVSSRayon] = ld.Level3ID
	from		#cfrVSS cfrvss
	join		dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession
	left join	dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = vss.idfLocation
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
end

