#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Veterinary.AggregateActionsReport
{
    public class ReportBase : ReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ILogger<ReportBase> Logger { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public long? ReportKey { get; set; }

        [Parameter]
        public bool IsReadOnly { get; set; }

        #endregion Parameters

        #region Member Variables

        protected bool IsProcessing;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        public ReportInformationSection InformationSection;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await StateContainer.InitializeModel();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await InvokeAsync(StateHasChanged);

                // get the record
                if (ReportKey != null)
                {
                    StateContainer.ReportKey = ReportKey.Value;
                    StateContainer.IsReadOnly = IsReadOnly;
                    await StateContainer.GetAggregateActionsReportDetails().ConfigureAwait(false);

                    //if (StateContainer.ReadPermissionIndicator)
                    //{
                        // pre-load organizations to one list
                        await StateContainer.LoadOrganizations();
                    //}
                }
                else
                {
                    // pre-load organizations to one list
                    await StateContainer.LoadOrganizations();

                    await StateContainer.SetNewRecordDefaults().ConfigureAwait(false);
                }

                await InvokeAsync(StateHasChanged);

                if (InformationSection != null)
                    await InformationSection.ComponentRefresh(StateContainer.ReportLocationViewModel);

                if (StateContainer.ReadPermissionIndicator)
                {
                    var lDotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("VetAggregateActionsReport.SetDotNetReference", _token,
                        lDotNetReference);

                    var enableSaveButton = ReportKey is null
                        ? StateContainer.VeterinaryAggregateActionsReportPermissions.Create
                        : StateContainer.VeterinaryAggregateActionsReportPermissions.Write;

                    await JsRuntime.InvokeAsync<string>("initializeSidebar", _token,
                        Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(),
                        StateContainer.VeterinaryAggregateActionsReportPermissions.Delete,
                        enableSaveButton,
                        Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                            .ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                    if (StateContainer.IsReadOnly)
                    {
                        await JsRuntime.InvokeVoidAsync("navigateToReviewStep", _token);
                    }
                }
                else
                    await JsRuntime.InvokeAsync<string>("insufficientPermissions", _token);
            }
        }

        /// <summary>
        /// </summary>
        public new void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion Methods

        #region Submit Click Event

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
                if (StateContainer.ReportKey <= 0)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == StateContainer.SiteID
                        ? SystemEventLogTypes.NewVeterinaryAggregateActionWasCreatedAtYourSite
                        : SystemEventLogTypes.NewVeterinaryAggregateActionWasCreatedAtAnotherSite;
                    StateContainer.PendingSaveEvents.Add(await CreateEvent(StateContainer.ReportKey,
                            null, eventTypeId, Convert.ToInt64(StateContainer.SiteID), null)
                        .ConfigureAwait(false));
                }
                else
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == StateContainer.SiteID
                        ? SystemEventLogTypes.VeterinaryAggregateActionWasChangedAtYourSite
                        : SystemEventLogTypes.VeterinaryAggregateActionWasChangedAtAnotherSite;
                    StateContainer.PendingSaveEvents.Add(await CreateEvent(StateContainer.ReportKey,
                            null, eventTypeId, Convert.ToInt64(StateContainer.SiteID), null)
                        .ConfigureAwait(false));
                }

                var response = await SaveAggregateActionsReport();

                if (response.ReturnCode == 0)
                {
                    dynamic result;

                    if (StateContainer.ReportKey == 0)
                    {
                        var message = string.Format(
                            Localizer.GetString(MessageResourceKeyConstants
                                .VeterinaryAggregateActionsReportSuccessfullySavedTheEIDSSIDIsMessage),
                            response.EIDSSAggregateReportID);

                        result = await ShowSuccessDialog(null, message, null,
                            ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.VeterinaryAggregateActionsReportReturntoAggregateActionsReportButtonText);
                    }
                    else
                    {
                        result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                            null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.VeterinaryAggregateActionsReportReturntoAggregateActionsReportButtonText);
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

                            const string path = "Veterinary/AggregateActionsReport/Details";
                            var query = $"?id={response.AggregateReportID}&isReadOnly=true";
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
                IsProcessing = false;
            }
        }

        #endregion Submit Click Event

        #region Print Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnPrint")]
        public async Task OnPrint()
        {
            try
            {
                {
                    _source = new CancellationTokenSource();
                    _token = _source.Token;

                    ReportViewModel reportModel = new();

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("SiteID", authenticatedUser.SiteId);

                    reportModel.AddParameter("idfsAggrCaseType",
                        EIDSSConstants.AggregateValue.VeterinaryAction);
                    reportModel.AddParameter("idfAggrCaseList",
                        StateContainer.ReportKey.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants
                            .VeterinaryAggregateActionReportPageHeading),
                        new Dictionary<string, object>
                        {
                            {"ReportName", "VeterinaryAggregateActionReport"}, {"Parameters", reportModel.Parameters}
                        },
                        new DialogOptions
                        {
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

        #endregion

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

                        var uri = $"{NavManager.BaseUri}Veterinary/AggregateActionsReport";

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
                    await DiagService.OpenAsync<EIDSSDialog>(string.Empty, dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        var response = await DeleteAggregateActionsReport(StateContainer.ReportKey, authenticatedUser.UserName);
                        if (response is { ReturnCode: 0 })
                        {
                            DiagService.Close();

                            _source?.Cancel();

                            const string path = "Veterinary/AggregateActionsReport?refreshResultsIndicator=true";
                            var uri = $"{NavManager.BaseUri}{path}";

                            NavManager.NavigateTo(uri, true);
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
    }
}