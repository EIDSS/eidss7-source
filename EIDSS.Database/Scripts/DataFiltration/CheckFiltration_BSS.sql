-- Check filtration records calculated for BSS Form

-- Input parameter - BSS Form ID:
declare @strFormID nvarchar(200)
set @strFormID = 'LGETBTBZ230020'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	BSS Form's attributes
--		-	Form ID
--		-	BSS Type
--		-	Date  Entered
--		-	EIDSS Person ID
--		-	Person Full Name
--		-	Administrative Unit of CR Address of Patient
--		-	Is deleted
--		-	Date Last Updated of BSS Form
--		-	Entered by Site
--		-	Hospital
--	2.	List of the third-level sites, where BBS Form is available


set nocount on

declare	@idfBasicSyndromicSurveillance bigint
set	@idfBasicSyndromicSurveillance = 
	(	select	top 1	idfBasicSyndromicSurveillance
		from	dbo.tlbBasicSyndromicSurveillance with (nolock)
		where	strFormID = @strFormID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfBasicSyndromicSurveillance
	)

if Object_ID('tempdb..#cfrBSS') is not null
begin
	execute sp_executesql N'drop table #cfrBSS'
end

create table	#cfrBSS
(	[idfBasicSyndromicSurveillance]	bigint not null primary key,
	[idfHuman]						bigint null,
	[idfsSite]						bigint null,
	[idfHospital]					bigint null,
	[idfCRAddress]					bigint null,
	[idfsCRARayon]					bigint null
)
truncate table #cfrBSS

if @idfBasicSyndromicSurveillance is not null
begin
	insert into #cfrBSS(idfBasicSyndromicSurveillance)
	values(@idfBasicSyndromicSurveillance)

	EXEC [dbo].[DF_BSS_FillList] @UsePredefinedData=1
	
	delete from #cfrBSS
	where	idfBasicSyndromicSurveillance <> @idfBasicSyndromicSurveillance

	/*1.	BSS Form's attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		bss.idfBasicSyndromicSurveillance 'Form System Identifier',
				h.idfHuman as 'Patient (Copy) System Identifier',
				h.idfHumanActual as 'Patient (Original) System Identifier',
				h.idfCurrentResidenceAddress as 'CR Address System Identifier',
				gl_cra.idfsLocation as 'CR Address Admin Unit System Identifier',
				bss.strFormID as 'Form ID',
				ISNULL(bss_type.[name], N'') as 'BSS Type',
				isnull(CONVERT(nvarchar, bss.datDateEntered, 120), N'Not Specified') as 'Entered Date',
				ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
				dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Person Full Name',
				case when gl_cra.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_cra.Level1Name, N'') + ISNULL(N'->' + ld_cra.Level2Name, N'') + ISNULL(N'->' + ld_cra.Level3Name, N'') + ISNULL(N'->' + ld_cra.Level4Name, N'') as 'Admin Unit of Person CR Address',
				case when bss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, bss.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(org_hospital.[name] + ISNULL(N'; Site ' + s_hospital.strSiteID + N' (' + s_hospital.strSiteType + N')', N''), N'') as 'Hospital'
	from		#cfrBSS cfrbss
	inner join	dbo.tlbBasicSyndromicSurveillance bss with (nolock)
	on			bss.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = bss.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	tlbGeoLocation gl_cra with (nolock)
	on			gl_cra.idfGeoLocation = h.idfCurrentResidenceAddress
	left join	gisLocationDenormalized ld_cra with (nolock)
	on			ld_cra.idfsLocation = gl_cra.idfsLocation
				and ld_cra.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000159 /*Basic Syndromic Surveillance - Type*/) bss_type
	on			bss_type.idfsReference = bss.idfsBasicSyndromicSurveillanceType

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrbss.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_hospital
	on			org_hospital.idfOffice = cfrbss.idfHospital
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrbss.idfHospital
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_hospital

	else

	select		bss.strFormID as 'Form ID',
				ISNULL(bss_type.[name], N'') as 'BSS Type',
				isnull(CONVERT(nvarchar, bss.datDateEntered, 120), N'Not Specified') as 'Entered Date',
				ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
				dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Person Full Name',
				case when gl_cra.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld_cra.Level1Name, N'') + ISNULL(N'->' + ld_cra.Level2Name, N'') + ISNULL(N'->' + ld_cra.Level3Name, N'') + ISNULL(N'->' + ld_cra.Level4Name, N'') as 'Admin Unit of Person CR Address',
				case when bss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, bss.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(org_hospital.[name] + ISNULL(N'; Site ' + s_hospital.strSiteID + N' (' + s_hospital.strSiteType + N')', N''), N'') as 'Hospital'
	from		#cfrBSS cfrbss
	inner join	dbo.tlbBasicSyndromicSurveillance bss with (nolock)
	on			bss.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance

	inner join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = bss.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	tlbGeoLocation gl_cra with (nolock)
	on			gl_cra.idfGeoLocation = h.idfCurrentResidenceAddress
	left join	gisLocationDenormalized ld_cra with (nolock)
	on			ld_cra.idfsLocation = gl_cra.idfsLocation
				and ld_cra.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000159 /*Basic Syndromic Surveillance - Type*/) bss_type
	on			bss_type.idfsReference = bss.idfsBasicSyndromicSurveillanceType

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrbss.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_hospital
	on			org_hospital.idfOffice = cfrbss.idfHospital
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfrbss.idfHospital
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_hospital

	/*1.	BSS Form's attributes - end*/

	/*2.	List of the third-level sites, where BSS Form is available - start*/
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
	from		#cfrBSS cfrbss
	inner join	dbo.tlbBasicSyndromicSurveillance bss with (nolock)
	on			bss.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance

	inner join	dbo.tflBasicSyndromicSurveillanceFiltered cfrbssf with (nolock)
	on			cfrbssf.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = cfrbssf.idfSiteGroup

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
	from		#cfrBSS cfrbss
	inner join	dbo.tlbBasicSyndromicSurveillance bss with (nolock)
	on			bss.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance

	inner join	dbo.tflBasicSyndromicSurveillanceFiltered cfrbssf with (nolock)
	on			cfrbssf.idfBasicSyndromicSurveillance = cfrbss.idfBasicSyndromicSurveillance

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = cfrbssf.idfSiteGroup

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

	/*2.	List of the third-level sites, where BSS Form is available - end*/

end
else begin
	select	'BSS Form' as 'Object Type', 
			@strFormID as 'Form ID', 
			'is not found' as 'Error'
end

set nocount off
