using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
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
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Extensions;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class FarmInventoryBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<FarmInventoryBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        public bool IsLoading { get; set; }
        public bool AvianReportTypeIndicator { get; set; }
        public string SectionHeadingResourceKey { get; set; }
        public string AddFlockOrHerdButtonResourceKey { get; set; }
        public string DetailsHeadingResourceKey { get; set; }
        public string SpeciesColumnHeadingResourceKey { get; set; }
        public string TotalColumnHeadingResourceKey { get; set; }
        protected List<BaseReferenceViewModel> FarmSpeciesTypes { get; set; }

        #endregion Properties

        #region Member Variables

        protected RadzenDataGrid<FarmInventoryGetListViewModel> FarmInventoryGrid;
        protected List<FarmInventoryGetListViewModel> SelectedFarmInventory;
        protected int Count;
        protected int FarmInventoryNewRecordsCount;
        protected bool DisableDeleteButton;
        protected bool DisableAddButton;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "RecordID";

        #endregion Constants

        #endregion Globals

        #region Methods

        #region Lifecycle Events

        /// <summary>
        ///
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            DisableDeleteButton = !StateContainer.ActiveSurveillanceSessionPermissions.Write;
            DisableAddButton = !StateContainer.ActiveSurveillanceSessionPermissions.Write;

            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers.
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            StateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
        }

        private async Task OnStateContainerChangeAsync(string property)
        {
            switch (property)
            {
                case "SelectedFarmID":
                    await FarmInventoryGrid.Reload();
                    break;

                case "ReportTypeID":
                    if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                    {
                        AvianReportTypeIndicator = true;
                        SectionHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionDetailedInformationFarmFlockSpeciesDetailsHeading);
                        AddFlockOrHerdButtonResourceKey = Localizer.GetString(ButtonResourceKeyConstants.VeterinarySessionDetailedInformationAddFlockButtonText);
                        DetailsHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionDetailedInformationFarmFlockSpeciesDetailsHeading);
                        SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants.VeterinarySessionDetailedInformationSpeciesColumnHeading);
                        TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants.VeterinarySessionDetailedInformationTotalColumnHeading);
                    }
                    else
                    {
                        SectionHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionDetailedInformationFarmHerdSpeciesDetailsHeading);
                        AddFlockOrHerdButtonResourceKey = Localizer.GetString(ButtonResourceKeyConstants.VeterinarySessionDetailedInformationAddHerdButtonText);
                        DetailsHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionDetailedInformationFarmHerdSpeciesDetailsHeading);
                        SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants.VeterinarySessionDetailedInformationSpeciesColumnHeading);
                        TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants.VeterinarySessionDetailedInformationTotalColumnHeading);
                    }
                    await InvokeAsync(StateHasChanged);
                    break;
            }
        }

        #endregion Lifecycle Events

        #region Data Grid Events

        /// <summary>
        ///
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadFarmInventoryData(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.SelectedFarmMasterID != null)
                {
                    StateContainer.FarmInventory ??= new List<FarmInventoryGetListViewModel>();

                    if (StateContainer.FarmInventory.All(x => x.FarmMasterID != StateContainer.SelectedFarmMasterID))
                    {
                        IsLoading = true;

                        if (IsLoading)
                        {
                            var request = new FarmInventoryGetListRequestModel()
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = int.MaxValue - 1,
                                SortColumn = "RecordID",
                                SortOrder = SortConstants.Ascending,
                            };

                            // farm inventory is not contained in current inventory
                            if (StateContainer.FarmInventory.All(x => x.FarmMasterID != StateContainer.SelectedFarmMasterID))
                            {
                                request.FarmMasterID = StateContainer.SelectedFarmMasterID;
                                request.MonitoringSessionID = null;
                                request.FarmID = StateContainer.Farms.FirstOrDefault(x => x.FarmMasterID == StateContainer.SelectedFarmMasterID
                                                        && x.FarmID.GetValueOrDefault() > 0)?.FarmID;
                            }
                            // get all inventory for this vet surveillance session
                            else
                            {
                                request.FarmMasterID = null;
                                request.MonitoringSessionID = StateContainer.SessionKey;
                                request.FarmID = null;
                            }

                            var farmInventory = await VeterinaryClient.GetFarmInventoryList(request, _token);
                            if (StateContainer.FarmInventory.All(x => x.FarmMasterID != StateContainer.SelectedFarmMasterID))
                                StateContainer.FarmInventory.AddRange(farmInventory);

                            SelectedFarmInventory = StateContainer.FarmInventory
                                .Where(x => x.FarmMasterID == StateContainer.SelectedFarmMasterID).ToList();
                            Count = !SelectedFarmInventory.Any() ? 0 : StateContainer.FarmInventory.Count(x => x.FarmMasterID == StateContainer.SelectedFarmMasterID);
                        }
                    }
                    else
                    {
                        SelectedFarmInventory = StateContainer.FarmInventory
                            .Where(x => x.FarmMasterID == StateContainer.SelectedFarmMasterID).ToList();
                        Count = !StateContainer.FarmInventory.Any() ? 0 : StateContainer.FarmInventory.Count(x => x.FarmMasterID == StateContainer.SelectedFarmMasterID);
                    }

                    RollUpFarmInventory(SelectedFarmInventory);

                    IsLoading = false;
                }
                else
                {
                    SelectedFarmInventory = new List<FarmInventoryGetListViewModel>();
                    Count = 0;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Data Grid Events

        #region Load Data Methods

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected void GetFarmInventorySpeciesTypes()
        {
            try
            {
                if (FarmSpeciesTypes is not null) return;
                if (StateContainer.DiseaseSpeciesSamples is not { Count: > 0 }) return;
                FarmSpeciesTypes = new List<BaseReferenceViewModel>();
                var species = StateContainer.DiseaseSpeciesSamples
                                .GroupBy(x => x.SpeciesTypeID)
                                .Select(grp => grp.ToList());
                foreach (var spec in species)
                {
                    var specie = new BaseReferenceViewModel();
                    var item = spec.First();
                    specie.IdfsBaseReference = item.SpeciesTypeID.GetValueOrDefault();
                    specie.Name = item.SpeciesTypeName;
                    FarmSpeciesTypes.Add(specie);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data Methods

        #region Add Farm Inventory Event

        protected async Task AddFlockOrHerd()
        {
            try
            {
                if (await ValidateFarmInventory(StateContainer.FarmInventory))
                {
                    StateContainer.FarmInventory ??= new List<FarmInventoryGetListViewModel>();

                    var identity = (StateContainer.FarmInventory.Count + 1) * -1;
                    var herdFlock = new FarmInventoryGetListViewModel
                    {
                        RecordID = identity,
                        RecordType = RecordTypeConstants.Herd,
                        FarmMasterID = StateContainer.SelectedFarmMasterID,
                        FarmID = StateContainer.FarmDetail.FarmID,
                        FlockOrHerdID = identity,
                        FlockOrHerdMasterID = null
                    };
                    if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                        herdFlock.EIDSSFlockOrHerdID = Localizer.GetString(FieldLabelResourceKeyConstants.VeterinarySessionFlockSpeciesFlockFieldLabel) + " " + (StateContainer.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Herd && x.FarmMasterID == StateContainer.SelectedFarmMasterID) + 1).ToString();
                    else
                        herdFlock.EIDSSFlockOrHerdID = Localizer.GetString(FieldLabelResourceKeyConstants.VeterinarySessionHerdSpeciesHerdFieldLabel) + " " + (StateContainer.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Herd && x.FarmMasterID == StateContainer.SelectedFarmMasterID) + 1).ToString();

                    herdFlock.TotalAnimalQuantity = 0;
                    herdFlock.DeadAnimalQuantity = 0;
                    herdFlock.SickAnimalQuantity = 0;
                    herdFlock.RowStatus = (int)RowStatusTypeEnum.Active;
                    herdFlock.RowAction = (int)RowActionTypeEnum.Insert;

                    StateContainer.FarmInventory.Add(herdFlock);
                    TogglePendingSaveFarmInventory(herdFlock, null);

                    await FarmInventoryGrid.Reload();
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
        /// <param name="flockOrHerd"></param>
        protected async Task AddSpecies(object flockOrHerd)
        {
            try
            {
                if (flockOrHerd is FarmInventoryGetListViewModel inventory
                    && StateContainer.FarmInventory.Any(x => x.RecordType == RecordTypeConstants.Herd
                                                            && x.RowStatus == (int)RowStatusTypeEnum.Active
                                                            && x.FlockOrHerdID != null
                                                            && x.FlockOrHerdID == inventory.FlockOrHerdID))
                {
                    if (await ValidateFarmInventory(StateContainer.FarmInventory))
                    {
                        var identity = (StateContainer.FarmInventory.Count + 1) * -1;

                        var species = new FarmInventoryGetListViewModel
                        {
                            RecordID = identity,
                            RecordType = RecordTypeConstants.Species,
                            SpeciesID = identity,
                            SpeciesMasterID = null,
                            FarmMasterID = StateContainer.SelectedFarmMasterID,
                            FarmID = StateContainer.FarmDetail.FarmID,
                            FlockOrHerdMasterID = inventory.FlockOrHerdMasterID,
                            EIDSSFlockOrHerdID = inventory.EIDSSFlockOrHerdID,
                            FlockOrHerdID = inventory.FlockOrHerdID,
                            TotalAnimalQuantity = 0,
                            DeadAnimalQuantity = 0,
                            SickAnimalQuantity = 0,
                            StartOfSignsDate = null,
                            RowStatus = (int)RowStatusTypeEnum.Active,
                            RowAction = (int)RowActionTypeEnum.Insert
                        };

                        StateContainer.FarmInventory.Add(species);
                        TogglePendingSaveFarmInventory(species, null);

                        await FarmInventoryGrid.Reload();
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #region Species Drop Down Change Event

        /// <summary>
        ///
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnSpeciesTypeChange(object value)
        {
            try
            {
                if (value is FarmInventoryGetListViewModel inventory)
                {
                    if (inventory.SpeciesTypeID is null)
                    {
                        StateContainer.FarmInventory.First(x => x.RecordID == inventory.RecordID).SpeciesTypeName = null;
                        SelectedFarmInventory.First(x => x.RecordID == inventory.RecordID).SpeciesTypeName = null;
                    }
                    else
                    {
                        StateContainer.FarmInventory.First(x => x.RecordID == inventory.RecordID).SpeciesTypeName = FarmSpeciesTypes.First(x => x.IdfsBaseReference == inventory.SpeciesTypeID).Name;
                        SelectedFarmInventory.First(x => x.RecordID == inventory.RecordID).SpeciesTypeName = FarmSpeciesTypes.First(x => x.IdfsBaseReference == inventory.SpeciesTypeID).Name;

                        var result = inventory.ShallowCopy();
                        result.RowAction = (int)RowActionTypeEnum.Update;
                        result.RowStatus = (int)RowStatusTypeEnum.Active;

                        TogglePendingSaveFarmInventory(result, inventory);
                    }

                    if (await ValidateSection() == false)
                    {
                        inventory.SpeciesTypeID = null;
                        StateContainer.FarmInventory.First(x => x.RecordID == inventory.RecordID).SpeciesTypeName = null;
                        SelectedFarmInventory.First(x => x.RecordID == inventory.RecordID).SpeciesTypeName = null;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Species Drop Down Change Event

        protected async Task OnTotalAnimalQuantityChange(FarmInventoryGetListViewModel item)
        {
            var index = StateContainer.FarmInventory.IndexOf(item);
            if (index >= 0)
            {
                StateContainer.FarmInventory[index] = item;

                if (item.RecordID < 0)
                {
                    var result = StateContainer.PendingSaveFarmInventory.First(x => x.RecordID == item.RecordID);
                    TogglePendingSaveFarmInventory(item, result);
                }
                else
                {
                    var result = item.ShallowCopy();
                    result.RowAction = (int)RowActionTypeEnum.Update;
                    result.RowStatus = (int)RowStatusTypeEnum.Active;

                    TogglePendingSaveFarmInventory(result, item);
                }
            }

            await ValidateFarmInventory(StateContainer.FarmInventory);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveFarmInventory(FarmInventoryGetListViewModel record, FarmInventoryGetListViewModel originalRecord)
        {
            StateContainer.PendingSaveFarmInventory ??= new List<FarmInventoryGetListViewModel>();

            if (StateContainer.PendingSaveFarmInventory.Any(x => x.RecordID == record.RecordID))
            {
                var index = StateContainer.PendingSaveFarmInventory.IndexOf(originalRecord);
                StateContainer.PendingSaveFarmInventory[index] = record;
            }
            else
            {
                StateContainer.PendingSaveFarmInventory.Add(record);
            }
        }

        #endregion Add Farm Inventory Event

        #region Delete Farm Inventory

        /// <summary>
        ///
        /// </summary>
        /// <param name="farmInventory"></param>
        protected async Task DeleteFarmInventory(object farmInventory)
        {
            try
            {
                var inventory = farmInventory as FarmInventoryGetListViewModel;
                var showError = false;

                // just a species delete
                if (inventory is { RecordType: RecordTypeConstants.Species })
                {
                    if (StateContainer.AnimalSamples != null && StateContainer.AnimalSamples.Any(x => x.SpeciesTypeID == inventory.SpeciesTypeID
                                                                                                    && x.SpeciesID == inventory.SpeciesID))
                    {
                        showError = true;
                    }
                    else
                    {
                        if (inventory.RecordID < 0)
                        {
                            StateContainer.FarmInventory.Remove(inventory);
                            StateContainer.PendingSaveFarmInventory.Remove(inventory);
                            FarmInventoryNewRecordsCount--;
                        }
                        else
                        {
                            var result = inventory.ShallowCopy();
                            result.RowAction = (int)RowActionTypeEnum.Delete;
                            result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                            StateContainer.FarmInventory.Remove(inventory);
                            Count--;

                            TogglePendingSaveFarmInventory(result, inventory);
                        }
                    }
                }
                // an entire herd or flock delete
                else
                {
                    if (inventory != null)
                    {
                        var speciesHerdGroup = StateContainer.FarmInventory.Where(x => x.FlockOrHerdID == inventory.FlockOrHerdID).ToList();
                        var species = speciesHerdGroup.Where(x => x.FlockOrHerdID == inventory.FlockOrHerdID && x.RecordType == RecordTypeConstants.Species).ToList();
                        var index = 0;
                        while (index < species.Count)
                        {
                            var item = species[index];
                            var hasSamples = StateContainer.AnimalSamples != null && StateContainer.AnimalSamples.Any(x => x.SpeciesTypeID == item.SpeciesTypeID);
                            if (hasSamples)
                            {
                                showError = true;
                            }

                            index++;
                        }

                        if (!showError)
                        {
                            foreach (var record in speciesHerdGroup)
                            {
                                // new item
                                if (record.RecordID < 0)
                                {
                                    StateContainer.FarmInventory.Remove(record);
                                    StateContainer.PendingSaveFarmInventory.Remove(record);
                                    FarmInventoryNewRecordsCount--;
                                }
                                else
                                {
                                    var result = record.ShallowCopy();
                                    result.RowAction = (int)RowActionTypeEnum.Delete;
                                    result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                    StateContainer.FarmInventory.Remove(record);
                                    Count--;

                                    TogglePendingSaveFarmInventory(result, record);
                                }
                            }
                        }
                    }
                }

                if (showError)
                {
                    await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage, null);
                }

                await FarmInventoryGrid.Reload();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Delete Farm Inventory

        #region Validation Methods

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        [JSInvokable()]
        public async Task<bool> ValidateSection()
        {
            bool validIndicator = await ValidateFarmInventory(StateContainer.FarmInventory);

            return validIndicator;
        }

        #endregion Validation Methods

        #endregion Methods
    }
}