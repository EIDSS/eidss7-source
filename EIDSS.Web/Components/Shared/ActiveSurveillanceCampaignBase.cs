#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Shared.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using static System.Int32;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using JsonSerializer = System.Text.Json.JsonSerializer;

#endregion

namespace EIDSS.Web.Components.Shared
{
    public class ActiveSurveillanceCampaignBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject]
        protected IOrganizationClient OrganizationClient { get; set; }
        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public long CampaignCategoryId { get; set; }
        [Parameter]
        public long? CampaignID { get; set; }
        [Parameter]
        public bool IsReadOnly { get; set; }
        [Parameter] 
        public LocalizedString ReturnButtonResourceString { get; set; }
        [Parameter] 
        public EventCallback<long?> FarmAddEditComplete { get; set; }
        [Parameter] 
        public bool ShowInDialog { get; set; }
        [Parameter] 
        public SearchModeEnum Mode { get; set; }

        #endregion

        #region Private Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private long? _previousStatus;
        private DateTime? _previousStartDate;
        private DateTime? _previousEndDate;

        #endregion

        #region Properties

        protected RadzenTemplateForm<ActiveSurveillanceCampaignViewModel> Form { get; set; }
        protected ActiveSurveillanceCampaignViewModel Model { get; set; }
        protected IEnumerable<BaseReferenceViewModel> SpeciesTypes { get; set; }
        protected IEnumerable<FilteredDiseaseGetListViewModel>  DiseaseList { get; set; }
        protected IEnumerable<BaseReferenceViewModel> SamplesTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> CampaignStatuses { get; set; }
        protected IEnumerable<BaseReferenceViewModel> CampaignTypes { get; set; }
        protected List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> CampaignDiseaseSpeciesSamples { get; set; }
        protected List<VeterinaryActiveSurveillanceSessionViewModel> VasCampaignSessionList { get; set; }
        protected List<ActiveSurveillanceSessionResponseModel> HasCampaignSessionList { get; set; }

        protected bool IsProcessing;
        public int HACode;
        public int AccessoryCode;
        public UserPermissions Permissions;
        protected string IndicatorKey;
        protected string ModelKey;
        protected DateTime MaxDate;
        protected string StartDateMaxValidMessage;
        
        #endregion

        #endregion

        #region Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            MaxDate = DateTime.MaxValue;
            StartDateMaxValidMessage = Localizer.GetString(MessageResourceKeyConstants.FutureDatesAreNotAllowedMessage);
            if (CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human))
            {
                AccessoryCode = HACodeList.HumanHACode;
                HACode = HACodeList.ASHACode;
                Permissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceCampaign);
                IndicatorKey = SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchPerformedIndicatorKey;
                ModelKey = SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchModelKey;
            }
            else
            {
                AccessoryCode = HACodeList.LiveStockAndAvian;
                HACode = HACodeList.ASHACode;
                Permissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceCampaign);
                IndicatorKey = SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey;
                ModelKey = SearchPersistenceKeys.VeterinaryActiveSurveillanceCampaignSearchModelKey;
            }

            if (Permissions.Read)
                await Initialize();
            else
            {
                Model = new ActiveSurveillanceCampaignViewModel
                {
                    ActiveSurveillanceCampaignDetail =
                    {
                        CampaignStatusTypeID = 0
                    }
                };

                await JsRuntime.InvokeAsync<string>("insufficientPermissions", _token);
            }

            await base.OnInitializedAsync();
        }

        #endregion

        #region Common Methods

        public async Task GetSpeciesTypes()
        {
            try
            {
                SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.SpeciesList, AccessoryCode).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = AccessoryCode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };

            DiseaseList = await CrossCuttingClient.GetFilteredDiseaseList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetStatusTypesAsync()
        {
            CampaignStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ASCampaignStatus, AccessoryCode);
        }

        protected async Task OnStatusTypeChange(Object args)
        {
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetCampaignTypesAsync()
        {
            CampaignTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ASCampaignType, AccessoryCode);
        }

        public async Task GetSamplesTypes()
        {
            try
            {
                SamplesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.SampleType, AccessoryCode).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
        
        protected void HandleValidSubmit()
        {
            if (Form.IsValid)
            {

            }
        }

        protected async Task CancelClicked()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                {
                    if (Mode == SearchModeEnum.SelectNoRedirect)
                    {
                        DiagService.Close("Cancelled");
                    }
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        _source?.Cancel();

                        var uri = CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) ? $"{NavManager.BaseUri}Human/ActiveSurveillanceCampaign" : $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceCampaign";
                        NavManager.NavigateTo(uri, true);
                    }
                    DiagService.Close();
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void ValidateSubmit()
        {
            
        }

        protected async Task SaveAll()
        {
            if (Model.IsDiseaseSpeciesSampleGridInEditMode == true)
                return;

            if (Form.EditContext.Validate())
            {
                if (Model.DiseaseSpeciesSampleList == null || Model.DiseaseSpeciesSampleList.Count == 0)
                {
                    string noDiseaseMessage = Localizer.GetString(CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) 
                        ? MessageResourceKeyConstants.HumanActiveSurveillanceCampaignDiseaseSampleRequiredMessage 
                        : MessageResourceKeyConstants.VeterinaryActiveSurveillanceCampaignDiseaseSpeciesSampleRequiredMessage);

                    await ShowMessageDialog(Empty, noDiseaseMessage);
                }
                else
                {
                    if (await IsValidOnChangeStartDateAsync(Model.ActiveSurveillanceCampaignDetail.CampaignStartDate) == false)
                        return;

                    if (await IsValidOnChangeEndDateAsync(Model.ActiveSurveillanceCampaignDetail.CampaignEndDate) == false)
                        return;

                    var response = await SaveActiveSurveillance();
                    if (response is { ReturnCode: 0 })
                    {

                        string thirdButton = null;
                        if (ShowInDialog)
                        {
                            thirdButton = Localizer.GetString(ReturnButtonResourceString);
                        }

                        dynamic result;

                        if (CampaignID is 0 or null)
                        {
                            var message = Localizer.GetString(MessageResourceKeyConstants
                                              .RecordSavedSuccessfullyMessage) +
                                          $"{Localizer.GetString(MessageResourceKeyConstants.MessagesRecordIDisMessage)}: {response.strCampaignID}";

                            result = await ShowSuccessDialog(null, message, null,
                                ButtonResourceKeyConstants.ReturnToDashboardButton,
                                CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) ? 
                                ButtonResourceKeyConstants.HumanActiveSurveillanceCampaignReturnToActiveSurveillanceCampaignButtonText : 
                                ButtonResourceKeyConstants.VeterinaryActiveSurveillanceCampaignReturnToActiveSurveillanceCampaignButtonText);
                        }
                        else
                        {
                            result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                                null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                                CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) ? 
                                    ButtonResourceKeyConstants.HumanActiveSurveillanceCampaignReturnToActiveSurveillanceCampaignButtonText : 
                                    ButtonResourceKeyConstants.VeterinaryActiveSurveillanceCampaignReturnToActiveSurveillanceCampaignButtonText);
                        }

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText ==
                                Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                            {
                                DiagService.Close();

                                _source?.Cancel();

                                var uri = $"{NavManager.BaseUri}Administration/Dashboard/Index";

                                NavManager.NavigateTo(uri, true);
                            }
                            else if (thirdButton != null
                                     && returnResult.ButtonResultText == Localizer.GetString(thirdButton)
                                     && Mode == SearchModeEnum.SelectNoRedirect)
                            {
                                if (response.idfCampaign != null) DiagService.Close(response.idfCampaign.Value);
                            }
                            else
                            {
                                IsProcessing = true;
                                CampaignID = response.idfCampaign.Value;
                                Model.ActiveSurveillanceCampaignDetail.CampaignID = response.idfCampaign.Value;
                                Model.ActiveSurveillanceCampaignDetail.EIDSSCampaignID = response.strCampaignID;
                                await InvokeAsync(StateHasChanged);
                                DiagService.Close();

                                //Reload to update notification count.
                                var path = CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) ? "Human/ActiveSurveillanceCampaign/Details" : "Veterinary/ActiveSurveillanceCampaign/Details";
                                var query = $"?campaignId={CampaignID}";
                                var uri = $"{NavManager.BaseUri}{path}{query}";
                                NavManager.NavigateTo(uri, true);
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public async Task onDelete()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();
                List<DialogButton> buttons = new();
                if (Model.VetCampaignSessionList.Any(c => c.CampaignKey != null))
                {
                    var okButton = new DialogButton
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                        ButtonType = DialogButtonType.OK
                    };
                    buttons.Add(okButton);

                    dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                    dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.UnableToDeleteBecauseOfChildRecordsMessage));
                    var result1 = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                    if (result1 is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                    {
                        _source?.Cancel();
                        _source = new CancellationTokenSource();
                        _token = _source.Token;

                        DiagService.Close();
                    }
                }
                else
                {
                    buttons = new List<DialogButton>();
                    DialogButton yesButton = new()
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                        ButtonType = DialogButtonType.Yes
                    };
                    DialogButton noButton = new()
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                        ButtonType = DialogButtonType.No
                    };
                    buttons.Add(yesButton);
                    buttons.Add(noButton);

                    dialogParams = new Dictionary<string, object>
                    {
                        { nameof(EIDSSDialog.DialogButtons), buttons },
                        {
                            nameof(EIDSSDialog.Message),
                            Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                        }
                    };

                    var result =
                        await DiagService.OpenAsync<EIDSSDialog>(
                            Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                    if (result == null)
                        return;

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            DiagService.Close();

                            var response = await DeleteCampaignAsync();

                            if (response.ReturnCode == 0)
                            {
                                DiagService.Close();

                                _source?.Cancel();

                                string uri;
                                if (CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human))
                                {
                                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys
                                        .HumanActiveSurveillanceCampaignSearchModelKey);
                                    uri = $"{NavManager.BaseUri}Human/ActiveSurveillanceCampaign/Index";
                                }
                                else
                                {
                                    await BrowserStorage.DeleteAsync(SearchPersistenceKeys
                                        .VeterinaryActiveSurveillanceCampaignSearchModelKey);
                                    uri = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceCampaign/Index";
                                }

                                NavManager.NavigateTo(uri, true);
                            }
                        }
                    }
                }
            
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task<APIPostResponseModel> DeleteCampaignAsync()
        {
            var result =
                await CrossCuttingClient.DeleteActiveSurveillanceCampaign(GetCurrentLanguage(), CampaignID.Value,authenticatedUser.UserName,
                    _token);

            switch (result.ReturnCode)
            {
                case 0:
                    await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                        null);
                    break;
                case 1:
                    await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                        null);
                    break;
            }

            return result;
        }

        protected bool DisableDelete()
        {
            return CampaignID == null || !Permissions.Delete;
        }

        protected bool DisableSave()
        {
            return !Permissions.Create && !Permissions.Write;
        }

        private async Task<ActiveSurveillanceCampaignSaveResponseModel> SaveActiveSurveillance()
        {
            try
            {
                var result = new ActiveSurveillanceCampaignSaveResponseModel();
                Model.PendingSaveEvents ??= new List<EventSaveRequestModel>();

                var dateValid = await IsValidOnChangeStartDateAsync(Model.ActiveSurveillanceCampaignDetail.CampaignStartDate);
                if (!dateValid) return result;
                dateValid = await IsValidOnChangeEndDateAsync(Model.ActiveSurveillanceCampaignDetail.CampaignEndDate);
                if (!dateValid) return result;
                ActiveSurveillanceCampaignSaveRequestModel request = new()
                {
                    idfCampaign = CampaignID,
                    LanguageId = GetCurrentLanguage(),
                    CampaignName = Model.ActiveSurveillanceCampaignDetail.CampaignName,
                    CampaignCategoryTypeID = CampaignCategoryId,
                    CampaignStatusTypeID = Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID.Value,
                    CampaignTypeID = Model.ActiveSurveillanceCampaignDetail.CampaignTypeID.Value,
                    CampaignAdministrator = Model.ActiveSurveillanceCampaignDetail.CampaignAdministrator,
                    CampaignDateStart = Model.ActiveSurveillanceCampaignDetail.CampaignStartDate,
                    CampaignDateEnd = Model.ActiveSurveillanceCampaignDetail.CampaignEndDate,
                    AuditUserName = authenticatedUser.UserName,
                    SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    strCampaignID = Model.ActiveSurveillanceCampaignDetail.EIDSSCampaignID,
                    Conclusion = Model.ActiveSurveillanceCampaignDetail.Conclusion
                };

                var tlbCampaignToDiagnosesList = new List<TlbCampaignToDiagnosis>();
                if (Model.DiseaseSpeciesSampleList != null)
                {
                    tlbCampaignToDiagnosesList = Model.DiseaseSpeciesSampleList.Where(a => a.RowStatus == (int)RowStatusTypeEnum.Active).Select(a => new TlbCampaignToDiagnosis
                    {
                        idfCampaignToDiagnosis = a.idfCampaignToDiagnosis.Value,
                        idfsDiagnosis = a.idfsDiagnosis,
                        intOrder = Convert.ToInt32(a.intOrder),
                        intPlannedNumber = a.intPlannedNumber,
                        idfsSampleType = a.idfsSampleType,
                        idfsSpeciesType = a.idfsSpeciesType,
                        Comments = a.Comments

                    }).ToList();
                }
                var tlbCampaignSessionList = new List<TlbCampaignSession>();

                if (Model.VetCampaignSessionList is {Count: > 0})
                {
                    tlbCampaignSessionList = Model.VetCampaignSessionList.Select(a => new TlbCampaignSession
                    {
                        idfMonitoringSession = a.SessionKey,
                        deleteFlag = a.CampaignKey == null

                    }).ToList();
                }

                if (Model.HumanCampaignSessionList is {Count: > 0})
                {
                    tlbCampaignSessionList = Model.HumanCampaignSessionList.Select(a => new TlbCampaignSession
                    {
                        idfMonitoringSession = a.SessionKey,
                        deleteFlag = a.CampaignKey == null

                    }).ToList();
                }
                _previousStatus = Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID;
                _previousStartDate = Model.ActiveSurveillanceCampaignDetail.CampaignStartDate;
                _previousEndDate = Model.ActiveSurveillanceCampaignDetail.CampaignEndDate;
                request.CampaignToDiagnosisCombo = JsonSerializer.Serialize(tlbCampaignToDiagnosesList);
                request.MonitoringSessions = JsonSerializer.Serialize(tlbCampaignSessionList);

                if (request.idfCampaign is null)
                {
                    long? diseaseId = null;
                    if (Model.DiseaseSpeciesSampleList is { Count: > 0 })
                    {
                        diseaseId = Model.DiseaseSpeciesSampleList.First().idfsDiagnosis;
                    }
                    if (CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human))
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          Convert.ToInt64(request.SiteID)
                            ? SystemEventLogTypes.NewHumanActiveSurveillanceCampaignWasCreatedAtYourSite
                            : SystemEventLogTypes
                                .NewHumanActiveSurveillanceCampaignWasCreatedAtAnotherSite;
                        Model.PendingSaveEvents.Add(await CreateEvent(0,
                                diseaseId, eventTypeId, Convert.ToInt64(request.SiteID), null)
                            .ConfigureAwait(false));
                    }
                    else
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          Convert.ToInt64(request.SiteID)
                            ? SystemEventLogTypes.NewVeterinaryActiveSurveillanceCampaignWasCreatedAtYourSite
                            : SystemEventLogTypes
                                .NewVeterinaryActiveSurveillanceCampaignWasCreatedAtAnotherSite;
                        Model.PendingSaveEvents.Add(await CreateEvent(0,
                                diseaseId, eventTypeId, Convert.ToInt64(request.SiteID), null)
                            .ConfigureAwait(false));
                    }
                }

                request.Events = JsonConvert.SerializeObject(Model.PendingSaveEvents);
                result = await CrossCuttingClient.SaveActiveSurveillanceCampaignAsync(request, _token);

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        private async Task Initialize()
        {
            Model = new ActiveSurveillanceCampaignViewModel
            {
                Permissions = Permissions,
                CampaignID = CampaignID,
                ActiveSurveillanceCampaignDetail =
                {
                    CampaignStatusTypeID = (long) CampaignStatusTypes.NewStatus
                }
            };
            _previousStatus = Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID;
            MaxDate = Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID == (long)CampaignStatusTypes.NewStatus ? DateTime.MaxValue : DateTime.Now;
            if (CampaignID != null)
            {
                var request = new ActiveSurveillanceCampaignDetailRequestModel
                {
                    CampaignID= CampaignID.Value,
                    LanguageId= GetCurrentLanguage()
                };
                var result = await CrossCuttingClient.GetActiveSurveillanceCampaignGetDetailAsync(request, _token);
                if (result != null)
                {
                    Model.ActiveSurveillanceCampaignDetail = result.FirstOrDefault();

                    if (Model.CampaignID != null)
                    {
                        var campaignDiseaseSpeciesSamplesRequest =
                            new ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel
                            {
                                CampaignID = Model.CampaignID.Value,
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = "idfCampaign",
                                SortOrder = SortConstants.Descending
                            };
                        _previousStatus = Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID;
                        _previousStartDate = Model.ActiveSurveillanceCampaignDetail.CampaignStartDate;
                        _previousEndDate = Model.ActiveSurveillanceCampaignDetail.CampaignEndDate;
                        MaxDate = Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID == (long)CampaignStatusTypes.NewStatus ? DateTime.MaxValue : DateTime.Now;

                        Model.DiseaseSpeciesSampleList = 
                            await CrossCuttingClient.GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync(campaignDiseaseSpeciesSamplesRequest,_token);
                    }
                }
            }

            if (IsReadOnly == true)
            {
                Model.IsReadonly = true;
                Model.ActiveSurveillanceCampaignDetail.DisableEIDSSCampaignID = true;
                Model.ActiveSurveillanceCampaignDetail.DisableCampaignTypeID = true;
                Model.ActiveSurveillanceCampaignDetail.DisableCampaignTypeName = true;
                Model.ActiveSurveillanceCampaignDetail.DisableCampaignStartDate = true;
                Model.ActiveSurveillanceCampaignDetail.DisableCampaignEndDate = true;
                Model.ActiveSurveillanceCampaignDetail.DisableLegacyCampaignID = true;
                Model.ActiveSurveillanceCampaignDetail.DisableCampaignAdministrator = true;
            }
        }

        protected async Task<bool> IsValidOnChangeStartDateAsync(object value)
        {
            var isValid = true;
            if (value != null)
            {
                var startDate = (DateTime?)value;

                if (Model.VetCampaignSessionList != null)
                {
                    if (Model.VetCampaignSessionList.Any(s=>s.StartDate < startDate || s.EndDate < startDate))
                    {
                       await ShowMessageDialog("The Session’s period (XX/XX/XXX-…) must match the Campaign period (XX/XX/XXX- XX/XX/XXX)");
                       Model.ActiveSurveillanceCampaignDetail.CampaignStartDate = null;
                         isValid = false;
                    }
                }
            }
            await InvokeAsync(StateHasChanged);
            return isValid;
        }

        protected async  Task<bool> IsValidOnChangeEndDateAsync(object value)
        {
            var isValid= true;
            if (value != null)
            {
                var endDate = (DateTime?)value;

                if (Model.VetCampaignSessionList != null)
                {
                    if (Model.VetCampaignSessionList.Any(s => s.StartDate > endDate || s.EndDate > endDate))
                    {
                        await ShowMessageDialog("The Session’s period (XX/XX/XXX-…) must match the Campaign period (XX/XX/XXX- XX/XX/XXX)");
                        Model.ActiveSurveillanceCampaignDetail.CampaignStartDate = null;
                        isValid = false;
                    }
                }
            }
            await InvokeAsync(StateHasChanged);
            return isValid;
        }

        protected async Task OnChangeStatusAsync(object value)
        {
            if (value != null)
            {
                var status = value is IEnumerable<object> objects ? Join(", ", objects) : value;

                var selectedStatus = Convert.ToInt64(status);

                switch (selectedStatus)
                {
                    case (long) CampaignStatusTypes.Open:
                        MaxDate = DateTime.Now;
                        StartDateMaxValidMessage =
                            $"{Localizer.GetString(MessageResourceKeyConstants.FutureDatesAreNotAllowedMessage)}  for open status";
                        break;
                    case (long) CampaignStatusTypes.NewStatus:
                        StartDateMaxValidMessage =
                            Localizer.GetString(MessageResourceKeyConstants.FutureDatesAreNotAllowedMessage);
                        MaxDate = DateTime.MaxValue;
                        break;
                    case (long) CampaignStatusTypes.Closed:
                    {
                        Model.ActiveSurveillanceCampaignDetail.CampaignEndDate ??= DateTime.Now;

                        break;
                    }
                }

                if (_previousStatus != null)
                {
                    //if (previousStatus == (long) CampaignStatusTypes.NewStatus &&
                    //    selectedStatus == (long) CampaignStatusTypes.Open)
                    //{
                    //    if (model.ActiveSurveillanceCampaignDetail.CampaignStartDate == null)
                    //    {
                    //        model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID = previousStatus;
                    //        await ShowMessageDialog("Campaign Status can’t be set to Open. Enter start date");
                    //    }
                    //}

                    if (_previousStatus == (long) CampaignStatusTypes.Open &&
                        selectedStatus == (long) CampaignStatusTypes.NewStatus)
                    {
                        if (Model.VetCampaignSessionList is {Count: > 0})
                        {
                            Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID = _previousStatus;
                            await ShowMessageDialog(
                                "Campaign Status can’t be set to New. There are sessions associated with this campaign");
                        }
                    }

                    if (_previousStatus == (long) CampaignStatusTypes.Open &&
                        selectedStatus == (long) CampaignStatusTypes.Closed)
                    {
                        if (Model.VetCampaignSessionList is {Count: > 0})
                        {

                            if (Model.VetCampaignSessionList.FirstOrDefault(c =>
                                    c.SessionStatusTypeName.ToUpper() == "OPEN") != null)
                            {
                                Model.ActiveSurveillanceCampaignDetail.CampaignStatusTypeID = _previousStatus;
                                await ShowMessageDialog(
                                    "Active Surveillance Campaign Status can’t be closed. Close all Sessions related to this Campaign before campaign closure");
                            }
                        }
                    }

                    if (selectedStatus == (long) CampaignStatusTypes.Closed)
                    {
                        Model.ActiveSurveillanceCampaignDetail.DisableEIDSSCampaignID = true;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignTypeID = true;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignTypeName = true;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignStartDate = true;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignEndDate = true;
                        Model.ActiveSurveillanceCampaignDetail.DisableLegacyCampaignID = true;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignAdministrator = true;
                    }
                    else
                    {
                        Model.ActiveSurveillanceCampaignDetail.DisableEIDSSCampaignID = false;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignTypeID = false;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignTypeName = false;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignStartDate = false;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignEndDate = false;
                        Model.ActiveSurveillanceCampaignDetail.DisableLegacyCampaignID = false;
                        Model.ActiveSurveillanceCampaignDetail.DisableCampaignAdministrator = false;
                    }
                }

                Model.PendingSaveEvents ??= new List<EventSaveRequestModel>();
                if (Model.CampaignID is not null && Model.CampaignID > 0)
                {
                    if (CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human))
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          Model.ActiveSurveillanceCampaignDetail.SiteId
                            ? SystemEventLogTypes.HumanActiveSurveillanceCampaignStatusWasChangedAtYourSite
                            : SystemEventLogTypes
                                .HumanActiveSurveillanceCampaignStatusWasChangedAtAnotherSite;
                        Model.PendingSaveEvents.Add(await CreateEvent((long) Model.CampaignID,
                                null, eventTypeId, Model.ActiveSurveillanceCampaignDetail.SiteId, null)
                            .ConfigureAwait(false));
                    }
                    else
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          Model.ActiveSurveillanceCampaignDetail.SiteId
                            ? SystemEventLogTypes.VeterinaryActiveSurveillanceCampaignWasChangedAtYourSite
                            : SystemEventLogTypes
                                .VeterinaryActiveSurveillanceCampaignWasChangedAtAnotherSite;
                        Model.PendingSaveEvents.Add(await CreateEvent((long) Model.CampaignID,
                                null, eventTypeId, Model.ActiveSurveillanceCampaignDetail.SiteId, null)
                            .ConfigureAwait(false));
                    }
                }
            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task ShowMessageDialog(string dialogName, string dialogMessage)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {"DialogName", dialogName},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(dialogMessage)}
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
            var dialogResult = result as DialogReturnResult;
            if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                _source?.Cancel();
                _source = new CancellationTokenSource();
                _token = _source.Token;
            }

            //DiagService.Close();
        }

        protected async Task ShowMessageDialog(string message)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(message)}
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
            var dialogResult = result as DialogReturnResult;
            if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                _source?.Cancel();
                _source = new();
                _token = _source.Token;
            }

            DiagService.Close();
        }



        public async Task UpdateCampaignDiseaseSpeciesSample(List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> diseaseSpeciesSamples)
        {
            if (diseaseSpeciesSamples.Count > 0 && diseaseSpeciesSamples.Find(v => v.IsInEditMode == true) != null)
                Model.IsDiseaseSpeciesSampleGridInEditMode = true;
            else
                Model.IsDiseaseSpeciesSampleGridInEditMode = false;

            Model.DiseaseSpeciesSampleList = diseaseSpeciesSamples;
           await InvokeAsync(StateHasChanged);
        }

        public async Task UpdateVetCampaignSessionList(List<VeterinaryActiveSurveillanceSessionViewModel> campaignSessionList)
        {
            Model.VetCampaignSessionList = campaignSessionList;
            await InvokeAsync(StateHasChanged);
        }


        public async Task UpdateHumanCampaignSessionList(List<ActiveSurveillanceSessionResponseModel> campaignSessionList)
        {
            Model.HumanCampaignSessionList = campaignSessionList;
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        public void Dispose()
        {
           
        }
    }
}
