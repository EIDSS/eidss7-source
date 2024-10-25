using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Services;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportSummaryPartialBase : ComponentBase
{
    [Parameter]
    public DiseaseReportComponentViewModel Model { get; set; }

    [Inject]
    protected IStringLocalizer Localizer { get; set; }

    [Inject]
    private ICrossCuttingClient CrossCuttingClient { get; set; }

    [Inject]
    private INotificationSiteAlertService NotificationSiteAlertService { get; set; }

    [Inject]
    private IHttpContextAccessor HttpContextAccessor { get; set; }

    [Inject]
    private ILogger<DiseaseReportSummaryPartialBase> Logger { get; set; }

    [Inject]
    private IJSRuntime JSRuntime { get; set; }
    
    [Inject] protected IHdrStateContainer HdrStateContainer { get; set; }

    private const string NotificationsCookieName = "HDRNotifications";

    protected RadzenTemplateForm<DiseaseReportComponentViewModel> Form { get; set; }

    protected List<BaseReferenceEditorsViewModel> ReportStatuses { get; set; } = [];

    protected List<BaseReferenceEditorsViewModel> ReportTypes { get; set; } = [];

    protected bool IsSummaryVisible { get; private set; } = true;

    [JSInvokable]
    public bool IsFormValid()
    {
        return Form.EditContext.Validate();
    }

    protected override async Task OnInitializedAsync()
    {
        ReportStatuses = await GetBaseReferenceList(EIDSSConstants.BaseReferenceTypeIds.CaseStatus);
        ReportTypes = await GetBaseReferenceList(EIDSSConstants.BaseReferenceTypeIds.CaseReportType);

        if (Model.ReportSummary.ReportStatusID == 0 || string.IsNullOrEmpty(Model.ReportSummary.ReportStatus))
        {
            Model.ReportSummary.ReportStatusID = EIDSSConstants.CaseStatus.InProgress;
        }

        if (Model.ReportSummary.ReportTypeID == 0 || string.IsNullOrEmpty(Model.ReportSummary.ReportType))
        {
            Model.ReportSummary.ReportTypeID = EIDSSConstants.CaseReportType.Passive;
        }
    }

    protected override async Task OnParametersSetAsync()
    {
        await base.OnParametersSetAsync();
        await HdrStateContainer.ChangeWithNotifyAboutStateChange((x) =>
        {
            x.DateEntered = Model.ReportSummary.DateEntered;
        });
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JSRuntime.InvokeVoidAsync("SummarySection.SetDotNetReference", DotNetObjectReference.Create(this));
        }
    }

    protected string GetDisease() =>
        string.IsNullOrEmpty(Model.NotificationSection.ChangedDiseaseName)
        ? Model.NotificationSection.strDisease
        : Model.NotificationSection.ChangedDiseaseName;

    protected string GetDateOfDiagnosisFormatted()
    {
        var date = Model.NotificationSection.DateOfChangedDiagnosis ?? Model.NotificationSection.dateOfDiagnosis;
        return date.HasValue ? date.Value.ToShortDateString() : string.Empty;
    }


    protected bool IsReportTypeActive() =>
        Model.ReportSummary.ReportTypeID == EIDSSConstants.CaseReportType.Active;

    protected bool IsReportStatusDisabled() =>
        (!Model.ReportSummary.blnCanReopenClosedCase.HasValue ||
        !Model.ReportSummary.blnCanReopenClosedCase.Value) &&
        Model.ReportSummary.IsReportClosed;

    protected bool IsReportTypeDisabled() =>
        Model.ReportSummary.ReportStatusID == (long)VeterinaryDiseaseReportStatusTypes.Closed ||
        Model.ReportSummary.IsReportTypeDisabled;

    protected bool HasCaseClassification() =>
        !string.IsNullOrEmpty(Model.ReportSummary.CaseClassification) &&
        Model.ReportSummary.blnInitialSSD != null &&
        !Model.ReportSummary.blnInitialSSD.Value &&
        Model.ReportSummary.blnFinalSSD != null &&
        !Model.ReportSummary.blnFinalSSD.Value;

    protected async Task OnReportStatusChange()
    {
        await GetSiteAlertForReopenClosedHDR();
    }

    protected void ToggleReportSummary()
    {
        IsSummaryVisible = !IsSummaryVisible;
    }

    private async Task<List<BaseReferenceEditorsViewModel>> GetBaseReferenceList(long referenceType)
    {
        BaseReferenceEditorGetRequestModel request = new()
        {
            IdfsReferenceType = referenceType,
            LanguageId = Thread.CurrentThread.CurrentCulture.Name,
            SortColumn = nameof(BaseReferenceEditorsViewModel.IntOrder),
            SortOrder = EIDSSConstants.SortConstants.Ascending
        };

        return await CrossCuttingClient.GetBaseReferenceList(request);
    }

    private async Task GetSiteAlertForReopenClosedHDR()
    {
        try
        {
            if (Model.ReportSummary.IsReportClosed &&
                Model.ReportSummary.ReportStatusID == EIDSSConstants.CaseStatus.InProgress &&
                Model.ReportSummary.idfHumanCase != null)
            {
                var eventTypeId = SystemEventLogTypes.ClosedHumanDiseaseReportWasReopenedAtYourSite;
                NotificationSiteAlertService.Events = GetNotificationEvents();

                if (NotificationSiteAlertService.Events == null)
                {
                    NotificationSiteAlertService.Events = new List<EventSaveRequestModel>();
                    await AddNotificationEvent(eventTypeId);
                }
                else if (!NotificationSiteAlertService.Events.Any(x => x.EventTypeId == (long)eventTypeId))
                {
                    await AddNotificationEvent(eventTypeId);
                }

                await WriteCookie(NotificationsCookieName, JsonConvert.SerializeObject(NotificationSiteAlertService.Events));
            }
        }
        catch (Exception ex)
        {
            Logger.LogError(ex.Message);
        }
    }

    private async Task AddNotificationEvent(SystemEventLogTypes eventTypeId)
    {
        var notificationEvent = await NotificationSiteAlertService.CreateEvent(Model.ReportSummary.idfHumanCase.Value, Model.ReportSummary.DiseaseID, eventTypeId, Model.ReportSummary.idfsSite, null);
        NotificationSiteAlertService.Events.Add(notificationEvent);
    }

    private List<EventSaveRequestModel> GetNotificationEvents()
    {
        return JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(HttpContextAccessor.HttpContext.Request.Cookies[NotificationsCookieName] ?? string.Empty);
    }

    private async Task WriteCookie(string name, string value)
    {
        await JSRuntime.InvokeAsync<object>("eval", $"document.cookie = '{name}={value}'");
    }
}
