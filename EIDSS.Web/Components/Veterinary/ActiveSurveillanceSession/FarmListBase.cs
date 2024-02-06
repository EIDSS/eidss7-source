using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Veterinary.Farm;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class FarmListBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationToken _token;
        private CancellationTokenSource _source;

        #endregion Member Variables

        #region Properties

        protected RadzenDataGrid<FarmViewModel> FarmListGrid { get; set; }
        protected int FarmCount { get; set; }
        protected bool IsLoading { get; set; }
        private int FarmDatabaseQueryCount { get; set; }
        private int FarmNewRecordCount { get; set; }
        private int FarmLastDatabasePage { get; set; }
        private int FarmLastPage { get; set; } = 1;
        private int PreviousPageSize { get; set; }

        #endregion Properties

        #region Constants

        private const string DefaultSortColumn = "EIDSSFarmID";

        #endregion Constants

        #endregion Globals

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            // select the first farm in the list if none are selected
            //if (StateContainer.Farms is { Count: > 0 } && !FarmSelected)
            //{
            //    await SelectFarmAsync(StateContainer.Farms.First());
            //}

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        protected async Task LoadFarms(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (FarmListGrid.PageSize != 0)
                    pageSize = FarmListGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.Farms is null ||
                        FarmLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
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

                        var request = new FarmSearchRequestModel()
                        {
                            MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                            SortColumn = sortColumn,
                            SortOrder = sortOrder,
                            Page = page,
                            PageSize = pageSize,
                            LanguageId = GetCurrentLanguage()
                        };
                        StateContainer.Farms =
                            await VeterinaryClient.GetFarmListAsync(request, _token).ConfigureAwait(false);
                        if (page == 1)
                            FarmDatabaseQueryCount = !StateContainer.Farms.Any()
                                ? 0
                                : StateContainer.Farms.First().RecordCount.GetValueOrDefault();
                    }
                    else if (StateContainer.Farms is { Count: > 0 })
                    {
                        FarmDatabaseQueryCount = StateContainer.Farms.All(x =>
                            x.RowStatus == (int)RowStatusTypeEnum.Inactive || x.FarmID < 0)
                            ? 0
                            : StateContainer.Farms.First(x => x.FarmID > 0).RecordCount.GetValueOrDefault();
                    }

                    if (StateContainer.Farms != null)
                        for (var index = 0; index < StateContainer.Farms.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.Farms[index].FarmID < 0)
                            {
                                StateContainer.Farms.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveFarms == null || index < 0 ||
                                StateContainer.Farms.Count == 0 ||
                                StateContainer.PendingSaveFarms.All(x =>
                                    x.FarmID != StateContainer.Farms[index].FarmID)) continue;
                            {
                                if (StateContainer.PendingSaveFarms
                                        .First(x => x.FarmID == StateContainer.Farms[index].FarmID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.Farms.RemoveAt(index);
                                    FarmDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.Farms[index] = StateContainer.PendingSaveFarms.First(x =>
                                        x.FarmID == StateContainer.Farms[index].FarmID);
                                }
                            }
                        }

                    FarmCount = FarmDatabaseQueryCount + FarmNewRecordCount;

                    if (FarmNewRecordCount > 0)
                    {
                        FarmLastDatabasePage =
                            Math.DivRem(FarmDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || FarmLastDatabasePage == 0)
                            FarmLastDatabasePage += 1;

                        if (page >= FarmLastDatabasePage && StateContainer.PendingSaveFarms != null &&
                            StateContainer.PendingSaveFarms.Any(x => x.FarmID < 0))
                        {
                            var newRecordsPendingSave =
                                StateContainer.PendingSaveFarms.Where(x => x.FarmID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - FarmLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(FarmCount, pageSize, out var remainderNewRecords);

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
                                remainderDatabaseQuery = 1;
                                pageSize = remainderNewRecords;
                                StateContainer.Farms?.Clear();
                            }
                            else
                            {
                                StateContainer.Farms?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.Farms?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (StateContainer.Farms != null)
                            StateContainer.Farms = StateContainer.Farms.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    FarmLastPage = page;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsLoading = false;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveFarms(FarmViewModel record, FarmViewModel originalRecord)
        {
            StateContainer.PendingSaveFarms ??= new List<FarmViewModel>();

            if (StateContainer.PendingSaveFarms.Any(x => x.FarmMasterID == record.FarmMasterID))
            {
                var index = StateContainer.PendingSaveFarms.IndexOf(originalRecord);
                StateContainer.PendingSaveFarms[index] = record;
            }
            else
            {
                StateContainer.PendingSaveFarms.Add(record);
            }
        }

        protected async Task SearchFarmAsync()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchFarm.SearchFarm>(@Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionDetailedInformationSearchFarmHeading),
                    new Dictionary<string, object>()
                    {
                        { "Mode", SearchModeEnum.SelectNoRedirect }
                    },
                     options: new DialogOptions()
                     {
                         ShowTitle = true,
                         //MJK - Height is set globally for dialogs
                         //Height = CSSClassConstants.LargeDialogHeight,
                         Width = CSSClassConstants.LargeDialogWidth,
                         AutoFocusFirstElement = true,
                         CloseDialogOnOverlayClick = true,
                         Draggable = false,
                         Resizable = true,
                         ShowClose = true
                     });

                switch (result)
                {
                    case FarmViewModel farm:
                        {
                            bool isValidFarm = false;
                            FarmViewModel objFarm = (FarmViewModel)result;
                            if (
                                (objFarm.CountryID != null && StateContainer.LocationModel.AdminLevel0Value != null 
                                    && objFarm.CountryID.Value != StateContainer.LocationModel.AdminLevel0Value.Value) ||
                                (objFarm.RegionID != null && StateContainer.LocationModel.AdminLevel1Value != null 
                                    && objFarm.RegionID.Value != StateContainer.LocationModel.AdminLevel1Value.Value) ||
                                (objFarm.RayonID != null && StateContainer.LocationModel.AdminLevel2Value != null 
                                    && objFarm.RayonID.Value != StateContainer.LocationModel.AdminLevel2Value.Value) ||
                                (objFarm.SettlementID != null && StateContainer.LocationModel.AdminLevel3Value != null 
                                    && objFarm.SettlementID.Value != StateContainer.LocationModel.AdminLevel3Value.Value)
                            )
                            {
                                var farmModelResult = await ShowWarningDialog(MessageResourceKeyConstants.CreateVeterinaryCaseTheFarmAddressDoesNotMatchTheSessionLocationDoYouWantToContinueMessage, null);
                                if (farmModelResult is DialogReturnResult returnResult)
                                {
                                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                                    {
                                        isValidFarm = true;
                                    }
                                }
                            }
                            else
                            {
                                isValidFarm = true;
                            }
                            if (isValidFarm)
                            {
                                StateContainer.Farms ??= new List<FarmViewModel>();
                                if (StateContainer.Farms.All(x => x.FarmMasterID != farm.FarmMasterID))
                                {
                                    FarmNewRecordCount += 1;
                                    farm.RowAction = (int)RowActionTypeEnum.Insert;
                                    farm.RowStatus = (int)RowStatusTypeEnum.Active;
                                    farm.FarmID = (StateContainer.Farms.Count + 1) * -1;
                                    TogglePendingSaveFarms(farm, null);

                                    await FarmListGrid.Reload().ConfigureAwait(false);
                                    await InvokeAsync(StateHasChanged);
                                }
                                else
                                {
                                    await ShowDuplicateFarmWarning().ConfigureAwait(false);
                                }
                            }
                            break;
                        }
                    case string when result == "Cancelled":
                        _source?.Cancel();
                        break;

                    case string when result == "Add":

                        var addFarmResult = await DiagService.OpenAsync<FarmSections>(
                    Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalFarmHeading),
                    new Dictionary<string, object>()
                        {
                            {
                                "ReturnButtonResourceString",
                                Localizer.GetString(ButtonResourceKeyConstants
                                    .VeterinarySessionReturnToActiveSurveillanceSessionText)
                            },
                            { "Mode", SearchModeEnum.SelectNoRedirect },
                            { "ShowInDialog", true }
                        },
                        new DialogOptions
                        {
                            Style = LaboratoryModuleCSSClassConstants.AddFarmDialog,
                            AutoFocusFirstElement = true,
                            //Height = CSSClassConstants.LargeDialogHeight,
                            Width = CSSClassConstants.LargeDialogWidth,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true    
                        });

                        switch (addFarmResult)
                        {
                            case long farmId:
                                var request = new FarmMasterSearchRequestModel()
                                {
                                    LanguageId = GetCurrentLanguage(),
                                    FarmMasterID = farmId,
                                    SortOrder = "desc",
                                    SortColumn = "EIDSSFarmID"
                                };
                                var farmMasterList = await VeterinaryClient.GetFarmMasterListAsync(request, _token);
                                if (farmMasterList != null)
                                {
                                    var farm = farmMasterList.First();
                                    StateContainer.Farms ??= new List<FarmViewModel>();
                                    FarmNewRecordCount += 1;
                                    farm.RowAction = (int)RowActionTypeEnum.Insert;
                                    farm.RowStatus = (int)RowStatusTypeEnum.Active;
                                    farm.FarmID ??= (StateContainer.Farms.Count + 1) * -1;

                                    TogglePendingSaveFarms(farm, null);
                                }

                                await FarmListGrid.Reload();

                                break;

                            case string when result == "Cancelled":
                                _source?.Cancel();
                                break;

                            case null:
                                DiagService.Close();
                                break;
                        }
                        break;

                    default:
                        DiagService.Close();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task DeleteFarm(FarmViewModel farm)
        {
            try
            {
                // has samples so do not allow delete
                if (StateContainer.AnimalSamples != null && StateContainer.AnimalSamples.Any(a => a.FarmMasterID == farm.FarmMasterID))
                {
                    var result = await ShowInformationalDialog(MessageResourceKeyConstants.UnableToDeleteBecauseOfChildRecordsMessage, null);
                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                        {
                            DiagService.Close(result);
                        }
                    }
                }
                else
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (StateContainer.Farms.Any(x => x.FarmMasterID == farm.FarmMasterID))
                            {
                                if (farm.FarmID <= 0)
                                {
                                    StateContainer.Farms.Remove(farm);
                                    StateContainer.PendingSaveFarms.Remove(farm);
                                    FarmNewRecordCount--;
                                }
                                else
                                {
                                    result = farm.ShallowCopy();
                                    result.RowAction = (int)RowActionTypeEnum.Delete;
                                    result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                    StateContainer.Farms.Remove(farm);
                                    FarmCount--;

                                    TogglePendingSaveFarms(result, farm);
                                }

                                // clear farm details if this is the currently selected farm
                                ClearFarmDetails(farm);
                            }

                            StateContainer.NotifyStateChanged("Farms");
                            await FarmListGrid.Reload();

                            DiagService.Close(result);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private void ClearFarmDetails(FarmViewModel farm)
        {
            if (farm.FarmMasterID != StateContainer.SelectedFarmMasterID) return;

            StateContainer.FarmDetail = new FarmMasterGetDetailViewModel();
            StateContainer.FarmLocationModel.AdminLevel0Value = null;
            StateContainer.FarmLocationModel.AdminLevel1Value = null;
            StateContainer.FarmLocationModel.AdminLevel2Value = null;
            StateContainer.FarmLocationModel.AdminLevel3Value = null;
            StateContainer.FarmLocationModel.Settlement = null;
            StateContainer.FarmLocationModel.StreetText = null;
            StateContainer.FarmLocationModel.PostalCodeText = null;
            StateContainer.FarmLocationModel.House = null;
            StateContainer.FarmLocationModel.Apartment = null;
            StateContainer.FarmLocationModel.Latitude = null;
            StateContainer.FarmLocationModel.Longitude = null;

            StateContainer.SelectedFarmMasterID = null;
            StateContainer.NotifyStateChanged("SelectedFarmID");
        }

        /// <summary>
        /// Get the farm from either the tlbFarms table if one exists
        /// for this monitoring session or from the tlbFarmsActual table
        /// if one does not exist.
        /// </summary>
        /// <param name="farm">Selected farm from grid</param>
        /// <returns></returns>
        protected async Task SelectFarmAsync(FarmViewModel farm)
        {
            FarmMasterGetDetailViewModel farmDetail = null;
            if (farm.FarmID is > 0)
            {
                var farmRequest = new FarmGetListDetailRequestModel()
                {
                    FarmID = farm.FarmID.GetValueOrDefault(),
                    LanguageID = GetCurrentLanguage(),
                };
                var farmsFound = await VeterinaryClient.GetFarmDetail(farmRequest);
                if (farmsFound is { Count: > 0 })
                {
                    var foundFarm = farmsFound.First();
                    farmDetail = new FarmMasterGetDetailViewModel
                    {
                        FarmID = foundFarm.FarmID.GetValueOrDefault(),
                        FarmMasterID = foundFarm.FarmMasterID,
                        AddressString = foundFarm.FarmAddress,
                        FarmTypeID = foundFarm.FarmTypeID,
                        EIDSSFarmID = foundFarm.EIDSSFarmID,
                        EIDSSFarmOwnerID = foundFarm.EIDSSFarmOwnerID,
                        EIDSSPersonID = foundFarm.EIDSSPersonID,
                        FarmOwnerID = foundFarm.FarmOwnerID,
                        FarmOwnerName = foundFarm.FarmOwnerName,
                        FarmOwnerFirstName = foundFarm.FarmOwnerFirstName,
                        FarmOwnerLastName = foundFarm.FarmOwnerLastName,
                        FarmAddressAdministrativeLevel0ID = foundFarm.FarmAddressidfsCountry,
                        FarmAddressAdministrativeLevel1ID = foundFarm.FarmAddressidfsRegion,
                        FarmAddressAdministrativeLevel2ID = foundFarm.FarmAddressidfsRayon,
                        FarmAddressAdministrativeLevel3ID = foundFarm.FarmAddressidfsSettlement,
                        FarmAddressAdministrativeLevel1Name = foundFarm.RegionName,
                        FarmAddressAdministrativeLevel2Name = foundFarm.RayonName,
                        FarmAddressAdministrativeLevel3Name = foundFarm.SettlementName,
                        FarmAddressID = foundFarm.FarmAddressID,
                        FarmAddressApartment = foundFarm.FarmAddressstrApartment,
                        FarmAddressBuilding = foundFarm.FarmAddressstrBuilding,
                        FarmAddressHouse = foundFarm.FarmAddressstrHouse,
                        FarmAddressLatitude = foundFarm.FarmAddressstrLatitude,
                        FarmAddressLongitude = foundFarm.FarmAddressstrLongitude,
                        FarmAddressPostalCode = foundFarm.FarmAddressstrPostalCode,
                        FarmAddressSettlementID = foundFarm.FarmAddressidfsSettlement,
                        FarmAddressStreetName = foundFarm.FarmAddressstrStreetName
                    };
                }
            }
            else
            {
                var request = new FarmMasterGetDetailRequestModel()
                {
                    FarmMasterID = farm.FarmMasterID.GetValueOrDefault(),
                    LanguageID = GetCurrentLanguage()
                };
                var farmMastersFound = await VeterinaryClient.GetFarmMasterDetail(request);
                if (farmMastersFound is { Count: > 0 })
                {
                    farmDetail = farmMastersFound.First();
                }
            }

            if (farmDetail != null)
            {
                StateContainer.FarmDetail = farmDetail;
                StateContainer.FarmLocationModel.AdminLevel0Value = farmDetail.FarmAddressAdministrativeLevel0ID;
                StateContainer.FarmLocationModel.AdminLevel1Value = farmDetail.FarmAddressAdministrativeLevel1ID;
                StateContainer.FarmLocationModel.AdminLevel2Value = farmDetail.FarmAddressAdministrativeLevel2ID;
                StateContainer.FarmLocationModel.AdminLevel3Value = farmDetail.FarmAddressAdministrativeLevel3ID;
                StateContainer.FarmLocationModel.Settlement = farmDetail.FarmAddressSettlementID;
                StateContainer.FarmLocationModel.StreetText = farmDetail.FarmAddressStreetName;
                StateContainer.FarmLocationModel.PostalCodeText = farmDetail.FarmAddressPostalCode;
                StateContainer.FarmLocationModel.House = farmDetail.FarmAddressHouse;
                StateContainer.FarmLocationModel.Apartment = farmDetail.FarmAddressApartment;
                StateContainer.FarmLocationModel.Latitude = farmDetail.FarmAddressLatitude;
                StateContainer.FarmLocationModel.Longitude = farmDetail.FarmAddressLongitude;
                StateContainer.SelectedFarmMasterID = farmDetail.FarmMasterID;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Methods
    }
}