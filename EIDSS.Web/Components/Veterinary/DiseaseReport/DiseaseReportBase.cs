#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
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
using EIDSS.ClientLibrary.Services;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class DiseaseReportBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DiseaseReportBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] INotificationSiteAlertService NotificationSiteAlertService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public CaseGetDetailViewModel Case { get; set; }

        #endregion

        #region Properties

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public DiseaseReportBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected DiseaseReportBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            _disposedValue = true;
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }


        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    if (Model.ReportStatusTypeID == (long)DiseaseReportStatusTypeEnum.Closed || (Model.OutbreakID != null && !Model.OutbreakCaseIndicator)) // && Model.ReportCurrentlyClosedIndicator)
                        Model.ReportDisabledIndicator = true;
                    else if (Model.WritePermissionIndicator == false && Model.DiseaseReportID > 0 || Model.CreatePermissionIndicator == false && Model.DiseaseReportID <= 0)
                        Model.ReportDisabledIndicator = true;

                    await InvokeAsync(StateHasChanged);

                    await JsRuntime.InvokeVoidAsync("VeterinaryDiseaseReport.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Submit Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnSubmit")]
        public async Task OnSubmit()
        {
            try
            {
                var newReportIndicator = false;

                if (Model.OutbreakCaseIndicator)
                {
                    Model.DiseaseReportSummaryValidIndicator = true;
                    Model.FarmDetailsSectionValidIndicator = true;
                    Model.NotificationSectionValidIndicator = Case.NotificationSectionValidIndicator;
                    Model.OutbreakID = Case.Session.idfOutbreak;
                    Model.EIDSSOutbreakID = Case.Session.strOutbreakID;
                    Model.InvestigatedByOrganizationID = Case.InvestigatedByOrganizationId;
                    Model.InvestigatedByPersonID = Case.InvestigatedByPersonId;
                    Model.InvestigationDate = Case.InvestigationDate;
                    Model.ClassificationTypeID = Case.ClassificationTypeId;

                    if (Model.DiseaseReportID == 0) newReportIndicator = true;
                }
                else
                {
                    if (Model.DiseaseReportID == 0)
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.SiteID
                            ? SystemEventLogTypes.NewVeterinaryDiseaseReportWasCreatedAtYourSite
                            : SystemEventLogTypes.NewVeterinaryDiseaseReportWasCreatedAtAnotherSite;
                        Model.PendingSaveEvents.Add(await NotificationSiteAlertService.CreateEvent(Model.DiseaseReportID,
                                Model.DiseaseID, eventTypeId, Model.SiteID, null) //, NotificationSiteAlertService.BuildVeterinaryDiseaseReportLink(Model.ReportCategoryTypeID, Model.FarmMasterID, Model.DiseaseReportID))
                            .ConfigureAwait(false));

                        newReportIndicator = true;
                    }
                }

                //Add deleted farm inventory records back to the main list for saving.
                if (Model.PendingDeleteFarmInventory is not null && Model.PendingDeleteFarmInventory.Count > 0)
                    foreach (var farmInventoryItem in Model.PendingDeleteFarmInventory)
                        Model.FarmInventory.Add(farmInventoryItem);

                var response =
                    await SaveDiseaseReport(Model, Model.OutbreakCaseIndicator ? Case : null, false, null, null);

                if (response.ReturnCode == 0)
                {
                    dynamic result;

                    if (Model.DiseaseReportID == 0) Model.EIDSSReportID = response.EIDSSReportID;

                    if (Model.OutbreakCaseIndicator)
                        Case.CaseId = response.CaseID;

                    if (response.DiseaseReportID != null) Model.DiseaseReportID = (long) response.DiseaseReportID;

                    if (newReportIndicator)
                    {
                        string message;

                        if (Model.OutbreakCaseIndicator)
                        {
                            message = string.Format(Localizer.GetString(MessageResourceKeyConstants
                                    .CreateVeterinaryCaseVeterinaryCaseHasBeenSavedSuccessfullyNewCaseIDMessage) + ".",
                                response.EIDSSCaseID);

                            result = await ShowSuccessDialog(null, message, null,
                                ButtonResourceKeyConstants.OutbreakCasesReturnToOutbreakSessionButtonText,
                                ButtonResourceKeyConstants.OutbreakCasesReturnToOutbreakCaseReportButtonText);
                        }
                        else
                        {
                            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                                message = string.Format(Localizer.GetString(MessageResourceKeyConstants
                                                            .AvianDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage) +
                                                        ".",
                                    response.EIDSSReportID);
                            else
                                message = string.Format(Localizer.GetString(MessageResourceKeyConstants
                                                            .LivestockDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage) +
                                                        ".",
                                    response.EIDSSReportID);

                            result = await ShowSuccessDialog(null, message, null,
                                ButtonResourceKeyConstants.ReturnToDashboardButton,
                                Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                    ? ButtonResourceKeyConstants.AvianDiseaseReportReturnToDiseaseReportButtonText
                                    : ButtonResourceKeyConstants.LivestockDiseaseReportReturnToDiseaseReportButtonText);
                        }
                    }
                    else
                    {
                        if (Model.OutbreakCaseIndicator)
                            result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                                null, null, ButtonResourceKeyConstants.OutbreakCasesReturnToOutbreakSessionButtonText,
                                ButtonResourceKeyConstants.OutbreakCasesReturnToOutbreakCaseReportButtonText);
                        else
                            result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                                null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                                Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                    ? ButtonResourceKeyConstants.AvianDiseaseReportReturnToDiseaseReportButtonText
                                    : ButtonResourceKeyConstants.LivestockDiseaseReportReturnToDiseaseReportButtonText);
                    }

                    if (result is DialogReturnResult returnResult)
                    {
                        if (Model.OutbreakCaseIndicator)
                        {
                            if (returnResult.ButtonResultText ==
                                Localizer.GetString(ButtonResourceKeyConstants
                                    .OutbreakCasesReturnToOutbreakSessionButtonText))
                            {
                                DiagService.Close();

                                _source?.Cancel();

                                var uri = $"{NavManager.BaseUri}Outbreak/OutbreakCases/Index?queryData=" +
                                          Model.OutbreakID;

                                NavManager.NavigateTo(uri, true);
                            }
                            else
                            {
                                DiagService.Close();

                                const string path = "Outbreak/OutbreakCases/VeterinaryDetails";
                                var query = $"?outbreakId={Model.OutbreakID}&caseId={Case.CaseId}&isReview=true";
                                var uri = $"{NavManager.BaseUri}{path}{query}";

                                NavManager.NavigateTo(uri, true);
                            }
                        }
                        else
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

                                const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                                var query =
                                    $"?reportTypeID={Model.ReportTypeID}&diseaseReportID={Model.DiseaseReportID}&isEdit=true&isReview=true";
                                var uri = $"{NavManager.BaseUri}{path}{query}";

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
                    {nameof(EIDSSDialog.DialogButtons), buttons},
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

                        string uri;
                        if (Model.OutbreakCaseIndicator)
                            uri = $"{NavManager.BaseUri}Outbreak/OutbreakCases/Index?queryData=" + Case.Session.idfOutbreak;
                        else
                            uri = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                ? $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/AvianDiseaseReport"
                                : $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/LivestockDiseaseReport";

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

        #endregion

        #region Print Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnPrint")]
        public async Task OnPrint()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                var fullName =
                    $"{authenticatedUser.FirstName} {authenticatedUser.SecondName} {authenticatedUser.LastName}";

                ReportViewModel reportModel = new();

                // required parameters N.B.(Every report needs these three)
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                reportModel.AddParameter("SiteID", authenticatedUser.SiteId);
                reportModel.AddParameter("UserFullName", fullName);
                reportModel.AddParameter("UserOrganization", authenticatedUser.Organization);

                if (Model.OutbreakCaseIndicator)
                {
                    reportModel.AddParameter("ObjID", Case.CaseId.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.CommonHeadingsPrintHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "VeterinaryOutbreakCase"}, {"Parameters", reportModel.Parameters}},
                        new DialogOptions
                        {
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px"
                        });
                }
                else
                {
                    reportModel.AddParameter("ObjID", Model.DiseaseReportID.ToString());

                    if (Model.ReportCategoryTypeID == (long)CaseTypeEnum.Avian)
                    {
                        await DiagService.OpenAsync<DisplayReport>(
                            Localizer.GetString(HeadingResourceKeyConstants.CommonHeadingsPrintHeading),
                            new Dictionary<string, object>
                                {{"ReportName", "AvianDiseaseReport"}, {"Parameters", reportModel.Parameters}},
                            new DialogOptions
                            {
                                Resizable = true,
                                Draggable = false,
                                Width = "1150px"
                            });
                    }
                    else
                    {
                        await DiagService.OpenAsync<DisplayReport>(
                            Localizer.GetString(HeadingResourceKeyConstants.CommonHeadingsPrintHeading),
                            new Dictionary<string, object>
                                {{"ReportName", "LivestockDiseaseReport"}, {"Parameters", reportModel.Parameters}},
                            new DialogOptions
                            {
                                Resizable = true,
                                Draggable = false,
                                Width = "1150px"
                            });
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Print Click Event

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
                    {nameof(EIDSSDialog.DialogButtons), buttons},
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

                        // Save the disease report to pick up any child records deleted but not saved yet.
                        //Add deleted farm inventory records back to the main list for saving.
                        if (Model.PendingDeleteFarmInventory is not null && Model.PendingDeleteFarmInventory.Count > 0)
                            foreach (var farmInventoryItem in Model.PendingDeleteFarmInventory)
                                Model.FarmInventory.Add(farmInventoryItem);

                        var saveResponse =
                            await SaveDiseaseReport(Model, Model.OutbreakCaseIndicator ? Case : null, false, null, null);

                        if (saveResponse.ReturnCode == 0)
                        {
                            var deleteResponse = await DeleteDiseaseReport(Model, Model.DiseaseReportID, Model.ReportCategoryTypeID);

                            if (deleteResponse.ReturnCode == 0)
                            {
                                DiagService.Close();

                                _source?.Cancel();

                                var uri = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                    ? $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/AvianDiseaseReport?refreshResultsIndicator=true"
                                    : $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/LivestockDiseaseReport?refreshResultsIndicator=true";

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
        }

        #endregion

        #endregion
    }
}