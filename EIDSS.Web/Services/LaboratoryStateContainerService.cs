#region Usings

using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using System.Collections.Generic;

#endregion

namespace EIDSS.Web.Services
{
    public class LaboratoryStateContainerService
    {
        #region Globals

        public List<BaseReferenceViewModel> AccessionConditionTypes { get; set; }
        public List<BaseReferenceViewModel> AccessionConditionTypesWithoutUnaccessioned { get; set; }
        public List<DepartmentGetListViewModel> FunctionalAreas;
        public List<BaseReferenceViewModel> SampleStatusTypes;
        public List<BaseReferenceViewModel> TestCategoryTypes;
        public List<BaseReferenceViewModel> TestNameTypes;
        public List<TestNameTestResultsMatrixViewModel> TestResultTypes;
        public List<BaseReferenceViewModel> TestStatusTypes;
        public List<BaseReferenceViewModel> RestrictedTestStatusTypes;
        public List<BaseReferenceViewModel> ExternalTestStatusTypes;
        public IList<SamplesGetListViewModel> Samples { get; set; }
        public IList<SamplesGetListViewModel> SelectedSamples { get; set; }
        public IList<SamplesGetListViewModel> PendingSaveSamples { get; set; } = new List<SamplesGetListViewModel>();
        public IList<SamplesGetListViewModel> SearchSamples { get; set; }
        public IList<TestingGetListViewModel> Testing { get; set; }
        public IList<TestingGetListViewModel> SelectedTesting { get; set; }
        public IList<TestingGetListViewModel> PendingSaveTesting { get; set; } = new List<TestingGetListViewModel>();
        public IList<TestingGetListViewModel> SearchTesting { get; set; }
        public IList<TestingGetListViewModel> SearchBatchTests { get; set; }
        public IList<TransferredGetListViewModel> Transferred { get; set; }
        public IList<TransferredGetListViewModel> SelectedTransferred { get; set; }
        public IList<TransferredGetListViewModel> PendingSaveTransferred { get; set; } = new List<TransferredGetListViewModel>();
        public IList<TransferredGetListViewModel> SearchTransferred { get; set; }
        public IList<MyFavoritesGetListViewModel> MyFavorites { get; set; }
        public IList<MyFavoritesGetListViewModel> SelectedMyFavorites { get; set; }
        public IList<MyFavoritesGetListViewModel> PendingSaveMyFavorites { get; set; } =
            new List<MyFavoritesGetListViewModel>();
        public IList<MyFavoritesGetListViewModel> SearchMyFavorites { get; set; }
        public IList<BatchesGetListViewModel> Batches { get; set; }
        public IList<BatchesGetListViewModel> SelectedBatches { get; set; }
        public IList<BatchesGetListViewModel> PendingSaveBatches { get; set; } = new List<BatchesGetListViewModel>();
        public IList<BatchesGetListViewModel> SearchBatches { get; set; }
        public IList<TestingGetListViewModel> SelectedBatchTests { get; set; }
        public IList<ApprovalsGetListViewModel> Approvals { get; set; }
        public IList<ApprovalsGetListViewModel> SelectedApprovals { get; set; }
        public IList<ApprovalsGetListViewModel> PendingSaveApprovals { get; set; } = new List<ApprovalsGetListViewModel>();
        public List<ApprovalsGetListViewModel> SearchApprovals { get; set; }
        public IList<TestAmendmentsSaveRequestModel> PendingSaveTestAmendments { get; set; } = new List<TestAmendmentsSaveRequestModel>();
        public List<FreezerSubdivisionViewModel> FreezerSubdivisions { get; set; } = new();
        public IList<FreezerBoxLocationAvailabilitySaveRequestModel> PendingSaveAvailableFreezerBoxLocations { get; set; } = new List<FreezerBoxLocationAvailabilitySaveRequestModel>();
        public IList<EventSaveRequestModel> PendingSaveEvents { get; set; } = new List<EventSaveRequestModel>();
        public int NewSamplesRegisteredCount { get; set; }
        public int NewSamplesFromMyFavoritesRegisteredCount { get; set; }
        public int NewTestsAssignedCount { get; set; }
        public bool TabChangeIndicator { get; set; }
        public string PrintBarcodeSamples { get; set; }
        public bool TestResultExternalEnteredOrValidationRejectedIndicator { get; set; }
        public bool? TestUnassignedIndicator { get; set; }
        public bool? TestCompletedIndicator { get; set; }

        #endregion

        #region Methods

        #endregion
    }
}
