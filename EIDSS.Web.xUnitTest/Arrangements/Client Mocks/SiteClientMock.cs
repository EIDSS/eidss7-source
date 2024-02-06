using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
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
    public class SiteClientMock : BaseClientMock<ISiteClient>, ISiteClient
    {
        public Task<APIPostResponseModel> DeleteSite(long siteID, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteSite(siteID, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteSite(siteID, deleteAnyway);
        }

        public Task<SiteGetDetailViewModel> GetSiteDetails(string languageId, long siteId, long userId)
        {
            Client.Setup(p=> p.GetSiteDetails(languageId, siteId, userId)).ReturnsAsync(BaseArrangement.Fixture.Create<SiteGetDetailViewModel>());
            return Client.Object.GetSiteDetails(languageId, siteId, userId);
        }

        public Task<List<SiteGetListViewModel>> GetSiteList(SiteGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetSiteList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SiteGetListViewModel>().ToList());
            return Client.Object.GetSiteList(request);
        }

        public Task<APISaveResponseModel> SaveSite(SiteSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveSite(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveSite(request);
        }
    }
}
