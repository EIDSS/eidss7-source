using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class LaboratoryClientMock : BaseClientMock<ILaboratoryClient>, ILaboratoryClient
    {
        public Task<List<ApprovalsGetListViewModel>> GetApprovalsAdvancedSearchList(ApprovalsGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<ApprovalsGetListViewModel>> GetApprovalsList(ApprovalsGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<ApprovalsGetListViewModel>> GetApprovalsSimpleSearchList(ApprovalsGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<BatchesGetListViewModel>> GetBatchesAdvancedSearchList(BatchesGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<BatchesGetListViewModel>> GetBatchesList(BatchesGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesAdvancedSearchList(MyFavoritesGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesList(MyFavoritesGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesSimpleSearchList(MyFavoritesGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<SampleGetDetailViewModel> GetSampleDetail(string languageID, long sampleID, long userID)
        {
            throw new NotImplementedException();
        }

        public Task<List<SamplesGetListViewModel>> GetSamplesAdvancedSearchList(SampleGetRequestModel request)
        {
            Client.Setup(p=> p.GetSamplesAdvancedSearchList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SamplesGetListViewModel>().ToList());
            return Client.Object.GetSamplesAdvancedSearchList(request);
        }


        public Task<List<SamplesGetListViewModel>> GetSamplesList(SampleGetRequestModel request)
        {
            Client.Setup(p=> p.GetSamplesList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SamplesGetListViewModel>().ToList());
            return Client.Object.GetSamplesList(request);
        }


        public Task<List<SamplesGetListViewModel>> GetSamplesSimpleSearchList(SampleGetRequestModel request)
        {
            Client.Setup(p=> p.GetSamplesSimpleSearchList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SamplesGetListViewModel>().ToList());
            return Client.Object.GetSamplesSimpleSearchList(request);
        }

        public Task<List<TestAmendmentsGetListViewModel>> GetTestAmendmentList(TestAmendmentGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<TestGetDetailViewModel> GetTestDetail(string languageID, long testID, long userID)
        {
            throw new NotImplementedException();
        }

        public Task<List<TestingGetListViewModel>> GetTestingAdvancedSearchList(TestingGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<TestingGetListViewModel>> GetTestingList(TestingGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<TestingGetListViewModel>> GetTestingSimpleSearchList(TestingGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<TransferGetDetailViewModel> GetTransferDetail(string languageID, long transferID, long userID)
        {
            throw new NotImplementedException();
        }

        public Task<List<TransferredGetListViewModel>> GetTransferredAdvancedSearchList(TransferredGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<TransferredGetListViewModel>> GetTransferredList(TransferredGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<TransferredGetListViewModel>> GetTransferredSimpleSearchList(TransferredGetRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<APISaveResponseModel> SaveLaboratory(LaboratorySaveRequestModel request)
        {
            throw new NotImplementedException();
        }
    }
}
