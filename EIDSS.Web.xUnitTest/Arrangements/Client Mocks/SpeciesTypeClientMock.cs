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
    public class SpeciesTypeClientMock : BaseClientMock<ISpeciesTypeClient>, ISpeciesTypeClient
    {
        public Task<APIPostResponseModel> DeleteSpeciesType(long speciesTypeId, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteSpeciesType(speciesTypeId, deleteAnyway)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.DeleteSpeciesType(speciesTypeId, deleteAnyway);
        }

        public Task<List<HACodeListViewModel>> GetHACodeList(string langId, int? intHACodeMask)
        {
            Client.Setup(p => p.GetHACodeList(langId, intHACodeMask)).Returns(
                Task.FromResult(BaseArrangement.Fixture.CreateMany<HACodeListViewModel>().ToList()));
            return Client.Object.GetHACodeList(langId, intHACodeMask);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetSpeciesTypeList(SpeciesTypeGetRequestModel request)
        {
            Client.Setup(p => p.GetSpeciesTypeList(request)).Returns(
                Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetSpeciesTypeList(request);
        }

        public Task<SpeciesTypeSaveRequestResponseModel> SaveSpeciesType(SpeciesTypeSaveRequestModel speciesTypeModel)
        {
            Client.Setup(p => p.SaveSpeciesType(speciesTypeModel)).Returns(Task.FromResult(
                BaseArrangement.Fixture.Create<SpeciesTypeSaveRequestResponseModel>()));
            return Client.Object.SaveSpeciesType(speciesTypeModel);
        }
    }
}
