using System;
using System.Threading.Tasks;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;
using Radzen.Blazor;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportFacilityDetailsPartialBase : ComponentBase
{
    [Inject] protected IHdrStateContainer HdrStateContainer { get; set; }
    [Parameter]
    public DiseaseReportFacilityDetailsPageViewModel Model { get; set; }
    protected RadzenTemplateForm<DiseaseReportFacilityDetailsPageViewModel> Form { get; set; }
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private IJSRuntime JsRuntime { get; set; }
    
    protected override async Task OnInitializedAsync()
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfHospitalization = Model.HospitalizationDate;
            x.DateOfSoughtCareFirst = Model.SoughtCareFirstDate;
        });
        await base.OnInitializedAsync();
    }

    [JSInvokable("ValidateSectionForSidebar")]
    public bool ValidForm()
    {
        return Form.EditContext.Validate();
    }
        
    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("DetailsFacilitySection.SetDotNetReference", DotNetObjectReference.Create(this));
        }
    }

    protected async Task OnHospitalizationDateChanged(DateTime? value)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfHospitalization = value;
        });
    }
    
    protected async Task OnSoughtCareFirstDateChanged(DateTime? value)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfSoughtCareFirst = value;
        });
    }
}