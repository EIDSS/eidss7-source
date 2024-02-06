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
    public class CaseClassificationClientMock : BaseClientMock<ICaseClassificationClient>, ICaseClassificationClient
    {
        public Task<APIPostResponseModel> DeleteCaseClassification(long CaseClassificationId, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteCaseClassification(CaseClassificationId, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteCaseClassification(CaseClassificationId, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetCaseClassificationList(CaseClassificationGetRequestModel CaseClassificationGetRequestModel)
        {
            Client.Setup(p => p.GetCaseClassificationList(CaseClassificationGetRequestModel)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList());
            return Client.Object.GetCaseClassificationList(CaseClassificationGetRequestModel);
        }

        public Task<APISaveResponseModel> SaveCaseClassification(CaseClassificationSaveRequestModel saveRequestModel)
        {
            Client.Setup(p => p.SaveCaseClassification(saveRequestModel)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveCaseClassification(saveRequestModel);
        }
    }
}
