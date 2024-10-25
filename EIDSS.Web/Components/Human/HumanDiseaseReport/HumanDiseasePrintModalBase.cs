using System.Threading.Tasks;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class HumanDiseasePrintModalBase : ComponentBase
{
    [Parameter] public DiseaseReportPrintViewModel ContactPrintViewModel { get; set; }
    [Parameter] public DiseaseReportPrintViewModel CaseInvestigationPrintViewModel { get; set; }
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private IJSRuntime JsRuntime { get; set; }
    protected bool Visible { get; set; }
    protected const string NotificationTabName = "notification";
    protected const string DiseaseTabName = "disease";
    protected string SelectedTab { get; set; } = NotificationTabName;

    [JSInvokable("Show")]
    public async Task Show()
    {
        Visible = true;
        SelectedTab = NotificationTabName;
        await InvokeAsync(StateHasChanged);
    }
    
    protected void Hide()
    {
        Visible = false;
    }
        
    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("HumanDiseasePrintModal.SetDotNetReference", DotNetObjectReference.Create(this));
        }
    }
}