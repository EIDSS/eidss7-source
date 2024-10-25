-- Check filtration records calculated for Aggregate Report or Actions

-- Input parameter - Aggregate Report ID:
declare @strReportID nvarchar(200)
set @strReportID = 'ZGETBTBZ233606'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	Aggregate Reports or Actions'attributes
--		-	Report ID
--		-	Report Type
--		-	Time Interval Unit
--		-	Start Date
--		-	End Date
--		-	Is deleted
--		-	Date Last Updated of Aggregate Report
--		-	Entered by: Institution
--		-	Notification Sent by: Institution
--		-	Notification Received by: Institution
--		-	Admin Unit of Address of the Site entered Report
--	2.	List of the third-level sites, where Aggregate Report is available


set nocount on

declare	@idfAggrCase bigint
set	@idfAggrCase = 
	(	select	top 1	idfAggrCase
		from	dbo.tlbAggrCase with (nolock)
		where	strCaseID = @strReportID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfAggrCase
	)

if Object_ID('tempdb..#cfrAggrCase') is not null
begin
	execute sp_executesql N'drop table #cfrAggrCase'
end

if Object_ID('tempdb..#cfrAggrCase') is null
create table	#cfrAggrCase
(	[idfAggrCase]					bigint not null primary key,
	[idfsSite]						bigint null,
	[idfReceivedByOffice]			bigint null,
	[idfSentByOffice]				bigint null,
	[idfEnteredByOffice]			bigint null,
	[idfsAggrCaseRayon]				bigint null
)
truncate table #cfrAggrCase

if @idfAggrCase is not null
begin
	insert into #cfrAggrCase(idfAggrCase)
	values(@idfAggrCase)

	EXEC [dbo].[DF_Aggregate_FillList] @UsePredefinedData=1
	
	delete from #cfrAggrCase
	where	idfAggrCase <> @idfAggrCase

	/*1.	Aggregate Reports or Actions'attributes - start*/

	if @ShowSystemIdentifiers > 0
	select		aggr.idfAggrCase 'Report System Identifier',
				aggr.idfsAdministrativeUnit as 'Report Admin Unit System Identifier',
				aggr.strCaseID as 'Report ID',
				ISNULL(replace(aggr_type.[name], N'Case', N'Report'), N'') as 'Report Type',
				case
					when	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 364
						then	'Year'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 89
						then	'Quarter'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 89
								)
							and DATEDIFF(MONTH, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 28
						then	'Month'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) >= 7
						then	'Week'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) < 7
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
						then	'Day'
					else	N'Unknown'
				end as 'Time Interval Unit',
				isnull(CONVERT(nvarchar, aggr.datStartDate, 120), N'Not Specified') as 'Start Date',
				isnull(CONVERT(nvarchar, aggr.datFinishDate, 120), N'Not Specified') as 'End Date',
				case when aggr.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, aggr.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by: Institution',
				ISNULL(org_sentby.[name] + ISNULL(N'; Site ' + s_sentby.strSiteID + N' (' + s_sentby.strSiteType + N')', N''), N'') as 'Notification Sent by: Institution',
				ISNULL(org_receivedby.[name] + ISNULL(N'; Site ' + s_receivedby.strSiteID + N' (' + s_receivedby.strSiteType + N')', N''), N'') as 'Notification Received by: Institution',
				ISNULL(ld_aggr.Level1Name, N'') + ISNULL(N'->' + ld_aggr.Level2Name, N'') + ISNULL(N'->' + ld_aggr.Level3Name, N'') + ISNULL(N'->' + ld_aggr.Level4Name, N'') as 'Admin Unit of Aggregate Report'
	from		#cfrAggrCase cfraggr
	inner join	dbo.tlbAggrCase aggr with (nolock)
	on			aggr.idfAggrCase = cfraggr.idfAggrCase

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000102 /*Aggregate Report Type*/) aggr_type
	on			aggr_type.idfsReference = aggr.idfsAggrCaseType

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfraggr.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_sentby
	on			org_sentby.idfOffice = cfraggr.idfSentByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfraggr.idfSentByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_sentby

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_receivedby
	on			org_receivedby.idfOffice = cfraggr.idfReceivedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfraggr.idfReceivedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_receivedby

	left join	gisLocationDenormalized ld_aggr with (nolock)
	on			ld_aggr.idfsLocation = aggr.idfsAdministrativeUnit
				and ld_aggr.idfsLanguage = 10049003 /*en-US*/

	else

	select		aggr.strCaseID as 'Report ID',
				ISNULL(replace(aggr_type.[name], N'Case', N'Report'), N'') as 'Report Type',
				case
					when	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 364
						then	'Year'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 89
						then	'Quarter'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 89
								)
							and DATEDIFF(MONTH, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 28
						then	'Month'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) >= 7
						then	'Week'
					when	(	DATEDIFF(YEAR, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
								or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) = 0
									or DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) < 7
							and DATEDIFF(DAY, aggr.datStartDate, dateadd(day, 1, aggr.datFinishDate)) > 0
						then	'Day'
					else	N'Unknown'
				end as 'Time Interval Unit',
				isnull(CONVERT(nvarchar, aggr.datStartDate, 120), N'Not Specified') as 'Start Date',
				isnull(CONVERT(nvarchar, aggr.datFinishDate, 120), N'Not Specified') as 'End Date',
				case when aggr.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, aggr.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by: Institution',
				ISNULL(org_sentby.[name] + ISNULL(N'; Site ' + s_sentby.strSiteID + N' (' + s_sentby.strSiteType + N')', N''), N'') as 'Notification Sent by: Institution',
				ISNULL(org_receivedby.[name] + ISNULL(N'; Site ' + s_receivedby.strSiteID + N' (' + s_receivedby.strSiteType + N')', N''), N'') as 'Notification Received by: Institution',
				ISNULL(ld_aggr.Level1Name, N'') + ISNULL(N'->' + ld_aggr.Level2Name, N'') + ISNULL(N'->' + ld_aggr.Level3Name, N'') + ISNULL(N'->' + ld_aggr.Level4Name, N'') as 'Admin Unit of Aggregate Report'
	from		#cfrAggrCase cfraggr
	inner join	dbo.tlbAggrCase aggr with (nolock)
	on			aggr.idfAggrCase = cfraggr.idfAggrCase

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000102 /*Aggregate Report Type*/) aggr_type
	on			aggr_type.idfsReference = aggr.idfsAggrCaseType

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfraggr.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_sentby
	on			org_sentby.idfOffice = cfraggr.idfSentByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfraggr.idfSentByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_sentby

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_receivedby
	on			org_receivedby.idfOffice = cfraggr.idfReceivedByOffice
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = cfraggr.idfReceivedByOffice
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_receivedby

	left join	gisLocationDenormalized ld_aggr with (nolock)
	on			ld_aggr.idfsLocation = aggr.idfsAdministrativeUnit
				and ld_aggr.idfsLanguage = 10049003 /*en-US*/

	/*1.	Aggregate Reports or Actions'attributes - end*/

	/*2.	List of the third-level sites, where Aggregate Report is available - start*/
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
	from		#cfrAggrCase cfraggr
	inner join	dbo.tlbAggrCase aggr with (nolock)
	on			aggr.idfAggrCase = cfraggr.idfAggrCase

	inner join	dbo.tflAggrCaseFiltered aggrf with (nolock)
	on			aggrf.idfAggrCase = cfraggr.idfAggrCase

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = aggrf.idfSiteGroup

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
	from		#cfrAggrCase cfraggr
	inner join	dbo.tlbAggrCase aggr with (nolock)
	on			aggr.idfAggrCase = cfraggr.idfAggrCase

	inner join	dbo.tflAggrCaseFiltered aggrf with (nolock)
	on			aggrf.idfAggrCase = cfraggr.idfAggrCase

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = aggrf.idfSiteGroup

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

	/*2.	List of the third-level sites, where Aggregate Report is available - end*/

end
else begin
	select	'Aggregate Report/Actions' as 'Object Type', 
			@strReportID as 'Report ID', 
			'is not found' as 'Error'
end

set nocount off
