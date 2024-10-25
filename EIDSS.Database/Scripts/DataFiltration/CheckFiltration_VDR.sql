-- Check filtration records calculated for VDR

-- Input parameter - VDR Report ID:
declare @strReportID nvarchar(200)
set @strReportID = 'VETTBTBZ240012'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	VDR's attributes
--		-	Report ID
--		-	Date Entered
--		-	Farm ID
--		-	Date Last Updated of VDR or its Related Lab objects
--		-	Is deleted
--		-	Entered by Site
--		-	Reported by Organization
--		-	Investigation Organization
--	2.	Addresses/Locations
--		-	Admin Unit of Farm Address
--		-	Admin Unit of Address of the site entered VDR
--	3.	Samples'attributes
--		-	Herd/Species/Animal
--		-	Sample Type
--		-	Local Sample ID
--		-	Is deleted
--		-	Collected by Institution
--		-	Sent to Organization
--		-	Transfered From (if applicable)
--		-	Transfered To (if applicable)
--	4.	Connected Chain for VDR if applicable
--	5.	List of the third-level sites, where VDR is available


set nocount on

declare	@idfVetCase bigint
set	@idfVetCase = 
	(	select	top 1	idfVetCase
		from	dbo.tlbVetCase with (nolock)
		where	strCaseID = @strReportID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfVetCase
	)

if Object_ID('tempdb..#cfrVC') is not null
begin
	execute sp_executesql N'drop table #cfrVC'
end

if Object_ID('tempdb..#cfrVCConnectedChain') is not null
begin
	execute sp_executesql N'drop table #cfrVCConnectedChain'
end

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

if @idfVetCase is not null
begin
	insert into #cfrVC(idfVetCase)
	values(@idfVetCase)

	EXEC [dbo].[DF_VDR_FillList] @UsePredefinedData=1
	
	delete from #cfrVC
	where	idfVetCase <> @idfVetCase

	/*1.	VDR's attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		vc.idfVetCase 'VDR System Identifier',
				f.idfFarm as 'Farm (Copy) System Identifier',
				f.idfFarmActual as 'Farm (Original) System Identifier',
				vc.strCaseID as 'Report ID',
				isnull(CONVERT(nvarchar, vc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
				isnull(CONVERT(nvarchar, vc.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				case when vc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(org_reported.[name] + ISNULL(N'; Site ' + s_reported.strSiteID + N' (' + s_reported.strSiteType + N')', N''), N'') as 'Reported by Organization',
				ISNULL(org_inv.[name] + ISNULL(N'; Site ' + s_inv.strSiteID + N' (' + s_inv.strSiteType + N')', N''), N'') as 'Investigation Organization'
	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = cfrvc.idfFarm
	left join	dbo.tlbFarmActual fa with (nolock)
	on			fa.idfFarmActual = f.idfFarmActual


	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrvc.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_reported
	on			org_reported.idfOffice = cfrvc.idfReportedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrvc.idfReportedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_reported			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_receivedby
	on			org_receivedby.idfOffice = cfrvc.idfReceivedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrvc.idfReceivedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_receivedby			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_inv
	on			org_inv.idfOffice = cfrvc.idfInvestigatedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrvc.idfInvestigatedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_inv

	else

	select		vc.strCaseID as 'Report ID',
				isnull(CONVERT(nvarchar, vc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
				isnull(CONVERT(nvarchar, vc.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				case when vc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(org_reported.[name] + ISNULL(N'; Site ' + s_reported.strSiteID + N' (' + s_reported.strSiteType + N')', N''), N'') as 'Reported by Organization',
				ISNULL(org_inv.[name] + ISNULL(N'; Site ' + s_inv.strSiteID + N' (' + s_inv.strSiteType + N')', N''), N'') as 'Investigation Organization'
	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = cfrvc.idfFarm
	left join	dbo.tlbFarmActual fa with (nolock)
	on			fa.idfFarmActual = f.idfFarmActual


	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrvc.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_reported
	on			org_reported.idfOffice = cfrvc.idfReportedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrvc.idfReportedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_reported			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_receivedby
	on			org_receivedby.idfOffice = cfrvc.idfReceivedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrvc.idfReceivedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_receivedby			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_inv
	on			org_inv.idfOffice = cfrvc.idfInvestigatedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrvc.idfInvestigatedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_inv
	/*1.	VDR's attributes - end*/

	/*2.	Addresses/Locations - start*/
	if @ShowSystemIdentifiers > 0
	select		vc.idfVetCase 'VDR System Identifier',
				cfrvc.idfFarmAddress as 'Farm Address System Identifier',
				gl_fa.idfsLocation as 'Farm Address Admin Unit System Identifier',
				gl_site.idfGeoLocationShared as 'Site Address System Identifier',
				gl_site.idfsLocation as 'Site Address Admin Unit System Identifier',
				vc.strCaseID as 'Report ID',
				case when gl_fa.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_fa.Level1Name, N'') + ISNULL(N'->' + ld_fa.Level2Name, N'') + ISNULL(N'->' + ld_fa.Level3Name, N'') + ISNULL(N'->' + ld_fa.Level4Name, N'') as 'Admin Unit of Farm Address',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered VDR'

	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = cfrvc.idfFarm

	left join	tlbGeoLocation gl_fa with (nolock)
	on			gl_fa.idfGeoLocation = cfrvc.idfFarmAddress
	left join	gisLocationDenormalized ld_fa with (nolock)
	on			ld_fa.idfsLocation = gl_fa.idfsLocation
				and ld_fa.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.tstSite s_entered with (nolock)
	on			s_entered.idfsSite = cfrvc.idfsSite
	left join	dbo.tlbOffice org_entered with (nolock)
	on			org_entered.idfOffice = s_entered.idfOffice
	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	else

	select		vc.strCaseID as 'Report ID',
				case when gl_fa.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_fa.Level1Name, N'') + ISNULL(N'->' + ld_fa.Level2Name, N'') + ISNULL(N'->' + ld_fa.Level3Name, N'') + ISNULL(N'->' + ld_fa.Level4Name, N'') as 'Admin Unit of Farm Address',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered VDR'

	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = cfrvc.idfFarm

	left join	tlbGeoLocation gl_fa with (nolock)
	on			gl_fa.idfGeoLocation = cfrvc.idfFarmAddress
	left join	gisLocationDenormalized ld_fa with (nolock)
	on			ld_fa.idfsLocation = gl_fa.idfsLocation
				and ld_fa.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.tstSite s_entered with (nolock)
	on			s_entered.idfsSite = cfrvc.idfsSite
	left join	dbo.tlbOffice org_entered with (nolock)
	on			org_entered.idfOffice = s_entered.idfOffice
	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	/*2.	Addresses/Locations - end*/

	/*3.	Samples'attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		vc.idfVetCase as 'VDR System Identifier',
				h.idfHerd as 'Herd System Identifier',
				sp.idfSpecies as 'Species System Identifier',
				a.idfAnimal as 'Animal System Identifier',
				m.idfMaterial as 'Sample System Identifier',
				tOutForSample.idfTransferOut as 'Transfer Out System Identifier',
				vc.strCaseID as 'Report ID',
				ISNULL(h.strHerdCode + N' / ', N'') + ISNULL(species_type.[name], N'') + ISNULL(N' / ' + a.strAnimalCode, N'') as 'Herd/Species/Animal',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Local Sample ID',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = cfrvc.idfFarm

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfVetCase = cfrvc.idfVetCase

	left join	dbo.tlbAnimal a with (nolock)
	on			a.idfAnimal = m.idfAnimal

	left join	dbo.tlbSpecies sp with (nolock)
		left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000086 /*Species Type*/) species_type
		on			species_type.idfsReference = sp.idfsSpeciesType
	on			sp.idfSpecies = ISNULL(a.idfSpecies, m.idfSpecies)

	left join	dbo.tlbHerd h with (nolock)
	on			h.idfHerd = sp.idfHerd
		
	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
	on			sample_type.idfsReference = m.idfsSampleType


	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_collected
	on			org_collected.idfOffice = m.idfFieldCollectedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = m.idfFieldCollectedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_collected

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_sent
	on			org_sent.idfOffice = m.idfSendToOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = m.idfSendToOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_sent

	outer apply
	(	select top 1
				tOut.idfTransferOut, tOut.strBarcode, tOut.idfSendFromOffice, tOut.idfSendToOffice
		from	dbo.tlbTransferOutMaterial tOutM with (nolock)
		join	dbo.tlbTransferOUT tOut with (nolock)
		on		tOut.idfTransferOut = tOutM.idfTransferOut
				and tOut.intRowStatus <= m.intRowStatus
		where	tOutM.idfMaterial = m.idfMaterial
				and tOutM.intRowStatus <= m.intRowStatus
	) tOutForSample

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_from
	on			org_transferred_from.idfOffice = tOutForSample.idfSendFromOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOutForSample.idfSendFromOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_from

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_to
	on			org_transferred_to.idfOffice = tOutForSample.idfSendToOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOutForSample.idfSendToOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_to

	else

	select		vc.strCaseID as 'Report ID',
				ISNULL(h.strHerdCode + N' / ', N'') + ISNULL(species_type.[name], N'') + ISNULL(N' / ' + a.strAnimalCode, N'') as 'Herd/Species/Animal',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Local Sample ID',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = cfrvc.idfFarm

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfVetCase = cfrvc.idfVetCase

	left join	dbo.tlbAnimal a with (nolock)
	on			a.idfAnimal = m.idfAnimal

	left join	dbo.tlbSpecies sp with (nolock)
		left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000086 /*Species Type*/) species_type
		on			species_type.idfsReference = sp.idfsSpeciesType
	on			sp.idfSpecies = ISNULL(a.idfSpecies, m.idfSpecies)

	left join	dbo.tlbHerd h with (nolock)
	on			h.idfHerd = sp.idfHerd
		
	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
	on			sample_type.idfsReference = m.idfsSampleType


	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_collected
	on			org_collected.idfOffice = m.idfFieldCollectedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = m.idfFieldCollectedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_collected

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_sent
	on			org_sent.idfOffice = m.idfSendToOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = m.idfSendToOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_sent

	outer apply
	(	select top 1
				tOut.idfTransferOut, tOut.strBarcode, tOut.idfSendFromOffice, tOut.idfSendToOffice
		from	dbo.tlbTransferOutMaterial tOutM with (nolock)
		join	dbo.tlbTransferOUT tOut with (nolock)
		on		tOut.idfTransferOut = tOutM.idfTransferOut
				and tOut.intRowStatus <= m.intRowStatus
		where	tOutM.idfMaterial = m.idfMaterial
				and tOutM.intRowStatus <= m.intRowStatus
	) tOutForSample

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_from
	on			org_transferred_from.idfOffice = tOutForSample.idfSendFromOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOutForSample.idfSendFromOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_from

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_to
	on			org_transferred_to.idfOffice = tOutForSample.idfSendToOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOutForSample.idfSendToOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_to

	/*3.	Samples'attributes - end*/

	/*4.	Connected Chain for VDR if applicable - start*/
	if @ShowSystemIdentifiers > 0
	begin
		;
		with	connectedChainLevel	(
					idfRootPredecessorVC,
					intLevel,
					idfLevelPredecessorVC,
					idfLevelSuccessorVC,
					strLevelSuccessorVCID,
					strLevelConnectedChainNames,
					strLevelConnectedChainIDs
								)
		as	(	select		cfrvccc.idfRootPredecessorVC,
							cfrvccc.intLevel,
							cfrvccc.idfLevelPredecessorVC,
							cfrvccc.idfLevelSuccessorVC,
							vc.strCaseID,
							cast((vc.strCaseID + case when vc.intRowStatus = 0 then N'' else N' (Deleted)' end) as nvarchar(2000)) collate Cyrillic_General_CI_AS,
							CAST(vc.idfVetCase as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrVCConnectedChain cfrvccc
				inner join	dbo.tlbVetCase vc with (nolock)
				on			vc.idfVetCase = cfrvccc.idfLevelSuccessorVC
				where		cfrvccc.idfLevelPredecessorVC is null
				union all
				select		cfrvccc.idfRootPredecessorVC,
							cfrvccc.intLevel,
							cfrvccc.idfLevelPredecessorVC,
							cfrvccc.idfLevelSuccessorVC,
							vc.strCaseID,
							cast((connectedChainLevel.strLevelConnectedChainNames + N'>' + (vc.strCaseID + case when vc.intRowStatus = 0 then N'' else N' (Deleted)' end) collate Cyrillic_General_CI_AS) as nvarchar(2000)) collate Cyrillic_General_CI_AS,
							cast((connectedChainLevel.strLevelConnectedChainIDs + N'>' + cast(vc.idfVetCase as nvarchar(20)) collate Cyrillic_General_CI_AS) as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrVCConnectedChain cfrvccc
				inner join	dbo.tlbVetCase vc with (nolock)
				on			vc.idfVetCase = cfrvccc.idfLevelSuccessorVC
				inner join	connectedChainLevel
				on			connectedChainLevel.idfRootPredecessorVC = cfrvccc.idfRootPredecessorVC
							and connectedChainLevel.idfLevelSuccessorVC = cfrvccc.idfLevelPredecessorVC
			)


		select		ccl.strLevelConnectedChainIDs as N'Connected Chain - System Identifiers',
					ccl.strLevelConnectedChainNames as 'Connected Chain - VDR Report IDs'
		from		connectedChainLevel ccl
		where		not exists
					(	select	1
						from	#cfrVCConnectedChain cfrvccc
						where	cfrvccc.idfRootPredecessorVC = ccl.idfRootPredecessorVC
								and cfrvccc.idfLevelPredecessorVC = ccl.idfLevelSuccessorVC
					)
		order by	reverse(ccl.strLevelConnectedChainNames)
	end
	else begin
		;
		with	connectedChainLevel	(
					idfRootPredecessorVC,
					intLevel,
					idfLevelPredecessorVC,
					idfLevelSuccessorVC,
					strLevelSuccessorVCID,
					strLevelConnectedChainNames
								)
		as	(	select		cfrvccc.idfRootPredecessorVC,
							cfrvccc.intLevel,
							cfrvccc.idfLevelPredecessorVC,
							cfrvccc.idfLevelSuccessorVC,
							vc.strCaseID,
							cast((vc.strCaseID + case when vc.intRowStatus = 0 then N'' else N' (Deleted)' end) as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrVCConnectedChain cfrvccc
				inner join	dbo.tlbVetCase vc with (nolock)
				on			vc.idfVetCase = cfrvccc.idfLevelSuccessorVC
				where		cfrvccc.idfLevelPredecessorVC is null
				union all
				select		cfrvccc.idfRootPredecessorVC,
							cfrvccc.intLevel,
							cfrvccc.idfLevelPredecessorVC,
							cfrvccc.idfLevelSuccessorVC,
							vc.strCaseID,
							cast((connectedChainLevel.strLevelConnectedChainNames + N'>' + (vc.strCaseID + case when vc.intRowStatus = 0 then N'' else N' (Deleted)' end) collate Cyrillic_General_CI_AS) as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrVCConnectedChain cfrvccc
				inner join	dbo.tlbVetCase vc with (nolock)
				on			vc.idfVetCase = cfrvccc.idfLevelSuccessorVC
				inner join	connectedChainLevel
				on			connectedChainLevel.idfRootPredecessorVC = cfrvccc.idfRootPredecessorVC
							and connectedChainLevel.idfLevelSuccessorVC = cfrvccc.idfLevelPredecessorVC
			)


		select		ccl.strLevelConnectedChainNames as 'Connected Chain - VDR Report IDs'
		from		connectedChainLevel ccl
		where		not exists
					(	select	1
						from	#cfrVCConnectedChain cfrvccc
						where	cfrvccc.idfRootPredecessorVC = ccl.idfRootPredecessorVC
								and cfrvccc.idfLevelPredecessorVC = ccl.idfLevelSuccessorVC
					)
		order by	reverse(ccl.strLevelConnectedChainNames)
	end
	/*4.	Connected Chain for VDR if applicable - end*/

	/*5.	List of the third-level sites, where VDR is available - start*/
	if @ShowSystemIdentifiers > 0
	select		distinct
				s.idfsSite as 'Site System Identifier',
				org.idfOffice as 'Office System Identifier',
				gl_site.idfsLocation as 'Admin Unit of Site Address System Identifier',
				isnull(s.strSiteID, N'') as 'Site ID',
				ISNULL(s_type.strDefault, N'') as 'Site Type',
				isnull(org.[name], N'') as 'Site Abbreviation',
				isnull(org.FullName, N'') as 'Site Full Name',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Site Address'
	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tflVetCaseFiltered vcf with (nolock)
	on			vcf.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = vcf.idfSiteGroup

	inner join	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference s_type with (nolock)
		on		s_type.idfsBaseReference = s.idfsSiteType
	on			s.idfsSite = s_to_sg.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org
	on			org.idfOffice = s.idfOffice

	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	else

	select		distinct
				isnull(s.strSiteID, N'') as 'Site ID',
				ISNULL(s_type.strDefault, N'') as 'Site Type',
				isnull(org.[name], N'') as 'Site Abbreviation',
				isnull(org.FullName, N'') as 'Site Full Name',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Site Address'
	from		#cfrVC cfrvc
	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tflVetCaseFiltered vcf with (nolock)
	on			vcf.idfVetCase = cfrvc.idfVetCase

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = vcf.idfSiteGroup

	inner join	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference s_type with (nolock)
		on		s_type.idfsBaseReference = s.idfsSiteType
	on			s.idfsSite = s_to_sg.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org
	on			org.idfOffice = s.idfOffice

	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	/*5.	List of the third-level sites, where VDR is available - end*/

end
else begin
	select	'VDR' as 'Object Type', 
			@strReportID as 'Report ID', 
			'is not found' as 'Error'
end

set nocount off
