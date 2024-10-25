using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Components.Shared;

namespace EIDSS.Web.Components.Human.Person;

public class PersonAddressSectionBase : PersonBaseComponent
{
    [Inject] public ICrossCuttingClient CrossCuttingClient { get; set; }
    [Inject] private ILogger<PersonAddressSectionBase> PersonAddressSectionLogger { get; set; }

    protected RadzenTemplateForm<PersonStateContainer> Form { get; set; }
    protected IEnumerable<BaseReferenceViewModel> PhoneNumberTypes { get; private set; }
    protected List<CountryModel> Countries { get; private set; }

    protected LocationView CurrentAddressLocationViewComponent;
    protected LocationView PermanentAddressLocationViewComponent;
    protected LocationView AlternateAddressLocationViewComponent;
    protected PersonHeader PersonHeaderComponent;

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
    private LocationViewModel originalPersonCurrentAddressLocationModel = new LocationViewModel();
    private LocationViewModel originalPersonPermanentAddressLocationModel = new LocationViewModel();
    private LocationViewModel originalPersonAlternateAddressLocationModel = new LocationViewModel();

    protected override async Task OnInitializedAsync()
    {
        _logger = PersonAddressSectionLogger;

        //Reset the cancellation token
        _source = new CancellationTokenSource();
        _token = _source.Token;

        PhoneNumberTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.ContactPhoneType, null);
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
            await JsRuntime.InvokeVoidAsync("PersonAddEdit.PersonAddressSection.SetDotNetReference", _token, dotNetReference);
            await ToggleLocationControlReadOnly();
        }

        await base.OnAfterRenderAsync(firstRender);
    }

    public async Task RefreshComponent()
    {
        await CurrentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonCurrentAddressLocationModel);
        await PermanentAddressLocationViewComponent.RefreshComponent(StateContainer.PersonPermanentAddressLocationModel);
        await AlternateAddressLocationViewComponent.RefreshComponent(StateContainer.PersonAlternateAddressLocationModel);
        await AlternateAddressLocationViewComponent.RefreshComponent(StateContainer.PersonAlternateAddressLocationModel);
    }

    protected async Task UpdateCurrentAddressHandlerAsync(LocationViewModel locationViewModel)
    {
        StateContainer.PersonCurrentAddressLocationModel = locationViewModel;

        if (StateContainer.WorkAddressSameAsCurrentAddress)
        {
            UpdateWorkAddressModel();
        }

        if (StateContainer.PermanentAddressSameAsCurrentAddress)
        {
            await PermSameAsCurrentAddress(true);
        }
    }

    protected void UpdatePermanentAddressHandlerAsync(LocationViewModel locationViewModel)
    {
        StateContainer.PersonPermanentAddressLocationModel = locationViewModel;
    }

    protected void UpdateAlternateAddressHandlerAsync(LocationViewModel locationViewModel)
    {
        StateContainer.PersonAlternateAddressLocationModel = locationViewModel;
    }

    private async Task OnStateContainerChangeAsync(string _)
    {
        await InvokeAsync(StateHasChanged);
    }

    private void UpdateWorkAddressModel()
    {
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

    protected async Task PermSameAsCurrentAddress(bool isChecked)
    {
        if (isChecked)
        {
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
        await ToggleLocationControlReadOnly(StateContainer.PermanentAddressSameAsCurrentAddress);
    }

    private async Task ToggleLocationControlReadOnly(bool value)
    {
        StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel1 = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel2 = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel3 = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel4 = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel5 = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableAdminLevel6 = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableSettlement = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableSettlementType = !value;
        StateContainer.PersonPermanentAddressLocationModel.OperationType = value ? LocationViewOperationType.ReadOnly : null;
        StateContainer.PersonPermanentAddressLocationModel.EnablePostalCode = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableStreet = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableHouse = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableBuilding = !value;
        StateContainer.PersonPermanentAddressLocationModel.EnableApartment = !value;

        await InvokeAsync(StateHasChanged);
    }

    [JSInvokable()]
    public async Task<bool> ValidateSection()
    {
        await InvokeAsync(StateHasChanged);

        Form.EditContext.Validate();

        StateContainer.PersonAddressSectionValidIndicator = Form.IsValid;

        return StateContainer.PersonAddressSectionValidIndicator;
    }

    [JSInvokable]
    public async Task ReloadSection()
    {
        await InvokeAsync(StateHasChanged);
    }

    private async Task ToggleLocationControlReadOnly()
    {
        if (StateContainer.IsReadOnly)
        {
            SaveOriginalLocationViewsState();

            StateContainer.PersonCurrentAddressLocationModel.SetFrom(LocationViewModel.DisableTemplate);
            StateContainer.PersonPermanentAddressLocationModel.SetFrom(LocationViewModel.DisableTemplate);
            StateContainer.PersonAlternateAddressLocationModel.SetFrom(LocationViewModel.DisableTemplate);
        }
        else
        {
            StateContainer.PersonCurrentAddressLocationModel.SetFrom(originalPersonCurrentAddressLocationModel);
            StateContainer.PersonCurrentAddressLocationModel.OperationType = null;
            StateContainer.PersonPermanentAddressLocationModel.SetFrom(originalPersonPermanentAddressLocationModel);
            StateContainer.PersonPermanentAddressLocationModel.OperationType = null;
            StateContainer.PersonAlternateAddressLocationModel.SetFrom(originalPersonAlternateAddressLocationModel);
            StateContainer.PersonAlternateAddressLocationModel.OperationType = null;
        }

        await InvokeAsync(StateHasChanged);
    }

    private void SaveOriginalLocationViewsState()
    {
        originalPersonCurrentAddressLocationModel.SetFrom(StateContainer.PersonCurrentAddressLocationModel);
        originalPersonPermanentAddressLocationModel.SetFrom(StateContainer.PersonPermanentAddressLocationModel);
        originalPersonAlternateAddressLocationModel.SetFrom(StateContainer.PersonAlternateAddressLocationModel);
    }

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
}