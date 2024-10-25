using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class ParentComponent : BaseComponent
    {
        [Inject]
        public ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        public IDiseaseClient DiseaseClient { get; set; }

        [Inject]
        public IHumanActiveSurveillanceSessionClient HumanActiveSurveillanceSessionClient { get; set; }

        [Inject]
        protected ActiveSurveillanceSessionStateContainer StateContainer { get; set; }

        [Inject]
        public ITokenService TokenService { get; set; }

        [Inject]
        private ILogger<ParentComponent> Logger { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected int DiseaseCount { get; set; }

        //Human Disease Report (Connected Properties)
        public static long? IdfMonitoringSession { get; set; }

        #region Drop Down Data Sources

        public static IEnumerable<BaseReferenceViewModel> TestCategories;
        public static List<TestNameTestResultsMatrixViewModel> TestResults;
        public static IEnumerable<BaseReferenceViewModel> TestStatuses;
        public static IEnumerable<BaseReferenceViewModel> Actions;
        public static IEnumerable<BaseReferenceViewModel> ActionStatuses;
        public static IEnumerable<BaseReferenceViewModel> Statuses;
        public static IEnumerable<BaseReferenceViewModel> SampleTypes;
        public static IEnumerable<BaseReferenceEditorsViewModel> Diseases;
        public static List<ActiveSurveillanceFilteredDisease> DiseasesFiltered;
        public IEnumerable<BaseReferenceEditorsViewModel> TestDiseases;
        public List<ActiveSurveillanceFilteredSampleType> SampleTypesFiltered;

        #endregion DropDown Data Sources

        protected override async Task OnInitializedAsync()
        {
            authenticatedUser = TokenService.GetAuthenticatedUser();

            _logger = Logger;

            _source = new CancellationTokenSource();
            _token = _source.Token;

            var request = new DiseasesGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "intOrder",
                SortOrder = SortConstants.Ascending,
                AccessoryCode = HACodeList.HumanHACode,
                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
            };

            var diseases = await DiseaseClient.GetDiseasesList(request);
            Diseases = diseases.AsODataEnumerable();
            Diseases = Diseases.Where(x => x.StrSampleType != null);

            DiseasesFiltered = new List<ActiveSurveillanceFilteredDisease>();

            foreach (var disease in Diseases)
            {
                var diseaseFiltered = new ActiveSurveillanceFilteredDisease
                {
                    DiseaseID = disease.KeyId,
                    DiseaseName = disease.StrName
                };

                DiseasesFiltered.Add(diseaseFiltered);
            }

            if (SampleTypes == null)
            {
                var sampleTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Sample Type",
                    HACodeList.HumanHACode);
                SampleTypes = sampleTypes.AsODataEnumerable();
            }
        }

        [ResponseCache(CacheProfileName = "Cache60")]
        public async Task GetBaseReferenceItems(LoadDataArgs args, string referenceTypeName)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), referenceTypeName, HACodeList.HumanHACode);

                switch (referenceTypeName)
                {
                    case BaseReferenceConstants.TestCategory:
                        TestCategories = list.AsODataEnumerable();
                        break;

                    case BaseReferenceConstants.TestResult:
                        //TestResults = list.AsODataEnumerable();
                        break;

                    case BaseReferenceConstants.ASSessionActionType:
                        Actions = list.AsODataEnumerable();
                        break;

                    case BaseReferenceConstants.ASSessionStatus:
                        Statuses = list.AsODataEnumerable();
                        break;

                    case BaseReferenceConstants.ASSessionActionStatus:
                        ActionStatuses = list.AsODataEnumerable();
                        break;

                    case BaseReferenceConstants.TestStatus:
                        TestStatuses = list.AsODataEnumerable();
                        break;
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        //Detailed Information Common functions
        protected async Task GetFilteredDiseases(object value)
        {
            try
            {
                var model = StateContainer.Model;

                if (value != null)
                {
                    model.DetailedInformation.SampleTypeDiseases = new List<ActiveSurveillanceFilteredDisease>();

                    var sampleTypeDiseases = model.DiseasesSampleTypesUnfiltered.Where(x => x.SampleTypeID == long.Parse(value.ToString() ?? string.Empty)).Select(diseaseSampleType =>
                    {
                        if (diseaseSampleType.DiseaseID != null)
                            return new ActiveSurveillanceFilteredDisease
                            {
                                DiseaseName = diseaseSampleType.DiseaseName,
                                DiseaseID = (long) diseaseSampleType.DiseaseID
                            };
                        return null;
                    }).ToList();

                    model.DetailedInformation.SampleTypeDiseases = sampleTypeDiseases.Distinct().ToList();

                    DiseaseCount = model.DetailedInformation.SampleTypeDiseases.Count;
                    model.DetailedInformation.idfsSampleType = long.Parse(value.ToString() ?? string.Empty);
                }
                else
                {
                    model.DetailedInformation.idfsSampleType = null;
                    model.DetailedInformation.SampleTypeDiseases = null;
                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [JSInvokable]
        public async Task Cancel()
        {
            var buttons = new List<DialogButton>();

            var cancelYes = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };

            var cancelNo = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.No
            };

            buttons.Add(cancelYes);
            buttons.Add(cancelNo);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage)
                }
            };

            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                var uri = $"{NavManager.BaseUri}Human/ActiveSurveillanceSession";
                NavManager.NavigateTo(uri, true);
            }
        }

        [JSInvokable]
        public async Task Submit()
        {
            try
            {
                bool permission;
                var model = StateContainer.Model;

                if (model.SessionInformation.MonitoringSessionID > 0)
                {
                    if (model.SessionInformation.SiteID != Convert.ToInt64(authenticatedUser.SiteId) && authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel)
                        permission = model.SessionInformation.WritePermissionIndicator;
                    else
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                        permission = permissions.Write;
                    }
                }
                else
                {
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                        permission = permissions.Create;
                    }
                }

                if (permission)
                {
                    var request = new ActiveSurveillanceSessionSaveRequestModel();
                    var diseaseCombinations = new List<ActiveSurveillanceSessionDisease>();
                    var samples = new List<ActiveSurveillanceSessionSample>();
                    var sampleToDiseases = new List<SampleToDiseaseSaveRequestModel>();
                    var activeSurveillanceSessionActions = new List<ActiveSurveillanceSessionAction>();
                    var tests = new List<ActiveSurveillanceSessionTest>();
                    var monitoringSessionToSampleTypes = new List<ActiveSurveillanceMonitoringSessionToSampleType>();
                    var idfMonitoringSession = model.SessionInformation.MonitoringSessionID;

                    model.PendingSaveEvents ??= new List<EventSaveRequestModel>();

                    foreach (var diseaseSampleType in model.DiseasesSampleTypesUnfiltered)
                    {
                        var diseaseCombination = new ActiveSurveillanceSessionDisease
                        {
                            MonitoringSessionToDiseaseID =
                                diseaseSampleType.ID < 0 ? diseaseSampleType.ID-- : diseaseSampleType.ID,
                            MonitoringSessionID = idfMonitoringSession,
                            DiseaseID = (long) diseaseSampleType.DiseaseID,
                            SampleTypeID = (long) diseaseSampleType.SampleTypeID,
                            RowAction = diseaseSampleType.RowAction
                        };
                        diseaseCombinations.Add(diseaseCombination);
                    }

                    //Enumerate Detailed Information to get a collection of Diseases and their associated sample types
                    if (model.DetailedInformation.UnfilteredList != null)
                    {
                        foreach (var detail in model.DetailedInformation.UnfilteredList)
                        {
                            if (detail.DiseaseIDs == null)
                            {
                                var lDiseaseIDs = new List<long>();

                                foreach (var diseaseSampleType in model.DiseasesSampleTypesUnfiltered.Where(x =>
                                             x.SampleTypeID == detail.idfsSampleType))
                                {
                                    lDiseaseIDs.Add((long) diseaseSampleType.DiseaseID);
                                    detail.DiseaseIDs += diseaseSampleType.DiseaseID.ToString() + ",";
                                }

                                model.DetailedInformation.DiseaseIDs = lDiseaseIDs.ToList();
                                detail.DiseaseIDs = (detail.DiseaseIDs + ".").Replace(",.", "");
                            }

                            if (detail.DiseaseIDs == null) continue;
                            var sample = new ActiveSurveillanceSessionSample
                            {
                                SampleID = detail.ID,
                                CollectedByOrganizationID = authenticatedUser.OfficeId,
                                SiteID = long.Parse(authenticatedUser.SiteId),
                                CollectedByPersonID = long.Parse(authenticatedUser.PersonId),
                                CollectionDate = detail.CollectionDate,
                                SentToOrganizationID = long.Parse(detail.idfSendToOffice.ToString()),
                                Comments = detail.Comment,
                                EIDSSLocalOrFieldSampleID = detail.FieldSampleID
                            };

                            switch (sample.SampleID)
                            {
                                case < 0:
                                    sample.RowAction = UserAction.Insert;
                                    break;

                                case > 0:
                                    if (detail.RowAction == UserAction.Delete)
                                    {
                                        sample.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                    }

                                    break;
                            }

                            sample.HumanMasterID = long.Parse(detail.HumanMasterID.ToString());
                            sample.HumanID = long.Parse(detail.PersonID.ToString());
                            sample.SampleTypeID = long.Parse(detail.idfsSampleType.ToString());
                            samples.Add(sample);

                            if (sample.SampleID == null) continue;
                            foreach (var disease in detail.DiseaseIDs.Split(','))
                            {
                                var sampleToDisease = new SampleToDiseaseSaveRequestModel
                                {
                                    MonitoringSessionToMaterialID = sampleToDiseases.Count + 1 * -1,
                                    MonitoringSessionID = model.SessionInformation.MonitoringSessionID,
                                    SampleID = (long) sample.SampleID,
                                    DiseaseID = Convert.ToInt64(disease),
                                    SampleTypeID = sample.SampleTypeID,
                                    RowAction = (int) RowActionTypeEnum.Insert,
                                    RowStatus = (int) RowStatusTypeEnum.Active
                                };

                                sampleToDiseases.Add(sampleToDisease);
                            }
                        }
                    }

                    model.SessionInformation.UnfilteredMonitoringSessionToSampleTypes ??=
                        model.SessionInformation.MonitoringSessionToSampleTypes;

                    //Enumerate Sample Types to map model for API request
                    if (model.SessionInformation.UnfilteredMonitoringSessionToSampleTypes != null)
                    {
                        foreach (var activeSurveillanceMonitoringSessionToSampleType in model.SessionInformation
                                     .UnfilteredMonitoringSessionToSampleTypes.Select(monitoringSessionToSampleType => new ActiveSurveillanceMonitoringSessionToSampleType
                                     {
                                         MonitoringSessionID = idfMonitoringSession,
                                         MonitoringSessionToSampleTypeID =
                                             monitoringSessionToSampleType.MonitoringSessionToSampleType,
                                         SampleTypeID = monitoringSessionToSampleType.SampleTypeID,
                                         OrderNumber = monitoringSessionToSampleType.OrderNumber,
                                         RowStatus = monitoringSessionToSampleType.RowStatus
                                     }))
                        {
                            activeSurveillanceMonitoringSessionToSampleType.RowAction =
                                activeSurveillanceMonitoringSessionToSampleType.MonitoringSessionToSampleTypeID < 0
                                    ? UserAction.Insert
                                    : string.Empty;

                            monitoringSessionToSampleTypes.Add(activeSurveillanceMonitoringSessionToSampleType);
                        }
                    }

                    //Enumerate Actions to map to model for API request
                    if (model.TestsInformation.UnfilteredList != null)
                    {
                        foreach (var activeSurveillanceSessionTest in model.TestsInformation.UnfilteredList.Select(test => new ActiveSurveillanceSessionTest
                                 {
                                     TestID = test.ID,
                                     MonitoringSessionID = idfMonitoringSession,
                                     TestNameTypeID = long.Parse(test.TestNameID.ToString()),
                                     TestCategoryTypeID = test.TestCategoryID,
                                     TestResultTypeID = long.Parse(test.TestResultID.ToString()),
                                     DiseaseID = long.Parse(test.DiseaseID.ToString()),
                                     ResultDate = test.ResultDate,
                                     RowAction = test.ID < 0 ? UserAction.Insert : string.Empty,
                                     RowStatus = test.intRowStatus,
                                     SampleID = long.Parse(test.SampleID.ToString()),
                                     SampleTypeID = samples.First(x => x.SampleID == test.SampleID).SampleTypeID,
                                     TestStatusTypeID = test.TestStatusID,
                                     ObservationID = null,
                                     OriginalTestResultTypeID = test.OriginalTestResultTypeID
                                 }))
                        {
                            if (activeSurveillanceSessionTest.OriginalTestResultTypeID != activeSurveillanceSessionTest.TestResultTypeID)
                            {
                                SystemEventLogTypes eventTypeId;

                                if (activeSurveillanceSessionTest.OriginalTestResultTypeID is null)
                                {
                                    eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                                  StateContainer.Model.SessionInformation.SiteID
                                        ? SystemEventLogTypes
                                            .NewLaboratoryTestResultForHumanActiveSurveillanceSessionWasRegisteredAtYourSite
                                        : SystemEventLogTypes
                                            .NewLaboratoryTestResultForHumanActiveSurveillanceSessionWasRegisteredAtAnotherSite;
                                    if (StateContainer.Model.SessionInformation.MonitoringSessionID != null)
                                    {
                                        if (StateContainer.Model.SessionInformation.SiteID != null)
                                            model.PendingSaveEvents.Add(await CreateEvent(
                                                (long) StateContainer.Model.SessionInformation.MonitoringSessionID,
                                                activeSurveillanceSessionTest.DiseaseID, eventTypeId,
                                                (long) StateContainer.Model.SessionInformation.SiteID, null));
                                    }
                                    else
                                    {
                                        if (StateContainer.Model.SessionInformation.SiteID != null)
                                            model.PendingSaveEvents.Add(await CreateEvent(0,
                                                activeSurveillanceSessionTest.DiseaseID, eventTypeId,
                                                (long) StateContainer.Model.SessionInformation.SiteID, null));
                                    }
                                }
                                else
                                {
                                    eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                                  StateContainer.Model.SessionInformation.SiteID
                                        ? SystemEventLogTypes
                                            .LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasAmendedAtYourSite
                                        : SystemEventLogTypes
                                            .LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasAmendedAtAnotherSite;
                                    if (StateContainer.Model.SessionInformation.MonitoringSessionID != null)
                                        if (StateContainer.Model.SessionInformation.SiteID != null)
                                            model.PendingSaveEvents.Add(await CreateEvent(
                                                (long) StateContainer.Model.SessionInformation.MonitoringSessionID,
                                                activeSurveillanceSessionTest.DiseaseID, eventTypeId,
                                                (long) StateContainer.Model.SessionInformation.SiteID, null));
                                }
                            }

                            tests.Add(activeSurveillanceSessionTest);
                        }
                    }

                    //Enumerate Tests to map to model for API request
                    if (model.ActionsInformation.UnfilteredList != null)
                    {
                        foreach (var activeSurveillanceSessionAction in model.ActionsInformation.UnfilteredList.Select(action => new ActiveSurveillanceSessionAction
                                 {
                                     MonitoringSessionActionID = action.MonitoringSessionActionID,
                                     ActionDate = action.ActionDate,
                                     ActionStatusTypeID = action.MonitoringSessionActionStatusTypeID,
                                     ActionTypeID = action.MonitoringSessionActionTypeID,
                                     Comments = action.Comments,
                                     EnteredByPersonID = long.Parse(authenticatedUser.PersonId),
                                     RowAction = action.RowAction, 
                                     RowStatus = action.RowStatus
                                 }))
                        {
                            activeSurveillanceSessionAction.RowAction = activeSurveillanceSessionAction.MonitoringSessionActionID < 0
                                ? UserAction.Insert
                                : string.Empty;

                            activeSurveillanceSessionActions.Add(activeSurveillanceSessionAction);
                        }
                    }

                    //Set request for record save/edit.
                    request.LanguageID = GetCurrentLanguage();
                    request.MonitoringSessionID = idfMonitoringSession;
                    request.SessionCategoryTypeID = SessionCategory.Human;
                    request.MonitoringSessionStatusTypeID =
                        model.SessionInformation.MonitoringSessionStatusTypeID; //Session Status
                    request.idfsLocation =
                        Common.GetLocationId(model.SessionInformation.LocationViewModel); //Location Hierarchy
                    request.EnteredByPersonID = long.Parse(authenticatedUser.PersonId);
                    request.CampaignID = model.SessionInformation.CampaignID;
                    request.SiteID = long.Parse(authenticatedUser.SiteId);
                    request.EIDSSSessionID = model.SessionInformation.EIDSSSessionID;
                    request.StartDate = model.SessionInformation.StartDate;
                    request.EndDate = model.SessionInformation.EndDate;
                    request.CreateDiseaseReportHumanID = null;
                    request.AuditUserName = authenticatedUser.UserName;
                    request.DiseaseCombinations = JsonConvert.SerializeObject(diseaseCombinations);
                    request.SampleTypeCombinations = JsonConvert.SerializeObject(monitoringSessionToSampleTypes);
                    request.Samples = JsonConvert.SerializeObject(samples);
                    request.SamplesToDiseases = JsonConvert.SerializeObject(sampleToDiseases);
                    request.Tests = JsonConvert.SerializeObject(tests);
                    request.Actions = JsonConvert.SerializeObject(activeSurveillanceSessionActions);
                    request.UserId = long.Parse(authenticatedUser.EIDSSUserId);

                    model.PendingSaveEvents ??= new List<EventSaveRequestModel>();

                    if (model.SessionInformation.MonitoringSessionStatusTypeID_Original ==
                        ActiveSurveillanceSessionStatusIds.Closed &&
                        model.SessionInformation.MonitoringSessionStatusTypeID ==
                        ActiveSurveillanceSessionStatusIds.Open)
                    {
                        model.PendingSaveEvents.Add(await CreateEvent((long) idfMonitoringSession, null,
                            SystemEventLogTypes.ClosedHumanActiveSurveillanceSessionWasReopenedAtYourSite,
                            (long) model.SessionInformation.SiteID, null).ConfigureAwait(false));
                    }

                    if (request.MonitoringSessionID == null)
                    {
                        model.PendingSaveEvents.Add(await CreateEvent(0, null,
                            SystemEventLogTypes.NewHumanActiveSurveillanceSessionWasCreatedAtYourSite,
                            (long) model.SessionInformation.SiteID, null).ConfigureAwait(false));
                    }

                    var iEventId = -1;

                    foreach (var siteEvent in model.PendingSaveEvents)
                    {
                        siteEvent.EventId = iEventId--;
                    }

                    request.Events = JsonConvert.SerializeObject(model.PendingSaveEvents);

                    var response =
                        await HumanActiveSurveillanceSessionClient.SetActiveSurveillanceSession(request, _token);

                    if (response != null)
                    {
                        var buttons = new List<DialogButton>();

                        var returnToDashboard = new DialogButton
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton),
                            ButtonType = DialogButtonType.Yes
                        };

                        var returnToActiveSurveillanceSession = new DialogButton
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants
                                .HumanActiveSurveillanceSessionReturnToActiveSurveillanceSessionButtonText),
                            ButtonType = DialogButtonType.OK
                        };

                        buttons.Add(returnToDashboard);
                        buttons.Add(returnToActiveSurveillanceSession);
                        string strMessage =
                            Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                        strMessage += " " + Localizer.GetString(MessageResourceKeyConstants.MessagesRecordIDisMessage);
                        strMessage += " " + response.FirstOrDefault().EIDSSSessionID + ".";

                        var dialogParams = new Dictionary<string, object>
                        {
                            {nameof(EIDSSDialog.DialogButtons), buttons},
                            {nameof(EIDSSDialog.LocalizedMessage), strMessage}
                        };
                        var result = await DiagService.OpenAsync<EIDSSDialog>(
                            Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                        if (result.ButtonResultText ==
                            Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                        {
                            var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                            NavManager.NavigateTo(uri, true);
                        }
                        else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants
                                     .HumanActiveSurveillanceSessionReturnToActiveSurveillanceSessionButtonText))
                        {
                            var uri =
                                $"{NavManager.BaseUri}Human/ActiveSurveillanceSession/Create?id={response.FirstOrDefault().MonitoringSessionID}&isReview=true";
                            NavManager.NavigateTo(uri, true);
                        }
                    }
                }
                else
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
                        {
                            nameof(EIDSSDialog.Message),
                            Localizer.GetString(MessageResourceKeyConstants
                                .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage)
                        }
                    };
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteSurveillanceSession(long monitoringSessionID)
        {
            try
            {
                bool permission;

                if (StateContainer.Model.SessionInformation.SiteID != Convert.ToInt64(authenticatedUser.SiteId) && authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel)
                    permission = StateContainer.Model.SessionInformation.WritePermissionIndicator;
                else
                {
                    var permissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                    permission = permissions.Write;
                }

                if (permission)
                {
                    var response =
                        await HumanActiveSurveillanceSessionClient.DeleteHumanActiveSurveillanceSession(
                            monitoringSessionID, _token);

                    switch (response.ReturnCode)
                    {
                        case 0:
                            await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                                null);

                            NavManager.NavigateTo($"{NavManager.BaseUri}Human/ActiveSurveillanceSession", true);
                            break;
                        case 1:
                            await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                                null);
                            break;
                    }

                    return response;
                }

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
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants
                            .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage)
                    }
                };
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return null;
        }

        public async Task<DialogReturnResult> ShowDeleteConfirmation()
        {
            var buttons = new List<DialogButton>();

            var yes = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };

            var no = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.No
            };

            buttons.Add(yes);
            buttons.Add(no);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                }
            };
            DialogReturnResult result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

            return result;
        }

        #region Modal Reset Routines

        public async Task ClearDetailedInformation()
        {
            var model = StateContainer.Model;

            model.DetailedInformation.SentToOrganization = null;
            model.DetailedInformation.PersonID = -1;
            model.DetailedInformation.EIDSSPersonID = string.Empty;
            model.DetailedInformation.PersonAddress = string.Empty;
            model.DetailedInformation.Comments = string.Empty;
            model.DetailedInformation.idfsSampleType = null;
            model.DetailedInformation.CollectionDate = null;
            model.DetailedInformation.FieldSampleID = string.Empty;

            var lClearList = new List<long>();

            model.DetailedInformation.DiseaseIDs = lClearList.ToList();

            StateContainer.SetActiveSurveillanceSessionViewModel(model);
            await InvokeAsync(StateHasChanged);
        }

        public async Task ClearTestModal(bool bClearAll)
        {
            var model = StateContainer.Model;

            if (bClearAll)
            {
                model.TestsInformation.FieldSampleID = string.Empty;
                model.TestsInformation.TestStatus = TestStatuses.First(x => x.IdfsBaseReference == EIDSSConstants.TestStatuses.Final).Name;
                model.TestsInformation.TestStatusID = EIDSSConstants.TestStatuses.Final;
                model.TestsInformation.LabSampleID = string.Empty;
                model.TestsInformation.TestDiseaseID = -1;
                model.TestsInformation.TestCategoryID = null;
                model.TestsInformation.ResultDate = null;
                model.TestsInformation.TestResultID = null;
                model.TestsInformation.Diseases = new List<ActiveSurveillanceFilteredDisease>();
                model.TestsInformation.TestNames = new List<ActiveSurveillanceSessionTestNamesResponseModel>();
                model.TestsInformation.TestResults = new List<TestNameTestResultsMatrixViewModel>();
            }

            model.TestsInformation.SampleType = string.Empty;
            model.TestsInformation.PersonID = -1;
            model.TestsInformation.EIDSSPersonID = string.Empty;

            StateContainer.SetActiveSurveillanceSessionViewModel(model);
            await InvokeAsync(StateHasChanged);
        }

        public async Task ClearActionModal()
        {
            var model = StateContainer.Model;

            model.ActionsInformation.ActionRequiredID = null;
            model.ActionsInformation.Comment = string.Empty;
            model.ActionsInformation.DateOfAction = null;
            model.ActionsInformation.EnteredBy = string.Empty;
            model.ActionsInformation.StatusID = -1;

            StateContainer.SetActiveSurveillanceSessionViewModel(model);
            await InvokeAsync(StateHasChanged);
        }

        [JSInvokable("OnDelete")]
        public async Task OnDelete()
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

                        if (StateContainer.Model.SessionInformation.MonitoringSessionID != null)
                            await DeleteSurveillanceSession((long) StateContainer.Model.SessionInformation
                                .MonitoringSessionID);
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [JSInvokable("OnPrint")]
        public async Task OnPrint()
        {
            // TODO MVB fix count
            try
            {
                if (StateContainer.Model.SessionInformation.MonitoringSessionID != null)
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("PersonID",
                        authenticatedUser.PersonId); // For Organization // model.SearchCriteria.EIDSSPersonID);
                    reportModel.AddParameter("idfCase",
                        StateContainer.Model.SessionInformation.MonitoringSessionID.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.HumanActiveSurveillanceSessionPageHeading),
                        new Dictionary<string, object>
                        {
                            {"ReportName", "HumanActiveSurveillanceSessionListOfSamples"},
                            {"Parameters", reportModel.Parameters}
                        },
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px"
                        });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Modal Reset Routines
    }
}