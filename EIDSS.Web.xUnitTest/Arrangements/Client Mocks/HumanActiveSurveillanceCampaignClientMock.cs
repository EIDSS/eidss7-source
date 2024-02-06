using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class HumanActiveSurveillanceCampaignClientMock : BaseClientMock<IHumanActiveSurveillanceCampaignClient>, IHumanActiveSurveillanceCampaignClient
    {
        public Task<List<HumanActiveSurveillanceCampaignViewModel>> GetHumanActiveServiellanceCampaign(HumanActiveSurveillanceCampaignRequestModel request)
        {
            Client.Setup(p=> p.GetHumanActiveServiellanceCampaign(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< HumanActiveSurveillanceCampaignViewModel>().ToList());
            return Client.Object.GetHumanActiveServiellanceCampaign(request);
        }
    }
}
