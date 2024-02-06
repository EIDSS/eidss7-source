using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class AggregateSettingsClientMock : BaseClientMock<IAggregateSettingsClient>, IAggregateSettingsClient
    {
        public Task<List<AggregateSettingsViewModel>> GetAggregateSettingsList(AggregateSettingsGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetAggregateSettingsList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< AggregateSettingsViewModel>().ToList());
            return Client.Object.GetAggregateSettingsList(request);
        }

        public Task<APISaveResponseModel> SaveAggregateSettings(AggregateSettingsSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveAggregateSettings(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveAggregateSettings(request);
        }
    }
}
