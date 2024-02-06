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
    public class ReportDiseaseGroupClientMock : BaseClientMock<IReportDiseaseGroupClient>, IReportDiseaseGroupClient
    {
        public Task<APIPostResponseModel> DeleteReportDiseaseGroup(long reportDiseaseGroupId, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteReportDiseaseGroup(reportDiseaseGroupId, deleteAnyway)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.DeleteReportDiseaseGroup(reportDiseaseGroupId, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetReportDiseaseGroupsList(ReportDiseaseGroupsGetRequestModel reportDiseaseGroupGetRequestModel)
        {
            Client.Setup(p => p.GetReportDiseaseGroupsList(reportDiseaseGroupGetRequestModel)).Returns(Task.FromResult(
                BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetReportDiseaseGroupsList(reportDiseaseGroupGetRequestModel);
        }

        public Task<ReportDiseaseGroupsSaveRequestResponseModel> SaveReportDiseaseGroup(ReportDiseaseGroupsSaveRequestModel saveRequestModel)
        {
            Client.Setup(p => p.SaveReportDiseaseGroup(saveRequestModel)).Returns(Task.FromResult(BaseArrangement.Fixture.Create<ReportDiseaseGroupsSaveRequestResponseModel>()));
            return Client.Object.SaveReportDiseaseGroup(saveRequestModel);
        }
    }
}
