using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Vector;

namespace EIDSS.Api.CodeGeneration
{
    public class GetVectorSurveillanceSessionListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VectorSurveillanceSessionViewModel>); }
        public string MethodParameters { get => "VectorSurveillanceSessionSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SURVEILLANCE_SESSION_GetListResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "";
    }

    public class SaveVectorSurveillanceSessionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.VectorSessionResponseModel>); }
        public string MethodParameters { get => "VectorSessionSetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SURVEILLANCE_SESSION_SETResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Saves an entire vector surveillance session including detailed and aggregate collections.";
    }

    public class GetVectorSurveillanceSessionMasterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.USP_VCTS_VSSESSION_New_GetDetailResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_VSSESSION_NEW_GetDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_VSSESSION_New_GetDetailResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "";
    }

    public class GetVectorSessionAggregateCollectionDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.VectorSessionDetailResponseModel>); }
        public string MethodParameters { get => "VectorSessionDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SESSIONSUMMARY_GETDetailResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Gets the detailed aggregate collection record that belongs to a vector surveillance session.";
    }

    public class GetVectorSessionFieldTestsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<FieldTestGetListViewModel>); }
        public string MethodParameters { get => "USP_VCTS_FIELDTEST_GetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_FIELDTEST_GetListResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Get detailed collection field tests for a vector session.";
    }

    public class GetVectorSessionSamplesAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<VectorSampleGetListViewModel>); }
        public string MethodParameters { get => "USP_VCTS_SAMPLE_GetListRequestModels request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SAMPLE_GetListResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "";
    }

    public class GetVectorSessionLabTestsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.USP_VCTS_LABTEST_GetListResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_LABTEST_GetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_LABTEST_GetListResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "";
    }

    public class GetVectorDetailsList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.USP_VCTS_VECT_GetDetailResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_VECT_GetDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_VECT_GetDetailResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Returns a LIst of Vectors";
    }

    public class SetVectorSessionSummary : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.USP_VCTS_SESSIONSUMMARY_SETResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_SESSIONSUMMARY_SETRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SESSIONSUMMARY_SETResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Saves a Vector Summary Record";
    }

    public class GetVectorSessionSummary : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.VectorSessionDetailResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_VecSessionSummary_GETListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SESSIONSUMMARY_GETListResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Returns a list of vector session aggregate collections.";
    }

    public class DeleteAggregateCollection : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<APIPostResponseModel>); }
        public string MethodParameters { get => "long idfsVSSessionSummary, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_VCTS_SESSIONSUMMARY_DELResult); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Soft deletes a vector aggregate collection.";
    }

    public class GetSessionDiagnosis : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Returns a List Of Diagnosis For a Vector Aggregate";
    }

    public class GetVectorDetailsCollection : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.Vector.USP_VCTS_VECTCollection_GetDetailResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_VECTCollection_GetDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_VECTCollection_GetDetailResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Returns Vector Details Collection Results";
    }

    public class DeleteDetailedCollection : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<APIPostResponseModel>); }
        public string MethodParameters { get => "long idfVector, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_VCTS_VECT_DELResult); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Soft deletes a vector detailed collection.";
    }

    public class DeleteSurveillanceSession : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<APIPostResponseModel>); }
        public string MethodParameters { get => "long idfVectorSurveillanceSession, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_VCTS_SURVEILLANCE_SESSION_DELResult); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Soft deletes a vector surveillance session.";
    }

    public class CopyDetailedCollection : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorSurveillanceSessionController; }
        public Type APIReturnType { get => typeof(List<APIPostResponseModel>); }
        public string MethodParameters { get => "USP_VCTS_DetailedCollections_CopyRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VCTS_DetailedCollections_CopyResult>); }
        public string APIGroupName => "Vector";
        public string SummaryInfo => "Copies 'Detailed Collections' for a given Vector.";
    }
}