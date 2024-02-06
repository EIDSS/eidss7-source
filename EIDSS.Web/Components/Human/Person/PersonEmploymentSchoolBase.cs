#region Usings

using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Components.Human.SearchPerson;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
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

#endregion

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonEmploymentSchoolBase : PersonBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        public ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private ILogger<PersonEmploymentSchoolBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies        

        #region Properties

        protected RadzenTemplateForm<PersonStateContainer> Form { get; set; }
        protected IEnumerable<BaseReferenceViewModel> OccupationTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> YesNoUnknownList { get; set; }
        protected List<CountryModel> Countries { get; set; }
        protected RadzenTextBox EmployerNameControl { get; set; }
        protected RadzenTextBox EmployerPhoneNumberControl { get; set; }
        protected RadzenTextBox SchoolNameControl { get; set; }
        protected RadzenTextBox ForeignWorkAddressControl { get; set; }
        protected RadzenTextBox ForeignSchoolAddressControl { get; set; }
        protected RadzenTextBox SchoolPhoneNumberControl { get; set; }

        protected LocationView SchoolAddressLocationViewComponent;
        protected LocationView EmploymentAddressLocationViewComponent;

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
            _logger = Logger;

            //Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            YesNoUnknownList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.YesNoValueList, null); //TODO YesNoUnknown Localization

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
                StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.PersonEmploymentSchoolSection.SetDotNetReference", _token, dotNetReference);

                await EmploymentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonEmploymentAddressLocationModel);
                await SchoolAddressLocationViewComponent.RefreshComponent(StateContainer.PersonSchoolAddressLocationModel);

            }
        }

        #endregion

        #region Data Loading and Events

        public async Task RefreshComponent()
        {
            await EmploymentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonEmploymentAddressLocationModel);
            await SchoolAddressLocationViewComponent.RefreshComponent(StateContainer.PersonSchoolAddressLocationModel);

        }

        protected void UpdateEmploymentAddressHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.PersonEmploymentAddressLocationModel = locationViewModel;
        }

        protected void UpdateSchoolAddressHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.PersonSchoolAddressLocationModel = locationViewModel;
        }


        private async Task OnStateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        public async Task GetOccupationTypesAsync(LoadDataArgs args)
        {
            try
            {
                OccupationTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.OccupationType, null);
                if (!IsNullOrEmpty(args.Filter))
                {
                    List<BaseReferenceViewModel> toList = OccupationTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    OccupationTypes = toList;
                }

                await InvokeAsync(StateHasChanged);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OccupationTypeChangedAsync(object value)
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

        protected async Task CountryChangedAsync(object value)
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

        public void SetEmploymentHidden(long? value)
        {
            if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
            {
                StateContainer.IsEmploymentHidden = false;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.No))
            {
                StateContainer.IsEmploymentHidden = true;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Unknown))
            {
                StateContainer.IsEmploymentHidden = true;
            }
        }

        public void SetSchoolHidden(long? value)
        {
            if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
            {
                StateContainer.IsSchoolHidden = false;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.No))
            {
                StateContainer.IsSchoolHidden = true;
            }
            else if (value == Convert.ToInt64(EIDSSConstants.YesNoValueList.Unknown))
            {
                StateContainer.IsSchoolHidden = true;
            }
        }

        public void WorkSameAsCurrentAddress(bool isChecked)
        {
            if (isChecked)
            {
                // save the perm address location to local variables before overriding with current address
                adminLevel0Value = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value;
                adminLevel1Value = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value;
                adminLevel2Value = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value;
                settlementType = StateContainer.PersonEmploymentAddressLocationModel.SettlementType;
                adminLevel3Value = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value;
                adminLevel1Text = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text;
                adminLevel2Text = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text;
                adminLevel3Text = StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text;
                postalCodeText = StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText;
                streetText = StateContainer.PersonEmploymentAddressLocationModel.StreetText;
                house = StateContainer.PersonEmploymentAddressLocationModel.House;
                building = StateContainer.PersonEmploymentAddressLocationModel.Building;
                apartment = StateContainer.PersonEmploymentAddressLocationModel.Apartment;

                // override perm address
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value;
                StateContainer.PersonEmploymentAddressLocationModel.SettlementType = StateContainer.PersonCurrentAddressLocationModel.SettlementType;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value = StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value;

                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text = StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text = StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text = StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text;

                StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText = StateContainer.PersonCurrentAddressLocationModel.PostalCodeText;
                StateContainer.PersonEmploymentAddressLocationModel.StreetText = StateContainer.PersonCurrentAddressLocationModel.StreetText;
                StateContainer.PersonEmploymentAddressLocationModel.House = StateContainer.PersonCurrentAddressLocationModel.House;
                StateContainer.PersonEmploymentAddressLocationModel.Building = StateContainer.PersonCurrentAddressLocationModel.Building;
                StateContainer.PersonEmploymentAddressLocationModel.Apartment = StateContainer.PersonCurrentAddressLocationModel.Apartment;
            }
            else
            {
                // restore values from local variables
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value = adminLevel0Value;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value = adminLevel1Value;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value = adminLevel2Value;
                StateContainer.PersonEmploymentAddressLocationModel.SettlementType = settlementType;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value = adminLevel3Value;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text = adminLevel1Text;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text = adminLevel2Text;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text = adminLevel3Text;
                StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText = postalCodeText;
                StateContainer.PersonEmploymentAddressLocationModel.StreetText = streetText;
                StateContainer.PersonEmploymentAddressLocationModel.House = house;
                StateContainer.PersonEmploymentAddressLocationModel.Building = building;
                StateContainer.PersonEmploymentAddressLocationModel.Apartment = apartment;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [JSInvokable()]
        public bool ValidateSection()
        {
            if (Form.IsValid)
                StateContainer.PersonEmploymentSchoolSectionValidIndicator = true;

            return StateContainer.PersonEmploymentSchoolSectionValidIndicator;
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

        #region SetPersonDisabledIndicator

        private async Task ToggleLocationControlReadOnly()
        {
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel1 = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel2 = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel3 = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel4 = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel5 = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel6 = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableSettlement = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableSettlementType = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.OperationType = StateContainer.IsReadOnly ? LocationViewOperationType.ReadOnly : null;
            StateContainer.PersonEmploymentAddressLocationModel.EnablePostalCode = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableStreet = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableHouse = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableBuilding = !StateContainer.IsReadOnly;
            StateContainer.PersonEmploymentAddressLocationModel.EnableApartment = !StateContainer.IsReadOnly;

            StateContainer.PersonSchoolAddressLocationModel.EnableAdminLevel1 = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableAdminLevel2 = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableAdminLevel3 = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableAdminLevel4 = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableAdminLevel5 = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableAdminLevel6 = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableSettlement = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableSettlementType = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.OperationType = StateContainer.IsReadOnly ? LocationViewOperationType.ReadOnly : null;
            StateContainer.PersonSchoolAddressLocationModel.EnablePostalCode = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableStreet = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableHouse = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableBuilding = !StateContainer.IsReadOnly;
            StateContainer.PersonSchoolAddressLocationModel.EnableApartment = !StateContainer.IsReadOnly;

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

        #endregion SetPersonDisabledIndicators

        #endregion
    }
}
