using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;
using Radzen.Blazor;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportCaseInvestigationBase : ComponentBase
{
    [Parameter]
    public DiseaseReportCaseInvestigationPageViewModel Model { get; set; }
    protected LocationView ExposureLocationAddressLocationViewComponent { get; set; }
    protected RadzenTemplateForm<DiseaseReportCaseInvestigationPageViewModel> Form { get; set; }
    [Inject] 
    protected IHdrStateContainer HdrStateContainer { get; set; }
    [Inject] 
    protected IStringLocalizer Localizer { get; set; }
    [Inject] 
    private ICrossCuttingClient CrossCuttingClient { get; set; }
    [Inject] 
    private IJSRuntime JsRuntime { get; set; }

    protected List<CountryModel> ForeignCountries = [];
    protected List<BaseReferenceViewModel> GroundTypes = [];
    private long? LastIdfsPointGeoLocationType { get; set; }

    protected override async Task OnInitializedAsync()
    {
       await base.OnInitializedAsync();
       HdrStateContainer.InvestigatedByOfficeId = Model.idfInvestigatedByOffice;
       HdrStateContainer.DateOfStartInvestigation = Model.StartDateofInvestigation;
       HdrStateContainer.DateOfExposure = Model.ExposureDate;
       ForeignCountries = await CrossCuttingClient.GetCountryList(Thread.CurrentThread.CurrentCulture.Name);
       
       GroundTypes = await CrossCuttingClient.GetBaseReferenceList(Thread.CurrentThread.CurrentCulture.Name, EIDSSConstants.BaseReferenceConstants.GroundType, EIDSSConstants.HACodeList.HumanHACode);
    }
    
    protected async Task InvestigatedByOfficeChanged(long? organizationId)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.InvestigatedByOfficeId = organizationId;
        });
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        await base.OnAfterRenderAsync(firstRender);
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("DiseaseReportCaseInvestigationSection.SetDotNetReference", DotNetObjectReference.Create(this));
            await InitializeExposureLocationView();
        }
    }

    private async Task InitializeExposureLocationView()
    {
        if (Model.IsReportClosed && ExposureLocationAddressLocationViewComponent != null)
        {
            Model.ExposureLocationAddress.SetFrom(LocationViewModel.DisableTemplate);
            Model.ExposureLocationAddress.OperationType = LocationViewOperationType.ReadOnly;
            await ExposureLocationAddressLocationViewComponent.RefreshComponent(Model.ExposureLocationAddress);
            await InvokeAsync(StateHasChanged);
        }
    }

    protected override void OnParametersSet()
    {
        base.OnParametersSet();
        LastIdfsPointGeoLocationType = Model.idfsPointGeoLocationType;
    }
    
    protected async Task OnExposureLocationRDChange(long? answerId)
    { 
        if (answerId == LastIdfsPointGeoLocationType)
        {
            LastIdfsPointGeoLocationType = null;
            Model.idfsPointGeoLocationType = null;
        }
        else
        {
            Model.idfsPointGeoLocationType = answerId; 
        }

        LastIdfsPointGeoLocationType = Model.idfsPointGeoLocationType;
    }

    [JSInvokable("ValidateSectionForSidebar")]
    public async Task<bool> ValidForm()
    {
        return Form.EditContext.Validate();
    }
}