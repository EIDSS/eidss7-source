#region Usings

using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.String;
using EIDSS.Web.Components.Shared;
using Microsoft.CodeAnalysis;

#endregion

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonAddressSectionBase : PersonBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] public ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private ILogger<PersonAddressSectionBase> PersonAddressSectionLogger { get; set; }

        #endregion Dependencies        

        #region Properties

        protected RadzenTemplateForm<PersonStateContainer> Form { get; set; }
        protected RadzenTextBox PhoneNumberControl { get; set; }
        protected RadzenTextBox PhoneNumber2Control { get; set; }
        protected IEnumerable<BaseReferenceViewModel> PhoneNumberTypes { get; set; }
        protected List<CountryModel> Countries { get; set; }
        protected RadzenTextBox ForeignAlternateAddressControl { get; set; }
        //protected bool IsAnotherPhoneNumberHidden { get; set; } = true;
        //protected bool IsAnotherAddressHidden { get; set; } = true;
        protected bool IsForeignAlternateAddressHidden { get; set; } = true;
        protected bool IsAlternateAddressHidden { get; set; } = false;
        protected IEnumerable<BaseReferenceViewModel> YesNoUnknownList { get; set; }

        protected LocationView CurrentAddressLocationViewComponent;
        protected LocationView PermanentAddressLocationViewComponent;
        protected LocationView AlternateAddressLocationViewComponent;



        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        long? adminLevel0Value;
        long? adminLevel1Value;
        long? adminLevel2Value;
        long? settlementType;
        long? adminLevel3Value;
        string adminLevel1Text;
        string adminLevel2Text;
        string adminLevel3Text;
        string postalCodeText;
        string streetText;
        string house;
        string building;
        string apartment;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = PersonAddressSectionLogger;

            //Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            YesNoUnknownList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.YesNoValueList, null);

            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        public void Dispose()
        {
            StateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
            _source?.Cancel();
            _source?.Dispose();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.PersonAddressSection.SetDotNetReference", _token, dotNetReference);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        #endregion

        #region Data Loading and Events

        public async Task RefreshComponent()
        {
            await CurrentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonCurrentAddressLocationModel);
            await PermanentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonPermanentAddressLocationModel);
            await AlternateAddressLocationViewComponent.RefreshComponent(StateContainer.PersonAlternateAddressLocationModel);

        }

        protected void UpdateCurrentAddressHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.PersonCurrentAddressLocationModel = locationViewModel;

            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value = locationViewModel.AdminLevel0Value;
            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value = locationViewModel.AdminLevel1Value;
            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value = locationViewModel.AdminLevel2Value;
            //StateContainer.PersonCurrentAddressLocationModel.SettlementType = locationViewModel.SettlementType;
            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value = locationViewModel.SettlementId;

            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text = locationViewModel.AdminLevel1Text;
            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text = locationViewModel.AdminLevel1Text;
            //StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text = locationViewModel.AdminLevel3Text;

            //StateContainer.PersonCurrentAddressLocationModel.PostalCodeText = locationViewModel.PostalCodeText;
            //StateContainer.PersonCurrentAddressLocationModel.Latitude = locationViewModel.Latitude;
            //StateContainer.PersonCurrentAddressLocationModel.Longitude = locationViewModel.Longitude;
            //StateContainer.PersonCurrentAddressLocationModel.StreetText = locationViewModel.StreetText;
            //StateContainer.PersonCurrentAddressLocationModel.House = locationViewModel.House;
            //StateContainer.PersonCurrentAddressLocationModel.Building = locationViewModel.Building;
            //StateContainer.PersonCurrentAddressLocationModel.Apartment = locationViewModel.Apartment;

        }

        protected void UpdatePermanentAddressHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.PersonPermanentAddressLocationModel = locationViewModel;

            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value = locationViewModel.AdminLevel0Value;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value = locationViewModel.AdminLevel1Value;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value = locationViewModel.AdminLevel2Value;
            //StateContainer.PersonPermanentAddressLocationModel.SettlementType = locationViewModel.SettlementType;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value = locationViewModel.SettlementId;

            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text = locationViewModel.AdminLevel1Text;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text = locationViewModel.AdminLevel1Text;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text = locationViewModel.AdminLevel3Text;

            //StateContainer.PersonPermanentAddressLocationModel.PostalCodeText = locationViewModel.PostalCodeText;
            //StateContainer.PersonPermanentAddressLocationModel.Latitude = locationViewModel.Latitude;
            //StateContainer.PersonPermanentAddressLocationModel.Longitude = locationViewModel.Longitude;
            //StateContainer.PersonPermanentAddressLocationModel.StreetText = locationViewModel.StreetText;
            //StateContainer.PersonPermanentAddressLocationModel.House = locationViewModel.House;
            //StateContainer.PersonPermanentAddressLocationModel.Building = locationViewModel.Building;
            //StateContainer.PersonPermanentAddressLocationModel.Apartment = locationViewModel.Apartment;

        }

        protected void UpdateAlternateAddressHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.PersonAlternateAddressLocationModel = locationViewModel;

            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value = locationViewModel.AdminLevel0Value;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value = locationViewModel.AdminLevel1Value;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value = locationViewModel.AdminLevel2Value;
            //StateContainer.PersonPermanentAddressLocationModel.SettlementType = locationViewModel.SettlementType;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value = locationViewModel.SettlementId;

            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text = locationViewModel.AdminLevel1Text;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text = locationViewModel.AdminLevel1Text;
            //StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text = locationViewModel.AdminLevel3Text;

            //StateContainer.PersonPermanentAddressLocationModel.PostalCodeText = locationViewModel.PostalCodeText;
            //StateContainer.PersonPermanentAddressLocationModel.Latitude = locationViewModel.Latitude;
            //StateContainer.PersonPermanentAddressLocationModel.Longitude = locationViewModel.Longitude;
            //StateContainer.PersonPermanentAddressLocationModel.StreetText = locationViewModel.StreetText;
            //StateContainer.PersonPermanentAddressLocationModel.House = locationViewModel.House;
            //StateContainer.PersonPermanentAddressLocationModel.Building = locationViewModel.Building;
            //StateContainer.PersonPermanentAddressLocationModel.Apartment = locationViewModel.Apartment;

        }

        private async Task OnStateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        public async Task GetPhoneNumberTypesAsync(LoadDataArgs args)
        {
            try
            {
                PhoneNumberTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.ContactPhoneType, null);
                if (!IsNullOrEmpty(args.Filter))
                {
                    List<BaseReferenceViewModel> toList = PhoneNumberTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    PhoneNumberTypes = toList;
                }
                await InvokeAsync(StateHasChanged);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void PhoneNumberTypeChangedAsync(object value)
        {
            //if (Convert.ToInt64(value) == EIDSSConstants.PersonalIDTypes.Unknown)
            //{
            //    model.SearchCriteria.PersonalID = null;
            //    personalIDDisabled = true;
            //}
            //else
            //{
            //    personalIDDisabled = false;
            //}
            //await InvokeAsync(StateHasChanged);
        }

        public async Task GetCountriesAsync(LoadDataArgs args)
        {
            try
            {
                Countries = await CrossCuttingClient.GetCountryList(GetCurrentLanguage());
                await InvokeAsync(StateHasChanged);

                //model.PersonEmploymentSchoolSection.WorkCountryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
                //model.PersonEmploymentSchoolSection.WorkCountryList.Insert(0, item2);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void CountryChangedAsync(object value)
        {
            //if (Convert.ToInt64(value) == EIDSSConstants.PersonalIDTypes.Unknown)
            //{
            //    model.SearchCriteria.PersonalID = null;
            //    personalIDDisabled = true;
            //}
            //else
            //{
            //    personalIDDisabled = false;
            //}
            //await InvokeAsync(StateHasChanged);
        }

        public void SetAnotherPhoneNumberHidden(long? value)
        {

            if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
            {
                StateContainer.IsAnotherPhoneNumberHidden = false;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.No))
            {
                StateContainer.IsAnotherPhoneNumberHidden = true;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Unknown))
            {
                StateContainer.IsAnotherPhoneNumberHidden = true;
            }

        }

        public void SetAnotherAddressHidden(long? value)
        {
            if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
            {
                StateContainer.IsAnotherAddressHidden = false;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.No))
            {
                StateContainer.IsAnotherAddressHidden = true;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Unknown))
            {
                StateContainer.IsAnotherAddressHidden = true;
            }
        }

        public async Task PermSameAsCurrentAddress(bool isChecked)
        {
            if (isChecked)
            {
                // save the perm address location to local variables before overriding with current address
                adminLevel0Value = StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value;
                adminLevel1Value = StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value;
                adminLevel2Value = StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value;
                settlementType = StateContainer.PersonPermanentAddressLocationModel.SettlementType;
                adminLevel3Value = StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value;
                adminLevel1Text = StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text;
                adminLevel2Text = StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text;
                adminLevel3Text = StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text;
                postalCodeText = StateContainer.PersonPermanentAddressLocationModel.PostalCodeText;
                streetText = StateContainer.PersonPermanentAddressLocationModel.StreetText;
                house = StateContainer.PersonPermanentAddressLocationModel.House;
                building = StateContainer.PersonPermanentAddressLocationModel.Building;
                apartment = StateContainer.PersonPermanentAddressLocationModel.Apartment;

                // override perm address
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value;
                StateContainer.PersonPermanentAddressLocationModel.SettlementType = StateContainer.PersonCurrentAddressLocationModel.SettlementType;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value;

                StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text = StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text = StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text = StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text;

                StateContainer.PersonPermanentAddressLocationModel.PostalCodeText = StateContainer.PersonCurrentAddressLocationModel.PostalCodeText;
                StateContainer.PersonPermanentAddressLocationModel.StreetText = StateContainer.PersonCurrentAddressLocationModel.StreetText;
                StateContainer.PersonPermanentAddressLocationModel.House = StateContainer.PersonCurrentAddressLocationModel.House;
                StateContainer.PersonPermanentAddressLocationModel.Building = StateContainer.PersonCurrentAddressLocationModel.Building;
                StateContainer.PersonPermanentAddressLocationModel.Apartment = StateContainer.PersonCurrentAddressLocationModel.Apartment;

            }
            else
            {
                // restore values from local variables
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value = adminLevel0Value;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value = adminLevel1Value;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value = adminLevel2Value;
                StateContainer.PersonPermanentAddressLocationModel.SettlementType = settlementType;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value = adminLevel3Value;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text = adminLevel1Text;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text = adminLevel2Text;
                StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text = adminLevel3Text;
                StateContainer.PersonPermanentAddressLocationModel.PostalCodeText = postalCodeText;
                StateContainer.PersonPermanentAddressLocationModel.StreetText = streetText;
                StateContainer.PersonPermanentAddressLocationModel.House = house;
                StateContainer.PersonPermanentAddressLocationModel.Building = building;
                StateContainer.PersonPermanentAddressLocationModel.Apartment = apartment;

            }
            await PermanentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonPermanentAddressLocationModel);

        }

        public void ToggleForeignAlternateAddress(bool value)
        {
            IsAlternateAddressHidden = value;
            IsForeignAlternateAddressHidden = !value;
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [JSInvokable()]
        public async Task<bool> ValidateSection()
        {
            await InvokeAsync(StateHasChanged);

            Form.EditContext.Validate();

            StateContainer.PersonAddressSectionValidIndicator = Form.IsValid;

            return StateContainer.PersonAddressSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion

        #region Set ReportDisabledIndicator

        private async Task ToggleLocationControlReadOnly()
        {
            StateContainer.PersonCurrentAddressLocationModel.EnableAdminLevel1 = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableAdminLevel2 = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableAdminLevel3 = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableAdminLevel4 = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableAdminLevel5 = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableAdminLevel6 = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableSettlement = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableSettlementType = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.OperationType = StateContainer.IsReadOnly ? LocationViewOperationType.ReadOnly : null;
            StateContainer.PersonCurrentAddressLocationModel.EnablePostalCode = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableStreet = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableHouse = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableBuilding = !StateContainer.IsReadOnly;
            StateContainer.PersonCurrentAddressLocationModel.EnableApartment = !StateContainer.IsReadOnly;

            StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel1 = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel2 = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel3 = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel4 = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel5 = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel6 = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableSettlement = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableSettlementType = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.OperationType = StateContainer.IsReadOnly ? LocationViewOperationType.ReadOnly : null;
            StateContainer.PersonPermanentAddressLocationModel.EnablePostalCode = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableStreet = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableHouse = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableBuilding = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.EnableApartment = !StateContainer.IsReadOnly;
            StateContainer.PersonPermanentAddressLocationModel.ShowLatitude = false;
            StateContainer.PersonPermanentAddressLocationModel.ShowLongitude = false;
            StateContainer.PersonPermanentAddressLocationModel.ShowMap = false;

            StateContainer.PersonAlternateAddressLocationModel.EnableAdminLevel1 = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableAdminLevel2 = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableAdminLevel3 = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableAdminLevel4 = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableAdminLevel5 = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableAdminLevel6 = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableSettlement = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableSettlementType = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.OperationType = StateContainer.IsReadOnly ? LocationViewOperationType.ReadOnly : null;
            StateContainer.PersonAlternateAddressLocationModel.EnablePostalCode = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableStreet = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableHouse = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableBuilding = !StateContainer.IsReadOnly;
            StateContainer.PersonAlternateAddressLocationModel.EnableApartment = !StateContainer.IsReadOnly;

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("SetPersonDisabledIndicator")]
        public async Task SetPersonDisabledIndicator(int currentIndex)
        {
            if (currentIndex == 3) //review section
            {
                StateContainer.IsReadOnly = true;
                StateContainer.IsReview = true;
            }
            else
            {
                StateContainer.IsReadOnly = false;
                StateContainer.IsReview = false;
            }

            await ToggleLocationControlReadOnly();
        }

        #endregion Set ReportDisabledIndicators

    }
}
