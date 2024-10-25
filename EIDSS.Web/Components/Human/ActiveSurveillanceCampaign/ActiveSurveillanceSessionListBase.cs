using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Human.SearchActiveSurveillanceSession;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Web.Components.Vector;
using EIDSS.Web.Components.Vector.Common;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.ClientLibrary;
using Microsoft.JSInterop;
using EIDSS.Web.Services;
using System.Linq.Dynamic.Core;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceCampaign
{
    public class ActiveSurveillanceSessionListBase : BaseComponent, IDisposable
    {
        #region GridColumnChooser and ColumnReOrder

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        #endregion GridColumnChooser and ColumnReOrder

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
        private IVeterinaryClient veterinaryClient { get; set; }

        [Inject]
        private IHumanActiveSurveillanceSessionClient _humanActiveSurveillanceSessionClient { get; set; }

        #endregion Dependencies

        #region parameters

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
        public EventCallback<List<ActiveSurveillanceSessionResponseModel>> CampaignSessionListChanged { get; set; }

        #endregion parameters

        #region private variables

        private string _indicatorKey;
        private string _modelKey;
        private CancellationTokenSource source;
        private CancellationToken token;
        private const string DIALOG_WIDTH = "850px";
        private const string DIALOG_HEIGHT = "750px";

        #endregion private variables

        #region Member Variables

        protected int HasCampaignSessionListCount;
        protected int HasCampaignSessionListDatabaseQueryCount;
        protected int HasCampaignSessionListLastDatabasePage;
        protected int HasCampaignSessionListNewRecordCount;

        protected RadzenDataGrid<ActiveSurveillanceSessionResponseModel> HasCampaignSessionListGrid;
        protected List<ActiveSurveillanceSessionResponseModel> HasCampaignSessionList;
        protected List<ActiveSurveillanceSessionResponseModel> HasCampaignSessionDelList;
        protected bool isLoading { get; set; }
        protected UserPermissions UserHumanASSessionPermissions;

        #endregion Member Variables

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "SessionID";

        #endregion Constants

        #region Methods

        protected override void OnInitialized()
        {
            gridExtension = new GridExtensionBase();
            GridColumnLoad("HasCampaignSessionListGrid");

            base.OnInitialized();
        }

        protected override async Task OnInitializedAsync()
        {
            GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);
            _logger = Logger;

            // reset the cancellation token
            source = new();
            token = source.Token;

            UserHumanASSessionPermissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceCampaign);

            HasCampaignSessionList = new List<ActiveSurveillanceSessionResponseModel>();
            HasCampaignSessionListGrid = new RadzenDataGrid<ActiveSurveillanceSessionResponseModel>();

            if (CampaignId != null)
            {
                await GetCampaignSessions();
                var args = new LoadDataArgs();
                await LoadData(args);

                //_indicatorKey = SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchPerformedIndicatorKey;
                //_modelKey = SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchModelKey;
            }

            await base.OnInitializedAsync();
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                HasCampaignSessionListCount = HasCampaignSessionList != null ? HasCampaignSessionList.Count : 0;
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

        protected async Task GetCampaignSessions()
        {
            try
            {
                var request = new ActiveSurveillanceSessionRequestModel();

                request.LanguageID = GetCurrentLanguage();
                request.CampaignKey = CampaignId;
                request.SessionID = null;
                request.SessionStatusTypeID = null;
                request.SessionStatusTypeID = null;
                request.DateEnteredFrom = null;
                request.DateEnteredTo = null;
                request.AdministrativeLevelID = null;
                request.DiseaseID = null;
                request.AdministrativeLevelID = null;

                request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
                request.UserOrganizationID = _tokenService.GetAuthenticatedUser().OfficeId;
                request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel);

                request.SortColumn = "SessionID";
                request.SortOrder = "desc";

                request.PageSize = 1000;
                request.PageNumber = 1;

                var result = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionListAsync(request, token);
                if (source?.IsCancellationRequested == false)
                {
                    HasCampaignSessionList = result;
                    HasCampaignSessionListCount = HasCampaignSessionList?.Count ?? 0;
                    await CampaignSessionListChanged.InvokeAsync(HasCampaignSessionList);
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

        protected void OpenEdit(long id)
        {
            NavManager.NavigateTo($"Human/ActiveSurveillanceSession/Create?id={id}", true);
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
                DiagService.Close(HasCampaignSessionList.First(x => x.SessionKey == id));
            }
            else
            {
                //  NavManager.NavigateTo($"Human/HumanDiseaseReport/SelectForReadOnly/{id}", true);
            }
        }

        protected async Task OnSearchSessionClick()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchHumanActiveSurveillanceSession>("Active Surveillance Session Search",
                    new Dictionary<string, object> { { "Mode", SearchModeEnum.Select } }, options: new DialogOptions()
                    {
                        Width = DIALOG_WIDTH,
                        //Height = DIALOG_HEIGHT,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result != null)
                {
                    var asSessionModel = result as ActiveSurveillanceSessionResponseModel;

                    if (HasCampaignSessionList != null)
                    {
                        if (HasCampaignSessionList.FirstOrDefault(c => asSessionModel != null && c.SessionKey == asSessionModel.SessionKey) == null)
                        {
                            if (asSessionModel != null)
                            {
                                var compareStartDateResult = CompareCampaignStartEndDateWithSessionStartDate(asSessionModel);
                                var compareEndDateResult = CompareCampaignStartEndDateWithSessionEndDate(asSessionModel);

                                if (compareStartDateResult && compareEndDateResult)
                                {
                                    var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel()
                                    {
                                        MonitoringSessionID = asSessionModel.SessionKey,
                                        LanguageID = GetCurrentLanguage()
                                    };

                                    var response =
                                        await veterinaryClient.GetActiveSurveillanceSessionDiseaseSpeciesListAsync(
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
                                                var blResult = await DiagService.Confirm(Localizer.GetString("Do you want to overwrite species/samples"), Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), new ConfirmOptions() { OkButtonText = "Yes", CancelButtonText = "No" });
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
                                else
                                {
                                    await ShowMessageDialog(
                                        "Session’s {Disease, Species-Sample Type combination, Start Date} does not match the Campaign and cannot be selected");
                                }
                            }
                            else
                            {
                                await ShowMessageDialog(
                                    "Session’s {Disease, Species-Sample Type combination, Start Date} does not match the Campaign and cannot be selected");
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
                var request = new ActiveSurveillanceSessionDetailedInformationRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfMonitoringSession = idfMonitoringSession,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = "asc"
                };

                var result = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionDetailedInformation(request, token);
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

        private async Task LinkSessionToCampaign(ActiveSurveillanceSessionResponseModel asSessionModel)
        {
            if (asSessionModel != null)
            {
                asSessionModel.CampaignKey = CampaignId;
                HasCampaignSessionList.Add(asSessionModel);
            }

            HasCampaignSessionListCount = HasCampaignSessionList.Count();
            await CampaignSessionListChanged.InvokeAsync(HasCampaignSessionList);

            if (HasCampaignSessionListGrid != null)
            {
                await InvokeAsync(() =>
                {
                    HasCampaignSessionListGrid.Reload();
                    StateHasChanged();
                });
            }
        }

        private bool CompareCampaignStartEndDateWithSessionStartDate(ActiveSurveillanceSessionResponseModel asSessionModel)
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

        private bool CompareCampaignStartEndDateWithSessionEndDate(ActiveSurveillanceSessionResponseModel asSessionModel)
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

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected bool CheckPermissonForEditOrDelete()
        {
            if (UserHumanASSessionPermissions.Read && UserHumanASSessionPermissions.Write)
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
                if (HasCampaignSessionList != null)
                {
                    var itemToRemove = HasCampaignSessionList.FirstOrDefault(r => r.SessionKey == monitoringSessionId);
                    if (itemToRemove != null)
                    {
                        var request = new DisassociateSessionFromCampaignSaveRequestModel
                        {
                            idfCampaign = CampaignId.Value,
                            idfMonitoringSesion = monitoringSessionId,
                            AuditUserName = _tokenService.GetAuthenticatedUser().UserName
                        };
                        var response = await CrossCuttingClient.DisassociateSessionFromCampaignAsync(request, token);
                        if (response.ReturnCode == 0)
                        {
                            HasCampaignSessionList.Remove(itemToRemove);
                            HasCampaignSessionListCount = HasCampaignSessionList.Count();
                            await CampaignSessionListChanged.InvokeAsync(HasCampaignSessionList);
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

        protected void OnAddSessionClick()
        {
            string url;

            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Human))
            {
                url = $"{NavManager.BaseUri}Human/ActiveSurveillanceSession/Create?campaignId={CampaignId.Value}";
            }
            else
            {
                url = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceSession/add?campaignId={CampaignId.Value}";
            }
            NavManager.NavigateTo(url, true);
        }

        #endregion Methods

        public void Dispose()
        {
        }

        #region Added For Grid Methods

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, HasCampaignSessionListGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = gridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = gridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task StateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion Added For Grid Methods
    }
}