-- Check filtration records calculated for Samples Transfer

-- Input parameter - Samples Transfer ID:
declare @strTransferID nvarchar(200)
set @strTransferID = 'STBTBTBZ240091'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	Samples Transfer's attributes
--		-	Transfer ID
--		-	Transfer Date
--		-	Is deleted
--		-	Date Last Updated of Samples Transfer
--		-	Entered by Site
--		-	Transferred From
--		-	Transferred To
--	2.	List of the third-level sites, where Transfer is available


set nocount on

declare	@idfTransferOut bigint
set	@idfTransferOut = 
	(	select	top 1	idfTransferOut
		from	dbo.tlbTransferOut with (nolock)
		where	strBarcode = @strTransferID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfTransferOut
	)

if Object_ID('tempdb..#cfrTransferOut') is not null
begin
	execute sp_executesql N'drop table #cfrTransferOut'
end

if Object_ID('tempdb..#cfrTransferOut') is null
create table	#cfrTransferOut
(	[idfTransferOut]				bigint not null primary key,
	[idfsSite]						bigint null,
	[idfSendFromOffice]				bigint null,
	[idfSendToOffice]				bigint null
)
truncate table #cfrTransferOut

if @idfTransferOut is not null
begin
	insert into #cfrTransferOut(idfTransferOut)
	values(@idfTransferOut)

	EXEC [dbo].[DF_TransferOut_FillList] @UsePredefinedData=1
	
	delete from #cfrTransferOut
	where	idfTransferOut <> @idfTransferOut

	/*1.	Samples Transfer's attributes - start*/

	if @ShowSystemIdentifiers > 0
	select		tOut.idfTransferOut 'Transfer System Identifier',
				tOut.strBarcode as 'Transfer ID',
				isnull(CONVERT(nvarchar, tOut.datSendDate, 120), N'Not Specified') as 'Transfer Date',
				case when tOut.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, tOut.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To'
	from		#cfrTransferOut cfrtOut
	inner join	dbo.tlbTransferOut tOut with (nolock)
	on			tOut.idfTransferOut = cfrtOut.idfTransferOut

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrtOut.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_from
	on			org_transferred_from.idfOffice = tOut.idfSendFromOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOut.idfSendFromOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_from

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_to
	on			org_transferred_to.idfOffice = tOut.idfSendToOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOut.idfSendToOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_to

	else

	select		tOut.strBarcode as 'Transfer ID',
				isnull(CONVERT(nvarchar, tOut.datSendDate, 120), N'Not Specified') as 'Transfer Date',
				case when tOut.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, tOut.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To'
	from		#cfrTransferOut cfrtOut
	inner join	dbo.tlbTransferOut tOut with (nolock)
	on			tOut.idfTransferOut = cfrtOut.idfTransferOut

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrtOut.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_from
	on			org_transferred_from.idfOffice = tOut.idfSendFromOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOut.idfSendFromOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_from

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_transferred_to
	on			org_transferred_to.idfOffice = tOut.idfSendToOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = tOut.idfSendToOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_transferred_to

	/*1.	Samples Transfer's attributes - end*/

	/*2.	List of the third-level sites, where Samples Transfer is available - start*/
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
	from		#cfrTransferOut cfrtOut
	inner join	dbo.tlbTransferOut tOut with (nolock)
	on			tOut.idfTransferOut = cfrtOut.idfTransferOut

	inner join	dbo.tflTransferOutFiltered cfrtOutf with (nolock)
	on			cfrtOutf.idfTransferOut = cfrtOut.idfTransferOut

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = cfrtOutf.idfSiteGroup

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
	from		#cfrTransferOut cfrtOut
	inner join	dbo.tlbTransferOut tOut with (nolock)
	on			tOut.idfTransferOut = cfrtOut.idfTransferOut

	inner join	dbo.tflTransferOutFiltered cfrtOutf with (nolock)
	on			cfrtOutf.idfTransferOut = cfrtOut.idfTransferOut

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = cfrtOutf.idfSiteGroup

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

	/*2.	List of the third-level sites, where Samples Transfer is available - end*/

end
else begin
	select	'Samples Transfer' as 'Object Type', 
			@strTransferID as 'Transfer ID', 
			'is not found' as 'Error'
end

set nocount off
