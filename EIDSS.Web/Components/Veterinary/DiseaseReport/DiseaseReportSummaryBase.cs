#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class DiseaseReportSummaryBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DiseaseReportSummaryBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<DiseaseReportGetDetailViewModel> Form { get; set; }
        protected RadzenDropDown<long?> ReportStatus { get; set; }
        protected RadzenDropDown<long?> Classification { get; set; }
        protected RadzenTextBox FieldAccessionId { get; set; }
        protected RadzenDropDown<long?> ReportType { get; set; }
        protected RadzenDatePicker<DateTime?> DiagnosisDate { get; set; }
        protected RadzenDropDown<long?> Disease { get; set; }

        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }
        public IEnumerable<BaseReferenceViewModel> ReportStatusTypes { get; set; }
        public IList<BaseReferenceViewModel> ClassificationTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> ReportTypes { get; set; }
        public IEnumerable<FilteredDiseaseGetListViewModel> Diseases { get; set; }

        public string ReportIdFieldLabelResourceKey { get; set; }
        public string ReportStatusFieldLabelResourceKey { get; set; }
        public string ClassificationFieldLabelResourceKey { get; set; }
        public string RelatedToDiseaseReportResourceKey { get; set; }
        public string FieldAccessionIdFieldLabelResourceKey { get; set; }
        public string OutbreakIdFieldLabelResourceKey { get; set; }
        public string SessionIdFieldLabelResourceKey { get; set; }
        public string LegacyIdFieldLabelResourceKey { get; set; }
        public string ReportTypeFieldLabelResourceKey { get; set; }
        public string CommentsFieldLabelResourceKey { get; set; }
        public string DiagnosisDateFieldLabelResourceKey { get; set; }
        public string DiseaseFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public DiseaseReportSummaryBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected DiseaseReportSummaryBase() : base(CancellationToken.None)
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
            _userPermissions = GetUserPermissions(PagePermission.CanReopenClosedVetDiseaseReportSession);
            Model.CanReopenClosedDiseaseReportSession = _userPermissions.Execute;

            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                ReportIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryReportIDFieldLabel;
                ReportStatusFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryReportStatusFieldLabel;
                ClassificationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryCaseClassificationFieldLabel;
                RelatedToDiseaseReportResourceKey = Localizer.GetString(FieldLabelResourceKeyConstants
                    .AvianDiseaseReportRelatedToDiseaseReportFieldLabel);
                FieldAccessionIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSummaryFieldAccessionIDFieldLabel;
                OutbreakIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryOutbreakIDFieldLabel;
                SessionIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummarySessionIDFieldLabel;
                LegacyIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryLegacyIDFieldLabel;
                ReportTypeFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryReportTypeFieldLabel;
                CommentsFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsCommentsFieldLabel;
                DiagnosisDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryDateOfDiagnosisFieldLabel;
                DiseaseFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSummaryDiseaseFieldLabel;
            }
            else
            {
                ReportIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummaryReportIDFieldLabel;
                ReportStatusFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummaryReportStatusFieldLabel;
                ClassificationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSummaryCaseClassificationFieldLabel;
                RelatedToDiseaseReportResourceKey = Localizer.GetString(FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportRelatedToDiseaseReportFieldLabel);
                FieldAccessionIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSummaryFieldAccessionIDFieldLabel;
                OutbreakIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummaryOutbreakIDFieldLabel;
                SessionIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummarySessionIDFieldLabel;
                LegacyIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummaryLegacyIDFieldLabel;
                ReportTypeFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummaryReportTypeFieldLabel;
                CommentsFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsCommentsFieldLabel;
                DiagnosisDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSummaryDateOfDiagnosisFieldLabel;
                DiseaseFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSummaryDiseaseFieldLabel;
            }

            Form = new RadzenTemplateForm<DiseaseReportGetDetailViewModel>
            {
                EditContext = new EditContext(Model)
            };

            MessageStore = new List<EIDSSValidationMessageStore>();

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
                await JsRuntime.InvokeVoidAsync("DiseaseReportSummary.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);

            Form.EditContext.OnFieldChanged += OnFormFieldChanged;
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                if (Form.EditContext is not null)
                    Form.EditContext.OnFieldChanged -= OnFormFieldChanged;

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

        #endregion

        #region Form Events

        /// <summary>
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnFormFieldChanged(object sender, FieldChangedEventArgs e)
        {
            ValidateField(e.FieldIdentifier);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetReportStatusTypes(LoadDataArgs args)
        {
            try
            {
                ReportStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.CaseStatus, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    ReportStatusTypes = ReportStatusTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetClassificationTypes(LoadDataArgs args)
        {
            try
            {
                ClassificationTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.CaseClassification, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    ClassificationTypes =
                        ClassificationTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();

                if (Model.ClassificationTypeID is not null)
                    if (ClassificationTypes.All(x => x.IdfsBaseReference != (long) Model.ClassificationTypeID))
                    {
                        BaseReferenceViewModel model = new()
                        {
                            IdfsBaseReference = (long) Model.ClassificationTypeID,
                            Name = Model.ClassificationTypeName
                        };

                        ClassificationTypes.Add(model);
                    }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetReportTypes(LoadDataArgs args)
        {
            try
            {
                ReportTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.CaseReportType, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    ReportTypes = ReportTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetDiseases(LoadDataArgs args)
        {
            try
            {
                FilteredDiseaseRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                        ? HACodeList.AvianHACode
                        : HACodeList.LivestockHACode,
                    AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    UsingType = (long) DiseaseUsingTypes.Standard,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);

                if (!IsNullOrEmpty(args.Filter))
                    Diseases = Diseases.Where(c =>
                        c.DiseaseName != null &&
                        c.DiseaseName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Report Status Type Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnReportStatusTypeChange(object value)
        {
            try
            {
                if (value is not null)
                    if (Model.DiseaseReportID > 0)
                        // Check if the disease report is being re-opened.
                        // If yes, then log a notification.
                        if (Model.ReportCurrentlyClosedIndicator &&
                            (long) value == (long) DiseaseReportStatusTypeEnum.InProcess)
                        {
                            var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.SiteID
                                ? SystemEventLogTypes.ClosedVeterinaryDiseaseReportWasReopenedAtYourSite
                                : SystemEventLogTypes.ClosedVeterinaryDiseaseReportWasReopenedAtAnotherSite;

                            if (Model.PendingSaveEvents.All(x => x.EventTypeId != (long) eventTypeId))
                                Model.PendingSaveEvents.Add(await CreateEvent(Model.DiseaseReportID,
                                    Model.DiseaseID, eventTypeId, Model.SiteID, null));
                        }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Classification Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnClassificationTypeChange(object value)
        {
            try
            {
                if (value is not null)
                    if (Model.DiseaseReportID > 0)
                    {
                        SystemEventLogTypes eventTypeId;

                        if (Model.OutbreakCaseIndicator)
                        {
                            eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.SiteID
                                ? SystemEventLogTypes
                                    .VeterinaryOutbreakCaseClassificationWasChangedAtYourSite
                                : SystemEventLogTypes
                                    .VeterinaryOutbreakCaseClassificationWasChangedAtAnotherSite;
                        }
                        else
                        {
                            eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.SiteID
                                ? SystemEventLogTypes
                                    .VeterinaryDiseaseReportClassificationWasChangedAtYourSite
                                : SystemEventLogTypes
                                    .VeterinaryDiseaseReportClassificationWasChangedAtAnotherSite;
                        }
                        if (Model.PendingSaveEvents.All(x => x.EventTypeId != (long) eventTypeId))
                            Model.PendingSaveEvents.Add(await CreateEvent(Model.DiseaseReportID,
                                Model.DiseaseID, eventTypeId, Model.SiteID, null));
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Disease Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected void OnDiseaseChange()
        {
            try
            {
                if (Model.DiseaseID is null) return;
                if (Model.FarmEpidemiologicalInfoFlexForm is null) return;
                Model.FarmEpidemiologicalInfoFlexForm.idfsDiagnosis = Model.DiseaseID;
                StateHasChanged();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Related to Disease Report Button Click Event
        
        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRelatedToDiseaseReportClick()
        {
            try
            {
                if (Form.EditContext.IsModified() ||
                    Model.FarmDetailsSectionModifiedIndicator ||
                    Model.NotificationSectionModifiedIndicator ||
                    Model.FarmEpidemiologicalInfoSectionModifiedIndicator ||
                    Model.SpeciesClinicalInvestigationInfoSectionModifiedIndicator ||
                    Model.ControlMeasuresSectionModifiedIndicator ||
                    Model.PendingSaveAnimals is not null && Model.PendingSaveAnimals.Count > 0 ||
                    Model.PendingSaveCaseLogs is not null && Model.PendingSaveCaseLogs.Count > 0 ||
                    Model.PendingSaveLaboratoryTestInterpretations is not null &&
                    Model.PendingSaveLaboratoryTestInterpretations.Count > 0 ||
                    Model.PendingSaveLaboratoryTests is not null && Model.PendingSaveLaboratoryTests.Count > 0 ||
                    Model.PendingSaveEvents is not null && Model.PendingSaveEvents.Count > 0 ||
                    Model.PendingSavePensideTests is not null && Model.PendingSavePensideTests.Count > 0 ||
                    Model.PendingSaveSamples is not null && Model.PendingSaveSamples.Count > 0 ||
                    Model.PendingSaveVaccinations is not null && Model.PendingSaveVaccinations.Count > 0)
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText != Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            _source?.Cancel();

                            const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                            var query =
                                $"?reportTypeID={Model.ReportCategoryTypeID}&farmID={Model.FarmID}&diseaseReportID={Model.RelatedToVeterinaryDiseaseReportID}&isEdit=true";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                        }
                        else
                        {
                            DiagService.Close(result);

                            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                                await JsRuntime.InvokeAsync<string>("validateAvianDiseaseReport", _token, null, false);
                            else
                                await JsRuntime.InvokeAsync<string>("validateLivestockDiseaseReport", _token, null, false);
                        }
                    }
                }
                else
                {
                    _source?.Cancel();

                    const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                    var query =
                        $"?reportTypeID={Model.ReportCategoryTypeID}&farmID={Model.FarmID}&diseaseReportID={Model.RelatedToVeterinaryDiseaseReportID}&isEdit=true";
                    var uri = $"{NavManager.BaseUri}{path}{query}";

                    NavManager.NavigateTo(uri, true);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Connected Disease Report Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnConnectedDiseaseReportClick()
        {
            try
            {
                const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                if (Form.EditContext.IsModified() ||
                    Model.FarmDetailsSectionModifiedIndicator ||
                    Model.NotificationSectionModifiedIndicator ||
                    Model.FarmEpidemiologicalInfoSectionModifiedIndicator ||
                    Model.SpeciesClinicalInvestigationInfoSectionModifiedIndicator ||
                    Model.ControlMeasuresSectionModifiedIndicator ||
                    Model.PendingSaveAnimals is not null && Model.PendingSaveAnimals.Count > 0 ||
                    Model.PendingSaveCaseLogs is not null && Model.PendingSaveCaseLogs.Count > 0 ||
                    Model.PendingSaveLaboratoryTestInterpretations is not null &&
                    Model.PendingSaveLaboratoryTestInterpretations.Count > 0 ||
                    Model.PendingSaveLaboratoryTests is not null && Model.PendingSaveLaboratoryTests.Count > 0 ||
                    Model.PendingSaveEvents is not null && Model.PendingSaveEvents.Count > 0 ||
                    Model.PendingSavePensideTests is not null && Model.PendingSavePensideTests.Count > 0 ||
                    Model.PendingSaveSamples is not null && Model.PendingSaveSamples.Count > 0 ||
                    Model.PendingSaveVaccinations is not null && Model.PendingSaveVaccinations.Count > 0)
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            DiagService.Close(result);

                            await JsRuntime.InvokeAsync<string>("validateDiseaseReport", _token);
                        }
                        else
                        {
                            _source?.Cancel();

                            var query =
                                $"?reportTypeID={Model.ReportCategoryTypeID}&farmID={Model.FarmID}&diseaseReportID={Model.ConnectedDiseaseReportID}&isEdit=true";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                        }
                    }
                }
                else
                {
                    _source?.Cancel();

                    var query =
                        $"?reportTypeID={Model.ReportCategoryTypeID}&farmID={Model.FarmID}&diseaseReportID={Model.ConnectedDiseaseReportID}&isEdit=true";
                    var uri = $"{NavManager.BaseUri}{path}{query}";

                    NavManager.NavigateTo(uri, true);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <param name="identifier"></param>
        private void ValidateField(FieldIdentifier identifier)
        {
            var errorMessages = Form.EditContext.GetValidationMessages(identifier);

            var tabIndex = identifier.FieldName switch
            {
                nameof(Model.ReportStatusTypeID) => ReportStatus.TabIndex,
                nameof(Model.ClassificationTypeID) => Classification.TabIndex,
                nameof(Model.EIDSSFieldAccessionID) => FieldAccessionId.TabIndex,
                nameof(Model.ReportTypeID) => ReportType.TabIndex,
                nameof(Model.DiagnosisDate) => DiagnosisDate.TabIndex,
                nameof(Model.DiseaseID) => Disease.TabIndex,
                _ => 0
            };

            var temp = MessageStore.Where(x => x.FieldName == identifier.FieldName).ToList();
            foreach (var error in temp) MessageStore.Remove(error);

            var enumerable = errorMessages.ToList();
            if (!enumerable.Any()) return;
            foreach (var message in enumerable)
                MessageStore.Add(new EIDSSValidationMessageStore
                { FieldName = identifier.FieldName, Message = message, TabIndex = tabIndex });
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<string> ValidateSummary()
        {
            Model.DiseaseReportSummaryValidIndicator = Form.EditContext.Validate();

            Model.DiseaseReportSummaryModifiedIndicator = Form.EditContext.IsModified();

            if (Model.DiseaseReportSummaryValidIndicator) return Empty;
            MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

            if (MessageStore.Count <= 0)
            {
                ValidateField(Form.EditContext.Field(nameof(Model.ReportStatusTypeID)));
                ValidateField(Form.EditContext.Field(nameof(Model.ClassificationTypeID)));
                ValidateField(Form.EditContext.Field(nameof(Model.EIDSSFieldAccessionID)));
                ValidateField(Form.EditContext.Field(nameof(Model.ReportTypeID)));
                ValidateField(Form.EditContext.Field(nameof(Model.DiagnosisDate)));
                ValidateField(Form.EditContext.Field(nameof(Model.DiseaseID)));
            }

            switch (MessageStore.First().FieldName)
            {
                case nameof(Model.ReportStatusTypeID):
                    await ReportStatus.Element.FocusAsync().ConfigureAwait(false);
                    break;
                case nameof(Model.ClassificationTypeID):
                    await Classification.Element.FocusAsync().ConfigureAwait(false);
                    break;
                case nameof(Model.EIDSSFieldAccessionID):
                    await FieldAccessionId.Element.FocusAsync().ConfigureAwait(false);
                    break;
                case nameof(Model.ReportTypeID):
                    await ReportType.Element.FocusAsync().ConfigureAwait(false);
                    break;
                case nameof(Model.DiagnosisDate):
                    await DiagnosisDate.Element.FocusAsync().ConfigureAwait(false);
                    break;
                case nameof(Model.DiseaseID):
                    await Disease.Element.FocusAsync().ConfigureAwait(false);
                    break;
            }

            return MessageStore.Any() ? MessageStore.First().FieldName : Empty;
        }

        #endregion

        #region Refresh Summary Method

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        [JSInvokable]
        public void RefreshSummary(bool isReview)
        {
            Model.ReportDisabledIndicator = Model.ReportStatusTypeID == (long)DiseaseReportStatusTypeEnum.Closed && Model.ReportCurrentlyClosedIndicator || isReview || (Model.OutbreakID != null && !Model.OutbreakCaseIndicator);

            StateHasChanged();
        }

        #endregion

        #endregion
    }
}