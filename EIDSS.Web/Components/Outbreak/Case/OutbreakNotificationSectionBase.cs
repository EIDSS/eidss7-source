#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
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
    public class OutbreakNotificationSectionBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<OutbreakNotificationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<CaseGetDetailViewModel> Form { get; set; }
        protected RadzenDatePicker<DateTime?> NotificationDate { get; set; }
        protected RadzenDropDownDataGrid<long?> SentByOrganization { get; set; }
        protected RadzenDropDown<long?> SentByPerson { get; set; }
        protected RadzenDropDownDataGrid<long?> ReceivedByOrganization { get; set; }
        protected RadzenDropDown<long?> ReceivedByPerson { get; set; }
        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> Organizations { get; set; }
        public IList<EmployeeLookupGetListViewModel> SentByPersons { get; set; }
        public IList<EmployeeLookupGetListViewModel> ReceivedByPersons { get; set; }
        public string SectionHeadingResourceKey { get; set; }
        public string NotificationSentByFacilityFieldLabelResourceKey { get; set; }
        public string NotificationSentByNameFieldLabelResourceKey { get; set; }
        public string NotificationDateFieldLabelResourceKey { get; set; }
        public string NotificationReceivedByFacilityFieldLabelResourceKey { get; set; }
        public string NotificationReceivedByNameFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        public OutbreakNotificationSectionBase(CancellationToken token) : base(token)
        {
        }

        protected OutbreakNotificationSectionBase() : base(CancellationToken.None)
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
                Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseNotificationHeading);

            NotificationSentByFacilityFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseNotificationSentByFacilityFieldLabel;
            NotificationSentByNameFieldLabelResourceKey =
                FieldLabelResourceKeyConstants.CreateVeterinaryCaseNotificationSentByNameFieldLabel;
            NotificationDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseDateOfNotificationFieldLabel;
            NotificationReceivedByFacilityFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseNotificationReceivedByFacilityFieldLabel;
            NotificationReceivedByNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                .CreateVeterinaryCaseNotificationReceivedByNameFieldLabel;

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
                await JsRuntime
                    .InvokeVoidAsync("OutbreakNotificationSection.SetDotNetReference", _token,
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
                nameof(Model.NotificationDate) => NotificationDate.TabIndex,
                nameof(Model.NotificationSentByOrganizationId) => SentByOrganization.TabIndex,
                nameof(Model.NotificationSentByPersonId) => SentByPerson.TabIndex,
                nameof(Model.NotificationReceivedByOrganizationId) => ReceivedByOrganization.TabIndex,
                nameof(Model.NotificationReceivedByPersonId) => ReceivedByPerson.TabIndex,
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
        public async Task GetSentByPersons(LoadDataArgs args)
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    OrganizationID = Model.NotificationSentByOrganizationId,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                if (Model.NotificationSentByOrganizationId is null)
                    SentByPersons = new List<EmployeeLookupGetListViewModel>();
                else
                    SentByPersons = await CrossCuttingClient.GetEmployeeLookupList(request).ConfigureAwait(false);

                if (Model.NotificationSentByPersonId is not null)
                    if (SentByPersons.Any(x => x.idfPerson == (long) Model.NotificationSentByPersonId))
                    {
                        EmployeeLookupGetListViewModel model = new()
                        {
                            idfPerson = (long) Model.NotificationSentByPersonId,
                            FullName = Model.NotificationSentByPersonName
                        };

                        SentByPersons.Add(model);
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
        public async Task GetReceivedByPersons(LoadDataArgs args)
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    OrganizationID = Model.NotificationReceivedByOrganizationId,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                ReceivedByPersons = await CrossCuttingClient.GetEmployeeLookupList(request).ConfigureAwait(false);

                if (Model.NotificationReceivedByPersonId is not null)
                    if (ReceivedByPersons.All(x => x.idfPerson != (long) Model.NotificationReceivedByPersonId))
                    {
                        EmployeeLookupGetListViewModel model = new()
                        {
                            idfPerson = (long) Model.NotificationReceivedByPersonId,
                            FullName = Model.NotificationReceivedByPersonName
                        };

                        ReceivedByPersons.Add(model);
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sent By Organization Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnSentByOrganizationChanged(object value)
        {
            try
            {
                if (value == null)
                    Model.NotificationSentByPersonId = null;
                else
                    await GetSentByPersons(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Received By Organization Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnReceivedByOrganizationChanged(object value)
        {
            try
            {
                if (value == null)
                    Model.NotificationReceivedByPersonId = null;
                else
                    await GetReceivedByPersons(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Sent By Person Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddSentByPersonClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>
                    {{"OrganizationID", Model.NotificationSentByOrganizationId}};

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

        #region Add Received By Person Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddReceivedByPersonClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>
                    {{"OrganizationID", Model.NotificationReceivedByOrganizationId}};

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true,
                        Draggable = false
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
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSubmit()
        {
            Model.NotificationSectionValidIndicator = Form.EditContext.Validate();

            if (Model.NotificationSectionValidIndicator) return Model.NotificationSectionValidIndicator;
            MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

            if (MessageStore.Count <= 0) return Model.NotificationSectionValidIndicator;
            switch (MessageStore.First().FieldName)
            {
                case nameof(Model.NotificationDate):
                    await NotificationDate.Element.FocusAsync();
                    break;
                case nameof(Model.NotificationSentByOrganizationId):
                    await SentByOrganization.Element.FocusAsync();
                    break;
                case nameof(Model.NotificationSentByPersonId):
                    await SentByPerson.Element.FocusAsync();
                    break;

                case nameof(Model.NotificationReceivedByOrganizationId):
                    await ReceivedByOrganization.Element.FocusAsync();
                    break;
                case nameof(Model.NotificationReceivedByPersonId):
                    await ReceivedByPerson.Element.FocusAsync();
                    break;
            }

            return Model.NotificationSectionValidIndicator;
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

        #endregion
    }
}