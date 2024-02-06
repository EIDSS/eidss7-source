#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.ViewModels.Common;
using Radzen;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class SurveillanceSessionBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] protected VeterinaryActiveSurveillanceSessionStateContainerService StateContainer { get; set; }

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject] protected IOrganizationClient OrganizationClient { get; set; }

        [Inject] protected IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Properties

        public List<BaseReferenceViewModel> SpeciesTypes { get; set; }

        #endregion

        #region Member Variables

        protected int ReportTypesCount;

        private CancellationToken _token;
        private CancellationTokenSource _source;
        private bool _disposed;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override Task OnInitializedAsync()
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _source = new CancellationTokenSource();
            _token = _source.Token;

            return base.OnInitializedAsync();
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                // TODO: dispose managed state (managed objects).
                _source?.Cancel();
                _source?.Dispose();
            }

            // TODO: free unmanaged resources (unmanaged objects) and override a finalizer below.
            // TODO: set large fields to null.

            _disposed = true;
        }

        #endregion

        #region Common Methods

        protected async Task ShowDuplicateFarmWarning()
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
                { "DialogName", "NarrowSearch" },
                { nameof(EIDSSDialog.DialogButtons), buttons },
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DuplicateRecordsAreNotAllowedMessage)
                }
            };
            await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams);
        }

        #endregion

        #region Surveillance Session Methods

        #region Farm Details Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReport"></param>
        public LocationViewModel SetFarmLocation(DiseaseReportGetDetailViewModel diseaseReport)
        {
            diseaseReport.FarmLocation = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnabledLatitude = true,
                EnabledLongitude = true,
                EnablePostalCode = false,
                EnableSettlement = false,
                EnableSettlementType = false,
                EnableStreet = false,
                OperationType = LocationViewOperationType.Edit,
                ShowAdminLevel0 = true,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlementType = true,
                ShowStreet = true,
                ShowBuilding = true,
                ShowApartment = true,
                ShowElevation = false,
                ShowHouse = true,
                ShowLatitude = true,
                ShowLongitude = true,
                ShowMap = true,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                IsDbRequiredAdminLevel0 = true,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                AdminLevel0Value = Convert.ToInt64(CountryID)
            };

            diseaseReport.FarmLocation.AdminLevel0Value = diseaseReport.FarmAddressAdministrativeLevel0ID;
            diseaseReport.FarmLocation.AdminLevel1Value = diseaseReport.FarmAddressAdministrativeLevel1ID;
            diseaseReport.FarmLocation.AdminLevel2Value = diseaseReport.FarmAddressAdministrativeLevel2ID;
            diseaseReport.FarmLocation.AdminLevel3Value = diseaseReport.FarmAddressAdministrativeLevel3ID;
            diseaseReport.FarmLocation.SettlementType = diseaseReport.FarmAddressSettlementTypeID;
            diseaseReport.FarmLocation.SettlementText = diseaseReport.FarmAddressSettlementName;
            diseaseReport.FarmLocation.SettlementId = diseaseReport.FarmAddressSettlementID;
            diseaseReport.FarmLocation.Settlement = diseaseReport.FarmAddressSettlementID;
            diseaseReport.FarmLocation.Apartment = diseaseReport.FarmAddressApartment;
            diseaseReport.FarmLocation.Building = diseaseReport.FarmAddressBuilding;
            diseaseReport.FarmLocation.House = diseaseReport.FarmAddressHouse;
            diseaseReport.FarmLocation.Latitude = diseaseReport.FarmAddressLatitude;
            diseaseReport.FarmLocation.Longitude = diseaseReport.FarmAddressLongitude;
            diseaseReport.FarmLocation.PostalCode = diseaseReport.FarmAddressPostalCodeID;
            diseaseReport.FarmLocation.PostalCodeText = diseaseReport.FarmAddressPostalCode;
            if (diseaseReport.FarmAddressPostalCodeID != null)
            {
                diseaseReport.FarmLocation.PostalCodeList = new List<PostalCodeViewModel>
                {
                    new()
                    {
                        PostalCodeID = diseaseReport.FarmAddressPostalCodeID.ToString(),
                        PostalCodeString = diseaseReport.FarmAddressPostalCode
                    }
                };
            }

            diseaseReport.FarmLocation.StreetText = diseaseReport.FarmAddressStreetName;
            diseaseReport.FarmLocation.Street = diseaseReport.FarmAddressStreetID;
            if (diseaseReport.FarmAddressStreetID != null)
            {
                diseaseReport.FarmLocation.StreetList = new List<StreetModel>
                {
                    new()
                    {
                        StreetID = diseaseReport.FarmAddressStreetID.ToString(),
                        StreetName = diseaseReport.FarmAddressStreetName
                    }
                };
            }

            return diseaseReport.FarmLocation;
        }

        #endregion

        #region Disease Reports Section Methods

        public bool ValidateDiseaseReportsSection()
        {
            StateContainer.SessionDiseaseReportsValidIndicator = true;
            return true;
        }

        #endregion

        #region Farm Inventory Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="farmMasterId"></param>
        /// <param name="farmId"></param>
        /// <returns></returns>
        public async Task<List<FarmInventoryGetListViewModel>> GetFarmInventory(long diseaseReportId, long farmMasterId,
            long? farmId)
        {
            var request = new FarmInventoryGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                FarmID = diseaseReportId > 0 ? farmId : null, // For existing disease reports.
                FarmMasterID =
                    diseaseReportId == 0 ? farmMasterId : null, // For disease reports that have not been saved.
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "RecordID",
                SortOrder = SortConstants.Ascending
            };

            return await VeterinaryClient.GetFarmInventoryList(request, _token).ConfigureAwait(false);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <returns></returns>
        public async Task<bool> ValidateFarmInventory(List<FarmInventoryGetListViewModel> farmInventory)
        {
            try
            {
                if (farmInventory is null)
                    return true;

                var flocksOrHerds = farmInventory.Where(x => x.RecordType == RecordTypeConstants.Herd);
                var validIndicator = true;

                foreach (var flockOrHerd in flocksOrHerds)
                {
                    if (validIndicator != true) continue;
                    string message;
                    if (!farmInventory.Any(x =>
                            x.FlockOrHerdID == flockOrHerd.FlockOrHerdID &
                            x.RecordType == RecordTypeConstants.Herd))
                    {
                        validIndicator = false;
                        message = StateContainer.ReportTypeID == ASSpeciesType.Avian
                            ? Localizer.GetString(MessageResourceKeyConstants
                                .AvianDiseaseReportFarmFlockSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage)
                            : MessageResourceKeyConstants
                                .LivestockDiseaseReportFarmHerdSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage;
                        await ShowErrorDialog(message, null);
                        break;
                    }
                    else
                    {
                        var species = farmInventory.Where(x =>
                            x.RecordType == RecordTypeConstants.Species &&
                            x.FlockOrHerdID == flockOrHerd.FlockOrHerdID);

                        foreach (var speciesItem in species)
                        {
                            if (speciesItem.SpeciesTypeID is null)
                            {
                                validIndicator = false;

                                message = Localizer.GetString(StateContainer.ReportTypeID == ASSpeciesType.Avian
                                    ? MessageResourceKeyConstants
                                        .AvianDiseaseReportFarmFlockSpeciesSpeciesIsRequiredMessage
                                    : MessageResourceKeyConstants
                                        .LivestockDiseaseReportFarmHerdSpeciesSpeciesIsRequiredMessage);
                                await ShowErrorDialog(message, null);
                                break;
                            }

                            if (species.Count(x =>
                                    (x.SpeciesTypeID != null) & (x.SpeciesTypeID == speciesItem.SpeciesTypeID) &
                                    (x.FlockOrHerdID == speciesItem.FlockOrHerdID)) > 1)
                            {
                                validIndicator = false;

                                message = Localizer.GetString(StateContainer.ReportTypeID == ASSpeciesType.Avian
                                    ? MessageResourceKeyConstants
                                        .AvianDiseaseReportFarmFlockSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedFlockMessage
                                    : MessageResourceKeyConstants
                                        .LivestockDiseaseReportFarmHerdSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedHerdMessage);
                                await ShowErrorDialog(message, null);
                                break;
                            }

                            if (speciesItem.TotalAnimalQuantity < speciesItem.SickAnimalQuantity)
                            {
                                validIndicator = false;
                                message = StateContainer.ReportTypeID == ASSpeciesType.Avian
                                    ? Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesTotalNumberOfAnimalsMessage) + " " +
                                      speciesItem.TotalAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage) +
                                      " " + speciesItem.SickAnimalQuantity.ToString() + "."
                                    : Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesTotalNumberOfAnimalsMessage) + " " +
                                      speciesItem.TotalAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage) +
                                      " " + speciesItem.SickAnimalQuantity.ToString() + ".";
                                await ShowErrorDialog(message, null);
                                speciesItem.SickAnimalQuantity = 0;
                                break;
                            }
                            else if (speciesItem.TotalAnimalQuantity < speciesItem.DeadAnimalQuantity)
                            {
                                validIndicator = false;
                                message = StateContainer.ReportTypeID == ASSpeciesType.Avian
                                    ? Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesTotalNumberOfAnimalsMessage) + " " +
                                      speciesItem.TotalAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage) +
                                      " " + speciesItem.DeadAnimalQuantity.ToString() + "."
                                    : Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesTotalNumberOfAnimalsMessage) + " " +
                                      speciesItem.TotalAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage) +
                                      " " + speciesItem.DeadAnimalQuantity.ToString() + ".";
                                await ShowErrorDialog(message, null);
                                speciesItem.DeadAnimalQuantity = 0;
                                break;
                            }
                            else if (speciesItem.TotalAnimalQuantity <
                                     (speciesItem.SickAnimalQuantity + speciesItem.DeadAnimalQuantity))
                            {
                                validIndicator = false;
                                message = StateContainer.ReportTypeID == ASSpeciesType.Avian
                                    ? Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesTheSumOfDeadMessage) + " " +
                                      speciesItem.DeadAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesAndSickMessage) + " " +
                                      speciesItem.SickAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .AvianDiseaseReportFarmFlockSpeciesCantBeMoreThanTotalMessage) + " " +
                                      speciesItem.TotalAnimalQuantity.ToString() + "."
                                    : Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesTheSumOfDeadMessage) + " " +
                                      speciesItem.DeadAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesAndSickMessage) + " " +
                                      speciesItem.SickAnimalQuantity.ToString() + " " +
                                      Localizer.GetString(MessageResourceKeyConstants
                                          .LivestockDiseaseReportFarmHerdSpeciesCantBeMoreThanTotalMessage) + " " +
                                      speciesItem.TotalAnimalQuantity.ToString() + ".";
                                await ShowErrorDialog(message, null);
                                speciesItem.DeadAnimalQuantity = 0;
                                speciesItem.SickAnimalQuantity = 0;
                                break;
                            }

                            if (!(speciesItem.StartOfSignsDate > DateTime.Today)) continue;
                            validIndicator = false;

                            message = Localizer.GetString(StateContainer.ReportTypeID == ASSpeciesType.Avian
                                ? MessageResourceKeyConstants
                                    .AvianDiseaseReportFarmFlockSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage
                                : MessageResourceKeyConstants
                                    .LivestockDiseaseReportFarmHerdSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage);
                            await ShowErrorDialog(message, null);
                            speciesItem.StartOfSignsDate = null;
                            break;
                        }
                    }
                }

                RollUpFarmInventory(farmInventory);

                return validIndicator;
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
        public void RollUpFarmInventory(List<FarmInventoryGetListViewModel> farmInventory)
        {
            foreach (var herd in farmInventory.Where(x => x.RecordType == RecordTypeConstants.Herd & x.RowStatus == 0)
                         .ToList())
            {
                var intSick = 0;
                var intDead = 0;
                var intTotal = 0;

                if (herd.RecordType == HerdSpeciesConstants.Farm) continue;
                foreach (var species in farmInventory.Where(x =>
                             x.FlockOrHerdID == herd.FlockOrHerdID & x.RowStatus == 0 &
                             x.RecordType == RecordTypeConstants.Species).ToList())
                {
                    if (species.SickAnimalQuantity != null)
                        intSick += (int)species.SickAnimalQuantity;

                    if (species.DeadAnimalQuantity != null)
                        intDead += (int)species.DeadAnimalQuantity;

                    if (species.TotalAnimalQuantity != null)
                        intTotal += (int)species.TotalAnimalQuantity;
                }

                farmInventory.First(x => x.RecordID == herd.RecordID).SickAnimalQuantity = intSick;
                farmInventory.First(x => x.RecordID == herd.RecordID).DeadAnimalQuantity = intDead;
                farmInventory.First(x => x.RecordID == herd.RecordID).TotalAnimalQuantity = intTotal;
            }

            foreach (var farm in farmInventory.Where(x => x.RecordType == HerdSpeciesConstants.Farm).ToList())
            {
                farm.TotalAnimalQuantity = farmInventory
                    .Where(x => x.RecordType == HerdSpeciesConstants.Herd && x.RowStatus == 0 &&
                                x.FarmMasterID == farm.FarmMasterID).Sum(x => x.TotalAnimalQuantity);
                farm.SickAnimalQuantity = farmInventory
                    .Where(x => x.RecordType == HerdSpeciesConstants.Herd && x.RowStatus == 0 &&
                                x.FarmMasterID == farm.FarmMasterID).Sum(x => x.SickAnimalQuantity);
                farm.DeadAnimalQuantity = farmInventory
                    .Where(x => x.RecordType == HerdSpeciesConstants.Herd && x.RowStatus == 0 &&
                                x.FarmMasterID == farm.FarmMasterID).Sum(x => x.DeadAnimalQuantity);
            }
        }

        #endregion

        #region Animals Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<AnimalGetListViewModel>> GetAnimals(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new AnimalGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetAnimalList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Samples Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<SampleGetListViewModel>> GetSamples(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new SampleGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            var list = await VeterinaryClient.GetSampleList(request, _token).ConfigureAwait(false);

            for (var index = 0; index < list.Count; index++)
            {
                if (IsNullOrEmpty(list[index].EIDSSLocalOrFieldSampleID))
                    list[index].EIDSSLocalOrFieldSampleID = "(" +
                                                            Localizer.GetString(FieldLabelResourceKeyConstants
                                                                .CommonLabelsNewFieldLabel) + " " + (index + 1) + ")";
            }

            return list;
        }

        #endregion

        #region Laboratory Tests and Results Summary and Interpretations Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestGetListViewModel>> GetLaboratoryTests(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            var request = new LaboratoryTestGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetLaboratoryTestList(request, _token).ConfigureAwait(false);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestInterpretationGetListViewModel>> GetLaboratoryTestInterpretations(
            long diseaseReportId, int page, int pageSize, string sortColumn, string sortOrder)
        {
            var request = new LaboratoryTestInterpretationGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetLaboratoryTestInterpretationList(request, _token).ConfigureAwait(false);
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public bool ValidateTestsSection()
        {
            StateContainer.SessionTestsValidIndicator = true;
            return true;
        }

        #endregion

        #region Session Header Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public bool ValidateSessionHeaderSection()
        {
            StateContainer.SessionHeaderValidIndicator = true;
            return true;
        }

        #endregion

        #region Actions Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public bool ValidateActionsSection()
        {
            StateContainer.SessionActionsValidIndicator = true;
            return true;
        }

        #endregion

        #region Aggregate Info Section Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAggregateRecords(VeterinaryActiveSurveillanceSessionAggregateViewModel record,
            VeterinaryActiveSurveillanceSessionAggregateViewModel originalRecord)
        {
            StateContainer.PendingSaveAggregateRecords ??= new List<VeterinaryActiveSurveillanceSessionAggregateViewModel>();

            if (StateContainer.PendingSaveAggregateRecords.Any(x =>
                    x.MonitoringSessionSummaryID == record.MonitoringSessionSummaryID))
            {
                var index = StateContainer.PendingSaveAggregateRecords.IndexOf(originalRecord);
                StateContainer.PendingSaveAggregateRecords[index] = record;
            }
            else
            {
                StateContainer.PendingSaveAggregateRecords.Add(record);
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public bool ValidateAggregateInformationSection()
        {
            StateContainer.SessionAggregateInformationValidIndicator = true;
            return true;
        }

        #endregion

        #region Save Surveillance Session Methods

        protected async Task<VeterinaryActiveSurveillanceSessionSaveRequestResponseModel> SaveSurveillanceSession()
        {
            try
            {
                Events = new List<EventSaveRequestModel>();

                var systemPreferences = ConfigurationService.SystemPreferences;

                long? siteId = StateContainer.SiteID ?? Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                StateContainer.SiteID = siteId;

                if (StateContainer.SessionInformationValidIndicator
                    && StateContainer.SessionDetailedInformationValidIndicator
                    && StateContainer.SessionTestsValidIndicator
                    && StateContainer.SessionActionsValidIndicator
                    && StateContainer.SessionAggregateInformationValidIndicator
                    && StateContainer.SessionDiseaseReportsValidIndicator)
                {
                    bool permission;

                    if (StateContainer.SessionKey > 0)
                    {
                        if (StateContainer.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                            authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                            permission = StateContainer.ActiveSurveillanceSessionPermissions.Write;
                        else
                        {
                            var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);
                            permission = permissions.Write;
                        }
                    }
                    else
                    {
                        {
                            var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);
                            permission = permissions.Create;
                        }
                    }

                    if (permission)
                    {
                        if (StateContainer.OriginalSessionStatusTypeID == ActiveSurveillanceSessionStatusIds.Closed &&
                            StateContainer.SessionStatusTypeID == ActiveSurveillanceSessionStatusIds.Open)
                        {
                            if (StateContainer.SessionKey != null)
                                StateContainer.PendingSaveEvents.Add(await CreateEvent((long) StateContainer.SessionKey,
                                    null,
                                    SystemEventLogTypes.ClosedVeterinaryActiveSurveillanceSessionWasReopenedAtYourSite,
                                    (long) StateContainer.SiteID, null).ConfigureAwait(false));
                        }

                        foreach (var eventRecord in StateContainer.PendingSaveEvents)
                        {
                            Events.Add(eventRecord);
                        }

                        //Get lowest administrative level for location of session
                        long? locationId;
                        if (StateContainer.LocationModel.AdminLevel4Value.HasValue)
                            locationId = StateContainer.LocationModel.AdminLevel4Value.Value;
                        else if (StateContainer.LocationModel.AdminLevel3Value.HasValue)
                            locationId = StateContainer.LocationModel.AdminLevel3Value.Value;
                        else if (StateContainer.LocationModel.AdminLevel2Value.HasValue)
                            locationId = StateContainer.LocationModel.AdminLevel2Value.Value;
                        else if (StateContainer.LocationModel.AdminLevel1Value.HasValue)
                            locationId = StateContainer.LocationModel.AdminLevel1Value.Value;
                        else
                            locationId = null;

                        var request = new VeterinaryActiveSurveillanceSessionSaveRequestModel
                        {
                            MonitoringSessionID = StateContainer.SessionKey,
                            SessionID = StateContainer.SessionID,
                            SessionStartDate = StateContainer.SessionStartDate,
                            SessionEndDate = StateContainer.SessionEndDate,
                            SessionStatusTypeID = StateContainer.SessionStatusTypeID,
                            SessionCategoryID = StateContainer.ReportTypeID == ASSpeciesType.Avian
                                ? (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession
                                : (long) ReportOrSessionTypeEnum
                                    .VeterinaryLivestockActiveSurveillanceSession, //TODO - temporarily translate SessionCategoryID and ReportTypeID until AS Species Type is fully implemented
                            SiteID = siteId,
                            LegacySessionID = StateContainer.LegacySessionID,
                            CountryID = StateContainer.LocationModel.AdminLevel0Value,
                            RegionID = StateContainer.LocationModel.AdminLevel1Value,
                            RayonID = StateContainer.LocationModel.AdminLevel2Value,
                            SettlementID = StateContainer.LocationModel.AdminLevel3Value,
                            CampaignKey = StateContainer.CampaignKey,
                            CampaignID = StateContainer.CampaignID,
                            DateEntered = StateContainer.DateEntered,
                            EnteredByPersonID = StateContainer.OfficerID,
                            RowStatus = (int) RowStatusTypeEnum.Active,
                            ReportTypeID = StateContainer.ReportTypeID,
                            AuditUserName = _tokenService.GetAuthenticatedUser().UserName,
                            DiseaseSpeciesSamples = JsonConvert.SerializeObject(
                                BuildDiseaseSpecieSamplesParameters(StateContainer.PendingSaveDiseaseSpeciesSamples)),
                            Farms = JsonConvert.SerializeObject(BuildFarmParameters(StateContainer.PendingSaveFarms,
                                StateContainer.ReportTypeID)),
                            FlocksOrHerds =
                                JsonConvert.SerializeObject(
                                    BuildFlocksOrHerdsParameters(StateContainer.PendingSaveFarmInventory)),
                            Species = JsonConvert.SerializeObject(
                                BuildSpeciesParameters(StateContainer.PendingSaveFarmInventory)),
                            Animals = JsonConvert.SerializeObject(
                                BuildAnimalParameters(StateContainer.PendingSaveAnimalSamples)),
                            Samples = JsonConvert.SerializeObject(
                                BuildSampleParameters(StateContainer.PendingSaveAnimalSamples)),
                            SamplesToDiseases = JsonConvert.SerializeObject(
                                BuildSampleToDiseaseParameters(StateContainer.PendingSaveAnimalSampleToDiseases)),
                            LaboratoryTests =
                                JsonConvert.SerializeObject(
                                    await BuildLaboratoryTestParameters(StateContainer.PendingSaveTests)),
                            LaboratoryTestInterpretations = JsonConvert.SerializeObject(
                                await BuildLaboratoryTestInterpretationParameters(StateContainer
                                    .PendingSaveTestInterpretations)),
                            Actions = JsonConvert.SerializeObject(
                                BuildActionParameters(StateContainer.PendingSaveActions)),
                            AggregateSummaryInfo = JsonConvert.SerializeObject(
                                BuildAggregateSummaryInfoParameters(StateContainer.PendingSaveAnimalSamplesAggregate,
                                    StateContainer.PendingSaveFarmsAggregate)),
                            AggregateSummaryDiseases = JsonConvert.SerializeObject(
                                BuildAggregateSummaryDiseaseParameters(StateContainer
                                    .PendingSaveAnimalSamplesAggregate)),
                            FarmsAggregate = JsonConvert.SerializeObject(
                                BuildFarmParameters(StateContainer.PendingSaveFarmsAggregate,
                                    StateContainer.ReportTypeID)),
                            FlocksOrHerdsAggregate =
                                JsonConvert.SerializeObject(
                                    BuildFlocksOrHerdsParameters(StateContainer.FarmInventoryAggregate)),
                            SpeciesAggregate =
                                JsonConvert.SerializeObject(
                                    BuildSpeciesParameters(StateContainer.FarmInventoryAggregate)),
                            DiseaseReports =
                                JsonConvert.SerializeObject(
                                    BuildDiseaseReportParameters(StateContainer.DiseaseReports)),
                            Events = JsonConvert.SerializeObject(Events),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            LocationID = locationId,
                            LinkLocalOrFieldSampleIDToReportID = systemPreferences.LinkLocalSampleIdToReportSessionId
                        };

                        var response = await VeterinaryClient.SaveVeterinaryActiveSurveillanceSession(request, _token);

                        return response;
                    }
                    
                    var buttons = new List<DialogButton>();
                    var okButton = new DialogButton
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                        ButtonType = DialogButtonType.OK
                    };
                    buttons.Add(okButton);
                    var dialogParams = new Dictionary<string, object>
                    {
                        {nameof(EIDSSDialog.DialogButtons), buttons},
                        {
                            nameof(EIDSSDialog.Message),
                            Localizer.GetString(MessageResourceKeyConstants
                                .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage)
                        }
                    };
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return new VeterinaryActiveSurveillanceSessionSaveRequestResponseModel();
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        private static List<VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel> BuildFarmParameters(
            IList<FarmViewModel> farms, long? reportTypeId)
        {
            List<VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel> requests = new();

            if (farms is null)
                return new List<VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel>();

            foreach (var farm in farms)
            {
                var request = new VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel();
                {
                    request.FarmID = farm.FarmID;
                    if (farm.FarmMasterID != null) request.FarmMasterID = (long) farm.FarmMasterID;
                    request.RowAction = farm.RowAction;
                    request.RowStatus = farm.RowStatus;
                    request.TotalAnimalQuantity = reportTypeId == ASSpeciesType.Avian
                        ? farm.TotalAvianAnimalQuantity
                        : farm.TotalLivestockAnimalQuantity;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        private static List<VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel> BuildFarmParametersAggregate(
            IList<FarmGetListDetailViewModel> farms, long? reportTypeId)
        {
            List<VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel> requests = new();

            if (farms is null)
                return new List<VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel>();

            foreach (var farm in farms)
            {
                var request = new VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel();
                {
                    request.FarmID = farm.FarmID;
                    if (farm.FarmMasterID != null) request.FarmMasterID = (long)farm.FarmMasterID;
                    request.RowAction = farm.RowAction;
                    request.RowStatus = farm.RowStatus;
                    request.TotalAnimalQuantity = reportTypeId == (long)CaseTypeEnum.Avian
                        ? farm.TotalAvianAnimalQuantity
                        : farm.TotalLivestockAnimalQuantity;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <returns></returns>
        private static List<FarmInventoryGroupSaveRequestModel> BuildFlocksOrHerdsParameters(
            IList<FarmInventoryGetListViewModel> farmInventory)
        {
            List<FarmInventoryGroupSaveRequestModel> requests = new();

            if (farmInventory is null)
                return new List<FarmInventoryGroupSaveRequestModel>();
            else
                farmInventory = farmInventory.Where(x => x.RecordType == RecordTypeConstants.Herd).ToList();

            foreach (var farmInventoryModel in farmInventory)
            {
                var request = new FarmInventoryGroupSaveRequestModel();
                {
                    request.DeadAnimalQuantity = farmInventoryModel.DeadAnimalQuantity;
                    request.EIDSSFlockOrHerdID = farmInventoryModel.EIDSSFlockOrHerdID;
                    request.FarmID = farmInventoryModel.FarmID;
                    request.FarmMasterID = farmInventoryModel.FarmMasterID;
                    if (farmInventoryModel.FlockOrHerdID != null)
                        request.FlockOrHerdID = (long)farmInventoryModel.FlockOrHerdID;
                    request.FlockOrHerdMasterID = farmInventoryModel.FlockOrHerdMasterID;
                    if (farmInventoryModel.RowAction != null)
                        request.RowAction = (int)farmInventoryModel.RowAction;
                    request.RowStatus = farmInventoryModel.RowStatus;
                    request.SickAnimalQuantity = farmInventoryModel.SickAnimalQuantity;
                    request.TotalAnimalQuantity = farmInventoryModel.TotalAnimalQuantity;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <returns></returns>
        private static List<FarmInventorySpeciesSaveRequestModel> BuildSpeciesParameters(
            IList<FarmInventoryGetListViewModel> farmInventory)
        {
            List<FarmInventorySpeciesSaveRequestModel> requests = new();

            if (farmInventory is null)
                return new List<FarmInventorySpeciesSaveRequestModel>();
            else
                farmInventory = farmInventory.Where(x => x.RecordType == RecordTypeConstants.Species).ToList();

            foreach (var farmInventoryModel in farmInventory)
            {
                var request = new FarmInventorySpeciesSaveRequestModel();
                {
                    request.AverageAge = farmInventoryModel.AverageAge;
                    request.DeadAnimalQuantity = farmInventoryModel.DeadAnimalQuantity;
                    if (farmInventoryModel.FlockOrHerdID != null)
                        request.FlockOrHerdID = (long)farmInventoryModel.FlockOrHerdID;
                    request.ObservationID = farmInventoryModel.ObservationID;
                    request.RelatedToSpeciesID = null;
                    request.RelatedToObservationID = null;
                    if (farmInventoryModel.RowAction != null)
                        request.RowAction = (int)farmInventoryModel.RowAction;
                    request.RowStatus = farmInventoryModel.RowStatus;
                    request.SickAnimalQuantity = farmInventoryModel.SickAnimalQuantity;
                    if (farmInventoryModel.SpeciesID != null) request.SpeciesID = (long)farmInventoryModel.SpeciesID;
                    request.SpeciesMasterID = farmInventoryModel.SpeciesMasterID;
                    if (farmInventoryModel.SpeciesTypeID != null)
                        request.SpeciesTypeID = (long)farmInventoryModel.SpeciesTypeID;
                    request.StartOfSignsDate = farmInventoryModel.StartOfSignsDate;
                    request.TotalAnimalQuantity = farmInventoryModel.TotalAnimalQuantity;
                    request.Comments = farmInventoryModel.Note;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="animals"></param>
        /// <returns></returns>
        private List<AnimalSaveRequestModel> BuildAnimalParameters(IList<SampleGetListViewModel> animals)
        {
            List<AnimalSaveRequestModel> requests = new();

            if (animals is null)
                return new List<AnimalSaveRequestModel>();

            foreach (var animalModel in animals)
            {
                var request = new AnimalSaveRequestModel();
                {
                    request.AgeTypeID = animalModel.AnimalAgeTypeID;
                    request.AnimalDescription = null;
                    request.AnimalID = animalModel.AnimalID.GetValueOrDefault();
                    request.AnimalName = animalModel.AnimalName;
                    request.ClinicalSignsIndicator = null;
                    request.Color = animalModel.AnimalColor;
                    request.ConditionTypeID = null;
                    request.EIDSSAnimalID = animalModel.EIDSSAnimalID is null ? Empty :
                        animalModel.EIDSSAnimalID.Contains(
                            Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)) ? Empty :
                        animalModel.EIDSSAnimalID;
                    request.SexTypeID = animalModel.AnimalGenderTypeID;
                    request.ObservationID = null;
                    request.RelatedToAnimalID = animalModel.AnimalID;
                    request.RelatedToObservationID = null;
                    request.SpeciesID = animalModel.SpeciesID;
                    request.RowAction = animalModel.AnimalID > 0
                        ? (int)RowActionTypeEnum.Update
                        : (int)RowActionTypeEnum.Insert;
                    request.RowStatus = animalModel.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseSpeciesList"></param>
        /// <returns></returns>
        private static List<VeterinaryActiveSurveillanceSessionDiseaseSpecieSamplesSaveRequestModel>
            BuildDiseaseSpecieSamplesParameters(
                IList<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> diseaseSpeciesList)
        {
            List<VeterinaryActiveSurveillanceSessionDiseaseSpecieSamplesSaveRequestModel> requests = new();

            if (diseaseSpeciesList is null)
                return new List<VeterinaryActiveSurveillanceSessionDiseaseSpecieSamplesSaveRequestModel>();

            foreach (var diseaseSpecies in diseaseSpeciesList)
            {
                var request = new VeterinaryActiveSurveillanceSessionDiseaseSpecieSamplesSaveRequestModel();
                {
                    request.MonitoringSessionToDiagnosisID = diseaseSpecies.MonitoringSessionToDiseaseID;
                    request.DiseaseID = diseaseSpecies.DiseaseID.GetValueOrDefault();
                    request.SpeciesTypeID = diseaseSpecies.SpeciesTypeID;
                    request.SampleTypeID = diseaseSpecies.SampleTypeID;
                    request.RowAction = diseaseSpecies.RowAction;
                    request.RowStatus = diseaseSpecies.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="samples"></param>
        /// <returns></returns>
        private List<SampleSaveRequestModel> BuildSampleParameters(IList<SampleGetListViewModel> samples)
        {
            List<SampleSaveRequestModel> requests = new();

            if (samples is null)
                return new List<SampleSaveRequestModel>();

            foreach (var sampleModel in samples)
            {
                var request = new SampleSaveRequestModel();
                {
                    request.AnimalID = sampleModel.AnimalID;
                    request.BirdStatusTypeID = sampleModel.BirdStatusTypeID;
                    request.CurrentSiteID = sampleModel.CurrentSiteID;
                    request.DiseaseID = sampleModel.DiseaseID;
                    if (sampleModel.EIDSSLocalOrFieldSampleID != null)
                    {
                        request.EIDSSLocalOrFieldSampleID = sampleModel.EIDSSLocalOrFieldSampleID.Contains("(" +
                            Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)) ? null : sampleModel.EIDSSLocalOrFieldSampleID;
                    }
                    else
                    {
                        request.EIDSSLocalOrFieldSampleID = null;
                    }

                    request.EnteredDate = sampleModel.EnteredDate;
                    request.FarmID = sampleModel.FarmID;
                    request.FarmMasterID = sampleModel.FarmMasterID;
                    request.CollectedByOrganizationID = sampleModel.CollectedByOrganizationID;
                    request.CollectedByPersonID = sampleModel.CollectedByPersonID;
                    request.CollectionDate = sampleModel.CollectionDate;
                    request.SentDate = sampleModel.SentDate;
                    request.SentToOrganizationID = sampleModel.SentToOrganizationID;
                    request.HumanDiseaseReportID = sampleModel.HumanDiseaseReportID;
                    request.HumanMasterID = sampleModel.HumanMasterID;
                    request.HumanID = sampleModel.HumanID;
                    request.MonitoringSessionID = sampleModel.MonitoringSessionID;
                    request.Comments = sampleModel.Comments;
                    request.ParentSampleID = sampleModel.ParentSampleID;
                    request.ReadOnlyIndicator = sampleModel.ReadOnlyIndicator;
                    request.RootSampleID = sampleModel.RootSampleID;
                    request.RowAction = sampleModel.RowAction;
                    request.RowStatus = sampleModel.RowStatus;
                    request.SampleID = sampleModel.SampleID;
                    request.SampleStatusTypeID = sampleModel.SampleStatusTypeID;
                    request.SampleTypeID = sampleModel.SampleTypeID;
                    request.SiteID = sampleModel.SiteID;
                    request.SpeciesID = sampleModel.SpeciesID;
                    request.VectorID = sampleModel.VectorID;
                    request.VectorSessionID = sampleModel.VectorSessionID;
                    request.VeterinaryDiseaseReportID = sampleModel.VeterinaryDiseaseReportID;
                }
                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="sampleToDisaseList"></param>
        /// <returns></returns>
        private List<SampleToDiseaseSaveRequestModel> BuildSampleToDiseaseParameters(
            IList<SampleToDiseaseGetListViewModel> sampleToDisaseList)
        {
            List<SampleToDiseaseSaveRequestModel> requests = new();

            if (sampleToDisaseList is null)
                return new List<SampleToDiseaseSaveRequestModel>();

            foreach (var sampleDisease in sampleToDisaseList)
            {
                var request = new SampleToDiseaseSaveRequestModel();
                {
                    request.MonitoringSessionToMaterialID = sampleDisease.MonitoringSessionToMaterialID;
                    request.MonitoringSessionID = sampleDisease.MonitoringSessionID;
                    request.SampleID = sampleDisease.SampleID;
                    request.DiseaseID = sampleDisease.DiseaseID;
                    request.SampleTypeID = sampleDisease.SampleTypeID;
                    request.RowAction = sampleDisease.RowAction;
                    request.RowStatus = sampleDisease.RowStatus;
                }
                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="aggregates"></param>
        /// <param name="farms"></param>
        /// <returns></returns>
        private static List<VeterinaryActiveSurveillanceSessionAggregateSummarySaveRequestModel>
            BuildAggregateSummaryInfoParameters(IList<VeterinaryActiveSurveillanceSessionAggregateViewModel> aggregates,
                IList<FarmViewModel> farms)
        {
            List<VeterinaryActiveSurveillanceSessionAggregateSummarySaveRequestModel> requests = new();

            if (aggregates is null && farms is null)
                return new List<VeterinaryActiveSurveillanceSessionAggregateSummarySaveRequestModel>();

            // add farm records to aggregates collection - coming in the
            //  aggregates collection only contains sample records so farms with
            //  no samples are not yet in aggregates but must be saved to tlbMonitoringSessionSummary
            if (farms != null)
            {
                aggregates ??= new List<VeterinaryActiveSurveillanceSessionAggregateViewModel>();

                var aggregateCount = aggregates.Count;
                foreach (var farm in farms)
                {
                    if (aggregates.Any(x => x.FarmMasterID == farm.FarmMasterID)) continue;

                    // farm is not in aggregates yet so add an aggregate record
                    //  with a farm and no sample
                    var request = new VeterinaryActiveSurveillanceSessionAggregateSummarySaveRequestModel();
                    {
                        request.MonitoringSessionSummaryID =
                            farm.MonitoringSessionSummaryID ?? (aggregateCount + 1) * -1;
                        request.FarmID = farm.FarmID;
                        request.FarmMasterID = farm.FarmMasterID;
                        request.SpeciesID = null;
                        request.AnimalSexID = null;
                        request.SampleAnimalsQty = null;
                        request.SamplesQty = null;
                        request.CollectionDate = null;
                        request.PositiveAnimalsQty = null;
                        request.CollectedByPersonID = null;
                        request.DiseaseID = null;
                        request.SampleTypeID = null;
                        request.RowAction = farm.RowAction;
                        request.RowStatus = farm.RowStatus;
                    }
                    requests.Add(request);
                    aggregateCount++;
                }
            }

            // gather up all the aggregate records with samples
            foreach (var aggregate in aggregates)
            {
                var request = new VeterinaryActiveSurveillanceSessionAggregateSummarySaveRequestModel();
                {
                    request.MonitoringSessionSummaryID = aggregate.MonitoringSessionSummaryID;
                    request.FarmID = aggregate.FarmID;
                    request.FarmMasterID = aggregate.FarmMasterID;
                    request.SpeciesID = aggregate.SpeciesID;
                    request.AnimalSexID = aggregate.AnimalGenderTypeID;
                    request.SampleAnimalsQty = aggregate.SampledAnimalsQuantity;
                    request.SamplesQty = aggregate.SamplesQuantity;
                    request.CollectionDate = aggregate.CollectionDate;
                    request.PositiveAnimalsQty = aggregate.PositiveAnimalsQuantity;
                    request.CollectedByPersonID = aggregate.CollectedByPersonID;
                    request.DiseaseID = aggregate.DiseaseID;
                    request.SampleTypeID = aggregate.SampleTypeID;
                    request.RowAction = aggregate.RowAction;
                    request.RowStatus = aggregate.RowStatus;
                }
                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="samples"></param>
        /// <returns></returns>
        private List<VeterinaryActiveSurveillanceSessionAggregateSummaryDiseasesSaveRequestModel>
            BuildAggregateSummaryDiseaseParameters(IList<VeterinaryActiveSurveillanceSessionAggregateViewModel> samples)
        {
            List<VeterinaryActiveSurveillanceSessionAggregateSummaryDiseasesSaveRequestModel> requests = new();

            if (samples is null)
                return new List<VeterinaryActiveSurveillanceSessionAggregateSummaryDiseasesSaveRequestModel>();

            foreach (var sampleModel in samples)
            {
                if (sampleModel.SelectedDiseases != null && sampleModel.SelectedDiseases.Any())
                {
                    foreach (var disease in sampleModel.SelectedDiseases)
                    {
                        var request = new VeterinaryActiveSurveillanceSessionAggregateSummaryDiseasesSaveRequestModel();
                        {
                            request.MonitoringSessionSummaryID = sampleModel.MonitoringSessionSummaryID;
                            request.DiseaseID = disease;
                            request.RowAction = sampleModel.RowAction;
                            request.RowStatus = sampleModel.RowStatus;
                        }
                        requests.Add(request);
                    }
                }
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="laboratoryTests"></param>
        /// <returns></returns>
        private async Task<List<LaboratoryTestSaveRequestModel>> BuildLaboratoryTestParameters(
            IList<LaboratoryTestGetListViewModel> laboratoryTests)
        {
            List<LaboratoryTestSaveRequestModel> requests = new();

            if (laboratoryTests is null)
                return new List<LaboratoryTestSaveRequestModel>();

            foreach (var laboratoryTestModel in laboratoryTests)
            {
                var request = new LaboratoryTestSaveRequestModel();
                {
                    request.BatchTestID = laboratoryTestModel.BatchTestID;
                    request.Comments = laboratoryTestModel.Comments;
                    request.ContactPersonName = laboratoryTestModel.ContactPersonName;
                    if (laboratoryTestModel.DiseaseID != null) request.DiseaseID = (long)laboratoryTestModel.DiseaseID;
                    request.ExternalTestIndicator = laboratoryTestModel.ExternalTestIndicator;
                    request.HumanDiseaseReportID = laboratoryTestModel.HumanDiseaseReportID;
                    request.MonitoringSessionID = laboratoryTestModel.MonitoringSessionID;
                    request.NonLaboratoryTestIndicator = laboratoryTestModel.NonLaboratoryTestIndicator;
                    request.ObservationID = laboratoryTestModel.ObservationID;
                    request.PerformedByOrganizationID = laboratoryTestModel.PerformedByOrganizationID;
                    request.ReadOnlyIndicator = laboratoryTestModel.ReadOnlyIndicator;
                    request.ReceivedDate = laboratoryTestModel.ReceivedDate;
                    request.ResultDate = laboratoryTestModel.ResultDate;
                    request.ResultEnteredByOrganizationID = laboratoryTestModel.ResultEnteredByOrganizationID;
                    request.ResultEnteredByPersonID = laboratoryTestModel.ResultEnteredByPersonID;
                    request.RowAction = laboratoryTestModel.RowAction;
                    request.RowStatus = laboratoryTestModel.RowStatus;
                    request.SampleID = laboratoryTestModel.SampleID;
                    request.StartedDate = laboratoryTestModel.StartedDate;
                    request.TestCategoryTypeID = laboratoryTestModel.TestCategoryTypeID;
                    request.TestedByOrganizationID = laboratoryTestModel.TestedByOrganizationID;
                    request.TestedByPersonID = laboratoryTestModel.TestedByPersonID;
                    request.TestID = laboratoryTestModel.TestID;
                    request.TestNameTypeID = laboratoryTestModel.TestNameTypeID;
                    request.TestNumber = laboratoryTestModel.TestNumber;
                    request.TestResultTypeID = laboratoryTestModel.TestResultTypeID;
                    request.TestStatusTypeID = laboratoryTestModel.TestStatusTypeID;
                    request.ValidatedByOrganizationID = laboratoryTestModel.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = laboratoryTestModel.ValidatedByPersonID;
                    request.VectorID = laboratoryTestModel.VectorID;
                    request.VectorSessionID = laboratoryTestModel.VectorSessionID;
                    request.VeterinaryDiseaseReportID = laboratoryTestModel.VeterinaryDiseaseReportID;
                }

                if (laboratoryTestModel.OriginalTestResultTypeID != laboratoryTestModel.TestResultTypeID)
                {
                    SystemEventLogTypes eventTypeId;

                    if (laboratoryTestModel.OriginalTestResultTypeID is null)
                    {
                        eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == StateContainer.SiteID
                            ? SystemEventLogTypes
                                .NewLaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasRegisteredAtYourSite
                            : SystemEventLogTypes
                                .NewLaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasRegisteredAtAnotherSite;
                        if (StateContainer.SessionKey != null)
                        {
                            if (StateContainer.SiteID != null)
                                Events.Add(await CreateEvent((long)StateContainer.SessionKey,
                                    laboratoryTestModel.DiseaseID, eventTypeId, (long)StateContainer.SiteID, null));
                        }
                        else
                        {
                            if (StateContainer.SiteID != null)
                                Events.Add(await CreateEvent(0,
                                    laboratoryTestModel.DiseaseID, eventTypeId, (long)StateContainer.SiteID, null));
                        }
                    }
                    else
                    {
                        eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == StateContainer.SiteID
                            ? SystemEventLogTypes
                                .LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasAmendedAtYourSite
                            : SystemEventLogTypes
                                .LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasAmendedAtAnotherSite;
                        if (StateContainer.SessionKey != null)
                            if (StateContainer.SiteID != null)
                                Events.Add(await CreateEvent((long)StateContainer.SessionKey,
                                    laboratoryTestModel.DiseaseID, eventTypeId, (long)StateContainer.SiteID, null));
                    }
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="laboratoryTestInterpretations"></param>
        /// <returns></returns>
        private async Task<List<LaboratoryTestInterpretationSaveRequestModel>>
            BuildLaboratoryTestInterpretationParameters(
                IList<LaboratoryTestInterpretationGetListViewModel> laboratoryTestInterpretations)
        {
            List<LaboratoryTestInterpretationSaveRequestModel> requests = new();

            if (laboratoryTestInterpretations is null)
                return new List<LaboratoryTestInterpretationSaveRequestModel>();

            foreach (var laboratoryTestInterpretationModel in laboratoryTestInterpretations)
            {
                var request = new LaboratoryTestInterpretationSaveRequestModel();
                {
                    request.DiseaseID = laboratoryTestInterpretationModel.DiseaseID;
                    request.InterpretedByOrganizationID = laboratoryTestInterpretationModel.InterpretedByOrganizationID;
                    request.InterpretedByPersonID = laboratoryTestInterpretationModel.InterpretedByPersonID;
                    request.InterpretedComment = laboratoryTestInterpretationModel.InterpretedComment;
                    request.InterpretedDate = laboratoryTestInterpretationModel.InterpretedDate;
                    request.InterpretedStatusTypeID = laboratoryTestInterpretationModel.InterpretedStatusTypeID;
                    request.ReadOnlyIndicator = laboratoryTestInterpretationModel.ReadOnlyIndicator;
                    request.ReportSessionCreatedIndicator =
                        laboratoryTestInterpretationModel.ReportSessionCreatedIndicator;
                    request.RowAction = laboratoryTestInterpretationModel.RowAction;
                    request.RowStatus = laboratoryTestInterpretationModel.RowStatus;
                    request.TestID = laboratoryTestInterpretationModel.TestID;
                    request.TestInterpretationID = laboratoryTestInterpretationModel.TestInterpretationID;
                    request.ValidatedByOrganizationID = laboratoryTestInterpretationModel.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = laboratoryTestInterpretationModel.ValidatedByPersonID;
                    request.ValidatedComment = laboratoryTestInterpretationModel.ValidatedComment;
                    request.ValidatedDate = laboratoryTestInterpretationModel.ValidatedDate;
                    request.ValidatedStatusIndicator = laboratoryTestInterpretationModel.ValidatedStatusIndicator;
                }

                if (laboratoryTestInterpretationModel.RowAction == (int)RowActionTypeEnum.Insert)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == StateContainer.SiteID
                        ? SystemEventLogTypes
                            .LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasInterpretedAtYourSite
                        : SystemEventLogTypes
                            .LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasInterpretedAtAnotherSite;
                    if (StateContainer.SessionKey != null)
                    {
                        if (StateContainer.SiteID != null)
                            Events.Add(await CreateEvent((long)StateContainer.SessionKey,
                                laboratoryTestInterpretationModel.DiseaseID, eventTypeId, (long)StateContainer.SiteID,
                                null));
                    }
                    else if (StateContainer.SiteID != null)
                        Events.Add(await CreateEvent(0,
                            laboratoryTestInterpretationModel.DiseaseID, eventTypeId, (long)StateContainer.SiteID,
                            null));
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="actions"></param>
        /// <returns></returns>
        private static List<VeterinaryActiveSurveillanceSessionActionSaveRequestModel> BuildActionParameters(
            IList<VeterinaryActiveSurveillanceSessionActionsViewModel> actions)
        {
            List<VeterinaryActiveSurveillanceSessionActionSaveRequestModel> requests = new();

            if (actions is null)
                return new List<VeterinaryActiveSurveillanceSessionActionSaveRequestModel>();

            foreach (var action in actions)
            {
                var request = new VeterinaryActiveSurveillanceSessionActionSaveRequestModel();
                {
                    if (action.MonitoringSessionActionID != null)
                        request.MonitoringSessionActionID = (long) action.MonitoringSessionActionID;
                    request.MonitoringSessionActionStatusTypeID = action.MonitoringSessionActionStatusTypeID;
                    request.Comments = action.Comments;
                    request.MonitoringSessionActionTypeID = action.MonitoringSessionActionTypeID;
                    request.EnteredByPersonID = action.EnteredByPersonID;
                    request.ActionDate = action.ActionDate;
                    request.RowAction = action.RowAction;
                    request.RowStatus = action.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="diseaseReports"></param>
        /// <returns></returns>
        private static List<VeterinaryActiveSurveillanceSessionDiseaseReportSaveRequestModel>
            BuildDiseaseReportParameters(IList<VeterinaryDiseaseReportViewModel> diseaseReports)
        {
            List<VeterinaryActiveSurveillanceSessionDiseaseReportSaveRequestModel> requests = new();

            if (diseaseReports is null)
                return new List<VeterinaryActiveSurveillanceSessionDiseaseReportSaveRequestModel>();

            foreach (var diseaseReport in diseaseReports)
            {
                var request = new VeterinaryActiveSurveillanceSessionDiseaseReportSaveRequestModel();
                {
                    request.LinkedDiseaseReportID = diseaseReport.ReportKey;
                    request.RowAction = diseaseReport.RowAction;
                    request.RowStatus = diseaseReport.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #region Delete Active Surveillance Session Method

        /// <summary>
        /// 
        /// </summary>
        /// <param name="monitoringSessionId"></param>
        /// <param name="reportCategoryTypeId"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteSurveillanceSession(long monitoringSessionId,
            long? reportCategoryTypeId)
        {
            try
            {
                bool permission;

                if (StateContainer.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                    authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                    permission = StateContainer.ActiveSurveillanceSessionPermissions.Delete;
                else
                {
                    var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);
                    permission = permissions.Delete;
                }

                if (permission)
                {
                    var response =
                        await VeterinaryClient.DeleteActiveSurveillanceSessionAsync(GetCurrentLanguage(),
                            monitoringSessionId, _token);

                    switch (response.ReturnCode)
                    {
                        case 0:
                            await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                                null);
                            break;

                        case 1:
                            await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                                null);
                            break;

                        case 2:
                            if (reportCategoryTypeId == (long) CaseTypeEnum.Avian)
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants
                                        .AvianDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage, null);
                            else if (reportCategoryTypeId == (long) CaseTypeEnum.Livestock)
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants
                                        .LivestockDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage, null);
                            else
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                                    null);
                            break;
                    }

                    return response;
                }

                var buttons = new List<DialogButton>();
                var okButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);
                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants
                            .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage)
                    }
                };
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return null;
        }

        #endregion

        #endregion

        #endregion

        #region Public Methods

        protected async Task GetCampaignDetail(ActiveSurveillanceCampaignDetailRequestModel request)
        {
            var source = new CancellationTokenSource();
            var campaignResult =
                await CrossCuttingClient.GetActiveSurveillanceCampaignGetDetailAsync(request, source.Token);
            if (campaignResult != null)
            {
                var campaign = campaignResult.First();
                if (await IsCampaignValid(campaign.CampaignID))
                {
                    StateContainer.HasLinkedCampaign = true;
                    StateContainer.CampaignKey = campaign.CampaignID;
                    StateContainer.CampaignID = campaign.EIDSSCampaignID;
                    StateContainer.CampaignType = campaign.CampaignTypeName;
                    StateContainer.CampaignName = campaign.CampaignName;
                    StateContainer.CampaignStartDate = campaign.CampaignStartDate;
                    StateContainer.CampaignEndDate = campaign.CampaignEndDate;
                }
            }
        }

        protected async Task<bool> IsCampaignValid(long campaignId)
        {
            if (StateContainer.DiseaseSpeciesSamples is not { Count: > 0 }) return true;

            var campaignDiseaseSpeciesSamples = await GetCampaignDiseaseSpeciesSamples(campaignId);

            return campaignDiseaseSpeciesSamples.All(x =>
                StateContainer.DiseaseSpeciesSamples.Any(y =>
                    y.DiseaseID == x.idfsDiagnosis && y.SpeciesTypeID == x.idfsSpeciesType));
        }

        protected async Task AddDiseaseSpeciesSamplesFromCampaign(long campaignId)
        {
            int? haCode = null;
            var campaignDiseaseSpeciesSamples = await GetCampaignDiseaseSpeciesSamples(campaignId);
            if (campaignDiseaseSpeciesSamples != null)
            {
                haCode = campaignDiseaseSpeciesSamples.FirstOrDefault()?.HACode;
                foreach (var item in campaignDiseaseSpeciesSamples)
                {
                    StateContainer.DiseaseSpeciesSamples ??=
                        new List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>();

                    if (item.HACode != haCode)
                    {
                        haCode = null;
                    }

                    if (StateContainer.DiseaseSpeciesSamples.Any(x => x.DiseaseID == item.idfsDiagnosis
                                                                      && x.SampleTypeID == item.idfsSampleType
                                                                      && x.SpeciesTypeID == item.idfsSpeciesType))
                        continue;

                    var diseaseSpeciesSample = new VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel
                    {
                        MonitoringSessionToDiseaseID = (StateContainer.DiseaseSpeciesSamples.Count + 1) * -1,
                        MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                        DiseaseID = item.idfsDiagnosis,
                        DiseaseName = item.Disease,
                        SpeciesTypeID = item.idfsSpeciesType,
                        SpeciesTypeName = item.SpeciesTypeName,
                        AvianOrLivestock = 0,
                        SampleTypeID = item.idfsSampleType,
                        SampleTypeName = item.SampleTypeName,
                        OrderNumber = 0,
                        RowStatus = 0,
                        RowAction = (int)RowActionTypeEnum.Insert,
                        RowNumber = StateContainer.DiseaseSpeciesSamples.Count + 1
                    };
                    StateContainer.DiseaseSpeciesSamples.Add(diseaseSpeciesSample);
                    StateContainer.DiseaseSpeciesNewRecordCount++;

                    TogglePendingSaveDiseaseSpecies(diseaseSpeciesSample, null);
                }
            }

            if (haCode != null)
            {
                StateContainer.SpeciesHACode = haCode;
                await GetReportTypesAsync(null);
            }

            StateContainer.DiseaseString = Empty;
            foreach (var dss in StateContainer.DiseaseSpeciesSamples)
            {
                var separator = !IsNullOrEmpty(StateContainer.DiseaseString) ? ", " : Empty;
                StateContainer.DiseaseString += $"{separator}{dss.DiseaseName}";
            }
        }

        private async Task<List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>>
            GetCampaignDiseaseSpeciesSamples(long campaignId)
        {
            var source = new CancellationTokenSource();
            var request = new ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel
            {
                CampaignID = campaignId,
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "idfCampaign",
                SortOrder = "desc"
            };
            return await CrossCuttingClient.GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync(request,
                source.Token);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveDiseaseSpecies(
            VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel record,
            VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel originalRecord)
        {
            StateContainer.PendingSaveDiseaseSpeciesSamples ??=
                new List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>();

            if (StateContainer.PendingSaveDiseaseSpeciesSamples.Any(x =>
                    x.MonitoringSessionToDiseaseID == record.MonitoringSessionToDiseaseID))
            {
                var index = StateContainer.PendingSaveDiseaseSpeciesSamples.IndexOf(originalRecord);
                StateContainer.PendingSaveDiseaseSpeciesSamples[index] = record;
            }
            else
            {
                StateContainer.PendingSaveDiseaseSpeciesSamples.Add(record);
            }
        }

        protected async Task GetReportTypesAsync(LoadDataArgs args)
        {
            //5380
            StateContainer.ReportTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.ASSpeciesType, HACodeList.LiveStockAndAvian);

            ReportTypesCount = StateContainer.ReportTypes.Count;
        }

        #endregion
    }
}