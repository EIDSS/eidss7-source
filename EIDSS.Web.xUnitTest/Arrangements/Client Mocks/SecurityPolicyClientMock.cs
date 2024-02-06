using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
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
    public class SecurityPolicyClientMock : BaseClientMock<ISecurityPolicyClient>, ISecurityPolicyClient
    {
        public Task<SecurityConfigurationViewModel> GetSecurityPolicy()
        {
            Client.Setup(p=> p.GetSecurityPolicy()).ReturnsAsync(BaseArrangement.Fixture.Create<SecurityConfigurationViewModel>());
            return Client.Object.GetSecurityPolicy();
        }

        public Task<APISaveResponseModel> SaveSecurityPolicy(SecurityPolicySaveRequestModel request)
        {
            Client.Setup(p=> p.SaveSecurityPolicy(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveSecurityPolicy(request);
        }
    }
}
