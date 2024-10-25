#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Components.Shared;
using Period = EIDSS.Web.Helpers.Period;

#endregion

namespace EIDSS.Web.Components.Human.WeeklyReporting
{
    public class WeeklyReportingFormBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        public ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<WeeklyReportingFormBase> Logger { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private IEmployeeClient EmployeeClient { get; set; }

        [Inject]
        private IWeeklyReportingFormClient WeeklyReportingFormClient { get; set; }

        [Inject]
        private ProtectedSessionStorage ProtectedSessionStore { get; set; }

        [Inject]
        private ITokenService TokenService { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public long? SessionID { get; set; }

        [Parameter]
        public bool IsReadOnly { get; set; }

        [Parameter]
        public int? Year { get; set; }

        [Parameter]
        public string Week { get; set; }

        [Parameter]
        public string DatSentByDate { get; set; }

        [Parameter]
        public string IdfSentByOffice { get; set; }

        public bool DisplayReport { get; set; }

        #endregion Parameters

        #region Member Variables

        protected RadzenTemplateForm<WeeklyReportComponentViewModel> Form;

        protected WeeklyReportComponentViewModel Model;
        public IEnumerable<OrganizationAdvancedGetListViewModel> SentToOrganizations;

        protected IEnumerable<OrganizationGetListViewModel> ReceivedByOffices;
        protected IEnumerable<EmployeeListViewModel> SentByOfficers;

        protected IEnumerable<Period> Years;
        protected IEnumerable<Period> Weeks;

        protected IEnumerable<ReportYearModel> ReportYears;
        protected IEnumerable<ReportMonthNameModel> ReportMonths;

        protected WeeklyReportSaveResponseModel ReportResponseModel;

        private CancellationTokenSource _source;

        protected WeeklyReportSaveRequestModel SaveRequestModel;
        protected WeeklyReportSaveResponseModel SaveResponseModel;
        protected APIPostResponseModel DeleteResponseModel;

        protected WeeklyReportingFormGetRequestModel GetRequestModel;
        protected List<ReportFormViewModel> ReportFormViewModelList;

        protected WeeklyReportingFormGetDetailRequestModel DetailRequestModel;
        protected ReportFormDetailViewModel ReportDetailViewModel;

        protected bool CanAddEmployee { get; set; }
        protected int Count;
        protected bool shouldRender = true;

        protected bool IsLoading;

        // start off disabled
        protected bool DisableDeleteButton = true;

        protected bool DisablePrintButton = true;

        protected int CollectedByInstitutionCount { get; set; }

        protected string StrFirstName { get; set; }

        #endregion MemberVariables

        #region Properties

        protected LocationView Location { get; set; }

        #endregion Properties

        #endregion Globals

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            IsLoading = true;

            _logger = Logger;

            // get the navigation uri and see if we are an Edit
            var uri = NavManager.Uri; //.NavigateTo($"Human/WeeklyReportingForm", true);

            InitializeModel();

            // we have to do this originally otherwise our resource string will throw exceptions
            await LoadWeeks();

            // Note: SessionID parameter is passed in on edit,
            // otherwise it is null for add
            if (SessionID != null)
            {
                Model.SessionKey = SessionID.Value;
                // load up our WeeklyReportComponentViewModel
                await GetWeeklyReportDetails();
            }

            //reset the cancellation token
            _source = new CancellationTokenSource();

            Model.ReportFormPermissions = GetUserPermissions(PagePermission.HumanWeeklyReport);

            // enable/disable buttons
            SetButtonStates();

            Model.IsReadonly = IsReadOnly;

            if (!Model.IsReadonly)
            {
                CanAddEmployee = true;
            }

            // if we are an add, and preferences are set, then set the default
            if (SessionID == null)
            {
                await SetRegionRayonDefaultsAsync(Model);
                await Location.RefreshComponent(Model.ReportFormLocationModel);
            }

            IsLoading = false;

            await base.OnInitializedAsync();
        }

        private async Task SetRegionRayonDefaultsAsync(WeeklyReportComponentViewModel model)
        {
            try
            {
                var langId = model.GetCurrentLanguage();
                var siteId = Convert.ToInt64(model.UserSiteID);
                var eidssUserId = Convert.ToInt64(model.EIDSS_UuserID);

                model.UserOrganizationID = authenticatedUser.OfficeId;

                var siteDetails = await SiteClient.GetSiteDetails(langId, siteId, eidssUserId);
                // site org name
                model.strSentByOffice = siteDetails.SiteOrganizationName;

                model.strEnteredByOffice = siteDetails.SiteName;
                
                var strTempDate = DateTime.Today.ToShortDateString();

                model.strDateEnteredBy = strTempDate;

                // get the user first and last name
                var personId = Convert.ToInt64(siteDetails.PersonID);
                model.idfEnteredByPerson = personId;
                await GetEnteredByOfficer(personId);

                model.strEnteredByPerson = $"{model.EmployeeDetail.strFirstName} {model.EmployeeDetail.strFamilyName}";

                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

                model.ReportFormLocationModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;
                model.ReportFormLocationModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task GetWeeklyReportDetails()
        {
            if (SessionID != 0)
            {
                const bool fromGetWeeklyReportDetails = true;

                ReportDetailViewModel = new ReportFormDetailViewModel();
                // load our request model
                DetailRequestModel = new WeeklyReportingFormGetDetailRequestModel
                {
                    LangID = GetCurrentLanguage(),
                    idfsReportFormType = (long?)ReportFormTypes.HumanWeeklyReportForm,
                    idfReportForm = SessionID
                };

                var response = await WeeklyReportingFormClient.GetWeeklyReportingFormDetail(DetailRequestModel);

                if (response != null)
                {
                    ReportDetailViewModel = response.FirstOrDefault();
                    if (ReportDetailViewModel != null)
                    {
                        try
                        {
                            // Update the Model properties
                            Model.AdministrativeUnitTypeID = ReportDetailViewModel.idfsAdministrativeUnit;
                            Model.AdminLevel0Value = ReportDetailViewModel.AdminLevel0;
                            Model.AdminLevel1Value = ReportDetailViewModel.AdminLevel1;
                            Model.AdminLevel2Value = ReportDetailViewModel.AdminLevel2;
                            Model.strAdminLevel3 = ReportDetailViewModel.SettlementName;
                            Model.idfsSettlement = ReportDetailViewModel.idfsSettlement;

                            Model.strComments = ReportDetailViewModel.Comments;
                            Model.DiseaseName = ReportDetailViewModel.diseaseName;
                            Model.strDateEnteredBy = ReportDetailViewModel.datEnteredByDate;

                            // these hold the values for the current record months and year
                            // we need to make sure that we are populating the dropdowns based on this
                            Model.strEndDate = ReportDetailViewModel.datFinishDate;
                            Model.strStartDate = ReportDetailViewModel.datStartDate;

                            string[] formats = { CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern };
                            DateTime.TryParseExact(ReportDetailViewModel.datStartDate, formats,
                                CultureInfo.CurrentCulture,
                                DateTimeStyles.None, out var outDate);
                            Model.datSentByDate = outDate;

                            Model.datStartDate = outDate;

                            Model.EnteredInstitution = ReportDetailViewModel.idfEnteredByOffice;
                            Model.idfEnteredByPerson = ReportDetailViewModel.idfEnteredByPerson;
                            Model.idfReportForm = ReportDetailViewModel.idfReportForm;
                            Model.idfSentByOffice = ReportDetailViewModel.idfSentByOffice;
                            Model.idfSentByPerson = ReportDetailViewModel.idfSentByPerson;
                            // get the entered by date
                            if (ReportDetailViewModel.datEnteredByDate != null)
                            {
                                DateTime.TryParseExact(ReportDetailViewModel.datEnteredByDate, formats,
                                    CultureInfo.CurrentCulture,
                                    DateTimeStyles.None, out outDate);
                                Model.datEnteredByDate = outDate;
                            }
                            else
                            {
                                Model.datEnteredByDate = null;
                            }
                            // get the sent by date
                            if (ReportDetailViewModel.datSentByDate != null)
                            {
                                DateTime.TryParseExact(ReportDetailViewModel.datSentByDate, formats,
                                    CultureInfo.CurrentCulture,
                                    DateTimeStyles.None, out outDate);
                                Model.datSentByDate = outDate;
                            }
                            else
                            {
                                Model.datSentByDate = null;
                            }
                            Model.DiseaseID = ReportDetailViewModel.idfsDiagnosis;
                            Model.idfsReportFormType = ReportDetailViewModel.idfsReportFormType;
                            Model.strReportFormID = ReportDetailViewModel.strReportFormID;
                            //Model.strSentByOffice = ReportDetailViewModel.strSentByOffice;
                            Model.strEnteredByOffice = ReportDetailViewModel.strEnteredByOffice;
                            //Model.strSentByPerson = ReportDetailViewModel.strSentByPerson;
                            // get the user first and last name
                            // idfEnteredByPersonID
                            var personId = ReportDetailViewModel.idfEnteredByPerson;
                            await GetEnteredByOfficer(personId);
                            Model.strEnteredByPerson = $"{Model.EmployeeDetail.strFirstName} {Model.EmployeeDetail.strFamilyName}";
                            Model.Total = ReportDetailViewModel.Total;
                            Model.AmongNotified = ReportDetailViewModel.Notified;
                            // try to load the office
                            Model.idfSentByOffice = ReportDetailViewModel.idfSentByOffice;

                            // the models location ReportFormLocationModel needs to be updated with the AdminLevels
                            if (ReportDetailViewModel.AdminLevel1 != null)
                                Model.ReportFormLocationModel.AdminLevel1Value =
                                    ReportDetailViewModel.AdminLevel1.Value;
                            if (ReportDetailViewModel.AdminLevel2 != null)
                                Model.ReportFormLocationModel.AdminLevel2Value =
                                    ReportDetailViewModel.AdminLevel2.Value;
                            if (ReportDetailViewModel.idfsSettlement != null)
                                Model.ReportFormLocationModel.AdminLevel3Value =
                                    ReportDetailViewModel.idfsSettlement.Value;

                            await Location.RefreshComponent(Model.ReportFormLocationModel);

                            // now set our Weeks dropdown to the saved value
                            await ResetWeeksDropdown(fromGetWeeklyReportDetails);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex.Message, null);
                            throw;
                        }
                    }
                }

                await InvokeAsync(StateHasChanged);
            }
        }

        private async Task ResetWeeksDropdown(bool fromGetWeeklyReportDetails = false)
        {
            var finishDate = string.Empty;

            try
            {
                // if our flag is set we need to get the year and month from the start and finish dates
                if (fromGetWeeklyReportDetails)
                {
                    finishDate = Model.strEndDate;

                    var reportYearArray = finishDate.Split('/');
                    var reportYear = reportYearArray[2];
                    // set the year
                    Model.CurrentYear = Convert.ToInt32(reportYear);
                    // store the year
                    Year = Model.CurrentYear;
                    Model.Year = Year;
                    // now that we have the year go back and reload the weeks
                    await LoadWeeks();

                    // the Week will become the Model.CurrentWeek in the change event handler
                    Model.Week = Week;
                }

                if (finishDate == "")
                {
                    finishDate = Model.strEndDate;
                }

                // count of elements
                var nCnt = 0;

                // now find the current week and set our Weeks to it
                // the Start Date and FinishDate strStartDate (StartDate) and strEndDate (FinishDate)
                // have the "Week" dropdown values
                foreach (var item in Weeks)
                {
                    // get the period name and parse the dates
                    // split on the dash, and get rid of spaces
                    var periodWeek = item.PeriodName.Split('-');
                    var periodEnd = periodWeek[2][1..];

                    DateTime.TryParse(periodEnd, out var tempPeriodDateEnd);
                    DateTime.TryParse(finishDate, out var tempModeDateEnd);

                    // get the value
                    if (tempPeriodDateEnd == tempModeDateEnd)
                    {
                        // the Week will become the Model.CurrentWeek in the change event handler
                        Week = Weeks.ElementAt(nCnt).PeriodName;
                        Model.Week = Week;

                        // store the year
                        Year = Model.CurrentYear;

                        // force these to update the form so our validation
                        // will pass in case the user goes with the auto-populated values
                        await WeekIdTypeChangedAsync(Week);
                        await UpdateYearIdTypeChangedAsync(Year);

                        // and get out
                        break;
                    }

                    // bump the count
                    nCnt++;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private void InitializeModel()
        {
            // get the default admin levels
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            long? eidssUserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
            long? userEmployeeId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
            long? userOrganizationId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
            long? userSiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
            _ = TokenService.GetAuthenticatedUser().Adminlevel1;
            _ = TokenService.GetAuthenticatedUser().Adminlevel2;
            var regionSetting = userPreferences.DefaultRegionInSearchPanels;
            var rayonSetting = userPreferences.DefaultRayonInSearchPanels;

            Model = new WeeklyReportComponentViewModel
            {
                UserEmployeeID = userEmployeeId,
                UserOrganizationID = userOrganizationId,
                UserSiteID = userSiteId,
                EIDSS_UuserID = eidssUserId,
                DefaultRegionShown = regionSetting,
                DefaultRayonShown = rayonSetting
            };

            if (IsReadOnly)
            {
                LoadReadOnlyModel(userPreferences, Model);
            }
            else
            {
                LoadEditModel(userPreferences, Model);
            }
        }

        private void LoadReadOnlyModel(UserPreferences userPreferences, WeeklyReportComponentViewModel model)
        {
            model.ReportFormLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnabledLatitude = true,
                EnabledLongitude = true,
                EnablePostalCode = false,
                EnableSettlement = false,
                EnableSettlementType = false,
                EnableStreet = false,
                OperationType = LocationViewOperationType.Edit,
                ShowAdminLevel0 = true,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlementType = false,
                ShowStreet = false,
                ShowBuilding = false,
                ShowApartment = false,
                ShowElevation = false,
                ShowHouse = false,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = false,
                ShowPostalCode = false,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredAdminLevel3 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().Adminlevel2 : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().Adminlevel3 : null,
            };
        }

        private void LoadEditModel(UserPreferences userPreferences, WeeklyReportComponentViewModel model)
        {
            // our Location Model
            model.ReportFormLocationModel = new LocationViewModel
            {
                CallingObjectID = "WeeklyReportingForm_",
                IsHorizontalLayout = true,
                ShowAdminLevel0 = true,
                EnableAdminLevel0 = false,
                ShowAdminLevel1 = true,
                EnableAdminLevel1 = true,
                ShowAdminLevel2 = true,
                EnableAdminLevel2 = true,
                ShowAdminLevel3 = true,
                EnableAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlement = true,
                ShowSettlementType = true,
                ShowStreet = false,
                ShowBuilding = false,
                ShowApartment = false,
                ShowElevation = false,
                ShowHouse = false,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = false,
                ShowPostalCode = false,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredAdminLevel3 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().Adminlevel2 : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().Adminlevel3 : null,
            };
        }

        protected override void OnAfterRender(bool firstRender)
        {
            if (!firstRender) return;
            authenticatedUser = _tokenService.GetAuthenticatedUser();

            Model.ReportFormPermissions = GetUserPermissions(PagePermission.HumanWeeklyReport);
        }

        protected void LocationChanged(LocationViewModel locationViewModel)
        {
            //Get lowest administrative level for location
            if (locationViewModel.AdminLevel3Value.HasValue)
            {
                Model.idfsLocation = locationViewModel.AdminLevel3Value.Value;
                Model.AdministrativeUnitTypeID = locationViewModel.AdminLevel3Value.Value;
                Model.AdminLevel0Value = locationViewModel.AdminLevel3Value.Value;
            }
            else if (locationViewModel.AdminLevel2Value.HasValue)
            {
                Model.idfsLocation = locationViewModel.AdminLevel2Value.Value;
                Model.AdminLevel2Value = locationViewModel.AdminLevel2Value.Value;
            }
            else if (locationViewModel.AdminLevel1Value.HasValue)
            {
                Model.idfsLocation = locationViewModel.AdminLevel1Value.Value;
                Model.AdminLevel1Value = locationViewModel.AdminLevel1Value.Value;
            }
            else
                Model.idfsLocation = null;
        }

        protected async Task HandleValidSubmit(WeeklyReportComponentViewModel model)
        {
            if (Form.IsValid)
            {
                if (model.Year == null)
                {
                }

                Week = model.Week ?? model.CurrentWeek;

                if (Form.IsValid)
                {
                    if (Form.EditContext.IsModified())
                    {
                    }
                    else
                    {
                        //no search criteria entered - display the EIDSS dialog component
                        //searchSubmitted = false;
                        //await ShowNoSearchCriteriaDialog();
                    }
                }

                try
                {
                    Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                    Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

                    await InvokeAsync(StateHasChanged);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        public async Task GetYearNameQueryAsync(LoadDataArgs args)
        {
            ReportYears = await CrossCuttingClient.GetReportYearList();
            // load as a startup value
            Year = Model.CurrentYear;
            await InvokeAsync(StateHasChanged);
        }

        public async Task GetWeekNameQueryAsync(LoadDataArgs args)
        {
            // get our list of string Weeks
            await LoadWeeks();

            await InvokeAsync(StateHasChanged);
        }

        public async Task LoadWeeks(bool fromGetWeeklyReportDetails = false)
        {
            List<Period> list = new();
            var nCnt = 1;

            try
            {
                var year = Model.Year == null ? DateTime.Today.Year : int.Parse(Model.Year.ToString());
                var currentYear = DateTime.Now.Year;

                var dt = Common.FillWeekList(year);
                foreach (DataRow row in dt.Rows)
                {
                    list.Add(new Period { PeriodNumber = int.Parse(row["PeriodNumber"].ToString() ?? string.Empty), PeriodName = row["PeriodName"].ToString() });
                }

                Weeks = list.AsODataEnumerable();

                // reformat the weeks with e.g.( 1- 01/01/1900 )
                foreach (var item in Weeks)
                {
                    item.PeriodName = $"{nCnt}- {item.PeriodName}";
                    nCnt++;
                }

                //foreach (var item in weeks)
                if (Weeks != null)
                {
                    // if we are not the current year then we have to start in January 1
                    if (year != currentYear)
                    {
                        if (Weeks.FirstOrDefault() != null)
                        {
                            Model.CurrentWeek = Weeks.FirstOrDefault()?.PeriodName;
                            Week = Model.CurrentWeek;
                        }
                    }
                    // the first time thru we should not have a value,
                    // so get the last week, amd make that the current week
                    else if (Weeks.LastOrDefault() != null && Model.CurrentWeek == null)
                    {
                        Model.CurrentWeek = Weeks.LastOrDefault()?.PeriodName;
                        Week = Model.CurrentWeek;
                    }

                    // If we are Initializing (Loading), then make the current week the last week.
                    if (IsLoading)
                    {
                        ParseWeeks(Model.CurrentWeek);

                        Week = Weeks.LastOrDefault()?.PeriodName;
                        // store the year
                        Year = Model.CurrentYear;
                    }
                }

                // force these to update the form so our validation
                // will pass in case the user goes with the auto-populated values
                await WeekIdTypeChangedAsync(Week);
                await UpdateYearIdTypeChangedAsync(Year);

                if (Model.idfSentByOffice != null)
                {
                    await LoadSentByOfficers(Model.idfSentByOffice);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task UpdateYearIdTypeChangedAsync(object value)
        {
            // Note: The Model.Week is bound to us
            if (value != null)
            {
                Year = Convert.ToInt32(value);
                Model.Year = Year;
                Model.CurrentYear = Year;
            }

            await InvokeAsync(StateHasChanged);
        }

        // handle the year
        protected async Task YearIdTypeChangedAsync(object value)
        {
            if (value != null)
            {
                Year = (int)value;

                // we have to reload the weeks for the current year
                await LoadWeeks();
            }

            await InvokeAsync(StateHasChanged);
        }

        // handle the week
        protected async Task WeekIdTypeChangedAsync(object value)
        {
            // Note: The Model.Week is bound to us
            if (value != null)
            {
                Week = value.ToString();
                Model.Week = Week;
                Model.CurrentWeek = Week;
            }

            await InvokeAsync(StateHasChanged);
        }

        public async Task GetSentToOrganizations(LoadDataArgs args)
        {
            try
            {
                var filter = args.Filter;

                // filter the result based on what we already have
                if (Model.LstSentToOrganizations.Any())
                {
                    SentToOrganizations = Model.LstSentToOrganizations.Where(x => x.EnglishName.Contains(filter, StringComparison.OrdinalIgnoreCase));
                }
                else // fetch the list
                {
                    OrganizationAdvancedGetRequestModel request = new()
                    {
                        LangID = GetCurrentLanguage(),
                        SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                        AccessoryCode = (int)AccessoryCodes.HumanHACode,
                        OrganizationTypeID = null,
                        AdvancedSearch = filter
                    };

                    Model.LstSentToOrganizations = await OrganizationClient.GetOrganizationAdvancedList(request);
                    Model.LstSentToOrganizations = Model.LstSentToOrganizations.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();

                    SentToOrganizations = Model.LstSentToOrganizations;
                }

                // if we are read only or edit load the values
                if (ReportDetailViewModel != null)
                {
                    if (ReportDetailViewModel.datSentByDate != null)
                    {
                        // we need a date time here for our date picker control
                        //Model.datSentByDate = DateTime.Parse(reportDetailViewModel.datSentByDate);
                        // save us off just in case
                        Model.strDateEnteredBy = ReportDetailViewModel.datSentByDate;

                        //DateTime enteredDate = DateTime.Parse(reportDetailViewModel.datEnteredByDate);
                        //Model.datEnteredByDate = DateTime.Parse(reportDetailViewModel.datEnteredByDate);
                        // we have to have a string value here
                        Model.strDateEnteredBy = ReportDetailViewModel.datEnteredByDate;
                    }

                    Model.idfSentByPerson = ReportDetailViewModel.idfSentByPerson;
                    //Model.strSentByPerson = ReportDetailViewModel.strSentByPerson;
                    Model.idfSentByOffice = ReportDetailViewModel.idfSentByOffice;

                    await LoadSentByOfficers(Model.idfSentByOffice);
                }

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
            EmployeeGetListRequestModel request = new();

            try
            {
                long? organizationId = value == null ? null : long.Parse(value.ToString() ?? string.Empty);

                request.LanguageId = GetCurrentLanguage();
                request.OrganizationID = organizationId;
                request.SortColumn = "EmployeeFullName";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;

                var list = await EmployeeClient.GetEmployeeList(request);
                SentByOfficers = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task GetEnteredByOfficer(long personId)
        {
            EmployeeDetailsGetRequestModel request = new();

            try
            {
                request.LangID = GetCurrentLanguage();
                request.idfPerson = personId;

                var response = await EmployeeClient.GetEmployeeDetail(request);
                Model.EmployeeDetail = response.FirstOrDefault();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OpenEmployeeAddModal()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams, new DialogOptions { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if (((EditContext) result).Validate())
                {
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        // the "name" could be used for validation
        // to make sure we are coming from a particular text area
        protected void OnChangeComments(string value, string name)
        {
            // since we are bound to the control we need not do anything
            _ = Model.strComments;
        }

        public async Task SaveAll()
        {
            Model.Week = Week;
            Model.Year = Year;

            //reset the cancellation token
            _source = new CancellationTokenSource();

            if (Form.EditContext.Validate())
            {
                // validate the form
                var validateResult = await ValidateSection();
                var isDuplicate = false;
                const bool updateFlag = false;

                Model.duplicateRecordsFound = string.Empty;

                // The weeks dropdown
                var weeks = Week;

                // set the Start and End (Finish) date
                ParseWeeks(weeks);

                // if we have a duplicate
                // if we have a session Id we are updating an existing record.
                if (SessionID != null)
                {
                    if (validateResult)
                    {
                        try
                        {
                            // these have the correct updated values
                            Model.Week = Week;
                            Model.Year = Year;

                            // force these to update the form so our validation
                            // will pass in case the user goes with the auto-populated values
                            await WeekIdTypeChangedAsync(Week);
                            await UpdateYearIdTypeChangedAsync(Year);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex.Message, null);
                            throw;
                        }
                    }
                }
                else
                {
                    if (validateResult)
                    {
                        try
                        {
                            // make sure a record does not already exist for this time and admin level
                            // get the client and save the form
                            GetRequestModel = new WeeklyReportingFormGetRequestModel();
                            ReportFormViewModelList = new List<ReportFormViewModel>();

                            // get a list of records
                            ReportFormViewModelList = await LoadRequestModel(GetRequestModel);

                            foreach (var invalidDate in from item in ReportFormViewModelList where item.AdminLevel2 == Model.ReportFormLocationModel.AdminLevel2Value where item.SentByDate != null select DateTime.Parse(item.DisplaySentByDate.ToString()) into sentBy let startDate = DateTime.Parse(Model.strStartDate) let endDate = DateTime.Parse(Model.strEndDate) select DatesBetween(sentBy, startDate, endDate))
                            {
                                if (invalidDate)
                                {
                                    // give a warning and return
                                    isDuplicate = true;
                                    // this message is not displayed, so we do not need to localize it
                                    Model.duplicateRecordsFound = "Consider editing the existing record.";
                                }

                                if (Model.duplicateRecordsFound == string.Empty || !isDuplicate) continue;
                                // string duplicateMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.WeeklyReportingFormDetailsDuplicateRecordMessage), Model.duplicateRecordsFound);
                                var duplicateMessage = $"{Localizer.GetString(MessageResourceKeyConstants.WeeklyReportingFormDetailsDuplicateRecordMessage)}";
                                Model.InformationalMessage = duplicateMessage;
                                _ = ShowInvalidEntry(Model.InformationalMessage);

                                // get us out of here!!!
                                return;
                            }
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex.Message, null);
                            throw;
                        }
                    }
                }

                if (validateResult && !isDuplicate)
                {
                    SaveRequestModel = new WeeklyReportSaveRequestModel();
                    SaveResponseModel = new WeeklyReportSaveResponseModel();

                    try
                    {
                        var newRecordIndicator = false;

                        // see if we are an update
                        SaveRequestModel.idfReportForm = Model.idfReportForm ?? 0;

                        if (SaveRequestModel.idfReportForm  == 0)
                            newRecordIndicator = true;

                        SaveRequestModel.strReportFormID = Model.strReportFormID != "" ? Model.strReportFormID : "";

                        SaveRequestModel.idfsReportFormType = Model.idfsReportFormType;

                        SaveRequestModel.idfSentByOffice = Model.idfSentByOffice;
                        SaveRequestModel.idfSentByPerson = Model.idfSentByPerson;
                        // use the UserOrg ID
                        SaveRequestModel.idfEnteredByOffice = Model.UserOrganizationID;
                        SaveRequestModel.idfEnteredByPerson = Model.idfEnteredByPerson;

                        if (Model.strStartDate != null)
                        {
                            if (!updateFlag)
                            {
                                Model.datStartDate = DateTime.Parse(Model.strStartDate);
                                SaveRequestModel.datStartDate = Model.datStartDate;
                            }
                            else
                            {
                                Model.datStartDate = DateTime.Parse(Model.strStartDate);
                                SaveRequestModel.datStartDate = Model.datStartDate;
                            }
                        }

                        if (Model.strEndDate != null)
                        {
                            if (!updateFlag)
                            {
                                Model.datEndDate = DateTime.Parse(Model.strEndDate);
                                SaveRequestModel.datFinishDate = Model.datEndDate;
                            }
                            else
                            {
                                Model.datEndDate = DateTime.Parse(Model.strEndDate);
                                SaveRequestModel.datFinishDate = Model.datEndDate;
                            }
                        }

                        SaveRequestModel.datEnteredByDate = Model.datEnteredByDate ??
                                                            DateTime.Now;

                        if (Model.datSentByDate != null)
                        {
                            SaveRequestModel.datSentByDate = Model.datSentByDate;
                        }

                        // diagnosis
                        SaveRequestModel.idfDiagnosis = Model.DiseaseID;
                        SaveRequestModel.total = Model.Total;

                        SaveRequestModel.SiteID = Convert.ToInt64(Model.UserSiteID);
                        SaveRequestModel.UserID = Convert.ToInt64(Model.EIDSS_UuserID);
                        // Not greater than Total
                        SaveRequestModel.notified = Model.AmongNotified;
                        SaveRequestModel.comments = Model.strComments;
                        SaveRequestModel.datModificationForArchiveDate = DateTime.Now.Date;
                        // this Model value is set up in LocationChanged as the dropdown are selected
                        SaveRequestModel.GeographicalAdministrativeUnitID = Model.AdministrativeUnitTypeID;

                        // get the client and save the form
                        SaveResponseModel = await WeeklyReportingFormClient.SaveWeeklyReportingForm(SaveRequestModel);

                        if (SaveResponseModel != null)
                        {
                            // try to get our values
                            Model.strReportFormID = SaveResponseModel.strReportFormID;
                            Model.idfReportForm = SaveResponseModel.idfReportForm;
                            Model.datSentByDate = SaveRequestModel.datSentByDate;
                            // Model.strSentByPerson = saveRequestModel.idfSentByPerson;
                            Model.datEnteredByDate = SaveRequestModel.datEnteredByDate;
                            Model.datStartDate = SaveRequestModel.datStartDate;
                            // copy us over
                            Model.EnteredInstitution = Model.idfSentByOffice;
                            Model.EnteredOfficer = Model.idfSentByPerson;

                            // enable our Delete button after first save
                            if (Model.strReportFormID != "")
                            {
                                SetButtonStates();
                            }

                            // Show success message
                            await ShowSaveSuccessMessage(newRecordIndicator);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex.Message, null);
                        throw;
                    }
                }
            }
        } // End SaveAll

        private static bool DatesBetween(DateTime input, DateTime start, DateTime end)
        {
            return input > start && input < end;
        }

        private async Task<List<ReportFormViewModel>> LoadRequestModel(WeeklyReportingFormGetRequestModel getRequestModel)
        {
            try
            {
                getRequestModel.ReportFormTypeId = (long?)ReportFormTypes.HumanWeeklyReportForm;
                if (Model.datStartDate == null)
                {
                    _ = DateTime.TryParse(Model.strStartDate, out var startDate);

                    getRequestModel.StartDate = startDate;
                }
                else
                {
                    getRequestModel.StartDate = Model.datStartDate; //.datEnteredByDate;
                }

                getRequestModel.EndDate = Model.datEndDate;

                //Get lowest administrative level for location
                if (Model.ReportFormLocationModel.AdminLevel3Value.HasValue)
                {
                    getRequestModel.AdministrativeLevelId = Model.ReportFormLocationModel.AdminLevel3Value.Value;
                    getRequestModel.AdministrativeUnitTypeId = Model.ReportFormLocationModel.AdminLevel3Value.Value;
                }
                else if (Model.ReportFormLocationModel.AdminLevel2Value.HasValue)
                {
                    getRequestModel.AdministrativeLevelId = Model.ReportFormLocationModel.AdminLevel2Value.Value;
                    getRequestModel.AdministrativeUnitTypeId = Model.ReportFormLocationModel.AdminLevel2Value.Value;
                }
                else if (Model.ReportFormLocationModel.AdminLevel1Value.HasValue)
                {
                    getRequestModel.AdministrativeLevelId = Model.ReportFormLocationModel.AdminLevel1Value.Value;
                    if (Model.ReportFormLocationModel.AdminLevel1Value.HasValue)
                    {
                        getRequestModel.AdministrativeUnitTypeId = Model.ReportFormLocationModel.AdminLevel1Value.Value;
                    }
                }
                else
                {
                    getRequestModel.AdministrativeLevelId = null;
                    getRequestModel.AdministrativeUnitTypeId = null;
                }

                getRequestModel.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel;

                getRequestModel.LanguageId = GetCurrentLanguage();
                getRequestModel.SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                //sorting
                getRequestModel.SortColumn = "EIDSSReportID";
                getRequestModel.SortOrder = EIDSSConstants.SortConstants.Descending;
                //paging
                getRequestModel.Page = 1;
                getRequestModel.PageSize = 10;

                var result = await WeeklyReportingFormClient.GetWeeklyReportingFormList(getRequestModel);

                ReportFormViewModelList = new List<ReportFormViewModel>();

                if (_source.IsCancellationRequested == false)
                {
                    ReportFormViewModelList = result;
                }

                return ReportFormViewModelList;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public async Task<bool> ValidateSection()
        {
            if (Model.Total != null && !(Model.Total < Model.AmongNotified)) return true;
            const bool validIndicator = false;

            //string message = "Total must be greater than Among them Notified";
            //await ShowInvalidEntry(message);
            await TotalValidate();

            return validIndicator;
        }

        public void ParseWeeks(string weeks, bool fromTable = false)
        {
            if (weeks == "") return;
            // now we are formatted with "1- 1/1/1900 - 1/7/1900"
            var firstDashPos = weeks.IndexOf('-');
            var lastDashPos = weeks.LastIndexOf('-');
            var nLen = (lastDashPos - 1) - (firstDashPos + 2);
            if (lastDashPos == -1 || firstDashPos == -1) return;
            // start at the actual month
            Model.strEndDate = weeks[(lastDashPos + 2)..];
            Model.strStartDate = weeks.Substring(firstDashPos + 2, nLen);
        }

        public async Task DeleteAll()
        {
            try
            {
                DiagService.OnClose -= async property => await HandleDeleteResponse(property);
                DiagService.OnClose += async property => await HandleDeleteResponse(property);
                await ShowConfirmDeleteMessage();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task HandleDeleteResponse(dynamic result)
        {
            result = (DialogReturnResult)result;

            if (result == null) return;
            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                try
                {
                    if (Model.ReportFormPermissions.Delete)
                    {
                        Model.auditUpdateUser = authenticatedUser.UserName;
                        //fire delete
                        DeleteResponseModel =
                            await WeeklyReportingFormClient.DeleteWeeklyReport(Model.idfReportForm,
                                Model.auditUpdateUser);

                        NavManager.NavigateTo($"Human/WeeklyReportingForm", true);
                    }
                    else
                    {
                        DiagService.OnClose -= async property => await HandleDeleteResponse(property);
                        DiagService.Close();

                        await InsufficientPermissions();
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
            else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
                // just close modal
                DiagService.OnClose -= async property => await HandleDeleteResponse(property);
                DiagService.Close();
            }
        }

        protected async Task ShowSaveSuccessMessage(bool newRecordIndicator)
        {
            try
            {
                string saveMsg;

                if (newRecordIndicator)
                    saveMsg = string.Format(Localizer.GetString(MessageResourceKeyConstants
                        .WeeklyReportingFormDetailsRecordSavedSuccessfullyTheRecordIDIsMessage) + ".",
                    Model.strReportFormID);
                else
                    saveMsg= Localizer.GetString(MessageResourceKeyConstants
                            .RecordSavedSuccessfullyMessage);

                var buttons = new List<DialogButton>();

                var returnToWeeklyReporting = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.WeeklyReportingFormDetailsReturntoWeeklyReportingFormButton),
                    ButtonType = DialogButtonType.Yes
                };
                var returnToDashboard = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton),
                    ButtonType = DialogButtonType.OK
                };

                buttons.Add(returnToWeeklyReporting);
                buttons.Add(returnToDashboard);

                var dialogParams = new Dictionary<string, object>
                {
                    {"DialogName", "SaveSuccess"},
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {nameof(EIDSSDialog.Message), new LocalizedString("SaveSuccess", saveMsg)}
                };

                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSSuccessModalHeading), dialogParams);

                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                {
                    //cancel add and user said yes
                    _source?.Cancel();
                    shouldRender = false;
                    // take us back to search
                    var uri = $"{NavManager.BaseUri}Human/WeeklyReportingForm";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel add but user said no so leave everything alone and cancel thread
                    _source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task ShowInvalidEntry(string msg)
        {
            try
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
                    {nameof(EIDSSDialog.Message), string.IsNullOrEmpty(msg) ? null : Localizer.GetString(msg)}
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //cancel said OK
                    _source?.Cancel();
                    shouldRender = false;
                }
                else
                {
                    // just cancel
                    _source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task ShowConfirmDeleteMessage()
        {
            try
            {
                var buttons = new List<DialogButton>();

                var yesButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);

                var noButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                    }
                };
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task TotalValidate()
        {
            string message = Localizer.GetString(MessageResourceKeyConstants.WeeklyReportingFormTotalMustBeGreaterThanAmongThemNotifiedMessage);
            try
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
                    {nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message)}
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //cancel add and user said yes
                    _source?.Cancel();
                    shouldRender = false;
                }
                else
                {
                    //cancel add but user said no so leave everything alone and cancel thread
                    _source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task CancelAdd()
        {
            try
            {
                // hide the print report
                DisplayReport = false;

                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel add and user said yes
                    _source?.Cancel();
                    shouldRender = false;
                    // take us back to search
                    var uri = $"{NavManager.BaseUri}Human/WeeklyReportingForm";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel add but user said no so leave everything alone and cancel thread
                    _source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task PrintMatrix()
        {
            if (Form.IsValid)
            {
                try
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("idfReportForm", Model.idfReportForm.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.WeeklyReportingFormDetailsPageHeading),
                        new Dictionary<string, object> { { "ReportName", "WeeklyReportingForm" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = EIDSSConstants.ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1050px"
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        protected async Task HandleValidPrintSubmit(WeeklyReportComponentViewModel model)
        {
            if (Form.IsValid)
            {
                var gisLocationList = model.ReportFormLocationModel.AdminLevel1List;
                // get the region
                var region = gisLocationList.ElementAt(1);
                var regionIdfsReference = region.idfsReference;
                // get the rayon
                var rayon = gisLocationList.ElementAt(2);
                var rayonIdfsReference = rayon.idfsReference;

                {
                    var total = model.Total.ToString();
                    var amongNotified = model.AmongNotified.ToString();
                    var comments = model.strComments;

                    try
                    {
                        //Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                        //Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                        //_ = DateTime.TryParse(reportQueryModel.StartIssueDate, out DateTime startIssueDate);
                        //_ = DateTime.TryParse(reportQueryModel.EndIssueDate, out DateTime endIssueDate);
                        Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                        Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

                        model.ReportParameters.Add(new KeyValuePair<string, string>("Region", regionIdfsReference.ToString()));
                        model.ReportParameters.Add(new KeyValuePair<string, string>("Rayon", rayonIdfsReference.ToString()));
                        model.ReportParameters.Add(new KeyValuePair<string, string>("Total", total));
                        model.ReportParameters.Add(new KeyValuePair<string, string>("Month", amongNotified));
                        model.ReportParameters.Add(new KeyValuePair<string, string>("Month", comments));

                        // return PartialView("~/Areas/Reports/Views/Shared/_PartialReport.cshtml", model);

                        await InvokeAsync(StateHasChanged);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex.Message, null);
                        throw;
                    }
                }
            }
        }

        private void SetButtonStates()
        {
            // control is enabled after first save
            if (Model.strReportFormID != "" && Model.ReportFormPermissions.Delete)
            {
                // Do Not disable us
                DisableDeleteButton = false;
            }

            if (!Model.ReportFormPermissions.Delete)
            {
                DisableDeleteButton = true;
            }

            if (Model.strReportFormID != "")
            {
                // show the print button
                DisablePrintButton = false;
            }
        }

        public void Dispose()
        {
            ProtectedSessionStore.DeleteAsync("WeeeklyReportDetails");

            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion Methods
    }
}