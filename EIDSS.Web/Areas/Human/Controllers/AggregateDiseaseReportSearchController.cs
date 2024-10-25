#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Extensions;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Areas.Human.Controllers
{
    [ViewComponent(Name = "AggregateDiseaseReportSearch")]
    [Area("Human")]
    public class AggregateDiseaseReportSearchController : BaseController
    {
        #region Globals

        private readonly IAggregateReportClient _aggregateReportClient;
        private readonly ISiteClient _siteClient;
        private readonly IAggregateSettingsClient _aggregateSettingsClient;
        private readonly UserPreferences _userPreferences;
        private readonly IConfiguration _configuration;
        private readonly UserPermissions _permissions;
        private AggregateReportSearchViewModel _aggregateDiseaseReportSearchViewModel;
        private bool _isFirstLoad = true;
        private readonly IStringLocalizer _localizer;

        #endregion

        #region Methods

        #region Constructors/Invocations

        public AggregateDiseaseReportSearchController(IAggregateReportClient aggregateReportClient,
            ISiteClient siteClient,
            IAggregateSettingsClient aggregateSettingsClient,
            IConfiguration configuration,
            ITokenService tokenService,
            ILogger<AggregateDiseaseReportSearchController> logger,
            IStringLocalizer localizer) :
            base(logger, tokenService)
        {
            _aggregateReportClient = aggregateReportClient;
            _siteClient = siteClient;
            _aggregateSettingsClient = aggregateSettingsClient;
            _configuration = configuration;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
            _permissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports);
            _localizer = localizer;
        }

        public async Task<IViewComponentResult> InvokeAsync(bool humanIndicator, bool recordSelectionIndicator, bool showInModalIndicator)
        {
            _aggregateDiseaseReportSearchViewModel = new AggregateReportSearchViewModel
            {
                TimeIntervalUnitSelect = new Select2Configruation(),
                AdministrativeLevelSelect = new Select2Configruation(),
                OrganizationSelect = new Select2Configruation(),
                SearchCriteria = new AggregateReportSearchRequestModel
                {
                    AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport),
                    OrganizationIDDisabledIndicator = true
                },
                Permissions = _permissions,
                HumanIndicator = humanIndicator,
                RecordSelectionIndicator = recordSelectionIndicator,
                ShowInModalIndicator = showInModalIndicator,
                SearchLocationViewModel = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = false,
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = false,
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
                    IsDbRequiredAdminLevel1 = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                },
                LangId = GetCurrentLanguage(),
                ReportName = "SearchForHumanAggregateDiseaseReport",
                ReportHeader = _localizer.GetString(HeadingResourceKeyConstants.HumanAggregateDiseaseReportPageHeading)
            };

            await FillConfigurationSettingsAsync(null);

            var viewData = new ViewDataDictionary<AggregateReportSearchViewModel>(ViewData, _aggregateDiseaseReportSearchViewModel);
            return new ViewViewComponentResult
            {
                ViewData = viewData
            };
        }

        private async Task FillConfigurationSettingsAsync(long? administrativeUnitType)
        {
            var searchLocationViewModel = new LocationViewModel();

            var siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                var aggregateSettingsGetRequestModel = new AggregateSettingsGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfCustomizationPackage = siteDetails.CustomizationPackageID,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = SortConstants.Ascending,
                    idfsSite = siteDetails.SiteID
                };

                var aggregateSettings = await _aggregateSettingsClient.GetAggregateSettingsList(aggregateSettingsGetRequestModel);

                var aggregateSetting = aggregateSettings.FirstOrDefault(a => a.idfsAggrCaseType == Convert.ToInt64(AggregateValue.Human));
                {
                    if (administrativeUnitType != null)
                    {
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitTypeID = administrativeUnitType.Value;
                    }
                    else
                    {
                        if (aggregateSetting != null)
                        {
                            _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitTypeID =
                                aggregateSetting.idfsStatisticAreaType;
                            var defaultDataAdministrativeLevel = new Select2DataItem
                            {
                                id = aggregateSetting.idfsStatisticAreaType.ToString(),
                                text = aggregateSetting.StrAreaType
                            };
                            _aggregateDiseaseReportSearchViewModel.AdministrativeLevelSelect.defaultSelect2Selection =
                                defaultDataAdministrativeLevel;
                        }
                    }

                    if (aggregateSetting != null)
                    {
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.TimeIntervalTypeID =
                            aggregateSetting.idfsStatisticPeriodType;
                        var defaultDataTimeInterval = new Select2DataItem
                        {
                            id = aggregateSetting.idfsStatisticPeriodType.ToString(),
                            text = aggregateSetting.StrPeriodType
                        };
                        _aggregateDiseaseReportSearchViewModel.TimeIntervalUnitSelect.defaultSelect2Selection =
                            defaultDataTimeInterval;
                    }
                }

                _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value = _userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;

                _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel2Value = _userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;

                //Set Other Admin Level Values - if needed
                const string orgControl = "OrganizationSelect";
                _aggregateDiseaseReportSearchViewModel.SearchCriteria.OrganizationIDDisabledIndicator = true;
                _aggregateDiseaseReportSearchViewModel.SearchCriteria.OrganizationID = null;

                // Location Control
                searchLocationViewModel.IsHorizontalLayout = true;
                searchLocationViewModel.EnableAdminLevel1 = false;
                searchLocationViewModel.EnableAdminLevel2 = false;
                searchLocationViewModel.EnableAdminLevel3 = false;
                searchLocationViewModel.EnableAdminLevel4 = false;
                searchLocationViewModel.EnableAdminLevel5 = false;
                searchLocationViewModel.EnableAdminLevel6 = false;
                searchLocationViewModel.EnableSettlement = false;
                searchLocationViewModel.EnableSettlementType = false;
                searchLocationViewModel.ShowAdminLevel0 = false;
                searchLocationViewModel.ShowAdminLevel1 = true;
                searchLocationViewModel.ShowAdminLevel2 = true;
                searchLocationViewModel.ShowAdminLevel3 = true;
                searchLocationViewModel.ShowAdminLevel4 = false;
                searchLocationViewModel.ShowAdminLevel5 = false;
                searchLocationViewModel.ShowAdminLevel6 = false;
                searchLocationViewModel.ShowSettlement = true;
                var selectedAdminLevelElement = "SelectedAdminLevel";
                if (!string.IsNullOrEmpty(searchLocationViewModel.CallingObjectID))
                {
                    selectedAdminLevelElement = $"{searchLocationViewModel.CallingObjectID}_SelectedAdminLevel";
                }
                searchLocationViewModel.AdminLevelRefreshJavascriptFunction = "refreshOrgByLocationAdminSelection(" + orgControl + "," + selectedAdminLevelElement + ");";
                searchLocationViewModel.ShowSettlementType = false;
                searchLocationViewModel.ShowStreet = false;
                searchLocationViewModel.ShowBuilding = false;
                searchLocationViewModel.ShowApartment = false;
                searchLocationViewModel.ShowElevation = false;
                searchLocationViewModel.ShowHouse = false;
                searchLocationViewModel.ShowLatitude = false;
                searchLocationViewModel.ShowLongitude = false;
                searchLocationViewModel.ShowMap = false;
                searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                searchLocationViewModel.ShowPostalCode = false;
                searchLocationViewModel.ShowCoordinates = false;
                searchLocationViewModel.IsDbRequiredAdminLevel1 = false;
                searchLocationViewModel.IsDbRequiredSettlement = false;
                searchLocationViewModel.IsDbRequiredSettlementType = false;
                searchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;
                searchLocationViewModel.OperationType = LocationViewOperationType.Edit;

                switch (_aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitTypeID)
                {
                    case (long)AdministrativeUnitTypes.Country:
                        searchLocationViewModel.ShowAdminLevel1 = false;
                        searchLocationViewModel.ShowAdminLevel2 = false;
                        searchLocationViewModel.ShowAdminLevel3 = false;

                        searchLocationViewModel.EnableAdminLevel1 = false;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.EnableSettlement = false;
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitID = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel0Value;
                        break;

                    case (long)AdministrativeUnitTypes.Region:
                        searchLocationViewModel.AdminLevel1Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = false;
                        searchLocationViewModel.ShowAdminLevel3 = false;

                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.DisableAtElementLevel = "AdminLevel2Value";
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitID = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        break;

                    case (long)AdministrativeUnitTypes.Rayon:
                        searchLocationViewModel.AdminLevel1Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = false;

                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.DisableAtElementLevel = "AdminLevel3Value";
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitID = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        break;
                    case (long)AdministrativeUnitTypes.Settlement:
                        searchLocationViewModel.AdminLevel1Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;

                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;

                        searchLocationViewModel.ShowSettlementType = false;
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitID = 
                            _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel3Value ??
                            _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel2Value;
                        break;

                    case (long)AdministrativeUnitTypes.Organization:
                        searchLocationViewModel.AdminLevel1Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;

                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;

                        searchLocationViewModel.ShowSettlementType = false;
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitID =
                            _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel3Value ??
                            _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel2Value;

                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.OrganizationIDDisabledIndicator = false;

                        break;

                    default:
                        searchLocationViewModel.AdminLevel1Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel2Value;

                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;

                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;

                        searchLocationViewModel.ShowSettlementType = false;
                        _aggregateDiseaseReportSearchViewModel.SearchCriteria.AdministrativeUnitID = _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel.AdminLevel3Value;

                        break;
                }

                _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel = searchLocationViewModel;
            }
        }

        public async Task<IActionResult> ReloadLocationControl([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            long? administrativeUnitTypeId = jsonObject["administrativeUnitTypeID"] == null ? null : (string.IsNullOrEmpty(jsonObject["administrativeUnitTypeID"].ToString()) ? null : Convert.ToInt64(jsonObject["administrativeUnitTypeID"]));

            _aggregateDiseaseReportSearchViewModel = new AggregateReportSearchViewModel
            {
                TimeIntervalUnitSelect = new Select2Configruation(),
                AdministrativeLevelSelect = new Select2Configruation(),
                OrganizationSelect = new Select2Configruation(),
                SearchCriteria = new AggregateReportSearchRequestModel(),
                Permissions = _permissions,
                HumanIndicator = true,
                RecordSelectionIndicator = true,
                ShowInModalIndicator = false,
                SearchLocationViewModel = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = false,
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = true,
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
                    IsDbRequiredAdminLevel1 = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                }
            };

            if (administrativeUnitTypeId != null) await FillConfigurationSettingsAsync(administrativeUnitTypeId.Value);

            return ViewComponent("LocationView", _aggregateDiseaseReportSearchViewModel.SearchLocationViewModel);
        }

        #endregion

        #region Search Aggregate Disease Report

        /// <summary>
        ///
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost()]
        [Route("GetAggregateDiseaseReportList")]
        public async Task<JsonResult> GetReportList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0,
                    draw = dataTableQueryPostObj.draw
                };

                var postParameterDefinitions = new { SearchCriteria_ReportID = "", SearchCriteria_LegacyReportID = "", TimeIntervalUnitSelect = "", AdministrativeLevelSelect = "", StartDate = "", EndDate = "", AdminLevel1Value = "", AdminLevel2Value = "", AdminLevel3Value = "", OrganizationSelect = "", HumanIndicator = "", IsFirstLoadIndicator = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                // prevent calling the api until the user clicks search
                if (bool.TryParse(searchCriteria.IsFirstLoadIndicator, out var result))
                {
                    if (result) return Json(tableData);
                }

                if (string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReportID) &&
                    string.IsNullOrEmpty(searchCriteria.SearchCriteria_LegacyReportID) &&
                    string.IsNullOrEmpty(searchCriteria.AdminLevel1Value) &&
                    string.IsNullOrEmpty(searchCriteria.AdminLevel2Value) &&
                    string.IsNullOrEmpty(searchCriteria.TimeIntervalUnitSelect) &&
                    string.IsNullOrEmpty(searchCriteria.StartDate) && string.IsNullOrEmpty(searchCriteria.EndDate) &&
                    string.IsNullOrEmpty(searchCriteria.AdministrativeLevelSelect) &&
                    string.IsNullOrEmpty(searchCriteria.AdminLevel3Value) &&
                    string.IsNullOrEmpty(searchCriteria.OrganizationSelect)) return Json(tableData);

                // paging
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                // sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                //var model = JsonConvert.DeserializeObject<AggregateReportSearchRequestModel>(dataTableQueryPostObj.postArgs);
                var model = new AggregateReportSearchRequestModel();
                model.LanguageId = GetCurrentLanguage();
                model.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel;
                model.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                model.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                model.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                model.AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport);
                model.Page = iPage;
                model.PageSize = iLength;
                model.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "ReportID";
                model.SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Descending;
                model.TimeIntervalTypeID = string.IsNullOrEmpty(searchCriteria.TimeIntervalUnitSelect) ? null : Convert.ToInt32(searchCriteria.TimeIntervalUnitSelect);
                model.AdministrativeUnitTypeID = string.IsNullOrEmpty(searchCriteria.AdministrativeLevelSelect) ? null : Convert.ToInt32(searchCriteria.AdministrativeLevelSelect);

                // get lowest administrative level.
                if (!string.IsNullOrEmpty(searchCriteria.AdminLevel3Value))
                {
                    if (!string.IsNullOrEmpty(searchCriteria.AdminLevel1Value) && !string.IsNullOrEmpty(searchCriteria.AdminLevel2Value))
                    {
                        model.AdministrativeUnitID = Convert.ToInt64(searchCriteria.AdminLevel3Value);
                    }
                }
                else if (!string.IsNullOrEmpty(searchCriteria.AdminLevel2Value))
                {
                    if (!string.IsNullOrEmpty(searchCriteria.AdminLevel1Value))
                    {
                        model.AdministrativeUnitID = Convert.ToInt64(searchCriteria.AdminLevel2Value);
                    }
                }
                else if (!string.IsNullOrEmpty(searchCriteria.AdminLevel1Value))
                    model.AdministrativeUnitID = Convert.ToInt64(searchCriteria.AdminLevel1Value);
                else
                    model.AdministrativeUnitID = null;

                model.ReportID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReportID) ? null : searchCriteria.SearchCriteria_ReportID;
                model.LegacyReportID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_LegacyReportID) ? null : searchCriteria.SearchCriteria_LegacyReportID;
                model.StartDate = string.IsNullOrEmpty(searchCriteria.StartDate) ? null : DateTime.Parse(searchCriteria.StartDate);
                model.EndDate = string.IsNullOrEmpty(searchCriteria.EndDate) ? null : DateTime.Parse(searchCriteria.EndDate);
                if (string.IsNullOrEmpty(searchCriteria.OrganizationSelect) || searchCriteria.OrganizationSelect == "null")
                {
                    model.OrganizationID = null;
                }
                else
                {
                    model.OrganizationID = Convert.ToInt64(searchCriteria.OrganizationSelect);
                }

                var list = await _aggregateReportClient.GetAggregateReportList(model);
                IEnumerable<AggregateReportGetListViewModel> reportList = list;

                if (list.Count <= 0) return Json(tableData);
                tableData.data.Clear();
                tableData.iTotalRecords = (int)list[0].RecordCount;
                tableData.iTotalDisplayRecords = (int)list[0].RecordCount;
                tableData.recordsTotal = (int)list[0].RecordCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        reportList.ElementAt(i).ReportKey.ToString(),
                        reportList.ElementAt(i).ReportID ?? "",
                        reportList.ElementAt(i).StartDate.HasValue ? reportList.ElementAt(i).StartDate.Value.ToShortDateString() : null,
                        reportList.ElementAt(i).TimeIntervalUnitTypeName != null ? reportList.ElementAt(i).TimeIntervalUnitTypeName : string.Empty,
                        reportList.ElementAt(i).AdministrativeLevel1Name != null ? reportList.ElementAt(i).AdministrativeLevel1Name : string.Empty,
                        reportList.ElementAt(i).AdministrativeLevel2Name != null ? reportList.ElementAt(i).AdministrativeLevel2Name : string.Empty,
                        reportList.ElementAt(i).SettlementName != null ? reportList.ElementAt(i).SettlementName : string.Empty,
                        reportList.ElementAt(i).OrganizationAdministrativeName != null ? reportList.ElementAt(i).OrganizationAdministrativeName : string.Empty,
                        reportList.ElementAt(i).ReportKey.ToString()
                    };

                    tableData.data.Add(cols);
                }

                _isFirstLoad = false;

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        public Task<IActionResult> PrintSearchResults([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var printViewModel = new AggregateReportSearchRequestModel
            {
                ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                StartDate = !string.IsNullOrEmpty(jsonObject["StartDate"]?.ToString())
                    ? DateTime.Parse(jsonObject["StartDate"].ToString())
                    : null,
                EndDate = !string.IsNullOrEmpty(jsonObject["EndDate"]?.ToString())
                    ? DateTime.Parse(jsonObject["EndDate"].ToString())
                    : null,
                AggregateReportTypeID = (long)AggregateDiseaseReportTypes.HumanAggregateDiseaseReport,
                AdministrativeUnitTypeID = !string.IsNullOrEmpty(jsonObject["AdministrativeUnitTypeID"]?.ToString()) &
                                           jsonObject["AdministrativeUnitTypeID"]?.ToString() != "-1"
                    ? long.Parse(jsonObject["AdministrativeUnitTypeID"]?.ToString() ?? string.Empty)
                    : null,
                TimeIntervalTypeID = !string.IsNullOrEmpty(jsonObject["TimeIntervalTypeID"]?.ToString()) &
                                     jsonObject["TimeIntervalTypeID"]?.ToString() != "-1"
                    ? long.Parse(jsonObject["TimeIntervalTypeID"]?.ToString() ?? string.Empty)
                    : null,
                AdministrativeUnitID = !string.IsNullOrEmpty(jsonObject["AdministrativeUnitID"]?.ToString()) &
                                       jsonObject["AdministrativeUnitID"]?.ToString() != "-1"
                    ? long.Parse(jsonObject["AdministrativeUnitID"]?.ToString() ?? string.Empty)
                    : null
            };

            if (printViewModel.OrganizationID != null)
            {
                printViewModel.OrganizationID =
                    !string.IsNullOrEmpty(jsonObject["OrganizationID"]?.ToString()) &
                    jsonObject["OrganizationID"].ToString() != "-1"
                        ? long.Parse(jsonObject["OrganizationID"].ToString())
                        : null;
            }

            printViewModel.Page = !string.IsNullOrEmpty(jsonObject["pageNo"].ToString())
                ? int.Parse(jsonObject["pageNo"].ToString())
                : 1;
            printViewModel.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
            printViewModel.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
            printViewModel.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
            printViewModel.SortColumn = !string.IsNullOrEmpty(jsonObject["SortColumn"].ToString())
                ? jsonObject["SortColumn"].ToString()
                : "FormID";
            printViewModel.SortOrder = !string.IsNullOrEmpty(jsonObject["SortOrder"].ToString())
                ? jsonObject["SortOrder"].ToString()
                : SortConstants.Descending;

            var printParameters = new List<KeyValuePair<string, string>>
            {
                new("LangID", GetCurrentLanguage()),
                new("ApplySiteFiltrationIndicator",
                    printViewModel.ApplySiteFiltrationIndicator.ToString())
            };
            if (printViewModel.StartDate != null)
                printParameters.Add(new KeyValuePair<string, string>("StartDate", printViewModel.StartDate != null ? printViewModel.StartDate.Value.ToString("d" ,uiCultureInfo) : string.Empty));
            if (printViewModel.EndDate != null) 
                printParameters.Add(new KeyValuePair<string, string>("EndDate", printViewModel.EndDate != null ? printViewModel.EndDate.Value.ToString("d", uiCultureInfo) : string.Empty));
            printParameters.Add(new KeyValuePair<string, string>("OrganizationID", printViewModel.OrganizationID != null ? printViewModel.OrganizationID.ToString() : string.Empty));
            printParameters.Add(new KeyValuePair<string, string>("pageNo", printViewModel.Page.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("pageSize", "50000"));
            printParameters.Add(new KeyValuePair<string, string>("UserSiteID", printViewModel.UserSiteID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("UserEmployeeID", printViewModel.UserEmployeeID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("UserOrganizationID", printViewModel.UserOrganizationID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("sortColumn", printViewModel.SortColumn));
            printParameters.Add(new KeyValuePair<string, string>("sortOrder", printViewModel.SortOrder));
            printParameters.Add(new KeyValuePair<string, string>("PersonID", printViewModel.UserEmployeeID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("AdministrativeUnitID", printViewModel.AdministrativeUnitID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("AdministrativeUnitTypeID", printViewModel.AdministrativeUnitTypeID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("TimeIntervalTypeID", printViewModel.TimeIntervalTypeID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("AggregateReportTypeID", ((long)AggregateDiseaseReportTypes.HumanAggregateDiseaseReport).ToString()));
            printParameters.Add(new KeyValuePair<string, string>("PrintDateTime", DateTime.Parse(jsonObject["printDateTime"].ToString()).ToString(uiCultureInfo) ));
            var pageViewModel = new AggregateReportSearchViewModel
            {
                PrintParameters = System.Text.Json.JsonSerializer.Serialize(printParameters),
                aggregateReportSearchRequestModel = new AggregateReportSearchRequestModel()
            };

            pageViewModel.aggregateReportSearchRequestModel = printViewModel;
            pageViewModel.ReportName = "SearchForHumanAggregateDiseaseReport";
            return Task.FromResult<IActionResult>(PartialView("_PrintAggregateDiseaseReportPartial", pageViewModel));
        }

        [HttpPost]
        public async Task<IActionResult> BuildDetailRowContentAsync([FromBody] EIDSSSGridChildRowParameter eIDSSSGridChildRowParameter)
        {
            var request = new AggregateReportSearchRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport),
                ReportID = eIDSSSGridChildRowParameter.Id,
                ApplySiteFiltrationIndicator = false,
                Page = 1,
                PageSize = 10,
                SortColumn = "ReportID",
                SortOrder = SortConstants.Descending
            };

            var response = await _aggregateReportClient.GetAggregateReportList(request);
            if (!(response?.Count > 0)) return Ok(string.Empty);
            var viewFromAnotherController = await this.RenderViewToStringAsync("~/Views/Shared/_AggregateDiseaseReportDetailReadOnlyPartial.cshtml", response.FirstOrDefault());
            return Ok(viewFromAnotherController);
        }

        #endregion

        #endregion
    }
}