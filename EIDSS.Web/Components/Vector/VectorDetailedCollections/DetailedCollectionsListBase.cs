using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.Web.ViewModels.Vector;
using EIDSS.Domain.RequestModels.Vector;
using Radzen;
using Microsoft.AspNetCore.WebUtilities;
using EIDSS.Domain.ResponseModels.Vector;
using System.Threading;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Vector;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using Microsoft.JSInterop;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class DetailedCollectionsListBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<DetailedCollectionsListBase> Logger { get; set; }

        #endregion Dependencies

        #region Properties

        protected RadzenDataGrid<USP_VCTS_VECT_GetDetailResponseModel> Grid { get; set; }
        protected RadzenDataGrid<VectorSampleGetListViewModel> DetailCollectionSampleGrid { get; set; }
        protected bool IsLoading { get; set; }
        protected int Count { get; set; }
        protected int DetailCollectionDatabaseQueryCount { get; set; }
        protected int NewDetailCollectionCount { get; set; }
        protected int DetailCollectionLastDatabasePage { get; set; }
        protected int DetailCollectionLastPage { get; set; }
        protected int PreviousPageSize { get; set; }
        protected List<VectorSampleGetListViewModel> DetailedCollectionGridSamples { get; set; }

        #endregion Properties

        #region Member Variables

        private CancellationToken _token;
        private CancellationTokenSource _source;

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
                await JsRuntime.InvokeVoidAsync("VectorSurveillanceSessionDetailedCollections.SetDotNetReference", _token,
                    lDotNetReference);
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();

                VectorSessionStateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
            }

            base.Dispose(disposing);
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

        #region Detailed Collections Grid

        protected async Task LoadDetailedCollections(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.VectorSessionKey != null)
                {
                    int page,
                        pageSize = 10;

                    page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (VectorSessionStateContainer.DetailedCollectionList is null)
                        IsLoading = true;

                    if (IsLoading || !string.IsNullOrEmpty(args.OrderBy) || page != Grid.CurrentPage)
                    {
                        string sortColumn,
                           sortOrder;

                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                            sortColumn = "strSessionID";
                            sortOrder = SortConstants.Descending;
                        }
                        else
                        {
                            sortColumn = args.Sorts.FirstOrDefault()?.Property;
                            sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue ? args.Sorts.FirstOrDefault().SortOrder.Value.ToString() : SortConstants.Descending;
                        }

                        var request = new USP_VCTS_VECT_GetDetailRequestModel()
                        {
                            LangID = GetCurrentLanguage(),
                            idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey,
                            PageNumber = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder
                        };

                        VectorSessionStateContainer.DetailedCollectionList = await VectorClient.GetVectorDetails(request, _token);
                        Count = !VectorSessionStateContainer.DetailedCollectionList.Any() ? 0 : VectorSessionStateContainer.DetailedCollectionList.First().TotalRowCount.GetValueOrDefault();
                    }
                    else if (VectorSessionStateContainer.DetailedCollectionList != null)
                        Count = VectorSessionStateContainer.DetailedCollectionList != null &&
                                !VectorSessionStateContainer.DetailedCollectionList.Any()
                            ? 0
                            : VectorSessionStateContainer.DetailedCollectionList.First().TotalRowCount.GetValueOrDefault();

                    IsLoading = false;
                }
                else
                {
                    VectorSessionStateContainer.DetailedCollectionList = new List<USP_VCTS_VECT_GetDetailResponseModel>();
                    Count = 0;
                    IsLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Detailed Collections Grid

        #region Detailed Collections Grid Row Expand

        protected async Task OnDetailCollectionRowExpand(long detailCollectionID)
        {
            DetailedCollectionGridSamples = new List<VectorSampleGetListViewModel>();
            var request = new USP_VCTS_SAMPLE_GetListRequestModels()
            {
                idfMaterial = null,
                idfVector = detailCollectionID,
                LangID = GetCurrentLanguage()
            };
            DetailedCollectionGridSamples = await VectorClient.GetVectorSamplesAsync(request, _token);
            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        #endregion Detailed Collections Grid Row Expand

        #region Delete Method

        protected async Task OnCollectionDeleteClick(USP_VCTS_VECT_GetDetailResponseModel item)
        {
            if (item != null)
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        var response = await VectorClient.DeleteDetailedCollection(item.idfVector, _token);
                        switch (response.ReturnCode)
                        {
                            case 0:
                                await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                                    null);

                                DiagService.Close(result);

                                // remove the collection from all lists as it is deleted from db
                                VectorSessionStateContainer.DetailedCollectionList.Remove(item);
                                Count--;

                                if (VectorSessionStateContainer.DetailedCollectionsDetailsList is { Count: > 0 })
                                {
                                    var detailedItem =
                                        VectorSessionStateContainer.DetailedCollectionsDetailsList.FirstOrDefault(x =>
                                            x.VectorSessionDetailKey == item.idfVector);
                                    if (detailedItem != null)
                                    {
                                        VectorSessionStateContainer.DetailedCollectionsDetailsList.Remove(detailedItem);
                                    }
                                }

                                if (VectorSessionStateContainer.PendingDetailedCollectionsDetailsList is { Count: > 0 })
                                {
                                    var detailedItem =
                                        VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.FirstOrDefault(x =>
                                            x.VectorSessionDetailKey == item.idfVector);
                                    if (detailedItem != null)
                                    {
                                        VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.Remove(detailedItem);
                                    }
                                }

                                await Grid.Reload();
                                break;

                            case 1:
                                await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
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
        protected void TogglePendingDetailCollection(VectorDetailedCollectionViewModel record,
            VectorDetailedCollectionViewModel originalRecord)
        {
            VectorSessionStateContainer.PendingDetailedCollectionsDetailsList ??=
                new List<VectorDetailedCollectionViewModel>();

            if (VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.Any(x =>
                    x.VectorSessionDetailKey == record.VectorSessionDetailKey))
            {
                var index = VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingDetailedCollectionsDetailsList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.Add(record);
            }
        }

        #endregion Delete Method

        #region Add and Edit Methods

        protected async Task AddNewDetailedCollection()
        {
            // new detailed collection
            if (VectorSessionStateContainer.PendingDetailedCollectionsDetailsList != null)
            {
                VectorSessionStateContainer.VectorDetailedCollectionKey = (VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.Count + 1) * -1;
            }
            else
            {
                VectorSessionStateContainer.VectorDetailedCollectionKey = -1;
            }

            VectorSessionStateContainer.DetailRowAction = (int)RowActionTypeEnum.Insert;
            VectorSessionStateContainer.DetailRowStatus = (int)RowStatusTypeEnum.Active;

            // set detailed collection fields to defaults
            VectorSessionStateContainer.DetailBasisOfRecordID = null;
            VectorSessionStateContainer.DetailCollectedByInstitutionID = null;
            VectorSessionStateContainer.DetailCollectedByPersonID = null;
            VectorSessionStateContainer.DetailCollectionMethodID = null;
            VectorSessionStateContainer.DetailCollectionTimePeriodID = null;
            VectorSessionStateContainer.DetailCollectionDate = DateTime.Now;
            VectorSessionStateContainer.DetailComment = null;
            VectorSessionStateContainer.DetailEctoparasitesCollectedID = null;
            VectorSessionStateContainer.DetailFieldPoolVectorID = null;
            VectorSessionStateContainer.DetailFieldSessionID = null;
            VectorSessionStateContainer.DetailForeignAddress = null;
            VectorSessionStateContainer.DetailGeoLocationTypeID = GeoLocationTypes.ExactPoint;
            VectorSessionStateContainer.DetailGeoReferenceSource = null;
            VectorSessionStateContainer.DetailHostReferenceID = null;
            VectorSessionStateContainer.DetailIdentifiedByInstitutionID = null;
            VectorSessionStateContainer.DetailIdentifiedByMethodID = null;
            VectorSessionStateContainer.DetailIdentifiedByPersonID = null;
            VectorSessionStateContainer.DetailIdentifiedDate = null;
            VectorSessionStateContainer.DetailObservationID = null;
            VectorSessionStateContainer.DetailQuantity = null;
            VectorSessionStateContainer.DetailSpeciesID = null;
            VectorSessionStateContainer.DetailVectorTypeID = null;
            VectorSessionStateContainer.DetailedCollectionsSamplesList = null;
            VectorSessionStateContainer.DetailedCollectionsFieldTestsList = null;

            // populate the address from the surveillance session by default
            VectorSessionStateContainer.DetailGeoLocationTypeID = (VectorSessionStateContainer.GeoLocationTypeID == GeoLocationTypes.National) ? GeoLocationTypes.ExactPoint : VectorSessionStateContainer.GeoLocationTypeID;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value = VectorSessionStateContainer.LocationViewModel.AdminLevel0Value;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value = VectorSessionStateContainer.LocationViewModel.AdminLevel1Value;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value = VectorSessionStateContainer.LocationViewModel.AdminLevel2Value;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value = VectorSessionStateContainer.LocationViewModel.AdminLevel3Value;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value = VectorSessionStateContainer.LocationViewModel.AdminLevel4Value;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value = VectorSessionStateContainer.LocationViewModel.AdminLevel5Value;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value = VectorSessionStateContainer.LocationViewModel.AdminLevel6Value;
            VectorSessionStateContainer.DetailLocationViewModel.Apartment = VectorSessionStateContainer.LocationViewModel.Apartment;
            VectorSessionStateContainer.DetailLocationViewModel.Building = VectorSessionStateContainer.LocationViewModel.Building;
            VectorSessionStateContainer.DetailLocationViewModel.House = VectorSessionStateContainer.LocationViewModel.House;
            VectorSessionStateContainer.DetailLocationViewModel.Street = VectorSessionStateContainer.LocationViewModel.Street;
            VectorSessionStateContainer.DetailLocationViewModel.StreetText = VectorSessionStateContainer.LocationViewModel.StreetText;
            VectorSessionStateContainer.DetailLocationViewModel.PostalCode = VectorSessionStateContainer.LocationViewModel.PostalCode;
            VectorSessionStateContainer.DetailLocationViewModel.Latitude = VectorSessionStateContainer.LocationViewModel.Latitude;
            VectorSessionStateContainer.DetailLocationViewModel.Longitude = VectorSessionStateContainer.LocationViewModel.Longitude;
            VectorSessionStateContainer.DetailLocationViewModel.SettlementId = VectorSessionStateContainer.LocationViewModel.SettlementId;
            VectorSessionStateContainer.DetailForeignAddress = VectorSessionStateContainer.ForeignAddress;
            VectorSessionStateContainer.DetailLocationDirection = VectorSessionStateContainer.LocationDirection;
            VectorSessionStateContainer.DetailLocationDistance = VectorSessionStateContainer.LocationDistance;
            VectorSessionStateContainer.DetailLocationGroundTypeID = VectorSessionStateContainer.LocationGroundTypeID;
            VectorSessionStateContainer.DetailLocationDescription = null;

            await SwitchLocation(VectorSessionStateContainer.DetailGeoLocationTypeID,
                VectorSessionStateContainer.DetailLocationViewModel,
                VectorTabs.DetailedCollectionsTab);

            // validate the surveillance session before we change tabs
            var isValid = await JsRuntime.InvokeAsync<bool>("validateSurveillanceSession", _token);
            if (isValid)
            {
                VectorSessionStateContainer.DetailedCollectionTabDisabled = false;
                VectorSessionStateContainer.SelectedVectorTab = (int)VectorTabs.DetailedCollectionsTab;
                VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = true;
            }
        }

        protected async Task OnCollectionEditClick(USP_VCTS_VECT_GetDetailResponseModel data)
        {
            // edit detailed collection
            if (data != null)
            {
                VectorSessionStateContainer.VectorDetailedCollectionKey = data.idfVector;

                // validate the surveillance session before we change tabs
                var isValid = await JsRuntime.InvokeAsync<bool>("validateSurveillanceSession", _token);
                if (isValid)
                {
                    VectorSessionStateContainer.DetailedCollectionTabDisabled = false;
                    VectorSessionStateContainer.SelectedVectorTab = (int)VectorTabs.DetailedCollectionsTab;
                    VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = true;
                    VectorSessionStateContainer.DetailVectorTypeID = data.idfsVectorType;
                }
            }
        }

        protected void OnDetailCollectionViewOnlyClick(USP_VCTS_VECT_GetDetailResponseModel data)
        {
            // view detailed collection
            if (data == null) return;
            VectorSessionStateContainer.VectorDetailedCollectionKey = data.idfVector;

            VectorSessionStateContainer.DetailCollectionDisabledIndicator = true;
            VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = false;
            VectorSessionStateContainer.DetailedCollectionTabDisabled = false;
            VectorSessionStateContainer.SelectedVectorTab = (int)VectorTabs.DetailedCollectionsTab;
        }

        #endregion Add and Edit Methods

        #region Copy Method

        protected async Task OnCollectionCopyClick(USP_VCTS_VECT_GetDetailResponseModel item)
        {
            if (item != null)
            {
                VectorSessionStateContainer.DetailedCollectionIdfVector = item.idfVector;

                var dialogResult = await DiagService.OpenAsync<DetailedCollectionCopy>(
                    @Localizer.GetString(HeadingResourceKeyConstants.VectorDetailedCollectionCopyDetailedCollectionRecordModalHeading),
                        null,
                        new DialogOptions() { Width = "700px", Resizable = true, Draggable = false });

                if (dialogResult is List<APIPostResponseModel> response)
                {
                    if (response is { Count: > 0 })
                    {
                        if (response.First().ReturnCode == 0)
                        {
                            // force a reload
                            VectorSessionStateContainer.DetailedCollectionList = null;
                            await Grid.Reload();
                        }
                    }
                    else
                    {
                        VectorSessionStateContainer.DetailedCollectionList = null;
                        await Grid.Reload();
                    }
                }
                else
                {
                    VectorSessionStateContainer.DetailedCollectionList = null;
                    await Grid.Reload();
                }
            }
        }

        #endregion Copy Method

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            return await Task.FromResult(true);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}