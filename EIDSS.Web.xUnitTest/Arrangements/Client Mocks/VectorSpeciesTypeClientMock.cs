using AutoFixture;
using Moq;
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
    public class VectorSpeciesTypeClientMock : BaseClientMock<IVectorSpeciesTypeClient>, IVectorSpeciesTypeClient
    {
        public Task<APIPostResponseModel> DeleteVectorSpeciesType(long VectorSpeciesTypeId, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteVectorSpeciesType(VectorSpeciesTypeId, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVectorSpeciesType(VectorSpeciesTypeId, deleteAnyway);

        }

        public Task<List<BaseReferenceEditorsViewModel>> GetVectorSpeciesTypeList(VectorSpeciesTypesGetRequestModel VectorSpeciesTypesGetRequestModel)
        {
            Client.Setup(p => p.GetVectorSpeciesTypeList(VectorSpeciesTypesGetRequestModel)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList());
            return Client.Object.GetVectorSpeciesTypeList(VectorSpeciesTypesGetRequestModel);
        }

        public Task<APISaveResponseModel> SaveVectorSpeciesType(VectorSpeciesTypesSaveRequestModel saveRequestModel)
        {
            Client.Setup(p => p.SaveVectorSpeciesType(saveRequestModel)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveVectorSpeciesType(saveRequestModel);
        }
    }
}
