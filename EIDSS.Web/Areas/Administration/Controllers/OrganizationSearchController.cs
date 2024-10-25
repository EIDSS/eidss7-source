#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Organization;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

#endregion

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "OrganizationSearch")]
    [Area("Administration")]
    public class OrganizationSearchController : BaseController
    {
        #region Global Values

        private readonly IOrganizationClient _organizationClient;
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContext;
        private readonly UserPermissions _organizationPermissions;

        #endregion

        #region Constructors/Invocations

        /// <summary>
        /// 
        /// </summary>
        /// <param name="organizationClient"></param>
        /// <param name="httpContext"></param>
        /// <param name="configuration"></param>
        /// <param name="tokenService"></param>
        /// <param name="logger"></param>
        public OrganizationSearchController(IOrganizationClient organizationClient, IHttpContextAccessor httpContext, IConfiguration configuration,
            ITokenService tokenService, ILogger<OrganizationSearchController> logger) :
            base(logger, tokenService)
        {
            _organizationClient = organizationClient;
            _configuration = configuration;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _httpContext = httpContext;
            _organizationPermissions = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
        }

        public IViewComponentResult Invoke(bool recordSelectionIndicator, bool showInModalIndicator)
        {
            OrganizationSearchViewModel model = new()
            {
                AccessoryCodeSelect = new Select2Configruation(),
                OrganizationTypeSelect = new Select2Configruation(),
                SearchCriteria = new OrganizationGetRequestModel(),
                OrganizationPermissions = _organizationPermissions,
                RecordSelectionIndicator = recordSelectionIndicator,
                ShowInModalIndicator = showInModalIndicator,
                SearchLocationViewModel = new LocationViewModel
                {
                    SetUserDefaultLocations = true,
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = true,
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

            if (_httpContext.HttpContext?.Request != null)
            {
                if (!string.IsNullOrEmpty(_httpContext.HttpContext.Request.Cookies["OrganizationSearchPerformedIndicator"]))
                {
                    if (_httpContext.HttpContext.Request.Cookies["OrganizationSearchPerformedIndicator"] == "true")
                    {
                        var postParameterDefinitions = new { SearchCriteria_OrganizationID = "", SearchCriteria_AbbreviatedName = "", SearchCriteria_FullName = "", AccessoryCodeSelect = "", AdminLevel1Value = "", AdminLevel2Value = "", Settlement = "", SearchCriteria_ShowForeignOrganizationsIndicator = "", OrganizationTypeSelect = "" };
                        var searchCriteria = JsonConvert.DeserializeAnonymousType(_httpContext.HttpContext.Request.Cookies["OrganizationSearchCriteria"] ?? string.Empty, postParameterDefinitions);

                        model.ShowSearchResults = true;
                        if (!string.IsNullOrEmpty(searchCriteria.ToString()))
                        {
                            model.SearchCriteria.AccessoryCode =
                                string.IsNullOrEmpty(searchCriteria.AccessoryCodeSelect)
                                    ? null
                                    : Convert.ToInt32(searchCriteria.AccessoryCodeSelect);
                            model.SearchCriteria.OrganizationID =
                                string.IsNullOrEmpty(searchCriteria.SearchCriteria_OrganizationID)
                                    ? null
                                    : searchCriteria.SearchCriteria_OrganizationID;
                            model.SearchCriteria.FullName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_FullName)
                                ? null
                                : searchCriteria.SearchCriteria_FullName;
                            model.SearchCriteria.AbbreviatedName =
                                string.IsNullOrEmpty(searchCriteria.SearchCriteria_AbbreviatedName)
                                    ? null
                                    : searchCriteria.SearchCriteria_AbbreviatedName;
                            model.SearchCriteria.OrganizationTypeID =
                                string.IsNullOrEmpty(searchCriteria.OrganizationTypeSelect)
                                    ? null
                                    : Convert.ToInt64(searchCriteria.OrganizationTypeSelect);
                            model.SearchCriteria.ShowForeignOrganizationsIndicator =
                                !string.IsNullOrEmpty(searchCriteria
                                    .SearchCriteria_ShowForeignOrganizationsIndicator) &&
                                Convert.ToBoolean(searchCriteria.SearchCriteria_ShowForeignOrganizationsIndicator);

                            model.SearchLocationViewModel.SetUserDefaultLocations = false;
                            model.SearchLocationViewModel.AdminLevel1Value =
                                string.IsNullOrEmpty(searchCriteria.AdminLevel1Value)
                                    ? null
                                    : Convert.ToInt64(searchCriteria.AdminLevel1Value);
                            model.SearchLocationViewModel.AdminLevel2Value =
                                string.IsNullOrEmpty(searchCriteria.AdminLevel2Value)
                                    ? null
                                    : Convert.ToInt64(searchCriteria.AdminLevel2Value);
                            model.SearchLocationViewModel.Settlement = string.IsNullOrEmpty(searchCriteria.Settlement)
                                ? null
                                : Convert.ToInt64(searchCriteria.Settlement);
                        }
                    }
                }
            }

            var viewData = new ViewDataDictionary<OrganizationSearchViewModel>(ViewData, model);
            return new ViewViewComponentResult
            {
                ViewData = viewData
            };
        }

        #endregion

        #region Search Organizations

        /// <summary>
        /// 
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetOrganizationList")]
        public async Task<JsonResult> GetOrganizationList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
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
                var postParameterDefinitions = new { SearchCriteria_OrganizationID = "", SearchCriteria_AbbreviatedName = "", SearchCriteria_FullName = "", AccessoryCodeSelect = "", SiteID = "", AdminLevel1Value = "", AdminLevel2Value = "", AdminLevel3Value = "", SearchCriteria_ShowForeignOrganizationsIndicator = "", OrganizationTypeSelect = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (!string.IsNullOrEmpty(Request.Cookies["OrganizationSearchPerformedIndicator"]))
                {
                    if (Request.Cookies["OrganizationSearchPerformedIndicator"] == "true")
                    {
                        if (!string.IsNullOrEmpty(Request.Cookies["OrganizationSearchCriteria"]))
                        {
                            searchCriteria = JsonConvert.DeserializeAnonymousType(Request.Cookies["OrganizationSearchCriteria"], postParameterDefinitions);

                            criteriaEnteredIndicator = true;
                        }

                        Response.Cookies.Append("OrganizationSearchPerformedIndicator", "false");
                    }
                }

                if (criteriaEnteredIndicator == false)
                {
                    if (!string.IsNullOrEmpty(searchCriteria.AccessoryCodeSelect)
                        || !string.IsNullOrEmpty(searchCriteria.SiteID)
                        || !string.IsNullOrEmpty(searchCriteria.AdminLevel1Value)
                        || !string.IsNullOrEmpty(searchCriteria.AdminLevel2Value)
                        || !string.IsNullOrEmpty(searchCriteria.OrganizationTypeSelect)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_AbbreviatedName)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_FullName)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_OrganizationID)
                        || !string.IsNullOrEmpty(searchCriteria.AdminLevel3Value)
                        || searchCriteria.SearchCriteria_ShowForeignOrganizationsIndicator == "true")
                    {
                        criteriaEnteredIndicator = true;
                    }
                }

                if (!criteriaEnteredIndicator) return Json(tableData);
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                //Get sorting values.
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                if (valuePair.Key == "OrganizationKey")
                    valuePair = new KeyValuePair<string, string>();

                var model = JsonConvert.DeserializeObject<OrganizationGetRequestModel>(dataTableQueryPostObj.postArgs);
                model.LanguageId = GetCurrentLanguage();
                model.Page = iPage;
                model.PageSize = iLength;
                //model.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "Order";
                model.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "AbbreviatedName"; 
                model.SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending;
                model.AbbreviatedName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_AbbreviatedName) ? null : searchCriteria.SearchCriteria_AbbreviatedName;
                model.AccessoryCode = string.IsNullOrEmpty(searchCriteria.AccessoryCodeSelect) ? null : Convert.ToInt32(searchCriteria.AccessoryCodeSelect);
                model.SiteID = string.IsNullOrEmpty(searchCriteria.SiteID) ? null : Convert.ToInt64(searchCriteria.SiteID);

                //Get lowest administrative level.
                if (!string.IsNullOrEmpty(searchCriteria.AdminLevel3Value))
                    model.AdministrativeLevelID = Convert.ToInt64(searchCriteria.AdminLevel3Value);
                else if (!string.IsNullOrEmpty(searchCriteria.AdminLevel2Value))
                    model.AdministrativeLevelID = Convert.ToInt64(searchCriteria.AdminLevel2Value);
                else if (!string.IsNullOrEmpty(searchCriteria.AdminLevel1Value))
                    model.AdministrativeLevelID = Convert.ToInt64(searchCriteria.AdminLevel1Value);
                else
                    model.AdministrativeLevelID = null;

                model.FullName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_FullName) ? null : searchCriteria.SearchCriteria_FullName;
                model.OrganizationID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_OrganizationID) ? null : searchCriteria.SearchCriteria_OrganizationID;
                model.OrganizationTypeID = string.IsNullOrEmpty(searchCriteria.OrganizationTypeSelect) ? null : Convert.ToInt64(searchCriteria.OrganizationTypeSelect);
                model.ShowForeignOrganizationsIndicator = !string.IsNullOrEmpty(searchCriteria.SearchCriteria_ShowForeignOrganizationsIndicator) && Convert.ToBoolean(searchCriteria.SearchCriteria_ShowForeignOrganizationsIndicator);

                var list = await _organizationClient.GetOrganizationList(model);
                IEnumerable<OrganizationGetListViewModel> organizationList = list;

                Response.Cookies.Append("OrganizationSearchCriteria", dataTableQueryPostObj.postArgs);

                if (list.Count <= 0) return Json(tableData);
                tableData.data.Clear();
                tableData.iTotalRecords = (int)list[0].RowCount;
                tableData.iTotalDisplayRecords = (int)list[0].RowCount;
                tableData.recordsTotal = (int)list[0].RowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        organizationList.ElementAt(i).OrganizationKey.ToString(),
                        organizationList.ElementAt(i).OrganizationKey.ToString(),
                        organizationList.ElementAt(i).AbbreviatedName ?? "",
                        organizationList.ElementAt(i).FullName ?? "",
                        organizationList.ElementAt(i).OrganizationID ?? "",
                        organizationList.ElementAt(i).AddressString ?? "",
                        organizationList.ElementAt(i).Order.ToString(),
                        organizationList.ElementAt(i).OrganizationKey.ToString(),
                        organizationList.ElementAt(i).OrganizationKey.ToString()
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

        [HttpPost]
        [Route("SetOrganizationSearchPerformedIndicator")]
        public JsonResult SetOrganizationSearchPerformedIndicator()
        {
            Response.Cookies.Append("OrganizationSearchPerformedIndicator", "true");

            return Json("");
        }

        #endregion
    }
}