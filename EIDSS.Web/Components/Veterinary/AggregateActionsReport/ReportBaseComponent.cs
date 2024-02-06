#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.AggregateActionsReport
{
    public class ReportBaseComponent : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] protected VeterinaryAggregateActionsReportStateContainer StateContainer { get; set; }
        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] protected IOrganizationClient OrganizationClient { get; set; }
        [Inject] protected IAggregateReportClient AggregateReportClient { get; set; }
        [Inject] protected IAggregateSettingsClient AggregateSettingsClient { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            // free unmanaged resources (unmanaged objects) and override finalizer
            // set large fields to null
            StateContainer = null;

            _disposedValue = true;
        }

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #region Save Aggregate Actions Report Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task<AggregateReportSaveResponseModel> SaveAggregateActionsReport()
        {
            try
            {
                bool permission;

                Events = new List<EventSaveRequestModel>();

                long? siteId = StateContainer.SiteID ?? Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                if (StateContainer.ReportKey > 0)
                {
                    if (StateContainer.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                        authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                        permission = StateContainer.WritePermissionIndicator;
                    else
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);
                        permission = permissions.Write;
                    }
                }
                else
                {
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);
                        permission = permissions.Create;
                    }
                }

                if (permission)
                {
                    if (StateContainer.ReportInformationValidIndicator
                        && StateContainer.DiagnosticSectionValidIndicator
                        && StateContainer.TreatmentSectionValidIndicator
                        && StateContainer.SanitarySectionValidIndicator)
                    {
                        foreach (var notification in StateContainer.PendingSaveEvents)
                            Events.Add(notification);

                        // set the administrative unit based on the location selected
                        StateContainer.SetAdministrativeLevels(StateContainer.AreaTypeID.GetValueOrDefault());

                        // set the starting and ending date of the report
                        await StateContainer.SetStartAndEndDates();

                        var request = new AggregateReportSaveRequestModel
                        {
                            AggregateReportID = StateContainer.ReportKey,
                            EIDSSAggregateReportID = StateContainer.ReportID,
                            AggregateReportTypeID = Convert.ToInt64(AggregateValue.VeterinaryAction),
                            ReceivedByOrganizationID = StateContainer.NotificationReceivedInstitutionID,
                            ReceivedByPersonID = StateContainer.NotificationReceivedOfficerID,
                            ReceivedByDate = StateContainer.NotificationReceivedDate,
                            SentByOrganizationID = StateContainer.NotificationSentInstitutionID,
                            SentByPersonID = StateContainer.NotificationSentOfficerID,
                            SentByDate = StateContainer.NotificationSentDate,
                            EnteredByOrganizationID = StateContainer.NotificationEnteredInstitutionID,
                            EnteredByPersonID = StateContainer.NotificationEnteredOfficerID,
                            EnteredByDate = StateContainer.NotificationEnteredDate,
                            StartDate = StateContainer.StartDate,
                            FinishDate = StateContainer.EndDate,
                            SiteID = siteId,
                            GeographicalAdministrativeUnitID = StateContainer.AdministrativeUnitID,
                            OrganizationalAdministrativeUnitID = StateContainer.OrganizationID,
                            DiagnosticVersion = StateContainer.DiagnosticMatrixVersionID,
                            DiagnosticObservationID = StateContainer.DiagnosticObservationID,
                            DiagnosticObservationFormTemplateID =
                                StateContainer.DiagnosticFlexFormRequest.idfsFormTemplate,
                            ProphylacticObservationID = StateContainer.TreatmentObservationID,
                            ProphylacticObservationFormTemplateID =
                                StateContainer.TreatmentFlexFormRequest.idfsFormTemplate,
                            ProphylacticVersion = StateContainer.TreatmentMatrixVersionID,
                            SanitaryObservationID = StateContainer.SanitaryObservationID,
                            SanitaryObservationFormTemplateID = StateContainer.SanitaryFlexFormRequest.idfsFormTemplate,
                            SanitaryVersion = StateContainer.SanitaryMatrixVersionID,
                            User = authenticatedUser.UserName,
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            Events = JsonConvert.SerializeObject(Events)
                        };

                        var response = await AggregateReportClient.SaveAggregateReport(request, _token);

                        return response;
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

            return new AggregateReportSaveResponseModel();
        }

        #endregion

        #region Delete Aggregate Actions Report

        /// <summary>
        /// </summary>
        /// <param name="reportKey"></param>
        /// <param name="user"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteAggregateActionsReport(long reportKey, string user)
        {
            try
            {
                bool permission;
                if (StateContainer.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                    authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                    permission = StateContainer.DeletePermissionIndicator;
                else
                {
                    var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);
                    permission = permissions.Delete;
                }

                if (permission)
                {
                    var response = await AggregateReportClient.DeleteAggregateReport(reportKey, user);

                    if (response.ReturnCode == 0)
                        await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                            null);
                    else
                        await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                            null);

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

        #endregion

        #endregion
    }
}