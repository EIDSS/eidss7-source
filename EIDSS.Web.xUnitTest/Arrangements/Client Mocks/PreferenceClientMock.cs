using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class PreferenceClientMock : BaseClientMock<IPreferenceClient>, IPreferenceClient
    {
        public PreferenceClientMock()
        {

        }
        public Task<SystemPreferences> InitializeSystemPreferences()
        {
            Client.Setup(p => p.InitializeSystemPreferences()).Returns(Task.FromResult(BaseArrangement.SystemPreferences));
            return Client.Object.InitializeSystemPreferences();
        }

        public Task<UserPreferences> InitializeUserPreferences(long userId)
        {
            Client.Setup(p => p.InitializeUserPreferences(userId)).Returns(Task.FromResult(BaseArrangement.UserPreferences));
            return Client.Object.InitializeUserPreferences(userId);
        }

        public Task<SystemPreferenceSaveResponseModel> SetSystemPreferences(SystemPreferences sysprefs)
        {
            Client.Setup(p => p.SetSystemPreferences(sysprefs)).Returns(
                Task.FromResult(BaseArrangement.Fixture.Create<SystemPreferenceSaveResponseModel>()));
            return Client.Object.SetSystemPreferences(sysprefs);
        }

        public Task<UserPreferenceSaveResponseModel> SetUserPreferences(UserPreferences userPrefs)
        {
            Client.Setup(p => p.SetUserPreferences(userPrefs)).Returns(Task.FromResult(
                BaseArrangement.Fixture.Create<UserPreferenceSaveResponseModel>()));
            return Client.Object.SetUserPreferences(userPrefs);

        }
    }
}
