#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
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
    public class ApprovalsBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ApprovalsBase> Logger { get; set; }
        [Inject] private ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback<int> SearchEvent { get; set; }

        [Parameter] public EventCallback<int> ClearSearchEvent { get; set; }

        [Parameter] public EventCallback SaveEvent { get; set; }

        [Parameter] public EventCallback SetMyFavoriteEvent { get; set; }

        [Parameter] public string SimpleSearchString { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<ApprovalsGetListViewModel> ApprovalsGrid { get; set; }
        public int Count { get; set; }
        private AdvancedSearchGetRequestModel AdvancedSearchCriteria { get; set; } = new();
        private bool IsAdvancedSearch { get; set; }
        private bool IsSearchPerformed { get; set; }
        public bool IsLoading { get; set; }
        protected IList<ApprovalsGetListViewModel> Approvals { get; set; }
        private bool IsReload { get; set; }
        protected SearchComponent Search { get; set; }

        #endregion

        #region Constants

        private const string ScrollToTopJs = "scrollToTop";

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        protected UserPermissions UserPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public ApprovalsBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected ApprovalsBase() : base(CancellationToken.None)
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
            UserPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

            if (UserPermissions.Read)
            {
                var result =
                    await BrowserStorage.GetAsync<string>(LaboratorySearchStorageConstants.ApprovalsSearchString);
                SimpleSearchString = result.Success ? result.Value : Empty;

                if (LaboratoryService.Approvals == null)
                {
                    IsLoading = true;

                    if (SimpleSearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                        SimpleSearchString = Empty;
                }
                else if (LaboratoryService.TabChangeIndicator)
                {
                    LaboratoryService.TabChangeIndicator = false;

                    if (LaboratoryService.SearchApprovals != null)
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
                    await GetTestStatusTypes();
                    await GetTestCategoryTypes();

                    if (UserPermissions.Read)
                        LaboratoryService.SelectedApprovals = new List<ApprovalsGetListViewModel>();
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
        public async Task LoadApprovalsData(LoadDataArgs args)
        {
            try
            {
                if (UserPermissions.Read)
                {
                    var pageSize = 100;
                    string sortColumn,
                        sortOrder;

                    if (ApprovalsGrid.PageSize != 0)
                        pageSize = ApprovalsGrid.PageSize;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "ActionRequested";
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.FirstOrDefault()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.FirstOrDefault()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    if (LaboratoryService.SearchApprovals is null && LaboratoryService.Approvals is null)
                        IsLoading = true;

                    if (IsLoading && IsSearchPerformed == false && IsReload == false)
                    {
                        if (!IsNullOrEmpty(SimpleSearchString))
                        {
                            var request = new ApprovalsGetRequestModel
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

                            LaboratoryService.SearchApprovals =
                                await LaboratoryClient.GetApprovalsSimpleSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchApprovals.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchApprovals[0].TotalRowCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Approvals = LaboratoryService.SearchApprovals.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else if (IsAdvancedSearch)
                        {
                            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                                .LaboratoryApprovalsAdvancedSearchPerformedIndicatorKey);

                            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                            if (searchPerformedIndicator)
                            {
                                var searchModelResult = await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                                    SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchModelKey);

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
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchApprovals =
                                await LaboratoryClient.GetApprovalsAdvancedSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchApprovals.Any() &&
                                    LaboratoryService.SearchApprovals.First().RowAction ==
                                    (int) RowActionTypeEnum.NarrowSearchCriteria)
                                {
                                    await ShowNarrowSearchCriteriaDialog();
                                }

                                if (LaboratoryService.SearchApprovals.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(
                                        LaboratoryService.SearchApprovals[0].TotalRowCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Approvals = LaboratoryService.SearchApprovals.Skip((page - 1) * pageSize)
                                    .Take(pageSize)
                                    .ToList();
                            }
                        }
                        else
                        {
                            var request = new ApprovalsGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                            };

                            if (LaboratoryService.Approvals is null || !LaboratoryService.Approvals.Any())
                            {
                                LaboratoryService.Approvals =
                                    await LaboratoryClient.GetApprovalsList(request, _token);
                                if (_source.IsCancellationRequested == false)
                                {
                                    ApplyPendingSaveRecordsToDefaultList();

                                    Approvals = LaboratoryService.Approvals.Take(pageSize).ToList();
                                }
                            }
                            else
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Approvals = LaboratoryService.Approvals.Skip((page - 1) * pageSize)
                                    .Take(pageSize).ToList();
                            }
                        }

                        Count = Approvals.Count == 0 ? 0 : Approvals.First().TotalRowCount;
                    }
                    else
                    {
                        if (LaboratoryService.SearchApprovals == null)
                        {
                            if (LaboratoryService.Approvals != null)
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Approvals = LaboratoryService.Approvals.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                                Count =
                                    (LaboratoryService.Approvals ?? new List<ApprovalsGetListViewModel>()).Any()
                                        ? (LaboratoryService.Approvals ?? new List<ApprovalsGetListViewModel>()).First()
                                        .TotalRowCount
                                        : Count;
                            }
                        }
                        else
                        {
                            ApplySearchListSort(sortColumn, sortOrder);

                            ApplyPendingSaveRecordsToSearchList();

                            Approvals = LaboratoryService.SearchApprovals.Skip((page - 1) * pageSize).Take(pageSize)
                                .ToList();
                            Count =
                                (LaboratoryService.SearchApprovals ?? new List<ApprovalsGetListViewModel>()).Any()
                                    ? (LaboratoryService.SearchApprovals ?? new List<ApprovalsGetListViewModel>())
                                    .First()
                                    .TotalRowCount
                                    : Count;
                        }
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
                LaboratoryService.Approvals = sortColumn switch
                {
                    "ActionRequested" => LaboratoryService.Approvals.OrderBy(x => x.ActionRequested)
                        .ToList(),
                    "EIDSSReportOrSessionID" => LaboratoryService.Approvals.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Approvals.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Approvals.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Approvals.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Approvals.OrderBy(x => x.EIDSSLaboratorySampleID)
                        .ToList(),
                    "AccessionDate" => LaboratoryService.Approvals.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Approvals
                        .OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "TestNameTypeName" => LaboratoryService.Approvals.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.Approvals.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.Approvals.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.Approvals.OrderBy(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Approvals.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Approvals
                };
            else
                LaboratoryService.Approvals = sortColumn switch
                {
                    "ActionRequested" => LaboratoryService.Approvals.OrderByDescending(x => x.ActionRequested)
                        .ToList(),
                    "EIDSSReportOrSessionID" => LaboratoryService.Approvals
                        .OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Approvals
                        .OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Approvals.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Approvals.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Approvals
                        .OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.Approvals.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Approvals
                        .OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "TestNameTypeName" => LaboratoryService.Approvals.OrderByDescending(x => x.TestNameTypeName)
                        .ToList(),
                    "TestStatusTypeName" => LaboratoryService.Approvals.OrderByDescending(x => x.TestStatusTypeName)
                        .ToList(),
                    "TestResultTypeName" => LaboratoryService.Approvals.OrderByDescending(x => x.TestResultTypeName)
                        .ToList(),
                    "ResultDate" => LaboratoryService.Approvals.OrderByDescending(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Approvals.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Approvals
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
                LaboratoryService.SearchApprovals = sortColumn switch
                {
                    "ActionRequested" => LaboratoryService.SearchApprovals.OrderBy(x => x.ActionRequested)
                        .ToList(),
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchApprovals.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchApprovals.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchApprovals.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchApprovals.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchApprovals
                        .OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchApprovals.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchApprovals
                        .OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchApprovals.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchApprovals.OrderBy(x => x.TestStatusTypeName)
                        .ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchApprovals.OrderBy(x => x.TestResultTypeName)
                        .ToList(),
                    "ResultDate" => LaboratoryService.SearchApprovals.OrderBy(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchApprovals.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchApprovals
                };
            else
                LaboratoryService.SearchApprovals = sortColumn switch
                {
                    "ActionRequested" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.ActionRequested)
                        .ToList(),
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchApprovals
                        .OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchApprovals
                        .OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.DiseaseName)
                        .ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchApprovals
                        .OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.AccessionDate)
                        .ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchApprovals
                        .OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.TestNameTypeName)
                        .ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchApprovals
                        .OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchApprovals
                        .OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.ResultDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchApprovals.OrderByDescending(x => x.EIDSSAnimalID)
                        .ToList(),
                    _ => LaboratoryService.SearchApprovals
                };
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToDefaultList()
        {
            if (LaboratoryService.PendingSaveApprovals == null || !LaboratoryService.PendingSaveApprovals.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveApprovals)
                if (LaboratoryService.Approvals != null && !LaboratoryService.Approvals.Any(x =>
                        (x.SampleID == t.SampleID && x.TestID is null) ||
                        (x.TestID is not null && x.TestID == t.TestID)))
                {
                    LaboratoryService.Approvals?.Add(t);
                }
                else
                {
                    if (LaboratoryService.Approvals == null) continue;
                    var recordIndex = LaboratoryService.Approvals.ToList().FindIndex(x =>
                        (x.SampleID == t.SampleID && x.TestID is null) ||
                        (x.TestID is not null && x.TestID == t.TestID));
                    if (recordIndex >= 0)
                        LaboratoryService.Approvals[recordIndex] = t;
                }

            if (LaboratoryService.Approvals != null)
                LaboratoryService.Approvals =
                    LaboratoryService.Approvals.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToSearchList()
        {
            if (LaboratoryService.PendingSaveApprovals == null || !LaboratoryService.PendingSaveApprovals.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveApprovals)
                if (LaboratoryService.SearchApprovals != null && !LaboratoryService.SearchApprovals.Any(x =>
                        (x.SampleID == t.SampleID && x.TestID is null) ||
                        (x.TestID is not null && x.TestID == t.TestID)))
                {
                    LaboratoryService.SearchApprovals?.Add(t);
                }
                else
                {
                    if (LaboratoryService.SearchApprovals == null) continue;
                    var recordIndex = LaboratoryService.SearchApprovals.ToList().FindIndex(x =>
                        (x.SampleID == t.SampleID && x.TestID is null) ||
                        (x.TestID is not null && x.TestID == t.TestID));
                    if (recordIndex >= 0)
                        LaboratoryService.SearchApprovals[recordIndex] = t;
                }

            if (LaboratoryService.SearchApprovals != null)
                LaboratoryService.SearchApprovals =
                    LaboratoryService.SearchApprovals.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task SortPendingSave()
        {
            await ApprovalsGrid.Reload();
            await ApprovalsGrid.FirstPage();
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
        protected void OnRowRender(RowRenderEventArgs<ApprovalsGetListViewModel> record)
        {
            try
            {
                var cssClass = record.Data.RowAction switch
                {
                    (int) RowActionTypeEnum.Update => LaboratoryModuleCSSClassConstants.SavePending,
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
        protected void OnCellRender(DataGridCellRenderEventArgs<ApprovalsGetListViewModel> record)
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
            if (Approvals is null)
                return false;

            if (LaboratoryService.SelectedApprovals is not {Count: > 0}) return false;
            foreach (var item in Approvals)
                if (item.TestID is null)
                {
                    if (LaboratoryService.SelectedApprovals.Any(x => x.SampleID == item.SampleID))
                        return true;
                }
                else
                {
                    if (LaboratoryService.SelectedApprovals.Any(x => x.TestID == item.TestID))
                        return true;
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
                LaboratoryService.SelectedApprovals ??= new List<ApprovalsGetListViewModel>();

                if (value == false)
                    foreach (var item in Approvals)
                        if (item.TestID is null)
                        {
                            if (LaboratoryService.SelectedApprovals.All(x => x.SampleID != item.SampleID)) continue;
                            {
                                var selected =
                                    LaboratoryService.SelectedApprovals.First(x => x.SampleID == item.SampleID);
                                LaboratoryService.SelectedApprovals.Remove(selected);
                            }
                        }
                        else
                        {
                            if (LaboratoryService.SelectedApprovals.All(x => x.TestID != item.TestID)) continue;
                            {
                                var selected = LaboratoryService.SelectedApprovals.First(x => x.TestID == item.TestID);
                                LaboratoryService.SelectedApprovals.Remove(selected);
                            }
                        }
                else
                    foreach (var item in Approvals)
                        LaboratoryService.SelectedApprovals.Add(item);
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
        protected bool IsRecordSelected(ApprovalsGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedApprovals != null)
                {
                    if (item.TestID is null)
                    {
                        if (LaboratoryService.SelectedApprovals.Any(x => x.SampleID == item.SampleID))
                            return true;
                    }
                    else
                    {
                        if (LaboratoryService.SelectedApprovals.Any(x => x.TestID == item.TestID))
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
        protected void RecordSelectionChange(bool? value, ApprovalsGetListViewModel item)
        {
            try
            {
                LaboratoryService.SelectedApprovals ??= new List<ApprovalsGetListViewModel>();

                if (value == false)
                {
                    item = item.TestID is null
                        ? LaboratoryService.SelectedApprovals.First(x => x.SampleID == item.SampleID)
                        : LaboratoryService.SelectedApprovals.First(x => x.TestID == item.TestID);

                    LaboratoryService.SelectedApprovals.Remove(item);
                }
                else
                {
                    LaboratoryService.SelectedApprovals.Add(item);
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
        protected async Task OnReloadApprovals()
        {
            try
            {
                IsLoading = true;

                await SaveEvent.InvokeAsync();

                await ApprovalsGrid.Reload();
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
        protected async Task OnRefreshApprovals()
        {
            IsReload = true;

            LaboratoryService.SelectedApprovals ??= new List<ApprovalsGetListViewModel>();

            LaboratoryService.SelectedApprovals.Clear();

            await ApprovalsGrid.FirstPage(true);

            await JsRuntime.InvokeVoidAsync(ScrollToTopJs, _token);
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

            await ApprovalsGrid.FirstPage(true);
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

            await ApprovalsGrid.FirstPage(true);
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
                LaboratoryService.SearchApprovals = null;

                await ApprovalsGrid.FirstPage(true);

                if (LaboratoryService.Approvals is not null && LaboratoryService.Approvals.Any())
                    Count = LaboratoryService.Approvals.First().TotalRowCount;
                await ClearSearchEvent.InvokeAsync(Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Approval Events

        /// <summary>
        /// </summary>
        /// <param name="approval"></param>
        /// <returns></returns>
        protected async Task OnEditApproval(ApprovalsGetListViewModel approval)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryDetails>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Tab", LaboratoryTabEnum.Approvals}, {"SampleID", approval.SampleID},
                        {"TestID", approval.TestID}
                    },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryRecordDetailsDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true
                    });

                if (result is DialogReturnResult)
                    await OnRefreshApprovals();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Restore Deleted Sample Record Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRestoreDeletedSampleRecord()
        {
            await ApprovalsGrid.Reload();

            await SortPendingSave();
        }

        #endregion

        #region Validate Test Result Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnValidateTestResult()
        {
            await ApprovalsGrid.Reload();

            await SortPendingSave();
        }

        #endregion

        #endregion
    }
}