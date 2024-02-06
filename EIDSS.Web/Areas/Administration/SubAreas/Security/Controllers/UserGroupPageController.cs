using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Administration.Security.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static System.String;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    [Controller]
    public class UserGroupPageController : BaseController
    {
        #region Globals

        private readonly IUserGroupClient _userGroupClient;
        private readonly UserPermissions _userGroupPermissions;

        #endregion

        #region Constructor

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userGroupClient"></param>
        public UserGroupPageController(IUserGroupClient userGroupClient, ITokenService tokenService,
            ILogger<UserGroupPageController> logger) : base(logger, tokenService)
        {
            _userGroupClient = userGroupClient;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userGroupPermissions = GetUserPermissions(PagePermission.CanManageUserGroups);
        }

        #endregion

        #region Search User Group

        /// <summary>
        /// Loads the list view. This is the default view for this controller.
        /// </summary>
        /// <returns></returns>
        public IActionResult Index()
        {
            UserGroupSearchViewModel model = new()
            {
                SearchCriteria = new UserGroupGetRequestModel() { SortColumn = "strName", SortOrder = SortDirection.Ascending },
                UserGroupPermissions = _userGroupPermissions,
                ShowSearchResults = false
            };

            ViewBag.JavaScriptFunction = "showUserGroupSearchCriteria();";

            return View(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpPost()]
        public IActionResult Index(UserGroupSearchViewModel model)
        {
            if (!ModelState.IsValid) return View(model);
            ViewBag.JavaScriptFunction = "hideUserGroupSearchCriteria();";
            model.UserGroupPermissions = _userGroupPermissions;
            model.ShowSearchResults = true;
            TempData["SearchCriteria"] = System.Text.Json.JsonSerializer.Serialize(model);

            return View(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost()]
        [Route("GetUserGroupList")]
        public async Task<JsonResult> GetUserGroupList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
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

                if (!ModelState.IsValid) return Json(tableData);
                var postParameterDefinitions = new { SearchCriteria_strName = "", SearchCriteria_strDescription = ""};
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (dataTableQueryPostObj.postArgs == "{}") return Json(tableData);
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                // Sorting
                KeyValuePair<string, string> valuePair = new();
                valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "strName";
                if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "idfsEmployeeGroupName")
                {
                    strSortColumn = valuePair.Key;
                }

                var model = JsonConvert.DeserializeObject<UserGroupGetRequestModel>(dataTableQueryPostObj.postArgs);
                model.LanguageId = GetCurrentLanguage();
                model.Page = iPage;
                model.PageSize = iLength;
                model.SortColumn = strSortColumn;
                model.SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortDirection.Ascending;
                model.strName = searchCriteria.SearchCriteria_strName == "" ? null : searchCriteria.SearchCriteria_strName;
                model.strDescription = searchCriteria.SearchCriteria_strDescription == "" ? null : searchCriteria.SearchCriteria_strDescription;
                model.idfsSite = long.Parse(authenticatedUser.SiteId);

                var list = new List<UserGroupViewModel>();
                list = await _userGroupClient.GetUserGroupList(model);

                if (list.Count <= 0) return Json(tableData);
                tableData.data.Clear();
                tableData.iTotalRecords = list[0].TotalRowCount;
                tableData.iTotalDisplayRecords = list[0].TotalRowCount;
                tableData.recordsTotal = list[0].TotalRowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        list.ElementAt(i).idfEmployeeGroup.ToString(),
                        list.ElementAt(i).idfsEmployeeGroupName.ToString(),
                        list.ElementAt(i).strName,
                        list.ElementAt(i).strDescription
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
        public async Task<IActionResult> Delete([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);
                if (jsonObject["idfEmployeeGroup"] != null && jsonObject["idfsEmployeeGroupName"] != null)
                {
                    response = await _userGroupClient.DeleteUserGroup(long.Parse(jsonObject["idfEmployeeGroup"].ToString()), long.Parse(jsonObject["idfsEmployeeGroupName"].ToString()), long.Parse(authenticatedUser.SiteId), authenticatedUser.UserName);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(response.ReturnMessage);
        }

        #endregion

        #region User Group Details

        public IActionResult Details(long? id)
        {
            UserGroupPageDetailsViewModel model = new()
            {
                UserGroupKey = id
            };

            return View(model);
        }

        #endregion

    }
}
