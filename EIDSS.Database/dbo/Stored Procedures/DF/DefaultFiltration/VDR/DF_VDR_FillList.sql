-- Examples:
/*
	EXEC [dbo].[DF_VDR_FillList]
	EXEC [dbo].[DF_VDR_FillList] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_VDR_FillList] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_VDR_FillList] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000
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

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

declare @i int
declare	@N	int

-- Fill in VDRs meeting date criteria if any
if @StartDate is not null
insert into	#cfrVC
(	[idfVetCase]
)
select		top (@MaxNumberOfProcessedObjects)
			vc.[idfVetCase]
from		dbo.tlbVetCase vc with (nolock)
left join	#cfrVC cfrvc
on			cfrvc.idfVetCase = vc.idfVetCase
where		vc.datModificationForArchiveDate >= @StartDate
			and cfrvc.idfVetCase is null

-- Add chains of connected VDRs and update attributes of the predefined VDRs or those VDRs, which meet date criterion
if @UsePredefinedData = 1 or @StartDate is not null
begin

	set @N = 1
	set @i = 0

	while @N > 0 and @i < 10 /*length of the chain of connected VDRs*/
	begin
		insert into	#cfrVC
		(	[idfVetCase]
		)
		select		distinct top (@MaxNumberOfProcessedObjects)
					vdr_predecessor.idfVetCase
		from		#cfrVC cfrvc
		inner join	dbo.tlbVetCase vc
		on			vc.idfVetCase = cfrvc.idfVetCase
		cross apply
		(	select	top 1	vdrr.[intRowStatus], vdrr.RelatedToVetDiseaseReportID
			from	[dbo].[VetDiseaseReportRelationship] vdrr with (nolock)
			where	vdrr.[VetDiseaseReportID] = cfrvc.idfVetCase
					and vdrr.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
					and vdrr.intRowStatus <= vc.intRowStatus
			order by vdrr.[intRowStatus], vdrr.[VetDiseaseReportRelnUID]
		) vdr_rel_predecessor

		inner join	dbo.tlbVetCase vdr_predecessor with (nolock)
		on			vdr_predecessor.idfVetCase = vdr_rel_predecessor.RelatedToVetDiseaseReportID
					and vdr_rel_predecessor.intRowStatus <= vdr_predecessor.intRowStatus
		left join	#cfrVC cfrvc_ex
		on			cfrvc_ex.idfVetCase = vdr_predecessor.idfVetCase
		where		cfrvc_ex.idfVetCase is null
		set @N = @@ROWCOUNT

		insert into	#cfrVC
		(	[idfVetCase]
		)
		select		distinct top (@MaxNumberOfProcessedObjects)
					vdr_successor.idfVetCase
		from		#cfrVC cfrvc
		inner join	dbo.tlbVetCase vc with (nolock)
		on			vc.idfVetCase = cfrvc.idfVetCase
		inner join	[dbo].[VetDiseaseReportRelationship] vdr_rel_successor with (nolock)
		on			vdr_rel_successor.RelatedToVetDiseaseReportID = cfrvc.idfVetCase
					and vdr_rel_successor.RelationshipTypeID = 10503001 /*Default Relation Type for connected VDRs*/
					and vdr_rel_successor.intRowStatus <= vc.intRowStatus
		inner join	dbo.tlbVetCase vdr_successor with (nolock)
		on			vdr_successor.idfVetCase = vdr_rel_successor.VetDiseaseReportID
					and vdr_rel_successor.intRowStatus <= vdr_successor.intRowStatus
		left join	#cfrVC cfrvc_ex
		on			cfrvc_ex.idfVetCase = vdr_successor.idfVetCase
		where		cfrvc_ex.idfVetCase is null
		set @N = @N + @@ROWCOUNT

		set @i = @i + 1
	end

	update		cfrvc
	set			[idfFarm] = vc.[idfFarm],
				[idfsSite] = vc.[idfsSite],
				[idfOutbreak] = vc.[idfOutbreak],
				[idfParentMonitoringSession] = vc.[idfParentMonitoringSession],
				[idfReportedByOffice] = vc.[idfReportedByOffice],
				[idfReceivedByOffice] = vc.[idfReceivedByOffice],
				[idfInvestigatedByOffice] = vc.[idfInvestigatedByOffice],
				[idfFarmAddress] = f.idfFarmAddress,
				[intRowStatus] = vc.intRowStatus
	from		#cfrVC cfrvc
	join		dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase
	left join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = vc.idfFarm

	update		cfrvc
	set			[idfFarmAddress] = ld.Level3ID
	from		#cfrVC cfrvc
	join		dbo.tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = cfrvc.[idfFarmAddress]
	left join	dbo.gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/
	where		gl.blnForeignAddress = 0
end


-- Create a tree of connected VDRs that shall fall under calculation of filtration records
exec [dbo].[DF_VDR_FillConnectedChain] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate