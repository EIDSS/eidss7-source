using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
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

    public class VeterinarySanitaryActionMatrixClientMock : BaseClientMock<IVeterinarySanitaryActionMatrixClient>, IVeterinarySanitaryActionMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVeterinarySanitaryActionMatrixRecord(long idfAggrSanitaryActionMTX)
        {
            Client.Setup(p=> p.DeleteVeterinarySanitaryActionMatrixRecord(idfAggrSanitaryActionMTX)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVeterinarySanitaryActionMatrixRecord(idfAggrSanitaryActionMTX);
        }

        public Task<List<VeterinarySanitaryActionMatrixViewModel>> GetVeterinarySanitaryActionMatrixReport(long idfVersion)
        {
            Client.Setup(p=> p.GetVeterinarySanitaryActionMatrixReport(idfVersion)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< VeterinarySanitaryActionMatrixViewModel>().ToList());
            return Client.Object.GetVeterinarySanitaryActionMatrixReport(idfVersion);
        }

        public Task<List<InvestigationTypeViewModel>> GetVeterinarySanitaryActionTypes(long idfsBaseReference, int intHACode, string languageId)
        {
            Client.Setup(prop=> prop.GetVeterinarySanitaryActionTypes(idfsBaseReference, intHACode, languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InvestigationTypeViewModel>().ToList());
            return Client.Object.GetVeterinarySanitaryActionTypes(idfsBaseReference, intHACode, languageId);
        }

        public Task<APIPostResponseModel> SaveVeterinarySanitaryActionMatrix(MatrixViewModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveVeterinarySanitaryActionMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveVeterinarySanitaryActionMatrix(saveRequestModel);
        }
    }
}
