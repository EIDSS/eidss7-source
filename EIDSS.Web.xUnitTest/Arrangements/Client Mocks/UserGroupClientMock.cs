using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class UserGroupClientMock : BaseClientMock<IUserGroupClient>, IUserGroupClient
    {

        public Task<APIPostResponseModel> DeleteEmployeesFromUserGroup(long? idfEmployeeGroup, string idfEmployeeList, string AuditUser)
        {
            Client.Setup(p=> p.DeleteEmployeesFromUserGroup(idfEmployeeGroup, idfEmployeeList, AuditUser)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteEmployeesFromUserGroup(idfEmployeeGroup, idfEmployeeList, AuditUser);
        }

        public Task<APIPostResponseModel> DeleteUserGroup(long? roleID, long? roleName, string user)
        {
            Client.Setup(prop=> prop.DeleteUserGroup(roleID, roleName, user)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteUserGroup(roleID, roleName, user);
        }

        public Task<List<EmployeesForUserGroupViewModel>> GetEmployeesForUserGroupList(EmployeesForUserGroupGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetEmployeesForUserGroupList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeesForUserGroupViewModel>().ToList());
            return Client.Object.GetEmployeesForUserGroupList(request);
        }

        public Task<List<UserPermissionByRoleViewModel>> GetPermissionsbyRole(PermissionsbyRoleGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetPermissionsbyRole(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<UserPermissionByRoleViewModel>().ToList());
            return Client.Object.GetPermissionsbyRole(request);
        }

        public Task<List<UserGroupDashboardViewModel>> GetUserGroupDashboardList(UserGroupDashboardGetRequestModel request)
        {
            Client.Setup(p=> p.GetUserGroupDashboardList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<UserGroupDashboardViewModel>().ToList());
            return Client.Object.GetUserGroupDashboardList(request);
        }

        public Task<List<UserGroupDetailViewModel>> GetUserGroupDetail(long? idfEmployeeGroup, string langId, string user)
        {
            Client.Setup(p=> p.GetUserGroupDetail(idfEmployeeGroup, langId, user)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<UserGroupDetailViewModel>().ToList());
            return Client.Object.GetUserGroupDetail(idfEmployeeGroup, langId, user);
        }

        public Task<List<UserGroupViewModel>> GetUserGroupList(UserGroupGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetUserGroupList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<UserGroupViewModel>().ToList());
            return Client.Object.GetUserGroupList(request);
        }

        public Task<List<UsergroupSystemfunctionPermissionViewModel>> GetUsergroupSystemfunctionPermissionList(string langId, long? systemFunctionId)
        {
            Client.Setup(p=> p.GetUsergroupSystemfunctionPermissionList(langId, systemFunctionId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<UsergroupSystemfunctionPermissionViewModel>().ToList());
            return Client.Object.GetUsergroupSystemfunctionPermissionList(langId, systemFunctionId);
        }

        public Task<APIPostResponseModel> SaveEmployeesToUserGroup(EmployeesToUserGroupSaveRequestModel request)
        {
            Client.Setup(prop => prop.SaveEmployeesToUserGroup(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveEmployeesToUserGroup(request);
        }

        public Task<UserGroupSaveResponseModel> SaveUserGroup(UserGroupSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveUserGroup(request)).ReturnsAsync(BaseArrangement.Fixture.Create<UserGroupSaveResponseModel>());
            return Client.Object.SaveUserGroup(request);
        }

        public Task<APIPostResponseModel> SaveUserGroupDashboard(UserGroupDashboardSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveUserGroupDashboard(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveUserGroupDashboard(request);
        }

        public Task<APIPostResponseModel> SaveUserGroupSystemFunctions(UserGroupSystemFunctionsSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveUserGroupSystemFunctions(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveUserGroupSystemFunctions(request);
        }
    }
}
