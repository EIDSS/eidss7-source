using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using Microsoft.JSInterop;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Services;
using System.Linq;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Web.Components.Human.Person;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.Human;
using System.ServiceModel.Channels;
using Newtonsoft.Json.Linq;
using System.Drawing;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportContactListBase : BaseComponent
    {
        [Parameter]
        public DiseaseReportContactListPageViewModel Model { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

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

        protected bool showTestGrid;

        protected bool enableAddButton;

        [Parameter]
        public bool isReportClosed { get; set; }

        [Parameter]
        public bool isOutbreakCase { get; set; } = false;

        public IList<DiseaseReportContactDetailsViewModel> selectedContacts;

        protected bool showReason;
        protected RadzenDataGrid<DiseaseReportContactDetailsViewModel> _grid;

        private UserPermissions userPermissions;

        protected bool accessToHumanDiseaseReportData { get; set; }

        protected bool accessToPersonalInfoData { get; set; }
        protected bool disableEditDelete { get; set; }

        private const string DIALOG_WIDTH = "700px";
        private const string DIALOG_HEIGHT = "775px";

        protected override async Task OnInitializedAsync()
        {
            try
            {
                await base.OnInitializedAsync();

                //  await JsRuntime.InvokeAsync<string>("SetContactsData", null);
                _logger = Logger;

                userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);

                accessToHumanDiseaseReportData = userPermissions.Create;
                if (accessToHumanDiseaseReportData)
                    enableAddButton = false;
                else
                    enableAddButton = true;

                accessToPersonalInfoData = userPermissions.AccessToPersonalData;

                // canAddTestResulsForHumanCaseSession = GetUserPermissions(PagePermission.CanAddTestResultsForHumanCase_Session);

                if (accessToHumanDiseaseReportData)
                    disableEditDelete = false;

                if (isReportClosed)
                {
                    disableEditDelete = false;
                    enableAddButton = true;
                }

                await JsRuntime.InvokeAsync<string>("SetContactsData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task PersonSearchClicked()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchPerson.SearchPerson>(Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalSearchPersonHeading),
                    new Dictionary<string, object> { { "Mode", SearchModeEnum.SelectNoRedirect }, { "ClearSearchResults", true } }, options: new DialogOptions()
                    {
                        Width = DIALOG_WIDTH,
                        // Height = DIALOG_HEIGHT,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result != null)
                {
                    if (result is string && result == "Add")
                    {
                        //  await AddPerson().ConfigureAwait(false);

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

                        if (result != null)
                        {
                            if (result is PersonViewModel recordpvm)
                            {
                                string house, building, apartment, postalCode;
                                house = building = apartment = postalCode = string.Empty;
                                HumanPersonSearchRequestModel request = new HumanPersonSearchRequestModel
                                {
                                    LanguageId = GetCurrentLanguage(),
                                    PersonalID = recordpvm.PersonalID,
                                    SortColumn = "EIDSSPersonID",
                                    SortOrder = SortConstants.Descending
                                };
                                var resultPersons = await PersonClient.GetPersonList(request);
                                result = resultPersons.First(x => x.HumanMasterID == result.HumanMasterID);

                                if (result != null)
                                {
                                    if (result is PersonViewModel newRecord)
                                    {
                                        DiseaseReportContactDetailsViewModel item = new DiseaseReportContactDetailsViewModel();
                                        item.strFirstName = newRecord.FirstOrGivenName;
                                        item.strLastName = newRecord.LastOrSurname;
                                        item.strSecondName = newRecord.SecondName;
                                        item.strContactPhone = newRecord.ContactPhoneNumber;
                                        item.idfsHumanGender = newRecord.GenderTypeID;
                                        item.idfCitizenship = newRecord.CitizenshipTypeID;
                                        item.datDateofBirth = newRecord.DateOfBirth;
                                        item.Age = newRecord.Age;
                                        item.idfContactedCasePerson = newRecord.HumanMasterID;
                                        //item.strPlaceInfo = newRecord.strPlaceInfo;
                                        //item.idfsPersonContactType = newRecord.idfsPersonContactType;
                                        //item.strPersonContactType = newRecord.strPersonContactType;
                                        //item.strComments = newRecord.strComments;
                                        //item.datDateOfLastContact = newRecord.datDateOfLastContact;
                                        item.idfContactPhoneType = newRecord.ContactPhoneNbrTypeID;
                                        item.AddressID = newRecord.AddressID;
                                        //item.blnForeignAddress = newRecord.blnForeignAddress;
                                        item.idfsCountry = newRecord.CountryID;
                                        item.idfsRegion = newRecord.RegionID;
                                        item.idfsRayon = newRecord.RayonID;
                                        item.idfsSettlement = newRecord.SettlementID;
                                        item.strStreetName = newRecord.StreetName;
                                        item.strPostCode = newRecord.PostalCode;
                                        item.strHouse = newRecord.House;
                                        item.strApartment = newRecord.Apartment;
                                        item.strBuilding = newRecord.Building;
                                        //item.LocationViewModel = newRecord.LocationViewModel;
                                        item.idfHumanActual = newRecord.HumanMasterID;
                                        //item.idfHuman = newRecord.EIDSSPersonID;
                                        //item.idfHumanCase = newRecord.idfHumanCase;
                                        //item.strPatientAddressString = newRecord.strPatientAddressString;
                                        item.RowAction = 1;
                                        Model.ContactDetails.Add(item);
                                        // ToggleSamplePanel();
                                        if (_grid != null)
                                        {
                                            await _grid.Reload();
                                            await JsRuntime.InvokeAsync<string>("SetContactsData", Model);
                                        }
                                    }
                                }
                            }
                        }
                        await InvokeAsync(StateHasChanged);
                    }
                    else if (result is PersonViewModel record)
                    {
                        PersonViewModel pvm = result;
                        var dialogParams = new Dictionary<string, object>();
                        // Model.personDetails = result;

                        // dialogParams.Add("idfDisease", Model.idfDisease);
                        dialogParams.Add("idfHumanCase", Model.idfHumanCase);
                        dialogParams.Add("idfHumanActual", Model.HumanActualID);
                        dialogParams.Add("isEdit", false);
                        dialogParams.Add("personDetails", result);
                        dialogParams.Add("accessToPersonalInfoData", accessToPersonalInfoData);

                        var userPreferences =
                            ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
                        var locationViewModel = new LocationViewModel()
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
                            ShowApartment = true,
                            ShowElevation = false,
                            ShowHouse = true,
                            ShowLatitude = true,
                            ShowLongitude = true,
                            ShowMap = true,
                            ShowBuildingHouseApartmentGroup = true,
                            ShowPostalCode = true,
                            ShowCoordinates = false,
                            IsDbRequiredAdminLevel1 = true,
                            IsDbRequiredAdminLevel2 = true,
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

                        dialogParams.Add("locationViewModel", locationViewModel);
                        dialogParams.Add("isOutbreakCase", isOutbreakCase);

                        if (isOutbreakCase)
                        {
                            Model.ContactTracingFlexFormRequest.idfObservation = null;
                            dialogParams.Add("ContactTracingFlexFormRequest", Model.ContactTracingFlexFormRequest);
                        }

                        dynamic contactResult = await DiagService.OpenAsync<DiseaseReportContactAddModal>(
                            Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                            dialogParams,
                            new DialogOptions()
                            { Width = "900px", Resizable = true, Draggable = false });

                        if (contactResult == null)
                            return;

                        if ((contactResult as EditContext).Validate())
                        {
                            var contact = contactResult as EditContext;
                            DiseaseReportContactDetailsViewModel obj =
                                (DiseaseReportContactDetailsViewModel)contactResult.Model;
                            DiseaseReportContactDetailsViewModel item = new DiseaseReportContactDetailsViewModel();
                            int count = 0;

                            if (Model.ContactDetails != null)
                            {
                                count = Model.ContactDetails.Count;
                            }

                            locationViewModel = obj.LocationViewModel;
                            count = Model.ContactDetails.Count;
                            item.strFirstName = obj.strFirstName;
                            item.strLastName = obj.strLastName;
                            item.strSecondName = obj.strSecondName;
                            item.strContactPhone = obj.strContactPhone;
                            item.idfsHumanGender = obj.idfsHumanGender;
                            item.idfCitizenship = obj.idfCitizenship;
                            item.datDateofBirth = obj.datDateofBirth;
                            item.Age = obj.Age;

                            item.idfContactedCasePerson = obj.idfContactedCasePerson;
                            item.strPlaceInfo = obj.strPlaceInfo;

                            item.idfsPersonContactType = obj.idfsPersonContactType;
                            item.strPersonContactType = obj.strPersonContactType;
                            item.strComments = obj.strComments;
                            item.datDateOfLastContact = obj.datDateOfLastContact;
                            item.idfContactPhoneType = obj.idfContactPhoneType;
                            item.AddressID = obj.AddressID;

                            item.blnForeignAddress = obj.blnForeignAddress;
                            item.idfsCountry = locationViewModel.AdminLevel0Value;
                            item.idfsRegion = locationViewModel.AdminLevel1Value;
                            item.idfsRayon = locationViewModel.AdminLevel2Value;
                            item.idfsSettlement = locationViewModel.AdminLevel3Value;
                            item.strStreetName = locationViewModel.StreetText;
                            item.strPostCode = locationViewModel.PostalCodeText;
                            item.strHouse = locationViewModel.House;
                            item.strApartment = locationViewModel.Apartment;
                            item.strBuilding = locationViewModel.Building;
                            item.LocationViewModel = obj.LocationViewModel;
                            item.idfHumanActual = obj.idfHumanActual;
                            // item.idfHuman = obj.idfHuman;
                            item.idfHumanCase = obj.idfHumanCase;
                            item.strPatientAddressString = obj.strPatientAddressString;
                            item.RowAction = 1;
                            if (item.blnForeignAddress == false)
                            {
                                if (!string.IsNullOrEmpty(locationViewModel.PostalCodeText))
                                {
                                    item.strPatientAddressString = locationViewModel.PostalCodeText;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel0Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel0Text;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel1Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel1Text;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel2Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel2Text;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel3Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel3Text;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.StreetText))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.StreetText;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.House))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.House;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.Building))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.Building;
                                }

                                if (!string.IsNullOrEmpty(locationViewModel.Apartment))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.Apartment;
                                }

                                if (!string.IsNullOrEmpty(obj.strContactPhone))
                                {
                                    item.strPatientAddressString += "," + obj.strContactPhone;
                                }

                                item.strPatientAddressString = item.strPatientAddressString.TrimStart(',');
                                item.strPatientAddressString = item.strPatientAddressString.TrimEnd(',');
                            }

                            if (Model.ContactDetails == null)
                                Model.ContactDetails = new List<DiseaseReportContactDetailsViewModel>();

                            if (isOutbreakCase && Model.ContactTracingFlexFormRequest.idfObservation != null)
                            {
                                item.TracingObservationID = (long)Model.ContactTracingFlexFormRequest.idfObservation;
                            }

                            Model.ContactDetails.Add(item);
                            // ToggleSamplePanel();
                            if (_grid != null)
                            {
                                await _grid.Reload();
                                await JsRuntime.InvokeAsync<string>("SetContactsData", Model);
                                // StateContainer.SetHumanDiseaseReportSampleSessionStateViewModel(Model);
                            }
                            // await BrowserStorage.SetAsync(HumaDiseaseReportPersistanceKeys.HDRSample, Model);
                        }
                        else
                        {
                            //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                        }

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

        protected async Task AddPerson()
        {
            try
            {
                var result = await DiagService.OpenAsync<PersonSections>(
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

                if (result != null)
                {
                    if (result is PersonViewModel record)
                    {
                        Model.HumanActualID = record.HumanMasterID;
                        // Model. = record.FullName;
                    }

                    //Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                }

                //var result = await DiagService.OpenAsync<PersonSections>(
                //    Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalFarmHeading),
                //    new Dictionary<string, object>()
                //    {
                //        { "ShowInDialog", true },
                //        { "ReturnButtonConstant", Localizer.GetString(ButtonResourceKeyConstants.VeterinarySessionReturnToActiveSurveillanceSessionText) }
                //    },
                //    new DialogOptions
                //    {
                //        Style = LaboratoryModuleCSSClassConstants.AddFarmDialog,
                //        AutoFocusFirstElement = true,
                //        CloseDialogOnOverlayClick = false,
                //        Draggable = false,
                //        Resizable = true
                //    });

                //if (result != null)
                //{
                //    var farmID = result as long?;
                //    var request = new FarmMasterSearchRequestModel()
                //    {
                //        LanguageId = GetCurrentLanguage(),
                //        FarmMasterID = farmID,
                //        SortOrder = "desc",
                //        SortColumn = "EIDSSFarmID"
                //    };
                //    var farmMasterList = await VeterinaryClient.GetFarmMasterListAsync(request);
                //    if (farmMasterList != null)
                //    {
                //        var farm = farmMasterList.First();
                //        if (StateContainer.Farms is null)
                //        {
                //            StateContainer.Farms = new();
                //        }
                //        FarmNewRecordCount += 1;
                //        farm.RowAction = (int)RowActionTypeEnum.Insert;
                //        farm.RowStatus = (int)RowStatusTypeEnum.Active;
                //        if (farm.FarmID is null)
                //            farm.FarmID = (StateContainer.Farms.Count + 1) * -1;
                //        StateContainer.Farms.Add(farm);
                //        TogglePendingSaveFarms(farm, null);
                //    }

                //    DiagService.Close();

                //    await FarmListGrid.Reload();
                // }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        public void Dispose()
        {
            //DiagService.OnOpen -= ModalOpen;
            //DiagService.OnClose -= ModalClose;
            StateContainer.OnChange -= StateHasChanged;
        }

        protected async Task OpenEditModal(DiseaseReportContactDetailsViewModel data)
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();
                // Model.personDetails = result;

                // dialogParams.Add("idfDisease", Model.idfDisease);
                dialogParams.Add("idfHumanCase", Model.idfHumanCase);
                dialogParams.Add("Model", data);
                dialogParams.Add("isEdit", true);
                //dialogParams.Add("personDetails", result);
                dialogParams.Add("accessToPersonalInfoData", accessToPersonalInfoData);
                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

                var locationViewModel = data.LocationViewModel;
                if (locationViewModel == null)
                {
                    locationViewModel = new LocationViewModel()
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
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        AdminLevel0Value = Convert.ToInt64(base.CountryID),
                        AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().Adminlevel2 : null,
                        AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().Adminlevel3 : null
                    };
                    // locationViewModel.AdminLevel0Value = data.idfsCountry;
                    locationViewModel.AdminLevel1Value = data.idfsRegion;
                    locationViewModel.AdminLevel2Value = data.idfsRayon;
                    locationViewModel.AdminLevel3Value = data.idfsSettlement;
                    locationViewModel.StreetText = data.strStreetName;
                    locationViewModel.PostalCodeText = data.strPostCode;
                    locationViewModel.House = data.strHouse;
                    locationViewModel.Building = data.strBuilding;
                    locationViewModel.Apartment = data.strApartment;
                }

                dialogParams.Add("locationViewModel", locationViewModel);

                if (isOutbreakCase)
                {
                    Model.ContactTracingFlexFormRequest.idfObservation = data.TracingObservationID;
                    dialogParams.Add("ContactTracingFlexFormRequest", Model.ContactTracingFlexFormRequest);
                }

                dynamic contactResult = await DiagService.OpenAsync<DiseaseReportContactAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                    dialogParams, new DialogOptions() { Width = "900px", Resizable = true, Draggable = false });

                if (contactResult == null)
                    return;

                if ((contactResult as EditContext).Validate())
                {
                    var contact = contactResult as EditContext;
                    DiseaseReportContactDetailsViewModel obj = (DiseaseReportContactDetailsViewModel)contactResult.Model;
                    DiseaseReportContactDetailsViewModel item = new DiseaseReportContactDetailsViewModel();

                    DiseaseReportContactDetailsViewModel oldItem = new DiseaseReportContactDetailsViewModel();
                    int count = 0;
                    if (Model.ContactDetails != null)
                    {
                        count = Model.ContactDetails.Count;
                        oldItem = Model.ContactDetails.Find(x => x.RowID == obj.RowID);
                        if (oldItem != null)
                        {
                            locationViewModel = obj.LocationViewModel;
                            count = Model.ContactDetails.Count;
                            item.RowID = obj.RowID;
                            item.strFirstName = obj.strFirstName;
                            item.strLastName = obj.strLastName;
                            item.strSecondName = obj.strSecondName;

                            item.idfsHumanGender = obj.idfsHumanGender;
                            item.idfCitizenship = obj.idfCitizenship;
                            item.datDateofBirth = obj.datDateofBirth;
                            item.Age = obj.Age;

                            item.idfContactedCasePerson = obj.idfContactedCasePerson;
                            item.strPlaceInfo = obj.strPlaceInfo;
                            item.idfsPersonContactType = obj.idfsPersonContactType;
                            item.strPersonContactType = obj.strPersonContactType;
                            item.strComments = obj.strComments;
                            item.datDateOfLastContact = obj.datDateOfLastContact;
                            item.strContactPhone = obj.strContactPhone;
                            item.idfContactPhoneType = obj.idfContactPhoneType;
                            item.RowAction = 2;
                            item.AddressID = obj.AddressID;

                            item.blnForeignAddress = obj.blnForeignAddress;
                            item.idfsCountry = locationViewModel.AdminLevel0Value;
                            item.idfsRegion = locationViewModel.AdminLevel1Value;
                            item.idfsRayon = locationViewModel.AdminLevel2Value;
                            item.idfsSettlement = locationViewModel.AdminLevel3Value;
                            item.strStreetName = locationViewModel.StreetText;
                            item.strPostCode = locationViewModel.PostalCodeText;
                            item.strHouse = locationViewModel.House;
                            item.strApartment = locationViewModel.Apartment;
                            item.strBuilding = locationViewModel.Building;
                            item.idfHumanActual = obj.idfHumanActual;
                            item.idfHuman = obj.idfHuman;
                            item.idfHumanCase = obj.idfHumanCase;
                            item.LocationViewModel = obj.LocationViewModel;
                            item.strPatientAddressString = obj.strPatientAddressString;

                            if (item.blnForeignAddress == false)
                            {
                                if (!string.IsNullOrEmpty(locationViewModel.PostalCodeText))
                                {
                                    item.strPatientAddressString = locationViewModel.PostalCodeText;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel0Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel0Text;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel1Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel1Text;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel2Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel2Text;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.AdminLevel3Text))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.AdminLevel3Text;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.StreetText))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.StreetText;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.House))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.House;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.Building))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.Building;
                                }
                                if (!string.IsNullOrEmpty(locationViewModel.Apartment))
                                {
                                    item.strPatientAddressString += "," + locationViewModel.Apartment;
                                }
                                if (!string.IsNullOrEmpty(obj.strContactPhone))
                                {
                                    item.strPatientAddressString += "," + obj.strContactPhone;
                                }
                                item.strPatientAddressString = item.strPatientAddressString.TrimStart(',');
                                item.strPatientAddressString = item.strPatientAddressString.TrimEnd(',');
                            }
                            // item.strPatientAddressString = locationViewModel.AdminLevel1Text + "," + locationViewModel.AdminLevel2Text + "," + locationViewModel.AdminLevel3Text;
                            if (Model.ContactDetails == null)
                                Model.ContactDetails = new List<DiseaseReportContactDetailsViewModel>();
                            Model.ContactDetails.Remove(oldItem);
                            Model.ContactDetails.Add(item);
                            if (_grid != null)
                            {
                                await _grid.Reload();
                                await JsRuntime.InvokeAsync<string>("SetContactsData", Model);
                                // StateContainer.SetHumanDiseaseReportSampleSessionStateViewModel(Model);
                            }
                        }
                    }
                }
                else
                {
                    //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                }

                //await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task DeleteRow(DiseaseReportContactDetailsViewModel item)
        {
            try
            {
                bool isDelete = false;
                if (Model.ContactDetails != null && Model.ContactDetails.Contains(item))
                {
                    foreach (var detail in Model.ContactDetails)
                    {
                        var result = await DiagService.Confirm(Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage), Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), new ConfirmOptions() { OkButtonText = "Yes", CancelButtonText = "No" });
                        if (result == true)
                        {
                            isDelete = true;
                        }
                        else
                        {
                            isDelete = false;
                        }
                        if (isDelete)
                        {
                            if (detail.RowID == item.RowID)
                            {
                                detail.RowStatus = 1;
                                await JsRuntime.InvokeAsync<string>("SetContactsData", Model);
                                Model.ContactDetails = Model.ContactDetails.Where(d => d.RowStatus == 0).ToList();
                                break;
                            }
                        }
                    }
                    await _grid.Reload();
                }
                else
                {
                    _grid.CancelEditRow(item);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }
}