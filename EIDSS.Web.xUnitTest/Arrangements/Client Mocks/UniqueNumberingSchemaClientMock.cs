using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
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
    public class UniqueNumberingSchemaClientMock : BaseClientMock<IUniqueNumberingSchemaClient>, IUniqueNumberingSchemaClient
    {
        public Task<List<UniqueNumberingSchemaListViewModel>> GetUniqueNumberingSchemaListAsync(UniqueNumberingSchemaGetRequestModel request)
        {
            Client.Setup(p=> p.GetUniqueNumberingSchemaListAsync(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< UniqueNumberingSchemaListViewModel>().ToList());
            return Client.Object.GetUniqueNumberingSchemaListAsync(request);
        }

        public Task<UniqueNumberingSchemaSaveResquestResponseModel> SaveUniqueNumberingSchemaAsync(UniqueNumberingSchemaSaveRequestModel saveRequestModel)
        {
            Client.Setup(prop=> prop.SaveUniqueNumberingSchemaAsync(saveRequestModel)).ReturnsAsync(BaseArrangement.Fixture.Create< UniqueNumberingSchemaSaveResquestResponseModel>());
            return Client.Object.SaveUniqueNumberingSchemaAsync(saveRequestModel);
        }
    }
}
