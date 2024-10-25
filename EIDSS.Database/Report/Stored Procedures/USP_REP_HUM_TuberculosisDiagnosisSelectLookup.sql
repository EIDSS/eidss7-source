

--*************************************************************************
-- Name 				: report.USP_REP_HUM_TuberculosisDiagnosisSelectLookup
-- DescriptiON			: 
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
 /*

exec [report].[USP_REP_HUM_TuberculosisDiagnosisSelectLookup] 'en-US'
exec [report].[USP_REP_HUM_TuberculosisDiagnosisSelectLookup] 'az-Latn-AZ'

*/ 
 
create procedure [Report].[USP_REP_HUM_TuberculosisDiagnosisSelectLookup]
	@LangID			as varchar(36)
AS
begin
	SELECT 0 as idfsReference,'' AS strName,1 as intOrder
	UNION ALL
	select distinct
		r.idfsReference, 
		r.[name] as strName,
		r.intOrder  

	from dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) r
	inner join trtDiagnosis d
			inner join dbo.trtDiagnosisToGroupForReportType dgrt
			on dgrt.idfsDiagnosis = d.idfsDiagnosis
			and dgrt.idfsCustomReportType = 10290041 --Report on Tuberculosis cases tested for HIV

			inner join dbo.trtReportDiagnosisGroup dg
			on dgrt.idfsReportDiagnosisGroup = dg.idfsReportDiagnosisGroup
			and dg.intRowStatus = 0 and dg.strDiagnosisGroupAlias = 'DG_Tuberculosis'
		on  r.idfsReference = d.idfsDiagnosis
			and d.intRowStatus = 0
	order by	2,1

end


