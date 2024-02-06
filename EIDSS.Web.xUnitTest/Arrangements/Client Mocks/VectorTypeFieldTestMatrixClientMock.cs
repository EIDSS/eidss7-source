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
    public class VectorTypeFieldTestMatrixClientMock : BaseClientMock<IVectorTypeFieldTestMatrixClient>, IVectorTypeFieldTestMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVectorTypeFieldTestMatrix(long idfPensideTestTypeForVectorType, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteVectorTypeFieldTestMatrix(idfPensideTestTypeForVectorType, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVectorTypeFieldTestMatrix(idfPensideTestTypeForVectorType, deleteAnyway);
        }

        public Task<List<ConfigurationMatrixViewModel>> GetVectorTypeFieldTestMatrixList(VectorTypeFieldTestMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetVectorTypeFieldTestMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ConfigurationMatrixViewModel>().ToList());
            return Client.Object.GetVectorTypeFieldTestMatrixList(request);
        }

        public Task<VectorTypeFieldTestMatrixSaveRequestResponseModel> SaveVectorTypeFieldTestMatrix(VectorTypeFieldTestMatrixSaveRequestModel request)
        {
            Client.Setup(prop => prop.SaveVectorTypeFieldTestMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.Create<VectorTypeFieldTestMatrixSaveRequestResponseModel>());
            return Client.Object.SaveVectorTypeFieldTestMatrix(request);
        }
    }
}
