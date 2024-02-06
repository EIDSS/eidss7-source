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
    public class DiseaseHumanGenderMatrixClientMock : BaseClientMock<IDiseaseHumanGenderMatrixClient>, IDiseaseHumanGenderMatrixClient
    {
        public Task<APIPostResponseModel> DeleteDiseaseHumanGenderMatrix(long DisgnosisGroupToGenderUID)
        {
            Client.Setup(p=> p.DeleteDiseaseHumanGenderMatrix(DisgnosisGroupToGenderUID)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteDiseaseHumanGenderMatrix(DisgnosisGroupToGenderUID);
        }

        public Task<List<DiseaseHumanGenderMatrixViewModel>> GetDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetDiseaseHumanGenderMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<DiseaseHumanGenderMatrixViewModel>().ToList());
            return Client.Object.GetDiseaseHumanGenderMatrix(request);
        }

        public Task<APISaveResponseModel> SaveDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixSaveRequestModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveDiseaseHumanGenderMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveDiseaseHumanGenderMatrix(saveRequestModel);
        }
    }
}
