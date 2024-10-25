using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class GetEventCount : ICodeGenDirective
    { 
        public string APIClassName { get => TargetedClassNames.NotificationController; }
        public Type APIReturnType { get => typeof(List<EventCountResponseModel>); }
        public string MethodParameters { get => "EventGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EVENT_GETCountResult>); }
        public string APIGroupName => "Administration";
        public string SummaryInfo => "";
    }

    public class GetEventList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.NotificationController; }
        public Type APIReturnType { get => typeof(List<EventGetListViewModel>); }
        public string MethodParameters { get => "EventGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EVENT_GETListResult>); }
        public string APIGroupName => "Administration";
        public string SummaryInfo => "";
    }

    public class SaveEventStatus : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.NotificationController; }
        public Type APIReturnType { get => typeof(EventSaveRequestResponseModel); }
        public string MethodParameters { get => "EventStatusSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EVENT_STATUS_SETResult); }
        public string APIGroupName => "Administration";
        public string SummaryInfo => "";
    }

    public class SaveEvent : ICodeGenDirective
    { 
        public string APIClassName { get => TargetedClassNames.NotificationController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "EventSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EVENT_SETResult); }
        public string APIGroupName => "Administration";
        public string SummaryInfo => "";
    }
}