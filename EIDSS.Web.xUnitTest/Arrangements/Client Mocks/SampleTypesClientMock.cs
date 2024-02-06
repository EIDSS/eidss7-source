using AutoFixture;
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
    public class SampleTypesClientMock : BaseClientMock<ISampleTypesClient>, ISampleTypesClient
    {
        public Task<APIPostResponseModel> DeleteSampleType(long sampletypeId, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteSampleType(sampletypeId, deleteAnyway)).Returns(
                Task.FromResult(BaseArrangement.APIPostResponseMock_200));

            return Client.Object.DeleteSampleType(sampletypeId, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetSampleTypesReferenceList(SampleTypesEditorGetRequestModel request)
        {
            Client.Setup(p => p.GetSampleTypesReferenceList(request)).Returns(Task.FromResult(
                BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetSampleTypesReferenceList(request);
        }

        public Task<APISaveResponseModel> SaveSampleType(SampleTypeSaveRequestModel request)
        {
            Client.Setup(p => p.SaveSampleType(request)).Returns(Task.FromResult(BaseArrangement.APISaveResponseMock));
            return Client.Object.SaveSampleType(request);
        }
    }
}
