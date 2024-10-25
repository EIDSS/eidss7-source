-- Examples:
/*
	EXEC [dbo].[DF_ActiveSurveillance_FillList]
	EXEC [dbo].[DF_ActiveSurveillance_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_ActiveSurveillance_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_ActiveSurveillance_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
)
AS

if Object_ID('tempdb..#cfrMS') is null
create table	#cfrMS
(	[idfMonitoringSession]			bigint not null primary key,
	[idfsSite]						bigint null,
	[idfsMSRayon]					bigint null

)

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

-- Fill in Human/Veterinary Active Surveillance Sessions meeting date criteria if any
if @StartDate is not null
insert into	#cfrMS
(	[idfMonitoringSession]
)
select		top (@MaxNumberOfProcessedObjects)
			ms.idfMonitoringSession
from		dbo.tlbMonitoringSession ms with (nolock)
left join	#cfrMS cfrms
on			cfrms.idfMonitoringSession = ms.idfMonitoringSession
where		ms.datModificationForArchiveDate >= @StartDate
			and (	ms.SessionCategoryID = @CalculateHumanData * 10502009 /*Veterinary Active Surveillance Session*/
					or ms.SessionCategoryID = @CalculateVetData * 10502001 /*Human Active Surveillance Session*/
					or (@CalculateVetData = 1 or ms.SessionCategoryID is null)
				)
			and cfrms.idfMonitoringSession is null

-- Update attributes of the predefined Active Surveillance Sessions or those Active Surveillance Sessions, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin
	update		cfrms
	set			[idfsSite] = ms.[idfsSite],
				[idfsMSRayon] = ld.Level3ID
	from		#cfrMS cfrms
	join		dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = cfrms.idfMonitoringSession
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = ms.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
end

