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
        private long? foreignWorkCountryID;
        private string foreignWorkAddress;
        private LocationViewModel originalPersonEmploymentAddressLocationModel = new LocationViewModel();
        private LocationViewModel originalPersonSchoolAddressLocationModel = new LocationViewModel();
        
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

            Countries = await CrossCuttingClient.GetCountryList(GetCurrentLanguage());
            SaveOriginalLocationViewsState();

            await base.OnInitializedAsync();
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }


        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.PersonEmploymentSchoolSection.SetDotNetReference", _token, dotNetReference);
                await ToggleLocationControlReadOnly();
            }
        }

        #endregion

        #region Data Loading and Events

        public async Task RefreshComponent()
        {
            await EmploymentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonEmploymentAddressLocationModel);
            await SchoolAddressLocationViewComponent.RefreshComponent(StateContainer.PersonSchoolAddressLocationModel);
            await ToggleLocationControlReadOnly(StateContainer.WorkAddressSameAsCurrentAddress);
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

        public async Task MakeWorkSameAsCurrentAddress(bool isChecked)
        {
            if (isChecked)
            {
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

                StateContainer.IsForeignWorkAddress = false;
                await ResetWorkAddress(false);
            }
            else
            {
                // restore values from local variables
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value = null;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value = null;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value = null;
                StateContainer.PersonEmploymentAddressLocationModel.SettlementType = null;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value = null;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text = null;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text = null;
                StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text = null;
                StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText = null;
                StateContainer.PersonEmploymentAddressLocationModel.StreetText = null;
                StateContainer.PersonEmploymentAddressLocationModel.House = null;
                StateContainer.PersonEmploymentAddressLocationModel.Building = null;
                StateContainer.PersonEmploymentAddressLocationModel.Apartment = null;
            }

            await RefreshComponent();
        }

        public async Task ResetWorkAddress(bool isChecked)
        {
            if (isChecked)
            {
                StateContainer.WorkAddressSameAsCurrentAddress = false;
                await MakeWorkSameAsCurrentAddress(false);
            }

            StateContainer.ForeignWorkCountryID = null;
            StateContainer.ForeignWorkAddress = null;
        }

        private async Task ToggleLocationControlReadOnly(bool value)
        {
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel1 = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel2 = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel3 = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel4 = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel5 = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableAdminLevel6 = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableSettlement = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableSettlementType = !value;
            StateContainer.PersonEmploymentAddressLocationModel.OperationType = value? LocationViewOperationType.ReadOnly : null;
            StateContainer.PersonEmploymentAddressLocationModel.EnablePostalCode = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableStreet = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableHouse = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableBuilding = !value;
            StateContainer.PersonEmploymentAddressLocationModel.EnableApartment = !value;

            await InvokeAsync(StateHasChanged);
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
            if (StateContainer.IsReadOnly)
            {
                SaveOriginalLocationViewsState();

                StateContainer.PersonEmploymentAddressLocationModel.SetFrom(LocationViewModel.DisableTemplate);
                StateContainer.PersonSchoolAddressLocationModel.SetFrom(LocationViewModel.DisableTemplate);
            }
            else 
            {
                StateContainer.PersonEmploymentAddressLocationModel.SetFrom(originalPersonEmploymentAddressLocationModel);
                StateContainer.PersonEmploymentAddressLocationModel.OperationType = null;
                StateContainer.PersonSchoolAddressLocationModel.SetFrom(originalPersonSchoolAddressLocationModel);
                StateContainer.PersonSchoolAddressLocationModel.OperationType = null;
            }

            await InvokeAsync(StateHasChanged);
        }

        private void SaveOriginalLocationViewsState()
        {
            originalPersonEmploymentAddressLocationModel.SetFrom(StateContainer.PersonEmploymentAddressLocationModel);
            originalPersonSchoolAddressLocationModel.SetFrom(StateContainer.PersonSchoolAddressLocationModel);
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
            if (StateContainer.WorkAddressSameAsCurrentAddress)
            {
                await RefreshComponent();
            }
        }

        #endregion SetPersonDisabledIndicators

        #endregion
    }
}
