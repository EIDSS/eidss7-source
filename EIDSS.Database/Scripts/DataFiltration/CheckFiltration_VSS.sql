-- Check filtration records calculated for Vector Surveillance Session

-- Input parameter - Vector Surveillance Session ID:
declare @strSessionID nvarchar(200)
set @strSessionID = 'JGETBTBZ230913'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	Vector Surveillance Session's attributes
--		-	Session ID
--		-	Field Session ID
--		-	Start Date
--		-	Date Last Updated of Vector Surveillance Session or its Related Lab objects
--		-	Location of Vector Surveillance Session
--		-	Entered by Site
--		-	Admin Unit of Address of the Site entered Session
--		-	Is deleted
--	2.	Pools/Vectors' attributes and locations
--		-	Pool/Vector ID
--		-	Field Pool/Vector ID
--		-	Vector Type
--		-	Vector Species
--		-	Is deleted
--		-	Collected by Institution
--		-	Identified by Institution
--		-	Admin Unit of Vector's Location
--	3.	Samples'attributes
--		-	Pool/Vector ID
--		-	Field Pool/Vector ID
--		-	Vector Type
--		-	Vector Species
--		-	Sample Type
--		-	Field Sample ID
--		-	Is deleted
--		-	Collected by Institution
--		-	Sent to Organization
--		-	Transfered From (if applicable)
--		-	Transfered To (if applicable)
--	4.	Field Tests
--		-	Pool/Vector ID
--		-	Field Pool/Vector ID
--		-	Vector Type
--		-	Vector Species
--		-	Sample Type
--		-	Field Sample ID
--		-	Field Test Name
--		-	Field Test Result
--		-	Is deleted
--		-	Tested by Institution
--	5.	Aggregate Collection Records'attributes
--		-	Record ID
--		-	Vector Type
--		-	Vector Species
--		-	Is deleted
--		-	Admin Unit of Aggregate Collection Records's Location
--	6.	List of the third-level sites, where Vector Surveillance Session is available


set nocount on

declare	@idfVectorSurveillanceSession bigint
set	@idfVectorSurveillanceSession = 
	(	select	top 1	idfVectorSurveillanceSession
		from	dbo.tlbVectorSurveillanceSession with (nolock)
		where	strSessionID = @strSessionID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfVectorSurveillanceSession
	)

if Object_ID('tempdb..#cfrVSS') is not null
begin
	execute sp_executesql N'drop table #cfrVSS'
end

if Object_ID('tempdb..#cfrVSS') is null
create table	#cfrVSS
(	[idfVectorSurveillanceSession]	bigint not null primary key,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfLocation]					bigint null,
	[idfsVSSRayon]					bigint null
)
truncate table #cfrVSS

if @idfVectorSurveillanceSession is not null
begin
	insert into #cfrVSS(idfVectorSurveillanceSession)
	values(@idfVectorSurveillanceSession)

	EXEC [dbo].[DF_VSS_FillList] @UsePredefinedData=1
	
	delete from #cfrVSS
	where	idfVectorSurveillanceSession <> @idfVectorSurveillanceSession

	/*1.	Vector Surveillance Session's attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		vss.idfVectorSurveillanceSession 'Session System Identifier',
				gl_site.idfGeoLocationShared as 'Site Address System Identifier',
				gl_site.idfsLocation as 'Site Address Admin Unit System Identifier',
				vss.strSessionID as 'Session ID',
				ISNULL(vss.strFieldSessionID, N'') as 'Field Session ID',
				isnull(CONVERT(nvarchar, vss.datStartDate, 120), N'Not Specified') as 'Start Date',
				isnull(CONVERT(nvarchar, vss.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(ld_session.Level1Name, N'') + ISNULL(N'->' + ld_session.Level2Name, N'') + ISNULL(N'->' + ld_session.Level3Name, N'') + ISNULL(N'->' + ld_session.Level4Name, N'') as 'Session Location',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered Session',
				case when vss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrvss.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	left join	tlbGeoLocationShared gl_session with (nolock)
	on			gl_session.idfGeoLocationShared = vss.idfLocation
	left join	gisLocationDenormalized ld_session with (nolock)
	on			ld_session.idfsLocation = gl_session.idfsLocation
				and ld_session.idfsLanguage = 10049003 /*en-US*/

	else

	select		vss.strSessionID as 'Session ID',
				ISNULL(vss.strFieldSessionID, N'') as 'Field Session ID',
				isnull(CONVERT(nvarchar, vss.datStartDate, 120), N'Not Specified') as 'Start Date',
				isnull(CONVERT(nvarchar, vss.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(ld_session.Level1Name, N'') + ISNULL(N'->' + ld_session.Level2Name, N'') + ISNULL(N'->' + ld_session.Level3Name, N'') + ISNULL(N'->' + ld_session.Level4Name, N'') as 'Session Location',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site',
				ISNULL(ld_site.Level1Name, N'') + ISNULL(N'->' + ld_site.Level2Name, N'') + ISNULL(N'->' + ld_site.Level3Name, N'') + ISNULL(N'->' + ld_site.Level4Name, N'') as 'Admin Unit of Address of the Site entered Session',
				case when vss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrvss.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	tlbGeoLocationShared gl_site with (nolock)
	on			gl_site.idfGeoLocationShared = org_entered.idfLocation
	left join	gisLocationDenormalized ld_site with (nolock)
	on			ld_site.idfsLocation = gl_site.idfsLocation
				and ld_site.idfsLanguage = 10049003 /*en-US*/

	left join	tlbGeoLocationShared gl_session with (nolock)
	on			gl_session.idfGeoLocationShared = vss.idfLocation
	left join	gisLocationDenormalized ld_session with (nolock)
	on			ld_session.idfsLocation = gl_session.idfsLocation
				and ld_session.idfsLanguage = 10049003 /*en-US*/

	/*1.	Vector Surveillance Session's attributes - end*/

	/*2.	Pools/Vectors' attributes and locations - start*/

	if @ShowSystemIdentifiers > 0	
	select		vss.idfVectorSurveillanceSession 'Session System Identifier',
				v.idfVector as 'Pool/Vector System Identifier',
				v.idfLocation as 'Pool/Vector Location System Identifier',
				gl.idfsLocation as 'Pool/Vector Location Admin Unit System Identifier',
				vss.strSessionID as 'Session ID',
				isnull(v.strVectorID, N'') as 'Pool/Vector ID',
				isnull(v.strFieldVectorID, N'') as 'Field Pool/Vector ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				case when v.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_identified.[name] + ISNULL(N'; Site ' + s_identified.strSiteID + N' (' + s_identified.strSiteType + N')', N''), N'') as 'Identified by Institution',
				case when gl.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld.Level1Name, N'') + ISNULL(N'->' + ld.Level2Name, N'') + ISNULL(N'->' + ld.Level3Name, N'') + ISNULL(N'->' + ld.Level4Name, N'') as 'Admin Unit of Vector Location'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVector v with (nolock)
	on			v.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = v.idfsVectorType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = v.idfsVectorSubType

	left join	tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = v.idfLocation
	left join	gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_collected
	on			org_collected.idfOffice = v.idfCollectedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = v.idfCollectedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_collected

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_identified
	on			org_identified.idfOffice = v.idfIdentifiedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = v.idfIdentifiedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_identified

	else

	select		vss.strSessionID as 'Session ID',
				isnull(v.strVectorID, N'') as 'Pool/Vector ID',
				isnull(v.strFieldVectorID, N'') as 'Field Pool/Vector ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				case when v.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_identified.[name] + ISNULL(N'; Site ' + s_identified.strSiteID + N' (' + s_identified.strSiteType + N')', N''), N'') as 'Identified by Institution',
				case when gl.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld.Level1Name, N'') + ISNULL(N'->' + ld.Level2Name, N'') + ISNULL(N'->' + ld.Level3Name, N'') + ISNULL(N'->' + ld.Level4Name, N'') as 'Admin Unit of Vector Location'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVector v with (nolock)
	on			v.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = v.idfsVectorType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = v.idfsVectorSubType

	left join	tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = v.idfLocation
	left join	gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_collected
	on			org_collected.idfOffice = v.idfCollectedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = v.idfCollectedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_collected

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_identified
	on			org_identified.idfOffice = v.idfIdentifiedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = v.idfIdentifiedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_identified

	/*2.	Pools/Vectors' attributes and locations - end*/

	/*3.	Samples'attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		vss.idfVectorSurveillanceSession 'Session System Identifier',
				v.idfVector as 'Pool/Vector System Identifier',
				m.idfMaterial as 'Sample System Identifier',
				tOutForSample.idfTransferOut as 'Transfer Out System Identifier',
				vss.strSessionID as 'Session ID',
				isnull(v.strVectorID, N'') as 'Pool/Vector ID',
				isnull(v.strFieldVectorID, N'') as 'Field Pool/Vector ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVector v with (nolock)
	on			v.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = v.idfsVectorType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = v.idfsVectorSubType

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession
				and m.idfVector = v.idfVector

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

	select		vss.strSessionID as 'Session ID',
				isnull(v.strVectorID, N'') as 'Pool/Vector ID',
				isnull(v.strFieldVectorID, N'') as 'Field Pool/Vector ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_collected.[name] + ISNULL(N'; Site ' + s_collected.strSiteID + N' (' + s_collected.strSiteType + N')', N''), N'') as 'Collected by Institution',
				ISNULL(org_sent.[name] + ISNULL(N'; Site ' + s_sent.strSiteID + N' (' + s_sent.strSiteType + N')', N''), N'') as 'Sent to Organization',
				ISNULL(org_transferred_from.[name] + ISNULL(N'; Site ' + s_transferred_from.strSiteID + N' (' + s_transferred_from.strSiteType + N')', N''), N'') as 'Transfered From (if applicable)',
				ISNULL(org_transferred_to.[name] + ISNULL(N'; Site ' + s_transferred_to.strSiteID + N' (' + s_transferred_to.strSiteType + N')', N''), N'') as 'Transfered To (if applicable)'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVector v with (nolock)
	on			v.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = v.idfsVectorType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = v.idfsVectorSubType

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession
				and m.idfVector = v.idfVector

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

	/*4.	Field Tests - start*/

	if @ShowSystemIdentifiers > 0
	select		vss.idfVectorSurveillanceSession 'Session System Identifier',
				v.idfVector as 'Pool/Vector System Identifier',
				m.idfMaterial as 'Sample System Identifier',
				ft.idfPensideTest as 'Field Test System Identifier',
				vss.strSessionID as 'Session ID',
				isnull(v.strVectorID, N'') as 'Pool/Vector ID',
				isnull(v.strFieldVectorID, N'') as 'Field Pool/Vector ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
				isnull(field_test_name.[name], N'') as 'Field Test Name',
				isnull(field_test_result.[name], N'') as 'Field Test Result',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_tested.[name] + ISNULL(N'; Site ' + s_tested.strSiteID + N' (' + s_tested.strSiteType + N')', N''), N'') as 'Tested by Institution'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVector v with (nolock)
	on			v.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = v.idfsVectorType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = v.idfsVectorSubType

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession
				and m.idfVector = v.idfVector

	inner join	dbo.tlbPensideTest ft
	on			ft.idfMaterial = m.idfMaterial

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
	on			sample_type.idfsReference = m.idfsSampleType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000104 /*Penside Test Name*/) field_test_name
	on			field_test_name.idfsReference = ft.idfsPensideTestName

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000105 /*Penside Test Name*/) field_test_result
	on			field_test_result.idfsReference = ft.idfsPensideTestResult

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_tested
	on			org_tested.idfOffice = ft.idfTestedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = ft.idfTestedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_tested

	else

	select		vss.strSessionID as 'Session ID',
				isnull(v.strVectorID, N'') as 'Pool/Vector ID',
				isnull(v.strFieldVectorID, N'') as 'Field Pool/Vector ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				isnull(sample_type.[name], N'') as 'Sample Type',
				isnull(m.strFieldBarcode, N'') as 'Field Sample ID',
				isnull(field_test_name.[name], N'') as 'Field Test Name',
				isnull(field_test_result.[name], N'') as 'Field Test Result',
				case when m.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(org_tested.[name] + ISNULL(N'; Site ' + s_tested.strSiteID + N' (' + s_tested.strSiteType + N')', N''), N'') as 'Tested by Institution'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVector v with (nolock)
	on			v.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = v.idfsVectorType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = v.idfsVectorSubType

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession
				and m.idfVector = v.idfVector

	inner join	dbo.tlbPensideTest ft
	on			ft.idfMaterial = m.idfMaterial

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000087 /*Samle Type*/) sample_type
	on			sample_type.idfsReference = m.idfsSampleType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000104 /*Penside Test Name*/) field_test_name
	on			field_test_name.idfsReference = ft.idfsPensideTestName

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000105 /*Penside Test Name*/) field_test_result
	on			field_test_result.idfsReference = ft.idfsPensideTestResult

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_tested
	on			org_tested.idfOffice = ft.idfTestedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = ft.idfTestedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_tested


	/*4.	Field Tests - end*/

	/*5.	Aggregate Collection Records'attributes - start*/

	if @ShowSystemIdentifiers > 0	
	select		vss.idfVectorSurveillanceSession 'Session System Identifier',
				vsss.idfsVSSessionSummary as 'Record System Identifier',
				vsss.idfGeoLocation as 'Record Location System Identifier',
				gl.idfsLocation as 'Record Location Admin Unit System Identifier',
				vss.strSessionID as 'Session ID',
				isnull(vsss.strVSSessionSummaryID, N'') as 'Record ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				case when vsss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				case when gl.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld.Level1Name, N'') + ISNULL(N'->' + ld.Level2Name, N'') + ISNULL(N'->' + ld.Level3Name, N'') + ISNULL(N'->' + ld.Level4Name, N'') as 'Admin Unit of Record Location'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVectorSurveillanceSessionSummary vsss with (nolock)
	on			vsss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = vsss.idfsVectorSubType

	left join	dbo.trtVectorSubType vst with (nolock)
	on			vst.idfsVectorSubType = vsss.idfsVectorSubType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = vst.idfsVectorType

	left join	tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = vsss.idfGeoLocation
	left join	gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/

	else

	select		vss.strSessionID as 'Session ID',
				isnull(vsss.strVSSessionSummaryID, N'') as 'Record ID',
				isnull(vector_type.[name], N'') as 'Vector Type',
				isnull(vector_species.[name], N'') as 'Vector Species',
				case when vsss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				case when gl.blnForeignAddress = 1 then N'Foreign Address: ' else '' end + ISNULL(ld.Level1Name, N'') + ISNULL(N'->' + ld.Level2Name, N'') + ISNULL(N'->' + ld.Level3Name, N'') + ISNULL(N'->' + ld.Level4Name, N'') as 'Admin Unit of Record Location'
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tlbVectorSurveillanceSessionSummary vsss with (nolock)
	on			vsss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000141 /*Vector Sub Type*/) vector_species
	on			vector_species.idfsReference = vsss.idfsVectorSubType

	left join	dbo.trtVectorSubType vst with (nolock)
	on			vst.idfsVectorSubType = vsss.idfsVectorSubType

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000140 /*Vector Type*/) vector_type
	on			vector_type.idfsReference = vst.idfsVectorType

	left join	tlbGeoLocation gl with (nolock)
	on			gl.idfGeoLocation = vsss.idfGeoLocation
	left join	gisLocationDenormalized ld with (nolock)
	on			ld.idfsLocation = gl.idfsLocation
				and ld.idfsLanguage = 10049003 /*en-US*/

	/*5.	Aggregate Collection Records'attributes - end*/

	/*6.	List of the third-level sites, where Vector Surveillance Session is available - start*/
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
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tflVectorSurveillanceSessionFiltered vssf with (nolock)
	on			vssf.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = vssf.idfSiteGroup

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
	from		#cfrVSS cfrvss
	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tflVectorSurveillanceSessionFiltered vssf with (nolock)
	on			vssf.idfVectorSurveillanceSession = cfrvss.idfVectorSurveillanceSession

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = vssf.idfSiteGroup

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

	/*6.	List of the third-level sites, where Vector Surveillance Session is available - end*/

end
else begin
	select	'Vector Surveillance Session' as 'Object Type', 
			@strSessionID as 'Session ID', 
			'is not found' as 'Error'
end

set nocount off
