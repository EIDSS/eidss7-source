using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportSymptomsPartialBase : ComponentBase
{
    [Parameter]
    public DiseaseReportSymptomsPageViewModel Model { get; set; }
    protected RadzenTemplateForm<DiseaseReportSymptomsPageViewModel> Form { get; set; }
    protected List<HumanDiseaseReportLkupCaseClassificationResponseModel> CaseClassifications = new();
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] protected IHdrStateContainer HdrStateContainer { get; set; }
    [Inject] private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }
    [Inject] private IJSRuntime JsRuntime { get; set; }
    protected FlexForm.FlexForm FlexFormHumanDiseaseSymptoms { get; set; }
    protected long? HumanDiseaseSymptomsObservationId { get; set; }

    protected override async Task OnInitializedAsync()
    {
        await base.OnInitializedAsync();

        HumanDiseaseSymptomsObservationId = Model.HumanDiseaseSymptoms.idfObservation;

        var list = await HumanDiseaseReportClient.GetHumanDiseaseReportLkupCaseClassificationAsync(new HumanDiseaseReportLkupCaseClassificationRequestModel
        {
            LangID = Thread.CurrentThread.CurrentCulture.Name,
        });

        CaseClassifications = list.Where(x =>
            x.blnInitialHumanCaseClassification &&
            x.strHACode.Split(',').Contains(EIDSSConstants.HACodeList.HumanHACode.ToString())).ToList();

        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfSymptomsOnset = Model.SymptomsOnsetDate;
        });
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

    [JSInvokable("SaveFlexFormHumanDiseaseSymptoms")]
    public async Task<long?> SaveFlexForm()
    {
        HumanDiseaseSymptomsObservationId = await FlexFormHumanDiseaseSymptoms.SaveFlexForm();
        StateHasChanged();
        return HumanDiseaseSymptomsObservationId;
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("DiseaseReportSymptomsSection.SetDotNetReference", DotNetObjectReference.Create(this));
        }
    }

    protected async Task SymptomsOnsetDateChanged(DateTime? value)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfSymptomsOnset = value;
        });
    }

    private async Task ReloadSectionIfNeeded(string diagnosisIdStr, bool mustResetObservation)
    {
        if (!string.IsNullOrEmpty(diagnosisIdStr) && long.TryParse(diagnosisIdStr, out var diagnosisId) && Model.HumanDiseaseSymptoms.idfsDiagnosis != diagnosisId)
        {
            Model.HumanDiseaseSymptoms.idfsDiagnosis = diagnosisId;
            if (mustResetObservation)
            {
                Model.HumanDiseaseSymptoms.idfObservation = null;
            }

            await FlexFormHumanDiseaseSymptoms.SetRequestParameter(Model.HumanDiseaseSymptoms);
            StateHasChanged();
        }
    }
}