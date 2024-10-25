#region Usings

using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class AddSampleToBatchBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AddSampleToBatchBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public string SearchString { get; set; }
        [Parameter] public EventCallback<int> SearchEvent { get; set; }
        [Parameter] public BatchesGetListViewModel Batch { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<TestingGetListViewModel> TestingGrid { get; set; }
        public int Count { get; set; }
        public bool IsLoading { get; set; }
        protected IList<TestingGetListViewModel> Testing { get; set; }
        protected IList<TestingGetListViewModel> SelectedTesting { get; set; }
        private bool IsSearchPerformed { get; set; }
        public bool AllowAddSampleToBatchIndicator { get; set; }

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
        public AddSampleToBatchBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AddSampleToBatchBase() : base(CancellationToken.None)
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
            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);

            SelectedTesting = new List<TestingGetListViewModel>();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            _disposedValue = true;
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

        #region Load Data Method

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
                    int lastPage = 0,
                        pageSize = 10;

                    if (TestingGrid.PageSize != 0)
                    {
                        pageSize = TestingGrid.PageSize;
                        IsLoading = true;
                    }

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (LaboratoryService.SearchBatchTests != null)
                    {
                        if (LaboratoryService.SearchBatchTests.Count > 0)
                            lastPage = LaboratoryService.SearchBatchTests.First().CurrentPage - 1;
                    }
                    else if (Testing != null)
                    {
                        if (Testing.Count > 0)
                            lastPage = Testing.First().CurrentPage - 1;
                    }
                    else
                    {
                        IsLoading = true;
                    }

                    if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        IsLoading = true;

                    if ((IsLoading || !IsNullOrEmpty(args.OrderBy)) && IsSearchPerformed == false)
                    {
                        string sortColumn,
                            sortOrder;

                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                            sortColumn = "EIDSSLaboratorySampleID";
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

                        if (IsNullOrEmpty(SearchString))
                        {
                            var request = new AdvancedSearchGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = "EIDSSLaboratorySampleID",
                                SortOrder = SortConstants.Descending,
                                DateFrom = SqlDateTime.MinValue.Value.AddYears(1),
                                DateTo = DateTime.Today,
                                DiseaseID = Batch.DiseaseID,
                                TestNameTypeID = Batch.BatchTestTestNameTypeID,
                                TestStatusTypeID = (long) TestStatusTypeEnum.InProgress,
                                BatchTestAssociationIndicator = true,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = null,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                                UserSiteGroupID = null
                            };

                            LaboratoryService.SearchBatchTests =
                                await LaboratoryClient.GetTestingAdvancedSearchList(request, _token);

                            if (LaboratoryService.SearchBatchTests.Count == 0)
                                await SearchEvent.InvokeAsync(0);
                            else
                                await SearchEvent.InvokeAsync(LaboratoryService.SearchBatchTests[0].InProgressCount);

                            Testing = LaboratoryService.SearchBatchTests;
                        }
                        else
                        {
                            var request = new TestingGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = page,
                                PageSize = pageSize,
                                SearchString = SearchString,
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

                            LaboratoryService.SearchBatchTests =
                                await LaboratoryClient.GetTestingSimpleSearchList(request, _token);

                            if (LaboratoryService.SearchBatchTests.Count == 0)
                                await SearchEvent.InvokeAsync(0);
                            else
                                await SearchEvent.InvokeAsync(LaboratoryService.SearchBatchTests[0].InProgressCount);

                            Testing = LaboratoryService.SearchBatchTests;
                        }

                        Count = !Testing.Any() ? 0 : Testing.First().TotalRowCount;
                    }
                }

                if (Testing != null)
                    foreach (var test in Testing)
                        if (test.TestResultTypeID != null)
                            test.TestResultTypeDisabledIndicator = true;

                IsLoading = false;
                IsSearchPerformed = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Testing is null)
                    return false;

                if (SelectedTesting is {Count: > 0})
                    if (Testing.Any(item =>
                            SelectedTesting.Any(x => x.TestID == item.TestID) &&
                            !item.TestResultTypeDisabledIndicator))
                    {
                        AllowAddSampleToBatchIndicator = true;
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
        protected void OnHeaderRecordSelectionChange(bool? value)
        {
            try
            {
                if (value == false)
                    foreach (var item in Testing)
                    {
                        var selected = SelectedTesting.FirstOrDefault(x => x.TestID == item.TestID);
                        if (selected != null) SelectedTesting.Remove(selected);
                    }
                else
                    foreach (var item in Testing)
                        if (!item.TestResultTypeDisabledIndicator)
                            SelectedTesting.Add(item);

                AllowAddSampleToBatchIndicator = SelectedTesting.Count > 0;
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
                if (SelectedTesting != null &&
                    SelectedTesting.Any(x => x.TestID == item.TestID) &&
                    !item.TestResultTypeDisabledIndicator)
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
        protected void OnRecordSelectionChange(bool? value, TestingGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = SelectedTesting.FirstOrDefault(x => x.TestID == item.TestID);
                    if (item != null) SelectedTesting.Remove(item);
                }
                else
                {
                    if (!item.TestResultTypeDisabledIndicator)
                        SelectedTesting.Add(item);
                }

                AllowAddSampleToBatchIndicator = SelectedTesting.Count > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected Task OnAddClick()
        {
            foreach (var test in SelectedTesting)
            {
                test.BatchTestID = Batch.BatchTestID;
                test.ActionPerformedIndicator = true;
                test.RowAction = (int) RowActionTypeEnum.Insert;
                TogglePendingSaveTesting(test);
            }

            DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.OK});
            return Task.CompletedTask;
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                var result =
                    await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                        .ConfigureAwait(false);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
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