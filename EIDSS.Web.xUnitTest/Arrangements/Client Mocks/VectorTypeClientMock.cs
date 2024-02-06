using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class VectorTypeClientMock : BaseClientMock<IVectorTypeClient>, IVectorTypeClient
    {
        public Task<APIPostResponseModel> DeleteVectorType(long vectorTypeId, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteVectorType(vectorTypeId, deleteAnyway)).Returns(
                Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.DeleteVectorType(vectorTypeId, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetVectorTypeList(VectorTypesGetRequestModel vectorTypesGetRequestModel)
        {
            Client.Setup(p => p.GetVectorTypeList(vectorTypesGetRequestModel)).Returns
                (Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetVectorTypeList(vectorTypesGetRequestModel);
        }

        public Task<VectorTypeSaveRequestResponseModel> SaveVectorType(VectorTypeSaveRequestModel saveRequestModel)
        {
            Client.Setup(p => p.SaveVectorType(saveRequestModel)).Returns(
                Task.FromResult(BaseArrangement.Fixture.Create<VectorTypeSaveRequestResponseModel>()));

            return Client.Object.SaveVectorType(saveRequestModel);
        }
    }
}
