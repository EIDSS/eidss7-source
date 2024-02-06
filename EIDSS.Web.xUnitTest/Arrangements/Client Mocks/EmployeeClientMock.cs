using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class EmployeeClientMock : BaseClientMock<IEmployeeClient>, IEmployeeClient
    {
        public Task<APIPostResponseModel> DeleteEmployee(long? idfPerson)
        {
            Client.Setup(p=> p.DeleteEmployee(idfPerson)).ReturnsAsync(BaseArrangement.Fixture.Create<APIPostResponseModel>());
            return Client.Object.DeleteEmployee(idfPerson);
        }

        public Task<APIPostResponseModel> DeleteEmployeeGroupMemberInfo(string idfEmployeeGroups, long? idfEmployee)
        {
            Client.Setup(p=> p.DeleteEmployeeGroupMemberInfo(idfEmployeeGroups, idfEmployee)).ReturnsAsync(BaseArrangement.Fixture.Create<APIPostResponseModel>());
            return Client.Object.DeleteEmployeeGroupMemberInfo(idfEmployeeGroups, idfEmployee);
        }

        public Task<APIPostResponseModel> DeleteEmployeeLoginInfo(long? idfUserId)
        {
            Client.Setup(p=> p.DeleteEmployeeLoginInfo(idfUserId)).ReturnsAsync(BaseArrangement.Fixture.Create<APIPostResponseModel>());
            return Client.Object.DeleteEmployeeLoginInfo(idfUserId);
        }

        public Task<APIPostResponseModel> DeleteEmployeeOrganization(string aspNetUserId, long? idfUserId)
        {
            Client.Setup(p=> p.DeleteEmployeeOrganization(aspNetUserId, idfUserId)).ReturnsAsync(BaseArrangement.Fixture.Create<APIPostResponseModel>());
            return Client.Object.DeleteEmployeeOrganization(aspNetUserId, idfUserId);
        }

        public Task<APIPostResponseModel> EmployeeOrganizationActivateDeactivateSet(long? idfPerson, bool? active)
        {
            Client.Setup(p=> p.EmployeeOrganizationActivateDeactivateSet(idfPerson, active)).ReturnsAsync(BaseArrangement.Fixture.Create<APIPostResponseModel>());
            return Client.Object.EmployeeOrganizationActivateDeactivateSet(idfPerson, active);
        }

        public Task<APIPostResponseModel> EmployeeOrganizationStatusSet(long? idfPerson, int? intRowStatus)
        {
            Client.Setup(p=> p.EmployeeOrganizationStatusSet(idfPerson, intRowStatus)).ReturnsAsync(BaseArrangement.Fixture.Create<APIPostResponseModel>());
            return Client.Object.EmployeeOrganizationStatusSet(idfPerson, intRowStatus);
        }

        public Task<List<AspNetUserDetailModel>> GetASPNetUser_GetDetails(string id)
        {
            Client.Setup(p=> p.GetASPNetUser_GetDetails(id)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<AspNetUserDetailModel>().ToList());
            return Client.Object.GetASPNetUser_GetDetails(id);
        }

        public Task<List<EmployeeDetailRequestResponseModel>> GetEmployeeDetail(EmployeeDetailsGetRequestModel request)
        {
            Client.Setup(p=> p.GetEmployeeDetail(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeeDetailRequestResponseModel>().ToList());
            return Client.Object.GetEmployeeDetail(request);
        }

        public Task<List<EmployeeGroupsByUserViewModel>> GetEmployeeGroupsByUser(long? idfUserId)
        {
            Client.Setup(p=> p.GetEmployeeGroupsByUser(idfUserId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeeGroupsByUserViewModel>().ToList());
            return Client.Object.GetEmployeeGroupsByUser(idfUserId);
        }

        public Task<List<EmployeeListViewModel>> GetEmployeeList(EmployeeGetListRequestModel request)
        {
            Client.Setup(p=> p.GetEmployeeList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeeListViewModel>().ToList());
            return Client.Object.GetEmployeeList(request);
        }

        public Task<List<AdminEmployeeSiteDetailsViewModel>> GetEmployeeSiteDetails(EmployeesSiteDetailsGetRequestModel request)
        {
            Client.Setup(p=> p.GetEmployeeSiteDetails(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<AdminEmployeeSiteDetailsViewModel>().ToList());
            return Client.Object.GetEmployeeSiteDetails(request);
        }

        public Task<List<EmployeeSiteFromOrgViewModel>> GetEmployeeSiteFromOrg(long? idfOffice)
        {
            Client.Setup(p=> p.GetEmployeeSiteFromOrg(idfOffice)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeeSiteFromOrgViewModel>().ToList());
            return Client.Object.GetEmployeeSiteFromOrg(idfOffice);
        }

        public Task<List<EmployeeUserGroupOrgDetailsViewModel>> GetEmployeeUserGroupAndPermissionDetail(EmployeeUserGroupOrgDetailsGetRequestModel request)
        {
            Client.Setup(p => p.GetEmployeeUserGroupAndPermissionDetail(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeeUserGroupOrgDetailsViewModel>().ToList());
            return Client.Object.GetEmployeeUserGroupAndPermissionDetail(request);
        }

        public Task<List<EmployeeUserGroupsAndPermissionsViewModel>> GetEmployeeUserGroupAndPermissions(EmployeesUserGroupAndPermissionsGetRequestModel request)
        {
            Client.Setup(p=> p.GetEmployeeUserGroupAndPermissions(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EmployeeUserGroupsAndPermissionsViewModel>().ToList());
            return Client.Object.GetEmployeeUserGroupAndPermissions(request);
        }

        public Task<EmployeeOrganizationSaveRequestResponseModel> SaveAdminNewDefaultEmployeeOrganization(EmployeeNewDefaultOrganizationSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveAdminNewDefaultEmployeeOrganization(request)).ReturnsAsync(BaseArrangement.Fixture.Create<EmployeeOrganizationSaveRequestResponseModel>());
            return Client.Object.SaveAdminNewDefaultEmployeeOrganization(request);
        }

        public Task<EmployeeSaveRequestResponseModel> SaveEmployee(EmployeeSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveEmployee(request)).ReturnsAsync(BaseArrangement.Fixture.Create<EmployeeSaveRequestResponseModel>());
            return Client.Object.SaveEmployee(request);
        }

        public Task<EmployeeOrganizationSaveRequestResponseModel> SaveEmployeeOrganization(EmployeeOrganizationSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveEmployeeOrganization(request)).ReturnsAsync(BaseArrangement.Fixture.Create<EmployeeOrganizationSaveRequestResponseModel>());
            return Client.Object.SaveEmployeeOrganization(request);
        }

        public Task<EmployeeUserGroupMemberSaveRequestResponseModel> SaveUserGroupMemberInfo(EmployeeUserGroupMemberSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveUserGroupMemberInfo(request)).ReturnsAsync(BaseArrangement.Fixture.Create<EmployeeUserGroupMemberSaveRequestResponseModel>());
            return Client.Object.SaveUserGroupMemberInfo(request);
        }

        public Task<EmployeeLoginSaveRequestResponseModel> SaveUserLoginInfo(EmployeeLoginSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveUserLoginInfo(request)).ReturnsAsync(BaseArrangement.Fixture.Create<EmployeeLoginSaveRequestResponseModel>());
            return Client.Object.SaveUserLoginInfo(request);
        }
    }
}
