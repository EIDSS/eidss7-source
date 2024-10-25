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
using EIDSS.Web.Components.CrossCutting;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class FarmListAggregateBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<FarmListAggregateBase> Logger { get; set; }

        #endregion Dependencies

        #region Properties

        protected RadzenDataGrid<FarmViewModel> FarmListAggregateGrid { get; set; }
        protected int FarmCountAggregate { get; set; }
        protected bool IsLoading { get; set; }
        private int FarmDatabaseQueryCount { get; set; }
        private int FarmNewRecordCount { get; set; }
        private int FarmLastDatabasePage { get; set; }
        private int FarmLastPage { get; set; } = 1;
        private int PreviousPageSize { get; set; }

        #endregion Properties

        #region Member Variables

        private CancellationToken _token;
        private CancellationTokenSource _source;

        #endregion Member Variables

        #region Constants

        private const string DefaultSortColumn = "EIDSSFarmID";

        #endregion Constants

        #endregion Globals

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        protected async Task LoadAggregateFarms(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (FarmListAggregateGrid.PageSize != 0)
                    pageSize = FarmListAggregateGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.FarmsAggregate is null ||
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

                        var aggregateRequest = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel()
                        {
                            MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                            LanguageID = GetCurrentLanguage()
                        };
                        StateContainer.AggregateRecords ??= new List<VeterinaryActiveSurveillanceSessionAggregateViewModel>();

                        StateContainer.AggregateRecords = await VeterinaryClient.GetActiveSurveillanceSessionAggregateInfoListAsync(aggregateRequest, _token);

                        if (StateContainer.AggregateRecords != null)
                        {
                            StateContainer.FarmsAggregate ??= new List<FarmViewModel>();

                            // pluck the farm records from the session summary table
                            //  (records that are not sample records)
                            foreach (var record in StateContainer.AggregateRecords)//.Where(x => x.SpeciesID == null))
                            {
                                var request = new FarmSearchRequestModel()
                                {
                                    FarmID = record.FarmID,
                                    SortColumn = sortColumn,
                                    SortOrder = sortOrder,
                                    Page = page,
                                    PageSize = pageSize,
                                    LanguageId = GetCurrentLanguage()
                                };
                                var farmResult = await VeterinaryClient.GetFarmListAsync(request, _token);
                                if (farmResult == null || !farmResult.Any()) continue;
                                var farm = farmResult.First();
                                farm.MonitoringSessionSummaryID = record.MonitoringSessionSummaryID;
                                if (!StateContainer.FarmsAggregate.Any(x => x.EIDSSFarmID == farm.EIDSSFarmID))
                                    StateContainer.FarmsAggregate.Add(farm);
                            }
                        }
                        else
                        {
                            StateContainer.FarmsAggregate ??= new List<FarmViewModel>();
                        }

                        if (page == 1 && StateContainer.FarmsAggregate is { Count: > 0 })
                        {
                            FarmDatabaseQueryCount = StateContainer.FarmsAggregate.First().RecordCount ?? 0;
                        }
                        else
                        {
                            FarmDatabaseQueryCount = 0;
                        }
                        StateContainer.AggregateRecords = StateContainer.AggregateRecords.Where(x => x.RowStatus == 0).ToList();

                    }
                    else if (StateContainer.FarmsAggregate is { Count: > 0 })
                    {
                        FarmDatabaseQueryCount = StateContainer.FarmsAggregate.All(x =>
                            x.RowStatus == (int)RowStatusTypeEnum.Inactive || x.FarmID < 0)
                            ? 0
                            : StateContainer.FarmsAggregate.First(x => x.FarmID > 0).RecordCount.GetValueOrDefault();
                    }
                    else
                    {
                        StateContainer.FarmsAggregate ??= new List<FarmViewModel>();
                        FarmDatabaseQueryCount = 0;
                    }

                    if (StateContainer.FarmsAggregate != null)
                        for (var index = 0; index < StateContainer.FarmsAggregate.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.FarmsAggregate[index].FarmID < 0)
                            {
                                StateContainer.FarmsAggregate.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveFarmsAggregate == null || index < 0 || StateContainer.FarmsAggregate.Count == 0 ||
                                StateContainer.PendingSaveFarmsAggregate.All(x =>
                                    x.FarmID != StateContainer.FarmsAggregate[index].FarmID)) continue;
                            {
                                if (StateContainer.PendingSaveFarmsAggregate
                                        .First(x => x.FarmID == StateContainer.FarmsAggregate[index].FarmID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.FarmsAggregate.RemoveAt(index);
                                    FarmDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.FarmsAggregate[index] = StateContainer.PendingSaveFarmsAggregate.First(x =>
                                        x.FarmID == StateContainer.FarmsAggregate[index].FarmID);
                                }
                            }
                        }

                    FarmCountAggregate = FarmDatabaseQueryCount + FarmNewRecordCount;

                    if (FarmNewRecordCount > 0)
                    {
                        FarmLastDatabasePage = Math.DivRem(FarmDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || FarmLastDatabasePage == 0)
                            FarmLastDatabasePage += 1;

                        if (page >= FarmLastDatabasePage && StateContainer.PendingSaveFarmsAggregate != null &&
                            StateContainer.PendingSaveFarmsAggregate.Any(x => x.FarmID < 0))
                        {
                            var newRecordsPendingSave =
                               StateContainer.PendingSaveFarmsAggregate.Where(x => x.FarmID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - FarmLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(FarmCountAggregate, pageSize, out var remainderNewRecords);

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
                                StateContainer.FarmsAggregate?.Clear();
                            }
                            else
                            {
                                StateContainer.FarmsAggregate?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.FarmsAggregate?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (StateContainer.FarmsAggregate != null)
                            StateContainer.FarmsAggregate = StateContainer.FarmsAggregate.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    FarmLastPage = page;
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
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveFarmsAggregate(FarmViewModel record, FarmViewModel originalRecord)
        {
            StateContainer.PendingSaveFarmsAggregate ??= new List<FarmViewModel>();

            if (StateContainer.PendingSaveFarmsAggregate.Any(x => x.FarmMasterID == record.FarmMasterID))
            {
                var index = StateContainer.PendingSaveFarmsAggregate.IndexOf(originalRecord);
                StateContainer.PendingSaveFarmsAggregate[index] = record;
            }
            else
            {
                StateContainer.PendingSaveFarmsAggregate.Add(record);
            }
        }

        protected async Task SearchFarmAsync()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchFarm.SearchFarm>(@Localizer.GetString(HeadingResourceKeyConstants.FarmPageHeading),
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
                        StateContainer.FarmsAggregate ??= new List<FarmViewModel>();
                        if (StateContainer.FarmsAggregate.All(x => x.FarmMasterID != farm.FarmMasterID))
                        {
                            FarmNewRecordCount += 1;
                            farm.RowAction = (int)RowActionTypeEnum.Insert;
                            farm.RowStatus = (int)RowStatusTypeEnum.Active;
                            farm.FarmID = (StateContainer.FarmsAggregate.Count + 1) * -1;
                            TogglePendingSaveFarmsAggregate(farm, null);

                            await FarmListAggregateGrid.Reload().ConfigureAwait(false);
                            await InvokeAsync(StateHasChanged);
                        }
                        else
                        {
                            await ShowDuplicateFarmWarning().ConfigureAwait(false);
                        }
                        break;

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
                            //MJK - Height is set globally for dialogs
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
                                    StateContainer.FarmsAggregate ??= new List<FarmViewModel>();
                                    FarmNewRecordCount += 1;
                                    farm.RowAction = (int)RowActionTypeEnum.Insert;
                                    farm.RowStatus = (int)RowStatusTypeEnum.Active;
                                    farm.FarmID ??= (StateContainer.FarmsAggregate.Count + 1) * -1;

                                    TogglePendingSaveFarmsAggregate(farm, null);
                                }

                                await FarmListAggregateGrid.Reload();

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

        protected async Task DeleteAggregateFarm(FarmViewModel farm)
        {
            try
            {
                // has samples so do not allow delete
                if (StateContainer.AnimalSamplesAggregate != null && StateContainer.AnimalSamplesAggregate.Any(a => a.FarmMasterID == farm.FarmMasterID))
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
                            if (StateContainer.FarmsAggregate.Any(x => x.FarmMasterID == farm.FarmMasterID))
                            {
                                if (farm.FarmID <= 0)
                                {
                                    StateContainer.FarmsAggregate.Remove(farm);
                                    StateContainer.PendingSaveFarmsAggregate.Remove(farm);
                                    FarmNewRecordCount--;
                                }
                                else
                                {
                                    result = farm.ShallowCopy();
                                    result.RowAction = (int)RowActionTypeEnum.Delete;
                                    result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                    StateContainer.FarmsAggregate.Remove(farm);
                                    FarmCountAggregate--;

                                    TogglePendingSaveFarmsAggregate(result, farm);
                                }

                                // clear farm details if this is the currently selected farm
                                ClearFarmDetails(farm);

                            }
                        }

                        StateContainer.NotifyStateChanged("FarmsAggregate");
                        await FarmListAggregateGrid.Reload();

                        DiagService.Close(result);
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
            if (farm.FarmMasterID != StateContainer.SelectedAggregateFarmMasterID) return;

            StateContainer.FarmDetailAggregate = new FarmMasterGetDetailViewModel();
            StateContainer.FarmLocationModelAggregate.AdminLevel0Value = null;
            StateContainer.FarmLocationModelAggregate.AdminLevel1Value = null;
            StateContainer.FarmLocationModelAggregate.AdminLevel2Value = null;
            StateContainer.FarmLocationModelAggregate.AdminLevel3Value = null;
            StateContainer.FarmLocationModelAggregate.Settlement = null;
            StateContainer.FarmLocationModelAggregate.StreetText = null;
            StateContainer.FarmLocationModelAggregate.PostalCodeText = null;
            StateContainer.FarmLocationModelAggregate.House = null;
            StateContainer.FarmLocationModelAggregate.Apartment = null;
            StateContainer.FarmLocationModelAggregate.Latitude = null;
            StateContainer.FarmLocationModelAggregate.Longitude = null;

            StateContainer.SelectedAggregateFarmMasterID = null;
            StateContainer.NotifyStateChanged("SelectedAggregateFarmID");
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
                StateContainer.FarmDetailAggregate = farmDetail;
                StateContainer.FarmLocationModelAggregate.AdminLevel0Value = farmDetail.FarmAddressAdministrativeLevel0ID;
                StateContainer.FarmLocationModelAggregate.AdminLevel1Value = farmDetail.FarmAddressAdministrativeLevel1ID;
                StateContainer.FarmLocationModelAggregate.AdminLevel2Value = farmDetail.FarmAddressAdministrativeLevel2ID;
                StateContainer.FarmLocationModelAggregate.AdminLevel3Value = farmDetail.FarmAddressAdministrativeLevel3ID;
                StateContainer.FarmLocationModelAggregate.Settlement = farmDetail.FarmAddressSettlementID;
                StateContainer.FarmLocationModelAggregate.StreetText = farmDetail.FarmAddressStreetName;
                StateContainer.FarmLocationModelAggregate.PostalCodeText = farmDetail.FarmAddressPostalCode;
                StateContainer.FarmLocationModelAggregate.House = farmDetail.FarmAddressHouse;
                StateContainer.FarmLocationModelAggregate.Apartment = farmDetail.FarmAddressApartment;
                StateContainer.FarmLocationModelAggregate.Latitude = farmDetail.FarmAddressLatitude;
                StateContainer.FarmLocationModelAggregate.Longitude = farmDetail.FarmAddressLongitude;

                StateContainer.SelectedAggregateFarmMasterID = farmDetail.FarmMasterID;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Methods
    }
}