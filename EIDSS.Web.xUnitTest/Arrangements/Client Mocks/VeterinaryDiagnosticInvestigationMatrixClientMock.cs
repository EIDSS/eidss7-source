using AutoFixture;
using Moq;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.RequestModels.Configuration;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class VeterinaryDiagnosticInvestigationMatrixClientMock : BaseClientMock<IVeterinaryDiagnosticInvestigationMatrixClient>, IVeterinaryDiagnosticInvestigationMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVeterinaryDiagnosticInvestigationMatrixRecord(long idfAggrDiagnosticActionMtx)
        {
            Client.Setup(p=> p.DeleteVeterinaryDiagnosticInvestigationMatrixRecord(idfAggrDiagnosticActionMtx)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVeterinaryDiagnosticInvestigationMatrixRecord(idfAggrDiagnosticActionMtx);
        }

        public Task<List<InvestigationTypeViewModel>> GetInvestigationTypeMatrixListAsync(long idfsBaseReference, int intHACode, string languageId)
        {
            Client.Setup(p=> p.GetInvestigationTypeMatrixListAsync(idfsBaseReference, intHACode, languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InvestigationTypeViewModel>().ToList());
            return Client.Object.GetInvestigationTypeMatrixListAsync(idfsBaseReference, intHACode, languageId);
        }

        public Task<List<InvestigationTypeViewModel>> GetInvestigationTypeMatrixListAsync(long idfsBaseReference, int? intHACode, string strLanguageId)
        {
            Client.Setup(p=> p.GetInvestigationTypeMatrixListAsync(idfsBaseReference, intHACode,strLanguageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InvestigationTypeViewModel>().ToList());
            return Client.Object.GetInvestigationTypeMatrixListAsync(idfsBaseReference, intHACode, strLanguageId);
        }

        public Task<List<VeterinaryDiagnosticInvestigationMatrixReportModel>> GetVeterinaryDiagnosticInvestigationMatrixReport(MatrixGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetVeterinaryDiagnosticInvestigationMatrixReport(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< VeterinaryDiagnosticInvestigationMatrixReportModel>().ToList());
            return Client.Object.GetVeterinaryDiagnosticInvestigationMatrixReport(request);
        }

        public Task<APIPostResponseModel> SaveVeterinaryDiagnosticInvestigationMatrix(MatrixViewModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveVeterinaryDiagnosticInvestigationMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveVeterinaryDiagnosticInvestigationMatrix(saveRequestModel);
        }
    }
}
