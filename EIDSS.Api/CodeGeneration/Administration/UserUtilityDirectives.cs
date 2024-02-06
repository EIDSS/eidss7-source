using System;
using System.Collections.Generic;
using EIDSS.CodeGenerator;
using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class GetUserListForConversionUtil : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AdminController; }

        public string APIGroupName => "Administration - Users";
        public Type APIReturnType { get => typeof(List<AdminUserListForUtilityViewModel>); }

        public string MethodParameters { get => "AdminUserListForUtilityRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_UserListGetForUtilityResult>); }

        public string SummaryInfo => "Gets a list of tstUserTable users.";
    }

    public class GetUserPermissionList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AdminController; }

        public string APIGroupName => "Administration - Users";
        public Type APIReturnType { get => typeof(List<UserPermissionDetailResponseModel>); }

        public string MethodParameters{get => "string LangID, long? idfEmployee, CancellationToken cancellationToken = default";}

        public APIMethodVerbEnumeration MethodVerb{get => APIMethodVerbEnumeration.GET;}

        public Type RepositoryReturnType{get => typeof(List<spObjectAccess_SelectDetailResult>);}

        public string SummaryInfo => "Gets a list of EIDSS 6 permissions assigned to this user.";

    }


    public class GetAVRUserPermissions : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AdminController; }

        public string APIGroupName => "Administration - Users";

        public Type APIReturnType
        {
            get => typeof(List<AVRPermissionResponseModel>);
        }

        public string MethodParameters
        {
            get => "long idfEmployee, CancellationToken cancellationToken = default";
        }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }

        public Type RepositoryReturnType => typeof(List<USP_AVR_UserPermissionsGetResult>);

        public string SummaryInfo => "Retrieves AVR User Permissions";
    }
}
