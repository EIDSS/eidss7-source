#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class SearchComponent : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SearchComponent> Logger { get; set; }
        [Inject] private ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] protected LaboratoryStateContainerService LaboratoryService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback<string> SimpleSearchEvent { get; set; }

        [Parameter] public EventCallback<bool?> TestUnassignedSearchEvent { get; set; }

        [Parameter] public EventCallback<bool?> TestCompletedSearchEvent { get; set; }

        [Parameter] public EventCallback<AdvancedSearchGetRequestModel> AdvancedSearchEvent { get; set; }

        [Parameter] public EventCallback<bool> ClearSearchEvent { get; set; }

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        public string SearchString { get; set; }
        public bool AdvancedSearchPerformedIndicator { get; set; }
        public bool TestUnassignedIndicator { get; set; }
        public bool TestCompletedIndicator { get; set; }

        public bool SearchDisabledIndicator
        {
            get
            {
                if (Tab != LaboratoryTabEnum.Batches) return _searchDisabledIndicator;
                if (LaboratoryService.SelectedBatches is {Count: 1})
                {
                    if (!LaboratoryService.SelectedBatches.Any(x =>
                            x.BatchStatusTypeID is (long) BatchTestStatusTypeEnum.Closed))
                        _searchDisabledIndicator = false;
                }
                else
                {
                    _searchDisabledIndicator = true;
                }

                return _searchDisabledIndicator;
            }
        }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;
        private bool _searchDisabledIndicator;

        #endregion

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var name = string.Empty;

                if (LaboratoryService.TestCompletedIndicator is not null)
                    TestCompletedIndicator = (bool)LaboratoryService.TestCompletedIndicator;

                if (LaboratoryService.TestUnassignedIndicator is not null)
                    TestUnassignedIndicator = (bool)LaboratoryService.TestUnassignedIndicator;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                        name = LaboratorySearchStorageConstants.SamplesSearchString;
                        break;
                    case LaboratoryTabEnum.Testing:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);

                        name = LaboratorySearchStorageConstants.TestingSearchString;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);

                        name = LaboratorySearchStorageConstants.TransferredSearchString;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                        name = LaboratorySearchStorageConstants.MyFavoritesSearchString;
                        break;
                    case LaboratoryTabEnum.Batches:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);

                        name = LaboratorySearchStorageConstants.BatchesSearchString;
                        break;
                    case LaboratoryTabEnum.Approvals:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                        name = LaboratorySearchStorageConstants.ApprovalsSearchString;
                        break;
                }

                _searchDisabledIndicator = !_userPermissions.Read;
                if (SearchDisabledIndicator == false)
                {
                    var result = await BrowserStorage.GetAsync<string>(name);
                    SearchString = result.Success ? result.Value : string.Empty;

                    if (SearchString == LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator)
                        SearchString = string.Empty;
                }

                await InvokeAsync(StateHasChanged);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
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

        /// <summary>
        /// </summary>
        protected async Task SearchButtonClicked()
        {
            await SimpleSearchEvent.InvokeAsync(SearchString);

            switch (Tab)
            {
                case LaboratoryTabEnum.Samples:
                    await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.SamplesSearchString, SearchString);
                    break;
                case LaboratoryTabEnum.Testing:
                    await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.TestingSearchString, SearchString);
                    break;
                case LaboratoryTabEnum.Transferred:
                    await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.TransferredSearchString,
                        SearchString);
                    break;
                case LaboratoryTabEnum.MyFavorites:
                    await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.MyFavoritesSearchString,
                        SearchString);
                    break;
                case LaboratoryTabEnum.Batches:
                    await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.BatchesSearchString, SearchString);
                    break;
                case LaboratoryTabEnum.Approvals:
                    await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.ApprovalsSearchString, SearchString);
                    break;
            }
        }

        /// <summary>
        /// </summary>
        protected async Task ClearButtonClicked()
        {
            AdvancedSearchPerformedIndicator = false;
            SearchString = null;
            switch (Tab)
            {
                case LaboratoryTabEnum.Samples:
                    await BrowserStorage.DeleteAsync(LaboratorySearchStorageConstants.SamplesSearchString);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratorySamplesAdvancedSearchModelKey);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratorySamplesAdvancedSearchPerformedIndicatorKey);
                    break;
                case LaboratoryTabEnum.Testing:
                    await BrowserStorage.DeleteAsync(LaboratorySearchStorageConstants.TestingSearchString);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTestingAdvancedSearchModelKey);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTestingAdvancedSearchPerformedIndicatorKey);
                    break;
                case LaboratoryTabEnum.Transferred:
                    await BrowserStorage.DeleteAsync(LaboratorySearchStorageConstants.TransferredSearchString);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchModelKey);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchPerformedIndicatorKey);
                    break;
                case LaboratoryTabEnum.MyFavorites:
                    await BrowserStorage.DeleteAsync(LaboratorySearchStorageConstants.MyFavoritesSearchString);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchModelKey);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchPerformedIndicatorKey);
                    break;
                case LaboratoryTabEnum.Batches:
                    await BrowserStorage.DeleteAsync(LaboratorySearchStorageConstants.BatchesSearchString);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchModelKey);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchPerformedIndicatorKey);
                    break;
                case LaboratoryTabEnum.Approvals:
                    await BrowserStorage.DeleteAsync(LaboratorySearchStorageConstants.ApprovalsSearchString);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchModelKey);
                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchPerformedIndicatorKey);
                    break;
            }

            await ClearSearchEvent.InvokeAsync();

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public async Task OnTestUnassignedIndicatorChanged(bool? value)
        {
            switch (Tab)
            {
                case LaboratoryTabEnum.Samples:
                    await BrowserStorage.SetAsync(
                        LaboratorySearchStorageConstants.TestUnassignedSearchPerformedIndicator,
                        LaboratorySearchStorageConstants.TestUnassignedSearchPerformedIndicator);
                    break;
            }

            await TestUnassignedSearchEvent.InvokeAsync(value);

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public async Task OnTestCompletedIndicatorChanged(bool? value)
        {
            switch (Tab)
            {
                case LaboratoryTabEnum.Samples:
                    await BrowserStorage.SetAsync(
                        LaboratorySearchStorageConstants.TestCompletedSearchPerformedIndicator,
                        LaboratorySearchStorageConstants.TestCompletedSearchPerformedIndicator);
                    break;
            }

            await TestCompletedSearchEvent.InvokeAsync(value);

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OpenAdvancedSearch()
        {
            try
            {
                var result = await DiagService.OpenAsync<AdvancedSearch>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAdvancedSearchModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions {Width = "700px", Resizable = true, Draggable = false});

                if (result == null)
                    return;

                //User cancelled, so just return to close the dialog and perform no further actions.
                if (result is DialogReturnResult)
                    return;

                //User searched, so return the search criteria model and perform the search action.
                if (((EditContext) result).Validate())
                {
                    SearchString = null;
                    AdvancedSearchPerformedIndicator = true;
                    switch (Tab)
                    {
                        case LaboratoryTabEnum.Samples:
                            await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.SamplesSearchString,
                                LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator);
                            break;
                        case LaboratoryTabEnum.Testing:
                            await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.TestingSearchString,
                                LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator);
                            break;
                        case LaboratoryTabEnum.Transferred:
                            await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.TransferredSearchString,
                                LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator);
                            break;
                        case LaboratoryTabEnum.MyFavorites:
                            await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.MyFavoritesSearchString,
                                LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator);
                            break;
                        case LaboratoryTabEnum.Approvals:
                            await BrowserStorage.SetAsync(LaboratorySearchStorageConstants.ApprovalsSearchString,
                                LaboratorySearchStorageConstants.AdvancedSearchPerformedIndicator);
                            break;
                    }

                    await AdvancedSearchEvent.InvokeAsync(result.Model as AdvancedSearchGetRequestModel);
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion
    }
}