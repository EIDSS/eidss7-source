using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
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
    public class SettlementClientMock : BaseClientMock<ISettlementClient>, ISettlementClient
    {
        public Task<List<SettlementTypeModel>> GetSettlementTypeList(string languageId)
        {
            Client.Setup(p=> p.GetSettlementTypeList(languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SettlementTypeModel>().ToList());
            return Client.Object.GetSettlementTypeList(languageId);
        }
    }
}
