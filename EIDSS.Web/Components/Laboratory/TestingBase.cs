#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class TestingBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ILogger<TestingBase> Logger { get; set; }
        [Inject] private ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback<int> SearchEvent { get; set; }
        [Parameter] public EventCallback<int> ClearSearchEvent { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public EventCallback SetMyFavoriteEvent { get; set; }
        [Parameter] public EventCallback<IList<LaboratorySelectionViewModel>> AssignTestEvent { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<TestingGetListViewModel> TestingGrid { get; set; }
        public int InProgressCount { get; set; }
        public int Count { get; set; }
        public string SimpleSearchString { get; set; }
        private AdvancedSearchGetRequestModel AdvancedSearchCriteria { get; set; } = new();
        private bool IsAdvancedSearch { get; set; }
        private bool IsSearchPerformed { get; set; }
        public bool IsLoading { get; set; }
        protected IList<TestingGetListViewModel> Testing { get; set; }
        private bool IsReload { get; set; }
        protected SearchComponent Search { get; set; }
        public bool TestingWritePermission { get; set; }

        #endregion

        #region Constants

        private const string ScrollToTopJs = "scrollToTop";

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;
        private int _databaseQueryCount;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public TestingBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected TestingBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);
            TestingWritePermission = _userPermissions.Write;

            if (_userPermissions.Read)
            {
                await GetTestResultTypes();

                var result =
                    await BrowserStorage.GetAsync<string>(LaboratorySearchStorageConstants.TestingSearchString);
                SimpleSearchString = result.Success ? result.Value : Empty;

                if (LaboratoryService.Testing == null)
                {
                    IsLoading = true;

                    if (SimpleSearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                        SimpleSearchString = Empty;
                }
                else if (LaboratoryService.TabChangeIndicator)
                {
                    LaboratoryService.TabChangeIndicator = false;

                    if (LaboratoryService.SearchTesting != null)
                    {
                        IsSearchPerformed = true;

                        if (SimpleSearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                        {
                            SimpleSearchString = Empty;
                            IsAdvancedSearch = true;
                            Search.AdvancedSearchPerformedIndicator = true;
                        }
                    }
                }
            }

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (_userPermissions.Read)
                {
                    await GetAccessionConditionTypes();
                    await GetFunctionalAreas();
                    await GetSampleStatusTypes();
                    await GetTestResultTypes();
                    await GetTestStatusTypes();
                    await GetTestCategoryTypes();

                    LaboratoryService.SelectedTesting = new List<TestingGetListViewModel>();
                }
                else
                    await InsufficientPermissions();
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadTestingData(LoadDataArgs args)
        {
            try
            {
                if (_userPermissions.Read)
                {
                    var pageSize = 100;
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "EIDSSLaboratorySampleID";
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    if (TestingGrid.PageSize != 0)
                        pageSize = TestingGrid.PageSize;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (LaboratoryService.SearchTesting is null && LaboratoryService.Testing is null)
                        IsLoading = true;

                    if (IsLoading && IsSearchPerformed == false && IsReload == false)
                    {
                        if (!IsNullOrEmpty(SimpleSearchString))
                        {
                            var request = new TestingGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SearchString = SimpleSearchString,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                DaysFromAccessionDate = Convert.ToInt32(ConfigurationService.SystemPreferences
                                    .NumberDaysDisplayedByDefault),
                                AccessionedIndicator = SimpleSearchString == Localizer.GetString(FieldLabelResourceKeyConstants.LaboratoryAdvancedSearchModalUnaccessionedFieldLabel) ? false : null,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchTesting =
                                await LaboratoryClient.GetTestingSimpleSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                _databaseQueryCount = !LaboratoryService.SearchTesting.Any()
                                    ? 0
                                    : LaboratoryService.SearchTesting.First().TotalRowCount;

                                if (LaboratoryService.SearchTesting.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchTesting[0].InProgressCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Testing = LaboratoryService.SearchTesting.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else if (IsAdvancedSearch)
                        {
                            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                                .LaboratoryTestingAdvancedSearchPerformedIndicatorKey);

                            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                            if (searchPerformedIndicator)
                            {
                                var searchModelResult = await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                                    SearchPersistenceKeys.LaboratoryTestingAdvancedSearchModelKey);

                                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                                if (searchModel != null) AdvancedSearchCriteria = searchModel;

                                if (AdvancedSearchCriteria.SampleStatusTypeList != null &&
                                    AdvancedSearchCriteria.SampleStatusTypeList.Any(x => x == 0))
                                {
                                    // Un-accessioned goes in the accession indicator list parameter.
                                    AdvancedSearchCriteria.AccessionIndicatorList =
                                        AdvancedSearchCriteria.SampleStatusTypeList.First(x => x == 0)
                                            .ToString();

                                    var sampleStatusTypes =
                                        AdvancedSearchCriteria.SampleStatusTypeList.ToList();
                                    sampleStatusTypes.Remove(sampleStatusTypes.First(x => x == 0));
                                    AdvancedSearchCriteria.SampleStatusTypeList = sampleStatusTypes;

                                    AdvancedSearchCriteria.SampleStatusTypes =
                                        sampleStatusTypes.Count == 0
                                            ? null
                                            : Join(",", AdvancedSearchCriteria.SampleStatusTypeList);
                                }
                            }

                            var request = new AdvancedSearchGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                AccessionIndicatorList = AdvancedSearchCriteria.AccessionIndicatorList,
                                DateFrom = AdvancedSearchCriteria.DateFrom,
                                DateTo = AdvancedSearchCriteria.DateTo,
                                DiseaseID = AdvancedSearchCriteria.DiseaseID,
                                EIDSSLaboratorySampleID = AdvancedSearchCriteria.EIDSSLaboratorySampleID,
                                EIDSSLocalOrFieldSampleID = AdvancedSearchCriteria.EIDSSLocalOrFieldSampleID,
                                EIDSSReportSessionOrCampaignID = AdvancedSearchCriteria.EIDSSReportSessionOrCampaignID,
                                EIDSSTransferID = AdvancedSearchCriteria.EIDSSTransferID,
                                FarmOwnerName = AdvancedSearchCriteria.FarmOwnerName,
                                PatientName = AdvancedSearchCriteria.PatientName,
                                ReportOrSessionTypeID = AdvancedSearchCriteria.ReportOrSessionTypeID,
                                ResultsReceivedFromOrganizationID =
                                    AdvancedSearchCriteria.ResultsReceivedFromOrganizationID,
                                SampleStatusTypeList = AdvancedSearchCriteria.SampleStatusTypeList,
                                SampleStatusTypes = AdvancedSearchCriteria.SampleStatusTypes,
                                SampleTypeID = AdvancedSearchCriteria.SampleTypeID,
                                SentToOrganizationID = AdvancedSearchCriteria.SentToOrganizationID,
                                SentToOrganizationSiteID = AdvancedSearchCriteria.SentToOrganizationSiteID,
                                SpeciesTypeID = AdvancedSearchCriteria.SpeciesTypeID,
                                SurveillanceTypeID = AdvancedSearchCriteria.SurveillanceTypeID,
                                TestNameTypeID = AdvancedSearchCriteria.TestNameTypeID,
                                TestResultDateFrom = AdvancedSearchCriteria.TestResultDateFrom,
                                TestResultDateTo = AdvancedSearchCriteria.TestResultDateTo,
                                TestResultTypeID = AdvancedSearchCriteria.TestResultTypeID,
                                TestStatusTypeID = AdvancedSearchCriteria.TestStatusTypeID,
                                TransferredToOrganizationID = AdvancedSearchCriteria.TransferredToOrganizationID,
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchTesting =
                                await LaboratoryClient.GetTestingAdvancedSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchTesting.Any() &&
                                    LaboratoryService.SearchTesting.First().RowAction ==
                                    (int) RowActionTypeEnum.NarrowSearchCriteria)
                                {
                                    await ShowNarrowSearchCriteriaDialog();
                                }

                                _databaseQueryCount = !LaboratoryService.SearchTesting.Any()
                                    ? 0
                                    : LaboratoryService.SearchTesting.First().TotalRowCount;

                                if (LaboratoryService.SearchTesting.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(
                                        LaboratoryService.SearchTesting[0].InProgressCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Testing = LaboratoryService.SearchTesting.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else
                        {
                            var request = new TestingGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                DaysFromAccessionDate = Convert.ToInt32(ConfigurationService.SystemPreferences
                                    .NumberDaysDisplayedByDefault),
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            if (LaboratoryService.Testing is null || !LaboratoryService.Testing.Any())
                            {
                                LaboratoryService.Testing = await LaboratoryClient.GetTestingList(request, _token);
                                if (_source.IsCancellationRequested == false)
                                {
                                    ApplyPendingSaveRecordsToDefaultList();

                                    Testing = LaboratoryService.Testing.Take(pageSize).ToList();

                                    _databaseQueryCount = LaboratoryService.Testing.Any(x => x.TestID > 0)
                                        ? LaboratoryService.Testing.First(x => x.TestID > 0).TotalRowCount
                                        : _databaseQueryCount;
                                }
                            }
                            else
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Testing = LaboratoryService.Testing.Skip((page - 1) * pageSize).Take(pageSize).ToList();
                            }
                        }

                        InProgressCount = !Testing.Any() ? _databaseQueryCount : Testing.First().InProgressCount;
                        Count = !Testing.Any() ? _databaseQueryCount : Testing.First().TotalRowCount;
                    }
                    else
                    {
                        if (LaboratoryService.SearchTesting == null)
                        {
                            if (LaboratoryService.Testing != null)
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Testing = LaboratoryService.Testing.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                                _databaseQueryCount =
                                    (LaboratoryService.Testing ?? new List<TestingGetListViewModel>()).Any(x =>
                                        x.TestID > 0)
                                        ? (LaboratoryService.Testing ?? new List<TestingGetListViewModel>())
                                        .First(x => x.TestID > 0)
                                        .TotalRowCount
                                        : _databaseQueryCount;
                            }
                        }
                        else
                        {
                            ApplySearchListSort(sortColumn, sortOrder);

                            ApplyPendingSaveRecordsToSearchList();

                            Testing = LaboratoryService.SearchTesting.Skip((page - 1) * pageSize).Take(pageSize)
                                .ToList();
                            _databaseQueryCount =
                                (LaboratoryService.SearchTesting ?? new List<TestingGetListViewModel>()).Any(x =>
                                    x.TestID > 0)
                                    ? (LaboratoryService.SearchTesting ?? new List<TestingGetListViewModel>())
                                    .First(x => x.TestID > 0)
                                    .TotalRowCount
                                    : _databaseQueryCount;
                        }
                    }

                    Count = _databaseQueryCount + LaboratoryService.NewTestsAssignedCount;

                    foreach (var t in Testing)
                    {
                        t.AdministratorRoleIndicator = authenticatedUser.IsInRole(RoleEnum.Administrator);
                        t.HumanLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Human);
                        t.VeterinaryLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Vet);
                        t.AllowDatesInThePast = ConfigurationService.SystemPreferences.AllowPastDates;
                        if (t.SentToOrganizationID == authenticatedUser.OfficeId)
                            t.WritePermissionIndicator = _userPermissions.Write;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);

                //Catch timeout exception
                if (ex.Message.Contains("Timeout"))
                {
                    if (_source?.IsCancellationRequested == false) _source?.Cancel();
                    await ShowNarrowSearchCriteriaDialog();
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                IsLoading = false;
                IsReload = false;
                IsSearchPerformed = false;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        private void ApplyDefaultListSort(string sortColumn, string sortOrder)
        {
            if (sortColumn is null) return;
            if (sortOrder == SortConstants.Ascending)
            {
                LaboratoryService.Testing = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Testing.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Testing.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Testing.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Testing.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Testing.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Testing.OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.Testing.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Testing.OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Testing.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.Testing.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestCategoryTypeName" => LaboratoryService.Testing.OrderBy(x => x.TestCategoryTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.Testing.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "StartedDate" => LaboratoryService.Testing.OrderBy(x => x.StartedDate).ToList(),
                    "TestResultTypeName" => LaboratoryService.Testing.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.Testing.OrderBy(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Testing.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Testing
                };
            }
            else
            {
                LaboratoryService.Testing = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Testing.OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Testing.OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Testing.OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Testing.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Testing.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Testing.OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.Testing.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Testing.OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Testing.OrderByDescending(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.Testing.OrderByDescending(x => x.TestNameTypeName).ToList(),
                    "TestCategoryTypeName" => LaboratoryService.Testing.OrderByDescending(x => x.TestCategoryTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.Testing.OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "StartedDate" => LaboratoryService.Testing.OrderByDescending(x => x.StartedDate).ToList(),
                    "TestResultTypeName" => LaboratoryService.Testing.OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.Testing.OrderByDescending(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Testing.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Testing
                };
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        private void ApplySearchListSort(string sortColumn, string sortOrder)
        {
            if (sortColumn is null) return;
            if (sortOrder == SortConstants.Ascending)
            {
                LaboratoryService.SearchTesting = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchTesting.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchTesting.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchTesting.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchTesting.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchTesting.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchTesting.OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchTesting.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchTesting.OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchTesting.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchTesting.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestCategoryTypeName" => LaboratoryService.SearchTesting.OrderBy(x => x.TestCategoryTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchTesting.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "StartedDate" => LaboratoryService.SearchTesting.OrderBy(x => x.StartedDate).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchTesting.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchTesting.OrderBy(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchTesting.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchTesting
                };
            }
            else
            {
                LaboratoryService.SearchTesting = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchTesting.OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchTesting.OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchTesting.OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchTesting.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.TestNameTypeName).ToList(),
                    "TestCategoryTypeName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.TestCategoryTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "StartedDate" => LaboratoryService.SearchTesting.OrderByDescending(x => x.StartedDate).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchTesting.OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchTesting.OrderByDescending(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchTesting.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchTesting
                };
            }
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToDefaultList()
        {
            if (LaboratoryService.PendingSaveTesting == null || !LaboratoryService.PendingSaveTesting.Any())
                return;

            foreach (var t in LaboratoryService.PendingSaveTesting)
            {
                if (LaboratoryService.Testing != null && LaboratoryService.Testing.All(x => x.TestID != t.TestID))
                    LaboratoryService.Testing?.Add(t);
                else
                {
                    if (LaboratoryService.Testing == null) continue;
                    var recordIndex = LaboratoryService.Testing.ToList().FindIndex(x => x.TestID == t.TestID);
                    if (recordIndex >= 0)
                        LaboratoryService.Testing[recordIndex] = t;
                }
            }

            if (LaboratoryService.Testing != null)
                LaboratoryService.Testing =
                    LaboratoryService.Testing.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToSearchList()
        {
            if (LaboratoryService.PendingSaveTesting == null || !LaboratoryService.PendingSaveTesting.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveTesting)
            {
                if (LaboratoryService.SearchTesting != null && LaboratoryService.SearchTesting.All(x => x.TestID != t.TestID))
                {
                    if (SimpleSearchString is not null)
                    {
                        if (t.AccessionConditionOrSampleStatusTypeName.Contains(SimpleSearchString) ||
                            t.DiseaseName.Contains(SimpleSearchString) ||
                            t.EIDSSAnimalID is not null && t.EIDSSAnimalID.Contains(SimpleSearchString) ||
                            t.EIDSSLaboratorySampleID is not null && t.EIDSSLaboratorySampleID.Contains(SimpleSearchString) ||
                            t.EIDSSLocalOrFieldSampleID is not null && t.EIDSSLocalOrFieldSampleID.Contains(SimpleSearchString) ||
                            t.EIDSSReportOrSessionID is not null && t.EIDSSReportOrSessionID.Contains(SimpleSearchString) ||
                            t.FunctionalAreaName is not null && t.FunctionalAreaName.Contains(SimpleSearchString) ||
                            t.PatientOrFarmOwnerName is not null && t.PatientOrFarmOwnerName.Contains(SimpleSearchString) ||
                            t.TestNameTypeName is not null && t.TestNameTypeName.Contains(SimpleSearchString) ||
                            t.TestStatusTypeName is not null && t.TestStatusTypeName.Contains(SimpleSearchString) ||
                            t.StartedDate is not null && t.StartedDate.ToString().Contains(SimpleSearchString) ||
                            t.TestResultTypeName is not null && t.TestResultTypeName.Contains(SimpleSearchString) ||
                            t.TestCategoryTypeName is not null && t.TestCategoryTypeName.Contains(SimpleSearchString) ||
                            t.AccessionDate is not null && t.AccessionDate.ToString().Contains(SimpleSearchString) ||
                            t.SampleTypeName.Contains(SimpleSearchString))
                            LaboratoryService.SearchTesting?.Add(t);
                    }
                    else
                        LaboratoryService.SearchTesting?.Add(t);
                }
                else
                {
                    if (LaboratoryService.SearchTesting == null) continue;
                    var recordIndex = LaboratoryService.SearchTesting.ToList().FindIndex(x => x.TestID == t.TestID);
                    if (recordIndex >= 0)
                        LaboratoryService.SearchTesting[recordIndex] = t;
                }
            }

            if (LaboratoryService.SearchTesting != null)
                LaboratoryService.SearchTesting =
                    LaboratoryService.SearchTesting.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
            };
            var dialogOptions = new DialogOptions()
            {
                ShowTitle = false,
                ShowClose = false
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams, dialogOptions);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                //search timed out, narrow search criteria
                _source?.Cancel();
                _source = new CancellationTokenSource();
                _token = _source.Token;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        protected void OnRowRender(RowRenderEventArgs<TestingGetListViewModel> record)
        {
            try
            {
                var cssClass = Empty;

                if (record.Data.ActionPerformedIndicator)
                    cssClass = record.Data.RowAction switch
                    {
                        (int)RowActionTypeEnum.Insert => LaboratoryModuleCSSClassConstants.SavePending,
                        (int)RowActionTypeEnum.Update => LaboratoryModuleCSSClassConstants.SavePending,
                        _ => LaboratoryModuleCSSClassConstants.NoSavePending
                    };

                record.Attributes.Add("class", cssClass);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        protected void OnCellRender(DataGridCellRenderEventArgs<TestingGetListViewModel> record)
        {
            try
            {
                var style = Empty;

                style += LaboratoryModuleCSSClassConstants.AccessionedCell;

                record.Attributes.Add("style", style);
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
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Testing is null)
                    return false;

                if (LaboratoryService.SelectedTesting is { Count: > 0 })
                    if (Testing.Any(item => LaboratoryService.SelectedTesting.Any(x => x.TestID == item.TestID)))
                        return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void HeaderRecordSelectionChange(bool? value)
        {
            try
            {
                LaboratoryService.SelectedTesting ??= new List<TestingGetListViewModel>();

                if (value == false)
                {
                    foreach (var item in Testing)
                    {
                        if (LaboratoryService.SelectedTesting.All(x => x.TestID != item.TestID)) continue;
                        {
                            var selected = LaboratoryService.SelectedTesting.First(x => x.TestID == item.TestID);

                            LaboratoryService.SelectedTesting.Remove(selected);
                        }
                    }
                }
                else
                {
                    foreach (var item in Testing)
                        LaboratoryService.SelectedTesting.Add(item);
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
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsRecordSelected(TestingGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedTesting != null &&
                    LaboratoryService.SelectedTesting.Any(x => x.TestID == item.TestID))
                    return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected void RecordSelectionChange(bool? value, TestingGetListViewModel item)
        {
            try
            {
                LaboratoryService.SelectedTesting ??= new List<TestingGetListViewModel>();

                if (value == false)
                {
                    item = LaboratoryService.SelectedTesting.First(x => x.TestID == item.TestID);

                    LaboratoryService.SelectedTesting.Remove(item);
                }
                else
                {
                    LaboratoryService.SelectedTesting.Add(item);
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
        /// <param name="item"></param>
        protected async Task OnTestCategoryDropDownChange(TestingGetListViewModel item)
        {
            try
            {
                IsReload = true;

                var test = Testing.First(x => x.TestID == item.TestID);

                if (test.TestCategoryTypeID is not null &&
                    LaboratoryService.TestCategoryTypes.Any(x => x.IdfsBaseReference == test.TestCategoryTypeID))
                    test.TestCategoryTypeName = LaboratoryService.TestCategoryTypes.First(x =>
                        x.IdfsBaseReference == test.TestCategoryTypeID).Name;
                else
                    test.TestCategoryTypeName = null;

                test.ActionPerformedIndicator = true;

                if (test.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != test.SampleID && x.TestID != test.TestID))
                    {
                        await GetMyFavorite(null, test, null, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).TestCategoryTypeID =
                            test.TestCategoryTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestCategoryTypeName = test.TestCategoryTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == test.SampleID && x.TestID == test.TestID));
                    }
                }

                TogglePendingSaveTesting(test);

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnTestResultDropDownChange(TestingGetListViewModel item)
        {
            try
            {
                IsReload = true;

                var test = Testing.First(x => x.TestID == item.TestID);

                if (item.TestResultTypeID is null)
                {
                    test.ResultDate = null;
                    test.ResultEnteredByOrganizationID = null;
                    test.ResultEnteredByPersonID = null;
                    test.ResultEnteredByPersonName = null;
                    test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                        x.IdfsBaseReference == (long)TestStatusTypeEnum.InProgress).IdfsBaseReference;
                    test.TestResultTypeID = null;
                }
                else
                {
                    test.ResultDate = item.ResultDate ?? DateTime.Now;
                    test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                    test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    test.ResultEnteredByPersonName = authenticatedUser.LastName + (IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);

                    if (test.TestStatusTypeID != (long) TestStatusTypeEnum.Final)
                        test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                            x.IdfsBaseReference == (long)TestStatusTypeEnum.Preliminary).IdfsBaseReference;

                    test.TestResultTypeID = item.TestResultTypeID;
                }

                test.ActionPerformedIndicator = true;

                if (test.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != test.SampleID  && x.TestID != test.TestID))
                    {
                        await GetMyFavorite(null, test, null, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).ResultDate =
                            test.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeID = test.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeName = test.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeID = test.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeName = test.TestStatusTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == test.SampleID && x.TestID == test.TestID));
                    }
                }

                TogglePendingSaveTesting(test);

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnResultDateChange(TestingGetListViewModel item)
        {
            try
            {
                IsReload = true;

                var test = Testing.First(x => x.TestID == item.TestID);

                if (item.ResultDate is null)
                {
                    test.ResultEnteredByOrganizationID = null;
                    test.ResultEnteredByPersonID = null;
                    test.ResultEnteredByPersonName = null;
                    test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                        x.IdfsBaseReference == (long)TestStatusTypeEnum.InProgress).IdfsBaseReference;
                    test.TestResultTypeID = null;
                    test.TestResultTypeRequiredVisibleIndicator = false;
                }
                else
                {
                    test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                    test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    test.ResultEnteredByPersonName = authenticatedUser.LastName + (IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);
                    test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                        x.IdfsBaseReference == (long)TestStatusTypeEnum.Preliminary).IdfsBaseReference;
                    test.TestResultTypeID = item.TestResultTypeID;
                    test.TestResultTypeRequiredVisibleIndicator = true;
                }

                if (test.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != test.SampleID && x.TestID != test.TestID))
                    {
                        await GetMyFavorite(null, test, null, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).ResultDate =
                            test.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeID = test.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeName = test.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeID = test.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeName = test.TestStatusTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == test.SampleID && x.TestID == test.TestID));
                    }
                }

                test.ActionPerformedIndicator = true;

                TogglePendingSaveTesting(test);

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        protected async void OnTestStatusDropDownChange(TestingGetListViewModel item)
        {
            try
            {
                IsReload = true;

                var test = Testing.First(x => x.TestID == item.TestID);

                switch (item.TestStatusTypeID)
                {
                    case (long)TestStatusTypeEnum.Deleted:
                        test.TestResultTypeRequiredVisibleIndicator = false;
                        break;

                    case (long)TestStatusTypeEnum.MarkedForDeletion:
                        test.TestResultTypeRequiredVisibleIndicator = false;
                        break;

                    case (long)TestStatusTypeEnum.NotStarted:
                        test.TestResultTypeRequiredVisibleIndicator = false;
                        break;

                    case (long)TestStatusTypeEnum.InProgress:
                        test.ResultDate = null;
                        test.ResultEnteredByOrganizationID = null;
                        test.ResultEnteredByPersonID = null;
                        test.ResultEnteredByPersonName = null;
                        test.TestResultTypeID = null;
                        test.TestResultTypeRequiredVisibleIndicator = false;
                        break;

                    case (long)TestStatusTypeEnum.Preliminary:
                        test.ResultDate = item.ResultDate ?? DateTime.Now;
                        test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                        test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                        test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                            x.IdfsBaseReference == (long)TestStatusTypeEnum.Preliminary).IdfsBaseReference;
                        test.TestResultTypeRequiredVisibleIndicator = true;
                        break;
                    case (long)TestStatusTypeEnum.Final:
                        test.ResultDate = item.ResultDate ?? DateTime.Now;
                        test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                        test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                        test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                            x.IdfsBaseReference == (long)TestStatusTypeEnum.Final).IdfsBaseReference;
                        test.TestResultTypeRequiredVisibleIndicator = true;
                        test.TestResultTypeDisabledIndicator = false;

                        test.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                        test.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        test.ValidatedByPersonName = authenticatedUser.LastName +
                                                     (IsNullOrEmpty(authenticatedUser.FirstName)
                                                         ? ""
                                                         : ", " + authenticatedUser.FirstName);
                        test.TestStatusTypeSelectDisabledIndicator = false;
                        break;
                }

                test.ActionPerformedIndicator = true;

                if (test.FavoriteIndicator)
                {
                    // Has the user selected the my favorites tab?
                    if (LaboratoryService.MyFavorites == null ||
                        LaboratoryService.MyFavorites.All(x => x.SampleID != test.SampleID && x.TestID != test.TestID))
                    {
                        await GetMyFavorite(null, test, null, null);
                    }
                    else
                    {
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).ActionPerformedIndicator =
                            true;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID).ResultDate =
                            test.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeID = test.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestResultTypeName = test.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeID = test.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeName = test.TestStatusTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID && x.TestID == test.TestID)
                            .TestStatusTypeSelectDisabledIndicator = false;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == test.SampleID && x.TestID == test.TestID));
                    }
                }

                TogglePendingSaveTesting(test);

                await SortPendingSave();
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
        protected async Task OnRefreshTesting()
        {
            IsReload = true;

            LaboratoryService.SelectedTesting ??= new List<TestingGetListViewModel>();

            LaboratoryService.SelectedTesting.Clear();

            await TestingGrid.FirstPage(true);

            await JsRuntime.InvokeVoidAsync(ScrollToTopJs, _token);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReloadTesting()
        {
            try
            {
                IsLoading = true;

                await SaveEvent.InvokeAsync();

                await TestingGrid.Reload();
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
        private async Task SortPendingSave()
        {
            await TestingGrid.Reload();
            await TestingGrid.FirstPage();

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <param name="test"></param>
        /// <returns></returns>
        protected async Task OnAccessionCommentClick(TestingGetListViewModel test)
        {
            try
            {
                IsReload = true;

                AccessionInViewModel model = new()
                {
                    AccessionConditionTypeID = test.AccessionConditionTypeID,
                    AccessionInComment = test.AccessionComment,
                    WritePermissionIndicator = test.WritePermissionIndicator,
                    SampleID = test.SampleID
                };

                var result = await DiagService.OpenAsync<AccessionInComment>(Empty,
                    new Dictionary<string, object> { { "Tab", LaboratoryTabEnum.Testing }, { "AccessionInAction", model } },
                    new DialogOptions
                    {
                        ShowTitle = false,
                        Style = LaboratoryModuleCSSClassConstants.AccessionCommentDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true
                    });

                if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    await UpdateTest(test);
                    LaboratoryService.SelectedTesting = new List<TestingGetListViewModel>();
                    await SortPendingSave();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Search Events

        /// <summary>
        /// </summary>
        /// <param name="simpleSearchString"></param>
        /// <returns></returns>
        protected async Task OnSimpleSearch(string simpleSearchString)
        {
            IsLoading = true;
            IsAdvancedSearch = false;
            AdvancedSearchCriteria = new AdvancedSearchGetRequestModel();
            SimpleSearchString = simpleSearchString;

            await TestingGrid.FirstPage(true);
        }

        /// <summary>
        ///     LUC13 - Search for a Sample - Advanced Search
        /// </summary>
        /// <param name="searchCriteria"></param>
        /// <returns></returns>
        protected async Task OnAdvancedSearch(AdvancedSearchGetRequestModel searchCriteria)
        {
            IsLoading = true;
            IsAdvancedSearch = true;
            AdvancedSearchCriteria = searchCriteria;
            SimpleSearchString = null;

            await TestingGrid.FirstPage(true);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearSearch()
        {
            try
            {
                IsAdvancedSearch = false;
                AdvancedSearchCriteria = new AdvancedSearchGetRequestModel();
                SimpleSearchString = null;
                LaboratoryService.SearchTesting = null;
                _databaseQueryCount = 0;

                await TestingGrid.FirstPage(true);

                if (LaboratoryService.Testing is not null && LaboratoryService.Testing.Any())
                    InProgressCount = LaboratoryService.Testing.First().InProgressCount;
                await ClearSearchEvent.InvokeAsync(InProgressCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Test Events

        /// <summary>
        /// </summary>
        /// <param name="test"></param>
        /// <returns></returns>
        protected async Task OnEditTest(TestingGetListViewModel test)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryDetails>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Tab", LaboratoryTabEnum.Testing}, {"SampleId", test.SampleID}, {"TestId", test.TestID}, { "Test", test }, {"DiseaseId", test.DiseaseID.ToString()}
                    },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryRecordDetailsDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result is DialogReturnResult)
                    await OnRefreshTesting();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Set My Favorite Event

        /// <summary>
        /// </summary>
        /// <param name="test"></param>
        /// <returns></returns>
        protected async Task OnSetMyFavorite(TestingGetListViewModel test)
        {
            try
            {
                await SetMyFavorite(test.SampleID, null, null);
                await SetMyFavoriteEvent.InvokeAsync();

                LaboratoryService.SelectedTesting ??= new List<TestingGetListViewModel>();
                LaboratoryService.SelectedTesting.Clear();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Assign Test Event

        /// <summary>
        /// </summary>
        protected async Task OnAssignTest()
        {
            try
            {
                IsReload = true;

                LaboratoryService.SelectedTesting.Clear();

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Batch Event

        /// <summary>
        /// </summary>
        protected async Task OnBatch()
        {
            try
            {
                LaboratoryService.SelectedTesting.Clear();

                await OnReloadTesting();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Set Test Result Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSetTestResult()
        {
            try
            {
                LaboratoryService.SelectedTesting.Clear();

                await OnReloadTesting();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Amend Test Result Event

        /// <summary>
        /// </summary>
        protected async Task OnAmendTest()
        {
            try
            {
                IsReload = true;

                LaboratoryService.SelectedTesting.Clear();

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Test Record Deletion Event

        /// <summary>
        /// </summary>
        protected async Task OnDeleteTestRecord()
        {
            try
            {
                IsReload = true;

                await DeleteTestRecord(LaboratoryTabEnum.Testing);

                LaboratoryService.SelectedTesting.Clear();

                await SortPendingSave();
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
