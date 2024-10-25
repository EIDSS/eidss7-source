using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportRiskFactorsPartialBase : ComponentBase
{
    [Parameter]
    public DiseaseReportCaseInvestigationRiskFactorsPageViewModel Model { get; set; }
    protected RadzenTemplateForm<DiseaseReportCaseInvestigationRiskFactorsPageViewModel> Form { get; set; }
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private IJSRuntime JsRuntime { get; set; }
    protected FlexForm.FlexForm FlexFormRiskFactors { get; set; }
    protected long? RiskFactorsObservationId { get; set; }

    protected override async Task OnInitializedAsync()
    {
        await base.OnInitializedAsync();

        RiskFactorsObservationId = Model.RiskFactors.idfObservation;
    }

    [JSInvokable("ValidateSectionForSidebar")]
    public bool ValidForm()
    {
        return Form.EditContext.Validate();
    }

    [JSInvokable("ReloadSectionIfNeeded")]
    public async Task ReloadSectionIfNeeded(string diagnosisIdStr)
    {
        await ReloadSectionIfNeeded(diagnosisIdStr, false);
    }

    [JSInvokable("ReloadWithEmptyObservation")]
    public async Task ReloadWithEmptyObservation(string diagnosisIdStr)
    {
        await ReloadSectionIfNeeded(diagnosisIdStr, true);
    }

    [JSInvokable("SaveFlexFormRiskFactors")]
    public async Task<long?> SaveFlexForm()
    {
        RiskFactorsObservationId = await FlexFormRiskFactors.SaveFlexForm();
        StateHasChanged();
        return RiskFactorsObservationId;
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("DiseaseReportRiskFactorsSection.SetDotNetReference", DotNetObjectReference.Create(this));
        }
    }

    private async Task ReloadSectionIfNeeded(string diagnosisIdStr, bool mustResetObservation)
    {
        if (!string.IsNullOrEmpty(diagnosisIdStr) && long.TryParse(diagnosisIdStr, out var diagnosisId) && Model.RiskFactors.idfsDiagnosis != diagnosisId)
        {
            Model.RiskFactors.idfsDiagnosis = diagnosisId;
            if (mustResetObservation)
            {
                Model.RiskFactors.idfObservation = null;
            }

            await FlexFormRiskFactors.SetRequestParameter(Model.RiskFactors);
            StateHasChanged();
        }
    }
}