#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
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
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class FarmBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] protected FarmStateContainer StateContainer { get; set; }
        [Inject] protected IVeterinaryClient VeterinaryClient { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ILogger<FarmBaseComponent> Logger { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #region Parameters

        [Parameter] public long? FarmMasterID { get; set; }
        [Parameter] public bool IsReadOnly { get; set; }
        [Parameter] public SearchModeEnum Mode { get; set; }
        [Parameter] public LocalizedString ReturnButtonResourceString { get; set; }
        [Parameter] public EventCallback<long?> FarmAddEditComplete { get; set; }
        [Parameter] public bool ShowInDialog { get; set; }
        [Parameter] public bool LaboratoryModuleIndicator { get; set; }

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            return base.OnInitializedAsync();
        }

        #endregion

        #region Farm Header Section Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public bool ValidateFarmHeaderSection()
        {
            StateContainer.FarmHeaderSectionValidIndicator = true;
            return true;
        }

        #endregion

        #region Farm Information Section Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public bool ValidateFarmInformationSection()
        {
            StateContainer.FarmInformationSectionValidIndicator = true;
            return true;
        }

        #endregion

        #region Farm Address Section Methods

        /// <summary>
        /// </summary>
        /// <param name="farmDetail"></param>
        public void SetLocation(FarmMasterGetDetailViewModel farmDetail)
        {
            var userPreferences =
                ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            StateContainer.FarmLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                AlwaysDisabled = !StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                                 !StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnableAdminLevel1 =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnableAdminLevel2 =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlement = true,
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
                EnableSettlementType = StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                                       StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnableHouse = StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                              StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnableApartment =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnableStreet =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnablePostalCode =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnableBuilding =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnabledLatitude =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                EnabledLongitude =
                    StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                    StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : null,
                AdministrativeLevelId = farmDetail.FarmAddressLocationID
            };

            if (!StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null ||
                !StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0)
                StateContainer.FarmLocationModel.OperationType = LocationViewOperationType.ReadOnly;

            if (StateContainer.FarmMasterID is null) return;
            StateContainer.FarmLocationModel.AdminLevel0Value =
                farmDetail.FarmAddressAdministrativeLevel0ID;
            StateContainer.FarmLocationModel.AdminLevel1Value =
                farmDetail.FarmAddressAdministrativeLevel1ID;
            StateContainer.FarmLocationModel.AdminLevel2Value =
                farmDetail.FarmAddressAdministrativeLevel2ID;
            StateContainer.FarmLocationModel.AdminLevel3Value = bottomAdmin switch
            {
                (long) GISAdministrativeLevels.AdminLevel3 => farmDetail.FarmAddressSettlementID,
                _ => StateContainer.FarmLocationModel.AdminLevel3Value
            };
            StateContainer.FarmLocationModel.SettlementType = farmDetail.FarmAddressSettlementTypeID;
            StateContainer.FarmLocationModel.StreetText = farmDetail.FarmAddressStreetName;
            StateContainer.FarmLocationModel.House = farmDetail.FarmAddressHouse;
            StateContainer.FarmLocationModel.Building = farmDetail.FarmAddressBuilding;
            StateContainer.FarmLocationModel.Apartment = farmDetail.FarmAddressApartment;
            StateContainer.FarmLocationModel.PostalCodeText = farmDetail.FarmAddressPostalCode;
            StateContainer.FarmLocationModel.Latitude = farmDetail.FarmAddressLatitude;
            StateContainer.FarmLocationModel.Longitude = farmDetail.FarmAddressLongitude;
        }

        #endregion

        #region Farm Review Section Methods

        protected bool ValidateMinimumFarmFields()
        {
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;
            var settlementRequired = bottomAdmin >= (long) EIDSSConstants.GISAdministrativeUnitTypes.Settlement;

            // farm owner is blank so farm name, admin level 1, 2, and optionally 3 are required
            if (IsNullOrEmpty(StateContainer.FarmOwner) && !IsNullOrEmpty(StateContainer.FarmName))
                if (StateContainer.FarmLocationModel.AdminLevel1Value != null &&
                    StateContainer.FarmLocationModel.AdminLevel2Value != null &&
                    (!settlementRequired || StateContainer.FarmLocationModel.AdminLevel3Value != null))
                    return true;

            // farm owner and farm name are blank so admin level 1, 2, and optionally 3 are required and street
            if (!IsNullOrEmpty(StateContainer.FarmOwner) ||
                !IsNullOrEmpty(StateContainer.FarmName)) return false;
            if (StateContainer.FarmLocationModel.AdminLevel1Value != null &&
                StateContainer.FarmLocationModel.AdminLevel2Value != null &&
                (!settlementRequired || StateContainer.FarmLocationModel.AdminLevel3Value != null) &&
                !IsNullOrEmpty(StateContainer.FarmLocationModel.StreetText))
                return true;

            return false;
        }

        #endregion

        #region Save Farm Methods

        /// <summary>
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        protected async Task<FarmSaveRequestResponseModel> SaveFarm()
        {
            try
            {
                if (StateContainer.FarmInformationSectionValidIndicator
                    && StateContainer.FarmAddressSectionValidIndicator)
                {
                    StateContainer.PendingSaveEvents ??= new List<EventSaveRequestModel>();

                    foreach (var notification in StateContainer.PendingSaveEvents)
                        Events.Add(notification);

                    //Get lowest administrative level for location
                    if (StateContainer.FarmLocationModel.AdminLevel5Value.HasValue)
                        StateContainer.FarmLocationModel.AdministrativeLevelId =
                            StateContainer.FarmLocationModel.AdminLevel5Value.Value;
                    else if (StateContainer.FarmLocationModel.AdminLevel4Value.HasValue)
                        StateContainer.FarmLocationModel.AdministrativeLevelId =
                            StateContainer.FarmLocationModel.AdminLevel4Value.Value;
                    else if (StateContainer.FarmLocationModel.AdminLevel3Value.HasValue)
                        StateContainer.FarmLocationModel.AdministrativeLevelId =
                            StateContainer.FarmLocationModel.AdminLevel3Value.Value;
                    else if (StateContainer.FarmLocationModel.AdminLevel2Value.HasValue)
                        StateContainer.FarmLocationModel.AdministrativeLevelId =
                            StateContainer.FarmLocationModel.AdminLevel2Value.Value;
                    else if (StateContainer.FarmLocationModel.AdminLevel1Value.HasValue)
                        StateContainer.FarmLocationModel.AdministrativeLevelId =
                            StateContainer.FarmLocationModel.AdminLevel1Value.Value;

                    var request = new FarmSaveRequestModel
                    {
                        FarmMasterID = StateContainer.FarmMasterID,
                        FarmCategory = StateContainer.FarmTypeID,
                        FarmOwnerID = StateContainer.FarmOwnerID,
                        FarmNationalName = StateContainer.FarmName,
                        EIDSSFarmID = StateContainer.EidssFarmID,
                        OwnershipStructureTypeID = StateContainer.OwnershipStructureTypeID,
                        Email = StateContainer.Email,
                        FarmAddressID = StateContainer.FarmAddressID,
                        FarmAddressApartment = StateContainer.FarmLocationModel.Apartment,
                        FarmAddressBuilding = StateContainer.FarmLocationModel.Building,
                        FarmAddressHouse = StateContainer.FarmLocationModel.House,
                        FarmAddressIdfsLocation = StateContainer.FarmLocationModel.AdministrativeLevelId,
                        FarmAddressLatitude = StateContainer.FarmLocationModel.Latitude,
                        FarmAddressLongitude = StateContainer.FarmLocationModel.Longitude,
                        FarmAddressPostalCode = StateContainer.FarmLocationModel.PostalCodeText,
                        FarmAddressStreet = StateContainer.FarmLocationModel.StreetText,
                        FarmTypeID = StateContainer.FarmTypeID,
                        Fax = StateContainer.Fax,
                        Phone = StateContainer.Phone,
                        NumberOfBirdsPerBuilding = StateContainer.NumberOfBirdsPerBuilding,
                        NumberOfBuildings = StateContainer.NumberOfBuildings,
                        AvianFarmTypeID = StateContainer.AvianFarmTypeID,
                        AvianProductionTypeID = StateContainer.AvianProductionTypeID,
                        AuditUser = _tokenService.GetAuthenticatedUser().UserName
                    };

                    var response = await VeterinaryClient.SaveFarm(request);

                    return response;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return new FarmSaveRequestResponseModel();
        }

        #endregion

        #region Delete Farm Methods

        public async Task<APIPostResponseModel> DeleteFarm()
        {
            try
            {
                var response = await VeterinaryClient.DeleteFarmMaster(StateContainer.FarmMasterID.Value, false, authenticatedUser.UserName);

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
                        await ShowErrorDialog(
                            MessageResourceKeyConstants.FarmUnableToDeleteDependentOnAnotherObjectMessage, null);
                        break;
                }

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Cancel Farm Add/Edit

        public async Task Cancel()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        _source?.Cancel();

                        // just take us back to the Farm Add
                        var uri = $"{NavManager.BaseUri}Veterinary/Farm";
                        // and force the reload
                        NavManager.NavigateTo(uri, true);
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

        #endregion
    }
}