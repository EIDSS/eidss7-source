using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
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
    public class VectorTypeSampleTypeMatrixClientMock : BaseClientMock<IVectorTypeSampleTypeMatrixClient>, IVectorTypeSampleTypeMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVectorTypeSampleTypeMatrix(long idfSampleTypeForVectorType, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteVectorTypeSampleTypeMatrix(idfSampleTypeForVectorType,deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVectorTypeSampleTypeMatrix(idfSampleTypeForVectorType, deleteAnyway);
        }

        public Task<List<VectorTypeSampleTypeMatrixViewModel>> GetVectorTypeSampleTypeMatrixList(VectorTypeSampleTypeMatrixGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetVectorTypeSampleTypeMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< VectorTypeSampleTypeMatrixViewModel>().ToList());
            return Client.Object.GetVectorTypeSampleTypeMatrixList(request);
        }

        public Task<VectorTypeSampleTypeMatrixSaveRequestResponseModel> SaveVectorTypeSampleTypeMatrix(VectorTypeSampleTypeMatrixSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveVectorTypeSampleTypeMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.Create< VectorTypeSampleTypeMatrixSaveRequestResponseModel>());
            return Client.Object.SaveVectorTypeSampleTypeMatrix(request);
        }
    }
}
