#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Administration.Site
{
    /// <summary>
    /// </summary>
    public class OrganizationsSectionBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<OrganizationsSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public SiteDetailsViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<OrganizationGetListViewModel> OrganizationsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private int _databaseQueryCount;
        private int _newRecordCount;
        private int _lastDatabasePage;
        private int _lastPage = 1;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "AbbreviatedName";

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();
        }

        /// <summary>
        ///     Cancel any background tasks and remove event handlers.
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                IsLoading = true;

                await JsRuntime.InvokeVoidAsync("OrganizationsSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
            }
        }

        #endregion

        #region Load Data Method

        /// <summary>
        /// </summary>
        /// <param name="siteId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<OrganizationGetListViewModel>> GetOrganizations(long siteId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new OrganizationGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
                SiteID = siteId
            };

            return await OrganizationClient.GetOrganizationList(request);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadOrganizationData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (OrganizationsGrid.PageSize != 0)
                    pageSize = OrganizationsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.OrganizationsSection.Organizations is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        IsLoading = true;

                    if (IsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        if (Model.SiteInformationSection.SiteDetails.SiteID is null)
                            Model.OrganizationsSection.Organizations = new List<OrganizationGetListViewModel>();
                        else
                            Model.OrganizationsSection.Organizations =
                                await GetOrganizations((long) Model.SiteInformationSection.SiteDetails.SiteID, page,
                                        pageSize, sortColumn, sortOrder)
                                    .ConfigureAwait(false);
                        _databaseQueryCount = (int) (!Model.OrganizationsSection.Organizations.Any()
                            ? 0
                            : Model.OrganizationsSection.Organizations.First().RowCount);
                    }
                    else if (Model.Organizations != null)
                    {
                        _databaseQueryCount = (Model.OrganizationsSection.Organizations ??
                                               new List<OrganizationGetListViewModel>()).All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.OrganizationKey < 0)
                            ? 0
                            : (int) Model.OrganizationsSection.Organizations.First(x => x.OrganizationKey > 0).RowCount;
                    }

                    if (Model.OrganizationsSection.Organizations != null)
                        for (var index = 0; index < Model.OrganizationsSection.Organizations.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.OrganizationsSection.Organizations[index].RowAction ==
                                (int) RowActionTypeEnum.Insert)
                            {
                                Model.OrganizationsSection.Organizations.RemoveAt(index);
                                index--;
                            }

                            if (Model.OrganizationsSection.PendingSaveOrganizations == null || index < 0 ||
                                Model.OrganizationsSection.Organizations.Count == 0 ||
                                Model.OrganizationsSection.PendingSaveOrganizations.All(x =>
                                    x.OrganizationKey !=
                                    Model.OrganizationsSection.Organizations[index].OrganizationKey)) continue;
                            {
                                if (Model.OrganizationsSection.PendingSaveOrganizations
                                        .First(x => x.OrganizationKey == Model.OrganizationsSection.Organizations[index]
                                            .OrganizationKey)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.OrganizationsSection.Organizations.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.OrganizationsSection.Organizations[index] =
                                        Model.OrganizationsSection.PendingSaveOrganizations.First(x =>
                                            x.OrganizationKey == Model.OrganizationsSection.Organizations[index]
                                                .OrganizationKey);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.OrganizationsSection.PendingSaveOrganizations != null &&
                            Model.OrganizationsSection.PendingSaveOrganizations.Any(x =>
                                x.RowAction == (int) RowActionTypeEnum.Insert))
                        {
                            var newRecordsPendingSave =
                                Model.OrganizationsSection.PendingSaveOrganizations
                                    .Where(x => x.RowAction == (int) RowActionTypeEnum.Insert).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _lastDatabasePage;
                            var quotientNewRecords = Math.DivRem(Count, pageSize, out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = pageSize - remainderDatabaseQuery > newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : pageSize - remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                pageSize = remainderNewRecords;
                                Model.OrganizationsSection.Organizations?.Clear();
                            }
                            else
                            {
                                Model.OrganizationsSection.Organizations?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.OrganizationsSection.Organizations?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.OrganizationsSection.Organizations != null)
                            Model.OrganizationsSection.Organizations = Model.OrganizationsSection.Organizations
                                .AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _lastPage = page;
                }

                IsLoading = false;
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
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveOrganizations(OrganizationGetListViewModel record,
            OrganizationGetListViewModel originalRecord)
        {
            Model.OrganizationsSection.PendingSaveOrganizations ??= new List<OrganizationGetListViewModel>();

            if (Model.OrganizationsSection.PendingSaveOrganizations.Any(
                    x => x.OrganizationKey == record.OrganizationKey))
            {
                var index = Model.OrganizationsSection.PendingSaveOrganizations.IndexOf(originalRecord);
                Model.OrganizationsSection.PendingSaveOrganizations[index] = record;
            }
            else
            {
                Model.OrganizationsSection.PendingSaveOrganizations.Add(record);
            }
        }

        #endregion

        #region Add Organization Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="organizationKey"></param>
        /// <param name="abbreviatedName"></param>
        /// <param name="organizationId"></param>
        /// <param name="addressString"></param>
        /// <returns></returns>
        [JSInvokable]
        public async Task OnOrganizationSelected(string organizationKey, string abbreviatedName, string organizationId,
            string addressString)
        {
            try
            {
                OrganizationGetListViewModel model = new()
                {
                    OrganizationKey = Convert.ToInt64(organizationKey),
                    AbbreviatedName = abbreviatedName,
                    OrganizationID = organizationId,
                    AddressString = addressString,
                    RowStatus = (int) RowStatusTypeEnum.Active,
                    RowAction = (int) RowActionTypeEnum.Insert
                };

                _newRecordCount += 1;

                Model.OrganizationsSection.Organizations.Add(model);

                TogglePendingSaveOrganizations(model, null);

                await OrganizationsGrid.Reload().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Organization Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="organization"></param>
        protected async Task OnDeleteOrganizationClick(object organization)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.OrganizationsSection.Organizations.Any(x =>
                                x.OrganizationKey == ((OrganizationGetListViewModel) organization).OrganizationKey))
                        {
                            if (((OrganizationGetListViewModel) organization).OrganizationKey <= 0)
                            {
                                Model.OrganizationsSection.Organizations.Remove(
                                    (OrganizationGetListViewModel) organization);
                                Model.OrganizationsSection.PendingSaveOrganizations.Remove(
                                    (OrganizationGetListViewModel) organization);
                                _newRecordCount--;
                            }
                            else
                            {
                                result = ((OrganizationGetListViewModel) organization).ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                Model.OrganizationsSection.Organizations.Remove(
                                    (OrganizationGetListViewModel) organization);
                                Count--;

                                TogglePendingSaveOrganizations(result, (OrganizationGetListViewModel) organization);
                            }
                        }

                        await OrganizationsGrid.Reload().ConfigureAwait(false);

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

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSubmit()
        {
            Model.OrganizationsSectionValidIndicator = true;

            return Model.OrganizationsSectionValidIndicator;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            Model.OrganizationsSectionValidIndicator = true;

            return Model.OrganizationsSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.OrganizationsSection.Organizations = null;
            OrganizationsGrid.Reload();
        }

        #endregion

        #endregion
    }
}