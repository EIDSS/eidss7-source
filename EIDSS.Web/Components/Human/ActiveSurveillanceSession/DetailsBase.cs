#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class DetailsBase : ParentComponent, IDisposable
    {
        #region Globals

        protected ActiveSurveillanceSessionViewModel Model;
        protected RadzenTemplateForm<ActiveSurveillanceSessionViewModel> SessionInformation;

        private CancellationTokenSource _source;
        private CancellationToken _token;
        protected bool IsLoading;

        protected SessionInformation SessionInformationComponent;

        [Inject] private ILogger<DetailsBase> Logger { get; set; }

        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;

                //reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                DiagService.OnClose += DialogClose;
                StateContainer.OnChange += StateHasChanged;

                await InitializeModel();

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    if (NavManager.TryGetQueryString("id", out long id))
                    {
                        NavManager.TryGetQueryString("readonly", out string recordReadOnly);
                        Model.RecordReadOnly = bool.Parse(recordReadOnly ?? "false");

                        if (Model.RecordReadOnly)
                        {
                            Model.ActiveSurveillanceSessionPermissions.Write = false;
                            Model.ActiveSurveillanceSessionPermissions.Delete = false;
                        }
                        else
                        {
                            Model.ActiveSurveillanceSessionPermissions =
                                GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                        }

                        await GetDetail(id);
                    }
                    else
                    {
                        if (NavManager.TryGetQueryString("campaignId", out long campaignId))
                        {
                            Model.SessionInformation.CampaignID = campaignId;

                            var request = new ActiveSurveillanceCampaignDetailRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                CampaignID = campaignId
                            };

                            var result =
                                await CrossCuttingClient.GetActiveSurveillanceCampaignGetDetailAsync(request, _token);

                            Model.SessionInformation.CampaignID = result[0].CampaignID;
                            Model.SessionInformation.strCampaignID = result[0].EIDSSCampaignID;
                            Model.SessionInformation.CampaignName = result[0].CampaignName;
                            Model.SessionInformation.CampaignTypeID = result[0].CampaignTypeID;
                            Model.SessionInformation.CampaignTypeName = result[0].CampaignTypeName;

                            var campaignDiseaseSpeciesSamplesRequest =
                                new ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel()
                                {
                                    CampaignID = campaignId,
                                    LanguageId = GetCurrentLanguage(),
                                    Page = 1,
                                    PageSize = MaxValue - 1,
                                    SortColumn = "idfCampaign",
                                    SortOrder = EIDSSConstants.SortConstants.Descending
                                };

                            var diseaseSamplesList =
                                await CrossCuttingClient.GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync(
                                    campaignDiseaseSpeciesSamplesRequest, _token);

                            var diseasesSampleTypes = new List<ActiveSurveillanceSessionDiseaseSampleType>();
                            var monitoringSessionToSampleTypes =
                                new List<ActiveSurveillanceSessionSamplesResponseModel>();

                            var monitoringSessionToDiseaseId = -1;

                            Model.Summary.Disease = Empty;

                            foreach (var diseaseSampleType in diseaseSamplesList)
                            {
                                if (Model.Summary.Disease.IndexOf(diseaseSampleType.Disease, StringComparison.Ordinal) < 0)
                                {
                                    Model.Summary.Disease += diseaseSampleType.Disease + ", ";
                                }

                                if (diseaseSampleType.idfsDiagnosis != null)
                                {
                                    if (diseaseSampleType.idfsSampleType != null)
                                    {
                                        var diseasesSampleType = new ActiveSurveillanceSessionDiseaseSampleType
                                        {
                                            ID = monitoringSessionToDiseaseId--,
                                            DiseaseID = (long) diseaseSampleType.idfsDiagnosis,
                                            DiseaseName = diseaseSampleType.Disease,
                                            SampleTypeID = (long) diseaseSampleType.idfsSampleType,
                                            SampleTypeName = diseaseSampleType.SampleTypeName,
                                            RowAction = EIDSSConstants.UserAction.Insert
                                        };

                                        diseasesSampleTypes.Add(diseasesSampleType);
                                    }
                                }

                                var monitoringSessionToSampleType = new ActiveSurveillanceSessionSamplesResponseModel
                                {
                                    MonitoringSessionID = id
                                };
                                monitoringSessionToSampleType.MonitoringSessionToSampleType =
                                    monitoringSessionToSampleType.NewMonitoringSessionToSampleTypeID--;
                                monitoringSessionToSampleType.SampleTypeID = diseaseSampleType.idfsSampleType;
                                monitoringSessionToSampleType.SampleTypeName = diseaseSampleType.SampleTypeName;

                                monitoringSessionToSampleTypes.Add(monitoringSessionToSampleType);
                            }

                            Model.DiseasesSampleTypesUnfiltered = diseasesSampleTypes.GroupBy(x => x.DiseaseID)
                                .Select(group => group.First()).ToList();
                            Model.DiseasesSampleTypes = diseasesSampleTypes;
                            Model.DiseasesSampleTypesCount = diseasesSampleTypes.Count;
                            Model.SessionInformation.MonitoringSessionToSampleTypes = monitoringSessionToSampleTypes;
                        }

                        Model.SessionInformation.MonitoringSessionStatusTypeID =
                            EIDSSConstants.ActiveSurveillanceSessionStatusIds.Open;

                        IdfMonitoringSession = null;
                    }

                    bool deletePermission;
                    bool writePermission;

                    if (Model.SessionInformation.MonitoringSessionID is > 0)
                    {
                        if (Model.SessionInformation.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                            authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                        {
                            deletePermission = Model.SessionInformation.DeletePermissionIndicator;
                            writePermission = Model.SessionInformation.WritePermissionIndicator;
                        }
                        else
                        {
                            var permissions =
                                GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                            deletePermission = permissions.Delete;
                            writePermission = permissions.Write;
                        }
                    }
                    else
                    {
                        var permissions =
                            GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                        deletePermission = permissions.Delete;
                        writePermission = permissions.Create;
                    }

                    //Override Delete with Write permission, if Write is false.
                    deletePermission = writePermission && deletePermission;

                    if (Model.ActiveSurveillanceSessionPermissions.Read)
                    {
                        await JsRuntime.InvokeAsync<string>("initializeSideBar", _token, deletePermission,
                            writePermission);

                        if (NavManager.TryGetQueryString("id", out long _))
                        {
                            NavManager.TryGetQueryString("isReview", out string isReviewQS);
                            var isReview = bool.Parse(isReviewQS ?? "false");
                            if (isReview)
                            {
                                await JsRuntime.InvokeVoidAsync("navigateToReviewStep", _token);
                            }
                        }
                    }
                    else
                    {
                        await JsRuntime.InvokeAsync<string>("insufficientPermissions", _token);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<bool> GetDetail(long id)
        {
            try
            {
                IdfMonitoringSession = id;

                var sessionRequest = new ActiveSurveillanceSessionDetailRequestModel
                {
                    LanguageID = GetCurrentLanguage(),
                    MonitoringSessionID = id,
                    ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
                };

                var response = await HumanActiveSurveillanceSessionClient.GetHumanActiveSurveillanceSessionDetailAsync(sessionRequest, _token);

                //Session Details
                if (response.Any())
                {
                    var session = response[0];
                    Model.SessionInformation.CampaignID = session.CampaignID;
                    Model.SessionInformation.strCampaignID = session.strCampaignID;
                    Model.SessionInformation.CampaignName = session.CampaignName;
                    Model.SessionInformation.CampaignTypeID = session.CampaignTypeID;
                    Model.SessionInformation.CampaignTypeName = session.CampaignTypeName;
                    Model.SessionInformation.DiseaseID = session.DiseaseID;
                    Model.SessionInformation.EIDSSSessionID = session.EIDSSSessionID;
                    Model.SessionInformation.EndDate = session.EndDate;
                    Model.SessionInformation.EnteredDate = session.EnteredDate;
                    Model.SessionInformation.MonitoringSessionID = session.HumanMonitoringSessionID;
                    Model.SessionInformation.MonitoringSessionStatusTypeID = session.SessionStatusTypeID;
                    Model.SessionInformation.Officer = session.EnteredByPersonName;
                    Model.SessionInformation.OfficerID = long.Parse(session.EnteredByPersonID.ToString());
                    Model.SessionInformation.Site = session.SiteName;
                    Model.SessionInformation.SiteID = session.SiteID;
                    Model.SessionInformation.StartDate = session.StartDate;
                    Model.SessionInformation.MonitoringSessionStatusTypeID = session.SessionStatusTypeID;
                    Model.SessionInformation.MonitoringSessionStatusTypeID_Original = session.SessionStatusTypeID;
                    Model.SessionInformation.AccessToGenderAndAgeDataPermissionIndicator =
                        session.AccessToGenderAndAgeDataPermissionIndicator;
                    Model.SessionInformation.AccessToPersonalDataPermissionIndicator =
                        session.AccessToPersonalDataPermissionIndicator;
                    Model.SessionInformation.DeletePermissionIndicator = session.DeletePermissionIndicator;
                    Model.SessionInformation.ReadPermissionIndicator = session.ReadPermissionIndicator;
                    Model.SessionInformation.WritePermissionIndicator = session.WritePermissionIndicator;

                    if (session.SiteID != Convert.ToInt64(authenticatedUser.SiteId))
                    {
                        Model.ActiveSurveillanceSessionPermissions.Delete = session.DeletePermissionIndicator;
                        Model.ActiveSurveillanceSessionPermissions.AccessToGenderAndAgeData =
                            session.AccessToGenderAndAgeDataPermissionIndicator;
                        Model.ActiveSurveillanceSessionPermissions.AccessToPersonalData =
                            session.AccessToPersonalDataPermissionIndicator;
                        Model.ActiveSurveillanceSessionPermissions.Read = session.ReadPermissionIndicator;
                        Model.ActiveSurveillanceSessionPermissions.Write = session.WritePermissionIndicator;
                    }

                    var diseaseSampleTypeRequest = new ActiveSurveillanceSessionDiseaseSampleTypeRequestModel
                    {
                        LanguageID = GetCurrentLanguage(),
                        MonitoringSessionID = id
                    };

                    var diseaseSampleTypeList =
                        await HumanActiveSurveillanceSessionClient.GetHumanActiveSurveillanceDiseaseSampleTypeListAsync(
                            diseaseSampleTypeRequest, _token);

                    var diseasesSampleTypes = new List<ActiveSurveillanceSessionDiseaseSampleType>();
                    var monitoringSessionToSampleType = new ActiveSurveillanceSessionSamplesResponseModel();
                    var monitoringSessionToSampleTypes = new List<ActiveSurveillanceSessionSamplesResponseModel>();

                    Model.Summary.Disease = Empty;

                    foreach (var diseaseSampleType in diseaseSampleTypeList)
                    {
                        if (Model.Summary.Disease.IndexOf(diseaseSampleType.DiseaseName, StringComparison.Ordinal) < 0)
                        {
                            Model.Summary.Disease += diseaseSampleType.DiseaseName + ", ";
                        }

                        var diseasesSampleType = new ActiveSurveillanceSessionDiseaseSampleType
                        {
                            ID = diseaseSampleType.MonitoringSessionToDiseaseID,
                            DiseaseID = diseaseSampleType.DiseaseID,
                            DiseaseName = diseaseSampleType.DiseaseName,
                            SampleTypeID = long.Parse(diseaseSampleType.SampleTypeID.ToString()),
                            SampleTypeName = diseaseSampleType.SampleTypeName
                        };

                        diseasesSampleTypes.Add(diseasesSampleType);

                        monitoringSessionToSampleType.MonitoringSessionID = id;
                        monitoringSessionToSampleType.SampleTypeID =
                            long.Parse(diseaseSampleType.SampleTypeID.ToString());
                        monitoringSessionToSampleType.SampleTypeName = diseaseSampleType.SampleTypeName;

                        monitoringSessionToSampleTypes.Add(monitoringSessionToSampleType);
                    }

                    if (diseasesSampleTypes.Count > 0)
                    {
                        diseasesSampleTypes = diseasesSampleTypes.GroupBy(x => x.DiseaseID)
                            .Select(group => group.First()).ToList();
                    }

                    var samplesRequest = new ActiveSurveillanceSessionSamplesListRequestModel()
                    {
                        LanguageID = GetCurrentLanguage(),
                        MonitoringSessionID = IdfMonitoringSession,
                        pageNo = 1,
                        pageSize = 10,
                        sortColumn = "SampleTypeName",
                        sortOrder = EIDSSConstants.SortConstants.Descending
                    };

                    var samplesList =
                        await HumanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionToSampleList(
                            samplesRequest, _token);

                    Model.DiseasesSampleTypesUnfiltered = diseasesSampleTypes;
                    Model.DiseasesSampleTypes = diseasesSampleTypes;
                    Model.DiseasesSampleTypesCount = diseasesSampleTypes.Count;
                    Model.SessionInformation.MonitoringSessionToSampleTypes = samplesList.GroupBy(x => x.SampleTypeID)
                        .Select(group => group.First()).ToList();

                    Model.Summary.Disease = (Model.Summary.Disease + ".").Replace(", .", "");

                    //Summary Header
                    await GetBaseReferenceItems(null, EIDSSConstants.BaseReferenceConstants.ASSessionStatus);
                    Model.Summary.Status = Statuses.First(x => x.IdfsBaseReference == session.SessionStatusTypeID).Name;
                    Model.Summary.SessionID = Model.SessionInformation.EIDSSSessionID;

                    Model.SessionInformation.LocationViewModel.AdminLevel0Value = session.AdminLevel1ID;
                    Model.SessionInformation.LocationViewModel.AdminLevel0Text = session.AdminLevel1Name;
                    Model.SessionInformation.LocationViewModel.AdminLevel1Value = session.AdminLevel2ID;
                    Model.SessionInformation.LocationViewModel.AdminLevel1Text = session.AdminLevel2Name;
                    Model.SessionInformation.LocationViewModel.AdminLevel2Value = session.AdminLevel3ID;
                    Model.SessionInformation.LocationViewModel.AdminLevel2Text = session.AdminLevel3Name;
                    Model.SessionInformation.LocationViewModel.AdminLevel3Value = session.AdminLevel4ID;
                    Model.SessionInformation.LocationViewModel.AdminLevel3Text = session.AdminLevel4Name;

                    StateContainer.SetActiveSurveillanceSessionViewModel(Model);
                    await SessionInformationComponent.ComponentRefresh(StateContainer.Model.SessionInformation
                        .LocationViewModel);
                    await InvokeAsync(StateHasChanged);
                }
                else
                    Model.ActiveSurveillanceSessionPermissions.Read = false;

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private async Task InitializeModel()
        {
            try
            {
                if (Model == null)
                {
                    authenticatedUser = _tokenService.GetAuthenticatedUser();

                    Model = new ActiveSurveillanceSessionViewModel
                    {
                        SessionInformation = new ActiveSurveillanceSessionInformationModel(),
                        DetailedInformation = new ActiveSurveillanceSessionDetailedInformation(),
                        TestsInformation = new ActiveSurveillanceSessionTestsInformation(),
                        DiseasesSampleTypesUnfiltered = new List<ActiveSurveillanceSessionDiseaseSampleType>(),
                        DiseasesSampleTypes = new List<ActiveSurveillanceSessionDiseaseSampleType>(),
                        ActionsInformation = new ActiveSurveillanceSessionActionsInformation(),
                        DiseaseReports = new ActiveSurveillanceSessionDiseaseReports(),
                        Summary = new ActiveSurveillanceSessionSummaryHeader()
                    };

                    //Pre-populated Content
                    Model.ActionsInformation.EnteredBy = authenticatedUser.LastName + ", " + authenticatedUser.FirstName + " " + authenticatedUser.SecondName;
                    Model.SessionInformation.Site = authenticatedUser.Organization;
                    Model.SessionInformation.SiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                    Model.SessionInformation.Officer = authenticatedUser.LastName + ", " + authenticatedUser.FirstName + " " + authenticatedUser.SecondName;
                    Model.SessionInformation.OfficerID = long.Parse(authenticatedUser.PersonId);
                    Model.SessionInformation.EnteredDate = DateTime.Today;

                    Model.ActiveSurveillanceSessionPermissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);

                    //Pre-load base reference items
                    await GetBaseReferenceItems(null, "Test Status");

                    Model.RecordSelectionIndicator = true;
                    Model.SessionInformation.EIDSSSessionID = Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel);
                    Model.Summary.SessionID = Model.SessionInformation.EIDSSSessionID;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        //protected void HandleSubmit(HumanActiveSurveillanceSessionCreateRequestModel _model)
        //{
        //    try
        //    {

        //    }
        //    catch (Exception ex)
        //    {
        //        Logger.LogError(ex.Message);
        //        throw;
        //    }
        //}

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            //source?.Cancel();
            //source?.Dispose();
            DiagService.OnClose -= DialogClose;
            StateContainer.OnChange -= StateHasChanged;
        }

        protected void DialogClose(dynamic result)
        {
            _source?.Dispose();
            StateContainer.OnChange -= StateHasChanged;
        }
    }

    public static class NavigationManagerExtensions
    {
        public static bool TryGetQueryString<T>(this NavigationManager navManager, string key, out T value)
        {
            var uri = navManager.ToAbsoluteUri(navManager.Uri);

            if (QueryHelpers.ParseQuery(uri.Query).TryGetValue(key, out var valueFromQueryString))
            {
                if (typeof(T) == typeof(long) && long.TryParse(valueFromQueryString, out var valueAsInt))
                {
                    value = (T)(object)valueAsInt;
                    return true;
                }

                if (typeof(T) == typeof(string))
                {
                    value = (T)(object)valueFromQueryString.ToString();
                    return true;
                }

                if (typeof(T) == typeof(decimal) && decimal.TryParse(valueFromQueryString, out var valueAsDecimal))
                {
                    value = (T)(object)valueAsDecimal;
                    return true;
                }
            }

            value = default;
            return false;
        }
    }
}