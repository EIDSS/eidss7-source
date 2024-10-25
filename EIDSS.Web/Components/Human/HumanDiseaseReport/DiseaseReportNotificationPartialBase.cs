using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using EIDSS.Web.Components.Shared.EmployerSearch;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Components.Shared.CustomDatePicker;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportNotificationPartialBase : ComponentBase
{
    [Parameter]
    public DiseaseReportNotificationPageViewModel Model { get; set; }
    protected RadzenTemplateForm<DiseaseReportNotificationPageViewModel> Form { get; set; }
    protected EmployerSearchBase FacilitySentByNameEmployerSearch { get; set; }
    protected EmployerSearchBase FacilityReceivedByNameEmployerSearch { get; set; }
    protected RadzenDropDown<long?> DiseaseDropdown { get; set; }
    protected List<FilteredDiseaseGetListViewModel> Diseases { get; set; } = new();
    protected List<BaseReferenceEditorsViewModel> PatientStates { get; set; } = new();
    protected List<BaseReferenceEditorsViewModel> PatientLocations { get; set; } = new();
    protected bool IsGenderOfDiseaseValid { get; set; } = true;
    protected bool IsAgeOfDiseaseValid { get; set; } = true;
    protected RadzenDropDown<long?> ChangedDiseaseDropdown { get; set; }

    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private LocalizationMemoryCacheProvider LocalizationMemoryCacheProvider { get; set; }
    [Inject] private IJSRuntime JsRuntime { get; set; }
    [Inject] protected IHdrStateContainer HdrStateContainer { get; set; }
    [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
    [Inject] private ITokenService TokenService { get; set; }
    [Inject] private ILogger<DiseaseReportNotificationPartialBase> Logger { get; set; }
    [Inject] private IDiseaseAgeGroupMatrixClient DiseaseAgeGroupMatrixClient { get; set; }
    [Inject] private IDiseaseHumanGenderMatrixClient DiseaseHumanGenderMatrixClient { get; set; }
    [Inject] private IAdminClient AdminClient { get; set; }
    [Inject] private DialogService DialogService { get; set; }

    [Inject]
    protected HumanDiseaseReportSessionStateContainer StateContainer { get; set; }

    [JSInvokable("ValidateSectionForSidebar")]
    public bool ValidForm()
    {
        return Form.EditContext.Validate();
    }

    protected override async Task OnInitializedAsync()
    {
        await base.OnInitializedAsync();
        var currentLanguage = Thread.CurrentThread.CurrentCulture.Name;

        var requestDiseases = new FilteredDiseaseRequestModel
        {
            LanguageId = currentLanguage,
            AccessoryCode = EIDSSConstants.HACodeList.HumanHACode,
            UsingType = EIDSSConstants.UsingType.StandardCaseType,
            UserEmployeeID = Convert.ToInt64(TokenService.GetAuthenticatedUser().PersonId)
        };

        Diseases = await CrossCuttingClient.GetFilteredDiseaseList(requestDiseases);

        var requestPatientState = new BaseReferenceEditorGetRequestModel
        {
            IdfsReferenceType = EIDSSConstants.BaseReferenceTypeIds.PatientState,
            LanguageId = currentLanguage,
            SortColumn = nameof(BaseReferenceEditorsViewModel.IntOrder),
            SortOrder = EIDSSConstants.SortConstants.Ascending
        };

        PatientStates = await CrossCuttingClient.GetBaseReferenceList(requestPatientState);

        var requestPatientLocation = new BaseReferenceEditorGetRequestModel
        {
            IdfsReferenceType = EIDSSConstants.BaseReferenceTypeIds.PatientLocationType,
            LanguageId = currentLanguage,
            SortColumn = nameof(BaseReferenceEditorsViewModel.IntOrder),
            SortOrder = EIDSSConstants.SortConstants.Ascending
        };

        PatientLocations = await CrossCuttingClient.GetBaseReferenceList(requestPatientLocation);

        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfNotification = Model.dateOfNotification;
            x.DateOfDiagnosis = Model.dateOfDiagnosis;
            x.DateOfCompletion = Model.dateOfCompletion;
            x.DateOfChangedDiagnosis = Model.DateOfChangedDiagnosis;
        });

        StateContainer.SetDiseaseReportNotificationPageViewModel(Model);
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JsRuntime.InvokeVoidAsync("NotificationSection.SetDotNetReference", DotNetObjectReference.Create(this));
        }
    }

    protected async Task SentByFacilityChanged(long? organizationId)
    {
        Model.idfNotificationSentByFacility = organizationId;
        await FacilitySentByNameEmployerSearch.SetEmployeeOrganization(organizationId);
    }

    protected async Task ReceivedByFacilityChanged(long? organizationId)
    {
        Model.idfNotificationReceivedByFacility = organizationId;
        await FacilityReceivedByNameEmployerSearch.SetEmployeeOrganization(organizationId);
    }

    protected bool IsRequired(string currentLanguage, string fieldId) => LocalizationMemoryCacheProvider.GetRequiredResourceByLanguageCultureNameAndResourceKey(currentLanguage, fieldId);

    protected bool IsVisible(string currentLanguage, string fieldId) => !LocalizationMemoryCacheProvider.GetHiddenResourceByLanguageCultureNameAndResourceKey(currentLanguage, fieldId);

    protected async Task OnDiseaseChange()
    {
        try
        {
            await ValidateAgeOfDisease(Model.idfDisease);
            await ValidateGenderOfDisease(Model.idfDisease);
            DiseaseDropdown.EditContext.Validate();
        }
        catch (Exception ex)
        {
            Logger.LogError(ex.Message);
        }

        await InvokeAsync(StateHasChanged);
    }

    private async Task ValidateGenderOfDisease(long? diseaseId)
    {
        if (Model.GenderTypeID != null && diseaseId > 0)
        {
            var request = new GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel
            {
                LanguageID = Thread.CurrentThread.CurrentCulture.Name,
                DiseaseID = diseaseId
            };

            var response = await DiseaseHumanGenderMatrixClient.GetGenderForDiseaseOrDiagnosisGroupMatrix(request);
            if (response is { Count: > 0 })
            {
                if (response.FirstOrDefault()?.GenderID != Model.GenderTypeID)
                {
                    IsGenderOfDiseaseValid = false;
                }
            }
        }
        else
        {
            IsGenderOfDiseaseValid = true;
        }
    }

    private async Task ValidateAgeOfDisease(long? diseaseId)
    {
        if (diseaseId > 0 && Model.ReportedAge != null && Model.ReportedAgeUOMID != null)
        {
            var request = new DiseaseAgeGroupGetRequestModel
            {
                LanguageId = Thread.CurrentThread.CurrentCulture.Name,
                IdfsDiagnosis = diseaseId,
                Page = 1,
                PageSize = 50,
                SortColumn = "idfDiagnosisAgeGroupToDiagnosis",
                SortOrder = EIDSSConstants.SortConstants.Ascending.ToLower()
            };
            var ageGroupMatrixResponse = await DiseaseAgeGroupMatrixClient.GetDiseaseAgeGroupMatrix(request);
            var ageGroupsRequest = new AgeGroupGetRequestModel
            {
                LanguageId = Thread.CurrentThread.CurrentCulture.Name,
                Page = 1,
                PageSize = 50,
                SortColumn = "Intorder",
                SortOrder = EIDSSConstants.SortConstants.Ascending.ToLower()
            };
            var ageGroupResponse = await AdminClient.GetAgeGroupList(ageGroupsRequest);

            if (ageGroupMatrixResponse is { Count: > 0 } && ageGroupResponse is { Length: > 0 })
            {
                IsAgeOfDiseaseValid = !ageGroupResponse
                    .Any(x => x.idfsAgeType == Model.ReportedAgeUOMID
                              && ageGroupMatrixResponse
                                  .Select(y => y.IdfsDiagnosisAgeGroup)
                                  .Contains(x.KeyId)
                              && Model.ReportedAge >=
                              x.IntLowerBoundary &&
                              Model.ReportedAge <= x.IntUpperBoundary);
            }
            else
            {
                IsAgeOfDiseaseValid = true;
            }
        }
        else
        {
            IsAgeOfDiseaseValid = true;
        }
    }

    protected async Task OnDateOfDiagnosisChanged(DateTime? value)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfDiagnosis = value;
        });
    }
    
    protected async Task OnDateOfCompletionChanged(DateTime? value)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfCompletion = value;
        });
    }

    protected async Task OnDateOfNotificationChanged(DateTime? value)
    {
        await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
        {
            x.DateOfNotification = value;
        });
    }

    protected bool IsChangedDiseaseIdValid() =>
        Model.idfDisease == null ||
        Model.ChangedDiseaseId == null ||
        Model.idfDisease != Model.ChangedDiseaseId;
    
    protected bool IsDateOfChangedDiagnosisDisabled() =>
        Model.IsReportClosed ||
        !Model.ChangedDiseaseId.HasValue ||
        !IsChangedDiseaseIdValid();

    protected bool IsChangeDiagnosisHistoryDisabled() =>
        !Model.ChangedDiseaseId.HasValue;

    protected async Task OnChangedDiseaseChange()
    {
        StateContainer.SetDiseaseReportNotificationPageViewModel(Model);

        if (Model.ChangedDiseaseId is null)
        {
            Model.DateOfChangedDiagnosis = null;
            Model.ChangeDiagnosisReasonId = null;
            Model.ChangedDiseaseName = null;
            return;
        }

        var context = ChangedDiseaseDropdown.EditContext;
        var field = context.Field(nameof(DiseaseReportNotificationPageViewModel.ChangedDiseaseId));
        if (!context.IsValid(field))
        {
            return;
        }

        var heading = Localizer.GetString(HeadingResourceKeyConstants.ReasonForDiseaseChangeHeading);
        var dialogResult = await DialogService.OpenAsync<DiseaseReportChangeDiagnosisReasonModal>(heading);
        if (dialogResult == null)
        {
            Model.ChangedDiseaseId = null;
            Model.DateOfChangedDiagnosis = null;
            HdrStateContainer.DateOfChangedDiagnosis = null;
            Model.ChangeDiagnosisReasonId = null;
            Model.ChangedDiseaseName = null;

            return;
        }

        Model.ChangeDiagnosisReasonId = dialogResult;

        var disease = Diseases.FirstOrDefault(x => x.DiseaseID == Model.ChangedDiseaseId);
        Model.ChangedDiseaseName = disease?.DiseaseName;
    }

    protected async Task ShowChangeDiagnosisHistory()
    {
        var heading = Localizer.GetString(HeadingResourceKeyConstants.ChangeDiagnosisHistoryHeading);
        var parameters = new Dictionary<string, object>
        {
            { nameof(DiseaseReportChangeDiagnosisHistoryModalBase.HumanCaseId), Model.idfHumanCase }
        };
        var options = new DialogOptions
        {
            Height = "auto",
            Width = "auto"
        };

        await DialogService.OpenAsync<DiseaseReportChangeDiagnosisHistoryModal>(heading, parameters, options);
    }
}