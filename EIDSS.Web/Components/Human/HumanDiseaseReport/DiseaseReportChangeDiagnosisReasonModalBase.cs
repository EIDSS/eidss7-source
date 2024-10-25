using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportChangeDiagnosisReasonModalBase : BaseComponent
{
    [Inject]
    private ICrossCuttingClient CrossCuttingClient { get; set; }

    protected DiseaseReportChangeDiagnosisReasonModalViewModel Model { get; set; } = new();

    protected IEnumerable<BaseReferenceViewModel> ChangeDiagnosisReasonList;

    protected override async Task OnInitializedAsync()
    {
        ChangeDiagnosisReasonList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.ReasonforChangedDiagnosis, null);
    }

    protected void OnSubmit(DiseaseReportChangeDiagnosisReasonModalViewModel model)
    {
        DiagService.Close(Model.ChangeDiagnosisReasonId);
    }
}
