
--##SUMMARY Select data for WHO module in Georgia

--##REMARKS Author: Romasheva S.
--##REMARKS Create date: 29.10.2013
--##REMARKS Update date: 22.01.2018


--##RETURNS Doesn't use

/*
--Example of a call of procedure:


--GG
--Measles

exec report.USP_REP_HUM_WhoReport @LangID=N'en-US',@StartDate='20140101',@EndDate='20141231', @idfsDiagnosis = 9843460000000   

  
exec report.USP_REP_HUM_WhoReport @LangID=N'en-US',@StartDate='20130801',@EndDate='20130901', @idfsDiagnosis = 9843460000000   



*/

CREATE  Procedure [Report].[USP_REP_HUM_WhoReport]
 (
		@LangID		as nvarchar(50), 
		@StartDate datetime,
		@EndDate datetime,
		@idfsDiagnosis bigint
 )
AS	


begin


declare	@cmd	nvarchar(4000)

-- Drop temporary tables
if Object_ID('tempdb..#HumanCasesToExport') is not null
begin
set	@cmd = N'drop table #HumanCasesToExport'
execute sp_executesql @cmd
end

if Object_ID('tempdb..#FFToExport') is not null
begin
set	@cmd = N'drop table #FFToExport'
execute sp_executesql @cmd
end

if Object_ID('tempdb..#ResultTable') is not null
begin
set	@cmd = N'drop table #ResultTable'
execute sp_executesql @cmd
end

-- Create temporary tables
if Object_ID('tempdb..#HumanCasesToExport') is null
create table #HumanCasesToExport
(	idfHumanCase				bigint not null primary key,
	idfHuman					bigint not null,
	idfCRAddress				bigint null,
	idfsDiagnosis				bigint not null,
	idfCSObservation			bigint null,
	idfEpiObservation			bigint null,
	datDateOnset				datetime not null,
	idfOutbreak					bigint null,
	NumberOfReceivedDoses		nvarchar(50) collate Cyrillic_General_CI_AS null,
	DateOfLastVaccination		datetime null,
	Fever						bigint null,
	Cough						bigint null,
	Coryza						bigint null,  		
	Conjunctivitis				bigint null,  
	RashDuration				nvarchar(50) collate Cyrillic_General_CI_AS null,	
	SourceOfInfection			bigint null,   
	Complications				bigint null,    
	Encephalitis				bigint null,    
	Pneumonia					bigint null,    	
	Diarrhoea					bigint null,    
	Other						nvarchar(500) collate Cyrillic_General_CI_AS null,	
	datConcludedDate			datetime null,
	idfsSampleType				bigint null,
	datFieldCollectionDate		datetime null,
	idfsTestResult				bigint null,
	idfsTestStatus				bigint null,
	idfTesting					bigint null
)
delete from #HumanCasesToExport

if Object_ID('tempdb..#FFToExport') is null
create table #FFToExport
(	idfActivityParameters		bigint not null primary key,
	idfsParameter				bigint not null,
	idfObservation				bigint not null,
	idfRow						bigint not null,
	varValue					sql_variant null
)
delete from #FFToExport

if Object_ID('tempdb..#ResultTable') is null
create table	#ResultTable
(	  
	  idfCase					bigint not null primary key
	, strCaseID					nvarchar(300) collate database_default not null 
	, intAreaID					int not null 
	, datDRash					date null
	, intGenderID				int not null 
	, datDBirth					date null
	, intAgeAtRashOnset			int null
	, intNumOfVaccines			int null
	, datDvaccine				datetime null
	, datDNotification			datetime null
	, datDInvestigation			datetime null
	, intClinFever				int null
	, intClinCCC				int null
	, intClinRashDuration		int null
	, intClinOutcome			int null
	, intClinHospitalization	int null
	, intSrcInf					int null
	, intSrcOutbreakRelated		int null
	, strSrcOutbreakID			nvarchar(50) collate database_default null default null
	, intCompComplications		int null
	, intCompEncephalitis		int null
	, intCompPneumonia			int null
	, intCompMalnutrition		int null
	, intCompDiarrhoea			int null
	, intCompOther				int null
	, intFinalClassification	int null
	, datDSpecimen				datetime null
	, intSpecimen				int null
	, datDLabResult				datetime null
	, intMeaslesIgm				int null
	, intMeaslesVirusDetection	int null		
	, intRubellaIgm				int null
	, intRubellaVirusDetection	int null
	, strCommentsEpi			nvarchar(500) collate database_default null 
)
delete from #ResultTable

declare 
  
	@idfsSummaryReportType						bigint,
	
	
	@FFP_DateOfOnset_M				bigint,
	@FFP_DateOfOnset_R				bigint,  	
		
	@FFP_NumberOfReceivedDoses_M	bigint,
	@FFP_NumberOfReceivedDoses_R	bigint,  		
	
	@FFP_DateOfLastVaccination_M	bigint,
	@FFP_DateOfLastVaccination_R	bigint,  		
	
	@FFP_Fever_M					bigint,
	@FFP_Fever_R					bigint,  		
	
	@FFP_Cough_M					bigint,
	@FFP_Cough_R					bigint,  	
	
	@FFP_Coryza_M					bigint,
	@FFP_Coryza_R					bigint,  	  	
	
	@FFP_Conjunctivitis_M			bigint,
	@FFP_Conjunctivitis_R			bigint,  	   				
	
	@FFP_RashDuration_M				bigint,
	@FFP_RashDuration_R				bigint,  		
	
	@FFP_SourceOfInfection_M		bigint,
	@FFP_SourceOfInfection_R		bigint,  		
	
	@FFP_Complications_M			bigint,
	@FFP_Complications_R			bigint,  		

	@FFP_Encephalitis_M				bigint,
	@FFP_Encephalitis_R				bigint,  		
	  		
	@FFP_Pneumonia_M				bigint,
	@FFP_Pneumonia_R				bigint,  		
	  		  		
	@FFP_Diarrhoea_M				bigint,
	--@FFP_Diarrhoea_R				bigint,  		
	  		  		
	@FFP_Other_M					bigint,  		  		
	--@FFP_Other_R					bigint,  	 
	 		
	@idfsDiagnosis_Measles			bigint,
	@idfsDiagnosis_Rubella			bigint
	
			  	
SET @idfsSummaryReportType = 10290027 /*WHO Report - AJ&GG*/

--HCS FF - Rash onset date. / HCS FF- Date of onset
select @FFP_DateOfOnset_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_DateOfOnset_M'
and intRowStatus = 0

select @FFP_DateOfOnset_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_DateOfOnset_R'
and intRowStatus = 0
  
--HEI - Number of received doses (any vaccine with measles component) / HEI - Number of Measles vaccine doses received
select @FFP_NumberOfReceivedDoses_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_NumberOfReceivedDoses_M'
and intRowStatus = 0

select @FFP_NumberOfReceivedDoses_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_NumberOfReceivedDoses_R'
and intRowStatus = 0  	

--HEI - Date of last vaccination/HEI - Date of last Measles vaccine
select @FFP_DateOfLastVaccination_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_DateOfLastVaccination_M'
and intRowStatus = 0	

select @FFP_DateOfLastVaccination_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_DateOfLastVaccination_R'
and intRowStatus = 0	  
	
--HCS - Fever/HCS - Fever
select @FFP_Fever_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Fever_M'
and intRowStatus = 0

select @FFP_Fever_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Fever_R'
and intRowStatus = 0  	
	
--HCS - Cough / Coryza / Conjunctivitis /HCS - Cough / Coryza / Conjunctivitis
select @FFP_Cough_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Cough_M'
and intRowStatus = 0	

select @FFP_Cough_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Cough_R'
and intRowStatus = 0	 


select @FFP_Coryza_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Coryza_M'
and intRowStatus = 0	

select @FFP_Coryza_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Coryza_R'
and intRowStatus = 0	  	


select @FFP_Conjunctivitis_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Conjunctivitis_M'
and intRowStatus = 0	

select @FFP_Conjunctivitis_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Conjunctivitis_R'
and intRowStatus = 0	  	


--HCS - Rash duration / HCS - Duration (days)
select @FFP_RashDuration_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_RashDuration_M'
and intRowStatus = 0

select @FFP_RashDuration_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_RashDuration_R'
and intRowStatus = 0  	
	
--EPI - Source of infection / EPI - Source of infection
select @FFP_SourceOfInfection_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_SourceOfInfection_M'
and intRowStatus = 0		

select @FFP_SourceOfInfection_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_SourceOfInfection_R'
and intRowStatus = 0	  	

--HCS - Complications / HCS - Complications
select @FFP_Complications_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Complications_M'
and intRowStatus = 0		

select @FFP_Complications_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Complications_R'
and intRowStatus = 0		  

--HCS - Encephalitis / HCS - Encephalitis
select @FFP_Encephalitis_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Encephalitis_M'
and intRowStatus = 0		

select @FFP_Encephalitis_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Encephalitis_R'
and intRowStatus = 0	  	

--HCS - Pneumonia / HCS - Pneumonia
select @FFP_Pneumonia_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Pneumonia_M'
and intRowStatus = 0	

select @FFP_Pneumonia_R = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Pneumonia_R'
and intRowStatus = 0	  	
	
--HCS - Diarrhoea / HCS - Diarrhoea
select @FFP_Diarrhoea_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Diarrhoea_M'
and intRowStatus = 0		

--select @FFP_Diarrhoea_R = idfsFFObject from trtFFObjectForCustomReport
--where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Diarrhoea_R'
--and intRowStatus = 0		  	

--HCS - Other (specify) / HCS - Other
select @FFP_Other_M = idfsFFObject from trtFFObjectForCustomReport
where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Other_M'
and intRowStatus = 0	 

--select @FFP_Other_R = idfsFFObject from trtFFObjectForCustomReport
--where idfsCustomReportType = @idfsSummaryReportType and strFFObjectAlias = 'FFP_Other_R'
--and intRowStatus = 0	   	

 	
--idfsDiagnosis for:
--Measles
select top 1 @idfsDiagnosis_Measles = d.idfsDiagnosis
from trtDiagnosis d
  inner join dbo.trtDiagnosisToGroupForReportType dgrt
  on dgrt.idfsDiagnosis = d.idfsDiagnosis
  and dgrt.idfsCustomReportType = @idfsSummaryReportType
  
  inner join dbo.trtReportDiagnosisGroup dg
  on dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
  and dg.intRowStatus = 0 and dg.strDiagnosisGroupAlias = 'DG_Measles'
 where d.intRowStatus = 0

--Rubella
select top 1 @idfsDiagnosis_Rubella = d.idfsDiagnosis
from trtDiagnosis d
  inner join dbo.trtDiagnosisToGroupForReportType dgrt
  on dgrt.idfsDiagnosis = d.idfsDiagnosis
  and dgrt.idfsCustomReportType = @idfsSummaryReportType
  
  inner join dbo.trtReportDiagnosisGroup dg
  on dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
  and dg.intRowStatus = 0 and dg.strDiagnosisGroupAlias = 'DG_Rubella'
 where d.intRowStatus = 0	


 declare @AreaIDs table
 (
 intAreaID int,
 idfsRegion bigint
 )

insert into @AreaIDs (intAreaID, idfsRegion)
select		
cast(tgra.varValue as int), gr.idfsRegion
from trtGISBaseReferenceAttribute tgra
	inner join trtAttributeType tat
	on tat.idfAttributeType = tgra.idfAttributeType
	and tat.strAttributeTypeName = 'WHOrep_specific_gis_region'

	inner join gisRegion gr
	on gr.idfsRegion = tgra.idfsGISBaseReference

declare	@DateOnsetParameter bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@DateOnsetParameter = @FFP_DateOfOnset_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@DateOnsetParameter = @FFP_DateOfOnset_R

insert into	#HumanCasesToExport
(	idfHumanCase,
	idfHuman,
	idfCRAddress,
	idfsDiagnosis,
	idfCSObservation,
	idfEpiObservation,
	datDateOnset,
	idfOutbreak
)
select	hc.idfHumanCase,
		h.idfHuman,
		h.idfCurrentResidenceAddress,
		isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis),
		hc.idfCSObservation,
		hc.idfEpiObservation,
		coalesce(	
			case
				when	(cast(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') as nvarchar) like N'%date%') or
						(cast(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') as nvarchar) like N'%char%' and ISDATE(cast(ap_DateOfOnset.varValue as nvarchar)) = 1) 
					then dbo.FN_GBL_DATECUTTIME(cast(ap_DateOfOnset.varValue as datetime))
					else null
			end, hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate
			),
		hc.idfOutbreak
from tlbHumanCase hc

	inner join tlbHuman h
	on hc.idfHuman = h.idfHuman and  h.intRowStatus = 0	
	outer apply ( 
		select top 1 
			ap.varValue
		from tlbActivityParameters ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @DateOnsetParameter
			and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_DateOfOnset

where	
	hc.intRowStatus = 0
	and 	
	isnull(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @idfsDiagnosis 
	and
	coalesce(	
		case
			when	(cast(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') as nvarchar) like N'%date%') or
					(cast(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') as nvarchar) like N'%char%' and ISDATE(cast(ap_DateOfOnset.varValue as nvarchar)) = 1) 
				then dbo.FN_GBL_DATECUTTIME(cast(ap_DateOfOnset.varValue as datetime))
				else null
		end, hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate
			) >= @StartDate
	
	and
	coalesce(	
		case
			when	(cast(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') as nvarchar) like N'%date%') or
					(cast(SQL_VARIANT_PROPERTY(ap_DateOfOnset.varValue, 'BaseType') as nvarchar) like N'%char%' and ISDATE(cast(ap_DateOfOnset.varValue as nvarchar)) = 1) 
				then dbo.FN_GBL_DATECUTTIME(cast(ap_DateOfOnset.varValue as datetime))
				else null
		end, hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate
			) < @EndDate   			

insert into	#FFToExport
(	idfActivityParameters,
	idfsParameter,
	idfObservation,
	idfRow,
	varValue
)
select		ap.idfActivityParameters,
			ap.idfsParameter,
			ap.idfObservation,
			ap.idfRow,
			ap.varValue
from		tlbActivityParameters ap
inner join	#HumanCasesToExport hc_cs
on			hc_cs.idfCSObservation = ap.idfObservation
where		ap.intRowStatus = 0

insert into	#FFToExport
(	idfActivityParameters,
	idfsParameter,
	idfObservation,
	idfRow,
	varValue
)
select		ap.idfActivityParameters,
			ap.idfsParameter,
			ap.idfObservation,
			ap.idfRow,
			ap.varValue
from		tlbActivityParameters ap
inner join	#HumanCasesToExport hc_epi
on			hc_epi.idfEpiObservation = ap.idfObservation
left join	#HumanCasesToExport hc_cs
on			hc_cs.idfCSObservation = hc_epi.idfEpiObservation
where		ap.intRowStatus = 0
			and hc_cs.idfHumanCase is null


declare	@FFP_NumberOfReceivedDoses bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_NumberOfReceivedDoses = @FFP_NumberOfReceivedDoses_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_NumberOfReceivedDoses = @FFP_NumberOfReceivedDoses_R

declare	@FFP_DateOfLastVaccination bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_DateOfLastVaccination = @FFP_DateOfLastVaccination_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_DateOfLastVaccination = @FFP_DateOfLastVaccination_R
	
declare	@FFP_Fever bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Fever = @FFP_Fever_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Fever = @FFP_Fever_R

declare	@FFP_Cough bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Cough = @FFP_Cough_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Cough = @FFP_Cough_R
	
declare	@FFP_Coryza bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Coryza = @FFP_Coryza_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Coryza = @FFP_Coryza_R
	
declare	@FFP_Conjunctivitis bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Conjunctivitis = @FFP_Conjunctivitis_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Conjunctivitis = @FFP_Conjunctivitis_R
	
declare	@FFP_RashDuration bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_RashDuration = @FFP_RashDuration_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_RashDuration = @FFP_RashDuration_R

declare	@FFP_SourceOfInfection bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_SourceOfInfection = @FFP_SourceOfInfection_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_SourceOfInfection = @FFP_SourceOfInfection_R

declare	@FFP_Complications bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Complications = @FFP_Complications_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Complications = @FFP_Complications_R

declare	@FFP_Encephalitis bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Encephalitis = @FFP_Encephalitis_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Encephalitis = @FFP_Encephalitis_R

declare	@FFP_Pneumonia bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Pneumonia = @FFP_Pneumonia_M
else if	@idfsDiagnosis = @idfsDiagnosis_Rubella
	set	@FFP_Pneumonia = @FFP_Pneumonia_R

declare	@FFP_Diarrhoea bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Diarrhoea = @FFP_Diarrhoea_M

declare	@FFP_Other bigint = -100
if	@idfsDiagnosis = @idfsDiagnosis_Measles
	set	@FFP_Other = @FFP_Other_M


update hc
set	hc.NumberOfReceivedDoses = cast(ap_NumberOfReceivedDoses.varValue as nvarchar(50)),
	hc.DateOfLastVaccination = 
	case
		when cast(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination.varValue, 'BaseType') as nvarchar) like N'%date%' or
				(cast(SQL_VARIANT_PROPERTY(ap_DateOfLastVaccination.varValue, 'BaseType') as nvarchar) like N'%char%' and ISDATE(cast(ap_DateOfLastVaccination.varValue as nvarchar)) = 1 )	
			then dbo.FN_GBL_DATECUTTIME(cast(ap_DateOfLastVaccination.varValue as datetime))
		else null
	end,
	hc.Fever = 
	case
		when SQL_VARIANT_PROPERTY(ap_Fever.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Fever.varValue as bigint)
		else null
	end,
	hc.Cough =
	case
		when SQL_VARIANT_PROPERTY(ap_Cough.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Cough.varValue as bigint)
		else null
	end,
	hc.Coryza =
	case
		when SQL_VARIANT_PROPERTY(ap_Coryza.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Coryza.varValue as bigint)
		else null
	end,  		
	hc.Conjunctivitis =
	case
		when SQL_VARIANT_PROPERTY(ap_Conjunctivitis.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Conjunctivitis.varValue as bigint)
		else null
	end,  
	hc.RashDuration = cast(ap_RashDuration.varValue as nvarchar(50)),	
	hc.SourceOfInfection =
	case
		when SQL_VARIANT_PROPERTY(ap_SourceOfInfection.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_SourceOfInfection.varValue as bigint)
		else null
	end,   
	hc.Complications =
	case
		when SQL_VARIANT_PROPERTY(ap_Complications.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Complications.varValue as bigint)
		else null
	end,    
	hc.Encephalitis =
	case
		when SQL_VARIANT_PROPERTY(ap_Encephalitis.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Encephalitis.varValue as bigint)
		else null
	end,    
	hc.Pneumonia =
	case
		when SQL_VARIANT_PROPERTY(ap_Pneumonia.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Pneumonia.varValue as bigint)
		else null
	end,    	
	hc.Diarrhoea =
	case
		when SQL_VARIANT_PROPERTY(ap_Diarrhoea.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			then cast(ap_Diarrhoea.varValue as bigint)
		else null
	end,    
	hc.Other = cast(ap_Other.varValue as nvarchar(500))	  		  		  		  			

 from #HumanCasesToExport hc
			
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfEpiObservation
			and	ap.idfsParameter = @FFP_NumberOfReceivedDoses
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_NumberOfReceivedDoses		
	 			
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfEpiObservation
			and	ap.idfsParameter = @FFP_DateOfLastVaccination
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_DateOfLastVaccination 	
		
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Fever
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Fever	
	
		
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Cough
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Cough	
	
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Coryza
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Coryza
	
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Conjunctivitis	
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Conjunctivitis

	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_RashDuration	
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_RashDuration
	
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfEpiObservation
			and	ap.idfsParameter = @FFP_SourceOfInfection	
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_SourceOfInfection
	
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Complications		
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Complications
	
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Encephalitis				
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Encephalitis

	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Pneumonia				
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Pneumonia
	
	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Diarrhoea						
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Diarrhoea


	outer apply ( 
		select top 1 
			ap.varValue
		from #FFToExport ap
		where	ap.idfObservation = hc.idfCSObservation
			and	ap.idfsParameter = @FFP_Other							
			--and ap.intRowStatus = 0
		order by ap.idfRow asc	
	) as  ap_Other


update	ct
set		ct.datConcludedDate = material.datConcludedDate,
		ct.idfsSampleType = material.idfsSampleType,
		ct.datFieldCollectionDate = material.datFieldCollectionDate,
		ct.idfsTestResult = material.idfsTestResult,
		ct.idfsTestStatus = material.idfsTestStatus,
		ct.idfTesting = material.idfTesting
from	#HumanCasesToExport ct	
outer apply	(
	select top 1 
		dbo.FN_GBL_DATECUTTIME(tt.datConcludedDate) as datConcludedDate,
		isnull(rm.idfsSampleType, m.idfsSampleType) as idfsSampleType,
		m.datFieldCollectionDate,
		tt.idfsTestResult,
		tt.idfsTestStatus,
		tt.idfTesting
	from tlbMaterial m
		left join tlbTesting tt
			inner join trtTestTypeForCustomReport ttcr
			on ttcr.idfsTestName = tt.idfsTestName
			and ttcr.intRowStatus = 0
			and ttcr.idfsCustomReportType = @idfsSummaryReportType
		on tt.idfMaterial = m.idfMaterial
		/*Added 2018-01-22 start*/
		and tt.idfsDiagnosis = ct.idfsDiagnosis
		/*Added 2018-01-22 end*/
		and tt.intRowStatus = 0
		and tt.datConcludedDate is not null
		
		left join tlbMaterial rm
		on rm.idfMaterial = m.idfParentMaterial
		and rm.intRowStatus = 0						
		
   where m.idfHumanCase = ct.idfHumanCase
			and m.intRowStatus = 0
   order by isnull(tt.datConcludedDate, '19000101') desc, m.datFieldCollectionDate desc
   )	as material	 

	select
		ct.idfHumanCase as idfCase,
		'GEO' + hc.strCaseID as strCaseID,
		aid.intAreaID, 
		dbo.FN_GBL_DATECUTTIME(ct.datDateOnset) as datDRash, 
		case 
			when h.idfsHumanGender = 10043001 then 2
			when h.idfsHumanGender = 10043002 then 1
			else 4
		end as intGenderID, 
		dbo.FN_GBL_DATECUTTIME(h.datDateofBirth) as datDBirth, 
		case
			when	IsNull(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
					and (IsNull(hc.intPatientAge, -1) >= 0 and IsNull(hc.intPatientAge, -1) <= 200)
				then	hc.intPatientAge
			when	IsNull(hc.idfsHumanAgeType, -1) = 10042002	-- Months
					and (IsNull(hc.intPatientAge, -1) >= 0 and IsNull(hc.intPatientAge, -1) <= 60)
				then	cast(hc.intPatientAge / 12 as int)
			when	IsNull(hc.idfsHumanAgeType, -1) = 10042001	-- Days
					and (IsNull(hc.intPatientAge, -1) >= 0)
				then	0
			else	null
		end	 as intAgeAtRashOnset,     	
		
		isnull(case when isnumeric(ct.NumberOfReceivedDoses) = 1  and cast(ct.NumberOfReceivedDoses as varchar) not in ('.', ',', '-', '+', '$')
					then	
						case  cast(ct.NumberOfReceivedDoses as bigint)
							when 9878670000000 then 0
							when 9878680000000 then 1
							when 9878690000000 then 2
							when 9878700000000 then 3
							else 9
						end	
					else 9 end
			, 9)	 as intNumOfVaccines, 
			
		ct.DateOfLastVaccination as datDvaccine, 			
		dbo.FN_GBL_DATECUTTIME(hc.datNotificationDate) as datDNotification, 
		dbo.FN_GBL_DATECUTTIME(hc.datInvestigationStartDate) as datDInvestigation, 
 		
		case ct.Fever
			when 25460000000 then 1
			when 25640000000 then 2
			when 25660000000 then 9
			else null
		end	 as intClinFever, 
		
		case 
			case 
				when ct.Cough = 25460000000 or ct.Coryza = 25460000000 or ct.Conjunctivitis = 25460000000 then 25460000000
				when ct.Cough = 25640000000 and ct.Coryza = 25640000000 and ct.Conjunctivitis = 25640000000 then 25640000000
				else 25660000000
			end		
			when 25460000000 then 1
			when 25640000000 then 2
			else 9
		end	 as intClinCCC, 			    			
		case when isnumeric(ct.RashDuration) = 1  and cast(ct.RashDuration as varchar) not in ('.', ',', '-', '+', '$')
				then --cast(ct.RashDuration as int) 
					 cast(cast(replace(ct.RashDuration,',','.') as decimal) as int)
				else null end as intClinRashDuration,
			
		case hc.idfsOutcome
			when 10770000000 then 1
			when 10760000000 then 2
			when 10780000000 then 3
			else 3
		end as intClinOutcome, 
		
		case hc.idfsYNHospitalization   
			when 10100001 then 1
			when 10100002 then 2
			when 10100003 then 9
			else null
		end as intClinHospitalization, 
		
		-- GG - FF parameter = 'Source of infection' -- idfsParameter = 9951440000000
		--9879590000000	Imported
		--9879600000000	Import-related
		--9879610000000	Indigenous
		--9879620000000	Unknown
		--Indigenous=Endemic, Imported=Imported, Import-related=Import-related, Unknown = Unknown, Blank = Blank

		case ct.SourceOfInfection 
			--GG
			when 9879590000000 then 1 --Imported = Imported
			when 9879610000000 then 2 --Indigenous = Endemic
			when 9879600000000 then 3 -- Import-related=Import-related
			when 9879620000000 then 9 --  Unknown = Unknown
			else null --Blank = Blank
		end	 as intSrcInf, 
		
		
		case hc.idfsYNRelatedToOutbreak
			when 10100001 then 1
			when 10100002 then 2
			when 10100003 then 9
			else null
		end as intSrcOutbreakRelated, 
  
		'' as strSrcOutbreakID,
		
		case 
			case 
				-- GG
				when ct.Complications = 25460000000 and ct.idfsDiagnosis = @idfsDiagnosis_Measles then 25460000000
				when ct.Complications = 25640000000 and ct.idfsDiagnosis = @idfsDiagnosis_Measles then 25640000000
				when ct.Complications = 25660000000 and ct.idfsDiagnosis = @idfsDiagnosis_Measles then 25660000000
				else 25660000000
			end		
			when 25460000000 then 1
			when 25640000000 then 2
			when 25660000000 then 9
			else null
		end	 as intCompComplications, 		 					
		
		case when ct.Complications = 25460000000 /*Yes*/ and ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			then
				case ct.Encephalitis 
					when 25460000000 then 1 
					when 25640000000 then 2 
					when 25660000000 then 9 		
					else null
				end	 
			else null
		end as intCompEncephalitis, 				
		
		case when ct.Complications = 25460000000 /*Yes*/ and ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			then
				case ct.Pneumonia 
					when 25460000000 then 1 
					when 25640000000 then 2 
					when 25660000000 then 9 		
					else null
				end		 
			else null
		end as intCompPneumonia, 				
    
		null as intCompMalnutrition, 
		
		case when ct.Complications = 25460000000 /*Yes*/ and ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			then
				case ct.Diarrhoea 
					when 25460000000 then 1 
					when 25640000000 then 2 
					when 25660000000 then 9 		
					else null
				end		 
			else null
		end as intCompDiarrhoea, 		
		
		case when ct.Complications = 25460000000 /*Yes*/ and ct.idfsDiagnosis = @idfsDiagnosis_Measles 
			then
				case when len(ct.Other) > 0 then 1 else 2 end 
			else null
		end as intCompOther, 		
            
		CASE 
			WHEN hc.idfsFinalCaseStatus = 370000000  --Not a Case
					THEN 0
			WHEN hc.idfsFinalCaseStatus = 350000000 --Confirmed
				AND ct.idfsDiagnosis = @idfsDiagnosis_Measles
				AND hc.blnLabDiagBasis = 1
					THEN 1
			WHEN hc.idfsFinalCaseStatus = 350000000  --Confirmed
				AND ct.idfsDiagnosis = @idfsDiagnosis_Measles
				AND isnull(hc.blnLabDiagBasis, 0) = 0
				AND hc.blnEpiDiagBasis = 1
					THEN 2
			WHEN hc.idfsFinalCaseStatus = 360000000 --Probable
				AND ct.idfsDiagnosis = @idfsDiagnosis_Measles
				AND (hc.blnLabDiagBasis = 1 or hc.blnEpiDiagBasis = 1 or hc.blnClinicalDiagBasis = 1)
					THEN 3
			WHEN hc.idfsFinalCaseStatus = 350000000 
				AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella
				AND hc.blnLabDiagBasis = 1
					THEN 6
			WHEN hc.idfsFinalCaseStatus = 350000000 
				AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella
				AND isnull(hc.blnLabDiagBasis, 0) = 0
				AND hc.blnEpiDiagBasis = 1
					THEN 7
			WHEN hc.idfsFinalCaseStatus = 360000000 --Probable
				AND ct.idfsDiagnosis = @idfsDiagnosis_Rubella
				AND  (hc.blnLabDiagBasis = 1 or hc.blnEpiDiagBasis = 1 or hc.blnClinicalDiagBasis = 1)
					THEN 8
			WHEN hc.idfsFinalCaseStatus = 380000000
				OR hc.idfsFinalCaseStatus = 12137920000000
				or hc.idfsFinalCaseStatus is null
				or (hc.blnLabDiagBasis is null and hc.blnEpiDiagBasis is null and hc.blnClinicalDiagBasis is null)
					THEN NULL
			ELSE NULL
		END intFinalClassification,        
    
    
		case 
		   when hc.idfsYNSpecimenCollected = 10100001 then ct.datFieldCollectionDate
		   else null
		end as datDSpecimen,       
        
		--Type of sample associated with the test which result is shown in #29/31. 
		--If #29/31 is blank then the sample with the latest date of sample collection should be taken. 
		--Blood = 1 Serum, 
		--Blood - serum=1 Serum, 
		--Saliva=2 Saliva/oral fluid, 
		--Swab - Rhinopharyngeal = 3 Nasopharyngeal swab, 
		--Urine=5 Urine, 
		--Blood - anticoagulated whole blood= 6 EDTA whole blood, 
		--in other case = 7 Other specimen. 
		--Which sample to send, it shall be defined by tests (see 29/31) NB: Parent Sample Type should be tranferred to CISID in case Sample Derivative was created.
		case
			isnull(case 
			   when hc.idfsYNSpecimenCollected = 10100001 then ct.idfsSampleType
			   else null
			end, -1)
			--GG
			when 9844440000000 /*Blood*/ then 1 --Serum
			when 9844480000000/*Blood - serum*/  then 1 --Serum
			when 9845550000000	/*Saliva*/ then 2 --Saliva/oral fluid
			when 9845840000000	/*Swab - Rhinopharyngeal*/ then 3 --Nasopharyngeal swab
			when 9846060000000	/*Urine*/ then 5 --Urine
			when 9844450000000 /*Blood - anticoagulated whole blood*/ then 6 --EDTA whole blood
			when -1 then null
			else 7
		end as intSpecimen,    

		case 
		   when hc.idfsYNSpecimenCollected = 10100001 then ct.datConcludedDate
		   else null
		end as datDLabResult,    			            
       
		

		--Test Name: ELISA IgM, Antibody detection
		--The Result of the lastest "ELISA IgM, Antibody detection" 
		--Test Name shall be taken (by Result Date). 
		--1 Positive = Positive AND Test Status = Final or Amended, 
		--2 Negative= Negative AND Test Status = Final or Amended, 
		--4 Inclonclusive = Cut off AND Test Status = Final or Amended, 
		--0 Not Tested = if sample data is filled in #26/27 but no test data available, 
		--3 In Process = any test result (including blank) for assigned test AND Test Status = In Process or Preliminary      
		case
			isnull(
					case 
					   when hc.idfsYNSpecimenCollected = 10100001 and ct.idfsDiagnosis = @idfsDiagnosis_Measles and ct.idfsTestStatus in (10001001, 10001006) --Final or Amended
							then ct.idfsTestResult
					   when hc.idfsYNSpecimenCollected = 10100001 and ct.idfsDiagnosis = @idfsDiagnosis_Measles and ct.idfsTestStatus in( 10001003, 10001004)	--In Process or Preliminary   
							then 3
					   when ct.idfsDiagnosis = @idfsDiagnosis_Measles and ct.idfTesting is null and ct.idfsSampleType is not null
							then 0
					   else null
					end, -1)
			--GG
			when 9848880000000 then 4--Indeterminate
			when 9848980000000 then 2--Negative
			when 9849050000000 then 1--Positive
			when 3			   then 3--In Process
			when 0			   then 0--Tested
			when -1 then null
			else null
		end as intMeaslesIgm,    
		
		null as intMeaslesVirusDetection,
		
		case
			isnull(
				case 
					   when hc.idfsYNSpecimenCollected = 10100001 and ct.idfsDiagnosis = @idfsDiagnosis_Rubella and ct.idfsTestStatus  in (10001001, 10001006) --Final or Amended
							then ct.idfsTestResult
					   when hc.idfsYNSpecimenCollected = 10100001 and ct.idfsDiagnosis = @idfsDiagnosis_Rubella and ct.idfsTestStatus in( 10001003, 10001004)	--In Process or Preliminary   
							then 3
					   when ct.idfsDiagnosis = @idfsDiagnosis_Rubella and ct.idfTesting is null	 and ct.idfsSampleType is not null
							then 0
					   else null
			end, -1)
			when 9848880000000 then 4--Indeterminate
			when 9848980000000 then 2--Negative
			when 9849050000000 then 1--Positive
			when 3			   then 3--In Process
			when 0			   then 0--Tested
			when -1 then null
			else null
		end as intRubellaIgm,  
		null as intRubellaVirusDetection,
		'Outbreak ID: ' + to1.strOutbreakID as strCommentsEpi
      
	
	

 			      			
 from	#HumanCasesToExport ct
	inner join tlbHumanCase hc
	on hc.idfHumanCase = ct.idfHumanCase

	inner join tlbHuman h
	on h.idfHuman = ct.idfHuman

	inner join	tlbGeoLocation gl
	on gl.idfGeoLocation = ct.idfCRAddress

	inner join @AreaIDs aid
	on aid.idfsRegion = gl.idfsRegion

	left join tlbOutbreak to1
	on to1.idfOutbreak = hc.idfOutbreak
	and to1.intRowStatus = 0   
order by ct.datDateOnset, hc.strCaseID


--insert into	#ResultTable
-- (	
--	  idfCase
--	, strCaseID	
--	, intAreaID	
--	, datDRash	
--	, intGenderID
--	, datDBirth	
--	, intAgeAtRashOnset	
--	, intNumOfVaccines	
--	, datDvaccine	
--	, datDNotification	
--	, datDInvestigation	
--	, intClinFever		
--	, intClinCCC	
--	, intClinRashDuration	
--	, intClinOutcome		
--	, intClinHospitalization	
--	, intSrcInf				
--	, intSrcOutbreakRelated		
--	, strSrcOutbreakID		
--	, intCompComplications	
--	, intCompEncephalitis	
--	, intCompPneumonia		
--	, intCompMalnutrition	
--	, intCompDiarrhoea		
--	, intCompOther		
--	, intFinalClassification
--	, datDSpecimen			
--	, intSpecimen			
--	, datDLabResult			
--	, intMeaslesIgm			
--	, intMeaslesVirusDetection	
--	, intRubellaIgm		
--	, intRubellaVirusDetection		
--	, strCommentsEpi			
--)
--select 
--	idfHumanCase
--	, strCaseID	
--	, intAreaID	
--	, datDRash	
--	, intGenderID
--	, datDBirth	
--	, intAgeAtRashOnset	
--	, intNumOfVaccines	
--	, datDvaccine	
--	, datDNotification	
--	, datDInvestigation	
--	, intClinFever		
--	, intClinCCC	
--	, intClinRashDuration	
--	, intClinOutcome		
--	, intClinHospitalization	
--	, intSrcInf				
--	, intSrcOutbreakRelated		
--	, strSrcOutbreakID		
--	, intCompComplications	
--	, intCompEncephalitis	
--	, intCompPneumonia		
--	, intCompMalnutrition	
--	, intCompDiarrhoea		
--	, intCompOther		
--	, intFinalClassification
--	, datDSpecimen			
--	, intSpecimen			
--	, datDLabResult			
--	, intMeaslesIgm			
--	, intMeaslesVirusDetection	
--	, intRubellaIgm				
--	, intRubellaVirusDetection
--	, strCommentsEpi	 


--from hc_table
 


--select * from #ResultTable
--order by datDRash, strCaseID

-- Drop temporary tables
if Object_ID('tempdb..#HumanCasesToExport') is not null
begin
set	@cmd = N'drop table #HumanCasesToExport'
execute sp_executesql @cmd
end

if Object_ID('tempdb..#ResultTable') is not null
begin
set	@cmd = N'drop table #ResultTable'
execute sp_executesql @cmd
end

end


