using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels.Administration.Security;
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
    public class SystemFunctionsClientMock : BaseClientMock<ISystemFunctionsClient>, ISystemFunctionsClient
    {
        public Task<SystemFunctionPersonANDEmployeeGroupDelResponseModel> DeleteSystemFunctionPersonAndEmployeeGroup(SystemFunctionsPersonAndEmpoyeeGroupDelRequestModel request)
        {
            Client.Setup(p=> p.DeleteSystemFunctionPersonAndEmployeeGroup(request)).ReturnsAsync(BaseArrangement.Fixture.Create< SystemFunctionPersonANDEmployeeGroupDelResponseModel>());
            return Client.Object.DeleteSystemFunctionPersonAndEmployeeGroup(request);
        }

        public Task<List<SystemFunctionPersonANDEmployeeGroupViewModel>> GetPersonAndEmployeeGroupList(PersonAndEmployeeGroupGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetPersonAndEmployeeGroupList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SystemFunctionPersonANDEmployeeGroupViewModel>().ToList());
            return Client.Object.GetPersonAndEmployeeGroupList(request);
        }

        public Task<List<SystemFunctionUserGroupAndUserViewModel>> GetSystemFunctionActorList(SystemFunctionsActorsGetRequestModel request)
        {
            Client.Setup(p=> p.GetSystemFunctionActorList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SystemFunctionUserGroupAndUserViewModel>().ToList());
            return Client.Object.GetSystemFunctionActorList(request);
        }

        public Task<List<SystemFunctionViewModel>> GetSystemFunctionList(SystemFunctionsGetRequestModel request)
        {
            Client.Setup(p=> p.GetSystemFunctionList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SystemFunctionViewModel>().ToList());
            return Client.Object.GetSystemFunctionList(request);
        }

        public Task<List<SystemFunctionUserPermissionViewModel>> GetSystemFunctionPermissionList(SystemFunctionPermissionGetRequestModel request)
        {
            Client.Setup(p=> p.GetSystemFunctionPermissionList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SystemFunctionUserPermissionViewModel>().ToList());
            return Client.Object.GetSystemFunctionPermissionList(request);
        }

        public Task<SystemFunctionUserPermissionSaveResponseModel> SaveSystemFunctionUsePermission(SystemFunctionsUserPermissionsSetParams request)
        {
            Client.Setup(p=> p.SaveSystemFunctionUsePermission(request)).ReturnsAsync(BaseArrangement.Fixture.Create< SystemFunctionUserPermissionSaveResponseModel>());
            return Client.Object.SaveSystemFunctionUsePermission(request);
        }
    }
}
