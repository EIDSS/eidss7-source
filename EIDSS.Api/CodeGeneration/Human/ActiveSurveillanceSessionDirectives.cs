using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ResponseModels.Human;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetHumanActiveSurveillanceSessionListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_MONITORING_SESSION_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceSessionDetailAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionDetailResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_MONITORING_SESSION_GETDetailResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceSessionSamplesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionSamplesResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionSamplesListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceSessionDetailedInformationListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionDetailedInformationResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionDetailedInformationRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_DetailedInformation_GetListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceSessionTestsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionTestsResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionTestsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_Tests_GetListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceSessionActionsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionActionsResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionActionsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_MONITORING_SESSION_ACTION_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceSessionTestNamesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionTestNamesResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionTestNameRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_GBL_TEST_DISEASE_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class SetHumanActiveSurveillanceSessionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionSaveResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_MONITORING_SESSION_SETResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceDetailedInformationListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionDetailedInformationResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionDetailedInformationRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_DetailedInformation_GetListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanActiveSurveillanceDiseaseSampleTypeListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionDiseaseSampleTypeResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionDiseaseSampleTypeRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_MONITORING_SESSION_TO_DISEASE_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DeleteActiveSurveillanceSessionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long MonitoringSessionID, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_HAS_MONITORING_SESSION_DELResult); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetActiveSurveillanceDiseaseReportsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<ActiveSurveillanceSessionDiseaseReportsResponseModel>); }
        public string MethodParameters { get => "ActiveSurveillanceSessionDiseaseReportsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_DISEASE_REPORT_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
}
