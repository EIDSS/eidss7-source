#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
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

namespace EIDSS.Web.Components.Outbreak.Case
{
    /// <summary>
    /// </summary>
    public class OutbreakInvestigationSectionBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<OutbreakInvestigationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<CaseGetDetailViewModel> Form { get; set; }
        protected RadzenDatePicker<DateTime?> InvestigationStartDateDatePicker { get; set; }
        protected RadzenDropDown<long?> InvestigatedByOrganizationDropDown { get; set; }
        protected RadzenDropDown<long?> InvestigatedByPersonDropDown { get; set; }
        protected RadzenDropDown<long?> ClassificationDropDown { get; set; }
        protected RadzenDropDown<long?> StatusDropDown { get; set; }
        protected RadzenCheckBox<bool> PrimaryCaseIndicatorCheckBox { get; set; }
        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> Organizations { get; set; }
        public IList<EmployeeLookupGetListViewModel> InvestigatedByPersons { get; set; }
        public IEnumerable<BaseReferenceViewModel> CaseStatusTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> ClassificationTypes { get; set; }
        public string SectionHeadingResourceKey { get; set; }
        public string InvestigatorOrganizationFieldLabelResourceKey { get; set; }
        public string InvestigatorNameFieldLabelResourceKey { get; set; }
        public string StartingDateOfInvestigationFieldLabelResourceKey { get; set; }
        public string CaseStatusFieldLabelResourceKey { get; set; }
        public string CaseClassificationFieldLabelResourceKey { get; set; }
        public string PrimaryCaseFieldLabelResourceKey { get; set; }
        public FlexForm.FlexForm CaseQuestionnaireFlexForm { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        public OutbreakInvestigationSectionBase(CancellationToken token) : base(token)
        {
        }

        protected OutbreakInvestigationSectionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            GetUserPermissions(PagePermission.AccessToOutbreakVeterinaryCaseData);

            SectionHeadingResourceKey =
                Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseOutbreakInvestigationHeading);

            InvestigatorOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseInvestigatorOrganizationFieldLabel;
            InvestigatorNameFieldLabelResourceKey =
                FieldLabelResourceKeyConstants.CreateVeterinaryCaseInvestigatorNameFieldLabel;
            StartingDateOfInvestigationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseStartingDateOfInvestigationFieldLabel;
            CaseStatusFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseCaseStatusFieldLabel;
            CaseClassificationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseCaseClassificationFieldLabel;
            PrimaryCaseFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCasePrimaryCaseFieldLabel;

            Form = new RadzenTemplateForm<CaseGetDetailViewModel> {EditContext = new EditContext(Model)};

            MessageStore = new List<EIDSSValidationMessageStore>();

            await base.OnInitializedAsync().ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await GetOrganizations(new LoadDataArgs()).ConfigureAwait(false);

                await JsRuntime
                    .InvokeVoidAsync("OutbreakInvestigationSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this)).ConfigureAwait(false);
            }

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
            var errorMessages = Form.EditContext.GetValidationMessages(e.FieldIdentifier);

            var tabIndex = e.FieldIdentifier.FieldName switch
            {
                nameof(Model.InvestigationDate) => InvestigationStartDateDatePicker.TabIndex,
                nameof(Model.InvestigatedByOrganizationId) => InvestigatedByOrganizationDropDown.TabIndex,
                nameof(Model.InvestigatedByPersonId) => InvestigatedByPersonDropDown.TabIndex,
                nameof(Model.ClassificationTypeId) => ClassificationDropDown.TabIndex,
                nameof(Model.StatusTypeId) => StatusDropDown.TabIndex,
                _ => 0
            };

            var temp = MessageStore.Where(x => x.FieldName == e.FieldIdentifier.FieldName).ToList();
            foreach (var error in temp) MessageStore.Remove(error);

            var enumerable = errorMessages.ToList();
            if (!enumerable.Any()) return;
            foreach (var message in enumerable)
                MessageStore.Add(new EIDSSValidationMessageStore
                    {FieldName = e.FieldIdentifier.FieldName, Message = message, TabIndex = tabIndex});
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetOrganizations(LoadDataArgs args)
        {
            try
            {
                if (Organizations is null)
                {
                    OrganizationAdvancedGetRequestModel request = new()
                    {
                        LangID = GetCurrentLanguage(),
                        AccessoryCode = null,
                        AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                        SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite
                    };

                    Organizations = await OrganizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                    Organizations = Organizations.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();
                }

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
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
        public async Task GetInvestigatedByPersons(LoadDataArgs args)
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    OrganizationID = Model.InvestigatedByOrganizationId,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                if (Model.InvestigatedByOrganizationId is null)
                    InvestigatedByPersons = new List<EmployeeLookupGetListViewModel>();
                else
                    InvestigatedByPersons =
                        await CrossCuttingClient.GetEmployeeLookupList(request).ConfigureAwait(false);

                if (Model.InvestigatedByPersonId is not null)
                    if (InvestigatedByPersons.Any(x => x.idfPerson == (long) Model.InvestigatedByPersonId))
                    {
                        EmployeeLookupGetListViewModel model = new()
                        {
                            idfPerson = (long) Model.InvestigatedByPersonId,
                            FullName = Model.InvestigatedByPersonName
                        };

                        InvestigatedByPersons.Add(model);
                    }
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
        public async Task GetCaseStatusTypes(LoadDataArgs args)
        {
            try
            {
                CaseStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakCaseStatus, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    CaseStatusTypes = CaseStatusTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
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
                        ClassificationTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Investigated By Organization Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnInvestigatedByOrganizationChange(object value)
        {
            try
            {
                if (value == null)
                    Model.InvestigatedByPersonId = null;
                else
                    await GetInvestigatedByPersons(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Investigated By Person Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddInvestigatedByPersonClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>
                    {{"OrganizationID", Model.InvestigatedByOrganizationId}};

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            Model.OutbreakInvestigationSectionValidIndicator = Form.EditContext.Validate();

            if (!Model.OutbreakInvestigationSectionValidIndicator)
                return Model.OutbreakInvestigationSectionValidIndicator;
            MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

            if (MessageStore.Count <= 0 && Model.OutbreakInvestigationSectionValidIndicator)
            {
                if (CaseQuestionnaireFlexForm.Request.idfsFormTemplate != null && CaseQuestionnaireFlexForm.Request.idfsFormTemplate != 0)
                    await CaseQuestionnaireFlexForm.SaveFlexForm();

                await InvokeAsync(StateHasChanged);

                Model.CaseQuestionnaireObservationId = CaseQuestionnaireFlexForm.Request.idfObservation;

                return Model.OutbreakInvestigationSectionValidIndicator;
            }

            switch (MessageStore.First().FieldName)
            {
                case nameof(Model.InvestigationDate):
                    await InvestigationStartDateDatePicker.Element.FocusAsync();
                    break;
                case nameof(Model.InvestigatedByOrganizationId):
                    await InvestigatedByOrganizationDropDown.Element.FocusAsync();
                    break;
                case nameof(Model.InvestigatedByPersonId):
                    await InvestigatedByPersonDropDown.Element.FocusAsync();
                    break;

                case nameof(Model.ClassificationTypeId):
                    await ClassificationDropDown.Element.FocusAsync();
                    break;
                case nameof(Model.StatusTypeId):
                    await StatusDropDown.Element.FocusAsync();
                    break;
            }

            return Model.OutbreakInvestigationSectionValidIndicator;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            Model.OutbreakInvestigationSectionValidIndicator = Form.EditContext.Validate();

            return Model.OutbreakInvestigationSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            if (Model.VeterinaryDiseaseReport.ReportCategoryTypeID == 0) return;
            FlexFormQuestionnaireGetRequestModel caseQuestionnaireFlexFormRequest = new()
            {
                idfsDiagnosis = Model.DiseaseId,
                LangID = GetCurrentLanguage()
            };

            if (Model.VeterinaryDiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                caseQuestionnaireFlexFormRequest.idfsFormType =
                    (long) FlexibleFormTypeEnum.AvianOutbreakCaseQuestionnaire;
                caseQuestionnaireFlexFormRequest.idfsFormTemplate = Model.Session.AvianCaseQuestionaireTemplateID;
            }
            else
            {
                caseQuestionnaireFlexFormRequest.idfsFormType =
                    (long) FlexibleFormTypeEnum.LivestockOutbreakCaseQuestionnaire;
                caseQuestionnaireFlexFormRequest.idfsFormTemplate =
                    Model.Session.LivestockCaseQuestionaireTemplateID;
            }

            if (CaseQuestionnaireFlexForm is null) return;
            var response = await CaseQuestionnaireFlexForm.CollectAnswers();
            Model.CaseQuestionnaireFlexFormAnswers = CaseQuestionnaireFlexForm.Answers;
            Model.CaseQuestionnaireObservationParameters = response.Answers;
            await CaseQuestionnaireFlexForm.Render();
            StateHasChanged();
        }

        #endregion

        #endregion
    }
}