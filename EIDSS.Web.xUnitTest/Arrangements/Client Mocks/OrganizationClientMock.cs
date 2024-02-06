using AutoFixture;
using Moq;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
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
    public class OrganizationClientMock : BaseClientMock<IOrganizationClient>, IOrganizationClient
    {
        public Task<APIPostResponseModel> DeleteOrganization(long organizationID, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteOrganization(organizationID, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteOrganization(organizationID, deleteAnyway);
        }

        public Task<List<OrganizationAdvancedGetListViewModel>> GetOrganizationAdvancedList(OrganizationAdvancedGetRequestModel request)
        {
            Client.Setup(p => p.GetOrganizationAdvancedList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<OrganizationAdvancedGetListViewModel>().ToList());
            return Client.Object.GetOrganizationAdvancedList(request);
        }
        public Task<OrganizationGetDetailViewModel> GetOrganizationDetail(string languageID, long organizationID)
        {
            Client.Setup(prop=> prop.GetOrganizationDetail(languageID, organizationID)).ReturnsAsync(BaseArrangement.Fixture.Create<OrganizationGetDetailViewModel>());
            return Client.Object.GetOrganizationDetail(languageID, organizationID);
        }

        public Task<List<OrganizationGetListViewModel>> GetOrganizationList(OrganizationGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetOrganizationList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< OrganizationGetListViewModel>().ToList());
            return Client.Object.GetOrganizationList(request);
        }

        public Task<APISaveResponseModel> SaveOrganization(OrganizationSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveOrganization(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveOrganization(request);
        }
    }
}
