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
    public class MeasuresClientMock : BaseClientMock<IMeasuresClient>, IMeasuresClient
    {
        public Task<APIPostResponseModel> DeleteMeasure(long? idfsAction, long? idfsMeasureList, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteMeasure(idfsAction, idfsMeasureList, deleteAnyway)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return DeleteMeasure(idfsAction, idfsMeasureList, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetMeasuresDropDownList(string langId)
        {
            Client.Setup(p => p.GetMeasuresDropDownList(langId)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetMeasuresDropDownList(langId);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetMeasuresList(MeasuresGetRequestModel measuresGetRequestModel)
        {
            Client.Setup(p => p.GetMeasuresList(measuresGetRequestModel)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetMeasuresList(measuresGetRequestModel);
        }

        public Task<MeasuresSaveRequestResponseModel> SaveMeasure(MeasuresSaveRequestModel saveRequestModel)
        {
            Client.Setup(p => p.SaveMeasure(saveRequestModel)).Returns(Task.FromResult(BaseArrangement.Fixture.Create<MeasuresSaveRequestResponseModel>()));
            return Client.Object.SaveMeasure(saveRequestModel);

        }
    }
}
