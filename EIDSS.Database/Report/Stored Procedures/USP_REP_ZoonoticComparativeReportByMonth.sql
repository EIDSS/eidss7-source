
--*************************************************************************
-- Name 				: report.USP_REP_ZoonoticComparativeReportByMonth
-- DescriptiON			: Zoonotic Comparative Report (by months).
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code: 
/* 
Implement rules for retrieving data into the Zoonotic Comparative Report (by months) according to the specification:
Example of a call of procedure:   7718570000000 Botulism  
										  7718730000000 Brucellosis  
										  7719840000000 Influenza - Avian (HPAI; H5N1)  
										  7720660000000 Rabies --baku 
										    
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2020, 1344330000000, 1344360000000, 7718730000000   
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2014, 1344330000000, null, 7718730000000   
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2014, 1344330000000, null, null    
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2014, 1344330000000, 1344360000000, 7720660000000  --other regions    
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2015, 1344340000000, 1344800000000, 7718730000000    
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2015, 1344340000000, null, 7718730000000  --republic  
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2015, null, null, 7718730000000 
exec report.USP_REP_ZoonoticComparativeReportByMonth 'ru', 2015, null, null, 7718730000000 
exec report.USP_REP_ZoonoticComparativeReportByMonth 'az-l', 2015, null, null, 7718730000000     
exec report.USP_REP_ZoonoticComparativeReportByMonth 'az-l', 2015, null, null, 7720660000000 --  Rabies 
exec report.USP_REP_ZoonoticComparativeReportByMonth 'az-l', 2015, null, null, null      
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2015, 1344330000000, 1344360000000, 7718570000000 --Botulism  
exec report.USP_REP_ZoonoticComparativeReportByMonth 'en', 2015, 1344330000000, 1344360000000, 56409380000000 --Group {Intestinal disease} with only one diagnosis {Botulism} 
exec spZoonoticDiagnosesAndGroups_SelectLookup 'en' 
*/ 

CREATE PROCEDURE [Report].[USP_REP_ZoonoticComparativeReportByMonth]  
					(@LangID as varchar(36), 
					@Year as int, 
					@idfsRegion as bigint, 
					@idfsRayon as bigint, 
					@idfsDiagnosis as bigint, 
					@SiteID as bigint = null)   
AS   
BEGIN    
declare @ReportTable table 
						(  
						intDataType    int not null, --primary key, -- 1 - human, 2 - animal    
						strAdministrativeUnit nvarchar(2000), 
						strDataType    nvarchar(200),   
						idfsRegion    bigint,  
						idfsRayon    bigint,     
						idfsDiagnosis   bigint,  
						intMonth int not null,   
						intCases int not null
						)   
declare @MonthTable table 
						(  
						intMonth int not null
						)   
										 					 
declare @idfsLanguage bigint,    
			@CountryID bigint,    
			@idfsSite bigint,  
			@StartDate datetime,  
			@FinishDate datetime,    
			@strRepublic nvarchar(200),    
			@idfsRegionBaku bigint,    
			@idfsRegionOtherRayons bigint,    
			@strAdministrativeUnit nvarchar(2000),    
			@strDataType_human nvarchar(200),    
			@strDataType_animal nvarchar(200) 
			
set @idfsLanguage = dbo.fnGetLanguageCode (@LangID)  
set @CountryID = 170000000  
set @idfsSite = ISNULL(@SiteID, dbo.fnSiteID())  
set @StartDate = cast(@Year as varchar) + '0101'  
set @FinishDate = dateadd(year, 1, @StartDate)  --1344340000000 --Other rayons   

select @idfsRegionOtherRayons = tbra.idfsGISBaseReference   
from trtGISBaseReferenceAttribute tbra    
inner join trtAttributeType at    
on at.strAttributeTypeName = N'AZ Region'   
where cast(tbra.varValue as nvarchar(100)) = N'Other rayons'     --1344330000000 --Baku   

select @idfsRegionBaku = tbra.idfsGISBaseReference   
from trtGISBaseReferenceAttribute tbra    
inner join trtAttributeType at    
on at.strAttributeTypeName = N'AZ Region'   
where cast(tbra.varValue as nvarchar(100)) = N'Baku'  --@strRepublic   

select @strRepublic = tsnt.strTextString    
from trtBaseReference tbr  
inner join trtStringNameTranslation tsnt 
on tsnt.idfsBaseReference = tbr.idfsBaseReference and tsnt.idfsLanguage = @idfsLanguage    
where tbr.idfsReferenceType = 19000132 --additional report text 
		and tbr.strDefault = 'Republic'  
	  
select @strDataType_human = tsnt.strTextString    
from trtBaseReference tbr  
inner join trtStringNameTranslation tsnt 
on tsnt.idfsBaseReference = tbr.idfsBaseReference 
and tsnt.idfsLanguage = @idfsLanguage    
where tbr.idfsReferenceType = 19000132 --additional report text   
		and tbr.strDefault = 'Among humans' 

select @strDataType_animal = tsnt.strTextString    
from trtBaseReference tbr  
inner join trtStringNameTranslation tsnt 
on tsnt.idfsBaseReference = tbr.idfsBaseReference 
and tsnt.idfsLanguage = @idfsLanguage    
where tbr.idfsReferenceType = 19000132 --additional report text   
		and tbr.strDefault = 'Among animals'   
		
set @strRepublic = isnull(@strRepublic, 'Republic')   
SET @strAdministrativeUnit =   case when @idfsRegion is null and @idfsRayon is null then  @strRepublic     
									when @idfsRayon is null and @idfsRegion is not null then (select [name] from fnGisReference(@LangID, 19000003) --rftRegion
																								where idfsReference = @idfsRegion)     
									when @idfsRayon is not null and @idfsRegion = @idfsRegionOtherRayons then (select [name] from fnGisReference(@LangID, 19000002)--rftRayon
																												where idfsReference = @idfsRayon)     
									when @idfsRayon is not null and @idfsRegion = @idfsRegionBaku then (select [name] from fnGisReference(@LangID, 19000003) --rftRegion
																										where idfsReference = @idfsRegion) + ', ' + 
																										(select [name] from fnGisReference(@LangID, 19000002) --rftRayon
																										where idfsReference = @idfsRayon)     
									else (select [name] from fnGisReference(@LangID, 19000002 ) --rftRayon
											where idfsReference = @idfsRayon)+ ', ' + 
										  (select [name] from fnGisReference(@LangID, 19000003) --rftRegion
											where idfsReference = @idfsRegion)    
							   end  

insert into @MonthTable(intMonth)
select * 
from
(
select 1 as intMonth
union all
select 2 as intMonth
union all
select 3 as intMonth
union all
select 4 as intMonth
union all
select 5 as intMonth
union all
select 6 as intMonth
union all
select 7 as intMonth
union all
select 8 as intMonth
union all
select 9 as intMonth
union all
select 10 as intMonth
union all
select 11 as intMonth
union all
select 12 as intMonth
) A

--Human Cases
insert into @ReportTable(intDataType, strDataType, strAdministrativeUnit, idfsRegion, idfsRayon, idfsDiagnosis, intMonth, intCases)  
select 1, @strDataType_human, @strAdministrativeUnit, @idfsRegion, @idfsRayon, @idfsDiagnosis,month(hc.datFinalCaseClassificationDate), count(hc.idfHumanCase)   
from tlbHumanCase hc    
inner join tlbHuman h 
left outer join tlbGeoLocation gl 
on h.idfCurrentResidenceAddress = gl.idfGeoLocation   
			and gl.intRowStatus = 0 
on hc.idfHuman = h.idfHuman  
			and h.intRowStatus = 0    
inner join trtDiagnosis td 
left join trtDiagnosisToDiagnosisGroup tdtdg 
on tdtdg.idfsDiagnosis = td.idfsDiagnosis 
			and tdtdg.intRowStatus = 0   
on td.idfsDiagnosis = isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) and td.intRowStatus = 0 and td.blnZoonotic = 1 and td.idfsUsingType = 10020001 and (td.idfsDiagnosis = @idfsDiagnosis or tdtdg.idfsDiagnosisGroup = @idfsDiagnosis or @idfsDiagnosis is null)    
left join tstSite ts    
on ts.idfsSite = hc.idfsSite 
	and ts.intRowStatus = 0 and ts.intFlags = 1    
where hc.datFinalCaseClassificationDate is not null  
		and (@StartDate <= hc.datFinalCaseClassificationDate 
		and hc.datFinalCaseClassificationDate < @FinishDate ) 
		and (gl.idfsRegion = @idfsRegion or @idfsRegion is null) 
		and (gl.idfsRayon = @idfsRayon or @idfsRayon is null) 
		and hc.intRowStatus = 0 
		and hc.idfsFinalCaseStatus = 350000000 --Confirmed Case
		and ts.idfsSite is null      
group by month(hc.datFinalCaseClassificationDate)     

--Insert missing months
insert into @ReportTable(intDataType, strDataType, strAdministrativeUnit, idfsRegion, idfsRayon, idfsDiagnosis, intMonth, intCases)  
select 1, @strDataType_human, @strAdministrativeUnit, @idfsRegion, @idfsRayon, @idfsDiagnosis, m.intMonth, 0
from @MonthTable m 
left join @ReportTable rt on rt.intMonth=m.intMonth
where rt.intMonth is null

--Total vet Cases ( Vet and ASSessions Cases)
insert into @ReportTable(intDataType, strDataType, strAdministrativeUnit, idfsRegion, idfsRayon, idfsDiagnosis, intMonth, intCases)    
select 2, @strDataType_animal, @strAdministrativeUnit, @idfsRegion, @idfsRayon, @idfsDiagnosis,intMonth, Sum(intCases) as intCases
FROM
(
--Vet Cases
select month(vc.datFinalDiagnosisDate) as intMonth, sum(case when vc.idfsCaseType = 10012003 then isnull(f.intLivestockSickAnimalQty, 0) else 0 end) + sum(case when vc.idfsCaseType = 10012003 then isnull(f.intLivestockDeadAnimalQty, 0) else 0 end) + sum(case when vc.idfsCaseType = 10012004 then isnull(f.intAvianSickAnimalQty, 0) else 0 end) + sum(case when vc.idfsCaseType = 10012004 then isnull(f.intAvianDeadAnimalQty, 0) else 0 end) as intCases        
from tlbVetCase vc    
inner join tlbFarm f     
left join tlbGeoLocation gl     
on gl.idfGeoLocation = f.idfFarmAddress     
		and gl.intRowStatus = 0    
on f.idfFarm = vc.idfFarm        
inner join trtDiagnosis td     
left join trtDiagnosisToDiagnosisGroup tdtdg      
on tdtdg.idfsDiagnosis = td.idfsDiagnosis      
		and tdtdg.intRowStatus = 0    
on td.idfsDiagnosis = vc.idfsFinalDiagnosis    
		and td.intRowStatus = 0    
		and td.blnZoonotic = 1    
		and td.idfsUsingType = 10020001    
		and (td.idfsDiagnosis = @idfsDiagnosis or tdtdg.idfsDiagnosisGroup = @idfsDiagnosis or @idfsDiagnosis is null)        
where vc.idfsCaseClassification = 350000000 --Confirmed Case  
		and (@StartDate <= vc.datFinalDiagnosisDate        
		and vc.datFinalDiagnosisDate < @FinishDate)     
		and(gl.idfsRegion = @idfsRegion or @idfsRegion is null)    
		and (gl.idfsRayon = @idfsRayon or @idfsRayon is null)    
		and vc.intRowStatus = 0    
		and (vc.idfsCaseReportType = 4578940000002  --passive 
				or vc.idfParentMonitoringSession is null 
				and vc.idfsCaseReportType = 4578940000001 --active
			)    
		and (vc.idfsFinalDiagnosis = @idfsDiagnosis or tdtdg.idfsDiagnosisGroup = @idfsDiagnosis or @idfsDiagnosis is null)   
group by month(vc.datFinalDiagnosisDate)     
UNION ALL 
--ASSessions
select month(tt.datConcludedDate) as intMonth, count(animal.idfAnimal) as intCases  
from tlbMonitoringSession tms    
inner join tlbFarm farm    
on farm.idfMonitoringSession = tms.idfMonitoringSession and farm.intRowStatus = 0        
inner join tlbHerd herd on herd.idfFarm = farm.idfFarm and herd.intRowStatus = 0        
inner join tlbSpecies species on species.idfHerd = herd.idfHerd and species.intRowStatus = 0        
inner join tlbAnimal animal on animal.idfSpecies = species.idfSpecies and animal.intRowStatus = 0        
outer apply (select top 1 test.datConcludedDate         
			 from  tlbMaterial material         
			 inner join tlbTesting test           
			 inner join trtDiagnosis td            
			 left join trtDiagnosisToDiagnosisGroup tdtdg  
			 on tdtdg.idfsDiagnosis = td.idfsDiagnosis            
					and tdtdg.intRowStatus = 0 
			 on td.idfsDiagnosis = test.idfsDiagnosis           
					and td.intRowStatus = 0 and td.blnZoonotic = 1 and td.idfsUsingType = 10020001 
					and (td.idfsDiagnosis = @idfsDiagnosis or tdtdg.idfsDiagnosisGroup = @idfsDiagnosis or @idfsDiagnosis is null)         
			 on test.idfMaterial = material.idfMaterial          
				    and test.intRowStatus = 0          
				    and test.idfsTestStatus in (10001001,-- Final
												10001006 -- Amended
												)                 
inner join trtTestTypeToTestResult tttr         
on tttr.idfsTestName = test.idfsTestName  and tttr.idfsTestResult = test.idfsTestResult and tttr.blnIndicative = 1        
where material.idfAnimal = animal.idfAnimal and material.intRowStatus = 0 and test.datConcludedDate is not null        
order by test.datConcludedDate asc) tt       
where  (tms.idfsRegion = @idfsRegion or @idfsRegion is null)    
		and (tms.idfsRayon = @idfsRayon or @idfsRayon is null)      
		and tt.datConcludedDate is not null    
		and ( @StartDate <= tt.datConcludedDate and tt.datConcludedDate  < @FinishDate)    
group by month(tt.datConcludedDate) 	              
) A  
group by intMonth

SELECT  
		rt.intDataType,
		rt.strAdministrativeUnit,
		rt.strDataType,
		rt.idfsRegion,
		ref_region.name as strRegionName,
		rt.idfsRayon,
		ref_rayon.name as strRayonName,
		rt.idfsDiagnosis,
		isnull(ref_diagnosis.name, ref_diagnosis_group.name) as strDiagnosis,
		rt.intMonth,
		rt.intCases
from   @ReportTable rt 
				left join dbo.fnGisReference(@LangID, 19000003) ref_region    
							on ref_region.idfsReference = rt.idfsRegion    
				left join dbo.fnGisReference(@LangID, 19000002) ref_rayon    
							on ref_rayon.idfsReference = rt.idfsRayon    
				left join dbo.fnReference(@LangID, 19000019) ref_diagnosis    
							on rt.idfsDiagnosis = ref_diagnosis.idfsReference    
				left join dbo.fnReference(@LangID, 19000156) ref_diagnosis_group    
							on rt.idfsDiagnosis = ref_diagnosis_group.idfsReference 
order by rt.intDataType, rt.intMonth
   
drop table if exists #months
END 
