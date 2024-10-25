-- Check filtration records calculated for HDR

-- Input parameter - HDR Report ID:
declare @strReportID nvarchar(200)
set @strReportID = 'HUMTBTBZ240160'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	HDR's attributes
--		-	Report ID
--		-	Date Entered
--		-	Current Diagnosis
--		-	EIDSS Person ID
--		-	Patient Full Name
--		-	Date Last Updated of HDR or its Related Lab objects
--		-	Is deleted
--		-	Entered by Organization
--		-	Notification Sent by Facility
--		-	Notification Received by Facility
--		-	Current location of patient: Hospital Name
--		-	Facility patient first sought care
--		-	Investigating Organization
--	2.	Addresses/Locations
--		-	Admin Unit of Patient's Current Residence Address
--		-	Admin Unit of Location of Exposure
--		-	Admin Unit of Address of the site entered HDR
--	3.	Samples'attributes
--		-	Sample Type
--		-	Local Sample ID
--		-	Is deleted
--		-	Collected by Institution
--		-	Sent to Organization
--		-	Transfered From (if applicable)
--		-	Transfered To (if applicable)
--	4.	Deduplication Chain for HDR if applicable
--	5.	List of the third-level sites, where HDR is available


set nocount on

declare	@idfHumanCase bigint
set	@idfHumanCase = 
	(	select	top 1	idfHumanCase
		from	dbo.tlbHumanCase with (nolock)
		where	strCaseID = @strReportID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfHumanCase
	)

if Object_ID('tempdb..#cfrHC') is not null
begin
	execute sp_executesql N'drop table #cfrHC'
end

if Object_ID('tempdb..#cfrHCDeduplicationChain') is not null
begin
	execute sp_executesql N'drop table #cfrHCDeduplicationChain'
end

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

if @idfHumanCase is not null
begin
	insert into #cfrHC(idfHumanCase)
	values(@idfHumanCase)

	EXEC [dbo].[DF_HDR_FillList] @UsePredefinedData=1

	delete from #cfrHC
	where idfHumanCase <> @idfHumanCase

	/*1.	HDR's attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		hc.idfHumanCase 'HDR System Identifier',
				h.idfHuman as 'Patient (Copy) System Identifier',
				h.idfHumanActual as 'Patient (Original) System Identifier',
				hc.strCaseID as 'Report ID',
				isnull(CONVERT(nvarchar, hc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				isnull(d.[name], N'') as 'Current Diagnosis',
				ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
				dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
				isnull(CONVERT(nvarchar, hc.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				case when hc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Organization',
				ISNULL(org_sentby.[name] + ISNULL(N'; Site ' + s_sentby.strSiteID + N' (' + s_sentby.strSiteType + N')', N''), N'') as 'Notification Sent by Facility',
				ISNULL(org_receivedby.[name] + ISNULL(N'; Site ' + s_receivedby.strSiteID + N' (' + s_receivedby.strSiteType + N')', N''), N'') as 'Notification Received by Facility',
				ISNULL(org_hospital.[name] + ISNULL(N'; Site ' + s_hospital.strSiteID + N' (' + s_hospital.strSiteType + N')', N''), N'') as 'Current location of patient: Hospital',
				ISNULL(org_pfsc.[name] + ISNULL(N'; Site ' + s_pfsc.strSiteID + N' (' + s_pfsc.strSiteType + N')', N''), N'') as 'Facility patient first sought care',
				ISNULL(org_inv.[name] + ISNULL(N'; Site ' + s_inv.strSiteID + N' (' + s_inv.strSiteType + N')', N''), N'') as 'Investigating Organization'
	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = cfrhc.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000019 /*Diagnosis*/) d
	on			d.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrhc.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_sentby
	on			org_entered.idfOffice = cfrhc.idfSentByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfSentByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_sentby			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_receivedby
	on			org_receivedby.idfOffice = cfrhc.idfReceivedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfReceivedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_receivedby			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_hospital
	on			org_hospital.idfOffice = cfrhc.idfHospital
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfHospital
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_hospital

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_pfsc
	on			org_pfsc.idfOffice = cfrhc.idfSoughtCareFacility
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfSoughtCareFacility
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_pfsc

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_inv
	on			org_inv.idfOffice = cfrhc.idfInvestigatedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfInvestigatedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_inv

	else

	select		hc.strCaseID as 'Report ID',
				isnull(CONVERT(nvarchar, hc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				isnull(d.[name], N'') as 'Current Diagnosis',
				ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
				dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
				isnull(CONVERT(nvarchar, hc.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				case when hc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Organization',
				ISNULL(org_sentby.[name] + ISNULL(N'; Site ' + s_sentby.strSiteID + N' (' + s_sentby.strSiteType + N')', N''), N'') as 'Notification Sent by Facility',
				ISNULL(org_receivedby.[name] + ISNULL(N'; Site ' + s_receivedby.strSiteID + N' (' + s_receivedby.strSiteType + N')', N''), N'') as 'Notification Received by Facility',
				ISNULL(org_hospital.[name] + ISNULL(N'; Site ' + s_hospital.strSiteID + N' (' + s_hospital.strSiteType + N')', N''), N'') as 'Current location of patient: Hospital',
				ISNULL(org_pfsc.[name] + ISNULL(N'; Site ' + s_pfsc.strSiteID + N' (' + s_pfsc.strSiteType + N')', N''), N'') as 'Facility patient first sought care',
				ISNULL(org_inv.[name] + ISNULL(N'; Site ' + s_inv.strSiteID + N' (' + s_inv.strSiteType + N')', N''), N'') as 'Investigating Organization'
	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = cfrhc.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000019 /*Diagnosis*/) d
	on			d.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrhc.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_sentby
	on			org_entered.idfOffice = cfrhc.idfSentByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfSentByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_sentby			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_receivedby
	on			org_receivedby.idfOffice = cfrhc.idfReceivedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfReceivedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_receivedby			

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_hospital
	on			org_hospital.idfOffice = cfrhc.idfHospital
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfHospital
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_hospital

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_pfsc
	on			org_pfsc.idfOffice = cfrhc.idfSoughtCareFacility
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfSoughtCareFacility
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_pfsc

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_inv
	on			org_inv.idfOffice = cfrhc.idfInvestigatedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrhc.idfInvestigatedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_inv
	/*1.	HDR's attributes - end*/

	/*2.	Addresses/Locations - start*/
	if @ShowSystemIdentifiers > 0
	select		hc.idfHumanCase 'HDR System Identifier',
				cfrhc.idfCRAddress as 'CR Address System Identifier',
				gl_cra.idfsLocation as 'CR Address Admin Unit System Identifier',
				cfrhc.idfExposureLocation as 'Location Of Exposure System Identifier',
				gl_exp.idfsLocation as 'Location Of Exposure Admin Unit System Identifier',
				gl_site.idfGeoLocationShared as 'Site Address System Identifier',
				gl_site.idfsLocation as 'Site Address Admin Unit System Identifier',
				hc.strCaseID as 'Report ID',
				case when gl_cra.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_cra.Level1Name, N'') + ISNULL(N'->' + ld_cra.Level2Name, N'') + ISNULL(N'->' + ld_cra.Level3Name, N'') + ISNULL(N'->' + ld_cra.Level4Name, N'') as 'Admin Unit of Current Residence Address',
				ISNULL(ld_exp.Level1Name, N'') + ISNULL(N'->' + ld_exp.Level2Name, N'') + ISNULL(N'->' + ld_exp.Level3Name, N'') + ISNULL(N'->' + ld_exp.Level4Name, N'') as 'Admin Unit of Location of Exposure',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered HDR'

	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = cfrhc.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	tlbGeoLocation gl_cra with (nolock)
	on			gl_cra.idfGeoLocation = cfrhc.idfCRAddress
	left join	gisLocationDenormalized ld_cra with (nolock)
	on			ld_cra.idfsLocation = gl_cra.idfsLocation
				and ld_cra.idfsLanguage = 10049003 /*en-US*/

	left join	tlbGeoLocation gl_exp with (nolock)
	on			gl_exp.idfGeoLocation = cfrhc.idfExposureLocation
	left join	gisLocationDenormalized ld_exp with (nolock)
	on			ld_exp.idfsLocation = gl_exp.idfsLocation
				and ld_exp.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.tstSite s_entered with (nolock)
	on			s_entered.idfsSite = cfrhc.idfsSite
	left join	dbo.tlbOffice org_entered with (nolock)
	on			org_entered.idfOffice = s_entered.idfOffice
	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	else

	select		hc.strCaseID as 'Report ID',
				case when gl_cra.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_cra.Level1Name, N'') + ISNULL(N'->' + ld_cra.Level2Name, N'') + ISNULL(N'->' + ld_cra.Level3Name, N'') + ISNULL(N'->' + ld_cra.Level4Name, N'') as 'Admin Unit of Current Residence Address',
				ISNULL(ld_exp.Level1Name, N'') + ISNULL(N'->' + ld_exp.Level2Name, N'') + ISNULL(N'->' + ld_exp.Level3Name, N'') + ISNULL(N'->' + ld_exp.Level4Name, N'') as 'Admin Unit of Location of Exposure',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered HDR'

	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = cfrhc.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	tlbGeoLocation gl_cra with (nolock)
	on			gl_cra.idfGeoLocation = cfrhc.idfCRAddress
	left join	gisLocationDenormalized ld_cra with (nolock)
	on			ld_cra.idfsLocation = gl_cra.idfsLocation
				and ld_cra.idfsLanguage = 10049003 /*en-US*/

	left join	tlbGeoLocation gl_exp with (nolock)
	on			gl_exp.idfGeoLocation = cfrhc.idfExposureLocation
	left join	gisLocationDenormalized ld_exp with (nolock)
	on			ld_exp.idfsLocation = gl_exp.idfsLocation
				and ld_exp.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.tstSite s_entered with (nolock)
	on			s_entered.idfsSite = cfrhc.idfsSite
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
	select		hc.idfHumanCase 'HDR System Identifier',
				m.idfMaterial as 'Sample System Identifier',
				tOutForSample.idfTransferOut as 'Transfer Out System Identifier',
				hc.strCaseID as 'Report ID',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Local Sample ID',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = cfrhc.idfHuman

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfHumanCase = cfrhc.idfHumanCase
		
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
	on			org_transferred_from.idfOffice = tOutForSample.idfSendToOffice
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

	select		hc.strCaseID as 'Report ID',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Local Sample ID',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = cfrhc.idfHuman

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfHumanCase = cfrhc.idfHumanCase
		
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
	on			org_transferred_from.idfOffice = tOutForSample.idfSendToOffice
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

	/*4.	Deduplication Chain for HDR if applicable - start*/
	if @ShowSystemIdentifiers > 0
	begin
		;
		with	deduplicationChainLevel	(
					idfRootSurvivorHC,
					intLevel,
					idfLevelSurvivorHC,
					idfLevelSupersededHC,
					strLevelSupersededHCID,
					strLevelDeduplicationChainNames,
					strLevelDeduplicationChainIDs
								)
		as	(	select		cfrhcdc.idfRootSurvivorHC,
							cfrhcdc.intLevel,
							cfrhcdc.idfLevelSurvivorHC,
							cfrhcdc.idfLevelSupersededHC,
							hc.strCaseID,
							cast((hc.strCaseID + case when hc.intRowStatus = 0 then N'' else N' (Deleted)' end) as nvarchar(2000)) collate Cyrillic_General_CI_AS,
							CAST(hc.idfHumanCase as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrHCDeduplicationChain cfrhcdc
				inner join	dbo.tlbHumanCase hc with (nolock)
				on			hc.idfHumanCase = cfrhcdc.idfLevelSupersededHC
				where		cfrhcdc.idfLevelSurvivorHC is null
				union all
				select		cfrhcdc.idfRootSurvivorHC,
							cfrhcdc.intLevel,
							cfrhcdc.idfLevelSurvivorHC,
							cfrhcdc.idfLevelSupersededHC,
							hc.strCaseID,
							cast(((hc.strCaseID + case when hc.intRowStatus = 0 then N'' else N' (Deleted)' end) + N'>' + deduplicationChainLevel.strLevelDeduplicationChainNames collate Cyrillic_General_CI_AS) as nvarchar(2000)) collate Cyrillic_General_CI_AS,
							cast((cast(hc.idfHumanCase as nvarchar(20)) + N'>' + deduplicationChainLevel.strLevelDeduplicationChainIDs collate Cyrillic_General_CI_AS) as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrHCDeduplicationChain cfrhcdc
				inner join	dbo.tlbHumanCase hc with (nolock)
				on			hc.idfHumanCase = cfrhcdc.idfLevelSupersededHC
				inner join	deduplicationChainLevel
				on			deduplicationChainLevel.idfRootSurvivorHC = cfrhcdc.idfRootSurvivorHC
							and deduplicationChainLevel.idfLevelSupersededHC = cfrhcdc.idfLevelSurvivorHC
			)


		select		dcl.strLevelDeduplicationChainIDs as N'Deduplication Chain - System Identifiers',
					dcl.strLevelDeduplicationChainNames as 'Deduplication Chain - HDR Report IDs'
		from		deduplicationChainLevel dcl
		where		not exists
					(	select	1
						from	#cfrHCDeduplicationChain cfrhcdc
						where	cfrhcdc.idfRootSurvivorHC = dcl.idfRootSurvivorHC
								and cfrhcdc.idfLevelSurvivorHC = dcl.idfLevelSupersededHC
					)
		order by	dcl.strLevelDeduplicationChainNames
	end
	else begin
		;
		with	deduplicationChainLevel	(
					idfRootSurvivorHC,
					intLevel,
					idfLevelSurvivorHC,
					idfLevelSupersededHC,
					strLevelSupersededHCID,
					strLevelDeduplicationChainNames
								)
		as	(	select		cfrhcdc.idfRootSurvivorHC,
							cfrhcdc.intLevel,
							cfrhcdc.idfLevelSurvivorHC,
							cfrhcdc.idfLevelSupersededHC,
							hc.strCaseID,
							cast((hc.strCaseID + case when hc.intRowStatus = 0 then N'' else N' (Deleted)' end) as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrHCDeduplicationChain cfrhcdc
				inner join	dbo.tlbHumanCase hc with (nolock)
				on			hc.idfHumanCase = cfrhcdc.idfLevelSupersededHC
				where		cfrhcdc.idfLevelSurvivorHC is null
				union all
				select		cfrhcdc.idfRootSurvivorHC,
							cfrhcdc.intLevel,
							cfrhcdc.idfLevelSurvivorHC,
							cfrhcdc.idfLevelSupersededHC,
							hc.strCaseID,
							cast(((hc.strCaseID + case when hc.intRowStatus = 0 then N'' else N' (Deleted)' end) + N'>' + deduplicationChainLevel.strLevelDeduplicationChainNames collate Cyrillic_General_CI_AS) as nvarchar(2000)) collate Cyrillic_General_CI_AS
				from		#cfrHCDeduplicationChain cfrhcdc
				inner join	dbo.tlbHumanCase hc with (nolock)
				on			hc.idfHumanCase = cfrhcdc.idfLevelSupersededHC
				inner join	deduplicationChainLevel
				on			deduplicationChainLevel.idfRootSurvivorHC = cfrhcdc.idfRootSurvivorHC
							and deduplicationChainLevel.idfLevelSupersededHC = cfrhcdc.idfLevelSurvivorHC
			)


		select		dcl.strLevelDeduplicationChainNames as 'Deduplication Chain - HDR Report IDs'
		from		deduplicationChainLevel dcl
		where		not exists
					(	select	1
						from	#cfrHCDeduplicationChain cfrhcdc
						where	cfrhcdc.idfRootSurvivorHC = dcl.idfRootSurvivorHC
								and cfrhcdc.idfLevelSurvivorHC = dcl.idfLevelSupersededHC
					)
		order by	dcl.strLevelDeduplicationChainNames
	end
	/*4.	Deduplication Chain for HDR if applicable - end*/

	/*5.	List of the third-level sites, where HDR is available - start*/
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
	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tflHumanCaseFiltered hcf with (nolock)
	on			hcf.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = hcf.idfSiteGroup

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
	from		#cfrHC cfrhc
	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tflHumanCaseFiltered hcf with (nolock)
	on			hcf.idfHumanCase = cfrhc.idfHumanCase

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = hcf.idfSiteGroup

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

	/*5.	List of the third-level sites, where HDR is available - end*/

end
else begin
	select	'HDR' as 'Object Type', 
			@strReportID as 'Report ID', 
			'is not found' as 'Error'
end

set nocount off
