using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class LocalizationClientMock : BaseClientMock<ILocalizationClient>, ILocalizationClient
    {
        public Task<List<LanguageModel>> GetLanguageList(string languageID)
        {

            Client.Setup(p => p.GetLanguageList(languageID)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<LanguageModel>().ToList()));
            return Client.Object.GetLanguageList(languageID);
        }

        public Task<List<ResourceModel>> GetResourceList(string cultureName)
        {
            Client.Setup(p => p.GetResourceList(cultureName));
            return Client.Object.GetResourceList(cultureName);
        }
    }
}
