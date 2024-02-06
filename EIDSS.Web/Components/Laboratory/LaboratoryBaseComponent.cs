#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class LaboratoryBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private IConfiguration ConfigurationService { get; set; }
        [Inject] protected LaboratoryStateContainerService LaboratoryService { get; set; }
        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] protected ITestNameTestResultsMatrixClient TestNameTestResultsMatrixClient { get; set; }
        [Inject] protected ILaboratoryClient LaboratoryClient { get; set; }
        [Inject] protected IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Properties

        public FlexFormQuestionnaireGetRequestModel FlexFormRequest { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private UserPermissions _userPermissions;

        #endregion

        #region Constants

        private const string OpeningParagraphHtmlTag = "<p>";
        private const string ClosingParagraphHtmlTag = "</p>";
        private const string TransferredDefaultSortColumn = "EIDSSTransferID";
        private const string MyFavoritesDefaultSortColumn = "EIDSSLaboratorySampleID";

        #endregion

        #endregion

        #region Constructors

        public LaboratoryBaseComponent(CancellationToken token)
        {
            _token = token;
        }

        #endregion

        #region Methods

        #region Common

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetAccessionConditionTypes()
        {
            try
            {
                if (LaboratoryService.AccessionConditionTypes == null)
                {
                    LaboratoryService.AccessionConditionTypes = await CrossCuttingClient.GetBaseReferenceList(
                        GetCurrentLanguage(), BaseReferenceConstants.AccessionCondition, HACodeList.NoneHACode);
                    LaboratoryService.AccessionConditionTypesWithoutUnaccessioned =
                        LaboratoryService.AccessionConditionTypes.ToList();
                    LaboratoryService.AccessionConditionTypes.Insert(0,
                        new BaseReferenceViewModel
                        {
                            IdfsBaseReference = 0,
                            Name = Localizer.GetString(FieldLabelResourceKeyConstants
                                .LaboratoryAdvancedSearchModalUnaccessionedFieldLabel)
                        });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetFunctionalAreas()
        {
            try
            {
                if (LaboratoryService.FunctionalAreas == null)
                {
                    DepartmentGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        OrganizationID = authenticatedUser.OfficeId,
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "DepartmentName",
                        SortOrder = SortConstants.Ascending
                    };
                    LaboratoryService.FunctionalAreas = await CrossCuttingClient.GetDepartmentList(request);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetSampleStatusTypes()
        {
            try
            {
                LaboratoryService.SampleStatusTypes ??= await CrossCuttingClient.GetBaseReferenceList(
                    GetCurrentLanguage(),
                    BaseReferenceConstants.SampleStatus, HACodeList.NoneHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestNameTypes()
        {
            try
            {
                if (LaboratoryService.TestNameTypes == null || LaboratoryService.TestNameTypes.Count == 0)
                    LaboratoryService.TestNameTypes =
                        await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.TestName, HACodeList.NoneHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestStatusTypes()
        {
            try
            {
                _userPermissions = GetUserPermissions(PagePermission.CanFinalizeLaboratoryTest);

                if (LaboratoryService.TestStatusTypes == null)
                {
                    LaboratoryService.TestStatusTypes =
                        await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.TestStatus, HACodeList.NoneHACode);

                    LaboratoryService.RestrictedTestStatusTypes = LaboratoryService.TestStatusTypes.ToList();

                    // Used for external tests associated with a transfer.
                    LaboratoryService.ExternalTestStatusTypes = LaboratoryService.TestStatusTypes.ToList();

                    var item = LaboratoryService.RestrictedTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended);
                    if (item != null)
                        LaboratoryService.RestrictedTestStatusTypes.Remove(item);
                    item = LaboratoryService.RestrictedTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined);
                    if (item != null)
                        LaboratoryService.RestrictedTestStatusTypes.Remove(item);
                    item = LaboratoryService.RestrictedTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted);
                    if (item != null)
                        LaboratoryService.RestrictedTestStatusTypes.Remove(item);

                    // Can finalize laboratory test result - execute?
                    if (_userPermissions.Execute == false)
                    {
                        item = LaboratoryService.RestrictedTestStatusTypes.Find(x =>
                            x.IdfsBaseReference == (long) TestStatusTypeEnum.Final);
                        if (item != null)
                            LaboratoryService.RestrictedTestStatusTypes.Remove(item);
                    }

                    item = LaboratoryService.RestrictedTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.MarkedForDeletion);
                    if (item != null)
                        LaboratoryService.RestrictedTestStatusTypes.Remove(item);
                    item = LaboratoryService.RestrictedTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.NotStarted);
                    if (item != null)
                        LaboratoryService.RestrictedTestStatusTypes.Remove(item);

                    item = LaboratoryService.ExternalTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended);
                    if (item != null)
                        LaboratoryService.ExternalTestStatusTypes.Remove(item);
                    item = LaboratoryService.ExternalTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined);
                    if (item != null)
                        LaboratoryService.ExternalTestStatusTypes.Remove(item);
                    item = LaboratoryService.ExternalTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted);
                    if (item != null)
                        LaboratoryService.ExternalTestStatusTypes.Remove(item);
                    item = LaboratoryService.ExternalTestStatusTypes.Find(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.MarkedForDeletion);
                    if (item != null)
                        LaboratoryService.ExternalTestStatusTypes.Remove(item);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestResultTypes()
        {
            try
            {
                if (LaboratoryService.TestResultTypes == null || !LaboratoryService.TestResultTypes.Any())
                {
                    var request = new TestNameTestResultsMatrixGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfsTestResultRelation = (long) TestResultRelationTypeEnum.LaboratoryTest,
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "strDefault",
                        SortOrder = SortConstants.Descending
                    };
                    LaboratoryService.TestResultTypes =
                        await TestNameTestResultsMatrixClient.GetTestNameTestResultsMatrixList(request);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <param name="testNameTypeId"></param>
        /// <returns></returns>
        public async Task<List<TestNameTestResultsMatrixViewModel>> GetTestResultTypesByTestName(LoadDataArgs args,
            long? testNameTypeId)
        {
            try
            {
                if (testNameTypeId == null) return new List<TestNameTestResultsMatrixViewModel>();

                if (LaboratoryService.TestResultTypes == null) await GetTestResultTypes();

                return LaboratoryService.TestResultTypes == null
                    ? new List<TestNameTestResultsMatrixViewModel>()
                    : LaboratoryService.TestResultTypes.Where(x => x.idfsTestName == testNameTypeId).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestCategoryTypes()
        {
            try
            {
                LaboratoryService.TestCategoryTypes ??= await CrossCuttingClient.GetBaseReferenceList(
                    GetCurrentLanguage(),
                    BaseReferenceConstants.TestCategory, HACodeList.NoneHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sampleId"></param>
        /// <returns></returns>
        protected async Task<SamplesGetListViewModel> GetSample(long sampleId)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                if (LaboratoryService.Samples != null && LaboratoryService.Samples.Any(x => x.SampleID == sampleId))
                    return LaboratoryService.Samples.First(x => x.SampleID == sampleId);

                if (LaboratoryService.PendingSaveSamples != null &&
                    LaboratoryService.PendingSaveSamples.Any(x => x.SampleID == sampleId))
                {
                    return LaboratoryService.PendingSaveSamples.First(x => x.SampleID == sampleId);
                }

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                SamplesGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "Query",
                    SortOrder = SortConstants.Ascending,
                    DaysFromAccessionDate = 0,
                    SampleID = sampleId,
                    FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                var sample = await LaboratoryClient.GetSamplesList(request, _token);

                return sample.First();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="testId"></param>
        /// <returns></returns>
        protected async Task<TestingGetListViewModel> GetTest(long testId)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                if (LaboratoryService.PendingSaveTesting != null && LaboratoryService.PendingSaveTesting.Any(x => x.TestID == testId))
                    return LaboratoryService.PendingSaveTesting.First(x => x.TestID == testId);

                if (LaboratoryService.Testing != null && LaboratoryService.Testing.Any(x => x.TestID == testId))
                    return LaboratoryService.Testing.First(x => x.TestID == testId);

                var request = new TestingGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "EIDSSLaboratorySampleID",
                    SortOrder = SortConstants.Ascending,
                    TestID = testId,
                    FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };
                LaboratoryService.Testing = await LaboratoryClient.GetTestingList(request, _token);

                return LaboratoryService.Testing.Any() ? LaboratoryService.Testing.First() : new TestingGetListViewModel();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="transferredOutSampleId"></param>
        /// <param name="transferredInSampleId"></param>
        /// <returns></returns>
        protected async Task<TransferredGetListViewModel> GetTransfer(long transferredOutSampleId, long? transferredInSampleId)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                if (LaboratoryService.Transferred != null &&
                    LaboratoryService.Transferred.Any(x => x.TransferredOutSampleID == transferredOutSampleId))
                    return LaboratoryService.Transferred.First(x => x.TransferredOutSampleID == transferredOutSampleId);

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                TransferredGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SampleID = transferredOutSampleId, 
                    SortColumn = "EIDSSLaboratorySampleID",
                    SortOrder = SortConstants.Ascending,
                    FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                var transfer = await LaboratoryClient.GetTransferredList(request, _token);

                if (transfer.Any()) return transfer.First(x => x.TransferredOutSampleID == transferredOutSampleId);

                if (transferredInSampleId is null) return new TransferredGetListViewModel();
                {
                    request.SampleID = transferredInSampleId;

                    transfer = await LaboratoryClient.GetTransferredList(request, _token);

                    return transfer.First(x => x.TransferredOutSampleID == transferredOutSampleId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sampleId"></param>
        /// <param name="testId"></param>
        /// <returns></returns>
        protected async Task<ApprovalsGetListViewModel> GetApproval(long? sampleId, long? testId)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                if (LaboratoryService.Approvals is not null &&
                    LaboratoryService.Approvals.Any(x => x.SampleID == sampleId && x.TestID == testId))
                {
                    return LaboratoryService.Approvals.First(x => x.SampleID == sampleId && x.TestID == testId);
                }
                else
                {
                    authenticatedUser = _tokenService.GetAuthenticatedUser();

                    ApprovalsGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SampleID = sampleId,
                        TestID = testId,
                        SortColumn = "EIDSSLaboratorySampleID",
                        SortOrder = SortConstants.Ascending,
                        UserOrganizationID = authenticatedUser.OfficeId
                    };

                    var approval = await LaboratoryClient.GetApprovalsList(request, _token);

                    return approval.First();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                _source?.Cancel();
                _source?.Dispose();
            }
        }

        /// <summary>
        /// Call this method only if the user has not already selected the my favorites tab.
        /// The individual my favorite record will be retrieved, and added to the pending
        /// save records.
        /// </summary>
        /// <param name="sample"></param>
        /// <param name="test"></param>
        /// <param name="transfer"></param>
        /// <param name="batch"></param>
        /// <returns></returns>
        protected async Task GetMyFavorite(SamplesGetListViewModel sample, TestingGetListViewModel test,
            TransferredGetListViewModel transfer, BatchesGetListViewModel batch)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                var request = new MyFavoritesGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1, // Go with the max value in the event a sample has more tests assigned than the selected page size.
                    SampleID = sample?.SampleID,
                    SortColumn = "EIDSSLaboratorySampleID",
                    SortOrder = SortConstants.Descending,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                LaboratoryService.MyFavorites = await LaboratoryClient.GetMyFavoritesList(request, _token);

                if (_token.IsCancellationRequested == false)
                {
                    if (LaboratoryService.MyFavorites is not null)
                    {
                        if (sample is not null && LaboratoryService.MyFavorites.Any(x => x.SampleID == sample.SampleID))
                        {
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).AccessionComment =
                                sample.AccessionComment;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                .AccessionConditionTypeID = sample.AccessionConditionTypeID;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                .EIDSSLocalOrFieldSampleID = sample.EIDSSLocalOrFieldSampleID;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).FunctionalAreaID =
                                sample.FunctionalAreaID;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).FunctionalAreaName =
                                sample.FunctionalAreaName;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).SampleTypeName =
                                sample.SampleTypeName;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                    .DestroyedByPersonID =
                                sample.DestroyedByPersonID;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).DestructionDate =
                                sample.DestructionDate;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                .DestructionMethodTypeID = sample.DestructionMethodTypeID;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                .ActionPerformedIndicator = true;

                            if (test is null && transfer is null)
                                TogglePendingSaveMyFavorites(
                                    LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID));
                        }
                        
                        if (test is not null && LaboratoryService.MyFavorites.Any(x => x.TestID == test.TestID))
                        {
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).ResultDate =
                                test.ResultDate;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestCategoryTypeID =
                                test.TestCategoryTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestCategoryTypeName =
                                test.TestCategoryTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestNameTypeID =
                                test.TestNameTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestNameTypeName =
                                test.TestNameTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestResultTypeID =
                                test.TestResultTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestResultTypeName =
                                test.TestResultTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).StartedDate =
                                test.StartedDate;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestStatusTypeID =
                                test.TestStatusTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestStatusTypeName =
                                test.TestStatusTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).ActionPerformedIndicator =
                                true;

                            TogglePendingSaveMyFavorites(
                                LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID));
                        }

                        if (transfer is not null &&
                            LaboratoryService.MyFavorites.Any(x => x.TransferID == transfer.TransferID))
                        {
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID).ResultDate =
                                transfer.ResultDate;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestCategoryTypeID =
                                transfer.TestCategoryTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestNameTypeID =
                                transfer.TestNameTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestNameTypeName =
                                transfer.TestNameTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestResultTypeID =
                                transfer.TestResultTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestResultTypeName =
                                transfer.TestResultTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID).StartedDate =
                                transfer.StartedDate;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestStatusTypeID =
                                transfer.TestStatusTypeID;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                    .TestStatusTypeName =
                                transfer.TestStatusTypeName;
                            LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID)
                                .ActionPerformedIndicator = true;

                            TogglePendingSaveMyFavorites(
                                LaboratoryService.MyFavorites.First(x => x.TransferID == transfer.TransferID));
                        }
                    }

                    // Clear out my favorites, so the grid will load appropriately if the user decides to navigate to that tab.
                    LaboratoryService.MyFavorites = null;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        protected void TogglePendingSaveSamples(SamplesGetListViewModel sample)
        {
            LaboratoryService.PendingSaveSamples ??= new List<SamplesGetListViewModel>();

            if (LaboratoryService.PendingSaveSamples.Any(x => x.SampleID == sample.SampleID))
            {
                var index = LaboratoryService.PendingSaveSamples.ToList().FindIndex(x => x.SampleID == sample.SampleID);
                LaboratoryService.PendingSaveSamples[index] = sample;
            }
            else
            {
                LaboratoryService.PendingSaveSamples.Add(sample);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="boxLocationAvailability"></param>
        protected void TogglePendingSaveBoxLocationAvailability(
            FreezerBoxLocationAvailabilitySaveRequestModel boxLocationAvailability)
        {
            LaboratoryService.PendingSaveAvailableFreezerBoxLocations ??=
                new List<FreezerBoxLocationAvailabilitySaveRequestModel>();

            if (LaboratoryService.PendingSaveAvailableFreezerBoxLocations.Any(x =>
                    x.FreezerSubdivisionID == boxLocationAvailability.FreezerSubdivisionID))
            {
                var index = LaboratoryService.PendingSaveAvailableFreezerBoxLocations.ToList().FindIndex(x => x.FreezerSubdivisionID == boxLocationAvailability.FreezerSubdivisionID);
                LaboratoryService.PendingSaveAvailableFreezerBoxLocations[index] = boxLocationAvailability;
            }
            else
            {
                LaboratoryService.PendingSaveAvailableFreezerBoxLocations.Add(boxLocationAvailability);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="test"></param>
        protected void TogglePendingSaveTesting(TestingGetListViewModel test)
        {
            LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();

            if (test is null) return;
            if (LaboratoryService.PendingSaveTesting.Any(x => x.TestID == test.TestID))
            {
                var index = LaboratoryService.PendingSaveTesting.ToList().FindIndex(x => x.TestID == test.TestID);
                LaboratoryService.PendingSaveTesting[index] = test;
            }
            else
            {
                LaboratoryService.PendingSaveTesting.Add(test);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="amendment"></param>
        public void TogglePendingSaveTestAmendments(TestAmendmentsSaveRequestModel amendment)
        {
            LaboratoryService.PendingSaveTestAmendments ??= new List<TestAmendmentsSaveRequestModel>();

            if (LaboratoryService.PendingSaveTestAmendments.Any(x => x.TestAmendmentID == amendment.TestAmendmentID))
            {
                var index = LaboratoryService.PendingSaveTestAmendments.ToList().FindIndex(x => x.TestAmendmentID == amendment.TestAmendmentID);
                LaboratoryService.PendingSaveTestAmendments[index] = amendment;
            }
            else
            {
                LaboratoryService.PendingSaveTestAmendments.Add(amendment);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="batch"></param>
        public void TogglePendingSaveBatches(BatchesGetListViewModel batch)
        {
            LaboratoryService.PendingSaveBatches ??= new List<BatchesGetListViewModel>();

            if (LaboratoryService.PendingSaveBatches.Any(x => x.BatchTestID == batch.BatchTestID))
            {
                var index = LaboratoryService.PendingSaveBatches.ToList().FindIndex(x => x.BatchTestID == batch.BatchTestID);
                LaboratoryService.PendingSaveBatches[index] = batch;
            }
            else
            {
                LaboratoryService.PendingSaveBatches.Add(batch);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="transfer"></param>
        public void TogglePendingSaveTransferred(TransferredGetListViewModel transfer)
        {
            LaboratoryService.PendingSaveTransferred ??= new List<TransferredGetListViewModel>();

            if (LaboratoryService.PendingSaveTransferred.Any(x => x.TransferID == transfer.TransferID))
            {
                var index = LaboratoryService.PendingSaveTransferred.ToList().FindIndex(x => x.TransferID == transfer.TransferID);
                LaboratoryService.PendingSaveTransferred[index] = transfer;
            }
            else
            {
                LaboratoryService.PendingSaveTransferred.Add(transfer);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="myFavorite"></param>
        protected void TogglePendingSaveMyFavorites(MyFavoritesGetListViewModel myFavorite)
        {
            LaboratoryService.PendingSaveMyFavorites ??= new List<MyFavoritesGetListViewModel>();

            if (LaboratoryService.PendingSaveMyFavorites.Any(x => x.SampleID == myFavorite.SampleID))
            {
                var index = myFavorite.TestID is null
                    ? LaboratoryService.PendingSaveMyFavorites.ToList()
                        .FindIndex(x => x.SampleID == myFavorite.SampleID)
                    : LaboratoryService.PendingSaveMyFavorites.ToList().FindIndex(x =>
                        x.SampleID == myFavorite.SampleID && x.TestID == myFavorite.TestID);

                // New test record added from My Favorites tab, so add to the pending save collection.
                if (index == -1)
                    LaboratoryService.PendingSaveMyFavorites.Add(myFavorite);
                else
                    LaboratoryService.PendingSaveMyFavorites[index] = myFavorite;
            }
            else
            {
                LaboratoryService.PendingSaveMyFavorites.Add(myFavorite);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="approval"></param>
        protected void TogglePendingSaveApprovals(ApprovalsGetListViewModel approval)
        {
            LaboratoryService.PendingSaveApprovals ??= new List<ApprovalsGetListViewModel>();

            if (LaboratoryService.PendingSaveApprovals.Any(x =>
                    x.SampleID == approval.SampleID && x.TestID == approval.TestID))
            {
                var index = LaboratoryService.PendingSaveApprovals.ToList().FindIndex(x => x.SampleID == approval.SampleID && x.TestID == approval.TestID);
                LaboratoryService.PendingSaveApprovals[index] = approval;
            }
            else
            {
                LaboratoryService.PendingSaveApprovals.Add(approval);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="eventRecord"></param>
        protected void TogglePendingSaveEvents(EventSaveRequestModel eventRecord)
        {
            LaboratoryService.PendingSaveEvents ??= new List<EventSaveRequestModel>();

            if (LaboratoryService.PendingSaveEvents.Any(x => x.EventId == eventRecord.EventId))
            {
                var index = LaboratoryService.PendingSaveEvents.ToList().FindIndex(x => x.EventId == eventRecord.EventId);
                LaboratoryService.PendingSaveEvents[index] = eventRecord;
            }
            else
            {
                eventRecord.EventId = LaboratoryService.PendingSaveEvents.Count + 1 * -1;
                LaboratoryService.PendingSaveEvents.Add(eventRecord);
            }
        }

        #endregion

        #region Accession

        /// <summary>
        /// </summary>
        /// <param name="records"></param>
        /// <param name="accessionConditionTypeId"></param>
        /// <param name="accessionConditionTypeName"></param>
        /// <returns></returns>
        protected async Task<List<SampleIDsGetListViewModel>> AccessionIn(IList<LaboratorySelectionViewModel> records,
            long? accessionConditionTypeId, string accessionConditionTypeName)
        {
            try
            {
                List<LaboratorySampleIDRequestModel> sampleIDs = new();
                SamplesGetListViewModel sample;
                List<TransferredGetListViewModel> transfers = null;

                foreach (var record in records)
                {
                    sample = await GetSample(record.SampleID);

                    switch (accessionConditionTypeId)
                    {
                        case null:
                            // Un-accessioned
                            sample.AccessionConditionTypeID = null;
                            sample.AccessionConditionOrSampleStatusTypeName = null;
                            sample.AccessionDate = null;
                            sample.SampleStatusTypeID = null;
                            break;
                        case (long)AccessionConditionTypeEnum.Rejected:
                            sample.AccessionConditionTypeID = accessionConditionTypeId;
                            sample.AccessionConditionOrSampleStatusTypeName = accessionConditionTypeName;

                            // Set the accession date as the laboratory has acted on it.
                            sample.AccessionDate = DateTime.Now; // ??= UserDate; TODO - change to use UTC time while subtracting out hours for logged in user's location.
                            sample.AccessionByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                            sample.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                            sample.CurrentSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                            sample.SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository;
                            break;
                        default:
                            await GetDates();
                            // Accepted in good or poor condition
                            sample.AccessionConditionTypeID = accessionConditionTypeId;
                            sample.AccessionConditionOrSampleStatusTypeName = accessionConditionTypeName;
                            sample.AccessionDate = DateTime.Now; // ??= UserDate; TODO - change to use UTC time while subtracting out hours for logged in user's location.
                            sample.AccessionByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                            sample.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                            sample.CurrentSiteID = Convert.ToInt64(authenticatedUser.SiteId);

                            // Add the sample to the list to obtain a sample ID as it is being accessioned in to the laboratory.
                            if (sample.EIDSSLaboratorySampleID == null)
                                sampleIDs.Add(new LaboratorySampleIDRequestModel
                                { SampleID = sample.SampleID, ProcessedIndicator = false });

                            // Transferred sample check
                            if (sample.SampleKindTypeID == (long)SampleKindTypeEnum.TransferredIn)
                            {
                                var request = new TransferredGetRequestModel
                                {
                                    LanguageId = GetCurrentLanguage(),
                                    Page = 1,
                                    PageSize = MaxValue - 1,
                                    SortColumn = "EIDSSTransferID",
                                    SortOrder = SortConstants.Descending,
                                    FiltrationIndicator = false,
                                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                    UserOrganizationID = authenticatedUser.OfficeId,
                                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                    UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID) ? null : Convert.ToInt64(authenticatedUser.SiteGroupID)
                                };

                                var tr = Task.Run(() => LaboratoryClient.GetTransferredList(request, _token), _token);
                                tr.Wait(_token);
                                transfers ??= tr.Result;

                                if (transfers.Any(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID))
                                {
                                    transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID).TransferStatusTypeID = (long)TransferStatusTypeEnum.Final;

                                    TogglePendingSaveTransferred(transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID));

                                    //Generate the site alert back to the sending laboratory.
                                    const SystemEventLogTypes eventTypeId = SystemEventLogTypes.LaboratorySampleTransferredOut;
                                    TogglePendingSaveEvents(await CreateEvent(transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID).TransferID,
                                        Convert.ToInt64(transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID).DiseaseID), eventTypeId, transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID).TransferredFromOrganizationSiteID, null));

                                    foreach (var eventRecord in LaboratoryService.PendingSaveEvents)
                                    {
                                        if (eventRecord.EventTypeId == (long) eventTypeId &&
                                            eventRecord.SiteId == transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID).TransferredFromOrganizationSiteID)
                                            eventRecord.LoginSiteId = transfers.First(x => x.TransferredInSampleID == sample.SampleID || x.TransferredOutSampleID == sample.ParentSampleID).TransferredFromOrganizationSiteID;
                                    }
                                }
                            }
                            break;
                    }

                    // Transferred sample check
                    if (sample.SampleKindTypeID == (long) SampleKindTypeEnum.TransferredIn)
                        sample.RootSampleID = sample.SampleID;

                    sample.ActionPerformedIndicator = true;

                    TogglePendingSaveSamples(sample);

                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != sample.SampleID)) continue;
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).AccessionIndicator =
                            sample.AccessionIndicator;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).AccessionDate =
                            sample.AccessionDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                            .AccessionConditionOrSampleStatusTypeName = sample.AccessionConditionOrSampleStatusTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                            .AccessionConditionTypeID = sample.AccessionConditionTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                            .ActionPerformedIndicator = true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).RowSelectionIndicator =
                            false;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID));
                    }
                }

                // Get the EIDSS laboratory sample ID for each accessioned in sample.
                if (sampleIDs.Count > 0)
                {
                    SampleIDsSaveRequestModel parameters = new() {Samples = JsonConvert.SerializeObject(sampleIDs)};

                    var t = Task.Run(() => LaboratoryClient.GetSampleIDList(parameters, _token), _token);
                    t.Wait(_token);
                    var returnResults = t.Result;

                    foreach (var sampleId in returnResults)
                    {
                        LaboratoryService.PendingSaveSamples.First(x => x.SampleID == sampleId.SampleID)
                            .EIDSSLaboratorySampleID = sampleId.EIDSSLaboratorySampleID;
                        LaboratoryService.PendingSaveSamples.First(x => x.SampleID == sampleId.SampleID)
                            .StorageLocationDisabledIndicator = false;

                        if (LaboratoryService.MyFavorites != null &&
                            LaboratoryService.MyFavorites.Any(x => x.SampleID == sampleId.SampleID))
                        {
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sampleId.SampleID)
                                .EIDSSLaboratorySampleID = sampleId.EIDSSLaboratorySampleID;
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sampleId.SampleID)
                                .StorageLocationDisabledIndicator = false;

                            TogglePendingSaveMyFavorites(
                                LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == sampleId.SampleID));
                        }
                        else
                        {
                            if (LaboratoryService.SearchMyFavorites == null ||
                                LaboratoryService.SearchMyFavorites.All(x => x.SampleID != sampleId.SampleID))
                                continue;
                            {
                                LaboratoryService.SearchMyFavorites.First(x => x.SampleID == sampleId.SampleID)
                                    .EIDSSLaboratorySampleID = sampleId.EIDSSLaboratorySampleID;
                                TogglePendingSaveMyFavorites(
                                    LaboratoryService.SearchMyFavorites.FirstOrDefault(x =>
                                        x.SampleID == sampleId.SampleID));
                            }
                        }
                    }

                    LaboratoryService.SelectedSamples = null;

                    return returnResults;
                }

                LaboratoryService.SelectedSamples = null;

                return new List<SampleIDsGetListViewModel>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="errorMessages"></param>
        /// <returns></returns>
        protected bool ValidateAccessioningIn(ref StringBuilder errorMessages)
        {
            var validateStatus = true;

            if (LaboratoryService.PendingSaveSamples is null)
                return true;

            foreach (var sample in from sample in LaboratoryService.PendingSaveSamples
                                   where sample.AccessionConditionTypeID != null
                                   where (sample.AccessionConditionTypeID
                                       == (long)AccessionConditionTypeEnum.AcceptedInPoorCondition) | (sample.AccessionConditionTypeID
                                       == (long)AccessionConditionTypeEnum.Rejected)
                     select sample)
                if (IsNullOrEmpty(sample.AccessionComment))
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + sample.EIDSSLaboratorySampleID + " - </strong>"
                                         + Localizer.GetString(MessageResourceKeyConstants.LaboratorySamplesCommentIsRequiredWhenSampleStatusIsAcceptedInPoorConditionOrRejectedMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }
                else if (sample.AccessionComment.Length < 7)
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + sample.EIDSSLaboratorySampleID + " - </strong>"
                                         + Localizer.GetString(MessageResourceKeyConstants.LaboratorySamplesCommentMustBeAtLeastSixCharactersInLengthMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }

            foreach (var sample in from sample in LaboratoryService.PendingSaveSamples
                     where sample.AccessionConditionTypeID != null
                     select sample)
                if (sample.AccessionDate is not null && sample.AccessionDate > DateTime.Now)
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + sample.EIDSSLaboratorySampleID + " - " + sample.AccessionDate + " - " + "</strong>" 
                                         + Localizer.GetString(MessageResourceKeyConstants.FutureDatesAreNotAllowedMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }

            return validateStatus;
        }

        #endregion

        #region Set Test Results

        /// <summary>
        /// </summary>
        /// <param name="errorMessages"></param>
        /// <returns></returns>
        protected bool ValidateTestResults(ref StringBuilder errorMessages)
        {
            var validateStatus = true;

            if (LaboratoryService.PendingSaveTesting is null)
                return true;

            foreach (var test in LaboratoryService.PendingSaveTesting)
            {
                if (test.ResultDate is null && test.TestResultTypeID is not null)
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + test.EIDSSLaboratorySampleID + " - " + test.TestNameTypeName + " - " + "</strong>" 
                                         + Localizer.GetString(MessageResourceKeyConstants.TestingResultDateIsRequiredMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }
                else if (test.TestResultTypeID is null && test.ResultDate is not null)
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + test.EIDSSLaboratorySampleID + " - " + test.TestNameTypeName + " - " + "</strong>" 
                                         + Localizer.GetString(MessageResourceKeyConstants.TestingTestResultIsRequiredMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }
                else if (test.ResultDate is not null && test.ResultDate > DateTime.Now)
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + test.EIDSSLaboratorySampleID + " - " + test.TestNameTypeName + " - " + "</strong>" 
                                         + Localizer.GetString(MessageResourceKeyConstants.TestingResultDateMustBeEarlierOrEqualToTheCurrentDateMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }
                else if (test.ResultDate is not null && Convert.ToDateTime(test.ResultDate).Date < Convert.ToDateTime(test.StartedDate).Date)
                {
                    errorMessages.Append(OpeningParagraphHtmlTag + "<strong>" + test.EIDSSLaboratorySampleID + " - " + test.TestNameTypeName + " - " + "</strong>" 
                                         + Localizer.GetString(MessageResourceKeyConstants.LaboratorySampleTestDetailsModalResultDateMustBeOnOrAfterTestStartedDateMessage)
                                         + ClosingParagraphHtmlTag);
                    validateStatus = false;
                }
            }

            return validateStatus;
        }

        #endregion

        #region Approve

        /// <summary>
        ///     LUC16 - approvals workflow
        /// </summary>
        /// <param name="tab"></param>
        /// <returns></returns>
        public async Task Approve(LaboratoryTabEnum tab)
        {
            try
            {
                SamplesGetListViewModel sampleRecord;
                TestingGetListViewModel testRecord = null;

                // Fill the reference types used in this method; if not already populated.
                await GetSampleStatusTypes();
                await GetTestStatusTypes();

                var sampleRecords = Empty;
                var testRecords = Empty;
                var samples = new List<SamplesGetListViewModel>();
                var tests = new List<TestingGetListViewModel>();
                dynamic request;

                switch (tab)
                {
                    case LaboratoryTabEnum.MyFavorites:
                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                        {
                            if (!IsNullOrEmpty(sampleRecords))
                                sampleRecords += ",";
                            sampleRecords += myFavorite.SampleID;

                            if (myFavorite.TestID is null) continue;
                            if (!IsNullOrEmpty(testRecords))
                                testRecords += ",";
                            testRecords += myFavorite.TestID;
                        }

                        request = new SamplesGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "SampleID",
                            SortOrder = SortConstants.Ascending,
                            DaysFromAccessionDate = 0,
                            SampleList = sampleRecords,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };
                        samples = await LaboratoryClient.GetSamplesList(request, _token);

                        request = new TestingGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "TestID",
                            SortOrder = SortConstants.Ascending,
                            TestList = testRecords,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };
                        tests = await LaboratoryClient.GetTestingList(request, _token);

                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                        {
                            ApprovalsGetListViewModel approvalRecord = null;
                            switch (myFavorite.ActionRequestedID)
                            {
                                case (long) SampleStatusTypeEnum.MarkedForDeletion:
                                    myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                    myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                    myFavorite.SampleStatusTypeID = (long) SampleStatusTypeEnum.Deleted;
                                    myFavorite.FreezerSubdivisionID = null;
                                    myFavorite.StorageBoxPlace = null;
                                    myFavorite.ActionPerformedIndicator = true;

                                    approvalRecord = await GetApproval(myFavorite.SampleID, null);
                                    approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                    approvalRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    approvalRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.Deleted;

                                    sampleRecord = samples.First(x => x.SampleID == myFavorite.SampleID);
                                    sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                    sampleRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    sampleRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.Deleted;
                                    ClearStorageBoxPlace(sampleRecord, sampleRecord.StorageBoxPlace);
                                    sampleRecord.FreezerSubdivisionID = null;
                                    sampleRecord.StorageBoxLocation = null;
                                    sampleRecord.StorageBoxPlace = null;
                                    sampleRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sampleRecord);
                                    TogglePendingSaveMyFavorites(myFavorite);
                                    TogglePendingSaveApprovals(approvalRecord);
                                    break;
                                case (long) SampleStatusTypeEnum.MarkedForDestruction:
                                    myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                    myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                    myFavorite.SampleStatusTypeID = (long) SampleStatusTypeEnum.Destroyed;
                                    myFavorite.FreezerSubdivisionID = null;
                                    myFavorite.StorageBoxPlace = null;
                                    myFavorite.ActionPerformedIndicator = true;

                                    approvalRecord = await GetApproval(myFavorite.SampleID, null);
                                    approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                    approvalRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    approvalRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.Destroyed;

                                    sampleRecord = samples.First(x => x.SampleID == myFavorite.SampleID);
                                    sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                    sampleRecord.DestructionDate = DateTime.Now;
                                    sampleRecord.DestroyedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                    sampleRecord.RowAction = (int) RowActionTypeEnum.SampleDestruction;
                                    sampleRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.Destroyed;
                                    ClearStorageBoxPlace(sampleRecord, sampleRecord.StorageBoxPlace);
                                    sampleRecord.FreezerSubdivisionID = null;
                                    sampleRecord.StorageBoxLocation = null;
                                    sampleRecord.StorageBoxPlace = null;
                                    sampleRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sampleRecord);
                                    TogglePendingSaveMyFavorites(myFavorite);
                                    TogglePendingSaveApprovals(approvalRecord);
                                    break;
                                case (long) TestStatusTypeEnum.MarkedForDeletion:
                                    myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                    myFavorite.TestStatusTypeID = (long) TestStatusTypeEnum.Deleted;
                                    myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                        .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                    myFavorite.ActionPerformedIndicator = true;

                                    if (myFavorite.TestID != null)
                                    {
                                        approvalRecord = await GetApproval(myFavorite.SampleID, (long) myFavorite.TestID);
                                        approvalRecord.RowAction = (int) RowActionTypeEnum.Update;
                                        approvalRecord.TestStatusTypeID = (long) TestStatusTypeEnum.Deleted;
                                        approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                            .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;

                                        testRecord = tests.First(x => x.TestID == myFavorite.TestID);
                                    }

                                    if (testRecord != null)
                                    {
                                        testRecord.RowAction = (int) RowActionTypeEnum.Update;
                                        testRecord.TestStatusTypeID = (long) TestStatusTypeEnum.Deleted;
                                        testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                            .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                        testRecord.ActionPerformedIndicator = true;

                                        TogglePendingSaveTesting(testRecord);
                                    }

                                    TogglePendingSaveMyFavorites(myFavorite);
                                    TogglePendingSaveApprovals(approvalRecord);
                                    break;
                                case (long) TestStatusTypeEnum.Preliminary:
                                    myFavorite.ResultDate = DateTime.Now;
                                    myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                    myFavorite.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                                    myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                        .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final).Name;
                                    myFavorite.ActionPerformedIndicator = true;

                                    if (myFavorite.TestID is not null)
                                    {
                                        approvalRecord = await GetApproval(null, (long) myFavorite.TestID);
                                        approvalRecord.ResultDate = DateTime.Now;
                                        approvalRecord.RowAction = (int) RowActionTypeEnum.Update;
                                        approvalRecord.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                                        approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                            .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final).Name;

                                        testRecord = tests.First(x => x.TestID == myFavorite.TestID);
                                    }

                                    if (testRecord is not null)
                                    {
                                        testRecord.ResultDate = DateTime.Now;
                                        testRecord.RowAction = (int) RowActionTypeEnum.Update;
                                        testRecord.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                                        testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                            .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final).Name;
                                        testRecord.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                                        testRecord.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                        testRecord.ValidatedByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                                        testRecord.ActionPerformedIndicator = true;

                                        TogglePendingSaveTesting(testRecord);
                                    }

                                    TogglePendingSaveMyFavorites(myFavorite);
                                    TogglePendingSaveApprovals(approvalRecord);
                                    break;
                            }
                        }

                        break;
                    case LaboratoryTabEnum.Approvals:
                        foreach (var approval in LaboratoryService.SelectedApprovals)
                        {
                            if (!IsNullOrEmpty(sampleRecords))
                                sampleRecords += ",";
                            sampleRecords += approval.SampleID;

                            if (approval.TestID is null) continue;
                            if (!IsNullOrEmpty(testRecords))
                                testRecords += ",";
                            testRecords += approval.TestID;
                        }

                        if (!IsNullOrEmpty(sampleRecords))
                        {
                            request = new SamplesGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = "Default",
                                SortOrder = SortConstants.Ascending,
                                DaysFromAccessionDate = 0,
                                SampleList = sampleRecords,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                            };
                            samples = await LaboratoryClient.GetSamplesList(request, _token);
                        }

                        if (!IsNullOrEmpty(testRecords))
                        {
                            request = new TestingGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = "TestID",
                                SortOrder = SortConstants.Ascending,
                                TestList = testRecords,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                            };
                            tests = await LaboratoryClient.GetTestingList(request, _token);
                        }

                        foreach (var approval in LaboratoryService.SelectedApprovals)
                            switch (approval.ActionRequestedID)
                            {
                                case (long) SampleStatusTypeEnum.MarkedForDeletion:
                                    approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                    approval.RowAction = (int) RowActionTypeEnum.Update;
                                    approval.SampleStatusTypeID = (long) SampleStatusTypeEnum.Deleted;

                                    sampleRecord = samples.First(x => x.SampleID == approval.SampleID);
                                    sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                    sampleRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    sampleRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.Deleted;
                                    ClearStorageBoxPlace(sampleRecord, sampleRecord.StorageBoxPlace);
                                    sampleRecord.FreezerSubdivisionID = null;
                                    sampleRecord.StorageBoxLocation = null;
                                    sampleRecord.StorageBoxPlace = null;
                                    sampleRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sampleRecord);
                                    TogglePendingSaveApprovals(approval);
                                    if (sampleRecord.FavoriteIndicator)
                                        await GetMyFavorite(sampleRecord, null, null, null);
                                    break;
                                case (long) SampleStatusTypeEnum.MarkedForDestruction:
                                    approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                    approval.RowAction = (int) RowActionTypeEnum.Update;
                                    approval.SampleStatusTypeID = (long) SampleStatusTypeEnum.Destroyed;

                                    sampleRecord = samples.First(x => x.SampleID == approval.SampleID);
                                    sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                        .SampleStatusTypes.First(x =>
                                            x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                    sampleRecord.DestructionDate = DateTime.Now;
                                    sampleRecord.DestroyedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                    sampleRecord.RowAction = (int) RowActionTypeEnum.SampleDestruction;
                                    sampleRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.Destroyed;
                                    ClearStorageBoxPlace(sampleRecord, sampleRecord.StorageBoxPlace);
                                    sampleRecord.FreezerSubdivisionID = null;
                                    sampleRecord.StorageBoxLocation = null;
                                    sampleRecord.StorageBoxPlace = null;
                                    sampleRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sampleRecord);
                                    TogglePendingSaveApprovals(approval);
                                    if (sampleRecord.FavoriteIndicator)
                                        await GetMyFavorite(sampleRecord, null, null, null);
                                    break;
                                case (long) TestStatusTypeEnum.MarkedForDeletion:
                                    approval.RowAction = (int) RowActionTypeEnum.Update;
                                    approval.TestStatusTypeID = (long) TestStatusTypeEnum.Deleted;
                                    approval.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                        .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;

                                    sampleRecord = samples.First(x => x.SampleID == approval.SampleID);

                                    testRecord = tests.First(x => x.TestID == approval.TestID);
                                    testRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    testRecord.TestStatusTypeID = (long) TestStatusTypeEnum.Deleted;
                                    testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                        .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                    testRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveTesting(testRecord);
                                    TogglePendingSaveApprovals(approval);

                                    if (testRecord.FavoriteIndicator)
                                        await GetMyFavorite(sampleRecord, testRecord, null, null);
                                    break;
                                case (long) TestStatusTypeEnum.Preliminary:
                                    approval.ResultDate = DateTime.Now;
                                    approval.RowAction = (int) RowActionTypeEnum.Update;
                                    approval.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                                    approval.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                        .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final).Name;

                                    sampleRecord = samples.First(x => x.SampleID == approval.SampleID);

                                    if (tests.Any(x => x.TestID == approval.TestID))
                                    {
                                        testRecord = tests.First(x => x.TestID == approval.TestID);
                                        testRecord.ResultDate = DateTime.Now;
                                        testRecord.RowAction = (int) RowActionTypeEnum.Update;
                                        testRecord.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                                        testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                            .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final).Name;
                                        testRecord.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                                        testRecord.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                        testRecord.ValidatedByPersonName = authenticatedUser.LastName + ", " +
                                                                           authenticatedUser.FirstName;
                                        testRecord.ActionPerformedIndicator = true;

                                        TogglePendingSaveTesting(testRecord);
                                        TogglePendingSaveApprovals(approval);
                                        if (testRecord.FavoriteIndicator)
                                            await GetMyFavorite(sampleRecord, testRecord, null, null);
                                    }

                                    break;
                            }

                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <param name="boxPlace"></param>
        public void ClearStorageBoxPlace(SamplesGetListViewModel sample, string boxPlace)
        {
            if (sample.FreezerSubdivisionID is null) return;
            sample.OldStorageBoxPlace = sample.StorageBoxPlace;
            sample.StorageBoxPlace = boxPlace;

            LaboratoryService.FreezerSubdivisions ??= new List<FreezerSubdivisionViewModel>();

            if (LaboratoryService.FreezerSubdivisions.All(x => x.FreezerSubdivisionID != sample.FreezerSubdivisionID))
                return;
            {
                var boxLocationAvailability =
                    JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(LaboratoryService
                        .FreezerSubdivisions.First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID)
                        .BoxPlaceAvailability);

                if (boxLocationAvailability.Any(slot =>
                        slot.BoxLocation == sample.OldStorageBoxPlace.Replace("-", "")))
                    foreach (var slot in boxLocationAvailability.Where(slot =>
                                 slot.BoxLocation == sample.OldStorageBoxPlace.Replace("-", "")))
                    {
                        slot.AvailabilityIndicator = true;
                        break;
                    }

                LaboratoryService.FreezerSubdivisions.First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID)
                    .BoxPlaceAvailability = JsonConvert.SerializeObject(boxLocationAvailability);
                LaboratoryService.FreezerSubdivisions.First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID)
                        .RowAction =
                    RowActionTypeEnum.Update.ToString();

                var freezerSubdivisionId = LaboratoryService.FreezerSubdivisions
                    .First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID).FreezerSubdivisionID;
                if (freezerSubdivisionId != null)
                {
                    FreezerBoxLocationAvailabilitySaveRequestModel request = new()
                    {
                        FreezerSubdivisionID = (long) freezerSubdivisionId,
                        BoxPlaceAvailability = LaboratoryService.FreezerSubdivisions
                            .First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID).BoxPlaceAvailability,
                        EIDSSFreezerSubdivisionID = LaboratoryService.FreezerSubdivisions
                            .First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID).EIDSSFreezerSubdivisionID
                    };

                    TogglePendingSaveBoxLocationAvailability(request);
                }

                StateHasChanged();
            }
        }

        #endregion

        #region Reject

        /// <summary>
        /// LUC16 - approvals workflow
        /// </summary>
        /// <param name="tab"></param>
        /// <returns></returns>
        public async Task Reject(LaboratoryTabEnum tab)
        {
            try
            {
                SamplesGetListViewModel sampleRecord;
                TestingGetListViewModel testRecord;

                // Fill the reference types used in this method; if not already populated.
                await GetSampleStatusTypes();
                await GetTestStatusTypes();

                var sampleRecords = Empty;
                var testRecords = Empty;
                List<SamplesGetListViewModel> samples;
                List<TestingGetListViewModel> tests;
                dynamic request;

                switch (tab)
                {
                    case LaboratoryTabEnum.MyFavorites:
                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                        {
                            if (!IsNullOrEmpty(sampleRecords))
                                sampleRecords += ",";
                            sampleRecords += myFavorite.SampleID;

                            if (myFavorite.TestID is not null)
                            {
                                if (!IsNullOrEmpty(testRecords))
                                    testRecords += ",";
                                testRecords += myFavorite.TestID;
                            }
                        }

                        request = new SamplesGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "SampleID",
                            SortOrder = SortConstants.Ascending,
                            DaysFromAccessionDate = 0,
                            SampleList = sampleRecords,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };
                        samples = await LaboratoryClient.GetSamplesList(request, _token);

                        request = new TestingGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "TestID",
                            SortOrder = SortConstants.Ascending,
                            TestList = testRecords,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };
                        tests = await LaboratoryClient.GetTestingList(request, _token);

                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                        {
                            ApprovalsGetListViewModel approvalRecord;
                            switch (myFavorite.ActionRequestedID)
                            {
                                case (long) SampleStatusTypeEnum.MarkedForDeletion:
                                case (long) SampleStatusTypeEnum.MarkedForDestruction:
                                    approvalRecord = await GetApproval(myFavorite.SampleID, null);
                                    sampleRecord = samples.First(x => x.SampleID == myFavorite.SampleID);

                                    if (approvalRecord.PreviousSampleStatusTypeID == null)
                                    {
                                        // Migrated record, set as default to in repository.
                                        approvalRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository;
                                        sampleRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository;
                                    }
                                    else
                                    {
                                        approvalRecord.SampleStatusTypeID = approvalRecord.PreviousSampleStatusTypeID;
                                        sampleRecord.SampleStatusTypeID = sampleRecord.PreviousSampleTypeID;
                                    }

                                    switch (approvalRecord.SampleStatusTypeID)
                                    {
                                        case (long) SampleStatusTypeEnum.Deleted:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.Destroyed:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.InRepository:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.InRepository)
                                                .Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.InRepository)
                                                .Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.InRepository)
                                                .Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.MarkedForDeletion:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDeletion).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDeletion).Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDeletion).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.MarkedForDestruction:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDestruction).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDestruction).Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDestruction).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.TransferredOut:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.TransferredOut)
                                                .Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.TransferredOut)
                                                .Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.TransferredOut)
                                                .Name;
                                            break;
                                    }

                                    myFavorite.PreviousSampleTypeID = null;
                                    myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                    myFavorite.SampleStatusTypeID = sampleRecord.SampleStatusTypeID;
                                    myFavorite.ActionPerformedIndicator = true;

                                    approvalRecord.PreviousSampleStatusTypeID = null;
                                    approvalRecord.RowAction = (int) RowActionTypeEnum.Update;

                                    sampleRecord.PreviousSampleTypeID = null;
                                    sampleRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    sampleRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sampleRecord);
                                    TogglePendingSaveMyFavorites(myFavorite);
                                    TogglePendingSaveApprovals(approvalRecord);
                                    break;
                                case (long) TestStatusTypeEnum.MarkedForDeletion:
                                case (long) TestStatusTypeEnum.Preliminary:
                                    approvalRecord = await GetApproval(null, myFavorite.TestID);
                                    testRecord = tests.First(x => x.TestID == myFavorite.TestID);

                                    if (approvalRecord.PreviousSampleStatusTypeID == null)
                                    {
                                        // Migrated record, set as default to in repository.
                                        approvalRecord.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                                        testRecord.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                                    }
                                    else
                                    {
                                        approvalRecord.TestStatusTypeID = approvalRecord.PreviousTestStatusTypeID;
                                        if (testRecord.PreviousTestStatusTypeID != null)
                                            testRecord.TestStatusTypeID = (long) testRecord.PreviousTestStatusTypeID;
                                    }

                                    switch (approvalRecord.TestStatusTypeID)
                                    {
                                        case (long) TestStatusTypeEnum.Amended:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended).Name;
                                            myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Declined:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined).Name;
                                            myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Deleted:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                            myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Final:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.SampleStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final)
                                                .Name;
                                            myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final)
                                                .Name;
                                            break;
                                        case (long) TestStatusTypeEnum.InProgress:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long)TestStatusTypeEnum.InProgress)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long)TestStatusTypeEnum.InProgress).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.MarkedForDeletion:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference ==
                                                            (long) TestStatusTypeEnum.MarkedForDeletion).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.MarkedForDeletion)
                                                .Name;
                                            myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.MarkedForDeletion)
                                                .Name;
                                            break;
                                        case (long) TestStatusTypeEnum.NotStarted:
                                            approvalRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.NotStarted).Name;
                                            testRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.NotStarted).Name;
                                            myFavorite.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.NotStarted).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Preliminary:
                                            approvalRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference ==
                                                            (long) TestStatusTypeEnum.Preliminary).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).Name;
                                            myFavorite.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).Name;
                                            break;
                                    }

                                    myFavorite.PreviousTestStatusTypeID = null;
                                    myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                    myFavorite.TestStatusTypeID = testRecord.TestStatusTypeID;
                                    myFavorite.ActionPerformedIndicator = true;

                                    approvalRecord.PreviousTestStatusTypeID = null;
                                    approvalRecord.RowAction = (int) RowActionTypeEnum.Update;

                                    testRecord.PreviousTestStatusTypeID = null;
                                    testRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    testRecord.ActionPerformedIndicator = true;

                                    EventSaveRequestModel eventRecord = new()
                                    {
                                        LoginSiteId = Convert.ToInt64(authenticatedUser.SiteId),
                                        ObjectId = testRecord.TestID,
                                        DiseaseId = testRecord.DiseaseID, 
                                        EventTypeId = (long)SystemEventLogTypes.LaboratoryTestResultRejected,
                                        InformationString = Format(
                                            Localizer.GetString(MessageResourceKeyConstants
                                                .ApprovalsTestResultNotValidatedNotificationMessage),
                                            approvalRecord.TestResultTypeName, approvalRecord.TestNameTypeName,
                                            approvalRecord.ResultDate.ToString(),
                                            approvalRecord.EIDSSLaboratorySampleID), 
                                        SiteId = testRecord.SiteID, //site id of where the record was created.
                                        UserId = approvalRecord.ResultEnteredByUserID
                                    };

                                    TogglePendingSaveTesting(testRecord);
                                    TogglePendingSaveMyFavorites(myFavorite);
                                    TogglePendingSaveApprovals(approvalRecord);
                                    TogglePendingSaveEvents(eventRecord);

                                    break;
                            }
                        }

                        break;
                    case LaboratoryTabEnum.Approvals:
                        foreach (var approval in LaboratoryService.SelectedApprovals)
                        {
                            if (!IsNullOrEmpty(sampleRecords))
                                sampleRecords += ",";
                            sampleRecords += approval.SampleID;

                            if (approval.TestID is not null)
                            {
                                if (!IsNullOrEmpty(testRecords))
                                    testRecords += ",";
                                testRecords += approval.TestID;
                            }
                        }

                        request = new SamplesGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "SampleID",
                            SortOrder = SortConstants.Ascending,
                            DaysFromAccessionDate = 0,
                            SampleList = sampleRecords,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };
                        samples = await LaboratoryClient.GetSamplesList(request, _token);

                        request = new TestingGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "TestID",
                            SortOrder = SortConstants.Ascending,
                            TestList = testRecords,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };
                        tests = await LaboratoryClient.GetTestingList(request, _token);

                        foreach (var approval in LaboratoryService.SelectedApprovals)
                            switch (approval.ActionRequestedID)
                            {
                                case (long) SampleStatusTypeEnum.MarkedForDeletion:
                                case (long) SampleStatusTypeEnum.MarkedForDestruction:
                                    sampleRecord = samples.First(x => x.SampleID == approval.SampleID);

                                    if (approval.PreviousSampleStatusTypeID == null)
                                    {
                                        // Migrated record, set as default to in repository.
                                        approval.SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository;
                                        sampleRecord.SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository;
                                    }
                                    else
                                    {
                                        approval.SampleStatusTypeID = approval.PreviousSampleStatusTypeID;
                                        sampleRecord.SampleStatusTypeID = sampleRecord.PreviousSampleTypeID;
                                    }

                                    switch (approval.SampleStatusTypeID)
                                    {
                                        case (long) SampleStatusTypeEnum.Deleted:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Deleted).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.Destroyed:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.Destroyed).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.InRepository:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.InRepository)
                                                .Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.InRepository)
                                                .Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.MarkedForDeletion:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDeletion).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDeletion).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.MarkedForDestruction:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDestruction).Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference ==
                                                    (long) SampleStatusTypeEnum.MarkedForDestruction).Name;
                                            break;
                                        case (long) SampleStatusTypeEnum.TransferredOut:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.TransferredOut)
                                                .Name;
                                            sampleRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .SampleStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) SampleStatusTypeEnum.TransferredOut)
                                                .Name;
                                            break;
                                    }

                                    approval.PreviousSampleStatusTypeID = null;
                                    approval.RowAction = (int) RowActionTypeEnum.Update;

                                    sampleRecord.PreviousSampleTypeID = null;
                                    sampleRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    sampleRecord.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sampleRecord);
                                    TogglePendingSaveApprovals(approval);

                                    if (sampleRecord.FavoriteIndicator)
                                        await GetMyFavorite(sampleRecord, null, null, null);
                                    break;
                                case (long) TestStatusTypeEnum.MarkedForDeletion:
                                case (long) TestStatusTypeEnum.Preliminary:
                                    testRecord = tests.First(x => x.TestID == approval.TestID);

                                    if (approval.PreviousSampleStatusTypeID == null)
                                    {
                                        // Migrated record, set as default to in repository.
                                        approval.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                                        testRecord.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                                    }
                                    else
                                    {
                                        approval.TestStatusTypeID = approval.PreviousTestStatusTypeID;
                                        testRecord.TestStatusTypeID = (long) testRecord.PreviousTestStatusTypeID;
                                    }

                                    switch (approval.TestStatusTypeID)
                                    {
                                        case (long) TestStatusTypeEnum.Amended:
                                            approval.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Amended).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Declined:
                                            approval.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Declined).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Deleted:
                                            approval.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Deleted).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Final:
                                            approval.TestStatusTypeName = LaboratoryService.SampleStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes
                                                .First(x => x.IdfsBaseReference == (long) TestStatusTypeEnum.Final)
                                                .Name;
                                            break;
                                        case (long) TestStatusTypeEnum.InProgress:
                                            approval.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.InProgress).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.InProgress).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.MarkedForDeletion:
                                            approval.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.MarkedForDeletion)
                                                .Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.MarkedForDeletion)
                                                .Name;
                                            break;
                                        case (long) TestStatusTypeEnum.NotStarted:
                                            approval.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.NotStarted).Name;
                                            testRecord.AccessionConditionOrSampleStatusTypeName = LaboratoryService
                                                .TestStatusTypes.First(x =>
                                                    x.IdfsBaseReference == (long) TestStatusTypeEnum.NotStarted).Name;
                                            break;
                                        case (long) TestStatusTypeEnum.Preliminary:
                                            approval.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).Name;
                                            testRecord.TestStatusTypeName = LaboratoryService.TestStatusTypes.First(x =>
                                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).Name;
                                            break;
                                    }

                                    approval.PreviousTestStatusTypeID = null;
                                    approval.RowAction = (int) RowActionTypeEnum.Update;

                                    testRecord.PreviousTestStatusTypeID = null;
                                    testRecord.RowAction = (int) RowActionTypeEnum.Update;
                                    testRecord.ActionPerformedIndicator = true;

                                    EventSaveRequestModel eventRecord = new()
                                    {
                                        LoginSiteId = Convert.ToInt64(authenticatedUser.SiteId),
                                        ObjectId = testRecord.TestID,
                                        DiseaseId = testRecord.DiseaseID,
                                        EventTypeId = (long) SystemEventLogTypes.LaboratoryTestResultRejected,
                                        InformationString = Format(
                                            Localizer.GetString(MessageResourceKeyConstants
                                                .ApprovalsTestResultNotValidatedNotificationMessage),
                                            approval.TestResultTypeName, approval.TestNameTypeName,
                                            approval.ResultDate.ToString(),
                                            approval.EIDSSLaboratorySampleID),
                                        SiteId = testRecord.SiteID, //site id of where the record was created.
                                        UserId = approval.ResultEnteredByUserID
                                    };
                                    LaboratoryService.TestResultExternalEnteredOrValidationRejectedIndicator = true;

                                    TogglePendingSaveTesting(testRecord);
                                    TogglePendingSaveApprovals(approval);
                                    TogglePendingSaveEvents(eventRecord);

                                    if (testRecord.FavoriteIndicator)
                                        await GetMyFavorite(null, testRecord, null, null);
                                    break;
                            }

                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Create Aliquot/Derivative

        /// <summary>
        /// </summary>
        /// <param name="samples"></param>
        /// <returns></returns>
        protected async Task<int> CreateAliquotDerivative(IList<SamplesGetListViewModel> samples)
        {
            try
            {
                UpdateBoxLocationAvailability();

                return await SaveAliquotDerivatives(samples.ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Assign Test

        /// <summary>
        /// </summary>
        /// <param name="tests"></param>
        /// <returns></returns>
        protected async Task AssignTest(List<TestingGetListViewModel> tests)
        {
            try
            {
                LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();

                foreach (var test in tests)
                {
                    LaboratoryService.PendingSaveTesting.Add(test);

                    var sample = await GetSample(test.SampleID);
                    sample.TestAssignedCount += 1;
                    sample.ActionPerformedIndicator = true;
                    TogglePendingSaveSamples(sample);

                    if (LaboratoryService.MyFavorites != null &&
                        LaboratoryService.MyFavorites.Any(x => x.SampleID == test.SampleID))
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestAssignedIndicator = true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .ActionPerformedIndicator = true;
                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID));
                    }

                    if (!test.FavoriteIndicator) continue;
                    await SetMyFavorite(0, null, test);
                    LaboratoryService.NewSamplesFromMyFavoritesRegisteredCount += 1;
                }

                LaboratoryService.NewTestsAssignedCount += tests.Count;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Transfer

        /// <summary>
        /// </summary>
        /// <param name="records"></param>
        /// <param name="transfer"></param>
        /// <returns></returns>
        protected async Task<string> TransferOut(IList<LaboratorySelectionViewModel> records,
            TransferredGetListViewModel transfer)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                SamplesGetListViewModel transferredOutSample;
                var pendingSaveSamples = new List<SamplesGetListViewModel>();
                var pendingSaveEvents = new List<EventSaveRequestModel>();
                var pendingSaveTransfers = new List<TransferredGetListViewModel>();
                var identity = 0;

                foreach (var record in records)
                {
                    transferredOutSample = await GetSample(record.SampleID);

                    identity += 1;

                    // Is the transferred to organization an EIDSS laboratory?  If so, then create a new sample record for accessioning.
                    // If not, then the transferred from laboratory will enter the test result received back from the transferred
                    // to laboratory via another method.
                    if (transfer.ExternalOrganizationIndicator == false)
                    {
                        var json = JsonConvert.SerializeObject(transferredOutSample);
                        var transferredInSample = JsonConvert.DeserializeObject<SamplesGetListViewModel>(json);

                        transferredInSample.AccessionComment = null;
                        transferredInSample.AccessionConditionOrSampleStatusTypeName = null;
                        transferredInSample.AccessionConditionTypeID = null;
                        transferredInSample.ActionPerformedIndicator = true;
                        transferredInSample.EnteredDate = DateTime.Now;
                        transferredInSample.ParentSampleID = transferredOutSample.SampleID;
                        transferredInSample.RootSampleID = transferredOutSample.RootSampleID;
                        transferredInSample.SampleID = identity * -1;
                        transferredInSample.SentDate = DateTime.Now;
                        transferredInSample.SentToOrganizationID = transfer.TransferredToOrganizationID;
                        transferredInSample.SampleKindTypeID = (long) SampleKindTypeEnum.TransferredIn;
                        transferredInSample.RowAction = (int) RowActionTypeEnum.InsertTransfer;

                        pendingSaveSamples.Add(transferredInSample);
                    }

                    transferredOutSample.ActionPerformedIndicator = true;
                    transferredOutSample.OutOfRepositoryDate = DateTime.Now;
                    transferredOutSample.SampleStatusTypeID = (long) SampleStatusTypeEnum.TransferredOut;

                    // Clear out the check box after action performed.

                    pendingSaveSamples.Add(transferredOutSample);

                    if (LaboratoryService.MyFavorites != null &&
                        LaboratoryService.MyFavorites.Any(x => x.SampleID == transferredOutSample.SampleID))
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transferredOutSample.SampleID)
                            .OutOfRepositoryDate = transferredOutSample.OutOfRepositoryDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transferredOutSample.SampleID)
                            .SampleStatusTypeID = transferredOutSample.SampleStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transferredOutSample.SampleID)
                            .ActionPerformedIndicator = true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transferredOutSample.SampleID)
                            .RowSelectionIndicator = false;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.First(x => x.SampleID == transferredOutSample.SampleID));
                    }

                    var transferPendingSave = new TransferredGetListViewModel
                    {
                        AccessionComment = transferredOutSample.AccessionComment,
                        AccessionConditionOrSampleStatusTypeName =
                            transferredOutSample.AccessionConditionOrSampleStatusTypeName,
                        AccessionDate = transferredOutSample.AccessionDate,
                        ActionPerformedIndicator = true,
                        DiseaseID = transferredOutSample.DiseaseID,
                        DiseaseName = transferredOutSample.DiseaseName,
                        EIDSSLaboratorySampleID = transferredOutSample.EIDSSLaboratorySampleID,
                        EIDSSLocalOrFieldSampleID = transferredOutSample.EIDSSLocalOrFieldSampleID,
                        EIDSSReportOrSessionID = transferredOutSample.EIDSSReportOrSessionID,
                        PurposeOfTransfer = transfer.PurposeOfTransfer,
                        PatientOrFarmOwnerName = transferredOutSample.PatientOrFarmOwnerName,
                        TransferredOutSampleID = transferredOutSample.SampleID,
                        SampleStatusTypeID = transferredOutSample.SampleStatusTypeID,
                        SampleTypeName = transferredOutSample.SampleTypeName,
                        SentByPersonID = transfer.SentByPersonID,
                        TransferredFromOrganizationSiteID = transfer.TransferredFromOrganizationSiteID,
                        TestRequested = transfer.TestRequested,
                        TransferDate = transfer.TransferDate,
                        TransferredFromOrganizationID = transfer.TransferredFromOrganizationID,
                        TransferredToOrganizationID = transfer.TransferredToOrganizationID,
                        TransferredToOrganizationName = transfer.TransferredToOrganizationName,
                        TransferStatusTypeID = (long) TransferStatusTypeEnum.InProgress,
                        TransferID = identity * -1
                    };

                    const SystemEventLogTypes eventTypeId = SystemEventLogTypes.LaboratorySampleTransferredIn;
                    
                    pendingSaveTransfers.Add(transferPendingSave);
                    if (transfer.TransferredToOrganizationSiteID == null) continue;
                    if (transferPendingSave.DiseaseID is null)
                    {
                        pendingSaveEvents.Add(await CreateEvent(transferPendingSave.TransferID,
                            null, eventTypeId,
                            (long) transfer.TransferredToOrganizationSiteID, null));
                    }
                    else if (transferPendingSave.DiseaseID.Contains(",") == false)
                    {
                        pendingSaveEvents.Add(await CreateEvent(transferPendingSave.TransferID,
                            Convert.ToInt64(transferPendingSave.DiseaseID), eventTypeId,
                            (long) transfer.TransferredToOrganizationSiteID, null));
                    }
                    else
                    {
                        pendingSaveEvents.Add(await CreateEvent(transferPendingSave.TransferID,
                            null, eventTypeId,
                            (long) transfer.TransferredToOrganizationSiteID, null));
                    }

                    foreach (var eventRecord in pendingSaveEvents.Where(eventRecord => eventRecord.EventTypeId == (long) eventTypeId &&
                                 eventRecord.SiteId == transfer.TransferredToOrganizationSiteID))
                    {
                        eventRecord.LoginSiteId = transfer.TransferredToOrganizationSiteID;
                    }
                }

                var returnCode = await SaveTransfers(pendingSaveSamples, pendingSaveTransfers, pendingSaveEvents);

                if (returnCode != 0) return Empty;
                {
                    var request = new TransferredGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SortColumn = TransferredDefaultSortColumn,
                        SortOrder = SortConstants.Descending,
                        UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        UserOrganizationID = authenticatedUser.OfficeId,
                        UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                            ? null
                            : Convert.ToInt64(authenticatedUser.SiteGroupID)
                    };

                    LaboratoryService.Transferred = await LaboratoryClient.GetTransferredList(request, _token);

                    var transferList = records.Aggregate(Empty,
                        (current, s) => current + s.EIDSSLaboratorySampleID + ',');
                    transferList = transferList.Remove(transferList.Length - 1, 1);
                    return transferList;
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task CancelTransfer()
        {
            try
            {
                foreach (var transfer in LaboratoryService.SelectedTransferred)
                {
                    transfer.RowStatus = (int) RowStatusTypeEnum.Inactive;
                    transfer.ActionPerformedIndicator = true;

                    var transferredOutSample = await GetSample(transfer.TransferredOutSampleID);
                    if (transfer.TransferredInSampleID is not null)
                    {
                        var transferredInSample = await GetSample((long) transfer.TransferredInSampleID);
                        transferredInSample.RowStatus = (int) RowStatusTypeEnum.Inactive;
                        transferredInSample.ActionPerformedIndicator = true;
                        TogglePendingSaveSamples(transferredInSample);
                    }

                    transferredOutSample.SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository;
                    transferredOutSample.SampleKindTypeID = null;
                    transferredOutSample.ActionPerformedIndicator = true;
                    TogglePendingSaveSamples(transferredOutSample);

                    TogglePendingSaveTransferred(transfer);

                    await SaveLaboratory();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Destruction

        /// <summary>
        ///     LUC14 - destroy a sample
        /// </summary>
        /// <param name="tab"></param>
        protected async Task DestroySampleByAutoclave(LaboratoryTabEnum tab)
        {
            try
            {
                var destructionMethods = await CrossCuttingClient.GetBaseReferenceList(
                    GetCurrentLanguage(), BaseReferenceConstants.DestructionMethod, HACodeList.NoneHACode);

                switch (tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples != null)
                            foreach (var sample in LaboratoryService.SelectedSamples)
                            {
                                sample.DestroyedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                sample.DestructionDate = DateTime.Now;
                                sample.DestructionMethodTypeID = (long) DestructionMethodTypes.Autoclave;

                                if (destructionMethods.Any(x => x.IdfsBaseReference == sample.DestructionMethodTypeID))
                                    sample.DestructionMethodTypeName = destructionMethods
                                        .First(x => x.IdfsBaseReference == sample.DestructionMethodTypeID).Name;

                                sample.SampleStatusTypeID = (long) SampleStatusTypeEnum.MarkedForDestruction;
                                sample.ActionPerformedIndicator = true;

                                TogglePendingSaveSamples(sample);

                                if (!sample.FavoriteIndicator) continue;
                                {
                                    // Has the user selected the my favorites tab?
                                    if (LaboratoryService.MyFavorites == null ||
                                        LaboratoryService.MyFavorites.All(x => x.SampleID != sample.SampleID))
                                    {
                                        await GetMyFavorite(sample, null, null, null);
                                    }
                                    else
                                    {
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .DestroyedByPersonID = sample.DestroyedByPersonID;
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .DestructionDate = sample.DestructionDate;
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .DestructionMethodTypeID = sample.DestructionMethodTypeID;
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .SampleStatusTypeID = sample.SampleStatusTypeID;
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .ActionPerformedIndicator = true;

                                        TogglePendingSaveMyFavorites(
                                            LaboratoryService.MyFavorites.FirstOrDefault(x =>
                                                x.SampleID == sample.SampleID));
                                    }
                                }
                            }

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites != null)
                            foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            {
                                myFavorite.DestroyedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                myFavorite.DestructionDate = DateTime.Now;
                                myFavorite.DestructionMethodTypeID = (long) DestructionMethodTypes.Autoclave;
                                myFavorite.SampleStatusTypeID = (long) SampleStatusTypeEnum.MarkedForDestruction;
                                myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                myFavorite.ActionPerformedIndicator = true;

                                TogglePendingSaveMyFavorites(myFavorite);

                                // Has the user selected the samples tab?
                                if (LaboratoryService.Samples == null ||
                                    LaboratoryService.Samples.All(x => x.SampleID != myFavorite.SampleID))
                                {
                                    var sample = await GetSample(myFavorite.SampleID);
                                    sample.DestroyedByPersonID = myFavorite.DestroyedByPersonID;
                                    sample.DestructionDate = myFavorite.DestructionDate;
                                    sample.DestructionMethodTypeID = myFavorite.DestructionMethodTypeID;

                                    if (destructionMethods.Any(x => x.IdfsBaseReference == sample.DestructionMethodTypeID))
                                        sample.DestructionMethodTypeName = destructionMethods
                                            .First(x => x.IdfsBaseReference == sample.DestructionMethodTypeID).Name;

                                    sample.SampleStatusTypeID = myFavorite.SampleStatusTypeID;
                                    sample.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sample);
                                }
                                else
                                {
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .DestroyedByPersonID = myFavorite.DestroyedByPersonID;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .DestructionDate = myFavorite.DestructionDate;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .DestructionMethodTypeID = myFavorite.DestructionMethodTypeID;

                                    if (destructionMethods.Any(x => x.IdfsBaseReference == LaboratoryService.Samples.First(z => z.SampleID == myFavorite.SampleID).DestructionMethodTypeID))
                                        LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).DestructionMethodTypeName = destructionMethods
                                            .First(x => x.IdfsBaseReference == LaboratoryService.Samples.First(y => y.SampleID == myFavorite.SampleID).DestructionMethodTypeID).Name;

                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .SampleStatusTypeID = myFavorite.SampleStatusTypeID;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(
                                        LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID));
                                }
                            }

                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        ///     LUC14 - destroy a sample
        /// </summary>
        /// <param name="tab"></param>
        protected async Task DestroySampleByIncineration(LaboratoryTabEnum tab)
        {
            try
            {
                var destructionMethods = await CrossCuttingClient.GetBaseReferenceList(
                    GetCurrentLanguage(), BaseReferenceConstants.DestructionMethod, HACodeList.NoneHACode);

                switch (tab)
                {
                    case LaboratoryTabEnum.Samples:
                        foreach (var sample in LaboratoryService.SelectedSamples)
                        {
                            sample.DestroyedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                            sample.DestructionDate = DateTime.Now;
                            sample.DestructionMethodTypeID = (long) DestructionMethodTypes.Incineration;

                            if (destructionMethods.Any(x => x.IdfsBaseReference == sample.DestructionMethodTypeID))
                                sample.DestructionMethodTypeName = destructionMethods
                                    .First(x => x.IdfsBaseReference == sample.DestructionMethodTypeID).Name;

                            sample.SampleStatusTypeID = (long) SampleStatusTypeEnum.MarkedForDestruction;
                            sample.ActionPerformedIndicator = true;

                            TogglePendingSaveSamples(sample);

                            if (!sample.FavoriteIndicator) continue;
                            {
                                // Has the user selected the my favorites tab?
                                if (LaboratoryService.MyFavorites == null ||
                                    LaboratoryService.MyFavorites.All(x => x.SampleID != sample.SampleID))
                                {
                                    await GetMyFavorite(sample, null, null, null);
                                }
                                else
                                {
                                    LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                        .DestroyedByPersonID = sample.DestroyedByPersonID;
                                    LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                        .DestructionDate = sample.DestructionDate;
                                    LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                        .DestructionMethodTypeID = sample.DestructionMethodTypeID;
                                    LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                        .SampleStatusTypeID = sample.SampleStatusTypeID;
                                    LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                        .ActionPerformedIndicator = true;

                                    TogglePendingSaveMyFavorites(
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID));
                                }
                            }
                        }

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites != null)
                            foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            {
                                myFavorite.DestroyedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                myFavorite.DestructionDate = DateTime.Now;
                                myFavorite.DestructionMethodTypeID = (long) DestructionMethodTypes.Incineration;
                                myFavorite.SampleStatusTypeID = (long) SampleStatusTypeEnum.MarkedForDestruction;
                                myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                myFavorite.ActionPerformedIndicator = true;

                                TogglePendingSaveMyFavorites(myFavorite);

                                // Has the user selected the samples tab?
                                if (LaboratoryService.Samples == null ||
                                    LaboratoryService.Samples.All(x => x.SampleID != myFavorite.SampleID))
                                {
                                    var sample = await GetSample(myFavorite.SampleID);
                                    sample.DestroyedByPersonID = myFavorite.DestroyedByPersonID;
                                    sample.DestructionDate = myFavorite.DestructionDate;
                                    sample.DestructionMethodTypeID = myFavorite.DestructionMethodTypeID;

                                    if (destructionMethods.Any(x => x.IdfsBaseReference == sample.DestructionMethodTypeID))
                                        sample.DestructionMethodTypeName = destructionMethods
                                            .First(x => x.IdfsBaseReference == sample.DestructionMethodTypeID).Name;

                                    sample.SampleStatusTypeID = myFavorite.SampleStatusTypeID;
                                    sample.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sample);
                                }
                                else
                                {
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .DestroyedByPersonID = myFavorite.DestroyedByPersonID;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .DestructionDate = myFavorite.DestructionDate;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .DestructionMethodTypeID = myFavorite.DestructionMethodTypeID;

                                    if (destructionMethods.Any(x => x.IdfsBaseReference == LaboratoryService.Samples.First(z => z.SampleID == myFavorite.SampleID).DestructionMethodTypeID))
                                        LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).DestructionMethodTypeName = destructionMethods
                                            .First(x => x.IdfsBaseReference == LaboratoryService.Samples.First(y => y.SampleID == myFavorite.SampleID).DestructionMethodTypeID).Name;

                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .SampleStatusTypeID = myFavorite.SampleStatusTypeID;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(
                                        LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID));
                                }
                            }

                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Register New Sample

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <param name="tab"></param>
        /// <returns></returns>
        public async Task Register(RegisterNewSampleViewModel model, LaboratoryTabEnum tab)
        {
            try
            {
                var counter = 0;
                var identity = LaboratoryService.NewSamplesRegisteredCount;
                List<LaboratorySampleIDRequestModel> sampleIDs = new();
                var collectedByPersonName = authenticatedUser.LastName;
                collectedByPersonName +=
                    !IsNullOrEmpty(authenticatedUser.FirstName) ? ", " + authenticatedUser.FirstName : "";

                await GetDates();

                while (counter < model.NumberOfSamples)
                {
                    identity += 1;

                    SamplesGetListViewModel sample = new()
                    {
                        AccessionConditionTypeID = (long) AccessionConditionTypeEnum.AcceptedInGoodCondition,
                        AccessionConditionOrSampleStatusTypeName = LaboratoryService.AccessionConditionTypes.First(x =>
                            x.IdfsBaseReference == (long) AccessionConditionTypeEnum.AcceptedInGoodCondition).Name,
                        SampleStatusTypeID = (long) SampleStatusTypeEnum.InRepository,
                        AccessionDate = DateTime.Now, // ??= UserDate; TODO - change to use UTC time while subtracting out hours for logged in user's location.
                        AccessionByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                        SampleTypeID = (long) model.SampleTypeID,
                        SampleTypeName = IsNullOrEmpty(model.SampleTypeName) ? null : model.SampleTypeName,
                        EnteredDate = DateTime.Now,
                        CollectionDate = model.CollectionDate,
                        SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        CurrentSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        ReadOnlyIndicator = false,
                        AccessionIndicator = 1,
                        FavoriteIndicator = model.FavoriteIndicator,
                        ReportOrSessionTypeName = IsNullOrEmpty(model.ReportOrSessionTypeName)
                            ? null
                            : model.ReportOrSessionTypeName,
                        EIDSSReportOrSessionID = IsNullOrEmpty(model.EIDSSReportOrSessionID)
                            ? null
                            : model.EIDSSReportOrSessionID,
                        HumanMasterID = model.HumanMasterID == null ? null : Convert.ToInt64(model.HumanMasterID),
                        HumanID = model.NewRecordAddedIndicator ? null : model.PatientFarmOrFarmOwnerID,
                        FarmMasterID = model.FarmMasterID,
                        FarmID = model.FarmID, 
                        PatientOrFarmOwnerName = IsNullOrEmpty(model.PatientFarmOrFarmOwnerName)
                            ? null
                            : model.PatientFarmOrFarmOwnerName,
                        PatientSpeciesVectorInformation = model.PatientSpeciesVectorInformation,
                        MonitoringSessionID = model.ActiveSurveillanceSessionID,
                        HumanDiseaseReportID = model.HumanDiseaseReportID,
                        VeterinaryDiseaseReportID = model.VeterinaryDiseaseReportID,
                        DiseaseID = model.DiseaseID.ToString(),
                        DiseaseName = model.DiseaseName,
                        DisplayDiseaseName = model.DiseaseName,
                        SpeciesTypeID = model.SpeciesTypeID,
                        VectorTypeID = model.VectorTypeID,
                        SpeciesID = model.SpeciesID,
                        VectorSessionID = model.VectorSurveillanceSessionID, 
                        VectorID = model.SampleCategoryTypeID == (long) CaseTypeEnum.Vector && model.VectorID is null ? identity * -1 : model.VectorID,
                        CollectedByOrganizationID = authenticatedUser.OfficeId,
                        CollectedByOrganizationName = authenticatedUser.Organization,
                        CollectedByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                        CollectedByPersonName = collectedByPersonName,
                        SentToOrganizationID = authenticatedUser.OfficeId,
                        SentToOrganizationName = authenticatedUser.Organization,
                        TestAssignedCount = 0,
                        TestCompletedIndicator = false,
                        SampleID = identity * -1,
                        ActionPerformedIndicator = true,
                        RowStatus = (int) RowStatusTypeEnum.Active
                    };

                    TogglePendingSaveSamples(sample);

                    if (model.FavoriteIndicator)
                    {
                        MyFavoritesGetListViewModel myFavorite = new()
                        {
                            AccessionConditionTypeID = (long)AccessionConditionTypeEnum.AcceptedInGoodCondition,
                            AccessionConditionOrSampleStatusTypeName = LaboratoryService.AccessionConditionTypes.First(x =>
                                x.IdfsBaseReference == (long)AccessionConditionTypeEnum.AcceptedInGoodCondition).Name,
                            SampleStatusTypeID = (long)SampleStatusTypeEnum.InRepository,
                            AccessionDate = DateTime.Now,
                            AccessionedInByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                            SampleTypeName = IsNullOrEmpty(model.SampleTypeName) ? null : model.SampleTypeName,
                            EnteredDate = DateTime.Now,
                            CollectionDate = model.CollectionDate,
                            SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                            CurrentSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                            ReadOnlyIndicator = true, // Prevent sample from being edited in the report/session.
                            AccessionIndicator = 1,
                            PatientOrFarmOwnerName = IsNullOrEmpty(model.PatientFarmOrFarmOwnerName)
                            ? null
                            : model.PatientFarmOrFarmOwnerName,
                            DiseaseID = model.DiseaseID.ToString(),
                            DiseaseName = model.DiseaseName,
                            CollectedByOrganizationID = authenticatedUser.OfficeId,
                            CollectedByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                            SentToOrganizationID = authenticatedUser.OfficeId,
                            TestCompletedIndicator = false,
                            SampleID = identity * -1,
                            ActionPerformedIndicator = true
                        };
                        TogglePendingSaveMyFavorites(myFavorite);
                    }

                    sampleIDs.Add(new LaboratorySampleIDRequestModel
                        {SampleID = sample.SampleID, ProcessedIndicator = false});

                    counter += 1;
                }

                // Get the EIDSS laboratory sample ID for each registered sample.
                if (sampleIDs.Count > 0)
                {
                    SampleIDsSaveRequestModel parameters = new() {Samples = JsonConvert.SerializeObject(sampleIDs)};
                    var returnResults = await LaboratoryClient.GetSampleIDList(parameters, _token);

                    foreach (var sampleId in returnResults)
                    {
                        if (LaboratoryService.Samples != null &&
                            LaboratoryService.Samples.Any(x => x.SampleID == sampleId.SampleID))
                            LaboratoryService.Samples.FirstOrDefault(x => x.SampleID == sampleId.SampleID)
                                .EIDSSLaboratorySampleID = sampleId.EIDSSLaboratorySampleID;

                        LaboratoryService.PendingSaveSamples.FirstOrDefault(x => x.SampleID == sampleId.SampleID)
                            .EIDSSLaboratorySampleID = sampleId.EIDSSLaboratorySampleID;

                        if (LaboratoryService.PendingSaveMyFavorites != null &&
                            LaboratoryService.PendingSaveMyFavorites.Any(x => x.SampleID == sampleId.SampleID))
                        {
                            LaboratoryService.PendingSaveMyFavorites.FirstOrDefault(x => x.SampleID == sampleId.SampleID)
                                .EIDSSLaboratorySampleID = sampleId.EIDSSLaboratorySampleID;
                        }
                    }
                }

                // Master count for both the Samples and My Favorites tabs.
                // Samples uses this count as they include ones in Samples and My Favorites.
                LaboratoryService.NewSamplesRegisteredCount += (int)model.NumberOfSamples;

                // Keep separate counts as the two grids (Samples and My Favorites) have there own paging to track.
                if (tab == LaboratoryTabEnum.MyFavorites)
                    LaboratoryService.NewSamplesFromMyFavoritesRegisteredCount += (int)model.NumberOfSamples;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Update Sample

        /// <summary>
        /// LUC11 - edit a sample
        /// </summary>
        /// <param name="sample"></param>
        protected async Task UpdateSample(SamplesGetListViewModel sample)
        {
            try
            {
                if (LaboratoryService.Samples is not null &&
                    LaboratoryService.Samples.Any(x => x.SampleID == sample.SampleID))
                {
                    if (LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID).AccessionConditionTypeID is
                        not null)
                    {
                        if (LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID)
                                .AccessionConditionTypeID is
                            (long) AccessionConditionTypeEnum.AcceptedInGoodCondition
                            or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition 
                            or (long) AccessionConditionTypeEnum.Rejected)
                        {
                            if (LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID)
                                    .AccessionDate is null)
                            {
                                IList<LaboratorySelectionViewModel> records = new List<LaboratorySelectionViewModel>();

                                records.Add(new LaboratorySelectionViewModel
                                {
                                    SampleID = sample.SampleID
                                });

                                await AccessionIn(records,
                                    LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID)
                                        .AccessionConditionTypeID,
                                    LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID)
                                        .AccessionConditionOrSampleStatusTypeName);
                            }
                        }
                    }

                    sample.ActionPerformedIndicator = true;
                    if (LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID).RowAction ==
                        (int) RowActionTypeEnum.Read)
                        LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID).RowAction =
                            (int) RowActionTypeEnum.Update;
                    sample.RowAction = LaboratoryService.Samples.First(x => x.SampleID == sample.SampleID).RowAction;
                }

                TogglePendingSaveSamples(sample);

                // Update the freezer box's availability depending on the storage location of the sample.
                UpdateBoxLocationAvailability();

                if (sample.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != sample.SampleID))
                    {
                        await GetMyFavorite(sample, null, null, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).AccessionComment =
                            sample.AccessionComment;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                            .AccessionConditionTypeID = sample.AccessionConditionTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                            .ActionPerformedIndicator = true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                            .EIDSSLocalOrFieldSampleID = sample.EIDSSLocalOrFieldSampleID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).FunctionalAreaID =
                            sample.FunctionalAreaID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).FunctionalAreaName =
                            sample.FunctionalAreaName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).SampleTypeName =
                            sample.SampleTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == sample.SampleID));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Restore Deleted Sample

        /// <summary>
        ///     LUC21 - Restore Deleted Sample
        /// </summary>
        /// <returns></returns>
        public void RestoreDeletedSample()
        {
            try
            {
                foreach (var sample in LaboratoryService.SelectedSamples)
                {
                    sample.RowAction = (int) RowActionTypeEnum.Update;
                    sample.ActionPerformedIndicator = true;

                    if (sample.PreviousSampleStatusTypeID != null)
                        sample.SampleStatusTypeID = sample.PreviousSampleStatusTypeID;
                    else sample.SampleStatusTypeID = (long) SampleStatusTypes.InRepository;

                    LaboratoryService.PendingSaveSamples ??= new List<SamplesGetListViewModel>();
                    LaboratoryService.PendingSaveSamples.Add(sample);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Set My Favorite

        /// <summary>
        /// </summary>
        /// <param name="sampleId"></param>
        /// <param name="newSample"></param>
        /// <param name="newTest"></param>
        /// <returns></returns>
        protected async Task SetMyFavorite(long sampleId, SamplesGetListViewModel newSample, TestingGetListViewModel newTest)
        {
            try
            {
                if (sampleId > 0)
                {
                    SamplesGetListViewModel sample;

                    if (LaboratoryService.Samples is not null &&
                        LaboratoryService.Samples.Any(x => x.SampleID == sampleId))
                        sample = LaboratoryService.Samples.First(x => x.SampleID == sampleId);
                    else
                        sample = await GetSample(sampleId);

                    sample.FavoriteIndicator = !sample.FavoriteIndicator;

                    await SaveMyFavorites(sample);
                }
                else if (newSample is not null)
                {
                    MyFavoritesGetListViewModel myFavorite = new()
                    {
                        AccessionComment = newSample.AccessionComment,
                        AccessionConditionOrSampleStatusTypeName = newSample.AccessionConditionOrSampleStatusTypeName,
                        AccessionConditionTypeID = newSample.AccessionConditionTypeID,
                        AccessionConditionTypeSelect = newSample.AccessionConditionTypeSelect,
                        AccessionDate = newSample.AccessionDate,
                        AccessionedInByPersonID = newSample.AccessionByPersonID,
                        AccessionIndicator = newSample.AccessionIndicator,
                        AccessToGenderAndAgeDataPermissionIndicator = newSample.AccessToGenderAndAgeDataPermissionIndicator,
                        AccessToPersonalDataPermissionIndicator = newSample.AccessToPersonalDataPermissionIndicator,
                        ActionPerformedIndicator = newSample.ActionPerformedIndicator,
                        AdministratorRoleIndicator = newSample.AdministratorRoleIndicator,
                        AllowDatesInThePast = newSample.AllowDatesInThePast,
                        BirdStatusTypeID = newSample.BirdStatusTypeID,
                        CanPerformSampleAccessionIn = newSample.CanPerformSampleAccessionIn,
                        CollectedByOrganizationID = newSample.CollectedByOrganizationID,
                        CollectedByPersonID = newSample.CollectedByPersonID,
                        CollectionDate = newSample.CollectionDate,
                        Comment = newSample.Comment,
                        CurrentSiteID = newSample.CurrentSiteID,
                        DeletePermissionIndicator = newSample.DeletePermissionIndicator,
                        DestroyedByPersonID = newSample.DestroyedByPersonID,
                        DestructionDate = newSample.DestructionDate,
                        DestructionMethodTypeID = newSample.DestructionMethodTypeID,
                        DiseaseID = newSample.DiseaseID,
                        DiseaseName = newSample.DiseaseName,
                        EIDSSAnimalID = newSample.EIDSSAnimalID,
                        EIDSSLaboratorySampleID = newSample.EIDSSLaboratorySampleID,
                        EIDSSLocalOrFieldSampleID = newSample.EIDSSLocalOrFieldSampleID,
                        EIDSSReportOrSessionID = newSample.EIDSSReportOrSessionID,
                        EnteredDate = newSample.EnteredDate,
                        FreezerSubdivisionID = newSample.FreezerSubdivisionID,
                        FunctionalAreaID = newSample.FunctionalAreaID,
                        FunctionalAreaIDDisabledIndicator = newSample.FunctionalAreaIDDisabledIndicator,
                        FunctionalAreaName = newSample.FunctionalAreaName,
                        HumanLaboratoryChiefIndicator = newSample.HumanLaboratoryChiefIndicator,
                        LaboratoryModuleSourceIndicator = newSample.LaboratoryModuleSourceIndicator,
                        MarkedForDispositionByPersonID = newSample.MarkedForDispositionByPersonID,
                        OutOfRepositoryDate = newSample.OutOfRepositoryDate,
                        ParentSampleID = newSample.ParentSampleID,
                        PatientOrFarmOwnerName = newSample.PatientOrFarmOwnerName,
                        PreviousSampleTypeID = newSample.PreviousSampleTypeID,
                        ReadOnlyIndicator = newSample.ReadOnlyIndicator,
                        ReadPermissionIndicator = newSample.ReadPermissionIndicator,
                        RootSampleID = newSample.RootSampleID,
                        RowAction = newSample.RowAction,
                        SampleID = newSample.SampleID,
                        SampleKindTypeID = newSample.SampleKindTypeID,
                        SampleStatusDate = newSample.SampleStatusDate,
                        SampleStatusTypeID = newSample.SampleStatusTypeID,
                        SampleStatusTypeSelectDisabledIndicator = newSample.SampleStatusTypeSelectDisabledIndicator,
                        SampleTypeName = newSample.SampleTypeName,
                        SentDate = newSample.SentDate,
                        SentToOrganizationID = newSample.SentToOrganizationID,
                        SiteID = newSample.SiteID,
                        StorageBoxPlace = newSample.StorageBoxPlace,
                        StorageLocationDisabledIndicator = newSample.StorageLocationDisabledIndicator,
                        VeterinaryLaboratoryChiefIndicator = newSample.VeterinaryLaboratoryChiefIndicator,
                        WritePermissionIndicator = newSample.WritePermissionIndicator
                    };

                    await GetMyFavorites();
                    TogglePendingSaveMyFavorites(myFavorite);
                }
                else if (newTest is not null)
                {
                    MyFavoritesGetListViewModel myFavorite = new()
                    {
                        AccessionComment = newTest.AccessionComment,
                        AccessionConditionOrSampleStatusTypeName = newTest.AccessionConditionOrSampleStatusTypeName,
                        AccessionConditionTypeID = newTest.AccessionConditionTypeID,
                        AccessionDate = newTest.AccessionDate,
                        AccessionIndicator = 1,
                        AccessToGenderAndAgeDataPermissionIndicator = newTest.AccessToGenderAndAgeDataPermissionIndicator,
                        AccessToPersonalDataPermissionIndicator = newTest.AccessToPersonalDataPermissionIndicator,
                        ActionPerformedIndicator = newTest.ActionPerformedIndicator,
                        AdministratorRoleIndicator = newTest.AdministratorRoleIndicator,
                        AllowDatesInThePast = newTest.AllowDatesInThePast,
                        CurrentSiteID = newTest.CurrentSiteID,
                        DeletePermissionIndicator = newTest.DeletePermissionIndicator,
                        DiseaseID = newTest.DiseaseID.ToString(),
                        DiseaseName = newTest.DiseaseName,
                        EIDSSAnimalID = newTest.EIDSSAnimalID,
                        EIDSSLaboratorySampleID = newTest.EIDSSLaboratorySampleID,
                        EIDSSLocalOrFieldSampleID = newTest.EIDSSLocalOrFieldSampleID,
                        EIDSSReportOrSessionID = newTest.EIDSSReportOrSessionID,
                        FunctionalAreaName = newTest.FunctionalAreaName,
                        HumanLaboratoryChiefIndicator = newTest.HumanLaboratoryChiefIndicator,
                        ParentSampleID = newTest.ParentSampleID,
                        PatientOrFarmOwnerName = newTest.PatientOrFarmOwnerName,
                        ReadOnlyIndicator = newTest.ReadOnlyIndicator,
                        ReadPermissionIndicator = newTest.ReadPermissionIndicator,
                        ResultDate = newTest.ResultDate,
                        RootSampleID = newTest.RootSampleID,
                        RowAction = newTest.RowAction,
                        SampleID = newTest.SampleID,
                        SampleStatusTypeID = newTest.SampleStatusTypeID,
                        SampleTypeName = newTest.SampleTypeName,
                        SentToOrganizationID = newTest.SentToOrganizationID,
                        SiteID = newTest.SiteID,
                        StartedDate = newTest.StartedDate,
                        TestCategoryTypeID = newTest.TestCategoryTypeID,
                        TestCategoryTypeName = newTest.TestCategoryTypeName,
                        TestID = newTest.TestID,
                        TestNameTypeID = newTest.TestNameTypeID,
                        TestNameTypeName = newTest.TestNameTypeName,
                        TestResultTypeID = newTest.TestResultTypeID,
                        TestResultTypeName = newTest.TestResultTypeName,
                        TestStatusTypeID = newTest.TestStatusTypeID,
                        TestStatusTypeName = newTest.TestStatusTypeName,
                        VeterinaryLaboratoryChiefIndicator = newTest.VeterinaryLaboratoryChiefIndicator,
                        WritePermissionIndicator = newTest.WritePermissionIndicator
                    };

                    TogglePendingSaveMyFavorites(myFavorite);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Update My Favorite

        /// <summary>
        /// </summary>
        /// <param name="myFavorite"></param>
        protected async Task UpdateMyFavorite(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                if (myFavorite.AccessionConditionTypeID == (long)AccessionConditionTypeEnum.Unaccessioned)
                    myFavorite.AccessionConditionTypeID = null;

                if (myFavorite.AccessionConditionTypeID is (long) AccessionConditionTypeEnum.AcceptedInGoodCondition
                    or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition)
                {
                    if (myFavorite.AccessionDate is null)
                    {
                        IList<LaboratorySelectionViewModel> records = new List<LaboratorySelectionViewModel>();

                        records.Add(new LaboratorySelectionViewModel
                        {
                            SampleID = myFavorite.SampleID
                        });

                        await AccessionIn(records, myFavorite.AccessionConditionTypeID, myFavorite.AccessionConditionOrSampleStatusTypeName);
                    }
                }

                TogglePendingSaveMyFavorites(myFavorite);

                myFavorite.ActionPerformedIndicator = true;

                if (LaboratoryService.Samples == null ||
                    LaboratoryService.Samples.All(x => x.SampleID != myFavorite.SampleID))
                {
                    var sample = await GetSample(myFavorite.SampleID);

                    sample.AccessionComment = myFavorite.AccessionComment;
                    sample.AccessionConditionTypeID = myFavorite.AccessionConditionTypeID;
                    sample.FunctionalAreaID = myFavorite.FunctionalAreaID;
                    sample.FunctionalAreaName = myFavorite.FunctionalAreaName;

                    TogglePendingSaveSamples(sample);
                }
                else
                {
                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).AccessionComment =
                        myFavorite.AccessionComment;
                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).AccessionConditionTypeID =
                        myFavorite.AccessionConditionTypeID;
                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).FunctionalAreaID =
                        myFavorite.FunctionalAreaID;
                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).FunctionalAreaName =
                        myFavorite.FunctionalAreaName;

                    TogglePendingSaveSamples(LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Test Record Deletion

        /// <summary>
        ///     LUC15 - delete a test record.
        /// </summary>
        /// <param name="tab"></param>
        protected async Task DeleteTestRecord(LaboratoryTabEnum tab)
        {
            try
            {
                LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();

                LaboratoryService.PendingSaveMyFavorites ??= new List<MyFavoritesGetListViewModel>();

                switch (tab)
                {
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting != null)
                            foreach (var test in LaboratoryService.SelectedTesting)
                            {
                                test.TestStatusTypeID = (long) TestStatusTypeEnum.MarkedForDeletion;
                                test.RowAction = (int) RowActionTypeEnum.Update;
                                test.ActionPerformedIndicator = true;

                                TogglePendingSaveTesting(test);

                                if (!test.FavoriteIndicator) continue;
                                // Has the user selected the my favorites tab?
                                if (LaboratoryService.MyFavorites == null ||
                                    LaboratoryService.MyFavorites.All(x => x.TestID != test.TestID))
                                {
                                    var sample = await GetSample(test.SampleID);
                                    await GetMyFavorite(sample, test, null, null);
                                }
                                else
                                {
                                    LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID).TestStatusTypeID =
                                        test.TestStatusTypeID;
                                    LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID)
                                        .RowAction = (int) RowActionTypeEnum.Update;
                                    LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID)
                                        .ActionPerformedIndicator = true;

                                    TogglePendingSaveMyFavorites(
                                        LaboratoryService.MyFavorites.First(x => x.TestID == test.TestID));
                                }
                            }

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites != null)
                            foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            {
                                myFavorite.TestStatusTypeID = (long) TestStatusTypeEnum.MarkedForDeletion;
                                myFavorite.RowAction = (int) RowActionTypeEnum.Update;
                                myFavorite.ActionPerformedIndicator = true;

                                TogglePendingSaveMyFavorites(myFavorite);

                                // Has the user selected the testing tab?
                                if (LaboratoryService.Testing is null || !LaboratoryService.Testing.Any(x =>
                                        myFavorite.TestID != null && x.TestID != (long)myFavorite.TestID))
                                {
                                    if (myFavorite.TestID == null) continue;
                                    var test = await GetTest((long) myFavorite.TestID);
                                    test.TestStatusTypeID = (long) myFavorite.TestStatusTypeID;
                                    test.RowAction = (int) RowActionTypeEnum.Update;
                                    test.ActionPerformedIndicator = true;

                                    TogglePendingSaveTesting(test);
                                }
                                else
                                {
                                    LaboratoryService.Testing.First(x =>
                                            myFavorite.TestID != null && x.TestID == (long) myFavorite.TestID)
                                        .TestStatusTypeID = (long) myFavorite.TestStatusTypeID;
                                    LaboratoryService.Testing.First(x =>
                                            myFavorite.TestID != null && x.TestID == (long) myFavorite.TestID)
                                        .RowAction = (int) RowActionTypeEnum.Update;
                                    LaboratoryService.Testing.First(x =>
                                            myFavorite.TestID != null && x.TestID == (long) myFavorite.TestID)
                                        .ActionPerformedIndicator = true;

                                    TogglePendingSaveTesting(LaboratoryService.Testing.First(x =>
                                        myFavorite.TestID != null && x.TestID == (long) myFavorite.TestID));
                                }
                            }

                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Update Test

        /// <summary>
        /// </summary>
        /// <param name="test"></param>
        protected async Task UpdateTest(TestingGetListViewModel test)
        {
            try
            {
                TogglePendingSaveTesting(test);

                test.ActionPerformedIndicator = true;

                if (test.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != test.SampleID))
                    {
                        await GetMyFavorite(null, test, null, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).AccessionComment =
                            test.AccessionComment;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).AccessionConditionTypeID =
                            test.AccessionConditionTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).ActionPerformedIndicator =
                            true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .EIDSSLocalOrFieldSampleID = test.EIDSSLocalOrFieldSampleID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).FunctionalAreaName =
                            test.FunctionalAreaName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).ResultDate =
                            test.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).SampleTypeName =
                            test.SampleTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestCategoryTypeID = test.TestCategoryTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestCategoryTypeName = test.TestCategoryTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestNameTypeID = test.TestNameTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestNameTypeName = test.TestNameTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeID = test.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeName = test.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .StartedDate = test.StartedDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeID = test.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeName = test.TestStatusTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Update Transfer

        /// <summary>
        /// </summary>
        /// <param name="transfer"></param>
        protected async Task UpdateTransfer(TransferredGetListViewModel transfer)
        {
            try
            {
                TogglePendingSaveTransferred(transfer);

                transfer.ActionPerformedIndicator = true;

                if (transfer.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != transfer.TransferredOutSampleID))
                    {
                        await GetMyFavorite(null, null, transfer, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .AccessionComment = transfer.AccessionComment;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .AccessionConditionTypeID = transfer.AccessionConditionTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .ActionPerformedIndicator = true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .EIDSSLocalOrFieldSampleID = transfer.EIDSSLocalOrFieldSampleID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .FunctionalAreaName = transfer.FunctionalAreaName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .ResultDate = transfer.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .SampleTypeName = transfer.SampleTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestCategoryTypeID = transfer.TestCategoryTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestNameTypeID = transfer.TestNameTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestNameTypeName = transfer.TestNameTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestResultTypeID = transfer.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestResultTypeName = transfer.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .StartedDate = transfer.StartedDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestStatusTypeID = transfer.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == transfer.TransferredOutSampleID)
                            .TestStatusTypeName = transfer.TestStatusTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x =>
                                x.SampleID == transfer.TransferredOutSampleID));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Storage Location

        /// <summary>
        /// </summary>
        public void UpdateBoxLocationAvailability()
        {
            foreach (var request in from freezerSubdivision in LaboratoryService.FreezerSubdivisions where freezerSubdivision.RowAction == RowActionTypeEnum.Update.ToString() where freezerSubdivision.FreezerSubdivisionID != null select new FreezerBoxLocationAvailabilitySaveRequestModel()
                     {
                         FreezerSubdivisionID = (long) freezerSubdivision.FreezerSubdivisionID,
                         BoxPlaceAvailability = freezerSubdivision.BoxPlaceAvailability, 
                         EIDSSFreezerSubdivisionID = freezerSubdivision.EIDSSFreezerSubdivisionID
                     })
            {
                TogglePendingSaveBoxLocationAvailability(request);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="number"></param>
        /// <returns></returns>
        public string GetLetter(int number)
        {
            return number switch
            {
                1 => "A",
                2 => "B",
                3 => "C",
                4 => "D",
                5 => "E",
                6 => "F",
                7 => "G",
                8 => "H",
                9 => "I",
                10 => "J",
                11 => "K",
                12 => "L",
                13 => "M",
                14 => "N",
                15 => "O",
                16 => "P",
                17 => "Q",
                18 => "R",
                19 => "S",
                20 => "T",
                21 => "U",
                22 => "V",
                23 => "W",
                24 => "X",
                25 => "Y",
                26 => "Z",
                _ => ""
            };
        }

        #endregion

        #region Save

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <returns></returns>
        protected async Task SaveMyFavorites(SamplesGetListViewModel sample)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                MyFavoritesGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = MyFavoritesDefaultSortColumn,
                    SortOrder = SortConstants.Descending,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                IList<MyFavoritesGetListViewModel> allMyFavorites;
                if (LaboratoryService.MyFavorites is null)
                    allMyFavorites = await LaboratoryClient.GetMyFavoritesList(request, _token);
                else
                    allMyFavorites = LaboratoryService.MyFavorites;

                var response = await LaboratoryClient.SaveLaboratory(new LaboratorySaveRequestModel
                {
                    Samples = JsonConvert.SerializeObject(new List<SamplesGetListViewModel>()),
                    Batches = JsonConvert.SerializeObject(new List<BatchesGetListViewModel>()),
                    Tests = JsonConvert.SerializeObject(new List<TestingGetListViewModel>()),
                    TestAmendments = JsonConvert.SerializeObject(new List<TestAmendmentsSaveRequestModel>()),
                    Transfers = JsonConvert.SerializeObject(new List<TransferredGetListViewModel>()),
                    FreezerBoxLocationAvailabilities =
                        JsonConvert.SerializeObject(new List<FreezerBoxLocationAvailabilitySaveRequestModel>()),
                    Events = JsonConvert.SerializeObject(new List<EventSaveRequestModel>()),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    Favorites = BuildMyFavorites(sample, allMyFavorites.ToList()),
                    AuditUserName = authenticatedUser.UserName
                }, _token);

                if (response.ReturnCode == 0)
                {
                    if (LaboratoryService.Testing is not null &&
                        LaboratoryService.Testing.Any(x => x.SampleID == sample.SampleID))
                    {
                        foreach (var test in LaboratoryService.Testing.Where(x => x.SampleID == sample.SampleID))
                        {
                            test.FavoriteIndicator = sample.FavoriteIndicator;
                        }
                    }

                    if (LaboratoryService.Transferred is not null &&
                        LaboratoryService.Transferred.Any(x => x.TransferredOutSampleID == sample.SampleID))
                    {
                        foreach (var transfer in LaboratoryService.Transferred.Where(x => x.TransferredOutSampleID == sample.SampleID))
                        {
                            transfer.FavoriteIndicator = sample.FavoriteIndicator;
                        }
                    }

                    if (LaboratoryService.Batches is not null && LaboratoryService.Batches.Any())
                    {
                        foreach (var batch in LaboratoryService.Batches)
                        {
                            if (batch.Tests is null || batch.Tests.All(x => x.SampleID != sample.SampleID)) continue;
                            {
                                foreach (var test in batch.Tests.Where(x => x.SampleID == sample.SampleID))
                                {
                                    test.FavoriteIndicator = sample.FavoriteIndicator;
                                }
                            }
                        }
                    }

                    // Reload my favorites to reflect the change.
                    LaboratoryService.MyFavorites = await LaboratoryClient.GetMyFavoritesList(request, _token);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <param name="allMyFavorites"></param>
        /// <returns></returns>
        private string BuildMyFavorites(SamplesGetListViewModel sample, List<MyFavoritesGetListViewModel> allMyFavorites)
        {
            var favoritesXml = "<Favorites>";

            if (allMyFavorites is null)
            {
                var myFavorites = LaboratoryService.MyFavorites.GroupBy(x => x.SampleID).Select(y => y.First()).ToList();
                foreach (var myFavorite in myFavorites)
                    if (myFavorite.SampleID == sample.SampleID)
                    {
                        if (sample.FavoriteIndicator)
                            favoritesXml += "<Favorite SampleID=\"" + myFavorite.SampleID + "\" />";
                    }
                    else
                    {
                        favoritesXml += "<Favorite SampleID=\"" + myFavorite.SampleID + "\" />";
                    }

                if (sample.FavoriteIndicator && LaboratoryService.MyFavorites.All(x => x.SampleID != sample.SampleID))
                    favoritesXml += "<Favorite SampleID=\"" + sample.SampleID + "\" />";
            }
            else
            {
                allMyFavorites = allMyFavorites.GroupBy(x => x.SampleID).Select(y => y.First()).ToList();
                foreach (var myFavorite in allMyFavorites)
                    if (myFavorite.SampleID == sample.SampleID)
                    {
                        if (sample.FavoriteIndicator)
                            favoritesXml += "<Favorite SampleID=\"" + myFavorite.SampleID + "\" />";
                    }
                    else
                    {
                        favoritesXml += "<Favorite SampleID=\"" + myFavorite.SampleID + "\" />";
                    }

                if (sample.FavoriteIndicator && allMyFavorites.All(x => x.SampleID != sample.SampleID))
                    favoritesXml += "<Favorite SampleID=\"" + sample.SampleID + "\" />";
            }

            favoritesXml += "</Favorites>";

            return favoritesXml;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task<int> SaveLaboratory()
        {
            try
            {
                StringBuilder errorMessages = new();

                if (ValidateAccessioningIn(ref errorMessages) && ValidateTestResults(ref errorMessages))
                {
                    if (LaboratoryService.PendingSaveTesting is not null && LaboratoryService.PendingSaveTesting.Any())
                    {
                        foreach (var test in LaboratoryService.PendingSaveTesting)
                        {
                            if (test.AdditionalTestDetailsFlexFormRequest is null) continue;
                            if (test.AdditionalTestDetailsFlexFormRequest.idfsFormTemplate is null)
                            {
                                var questions = await FlexFormClient.GetQuestionnaire(test.AdditionalTestDetailsFlexFormRequest);

                                if (questions.Count > 0)
                                    test.AdditionalTestDetailsFlexFormRequest.idfsFormTemplate = questions[0].idfsFormTemplate;
                            }

                            if (test.AdditionalTestDetailsFlexFormRequest.idfsFormTemplate == null) continue;
                            FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                            {
                                Answers = test.AdditionalTestDetailsObservationParameters,
                                idfsFormTemplate = (long)test.AdditionalTestDetailsFlexFormRequest.idfsFormTemplate,
                                idfObservation = test.AdditionalTestDetailsFlexFormRequest.idfObservation,
                                User = test.AdditionalTestDetailsFlexFormRequest.User
                            };
                            var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                            test.AdditionalTestDetailsFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                            test.ObservationID = flexFormResponse.idfObservation;
                        }
                    }

                    if (LaboratoryService.PendingSaveBatches is not null && LaboratoryService.PendingSaveBatches.Any())
                    {
                        foreach (var batch in LaboratoryService.PendingSaveBatches)
                        {
                            if (batch.QualityControlValuesFlexFormRequest is null) continue;
                            if (batch.QualityControlValuesFlexFormRequest.idfsFormTemplate is null)
                            {
                                var questions = await FlexFormClient.GetQuestionnaire(batch.QualityControlValuesFlexFormRequest);

                                if (questions.Count > 0)
                                    batch.QualityControlValuesFlexFormRequest.idfsFormTemplate = questions[0].idfsFormTemplate;
                            }

                            if (batch.QualityControlValuesFlexFormRequest.idfsFormTemplate == null) continue;
                            FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                            {
                                Answers = batch.QualityControlValuesObservationParameters,
                                idfsFormTemplate = (long)batch.QualityControlValuesFlexFormRequest.idfsFormTemplate,
                                idfObservation = batch.QualityControlValuesFlexFormRequest.idfObservation,
                                User = batch.QualityControlValuesFlexFormRequest.User
                            };
                            var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                            batch.QualityControlValuesFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                            batch.ObservationID = flexFormResponse.idfObservation;
                        }
                    }

                    LaboratoryService.PendingSaveApprovals ??= new List<ApprovalsGetListViewModel>();
                    LaboratoryService.PendingSaveAvailableFreezerBoxLocations ??=
                        new List<FreezerBoxLocationAvailabilitySaveRequestModel>();
                    LaboratoryService.PendingSaveBatches ??= new List<BatchesGetListViewModel>();
                    LaboratoryService.PendingSaveEvents ??= new List<EventSaveRequestModel>();
                    LaboratoryService.PendingSaveMyFavorites ??= new List<MyFavoritesGetListViewModel>();
                    LaboratoryService.PendingSaveSamples ??= new List<SamplesGetListViewModel>();
                    LaboratoryService.PendingSaveTestAmendments ??= new List<TestAmendmentsSaveRequestModel>();
                    LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();
                    LaboratoryService.PendingSaveTransferred ??= new List<TransferredGetListViewModel>();

                    var request = new LaboratorySaveRequestModel
                    {
                        Samples = JsonConvert.SerializeObject(
                            BuildSampleParameters(LaboratoryService.PendingSaveSamples)),
                        Batches = JsonConvert.SerializeObject(
                            BuildBatchesParameters(LaboratoryService.PendingSaveBatches)),
                        Tests = JsonConvert.SerializeObject(
                            BuildTestingParameters(LaboratoryService.PendingSaveTesting)),
                        TestAmendments = JsonConvert.SerializeObject(LaboratoryService.PendingSaveTestAmendments),
                        Transfers = JsonConvert.SerializeObject(await 
                            BuildTransferredParameters(LaboratoryService.PendingSaveTransferred)),
                        FreezerBoxLocationAvailabilities =
                            JsonConvert.SerializeObject(LaboratoryService.PendingSaveAvailableFreezerBoxLocations),
                        Events = JsonConvert.SerializeObject(LaboratoryService.PendingSaveEvents),
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        Favorites = BuildMyFavorites(await GetAllMyFavorites()),
                        AuditUserName = authenticatedUser.UserName
                    };

                    var response = await LaboratoryClient.SaveLaboratory(request, _token);

                    if (response.ReturnCode != 0)
                        if (response.ReturnCode != null)
                            return (int) response.ReturnCode;
                    List<DialogButton> buttons = new();
                    DialogButton okButton = new()
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                        ButtonType = DialogButtonType.OK
                    };
                    buttons.Add(okButton);

                    Dictionary<string, object> dialogParams = new()
                    {
                        {nameof(EIDSSDialog.DialogButtons), buttons},
                        {
                            nameof(EIDSSDialog.Message),
                            Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)
                        }
                    };
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                    LaboratoryService.Samples = null;
                    LaboratoryService.Testing = null;
                    LaboratoryService.Transferred = null;
                    LaboratoryService.MyFavorites = null;
                    LaboratoryService.Batches = null;
                    LaboratoryService.Approvals = null;

                    LaboratoryService.PendingSaveSamples = null;
                    LaboratoryService.PendingSaveTesting = null;
                    LaboratoryService.PendingSaveTestAmendments = new List<TestAmendmentsSaveRequestModel>();
                    LaboratoryService.PendingSaveTransferred = null;
                    LaboratoryService.PendingSaveMyFavorites = null;
                    LaboratoryService.PendingSaveEvents = new List<EventSaveRequestModel>();
                    LaboratoryService.PendingSaveBatches = null;
                    LaboratoryService.PendingSaveApprovals = null;

                    LaboratoryService.NewSamplesRegisteredCount = 0;
                    LaboratoryService.NewSamplesFromMyFavoritesRegisteredCount = 0;
                    LaboratoryService.NewTestsAssignedCount = 0;

                    if (response.ReturnCode != null) return (int) response.ReturnCode;
                }
                else
                {
                    var html = errorMessages.ToString();
                    await ShowHtmlErrorDialog(new MarkupString(html));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return MinValue;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetMyFavorites()
        {
            try
            {
                if (LaboratoryService.MyFavorites == null || !LaboratoryService.MyFavorites.Any())
                {
                    var myFavoritesRequest = new MyFavoritesGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = MyFavoritesDefaultSortColumn,
                        SortOrder = SortConstants.Descending,
                        UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        UserOrganizationID = authenticatedUser.OfficeId,
                        UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                    };

                    LaboratoryService.MyFavorites =
                        await LaboratoryClient.GetMyFavoritesList(myFavoritesRequest, _token);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task<List<MyFavoritesGetListViewModel>> GetAllMyFavorites()
        {
            try
            {
                var myFavoritesRequest = new MyFavoritesGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = MyFavoritesDefaultSortColumn,
                    SortOrder = SortConstants.Descending,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };
                var list = await LaboratoryClient.GetMyFavoritesList(myFavoritesRequest, _token);

                if (LaboratoryService.PendingSaveMyFavorites is not null &&
                    LaboratoryService.PendingSaveMyFavorites.Any())
                {
                    list.AddRange(LaboratoryService.PendingSaveMyFavorites);
                }

                return list;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="samples"></param>
        /// <returns></returns>
        protected async Task<int> SaveAliquotDerivatives(List<SamplesGetListViewModel> samples)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                MyFavoritesGetRequestModel myFavoritesRequest = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = MyFavoritesDefaultSortColumn,
                    SortOrder = SortConstants.Descending,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };                
                var allMyFavorites = await LaboratoryClient.GetMyFavoritesList(myFavoritesRequest, _token);

                var response = await LaboratoryClient.SaveLaboratory(new LaboratorySaveRequestModel
                {
                    Samples = JsonConvert.SerializeObject(BuildSampleParameters(samples)),
                    Batches = JsonConvert.SerializeObject(new List<BatchesGetListViewModel>()),
                    Tests = JsonConvert.SerializeObject(new List<TestingGetListViewModel>()),
                    TestAmendments = JsonConvert.SerializeObject(new List<TestAmendmentsSaveRequestModel>()),
                    Transfers = JsonConvert.SerializeObject(new List<TransferredGetListViewModel>()),
                    FreezerBoxLocationAvailabilities = JsonConvert.SerializeObject(LaboratoryService.PendingSaveAvailableFreezerBoxLocations),
                    Events = JsonConvert.SerializeObject(new List<EventSaveRequestModel>()),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    Favorites = BuildMyFavorites(allMyFavorites),
                    AuditUserName = authenticatedUser.UserName
                }, _token);

                switch (response.ReturnCode)
                {
                    case 0:
                    {
                        foreach (var request in from sample in samples where sample.FavoriteIndicator select new SamplesGetRequestModel
                                 {
                                     LanguageId = GetCurrentLanguage(),
                                     Page = 1,
                                     PageSize = MaxValue - 1,
                                     SortColumn = "SampleID",
                                     SortOrder = SortConstants.Ascending,
                                     SearchString = sample.EIDSSLaboratorySampleID,
                                     UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                     UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                     UserOrganizationID = authenticatedUser.OfficeId,
                                     UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                     UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID) ? null : Convert.ToInt64(authenticatedUser.SiteGroupID)
                                 })
                        {
                            var favorites = await LaboratoryClient.GetSamplesSimpleSearchList(request, _token);
                            if (favorites.Any())
                                await SetMyFavorite(favorites.First().SampleID, null, null);
                        }

                        LaboratoryService.Samples = null;

                        List<DialogButton> buttons = new();
                        DialogButton okButton = new()
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                            ButtonType = DialogButtonType.OK
                        };
                        buttons.Add(okButton);

                        Dictionary<string, object> dialogParams = new()
                        {
                            {nameof(EIDSSDialog.DialogButtons), buttons},
                            {
                                nameof(EIDSSDialog.Message),
                                Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)
                            }
                        };
                        await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams);
                        break;
                    }
                    case null:
                        return -1;
                }

                //if (response.ReturnCode != 0) return (int) response.ReturnCode;

                return (int) response.ReturnCode;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="samples"></param>
        /// <param name="transfers"></param>
        /// <param name="events"></param>
        /// <returns></returns>
        protected async Task<int> SaveTransfers(List<SamplesGetListViewModel> samples, List<TransferredGetListViewModel> transfers, List<EventSaveRequestModel> events)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                MyFavoritesGetRequestModel myFavoritesRequest = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = MyFavoritesDefaultSortColumn,
                    SortOrder = SortConstants.Descending,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };                
                var allMyFavorites = await LaboratoryClient.GetMyFavoritesList(myFavoritesRequest, _token);

                LaboratorySaveRequestModel saveRequest = new()
                {
                    Samples = JsonConvert.SerializeObject(BuildSampleParameters(samples)),
                    Batches = JsonConvert.SerializeObject(new List<BatchesGetListViewModel>()),
                    Tests = JsonConvert.SerializeObject(new List<TestingGetListViewModel>()),
                    TestAmendments = JsonConvert.SerializeObject(new List<TestAmendmentsSaveRequestModel>()),
                    Transfers = JsonConvert.SerializeObject(await BuildTransferredParameters(transfers)),
                    FreezerBoxLocationAvailabilities = JsonConvert.SerializeObject(new List<FreezerBoxLocationAvailabilitySaveRequestModel>()),
                    Events = JsonConvert.SerializeObject(events),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    Favorites = BuildMyFavorites(allMyFavorites),
                    AuditUserName = authenticatedUser.UserName
                };

                var response = await LaboratoryClient.SaveLaboratory(saveRequest, _token);

                switch (response.ReturnCode)
                {
                    case 0:
                    {
                        foreach (var request in from sample in samples where sample.FavoriteIndicator select new SamplesGetRequestModel
                                 {
                                     LanguageId = GetCurrentLanguage(),
                                     Page = 1,
                                     PageSize = MaxValue - 1,
                                     SortColumn = "SampleID",
                                     SortOrder = SortConstants.Ascending,
                                     SearchString = sample.EIDSSLaboratorySampleID,
                                     UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                     UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                     UserOrganizationID = authenticatedUser.OfficeId,
                                     UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                     UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID) ? null : Convert.ToInt64(authenticatedUser.SiteGroupID)
                                 })
                        {
                            var favorites = await LaboratoryClient.GetSamplesSimpleSearchList(request, _token);
                            if (favorites.Any())
                                await SetMyFavorite(favorites.First().SampleID, null, null);
                        }

                        LaboratoryService.Samples = null;

                        List<DialogButton> buttons = new();
                        DialogButton okButton = new()
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                            ButtonType = DialogButtonType.OK
                        };
                        buttons.Add(okButton);

                        Dictionary<string, object> dialogParams = new()
                        {
                            {nameof(EIDSSDialog.DialogButtons), buttons},
                            {
                                nameof(EIDSSDialog.Message),
                                Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)
                            }
                        };
                        await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams);

                        LaboratoryService.PendingSaveTransferred = null;
                        break;
                    }
                    case null:
                        return -1;
                }

                //if (response.ReturnCode != 0) return (int) response.ReturnCode;

                return (int) response.ReturnCode;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="tests"></param>
        /// <returns></returns>
        protected async Task<int> SaveAssignedTests(List<TestingGetListViewModel> tests)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                MyFavoritesGetRequestModel myFavoritesRequest = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = MyFavoritesDefaultSortColumn,
                    SortOrder = SortConstants.Descending,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };                
                var allMyFavorites = await LaboratoryClient.GetMyFavoritesList(myFavoritesRequest, _token);

                IList<SamplesGetListViewModel> samples = new List<SamplesGetListViewModel>();
                if (LaboratoryService.PendingSaveSamples is not null)
                    samples = LaboratoryService.PendingSaveSamples;

                var response = await LaboratoryClient.SaveLaboratory(new LaboratorySaveRequestModel
                {
                    Samples = JsonConvert.SerializeObject(BuildSampleParameters(samples)),
                    Batches = JsonConvert.SerializeObject(new List<BatchesGetListViewModel>()),
                    Tests = JsonConvert.SerializeObject(BuildTestingParameters(tests)),
                    TestAmendments = JsonConvert.SerializeObject(new List<TestAmendmentsSaveRequestModel>()),
                    Transfers = JsonConvert.SerializeObject(new List<TransferredGetListViewModel>()),
                    FreezerBoxLocationAvailabilities =
                        JsonConvert.SerializeObject(new List<FreezerBoxLocationAvailabilitySaveRequestModel>()),
                    Events = JsonConvert.SerializeObject(new List<EventSaveRequestModel>()),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    Favorites = BuildMyFavorites(allMyFavorites),
                    AuditUserName = authenticatedUser.UserName
                }, _token);

                if (response.ReturnCode == 0) 
                { 
                    foreach (var request in from sample in samples where sample.FavoriteIndicator select new SamplesGetRequestModel
                                 {
                                     LanguageId = GetCurrentLanguage(),
                                     Page = 1,
                                     PageSize = MaxValue - 1,
                                     SortColumn = "SampleID",
                                     SortOrder = SortConstants.Ascending,
                                     SearchString = sample.EIDSSLaboratorySampleID,
                                     UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                     UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                     UserOrganizationID = authenticatedUser.OfficeId,
                                     UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                     UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID) ? null : Convert.ToInt64(authenticatedUser.SiteGroupID)
                                 })
                        {
                            var favorites = await LaboratoryClient.GetSamplesSimpleSearchList(request, _token);
                            if (favorites.Any())
                                await SetMyFavorite(favorites.First().SampleID, null, null);
                        }

                    LaboratoryService.Samples = null; 
                    LaboratoryService.Testing = null;

                    List<DialogButton> buttons = new();
                        DialogButton okButton = new()
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                            ButtonType = DialogButtonType.OK
                        };
                        buttons.Add(okButton);

                        Dictionary<string, object> dialogParams = new()
                        {
                            {nameof(EIDSSDialog.DialogButtons), buttons},
                            {
                                nameof(EIDSSDialog.Message),
                                Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)
                            }
                        };
                        await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams);
                }

                if (response.ReturnCode != null) return (int) response.ReturnCode;

                return -1;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                _source?.Cancel();
                _source?.Dispose();
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="samples"></param>
        /// <returns></returns>
        private static List<SamplesSaveRequestModel> BuildSampleParameters(IList<SamplesGetListViewModel> samples)
        {
            List<SamplesSaveRequestModel> requests = new();

            if (samples is null)
                return new List<SamplesSaveRequestModel>();

            foreach (var sampleModel in samples)
            {
                var request = new SamplesSaveRequestModel();
                {
                    request.AccessionByPersonID = sampleModel.AccessionByPersonID;
                    request.AccessionComment = sampleModel.AccessionComment;
                    request.AccessionConditionTypeID = sampleModel.AccessionConditionTypeID;
                    request.AccessionDate = sampleModel.AccessionDate;
                    request.AnimalID = sampleModel.AnimalID;
                    request.BirdStatusTypeID = sampleModel.BirdStatusTypeID;
                    request.CurrentSiteID = sampleModel.CurrentSiteID;
                    request.DestroyedByPersonID = sampleModel.DestroyedByPersonID;
                    request.DestructionDate = sampleModel.DestructionDate;
                    request.DestructionMethodTypeID = sampleModel.DestructionMethodTypeID;
                    if (sampleModel.DiseaseID is not null)
                        request.DiseaseID = sampleModel.DiseaseID.Contains(",")
                            ? null
                            : Convert.ToInt64(sampleModel.DiseaseID);
                    request.EIDSSLocalOrFieldSampleID = sampleModel.EIDSSLocalOrFieldSampleID;
                    request.EIDSSLaboratorySampleID = sampleModel.EIDSSLaboratorySampleID;
                    request.EnteredDate = sampleModel.EnteredDate;
                    request.FavoriteIndicator = sampleModel.FavoriteIndicator;
                    request.CollectedByOrganizationID = sampleModel.CollectedByOrganizationID;
                    request.CollectedByPersonID = sampleModel.CollectedByPersonID;
                    request.CollectionDate = sampleModel.CollectionDate;
                    request.SentDate = sampleModel.SentDate;
                    request.SentToOrganizationID = sampleModel.SentToOrganizationID;
                    request.FreezerSubdivisionID = sampleModel.FreezerSubdivisionID;
                    request.FunctionalAreaID = sampleModel.FunctionalAreaID;
                    request.HumanDiseaseReportID = sampleModel.HumanDiseaseReportID;
                    request.HumanMasterID = sampleModel.HumanMasterID;
                    request.HumanID = sampleModel.HumanID;
                    request.FarmMasterID = sampleModel.FarmMasterID;
                    request.FarmID = sampleModel.FarmID;
                    request.MainTestID = sampleModel.MainTestID;
                    request.MarkedForDispositionByPersonID = sampleModel.MarkedForDispositionByPersonID;
                    request.MonitoringSessionID = sampleModel.MonitoringSessionID;
                    request.Comment = sampleModel.Comment;
                    request.ParentSampleID = sampleModel.ParentSampleID;
                    request.OutOfRepositoryDate = sampleModel.OutOfRepositoryDate;
                    request.ReadOnlyIndicator = sampleModel.ReadOnlyIndicator;
                    request.RootSampleID = sampleModel.RootSampleID;
                    request.RowAction = sampleModel.RowAction;
                    request.RowStatus = sampleModel.RowStatus;
                    request.SampleID = sampleModel.SampleID;
                    request.SampleKindTypeID = sampleModel.SampleKindTypeID;
                    request.SampleStatusTypeID = sampleModel.SampleStatusTypeID;
                    request.SampleTypeID = sampleModel.SampleTypeID;
                    request.SiteID = sampleModel.SiteID;
                    request.SpeciesID = sampleModel.SpeciesID;
                    request.SpeciesTypeID = sampleModel.SpeciesTypeID;
                    request.StorageBoxPlace = sampleModel.StorageBoxPlace;
                    request.VectorID = sampleModel.VectorID;
                    request.VectorSessionID = sampleModel.VectorSessionID;
                    request.VectorTypeID = sampleModel.VectorTypeID;
                    request.VeterinaryDiseaseReportID = sampleModel.VeterinaryDiseaseReportID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="tests"></param>
        /// <returns></returns>
        private static List<TestingSaveRequestModel> BuildTestingParameters(IList<TestingGetListViewModel> tests)
        {
            List<TestingSaveRequestModel> requests = new();

            if (tests is null)
                return new List<TestingSaveRequestModel>();

            foreach (var test in tests)
            {
                var request = new TestingSaveRequestModel();
                {
                    request.BatchTestID = test.BatchTestID;
                    request.ConcludedDate = test.ResultDate;
                    request.ContactPersonName = test.ContactPersonName;
                    request.DiseaseID = Convert.ToInt64(test.DiseaseID);
                    request.ExternalTestIndicator = test.ExternalTestIndicator;
                    request.NonLaboratoryTestIndicator = test.NonLaboratoryTestIndicator;
                    request.Note = test.Note;
                    request.ObservationID = test.ObservationID;
                    request.PerformedByOrganizationID = test.PerformedByOrganizationID;
                    request.PreviousTestStatusTypeID = test.PreviousTestStatusTypeID;
                    request.ReadOnlyIndicator = test.ReadOnlyIndicator;
                    request.ReceivedDate = test.ReceivedDate;
                    request.ResultEnteredByOrganizationID = test.ResultEnteredByOrganizationID;
                    request.ResultEnteredByPersonID = test.ResultEnteredByPersonID;
                    request.RowAction = test.RowAction;
                    request.RowStatus = test.RowStatus;
                    request.SampleID = test.SampleID;
                    request.EIDSSLaboratorySampleID = test.EIDSSLaboratorySampleID;
                    request.StartedDate = test.StartedDate;
                    request.TestCategoryTypeID = test.TestCategoryTypeID;
                    request.TestedByOrganizationID = test.TestedByOrganizationID;
                    request.TestedByPersonID = test.TestedByPersonID;
                    request.TestID = test.TestID;
                    request.TestNameTypeID = test.TestNameTypeID;
                    request.TestNumber = test.TestNumber;
                    request.TestResultTypeID = test.TestResultTypeID;
                    request.TestStatusTypeID = test.TestStatusTypeID;
                    request.ValidatedByOrganizationID = test.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = test.ValidatedByPersonID;
                    request.HumanDiseaseReportID = test.HumanDiseaseReportID;
                    request.VeterinaryDiseaseReportID = test.VeterinaryDiseaseReportID;
                    request.MonitoringSessionID = test.MonitoringSessionID;
                    request.VectorID = test.VectorID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="transfers"></param>
        /// <returns></returns>
        private async Task<List<TransferredSaveRequestModel>> BuildTransferredParameters(
            IList<TransferredGetListViewModel> transfers)
        {
            List<TransferredSaveRequestModel> requests = new();

            if (transfers is null)
                return new List<TransferredSaveRequestModel>();

            foreach (var transfer in transfers)
            {
                var request = new TransferredSaveRequestModel();
                {
                    request.EIDSSTransferID = transfer.EIDSSTransferID;
                    request.PurposeOfTransfer = transfer.PurposeOfTransfer;
                    request.RowAction = transfer.RowAction;
                    request.RowStatus = transfer.RowStatus;
                    request.SampleID = transfer.TransferredOutSampleID;
                    request.SentByPersonID = transfer.SentByPersonID;
                    request.TransferDate = transfer.TransferDate;
                    request.TransferredFromOrganizationID = transfer.TransferredFromOrganizationID;
                    request.TransferredToOrganizationID = transfer.TransferredToOrganizationID;
                    request.SiteID = transfer.TransferredFromOrganizationSiteID;
                    request.TestRequested = transfer.TestRequested;
                    request.TransferID = transfer.TransferID;
                    request.TransferStatusTypeID = transfer.TransferStatusTypeID;
                }

                if (transfer.TestResultTypeID is not null && transfer.TestID is not null)
                {
                    const SystemEventLogTypes eventTypeId =
                        SystemEventLogTypes.TestResultEnteredForLaboratorySampleTransferredOut;

                    TogglePendingSaveEvents(await CreateEvent((long) transfer.TestID,
                        transfer.TestDiseaseID, eventTypeId,
                        transfer.TransferredFromOrganizationSiteID, null));

                    LaboratoryService.TestResultExternalEnteredOrValidationRejectedIndicator = true;

                    request.TransferStatusTypeID = (long) TransferStatusTypeEnum.Final;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="myFavorites"></param>
        /// <returns></returns>
        private static string BuildMyFavorites(IList<MyFavoritesGetListViewModel> myFavorites)
        {
            string favoritesXml;

            myFavorites = myFavorites.GroupBy(x => x.SampleID).Select(y => y.First()).ToList();

            if (myFavorites.Count > 0)
            {
                favoritesXml = myFavorites.Aggregate("<Favorites>",
                    (current, favoriteModel) => current + "<Favorite SampleID=\"" + favoriteModel.SampleID + "\" />");
                favoritesXml += "</Favorites>";
            }
            else
            {
                favoritesXml = "<Favorites></Favorites>";
            }

            return favoritesXml;
        }

        /// <summary>
        /// </summary>
        /// <param name="batches"></param>
        /// <returns></returns>
        private static List<BatchesSaveRequestModel> BuildBatchesParameters(IList<BatchesGetListViewModel> batches)
        {
            List<BatchesSaveRequestModel> requests = new();

            if (batches is null)
                return new List<BatchesSaveRequestModel>();

            foreach (var batch in batches)
            {
                var request = new BatchesSaveRequestModel();
                {
                    request.BatchStatusTypeID = batch.BatchStatusTypeID;
                    request.BatchTestID = batch.BatchTestID;
                    request.EIDSSBatchTestID = batch.EIDSSBatchTestID;
                    request.ObservationID = batch.ObservationID;
                    request.PerformedByOrganizationID = batch.PerformedByOrganizationID;
                    request.PerformedByPersonID = batch.PerformedByPersonID;
                    request.PerformedDate = batch.PerformedDate;
                    request.ResultEnteredByOrganizationID = batch.ResultEnteredByOrganizationID;
                    request.ResultEnteredByPersonID = batch.ResultEnteredByPersonID;
                    request.RowAction = batch.RowAction;
                    request.RowStatus = batch.RowStatus;
                    request.SiteID = batch.SiteID;
                    request.TestNameTypeID = batch.BatchTestTestNameTypeID;
                    request.ValidatedByOrganizationID = batch.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = batch.ValidatedByPersonID;
                    request.ValidationDate = batch.ValidationDate;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #region Print Barcodes

        /// <summary>
        /// </summary>
        /// <param name="samplesList"></param>
        /// <returns></returns>
        public async Task GenerateBarcodeReport(string samplesList)
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                SamplesGetRequestModel requestNewSamples = new()
                {
                    SampleList = samplesList,
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "strBarcode",
                    SortOrder = SortConstants.Ascending
                };
                var newSamples = await LaboratoryClient.GetSamplesByBarCodeList(requestNewSamples, _token);

                if (newSamples.Any())
                {
                    samplesList = newSamples.Aggregate(Empty,
                        (current, s) => current + (s.SampleID.ToString() + ','));

                    samplesList = samplesList.Remove(samplesList.Length - 1, 1);

                    ReportViewModel model = new();

                    model.AddParameter("LangID", GetCurrentLanguage());
                    model.AddParameter("SamplesList", samplesList);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.PrintBarcodesPageHeading),
                        new Dictionary<string, object> { { "ReportName", ConfigurationService.GetValue<string>("ReportServer:Path").Replace("/", Empty) + "/AliquotBarCodes" }, { "Parameters", model.Parameters } },
                        new DialogOptions
                        {
                            Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog,
                            Resizable = true,
                            Draggable = false
                        });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}