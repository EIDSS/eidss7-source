
 
 --##SUMMARY Border rayons’ incidence comparative report
 /*
 Implement rules for retrieving data into the Border rayons’ incidence comparative report according to the specification:
 $/BTRP/Project_Documents/08x-Implementation/Customizations/AJ/AJ Customization EIDSS v6/Reports/Border rayons' incidents comparative report/Specification for report development - Border rayons' incidents comparative report.doc
 */
 
 --##REMARKS Author: Romasheva S.
 --##REMARKS Create date: 25.09.2015
 
 --##RETURNS Don't use 
 
 /*
 --Example of a call of procedure:
 
exec [report].[USP_REP_HUM_BorderRayonsComparativeReport] @LangID='en',@Year=2016,@FromMonth=1,@ToMonth=12,@StrCounter=N'1',@RegionID=1344330000000,@RayonID=1344360000000,@StrDiagnosis='7718510000000,7718060000000',@SiteID=871 
exec [report].[USP_REP_HUM_BorderRayonsComparativeReport] @LangID='en',@Year=2016,@FromMonth=1,@ToMonth=12,@StrCounter=N'1',@RegionID=1344330000000,@RayonID=1344440000000,@StrDiagnosis='',@SiteID=871 
exec [report].[USP_REP_HUM_BorderRayonsComparativeReport] @LangID='en',@Year=2016,@FromMonth=1,@ToMonth=12,@StrCounter=N'1',@RegionID=1344330000000,@RayonID=1344440000000,@StrDiagnosis='7718050000000,7718120000000,7718130000000,7718290000000,7718350000000,7718360000000',@SiteID=871 
exec [report].[USP_REP_HUM_BorderRayonsComparativeReport] @LangID='en',@Year=2016,@FromMonth=1,@ToMonth=12,@StrCounter=N'1,2',@RegionID=1344330000000,@RayonID=1344440000000,@StrDiagnosis=''

 */ 
  
 create PROCEDURE [Report].[USP_REP_HUM_BorderRayonsComparativeReport]
 	@LangID				as varchar(36),
 	@Year				as int, 
 	@FromMonth			as int = null,
 	@ToMonth			as int = null,
 	@strCounter			as nvarchar(max),  -- 1 = Absolute number, 2 = For 10.000 population, 3 = For 100.000 population, 4 = For 1.000.000 population
 	@RegionID			as bigint,
 	@RayonID			as bigint,
 	@strDiagnosis		as  nvarchar(max),
 	@SiteID				as bigint = null
 AS
  BEGIN

	
	create table #Diagnosis (
		intRowNum int identity not null,
		idfsDiagnosis bigint primary key,
		strDiagnosisName nvarchar(2000),
		strIDC10 nvarchar(200)
	)
 	
 	
 	create table	#ReportDiagnosisTable	
	(	
	    strKey					varchar(200) not null,-- primary key,   -- let it be idfsRayon + '_' + intCounter
 		idfsRayon				bigint not null, -- =-1 for total row
 		intCounter				int not null,
 		intCounterValue			int not null,
 		strRayonName			nvarchar(2000) not null,
 		
 		idfsDiagnosis			bigint,
 		strDiagnosis			nvarchar(200),
 		strIDCCode				nvarchar(100),	
 		dblValue				decimal(10,2),

 		dblTotal				decimal(10,2),
 		blnTotalVisible			bit default 0,
 													
 		intRowNum				int not null default 0 -- =999 for total row
	)
 	
 	declare
 		@idfsLanguage bigint,
 		@CountryID bigint,
 		@idfsSite bigint,
 		@idfsSiteType bigint,
 		
 		@StartDate	datetime,	 
 		@FinishDate datetime,
 
 		
 		@isWeb bigint,
 		@idfsStatType_Population bigint,
 		
 		@iDiagnosis	int,
 		@blnTotalVisible bit = 0,
 		
 		@iCounter int
 		
	
	declare @FilteredRayons table
	(idfsRayon bigint primary key) 		
 
 	declare @RayonsForStatistics table
	(
		idfsRayon bigint,
		maxYear int,
		intPopulation int,
		primary key (idfsRayon)
	)	
	
	declare @BorderRayons table (
		idfsRayon bigint not null primary key	
	)
	

	
 	SET @idfsLanguage = dbo.fnGetLanguageCode (@LangID)	
 		
 	set	@CountryID = 170000000
 	
 	if @FromMonth is null set @FromMonth = 1
 	if @ToMonth is null set @ToMonth = 12
 	set @StartDate = CAST(@Year AS VARCHAR(4)) + case when @FromMonth < 10 then '0' else '' end + cast(@FromMonth as varchar) + '01'
	set @FinishDate = CAST(@Year AS VARCHAR(4)) + case when @ToMonth < 10 then '0' else '' end + cast(@ToMonth as varchar) + '01'
	
	set @FinishDate = dateadd(month, 1, @FinishDate)
	
 	print @StartDate
 	print @FinishDate
 	
	set @idfsSite = ISNULL(@SiteID, dbo.fnSiteID())
	
		declare  @Counters table(
		intCounter int primary key,
		intCounterValue numeric(10,2) not null
	)

	--if cast(@CounterXML as varchar(max)) <> '<ItemList></ItemList>'
	--begin 
	--	EXEC sp_xml_preparedocument @iCounter OUTPUT, @CounterXML

		insert into @Counters (
 			intCounter,
 			intCounterValue
 		) 
 		select 
 			CAST(cn.[Value] AS BIGINT), 
 			case CAST(cn.[Value] AS BIGINT) 
 				when 1 then 1
 				when 2 then 10000.00
 				when 3 then 100000.00
 				when 4 then 1000000.00
 				else 0
 			end
 		from report.FN_GBL_SYS_SplitList(@StrCounter,1,',') cn
 		
		
 		insert into #Diagnosis (
 			idfsDiagnosis,
 			strDiagnosisName, 
 			strIDC10
 		) 
 		select td.idfsDiagnosis, fr.name, td.strIDC10
 		from report.FN_GBL_SYS_SplitList(@StrDiagnosis,1,',') dg
 		inner join trtDiagnosis td
 		on td.idfsDiagnosis =  CAST(dg.[Value] AS BIGINT) 
 		inner join dbo.fnReference(@LangID, 19000019) fr
 		on td.idfsDiagnosis = fr.idfsReference
 		
 		left join trtDiagnosisToDiagnosisGroup dgr
 			inner join dbo.fnReference(@LangID, 19000156) dgn
 			on dgn.idfsReference = dgr.idfsDiagnosisGroup
 		on dgr.idfsDiagnosis = td.idfsDiagnosis
 		and dgr.intRowStatus = 0
 		
 		order by 
 			case when dgr.idfDiagnosisToDiagnosisGroup is not null then '1' else '2' end + '_' + isnull(dgn.name, '') + fr.name
	
	-- calc @blnTotalVisible
	if exists(
		select *
		from trtDiagnosisToDiagnosisGroup tdtdg
			left join #Diagnosis d
			on d.idfsDiagnosis = tdtdg.idfsDiagnosis
			
		where not exists (
			select * from trtDiagnosisToDiagnosisGroup tdtdg2
			left join #Diagnosis d2
			on d2.idfsDiagnosis = tdtdg2.idfsDiagnosis
			where tdtdg2.idfsDiagnosisGroup = tdtdg.idfsDiagnosisGroup
			and d2.idfsDiagnosis is null
		)	
	) or 
	not exists (select * from #Diagnosis) 
	begin	
		set @blnTotalVisible = 1
	end	
	--------
  
	select @isWeb = isnull(ts.blnIsWEB, 0) 
	from tstSite ts
	join tstLocalSiteOptions lso
	on lso.strName = N'SiteID'
		and lso.strValue = cast(ts.idfsSite as nvarchar(20))
	
	select @idfsSiteType = ts.idfsSiteType
	from tstSite ts
	join tstLocalSiteOptions lso
	on lso.strName = N'SiteID'
		and lso.strValue = cast(ts.idfsSite as nvarchar(20))
	if @idfsSiteType is null set @idfsSiteType = 10085001	
	
	--set @idfsStatType_Population = 39850000000  -- Population
	select @idfsStatType_Population = tbra.idfsBaseReference
	from trtBaseReferenceAttribute tbra
		inner join	trtAttributeType at
		on			at.strAttributeTypeName = N'Statistical Data Type'
	where cast(tbra.varValue as nvarchar(100)) = N'Population'
		   
	insert into @BorderRayons
	select tgfcr.idfsGISBaseReference
	from trtGISObjectForCustomReport tgfcr 
		inner join report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) gr
		on gr.idfsRayon = tgfcr.idfsGISBaseReference
	where cast(tgfcr.strGISObjectAlias as bigint) = @RayonID
   
if exists (select * from @Counters c where c.intCounter > 1) -- 1 = Absolute number
begin
	if @idfsSiteType not in (10085001, 10085002) or @isWeb <> 1
	begin
		insert into @FilteredRayons (idfsRayon)
		select r.idfsRayon
		from  tstSite s
			inner join	tstCustomizationPackage cp
			on			cp.idfCustomizationPackage = s.idfCustomizationPackage	
						and cp.idfsCountry = @CountryID
			
			inner join	tlbOffice o
			on			o.idfOffice = s.idfOffice
						and o.intRowStatus = 0
						
			inner join	tlbGeoLocationShared gls
			on			gls.idfGeoLocationShared = o.idfLocation
			
			inner join report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
			  on r.idfsRayon = gls.idfsRayon
			  and r.intRowStatus = 0
			
			inner join	tflSiteToSiteGroup sts
				inner join	tflSiteGroup tsg
				on			tsg.idfSiteGroup = sts.idfSiteGroup
							and tsg.idfsRayon is null
			on			sts.idfsSite = s.idfsSite
			
			inner join	tflSiteGroupRelation sgr
			on			sgr.idfSenderSiteGroup = sts.idfSiteGroup
			
			inner join	tflSiteToSiteGroup stsr
				inner join	tflSiteGroup tsgr
				on			tsgr.idfSiteGroup = stsr.idfSiteGroup
							and tsgr.idfsRayon is null
			on			sgr.idfReceiverSiteGroup =stsr.idfSiteGroup
						and stsr.idfsSite = @idfsSite
		where  gls.idfsRayon is not null
		
		-- + border area
		insert into @FilteredRayons (idfsRayon)
		select distinct
			osr.idfsRayon
		from @FilteredRayons fr
			inner join report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
			on			r.idfsRayon = fr.idfsRayon
						and r.intRowStatus = 0
	          
			inner join	tlbGeoLocationShared gls
			on			gls.idfsRayon = r.idfsRayon
		
			inner join	tlbOffice o
			on			gls.idfGeoLocationShared = o.idfLocation
						and o.intRowStatus = 0
			
			inner join tstSite s
				inner join	tstCustomizationPackage cp
				on			cp.idfCustomizationPackage = s.idfCustomizationPackage	
			on s.idfOffice = o.idfOffice
			
			inner join tflSiteGroup tsg_cent 
			on tsg_cent.idfsCentralSite = s.idfsSite
			and tsg_cent.idfsRayon is null
			and tsg_cent.intRowStatus = 0	
			
			inner join tflSiteToSiteGroup tstsg
			on tstsg.idfSiteGroup = tsg_cent.idfSiteGroup
			
			inner join tstSite ts
			on ts.idfsSite = tstsg.idfsSite
			
			inner join tlbOffice os
			on os.idfOffice = ts.idfOffice
			and os.intRowStatus = 0
			
			inner join tlbGeoLocationShared ogl
			on ogl.idfGeoLocationShared = o.idfLocation
			
			inner join report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) osr
			on osr.idfsRayon = ogl.idfsRayon
			and ogl.intRowStatus = 0				
			
			left join @FilteredRayons fr2 
			on	osr.idfsRayon = fr2.idfsRayon
		where fr2.idfsRayon is null
	end	

	-- Get statictics for Rayon-region
	insert into @RayonsForStatistics (idfsRayon)
	select r.idfsRayon  from report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r
	where (
		  idfsRayon = @RayonID  or
		  idfsRayon in (select br.idfsRayon	from @BorderRayons br)
		  ) 
		  and 
		  (
		  	@idfsSiteType  in (10085001, 10085002) --sitCDR, sitEMS
			or 
			@isWeb = 1
			or		
			idfsRayon in (select idfsRayon from @FilteredRayons)
		  )
		  and intRowStatus = 0
				

	-- определяем для района максимальный год (меньший или равный отчетному году), за который есть статистика.
	update rfstat set
	   rfstat.maxYear = mrfs.maxYear
	from @RayonsForStatistics rfstat
	inner join (
		select MAX(year(stat.datStatisticStartDate)) as maxYear, rfs.idfsRayon
		from @RayonsForStatistics  rfs    
		  inner join dbo.tlbStatistic stat
		  on stat.idfsArea = rfs.idfsRayon 
		  and stat.intRowStatus = 0
		  and stat.idfsStatisticDataType = @idfsStatType_Population
		  and year(stat.datStatisticStartDate) <= @Year
		group by rfs.idfsRayon
		) as mrfs
		on rfstat.idfsRayon = mrfs.idfsRayon

	                                      	
	-- определяем статистику для каждого района
	update rfsu set
		rfsu.intPopulation = s.sumValue
	from @RayonsForStatistics rfsu
		inner join (select SUM(cast(varValue as int)) as sumValue, rfs.idfsRayon
			from dbo.tlbStatistic s
			  inner join @RayonsForStatistics rfs
			  on rfs.idfsRayon = s.idfsArea and
				 s.intRowStatus = 0 and
				 s.idfsStatisticDataType = @idfsStatType_Population and
				 s.datStatisticStartDate = cast(rfs.maxYear as varchar(4)) + '-01-01' 
			group by rfs.idfsRayon ) as s
		on rfsu.idfsRayon = s.idfsRayon
	
	-- end of get statistics
end --if @Counter > 1 begin	   
   
   	
if OBJECT_ID('tempdb.dbo.#ReportTable') is not null 
drop table #ReportTable

create table #ReportTable
(	id int not null identity(1,1) primary key,
	idfsRayon bigint not null,
	idfsDiagnosis bigint foreign key references trtDiagnosis(idfsDiagnosis),
	intTotal  int not null
)

if exists (select * from #Diagnosis)
	insert into #ReportTable (idfsRayon, idfsDiagnosis, intTotal)
	select 
		r.idfsRayon,
		d.idfsDiagnosis,
		0
	from (
		select gr.idfsRayon
		from report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) gr
		where gr.idfsRayon = @RayonID
		union
		select br.idfsRayon
		from @BorderRayons br
	) r
	cross join #Diagnosis d
else	   
	insert into #ReportTable (idfsRayon, idfsDiagnosis, intTotal)
	select 
		r.idfsRayon,
		null,
		0
	from (
		select gr.idfsRayon
		from report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) gr
		where gr.idfsRayon = @RayonID
		union
		select br.idfsRayon
		from @BorderRayons br
	) r	   
	   

		   
declare 
	@idfsRegion bigint, 
	@idfsRayon	bigint	   
	
declare cur cursor for
select distinct gr.idfsRegion, rt.idfsRayon
from #ReportTable rt
	inner join report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) gr
	on gr.idfsRayon = rt.idfsRayon

open cur

fetch next from cur into @idfsRegion, @idfsRayon

while @@FETCH_STATUS = 0 
begin	   
	exec [spRepHumBorderRayonsComparativeReport_Calculations] @StartDate, @FinishDate, @idfsRegion, @idfsRayon
	fetch next from cur into @idfsRegion, @idfsRayon
end

close cur
deallocate cur		   
   


insert into #ReportDiagnosisTable (strKey, idfsRayon, intCounter, intCounterValue,  strRayonName, blnTotalVisible, intRowNum, idfsDiagnosis, strDiagnosis, strIDCCode, dblValue)
select cast(rayon.idfsRayon as varchar) + '_' + cast(c.intCounter as varchar), rayon.idfsRayon, c.intCounter, c.intCounterValue, rf_rayon.name, @blnTotalVisible, rayon.intRowNum
		,dg1.idfsDiagnosis, dg1.strDiagnosisName, dg1.strIDC10, rt1.intTotal
from
	(
		select gr.idfsRayon, -1 as intRowNum
		from report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) gr
		where gr.idfsRayon = @RayonID
		union
		select br.idfsRayon, 0 as intRowNum
		from @BorderRayons br
	) as rayon
	inner join dbo.fnGisReference(@LangID, 19000002) rf_rayon
	on rf_rayon.idfsReference = rayon.idfsRayon
	
	cross join @Counters c
	
		inner join #ReportTable rt1 on rt1.idfsRayon = rayon.idfsRayon 
		left join #Diagnosis dg1 on dg1.idfsDiagnosis = rt1.idfsDiagnosis --and dg1.intRowNum = 1	
order by dg1.intRowNum,rayon.intRowNum	


update rdt set
	rdt.dblTotal = rt_total.intTotal
from  #ReportDiagnosisTable rdt
	inner join #ReportTable rt_total
		on rdt.idfsRayon = rt_total.idfsRayon
		and rt_total.idfsDiagnosis is null
		

update rdt set
	rdt.dblTotal =rdtTotal.dblValueTotal
from  #ReportDiagnosisTable rdt
inner join #ReportTable rt1 on rt1.idfsRayon = rdt.idfsRayon
inner join (SELECT rdt1.idfsRayon,SUM(isnull(rdt1.dblValue,0)) + MAX(isnull(rdt1.dblTotal, 0)) dblValueTotal
				--isnull(rdt.dblValue_1, 0) + 
				--isnull(rdt.dblValue_2, 0) + 
				--isnull(rdt.dblValue_3, 0) + 
				--isnull(rdt.dblValue_4, 0) + 
				--isnull(rdt.dblValue_5, 0) + 
				--isnull(rdt.dblValue_6, 0) + 
				--isnull(rdt.dblValue_7, 0) +
				--isnull(rdt.dblValue_8, 0) + 
				--isnull(rdt.dblValue_9, 0) + 
				--isnull(rdt.dblValue_10, 0) + 
				--isnull(rdt.dblValue_11, 0) + 
				--isnull(rdt.dblValue_12, 0) +  
				--isnull(rdt.dblTotal, 0)
from  #ReportDiagnosisTable rdt1
group by rdt1.idfsRayon,rdt1.intCounter) rdtTotal on rdtTotal.idfsRayon=rdt.idfsRayon

			
---- + total bottom            
--insert into #ReportDiagnosisTable (strKey, intCounter, intCounterValue, idfsRayon, strRayonName, 
--			idfsDiagnosis_1, strDiagnosis_1, strIDCCode_1, dblValue_1, 
--			idfsDiagnosis_2, strDiagnosis_2, strIDCCode_2, dblValue_2, 
--			idfsDiagnosis_3, strDiagnosis_3, strIDCCode_3, dblValue_3, 
--			idfsDiagnosis_4, strDiagnosis_4, strIDCCode_4, dblValue_4, 
--			idfsDiagnosis_5, strDiagnosis_5, strIDCCode_5, dblValue_5, 
--			idfsDiagnosis_6, strDiagnosis_6, strIDCCode_6, dblValue_6, 
--			idfsDiagnosis_7, strDiagnosis_7, strIDCCode_7, dblValue_7, 
--			idfsDiagnosis_8, strDiagnosis_8, strIDCCode_8, dblValue_8,
--			idfsDiagnosis_9, strDiagnosis_9, strIDCCode_9, dblValue_9,
--			idfsDiagnosis_10, strDiagnosis_10, strIDCCode_10, dblValue_10,
--			idfsDiagnosis_11, strDiagnosis_11, strIDCCode_11, dblValue_11,
--			idfsDiagnosis_12, strDiagnosis_12, strIDCCode_12, dblValue_12,
--			dblTotal, blnTotalVisible, intRowNum)
--select  '-1_' + cast(intCounter as varchar), intCounter, intCounterValue, -1, '',
--		idfsDiagnosis_1, strDiagnosis_1, strIDCCode_1, sum(dblValue_1),
--		idfsDiagnosis_2, strDiagnosis_2, strIDCCode_2, sum(dblValue_2), 
--		idfsDiagnosis_3, strDiagnosis_3, strIDCCode_3, sum(dblValue_3), 
--		idfsDiagnosis_4, strDiagnosis_4, strIDCCode_4, sum(dblValue_4), 
--		idfsDiagnosis_5, strDiagnosis_5, strIDCCode_5, sum(dblValue_5), 
--		idfsDiagnosis_6, strDiagnosis_6, strIDCCode_6, sum(dblValue_6), 
--		idfsDiagnosis_7, strDiagnosis_7, strIDCCode_7, sum(dblValue_7), 
--		idfsDiagnosis_8, strDiagnosis_8, strIDCCode_8, sum(dblValue_8),
--		idfsDiagnosis_9, strDiagnosis_9, strIDCCode_9, sum(dblValue_9),
--		idfsDiagnosis_10, strDiagnosis_10, strIDCCode_10, sum(dblValue_10),
--		idfsDiagnosis_11, strDiagnosis_11, strIDCCode_11, sum(dblValue_11),
--		idfsDiagnosis_12, strDiagnosis_12, strIDCCode_12, sum(dblValue_12),
--		sum(dblTotal), @blnTotalVisible, 999
--from #ReportDiagnosisTable		
--group by 
--			idfsDiagnosis_1, strDiagnosis_1, strIDCCode_1,
--			idfsDiagnosis_2, strDiagnosis_2, strIDCCode_2, 
--			idfsDiagnosis_3, strDiagnosis_3, strIDCCode_3, 
--			idfsDiagnosis_4, strDiagnosis_4, strIDCCode_4, 
--			idfsDiagnosis_5, strDiagnosis_5, strIDCCode_5,
--			idfsDiagnosis_6, strDiagnosis_6, strIDCCode_6, 
--			idfsDiagnosis_7, strDiagnosis_7, strIDCCode_7, 
--			idfsDiagnosis_8, strDiagnosis_8, strIDCCode_8, 
--			idfsDiagnosis_9, strDiagnosis_9, strIDCCode_9, 
--			idfsDiagnosis_10, strDiagnosis_10, strIDCCode_10, 
--			idfsDiagnosis_11, strDiagnosis_11, strIDCCode_11, 
--			idfsDiagnosis_12, strDiagnosis_12, strIDCCode_12,
--			intCounter, intCounterValue


--	update rt set 
--		rt.dblValue_1 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_1 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_2 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_2 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_3 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_3 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_4 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_4 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_5 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_5 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_6 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_6 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_7 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_7 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_8 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_8 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_9 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_9 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_10 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_10 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_11 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_11 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblValue_12 = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue_12 / rfs.intPopulation) * rt.intCounterValue end,
--		rt.dblTotal   = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblTotal   / rfs.intPopulation) * rt.intCounterValue end
--	from #ReportDiagnosisTable rt
--		inner join @RayonsForStatistics rfs
--		on rfs.idfsRayon = rt.idfsRayon
--	where rt.intCounter > 1
	update rt set 
		rt.dblValue = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblValue / rfs.intPopulation) * rt.intCounterValue end,
		rt.dblTotal   = case isnull(rfs.intPopulation, 0) when 0 then null else (rt.dblTotal   / rfs.intPopulation) * rt.intCounterValue end
	from #ReportDiagnosisTable rt
		inner join @RayonsForStatistics rfs
		on rfs.idfsRayon = rt.idfsRayon
	where rt.intCounter > 1
		
--	-- total bottom
--	update rt set
--		rt.dblValue_1 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_1 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_2 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_2 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_3 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_3 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_4 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_4 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_5 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_5 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_6 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_6 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_7 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_7 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_8 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_8 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_9 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_9 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_10 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_10 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_11 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_11 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblValue_12 = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblValue_12 / rfs.sum_Population) * rt.intCounterValue end,
--		rt.dblTotal   = case isnull(rfs.sum_Population, 0) when 0 then null else (rt.dblTotal   / rfs.sum_Population) * rt.intCounterValue end
--	from #ReportDiagnosisTable rt	
--		cross join (
--			select sum(rfs_s.intPopulation) as sum_Population
--			from @RayonsForStatistics rfs_s
--		) as rfs
--	where rt.idfsRayon = -1
--	and rt.intCounter > 1



   
 	select * from #ReportDiagnosisTable
 	order by intRowNum, strRayonName,  intCounter

 
 END

	

