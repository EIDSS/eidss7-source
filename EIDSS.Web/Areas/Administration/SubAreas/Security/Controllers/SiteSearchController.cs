using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [ViewComponent(Name = "SiteSearch")]
    [Area("Administration")]
    [SubArea("Security")]
    public class SiteSearchController : BaseController
    {
        private readonly ISiteClient _siteClient;
        private readonly UserPermissions _sitePermissions;
        private readonly IHttpContextAccessor _httpContext;

        public SiteSearchController(ISiteClient siteClient, IHttpContextAccessor httpContext, ITokenService tokenService, ILogger<SiteSearchController> logger) :
            base(logger, tokenService)
        {
            _siteClient = siteClient;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _httpContext = httpContext;
            _sitePermissions = GetUserPermissions(PagePermission.AccessToEIDSSSitesList_ManagingDataAccessFromOtherSites);
        }

        public IViewComponentResult Invoke(bool recordSelectionIndicator, bool showInModalIndicator, int interfaceEditorSet)
        {
            SiteSearchViewModel model = new()
            {
                RecordSelectionIndicator = recordSelectionIndicator,
                ShowInModalIndicator = showInModalIndicator,
                SiteTypeSelect = new Select2Configruation(),
                OrganizationSelect = new Select2Configruation(),
                SearchCriteria = new SiteGetRequestModel(),
                SitePermissions = _sitePermissions,
                InterfaceEditorSet = interfaceEditorSet
            };

            if (_httpContext.HttpContext?.Request != null)
            {
                if (!string.IsNullOrEmpty(_httpContext.HttpContext.Request.Cookies["SiteSearchPerformedIndicator"]))
                {
                    if (_httpContext.HttpContext.Request.Cookies["SiteSearchPerformedIndicator"] == "true")
                    {
                        var postParameterDefinitions = new { SearchCriteria_SiteID = "", SearchCriteria_SiteCode = "", SearchCriteria_SiteName = "", SiteTypeSelect = "", SearchCriteria_HASCSiteID = "", OrganizationSelect = "" };
                        var searchCriteria = JsonConvert.DeserializeAnonymousType(_httpContext.HttpContext.Request.Cookies["SiteSearchCriteria"] ?? string.Empty, postParameterDefinitions);

                        model.ShowSearchResults = true;
                        model.SearchCriteria.EIDSSSiteID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteCode) ? null : searchCriteria.SearchCriteria_SiteCode;
                        model.SearchCriteria.HASCSiteID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_HASCSiteID) ? null : searchCriteria.SearchCriteria_HASCSiteID;
                        model.SearchCriteria.OrganizationID = string.IsNullOrEmpty(searchCriteria.OrganizationSelect) ? null : Convert.ToInt64(searchCriteria.OrganizationSelect);
                        model.SearchCriteria.SiteID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteID) ? null : Convert.ToInt64(searchCriteria.SearchCriteria_SiteID);
                        model.SearchCriteria.SiteName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteName) ? null : searchCriteria.SearchCriteria_SiteName;
                        model.SearchCriteria.SiteTypeID = string.IsNullOrEmpty(searchCriteria.SiteTypeSelect) ? null : Convert.ToInt64(searchCriteria.SiteTypeSelect);
                    }
                }
            }

            var viewData = new ViewDataDictionary<SiteSearchViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }

        [HttpPost()]
        public async Task<JsonResult> GetSiteList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var criteriaEnteredIndicator = false;

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0,
                    draw = dataTableQueryPostObj.draw
                };

                if (!ModelState.IsValid) return Json(tableData);
                var postParameterDefinitions = new { SearchCriteria_SiteID = "", SearchCriteria_EIDSSSiteID = "", SearchCriteria_SiteName = "", SiteTypeSelect = "", SearchCriteria_HASCSiteID = "", OrganizationSelect = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (!string.IsNullOrEmpty(Request.Cookies["SiteSearchPerformedIndicator"]))
                {
                    if (Request.Cookies["SiteSearchPerformedIndicator"] == "true")
                    {
                        if (!string.IsNullOrEmpty(Request.Cookies["SiteSearchCriteria"]))
                        {
                            searchCriteria = JsonConvert.DeserializeAnonymousType(Request.Cookies["SiteSearchCriteria"], postParameterDefinitions);

                            criteriaEnteredIndicator = true;
                        }

                        Response.Cookies.Append("SiteSearchPerformedIndicator", "false");
                    }
                }

                if (criteriaEnteredIndicator == false)
                {
                    if (!string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteID)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_EIDSSSiteID)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteName)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_HASCSiteID)
                        || !string.IsNullOrEmpty(searchCriteria.OrganizationSelect)
                        || !string.IsNullOrEmpty(searchCriteria.SiteTypeSelect))
                    {
                        criteriaEnteredIndicator = true;
                    }
                }

                if (criteriaEnteredIndicator != true) return Json(tableData);
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                // Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var model = JsonConvert.DeserializeObject<SiteGetRequestModel>(dataTableQueryPostObj.postArgs);
                model.LanguageId = GetCurrentLanguage();
                model.Page = iPage;
                model.PageSize = iLength;
                model.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "SiteName";
                model.SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending;
                model.EIDSSSiteID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_EIDSSSiteID) ? null : searchCriteria.SearchCriteria_EIDSSSiteID;
                model.HASCSiteID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_HASCSiteID) ? null : searchCriteria.SearchCriteria_HASCSiteID;
                model.OrganizationID = string.IsNullOrEmpty(searchCriteria.OrganizationSelect) ? null : Convert.ToInt64(searchCriteria.OrganizationSelect);
                model.SiteID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteID) ? null : Convert.ToInt64(searchCriteria.SearchCriteria_SiteID);
                model.SiteName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_SiteName) ? null : searchCriteria.SearchCriteria_SiteName;
                model.SiteTypeID = string.IsNullOrEmpty(searchCriteria.SiteTypeSelect) ? null : Convert.ToInt64(searchCriteria.SiteTypeSelect);

                var list = await _siteClient.GetSiteList(model);
                IEnumerable<SiteGetListViewModel> siteList = list;

                Response.Cookies.Append("SiteSearchCriteria", dataTableQueryPostObj.postArgs);

                if (list.Count <= 0) return Json(tableData);
                tableData.data.Clear();
                tableData.iTotalRecords = (int)list[0].RowCount;
                tableData.iTotalDisplayRecords = (int)list[0].RowCount;
                tableData.recordsTotal = (int)list[0].RowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        siteList.ElementAt(i).SiteID.ToString(),
                        (i + 1 + (iPage - 1) * iLength).ToString(),
                        siteList.ElementAt(i).SiteID.ToString(),
                        siteList.ElementAt(i).EIDSSSiteID ?? "",
                        siteList.ElementAt(i).SiteName ?? "",
                        siteList.ElementAt(i).SiteTypeName ?? "",
                        siteList.ElementAt(i).HASCSiteID ?? "",
                        siteList.ElementAt(i).OrganizationName,
                        siteList.ElementAt(i).SiteID.ToString()
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

        [HttpPost()]
        [Route("SetSiteSearchPerformedIndicator")]
        public JsonResult SetSiteSearchPerformedIndicator()
        {
            Response.Cookies.Append("SiteSearchPerformedIndicator", "true");

            return Json("");
        }
    }
}