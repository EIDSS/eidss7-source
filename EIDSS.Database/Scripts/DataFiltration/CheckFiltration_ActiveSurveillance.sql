-- Check filtration records calculated for Active Surveillance Session

-- Input parameter - Active Surveillance Session ID:
declare @strSessionID nvarchar(200)
set @strSessionID = 'HASTBTBZ240002'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	Active Surveillance Session's attributes
--		-	Session ID
--		-	Session Category (HAAS/VAAS)
--		-	Date Entered
--		-	Date Last Updated of Active Surveillance Session or its Related Lab objects
--		-	Location of Active Surveillance Session
--		-	Entered by Site
--		-	Admin Unit of Address of the Site entered Session
--		-	Is deleted
--	2.	Addresses of Persons/Farms
--		-	In case of HASS: Admin Units of Persons' Current Residence Addresses
--		-	In case of VASS: Admin Units of Farms' Addresses
--	3.	Samples'attributes
--		-	In case of HAAS: Person Full Name
--		-	In case of VAAS: Farm/Herd/Species/Animal
--		-	Sample Type
--		-	Field Sample ID
--		-	Is deleted
--		-	Sent to Organization
--		-	Transfered From (if applicable)
--		-	Transfered To (if applicable)
--	4.	Linked Disease Reports
--		-	In case of HASS: HDRs
--		-	In case of VASS: VDRs
--	5.	List of the third-level sites, where Active Surveillance Session is available


set nocount on

declare	@idfMonitoringSession bigint
set	@idfMonitoringSession = 
	(	select	top 1	idfMonitoringSession
		from	dbo.tlbMonitoringSession with (nolock)
		where	strMonitoringSessionID = @strSessionID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfMonitoringSession
	)

declare	@idfsSessionCategory bigint
declare	@isHAAS bit = 0
set	@idfsSessionCategory =
	(	select	SessionCategoryID
		from	dbo.tlbMonitoringSession with (nolock)
		where	idfMonitoringSession = @idfMonitoringSession
	)
if	@idfsSessionCategory = 10502001
	set	@isHAAS = 1

if Object_ID('tempdb..#cfrMS') is not null
begin
	execute sp_executesql N'drop table #cfrMS'
end

if Object_ID('tempdb..#cfrMS') is null
create table	#cfrMS
(	[idfMonitoringSession]			bigint not null primary key,
	[idfsSite]						bigint null,
	[idfsMSRayon]					bigint null
)
truncate table #cfrMS

if @idfMonitoringSession is not null
begin
	insert into #cfrMS(idfMonitoringSession)
	values(@idfMonitoringSession)

	EXEC [dbo].[DF_ActiveSurveillance_FillList] @UsePredefinedData=1
	
	delete from #cfrMS
	where	idfMonitoringSession <> @idfMonitoringSession

	/*1.	Active Surveillance Session's attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		ms.idfMonitoringSession 'Session System Identifier',
				gl_site.idfGeoLocationShared as 'Site Address System Identifier',
				gl_site.idfsLocation as 'Site Address Admin Unit System Identifier',
				ms.strMonitoringSessionID as 'Session ID',
				case when @isHAAS = 1 then N'HAAS' else N'VAAS' end as 'Session Category',
				isnull(CONVERT(nvarchar, ms.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				isnull(CONVERT(nvarchar, ms.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(ld_session.Level1Name, N'') + ISNULL(N'->' + ld_session.Level2Name, N'') + ISNULL(N'->' + ld_session.Level3Name, N'') + ISNULL(N'->' + ld_session.Level4Name, N'') as 'Session Location',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered Session',
				case when ms.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'
	from		#cfrMS cfrms
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrms.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	left join	gisLocationDenormalized ld_session with (nolock)
	on			ld_session.idfsLocation = ms.idfsLocation
				and ld_session.idfsLanguage = 10049003 /*en-US*/

	else

	select		ms.strMonitoringSessionID as 'Session ID',
				case when @isHAAS = 1 then N'HAAS' else N'VAAS' end as 'Session Category',
				isnull(CONVERT(nvarchar, ms.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				isnull(CONVERT(nvarchar, ms.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(ld_session.Level1Name, N'') + ISNULL(N'->' + ld_session.Level2Name, N'') + ISNULL(N'->' + ld_session.Level3Name, N'') + ISNULL(N'->' + ld_session.Level4Name, N'') as 'Session Location',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered Session',
				case when ms.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'
	from		#cfrMS cfrms
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrms.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	left join	gisLocationDenormalized ld_session with (nolock)
	on			ld_session.idfsLocation = ms.idfsLocation
				and ld_session.idfsLanguage = 10049003 /*en-US*/

	/*1.	Active Surveillance Session's attributes - end*/

	/*2.	Addresses of Persons/Farms - start*/
	if @ShowSystemIdentifiers > 0	
		if @isHAAS = 0
			select		ms.idfMonitoringSession 'Session System Identifier',
						f.idfFarm as 'Farm (Copy) System Identifier',
						f.idfFarmActual as 'Farm (Original) System Identifier',
						f.idfFarmAddress as 'Farm Address System Identifier',
						gl_fa.idfsLocation as 'Farm Address Admin Unit System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
						case when gl_fa.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_fa.Level1Name, N'') + ISNULL(N'->' + ld_fa.Level2Name, N'') + ISNULL(N'->' + ld_fa.Level3Name, N'') + ISNULL(N'->' + ld_fa.Level4Name, N'') as 'Admin Unit of Farm Address'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbFarm f with (nolock)
			on			f.idfMonitoringSession = cfrms.idfMonitoringSession
			left join	dbo.tlbFarmActual fa with (nolock)
			on			fa.idfFarmActual = f.idfFarm

			left join	tlbGeoLocation gl_fa with (nolock)
			on			gl_fa.idfGeoLocation = f.idfFarmAddress
			left join	gisLocationDenormalized ld_fa with (nolock)
			on			ld_fa.idfsLocation = gl_fa.idfsLocation
						and ld_fa.idfsLanguage = 10049003 /*en-US*/
			union
			select		ms.idfMonitoringSession 'Session System Identifier',
						f.idfFarm as 'Farm (Copy) System Identifier',
						f.idfFarmActual as 'Farm (Original) System Identifier',
						f.idfFarmAddress as 'Farm Address System Identifier',
						gl_fa.idfsLocation as 'Farm Address Admin Unit System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
						case when gl_fa.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_fa.Level1Name, N'') + ISNULL(N'->' + ld_fa.Level2Name, N'') + ISNULL(N'->' + ld_fa.Level3Name, N'') + ISNULL(N'->' + ld_fa.Level4Name, N'') as 'Admin Unit of Farm Address'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession
			inner join	dbo.tlbMonitoringSessionSummary mss with (nolock)
			on			mss.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbFarm f with (nolock)
			on			f.idfFarm = mss.idfFarm
			left join	dbo.tlbFarmActual fa with (nolock)
			on			fa.idfFarmActual = f.idfFarm

			left join	tlbGeoLocation gl_fa with (nolock)
			on			gl_fa.idfGeoLocation = f.idfFarmAddress
			left join	gisLocationDenormalized ld_fa with (nolock)
			on			ld_fa.idfsLocation = gl_fa.idfsLocation
						and ld_fa.idfsLanguage = 10049003 /*en-US*/

		else
			select		ms.idfMonitoringSession 'Session System Identifier',
						h.idfHuman as 'Person (Copy) System Identifier',
						h.idfHumanActual as 'Person (Original) System Identifier',
						h.idfCurrentResidenceAddress as 'Person CR Address System Identifier',
						gl_cra.idfsLocation as 'CR Address Admin Unit System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
						dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
						case when gl_cra.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_cra.Level1Name, N'') + ISNULL(N'->' + ld_cra.Level2Name, N'') + ISNULL(N'->' + ld_cra.Level3Name, N'') + ISNULL(N'->' + ld_cra.Level4Name, N'') as 'Admin Unit of CR Address'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHuman h with (nolock)
			on			h.idfMonitoringSession = cfrms.idfMonitoringSession
			left join	dbo.HumanActualAddlInfo haai with (nolock)
			on			haai.HumanActualAddlInfoUID = h.idfHumanActual

			left join	tlbGeoLocation gl_cra with (nolock)
			on			gl_cra.idfGeoLocation = h.idfCurrentResidenceAddress
			left join	gisLocationDenormalized ld_cra with (nolock)
			on			ld_cra.idfsLocation = gl_cra.idfsLocation
						and ld_cra.idfsLanguage = 10049003 /*en-US*/
	else
		if @isHAAS = 0
			select		ms.strMonitoringSessionID as 'Session ID',
						coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
						case when gl_fa.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_fa.Level1Name, N'') + ISNULL(N'->' + ld_fa.Level2Name, N'') + ISNULL(N'->' + ld_fa.Level3Name, N'') + ISNULL(N'->' + ld_fa.Level4Name, N'') as 'Admin Unit of Farm Address'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbFarm f with (nolock)
			on			f.idfMonitoringSession = cfrms.idfMonitoringSession
			left join	dbo.tlbFarmActual fa with (nolock)
			on			fa.idfFarmActual = f.idfFarm

			left join	tlbGeoLocation gl_fa with (nolock)
			on			gl_fa.idfGeoLocation = f.idfFarmAddress
			left join	gisLocationDenormalized ld_fa with (nolock)
			on			ld_fa.idfsLocation = gl_fa.idfsLocation
						and ld_fa.idfsLanguage = 10049003 /*en-US*/
			union
			select		ms.strMonitoringSessionID as 'Session ID',
						coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
						case when gl_fa.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_fa.Level1Name, N'') + ISNULL(N'->' + ld_fa.Level2Name, N'') + ISNULL(N'->' + ld_fa.Level3Name, N'') + ISNULL(N'->' + ld_fa.Level4Name, N'') as 'Admin Unit of Farm Address'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession
			inner join	dbo.tlbMonitoringSessionSummary mss with (nolock)
			on			mss.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbFarm f with (nolock)
			on			f.idfFarm = mss.idfFarm
			left join	dbo.tlbFarmActual fa with (nolock)
			on			fa.idfFarmActual = f.idfFarm

			left join	tlbGeoLocation gl_fa with (nolock)
			on			gl_fa.idfGeoLocation = f.idfFarmAddress
			left join	gisLocationDenormalized ld_fa with (nolock)
			on			ld_fa.idfsLocation = gl_fa.idfsLocation
						and ld_fa.idfsLanguage = 10049003 /*en-US*/

		else
			select		ms.strMonitoringSessionID as 'Session ID',
						ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
						dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
						case when gl_cra.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_cra.Level1Name, N'') + ISNULL(N'->' + ld_cra.Level2Name, N'') + ISNULL(N'->' + ld_cra.Level3Name, N'') + ISNULL(N'->' + ld_cra.Level4Name, N'') as 'Admin Unit of CR Address'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHuman h with (nolock)
			on			h.idfMonitoringSession = cfrms.idfMonitoringSession
			left join	dbo.HumanActualAddlInfo haai with (nolock)
			on			haai.HumanActualAddlInfoUID = h.idfHumanActual

			left join	tlbGeoLocation gl_cra with (nolock)
			on			gl_cra.idfGeoLocation = h.idfCurrentResidenceAddress
			left join	gisLocationDenormalized ld_cra with (nolock)
			on			ld_cra.idfsLocation = gl_cra.idfsLocation
						and ld_cra.idfsLanguage = 10049003 /*en-US*/

	/*2.	Addresses/Locations - end*/

	/*3.	Samples'attributes - start*/
	if @ShowSystemIdentifiers > 0
		if	@isHAAS = 0
			select		ms.idfMonitoringSession as 'Session System Identifier',
						f.idfFarm as 'Farm (Copy) System Identifier',
						f.idfFarmActual as 'Farm (Original) System Identifier',
						h.idfHerd as 'Herd System Identifier',
						sp.idfSpecies as 'Species System Identifier',
						a.idfAnimal as 'Animal System Identifier',
						m.idfMaterial as 'Sample System Identifier',
						tOutForSample.idfTransferOut as 'Transfer Out System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						ISNULL(ISNULL(fa.strFarmCode, f.strFarmCode) + N' / ', N'') + ISNULL(h.strHerdCode + N' / ', N'') + ISNULL(species_type.[name], N'') + ISNULL(N' / ' + a.strAnimalCode, N'') as 'Farm/Herd/Species/Animal',
						isnull(sample_type.[name], N'') as 'Sample Type',
						isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
						case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
						ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
						ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
						ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbFarm f with (nolock)
				left join	dbo.tlbFarmActual fa with (nolock)
				on			fa.idfFarmActual = f.idfFarm
			on			f.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHerd h with (nolock)
			on			h.idfFarm = f.idfFarm

			inner join	dbo.tlbSpecies sp with (nolock)
				left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000086 /*Species Type*/) species_type
				on			species_type.idfsReference = sp.idfsSpeciesType
			on			sp.idfHerd = h.idfHerd

			left join	dbo.tlbAnimal a with (nolock)
			on			a.idfSpecies = sp.idfSpecies

			inner join	dbo.tlbMaterial m with (nolock)
			on			m.idfMonitoringSession = cfrms.idfMonitoringSession
						and (	(a.idfAnimal is null and m.idfSpecies = sp.idfSpecies)
								or (a.idfAnimal is not null and m.idfAnimal = a.idfAnimal)
							)

			left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
			on			sample_type.idfsReference = m.idfsSampleType

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
			select		ms.idfMonitoringSession as 'Session System Identifier',
						h.idfHuman as 'Person (Copy) System Identifier',
						h.idfHumanActual as 'Person (Original) System Identifier',
						m.idfMaterial as 'Sample System Identifier',
						tOutForSample.idfTransferOut as 'Transfer Out System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
						dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
						isnull(sample_type.[name], N'') as 'Sample Type',
						isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
						case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
						ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
						ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
						ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHuman h with (nolock)
			on			h.idfMonitoringSession = cfrms.idfMonitoringSession
			left join	dbo.HumanActualAddlInfo haai with (nolock)
			on			haai.HumanActualAddlInfoUID = h.idfHumanActual

			inner join	dbo.tlbMaterial m with (nolock)
			on			m.idfMonitoringSession = cfrms.idfMonitoringSession
						and m.idfHuman = h.idfHuman

			left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
			on			sample_type.idfsReference = m.idfsSampleType

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

		if	@isHAAS = 0
			select		ms.strMonitoringSessionID as 'Session ID',
						ISNULL(ISNULL(fa.strFarmCode, f.strFarmCode) + N' / ', N'') + ISNULL(h.strHerdCode + N' / ', N'') + ISNULL(species_type.[name], N'') + ISNULL(N' / ' + a.strAnimalCode, N'') as 'Farm/Herd/Species/Animal',
						isnull(sample_type.[name], N'') as 'Sample Type',
						isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
						case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
						ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
						ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
						ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbFarm f with (nolock)
				left join	dbo.tlbFarmActual fa with (nolock)
				on			fa.idfFarmActual = f.idfFarm
			on			f.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHerd h with (nolock)
			on			h.idfFarm = f.idfFarm

			inner join	dbo.tlbSpecies sp with (nolock)
				left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000086 /*Species Type*/) species_type
				on			species_type.idfsReference = sp.idfsSpeciesType
			on			sp.idfHerd = h.idfHerd

			left join	dbo.tlbAnimal a with (nolock)
			on			a.idfSpecies = sp.idfSpecies

			inner join	dbo.tlbMaterial m with (nolock)
			on			m.idfMonitoringSession = cfrms.idfMonitoringSession
						and (	(a.idfAnimal is null and m.idfSpecies = sp.idfSpecies)
								or (a.idfAnimal is not null and m.idfAnimal = a.idfAnimal)
							)

			left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
			on			sample_type.idfsReference = m.idfsSampleType

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
			select		ms.strMonitoringSessionID as 'Session ID',
						ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
						dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
						isnull(sample_type.[name], N'') as 'Sample Type',
						isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
						case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
						ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
						ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
						ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHuman h with (nolock)
			on			h.idfMonitoringSession = cfrms.idfMonitoringSession
			left join	dbo.HumanActualAddlInfo haai with (nolock)
			on			haai.HumanActualAddlInfoUID = h.idfHumanActual

			inner join	dbo.tlbMaterial m with (nolock)
			on			m.idfMonitoringSession = cfrms.idfMonitoringSession
						and m.idfHuman = h.idfHuman

			left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
			on			sample_type.idfsReference = m.idfsSampleType

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

	/*4.	Linked Disease Reports - start*/
	if @ShowSystemIdentifiers > 0
		if	@isHAAS = 0
			select		ms.idfMonitoringSession as 'Session System Identifier',
						vc.idfVetCase as 'VDR System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						ISNULL(vc.strCaseID, N'') as 'VDR Report ID'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbVetCase vc with (nolock)
				inner join	dbo.tlbFarm f with (nolock)
				on			f.idfFarm = vc.idfFarm
			on			vc.idfParentMonitoringSession = cfrms.idfMonitoringSession
		else
			select		ms.idfMonitoringSession as 'Session System Identifier',
						hc.idfHumanCase as 'HDR System Identifier',
						ms.strMonitoringSessionID as 'Session ID',
						ISNULL(hc.strCaseID, N'') as 'HDR Report ID'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHumanCase hc with (nolock)
				inner join	dbo.tlbHuman h with (nolock)
				on			h.idfHuman = hc.idfHuman
			on			hc.idfParentMonitoringSession = cfrms.idfMonitoringSession
	else
		if	@isHAAS = 0
			select		ms.strMonitoringSessionID as 'Session ID',
						ISNULL(vc.strCaseID, N'') as 'VDR Report ID'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbVetCase vc with (nolock)
				inner join	dbo.tlbFarm f with (nolock)
				on			f.idfFarm = vc.idfFarm
			on			vc.idfParentMonitoringSession = cfrms.idfMonitoringSession
		else
			select		ms.strMonitoringSessionID as 'Session ID',
						ISNULL(hc.strCaseID, N'') as 'HDR Report ID'
			from		#cfrMS cfrms
			inner join	dbo.tlbMonitoringSession ms with (nolock)
			on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

			inner join	dbo.tlbHumanCase hc with (nolock)
				inner join	dbo.tlbHuman h with (nolock)
				on			h.idfHuman = hc.idfHuman
			on			hc.idfParentMonitoringSession = cfrms.idfMonitoringSession

	/*4.	Linked Disease Reports - end*/

	/*5.	List of the third-level sites, where Active Surveillance Session is available - start*/
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
	from		#cfrMS cfrms
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

	inner join	dbo.tflMonitoringSessionFiltered msf with (nolock)
	on			msf.idfMonitoringSession = cfrms.idfMonitoringSession

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = msf.idfSiteGroup

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
	from		#cfrMS cfrms
	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = cfrms.idfMonitoringSession

	inner join	dbo.tflMonitoringSessionFiltered msf with (nolock)
	on			msf.idfMonitoringSession = cfrms.idfMonitoringSession

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = msf.idfSiteGroup

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

	/*5.	List of the third-level sites, where Active Surveillance Session is available - end*/

end
else begin
	select	'Active Surveillance Session' as 'Object Type', 
			@strSessionID as 'Session ID', 
			'is not found' as 'Error'
end

set nocount off
