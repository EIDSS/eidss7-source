using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.ResponseModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportChangeDiagnosisHistoryModalBase : ComponentBase
{
    [Inject]
    protected IStringLocalizer Localizer { get; set; }

    [Inject]
    private IChangeDiagnosisHistoryClient ChangeDiagnosisHistoryClient { get; set; }

    [Parameter]
    public long HumanCaseId { get; set; }

    protected IEnumerable<ChangeDiagnosisHistoryResponseModel> Data { get; set; }
    protected IEnumerable<int> PageSizeOptions = new[] { 10, 25, 50, 100 };

    protected override async Task OnInitializedAsync()
    {
        await base.OnInitializedAsync();

        await LoadChangeDiagnosisHistoryAsync();
    }

    private async Task LoadChangeDiagnosisHistoryAsync()
    {
        var currentLanguage = Thread.CurrentThread.CurrentCulture.Name;
        Data = await ChangeDiagnosisHistoryClient.GetChangeDiagnosisHistoryAsync(HumanCaseId, currentLanguage);
    }
}
