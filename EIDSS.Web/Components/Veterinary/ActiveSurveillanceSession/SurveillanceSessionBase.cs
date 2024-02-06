#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.CrossCutting;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class SurveillanceSessionBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ILogger<SurveillanceSessionBase> Logger { get; set; }

        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public long? SessionID { get; set; }

        [Parameter]
        public bool IsReadOnly { get; set; }

        [Parameter]
        public long? CampaignKey { get; set; }

        #endregion Parameters

        #region Member Variables

        protected bool IsProcessing;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            InitializeModel();

            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            // SessionID parameter is passed in on edit,
            //  otherwise it is null for add
            if (SessionID != null)
            {
                StateContainer.SessionKey = SessionID.Value;
            }

            if (StateContainer.SessionKey is not null && StateContainer.SessionKey > 0)
            {
                var request = new VeterinaryActiveSurveillanceSessionDetailRequestModel
                {
                    MonitoringSessionID = StateContainer.SessionKey.Value,
                    SortColumn = "EIDSSSessionID",
                    SortOrder = EIDSSConstants.SortConstants.Descending,
                    Page = 1,
                    PageSize = 10,
                    LanguageId = GetCurrentLanguage(),
                    ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                    UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                    UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId)
                };
                var results = await VeterinaryClient.GetActiveSurveillanceSessionDetailAsync(request, _token);

                var surveillanceSession = results.FirstOrDefault();
                if (surveillanceSession != null)
                {
                    StateContainer.SessionKey = surveillanceSession.VeterinaryMonitoringSessionID;
                    StateContainer.SessionID = surveillanceSession.EIDSSSessionID;
                    StateContainer.SessionStartDate = surveillanceSession.StartDate;
                    StateContainer.SessionEndDate = surveillanceSession.EndDate;
                    StateContainer.SessionStatusTypeID = surveillanceSession.SessionStatusTypeID;
                    StateContainer.OriginalSessionStatusTypeID = surveillanceSession.SessionStatusTypeID;
                    StateContainer.SessionStatusTypeName = surveillanceSession.SessionStatusTypeName;
                    StateContainer.ReportTypeID = surveillanceSession.ReportTypeID;
                    StateContainer.DiseaseString = surveillanceSession.DiseaseNames;
                    StateContainer.SiteName = surveillanceSession.SiteName;
                    StateContainer.LegacySessionID = surveillanceSession.LegacyID;
                    StateContainer.LocationModel.AdminLevel0Value = surveillanceSession.CountryID;
                    StateContainer.LocationModel.AdminLevel1Value = surveillanceSession.RegionID;
                    StateContainer.LocationModel.AdminLevel2Value = surveillanceSession.RayonID;
                    StateContainer.LocationModel.AdminLevel3Value = surveillanceSession.SettlementID;
                    StateContainer.LocationModel.AdministrativeLevelId = surveillanceSession.LocationID;
                    StateContainer.CampaignKey = surveillanceSession.CampaignKey;
                    StateContainer.CampaignID = surveillanceSession.CampaignID;
                    StateContainer.CampaignName = surveillanceSession.CampaignName;
                    StateContainer.CampaignType = surveillanceSession.CampaignTypeName;
                    StateContainer.HasLinkedCampaign = surveillanceSession.CampaignKey.HasValue;
                    StateContainer.DateEntered = surveillanceSession.EnteredDate;
                    StateContainer.OfficerID = surveillanceSession.EnteredByPersonID;
                    StateContainer.OfficerName = surveillanceSession.EnteredByPersonName;
                    StateContainer.HACode = StateContainer.ReportTypeID == EIDSSConstants.ASSpeciesType.Avian
                        ? EIDSSConstants.HACodeList.AvianHACode
                        : EIDSSConstants.HACodeList.LivestockHACode;
                }
                else
                {
                    StateContainer.ActiveSurveillanceSessionPermissions.Read = false;
                }
            }

            // if CampaignKey parameter has a value so we are adding
            // a surveillance session from the campaign
            if (CampaignKey != null)
            {
                StateContainer.CampaignKey = CampaignKey.Value;
                var request = new ActiveSurveillanceCampaignDetailRequestModel()
                {
                    CampaignID = StateContainer.CampaignKey.Value,
                    LanguageId = GetCurrentLanguage()
                };
                await GetCampaignDetail(request);
                if (CampaignKey != null) await AddDiseaseSpeciesSamplesFromCampaign(CampaignKey.Value);
            }

            if (StateContainer.SessionKey is > 0)
            {
                StateContainer.ReportTypeDisabled = true;
            }

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (StateContainer.ActiveSurveillanceSessionPermissions.Read)
                {
                    var lDotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("VeterinaryActiveSurveillanceSession.SetDotNetReference", _token,
                        lDotNetReference);

                    await JsRuntime.InvokeAsync<string>("initializeVetSurveillanceSidebar", _token,
                        Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(),
                        StateContainer.ActiveSurveillanceSessionPermissions.Delete,
                        Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                            .ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString(),
                        StateContainer.ActiveSurveillanceSessionPermissions.Delete
                    );

                    if (IsReadOnly)
                    {
                        StateContainer.IsReadOnly = IsReadOnly;
                        await JsRuntime.InvokeVoidAsync("navigateToVeterinarySurveillanceSessionReviewStep", _token, 6);
                    }
                }
                else
                    await JsRuntime.InvokeAsync<string>("insufficientPermissions", _token);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public new void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        private void InitializeModel()
        {
            StateContainer.ActiveSurveillanceSessionPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);
            StateContainer.VeterinaryDiseaseResultPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
            StateContainer.CanInterpretVeterinaryPermissions = _tokenService.GerUserPermissions(PagePermission.CanInterpretVetDiseaseReportSessionTestResult);
            StateContainer.CanManageReferenceTablesPermissions =
                _tokenService.GerUserPermissions(PagePermission.CanManageReferenceDataTables);

            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            //initialize the location control
            StateContainer.LocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,

                ShowAdminLevel0 = true,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = bottomAdmin >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                AdministrativeLevelEnabled = true,
                EnableAdminLevel0 = true,
                EnableAdminLevel1 = true,
                EnableAdminLevel2 = true,
                EnableAdminLevel3 = bottomAdmin >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                EnableAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                EnableAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                EnableAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowSettlement = true,
                ShowSettlementType = true,
                ShowStreet = false,
                ShowBuilding = false,
                ShowApartment = false,
                ShowElevation = false,
                ShowHouse = false,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = false,
                ShowPostalCode = false,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel0 = true,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
            };
        }

        #endregion Methods

        #region Hide and Show Session Header

        [JSInvokable("ShowSurveillanceSessionHeader")]
        public void ShowSurveillanceSessionHeader()
        {
            StateContainer.ShowSessionHeaderIndicator = true;
        }

        [JSInvokable("HideSurveillanceSessionHeader")]
        public void HideSurveillanceSessionHeader()
        {
            StateContainer.ShowSessionHeaderIndicator = false;
        }

        #endregion Hide and Show Session Header

        #region Save Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnSubmit")]
        public async Task OnSubmit()
        {
            try
            {
                IsProcessing = true;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                StateContainer.PendingSaveEvents ??= new List<EventSaveRequestModel>();
                if (StateContainer.SessionKey <= 0)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Convert.ToInt64(StateContainer.SiteID)
                        ? SystemEventLogTypes.NewVeterinaryActiveSurveillanceSessionWasCreatedAtYourSite
                        : SystemEventLogTypes.NewVeterinaryActiveSurveillanceSessionWasCreatedAtAnotherSite;
                    long? diseaseId = null;
                    if (StateContainer.DiseaseSpeciesSamples is { Count: > 0 })
                    {
                        diseaseId = StateContainer.DiseaseSpeciesSamples.First().DiseaseID;
                    }
                    StateContainer.PendingSaveEvents.Add(await CreateEvent(StateContainer.SessionKey.GetValueOrDefault(),
                            diseaseId, eventTypeId, Convert.ToInt64(StateContainer.SiteID), null)
                        .ConfigureAwait(false));
                }

                var response = await SaveSurveillanceSession();

                if (response.ReturnCode == 0)
                {
                    dynamic result;

                    if (StateContainer.SessionKey == 0)
                    {
                        var message = string.Format(Localizer.GetString(MessageResourceKeyConstants.VeterinarySessionYouSuccessfullyCreatedANewVeterinarySurveillancSessionInTheEIDSSSystemTheEIDSSIDIsMessage), response.SessionID);
                        result = await ShowSuccessDialog(null, message, null,
                            ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.VeterinarySessionReturnToActiveSurveillanceSessionText);
                    }
                    else
                    {
                        result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                            null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.VeterinarySessionReturnToActiveSurveillanceSessionText);
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
                        else
                        {
                            DiagService.Close();

                            const string path = "Veterinary/ActiveSurveillanceSession/Details";
                            var query = $"?sessionID={response.SessionKey}";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeVoidAsync("clearProcessingStatus", _token);
                IsProcessing = false;
            }
        }

        #endregion Save Click Event

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnCancel")]
        public async Task OnCancel()
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
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        _source?.Cancel();

                        var uri = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceSession";

                        NavManager.NavigateTo(uri, true);
                    }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Cancel Click Event

        #region Delete Click Event

        /// <summary>
        /// </summary>
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
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        if (StateContainer.SessionKey != null)
                        {
                            var response = await DeleteSurveillanceSession(StateContainer.SessionKey.Value,
                                StateContainer.ReportTypeID);
                            if (response.ReturnCode == 0)
                            {
                                await BrowserStorage.DeleteAsync(EIDSSConstants.SearchPersistenceKeys
                                    .VeterinaryActiveSurveillanceSessionSearchModelKey);
                                string uri = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceSession/Index";

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

        #endregion Delete Click Event

        #region Print Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnPrint")]
        public async Task OnPrint()
        {
            try
            {
                _source = new CancellationTokenSource();
                _token = _source.Token;

                var fullName =
                    $"{authenticatedUser.FirstName} {authenticatedUser.SecondName} {authenticatedUser.LastName}";

                ReportViewModel reportModel = new();

                // required parameters
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("PersonID", authenticatedUser.PersonId);

                // specific parameters
                reportModel.AddParameter("Country", StateContainer.LocationModel.AdminLevel0Value != null ? StateContainer.LocationModel.AdminLevel0Value.ToString() : string.Empty);
                reportModel.AddParameter("Year", StateContainer.SessionStartDate != null ? StateContainer.SessionStartDate.Value.Year.ToString() : string.Empty);
                reportModel.AddParameter("UserOrganization", authenticatedUser.OfficeId.ToString());
                reportModel.AddParameter("UserFullName", fullName);

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.VeterinaryActiveSurveillanceSessionPageHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "VeterinaryActiveSurveillanceReport"}, {"Parameters", reportModel.Parameters}},
                    new DialogOptions
                    {
                        Style = EIDSSConstants.ActiveSurveillanceSessionConstants.Summaries,
                        Left = "150",
                        Resizable = true,
                        Draggable = false,
                        Width = "1150px"
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Print Click Event
    }
}