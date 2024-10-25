using System;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.Interfaces;
using EIDSS.Web.Components.Human.Person;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;
using Radzen.Blazor;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportPersonalInformationBase : ComponentBase, IHdrContainerObserver, IDisposable
{
    private PersonStateContainer _personStateContainer;
    private IDisposable _unsubscriberForHdrStateContainer;
    
    [Parameter]
    public DiseaseReportPersonalInformationPageViewModel Model { get; set; }
    [Parameter]
    public bool IsReportClosed { get; set; }
    protected RadzenTemplateForm<DiseaseReportPersonalInformationPageViewModel> Form { get; set; }
    protected PersonInformationSection PersonInformationSection { get; set; }
    [Inject] 
    protected IHdrStateContainer HdrStateContainer { get; set; }
    [Inject] 
    protected IStringLocalizer Localizer { get; set; }
    [Inject] 
    private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }
    [Inject] 
    private IJSRuntime JsRuntime { get; set; }
    [Inject]
    private IPersonStateContainerResolver PersonStateContainerResolver { get; set; }
    [Inject]
    protected IConfiguration Configuration { get; set; }

    protected override void OnInitialized()
    {
        base.OnInitialized();
        _unsubscriberForHdrStateContainer = HdrStateContainer.Subscribe(this);
        _personStateContainer = PersonStateContainerResolver.GetContainerFor("HDR");
        _personStateContainer.IsReview = true;
        _personStateContainer.IsReadOnly = true;
        _personStateContainer.IsHeaderVisible = false;
        _personStateContainer.IsDateOfDeathVisible = false;
        _personStateContainer.IsFindPINVisible = false;
        _personStateContainer.IsPersonValidationActive = false;
        _personStateContainer.IsHumanAgeFieldsCouldBeSelectedByUserWhenDateOfBirthIsNotSet = true;
        
        var countryId = Convert.ToInt64(Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"));
        _personStateContainer.SetupFrom(Model.PersonInfo, countryId);
    }

    protected override async Task OnInitializedAsync()
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfBirth = Model.PersonInfo.DateOfBirth;
        });

        await base.OnInitializedAsync();
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        await base.OnAfterRenderAsync(firstRender);
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("PersonInfoSection.SetDotNetReference", DotNetObjectReference.Create(this));
            await UpdateAge();
        }
    }

    private async Task UpdateAge()
    {
        if (HdrStateContainer.DateOfBirth != null && (HdrStateContainer.DateOfBirth < DateTime.Now.Date.AddDays(1)))
        {
            await PersonInformationSection.UpdateAge();
        }
    }

    [JSInvokable("ValidateSectionForSidebar")]
    public async Task<bool> ValidForm()
    {
        return Form.EditContext.Validate() && await PersonInformationSection.ValidateSection(isReview: true);
    }

    public void Dispose()
    {
        _unsubscriberForHdrStateContainer?.Dispose();
    }

    public async Task OnHdrStateContainerChange(IHdrStateContainer current, IHdrStateContainer previous)
    {
        if (current.DateOfDeath != previous.DateOfDeath)
        {
            await UpdateAge();
        }
        StateHasChanged();
    }
    
    protected async Task OnDateOfBirthChange(DateTime? dateOfBirth)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfBirth = dateOfBirth;
        });
    }
}