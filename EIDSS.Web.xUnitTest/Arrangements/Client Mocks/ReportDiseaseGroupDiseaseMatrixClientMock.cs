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
    public class ReportDiseaseGroupDiseaseMatrixClientMock : BaseClientMock<IReportDiseaseGroupDiseaseMatrixClient>, IReportDiseaseGroupDiseaseMatrixClient
    {
        public Task<APIPostResponseModel> DeleteReportDiseaseGroupDiseaseMatrix(long idfDiagnosisToGroupForReportType, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteReportDiseaseGroupDiseaseMatrix(idfDiagnosisToGroupForReportType, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteReportDiseaseGroupDiseaseMatrix(idfDiagnosisToGroupForReportType, deleteAnyway);
        }

        public Task<List<ReportDiseaseGroupDiseaseMatrixViewModel>> GetReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetReportDiseaseGroupDiseaseMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ReportDiseaseGroupDiseaseMatrixViewModel>().ToList());
            return Client.Object.GetReportDiseaseGroupDiseaseMatrix(request);
        }

        public Task<APISaveResponseModel> SaveReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixSaveRequestModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveReportDiseaseGroupDiseaseMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveReportDiseaseGroupDiseaseMatrix(saveRequestModel);
        }
    }
}
