using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class ILIAggregateSearchPageController : BaseController
    {
        private readonly ILIAggregatePageViewModel _pageViewModel;
        private readonly IILIAggregateFormClient _iliAggregateFormClient;
        private readonly IOrganizationClient _organizationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;

        public ILIAggregateSearchPageController(
            IILIAggregateFormClient iliAggregateFormClient,
            IOrganizationClient organizationClient,
            ITokenService tokenService,
            ILogger<ILIAggregateSearchPageController> logger, ICrossCuttingClient crossCuttingClient) : base(logger, tokenService)
        {
            _pageViewModel = new ILIAggregatePageViewModel();
            _organizationClient = organizationClient;
            _crossCuttingClient = crossCuttingClient;
            _iliAggregateFormClient = iliAggregateFormClient;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _pageViewModel.UserPermissions = userPermissions;
        }

        public async Task<IActionResult> Index()
        {
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            OrganizationGetRequestModel requestHuman = new()
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "Order",
                SortOrder = EIDSSConstants.SortConstants.Ascending,
                AccessoryCode = Convert.ToInt32(AccessoryCodeEnum.Human),
                ShowForeignOrganizationsIndicator = false
            };

            var lstHuman = await _organizationClient.GetOrganizationList(requestHuman);

            OrganizationGetRequestModel requestSyndromic = new()
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "Order",
                SortOrder = EIDSSConstants.SortConstants.Ascending,
                AccessoryCode = Convert.ToInt32(AccessoryCodeEnum.Syndromic),
                ShowForeignOrganizationsIndicator = false
            };

            var lstSyndromic = await _organizationClient.GetOrganizationList(requestSyndromic);
            var lstOrganizationsCombined = lstHuman.Concat(lstSyndromic).GroupBy(x => x.OrganizationKey).Select(x => x.FirstOrDefault()).ToList();

            _pageViewModel.HospitalList = lstOrganizationsCombined;

            OrganizationGetListViewModel item = new()
            {
                OrganizationKey = -1,
                FullName = string.Empty
            };

            _pageViewModel.HospitalList.Insert(0, item);
            _pageViewModel.DataEntrySiteList = _pageViewModel.HospitalList;

            //Default Weeks From to the first monday of the first week
            var dt = new DateTime(DateTime.Now.Year, 1, 1);

            while (dt.DayOfWeek != DayOfWeek.Monday)
            {
                dt = dt.AddDays(1);
            }

            _pageViewModel.WeeksFrom = dt;
            _pageViewModel.WeeksTo = DateTime.Now.Date;

            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                DateTime startDate = new();
                DateTime finishDate = new();

                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var request = new ILIAggregateFormSearchRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = iPage,
                    PageSize = iLength,
                    SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "FormID",
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Descending
                };

                var searchFilter = JObject.Parse(dataTableQueryPostObj.postArgs);

                request.FormID = searchFilter["txtFormID"]?.ToString() == string.Empty ? null : searchFilter["txtFormID"]?.ToString();
                request.LegacyFormID = searchFilter["txtLegacyFormID"]?.ToString() == string.Empty ? null : searchFilter["txtLegacyFormID"]?.ToString();

                if (!string.IsNullOrEmpty(request.FormID)) // ignore legacy form id, hospital, start date, and end date if form id is entered in search
                {
                    request.LegacyFormID = null;
                    request.AggregateHeaderID = null;
                    request.UserSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    request.UserOrganizationID = null;
                    request.UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId);
                    request.ApplySiteFiltrationIndicator = false;
                }
                else if (!string.IsNullOrEmpty(request.LegacyFormID)) // ignore form id, hospital, start date, and end date if legacy form id is entered in search
                {
                    request.FormID = null;
                    request.AggregateHeaderID = null;
                    request.UserSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    request.UserOrganizationID = null;
                    request.UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId);
                    request.ApplySiteFiltrationIndicator = false;
                }
                else
                {
                    request.HospitalID = long.Parse(searchFilter["ddlHospitalList"]?.ToString() ?? string.Empty);

                    if (!string.IsNullOrEmpty(searchFilter["WeeksFrom"]?.ToString()))
                    {
                        _ = DateTime.TryParse(searchFilter["WeeksFrom"].ToString(), out startDate);
                        var start = (int)startDate.DayOfWeek;
                        var target = 0;
                        if (target < start)
                        {
                            target += 7;
                            request.StartDate = startDate.AddDays(target - start);
                        }
                        else
                        {
                            request.StartDate = startDate;
                        }
                    }
                    else
                    {
                        request.StartDate = null;
                    }

                    if (!string.IsNullOrEmpty(searchFilter["WeeksTo"]?.ToString()))
                    {
                        _ = DateTime.TryParse(searchFilter["WeeksTo"].ToString(), out finishDate);
                        while (finishDate.DayOfWeek != DayOfWeek.Saturday)
                        {
                            finishDate = finishDate.AddDays(-1);
                        }
                        request.FinishDate = finishDate;
                    }
                    else
                    {
                        request.FinishDate = null;
                    }

                    // compare the From and To dates and return on error
                    // if either is null return
                    var result = DateTime.Compare(startDate, finishDate);
                    switch (result)
                    {
                        case < 0:
                            break;
                        case 0:
                            break;
                        default:
                            request.StartDate = request.FinishDate;
                            return Json("");
                    }

                    request.AggregateHeaderID = null;
                    request.UserSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    request.UserOrganizationID = null;
                    request.UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId);
                    request.ApplySiteFiltrationIndicator = false;
                }

                if (string.IsNullOrEmpty(request.FormID) &&
                    request.StartDate == null &&
                    request.FinishDate == null &&
                    request.HospitalID == -1)
                {
                    return Json("");
                }

                if (request.HospitalID == -1) request.HospitalID = null;

                var response = await _iliAggregateFormClient.GetILIAggregateList(request);
                IEnumerable<ILIAggregateViewModel> iliAggregateList = response;
                var r = JsonSerializer.Serialize(request);
                var tableData = new TableData
                {
                    data = new List<List<string>>(),
                    iTotalRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                    iTotalDisplayRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                    draw = dataTableQueryPostObj.draw
                };

                if (!iliAggregateList.Any()) return Json(tableData);
                for (var i = 0; i < iliAggregateList.Count(); i++)
                {
                    var cols = new List<string>
                    {
                        iliAggregateList.ElementAt(i).AggregateHeaderKey.ToString(),
                        iliAggregateList.ElementAt(i).FormID,
                        iliAggregateList.ElementAt(i).LegacyFormID,
                        iliAggregateList.ElementAt(i).StartDate.ToShortDateString() + " - " + iliAggregateList.ElementAt(i).EndDate.ToShortDateString(),
                        iliAggregateList.ElementAt(i).ILITablesList,
                        iliAggregateList.ElementAt(i).FormID
                    };
                    tableData.data.Add(cols);
                }

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public IActionResult Details()
        {
            try
            {
                _pageViewModel.Select2Configurations = new List<Select2Configruation>();
                _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
                _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<IActionResult> ShowPrintBarCodeScreen([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var printViewModel = new ILIAggregateFormSearchRequestModel
            {

                AggregateHeaderID = !string.IsNullOrEmpty(jsonObject["AggregateHeaderId"]?.ToString()) ? long.Parse(jsonObject["AggregateHeaderId"].ToString()) : null,
                ApplySiteFiltrationIndicator = !string.IsNullOrEmpty(jsonObject["ApplySiteFiltrationIndicator"]?.ToString()) && bool.Parse(jsonObject["ApplySiteFiltrationIndicator"].ToString()),
                StartDate = !string.IsNullOrEmpty(jsonObject["startDate"]?.ToString()) ? DateTime.Parse(jsonObject["startDate"].ToString()) : null,
                FinishDate = !string.IsNullOrEmpty(jsonObject["FinishDate"]?.ToString()) ? DateTime.Parse(jsonObject["FinishDate"].ToString()) : null,
                FormID = !string.IsNullOrEmpty(jsonObject["FormID"]?.ToString()) ? jsonObject["FormID"].ToString() : string.Empty,
                LegacyFormID = !string.IsNullOrEmpty(jsonObject["LegacyFormID"]?.ToString()) ? jsonObject["LegacyFormID"].ToString() : string.Empty,
                HospitalID = !string.IsNullOrEmpty(jsonObject["HospitalId"]?.ToString()) & jsonObject["HospitalId"]?.ToString() != "-1" ? long.Parse(jsonObject["HospitalId"]?.ToString() ?? string.Empty) : null,
                Page = !string.IsNullOrEmpty(jsonObject["pageNo"]?.ToString()) ? int.Parse(jsonObject["pageNo"].ToString()) : 1,
                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                UserEmployeeID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                UserOrganizationID = !string.IsNullOrEmpty(jsonObject["UserOrganizationId"].ToString()) ? long.Parse(jsonObject["UserOrganizationId"].ToString()) : null,
                LanguageId = !string.IsNullOrEmpty(jsonObject["FinishDate"].ToString()) ? jsonObject["FinishDate"].ToString() : string.Empty,
                SortColumn = !string.IsNullOrEmpty(jsonObject["SortColumn"].ToString()) ? jsonObject["SortColumn"].ToString() : "FormID",
                SortOrder = !string.IsNullOrEmpty(jsonObject["SortOrder"].ToString()) ? jsonObject["SortOrder"].ToString() : "desc"
            };

            if (!string.IsNullOrEmpty(jsonObject["startDate"].ToString()))
            {
                _ = DateTime.TryParse(jsonObject["startDate"].ToString(), out var startDate);
                var start = (int)startDate.DayOfWeek;
                var target = 0;
                if (target <= start) target += 7;
                printViewModel.StartDate = startDate.AddDays(target - start);
            }
            else printViewModel.StartDate = null;

            if (!string.IsNullOrEmpty(jsonObject["FinishDate"].ToString()))
            {
                _ = DateTime.TryParse(jsonObject["FinishDate"].ToString(), out var finishDate);
                while (finishDate.DayOfWeek != DayOfWeek.Saturday)
                {
                    finishDate = finishDate.AddDays(-1);
                }
                printViewModel.FinishDate = finishDate;
            }
            else printViewModel.FinishDate = null;

            var printParameters = new List<KeyValuePair<string, string>>
            {
                new("LangID", GetCurrentLanguage()),
                new("AggregateHeaderID", printViewModel.AggregateHeaderID.ToString()),
                new("ApplySiteFiltrationIndicator", printViewModel.ApplySiteFiltrationIndicator.ToString())
            };
            if (printViewModel.StartDate != null)
                printParameters.Add(new KeyValuePair<string, string>("StartDate", printViewModel.StartDate != null ? printViewModel.StartDate.Value.ToString("d", uiCultureInfo) : string.Empty));
            if (printViewModel.FinishDate != null)
                printParameters.Add(new KeyValuePair<string, string>("FinishDate", printViewModel.FinishDate != null ? printViewModel.FinishDate.Value.ToString("d", uiCultureInfo) : string.Empty));
            printParameters.Add(new KeyValuePair<string, string>("FormID", printViewModel.FormID));
            printParameters.Add(new KeyValuePair<string, string>("LegacyFormID", printViewModel.LegacyFormID));
            printParameters.Add(new KeyValuePair<string, string>("HospitalID", printViewModel.HospitalID != null ? printViewModel.HospitalID.ToString() : string.Empty));
            printParameters.Add(new KeyValuePair<string, string>("pageNo", printViewModel.Page.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("PageSize", "50000"));
            printParameters.Add(new KeyValuePair<string, string>("UserSiteID", printViewModel.UserSiteID.ToString()));
            printParameters.Add(new KeyValuePair<string, string>("UserEmployeeID", printViewModel.UserEmployeeID != null ? printViewModel.UserEmployeeID.ToString() : string.Empty));
            printParameters.Add(new KeyValuePair<string, string>("UserOrganizationID", printViewModel.UserOrganizationID != null ? printViewModel.UserOrganizationID.ToString() : string.Empty));
            printParameters.Add(new KeyValuePair<string, string>("SortColumn", printViewModel.SortColumn));
            printParameters.Add(new KeyValuePair<string, string>("SortOrder", printViewModel.SortOrder));
            printParameters.Add(new KeyValuePair<string, string>("PrintDateTime", DateTime.Parse(jsonObject["printDateTime"]?.ToString() ?? string.Empty).ToString(uiCultureInfo)));
            _pageViewModel.PrintParameters = JsonSerializer.Serialize(printParameters);
            _pageViewModel.iLIAggregateFormSearchRequestModel = printViewModel;
            _pageViewModel.ReportName = "SearchForILIAggregateForm";
            return PartialView("_PrintILIAggregatePartial", _pageViewModel);
        }

        [HttpPost]
        public async Task<IActionResult> PrintBarCode([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var languageId = jsonObject["languageId"]?.ToString();
            var showBarCodePrintArea = jsonObject["showBarCodePrintArea"]?.ToString();

            var printViewModel = new UniqueNumberSchemaPrintModel
            {
                TypeOfBarCodeLabel = jsonObject["typeOfBarCodeLabel"]?.ToString(),
                LanguageId = jsonObject["languageId"]?.ToString(),
                ReportLanguageModels = await _crossCuttingClient.GetReportLanguageList(languageId),
                NoOfLabelsToPrint = jsonObject["noOfLabelsToPrint"]?.ToString(),
                Prefix = jsonObject["prefix"]?.ToString(),
                Site = jsonObject["site"]?.ToString(),
                Year = jsonObject["year"]?.ToString(),
                isDateChecked = Convert.ToBoolean(jsonObject["isDateChecked"]),
                isPrefixChecked = Convert.ToBoolean(jsonObject["isPrefixChecked"]),
                isSiteChecked = Convert.ToBoolean(jsonObject["isSiteChecked"]),
                isYearChecked = Convert.ToBoolean(jsonObject["isYearChecked"]),
                TypeOfBarCodeLabelName = jsonObject["typeOfBarCodeLabelName"].ToString(),
                ReportName = "PrintBarcodes",
                ShowBarCodePrintArea = showBarCodePrintArea == "true"
            };

            printViewModel.PrintParameters = new List<KeyValuePair<string, string>>
            {
                new("TypeOfBarCodeLabel", printViewModel.TypeOfBarCodeLabel),
                new("LangID", printViewModel.LanguageId),
                new("NoOfLabelsToPrint", printViewModel.NoOfLabelsToPrint),
                new("Prefix", printViewModel.isPrefixChecked ? "1" : "0"),
                new("Site", printViewModel.isSiteChecked ? printViewModel.Site : ""),
                new("Year", printViewModel.isYearChecked ? "1" : "0"),
                new("Date", printViewModel.isDateChecked ? "1" : "0")
            };

            printViewModel.BarcodeParametersJSON = JsonSerializer.Serialize(printViewModel.PrintParameters);

            return PartialView("_PrintBarCodePartial", printViewModel);
        }
    }
}