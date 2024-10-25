-- Check filtration records calculated for ILI Aggregate Form or Actions

-- Input parameter - ILI Aggregate Form ID:
declare @strFormID nvarchar(200)
set @strFormID = 'RGETBTBZ230009'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	ILI Aggregate Forms' attributes
--		-	Form ID
--		-	Time Interval Unit
--		-	Start Date
--		-	End Date
--		-	Is deleted
--		-	Date Last Updated of ILI Aggregate Form
--		-	Entered by Site
--	2.	Hospitals in the rows of the form
--	3.	List of the third-level sites, where ILI Aggregate Form is available


set nocount on

declare	@idfAggregateHeader bigint
set	@idfAggregateHeader = 
	(	select	top 1	idfAggregateHeader
		from	dbo.tlbBasicSyndromicSurveillanceAggregateHeader with (nolock)
		where	strFormID = @strFormID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfAggregateHeader
	)

if Object_ID('tempdb..#cfrBSSAggr') is not null
begin
	execute sp_executesql N'drop table #cfrBSSAggr'
end

if Object_ID('tempdb..#cfrBSSAggr') is null
create table	#cfrBSSAggr
(	[idfAggregateHeader]			bigint not null primary key,
	[idfsSite]						bigint null
)
truncate table #cfrBSSAggr

if @idfAggregateHeader is not null
begin
	insert into #cfrBSSAggr(idfAggregateHeader)
	values(@idfAggregateHeader)

	EXEC [dbo].[DF_BSSAggregate_FillList] @UsePredefinedData=1
	
	delete from #cfrBSSAggr
	where	idfAggregateHeader <> @idfAggregateHeader

	/*1.	ILI Aggregate Forms' attributes - start*/
	if @ShowSystemIdentifiers > 0
	select		bssaggr.idfAggregateHeader 'Form System Identifier',
				bssaggr.strFormID as 'Form ID',
				case
					when	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 364
						then	'Year'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 89
						then	'Quarter'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 89
								)
							and DATEDIFF(MONTH, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 28
						then	'Month'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) >= 7
						then	'Week'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) < 7
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
						then	'Day'
					else	N'Unknown'
				end as 'Time Interval Unit',
				isnull(CONVERT(nvarchar, bssaggr.datStartDate, 120), N'Not Specified') as 'Start Date',
				isnull(CONVERT(nvarchar, bssaggr.datFinishDate, 120), N'Not Specified') as 'End Date',
				case when bssaggr.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, bssaggr.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site'
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	on			bssaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrbssaggr.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	else

	select		bssaggr.strFormID as 'Form ID',
				case
					when	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 364
						then	'Year'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 89
						then	'Quarter'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 89
								)
							and DATEDIFF(MONTH, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 28
						then	'Month'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) >= 7
						then	'Week'
					when	(	DATEDIFF(YEAR, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
								or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 364
							)
							and (	DATEDIFF(QUARTER, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 89
								)
							and (	DATEDIFF(MONTH, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) = 0
									or DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) <= 28
								)
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) < 7
							and DATEDIFF(DAY, bssaggr.datStartDate, dateadd(day, 1, bssaggr.datFinishDate)) > 0
						then	'Day'
					else	N'Unknown'
				end as 'Time Interval Unit',
				isnull(CONVERT(nvarchar, bssaggr.datStartDate, 120), N'Not Specified') as 'Start Date',
				isnull(CONVERT(nvarchar, bssaggr.datFinishDate, 120), N'Not Specified') as 'End Date',
				case when bssaggr.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				isnull(CONVERT(nvarchar, bssaggr.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site'
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	on			bssaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrbssaggr.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	/*1.	ILI Aggregate Forms' attributes - end*/

	/*2.	Hospitals in the rows of the form - start*/
	if @ShowSystemIdentifiers > 0
	select		bssaggr.idfAggregateHeader 'Form System Identifier',
				bssaggr_row.idfAggregateDetail 'Form Row System Identifier',
				bssaggr.strFormID as 'Form ID',
				case when bssaggr_row.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is Row deleted',
				ISNULL(org_hospital.[name], N'') + ISNULL(N'; Site ' + s_hospital.strSiteID + N' (' + s_hospital.strSiteType + N')', N'') as 'Hosptal/Sentinel Station'
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	on			bssaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateDetail bssaggr_row with (nolock)
	on			bssaggr_row.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_hospital
	on			org_hospital.idfOffice = bssaggr_row.idfHospital
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = bssaggr_row.idfHospital
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_hospital

	else

	select		distinct
				bssaggr.strFormID as 'Form ID',
				case when bssaggr_row.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is Row deleted',
				ISNULL(org_hospital.[name], N'') + ISNULL(N'; Site ' + s_hospital.strSiteID + N' (' + s_hospital.strSiteType + N')', N'') as 'Hosptal/Sentinel Station'
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	on			bssaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateDetail bssaggr_row with (nolock)
	on			bssaggr_row.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_hospital
	on			org_hospital.idfOffice = bssaggr_row.idfHospital
	outer apply
	(	select	top 1 s.idfsSite, s.strSiteID, br.strDefault as strSiteType
		from	dbo.tstSite s with (nolock)
		join	dbo.trtBaseReference br with (nolock)
		on		br.idfsBaseReference = s.idfsSiteType
		where	s.idfOffice = bssaggr_row.idfHospital
				and s.intRowStatus = 0
		order by	s.idfsSite
	) s_hospital

	/*2.	Hospitals in the rows of the form - end*/

	/*3.	List of the third-level sites, where ILI Aggregate Form is available - start*/
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
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	on			bssaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	inner join	dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered cfrbssaggrf with (nolock)
	on			cfrbssaggrf.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = cfrbssaggrf.idfSiteGroup

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
	from		#cfrBSSAggr cfrbssaggr
	inner join	dbo.tlbBasicSyndromicSurveillanceAggregateHeader bssaggr with (nolock)
	on			bssaggr.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	inner join	dbo.tflBasicSyndromicSurveillanceAggregateHeaderFiltered cfrbssaggrf with (nolock)
	on			cfrbssaggrf.idfAggregateHeader = cfrbssaggr.idfAggregateHeader

	inner join	dbo.tflSiteToSiteGroup s_to_sg with (nolock)
	on			s_to_sg.idfSiteGroup = cfrbssaggrf.idfSiteGroup

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

	/*3.	List of the third-level sites, where ILI Aggregate Form is available - end*/

end
else begin
	select	'ILI Aggregate Form' as 'Object Type', 
			@strFormID as 'Form ID', 
			'is not found' as 'Error'
end

set nocount off
