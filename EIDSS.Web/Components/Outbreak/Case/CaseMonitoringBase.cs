#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case
{
    /// <summary>
    /// </summary>
    public class CaseMonitoringBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CaseMonitoringBase> Logger { get; set; }
        [Inject] protected IConfigurationClient ConfigurationClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Case { get; set; }
        [Parameter] public long? DiseaseReportId { get; set; }
        [Parameter] public CaseMonitoringGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<CaseMonitoringGetListViewModel> Form { get; set; }
        protected RadzenDropDown<long?> InvestigatedByOrganizationDropDown { get; set; }
        protected RadzenDropDown<long?> InvestigatedByPersonDropDown { get; set; }
        protected RadzenTextBox AdditionalCommentsTextBox { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> Organizations { get; set; }
        public IList<EmployeeLookupGetListViewModel> InvestigatedByPersons { get; set; }
        public FlexForm.FlexForm CaseMonitoring { get; set; }
        public bool IsLoading { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        public CaseMonitoringBase(CancellationToken token) : base(token)
        {
        }

        protected CaseMonitoringBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            base.OnInitialized();

            _logger = Logger;

            IsLoading = true;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            FlexFormQuestionnaireGetRequestModel caseMonitoringFlexFormRequest = new()
            {
                idfObservation = Model.ObservationId,
                idfsDiagnosis = Case.DiseaseId,
                LangID = GetCurrentLanguage()
            };

            switch (Case.CaseTypeId)
            {
                case (long) OutbreakSpeciesTypeEnum.Human:
                    caseMonitoringFlexFormRequest.idfsFormTemplate = Case.Session.HumanCaseMonitoringTemplateID;
                    caseMonitoringFlexFormRequest.idfsFormType =
                        (long) FlexibleFormTypeEnum.HumanOutbreakCaseMonitoring;
                    break;
                case (long) OutbreakSpeciesTypeEnum.Avian:
                    caseMonitoringFlexFormRequest.idfsFormTemplate = Case.Session.AvianCaseMonitoringTemplateID;
                    caseMonitoringFlexFormRequest.idfsFormType =
                        (long) FlexibleFormTypeEnum.AvianOutbreakCaseMonitoring;
                    break;
                case (long) OutbreakSpeciesTypeEnum.Livestock:
                    caseMonitoringFlexFormRequest.idfsFormTemplate = Case.Session.LivestockCaseMonitoringTemplateID;
                    caseMonitoringFlexFormRequest.idfsFormType =
                        (long) FlexibleFormTypeEnum.LivestockOutbreakCaseMonitoring;
                    break;
            }

            Model.CaseMonitoringFlexFormRequest = caseMonitoringFlexFormRequest;
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
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
            SuppressFinalize(this);
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

                if (args is not null && !IsNullOrEmpty(args.Filter))
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

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.CaseMonitoringId)
            {
                case 0:
                case null:
                {
                    Model.CaseMonitoringId = (Case.CaseMonitorings.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                }
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            Model.AdditionalComments = AdditionalCommentsTextBox.Value;

            if (Model.CaseMonitoringFlexFormRequest.idfsFormTemplate is not null)
            {
                var response = await CaseMonitoring.CollectAnswers();
                await InvokeAsync(StateHasChanged);
                Model.CaseMonitoringFlexFormRequest.idfsFormTemplate = response.idfsFormTemplate;
                Model.CaseMonitoringFlexFormAnswers = CaseMonitoring.Answers;
                Model.CaseMonitoringObservationParameters = response.Answers;
            }

            switch (Case.CaseTypeId)
            {
                case (long) OutbreakSpeciesTypeEnum.Human:
                    Model.HumanCaseId = DiseaseReportId;
                    break;
                case (long) OutbreakSpeciesTypeEnum.Avian:
                        Model.VeterinaryCaseId = DiseaseReportId;
                    break;
                case (long) OutbreakSpeciesTypeEnum.Livestock:
                    Model.VeterinaryCaseId = DiseaseReportId;
                    break;
            }

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
                }
                else
                {
                    DiagService.Close();
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