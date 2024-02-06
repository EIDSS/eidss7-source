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
    public class VectorTypeCollectionMethodMatrixClientMock : BaseClientMock<IVectorTypeCollectionMethodMatrixClient>, IVectorTypeCollectionMethodMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVectorTypeCollectionmethodMatrix(long idfCollectionMethodForVectorType, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteVectorTypeCollectionmethodMatrix(idfCollectionMethodForVectorType, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVectorTypeCollectionmethodMatrix(idfCollectionMethodForVectorType, deleteAnyway);
        }

        public Task<List<VectorTypeCollectionMethodMatrixViewModel>> GetVectorTypeCollectionMethodMatrixList(VectorTypeCollectionMethodMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetVectorTypeCollectionMethodMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< VectorTypeCollectionMethodMatrixViewModel>().ToList());
            return Client.Object.GetVectorTypeCollectionMethodMatrixList(request);
        }

        public Task<VectorTypeCollectionMethodMatrixSaveRequestResponseModel> SaveVectorTypeCollectionMethodMatrix(VectorTypeCollectionMethodMatrixSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveVectorTypeCollectionMethodMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.Create<VectorTypeCollectionMethodMatrixSaveRequestResponseModel>());
            return Client.Object.SaveVectorTypeCollectionMethodMatrix(request);
        }
    }
}
