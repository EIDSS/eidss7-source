using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Human.Person;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static EIDSS.Localization.Constants.MessageResourceKeyConstants;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportContactListBase : BaseComponent
    {
        [Parameter]
        public DiseaseReportContactListPageViewModel Model { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private IPersonStateContainerResolver PersonStateContainerResolver { get; set; }
        
        [Inject]
        private IHdrStateContainer HdrStateContainer { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IAdminClient AdminClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportContactListPageViewModel> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        protected HumanDiseaseReportSessionStateContainer StateContainer { get; set; }

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Parameter]
        public bool isReportClosed { get; set; }

        [Parameter]
        public bool isOutbreakCase { get; set; }

        protected bool showReason;
        protected RadzenDataGrid<DiseaseReportContactDetailsViewModel> _grid;

        private UserPermissions userPermissions;

        private const string DIALOG_WIDTH = "900px";

        protected override async Task OnInitializedAsync()
        {
            try
            {
                await base.OnInitializedAsync();

                _logger = Logger;

                userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);

                await SetDataInLocalStorageAndHdrContainer();
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected bool IsAddButtonDisabled =>
            !userPermissions.Create ||
            isReportClosed;

        protected bool IsEditDeleteDisabled =>
            !userPermissions.Create ||
            isReportClosed;

        protected async Task PersonSearchClicked()
        {
            try
            {
                var pvm = await GetSelectedPersonFromModals();
                if (pvm != null)
                {
                    var locationViewModel = CreateLocationViewModel();
                    locationViewModel.AdminLevel0Value = pvm.CountryID;
                    locationViewModel.AdminLevel0Text = pvm.CountryName;
                    locationViewModel.AdminLevel1Value = pvm.RegionID;
                    locationViewModel.AdminLevel1Text = pvm.RegionName;
                    locationViewModel.AdminLevel2Value = pvm.RayonID;
                    locationViewModel.AdminLevel2Text = pvm.RayonName;
                    locationViewModel.AdminLevel3Value = pvm.SettlementID;
                    locationViewModel.AdminLevel3Text = pvm.SettlementName;
                    locationViewModel.StreetText = pvm.StreetName;
                    locationViewModel.House = pvm.House;
                    locationViewModel.Building = pvm.Building;
                    locationViewModel.Apartment = pvm.Apartment;
                    locationViewModel.PostalCodeText = pvm.PostalCode;

                    var dialogParams = new Dictionary<string, object>
                    {
                        { "idfHumanCase", Model.idfHumanCase },
                        { "idfHumanActual", Model.HumanActualID },
                        { "personDetails", pvm },
                        { "accessToPersonalInfoData", userPermissions.AccessToPersonalData },
                        { "locationViewModel", locationViewModel },
                        { "isOutbreakCase", isOutbreakCase },
                        { "isEdit", false }
                    };

                    var editContactResultModel = await OpenEditContactDetailsModal(new DiseaseReportContactDetailsViewModel { RowAction = (int)RowActionTypeEnum.Insert, LocationViewModel = locationViewModel }, dialogParams);

                    DiagService.Close();

                    if (editContactResultModel != null && await ShouldSaveRecordAfterDuplicationVerification(editContactResultModel))
                    {
                        Model.ContactDetails.Add(editContactResultModel);
                        await SetDataInLocalStorageAndHdrContainer();
                        await _grid.Reload();
                        await InvokeAsync(StateHasChanged);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task SetDataInLocalStorageAndHdrContainer()
        {
            await JsRuntime.InvokeAsync<string>("SetContactsData", Model);
            HdrStateContainer.MinimumValueOfLastContactDateFromContacts = Model.ContactDetails
                .Where(x => x.datDateOfLastContact.HasValue && x.RowStatus != (int)RowActionTypeEnum.Delete)
                .Min(x => x.datDateOfLastContact);
        }

        private async Task<bool> ShouldSaveRecordAfterDuplicationVerification(DiseaseReportContactDetailsViewModel editContactResultModel)
        {
            var firstName = editContactResultModel.strFirstName;
            var lasName = editContactResultModel.strLastName;
            var region = editContactResultModel.idfsRegion;
            var dateOfBirth = editContactResultModel.datDateofBirth;

            var possibleDuplication = Model.ContactDetails.Where(x =>
                (string.IsNullOrEmpty(firstName) || firstName == x.strFirstName) &&
                (string.IsNullOrEmpty(lasName) || lasName == x.strLastName) &&
                (!(region > 0) || region == x.idfsRegion) &&
                (dateOfBirth == null || dateOfBirth == x.datDateofBirth)
            ).ToList();

            if (!possibleDuplication.Any())
            {
                return true;
            }

            var duplicateRecordsFound = string.Join(", ", possibleDuplication.Select(x => $"{x.strFirstName ?? ""} {x.strLastName}".Trim()));
            var duplicateMessage =
                string.Format(
                    Localizer.GetString(HumanActiveSurveillanceCampaignDuplicateRecordFoundDoYouWantToContinueSavingTheCurrentRecordMessage),
                    duplicateRecordsFound);

            var yesWasSelectedByUser = await DiagService.Confirm(duplicateMessage,
                Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading),
                new ConfirmOptions
                {
                    OkButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    CancelButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton)
                });

            return yesWasSelectedByUser.GetValueOrDefault();
        }

        private async Task<PersonViewModel> GetSelectedPersonFromModals()
        {
            dynamic result = await DiagService.OpenAsync<SearchPerson.SearchPerson>(Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalSearchPersonHeading),
                new Dictionary<string, object> { { "Mode", SearchModeEnum.SelectNoRedirect }, { "ClearSearchResults", true } }, options: new DialogOptions()
                {
                    Width = DIALOG_WIDTH,
                    CloseDialogOnOverlayClick = false,
                    Draggable = false,
                    Resizable = true
                });

            if (result is string && result == "Add")
            {
                PersonStateContainerResolver.GetContainerFor("personForm").ResetModelValues();
                result = await DiagService.OpenAsync<PersonSections>(
                    Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                    new Dictionary<string, object>() { { "ShowInDialog", true } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.AddPersonDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result is PersonViewModel recordpvm)
                {
                    HumanPersonSearchRequestModel request = new HumanPersonSearchRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        PersonalID = recordpvm.PersonalID,
                        SortColumn = "EIDSSPersonID",
                        SortOrder = SortConstants.Descending,
                        EIDSSPersonID = recordpvm.EIDSSPersonID
                    };
                    var resultPersons = await PersonClient.GetPersonList(request);
                    result = resultPersons.First(x => x.HumanMasterID == result.HumanMasterID);

                    if (result is PersonViewModel newRecord)
                    {
                        return newRecord;
                    }
                }
            }

            if (result is PersonViewModel pvm)
            {
                return pvm;
            }

            return null;
        }

        public void Dispose()
        {
            StateContainer.OnChange -= StateHasChanged;
        }

        protected async Task OpenEditModal(DiseaseReportContactDetailsViewModel data)
        {
            var locationViewModel = data.LocationViewModel;
            if (locationViewModel == null)
            {
                locationViewModel = CreateLocationViewModel();
                locationViewModel.AdminLevel1Value = data.idfsRegion;
                locationViewModel.AdminLevel2Value = data.idfsRayon;
                locationViewModel.AdminLevel3Value = data.idfsSettlement;
                locationViewModel.StreetText = data.strStreetName;
                locationViewModel.PostalCodeText = data.strPostCode;
                locationViewModel.House = data.strHouse;
                locationViewModel.Building = data.strBuilding;
                locationViewModel.Apartment = data.strApartment;
            }

            var dialogParams = new Dictionary<string, object>
            {
                { "idfHumanCase", Model.idfHumanCase },
                { "Model", data },
                { "isEdit", true },
                { "accessToPersonalInfoData", userPermissions.AccessToPersonalData },
                { "locationViewModel", locationViewModel }
            };

            if (isOutbreakCase)
            {
                Model.ContactTracingFlexFormRequest.idfObservation = data.TracingObservationID;
                dialogParams.Add("ContactTracingFlexFormRequest", Model.ContactTracingFlexFormRequest);
            }

            var editeDetailsViewModel = await OpenEditContactDetailsModal(data, dialogParams);
            if (editeDetailsViewModel != null)
            {
                await SetDataInLocalStorageAndHdrContainer();
                await _grid.Reload();
            };
        }

        private async Task<DiseaseReportContactDetailsViewModel?> OpenEditContactDetailsModal(DiseaseReportContactDetailsViewModel modelToEdit, Dictionary<string, object> dialogParams)
        {
            if (isOutbreakCase)
            {
                Model.ContactTracingFlexFormRequest.idfObservation = null;
                dialogParams.Add("ContactTracingFlexFormRequest", Model.ContactTracingFlexFormRequest);
            }

            var contactResultObject = await DiagService.OpenAsync<DiseaseReportContactAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                dialogParams, new DialogOptions { Width = "900px", Resizable = true, Draggable = false });

            if (contactResultObject is EditContext contactResult && contactResult.Validate())
            {
                var editedModel = (DiseaseReportContactDetailsViewModel)contactResult.Model;
                modelToEdit.RowAction = modelToEdit.RowAction == (int)RowActionTypeEnum.Insert
                    ? (int)RowActionTypeEnum.Insert
                    : (int)RowActionTypeEnum.Update;
                var locationViewModel = editedModel.LocationViewModel;
                modelToEdit.strFirstName = editedModel.strFirstName;
                modelToEdit.strLastName = editedModel.strLastName;
                modelToEdit.strSecondName = editedModel.strSecondName;

                modelToEdit.idfsHumanGender = editedModel.idfsHumanGender;
                modelToEdit.idfCitizenship = editedModel.idfCitizenship;
                modelToEdit.datDateofBirth = editedModel.datDateofBirth;
                modelToEdit.Age = editedModel.Age;

                modelToEdit.idfContactedCasePerson = editedModel.idfContactedCasePerson;
                modelToEdit.strPlaceInfo = editedModel.strPlaceInfo;
                modelToEdit.idfsPersonContactType = editedModel.idfsPersonContactType;
                modelToEdit.strPersonContactType = editedModel.strPersonContactType;
                modelToEdit.strComments = editedModel.strComments;
                modelToEdit.datDateOfLastContact = editedModel.datDateOfLastContact;
                modelToEdit.strContactPhone = editedModel.strContactPhone;
                modelToEdit.idfContactPhoneType = editedModel.idfContactPhoneType;
                modelToEdit.AddressID = editedModel.AddressID;

                modelToEdit.blnForeignAddress = editedModel.blnForeignAddress;
                modelToEdit.idfsCountry = locationViewModel.AdminLevel0Value;
                modelToEdit.idfsRegion = locationViewModel.AdminLevel1Value;
                modelToEdit.idfsRayon = locationViewModel.AdminLevel2Value;
                modelToEdit.idfsSettlement = locationViewModel.AdminLevel3Value;
                modelToEdit.strStreetName = locationViewModel.StreetText;
                modelToEdit.strPostCode = locationViewModel.PostalCodeText;
                modelToEdit.strHouse = locationViewModel.House;
                modelToEdit.strApartment = locationViewModel.Apartment;
                modelToEdit.strBuilding = locationViewModel.Building;
                modelToEdit.idfHumanActual = editedModel.idfHumanActual;
                modelToEdit.idfHuman = editedModel.idfHuman;
                modelToEdit.idfHumanCase = editedModel.idfHumanCase;
                modelToEdit.LocationViewModel = editedModel.LocationViewModel;
                modelToEdit.strPatientAddressString = editedModel.strPatientAddressString;

                if (modelToEdit.blnForeignAddress == false)
                {
                    modelToEdit.strPatientAddressString = string.Join(", ", new List<string>
                    {
                        locationViewModel.PostalCodeText,
                        locationViewModel.AdminLevel0Text,
                        locationViewModel.AdminLevel1Text,
                        locationViewModel.AdminLevel2Text,
                        locationViewModel.AdminLevel3Text,
                        locationViewModel.StreetText,
                        locationViewModel.House,
                        locationViewModel.Building,
                        locationViewModel.Apartment,
                        editedModel.strContactPhone
                    }.Where(x => !string.IsNullOrEmpty(x)));
                }

                if (isOutbreakCase && Model.ContactTracingFlexFormRequest.idfObservation != null)
                {
                    modelToEdit.TracingObservationID = (long)Model.ContactTracingFlexFormRequest.idfObservation;
                }

                return modelToEdit;
            }

            return null;
        }

        protected async Task DeleteRow(DiseaseReportContactDetailsViewModel item)
        {
            if (Model.ContactDetails != null && Model.ContactDetails.Contains(item))
            {
                var result = await DiagService.Confirm(Localizer.GetString(DoYouWantToDeleteThisRecordMessage), Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), new ConfirmOptions() { OkButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton), CancelButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton) });
                if (result == true)
                {
                    item.RowStatus = (int)RowActionTypeEnum.Delete;
                    await SetDataInLocalStorageAndHdrContainer();
                    await _grid.Reload();
                }
            }
        }

        private LocationViewModel CreateLocationViewModel()
        {
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
            return new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
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
                ShowApartment = false,
                ShowElevation = false,
                ShowHouse = true,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel0 = false,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredAdminLevel3 = false,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(base.CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().Adminlevel2
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().Adminlevel3
                    : null
            };
        }
    }
}