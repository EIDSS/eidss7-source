#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class SamplesBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ILogger<SamplesBase> Logger { get; set; }
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
        [Parameter] public EventCallback<IList<LaboratorySelectionViewModel>> CreateAliquotDerivativeEvent { get; set; }
        [Parameter] public EventCallback<IList<LaboratorySelectionViewModel>> AssignTestEvent { get; set; }
        [Parameter] public EventCallback<IList<LaboratorySelectionViewModel>> TransferOutEvent { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<SamplesGetListViewModel> SamplesGrid { get; set; }
        public int Count { get; set; }
        public int UnaccessionedSampleCount { get; set; }
        public string SimpleSearchString { get; set; }
        public bool IsLoading { get; set; }
        private AdvancedSearchGetRequestModel AdvancedSearchCriteria { get; set; } = new();
        private bool IsAdvancedSearch { get; set; }
        private bool IsSearchPerformed { get; set; }
        protected IList<SamplesGetListViewModel> Samples { get; set; }
        public bool CanModifyAccessionDatePermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
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
        public SamplesBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected SamplesBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
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
            WritePermissionIndicator = _userPermissions.Write;

            if (_userPermissions.Read)
            {
                var result =
                    await BrowserStorage.GetAsync<string>(LaboratorySearchStorageConstants.SamplesSearchString);
                SimpleSearchString = result.Success ? result.Value : Empty;

                if (LaboratoryService.Samples == null)
                {
                    IsLoading = true;

                    if (SimpleSearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                        SimpleSearchString = Empty;
                }
                else if (LaboratoryService.TabChangeIndicator)
                {
                    LaboratoryService.TabChangeIndicator = false;

                    if (LaboratoryService.SearchSamples != null)
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
            try
            {
                if (firstRender)
                {
                    await GetAccessionConditionTypes();
                    await GetFunctionalAreas();
                    await GetSampleStatusTypes();

                    if (_userPermissions.Read)
                        LaboratoryService.SelectedSamples = new List<SamplesGetListViewModel>();
                    else
                        await InsufficientPermissions();
                }

                await base.OnAfterRenderAsync(firstRender);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
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
        ///     Free up managed and unmanaged resources.
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
        protected async Task LoadSamplesData(LoadDataArgs args)
        {
            try
            {
                if (_userPermissions.Read)
                {
                    var pageSize = 100;
                    string sortColumn,
                        sortOrder;

                    if (SamplesGrid.PageSize != 0)
                        pageSize = SamplesGrid.PageSize;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = DefaultSortColumn;
                        sortOrder = SortConstants.Ascending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First().Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First().SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    if (LaboratoryService.SearchSamples is null && LaboratoryService.Samples is null)
                        IsLoading = true;

                    if (IsLoading && IsSearchPerformed == false && IsReload == false)
                    {
                        if (!IsNullOrEmpty(SimpleSearchString))
                        {
                            var request = new SamplesGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                DaysFromAccessionDate = Convert.ToInt32(ConfigurationService.SystemPreferences
                                    .NumberDaysDisplayedByDefault),
                                AccessionedIndicator =
                                    SimpleSearchString == Localizer.GetString(FieldLabelResourceKeyConstants
                                        .LaboratoryAdvancedSearchModalUnaccessionedFieldLabel)
                                        ? false
                                        : null,
                                TestCompletedIndicator = LaboratoryService.TestCompletedIndicator,
                                TestUnassignedIndicator = LaboratoryService.TestUnassignedIndicator,
                                SearchString = SimpleSearchString,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchSamples =
                                await LaboratoryClient.GetSamplesSimpleSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                UnaccessionedSampleCount = !LaboratoryService.SearchSamples.Any()
                                    ? 0
                                    : LaboratoryService.SearchSamples.First().UnaccessionedSampleCount;

                                _databaseQueryCount = !LaboratoryService.SearchSamples.Any()
                                    ? 0
                                    : LaboratoryService.SearchSamples.First().TotalRowCount;

                                if (LaboratoryService.SearchSamples.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchSamples[0]
                                        .UnaccessionedSampleCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Samples = LaboratoryService.SearchSamples.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else if (IsAdvancedSearch)
                        {
                            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                                .LaboratorySamplesAdvancedSearchPerformedIndicatorKey);

                            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                            if (searchPerformedIndicator)
                            {
                                var searchModelResult = await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                                    SearchPersistenceKeys.LaboratorySamplesAdvancedSearchModelKey);

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
                                TestCompletedIndicator = LaboratoryService.TestCompletedIndicator,
                                TestUnassignedIndicator = LaboratoryService.TestUnassignedIndicator,
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchSamples =
                                await LaboratoryClient.GetSamplesAdvancedSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchSamples.Any() &&
                                    LaboratoryService.SearchSamples.First().RowAction ==
                                    (int) RowActionTypeEnum.NarrowSearchCriteria)
                                {
                                    await ShowNarrowSearchCriteriaDialog();
                                }

                                UnaccessionedSampleCount = !LaboratoryService.SearchSamples.Any()
                                    ? 0
                                    : LaboratoryService.SearchSamples.First().UnaccessionedSampleCount;

                                _databaseQueryCount = !LaboratoryService.SearchSamples.Any()
                                    ? 0
                                    : LaboratoryService.SearchSamples.First().TotalRowCount;

                                if (LaboratoryService.SearchSamples.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchSamples[0]
                                        .UnaccessionedSampleCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Samples = LaboratoryService.SearchSamples.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else
                        {
                            var request = new SamplesGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                DaysFromAccessionDate = Convert.ToInt32(ConfigurationService.SystemPreferences
                                    .NumberDaysDisplayedByDefault),
                                TestCompletedIndicator = LaboratoryService.TestCompletedIndicator,
                                TestUnassignedIndicator = LaboratoryService.TestUnassignedIndicator,
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.Samples = await LaboratoryClient.GetSamplesList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                UnaccessionedSampleCount = !LaboratoryService.Samples.Any()
                                    ? 0
                                    : LaboratoryService.Samples.First().UnaccessionedSampleCount;

                                _databaseQueryCount = !LaboratoryService.Samples.Any()
                                    ? 0
                                    : LaboratoryService.Samples.First().TotalRowCount;

                                ApplyPendingSaveRecordsToDefaultList();

                                Samples = LaboratoryService.Samples.Take(pageSize).ToList();
                            }
                        }
                    }
                    else
                    {
                        if (LaboratoryService.SearchSamples is null)
                        {
                            if (LaboratoryService.Samples != null)
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Samples = LaboratoryService.Samples.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                                _databaseQueryCount =
                                    (LaboratoryService.Samples ?? new List<SamplesGetListViewModel>()).Any(x =>
                                        x.SampleID > 0)
                                        ? (LaboratoryService.Samples ?? new List<SamplesGetListViewModel>())
                                        .First(x => x.SampleID > 0)
                                        .TotalRowCount
                                        : _databaseQueryCount;
                            }
                        }
                        else
                        {
                            ApplySearchListSort(sortColumn, sortOrder);

                            ApplyPendingSaveRecordsToSearchList();

                            Samples = LaboratoryService.SearchSamples.Skip((page - 1) * pageSize).Take(pageSize)
                                .ToList();
                            _databaseQueryCount =
                                (LaboratoryService.SearchSamples ?? new List<SamplesGetListViewModel>()).Any(x =>
                                    x.SampleID > 0)
                                    ? (LaboratoryService.SearchSamples ?? new List<SamplesGetListViewModel>())
                                    .First(x => x.SampleID > 0)
                                    .TotalRowCount
                                    : _databaseQueryCount;
                        }
                    }

                    Count = _databaseQueryCount + LaboratoryService.NewSamplesRegisteredCount;

                    foreach (var t in Samples)
                    {
                        t.AdministratorRoleIndicator = authenticatedUser.IsInRole(RoleEnum.Administrator);
                        t.HumanLaboratoryChiefIndicator = authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Human);
                        t.VeterinaryLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Vet);
                        t.CanPerformSampleAccessionIn =
                            GetUserPermissions(PagePermission.CanPerformSampleAccessionIn).Execute;
                        t.CanModifyStatusOfRejectedDeletedSample =
                            GetUserPermissions(PagePermission.CanModifyStatusOfRejectedSample).Execute;
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
                LaboratoryService.Samples = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Samples.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Samples.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Samples.OrderBy(x => x.DisplayDiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSLaboratorySampleID)
                        .ToList(),
                    "AccessionDate" => LaboratoryService.Samples.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Samples
                        .OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Samples.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Samples
                };
            else
                LaboratoryService.Samples = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Samples
                        .OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Samples
                        .OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Samples
                        .OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Samples.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Samples.OrderByDescending(x => x.DisplayDiseaseName)
                        .ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Samples
                        .OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.Samples.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Samples
                        .OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Samples.OrderByDescending(x => x.FunctionalAreaName)
                        .ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Samples.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Samples
                };
        }

        /// <summary>
        /// </summary>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        private void ApplySearchListSort(string sortColumn, string sortOrder)
        {
            if (sortColumn is null) return;
            if (sortOrder == SortConstants.Ascending)
                LaboratoryService.SearchSamples = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchSamples.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchSamples.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchSamples
                        .OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchSamples.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchSamples.OrderBy(x => x.DisplayDiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchSamples.OrderBy(x => x.EIDSSLaboratorySampleID)
                        .ToList(),
                    "AccessionDate" => LaboratoryService.SearchSamples.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchSamples
                        .OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchSamples.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchSamples.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchSamples
                };
            else
                LaboratoryService.SearchSamples = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchSamples
                        .OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchSamples
                        .OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchSamples
                        .OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchSamples.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchSamples.OrderByDescending(x => x.DisplayDiseaseName)
                        .ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchSamples
                        .OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchSamples.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchSamples
                        .OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchSamples.OrderByDescending(x => x.FunctionalAreaName)
                        .ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchSamples.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchSamples
                };
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToDefaultList()
        {
            if (LaboratoryService.PendingSaveSamples == null || !LaboratoryService.PendingSaveSamples.Any()) return;

            foreach (var t in LaboratoryService.PendingSaveSamples)
                if (LaboratoryService.Samples != null && LaboratoryService.Samples.All(x => x.SampleID != t.SampleID) &&
                    t.TestAssignedCount == 0)
                {
                    LaboratoryService.Samples?.Add(t);
                }
                else
                {
                    if (LaboratoryService.Samples == null) continue;
                    var recordIndex = LaboratoryService.Samples.ToList().FindIndex(x => x.SampleID == t.SampleID);
                    if (recordIndex >= 0)
                        LaboratoryService.Samples[recordIndex] = t;
                }

            if (LaboratoryService.Samples != null)
                LaboratoryService.Samples =
                    LaboratoryService.Samples.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToSearchList()
        {
            if (LaboratoryService.PendingSaveSamples == null || !LaboratoryService.PendingSaveSamples.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveSamples)
                if (LaboratoryService.SearchSamples != null &&
                    LaboratoryService.SearchSamples.All(x => x.SampleID != t.SampleID) && t.TestAssignedCount == 0)
                {
                    if (SimpleSearchString is not null)
                    {
                        if (t.AccessionConditionOrSampleStatusTypeName.Contains(SimpleSearchString) ||
                            t.DisplayDiseaseName.Contains(SimpleSearchString) ||
                            (t.EIDSSAnimalID is not null && t.EIDSSAnimalID.Contains(SimpleSearchString)) ||
                            (t.EIDSSLaboratorySampleID is not null &&
                             t.EIDSSLaboratorySampleID.Contains(SimpleSearchString)) ||
                            (t.EIDSSLocalOrFieldSampleID is not null &&
                             t.EIDSSLocalOrFieldSampleID.Contains(SimpleSearchString)) ||
                            (t.EIDSSReportOrSessionID is not null &&
                             t.EIDSSReportOrSessionID.Contains(SimpleSearchString)) ||
                            (t.FunctionalAreaName is not null && t.FunctionalAreaName.Contains(SimpleSearchString)) ||
                            (t.PatientOrFarmOwnerName is not null &&
                             t.PatientOrFarmOwnerName.Contains(SimpleSearchString)) ||
                            (t.AccessionDate is not null && t.AccessionDate.ToString().Contains(SimpleSearchString)) ||
                            t.SampleTypeName.Contains(SimpleSearchString))
                            LaboratoryService.SearchSamples?.Add(t);
                    }
                    else
                    {
                        LaboratoryService.SearchSamples?.Add(t);
                    }
                }
                else
                {
                    if (LaboratoryService.SearchSamples == null) continue;
                    var recordIndex = LaboratoryService.SearchSamples.ToList().FindIndex(x => x.SampleID == t.SampleID);
                    if (recordIndex >= 0)
                        LaboratoryService.SearchSamples[recordIndex] = t;
                }

            if (LaboratoryService.SearchSamples != null)
                LaboratoryService.SearchSamples =
                    LaboratoryService.SearchSamples.OrderByDescending(x => x.RowAction).ToList();
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
        protected void OnRowRender(RowRenderEventArgs<SamplesGetListViewModel> record)
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
        protected void OnCellRender(DataGridCellRenderEventArgs<SamplesGetListViewModel> record)
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
                if (Samples is null)
                    return false;

                if (LaboratoryService.SelectedSamples is {Count: > 0})
                    if (Samples.Any(item => LaboratoryService.SelectedSamples.Any(x => x.SampleID == item.SampleID)))
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
                LaboratoryService.SelectedSamples ??= new List<SamplesGetListViewModel>();

                if (value == false)
                    foreach (var item in Samples)
                    {
                        if (LaboratoryService.SelectedSamples.All(x => x.SampleID != item.SampleID)) continue;
                        {
                            var selected = LaboratoryService.SelectedSamples.First(x => x.SampleID == item.SampleID);

                            LaboratoryService.SelectedSamples.Remove(selected);
                        }
                    }
                else
                    foreach (var item in Samples)
                        LaboratoryService.SelectedSamples.Add(item);
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
        protected bool IsRecordSelected(SamplesGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedSamples is not null &&
                    LaboratoryService.SelectedSamples.Any(x => x.SampleID == item.SampleID))
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
        protected void RecordSelectionChange(bool? value, SamplesGetListViewModel item)
        {
            try
            {
                LaboratoryService.SelectedSamples ??= new List<SamplesGetListViewModel>();

                if (value == false)
                {
                    item = LaboratoryService.SelectedSamples.First(x => x.SampleID == item.SampleID);

                    LaboratoryService.SelectedSamples.Remove(item);
                }
                else
                {
                    LaboratoryService.SelectedSamples.Add(item);
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
        public async Task OnRefreshSamples()
        {
            IsReload = true;

            LaboratoryService.SelectedSamples ??= new List<SamplesGetListViewModel>();

            LaboratoryService.SelectedSamples.Clear();

            await InvokeAsync(() =>
            {
                SamplesGrid.FirstPage(true);
                JsRuntime.InvokeVoidAsync(ScrollToTopJs, _token);
            });
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReloadSamples()
        {
            IsLoading = true;

            await SaveEvent.InvokeAsync();

            if (!IsNullOrEmpty(LaboratoryService.PrintBarcodeSamples))
                await GenerateBarcodeReport(LaboratoryService.PrintBarcodeSamples);

            LaboratoryService.PrintBarcodeSamples = null;

            await SamplesGrid.Reload();
        }

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <returns></returns>
        protected async Task OnAccessionConditionTypeSelectChange(SamplesGetListViewModel sample)
        {
            try
            {
                await UpdateSample(sample);
                await OnRefreshSamples();
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
        /// <param name="sample"></param>
        /// <returns></returns>
        public async Task OnAccessionCommentClick(SamplesGetListViewModel sample)
        {
            try
            {
                IsReload = true;

                AccessionInViewModel model = new()
                {
                    AccessionConditionTypeID = sample.AccessionConditionTypeID,
                    AccessionInComment = sample.AccessionComment, SampleID = sample.SampleID, 
                    WritePermissionIndicator = sample.WritePermissionIndicator
                };

                var result = await DiagService.OpenAsync<AccessionInComment>(Empty,
                    new Dictionary<string, object> {{"Tab", LaboratoryTabEnum.Samples}, {"AccessionInAction", model}},
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
                    await UpdateSample(sample);
                    LaboratoryService.SelectedSamples = new List<SamplesGetListViewModel>();
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
        /// <param name="sample"></param>
        protected async Task OnAccessionDateDatePickerChange(SamplesGetListViewModel sample)
        {
            try
            {
                IsReload = true;

                await UpdateSample(sample);
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
        /// <param name="sample"></param>
        protected async Task OnSampleStatusTypeSelectChange(SamplesGetListViewModel sample)
        {
            try
            {
                IsReload = true;

                await UpdateSample(sample);
                LaboratoryService.SelectedSamples = new List<SamplesGetListViewModel>();
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
        /// <param name="sample"></param>
        /// <returns></returns>
        protected async Task OnFunctionalAreaSelectChange(SamplesGetListViewModel sample)
        {
            try
            {
                IsReload = true;

                await UpdateSample(sample);
                LaboratoryService.SelectedSamples = new List<SamplesGetListViewModel>();
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
        private async Task SortPendingSave()
        {
            await SamplesGrid.Reload();
            await SamplesGrid.FirstPage(true);
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Search Events

        /// <summary>
        ///     LUC13 - Search for a Sample - Simple Search
        /// </summary>
        /// <param name="simpleSearchString"></param>
        /// <returns></returns>
        protected async Task OnSimpleSearch(string simpleSearchString)
        {
            IsLoading = true;
            IsAdvancedSearch = false;
            AdvancedSearchCriteria = new AdvancedSearchGetRequestModel();
            SimpleSearchString = simpleSearchString;

            await SamplesGrid.FirstPage(true);
        }

        /// <summary>
        ///     LUC13 - Search for a Sample - Test Unassigned Indicator Filter
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnTestUnassignedSearch(bool? value)
        {
            IsLoading = true;
            LaboratoryService.TestUnassignedIndicator = value;
            if (LaboratoryService.TestUnassignedIndicator == false)
                LaboratoryService.TestUnassignedIndicator = null;

            await SamplesGrid.FirstPage(true);

            await ClearSearchEvent.InvokeAsync(UnaccessionedSampleCount);
        }

        /// <summary>
        ///     LUC13 - Search for a Sample - Test Completed Indicator Filter
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnTestCompletedSearch(bool? value)
        {
            IsLoading = true;
            LaboratoryService.TestCompletedIndicator = value;
            if (LaboratoryService.TestCompletedIndicator == false)
                LaboratoryService.TestCompletedIndicator = null;

            await SamplesGrid.FirstPage(true);

            await ClearSearchEvent.InvokeAsync(UnaccessionedSampleCount);
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

            await SamplesGrid.FirstPage(true);
        }

        /// <summary>
        ///     LUC13 - Search for a Sample - Clear out search fields and reload data grid to the default.
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
                LaboratoryService.SearchSamples = null;
                _databaseQueryCount = 0;

                await SamplesGrid.FirstPage(true);

                if (LaboratoryService.Samples is not null && LaboratoryService.Samples.Any())
                    UnaccessionedSampleCount = LaboratoryService.Samples.First().UnaccessionedSampleCount;
                await ClearSearchEvent.InvokeAsync(UnaccessionedSampleCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Sample Events

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <returns></returns>
        protected async Task OnEditSample(SamplesGetListViewModel sample)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryDetails>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Tab", LaboratoryTabEnum.Samples}, {"SampleID", sample.SampleID}, { "Sample", sample },
                        {"DiseaseId", sample.DiseaseID}
                    },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryRecordDetailsDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true
                    }).ConfigureAwait(false);

                if (result is DialogReturnResult)
                {
                    await OnRefreshSamples();
                }
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
        /// <param name="sample"></param>
        /// <returns></returns>
        protected async Task OnSetMyFavorite(SamplesGetListViewModel sample)
        {
            try
            {
                await SetMyFavorite(sample.SampleID, null, null);
                LaboratoryService.SelectedSamples?.Clear();
                if (sample.SampleID > 0)
                    await SetMyFavoriteEvent.InvokeAsync();
                else
                    await SetMyFavoriteForNewRecordEvent.InvokeAsync();

                LaboratoryService.SelectedSamples ??= new List<SamplesGetListViewModel>();

                LaboratoryService.SelectedSamples.Clear();
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
            await OnRefreshSamples();
        }

        #endregion

        #region Create Aliqout/Derivative Event

        /// <summary>
        /// </summary>
        protected async Task OnCreateAliquotDerivative()
        {
            try
            {
                LaboratoryService.SelectedSamples.Clear();

                await OnReloadSamples();
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
                LaboratoryService.SelectedSamples.Clear();

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
                LaboratoryService.SelectedSamples = new List<SamplesGetListViewModel>();

                await SamplesGrid.FirstPage(true);

                await TransferOutEvent.InvokeAsync();
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
                await DestroySampleByAutoclave(LaboratoryTabEnum.Samples);

                LaboratoryService.SelectedSamples.Clear();

                await OnRefreshSamples();
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
                await DestroySampleByIncineration(LaboratoryTabEnum.Samples);

                LaboratoryService.SelectedSamples.Clear();

                await OnRefreshSamples();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Record Deletion Event

        /// <summary>
        /// </summary>
        protected async Task OnDeleteSampleRecord()
        {
            LaboratoryService.SelectedSamples.Clear();

            await OnRefreshSamples();
        }

        #endregion

        #region Restore Deleted Sample Record Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRestoreDeletedSampleRecord()
        {
            await OnRefreshSamples();
        }

        #endregion

        #endregion
    }
}
