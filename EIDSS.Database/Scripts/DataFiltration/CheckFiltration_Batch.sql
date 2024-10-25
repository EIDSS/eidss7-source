-- Check filtration records calculated for Batch of Tests

-- Input parameter - Batch ID:
declare @strBatchID nvarchar(200)
set @strBatchID = 'BTBTBTBZ240001'

-- Additional parameter (option whether system identifiers shall be shown)
declare	@ShowSystemIdentifiers	bit
set	@ShowSystemIdentifiers = 0 -- 1 = Yes, 0 = No

--Output data sets:
--	1.	Batch's attributes
--		-	Batch ID
--		-	Is deleted
--		-	Test Name
--		-	Date Last Updated of Batch
--		-	Entered by Site
--	2.	List of HDRs containing laboratory tests from the batch
--	3.	List of VDRs containing laboratory tests from the batch
--	4.	List of Active Surveillance Sessions containing laboratory tests from the batch
--	5.	List of Vector Surveillance Sessions containing laboratory tests from the batch
--	6.	List of the third-level sites, where Batch is available


set nocount on

declare	@idfBatchTest bigint
set	@idfBatchTest = 
	(	select	top 1	idfBatchTest
		from	dbo.tlbBatchTest with (nolock)
		where	strBarcode = @strBatchID collate Cyrillic_General_CI_AS
		order	by intRowStatus, idfBatchTest
	)

if Object_ID('tempdb..#cfrBatchTest') is not null
begin
	execute sp_executesql N'drop table #cfrBatchTest'
end

if Object_ID('tempdb..#cfrBatchTest') is null
create table	#cfrBatchTest
(	[idfBatchTest]					bigint not null primary key,
	[idfsSite]						bigint null
)
truncate table #cfrBatchTest

if @idfBatchTest is not null
begin
	insert into #cfrBatchTest(idfBatchTest)
	values(@idfBatchTest)

	EXEC [dbo].[DF_BatchTest_FillList] @UsePredefinedData=1
	
	delete from #cfrBatchTest
	where	idfBatchTest <> @idfBatchTest

	/*1.	Batch's attributes - start*/

	if @ShowSystemIdentifiers > 0
	select		bt.idfBatchTest 'Batch System Identifier',
				bt.strBarcode as 'Batch ID',
				case when bt.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(test_name.[name], N'') as 'Test Name',
				isnull(CONVERT(nvarchar, bt.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site'
	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000097 /*Test Name*/) test_name
	on			test_name.idfsReference = bt.idfsTestName

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrbt.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	else

	select		bt.strBarcode as 'Batch ID',
				case when bt.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted',
				ISNULL(test_name.[name], N'') as 'Test Name',
				isnull(CONVERT(nvarchar, bt.datModificationForArchiveDate, 120), N'Not Specified') as 'Date for Filtration Calculation',
				ISNULL(org_entered.[name], N'') + ISNULL(N'; Site ' + s_entered.strSiteID + N' (' + s_entered_type.strDefault + N')', N'') as 'Entered by Site'
	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000097 /*Test Name*/) test_name
	on			test_name.idfsReference = bt.idfsTestName

	left join	dbo.tstSite s_entered with (nolock)
		join	dbo.trtBaseReference s_entered_type with (nolock)
		on		s_entered_type.idfsBaseReference = s_entered.idfsSiteType
	on			s_entered.idfsSite = cfrbt.idfsSite
	left join	dbo.FN_GBL_InstitutionRepair('en-US') org_entered
	on			org_entered.idfOffice = s_entered.idfOffice

	/*1.	Batch's attributes - end*/

	/*2.	List of HDRs containing laboratory tests from the batch - start*/

	if @ShowSystemIdentifiers > 0
	select		distinct
				bt.idfBatchTest 'Batch System Identifier',
				hc.idfHumanCase 'HDR System Identifier',
				h.idfHuman as 'Patient (Copy) System Identifier',
				h.idfHumanActual as 'Patient (Original) System Identifier',
				bt.strBarcode as 'Batch ID',
				hc.strCaseID as 'HDR Report ID',
				isnull(CONVERT(nvarchar, hc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				isnull(d.[name], N'') as 'Current Diagnosis',
				ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
				dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
				case when hc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = m.idfHumanCase

	left join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = hc.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000019 /*Diagnosis*/) d
	on			d.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

	else

	select		distinct
				bt.strBarcode as 'Batch ID',
				hc.strCaseID as 'HDR Report ID',
				isnull(CONVERT(nvarchar, hc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				isnull(d.[name], N'') as 'Current Diagnosis',
				ISNULL(haai.EIDSSPersonID, N'') as 'EIDSS Person ID',
				dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) as 'Patient Full Name',
				case when hc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbHumanCase hc with (nolock)
	on			hc.idfHumanCase = m.idfHumanCase

	left join	dbo.tlbHuman h with (nolock)
	on			h.idfHuman = hc.idfHuman
	left join	dbo.HumanActualAddlInfo haai with (nolock)
	on			haai.HumanActualAddlInfoUID = h.idfHumanActual

	left join	dbo.FN_GBL_ReferenceRepair('en-US', 19000019 /*Diagnosis*/) d
	on			d.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

	/*2.	List of HDRs containing laboratory tests from the batch - end*/

	/*3.	List of VDRs containing laboratory tests from the batch - start*/

	if @ShowSystemIdentifiers > 0
	select		distinct
				bt.idfBatchTest 'Batch System Identifier',
				vc.idfVetCase 'VDR System Identifier',
				f.idfFarm as 'Farm (Copy) System Identifier',
				f.idfFarmActual as 'Farm (Original) System Identifier',
				bt.strBarcode as 'Batch ID',
				vc.strCaseID as 'VDR Report ID',
				isnull(CONVERT(nvarchar, vc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
				case when vc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = m.idfVetCase

	left join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = vc.idfFarm
	left join	dbo.tlbFarmActual fa with (nolock)
	on			fa.idfFarmActual = f.idfFarmActual

	else

	select		distinct
				bt.strBarcode as 'Batch ID',
				vc.strCaseID as 'VDR Report ID',
				isnull(CONVERT(nvarchar, vc.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				coalesce(fa.strFarmCode, f.strFarmCode, N'') as 'Farm ID',
				case when vc.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbVetCase vc with (nolock)
	on			vc.idfVetCase = m.idfVetCase

	left join	dbo.tlbFarm f with (nolock)
	on			f.idfFarm = vc.idfFarm
	left join	dbo.tlbFarmActual fa with (nolock)
	on			fa.idfFarmActual = f.idfFarmActual

	/*3.	List of VDRs containing laboratory tests from the batch - end*/

	/*4.	List of Active Surveillance Sessions containing laboratory tests from the batch - start*/

	if @ShowSystemIdentifiers > 0
	select		distinct
				bt.idfBatchTest 'Batch System Identifier',
				ms.idfMonitoringSession 'Session System Identifier',
				bt.strBarcode as 'Batch ID',
				ms.strMonitoringSessionID as 'AS Session ID',
				case when ms.SessionCategoryID = 10502001 then N'HAAS' else N'VAAS' end as 'AS Session Category',
				isnull(CONVERT(nvarchar, ms.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				case when ms.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = m.idfMonitoringSession

	else

	select		distinct
				bt.strBarcode as 'Batch ID',
				ms.strMonitoringSessionID as 'AS Session ID',
				case when ms.SessionCategoryID = 10502001 then N'HAAS' else N'VAAS' end as 'AS Session Category',
				isnull(CONVERT(nvarchar, ms.datEnteredDate, 120), N'Not Specified') as 'Date Entered',
				case when ms.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbMonitoringSession ms with (nolock)
	on			ms.idfMonitoringSession = m.idfMonitoringSession

	/*4.	List of Active Surveillance Sessions containing laboratory tests from the batch - end*/

	/*5.	List of Vector Surveillance Sessions containing laboratory tests from the batch - start*/

	if @ShowSystemIdentifiers > 0
	select		distinct
				bt.idfBatchTest 'Batch System Identifier',
				vss.idfVectorSurveillanceSession 'Session System Identifier',
				bt.strBarcode as 'Batch ID',
				vss.strSessionID as 'VS Session ID',
				ISNULL(vss.strFieldSessionID, N'') as 'Field VS Session ID',
				isnull(CONVERT(nvarchar, vss.datStartDate, 120), N'Not Specified') as 'Start Date',
				case when vss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession

	else

	select		distinct
				bt.strBarcode as 'Batch ID',
				vss.strSessionID as 'VS Session ID',
				ISNULL(vss.strFieldSessionID, N'') as 'Field VS Session ID',
				isnull(CONVERT(nvarchar, vss.datStartDate, 120), N'Not Specified') as 'Start Date',
				case when vss.intRowStatus <> 0 then N'Deleted' else N'' end as 'Is deleted'

	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tlbTesting t with (nolock)
	on			t.idfBatchTest = bt.idfBatchTest

	inner join	dbo.tlbMaterial m with (nolock)
	on			m.idfMaterial = t.idfMaterial

	inner join	dbo.tlbVectorSurveillanceSession vss with (nolock)
	on			vss.idfVectorSurveillanceSession = m.idfVectorSurveillanceSession

	/*5.	List of Vector Surveillance Sessions containing laboratory tests from the batch - end*/

	/*6.	List of the third-level sites, where Batch is available - start*/
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
	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tflBatchTestFiltered cfrtOutf with (nolock)
	on			cfrtOutf.idfBatchTest = cfrbt.idfBatchTest

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
	from		#cfrBatchTest cfrbt
	inner join	dbo.tlbBatchTest bt with (nolock)
	on			bt.idfBatchTest = cfrbt.idfBatchTest

	inner join	dbo.tflBatchTestFiltered cfrtOutf with (nolock)
	on			cfrtOutf.idfBatchTest = cfrbt.idfBatchTest

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

	/*6.	List of the third-level sites, where Batch is available - end*/

end
else begin
	select	'Batch' as 'Object Type', 
			@strBatchID as 'Batch ID', 
			'is not found' as 'Error'
end

set nocount off
