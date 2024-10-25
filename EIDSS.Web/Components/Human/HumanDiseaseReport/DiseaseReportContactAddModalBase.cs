
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Laboratory;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Components.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Web.ViewModels.Administration;
using EIDSS.Web.Components.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using Microsoft.JSInterop;
using EIDSS.Domain.RequestModels.FlexForm;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportContactAddModalBase : BaseComponent
    {
        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private IHumanDiseaseReportClient humanDiseaseReportClient { get; set; }

        [Inject]
        ILogger<DiseaseReportSampleAddModalBase> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        ProtectedSessionStorage ProtectedSessionStore { get; set; }

        [Parameter]
        public DiseaseReportContactDetailsViewModel Model { get; set; } = new ();

        [Parameter]
        public LocationViewModel locationViewModel { get; set; }

        [Parameter]
        public bool isOutbreakCase { get; set; } = false;
        [Parameter]
        public FlexFormQuestionnaireGetRequestModel ContactTracingFlexFormRequest { get; set; }

        [Parameter]
        public long? idfHumanCase { get; set; }

        [Parameter]

        public long? idfHumanActual { get; set; }

        [Parameter]
        public bool isEdit { get; set; } = false;

        public DiseaseReportContactDetailsViewModel contactDetailModal { get; set; }

        [Parameter]
        public PersonViewModel personDetails { get; set; }

        [Parameter]
        public bool accessToPersonalInfoData { get; set; }

        protected RadzenTemplateForm<DiseaseReportContactDetailsViewModel> _form;
        public FlexForm.FlexForm ff { get; set; }

        protected EditContext EditContext { get; set; }

        protected bool? enableLocation { get; set; } = false;

        protected bool? enableForeignLocation { get; set; } = false;

        protected IEnumerable<BaseReferenceViewModel> genderIDTypes;

        protected IEnumerable<BaseReferenceViewModel> nationalityList;

        protected IEnumerable<BaseReferenceViewModel> patientContactType;

        protected IEnumerable<BaseReferenceViewModel> contactPhoneType;

        protected IEnumerable<CountryModel> foreignCountry;

        protected async override Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;

                contactDetailModal = Model;
                EditContext = new(contactDetailModal);

                contactDetailModal.LocationViewModel = locationViewModel;

                if (!isEdit)
                {
                    if (accessToPersonalInfoData)
                    {
                        contactDetailModal.strFirstName = personDetails.FirstOrGivenName;
                        contactDetailModal.strLastName = personDetails.LastOrSurname;
                        contactDetailModal.strSecondName = personDetails.SecondName;
                        contactDetailModal.idfsHumanGender = personDetails.GenderTypeID;
                        contactDetailModal.datDateofBirth = personDetails.DateOfBirth;
                        if (contactDetailModal.datDateofBirth != null)
                        {
                            contactDetailModal.Age = get_age(contactDetailModal.datDateofBirth);
                        }
                    }
                    else
                    {
                        contactDetailModal.strFirstName = "********";
                        contactDetailModal.strLastName = "********";
                        contactDetailModal.strSecondName = "********";
                    }

                    contactDetailModal.idfContactPhoneType = personDetails.ContactPhoneNbrTypeID;
                    contactDetailModal.idfCitizenship = personDetails.CitizenshipTypeID;
                    contactDetailModal.strContactPhone = personDetails.ContactPhoneCountryCode + "" + personDetails.ContactPhoneNumber;
                    contactDetailModal.idfContactedCasePerson = personDetails.HumanMasterID;
                    contactDetailModal.AddressID = personDetails.AddressID;
                    contactDetailModal.idfHumanActual = personDetails.HumanMasterID;
                }

                contactDetailModal.idfHumanCase = idfHumanCase;
                await EnableLocation(contactDetailModal.blnForeignAddress);
                contactDetailModal.idfsRegion = locationViewModel.AdminLevel1Value;
                contactDetailModal.idfsRayon = locationViewModel.AdminLevel2Value;
                contactDetailModal.idfsSettlement = locationViewModel.AdminLevel3Value;
                contactDetailModal.strStreetName = locationViewModel.StreetText;
                contactDetailModal.strPostCode = locationViewModel.PostalCodeText;
                contactDetailModal.strHouse = locationViewModel.House;
                contactDetailModal.strBuilding = locationViewModel.Building;
                contactDetailModal.strApartment = locationViewModel.Apartment;

                patientContactType = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.PatientContactType, null);
                await UpdateRelation(Model.idfsPersonContactType);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }

        }

        public int get_age(DateTime? dob)
        {
            try
            {
                int age = 0;
                age = DateTime.Now.Subtract(dob.Value).Days;
                age = age / 365;
                return age;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            contactDetailModal.LocationViewModel = locationViewModel;
        }

        protected async Task GetGenderTypesAsync(LoadDataArgs args)
        {
            try
            {
                genderIDTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.HumanGender, null);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }
        protected async Task GetNationalityListAsync(LoadDataArgs args)
        {
            try
            {
                nationalityList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.NationalityList, null);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task GetContactPhoneTypeAsync(LoadDataArgs args)
        {
            try
            {
                contactPhoneType = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.ContactPhoneType, null);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task GetForeignCountry(LoadDataArgs args)
        {
            try
            {
                foreignCountry = await CrossCuttingClient.GetCountryList(GetCurrentLanguage());
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateRelation(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    var h = patientContactType.Where(x => x.IdfsBaseReference == long.Parse(Value.ToString()));
                    if (h != null && h.Count() > 0)
                    {
                        contactDetailModal.strPersonContactType = h.FirstOrDefault().Name ?? h.FirstOrDefault().StrDefault;
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task EnableLocation(bool? Value)
        {
            try
            {
                //var enableflag = (bool)Value;
                if (Value == true)
                {
                    enableLocation = true;
                    enableForeignLocation = false;
                    contactDetailModal.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                    contactDetailModal.LocationViewModel.IsDbRequiredAdminLevel2 = false;
                    contactDetailModal.LocationViewModel.IsDbRequiredAdminLevel1 = false;

                }
                else
                {
                    enableLocation = false;
                    enableForeignLocation = true;
                    contactDetailModal.LocationViewModel.IsDbRequiredAdminLevel3 = false; // settlement is not required
                    contactDetailModal.LocationViewModel.IsDbRequiredAdminLevel2 = true;
                    contactDetailModal.LocationViewModel.IsDbRequiredAdminLevel1 = true;

                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleValidContactSubmit(DiseaseReportContactDetailsViewModel model)
        {
            try
            {

                if (_form.IsValid)
                {
                    if (isOutbreakCase)
                    {
                        await ff.SaveFlexForm();
                    }

                    // just return even if unmodified
                    DiagService.Close(EditContext);

                    //if (_form.EditContext.IsModified())
                    //{
                    //    DiagService.Close(EditContext);
                    //}
                    //else
                    //{
                    //    DiagService.Close(null);
                    //}
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleInvalidContactSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                //TODO - display the validation Errors on the dialog?  
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.FieldIsRequiredMessage));
                // await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult)
                {
                    //do nothing because it is just the ok button
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

    }
}
