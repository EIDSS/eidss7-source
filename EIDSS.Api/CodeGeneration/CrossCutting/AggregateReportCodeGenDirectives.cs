using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;

namespace EIDSS.Api.CodeGeneration.CrossCutting
{
    public class GetAggregateReportList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AggregateReportController; }
        public Type APIReturnType { get => typeof(List<AggregateReportGetListViewModel>); }
        public string MethodParameters { get => "AggregateReportSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_AGG_REPORT_GETListResult>); }
        public string APIGroupName => "Aggregate Reports";
        public string SummaryInfo => "";
    }

    public class DeleteAggregateReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AggregateReportController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long reportKey, string User, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_AGG_REPORT_DELETEResult); }
        public string APIGroupName => "Aggregate Reports";
        public string SummaryInfo => "";
    }

    public class GetAggregateReportDetail : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AggregateReportController; }
        public Type APIReturnType { get => typeof(List<AggregateReportGetDetailViewModel>); }
        public string MethodParameters { get => "AggregateReportGetListDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_AGG_CASE_GETDETAILResult>); }
        public string APIGroupName => "Aggregate Reports";
        public string SummaryInfo => "";
    }

    public class SaveAggregateReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AggregateReportController; }
        public Type APIReturnType { get => typeof(AggregateReportSaveResponseModel); }
        public string MethodParameters { get => "AggregateReportSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_AGG_REPORT_SETResult); }
        public string APIGroupName => "Aggregate Reports";
        public string SummaryInfo => "";
    }

    public class SaveObservation : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AggregateReportController; }
        public Type APIReturnType { get => typeof(ObservationSaveResponseModel); }
        public string MethodParameters { get => "ObservationSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_GBL_OBSERVATION_SETResult); }
        public string APIGroupName => "Aggregate Reports";
        public string SummaryInfo => "";
    }
}