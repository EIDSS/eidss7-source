using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class DiseaseClientMock : BaseClientMock<IDiseaseClient>, IDiseaseClient
    {
        public Task<APIPostResponseModel> DeleteDisease(long idfsDiagnosis, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteDisease(idfsDiagnosis, deleteAnyway)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.DeleteDisease(idfsDiagnosis, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetDiseasesList(DiseasesGetRequestModel request)
        {
            Client.Setup(p => p.GetDiseasesList(request)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetDiseasesList(request);
        }

        public Task<APIPostResponseModel> SaveDisease(DiseaseSaveRequestModel diseaseModel)
        {
            Client.Setup(p => p.SaveDisease(diseaseModel)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.SaveDisease(diseaseModel);
        }
    }
}
