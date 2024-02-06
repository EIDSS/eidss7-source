using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
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
    public class SiteAlertsSubscriptionClientMock : BaseClientMock<ISiteAlertsSubscriptionClient>, ISiteAlertsSubscriptionClient
    {
        public Task<List<EventSubscriptionTypeModel>> GetSiteAlertsSubscriptionList(EventSubscriptionGetRequestModel model)
        {
            Client.Setup(p => p.GetSiteAlertsSubscriptionList(model)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<EventSubscriptionTypeModel>().ToList());
            return Client.Object.GetSiteAlertsSubscriptionList(model);
        }

        public Task<SitelAlertsSubcriptionSaveResponseModel> SaveSiteAlertSubcriptionEvent(SiteAlertEventSetParams request)
        {
            Client.Setup(p => p.SaveSiteAlertSubcriptionEvent(request)).ReturnsAsync(BaseArrangement.Fixture.Create<SitelAlertsSubcriptionSaveResponseModel>());
            return Client.Object.SaveSiteAlertSubcriptionEvent(request);
        }
    }
}
