using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Administration.Security
{
    public class GetUserGroupDashboardList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(List<UserGroupDashboardViewModel>); }
        public string MethodParameters { get => "UserGroupDashboardGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_GETLISTResult>); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class SaveUserGroupDashboard : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "UserGroupDashboardSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMPLOYEEGROUP_DASHBOARD_SETResult); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class DeleteUserGroup : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long? roleID, long? roleName, long? idfsSite, string user, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMPLOYEEGROUP_DELResult); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class GetUserGroupDetail : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(List<UserGroupDetailViewModel>); }
        public string MethodParameters { get => "long? idfEmployeeGroup, string langId, string user, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMPLOYEEGROUP_GETDETAILResult>); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class GetUserGroupList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(List<UserGroupViewModel>); }
        public string MethodParameters { get => "UserGroupGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMPLOYEEGROUP_GETLISTResult>); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class SaveUserGroup : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(UserGroupSaveResponseModel); }
        public string MethodParameters { get => "UserGroupSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMPLOYEEGROUP_SETResult); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class SaveUserGroupSystemFunctions : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "UserGroupSystemFunctionsSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SETResult); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class DeleteEmployeesFromUserGroup : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long? idfEmployeeGroup, string idfEmployeeList, string AuditUser, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMPLOYEES_IN_USERGROUP_DELResult); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class GetEmployeesForUserGroupList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(List<EmployeesForUserGroupViewModel>); }
        public string MethodParameters { get => "EmployeesForUserGroupGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMPLOYEESFOREMPLOYEEGROUP_GETLISTResult>); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class GetUsergroupSystemfunctionPermissionList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(List<UsergroupSystemfunctionPermissionViewModel>); }
        public string MethodParameters { get => "string langId, long? systemFunctionId, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_USERGROUP_SYSTEMFUNCTION_PERMISSION_GETLISTResult>); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class SaveEmployeesToUserGroup : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "EmployeesToUserGroupSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_USERGROUPTOEMPLOYEE_SETResult); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

    public class GetPermissionsbyRole : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UserGroupController; }
        public Type APIReturnType { get => typeof(List<UserPermissionByRoleViewModel>); }
        public string MethodParameters { get => "PermissionsbyRoleGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ASPNetUserGetPermissionByRole_GETLISTResult>); }
        public string APIGroupName => "Administration - User Groups";
        public string SummaryInfo => "";
    }

}
