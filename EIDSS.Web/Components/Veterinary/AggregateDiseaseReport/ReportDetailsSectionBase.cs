#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Administration;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.AggregateDiseaseReport
{
    public class ReportDetailsSectionBase : AggregateDiseaseReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ReportDetailsSectionBase> Logger { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private IEmployeeClient EmployeeClient { get; set; }
        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private IAggregateReportClient AggregateReportClient { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public AggregateReportDetailsViewModel Model { get; set; }

        [Parameter] public bool IsReadOnly { get; set; }

        #endregion

        #region Private Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #region Protected and Public Fields

        protected IEnumerable<OrganizationAdvancedGetListViewModel> Organizations;
        protected IEnumerable<EmployeeLookupGetListViewModel> SentByOfficers;
        protected IEnumerable<EmployeeLookupGetListViewModel> ReceivedByOfficers;
        protected IEnumerable<Period> Years;
        protected IEnumerable<Period> Quarters;
        protected IEnumerable<Period> Months;
        protected IEnumerable<Period> Weeks;
        protected IEnumerable<OrganizationGetListViewModel> AdministrativeLevelOrganizations;
        protected RadzenTemplateForm<AggregateReportDetailsViewModel> Form;
        protected LocationView LocationViewControl;

        private UserPermissions _userPermissions;

        protected bool CanAddEmployee { get; set; }

        #endregion Protected and Public Fields

        #endregion

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync(
                    "VeterinaryAggregateDiseaseReport.ReportDetailsSection.SetDotNetReference", _token,
                    dotNetReference);

                await GetOrganizations(new LoadDataArgs());
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();

            var uri = NavManager.ToAbsoluteUri(NavManager.Uri);
            QueryHelpers.ParseQuery(uri.Query);
            if (QueryHelpers.ParseQuery(uri.Query).TryGetValue("isReadOnly", out var readOnlyToken))
                _ = readOnlyToken.Last();

            IsReadOnly = readOnlyToken == "true";

            //initialize model
            await InitializeModelAsync();

            _userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
            CanAddEmployee = !IsReadOnly && _userPermissions.Create;

            Model.IsReadOnly = IsReadOnly;

            await base.OnInitializedAsync();

            _logger = Logger;
        }

        protected override async Task OnParametersSetAsync()
        {
            await ToggleLocationControlReadOnly();

            await base.OnParametersSetAsync();
        }

        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            await InvokeAsync(StateHasChanged);
            Form.EditContext.Validate();
            if (Form.IsValid) Model.ReportDetailsSection.ReportDetailsSectionValidIndicator = true;
            return Model.ReportDetailsSection.ReportDetailsSectionValidIndicator;
        }

        public void Dispose()
        {
        }

        #region Protected Methods and Delegates

        #region Load DropDowns

        public async Task GetOrganizations(LoadDataArgs args)
        {
            try
            {
                if (Organizations is null)
                {
                    OrganizationAdvancedGetRequestModel request = new()
                    {
                        LangID = GetCurrentLanguage(),
                        AccessoryCode = HACodeList.LiveStockAndAvian,
                        AdvancedSearch = null,
                        SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                        RowStatus = Model.idfAggrCase is null ? (int)RowStatusTypeEnum.Active : null,
                    };

                    var organizationList = await OrganizationClient.GetOrganizationAdvancedList(request);

                    Organizations = organizationList.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();
                }

                if (!IsNullOrEmpty(args.Filter))
                    Organizations = Organizations
                        .Where(x => x.FullName.ToLowerInvariant().Contains(args.Filter.ToLowerInvariant())).ToList();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadSentByOfficers(object value)
        {
            EmployeeLookupGetRequestModel request = new();

            try
            {
                long? organizationId = value == null ? null : long.Parse(value.ToString());

                request.LanguageId = GetCurrentLanguage();
                request.AccessoryCode = null;
                //request.AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter;
                request.OrganizationID = organizationId;
                request.SortColumn = "FullName";
                request.SortOrder = SortConstants.Ascending;

                var list = await CrossCuttingClient.GetEmployeeLookupList(request);

                SentByOfficers = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadReceivedByOfficers(object value)
        {
            EmployeeLookupGetRequestModel request = new();

            try
            {
                long? organizationId = value == null ? null : long.Parse(value.ToString());

                request.LanguageId = GetCurrentLanguage();
                request.AccessoryCode = null;
                //request.AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter;
                request.OrganizationID = organizationId;
                request.SortColumn = "FullName";
                request.SortOrder = SortConstants.Ascending;

                var list = await CrossCuttingClient.GetEmployeeLookupList(request);

                ReceivedByOfficers = list.AsODataEnumerable();

                //await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void LoadYearsAsync()
        {
            //List<Select2DataItem> list = new();
            List<Period> list = new();

            try
            {
                //Range of years to be 1900 to current year, descending
                for (var y = DateTime.Today.Year; y >= 1900; y += -1)
                    list.Add(new Period { PeriodNumber = y, PeriodName = y.ToString() });

                Years = list.AsODataEnumerable();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void LoadQuarters()
        {
            List<Period> list = new();

            try
            {
                var year = Model.ReportDetailsSection.Year == null
                    ? DateTime.Today.Year
                    : Parse(Model.ReportDetailsSection.Year.ToString());

                var dt = Common.FillQuarterList(year);
                list.AddRange(from DataRow row in dt.Rows
                              select new Period
                              {
                                  PeriodNumber = Parse(row["PeriodNumber"].ToString()),
                                  PeriodName = row["PeriodName"].ToString()
                              });

                Quarters = list.AsODataEnumerable();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadMonths()
        {
            List<Period> list = new();

            try
            {
                var year = Model.ReportDetailsSection.Year == null
                    ? DateTime.Today.Year
                    : Parse(Model.ReportDetailsSection.Year.ToString());

                var dt = await FillMonthListAsync(year);
                list.AddRange(from DataRow row in dt.Rows
                              select new Period
                              {
                                  PeriodNumber = Parse(row["PeriodNumber"].ToString()),
                                  PeriodName = row["PeriodName"].ToString()
                              });

                Months = list.AsODataEnumerable();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void LoadWeeks()
        {
            List<Period> list = new();

            try
            {
                var year = Model.ReportDetailsSection.Year == null
                    ? DateTime.Today.Year
                    : Parse(Model.ReportDetailsSection.Year.ToString());

                var dt = Common.FillWeekList(year);
                list.AddRange(from DataRow row in dt.Rows
                              select new Period
                              {
                                  PeriodNumber = Parse(row["PeriodNumber"].ToString()),
                                  PeriodName = row["PeriodName"].ToString()
                              });

                Weeks = list.AsODataEnumerable();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            Model.ReportDetailsSection.DetailsLocationViewModel = locationViewModel;
            await GetOrganizationsByAdministrativeLevelIdAsync(locationViewModel);
        }

        protected async Task GetOrganizationsByAdministrativeLevelIdAsync(LocationViewModel model)
        {
            // Get a filtered list of organizations that corresponds to the selected values in “AdminLevel1”, and/or “AdminLevel2”, and /or “AdminLevel3” and/or “AdminLevelX” fields.
            long? administrativeLevelId;

            //Get lowest administrative level.
            if (model.AdminLevel3Value != null)
                administrativeLevelId = IsNullOrEmpty(model.AdminLevel3Value.ToString())
                    ? null
                    : Convert.ToInt64(model.AdminLevel3Value);
            else if (model.AdminLevel2Value != null)
                administrativeLevelId = IsNullOrEmpty(model.AdminLevel2Value.ToString())
                    ? null
                    : Convert.ToInt64(model.AdminLevel2Value);
            else if (model.AdminLevel1Value != null)
                administrativeLevelId = IsNullOrEmpty(model.AdminLevel1Value.ToString())
                    ? null
                    : Convert.ToInt64(model.AdminLevel1Value);
            else
                administrativeLevelId = null;

            var request = new OrganizationGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = MaxValue - 1,
                SortColumn = "AbbreviatedName",
                SortOrder = SortConstants.Ascending,
                AdministrativeLevelID = administrativeLevelId
            };
            var list = await OrganizationClient.GetOrganizationList(request);
            AdministrativeLevelOrganizations = list.AsODataEnumerable();
        }

        protected async Task ReloadPeriods(object value)
        {
            //int year = value == null ? DateTime.Today.Year : int.Parse(value.ToString());
            //Model.ReportDetailsSection.Year = year;
            LoadQuarters();
            await LoadMonths();
            LoadWeeks();
        }

        #endregion Load DropDowns

        #region Save

        [JSInvokable]
        public async Task OnSubmit()
        {
            try
            {
                bool permission;

                if (Model.idfAggrCase > 0)
                {
                    if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite != Convert.ToInt64(authenticatedUser.SiteId) &&
                        authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                        permission = Model.Permissions.Write;
                    else
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateDiseaseReports);
                        permission = permissions.Write;
                    }
                }
                else
                {
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateDiseaseReports);
                        permission = permissions.Create;
                    }
                }

                if (permission)
                {
                    Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation =
                        Model.DiseaseMatrixSection.AggregateCase.idfObservation;
                    await SaveAggregateDiseaseReport(Model);

                    DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Add});
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
        }

        protected async Task SaveAggregateDiseaseReport(AggregateReportDetailsViewModel model)
        {
            try
            {
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate =
                    model.DiseaseMatrixSection.idfsFormTemplate;

                var administrativeUnit = Empty;
                if (await ValidateAggregateDiseaseReportAsync(model.ReportDetailsSection, true) == false)
                {
                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization != null)
                    {
                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel1List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value).Name;

                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel2List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value).Name;

                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel3List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value).Name;

                        var strOrganization = AdministrativeLevelOrganizations.First(x => x.OrganizationKey ==
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization).AbbreviatedName;

                        administrativeUnit += " <" + model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text
                                                   + "/" + model.ReportDetailsSection.DetailsLocationViewModel
                                                       .AdminLevel2Text
                                                   + "/" + model.ReportDetailsSection.DetailsLocationViewModel
                                                       .AdminLevel3Text
                                                   + "/" + strOrganization + ">";
                    }
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value != null)
                    {
                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel1List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value).Name;

                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel2List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value).Name;

                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel3List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value).Name;

                        administrativeUnit += " <" + model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text
                                                   + "/" + model.ReportDetailsSection.DetailsLocationViewModel
                                                       .AdminLevel2Text
                                                   + "/" + model.ReportDetailsSection.DetailsLocationViewModel
                                                       .AdminLevel3Text + ">";
                    }
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value != null)
                    {
                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel1List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value).Name;

                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel2List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value).Name;

                        administrativeUnit += " <" + model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text
                                                   + "/" + model.ReportDetailsSection.DetailsLocationViewModel
                                                       .AdminLevel2Text + ">";
                    }
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value != null)
                    {
                        //administrativeUnit += model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text;
                        if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text is null &&
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value is not null)
                            model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text = model
                                .ReportDetailsSection.DetailsLocationViewModel.AdminLevel1List.First(x =>
                                    x.idfsReference ==
                                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value).Name;

                        administrativeUnit +=
                            " <" + model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text + ">";
                    }

                    var duplicateRecordMessage = Format(
                        Localizer.GetString(MessageResourceKeyConstants
                            .VeterinaryAggregateDiseaseReportDuplicateReportExistsMessage),
                        Convert.ToDateTime(model.ReportDetailsSection.AggregateDiseaseReportDetails.datStartDate)
                            .ToShortDateString(),
                        Convert.ToDateTime(model.ReportDetailsSection.AggregateDiseaseReportDetails.datFinishDate)
                            .ToShortDateString(),
                        administrativeUnit);

                    List<DialogButton> buttons = new();
                    DialogButton yesButton = new()
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                        ButtonType = DialogButtonType.Yes
                    };
                    buttons.Add(yesButton);
                    DialogButton noButton = new()
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                        ButtonType = DialogButtonType.No
                    };
                    buttons.Add(noButton);

                    Dictionary<string, object> dialogParams = new()
                    {
                        { nameof(EIDSSDialog.DialogButtons), buttons },
                        { nameof(EIDSSDialog.Message), Localizer.GetString(duplicateRecordMessage) }
                    };

                    var result = await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                    if (result == null)
                        return;

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            DiagService.Close(result);
                            NavManager.NavigateTo(
                                $"Veterinary/VeterinaryAggregateDiseasesReport/Details/{model.ReportDetailsSection.idfAggrCaseDuplicateReport}",
                                true);
                        }
                }
                else
                {
                    model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite ??=
                        Convert.ToInt64(authenticatedUser.SiteId);
                    model.PendingSaveEvents ??= new List<EventSaveRequestModel>();

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase is null)
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite
                            ? SystemEventLogTypes.NewVeterinaryAggregateDiseaseReportWasCreatedAtYourSite
                            : SystemEventLogTypes.NewVeterinaryAggregateDiseaseReportWasCreatedAtAnotherSite;
                        model.PendingSaveEvents.Add(await CreateEvent(0,
                                null, eventTypeId,
                                (long)model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite, null)
                            .ConfigureAwait(false));
                    }
                    else
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite
                            ? SystemEventLogTypes.VeterinaryAggregateDiseaseReportWasChangedAtYourSite
                            : SystemEventLogTypes.VeterinaryAggregateDiseaseReportWasChangedAtAnotherSite;
                        model.PendingSaveEvents.Add(await CreateEvent(0,
                                null, eventTypeId,
                                (long)model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite, null)
                            .ConfigureAwait(false));
                    }

                    var request = new AggregateReportSaveRequestModel
                    {
                        AggregateReportID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase,
                        EIDSSAggregateReportID = model.ReportDetailsSection.AggregateDiseaseReportDetails.strCaseID,
                        AggregateReportTypeID =
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAggrCaseType,
                        ReceivedByOrganizationID =
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByOffice,
                        ReceivedByPersonID =
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByPerson,
                        ReceivedByDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datReceivedByDate,
                        SentByOrganizationID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice,
                        SentByPersonID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByPerson,
                        SentByDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datSentByDate,
                        EnteredByOrganizationID =
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByOffice,
                        EnteredByPersonID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByPerson,
                        EnteredByDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datEnteredByDate,
                        StartDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datStartDate,
                        FinishDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datFinishDate,
                        SiteID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite ??
                                 Convert.ToInt64(authenticatedUser.SiteId),
                        GeographicalAdministrativeUnitID = model.ReportDetailsSection.AggregateDiseaseReportDetails
                            .idfsAdministrativeUnit,
                        OrganizationalAdministrativeUnitID =
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization,
                        CaseVersion = model.DiseaseMatrixSection.idfVersion,
                        CaseObservationID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation,
                        CaseObservationFormTemplateID = model.DiseaseMatrixSection.idfsFormTemplate,
                        User = authenticatedUser.UserName,
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        Events = JsonConvert.SerializeObject(model.PendingSaveEvents)
                    };

                    var response = await AggregateReportClient.SaveAggregateReport(request, _token);

                    if (response.ReturnCode == 0)
                    {
                        dynamic result;

                        if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase is null)
                        {
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase =
                                response.AggregateReportID;
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.strCaseID =
                                response.EIDSSAggregateReportID;

                            var message = Format(
                                Localizer.GetString(MessageResourceKeyConstants
                                    .VeterinaryAggregateActionsReportSuccessfullySavedTheEIDSSIDIsMessage) + ".",
                                response.EIDSSAggregateReportID);

                            result = await ShowSuccessDialog(null, message, null,
                                ButtonResourceKeyConstants.ReturnToDashboardButton,
                                ButtonResourceKeyConstants
                                    .HumanAggregateDiseaseReportReturnToAggregateDiseaseReportButton);
                        }
                        else
                        {
                            result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                                null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                                ButtonResourceKeyConstants
                                    .HumanAggregateDiseaseReportReturnToAggregateDiseaseReportButton);
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

                                var path = "Veterinary/VeterinaryAggregateDiseasesReport/Details";
                                var query = $"?id={response.AggregateReportID}&isReadOnly=true";
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
            finally
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            //return int.MinValue;
        }

        private async Task<bool> ValidateAggregateDiseaseReportAsync(ReportDetailsSectionViewModel model,
            bool saveObservationIDIndicator)
        {
            var periodEnteredIndicator = false;
            var period = (long)model.AggregateDiseaseReportDetails.idfsPeriodType;
            var administrativeUnitEnteredIndicator = false;
            var administrativeUnit = (long)model.AggregateDiseaseReportDetails.idfsAreaType;
            DateTime sDate = new();
            DateTime eDate = new();

            switch (period)
            {
                case (long)TimePeriodTypes.Day:
                    if (model.Day != null)
                    {
                        periodEnteredIndicator = true;
                        sDate = Convert.ToDateTime(model.Day);
                        eDate = Convert.ToDateTime(model.Day);
                    }

                    break;

                case (long)TimePeriodTypes.Month:
                    if ((model.Year != null) & (model.Month != null))
                    {
                        periodEnteredIndicator = true;
                        sDate = new DateTime(Convert.ToInt16(model.Year.ToString()), (int)model.Month, 1);
                        eDate = sDate.AddMonths(1).AddDays(-1);
                    }

                    break;

                case (long)TimePeriodTypes.Quarter:
                    if ((model.Year != null) & (model.Quarter != null))
                    {
                        periodEnteredIndicator = true;
                        var dRange = Common.GetQuarterText((int)model.Quarter, (int)model.Year).Split("-");

                        if (dRange.Length == 3)
                        {
                            sDate = Convert.ToDateTime(dRange[1].Trim());
                            eDate = Convert.ToDateTime(dRange[2].Trim());
                        }
                        else
                        {
                            if (dRange[0].Contains("–"))
                            {
                                var list = dRange[0].Split("–");
                                sDate = Convert.ToDateTime(list[1].Trim());
                            }

                            //sDate = Convert.ToDateTime(dRange[0].Trim());
                            eDate = Convert.ToDateTime(dRange[1].Trim());
                        }
                    }

                    break;

                case (long)TimePeriodTypes.Week:
                    if ((model.Year != null) & (model.Week != null))
                    {
                        periodEnteredIndicator = true;
                        Common.GetFirstAndLastDateOfWeek((int)model.Year, (int)model.Week, GetCurrentLanguage(),
                            ref sDate, ref eDate);
                    }

                    break;

                case (long)TimePeriodTypes.Year:
                    if (model.Year != null)
                    {
                        periodEnteredIndicator = true;
                        sDate = new DateTime(Convert.ToInt16(model.Year.ToString()), 1, 1);
                        eDate = sDate.AddYears(1).AddDays(-1);
                    }

                    break;
            }

            model.AggregateDiseaseReportDetails.datStartDate = sDate;
            model.AggregateDiseaseReportDetails.datFinishDate = eDate;

            switch (administrativeUnit)
            {
                case (long)AdministrativeUnitTypes.Settlement:
                    if (model.DetailsLocationViewModel.AdminLevel3Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit =
                            model.DetailsLocationViewModel.AdminLevel3Value;
                    }

                    break;

                case (long)AdministrativeUnitTypes.Rayon:
                    if (model.DetailsLocationViewModel.AdminLevel2Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit =
                            model.DetailsLocationViewModel.AdminLevel2Value;
                    }

                    break;

                case (long)AdministrativeUnitTypes.Region:
                    if (model.DetailsLocationViewModel.AdminLevel1Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit =
                            model.DetailsLocationViewModel.AdminLevel1Value;
                    }

                    break;

                case (long)AdministrativeUnitTypes.Country:
                    if (model.DetailsLocationViewModel.AdminLevel0Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit =
                            model.DetailsLocationViewModel.AdminLevel0Value;
                    }

                    break;

                default:
                    administrativeUnitEnteredIndicator = true;
                    model.AggregateDiseaseReportDetails.idfsAdministrativeUnit =
                        model.DetailsLocationViewModel.AdminLevel3Value;
                    break;
            }

            if (!(periodEnteredIndicator & administrativeUnitEnteredIndicator)) return true;
            var administrativeUnitId = (long?)null;

            if (model.AggregateDiseaseReportDetails.idfsAdministrativeUnit != null)
                administrativeUnitId = model.AggregateDiseaseReportDetails.idfsAdministrativeUnit;
            else if (model.AggregateDiseaseReportDetails.Organization != null)
                administrativeUnitId = model.AggregateDiseaseReportDetails.Organization;

            AggregateReportSearchRequestModel request = new()
            {
                LanguageId = GetCurrentLanguage(),
                AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport),
                Page = 1,
                PageSize = 10,
                SortColumn = "ReportID",
                SortOrder = SortConstants.Descending,
                TimeIntervalTypeID = period,
                AdministrativeUnitTypeID = administrativeUnit,
                AdministrativeUnitID = administrativeUnitId,
                OrganizationID = model.AggregateDiseaseReportDetails.Organization != null
                    ? model.AggregateDiseaseReportDetails.Organization
                    : null,
                StartDate = model.AggregateDiseaseReportDetails.datStartDate,
                EndDate = model.AggregateDiseaseReportDetails.datFinishDate
            };
            var duplicateList = await AggregateReportClient.GetAggregateReportList(request, _token);

            if (model.AggregateDiseaseReportDetails.idfAggrCase == null && duplicateList.Count > 0)
            {
                model.idfAggrCaseDuplicateReport = duplicateList.FirstOrDefault().ReportKey;
                return false;
            }

            if (!duplicateList.Any(x => x.ReportKey != (long)model.AggregateDiseaseReportDetails.idfAggrCase))
                return true;
            model.idfAggrCaseDuplicateReport = duplicateList.FirstOrDefault().ReportKey;
            return false;
        }

        #endregion Save

        #region Delete

        [JSInvokable]
        public async Task OnDelete()
        {
            var id = Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase;
            //NavManager.NavigateTo($"Veterinary/VeterinaryAggregateDiseasesReport/Delete/{id}", true);

            if (id != null)
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
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
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close(result);
                        await Delete(id);
                    }
            }
        }

        protected async Task Delete(long? id)
        {
            bool permission;
            if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite != Convert.ToInt64(authenticatedUser.SiteId) &&
                authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                permission = Model.Permissions.Delete;
            else
            {
                var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateDiseaseReports);
                permission = permissions.Delete;
            }

            if (permission)
            {
                if (id != null)
                {
                    var response =
                        await AggregateReportClient.DeleteAggregateReport((long) id,
                            authenticatedUser.UserName);
                    if (response.ReturnCode == 0)
                    {
                        List<DialogButton> buttons = new();
                        DialogButton okButton = new()
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                            ButtonType = DialogButtonType.OK
                        };
                        buttons.Add(okButton);

                        Dictionary<string, object> dialogParams = new()
                        {
                            {nameof(EIDSSDialog.DialogButtons), buttons},
                            {
                                nameof(EIDSSDialog.Message),
                                Localizer.GetString(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage)
                            }
                        };
                        await DiagService.OpenAsync<EIDSSDialog>(
                            Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
                        NavManager.NavigateTo("Veterinary/VeterinaryAggregateDiseasesReport", true);
                    }
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

        #endregion Delete

        #region Print

        [JSInvokable("OnPrint")]
        public async Task OnPrint()
        {
            try
            {
                if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase != null)
                {
                    _source = new CancellationTokenSource();
                    _token = _source.Token;

                    string fullName =
                        $"{authenticatedUser.FirstName} {authenticatedUser.SecondName} {authenticatedUser.LastName}";

                    ReportViewModel reportModel = new();

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("SiteID", authenticatedUser.SiteId);

                    reportModel.AddParameter("idfsAggrCaseType",
                        ((long)FlexibleFormTypes.VeterinaryAggregate).ToString());
                    reportModel.AddParameter("idfAggrCaseList",
                        Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants
                            .VeterinaryAggregateDiseaseReportPageHeading),
                        new Dictionary<string, object>
                        {
                            {"ReportName", "VeterinaryAggregateDiseaseReport"}, {"Parameters", reportModel.Parameters}
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

        #endregion Print

        #region Cancel

        [JSInvokable]
        public async Task OnCancel()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>
                {
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage)
                    }
                };
                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                var dialogResult = result as DialogReturnResult;
                if (dialogResult?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel changes and user said yes
                    _source?.Cancel();
                    NavManager.NavigateTo("Veterinary/VeterinaryAggregateDiseasesReport", true);
                }
                else
                {
                    //cancel changes but user said no so leave everything alone and cancel thread
                    _source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion Cancel

        #region Add Employee

        protected async Task OpenEmployeeAddModal(long? id)
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                {
                    if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice != null &&
                        Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice == id)
                        await LoadSentByOfficers(Model.ReportDetailsSection.AggregateDiseaseReportDetails
                            .idfSentByOffice);

                    if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByOffice != null &&
                        Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByOffice == id)
                        await LoadReceivedByOfficers(Model.ReportDetailsSection.AggregateDiseaseReportDetails
                            .idfReceivedByOffice);

                    return;
                }

                if (((EditContext)result).Validate())
                {
                    //SaveNonUserEmployee(result);
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task<EmployeeSaveRequestResponseModel> SaveNonUserEmployee(EditContext result)
        {
            var response = new EmployeeSaveRequestResponseModel();

            var employeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            var obj = (EmployeePersonalInfoPageViewModel)result.Model;
            employeePersonalInfoSaveRequest.strPersonalID = obj.PersonalID;
            employeePersonalInfoSaveRequest.idfPersonalIDType = obj.PersonalIDType.ToString();
            employeePersonalInfoSaveRequest.strFirstName = obj.FirstOrGivenName;
            employeePersonalInfoSaveRequest.strSecondName = obj.SecondName;
            employeePersonalInfoSaveRequest.strFamilyName = obj.LastOrSurName;
            employeePersonalInfoSaveRequest.strContactPhone = obj.ContactPhone;
            employeePersonalInfoSaveRequest.idfInstitution = obj.OrganizationID;
            employeePersonalInfoSaveRequest.idfsSite = obj.SiteID;
            employeePersonalInfoSaveRequest.idfsStaffPosition = obj.PositionTypeID;
            employeePersonalInfoSaveRequest.idfDepartment = obj.DepartmentID;

            employeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;

            var duplicateCheckRequest = new EmployeeGetListRequestModel
            {
                FirstOrGivenName = employeePersonalInfoSaveRequest.strFirstName,
                LanguageId = GetCurrentLanguage(),
                LastOrSurName = employeePersonalInfoSaveRequest.strFamilyName,
                PersonalIdType =
                    employeePersonalInfoSaveRequest.idfPersonalIDType != null &&
                    employeePersonalInfoSaveRequest.idfPersonalIDType != Empty
                        ? long.Parse(employeePersonalInfoSaveRequest.idfPersonalIDType)
                        : null,
                PersonalIDValue = employeePersonalInfoSaveRequest.strPersonalID,
                OrganizationID = employeePersonalInfoSaveRequest.idfInstitution,
                Page = 1,
                PageSize = 10,
                SortOrder = SortConstants.Ascending,
                SortColumn = "EmployeeID"
            };

            var duplicateResponse = await EmployeeClient.GetEmployeeList(duplicateCheckRequest);
            if (duplicateResponse is { Count: > 0 })
            {
                employeePersonalInfoSaveRequest.idfPerson = duplicateResponse.FirstOrDefault()?.EmployeeID;
                response.RetunMessage = "DOES EXIST";
                var duplicateField = !IsNullOrEmpty(duplicateResponse.FirstOrDefault()?.LastOrSurName)
                    ? duplicateResponse.FirstOrDefault()?.LastOrSurName
                    : "";
                duplicateField += !IsNullOrEmpty(duplicateResponse.FirstOrDefault()?.FirstOrGivenName)
                    ? " " + duplicateResponse.FirstOrDefault()?.FirstOrGivenName
                    : "";
                duplicateField +=
                    duplicateResponse.FirstOrDefault()?.OrganizationID != null &&
                    duplicateResponse.FirstOrDefault()?.OrganizationID != 0
                        ? " " + duplicateResponse.FirstOrDefault()?.OrganizationAbbreviatedName
                        : "";
                duplicateField += !IsNullOrEmpty(employeePersonalInfoSaveRequest.idfPersonalIDType)
                    ? " " + employeePersonalInfoSaveRequest.idfPersonalIDTypeText
                    : "";
                duplicateField += !IsNullOrEmpty(employeePersonalInfoSaveRequest.strPersonalID)
                    ? " " + employeePersonalInfoSaveRequest.strPersonalID
                    : "";
                response.DuplicateMessage =
                    Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), duplicateField);
            }
            else
            {
                response = await EmployeeClient.SaveEmployee(employeePersonalInfoSaveRequest);
                if (response.ReturnCode != 0) return response;
                await LoadSentByOfficers(Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice);
                await LoadReceivedByOfficers(Model.ReportDetailsSection.AggregateDiseaseReportDetails
                    .idfReceivedByOffice);
            }

            return response;
        }

        #endregion Add Employee

        #endregion Protected Methods and Delegates

        #region Common functions

        public async Task<DataTable> FillMonthListAsync(int year)
        {
            DataTable mMonthList;
            try
            {
                var monthNamesList = await CrossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());

                mMonthList = Common.CreatePeriodTable();

                var intMonth = 1;
                var monthDict = new Dictionary<int, string>();

                for (var index = 0; index <= monthNamesList.Count - 1; index++)
                    monthDict.Add(Parse(monthNamesList[index].idfsReference.ToString()),
                        monthNamesList[index].strTextString);

                foreach (var item in monthDict.Keys)
                {
                    Common.AddMonthRow(mMonthList, year, intMonth, monthDict[item]);
                    intMonth += 1;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return mMonthList;
        }

        #endregion

        #region Private Methods

        private async Task InitializeModelAsync()
        {
            Model.lstSentToOrganizations = new List<OrganizationAdvancedGetListViewModel>();
            Model.lstRecvByOrganizations = new List<OrganizationAdvancedGetListViewModel>();

            if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice != null)
                await LoadSentByOfficers(Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice);

            if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByOffice != null)
                await LoadReceivedByOfficers(Model.ReportDetailsSection.AggregateDiseaseReportDetails
                    .idfReceivedByOffice);

            if (Model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization != null)
                await GetOrganizationsByAdministrativeLevelIdAsync(Model.ReportDetailsSection.DetailsLocationViewModel);

            var userPreferences =
                ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
        }

        private async Task ToggleLocationControlReadOnly()
        {
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableAdminLevel1 = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableAdminLevel2 = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableAdminLevel3 = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableAdminLevel4 = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableAdminLevel5 = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableAdminLevel6 = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableSettlement = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.EnableSettlementType = !IsReadOnly;
            Model.ReportDetailsSection.DetailsLocationViewModel.OperationType =
                IsReadOnly ? LocationViewOperationType.ReadOnly : null;

            await InvokeAsync(StateHasChanged);
        }

        #endregion Private Methods

        #region Set ReportDisabledIndicator

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("SetReportDisabledIndicator")]
        public async Task SetReportDisabledIndicator(int currentIndex)
        {
            if (currentIndex == 2) //review section
            {
                IsReadOnly = true;
                Model.IsReadOnly = true;
            }
            else
            {
                if ((Model.idfAggrCase <= 0 &&
                     !Model.Permissions.Create)
                    || (Model.idfAggrCase > 0 &&
                        !Model.Permissions.Write))
                {
                    IsReadOnly = true;
                    Model.IsReadOnly = true;
                }
                else
                {
                    IsReadOnly = false;
                    Model.IsReadOnly = false;
                }
            }

            await ToggleLocationControlReadOnly();
        }

        #endregion Set ReportDisabledIndicators
    }
}