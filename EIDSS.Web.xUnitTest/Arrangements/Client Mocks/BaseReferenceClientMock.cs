using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class BaseClientMock : BaseClientMock<IBaseReferenceClient>, IBaseReferenceClient
    {
        public Task<List<BaseReferenceListViewModel>> GetBaseReferenceList(long idfsreferenceType, string langId)
        {
            Client.Setup(p => p.GetBaseReferenceList(idfsreferenceType, langId)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceListViewModel>().ToList()));
            return Client.Object.GetBaseReferenceList(idfsreferenceType, langId);
        }
    }
}
