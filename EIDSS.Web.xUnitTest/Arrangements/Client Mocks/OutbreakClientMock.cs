using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class OutbreakClientMock : BaseClientMock<IOutbreakClient>, IOutbreakClient
    {
        public Task<APIPostResponseModel> DeleteSessionNote(OutbreakSessionNoteDeleteRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<OutbreakCaseListModel>> GetCasesList(OutbreakCaseListRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<OutbreakSessionListViewModel>> GetOutbreakSessionList(OutbreakSessionListRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<OutbreakSessionDetailsResponseModel>> GetSessionDetail(OutbreakSessionDetailRequestModel request)
        {
            Client.Setup(p => p.GetSessionDetail(request)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<OutbreakSessionDetailsResponseModel>().ToList()));
            return Client.Object.GetSessionDetail(request);
        }

        public Task<List<OutbreakSessionListViewModel>> GetSessionList(OutbreakSessionListRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<OutbreakSessionNoteDetailsViewModel> GetSessionNoteDetails(OutbreakSessionNoteDetailsRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<OutbreakSessionNoteListViewModel>> GetSessionNoteList(OutbreakSessionNoteListRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<OutbreakSessionParametersListModel>> GetSessionParametersList(OutbreakSessionDetailRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<OutbreakCaseSaveResponseModel> SetCase(OutbreakCaseCreateRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<APISaveResponseModel> SetOutbreakSession(OutbreakSessionCreateRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<OutbreakSessionDetailsSaveResponseModel> SetSession(OutbreakSessionCreateRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<OutbreakSessionNoteSaveResponseModel> SetSessionNote(OutbreakSessionNoteCreateRequestModel request)
        {
            throw new NotImplementedException();
        }
    }
}
