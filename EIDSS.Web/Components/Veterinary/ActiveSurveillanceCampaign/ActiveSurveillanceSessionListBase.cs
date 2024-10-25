using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Veterinary.ViewModels.Veterinary.ActiveSurveillanceSession;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Veterinary.SearchActiveSurveillanceSession;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceCampaign
{
    public class ActiveSurveillanceSessionListBase : BaseComponent, IDisposable
    {

        #region Dependencies

        [Inject]
        protected IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected IBaseReferenceClient BaseReferenceClient { get; set; }

        [Inject]
        private ILogger<ActiveSurveillanceSessionListBase> Logger { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IVeterinaryClient  veterinaryClient { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public int AccessoryCode { get; set; }

        [Parameter]
        public long? CampaignId { get; set; }

        [Parameter]
        public UserPermissions permissions { get; set; }

        [Parameter]
        public long SessionCategoryId { get; set; }

        [Parameter]
        public long CampaignCategoryId { get; set; }

        [Parameter]
        public DateTime? CampaignStartDate { get; set; }

        [Parameter]
        public DateTime? CampaignEndDate { get; set; }

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        [Parameter]
        public long? CampaignStatusId { get; set; }

        [Parameter]
        public List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> DiseaseSpeciesSamples { get; set; }


        [Parameter]
        public EventCallback<List<VeterinaryActiveSurveillanceSessionViewModel>> CampaignSessionListChanged { get; set; }

        [Parameter]
        public string CampaignName { get; set; }

        [Parameter]
        public long? CampaignTypeID { get; set; }

        [Parameter]
        public string CampaignAdministrator { get; set; }

        [Parameter]
        public string EIDSSCampaignID { get; set; }

        [Parameter]
        public string Conclusion { get; set; }

        [Parameter]
        public bool IsReadOnly { get; set; }

        #endregion

        #region Private Variables

        private string _indicatorKey;
        private string _modelKey;
        private CancellationTokenSource source;
        private CancellationToken token;
        private const string DIALOG_WIDTH = "700px";
        private const string DIALOG_HEIGHT = "775px";

        #endregion

        #region Member Variables

        protected int VasCampaignSessionListCount;
        protected int VasCampaignSessionListDatabaseQueryCount;
        protected int VasCampaignSessionListLastDatabasePage;
        protected int VasCampaignSessionListNewRecordCount;

        protected RadzenDataGrid<VeterinaryActiveSurveillanceSessionViewModel> VasCampaignSessionListGrid;
        protected List<VeterinaryActiveSurveillanceSessionViewModel> VasCampaignSessionList;
        protected List<VeterinaryActiveSurveillanceSessionViewModel> VasCampaignSessionDelList;
        protected bool isLoading { get; set; }
        protected UserPermissions UserVetASSessionPermissions;

        #endregion

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "SessionID";

        #endregion

        #region methods


        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // reset the cancellation token
            source = new();
            token = source.Token;
            UserVetASSessionPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);


            VasCampaignSessionList = new List<VeterinaryActiveSurveillanceSessionViewModel>();
            VasCampaignSessionListGrid = new RadzenDataGrid<VeterinaryActiveSurveillanceSessionViewModel>();


            if (CampaignId != null)
            {
                await GetCampaignSessions();
                var args = new LoadDataArgs();
                await LoadData(args);

                //_indicatorKey = SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey;
                //_modelKey = SearchPersistenceKeys.VetActiveSurveillanceCampaignSearchModelKey;
            }

            await base.OnInitializedAsync();
        }

        protected override async Task OnParametersSetAsync()
        {

        }

        protected async Task GetCampaignSessions()
        {

            try
            {
                var request = new VeterinaryActiveSurveillanceSessionSearchRequestModel();

                request.LanguageId = GetCurrentLanguage();
                request.CampaignKey = CampaignId;
                request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
                request.UserOrganizationID = _tokenService.GetAuthenticatedUser().OfficeId;
                request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                if (_tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel))
                {
                    request.ApplySiteFiltrationIndicator = true;
                }
                else
                {
                    request.ApplySiteFiltrationIndicator = false;
                }

                request.SortColumn = "SessionID";
                request.SortOrder =  "desc";

                request.PageSize =  1000;
                request.Page = 1;

                var result = await veterinaryClient.GetActiveSurveillanceSessionListAsync(request, token);
                if (source?.IsCancellationRequested == false)
                {
                    VasCampaignSessionList = result;
                    VasCampaignSessionListCount = VasCampaignSessionList?.Count ?? 0;
                    await CampaignSessionListChanged.InvokeAsync(VasCampaignSessionList);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                //catch cancellation or timeout exception
                if (source?.IsCancellationRequested == true)
                {
                    //await ShowNarrowSearchCriteriaDialog();
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                
                VasCampaignSessionListCount = VasCampaignSessionList?.Count ?? 0;
               
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
            finally
            {
                await InvokeAsync(StateHasChanged);
            }


        }

        protected void OpenEdit(long id)
        {
            NavManager.NavigateTo($"Veterinary/ActiveSurveillanceSession/Details?sessionID={id}", true);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected bool CheckPermissonForEditOrDelete()
        {
            if (UserVetASSessionPermissions.Read && UserVetASSessionPermissions.Write)
                return true;
            else return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="monitoringSessionId"></param>
        /// <returns></returns>
        protected async Task DeleteCampaignSessionAsync(long monitoringSessionId)
        {
            try
            {
                if (VasCampaignSessionList != null)
                {
                    var itemToRemove = VasCampaignSessionList.FirstOrDefault(r => r.SessionKey == monitoringSessionId);
                    if (itemToRemove != null)
                    {
                        var request = new DisassociateSessionFromCampaignSaveRequestModel
                        {
                            idfCampaign = CampaignId.Value,
                            idfMonitoringSesion = monitoringSessionId,
                            AuditUserName = _tokenService.GetAuthenticatedUser().UserName
                        };
                        var response = await CrossCuttingClient.DisassociateSessionFromCampaignAsync(request,token);
                        if (response.ReturnCode == 0)
                        {
                            VasCampaignSessionList.Remove(itemToRemove);
                            VasCampaignSessionListCount = VasCampaignSessionList.Count();
                            await CampaignSessionListChanged.InvokeAsync(VasCampaignSessionList);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
           
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="monitoringSessionID"></param>
        /// <returns></returns>
        public async Task onDelete(long monitoringSessionID)
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
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        await DeleteCampaignSessionAsync(monitoringSessionID);
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void SendReportLink(long id)
        {
            if (Mode == SearchModeEnum.Import)
            {
                if (CallbackUrl.EndsWith('/'))
                {
                    CallbackUrl = CallbackUrl.Substring(0, CallbackUrl.Length - 1);
                }

                var url = CallbackUrl + $"?Id={id}";

                if (CallbackKey != null)
                {
                    url += "&callbackkey=" + CallbackKey.ToString();
                }
                NavManager.NavigateTo(url, true);
            }
            else if (Mode == SearchModeEnum.Select)
            {
                DiagService.Close(VasCampaignSessionList.First(x => x.SessionKey == id));
            }
            else
            {
                var uri = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceSession/Details?sessionID={id}&isReadOnly=true";
                NavManager.NavigateTo(uri, true);
            }
        }

        protected async Task OnSearchSessionClick()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchVeterinaryActiveSurveillanceSession>("Active Surveillance Session Search",
                    new Dictionary<string, object> { { "Mode", SearchModeEnum.Select } }, options: new DialogOptions()
                    {
                        Width = DIALOG_WIDTH,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result != null)
                {
                    var asSessionModel = result as VeterinaryActiveSurveillanceSessionViewModel;
                    if (VasCampaignSessionList != null)
                    {
                        if (VasCampaignSessionList.FirstOrDefault(c => c.SessionKey == asSessionModel.SessionKey) ==
                            null)
                        {
                            {
                                var compareStartDateResult =
                                    CompareCampaignStartEndDateWithSessionStartDate(asSessionModel);
                                var compareEndDateResult =
                                    CompareCampaignStartEndDateWithSessionEndDate(asSessionModel);

                                if (compareStartDateResult && compareEndDateResult)
                                {
                                    if (asSessionModel != null)
                                    {
                                        var request =
                                            new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel()
                                            {
                                                MonitoringSessionID = asSessionModel.SessionKey,
                                                LanguageID = GetCurrentLanguage()
                                            };

                                        var response = await veterinaryClient
                                            .GetActiveSurveillanceSessionDiseaseSpeciesListAsync(
                                                request, token);
                                        var comparePartialResult = CompareDiseaseSamples(response);

                                        switch (comparePartialResult)
                                        {
                                            case DiseaseSampleCompare.SameSample:
                                                //Link
                                                await LinkSessionToCampaign(asSessionModel);
                                                break;
                                            case DiseaseSampleCompare.DifferentSample:
                                                var returnCount = await CheckSamplesCollected(asSessionModel.SiteKey);
                                                if (returnCount > 0)
                                                {
                                                    await ShowMessageDialog(
                                                        "The Disease and Species List in the Active Surveillance Session must be the same or be the subset of the Disease and Species List in the chosen Active Surveillance Campaign");
                                                }
                                                else
                                                {
                                                    var blResult = await DiagService.Confirm(
                                                        Localizer.GetString("Do you want to overwrite species/samples"),
                                                        Localizer.GetString(HeadingResourceKeyConstants
                                                            .EIDSSModalHeading),
                                                        new ConfirmOptions()
                                                            {OkButtonText = "Yes", CancelButtonText = "No"});
                                                    if (blResult == true)
                                                    {
                                                        await LinkSessionToCampaign(asSessionModel);
                                                    }
                                                }

                                                //Check samples Collected and ask for samples overwrite and overwrite for yes
                                                //link
                                                break;
                                            case DiseaseSampleCompare.DifferentDisease:
                                                //
                                                await ShowMessageDialog(
                                                    "Session’s {Disease, Species-Sample Type combination, Start Date} does not match the Campaign and cannot be selected");
                                                break;
                                        }
                                    }
                                }
                                else
                                {
                                    await ShowMessageDialog(
                                        "Session’s {Disease, Species-Sample Type combination, Start Date} does not match the Campaign and cannot be selected");
                                }
                            }
                        }
                        else
                        {
                            await ShowMessageDialog(MessageResourceKeyConstants.DuplicateRecordsAreNotAllowedMessage);
                        }
                    }
                    DiagService.Close(result);

                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }


        protected async Task<int> CheckSamplesCollected(long idfMonitoringSession)
        {
            int returnResult = 0;
            try
            {
                var request = new VeterinaryActiveSurveillanceSessionDetailRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    MonitoringSessionID = idfMonitoringSession,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = "asc"
                };

                var result = await veterinaryClient.GetActiveSurveillanceSessionDetailAsync(request, token);
                if (result != null)
                {
                    returnResult = result.Count;
                }



            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                if (source?.IsCancellationRequested == true)
                {

                }
                else
                {
                    throw;
                }
            }
            return returnResult;
        }

        private DiseaseSampleCompare CompareDiseaseSamples(List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> response)
        {
            var returnValue = DiseaseSampleCompare.None;
            if (response != null)
            {
                // var compare = response.Where(d => DiseaseSpeciesSamples.Any(r => r.idfsDiagnosis == d.DiseaseID && r.idfsSampleType == d.SampleTypeID));
                var diseaseCompare = response.Where(d => DiseaseSpeciesSamples.TrueForAll(r => r.idfsDiagnosis == d.DiseaseID));
                if (diseaseCompare.Any())
                {
                    returnValue = DiseaseSampleCompare.SameDisease;
                    //disease is same 
                    var samplesCompare =
                        response.Where(d => DiseaseSpeciesSamples.TrueForAll(r => r.idfsSampleType == d.SampleTypeID));
                    if (samplesCompare.Any())
                    {
                        //samples is same 
                        returnValue = DiseaseSampleCompare.SameSample;
                    }
                    else
                    {
                        //sample is not same 
                        returnValue = DiseaseSampleCompare.DifferentSample;
                    }
                }
                else
                {
                    //disease is not same 
                    returnValue = DiseaseSampleCompare.DifferentDisease;
                }
            }

            return returnValue;
        }

        private bool CompareCampaignStartEndDateWithSessionStartDate(VeterinaryActiveSurveillanceSessionViewModel asSessionModel)
        {
            if (CampaignStartDate != null)
            {
                if (asSessionModel.StartDate != null)
                {
                    if (asSessionModel.StartDate < CampaignStartDate)
                    {
                        return false;
                    }

                    if (asSessionModel.EndDate < CampaignStartDate)
                    {
                        return false;
                    }
                }
            }

            return true;

        }

        private bool CompareCampaignStartEndDateWithSessionEndDate(VeterinaryActiveSurveillanceSessionViewModel asSessionModel)
        {
            if (CampaignEndDate != null)
            {
                if (asSessionModel.StartDate != null)
                {
                    if (asSessionModel.StartDate > CampaignEndDate)
                    {
                        return false;
                    }

                    if (asSessionModel.EndDate > CampaignEndDate)
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        private async Task LinkSessionToCampaign(VeterinaryActiveSurveillanceSessionViewModel asSessionModel)
        {
            if (asSessionModel != null)
            {
                asSessionModel.CampaignKey = CampaignId;
                VasCampaignSessionList.Add(asSessionModel);
            }

            VasCampaignSessionListCount = VasCampaignSessionList.Count();
            await CampaignSessionListChanged.InvokeAsync(VasCampaignSessionList);

            if (VasCampaignSessionListGrid != null)
            {
                await VasCampaignSessionListGrid.Reload();
                await InvokeAsync(StateHasChanged);
            
            }
        }

        protected async Task OnAddSessionClickAsync()
        {
            var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToSaveYourChangesMessage, null);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                var response = await SaveActiveSurveillance();
                if (response is { ReturnCode: 0 })
                {
                    string url = null;

                    if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Human))
                    {
                        if (CampaignId != null)
                            url = $"{NavManager.BaseUri}Human/ActiveSurveillanceSession/Add?campaignId={CampaignId.Value}";
                    }
                    else
                    {
                        if (CampaignId != null)
                            url = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceSession/Add?campaignId={CampaignId.Value}";
                    }

                    if (url != null) NavManager.NavigateTo(url, true);
                }
            }
        }

        private async Task<ActiveSurveillanceCampaignSaveResponseModel> SaveActiveSurveillance()
        {
            try
            {
                var result = new ActiveSurveillanceCampaignSaveResponseModel();
                //model.PendingSaveEvents ??= new List<EventSaveRequestModel>();
                var PendingSaveEvents = new List<EventSaveRequestModel>();

                var dateValid = await IsValidOnChangeStartDateAsync(CampaignStartDate);
                if (!dateValid) return result;
                dateValid = await IsValidOnChangeEndDateAsync(CampaignEndDate);
                if (!dateValid) return result;
                ActiveSurveillanceCampaignSaveRequestModel request = new()
                {
                    idfCampaign = CampaignId,
                    LanguageId = GetCurrentLanguage(),
                    CampaignName = CampaignName,
                    CampaignCategoryTypeID = CampaignCategoryId,
                    CampaignStatusTypeID = CampaignStatusId.Value,
                    CampaignTypeID = CampaignTypeID.Value,
                    CampaignAdministrator = CampaignAdministrator,
                    CampaignDateStart = CampaignStartDate,
                    CampaignDateEnd = CampaignEndDate,
                    AuditUserName = authenticatedUser.UserName,
                    SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    strCampaignID = EIDSSCampaignID,
                    Conclusion = Conclusion
                };

                var tlbCampaignToDiagnosesList = new List<TlbCampaignToDiagnosis>();
                if (DiseaseSpeciesSamples != null)
                {
                    tlbCampaignToDiagnosesList = DiseaseSpeciesSamples.Where(a => a.RowStatus == (int)RowStatusTypeEnum.Active).Select(a => new TlbCampaignToDiagnosis
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

                if (VasCampaignSessionList is { Count: > 0 })
                {
                    tlbCampaignSessionList = VasCampaignSessionList.Select(a => new TlbCampaignSession
                    {
                        idfMonitoringSession = a.SessionKey,
                        deleteFlag = a.CampaignKey == null

                    }).ToList();
                }

                if (VasCampaignSessionList is { Count: > 0 })
                {
                    tlbCampaignSessionList = VasCampaignSessionList.Select(a => new TlbCampaignSession
                    {
                        idfMonitoringSession = a.SessionKey,
                        deleteFlag = a.CampaignKey == null

                    }).ToList();
                }
                //previousStatus = CampaignStatusId;
                //previousStartDate = CampaignStartDate;
                //previousEndDate = CampaignEndDate;
                request.CampaignToDiagnosisCombo = System.Text.Json.JsonSerializer.Serialize(tlbCampaignToDiagnosesList);
                request.MonitoringSessions = System.Text.Json.JsonSerializer.Serialize(tlbCampaignSessionList);

                if (request.idfCampaign is null)
                {
                    long? diseaseId = null;
                    if (DiseaseSpeciesSamples is { Count: > 0 })
                    {
                        diseaseId = DiseaseSpeciesSamples.First().idfsDiagnosis;
                    }
                    if (CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human))
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          Convert.ToInt64(request.SiteID)
                            ? SystemEventLogTypes.NewHumanActiveSurveillanceCampaignWasCreatedAtYourSite
                            : SystemEventLogTypes
                                .NewHumanActiveSurveillanceCampaignWasCreatedAtAnotherSite;

                        PendingSaveEvents.Add(await CreateEvent(0,
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

                        PendingSaveEvents.Add(await CreateEvent(0,
                                diseaseId, eventTypeId, Convert.ToInt64(request.SiteID), null)
                            .ConfigureAwait(false));
                    }
                }

                request.Events = JsonConvert.SerializeObject(PendingSaveEvents);
                result = await CrossCuttingClient.SaveActiveSurveillanceCampaignAsync(request, token);

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task<bool> IsValidOnChangeStartDateAsync(object value)
        {
            var isValid = true;
            if (value != null)
            {
                var startDate = (DateTime?)value;

                if (VasCampaignSessionList != null)
                {
                    if (VasCampaignSessionList.Any(s => s.StartDate < startDate || s.EndDate < startDate))
                    {
                        await ShowMessageDialog("The Session’s period (XX/XX/XXX-…) must match the Campaign period (XX/XX/XXX- XX/XX/XXX)");
                        CampaignStartDate = null;
                        isValid = false;
                    }
                }
            }
            await InvokeAsync(StateHasChanged);
            return isValid;
        }

        protected async Task<bool> IsValidOnChangeEndDateAsync(object value)
        {
            var isValid = true;
            if (value != null)
            {
                var endDate = (DateTime?)value;

                if (VasCampaignSessionList != null)
                {
                    if (VasCampaignSessionList.Any(s => s.StartDate > endDate || s.EndDate > endDate))
                    {
                        await ShowMessageDialog("The Session’s period (XX/XX/XXX-…) must match the Campaign period (XX/XX/XXX- XX/XX/XXX)");
                        CampaignEndDate = null;
                        isValid = false;
                    }
                }
            }
            await InvokeAsync(StateHasChanged);
            return isValid;
        }

        protected async Task ShowMessageDialog(string message)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(message));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    source?.Cancel();
                    source = new();
                    token = source.Token;
                }

                DiagService.Close(result);


            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion

        public void Dispose()
        {

        }
    }
}
