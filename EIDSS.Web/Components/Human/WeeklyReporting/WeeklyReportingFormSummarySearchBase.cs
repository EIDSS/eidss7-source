
#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingSummary;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Globalization;
using EIDSS.Web.ViewModels;
using System.Linq;
using EIDSS.ClientLibrary.Services;
using EIDSS.ReportViewer;
using Microsoft.Extensions.Configuration;
#endregion


namespace EIDSS.Web.Components.Human.WeeklyReporting
{
    public class WeeklyReportingFormSummarySearchBase : SearchComponentBase<WeeklyReportingFormSummarySearchViewModel>, IDisposable
    {

        #region Protected and Public Fields
        protected RadzenAccordion _radAccordion;
        //protected RadzenDataGrid<WeeklyReportingFormSummarySearchViewModel> grid;
        protected RadzenTemplateForm<WeeklyReportingFormSummarySearchViewModel> form;
        protected WeeklyReportingFormSummarySearchViewModel model;
        

        protected RadzenDataGrid<WeeklyReportingFormSummarySearchViewModel> Grid;

        protected IEnumerable<WeeklyReportingFormSummarySearchViewModel> SearchResults { get; set; }

        protected IEnumerable<ReportYearModel> reportYears;
        protected IEnumerable<ReportMonthNameModel> reportMonths;
        protected IConfiguration _configuration;

        public long MinimumTimeInterval { get; set; }

        protected bool showSearchResults;

        protected void LocationChanged(LocationViewModel locationViewModel)
        {
            if (locationViewModel.AdminLevel3Value.HasValue)
                model.idfsLocation = locationViewModel.AdminLevel3Value.Value;
            else if (locationViewModel.AdminLevel2Value.HasValue)
                model.idfsLocation = locationViewModel.AdminLevel2Value.Value;
            else if (locationViewModel.AdminLevel1Value.HasValue)
                model.idfsLocation = locationViewModel.AdminLevel1Value.Value;
            else
                model.idfsLocation = null;
        }

        #endregion

        #region Private Fields and Properties

        private bool searchSubmitted;

        private CancellationTokenSource source;
        private CancellationToken token;

        public string ReportFileName { get; set; } = "Weekly Reporting Form Summary";

        #endregion Private Fields and Properties

        #region Parameters

        [Parameter]
        public int? Year { get; set; }

        [Parameter]
        public string Month { get; set; }

        [Parameter]
        public string Region { get; set; }

        [Parameter]
        public string Rayon { get; set; }
        #endregion

        public WeeklyReportingFormSummarySearchBase()
        {
            
            MinimumTimeInterval = (long)TimePeriodTypes.Month;
        }

        #region Dependency Injection

        //[Inject]
        //private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        private ILogger<WeeklyReportingFormSummarySearchBase> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IConfiguration Configuration { get; set; }

        //[Inject] 
        //private IServiceProvider servceProvider { get; set; }

        [Inject] 
        private IApplicationContext ApplicationContext { get; set; }


        #endregion

        #region Lifecycle Methods

        public override async Task SetParametersAsync(ParameterView parameters)
        {
            await InitializeModelAsync();
        }

        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();

            _logger = Logger;
            
            //reset the cancellation token
            source = new();
            token = source.Token;

            //set grid for not loaded
            isLoading = false;
        }

        // public async Task<List<ReportMonthNameModel>> GetReportMonthNameList(string languageId)
        public async Task GetMonthNameQueryAsync(LoadDataArgs args)
        {
           reportMonths = await CrossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());

            // load as a startup value
            Year = model.CurrentYear;

            if (!String.IsNullOrEmpty(args.Filter))
                reportMonths = reportMonths
                    .Where(x => x.strDefault.ToLowerInvariant().Contains(args.Filter.ToLowerInvariant())).ToList();

            await InvokeAsync(StateHasChanged);
        }

        // public async Task<List<ReportYearModel>> GetReportYearList()
        public async Task GetYearNameQueryAsync(LoadDataArgs args)
        {
           reportYears = await CrossCuttingClient.GetReportYearList();

            // load as a startup value
            Month = model.CurrentMonth;

            if (!String.IsNullOrEmpty(args.Filter))
                reportYears = reportYears
                    .Where(x => x.Year.ToString().Contains(args.Filter.ToLowerInvariant())).ToList();

            await InvokeAsync(StateHasChanged);
        }

        // handle the year
        protected async Task YearIDTypeChangedAsync(object value)
        {
            if (value != null)
            {
               Year = (int)value;
            }

            await InvokeAsync(StateHasChanged);
        }

        // handle the month
        protected async Task MonthIDTypeChangedAsync(object value)
        {
            if (value != null)
            {
                Month = value.ToString();
            }

            await InvokeAsync(StateHasChanged);
        }

        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }
        #endregion

        #region Protected Methods and Delegates

        protected void RefreshLocationViewModelHandler(LocationViewModel locationViewModel)
        {
            model.SearchLocationViewModel = locationViewModel;
        }

        protected void OnClick()
        {
            var x = model.SearchLocationViewModel;
        }

        protected void LoadData(LoadDataArgs args)
        {
            var list = new List<WeeklyReportingFormSummarySearchViewModel>();
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;

                    SearchResults = new List<WeeklyReportingFormSummarySearchViewModel>(); 
                    count = 0;
                }
                catch (Exception)
                {
                    throw;
                }
                finally
                {
                    isLoading = false;
                }
            }
            else
            {
                //initialize the grid so that it displays 'No records message'
                SearchResults = new List<WeeklyReportingFormSummarySearchViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task DisplaySearchResults(WeeklyReportingFormSummarySearchViewModel model)
        {
            if (form.IsValid)
            {
                long? regionIdfsReference;
                long? rayonIdfsReference;
                //TODO: remove commented if session-User approach works//string organization = ConfigurationService.GetUserToken().Organization;
                //TODO: consider usage of _tokenService.GetAuthenticatedUser().Organization
                string organization = authenticatedUser.Organization;

                regionIdfsReference = model.SearchLocationViewModel.AdminLevel1Value;
                if (regionIdfsReference == null)
                {
                    regionIdfsReference = 0;
                }

                rayonIdfsReference = model.SearchLocationViewModel.AdminLevel2Value;
                if (rayonIdfsReference == null)
                {
                    rayonIdfsReference = 0;
                }

                string Year = string.Empty;
                string sMonth = string.Empty;
                long? Month = 0;

                if (model.Year == null)
                    Year = model.CurrentYear.ToString();
                else
                    Year = model.Year.ToString();

                if (model.Month == null)
                    sMonth = model.CurrentMonth;
                else
                    sMonth = model.Month;

                // get the numeric value
                Month = DateTime.ParseExact(sMonth, "MMMM", CultureInfo.CurrentCulture).Month;

                // call this sp USP_GBL_ReportForm_GetList

                try
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("Year", Year);
                    reportModel.AddParameter("Month", Month.ToString());
                    reportModel.AddParameter("UserOrganization", organization);
                    reportModel.AddParameter("RegionID", regionIdfsReference.ToString());
                    reportModel.AddParameter("RayonID", rayonIdfsReference.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.WeeklyReportingFormSummaryPageHeading),
                        new Dictionary<string, object> { { "ReportName", "WeeklyReportingSummary" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = EIDSSConstants.ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1175px"
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        protected async Task HandleValidSearchSubmit(WeeklyReportingFormSummarySearchViewModel model)
        {
            if (form.IsValid)
            {
                long? regionIdfsReference;
                long? rayonIdfsReference;
                //TODO: remove commented if session-User approach works//string organization = ConfigurationService.GetUserToken().Organization;
                //TODO: consider usage of _tokenService.GetAuthenticatedUser().Organization
                string organization = authenticatedUser.Organization;

                //List<GisLocationChildLevelModel> GISLocationList = model.SearchLocationViewModel.AdminLevel1List;
                //// get the region 
                //var region = GISLocationList.ElementAt(1);
                //regionIdfsReference = region.idfsReference;
                //// get the rayon
                //var rayon = GISLocationList.ElementAt(2);
                //rayonIdfsReference = rayon.idfsReference;

                regionIdfsReference = model.SearchLocationViewModel.AdminLevel1Value;
                if (regionIdfsReference == null)
                {
                    regionIdfsReference = 0;
                }
                
                rayonIdfsReference = model.SearchLocationViewModel.AdminLevel2Value;
                if (rayonIdfsReference == null)
                {
                    rayonIdfsReference = 0;
                }

                string Year = string.Empty;
                string sMonth = string.Empty;
                long? Month = 0;

                if (model.Year ==  null)
                    Year = model.CurrentYear.ToString();
                else
                    Year = model.Year.ToString();

                if (model.Month ==  null)
                    sMonth = model.CurrentMonth;
                else
                    sMonth = model.Month;

                // get the numeric value
                Month = DateTime.ParseExact(sMonth, "MMMM", CultureInfo.CurrentCulture).Month;

                try
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("Year", Year);
                    reportModel.AddParameter("Month", Month.ToString());
                    reportModel.AddParameter("UserOrganization", organization);
                    reportModel.AddParameter("RegionID", regionIdfsReference.ToString());
                    reportModel.AddParameter("RayonID", rayonIdfsReference.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.WeeklyReportingFormSummaryPageHeading),
                        new Dictionary<string, object> { { "ReportName", "WeeklyReportingSummary" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = EIDSSConstants.ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1175px"
                            
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }
       
        #endregion

        #region Private Methods
        private async Task InitializeModelAsync()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            
            // TODO - do we need user preferences here to get the default admin levels or will location component handle this?
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            model = new WeeklyReportingFormSummarySearchViewModel();
            model.WeeklyReportFormSummaryPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.HumanWeeklyReportSummary);
            model.RecordSelectionIndicator = true;
            model.SearchLocationViewModel = new();
            model.ReportParameters = new();
            
            await FillConfigurationSettingsAsync();
        }

        protected async Task FillConfigurationSettingsAsync()
        {
            // set the report path
            _configuration = Configuration;
            model.ReportPath = _configuration.GetValue<string>("ReportServer:Path");

            LocationViewModel locationViewModel = new LocationViewModel();
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
            var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId), Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId));

            // Country is always admin level 0, Region Admin 1, Rayon Admin 2...
            model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;

            if (siteDetails != null)
            {
                BaseReferenceViewModel item = new BaseReferenceViewModel();
                item.StrDefault = "";
                item.IdfsBaseReference = -1;

                //_weeklyReportingSummarySearchViewModel.MinimumAdministrativeLevelId = (long)AdministrativeUnitTypes.Rayon;
                //_weeklyReportingSummarySearchViewModel.MinimumTimeIntervalId = (long)TimePeriodTypes.Month;

                // Location Control
                // I want to hide most of these by setting them to false
                //SetupRequiredSearchLocationModel(locationViewModel);

                locationViewModel.IsHorizontalLayout = true;
                locationViewModel.ShowAdminLevel0 = false;
                locationViewModel.ShowAdminLevel1 = true;  //Region
                locationViewModel.ShowAdminLevel2 = true;  //Rayon
                locationViewModel.ShowAdminLevel3 = false;
                locationViewModel.EnableAdminLevel0= false;  //Region
                locationViewModel.EnableAdminLevel1 = true;  //Region
                locationViewModel.EnableAdminLevel2 = true;  //Rayon
                locationViewModel.EnableAdminLevel3 = false;
                locationViewModel.ShowAdminLevel4 = false;
                locationViewModel.ShowAdminLevel5 = false;
                locationViewModel.ShowAdminLevel6 = false;
                locationViewModel.ShowHouse = false;
                locationViewModel.ShowBuilding = false;
                locationViewModel.ShowStreet = false;
                locationViewModel.ShowApartment = false;
                locationViewModel.ShowPostalCode = false;
                locationViewModel.ShowCoordinates = false;
                locationViewModel.ShowBuildingHouseApartmentGroup = false;
                locationViewModel.ShowElevation = false;
                locationViewModel.ShowLatitude = false;
                locationViewModel.ShowLongitude = false;
                locationViewModel.ShowMap = false;
                locationViewModel.ShowSettlement = false;
                locationViewModel.ShowSettlementType = false;
                locationViewModel.DivSettlementType = false;
                locationViewModel.DivSettlementGroup = false;

                // MVB test
                locationViewModel.DivSettlementGroup = false;

                locationViewModel.SettlementTypeList = null;
                locationViewModel.IsDbRequiredSettlementType = false;
                locationViewModel.SettlementType = null;
                locationViewModel.ShowSettlementType = false;
                locationViewModel.EnableSettlementType = false;
                locationViewModel.DivSettlementType = false;

                locationViewModel.SettlementList = null;
                locationViewModel.IsDbRequiredSettlement = false;
                locationViewModel.Settlement = null;
                locationViewModel.SettlementText = null;
                locationViewModel.ShowSettlement = false;
                locationViewModel.EnableSettlement = false;
                locationViewModel.DivSettlement = false;
                // MVB test

                locationViewModel.AdminLevel0Value = siteDetails.CountryID;


                if (userPreferences.DefaultRegionInSearchPanels)
                {
                    locationViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
                }
                else
                {
                    locationViewModel.AdminLevel1Value = null;
                }

                if (userPreferences.DefaultRayonInSearchPanels)
                {
                    locationViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;
                }
                else
                {
                    locationViewModel.AdminLevel2Value = null;
                }

                model.SearchLocationViewModel = locationViewModel;

               await InvokeAsync(StateHasChanged);
            }

            #endregion
        }
    }
}
