using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using System;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class GetEmployees : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<EmployeeListViewModel>); }

        public string MethodParameters { get => "EmployeeGetListRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMPLOYEE_GETLISTResult>); }

        public string SummaryInfo => "";
    }
    public class GetEmployeeDetails : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<EmployeeDetailRequestResponseModel>); }

        public string MethodParameters { get => "EmployeeDetailsGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_GBL_PERSON_GETDetailResult>); }

        public string SummaryInfo => "";
    }
    public class GetEmployeeSiteDetails : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<AdminEmployeeSiteDetailsViewModel>); }

        public string MethodParameters { get => "EmployeesSiteDetailsGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_GBL_EMPLOYEESITE_GETDETAILResult>); }

        public string SummaryInfo => "";
    }

    public class GetEmployeeSiteFromOrg : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<EmployeeSiteFromOrgViewModel>); }

        public string MethodParameters { get => "long? idfOffice, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_GBL_LKUP_SITE_FROM_ORGResult>); }

        public string SummaryInfo => "";
    }
    public class GetEmployeeUserGroupAndPermissionsList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<EmployeeUserGroupsAndPermissionsViewModel>); }

        public string MethodParameters { get => "EmployeesUserGroupAndPermissionsGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETListResult>); }

        public string SummaryInfo => "";
    }

    public class GetASPNetUser_GetDetails : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<AspNetUserDetailModel>); }

        public string MethodParameters { get => "string id, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ASPNetUser_GetDetailResult>); }

        public string SummaryInfo => "";
    }

    public class GetEmployeeGroupsByUser : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<EmployeeGroupsByUserViewModel>); }

        public string MethodParameters { get => "long? idfUserId, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMPLOYEEGROUP_BYUSER_GetDetailResult>); }

        public string SummaryInfo => "";
    }

    public class GetEmployeeUserGroupAndPermissionDetail : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(List<EmployeeUserGroupOrgDetailsViewModel>); }

        public string MethodParameters { get => "EmployeeUserGroupOrgDetailsGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETDetailResult>); }

        public string SummaryInfo => "";
    }
    public class SaveEmployee : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(EmployeeSaveRequestResponseModel); }

        public string MethodParameters { get => "EmployeeSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMP_SETResult); }

        public string SummaryInfo => "";
    }

    public class SaveUserLoginInfo : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(EmployeeLoginSaveRequestResponseModel); }

        public string MethodParameters { get => "EmployeeLoginSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_USR_LOGININFO_SETResult); }

        public string SummaryInfo => "";
    }

    public class SaveUserGroupMemberInfo : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(EmployeeUserGroupMemberSaveRequestResponseModel); }

        public string MethodParameters { get => "EmployeeUserGroupMemberSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_USR_GROUPMEMBER_SETResult); }

        public string SummaryInfo => "";
    }
    public class SaveAdminEmployeeOrganization : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(EmployeeOrganizationSaveRequestResponseModel); }

        public string MethodParameters { get => "EmployeeOrganizationSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMP_ORGANIZATION_SETResult); }

        public string SummaryInfo => "";
    }

    public class SaveAdminNewDefaultEmployeeOrganization : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public string APIGroupName => "Administration - Employees";
        public Type APIReturnType { get => typeof(EmployeeOrganizationSaveRequestResponseModel); }

        public string MethodParameters { get => "EmployeeNewDefaultOrganizationSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMP_NEW_DEFAULT_ORGANIZATION_SETResult); }

        public string SummaryInfo => "";
    }

    public class DeleteEmployee : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long? idfPerson, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMPLOYEE_DELResult); }

        public string APIGroupName => "Administration - Employees";

        public string SummaryInfo => "Delete Employee";
        
    }

    public class DeleteEmployeeOrganization : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "string aspNetUserId, long? idfUserId, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMP_ORGANIZATION_DELResult); }

        public string APIGroupName => "Administration - Employees";

        public string SummaryInfo => "Delete Employee Organization";

    }

    public class EmployeeOrganizationStatusSet : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long? idfPerson, int? intRowStatus, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMP_ORGANIZATION_STATUS_SETResult); }

        public string APIGroupName => "Administration - Employees";

        public string SummaryInfo => "Set Employee Active/Inactive";

    }

    public class EmployeeOrganizationActivateDeactivateSet : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long? idfPerson, bool? active, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_EMP_ORGANIZATION_ACTIVATE_DEACTIVATE_SETResult); }

        public string APIGroupName => "Administration - Employees";

        public string SummaryInfo => "Set Employee Organization Active Deactive";

    }

    public class DeleteEmployeeLoginInfo : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long? idfUserId, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_USR_LOGININFO_DELResult); }

        public string APIGroupName => "Administration - Employees";

        public string SummaryInfo => "Delete Employee Login Info";

    }

    public class DeleteEmployeeGroupMemberInfo : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.EmployeesController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "string idfEmployeeGroups, long? idfEmployee, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_USR_GROUPMEMBER_DELResult); }

        public string APIGroupName => "Administration - Employees";

        public string SummaryInfo => "Delete Employee Group Member";

    }
}
