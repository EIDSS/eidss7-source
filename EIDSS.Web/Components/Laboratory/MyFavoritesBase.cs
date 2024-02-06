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
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.JSInterop;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class MyFavoritesBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<MyFavoritesBase> Logger { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback<int> SearchEvent { get; set; }
        [Parameter] public EventCallback<int> ClearSearchEvent { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public EventCallback SetMyFavoriteEvent { get; set; }
        [Parameter] public EventCallback SetMyFavoriteForNewRecordEvent { get; set; }
        [Parameter] public EventCallback<IList<LaboratorySelectionViewModel>> AccessionInEvent { get; set; }
        [Parameter] public EventCallback CreateAliquotDerivativeEvent { get; set; }
        [Parameter] public EventCallback AssignTestEvent { get; set; }
        [Parameter] public EventCallback<IList<LaboratorySelectionViewModel>> TransferOutEvent { get; set; }

        #endregion

        #region Properties

        public RadzenDataGrid<MyFavoritesGetListViewModel> MyFavoritesGrid { get; set; }
        public int Count { get; set; }
        public string SimpleSearchString { get; set; }
        private AdvancedSearchGetRequestModel AdvancedSearchCriteria { get; set; } = new();
        private bool IsAdvancedSearch { get; set; }
        private bool IsSearchPerformed { get; set; }
        public bool IsLoading { get; set; }
        protected IList<MyFavoritesGetListViewModel> MyFavorites { get; set; }
        public bool CanModifyAccessionDatePermissionIndicator { get; set; }
        public bool SamplesWritePermission { get; set; }
        public bool TestingWritePermission { get; set; }
        public bool TransferredWritePermission { get; set; }
        private bool IsReload { get; set; }
        protected SearchComponent Search { get; set; }

        #endregion

        #region Constants

        private const string DefaultSortColumn = "Default";
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
        public MyFavoritesBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected MyFavoritesBase() : base(CancellationToken.None)
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

            _userPermissions = GetUserPermissions(PagePermission.CanModifyAccessionDateAfterSave);
            CanModifyAccessionDatePermissionIndicator = _userPermissions.Execute;

            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
            SamplesWritePermission = _userPermissions.Write;
            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);
            TestingWritePermission = _userPermissions.Write;
            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);
            TransferredWritePermission = _userPermissions.Write;

            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
            if (_userPermissions.Read)
            {
                await GetTestResultTypes();

                var result =
                    await BrowserStorage.GetAsync<string>(LaboratorySearchStorageConstants.MyFavoritesSearchString);
                SimpleSearchString = result.Success ? result.Value : Empty;

                if (LaboratoryService.MyFavorites == null)
                {
                    IsLoading = true;

                    if (SimpleSearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                        SimpleSearchString = Empty;
                }
                else if (LaboratoryService.TabChangeIndicator)
                {
                    LaboratoryService.TabChangeIndicator = false;

                    if (LaboratoryService.SearchMyFavorites != null)
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
                    await GetTestStatusTypes();
                    await GetTestCategoryTypes();

                    LaboratoryService.SelectedMyFavorites = new List<MyFavoritesGetListViewModel>();
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
        protected async Task LoadMyFavoritesData(LoadDataArgs args)
        {
            try
            {
                if (_userPermissions.Read)
                {
                    var pageSize = 100;
                    string sortColumn,
                        sortOrder;

                    if (MyFavoritesGrid.PageSize != 0)
                        pageSize = MyFavoritesGrid.PageSize;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = DefaultSortColumn;
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.FirstOrDefault()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    if (LaboratoryService.SearchMyFavorites is null && LaboratoryService.MyFavorites is null)
                        IsLoading = true;

                    if (IsLoading && IsSearchPerformed == false && IsReload == false)
                    {
                        if (!IsNullOrEmpty(SimpleSearchString))
                        {
                            var request = new MyFavoritesGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                AccessionedIndicator =
                                    SimpleSearchString == Localizer.GetString(FieldLabelResourceKeyConstants
                                        .LaboratoryAdvancedSearchModalUnaccessionedFieldLabel)
                                        ? false
                                        : null,
                                SearchString = SimpleSearchString,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchMyFavorites =
                                await LaboratoryClient.GetMyFavoritesSimpleSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                _databaseQueryCount =
                                    (LaboratoryService.SearchMyFavorites ?? new List<MyFavoritesGetListViewModel>()).Any(x =>
                                        x.SampleID > 0)
                                        ? (LaboratoryService.SearchMyFavorites ?? new List<MyFavoritesGetListViewModel>())
                                        .First(x => x.SampleID > 0)
                                        .TotalRowCount
                                        : _databaseQueryCount;

                                if (LaboratoryService.SearchMyFavorites.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchMyFavorites[0].TotalRowCount);

                                ApplyPendingSaveRecordsToSearchList();

                                MyFavorites = LaboratoryService.SearchMyFavorites.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else if (IsAdvancedSearch)
                        {
                            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                                .LaboratoryMyFavoritesAdvancedSearchPerformedIndicatorKey);

                            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                            if (searchPerformedIndicator)
                            {
                                var searchModelResult = await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                                    SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchModelKey);

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

                            LaboratoryService.SearchMyFavorites =
                                await LaboratoryClient.GetMyFavoritesAdvancedSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchMyFavorites.Any() &&
                                    LaboratoryService.SearchMyFavorites.First().RowAction ==
                                    (int) RowActionTypeEnum.NarrowSearchCriteria)
                                {
                                    await ShowNarrowSearchCriteriaDialog();
                                }

                                _databaseQueryCount =
                                    (LaboratoryService.SearchMyFavorites ?? new List<MyFavoritesGetListViewModel>())
                                    .Any(x =>
                                        x.SampleID > 0)
                                        ? (LaboratoryService.SearchMyFavorites ??
                                           new List<MyFavoritesGetListViewModel>())
                                        .First(x => x.SampleID > 0)
                                        .TotalRowCount
                                        : _databaseQueryCount;

                                if (LaboratoryService.SearchMyFavorites.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchMyFavorites[0]
                                        .TotalRowCount);

                                ApplyPendingSaveRecordsToSearchList();

                                MyFavorites = LaboratoryService.SearchMyFavorites.Skip((page - 1) * pageSize)
                                    .Take(pageSize)
                                    .ToList();
                            }
                        }
                        else
                        {
                            var request = new MyFavoritesGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.MyFavorites = await LaboratoryClient.GetMyFavoritesList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                ApplyPendingSaveRecordsToDefaultList();

                                MyFavorites = LaboratoryService.MyFavorites.Take(pageSize).ToList();

                                _databaseQueryCount =
                                    (LaboratoryService.MyFavorites ?? new List<MyFavoritesGetListViewModel>()).Any(x =>
                                        x.SampleID > 0)
                                        ? (LaboratoryService.MyFavorites ?? new List<MyFavoritesGetListViewModel>())
                                        .First(x => x.SampleID > 0)
                                        .TotalRowCount
                                        : _databaseQueryCount;
                            }
                        }
                    }
                    else
                    {
                        if (LaboratoryService.SearchMyFavorites == null)
                        {
                            if (LaboratoryService.MyFavorites != null)
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                MyFavorites = LaboratoryService.MyFavorites.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();

                                _databaseQueryCount =
                                    (LaboratoryService.MyFavorites ?? new List<MyFavoritesGetListViewModel>()).Any(x =>
                                        x.SampleID > 0)
                                        ? (LaboratoryService.MyFavorites ?? new List<MyFavoritesGetListViewModel>())
                                        .First(x => x.SampleID > 0)
                                        .TotalRowCount
                                        : _databaseQueryCount;
                            }
                        }
                        else
                        {
                            ApplySearchListSort(sortColumn, sortOrder);

                            ApplyPendingSaveRecordsToSearchList();

                            MyFavorites = LaboratoryService.SearchMyFavorites.Skip((page - 1) * pageSize).Take(pageSize).ToList();
                            _databaseQueryCount =
                                (LaboratoryService.SearchMyFavorites ?? new List<MyFavoritesGetListViewModel>()).Any(x =>
                                    x.SampleID > 0)
                                    ? (LaboratoryService.SearchMyFavorites ?? new List<MyFavoritesGetListViewModel>())
                                    .First(x => x.SampleID > 0)
                                    .TotalRowCount
                                    : _databaseQueryCount;
                        }
                    }

                    Count = _databaseQueryCount + LaboratoryService.NewSamplesFromMyFavoritesRegisteredCount;

                    foreach (var t in MyFavorites)
                    {
                        t.AdministratorRoleIndicator =
                            authenticatedUser.IsInRole(RoleEnum.Administrator);
                        t.HumanLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Human);
                        t.VeterinaryLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Vet);
                        t.CanPerformSampleAccessionIn =
                            GetUserPermissions(PagePermission.CanPerformSampleAccessionIn).Execute;
                        t.AllowDatesInThePast = ConfigurationService.SystemPreferences.AllowPastDates;
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
                LaboratoryService.MyFavorites = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.MyFavorites.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.MyFavorites.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.MyFavorites.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.MyFavorites.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.MyFavorites.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.MyFavorites.OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.MyFavorites.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.MyFavorites.OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.MyFavorites.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.MyFavorites.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.MyFavorites.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.MyFavorites.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.MyFavorites.OrderBy(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.MyFavorites.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.MyFavorites
                };
            }
            else
            {
                LaboratoryService.MyFavorites = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.MyFavorites.OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.MyFavorites.OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.MyFavorites.OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.MyFavorites.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.MyFavorites.OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.MyFavorites.OrderByDescending(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.MyFavorites.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.MyFavorites
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
                LaboratoryService.SearchMyFavorites = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchMyFavorites.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchMyFavorites
                };
            }
            else
            {
                LaboratoryService.SearchMyFavorites = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.FunctionalAreaName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchMyFavorites
                };
            }
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToDefaultList()
        {
            if (LaboratoryService.PendingSaveMyFavorites == null || !LaboratoryService.PendingSaveMyFavorites.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveMyFavorites)
            {
                if (LaboratoryService.MyFavorites != null && !LaboratoryService.MyFavorites.Any(x => (x.SampleID == t.SampleID && x.TestID is null) || (x.TestID is not null && x.TestID == t.TestID)))
                    LaboratoryService.MyFavorites?.Add(t);
                else
                {
                    if (LaboratoryService.MyFavorites == null) continue;
                    var recordIndex = LaboratoryService.MyFavorites.ToList().FindIndex(x => (x.SampleID == t.SampleID && x.TestID is null) || (x.TestID is not null && x.TestID == t.TestID));
                    if (recordIndex >= 0)
                        LaboratoryService.MyFavorites[recordIndex] = t;
                }
            }

            if (LaboratoryService.MyFavorites != null)
                LaboratoryService.MyFavorites =
                    LaboratoryService.MyFavorites.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToSearchList()
        {
            if (LaboratoryService.PendingSaveMyFavorites == null || !LaboratoryService.PendingSaveMyFavorites.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveMyFavorites)
            {
                if (LaboratoryService.SearchMyFavorites != null && !LaboratoryService.SearchMyFavorites.Any(x =>
                        (x.SampleID == t.SampleID && x.TestID is null) || (x.TestID is not null && x.TestID == t.TestID)))
                {
                    if (SimpleSearchString is not null)
                    {
                        if (t.AccessionConditionOrSampleStatusTypeName.Contains(SimpleSearchString) || 
                            t.DisplayDiseaseName.Contains(SimpleSearchString) || 
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
                            LaboratoryService.SearchMyFavorites?.Add(t);
                    }
                    else
                        LaboratoryService.SearchMyFavorites?.Add(t);
                }
                else
                {
                    if (LaboratoryService.SearchMyFavorites == null) continue;
                    var recordIndex = LaboratoryService.SearchMyFavorites.ToList().FindIndex(x => (x.SampleID == t.SampleID && x.TestID is null) || (x.TestID is not null && x.TestID == t.TestID));
                    if (recordIndex >= 0)
                        LaboratoryService.SearchMyFavorites[recordIndex] = t;
                }
            }

            if (LaboratoryService.SearchMyFavorites != null)
                LaboratoryService.SearchMyFavorites =
                    LaboratoryService.SearchMyFavorites.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task SortPendingSave()
        {
            await MyFavoritesGrid.Reload();
            await MyFavoritesGrid.FirstPage();
            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)
                }
            };
            var dialogOptions = new DialogOptions
            {
                ShowTitle = false,
                ShowClose = false
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams, dialogOptions);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.OKButton))
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
        protected void OnRowRender(RowRenderEventArgs<MyFavoritesGetListViewModel> record)
        {
            try
            {
                var cssClass = record.Data.AccessionIndicator == 0 && record.Data.AccessionConditionTypeID is null
                    ? LaboratoryModuleCSSClassConstants.Unaccessioned
                    : LaboratoryModuleCSSClassConstants.NoSavePending;

                if (record.Data.ActionPerformedIndicator)
                    cssClass = record.Data.RowAction switch
                    {
                        (int) RowActionTypeEnum.Accession => LaboratoryModuleCSSClassConstants.UnaccessionedSavePending,
                        (int) RowActionTypeEnum.InsertAccession => LaboratoryModuleCSSClassConstants.SavePending,
                        (int) RowActionTypeEnum.Insert => LaboratoryModuleCSSClassConstants.SavePending,
                        (int) RowActionTypeEnum.Update => record.Data.AccessionIndicator == 0
                            ? LaboratoryModuleCSSClassConstants.UnaccessionedSavePending
                            : LaboratoryModuleCSSClassConstants.SavePending,
                        _ => record.Data.AccessionIndicator == 0
                            ? LaboratoryModuleCSSClassConstants.Unaccessioned
                            : LaboratoryModuleCSSClassConstants.NoSavePending
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
        protected void OnCellRender(DataGridCellRenderEventArgs<MyFavoritesGetListViewModel> record)
        {
            try
            {
                var style = Empty;

                if (record.Data.AccessionIndicator == 0 && record.Data.AccessionConditionTypeID is null)
                    style += LaboratoryModuleCSSClassConstants.UnaccessionedCell;
                else
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
                if (MyFavorites is null)
                    return false;

                if (LaboratoryService.SelectedMyFavorites is {Count: > 0})
                    foreach (var item in MyFavorites)
                        if (item.TestID is null)
                        {
                            if (LaboratoryService.SelectedMyFavorites.Any(x => x.SampleID == item.SampleID))
                                return true;
                        }
                        else
                        {
                            if (LaboratoryService.SelectedMyFavorites.Any(x => x.TestID == item.TestID))
                                return true;
                        }
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
                LaboratoryService.SelectedMyFavorites ??= new List<MyFavoritesGetListViewModel>();

                if (value == false)
                    foreach (var item in MyFavorites)
                        if (item.TestID is null)
                        {
                            if (LaboratoryService.SelectedMyFavorites.All(x => x.SampleID != item.SampleID)) continue;
                            {
                                var selected =
                                    LaboratoryService.SelectedMyFavorites.First(x => x.SampleID == item.SampleID);

                                LaboratoryService.SelectedMyFavorites.Remove(selected);
                            }
                        }
                        else
                        {
                            if (LaboratoryService.SelectedMyFavorites.All(x => x.TestID != item.TestID)) continue;
                            {
                                var selected =
                                    LaboratoryService.SelectedMyFavorites.First(x => x.TestID == item.TestID);

                                LaboratoryService.SelectedMyFavorites.Remove(selected);
                            }
                        }
                else
                    foreach (var item in MyFavorites)
                        LaboratoryService.SelectedMyFavorites.Add(item);
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
        protected bool IsRecordSelected(MyFavoritesGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedMyFavorites != null)
                {
                    if (item.TestID is null)
                    {
                        if (LaboratoryService.SelectedMyFavorites.Any(x => x.SampleID == item.SampleID))
                            return true;
                    }
                    else
                    {
                        if (LaboratoryService.SelectedMyFavorites.Any(x => x.TestID == item.TestID))
                            return true;
                    }
                }
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
        protected void RecordSelectionChange(bool? value, MyFavoritesGetListViewModel item)
        {
            try
            {
                LaboratoryService.SelectedMyFavorites ??= new List<MyFavoritesGetListViewModel>();

                if (value == false)
                {
                    item = item.TestID is null
                        ? LaboratoryService.SelectedMyFavorites.First(x => x.SampleID == item.SampleID)
                        : LaboratoryService.SelectedMyFavorites.First(x => x.TestID == item.TestID);

                    LaboratoryService.SelectedMyFavorites.Remove(item);
                }
                else
                {
                    LaboratoryService.SelectedMyFavorites.Add(item);
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
        public async Task OnRefreshMyFavorites()
        {
            IsReload = true;

            LaboratoryService.SelectedMyFavorites ??= new List<MyFavoritesGetListViewModel>();

            LaboratoryService.SelectedMyFavorites.Clear();

            await MyFavoritesGrid.FirstPage(true);

            await JsRuntime.InvokeVoidAsync(ScrollToTopJs, _token);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReloadMyFavorites()
        {
            try
            {
                IsLoading = true;

                await SaveEvent.InvokeAsync();

                if (!IsNullOrEmpty(LaboratoryService.PrintBarcodeSamples))
                    await GenerateBarcodeReport(LaboratoryService.PrintBarcodeSamples);

                LaboratoryService.PrintBarcodeSamples = null;

                await MyFavoritesGrid.Reload();
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
        protected async Task OnTestStatusDropDownChange(MyFavoritesGetListViewModel item)
        {
            try
            {
                IsReload = true;

                TestingGetListViewModel test = null;
                TransferredGetListViewModel transfer = null;

                if (item.TransferID is not null) transfer = await GetTransfer(item.SampleID, null);

                if (item.TestID is not null) test = await GetTest((long) item.TestID);

                if (item.TestStatusTypeID is not null)
                    switch (item.TestStatusTypeID)
                    {
                        case (long) TestStatusTypeEnum.InProgress:
                            item.ResultDate = null;
                            item.TestResultTypeID = null;
                            break;
                        case (long) TestStatusTypeEnum.Preliminary:
                            item.ResultDate ??= DateTime.Now;
                            item.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                            item.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                             (IsNullOrEmpty(authenticatedUser.FirstName)
                                                                 ? ""
                                                                 : ", " + authenticatedUser.FirstName);
                            item.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).IdfsBaseReference;
                            break;
                        case (long)TestStatusTypeEnum.Final:
                            item.ResultDate ??= DateTime.Now;
                            item.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                            item.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                             (IsNullOrEmpty(authenticatedUser.FirstName)
                                                                 ? ""
                                                                 : ", " + authenticatedUser.FirstName);
                            item.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                                x.IdfsBaseReference == (long)TestStatusTypeEnum.Final).IdfsBaseReference;
                            item.TestResultTypeRequiredVisibleIndicator = true;
                            break;
                    }

                if (test is not null)
                {
                    if (item.TestStatusTypeID != null)
                    {
                        test.ActionPerformedIndicator = true;
                        test.TestStatusTypeID = (long) item.TestStatusTypeID;
                        test.TestStatusTypeName = item.TestStatusTypeName;

                        switch (item.TestStatusTypeID)
                        {
                            case (long) TestStatusTypeEnum.Final:
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
                                break;
                            case (long) TestStatusTypeEnum.InProgress:
                                test.ResultDate = null;
                                test.ResultEnteredByOrganizationID = null;
                                test.ResultEnteredByPersonID = null;
                                test.ResultEnteredByPersonName = null;
                                test.TestResultTypeID = null;
                                break;
                            case (long) TestStatusTypeEnum.Preliminary:
                                test.ResultDate = item.ResultDate ?? DateTime.Now;
                                test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                                test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                                 (IsNullOrEmpty(authenticatedUser.FirstName)
                                                                     ? ""
                                                                     : ", " + authenticatedUser.FirstName);
                                break;
                        }
                    }

                    TogglePendingSaveTesting(test);
                }

                if (transfer is not null)
                {
                    if (item.TestStatusTypeID != null)
                    {
                        transfer.TestStatusTypeID = (long) item.TestStatusTypeID;
                        transfer.TestStatusTypeName = item.TestStatusTypeName;

                        switch (item.TestStatusTypeID)
                        {
                            case (long) TestStatusTypeEnum.InProgress:
                                transfer.ResultDate = null;
                                transfer.TestResultTypeID = null;
                                break;
                            case (long) TestStatusTypeEnum.Preliminary:
                                transfer.ResultDate = item.ResultDate ?? DateTime.Now;
                                break;
                        }
                    }

                    transfer.ActionPerformedIndicator = true;
                    TogglePendingSaveTransferred(transfer);
                }

                item.ActionPerformedIndicator = true;
                TogglePendingSaveMyFavorites(item);

                await SaveEvent.InvokeAsync();

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
        protected async Task OnTestCategoryDropDownChange(MyFavoritesGetListViewModel item)
        {
            try
            {
                IsReload = true;

                TestingGetListViewModel test = null;

                if (item.TestID is not null) test = await GetTest((long) item.TestID);

                item.TestCategoryTypeName = LaboratoryService.TestCategoryTypes.First(x =>
                    x.IdfsBaseReference == item.TestCategoryTypeID).Name;
                if (test != null)
                {
                    test.TestCategoryTypeID = item.TestCategoryTypeID;

                    test.ActionPerformedIndicator = true;

                    TogglePendingSaveTesting(test);
                }

                if (item.TransferID is not null)
                {
                    var transfer = await GetTransfer(item.SampleID, null);

                    if (transfer != null)
                    {
                        transfer.TestCategoryTypeID = item.TestCategoryTypeID;

                        transfer.ActionPerformedIndicator = true;

                        TogglePendingSaveTransferred(transfer);
                    }
                }

                item.ActionPerformedIndicator = true;
                TogglePendingSaveMyFavorites(item);

                await SaveEvent.InvokeAsync();

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
        protected async Task OnTestResultDropDownChange(MyFavoritesGetListViewModel item)
        {
            try
            {
                IsReload = true;

                TestingGetListViewModel test = null;
                TransferredGetListViewModel transfer = null;

                if (item.TransferID is not null)
                    transfer = await GetTransfer(item.SampleID, null);

                if (item.TestID is not null) test = await GetTest((long) item.TestID);

                if (item.TestResultTypeID is null)
                {
                    if (test is not null)
                    {
                        test.ResultDate = null;
                        test.ResultEnteredByOrganizationID = null;
                        test.ResultEnteredByPersonID = null;
                        test.ResultEnteredByPersonName = null;
                        test.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                        test.TestResultTypeID = null;
                    }

                    if (transfer is not null)
                    {
                        transfer.ResultDate = null;
                        transfer.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                        transfer.TestResultTypeID = null;
                        transfer.ActionPerformedIndicator = true;

                        TogglePendingSaveTransferred(transfer);
                    }

                    item.ResultDate = null;
                    item.ResultEnteredByPersonID = null;
                    item.ResultEnteredByPersonName = null;
                    item.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                        x.IdfsBaseReference == (long) TestStatusTypeEnum.InProgress).IdfsBaseReference;
                    item.TestResultTypeID = null;
                }
                else
                {
                    if (test is not null)
                    {
                        test.ResultDate = item.ResultDate ?? DateTime.Now;
                        test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                        test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);

                        if (item.TransferID is not null)
                            test.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                        else if (test.TestStatusTypeID != (long) TestStatusTypeEnum.Final)
                            test.TestStatusTypeID = (long) TestStatusTypeEnum.Preliminary;
                        item.TestStatusTypeID = test.TestStatusTypeID;

                        test.TestResultTypeID = item.TestResultTypeID;

                        item.ResultDate = test.ResultDate;
                        item.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        item.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                    }

                    if (transfer is not null)
                    {
                        transfer.ResultDate = item.ResultDate ?? DateTime.Now;
                        transfer.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                        item.TestStatusTypeID = (long) TestStatusTypeEnum.Final;
                        transfer.TestResultTypeID = item.TestResultTypeID;
                    }

                    item.TestResultTypeID = item.TestResultTypeID;
                }

                if (test is not null)
                {
                    test.ActionPerformedIndicator = true;
                    TogglePendingSaveTesting(test);
                }

                if (transfer is not null)
                {
                    transfer.ActionPerformedIndicator = true;
                    TogglePendingSaveTransferred(transfer);
                }

                item.ActionPerformedIndicator = true;
                TogglePendingSaveMyFavorites(item);

                await SaveEvent.InvokeAsync();

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
        protected async Task OnResultDateChange(MyFavoritesGetListViewModel item)
        {
            try
            {
                IsReload = true;

                TestingGetListViewModel test = null;
                TransferredGetListViewModel transfer = null;

                if (item.TransferID is not null)
                    transfer = await GetTransfer(item.SampleID, null);

                if (item.TestID is not null) test = await GetTest((long) item.TestID);

                if (item.ResultDate is null)
                {
                    if (test is not null)
                    {
                        test.ResultDate = item.ResultDate;
                        test.ResultEnteredByOrganizationID = null;
                        test.ResultEnteredByPersonID = null;
                        test.ResultEnteredByPersonName = null;
                        test.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                        test.TestResultTypeID = null;
                        test.TestResultTypeRequiredVisibleIndicator = false;
                        test.ActionPerformedIndicator = true;
                        TogglePendingSaveTesting(test);

                        item.ResultEnteredByPersonID = null;
                        item.ResultEnteredByPersonName = null;
                    }

                    if (transfer is not null)
                    {
                        transfer.ResultDate = item.ResultDate;
                        transfer.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                        transfer.TestResultTypeID = null;
                        transfer.ActionPerformedIndicator = true;
                        TogglePendingSaveTransferred(transfer);
                    }
                }
                else
                {
                    if (test is not null)
                    {
                        test.ResultDate = item.ResultDate;
                        test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                        test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                        test.TestStatusTypeID = (long) TestStatusTypeEnum.Preliminary;
                        test.TestResultTypeID = item.TestResultTypeID;
                        test.TestResultTypeRequiredVisibleIndicator = true;
                        test.ActionPerformedIndicator = true;
                        TogglePendingSaveTesting(test);

                        item.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        item.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                    }

                    if (transfer is not null)
                    {
                        transfer.ResultDate = item.ResultDate;
                        transfer.TestStatusTypeID = (long) TestStatusTypeEnum.Preliminary;
                        transfer.TestResultTypeID = item.TestResultTypeID;
                        transfer.ActionPerformedIndicator = true;
                        TogglePendingSaveTransferred(transfer);
                    }
                }

                item.ActionPerformedIndicator = true;
                TogglePendingSaveMyFavorites(item);

                await OnRefreshMyFavorites();

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
        /// <param name="myFavorite"></param>
        /// <returns></returns>
        protected async Task OnAccessionConditionTypeSelectChange(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                await UpdateMyFavorite(myFavorite);

                await OnRefreshMyFavorites();

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
        /// <param name="myFavorite"></param>
        /// <returns></returns>
        protected async Task OnAccessionCommentClick(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                AccessionInViewModel model = new()
                {
                    AccessionConditionTypeID = myFavorite.AccessionConditionTypeID,
                    AccessionInComment = myFavorite.AccessionComment,
                    WritePermissionIndicator = myFavorite.WritePermissionIndicator,
                    SampleID = myFavorite.SampleID
                };

                var result = await DiagService.OpenAsync<AccessionInComment>(Empty,
                    new Dictionary<string, object>
                        {{"Tab", LaboratoryTabEnum.MyFavorites}, {"AccessionInAction", model}},
                    new DialogOptions
                    {
                        ShowTitle = false,
                        Style = LaboratoryModuleCSSClassConstants.AccessionCommentDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = false
                    });

                if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                    Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    await UpdateMyFavorite(myFavorite);
                    await OnRefreshMyFavorites();
                    await SortPendingSave();
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
        /// <param name="myFavorite"></param>
        protected async Task OnAccessionDateDatePickerChange(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                IsReload = true;

                await UpdateMyFavorite(myFavorite);
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
        /// <param name="myFavorite"></param>
        protected async Task OnSampleStatusTypeSelectChange(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                await UpdateMyFavorite(myFavorite);

                await OnRefreshMyFavorites();

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
        /// <param name="myFavorite"></param>
        /// <returns></returns>
        protected async Task OnFunctionalAreaSelectChange(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                await UpdateMyFavorite(myFavorite);

                await OnRefreshMyFavorites();

                await SortPendingSave();
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

            await MyFavoritesGrid.FirstPage(true);
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

            await MyFavoritesGrid.FirstPage(true);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearSearch()
        {
            try
            {
                IsLoading = true;
                IsAdvancedSearch = false;
                AdvancedSearchCriteria = new AdvancedSearchGetRequestModel();
                SimpleSearchString = null;
                LaboratoryService.SearchMyFavorites = null;
                _databaseQueryCount = 0;

                await MyFavoritesGrid.FirstPage(true);

                var myFavoritesCount = 0;
                if (LaboratoryService.MyFavorites is not null && LaboratoryService.MyFavorites.Any())
                    myFavoritesCount = LaboratoryService.MyFavorites.GroupBy(x => x.SampleID).Count();
                await ClearSearchEvent.InvokeAsync(myFavoritesCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit My Favorite Events

        /// <summary>
        /// </summary>
        /// <param name="myFavorite"></param>
        /// <returns></returns>
        protected async Task OnEditMyFavorite(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryDetails>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Tab", LaboratoryTabEnum.MyFavorites}, {"SampleID", myFavorite.SampleID},
                        {"TransferId", myFavorite.TransferID},
                        {"TestID", myFavorite.TestID}
                    },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryRecordDetailsDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true
                    });

                if (result is DialogReturnResult)
                    await OnRefreshMyFavorites();
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
        /// <param name="myFavorite"></param>
        /// <returns></returns>
        protected async Task OnSetMyFavorite(MyFavoritesGetListViewModel myFavorite)
        {
            try
            {
                await SetMyFavorite(myFavorite.SampleID, null, null);
                LaboratoryService.SelectedSamples?.Clear();
                if (myFavorite.SampleID > 0)
                    await SetMyFavoriteEvent.InvokeAsync();
                else
                    await SetMyFavoriteForNewRecordEvent.InvokeAsync();

                LaboratoryService.SelectedMyFavorites ??= new List<MyFavoritesGetListViewModel>();

                LaboratoryService.SelectedMyFavorites.Clear();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Register New Sample Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRegisterNewSample()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #region Create Aliqout/Derivative Event

        /// <summary>
        /// </summary>
        protected async Task OnCreateAliquotDerivative()
        {
            try
            {
                LaboratoryService.SelectedMyFavorites.Clear();

                await OnReloadMyFavorites();
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
                LaboratoryService.SelectedMyFavorites.Clear();

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Transfer Out Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnTransferOut()
        {
            try
            {
                LaboratoryService.SelectedMyFavorites = new List<MyFavoritesGetListViewModel>();
                await MyFavoritesGrid.Reload();
                await TransferOutEvent.InvokeAsync();
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
        protected async Task OnAmendTestResult()
        {
            try
            {
                LaboratoryService.SelectedMyFavorites.Clear();

                await SortPendingSave();
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
                LaboratoryService.SelectedMyFavorites.Clear();

                await OnReloadMyFavorites();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Destruction Events

        /// <summary>
        /// </summary>
        protected async Task OnDestroySampleByAutoclave()
        {
            try
            {
                await DestroySampleByAutoclave(LaboratoryTabEnum.MyFavorites);

                LaboratoryService.SelectedMyFavorites.Clear();

                await OnRefreshMyFavorites();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        protected async Task OnDestroySampleByIncineration()
        {
            try
            {
                await DestroySampleByIncineration(LaboratoryTabEnum.MyFavorites);

                LaboratoryService.SelectedMyFavorites.Clear();

                await OnRefreshMyFavorites();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Approve Sample Destruction Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnApproveSampleDestruction()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #region Approve Record Deletion Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnApproveRecordDeletion()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #region Sample Record Deletion Event

        /// <summary>
        /// </summary>
        protected async Task OnDeleteSampleRecordEvent()
        {
            LaboratoryService.SelectedMyFavorites.Clear();

            await OnRefreshMyFavorites();
        }

        #endregion

        #region Test Record Deletion Event

        /// <summary>
        /// </summary>
        protected async Task OnDeleteTestRecord()
        {
            try
            {
                await DeleteTestRecord(LaboratoryTabEnum.MyFavorites);

                LaboratoryService.SelectedMyFavorites.Clear();

                await OnRefreshMyFavorites();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Reject Record Deletion Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRejectRecordDeletion()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #region Reject Sample Destruction Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRejectSampleDestruction()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #region Restore Deleted Sample Record Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRestoreDeletedSampleRecord()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #region Validate Test Result Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnValidateTestResult()
        {
            await OnRefreshMyFavorites();
        }

        #endregion

        #endregion
    }
}
