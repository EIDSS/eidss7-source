using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using EIDSS.Domain.ResponseModels;

namespace EIDSS.Api.CodeGeneration.Veterinary
{
    public class GetVeterinaryActiveSurveillanceSessionListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VeterinaryActiveSurveillanceSessionViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Gets a list of veterinary active surveillance sessions based on search criteria.";
    }

    public class GetVeterinaryActiveSurveillanceSessionDetailAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VeterinaryActiveSurveillanceSessionDetailViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_GETDetailResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Gets the details of a veterinary active surveillance session.";
    }

    public class GetVeterinaryActiveSurveillanceSessionDiseaseSpeciesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_TO_DISEASE_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of disease, species, and sample type combination records for a specific active surveillance session.";
    }

    public class GetVeterinaryActiveSurveillanceSessionSamplesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<SampleGetListViewModel>); }
        public string MethodParameters { get => "SampleGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_SAMPLE_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of sample records for a specific active surveillance session.";
    }

    public class GetVeterinaryActiveSurveillanceSessionSampleDiseaseListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<SampleToDiseaseGetListViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionSampleDiseaseRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_SAMPLE_TO_DISEASE_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of selected diseases for a particular sample type.";
    }

    public class GetVeterinaryActiveSurveillanceSessionTestsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<LaboratoryTestGetListViewModel>); }
        public string MethodParameters { get => "LaboratoryTestGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_TEST_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of test records for a specific active surveillance session.";
    }

    public class GetVeterinaryActiveSurveillanceSessionActionsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VeterinaryActiveSurveillanceSessionActionsViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionActionsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_ACTION_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of action records for a specific active surveillance session.";
    }

    public class GetVeterinaryActiveSurveillanceSessionAggregateInfoListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VeterinaryActiveSurveillanceSessionAggregateViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_SUMMARY_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of aggregate information for a specific active surveillance session.";
    }

    public class GetVeterinaryActiveSurveillanceSessionAggregateDiseaseListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel>); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionAggregateNonPagedRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VAS_MONITORING_SESSION_SUMMARY_TO_DISEASE_GETListResult>); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Returns a list of aggregate diseases for a specific active surveillance session.";
    }

    public class SaveVeterinaryActiveSurveillanceSessionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryActiveSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(VeterinaryActiveSurveillanceSessionSaveRequestResponseModel); }
        public string MethodParameters { get => "VeterinaryActiveSurveillanceSessionSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_VAS_MONITORING_SESSION_SETResult); }
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Save veterinary active surveillance session";
    }

    public class DeleteVeterinaryActiveSurveillanceSessionAsync : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VeterinaryActiveSurveillanceSessionController;
        public Type APIReturnType => typeof(APIPostResponseModel);
        public string MethodParameters => "string LanguageID, long MonitoringSessionID, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.DELETE;
        public Type RepositoryReturnType => typeof(USP_VAS_MONITORING_SESSION_DELResult);
        public string APIGroupName => "Veterinary";
        public string SummaryInfo => "Delete Veterinary active surveillance session";
    }
}