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
    public class HumanAggregateDiseaseMatrixClientMock : BaseClientMock<IHumanAggregateDiseaseMatrixClient>, IHumanAggregateDiseaseMatrixClient
    {
        public Task<APIPostResponseModel> DeleteHumanAggregateDiseaseMatrixRecord(long idfAggrHumanCaseMTX)
        {
            Client.Setup(p=> p.DeleteHumanAggregateDiseaseMatrixRecord(idfAggrHumanCaseMTX)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteHumanAggregateDiseaseMatrixRecord(idfAggrHumanCaseMTX);
        }

        public Task<List<HumanAggregateDiseaseMatrixViewModel>> GetHumanAggregateDiseaseMatrixList(HumanAggregateCaseMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetHumanAggregateDiseaseMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< HumanAggregateDiseaseMatrixViewModel>().ToList());
            return Client.Object.GetHumanAggregateDiseaseMatrixList(request);
        }

        public Task<List<HumanDiseaseDiagnosisListViewModel>> GetHumanDiseaseDiagnosisMatrixListAsync(long usingType, long intHACode, string strLanguageID)
        {
            Client.Setup(p=> p.GetHumanDiseaseDiagnosisMatrixListAsync(usingType, intHACode, strLanguageID)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< HumanDiseaseDiagnosisListViewModel>().ToList());
            return Client.Object.GetHumanDiseaseDiagnosisMatrixListAsync(usingType, intHACode, strLanguageID);
        }

        public Task<APIPostResponseModel> SaveHumanAggregateDiseaseMatrix(MatrixViewModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveHumanAggregateDiseaseMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveHumanAggregateDiseaseMatrix(saveRequestModel);
        }
    }
}
