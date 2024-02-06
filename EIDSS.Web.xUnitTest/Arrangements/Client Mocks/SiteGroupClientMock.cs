using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
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
    public class SiteGroupClientMock : BaseClientMock<ISiteGroupClient>, ISiteGroupClient
    {
        public Task<APIPostResponseModel> DeleteSiteGroup(long siteGroupID, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteSiteGroup(siteGroupID, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteSiteGroup(siteGroupID, deleteAnyway);
        }

        public Task<SiteGroupGetDetailViewModel> GetSiteGroupDetails(string languageID, long siteGroupID)
        {
            Client.Setup(p=> p.GetSiteGroupDetails(languageID, siteGroupID)).ReturnsAsync(BaseArrangement.Fixture.Create<SiteGroupGetDetailViewModel>());
            return Client.Object.GetSiteGroupDetails(languageID, siteGroupID);
        }

        public Task<List<SiteGroupGetListViewModel>> GetSiteGroupList(SiteGroupGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetSiteGroupList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SiteGroupGetListViewModel>().ToList());
            return Client.Object.GetSiteGroupList(request);
        }

        public Task<APISaveResponseModel> SaveSiteGroup(SiteGroupSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveSiteGroup(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveSiteGroup(request);
        }
    }
}
