#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
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
using static System.GC;
using static System.Int32;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class TransferredBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<TransferredBase> Logger { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback<int> SearchEvent { get; set; }
        [Parameter] public EventCallback<int> ClearSearchEvent { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public EventCallback SetMyFavoriteEvent { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<TransferredGetListViewModel> TransferredGrid { get; set; }
        public int Count { get; set; }
        private AdvancedSearchGetRequestModel AdvancedSearchCriteria { get; set; } = new();
        public string SimpleSearchString { get; set; }
        private bool IsAdvancedSearch { get; set; }
        private bool IsSearchPerformed { get; set; }
        public bool IsLoading { get; set; }
        protected IList<TransferredGetListViewModel> Transferred { get; set; }
        private bool IsReload { get; set; }
        protected SearchComponent Search { get; set; }
        public bool TransferredWritePermission { get; set; }

        #endregion

        #region Constants

        private const string DefaultSortColumn = "EIDSSTransferID";
        private const string ScrollToTopJs = "scrollToTop";

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public TransferredBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected TransferredBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                _logger = Logger;

                authenticatedUser = _tokenService.GetAuthenticatedUser();
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);
                TransferredWritePermission = _userPermissions.Write;

                if (_userPermissions.Read)
                {
                    //await GetTestResultTypes();

                    var result =
                        await BrowserStorage.GetAsync<string>(LaboratorySearchStorageConstants.TransferredSearchString);
                    SimpleSearchString = result.Success ? result.Value : Empty;

                    if (LaboratoryService.Transferred == null)
                    {
                        IsLoading = true;

                        if (SimpleSearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                            SimpleSearchString = Empty;
                    }
                    else if (LaboratoryService.TabChangeIndicator)
                    {
                        LaboratoryService.TabChangeIndicator = false;

                        if (LaboratoryService.SearchTransferred != null)
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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
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
                    await GetTestNameTypes();

                    if (_userPermissions.Read)
                        LaboratoryService.SelectedTransferred = new List<TransferredGetListViewModel>();
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
        protected async Task LoadTransferredData(LoadDataArgs args)
        {
            try
            {
                if (_userPermissions.Read)
                {
                    var pageSize = 100;
                    string sortColumn,
                        sortOrder;

                    if (TransferredGrid.PageSize != 0)
                        pageSize = TransferredGrid.PageSize;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = DefaultSortColumn;
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First().Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First().SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    if (LaboratoryService.SearchTransferred is null && LaboratoryService.Transferred is null)
                        IsLoading = true;

                    if (IsLoading && IsSearchPerformed == false && IsReload == false)
                    {
                        if (!IsNullOrEmpty(SimpleSearchString))
                        {
                            var request = new TransferredGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                AccessionedIndicator = SimpleSearchString == Localizer.GetString(FieldLabelResourceKeyConstants.LaboratoryAdvancedSearchModalUnaccessionedFieldLabel) ? false : null,
                                SearchString = SimpleSearchString,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchTransferred =
                                await LaboratoryClient.GetTransferredSimpleSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchTransferred.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(
                                        LaboratoryService.SearchTransferred[0].InProgressCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Transferred = LaboratoryService.SearchTransferred.Skip((page - 1) * pageSize)
                                    .Take(pageSize)
                                    .ToList();
                            }
                        }
                        else if (IsAdvancedSearch)
                        {
                            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                                .LaboratoryTransferredAdvancedSearchPerformedIndicatorKey);

                            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                            if (searchPerformedIndicator)
                            {
                                var searchModelResult = await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                                    SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchModelKey);

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
                                EIDSSReportSessionOrCampaignID =
                                    AdvancedSearchCriteria.EIDSSReportSessionOrCampaignID,
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
                                TestNameTypeName = AdvancedSearchCriteria.TestNameTypeName, 
                                TestResultDateFrom = AdvancedSearchCriteria.TestResultDateFrom,
                                TestResultDateTo = AdvancedSearchCriteria.TestResultDateTo,
                                TestResultTypeID = AdvancedSearchCriteria.TestResultTypeID,
                                TestStatusTypeID = AdvancedSearchCriteria.TestStatusTypeID,
                                TransferredToOrganizationID = AdvancedSearchCriteria.TransferredToOrganizationID,
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.SearchTransferred =
                                await LaboratoryClient.GetTransferredAdvancedSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchTransferred.Any() &&
                                    LaboratoryService.SearchTransferred.First().RowAction ==
                                    (int) RowActionTypeEnum.NarrowSearchCriteria)
                                {
                                    await ShowNarrowSearchCriteriaDialog();
                                }

                                if (LaboratoryService.SearchTransferred.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(
                                        LaboratoryService.SearchTransferred[0].InProgressCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Transferred = LaboratoryService.SearchTransferred.Skip((page - 1) * pageSize)
                                    .Take(pageSize)
                                    .ToList();
                            }
                        }
                        else
                        {
                            var request = new TransferredGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                    ? null
                                    : Convert.ToInt64(authenticatedUser.SiteGroupID)
                            };

                            LaboratoryService.Transferred =
                                await LaboratoryClient.GetTransferredList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                ApplyPendingSaveRecordsToDefaultList();

                                Transferred = LaboratoryService.Transferred.Take(pageSize).ToList();
                            }
                        }

                        Count = Transferred.Count == 0 ? 0 : Transferred.First().TotalRowCount;
                    }
                    else
                    {
                        if (LaboratoryService.SearchTransferred == null)
                        {
                            if (LaboratoryService.Transferred != null)
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Transferred = LaboratoryService.Transferred.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                                Count =
                                    (LaboratoryService.Transferred ?? new List<TransferredGetListViewModel>()).Any()
                                        ? (LaboratoryService.Transferred ?? new List<TransferredGetListViewModel>())
                                        .First()
                                        .TotalRowCount
                                        : Count;
                            }
                        }
                        else
                        {
                            ApplySearchListSort(sortColumn, sortOrder);

                            ApplyPendingSaveRecordsToSearchList();

                            Transferred = LaboratoryService.SearchTransferred.Skip((page - 1) * pageSize).Take(pageSize)
                                .ToList();
                            Count =
                                (LaboratoryService.SearchTransferred ?? new List<TransferredGetListViewModel>()).Any()
                                    ? (LaboratoryService.SearchTransferred ?? new List<TransferredGetListViewModel>())
                                    .First()
                                    .TotalRowCount
                                    : Count;
                        }
                    }

                    foreach (var t in Transferred)
                    {
                        t.AdministratorRoleIndicator =
                            authenticatedUser.IsInRole(RoleEnum.Administrator);
                        t.HumanLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Human);
                        t.VeterinaryLaboratoryChiefIndicator =
                            authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Vet);
                        t.AllowDatesInThePast = ConfigurationService.SystemPreferences.AllowPastDates;
                        if (t.TransferredFromOrganizationID == authenticatedUser.OfficeId || 
                            t.TransferredToOrganizationID == authenticatedUser.OfficeId)
                            t.WritePermissionIndicator = _userPermissions.Write;

                        if (t.DiseaseID is not null && t.DiseaseID.Contains(","))
                        {
                            var diseaseIDsSplit = t.DiseaseID.Split(",");
                            var diseaseNamesSplit = t.DiseaseName.Split("|");

                            t.Diseases = new List<FilteredDiseaseGetListViewModel>();
                            for (var index2 = 0; index2 < diseaseIDsSplit.Length; index2++)
                                t.Diseases?.Add(new FilteredDiseaseGetListViewModel
                                {
                                    DiseaseID = Convert.ToInt64(diseaseIDsSplit[index2]),
                                    DiseaseName = diseaseNamesSplit[index2]
                                });
                        }
                        else
                        {
                            t.Diseases = new List<FilteredDiseaseGetListViewModel>();
                            t.Diseases?.Add(new FilteredDiseaseGetListViewModel
                            {
                                DiseaseID = Convert.ToInt64(t.DiseaseID),
                                DiseaseName = t.DiseaseName
                            });
                            t.TestDiseaseID = Convert.ToInt64(t.DiseaseID);
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
            {
                LaboratoryService.Transferred = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Transferred.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Transferred.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Transferred.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Transferred.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Transferred.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Transferred.OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "EIDSSTransferID" => LaboratoryService.Transferred.OrderBy(x => x.EIDSSTransferID).ToList(),
                    "AccessionDate" => LaboratoryService.Transferred.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Transferred.OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Transferred.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "TestRequested" => LaboratoryService.Transferred.OrderBy(x => x.TestRequested).ToList(),
                    "TransferredToOrganizationName" => LaboratoryService.Transferred.OrderBy(x => x.TransferredToOrganizationName).ToList(),
                    "TestNameTypeName" => LaboratoryService.Transferred.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.Transferred.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.Transferred.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.Transferred.OrderBy(x => x.ResultDate).ToList(),
                    "TransferDate" => LaboratoryService.Transferred.OrderBy(x => x.TransferDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Transferred.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Transferred
                };
            }
            else
            {
                LaboratoryService.Transferred = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Transferred.OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Transferred.OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Transferred.OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Transferred.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Transferred.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Transferred.OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "EIDSSTransferID" => LaboratoryService.Transferred.OrderByDescending(x => x.EIDSSTransferID).ToList(),
                    "AccessionDate" => LaboratoryService.Transferred.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Transferred.OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Transferred.OrderByDescending(x => x.FunctionalAreaName).ToList(),
                    "TestRequested" => LaboratoryService.Transferred.OrderByDescending(x => x.TestRequested).ToList(),
                    "TransferredToOrganizationName" => LaboratoryService.Transferred.OrderByDescending(x => x.TransferredToOrganizationName).ToList(),
                    "TestNameTypeName" => LaboratoryService.Transferred.OrderByDescending(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.Transferred.OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.Transferred.OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.Transferred.OrderByDescending(x => x.ResultDate).ToList(),
                    "TransferDate" => LaboratoryService.Transferred.OrderByDescending(x => x.TransferDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Transferred.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Transferred
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
                LaboratoryService.SearchTransferred = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchTransferred.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchTransferred.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchTransferred.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchTransferred.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchTransferred.OrderBy(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchTransferred.OrderBy(x => x.EIDSSLaboratorySampleID).ToList(),
                    "EIDSSTransferID" => LaboratoryService.SearchTransferred.OrderBy(x => x.EIDSSTransferID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchTransferred.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchTransferred.OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchTransferred.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "TestRequested" => LaboratoryService.SearchTransferred.OrderBy(x => x.TestRequested).ToList(),
                    "TransferredToOrganizationName" => LaboratoryService.SearchTransferred.OrderBy(x => x.TransferredToOrganizationName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchTransferred.OrderBy(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchTransferred.OrderBy(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchTransferred.OrderBy(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchTransferred.OrderBy(x => x.ResultDate).ToList(),
                    "TransferDate" => LaboratoryService.SearchTransferred.OrderBy(x => x.TransferDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchTransferred.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchTransferred
                };
            }
            else
            {
                LaboratoryService.SearchTransferred = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.DiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "EIDSSTransferID" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.EIDSSTransferID).ToList(),
                    "AccessionDate" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.FunctionalAreaName).ToList(),
                    "TestRequested" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.TestRequested).ToList(),
                    "TransferredToOrganizationName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.TransferredToOrganizationName).ToList(),
                    "TestNameTypeName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.TestNameTypeName).ToList(),
                    "TestStatusTypeName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.TestStatusTypeName).ToList(),
                    "TestResultTypeName" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.TestResultTypeName).ToList(),
                    "ResultDate" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.ResultDate).ToList(),
                    "TransferDate" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.TransferDate).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.SearchTransferred.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.SearchTransferred
                };
            }
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToDefaultList()
        {
            if (LaboratoryService.PendingSaveTransferred == null || !LaboratoryService.PendingSaveTransferred.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveTransferred)
            {
                if (LaboratoryService.Transferred != null && LaboratoryService.Transferred.All(x => x.TransferredOutSampleID != t.TransferredOutSampleID))
                    LaboratoryService.Transferred?.Add(t);
                else
                {
                    if (LaboratoryService.Transferred == null) continue;
                    var recordIndex = LaboratoryService.Transferred.ToList().FindIndex(x => x.TransferredOutSampleID == t.TransferredOutSampleID);
                    if (recordIndex >= 0)
                        LaboratoryService.Transferred[recordIndex] = t;
                }
            }

            if (LaboratoryService.Transferred != null)
                LaboratoryService.Transferred =
                    LaboratoryService.Transferred.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToSearchList()
        {
            if (LaboratoryService.PendingSaveTransferred == null || !LaboratoryService.PendingSaveTransferred.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveTransferred)
            {
                if (LaboratoryService.SearchTransferred != null && LaboratoryService.SearchTransferred.All(x => x.TransferredOutSampleID != t.TransferredOutSampleID))
                    LaboratoryService.SearchTransferred?.Add(t);
                else
                {
                    if (LaboratoryService.SearchTransferred == null) continue;
                    var recordIndex = LaboratoryService.SearchTransferred.ToList().FindIndex(x => x.TransferredOutSampleID == t.TransferredOutSampleID);
                    if (recordIndex >= 0)
                        LaboratoryService.SearchTransferred[recordIndex] = t;
                }
            }

            if (LaboratoryService.SearchTransferred != null)
                LaboratoryService.SearchTransferred =
                    LaboratoryService.SearchTransferred.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task SortPendingSave()
        {
            await TransferredGrid.Reload();
            await TransferredGrid.FirstPage();
            await InvokeAsync(StateHasChanged);
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
        protected void OnRowRender(RowRenderEventArgs<TransferredGetListViewModel> record)
        {
            try
            {
                var cssClass = Empty;

                if (record.Data.ActionPerformedIndicator)
                    cssClass = record.Data.RowAction switch
                    {
                        (int) RowActionTypeEnum.Insert => LaboratoryModuleCSSClassConstants.SavePending,
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
        protected void OnCellRender(DataGridCellRenderEventArgs<TransferredGetListViewModel> record)
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
                if (Transferred is null)
                    return false;

                if (LaboratoryService.SelectedTransferred is {Count: > 0})
                    if (Transferred.Any(item => LaboratoryService.SelectedTransferred.Any(x =>
                            x.TransferID == item.TransferID &&
                            x.TransferredOutSampleID == item.TransferredOutSampleID)))
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
                LaboratoryService.SelectedTransferred ??= new List<TransferredGetListViewModel>();

                if (value == false)
                {
                    foreach (var item in Transferred)
                    {
                        if (LaboratoryService.SelectedTransferred.All(x => x.TransferID != item.TransferID &&
                                                                           x.TransferredOutSampleID != item.TransferredOutSampleID)) continue;
                        {
                            var selected =
                                LaboratoryService.SelectedTransferred.First(x =>
                                    x.TransferID == item.TransferID &&
                                    x.TransferredOutSampleID == item.TransferredOutSampleID);

                            LaboratoryService.SelectedTransferred.Remove(selected);
                        }
                    }
                }
                else
                {
                    foreach (var item in Transferred)
                        LaboratoryService.SelectedTransferred.Add(item);
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
        protected bool IsRecordSelected(TransferredGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedTransferred != null && LaboratoryService.SelectedTransferred.Any(x =>
                        x.TransferID == item.TransferID && x.TransferredOutSampleID == item.TransferredOutSampleID))
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
        protected void RecordSelectionChange(bool? value, TransferredGetListViewModel item)
        {
            try
            {
                LaboratoryService.SelectedTransferred ??= new List<TransferredGetListViewModel>();

                if (value == false)
                {
                    if (LaboratoryService != null && !LaboratoryService.SelectedTransferred.Any(x =>
                            x.TransferID == item.TransferID &&
                            x.TransferredOutSampleID == item.TransferredOutSampleID)) return;
                    {
                        item = LaboratoryService.SelectedTransferred.First(x =>
                            x.TransferID == item.TransferID && x.TransferredOutSampleID == item.TransferredOutSampleID);

                        LaboratoryService.SelectedTransferred.Remove(item);
                    }
                }
                else
                {
                    LaboratoryService.SelectedTransferred.Add(item);
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
        protected async Task OnRefreshTransferred()
        {
            IsReload = true;

            LaboratoryService.SelectedTransferred ??= new List<TransferredGetListViewModel>();

            LaboratoryService.SelectedTransferred.Clear();

            await TransferredGrid.FirstPage(true);

            await JsRuntime.InvokeVoidAsync(ScrollToTopJs, _token);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReloadTransferred()
        {
            try
            {
                IsLoading = true;

                await SaveEvent.InvokeAsync();

                await TransferredGrid.Reload();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="transfer"></param>
        /// <returns></returns>
        protected async Task OnAccessionCommentClick(TransferredGetListViewModel transfer)
        {
            try
            {
                AccessionInViewModel model = new()
                {
                    AccessionConditionTypeID = transfer.AccessionConditionTypeID,
                    AccessionInComment = transfer.AccessionComment, 
                    WritePermissionIndicator = transfer.WritePermissionIndicator,
                    SampleID = transfer.TransferredOutSampleID
                };

                var result = await DiagService.OpenAsync<AccessionInComment>("",
                    new Dictionary<string, object>
                        {{"Tab", LaboratoryTabEnum.Transferred}, {"AccessionInAction", model}},
                    new DialogOptions
                    {
                        ShowTitle = false, Style = LaboratoryModuleCSSClassConstants.AccessionCommentDialog,
                        AutoFocusFirstElement = true, CloseDialogOnOverlayClick = true
                    });

                if (result == null)
                {
                    await OnRefreshTransferred();

                    LaboratoryService.SelectedTransferred = new List<TransferredGetListViewModel>();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnTestNameDropDownChange(TransferredGetListViewModel item)
        {
            if (item.TestNameTypeID is not null)
            {
                if (LaboratoryService.TestNameTypes is not null && LaboratoryService.TestNameTypes.Any(x => x.IdfsBaseReference == item.TestNameTypeID))
                    item.TestNameTypeName = LaboratoryService.TestNameTypes
                        .First(x => x.IdfsBaseReference == item.TestNameTypeID).Name;
            }
            else
                item.TestNameTypeName = null;

            var test = await BuildExternalTest(item);

            item.ActionPerformedIndicator = true;

            TogglePendingSaveTesting(test);

            TogglePendingSaveTransferred(item);

            await SortPendingSave();
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnTestResultDropDownChange(TransferredGetListViewModel item)
        {
            try
            {
                var test = await BuildExternalTest(item);

                if (item.TestResultTypeID is null)
                {
                    item.ResultDate = null;
                    
                    test.ActionPerformedIndicator = true;
                    test.ResultDate = null;
                    test.ResultEnteredByOrganizationID = null;
                    test.ResultEnteredByPersonID = null;
                    test.ResultEnteredByPersonName = null;
                    test.TestStatusTypeID = (long)TestStatusTypeEnum.InProgress;
                    test.TestResultTypeID = null;
                    test.ValidatedByOrganizationID = null;
                    test.ValidatedByPersonID = null;
                    test.ValidatedByPersonName = null;
                }
                else
                {
                    item.ResultDate = DateTime.Now;

                    test.ActionPerformedIndicator = true;
                    test.ResultDate = item.ResultDate ?? DateTime.Now;
                    test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                    test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    test.ResultEnteredByPersonName = authenticatedUser.LastName + (IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);
                    test.TestStatusTypeID = (long)TestStatusTypeEnum.Final;
                    test.TestResultTypeID = item.TestResultTypeID;
                    test.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                    test.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    test.ValidatedByPersonName = authenticatedUser.LastName + (IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);
                }

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
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).ResultDate =
                            test.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestResultTypeID = test.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestResultTypeName = test.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestStatusTypeID = test.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestStatusTypeName = test.TestStatusTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == test.SampleID));
                    }
                }

                item.ActionPerformedIndicator = true;

                TogglePendingSaveTesting(test);

                TogglePendingSaveTransferred(item);

                await SortPendingSave();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnResultDateTextChange(TransferredGetListViewModel item)
        {
            try
            {
                var test = await BuildExternalTest(item);

                if (item.ResultDate is null)
                {
                    item.TestResultTypeID = null;
                    item.TestResultTypeName = null;

                    test.ResultDate = null;
                    test.ResultEnteredByOrganizationID = null;
                    test.ResultEnteredByPersonID = null;
                    test.ResultEnteredByPersonName = null;
                    test.TestStatusTypeID = (long)TestStatusTypeEnum.InProgress;
                    test.TestResultTypeID = null;
                    test.ValidatedByOrganizationID = null;
                    test.ValidatedByPersonID = null;
                    test.ValidatedByPersonName = null;
                }

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
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).ResultDate =
                            test.ResultDate;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestResultTypeID = test.TestResultTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestResultTypeName = test.TestResultTypeName;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestStatusTypeID = test.TestStatusTypeID;
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID)
                            .TestStatusTypeName = test.TestStatusTypeName;

                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.FirstOrDefault(x => x.SampleID == test.SampleID));
                    }
                }

                item.ActionPerformedIndicator = true;

                TogglePendingSaveTesting(test);

                TogglePendingSaveTransferred(item);

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
        protected async Task OnTestDiseaseDropDownChange(TransferredGetListViewModel item)
        {
            if (item.TestDiseaseID is null)
            {
                if (LaboratoryService.PendingSaveTesting is not null && item.TestID is not null &&
                    LaboratoryService.PendingSaveTesting.Any(x => x.TestID == item.TestID))
                {
                    var index = LaboratoryService.PendingSaveTesting.ToList().FindIndex(x => x.TestID == item.TestID);
                    LaboratoryService.PendingSaveTesting.RemoveAt(index);

                    item.TestNameTypeID = null;
                    item.TestNameTypeName = null;
                    item.TestResultTypeID = null;
                    item.TestResultTypeName = null;
                    item.TestStatusTypeID = (long) TestStatusTypeEnum.NotStarted;
                    item.TestStatusTypeName = null;
                    item.ResultDate = null;
                    item.TestCategoryTypeID = null;
                    item.StartedDate = null;
                    item.ContactPersonName = null;
                }
            }
            else
            {
                var test = await BuildExternalTest(item);

                TogglePendingSaveTesting(test);
            }

            item.ActionPerformedIndicator = true;

            TogglePendingSaveTransferred(item);

            await SortPendingSave();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        private async Task<TestingGetListViewModel> BuildExternalTest(TransferredGetListViewModel item)
        {
            LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();
            LaboratoryService.MyFavorites ??= new List<MyFavoritesGetListViewModel>();

            TestingGetListViewModel test;
            if (LaboratoryService.PendingSaveTesting.Any(x => x.TestID == item.TestID))
                test = LaboratoryService.PendingSaveTesting.First(x => x.TestID == item.TestID);
            else
                test = new TestingGetListViewModel
                {
                    StartedDate = DateTime.Now,
                    ExternalTestIndicator = true,
                    RowAction = (int) RowActionTypeEnum.Insert,
                    RowStatus = (int) RowStatusTypeEnum.Active,
                    SampleID = item.TransferredOutSampleID,
                    DiseaseID = item.TestDiseaseID,
                    DiseaseName = item.Diseases.First(x => x.DiseaseID == item.TestDiseaseID).DiseaseName,
                    TestNameTypeID = item.TestNameTypeID,
                    TestCategoryTypeName = item.TestNameTypeName,
                    TestStatusTypeID = (long) TestStatusTypeEnum.InProgress,
                    TestID = item.TestID is null or <= 0
                        ? LaboratoryService.PendingSaveTesting.Count(x => x.RowAction == (int) RowActionTypeEnum.Insert) +
                          1 * -1
                        : (long) item.TestID
                };

            if (item.FavoriteIndicator)
            {
                var sample = await GetSample(item.TransferredOutSampleID);
                await GetMyFavorite(sample, test, item, null);
            }

            item.TestID = test.TestID;

            return test;
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

            await TransferredGrid.FirstPage(true);
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

            await TransferredGrid.FirstPage(true);
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
                LaboratoryService.SearchTransferred = null;
                
                await TransferredGrid.FirstPage(true);

                var inProgressCount = 0;
                if (LaboratoryService.Transferred is not null && LaboratoryService.Transferred.Any())
                    inProgressCount = LaboratoryService.Transferred.First().InProgressCount;

                await ClearSearchEvent.InvokeAsync(inProgressCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Transfer Events

        /// <summary>
        /// </summary>
        /// <param name="transfer"></param>
        /// <returns></returns>
        protected async Task OnEditTransfer(TransferredGetListViewModel transfer)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryDetails>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Tab", LaboratoryTabEnum.Transferred}, {"SampleId", transfer.TransferredOutSampleID},
                        {"TransferId", transfer.TransferID}, {"TransferredInSampleId", transfer.TransferredInSampleID}, 
                        {"Transfer", transfer},
                        {"DiseaseId", transfer.DiseaseID}, {"TestId", transfer.TestID}
                    },
                    new DialogOptions
                    {
                        ShowClose = true, 
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryRecordDetailsDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == DialogResultConstants.Save)
                        await OnReloadTransferred();

                    DiagService.Close(result);
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
        /// <param name="transfer"></param>
        /// <returns></returns>
        protected async Task OnSetMyFavorite(TransferredGetListViewModel transfer)
        {
            try
            {
                await SetMyFavorite(transfer.TransferredOutSampleID, null, null);
                await SetMyFavoriteEvent.InvokeAsync();

                LaboratoryService.SelectedTransferred ??= new List<TransferredGetListViewModel>();
                LaboratoryService.SelectedTransferred.Clear();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Accession In Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAccessionIn()
        {
            await TransferredGrid.Reload();
        }

        #endregion

        #endregion
    }
}
