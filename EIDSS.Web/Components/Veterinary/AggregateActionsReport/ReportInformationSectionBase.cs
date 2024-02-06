#region Usings

using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
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

namespace EIDSS.Web.Components.Veterinary.AggregateActionsReport
{
    public class ReportInformationSectionBase : ReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ReportInformationSectionBase> Logger { get; set; }

        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        protected IList<OrganizationAdvancedGetListViewModel> LocationOrganizations { get; set; }
        protected int LocationOrganizationCount { get; set; }
        protected IList<OrganizationAdvancedGetListViewModel> SentByOrganizations { get; set; }
        protected int SentByOrganizationCount { get; set; }
        protected IList<OrganizationAdvancedGetListViewModel> ReceivedByOrganizations { get; set; }
        protected int ReceivedByOrganizationCount { get; set; }
        protected IList<EmployeeLookupGetListViewModel> SentByOfficers { get; set; }
        protected int SentByOfficersCount { get; set; }
        protected IList<EmployeeLookupGetListViewModel> ReceivedByOfficers { get; set; }
        protected int ReceivedByOfficersCount { get; set; }
        protected RadzenDropDown<long?> SentByOfficerDropDown { get; set; }
        protected RadzenDropDown<long?> ReceivedByOfficerDropDown { get; set; }

        protected RadzenTemplateForm<VeterinaryAggregateActionsReportStateContainer> Form;

        protected LocationView LocationComponent;


        #endregion Properties

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetAggregateActionsReportInformationSection.SetDotNetReference",
                        _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();

                StateContainer.OnChange -= async property => await OnStateContainerChangeAsync(property);
            }

            base.Dispose(disposing);
        }

        private async Task OnStateContainerChangeAsync(string property)
        {
            switch (property)
            {
                case "NotificationReceivedInstitutionID":
                    await OnReceivedByInstitutionChange();
                    break;

                case "NotificationSentInstitutionID":
                    await OnSentByInstitutionChange();
                    break;

                case "Week":
                    await InvokeAsync(StateHasChanged);
                    break;

                case "Month":
                    await InvokeAsync(StateHasChanged);
                    break;

                case "Quarter":
                    await InvokeAsync(StateHasChanged);
                    break;
            }
        }

        #endregion Lifecycle Methods

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetReceivedByOrganizations(LoadDataArgs args)
        {
            try
            {
                if (StateContainer is {Organizations: null}) await StateContainer.LoadOrganizations();

                if (StateContainer is {Organizations: { }})
                {
                    var query = StateContainer.Organizations.AsQueryable();
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        query = query.Where(x => x.name.ToLowerInvariant().StartsWith(args.Filter.ToLowerInvariant()));
                    }

                    ReceivedByOrganizationCount = query.Count();
                    ReceivedByOrganizations = query.ToList();
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
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetSentByOrganizations(LoadDataArgs args)
        {
            try
            {
                if (StateContainer is {Organizations: null}) await StateContainer.LoadOrganizations();

                if (StateContainer is {Organizations: { }})
                {
                    var query = StateContainer.Organizations.AsQueryable();

                    if (!IsNullOrEmpty(args.Filter))
                    {
                        query = query.Where(x => x.name.ToLowerInvariant().StartsWith(args.Filter.ToLowerInvariant()));
                    }

                    SentByOrganizationCount = query.Count();
                    SentByOrganizations = query.ToList();
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
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetLocationOrganizations(LoadDataArgs args)
        {
            try
            {
                if (StateContainer is {Organizations: null}) await StateContainer.LoadOrganizations();

                if (StateContainer is {Organizations: { }})
                {
                    var query = StateContainer.Organizations.AsQueryable();
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        query = query.Where(x => x.name.ToLowerInvariant().StartsWith(args.Filter.ToLowerInvariant()));
                    }

                    LocationOrganizationCount = query.Count();
                    LocationOrganizations = query.ToList();
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
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetSentByOfficers(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.NotificationSentInstitutionID is not null)
                {
                    EmployeeLookupGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        AccessoryCode = null,
                        AdvancedSearch = null,
                        OrganizationID = StateContainer.NotificationSentInstitutionID,
                        SortColumn = "FullName",
                        SortOrder = SortConstants.Ascending
                    };

                    SentByOfficers = await CrossCuttingClient.GetEmployeeLookupList(request);
                }

                if (!IsNullOrEmpty(args.Filter))
                {
                    SentByOfficers = SentByOfficers?.Where(x =>
                        x.FullName.ToLowerInvariant().StartsWith(args.Filter.ToLowerInvariant())).ToList();
                }

                SentByOfficersCount = SentByOfficers is not null && SentByOfficers.Any() ? SentByOfficers.Count() : 0;

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
        protected async Task GetReceivedByOfficers(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.NotificationReceivedInstitutionID is not null)
                {
                    EmployeeLookupGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        AccessoryCode = null,
                        AdvancedSearch = null,
                        OrganizationID = StateContainer.NotificationReceivedInstitutionID,
                        SortColumn = "FullName",
                        SortOrder = SortConstants.Ascending
                    };

                    ReceivedByOfficers = await CrossCuttingClient.GetEmployeeLookupList(request);
                }

                if (!IsNullOrEmpty(args.Filter))
                {
                    ReceivedByOfficers = ReceivedByOfficers?.Where(x =>
                        x.FullName.ToLowerInvariant().StartsWith(args.Filter.ToLowerInvariant())).ToList();
                }

                ReceivedByOfficersCount = (ReceivedByOfficers is not null && ReceivedByOfficers.Any())
                    ? ReceivedByOfficers.Count
                    : 0;

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data Methods

        #region Add Employee Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddEmployeeClick(string fromButton)
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true,
                        Draggable = false
                    });

                if (result is EmployeeSaveRequestResponseModel)
                {
                    switch (fromButton)
                    {
                        case "SentByAdd":
                            SentByOfficersCount = 0;
                            SentByOfficers = null;
                            await GetSentByOfficers(new LoadDataArgs());
                            break;

                        case "ReceivedByAdd":
                            ReceivedByOfficersCount = 0;
                            ReceivedByOfficers = null;
                            await GetReceivedByOfficers(new LoadDataArgs());
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Control Events

        protected async Task OnLocationChanged(LocationViewModel locationViewModel)
        {
            StateContainer.ReportLocationViewModel = locationViewModel;
            StateContainer.SetAdministrativeUnit();
            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        public async Task ComponentRefresh(LocationViewModel locationViewModel)
        {
            await LocationComponent.RefreshComponent(locationViewModel);
        }

        protected async Task OnSentByInstitutionChange()
        {
            SentByOfficersCount = 0;
            SentByOfficers = null;
            await GetSentByOfficers(new LoadDataArgs());
        }

        protected async Task OnReceivedByInstitutionChange()
        {
            ReceivedByOfficersCount = 0;
            ReceivedByOfficers = null;
            await GetReceivedByOfficers(new LoadDataArgs());
        }

        protected async Task OnChangePeriod(object item, string changedPeriodType)
        {
            switch (changedPeriodType)
            {
                case StatisticPeriodType.Year:
                    if (StateContainer.ShowQuarter)
                        StateContainer.LoadQuarters(new LoadDataArgs());
                    else if (StateContainer.ShowMonth)
                        await StateContainer.LoadMonths(new LoadDataArgs());
                    else if (StateContainer.ShowWeek)
                        StateContainer.LoadWeeks(new LoadDataArgs());
                    break;
            }
        }

        protected void OnChangeDay(object item)
        {
            if (item is null) return;
            var day = (DateTime)item;
        }

        #endregion Control Events

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            StateContainer.ReportInformationValidIndicator = Form.EditContext.Validate();

            StateContainer.ReportInformationModifiedIndicator = Form.EditContext.IsModified();

            return await Task.FromResult(StateContainer.ReportInformationValidIndicator);
        }

        #endregion Validation Methods

        #region Set ReportDisabledIndicator

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("SetReportDisabledIndicator")]
        public async Task SetReportDisabledIndicator(int currentIndex)
        {
            if (currentIndex == 4) //review section
            {
                StateContainer.InformationReportDisabledIndicator = true;
            }
            else
            {
                if ((StateContainer.ReportKey <= 0 &&
                     !StateContainer.VeterinaryAggregateActionsReportPermissions.Create)
                    || (StateContainer.ReportKey > 0 &&
                        !StateContainer.VeterinaryAggregateActionsReportPermissions.Write))
                {
                    StateContainer.InformationReportDisabledIndicator = true;
                }
                else
                {
                    StateContainer.InformationReportDisabledIndicator = false;
                }
            }

            StateContainer.SetAdministrativeLevels(StateContainer.AreaTypeID.GetValueOrDefault());
            await InvokeAsync(StateHasChanged);
        }

        #endregion Set ReportDisabledIndicators

        #endregion Methods
    }
}