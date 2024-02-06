using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
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
    public class ILIAggregateFormClientMock : BaseClientMock<IILIAggregateFormClient>, IILIAggregateFormClient
    {
        public Task<APIPostResponseModel> DeleteILIAggregateDetail(string userId, long idfAggregateDetail)
        {
            throw new NotImplementedException();
        }

        public Task<APIPostResponseModel> DeleteILIAggregateHeader(long idfAggregateHeader)
        {
            throw new NotImplementedException();
        }

        public Task<List<ILIAggregateViewModel>> GetILIAggregateDetailList(ILIAggregateFormDetailRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<ILIAggregateViewModel>> GetILIAggregateList(ILIAggregateFormSearchRequestModel request)
        {
            Client.Setup(p=> p.GetILIAggregateList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ILIAggregateViewModel>().ToList());
            return Client.Object.GetILIAggregateList(request);
        }

        public Task<ILIAggregateDetailSaveRequestModel> SaveILIAggregateDetail(ILIAggregateDetailSaveRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<ILIAggregateSaveRequestModel> SaveILIAggregateHeader(ILIAggregateSaveRequestModel request)
        {
            throw new NotImplementedException();
        }
    }
}
