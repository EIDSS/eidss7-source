using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;
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
    public class AggregateDiseaseReportClientMock : BaseClientMock<IAggregateDiseaseReportClient>, IAggregateDiseaseReportClient
    {
        public Task<APIPostResponseModel> DeleteAggregateDiseaseReport(long ID)
        {
            throw new NotImplementedException();
        }

        public Task<List<AggregateDiseaseReportGetDetailViewModel>> GetAggregateDiseaseReportDetail(string LangID, long? idfsAggrCaseType, long? idfAggrCase)
        {
            throw new NotImplementedException();
        }

        public Task<List<AggregateDiseaseReportGetListViewModel>> GetAggregateDiseaseReportList(AggregateDiseaseReportSearchRequestModel request)
        {
            Client.Setup(p=> p.GetAggregateDiseaseReportList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<AggregateDiseaseReportGetListViewModel>().ToList());
            return Client.Object.GetAggregateDiseaseReportList(request);
        }

        public Task<AggregateDiseaseReportSaveResponseModel> SaveAggregateDiseaseReport(AggregateDiseaseReportSaveRequestModel request)
        {
            Client.Setup(p => p.SaveAggregateDiseaseReport(request)).Returns(Task.FromResult(BaseArrangement.Fixture.Create<AggregateDiseaseReportSaveResponseModel>()));
            return Client.Object.SaveAggregateDiseaseReport(request);
        }

        public Task<ObservationSaveResponseModel> SaveObservation(ObservationSaveRequestModel request)
        {
            Client.Setup(p => p.SaveObservation(request)).Returns(Task.FromResult(BaseArrangement.Fixture.Create<ObservationSaveResponseModel>()));
            return Client.Object.SaveObservation(request);
        }
    }
}
