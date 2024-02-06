
--##SUMMARY   
  
--##REMARKS Author: Romasheva S.  
--##REMARKS Create date: 05.09.2013  
  
--##RETURNS Don't use   
  
/*  
--Example of a call of procedure:  
  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2011, 2016, '1',  null, null, null  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2014, 2015, '2',  null, null, null  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2012, 2015, '1',  null, null, null  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2012, 2013, '1,2',  null, null, null  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2014, 2016, '1,2',  null, 1344330000000 /*Baku*/, 1344390000000 /*Nizami (Baku)*/  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2015, 2016, '1,2',  null, 10300053, 867  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2015, 2016, '2',  null, 10300053, null  
  
test 1  
 Region (blank)  
 Rayon (blank)  
 From 2015  
 To 2014  
 Diagnosis Brucellosis  
 Entered by Organization (blank)  
 Generate report on site Republican APS  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2014, 2015, '1',  7718730000000, null, null  
  
test 2  
 Region (blank)  
 Rayon (blank)  
 From 2015  
 To 2014  
 Diagnosis Brucellosis  
 Entered by Organization Water Transport CHE  
 Generate report on site Republican APS  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2014, 2015, '1',  7718730000000, 10300053, 869  
  
test 3  
 Region Other rayons  
 Rayon (blank)  
 From 2015  
 To 2014  
 Diagnosis Acute Respiratory Infections  
 Entered by Organization (blank)  
 Generate report on site Republican APS  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2014, 2015, '1',  7718080000000, 1344340000000, null  
  
--test 4  
-- Region Other rayons  
-- Rayon Zagatala  
-- From 2015  
-- To 2014  
-- Diagnosis (blank)  
-- Entered by Organization (blank)  
-- Generate report on site Republican APS  
exec report.USP_REP_HUM_ComparativeTwoYears 'en', 2015, 2016, '1,2',  null, 1344340000000, 1344790000000  
*/   
   
CREATE PROCEDURE [Report].[USP_REP_HUM_ComparativeTwoYears]  
 @LangID		as varchar(36),  
 @FirstYear		as int,   
 @SecondYear	as int,   
 @strCounter	as nvarchar(max),  -- 1 = Absolute number, 2 = For 10.000 population, 3 = For 100.000 population, 4 = For 1.000.000 population  
 @DiagnosisID	as bigint = null,  
 @RegionID		as bigint = null,  
 @RayonID		as bigint = null,  
 @SiteID		as bigint = null  
AS  
BEGIN  
  
declare @ReportTable table  
(strKey varchar(200) not null primary key   -- let it be intYear + '_' + intCounter  
 , intYear int not null   
 , intCounter int not null   
 , intCounterValue int not null  
 , intJanuary float not null   
 , intFebruary float not null   
 , intMarch float not null   
 , intApril float not null   
 , intMay float not null   
 , intJune float not null   
 , intJuly float not null   
 , intAugust float not null   
 , intSeptember float not null   
 , intOctober float not null   
 , intNovember float not null   
 , intDecember float not null   
 , intTotal float not null  
   
)  
   
 declare  
  @idfsLanguage bigint,  
  @CountryID bigint,  
  @idfsSite bigint,  
  @idfsSiteType bigint,  
    
  @StartDate datetime,    
  @FinishDate datetime,  
  
    
  @isWeb bigint,  
  @idfsStatType_Population bigint,  
    
  @iCounter int,  
    
   @TransportCHE bigint  
   
  
 declare  @Counters table(  
  intCounter int primary key,  
  intCounterValue numeric(10,2) not null  
 )  
  
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
  
  
 --declare @FilteredRayons table  
 --(idfsRayon bigint primary key)  
   
 declare @Years table (  
  intYear int primary key,  
  StatisticsForYear int  
 )  
 declare @intYear int  
 set @intYear = @FirstYear  
   
 while @intYear <= @SecondYear  
 begin  
  insert into @Years(intYear) values(@intYear)  
  set @intYear = @intYear + 1  
 end  
   
  
 declare @RayonsForStatistics table  
 (idfsRayon bigint,  
  maxYear int,  
  intYear int,  
  primary key (idfsRayon, intYear)  
 )   
  
    
 SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET (@LangID)   
    
    
 set @CountryID = 170000000  
   
 set @idfsSite = ISNULL(@SiteID, dbo.fnSiteID())  
    
 --select @isWeb = isnull(ts.blnIsWEB, 0)   
 --from tstSite ts  
 --join tstLocalSiteOptions lso  
 --on lso.strName = N'SiteID'  
 -- and lso.strValue = cast(ts.idfsSite as nvarchar(20))  
   
 --select @idfsSiteType = ts.idfsSiteType  
 --from tstSite ts  
 --join tstLocalSiteOptions lso  
 --on lso.strName = N'SiteID'  
 -- and lso.strValue = cast(ts.idfsSite as nvarchar(20))  
 --if @idfsSiteType is null set @idfsSiteType = 10085001   
   
 --set @idfsStatType_Population = 39850000000  -- Population  
 select @idfsStatType_Population = tbra.idfsBaseReference  
 from trtBaseReferenceAttribute tbra  
  inner join trtAttributeType at  
  on   at.strAttributeTypeName = N'Statistical Data Type'  
 where cast(tbra.varValue as nvarchar(100)) = N'Population'  
   
 select @TransportCHE = frr.idfsReference  
  from dbo.FN_GBL_GIS_ReferenceRepair('en', 19000020) frr  
  where frr.name =  'Transport CHE'  
  print @TransportCHE  
    
if exists (select * from @Counters c where c.intCounter > 1) -- 1 = Absolute number  
begin  
  
 -- Get statictics for Rayon-region  
 insert into @RayonsForStatistics (idfsRayon, intYear)  
 select r.idfsRayon, y.intYear  from report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) r  
  cross join @Years y  
 where (  
    idfsRayon = @RayonID or  
    (idfsRegion = @RegionID and @RayonID is null) or  
    (idfsCountry = @CountryID and @RayonID is null and @RegionID is null) or  
    (idfsCountry = @CountryID and @RegionID = @TransportCHE)  
    )   
   -- and   
   -- (  
   --  @idfsSiteType  in (10085001, 10085002) --sitCDR, sitEMS  
   --or   
   --@isWeb = 1  
   --or    
   --idfsRayon in (select idfsRayon from @FilteredRayons)  
   -- )  
    and intRowStatus = 0  
      
 -- for each year  
 -- определяем для района максимальный год (меньший или равный отчетному году), за который есть статистика.  
 update rfstat set  
    rfstat.maxYear = mrfs.maxYear  
 from @RayonsForStatistics rfstat  
 inner join (  
  select MAX(year(stat.datStatisticStartDate)) as maxYear, rfs.idfsRayon, rfs.intYear  
  from @RayonsForStatistics  rfs      
    inner join dbo.tlbStatistic stat  
    on stat.idfsArea = rfs.idfsRayon   
    and stat.intRowStatus = 0  
    and stat.idfsStatisticDataType = @idfsStatType_Population  
    and year(stat.datStatisticStartDate) <= rfs.intYear  
  group by  rfs.intYear, rfs.idfsRayon  
  ) as mrfs  
  on rfstat.idfsRayon = mrfs.idfsRayon  
  and rfstat.intYear = mrfs.intYear  
                                          
 --если статистика есть по каждому району, то суммируем ее.   
 --Иначе считаем статистику не полной и вообще не считаем для данного года-региона  
 update y set  
  y.StatisticsForYear = s.sumValue  
 from @Years y  
  inner join (select SUM(cast(varValue as int)) as sumValue, rfs.intYear  
   from dbo.tlbStatistic s  
     inner join @RayonsForStatistics rfs  
     on rfs.idfsRayon = s.idfsArea and  
     s.intRowStatus = 0 and  
     s.idfsStatisticDataType = @idfsStatType_Population and  
     s.datStatisticStartDate = cast(rfs.maxYear as varchar(4)) + '-01-01'   
   group by rfs.intYear ) as s  
  on s.intYear = y.intYear  
    
  outer apply (  
   select top 1 rfs.intYear  
   from @RayonsForStatistics rfs  
   where rfs.maxYear is null  
   and y.intYear = rfs.intYear  
  ) as oa  
 where oa.intYear is null  
   
 --select * from @Years  
 -- end of get statistics  
end --if @Counter > 1 begin   
   
   
   
if OBJECT_ID('tempdb.dbo.#ReportTable') is not null   
drop table #ReportTable  
  
     
create table #ReportTable  
( intYear   int not null,  
 intMonth  int not null,  
 intTotal  int not null,  
 primary key (intYear, intMonth)  
)  
  
declare @month table (intMonth int primary key)  
  
insert into @month (intMonth) values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)  
  
insert into #ReportTable (intYear, intMonth, intTotal)  
select y.intYear, m.intMonth, 0  
from @Years y  
 cross join @month m  
  
 
declare cur cursor local forward_only for   
select y.intYear  
from @Years y  
  
open cur  
  
fetch next from cur into @intYear  
  
while @@FETCH_STATUS = 0  
begin   
 set @StartDate = (CAST(@intYear AS VARCHAR(4)) + '01' + '01')  
 set @FinishDate = dateADD(yyyy, 1, @StartDate)  
   
 exec [report].[USP_REP_HUM_ComparativeTwoYears_Calculations] @CountryID, @StartDate, @FinishDate, @RegionID, @RayonID, @DiagnosisID  
  
 fetch next from cur into @intYear  
end   
  
--SELECT * FROM #ReportTable
   
insert into @ReportTable   
(     
   strKey  
 , intYear  
 , intCounter  
 , intCounterValue  
 , intJanuary   
 , intFebruary   
 , intMarch  
 , intApril   
 , intMay  
 , intJune   
 , intJuly  
 , intAugust  
 , intSeptember  
 , intOctober  
 , intNovember  
 , intDecember  
 , intTotal   
)  
select   
 cast(intYear as varchar(10)) + '_' + cast(intCounter as varchar(10))  
 , intYear  
 , intCounter  
 , intCounterValue  
 , [1] as intJanuary   
 , [2] as intFebruary   
 , [3] as intMarch  
 , [4] as intApril   
 , [5] as intMay  
 , [6] as intJune   
 , [7] as intJuly  
 , [8] as intAugust  
 , [9] as intSeptember  
 , [10] as intOctober  
 , [11] as intNovember  
 , [12] as intDecember  
 , [1]+ [2]+ [3]+ [4]+ [5]+ [6]+ [7]+ [8]+ [9]+ [10]+ [11]+ [12]  

from   
 (   
  select rt.intYear, intMonth, intTotal, c.intCounter, c.intCounterValue  
  from #ReportTable rt  
   cross join @Counters c  
 ) as p  
 pivot  
 (   
  sum(intTotal)  
  for intMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])  
 ) as pvt  
 order by intYear  


 update rt set   
  intJanuary = case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intJanuary / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intFebruary = case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intFebruary / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intMarch =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intMarch / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intApril =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intApril / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intMay =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intMay / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intJune =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intJune / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intJuly =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intJuly / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intAugust =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intAugust / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intSeptember = case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intSeptember / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intOctober = case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intOctober / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intNovember = case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intNovember / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intDecember = case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intDecember / y.StatisticsForYear) * rt.intCounterValue,2) end,  
  intTotal =  case isnull(y.StatisticsForYear, 0) when 0 then 0 else ROUND((intTotal / y.StatisticsForYear) * rt.intCounterValue,2) end  
 from @ReportTable rt  
  inner join @Years y  
   on rt.intYear = y.intYear  
 where rt.intCounter > 1  


 select * from @ReportTable  
  
END  
   
   
