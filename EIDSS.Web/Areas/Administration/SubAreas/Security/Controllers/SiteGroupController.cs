#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SiteGroup;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;
using static System.String;
using JsonSerializer = System.Text.Json.JsonSerializer;


#endregion

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    public class SiteGroupController : BaseController
    {
        #region Global Values

        private readonly ISiteGroupClient _siteGroupClient;
        private readonly ISiteClient _siteClient;
        private readonly IAdminClient _adminClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly IStringLocalizer _localizer;
        private readonly IHttpContextAccessor _httpContext;

        private readonly UserPermissions _siteGroupPermissions;

        #endregion

        #region Constructors

        public SiteGroupController(ISiteGroupClient siteGroupClient, ISiteClient siteClient,
            IAdminClient adminClient, ICrossCuttingClient crossCuttingClient, IConfiguration configuration, IStringLocalizer localizer, IHttpContextAccessor httpContext, 
            ITokenService tokenService, ILogger<SiteGroupController> logger) : base(logger, tokenService)
        {
            _siteGroupClient = siteGroupClient;
            _siteClient = siteClient;
            _adminClient = adminClient;
            _crossCuttingClient = crossCuttingClient;
            _configuration = configuration;
            _localizer = localizer;
            _httpContext = httpContext;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _siteGroupPermissions = GetUserPermissions(PagePermission.CanManageEIDSSSites);
        }

        #endregion

        #region Search Site Groups

        public async Task<IActionResult> List()
        {
            SiteGroupSearchViewModel model = new()
            {
                SiteGroupTypeSelect = new Select2Configruation(),
                SearchCriteria = new SiteGroupGetRequestModel(),
                SiteGroupPermissions = _siteGroupPermissions,
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
                    IsDbRequiredAdminLevel2 = false,
                    IsDbRequiredApartment = false,
                    IsDbRequiredBuilding = false,
                    IsDbRequiredHouse = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    IsDbRequiredStreet = false,
                    IsDbRequiredPostalCode = false,
                    AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                }
            };

            if (_httpContext.HttpContext?.Request != null)
            {
                if (!IsNullOrEmpty(_httpContext.HttpContext.Request.Cookies["SiteGroupSearchPerformedIndicator"]))
                {
                    if (_httpContext.HttpContext.Request.Cookies["SiteGroupSearchPerformedIndicator"] == "true")
                    {
                        var postParameterDefinitions = new { SearchCriteria_SiteGroupName = "", SiteGroupTypeSelect = "", AdminLevel1Value = "", AdminLevel2Value = "", SettlementType = "", AdminLevel3Value = "" };
                        var searchCriteria = JsonConvert.DeserializeAnonymousType(_httpContext.HttpContext.Request.Cookies["SiteGroupSearchCriteria"] ?? Empty, postParameterDefinitions);

                        model.ShowSearchResults = true;
                        model.SearchCriteria.SiteGroupName = IsNullOrEmpty(searchCriteria.SearchCriteria_SiteGroupName) ? null : searchCriteria.SearchCriteria_SiteGroupName;
                        model.SearchCriteria.SiteGroupTypeID = IsNullOrEmpty(searchCriteria.SiteGroupTypeSelect) ? null : Convert.ToInt64(searchCriteria.SiteGroupTypeSelect);

                        var siteGroupTypes = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.SiteGroupType, (int)AccessoryCodes.NoneHACode);
                        if (siteGroupTypes.Any(x => x.IdfsBaseReference == model.SearchCriteria.SiteGroupTypeID))
                        {
                            var defaultData = new Select2DataItem
                            {
                                id = model.SearchCriteria.SiteGroupTypeID.ToString(),
                                text = siteGroupTypes.First(x =>
                                    x.IdfsBaseReference == model.SearchCriteria.SiteGroupTypeID).Name
                            };
                            model.SiteGroupTypeSelect.defaultSelect2Selection = defaultData;
                        }

                        if (!IsNullOrEmpty(searchCriteria.AdminLevel3Value))
                        {
                            model.SearchCriteria.AdministrativeLevelID =
                                Convert.ToInt64(searchCriteria.AdminLevel2Value);
                            model.SearchLocationViewModel.AdminLevel1Value = Convert.ToInt64(searchCriteria.AdminLevel1Value);
                            model.SearchLocationViewModel.AdminLevel2Value = Convert.ToInt64(searchCriteria.AdminLevel2Value);

                            if (!IsNullOrEmpty(searchCriteria.SettlementType))
                            {
                                model.SearchLocationViewModel.SettlementType =
                                    Convert.ToInt64(searchCriteria.SettlementType);
                            }

                            model.SearchLocationViewModel.SettlementId = Convert.ToInt64(searchCriteria.AdminLevel3Value);
                        }
                        else if (!IsNullOrEmpty(searchCriteria.AdminLevel2Value))
                        {
                            model.SearchCriteria.AdministrativeLevelID =
                                Convert.ToInt64(searchCriteria.AdminLevel2Value);
                            model.SearchLocationViewModel.AdminLevel1Value = Convert.ToInt64(searchCriteria.AdminLevel1Value);
                            model.SearchLocationViewModel.AdminLevel2Value = Convert.ToInt64(searchCriteria.AdminLevel2Value);

                            if (!IsNullOrEmpty(searchCriteria.SettlementType))
                            {
                                model.SearchLocationViewModel.SettlementType =
                                    Convert.ToInt64(searchCriteria.SettlementType);
                            }
                        }
                        else
                        {
                            model.SearchCriteria.AdministrativeLevelID = IsNullOrEmpty(searchCriteria.AdminLevel1Value)
                                ? null
                                : Convert.ToInt64(searchCriteria.AdminLevel1Value);

                            if (model.SearchCriteria.AdministrativeLevelID is not null)
                                model.SearchLocationViewModel.AdminLevel1Value = Convert.ToInt64(searchCriteria.AdminLevel1Value);
                        }
                    }
                }
            }

            ViewBag.JavaScriptFunction = model.ShowSearchResults ? "hideSiteGroupSearchCriteria();" : "showSiteGroupSearchCriteria();";

            return View(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> GetSiteGroupList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
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
                var postParameterDefinitions = new { SearchCriteria_SiteGroupName = "", SiteGroupTypeSelect = "", AdminLevel1Value = "", AdminLevel2Value = "", SettlementType = "", AdminLevel3Value = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (!IsNullOrEmpty(Request.Cookies["SiteGroupSearchPerformedIndicator"]))
                {
                    if (Request.Cookies["SiteGroupSearchPerformedIndicator"] == "true")
                    {
                        if (!IsNullOrEmpty(Request.Cookies["SiteGroupSearchCriteria"]))
                        {
                            searchCriteria = JsonConvert.DeserializeAnonymousType(Request.Cookies["SiteGroupSearchCriteria"], postParameterDefinitions);

                            criteriaEnteredIndicator = true;
                        }

                        Response.Cookies.Append("SiteGroupSearchPerformedIndicator", "false");
                    }
                }

                if (criteriaEnteredIndicator == false)
                {
                    if (!IsNullOrEmpty(searchCriteria.SearchCriteria_SiteGroupName)
                        || !IsNullOrEmpty(searchCriteria.SiteGroupTypeSelect)
                        || !IsNullOrEmpty(searchCriteria.AdminLevel1Value)
                        || !IsNullOrEmpty(searchCriteria.AdminLevel2Value) 
                        || !IsNullOrEmpty(searchCriteria.SettlementType) 
                        || !IsNullOrEmpty(searchCriteria.AdminLevel3Value))
                    {
                        criteriaEnteredIndicator = true;
                    }
                }

                if (!criteriaEnteredIndicator) return Json(tableData);
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                // Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var model = JsonConvert.DeserializeObject<SiteGroupGetRequestModel>(dataTableQueryPostObj.postArgs);
                model.LanguageId = GetCurrentLanguage();
                model.Page = iPage;
                model.PageSize = iLength;
                model.SortColumn = !IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "SiteGroupName";
                model.SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending;
                model.SiteGroupName = IsNullOrEmpty(searchCriteria.SearchCriteria_SiteGroupName) ? null : searchCriteria.SearchCriteria_SiteGroupName;
                model.SiteGroupTypeID = IsNullOrEmpty(searchCriteria.SiteGroupTypeSelect) ? null : Convert.ToInt64(searchCriteria.SiteGroupTypeSelect);

                if (!IsNullOrEmpty(searchCriteria.AdminLevel3Value))
                    model.AdministrativeLevelID = Convert.ToInt64(searchCriteria.AdminLevel3Value);
                else if (!IsNullOrEmpty(searchCriteria.AdminLevel2Value))
                    model.AdministrativeLevelID = Convert.ToInt64(searchCriteria.AdminLevel2Value);
                else
                    model.AdministrativeLevelID = IsNullOrEmpty(searchCriteria.AdminLevel1Value) ? null : Convert.ToInt64(searchCriteria.AdminLevel1Value);

                var list = await _siteGroupClient.GetSiteGroupList(model);
                IEnumerable<SiteGroupGetListViewModel> siteGroupList = list;

                Response.Cookies.Append("SiteGroupSearchCriteria", dataTableQueryPostObj.postArgs);

                if (list.Count <= 0) return Json(tableData);
                tableData.data.Clear();
                var rowCount = list[0].RowCount;
                if (rowCount != null)
                {
                    tableData.iTotalRecords = (int) rowCount;
                    tableData.iTotalDisplayRecords = (int) rowCount;
                    tableData.recordsTotal = (int) rowCount;
                }

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        siteGroupList.ElementAt(i).SiteGroupID.ToString(),
                        siteGroupList.ElementAt(i).SiteGroupName ?? "",
                        siteGroupList.ElementAt(i).SiteGroupTypeName ?? "",
                        siteGroupList.ElementAt(i).AdministrativeLevelName ?? "",
                        siteGroupList.ElementAt(i).SiteGroupID.ToString()
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
        [Route("SetSiteGroupSearchPerformedIndicator")]
        public JsonResult SetSiteGroupSearchPerformedIndicator()
        {
            Response.Cookies.Append("SiteGroupSearchPerformedIndicator", "true");

            return Json("");
        }

        #endregion

        #region Site Group Details

        /// <summary>
        /// Sets up a new site group or gets the details for an existing site group.
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public async Task<IActionResult> Details(long? id)
        {
            try
            {
                SiteGroupDetailsViewModel model = new()
                {
                    SiteGroupInformationSection = new SiteGroupInformationSectionViewModel
                    {
                        DetailsLocationViewModel = new LocationViewModel
                        {
                            CallingObjectID = "SiteGroupInformationSection_",
                            IsHorizontalLayout = true,
                            EnableAdminLevel1 = true,
                            ShowAdminLevel1 = true,
                            ShowAdminLevel2 = true,
                            ShowAdminLevel3 = true,
                            ShowAdminLevel4 = false,
                            ShowAdminLevel5 = false,
                            ShowAdminLevel6 = false,
                            ShowBuildingHouseApartmentGroup = false,
                            ShowElevation = false,
                            ShowCoordinates = false,
                            ShowPostalCode = false,
                            ShowStreet = false,
                            ShowSettlement = true,
                            ShowSettlementType = true,
                            IsDbRequiredAdminLevel1 = false,
                            IsDbRequiredAdminLevel2 = false,
                            IsDbRequiredApartment = false,
                            IsDbRequiredBuilding = false,
                            IsDbRequiredHouse = false,
                            IsDbRequiredSettlement = false,
                            IsDbRequiredSettlementType = false,
                            IsDbRequiredStreet = false,
                            IsDbRequiredPostalCode = false,
                            AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                        },
                        SiteGroupDetails = new SiteGroupGetDetailViewModel(),
                        SiteGroupTypeSelect = new Select2Configruation(),
                        SiteGroupTypeModal = new EIDSSModalConfiguration(),
                        CentralSiteSelect = new Select2Configruation(),
                        LoggedInUserPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables)
                    },
                    SitesSection = new SitesSectionViewModel
                    {
                        SiteGroupPermissions = _siteGroupPermissions
                    },
                    SiteGroupPermissions = _siteGroupPermissions
                };

                if (id == null) return View(model);
                model.SiteGroupInformationSection.SiteGroupDetails = await _siteGroupClient.GetSiteGroupDetails(GetCurrentLanguage(), (long)id);
                model.SiteGroupInformationSection.DetailsLocationViewModel.AdminLevel1Value = model.SiteGroupInformationSection.SiteGroupDetails.AdministrativeLevel1ID;
                model.SiteGroupInformationSection.DetailsLocationViewModel.AdminLevel2Value = model.SiteGroupInformationSection.SiteGroupDetails.AdministrativeLevel2ID;
                model.SiteGroupInformationSection.DetailsLocationViewModel.SettlementType = model.SiteGroupInformationSection.SiteGroupDetails.SettlementTypeID;
                model.SiteGroupInformationSection.DetailsLocationViewModel.SettlementId = model.SiteGroupInformationSection.SiteGroupDetails.SettlementID;

                _httpContext.HttpContext?.Response.Cookies.Append("SiteGroupSearchPerformedIndicator", "true");

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("SaveSiteGroup")]
        public async Task<JsonResult> SaveSiteGroup([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                SiteGroupDetailsViewModel model = new()
                {
                    SiteGroupInformationSection = new SiteGroupInformationSectionViewModel
                    {
                        SiteGroupDetails = new SiteGroupGetDetailViewModel
                        {
                            SiteGroupID = IsNullOrEmpty(jsonObject["SiteGroupID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["SiteGroupID"]),
                            SiteGroupName = IsNullOrEmpty(jsonObject["SiteGroupName"]?.ToString()) ? null : jsonObject["SiteGroupName"].ToString(),
                            SiteGroupDescription = jsonObject["Description"]?.ToString(),
                            CentralSiteID = IsNullOrEmpty(jsonObject["CentralSiteID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["CentralSiteID"].ToString()),
                            RowStatus = jsonObject["ActiveStatusIndicator"]?.ToString() == "true" ? 0 : 1,
                            LocationID = IsNullOrEmpty(jsonObject["LocationID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["LocationID"].ToString()),
                            SiteGroupTypeID = Convert.ToInt64(jsonObject["SiteGroupTypeID"]?.ToString())
                        }
                    },
                    Sites = jsonObject["Sites"]?.ToString()
                };

                ModelState.ClearValidationState(nameof(SiteGroupGetDetailViewModel));
                if (!TryValidateModel(model.SiteGroupInformationSection.SiteGroupDetails, nameof(SiteGroupGetDetailViewModel)))
                {
                    model.ErrorMessage = "The record is not valid.  Please verify all data and correct any errors.";
                    return Json(model);
                }

                if (!ModelState.IsValid) return Json(model);
                SiteGroupSaveRequestModel request = new() { SiteGroupDetails = model.SiteGroupInformationSection.SiteGroupDetails, Sites = model.Sites, AuditUserName = authenticatedUser.UserName, LanguageID = GetCurrentLanguage() };
                var response = await _siteGroupClient.SaveSiteGroup(request);

                if (response.ReturnCode != null)
                {
                    switch (response.ReturnCode)
                    {
                        // Success
                        case 0:
                            model.SiteGroupInformationSection.SiteGroupDetails.SiteGroupID ??= response.KeyId;
                            model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage);
                            break;
                        default:
                            throw new ApplicationException("Unable to save site group.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to save site group.");
                }

                return Json(model);
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
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> AddSiteGroupType([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);
                var serializer = JsonSerializer.Serialize(data);
                
                BaseReferenceSaveRequestModel request = new()
                {
                    intHACode = null,
                    Default = jsonObject["strDefault"]?.ToString(),
                    Name = jsonObject["strName"]?.ToString(),
                    LanguageId = GetCurrentLanguage(),
                    ReferenceTypeId = (long)ReferenceTypes.SiteGroupType,
                    EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                if (jsonObject["intOrder"] == null)
                    request.intOrder = 0;
                else
                {
                    request.intOrder = !IsNullOrEmpty(jsonObject["intOrder"].ToString()) ? Parse(jsonObject["intOrder"].ToString()) : 0;
                }

                var response = await _adminClient.SaveBaseReference(request);

                if (response.ReturnMessage != "DOES EXIST") return Json(response);
                response.strDuplicatedField = request.Default;
                response.strClientPageMessage = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), response.strDuplicatedField);

                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json("");
        }

        /// <summary>
        /// Deletes a site group.
        /// </summary>
        /// <param name="siteGroupId"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> Delete(long siteGroupId)
        {
            try
            {
                var response = await _siteGroupClient.DeleteSiteGroup(siteGroupId, true);

                if (response.ReturnCode != null)
                {
                    if (response.ReturnCode == 0)
                    {
                        return RedirectToAction(nameof(List), "SiteGroup");
                    }
                    else if (response.ReturnCode == -1)
                    {
                        SiteGroupDetailsViewModel model = new()
                        {
                            SiteGroupInformationSection = new SiteGroupInformationSectionViewModel
                            {
                                SiteGroupTypeSelect = new Select2Configruation(),
                                SiteGroupTypeModal = new EIDSSModalConfiguration(),
                                CentralSiteSelect = new Select2Configruation(),
                                DetailsLocationViewModel = new LocationViewModel
                                {
                                    CallingObjectID = "SiteGroupInformationSection_",
                                    IsHorizontalLayout = true,
                                    EnableAdminLevel1 = true,
                                    ShowAdminLevel1 = true,
                                    ShowAdminLevel2 = true,
                                    ShowAdminLevel3 = false,
                                    ShowBuildingHouseApartmentGroup = false,
                                    ShowElevation = false,
                                    ShowCoordinates = false,
                                    ShowPostalCode = false,
                                    ShowStreet = false,
                                    ShowSettlement = true,
                                    ShowSettlementType = true,
                                    IsDbRequiredAdminLevel1 = false,
                                    IsDbRequiredAdminLevel2 = false,
                                    IsDbRequiredApartment = false,
                                    IsDbRequiredBuilding = false,
                                    IsDbRequiredHouse = false,
                                    IsDbRequiredSettlement = false,
                                    IsDbRequiredSettlementType = false,
                                    IsDbRequiredStreet = false,
                                    IsDbRequiredPostalCode = false,
                                    AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                                },
                                SiteGroupDetails = await _siteGroupClient.GetSiteGroupDetails(GetCurrentLanguage(), siteGroupId)
                            },
                            ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage)
                        };

                        ViewBag.JavaScriptFunction = "showErrorModal('" + model.ErrorMessage + "');";

                        return View("Details", model);
                    }
                    else
                    {
                        throw new ApplicationException("Unable to delete site group.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to delete site group.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sites Section

        /// <summary>
        /// 
        /// </summary>
        /// <param name="siteGroupId"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> GetSiteList([FromBody] long? siteGroupId)
        {
            try
            {
                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0,
                    draw = 1
                };

                if (!ModelState.IsValid) return Json(tableData);
                if (siteGroupId == null) return Json(tableData);
                // Sorting
                KeyValuePair<string, string> valuePair = new();

                SiteGetRequestModel model = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue,
                    SortColumn = !IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "SiteName",
                    SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending,
                    SiteGroupID = (long)siteGroupId
                };

                var list = await _siteClient.GetSiteList(model);
                IEnumerable<SiteGetListViewModel> siteList = list;

                if (list.Count <= 0) return Json(tableData);
                tableData.iTotalRecords = list[0].TotalRowCount;
                tableData.iTotalDisplayRecords = list[0].TotalRowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        siteList.ElementAt(i).SiteToSiteGroupID.ToString(),
                        siteList.ElementAt(i).SiteID.ToString(),
                        siteList.ElementAt(i).SiteName,
                        siteList.ElementAt(i).EIDSSSiteID,
                        RowStatusTypes.Active.ToString(),
                        "R",
                        siteList.ElementAt(i).SiteToSiteGroupID.ToString()
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

        /// <summary>
        /// Deletes a site to site group row.
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult DeleteSiteToSiteGroup([FromBody] JsonElement data)
        {
            try
            {
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(data);
        }

        #endregion
    }
}