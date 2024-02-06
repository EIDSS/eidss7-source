#region Usings

using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Outbreak.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;
using GISAdministrativeUnitTypes = EIDSS.ClientLibrary.Enumerations.GISAdministrativeUnitTypes;

#endregion

namespace EIDSS.Web.Areas.Outbreak.Controllers
{
    [Area("Outbreak")]
    [Controller]
    public class OutbreakPageController : BaseController
    {
        #region Globals

        public OutbreakPageViewModel OutbreakPageViewModel;
        private readonly ISiteClient _siteClient;
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly IOutbreakClient _outbreakClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfigurationClient _configurationClient;
        private readonly IStringLocalizer _localizer;
        private readonly UserPreferences _userPreferences;

        #endregion

        #region Constructors

        public OutbreakPageController(IOutbreakClient outbreakClient, ISiteClient siteClient, ICrossCuttingClient crossCuttingClient, IConfigurationClient configurationClient, IStringLocalizer localizer,
            ITokenService tokenService, ILogger<OutbreakPageController> logger) : base(logger, tokenService)
        {
            _outbreakClient = outbreakClient;
            _siteClient = siteClient;
            _crossCuttingClient = crossCuttingClient;
            _configurationClient = configurationClient;
            _localizer = localizer;
            _outbreakClient = outbreakClient;

            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = _authenticatedUser.Preferences;
            var userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            OutbreakPageViewModel = new OutbreakPageViewModel
            {
                CurrentLanguage = GetCurrentLanguage(),
                EidssGridConfiguration = new EIDSSGridConfiguration(),
                OutbreakPermissions = userPermissions,
                SearchCriteria = new OutbreakSessionSearchRequestModel(),
                OutbreakReportPrintViewModel = new OutbreakReportPrintViewModel
                {
                    ReportName = "SearchForOutbreaks"
                }
            };
        }

        #endregion

        #region Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public IActionResult Index()
        {
            return View(OutbreakPageViewModel);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="searchModel"></param>
        /// <returns></returns>
        [HttpPost]
        public Task<IActionResult> PrintOutbreakSessions([FromBody]  OutbreakSearchForOutbreaksPrint searchModel)
        {
            searchModel.LangID = GetCurrentLanguage();
            searchModel.ReportTitle = _localizer.GetString(HeadingResourceKeyConstants.OutbreakManagementListOutbreakManagementListHeading);
            searchModel.SiteID = _authenticatedUser.SiteId;
            searchModel.PersonID = _authenticatedUser.PersonId;
            searchModel.PageNumber = "1";
            searchModel.PageSize = (int.MaxValue - 1).ToString();

            var sortColumn = "INIT";

            searchModel.SortColumn = searchModel.SortColumn.Trim();
            if (searchModel.SortColumn ==
                _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListOutbreakIDColumnHeading))
                sortColumn = "OutbreakID";
            else if (searchModel.SortColumn ==
                _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListStatusColumnHeading))
                sortColumn = "OutbreakStatusTypeName";
            else if (searchModel.SortColumn ==
                     _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListTypeColumnHeading))
                sortColumn = "OutbreakTypeName";
            else if (searchModel.SortColumn ==
                     _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListAdministrativeLevel2ColumnHeading))
                sortColumn = "AdministrativeLevel2Name";
            else if (searchModel.SortColumn ==
                     _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListAdministrativeLevel3ColumnHeading))
                sortColumn = "AdministrativeLevel3Name";
            else if (searchModel.SortColumn ==
                _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListDiseaseColumnHeading))
                sortColumn = "DiseaseName";
            else if (searchModel.SortColumn ==
                     _localizer.GetString(ColumnHeadingResourceKeyConstants.OutbreakManagementListStartDateColumnHeading))
                sortColumn = "StartDate";

            OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters = new List<KeyValuePair<string, string>>
            {
                new("LangID", searchModel.LangID),
                new("ReportTitle", searchModel.ReportTitle),
                new("SortColumn", sortColumn),
                new("PageNumber", searchModel.PageNumber),
                new("SortOrder", searchModel.SortOrder),
                new("PageSize", searchModel.PageSize),
                new("OutbreakID", IsNullOrEmpty(searchModel.OutbreakID) ? Empty : searchModel.OutbreakID),
                new("QuickSearch", ""),
                new("UserSiteID", _authenticatedUser.SiteId),
                new("UserOrganizationID", _authenticatedUser.OfficeId.ToString()),
                new("UserEmployeeID", _authenticatedUser.PersonId),
                new("ApplySiteFiltrationIndicator", _authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel ? "1" : "0"),
                new("PrintDateTime", DateTime.Now.ToShortDateString().ToString(new CultureInfo(GetCurrentLanguage())))
            };

            if (!IsNullOrEmpty(searchModel.AdministrativeLevelID))
                OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("AdministrativeLevelID", searchModel.AdministrativeLevelID));
            if (!IsNullOrEmpty(searchModel.OutbreakTypeID))
                OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("OutbreakTypeID", searchModel.OutbreakTypeID));
            if (!IsNullOrEmpty(searchModel.OutbreakStatusTypeID))
                OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("OutbreakStatusTypeID", searchModel.OutbreakStatusTypeID));
            if (!IsNullOrEmpty(searchModel.StartDateFrom))
            {
                DateTime? startDate = Convert.ToDateTime(searchModel.StartDateFrom);
                OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("StartDateFrom", startDate.Value.ToString("d", cultureInfo)));
            }
            if (!IsNullOrEmpty(searchModel.StartDateTo))
            {
                DateTime? endDate = Convert.ToDateTime(searchModel.StartDateTo);
                OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("StartDateTo", endDate.Value.ToString("d", cultureInfo)));
            }
            if (!IsNullOrEmpty(searchModel.SearchDiagnosisGroup))
                OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("SearchDiagnosesGroup", searchModel.SearchDiagnosisGroup));

            OutbreakPageViewModel.OutbreakReportPrintViewModel.ReportName = "SearchForOutbreaks";
            OutbreakPageViewModel.OutbreakReportPrintViewModel.PrintParameters = System.Text.Json.JsonSerializer.Serialize(OutbreakPageViewModel.OutbreakReportPrintViewModel.Parameters);

            return Task.FromResult<IActionResult>(PartialView("_PrintOutbreakSessionsPartial", OutbreakPageViewModel));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<IActionResult> Search(OutbreakSessionSearchRequestModel request)
        {
            await BuildSessionLocationControl(null);

            var outbreakStatusTypes = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OutbreakStatus, (int)AccessoryCodes.NoneHACode);
            if (outbreakStatusTypes.Any(x => x.IdfsBaseReference ==
                                             (long)OutbreakSessionStatus.InProgress))
            {
                OutbreakPageViewModel.DefaultOutbreakStatusTypeName = outbreakStatusTypes.First(x =>
                    x.IdfsBaseReference == (long)OutbreakSessionStatus.InProgress).Name;
            }

            return View(OutbreakPageViewModel);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var iPage = dataTableQueryPostObj.page;
            var iLength = dataTableQueryPostObj.length;

            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            if (valuePair.Key == "idfOutbreak")
            {
                valuePair = new KeyValuePair<string, string>("INIT", valuePair.Value);
            }

            long? locationId = null;

            for (var i = 1; i < 4; i++)
            {
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["AdminLevel" + i + "Value"] == null) continue;
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["AdminLevel" + i + "Value"]?.ToString() != "")
                {
                    locationId = long.Parse(JObject.Parse(dataTableQueryPostObj.postArgs)["AdminLevel" + i + "Value"]?.ToString() ?? Empty);
                }
            }

            long? outbreakTypeId = null;
            long? searchDiagnosesGroup = null;
            DateTime? startDateFrom = null;
            DateTime? startDateTo = null;
            long? outbreakStatusTypeId = null;
            string outbreakId = null;

            if (JObject.Parse(dataTableQueryPostObj.postArgs)["OutbreakId"] != null)
            {
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["OutbreakId"]?.ToString() != "")
                {
                    outbreakId = JObject.Parse(dataTableQueryPostObj.postArgs)["OutbreakId"]?.ToString();
                }
            }

            if (JObject.Parse(dataTableQueryPostObj.postArgs)["OutbreakTypeId"] != null)
            {
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["OutbreakTypeId"]?.ToString() != "")
                {
                    outbreakTypeId = long.Parse(JObject.Parse(dataTableQueryPostObj.postArgs)["OutbreakTypeId"]?.ToString() ?? Empty);
                }
            }

            if (JObject.Parse(dataTableQueryPostObj.postArgs)["idfsDiagnosisOrDiagnosisGroup"] != null)
            {
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["idfsDiagnosisOrDiagnosisGroup"]?.ToString() != "")
                {
                    searchDiagnosesGroup = long.Parse(JObject.Parse(dataTableQueryPostObj.postArgs)["idfsDiagnosisOrDiagnosisGroup"]?.ToString() ?? Empty);
                }
            }

            if (JObject.Parse(dataTableQueryPostObj.postArgs)["AdvancedSearchIndicator"] != null)
            {
                // Use the user entered start date from and to, if any.
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["SearchCriteria_StartDateFrom"] != null)
                {
                    if (JObject.Parse(dataTableQueryPostObj.postArgs)["SearchCriteria_StartDateFrom"]?.ToString() != "")
                    {
                        startDateFrom =
                            DateTime.Parse(JObject.Parse(dataTableQueryPostObj.postArgs)["SearchCriteria_StartDateFrom"]?.ToString() ??
                                           Empty);
                    }
                }

                if (JObject.Parse(dataTableQueryPostObj.postArgs)["SearchCriteria_StartDateTo"] != null)
                {
                    if (JObject.Parse(dataTableQueryPostObj.postArgs)["SearchCriteria_StartDateTo"]?.ToString() != "")
                    {
                        startDateTo =
                            DateTime.Parse(JObject.Parse(dataTableQueryPostObj.postArgs)["SearchCriteria_StartDateTo"]?.ToString() ??
                                           Empty);
                    }
                }
            }
            else
            {
                // Default settings of the dates.
                // BR: by default, when the “Outbreak Management List” page is displayed, the system shall display a list of Outbreak Session records
                // where the Start Date is within the last 365 days (from current date to a date minus 365 days).
                startDateTo = DateTime.Today;
                startDateFrom = startDateTo.Value.AddDays(-365);
            }

            if (JObject.Parse(dataTableQueryPostObj.postArgs)["idfsOutbreakStatus"] != null)
            {
                if (JObject.Parse(dataTableQueryPostObj.postArgs)["idfsOutbreakStatus"]?.ToString() != "")
                {
                    outbreakStatusTypeId = long.Parse(JObject.Parse(dataTableQueryPostObj.postArgs)["idfsOutbreakStatus"]?.ToString() ?? Empty);
                }
            }

            var request = new OutbreakSessionListRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                QuickSearch = JObject.Parse(dataTableQueryPostObj.postArgs)["SearchBox"]?.ToString(),
                PageNumber = iPage,
                PageSize = iLength,
                SortColumn = !IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "OutbreakStatusOrder",
                SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Descending,
                ApplySiteFiltrationIndicator = _authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel,
                UserEmployeeID = long.Parse(_authenticatedUser.PersonId),
                UserOrganizationID = _authenticatedUser.OfficeId,
                UserSiteID = long.Parse(_authenticatedUser.SiteId),
                OutbreakID = outbreakId,
                OutbreakTypeID = outbreakTypeId,
                SearchDiagnosesGroup = searchDiagnosesGroup,
                StartDateFrom = startDateFrom,
                StartDateTo = startDateTo,
                OutbreakStatusTypeID = outbreakStatusTypeId,
                AdministrativeLevelID = locationId
            };

            ModelState.ClearValidationState(nameof(OutbreakSessionListRequestModel));
            if (!TryValidateModel(request, nameof(OutbreakSessionListRequestModel)))
            {
                return Json(request);
            }

            var osl = await _outbreakClient.GetSessionList(request);

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = osl.Count == 0 ? 0 : (int)osl[0].TotalCount,
                iTotalDisplayRecords = osl.Count == 0 ? 0 : (int)osl[0].RecordCount,
                draw = dataTableQueryPostObj.draw
            };

            if (osl.Count <= 0) return Json(tableData);
            {
                foreach (var cols in osl.Select(t => new List<string>
                         {
                             t.idfOutbreak.ToString(),
                             t.OutbreakID ?? "",
                             t.OutbreakStatusTypeName ?? "",
                             t.OutbreakTypeName ?? "",
                             t.AdministrativeLevel2Name ?? "",
                             t.AdministrativeLevel3Name ?? "",
                             t.DiseaseName ?? "",
                             t.StartDate == null ? "" : $"{t.StartDate:d}"
                         }))
                {
                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="administrativeUnitType"></param>
        /// <returns></returns>
        private async Task BuildSessionLocationControl(long? administrativeUnitType)
        {
            var sessionLocationViewModel = new LocationViewModel();

            var siteDetails = await _siteClient.GetSiteDetails(OutbreakPageViewModel.CurrentLanguage, Convert.ToInt64(_authenticatedUser.SiteId), Convert.ToInt64(_authenticatedUser.EIDSSUserId));
            if (siteDetails != null)
            {
                var aggregateSettingsGetRequestModel = new AggregateSettingsGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfCustomizationPackage = siteDetails.CustomizationPackageID,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = SortConstants.Ascending
                };

                await _configurationClient.GetAggregateSettings(aggregateSettingsGetRequestModel);

                if (administrativeUnitType != null)
                {
                    OutbreakPageViewModel.SearchAdministrativeUnitTypeID = administrativeUnitType.Value;
                }
                else
                {
                    OutbreakPageViewModel.SearchAdministrativeUnitTypeID = (long)GISAdministrativeLevels.AdminLevel1;
                }

                OutbreakPageViewModel.SessionLocationViewModel = new LocationViewModel
                {
                    AdminLevel0Value = siteDetails.CountryID
                };
                sessionLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                OutbreakPageViewModel.SessionLocationViewModel.AdminLevel1Value = _userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;

                OutbreakPageViewModel.SessionLocationViewModel.AdminLevel2Value = _userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;

                // Location Control
                sessionLocationViewModel.IsHorizontalLayout = true;
                sessionLocationViewModel.ShowAdminLevel0 = false;
                sessionLocationViewModel.ShowAdminLevel1 = true;
                sessionLocationViewModel.ShowAdminLevel2 = true;
                sessionLocationViewModel.ShowAdminLevel3 = true;
                sessionLocationViewModel.ShowAdminLevel4 = false;
                sessionLocationViewModel.ShowAdminLevel5 = false;
                sessionLocationViewModel.ShowAdminLevel6 = false;
                sessionLocationViewModel.ShowSettlement = false;
                sessionLocationViewModel.ShowSettlementType = false;
                sessionLocationViewModel.ShowStreet = false;
                sessionLocationViewModel.ShowApartment = false;
                sessionLocationViewModel.ShowPostalCode = false;
                sessionLocationViewModel.ShowCoordinates = false;
                sessionLocationViewModel.ShowBuildingHouseApartmentGroup = false;

                sessionLocationViewModel.AdminLevel1Text = _localizer.GetString(FieldLabelResourceKeyConstants.Region1FieldLabel);
                sessionLocationViewModel.AdminLevel2Text = _localizer.GetString(FieldLabelResourceKeyConstants.Rayon1FieldLabel);
                sessionLocationViewModel.AdminLevel3Text = _localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
                sessionLocationViewModel.AdminLevel4Text = _localizer.GetString(FieldLabelResourceKeyConstants.SettlementFieldLabel);

                OutbreakPageViewModel.SearchAdministrativeUnitTypeID = (long)GISAdministrativeLevels.AdminLevel1;

                switch (OutbreakPageViewModel.SearchAdministrativeUnitTypeID)
                {
                    case (long)GISAdministrativeLevels.AdminLevel1:
                        sessionLocationViewModel.AdminLevel1Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = false;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.EnableAdminLevel1 = true;
                        break;
                    case (long)GISAdministrativeLevels.AdminLevel2:
                        sessionLocationViewModel.AdminLevel1Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.AdminLevel2Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel2Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = false;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.IsDbRequiredAdminLevel2 = false;
                        sessionLocationViewModel.ShowAdminLevel2 = true;
                        break;
                    case (long)GISAdministrativeUnitTypes.Settlement:
                        sessionLocationViewModel.AdminLevel1Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.AdminLevel2Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel2Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.EnableAdminLevel1 = true;
                        sessionLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        sessionLocationViewModel.ShowAdminLevel2 = true;
                        sessionLocationViewModel.EnableAdminLevel2 = true;
                        break;
                    default:
                        sessionLocationViewModel.AdminLevel1Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.AdminLevel2Value = OutbreakPageViewModel.SessionLocationViewModel.AdminLevel2Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.EnableAdminLevel1 = true;
                        sessionLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        sessionLocationViewModel.ShowAdminLevel2 = true;
                        sessionLocationViewModel.EnableAdminLevel2 = true;
                        break;
                }
            }
            OutbreakPageViewModel.SessionLocationViewModel = sessionLocationViewModel;
        }

        #endregion

        public class OutbreakSearchForOutbreaksPrint
        {
            public string LangID { get; set; }
            public string ReportTitle { get; set; }
            public string SiteID { get; set; }
            public string SortColumn { get; set; }
            public string PageNumber { get; set; }
            public string SortOrder { get; set; }
            public string PageSize { get; set; }
            public string OutbreakID { get; set; }
            public string OutbreakTypeID { get; set; }
            public string SearchDiagnosisGroup { get; set; }
            public string StartDateFrom { get; set; }
            public string StartDateTo { get; set; }
            public string OutbreakStatusTypeID { get; set; }
            public string AdministrativeLevelID { get; set; }
            public string UserSiteID { get; set; }
            public string UserOrganizationID { get; set; }
            public string UserEmployeeID { get; set; }
            public string ApplySiteFiltrationIndicator { get; set; }
            public string PersonID { get; set; }
        }
    }
}
