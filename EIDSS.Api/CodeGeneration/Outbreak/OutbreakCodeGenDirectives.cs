using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using EIDSS.Domain.ViewModels.Veterinary;

namespace EIDSS.Api.CodeGeneration
{
    public class GetSessionListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakSessionListViewModel>); }
        public string MethodParameters { get => "OutbreakSessionListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Session_GetListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetSessionDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakSessionDetailsResponseModel>); }
        public string MethodParameters { get => "string LanguageID, long idfOutbreak, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Session_GetDetailResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetSessionParametersListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakSessionParametersListModel>); }
        public string MethodParameters { get => "string LanguageID, long idfOutbreak, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Session_Parameters_GetListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class SetSessionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(OutbreakSessionDetailsSaveResponseModel); }
        public string MethodParameters { get => "OutbreakSessionCreateRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_OMM_Session_SetResult); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetCaseListAsync: ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<CaseGetListViewModel>); }
        public string MethodParameters { get => "OutbreakCaseListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Case_GetListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetVeterinaryCaseList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<VeterinaryCaseGetListViewModel>); }
        public string MethodParameters { get => "VeterinaryCaseSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_VET_CASE_GETListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetCaseDetailAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<CaseGetDetailViewModel>); }
        public string MethodParameters { get => "string languageId, long caseId, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Case_GetDetailResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class QuickSaveCase : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(CaseQuickSaveResponseModel); }
        public string MethodParameters { get => "CaseQuickSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_OMM_Case_QuickSetResult); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetSessionNoteListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakSessionNoteListViewModel>); }
        public string MethodParameters { get => "OutbreakSessionNoteListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Session_Note_GetListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetSessionNoteDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakSessionNoteDetailsViewModel>); }
        public string MethodParameters { get => "string LangID, long idfOutbreakNote, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Session_Note_GetDetailResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class DeleteSessionNoteAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "OutbreakSessionNoteDeleteRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_OMM_SESSION_Note_DeleteResult); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetNoteFileAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakNoteFileResponseModel>); }
        public string MethodParameters { get => "OutbreakNoteRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Note_File_GetResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetHeatMapDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakHeatMapResponseModel>); }
        public string MethodParameters { get => "OutbreakHeatMapRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_HeatMapResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetCaseMonitoringListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<CaseMonitoringGetListViewModel>); }
        public string MethodParameters { get => "CaseMonitoringGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_CASE_MONITORING_GETListResult>); }
        public string APIGroupName => "Outbreak Case";
        public string SummaryInfo => "Returns a list of case monitoring records for a specific outbreak case.";
    }

    public class GetContactListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<ContactGetListViewModel>); }
        public string MethodParameters { get => "ContactGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Contact_GetListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetVectorList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<VectorGetListViewModel>); }
        public string MethodParameters { get => "VectorGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_Vector_GetListResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class SaveContact : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(ContactSaveResponseModel); }
        public string MethodParameters { get => "ContactSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_OMM_Contact_SetResult); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }

    public class GetHumanCaseDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.OutbreakController; }
        public Type APIReturnType { get => typeof(List<OutbreakHumanCaseDetailResponseModel>); }
        public string MethodParameters { get => "OutbreakHumanCaseDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_OMM_HUMAN_Case_GetDetailResult>); }
        public string APIGroupName => "Outbreak";
        public string SummaryInfo => "";
    }
}