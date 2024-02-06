#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Veterinary.SearchFarm;
using EIDSS.Web.Enumerations;
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
using static System.GC;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case
{
    /// <summary>
    /// </summary>
    public class ContactBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ContactBase> Logger { get; set; }
        [Inject] protected IConfigurationClient ConfigurationClient { get; set; }
        [Inject] protected IPersonClient PersonClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Case { get; set; }
        [Parameter] public ContactGetListViewModel Model { get; set; }
        [Parameter] public bool AddContactPremiseIndicator { get; set; }
        [Parameter] public bool ContactsTabIndicator { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<ContactGetListViewModel> Form { get; set; }
        protected RadzenDropDown<long?> ContactRelationshipTypeDropDown { get; set; }
        protected RadzenDropDown<long?> ContactStatusTypeDropDown { get; set; }
        protected RadzenDropDown<long?> CountryDropDown { get; set; }
        protected RadzenDatePicker<DateTime?> DateOfLastContactDatePicker { get; set; }
        protected RadzenTextBox PlaceOfLastContactTextBox { get; set; }
        protected RadzenTextArea ContactCommentsTextArea { get; set; }
        protected RadzenTextArea ForeignAddressStringTextArea { get; set; }
        public FlexForm.FlexForm ContactTracing { get; set; }
        public IEnumerable<BaseReferenceViewModel> ContactRelationshipTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> ContactStatusTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> ContactTypes { get; set; }
        public IEnumerable<CountryModel> Countries { get; set; }
        public bool IsLoading { get; set; }
        public bool CanEditIndicator { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        public ContactBase(CancellationToken token) : base(token)
        {
        }

        protected ContactBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            base.OnInitialized();

            _logger = Logger;

            IsLoading = true;

            CanEditIndicator = Model.ContactStatusID != (long) OutbreakContactStatusTypeEnum.ConvertToCase;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            FlexFormQuestionnaireGetRequestModel contactTracingFlexFormRequest = new()
            {
                idfObservation = Model.ContactTracingObservationID,
                idfsDiagnosis = Case.DiseaseId,
                LangID = GetCurrentLanguage()
            };

            switch (Case.CaseTypeId)
            {
                case (long) OutbreakSpeciesTypeEnum.Human:
                    contactTracingFlexFormRequest.idfsFormTemplate = Case.Session.HumanContactTracingTemplateID;
                    contactTracingFlexFormRequest.idfsFormType =
                        (long) FlexibleFormTypeEnum.HumanOutbreakCaseContactTracing;
                    break;
                case (long) OutbreakSpeciesTypeEnum.Avian:
                    contactTracingFlexFormRequest.idfsFormTemplate = Case.Session.AvianContactTracingTemplateID;
                    contactTracingFlexFormRequest.idfsFormType =
                        (long) FlexibleFormTypeEnum.AvianOutbreakCaseContactTracing;
                    break;
                case (long) OutbreakSpeciesTypeEnum.Livestock:
                    contactTracingFlexFormRequest.idfsFormTemplate = Case.Session.LivestockContactTracingTemplateID;
                    contactTracingFlexFormRequest.idfsFormType =
                        (long) FlexibleFormTypeEnum.LivestockOutbreakCaseContactTracing;
                    break;
            }

            Model.ContactTracingFlexFormRequest = contactTracingFlexFormRequest;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            await base.OnAfterRenderAsync(firstRender);

            if (firstRender)
            {
                ContactTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakContactType, HACodeList.NoneHACode);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            _disposedValue = true;
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetContactRelationshipTypes(LoadDataArgs args)
        {
            try
            {
                ContactRelationshipTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.PatientContactType, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    ContactRelationshipTypes = ContactRelationshipTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetContactStatusTypes(LoadDataArgs args)
        {
            try
            {
                ContactStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakContactStatus, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    ContactStatusTypes = ContactStatusTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetCountries(LoadDataArgs args)
        {
            try
            {
                Countries = await CrossCuttingClient.GetCountryList(GetCurrentLanguage());

                if (!IsNullOrEmpty(args.Filter))
                    Countries = Countries.Where(c =>
                        c.strCountryName != null &&
                        c.strCountryName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Foreign Address Indicator Change Event

        /// <summary>
        /// </summary>
        protected async Task OnForeignAddressIndicatorChange()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Add Contact Premise Button Click Event

        /// <summary>
        /// </summary>
        protected void OnAddContactPremiseButtonClick()
        {
            AddContactPremiseIndicator = true;
        }

        #endregion

        #region Search Contact Name Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchContactNameClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<SearchFarm>(
                    Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalSearchPersonHeading),
                    new Dictionary<string, object> {{"Mode", SearchModeEnum.Select}},
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        //Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result != null)
                    if (result is FarmViewModel record)
                    {
                        if (record.FarmOwnerID != null) Model.HumanMasterID = (long) record.FarmOwnerID;
                        Model.ContactName = record.FarmOwnerName;
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnSaveClick()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.CaseContactID)
            {
                case 0:
                {
                    Model.CaseContactID = (Case.Contacts.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                }
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            if (AddContactPremiseIndicator)
            {
                if (Model.ContactLocation.AdministrativeLevelId is null)
                {
                    //Get lowest administrative level for location
                    if (Model.ContactLocation.AdminLevel5Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel5Value.Value;
                    else if (Model.ContactLocation.AdminLevel4Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel4Value.Value;
                    if (Model.ContactLocation.AdminLevel3Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel3Value.Value;
                    else if (Model.ContactLocation.AdminLevel2Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel2Value.Value;
                    else if (Model.ContactLocation.AdminLevel1Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel1Value.Value;
                }

                dynamic request = new PersonSaveRequestModel
                {
                    CopyToHumanIndicator = false,
                    FirstName = Model.FirstName,
                    SecondName = Model.SecondName,
                    LastName = Model.LastName,
                    HumanidfsLocation = Model.ContactLocation.AdministrativeLevelId,
                    HumanstrStreetName = Model.ContactLocation.StreetText,
                    HumanstrApartment = Model.ContactLocation.Apartment,
                    HumanstrBuilding = Model.ContactLocation.Building,
                    HumanstrHouse = Model.ContactLocation.House,
                    HumanidfsPostalCode = Model.ContactLocation.PostalCodeText,
                    ContactPhone = Model.ContactPhone,
                    AuditUser = authenticatedUser.UserName
                };
                var response = await PersonClient.SavePerson(request);

                if (Model.OutbreakTypeID == (long)OutbreakTypeEnum.Veterinary)
                {
                    Model.HumanMasterID = response.HumanMasterID;
                    Model.ContactName = Model.LastName + (IsNullOrEmpty(Model.FirstName) ? "" : ", " + Model.FirstName);
                    request = new FarmSaveRequestModel
                    {
                        FarmCategory = Case.VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian
                            ? (long)FarmTypeEnum.Avian
                            : (long)FarmTypeEnum.Livestock,
                        FarmOwnerID = response.HumanMasterID,
                        FarmNationalName = Model.FarmName,
                        FarmAddressApartment = Model.ContactLocation.Apartment,
                        FarmAddressBuilding = Model.ContactLocation.Building,
                        FarmAddressHouse = Model.ContactLocation.House,
                        FarmAddressIdfsLocation = Model.ContactLocation.AdministrativeLevelId,
                        FarmAddressPostalCode = Model.ContactLocation.PostalCodeText,
                        FarmAddressStreet = Model.ContactLocation.StreetText,
                        FarmTypeID = Case.VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian
                            ? (long)FarmTypeEnum.Avian
                            : (long)FarmTypeEnum.Livestock,
                        Phone = Model.ContactPhone,
                        AuditUser = _tokenService.GetAuthenticatedUser().UserName
                    };
                    await VeterinaryClient.SaveFarm(request);
                }
            }

            if (Model.OutbreakTypeID == (long)OutbreakTypeEnum.Veterinary)
            {
                Model.ContactTypeID = ContactTypes
                .First(x => x.IdfsBaseReference == (long)OutbreakContactTypeEnum.Veterinary).IdfsBaseReference;
                Model.ContactTypeName = ContactTypes
                    .First(x => x.IdfsBaseReference == (long)OutbreakContactTypeEnum.Veterinary).Name;
            }
            else
            {
                Model.ContactTypeID = ContactTypes
                .First(x => x.IdfsBaseReference == (long)OutbreakContactTypeEnum.Human).IdfsBaseReference;
                Model.ContactTypeName = ContactTypes
                    .First(x => x.IdfsBaseReference == (long)OutbreakContactTypeEnum.Human).Name;
            }

            Model.ContactRelationshipTypeID = (ContactRelationshipTypeDropDown.SelectedItem as BaseReferenceViewModel)
                ?.IdfsBaseReference;
            Model.ContactRelationshipTypeName =
                (ContactRelationshipTypeDropDown.SelectedItem as BaseReferenceViewModel)?.Name;

            Model.ContactStatusID =
                (ContactStatusTypeDropDown.SelectedItem as BaseReferenceViewModel)?.IdfsBaseReference;
            Model.ContactStatusName = (ContactStatusTypeDropDown.SelectedItem as BaseReferenceViewModel)?.Name;

            Model.PlaceOfLastContact = PlaceOfLastContactTextBox.Value;
            Model.Comment = IsNullOrEmpty(ContactCommentsTextArea.Value) ? null : ContactCommentsTextArea.Value;

            if (ContactTracing is not null)
            {
                var response = await ContactTracing.CollectAnswers();
                await InvokeAsync(StateHasChanged);
                Model.ContactTracingFlexFormRequest.idfsFormTemplate = response.idfsFormTemplate;
                Model.ContactTracingFlexFormAnswers = ContactTracing.Answers;
                Model.ContactTracingObservationParameters = response.Answers;
            }

            if (ContactsTabIndicator)
                if (Model.ContactLocation.AdministrativeLevelId is null)
                {
                    //Get lowest administrative level for location
                    if (Model.ContactLocation.AdminLevel5Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel5Value.Value;
                    else if (Model.ContactLocation.AdminLevel4Value.HasValue)
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel4Value.Value;
                    if (Model.ContactLocation.AdminLevel3Value.HasValue)
                    {
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel3Value.Value;
                    }
                    else if (Model.ContactLocation.AdminLevel2Value.HasValue)
                    {
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel2Value.Value;
                        Model.CurrentLocation = Model.ContactLocation.AdminLevel2Text + " " +
                                                Model.ContactLocation.AdminLevel1Text;
                    }
                    else if (Model.ContactLocation.AdminLevel1Value.HasValue)
                    {
                        Model.ContactLocation.AdministrativeLevelId = Model.ContactLocation.AdminLevel1Value.Value;
                        Model.CurrentLocation = Model.ContactLocation.AdminLevel1Text;
                    }
                }

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
                }
                else
                {
                    DiagService.Close();
                }
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