using AutoFixture;
using Moq;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class ConfigurableFiltrationClientMock : BaseClientMock<IConfigurableFiltrationClient>, IConfigurableFiltrationClient
    {
        public Task<APIPostResponseModel> DeleteAccessRule(long accessRuleID)
        {
            Client.Setup(p=> p.DeleteAccessRule(accessRuleID)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteAccessRule(accessRuleID);
        }

        public Task<List<AccessRuleActorGetListViewModel>> GetAccessRuleActorList(AccessRuleActorGetRequestModel request)
        {
            Client.Setup(p => p.GetAccessRuleActorList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<AccessRuleActorGetListViewModel>().ToList());
            return Client.Object.GetAccessRuleActorList(request);
        }

        public Task<AccessRuleGetDetailViewModel> GetAccessRuleDetail(string languageID, long accessRuleID)
        {
            Client.Setup(p => p.GetAccessRuleDetail(languageID, accessRuleID)).ReturnsAsync(BaseArrangement.Fixture.Create<AccessRuleGetDetailViewModel>());
            return Client.Object.GetAccessRuleDetail(languageID, accessRuleID);
        }

        public Task<List<AccessRuleGetListViewModel>> GetAccessRuleList(AccessRuleGetRequestModel request)
        {
            Client.Setup(p => p.GetAccessRuleList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<AccessRuleGetListViewModel>().ToList());
            return Client.Object.GetAccessRuleList(request);
        }

        public Task<APISaveResponseModel> SaveAccessRule(AccessRuleSaveRequestModel request)
        {
            Client.Setup(p => p.SaveAccessRule(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveAccessRule(request);
        }
    }
}
