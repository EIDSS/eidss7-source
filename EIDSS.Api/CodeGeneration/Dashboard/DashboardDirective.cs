using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ViewModels.Dashboard;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Dashboard
{
    public class GetDashboardApprovals : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<ApprovalsGetListViewModel>); }
        public string MethodParameters { get => "string LanguageID, string SiteList, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_APPROVALS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard Approvals";
    }

    public class GetDashboardInvestigations : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardInvestigationsListViewModel>); }
        public string MethodParameters { get => "DashboardInvestigationsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_INVESTIGATIONS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard Investigations";
    }

    public class GetDashboardMyInvestigations : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardInvestigationsListViewModel>); }
        public string MethodParameters { get => "DashboardInvestigationsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_MYINVESTIGATIONS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard My Investigations";
    }

    public class GetDashboardNotifications : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardNotificationsListViewModel>); }
        public string MethodParameters { get => "DashboardNotificationsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_NOTIFICATIONS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard Notifications";
    }

    public class GetDashboardMyNotifications : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardNotificationsListViewModel>); }
        public string MethodParameters { get => "DashboardNotificationsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_MYNOTIFICATIONS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard My Notifications";
    }

    public class GetDashboardMyCollections : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardCollectionsListViewModel>); }
        public string MethodParameters { get => "DashboardCollectionsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_MYCOLLECTIONS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard My Collections";
    }

    public class GetDashboardUsers : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardUsersListViewModel>); }
        public string MethodParameters { get => "DashboardUsersGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_USERS_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard Users";
    }

    public class GetDashboardLinks : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DashboardController; }
        public Type APIReturnType { get => typeof(List<DashboardLinksListViewModel>); }
        public string MethodParameters { get => "DashboardLinksGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_DAS_DASHBOARD_GETListResult>); }
        public string APIGroupName => "Dashboard";
        public string SummaryInfo => "Gets the Dashboard Links";
    }


}
