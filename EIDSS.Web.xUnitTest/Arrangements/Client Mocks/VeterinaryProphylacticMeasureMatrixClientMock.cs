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

    public class VeterinaryProphylacticMeasureMatrixClientMock : BaseClientMock<IVeterinaryProphylacticMeasureMatrixClient>, IVeterinaryProphylacticMeasureMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVeterinaryProphylacticMeasureMatrixRecord(long idfAggrProphylacticActionMTX)
        {
            Client.Setup(p=> p.DeleteVeterinaryProphylacticMeasureMatrixRecord(idfAggrProphylacticActionMTX)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVeterinaryProphylacticMeasureMatrixRecord(idfAggrProphylacticActionMTX);
        }

        public Task<List<VeterinaryProphylacticMeasureMatrixViewModel>> GetVeterinaryProphylacticMeasureMatrixReport(VeterinaryProphylacticMeasureMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetVeterinaryProphylacticMeasureMatrixReport(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< VeterinaryProphylacticMeasureMatrixViewModel>().ToList());
            return Client.Object.GetVeterinaryProphylacticMeasureMatrixReport(request);
        }

        public Task<List<InvestigationTypeViewModel>> GetVeterinaryProphylacticMeasureTypes(long idfsBaseReference, int intHACode, string languageId)
        {
            Client.Setup(prop=> prop.GetVeterinaryProphylacticMeasureTypes(idfsBaseReference,intHACode,languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InvestigationTypeViewModel>().ToList());
            return Client.Object.GetVeterinaryProphylacticMeasureTypes(idfsBaseReference, intHACode, languageId);
        }

        public Task<APIPostResponseModel> SaveVeterinaryProphylacticMeasureMatrix(MatrixViewModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveVeterinaryProphylacticMeasureMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveVeterinaryProphylacticMeasureMatrix(saveRequestModel);
        }
    }
}
