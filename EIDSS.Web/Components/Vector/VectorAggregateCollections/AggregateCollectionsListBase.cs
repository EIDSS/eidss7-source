using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
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

namespace EIDSS.Web.Components.Vector.VectorAggregateCollections
{
    public class AggregateCollectionsListBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<AggregateCollectionsListBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        protected RadzenDataGrid<VectorSessionDetailResponseModel> Grid { get; set; }
        protected bool IsLoading { get; set; }

        #endregion Properties

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override void OnInitialized()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VectorSurveillanceSessionAggregateCollections.SetDotNetReference", _token,
                    lDotNetReference);
            }
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            VectorSessionStateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
        }

        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "SelectedVectorTab")
            {
                await InvokeAsync(StateHasChanged);
                await Grid.Reload();
            }
        }

        #endregion State Container Events

        #region Control Events

        protected void OnCollectionViewOnlyClick(object data)
        {
            if (data == null) return;
            VectorSessionStateContainer.VectorSessionSummaryKey =
                (data as VectorSessionDetailResponseModel)?.idfsVSSessionSummary;

            VectorSessionStateContainer.AggregateCollectionDisabledIndicator = true;
            VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = false;
            VectorSessionStateContainer.AggregateCollectionTabDisabled = false;
            VectorSessionStateContainer.SelectedVectorTab = (int)VectorTabs.AggregateCollectionsTab;
        }

        protected async Task OnCollectionEditClick(object data)
        {
            if (data != null)
            {
                VectorSessionStateContainer.VectorSessionSummaryKey =
                    (data as VectorSessionDetailResponseModel)?.idfsVSSessionSummary;

                // validate the surveillance session before we change tabs
                var isValid = await JsRuntime.InvokeAsync<bool>("validateSurveillanceSession", _token);
                if (isValid)
                {
                    VectorSessionStateContainer.AggregateCollectionTabDisabled = false;
                    VectorSessionStateContainer.SelectedVectorTab = (int)VectorTabs.AggregateCollectionsTab;
                    VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = true;
                }
            }
        }

        protected async Task OnAddNewCollectionClick()
        {
            // new aggregate collection
            if (VectorSessionStateContainer.AggregateCollectionList != null)
            {
                VectorSessionStateContainer.VectorSessionSummaryKey = (VectorSessionStateContainer.AggregateCollectionList.Count + 1) * -1;
            }
            else
            {
                VectorSessionStateContainer.VectorSessionSummaryKey = -1;
            }

            VectorSessionStateContainer.SummaryRowStatus = (int)RowStatusTypes.Active;
            VectorSessionStateContainer.SummaryRowAction = (int)RowActionTypeEnum.Insert;

            // set aggregate collection fields to defaults
            VectorSessionStateContainer.SummaryCollectionDateTime = null;
            VectorSessionStateContainer.SummaryForeignAddress = null;
            VectorSessionStateContainer.SummaryGeoLocationTypeID = null;
            VectorSessionStateContainer.SummaryInfoSexID = null;
            VectorSessionStateContainer.SummaryInfoSpeciesID = null;
            VectorSessionStateContainer.SummaryRecordID = null;
            VectorSessionStateContainer.PoolsAndVectors = null;
            VectorSessionStateContainer.SummaryVectorTypeID = null;

            // populate the address from the surveillance session by default
            VectorSessionStateContainer.SummaryGeoLocationTypeID = (VectorSessionStateContainer.GeoLocationTypeID == GeoLocationTypes.National) ? GeoLocationTypes.ExactPoint : VectorSessionStateContainer.GeoLocationTypeID;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Value = VectorSessionStateContainer.LocationViewModel.AdminLevel0Value;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value = VectorSessionStateContainer.LocationViewModel.AdminLevel1Value;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value = VectorSessionStateContainer.LocationViewModel.AdminLevel2Value;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Value = VectorSessionStateContainer.LocationViewModel.AdminLevel3Value;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel4Value = VectorSessionStateContainer.LocationViewModel.AdminLevel4Value;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel5Value = VectorSessionStateContainer.LocationViewModel.AdminLevel5Value;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel6Value = VectorSessionStateContainer.LocationViewModel.AdminLevel6Value;
            VectorSessionStateContainer.SummaryLocationViewModel.Apartment = VectorSessionStateContainer.LocationViewModel.Apartment;
            VectorSessionStateContainer.SummaryLocationViewModel.Building = VectorSessionStateContainer.LocationViewModel.Building;
            VectorSessionStateContainer.SummaryLocationViewModel.House = VectorSessionStateContainer.LocationViewModel.House;
            VectorSessionStateContainer.SummaryLocationViewModel.Street = VectorSessionStateContainer.LocationViewModel.Street;
            VectorSessionStateContainer.SummaryLocationViewModel.StreetText = VectorSessionStateContainer.LocationViewModel.StreetText;
            VectorSessionStateContainer.SummaryLocationViewModel.PostalCode = VectorSessionStateContainer.LocationViewModel.PostalCode;
            VectorSessionStateContainer.SummaryLocationViewModel.Latitude = VectorSessionStateContainer.LocationViewModel.Latitude;
            VectorSessionStateContainer.SummaryLocationViewModel.Longitude = VectorSessionStateContainer.LocationViewModel.Longitude;
            VectorSessionStateContainer.SummaryLocationViewModel.SettlementId = VectorSessionStateContainer.LocationViewModel.SettlementId;
            VectorSessionStateContainer.SummaryForeignAddress = VectorSessionStateContainer.ForeignAddress;
            VectorSessionStateContainer.SummaryLocationDirection = VectorSessionStateContainer.LocationDirection;
            VectorSessionStateContainer.SummaryLocationDistance = VectorSessionStateContainer.LocationDistance;
            VectorSessionStateContainer.SummaryLocationGroundTypeID = VectorSessionStateContainer.LocationGroundTypeID;
            VectorSessionStateContainer.SummaryLocationDescription = null;

            await SwitchLocation(VectorSessionStateContainer.SummaryGeoLocationTypeID,
                VectorSessionStateContainer.SummaryLocationViewModel,
                VectorTabs.AggregateCollectionsTab);

            // validate the surveillance session before we change tabs
            var isValid = await JsRuntime.InvokeAsync<bool>("validateSurveillanceSession", _token);
            if (isValid)
            {
                VectorSessionStateContainer.AggregateCollectionTabDisabled = false;
                VectorSessionStateContainer.SelectedVectorTab = (int)VectorTabs.AggregateCollectionsTab;
                VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = true;
            }
        }

        protected async Task OnCollectionDeleteClick(VectorSessionDetailResponseModel item)
        {
            if (item != null)
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        var response = await VectorClient.DeleteAggregateCollection(item.idfsVSSessionSummary, _token);
                        switch (response.ReturnCode)
                        {
                            case 0:
                                
                                if (item.idfsVSSessionSummary <= 0)
                                {
                                    VectorSessionStateContainer.AggregateCollectionList.Remove(item);
                                    VectorSessionStateContainer.PendingAggregateCollectionList.Remove(item);
                                    VectorSessionStateContainer.AggregateNewCollectionsCount--;
                                }
                                else
                                {
                                    VectorSessionStateContainer.AggregateCollectionList.Remove(item);
                                    VectorSessionStateContainer.AggregateCollectionsCount--;
                                    if (VectorSessionStateContainer.PendingAggregateCollectionList is { Count: > 0 })
                                    {
                                        var aggregateItem =
                                            VectorSessionStateContainer.PendingAggregateCollectionList.FirstOrDefault(x =>
                                                x.idfsVSSessionSummary == item.idfsVSSessionSummary);
                                        if (aggregateItem != null)
                                        {
                                            VectorSessionStateContainer.PendingAggregateCollectionList.Remove(aggregateItem);
                                        }
                                    }
                                }

                                await Grid.Reload();
                                break;
                            case 1:
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                                    null);
                                DiagService.Close(result);
                                break;
                        }
                    }
                    else
                    {
                        DiagService.Close(result);
                    }
                }
                else
                {
                    DiagService.Close();
                }
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingAggregateCollection(VectorSessionDetailResponseModel record,
            VectorSessionDetailResponseModel originalRecord)
        {
            VectorSessionStateContainer.PendingAggregateCollectionList ??=
                new List<VectorSessionDetailResponseModel>();

            if (VectorSessionStateContainer.PendingAggregateCollectionList.Any(x =>
                    x.idfsVSSessionSummary == record.idfsVSSessionSummary))
            {
                var index = VectorSessionStateContainer.PendingAggregateCollectionList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingAggregateCollectionList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingAggregateCollectionList.Add(record);
            }
        }

        #endregion Control Events

        #region Load Data Grid

        protected async Task LoadAggregateCollectionsGrid(LoadDataArgs args)
        {
            try
            {
                int page = 1, pageSize = 10;

                string sortColumn = "strVSSessionSummaryID",
                    sortOrder = SortConstants.Descending;

                if (args.Top != null) page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                if (VectorSessionStateContainer.AggregateCollectionList is null
                    || !VectorSessionStateContainer.AggregateCollectionList.Any())
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "strVSSessionSummaryID";
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.FirstOrDefault()?.Property;
                        sortOrder = args.Sorts.FirstOrDefault() != null
                            ? args.Sorts.FirstOrDefault()?.SortOrder.GetValueOrDefault().ToString()
                            : SortConstants.Descending;
                    }

                    var request = new USP_VCTS_VecSessionSummary_GETListRequestModel()
                    {
                        LangID = GetCurrentLanguage(),
                        idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey
                    };

                    VectorSessionStateContainer.AggregateCollectionList = await VectorClient.GetVectorAggregateCollectionList(request, _token);
                    VectorSessionStateContainer.AggregateCollectionsDatabaseQueryCount = !VectorSessionStateContainer.AggregateCollectionList.Any()
                        ? 0
                        : VectorSessionStateContainer.AggregateCollectionList.First().TotalRowCount;
                }
                else if (VectorSessionStateContainer.AggregateCollectionList != null)
                {
                    VectorSessionStateContainer.AggregateCollectionsDatabaseQueryCount = !VectorSessionStateContainer.AggregateCollectionList.Any()
                        ? 0
                        : VectorSessionStateContainer.AggregateCollectionList.First().TotalRowCount;
                }

                // remove or match up pending items that did not come from the database call
                if (VectorSessionStateContainer.AggregateCollectionList != null)
                {
                    for (var index = 0; index < VectorSessionStateContainer.AggregateCollectionList.Count; index++)
                    {
                        // Remove any added unsaved records; will be added back at the end.
                        if (VectorSessionStateContainer.AggregateCollectionList[index].idfsVSSessionSummary < 0)
                        {
                            VectorSessionStateContainer.AggregateCollectionList.RemoveAt(index);
                            index--;
                        }

                        if (VectorSessionStateContainer.PendingAggregateCollectionList == null || index < 0 || VectorSessionStateContainer.AggregateCollectionList.Count == 0 || VectorSessionStateContainer.PendingAggregateCollectionList.All(x =>
                                x.idfsVSSessionSummary != VectorSessionStateContainer.AggregateCollectionList[index].idfsVSSessionSummary)) continue;
                        {
                            if (VectorSessionStateContainer.PendingAggregateCollectionList.First(x => x.idfsVSSessionSummary == VectorSessionStateContainer.AggregateCollectionList[index].idfsVSSessionSummary)
                                    .intRowStatus == (int)RowStatusTypeEnum.Inactive)
                            {
                                VectorSessionStateContainer.AggregateCollectionList.RemoveAt(index);
                                VectorSessionStateContainer.AggregateCollectionsDatabaseQueryCount--;
                                index--;
                            }
                            else
                            {
                                VectorSessionStateContainer.AggregateCollectionList[index] = VectorSessionStateContainer.PendingAggregateCollectionList.First(x =>
                                    x.idfsVSSessionSummary == VectorSessionStateContainer.AggregateCollectionList[index].idfsVSSessionSummary);
                            }
                        }
                    }
                }

                VectorSessionStateContainer.AggregateCollectionsCount = VectorSessionStateContainer.AggregateCollectionsDatabaseQueryCount + VectorSessionStateContainer.AggregateNewCollectionsCount;

                if (VectorSessionStateContainer.AggregateNewCollectionsCount > 0)
                {
                    VectorSessionStateContainer.AggregateCollectionsLastDatabasePage = Math.DivRem(VectorSessionStateContainer.AggregateCollectionsDatabaseQueryCount, pageSize, out int remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0 || VectorSessionStateContainer.AggregateCollectionsLastDatabasePage == 0)
                        VectorSessionStateContainer.AggregateCollectionsLastDatabasePage += 1;

                    if (page >= VectorSessionStateContainer.AggregateCollectionsLastDatabasePage && VectorSessionStateContainer.PendingAggregateCollectionList != null &&
                          VectorSessionStateContainer.PendingAggregateCollectionList.Any(x => x.idfsVSSessionSummary < 0))
                    {
                        var newRecordsPendingSave =
                            VectorSessionStateContainer.PendingAggregateCollectionList.Where(x => x.idfsVSSessionSummary < 0).ToList();
                        var counter = 0;
                        var pendingSavePage = page - VectorSessionStateContainer.AggregateCollectionsLastDatabasePage;
                        var quotientNewRecords = Math.DivRem(VectorSessionStateContainer.AggregateCollectionsCount, pageSize, out var remainderNewRecords);

                        if (remainderNewRecords >= pageSize / 2)
                            quotientNewRecords += 1;

                        if (pendingSavePage == 0)
                        {
                            pageSize = remainderDatabaseQuery < newRecordsPendingSave.Count
                                ? newRecordsPendingSave.Count
                                : remainderDatabaseQuery;
                        }
                        else if (page - 1 == quotientNewRecords)
                        {
                            pageSize = remainderNewRecords;
                            VectorSessionStateContainer.AggregateCollectionList?.Clear();
                        }
                        else
                        {
                            VectorSessionStateContainer.AggregateCollectionList?.Clear();
                        }

                        while (counter < pageSize)
                        {
                            VectorSessionStateContainer.AggregateCollectionList?.Add(pendingSavePage == 0
                                ? newRecordsPendingSave[counter]
                                : newRecordsPendingSave[
                                    pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                            counter += 1;
                        }
                    }

                    if (VectorSessionStateContainer.AggregateCollectionList != null)
                        VectorSessionStateContainer.AggregateCollectionList =
                            VectorSessionStateContainer.AggregateCollectionList.AsQueryable()
                                .OrderBy(sortColumn,
                                    sortOrder == SortConstants.Ascending).ToList();
                }

                VectorSessionStateContainer.AggregateCollectionsLastDatabasePage = page;

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data Grid

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            // no validation here, just return valid
            return await Task.FromResult(true);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}