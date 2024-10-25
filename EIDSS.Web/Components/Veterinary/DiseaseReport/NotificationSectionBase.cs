#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class NotificationSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<NotificationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<DiseaseReportGetDetailViewModel> Form { get; set; }
        protected RadzenDropDownDataGrid<long?> ReportedByOrganization { get; set; }
        protected RadzenDropDown<long?> ReportedByPerson { get; set; }
        protected RadzenDatePicker<DateTime?> InitialReportDate { get; set; }
        protected RadzenDropDownDataGrid<long?> InvestigatedByOrganization { get; set; }
        protected RadzenDropDown<long?> InvestigatedByPerson { get; set; }
        protected RadzenDatePicker<DateTime?> AssignedDate { get; set; }
        protected RadzenDatePicker<DateTime?> InvestigationDate { get; set; }

        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> Organizations { get; set; }
        public IList<EmployeeLookupGetListViewModel> ReportedByPersons { get; set; }
        public IList<EmployeeLookupGetListViewModel> InvestigatedByPersons { get; set; }
        public string SectionHeadingResourceKey { get; set; }
        public string InvestigatedHeadingResourceKey { get; set; }
        public string DataEntryHeadingResourceKey { get; set; }
        public string ReportedByOrganizationFieldLabelResourceKey { get; set; }
        public string ReportedByPersonFieldLabelResourceKey { get; set; }
        public string InitialReportDateFieldLabelResourceKey { get; set; }
        public string InvestigatedByOrganizationFieldLabelResourceKey { get; set; }
        public string InvestigatedByPersonFieldLabelResourceKey { get; set; }
        public string AssignedDateFieldLabelResourceKey { get; set; }
        public string InvestigationDateFieldLabelResourceKey { get; set; }
        public string DataEntrySiteFieldLabelResourceKey { get; set; }
        public string DataEntryOfficerFieldLabelResourceKey { get; set; }
        public string DataEntryDateFieldLabelResourceKey { get; set; }
        public string ReportDateAssignedDateCompareValidatorResourceKey { get; set; }
        public string ReportDateInvestigationDateCompareValidatorResourceKey { get; set; }
        public string AssignedDateInvestigationDateCompareValidatorResourceKey { get; set; }

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
        public NotificationSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected NotificationSectionBase() : base(CancellationToken.None)
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

            GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);

            if (Model.ReportTypeID == (long) CaseTypeEnum.Avian)
            {
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportNotificationHeading);
                InvestigatedHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportNotificationInvestigatedHeading);
                DataEntryHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportNotificationDataEntryHeading);

                ReportedByOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationOrganizationFieldLabel;
                ReportedByPersonFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportNotificationReportedByFieldLabel;
                InitialReportDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInitialReportDateFieldLabel;
                InvestigatedByOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInvestigationOrganizationFieldLabel;
                InvestigatedByPersonFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInvestigatorNameFieldLabel;
                AssignedDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationAssignedDateFieldLabel;
                InvestigationDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationInvestigationDateFieldLabel;
                DataEntrySiteFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationDataEntrySiteFieldLabel;
                DataEntryOfficerFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationDataEntryOfficerFieldLabel;
                DataEntryDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportNotificationDataEntryDateFieldLabel;

                ReportDateAssignedDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .AvianDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsAssignedDateMessage;
                ReportDateInvestigationDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .AvianDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsInvestigationDateMessage;
                AssignedDateInvestigationDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .AvianDiseaseReportNotificationTheInvestigationDateMustBeLaterThanOrTheSameAstheAssignedDateMessage;
            }
            else
            {
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportNotificationHeading);
                InvestigatedHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .LivestockDiseaseReportNotificationInvestigatedHeading);
                DataEntryHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportNotificationDataEntryHeading);

                ReportedByOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationOrganizationFieldLabel;
                ReportedByPersonFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationReportedByFieldLabel;
                InitialReportDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationInitialReportDateFieldLabel;
                InvestigatedByOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationInvestigationOrganizationFieldLabel;
                InvestigatedByPersonFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationInvestigatorNameFieldLabel;
                AssignedDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationAssignedDateFieldLabel;
                InvestigationDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationInvestigationDateFieldLabel;
                DataEntrySiteFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationDataEntrySiteFieldLabel;
                DataEntryOfficerFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationDataEntryOfficerFieldLabel;
                DataEntryDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportNotificationDataEntryDateFieldLabel;

                ReportDateAssignedDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .LivestockDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsAssignedDateMessage;
                ReportDateInvestigationDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .LivestockDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsInvestigationDateMessage;
                AssignedDateInvestigationDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .LivestockDiseaseReportNotificationTheInvestigationDateMustBeLaterThanOrTheSameAstheAssignedDateMessage;
            }

            Form = new RadzenTemplateForm<DiseaseReportGetDetailViewModel> {EditContext = new EditContext(Model)};

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
                await JsRuntime
                    .InvokeVoidAsync("NotificationSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this)).ConfigureAwait(false);

                await GetOrganizations(new LoadDataArgs()).ConfigureAwait(false);
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
                nameof(Model.ReportedByOrganizationID) => ReportedByOrganization.TabIndex,
                nameof(Model.ReportedByPersonID) => ReportedByPerson.TabIndex,
                nameof(Model.ReportDate) => InitialReportDate.TabIndex,
                nameof(Model.InvestigatedByOrganizationID) => InvestigatedByOrganization.TabIndex,
                nameof(Model.InvestigatedByPersonID) => InvestigatedByPerson.TabIndex,
                nameof(Model.AssignedDate) => AssignedDate.TabIndex,
                nameof(Model.InvestigationDate) => InvestigationDate.TabIndex,
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
                        AccessoryCode = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian ? (int) AccessoryCodeEnum.Avian : (int) AccessoryCodeEnum.Livestock,
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
        public async Task GetReportedByPersons(LoadDataArgs args)
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    OrganizationID = Model.ReportedByOrganizationID,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                if (Model.ReportedByOrganizationID is null)
                    ReportedByPersons = new List<EmployeeLookupGetListViewModel>();
                else
                    ReportedByPersons = await CrossCuttingClient.GetEmployeeLookupList(request).ConfigureAwait(false);

                if (Model.ReportedByPersonID is not null)
                    if (ReportedByPersons.All(x => x.idfPerson != (long) Model.ReportedByPersonID))
                    {
                        EmployeeLookupGetListViewModel model = new()
                        {
                            idfPerson = (long) Model.ReportedByPersonID,
                            FullName = Model.ReportedByPersonName
                        };

                        ReportedByPersons.Add(model);
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
                    OrganizationID = Model.InvestigatedByOrganizationID,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                InvestigatedByPersons = await CrossCuttingClient.GetEmployeeLookupList(request).ConfigureAwait(false);

                if (Model.InvestigatedByPersonID is not null)
                    if (InvestigatedByPersons.All(x => x.idfPerson != (long) Model.InvestigatedByPersonID))
                    {
                        EmployeeLookupGetListViewModel model = new()
                        {
                            idfPerson = (long) Model.InvestigatedByPersonID,
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

        #endregion

        #region Reported By Organization Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnReportedByOrganizationChanged(object value)
        {
            try
            {
                if (value == null)
                    Model.ReportedByPersonID = null;
                else
                    await GetReportedByPersons(new LoadDataArgs()).ConfigureAwait(false);
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
        protected async Task OnInvestigatedByOrganizationChanged(object value)
        {
            try
            {
                if (value == null)
                    Model.InvestigatedByPersonID = null;
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

        #region Add Reported By Person Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddReportedByPersonClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object> {{"OrganizationID", Model.ReportedByOrganizationID}};

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
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

        #region Add Investigated By Person Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddInvestigatedByPersonClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>
                    {{"OrganizationID", Model.InvestigatedByOrganizationID}};

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
                    }).ConfigureAwait(false);

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
        /// <param name="identifier"></param>
        private void ValidateField(FieldIdentifier identifier)
        {
            var errorMessages = Form.EditContext.GetValidationMessages(identifier);

            var tabIndex = identifier.FieldName switch
            {
                nameof(Model.ReportedByOrganizationID) => ReportedByOrganization.TabIndex,
                nameof(Model.ReportedByPersonID) => ReportedByPerson.TabIndex,
                nameof(Model.ReportDate) => InitialReportDate.TabIndex,
                nameof(Model.InvestigatedByOrganizationID) => InvestigatedByOrganization.TabIndex,
                nameof(Model.InvestigatedByPersonID) => InvestigatedByPerson.TabIndex,
                nameof(Model.AssignedDate) => AssignedDate.TabIndex,
                nameof(Model.InvestigationDate) => InvestigationDate.TabIndex,
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
        public async Task<string> ValidateSectionForSubmit()
        {
            Model.NotificationSectionValidIndicator = Form.EditContext.Validate();
            Model.NotificationSectionModifiedIndicator = Form.EditContext.IsModified();

            if (Model.NotificationSectionValidIndicator) return Empty;
            MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

            if (MessageStore.Count <= 0)
            {
                ValidateField(Form.EditContext.Field(nameof(Model.ReportedByOrganizationID)));
                ValidateField(Form.EditContext.Field(nameof(Model.ReportedByPersonID)));
                ValidateField(Form.EditContext.Field(nameof(Model.ReportDate)));
                ValidateField(Form.EditContext.Field(nameof(Model.InvestigatedByOrganizationID)));
                ValidateField(Form.EditContext.Field(nameof(Model.InvestigatedByPersonID)));
                ValidateField(Form.EditContext.Field(nameof(Model.AssignedDate)));
                ValidateField(Form.EditContext.Field(nameof(Model.InvestigationDate)));
            }

            switch (MessageStore.First().FieldName)
            {
                case nameof(Model.ReportedByOrganizationID):
                    await ReportedByOrganization.Element.FocusAsync();
                    break;
                case nameof(Model.ReportedByPersonID):
                    await ReportedByPerson.Element.FocusAsync();
                    break;
                case nameof(Model.ReportDate):
                    await InitialReportDate.Element.FocusAsync();
                    break;
                case nameof(Model.InvestigatedByOrganizationID):
                    await InvestigatedByOrganization.Element.FocusAsync();
                    break;
                case nameof(Model.InvestigatedByPersonID):
                    await InvestigatedByPerson.Element.FocusAsync();
                    break;
                case nameof(Model.AssignedDate):
                    await AssignedDate.Element.FocusAsync();
                    break;
                case nameof(Model.InvestigationDate):
                    await InvestigationDate.Element.FocusAsync();
                    break;
            }

            return MessageStore.Any() ? MessageStore.First().FieldName : Empty;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            Model.NotificationSectionValidIndicator = Form.EditContext.Validate();

            return Model.NotificationSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        [JSInvokable]
        public void ReloadSection()
        {
            StateHasChanged();
        }

        #endregion

        #endregion
    }
}