using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Administration;
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
    public class DiseaseAgeGroupMatrixClientMock : BaseClientMock<IDiseaseAgeGroupMatrixClient>, IDiseaseAgeGroupMatrixClient
    {
        public Task<AgeGroupSaveRequestResponseModel> DeleteDiseaseAgeGroupMatrixRecord(long idfDiagnosisAgeGroupToDiagnosis)
        {
            Client.Setup(p=> p.DeleteDiseaseAgeGroupMatrixRecord(idfDiagnosisAgeGroupToDiagnosis)).ReturnsAsync(BaseArrangement.Fixture.Create< AgeGroupSaveRequestResponseModel>());
            return Client.Object.DeleteDiseaseAgeGroupMatrixRecord(idfDiagnosisAgeGroupToDiagnosis);
        }

        public Task<List<DiseaseAgeGroupMatrixViewModel>> GetDiseaseAgeGroupMatrix(DiseaseAgeGroupGetRequestModel request)
        {
            Client.Setup(p=> p.GetDiseaseAgeGroupMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< DiseaseAgeGroupMatrixViewModel>().ToList());
            return Client.Object.GetDiseaseAgeGroupMatrix(request);
        }

        public Task<AgeGroupSaveRequestResponseModel> SaveDiseaseAgeGroupMatrix(DiseaseAgeGroupSaveRequestModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveDiseaseAgeGroupMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.Fixture.Create< AgeGroupSaveRequestResponseModel>());
            return Client.Object.SaveDiseaseAgeGroupMatrix(saveRequestModel);
        }
    }
}
