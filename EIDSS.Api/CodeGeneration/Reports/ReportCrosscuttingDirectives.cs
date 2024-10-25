using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Reports
{
    public class GetReportPeriod : ICodeGenDirective

    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;

        public Type APIReturnType => typeof(List<ReportingPeriodViewModel>);

        public string MethodParameters => "string languageId, string year, string reportingPeriodType, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REP_ReportingPeriodResult>);

        public string APIGroupName => "Reporting";

        public string SummaryInfo => "";
    }

    public class GetReportPeriodType : ICodeGenDirective

    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;

        public Type APIReturnType => typeof(List<ReportingPeriodTypeViewModel>);

        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REP_ReportingPeriodTypeResult>);

        public string APIGroupName => "Reporting";

        public string SummaryInfo => "";
    }

    public class GetVetNameOfInvestigationOrMeasure : ICodeGenDirective

    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;

        public Type APIReturnType => typeof(List<VetNameOfInvestigationOrMeasureViewModel>);

        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REP_VET_NameOfInvestigationOrMeasureSelectLookupResult>);

        public string APIGroupName => "Reporting";

        public string SummaryInfo => "";
    }

    public class GetVetSummarySurveillanceType : ICodeGenDirective

    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;

        public Type APIReturnType => typeof(List<VetSummarySurveillanceTypeViewModel>);

        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REP_VET_SummarySurveillanceTypeResult>);

        public string APIGroupName => "Reporting";

        public string SummaryInfo => "";
    }

    public class GetHumanWhoMeaslesRubellaDiagnosis : ICodeGenDirective

    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;

        public Type APIReturnType => typeof(List<WhoMeaslesRubellaDiagnosisViewModel>);

        public string MethodParameters => "CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REP_HUM_WhoMeaslesRubella_DiagnosisResult>);

        public string APIGroupName => "Reporting";

        public string SummaryInfo => "";
    }

    public class GetHumanComparitiveCounter : ICodeGenDirective

    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;

        public Type APIReturnType => typeof(List<HumanComparitiveCounterViewModel>);

        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REP_HUM_ComparitiveCounter_GETResult>);

        public string APIGroupName => "Reporting";

        public string SummaryInfo => "";
    }

    public class GetTuberculosisDiagnosisList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<TuberculosisDiagnosisViewModel>);
        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_HUM_TuberculosisDiagnosisSelectLookupResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetSpeciesTypes : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<SpeciesTypeViewModel>);
        public string MethodParameters => "string languageId, long? idfsDiagnosis, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_SpeciesType_GetListResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetCurrentCountryList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<CurrentCountryViewModel>);
        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_GetCurrentCountryResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetLABAssignmentDiagnosticAZSendToList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<LABAssignmentDiagnosticAZSendToViewModel>);
        public string MethodParameters => "string languageId, string caseId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_LAB_AssignmentDiagnosticAZSendToLookupResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetLABTestingResultsDepartmentList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<LABTestingResultsDepartmentViewModel>);
        public string MethodParameters => "string languageId, string sampleId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_LAB_TestingResultsDepartmentLookupResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetReportList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<ReportListViewModel>);
        public string MethodParameters => "CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_Reports_GetListResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetHumDateFieldSourceList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<HumDateFieldSourceViewModel>);
        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_HUM_DateFieldSource_GETResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetReportOrganizationList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<ReportOrganizationViewModel>);
        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_Organization_GETResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetVetDateFieldSourceList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<VetDateFieldSourceViewModel>);
        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_VET_DateFieldSource_GETResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetHumanComparitiveCounterGG : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<HumanComparitiveCounterGGViewModel>);
        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_HUM_ComparitiveCounter_GET_GGResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetReportQuarterGG : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<ReportQuarterModelGG>);
        public string MethodParameters => "string languageId, string year, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_REP_Quarter_GGResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetVeterinaryAggregateDiagnosticActionSummaryReportDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<AggregateSummaryViewModel>);
        public string MethodParameters => "AggregateSummaryRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_REP_Veterinary_Aggregate_DiagnosticAction_Summary_Report_DetailResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetVeterinaryAggregateProphylacticActionSummaryReportDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<AggregateSummaryViewModel>);
        public string MethodParameters => "AggregateSummaryRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_REP_Veterinary_Aggregate_ProphylacticAction_Summary_Report_DetailResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetVeterinaryAggregateSanitaryActionSummaryReportDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<AggregateSummaryViewModel>);
        public string MethodParameters => "AggregateSummaryRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_REP_Veterinary_Aggregate_SanitaryAction_Summary_Report_DetailResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetVeterinaryAggregateReportDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<AggregateSummaryViewModel>);
        public string MethodParameters => "AggregateSummaryRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_REP_Veterinary_Aggregate_Disease_Summary_Report_DetailResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }

    public class GetHumanAggregateReportDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportCrossCuttingController;
        public Type APIReturnType => typeof(List<AggregateSummaryViewModel>);
        public string MethodParameters => "AggregateSummaryRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_REP_Human_Aggregate_Disease_Summary_Report_DetailResult>);
        public string APIGroupName => "Reporting";
        public string SummaryInfo => "";
    }
}