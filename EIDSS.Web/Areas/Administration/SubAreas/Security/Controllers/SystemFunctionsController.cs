using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.Json;
using EIDSS.Domain.ViewModels;
using Microsoft.Extensions.Localization;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Localization.Constants;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    [Controller]

    public class SystemFunctionsController : BaseController
    {
        #region Globals

        private readonly ISystemFunctionsClient _systemFunctionsClient;
        private readonly IStringLocalizer _localizer;
        private readonly UserPermissions _accessWithRightManagement;
        private readonly UserPermissions _accessToSystemFunctionList;

        private readonly ICrossCuttingClient _crossCuttingClient;


        #endregion

        #region Constructor
        public SystemFunctionsController(ISystemFunctionsClient systemFunctionsClient, ICrossCuttingClient crossCuttingClient, IStringLocalizer localizer, ITokenService tokenService,
            ILogger<SystemFunctionsController> logger) : base(logger, tokenService)
        {
            _systemFunctionsClient = systemFunctionsClient;
            _accessWithRightManagement= GetUserPermissions(PagePermission.CanWorkWithAccessRightsManagement);
            _accessToSystemFunctionList = GetUserPermissions(PagePermission.AccessToSystemFunctionsList);
             authenticatedUser = _tokenService.GetAuthenticatedUser();
            _localizer = localizer;
            _crossCuttingClient = crossCuttingClient;


        }

        #endregion

        #region Search System Functions

        /// <summary>
        /// List
        /// </summary>
        /// <returns></returns>
        public IActionResult List()
        {
            SystemFunctionSearchViewModel model = new()
            {
                SearchCriteria = new SystemFunctionsGetRequestModel() { SortColumn = "SystemFunctionName", SortOrder = "ASC" },
                ShowSearchResults = true,
                SysemFunctionListReadPermission = _accessToSystemFunctionList.Read,
                SysemFunctionListWritePermission = _accessToSystemFunctionList.Write,
                AcccessRightWritePermission = _accessWithRightManagement.Write,
                AcccessRightReadPermission = _accessWithRightManagement.Read,
                NoAccessInformationMessage = "User has insufficientPermissions"
        };
            //ViewBag.JavaScriptFunction = "showSystemFunctionsSearchCriteria();";
            return View(model);
        }

        [HttpPost()]
        public IActionResult List(SystemFunctionSearchViewModel model)
        {         
            ViewBag.JavaScriptFunction = "hideSystemFunctionsSearchCriteria();";
            model.ShowSearchResults = true;
            model.SysemFunctionListReadPermission = _accessToSystemFunctionList.Read;
            model.SysemFunctionListWritePermission = _accessToSystemFunctionList.Write;
            model.AcccessRightWritePermission = _accessWithRightManagement.Write;
            model.AcccessRightReadPermission = _accessWithRightManagement.Read;
            model.NoAccessInformationMessage = "User has insufficientPermissions";
            TempData["SearchCriteria"] = JsonSerializer.Serialize(model);
            return View(model);
        }

        /// <summary>
        /// GetSystemFunctionsList
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost()]
        public async Task<JsonResult> GetSystemFunctionsList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var postParameterDefinitions = new { SearchBox = "" };
                var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                List<SystemFunctionViewModel> list = new List<SystemFunctionViewModel>();
                if (dataTableQueryPostObj.postArgs.Length > 0)
                {
                    //Sorting
                    KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
                    valuePair = dataTableQueryPostObj.ReturnSortParameter();

                    string strSortColumn = "intOrder";
                    if (!String.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "idfsBaseReference")
                    {
                        strSortColumn = valuePair.Key;
                    }
                     strSortColumn = "intOrder";

                    var searchCriteria = new SystemFunctionsGetRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = dataTableQueryPostObj.page,
                        PageSize = dataTableQueryPostObj.length,
                        SortColumn = strSortColumn,
                        SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc",
                        FunctionName = referenceType.SearchBox
                    };

                  

                    list = await _systemFunctionsClient.GetSystemFunctionList(searchCriteria);
                }

                TableData tableData = new TableData();
                tableData.data = new List<List<string>>();
                tableData.iTotalRecords = list.Count() == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
                tableData.iTotalDisplayRecords = list.Count() == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
                tableData.draw = dataTableQueryPostObj.draw;

                if (list.Count > 0)
                {
                    int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                    for (int i = 0; i < list.Count; i++)
                    {
                        List<string> cols = new()
                        {
                            (row + i + 1).ToString(),
                            list.ElementAt(i).idfsBaseReference.ToString(),
                            list.ElementAt(i).SystemFunction,
                            list.ElementAt(i).idfsBaseReference.ToString()

                        };

                        tableData.data.Add(cols);
                    }            
                }
                
                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region System Function Details

        public async Task<IActionResult> Details(long id)
        {
            SystemFunctionsDetailsViewModel model = new();
            string systemFunctionName = "";
            try
            {
                var searchCriteria = new SystemFunctionsGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 200,
                    SortColumn = "SystemFunctionName",
                    SortOrder = "asc",
                    FunctionName = ""
                };

                var list = await _systemFunctionsClient.GetSystemFunctionList(searchCriteria);
                if (list!= null)
                {
                    systemFunctionName = list.FirstOrDefault(l => l.idfsBaseReference == id).SystemFunction;
                }

                var requestModel = new SystemFunctionsActorsGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 1000,
                    SortColumn = "Name",
                    SortOrder = "asc",
                    Name = null,
                    Id = Convert.ToInt64(id),
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    UserOrganizationID = Convert.ToInt64(authenticatedUser.Institution),
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)

            };


                //var systemFunctionUserGroupAndUserList = await _systemFunctionsClient.GetSystemFunctionActorList(requestModel);
                model = new()
                {
                    SysemFunctionListReadPermission = _accessToSystemFunctionList.Read,
                    SysemFunctionListWritePermission = _accessToSystemFunctionList.Write,
                    AcccessRightWritePermission = _accessWithRightManagement.Write,
                    AcccessRightReadPermission = _accessWithRightManagement.Read,
                    SystemFunctionId = id,
                    //SystemFunctionUserGroupAndUserList = systemFunctionUserGroupAndUserList,
                    SystemFunctionName = systemFunctionName,
                    SearchPersonAndEmployeeGroupViewModel = new SearchPersonAndEmployeeGroupViewModel()
                    {
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        SystemFunctionId = id,
                        
                        ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.ActorsHeading),
                        ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.EmployeeType, 0).ConfigureAwait(false),
                        SearchCriteria = new PersonAndEmployeeGroupGetRequestModel()
                        {
                            SystemFunctionId = id,
                            LanguageId = GetCurrentLanguage(),
                        }

                    }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }


            return View(model);
        }

        [HttpPost()]
        public async Task<IActionResult> Details(SystemFunctionsDetailsViewModel model)
        {

            try
            {
                long systemFunctionId = 0;

                var requestModel = new SystemFunctionsActorsGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 1000,
                    SortColumn = "Name",
                    SortOrder = "asc",
                    Name = null,
                    Id = 0,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    UserOrganizationID = Convert.ToInt64(authenticatedUser.Institution),
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                //if (TempData["SystemFunctionId"] != null)
                //{
                //    systemFunctionId = Convert.ToInt64(TempData["SystemFunctionId"].ToString());
                //}
                //TempData.Keep();

                if (model == null)
                {
                    model = new();
                }
                //model.SystemFunctionId = systemFunctionId;
                model.SystemFunctionUserGroupAndUserList = await _systemFunctionsClient.GetSystemFunctionActorList(requestModel);
                model.SearchPersonAndEmployeeGroupViewModel = new SearchPersonAndEmployeeGroupViewModel()
                {
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    //SystemFunctionId = systemFunctionId,
                    ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.ActorsHeading),
                    ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.EmployeeType, 0).ConfigureAwait(false),
                    SearchCriteria = new PersonAndEmployeeGroupGetRequestModel()
                    {
                        // SystemFunctionId = systemFunctionId,
                        LanguageId = GetCurrentLanguage(),
                    }

                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return View(model);

        }

        [HttpPost()]
        public async Task<JsonResult> GetAccessUserListAsync([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var postParameterDefinitions = new { searchBox = "", systemFunctionId="" };
                var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);
                List<SystemFunctionUserGroupAndUserViewModel> list = new List<SystemFunctionUserGroupAndUserViewModel>();

                if (dataTableQueryPostObj.postArgs.Length > 0)
                {
                    //Sorting
                    KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
                    valuePair = dataTableQueryPostObj.ReturnSortParameter();
                    var orderData = Newtonsoft.Json.JsonConvert.DeserializeObject<IEnumerable<IDictionary<string, object>>>(dataTableQueryPostObj.order.ToString());
                    var orderArray = orderData.Select(d => d.Values.ToArray()).ToArray();
                    var strSortColumn = "Name";
                    var srtSortOrder = "asc";
                    if (Convert.ToInt32(orderArray[0][0]) == 2)
                        strSortColumn = "Name";
                    if (Convert.ToInt32(orderArray[0][0]) == 3)
                        strSortColumn = "Type";
                    srtSortOrder = Convert.ToString(orderArray[0][1]);
                    var requestModel = new SystemFunctionsActorsGetRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = dataTableQueryPostObj.page,
                        PageSize = dataTableQueryPostObj.length,
                        SortColumn = strSortColumn,
                        SortOrder = srtSortOrder,
                        Name = referenceType.searchBox,
                        Id = Convert.ToInt64(referenceType.systemFunctionId),
                        UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        UserOrganizationID = Convert.ToInt64(authenticatedUser.Institution),
                        UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                    };

                    list = await _systemFunctionsClient.GetSystemFunctionActorList(requestModel);
                }

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount,
                    iTotalDisplayRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount,
                    draw = dataTableQueryPostObj.draw
                };

                if (list.Count > 0)
                {
                    int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                    for (int i = 0; i < list.Count; i++)
                    {
                        List<string> cols = new()
                        {
                            (row + i + 1).ToString(),
                            list.ElementAt(i).id.ToString(),
                            list.ElementAt(i).Name,
                            list.ElementAt(i).TypeName,

                        };

                        tableData.data.Add(cols);
                    }
                }

                return Json(tableData);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }


        }


        //[HttpGet()]
        //public async Task<JsonResult> GetAccessUserListAsync([FromQuery] long systemFunctionId)
        //{
        //    TableData tableData = new()
        //    {
        //        data = new List<List<string>>(),
        //        draw = 1,
        //        iTotalRecords = 0,
        //        iTotalDisplayRecords = 0
        //    };

        //    try
        //    {
        //        //TempData["SystemFunctionId"] = systemFunctionId;

        //        List<SystemFunctionUserGroupAndUserViewModel> list = new();
        //        list = await _systemFunctionsClient.GetSystemFunctionActorList(GetCurrentLanguage(), systemFunctionId);
               
        //        if (list.Count > 0)
        //        {
        //            tableData.iTotalRecords = list.Count;
        //            tableData.iTotalDisplayRecords = list.Count;
        //            for (int i = 0; i < list.Count; i++)
        //            {
        //                List<string> cols = new()
        //                {
        //                    list.ElementAt(i).id.ToString(),
        //                    list.ElementAt(i).Name,
        //                    list.ElementAt(i).TypeName,

        //                };

        //                tableData.data.Add(cols);
        //            }
        //        }
               
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, null);
        //        throw;
        //    }

        //    return Json(tableData);

        //}

        [HttpPost()]
        public async Task<JsonResult> GetPermissionList([FromBody] SystemFunctionPermissionGetRequestModel request)
        {
            try
            {
                request.LanguageId = GetCurrentLanguage();
                List<SystemFunctionUserPermissionViewModel> list = new();
                list = await _systemFunctionsClient.GetSystemFunctionPermissionList(request);
                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    draw = 1,
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0
                };

                if (list.Count > 0)
                {
                    tableData.iTotalRecords = list.Count;
                    tableData.iTotalDisplayRecords = list.Count;
                    for (int i = 0; i < list.Count; i++)
                    {
                        List<string> cols = new()
                        {
                            list.ElementAt(i).SystemFunctionID.ToString(),
                            list.ElementAt(i).IdfEmployee.ToString(),
                            list.ElementAt(i).SystemFunctionOperationID.ToString(),
                            list.ElementAt(i).StrSystemFunctionOperation,
                            list.ElementAt(i).OperationStatus == 0 ? "true" : "false"
                        };

                        tableData.data.Add(cols);
                    }
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
        public async Task<IActionResult> SavePermissions([FromBody] List<RoleSystemFunctionOperation> operations)
        {
            try
            {
                string strRoleFunctionsOperations = JsonSerializer.Serialize(operations);
                SystemFunctionsSaveRequestModel systemFunctionsUserPermissionsSetParams = new SystemFunctionsSaveRequestModel()
                {
                    rolesandfunctions = strRoleFunctionsOperations,
                    langageId = GetCurrentLanguage(),
                    roleID = (long)operations.FirstOrDefault().RoleId,
                    user = authenticatedUser.UserName
                };

                var response = await _crossCuttingClient.SaveSystemFunctions(systemFunctionsUserPermissionsSetParams);

                var model = new SaveResponseViewModel();
                if (response.ReturnCode != null)
                {
                    switch (response.ReturnCode)
                    {
                        // Success
                        case 0:
                            model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                            break;

                        default:
                            throw new ApplicationException("Unable to save permissions.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to save permission.");
                }

                model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);

                return Json(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null); 
                throw;
            }

        }
        public async Task<IActionResult> SaveSystemFunctionsPersonAndEmployeeGroups([FromBody] List<RoleSystemFunctionModel> roleSystemFunctionModels )
        {
            try
            {

                var systemFunctionId = roleSystemFunctionModels.FirstOrDefault().SystemFunction;
                var roleId = roleSystemFunctionModels.FirstOrDefault().RoleId;
                var systemFuncionList = await _crossCuttingClient.GetSystemFunctionPermissions(GetCurrentLanguage(), systemFunctionId);
                var filteredSystemFuncionList = systemFuncionList.Where(f => f.intRowStatus == 0);

                var roleSystemFunctionOoperationList = new List<RoleSystemFunctionOperationModel>();
                foreach (var item in roleSystemFunctionModels)
                {
                    foreach (var systemFunction in filteredSystemFuncionList)
                    {
                        var roleSystemFunctionOoperation = new RoleSystemFunctionOperationModel();
                        roleSystemFunctionOoperation.RoleId = item.RoleId;
                        roleSystemFunctionOoperation.SystemFunction = systemFunctionId;
                        roleSystemFunctionOoperation.Operation = systemFunction.SystemFunctionOperationID;
                        roleSystemFunctionOoperation.intRowStatus = 1;
                        roleSystemFunctionOoperationList.Add(roleSystemFunctionOoperation);
                    }
                }

                string strRoleFunctionsOperations = JsonSerializer.Serialize(roleSystemFunctionOoperationList);
                SystemFunctionsUserPermissionsSetParams systemFunctionsUserPermissionsSetParams = new SystemFunctionsUserPermissionsSetParams()
                {
                    rolesandfunctions = strRoleFunctionsOperations,
                    langageId = GetCurrentLanguage(),
                    roleID = roleId,
                    user = authenticatedUser.UserName
                };
                    
                var response = await _systemFunctionsClient.SaveSystemFunctionUsePermission(systemFunctionsUserPermissionsSetParams);

                var model = new SaveResponseViewModel();
                if (response.ReturnCode != null)
                {
                    switch (response.ReturnCode)
                    {
                        // Success
                        case 0:
                            model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                            break;

                        default:
                            throw new ApplicationException("Unable to add person or employee group.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to add person or employee group.");
                }

                model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);

                return Json(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

        }


        public async Task<IActionResult> DeleteSystemFunctionsPersonAndEmployeeGroups([FromBody] SystemFunctionsPersonAndEmpoyeeGroupDelRequestModel request)
        {
            try
            {
                var response = await _systemFunctionsClient.DeleteSystemFunctionPersonAndEmployeeGroup(request);

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

        }


        #endregion

    }
}
