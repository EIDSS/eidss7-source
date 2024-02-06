using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Administration.Security.ViewModels;
using EIDSS.Web.Administration.Security.ViewModels.UserGroup;
using EIDSS.Web.Administration.ViewModels.Administration;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.UserGroup;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [ViewComponent(Name = "UserGroupDetails")]
    [Area("Administration")]
    [SubArea("Security")]
    public class UserGroupDetailsController : BaseController
    {
        #region Globals

        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IUserGroupClient _userGroupClient;
        private readonly IStringLocalizer _localizer;
        private UserPermissions _userGroupPermissions;

        #endregion

        #region Constructor

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userGroupClient"></param>
        /// <param name="localizer"></param>
        public UserGroupDetailsController(IUserGroupClient userGroupClient, 
            ICrossCuttingClient crossCuttingClient, 
            IStringLocalizer localizer, 
            ITokenService tokenService,
            ILogger<UserGroupDetailsController> logger) : base(logger, tokenService)
        {
            _userGroupClient = userGroupClient;
            _crossCuttingClient = crossCuttingClient;
            _localizer = localizer;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userGroupPermissions = GetUserPermissions(PagePermission.CanManageUserGroups);
        }

        #endregion

        public async Task<IViewComponentResult> InvokeAsync(long? id)
        {
            UserGroupPageDetailsViewModel model;
            List<UserGroupDashboardViewModel> DashboardIcons = new List<UserGroupDashboardViewModel>();
            List<UserGroupDashboardViewModel> DashboardGrids = new List<UserGroupDashboardViewModel>();
            List<UserGroupDashboardViewModel> SelectedDashboardIcons = new List<UserGroupDashboardViewModel>();

            var requestIcons = new UserGroupDashboardGetRequestModel
            {
                roleId = null,
                dashBoardItemType = "icon",
                langId = GetCurrentLanguage(),
                user = null
            };
            DashboardIcons = await _userGroupClient.GetUserGroupDashboardList(requestIcons);

            var requestGrids = new UserGroupDashboardGetRequestModel
            {
                roleId = null,
                dashBoardItemType = "grid",
                langId = GetCurrentLanguage(),
                user = null
            };
            DashboardGrids = await _userGroupClient.GetUserGroupDashboardList(requestGrids);
            UserGroupDashboardViewModel defaultGrid = new UserGroupDashboardViewModel
            {
                idfsBaseReference = 0,
                strBaseReferenceCode = "",
                strDefault = "",
                strName = "",
                PageLink = ""
            };
            DashboardGrids.Insert(0, defaultGrid);

            model = new()
            {
                InformationSection = new InformationSectionViewModel()
                {
                    UserGroupDetails = new UserGroupDetailViewModel(),
                },
                UsersAndGroupsSection = new UsersAndGroupsSectionViewModel(),
                DashboardIconsSection = new DashboardIconsSectionViewModel(),
                DashboardGridsSection = new DashboardGridsSectionViewModel(),
                SystemFunctionsSection = new SystemFunctionsSectionViewModel(),
                //DeleteVisibleIndicator = false,
            };

            model.UsersAndGroupsSection.UserGroupPermissions = _userGroupPermissions;
            model.UsersAndGroupsSection.EmployeesForUserGroup = new List<EmployeesForUserGroupViewModel>();
            model.UsersAndGroupsSection.EmployeesForUserGroupGridConfiguration = new EIDSSGridConfiguration();
            model.UsersAndGroupsSection.SearchEmployeeActorViewModel = new SearchEmployeeActorViewModel();
            model.UsersAndGroupsSection.SearchEmployeeActorViewModel.Permissions = _userGroupPermissions;
            model.UsersAndGroupsSection.UsersAndGroupsToSave = new List<EmployeesForUserGroupViewModel>();

            model.SystemFunctionsSection.SystemFunctionPageViewModel = new SystemFunctionsPagesViewModel();
            model.DashboardIconsSection.DashboardIcons = DashboardIcons;
            model.DashboardGridsSection.DashboardGrids = DashboardGrids;

            if (id == null)
            {
                model.DeleteVisibleIndicator = false;
                model.SystemFunctionsSection.SystemFunctionPageViewModel.UserIDAndUserGroups = string.Empty;
            }
            else
            {
                var response = await _userGroupClient.GetUserGroupDetail((long)id, GetCurrentLanguage(), null);
                model.DeleteVisibleIndicator = true;
                if (response.Count > 0)
                {
                    model.InformationSection.UserGroupDetails = response[0];
                    //model.DeleteVisibleIndicator = true;
                    model.UsersAndGroupsSection.idfEmployeeGroup = id;
                    model.UsersAndGroupsSection.EmployeesForUserGroup = await LoadUsersAndGroups(id);

                    model.SystemFunctionsSection.SystemFunctionPageViewModel.UserIDAndUserGroups = id.ToString();
                    model.SystemFunctionsSection.SystemFunctionPageViewModel.EmployeeID = (long)id;
                //}
                //else
                //{
                }

                requestIcons.roleId = (long)id;
                var lstIcons = await _userGroupClient.GetUserGroupDashboardList(requestIcons);

                if (lstIcons.Count > 0)
                {
                    for (int i = 0; i < DashboardIcons.Count(); i++)
                    {
                        foreach (var item in lstIcons)
                        {
                            if (item.idfsBaseReference == DashboardIcons[i].idfsBaseReference)
                            {
                                DashboardIcons[i].Selected = true;
                            }
                        }
                    }
                    //model.DashboardIconsSection.SelectedDashboardIcons = DashboardIcons;
                }
                model.DashboardIconsSection.SelectedDashboardIcons = DashboardIcons;

                requestGrids.roleId = (long)id;
                var list = await _userGroupClient.GetUserGroupDashboardList(requestGrids);
                if (list.Count > 0)
                    model.DashboardGridsSection.SelectedDashboardGrid = list[0].idfsBaseReference.ToString();

                //TempData["idfEmployeeGroup"] = model.InformationSection.UserGroupDetails.idfEmployeeGroup.ToString();
            }

            model.DashboardIconsSection.SelectedDashboardIcons = DashboardIcons;

            model.UserGroupKey = id;
            model.UsersAndGroupsSection.SearchEmployeeActorViewModel.ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.SearchActorsModalHeading);
            model.UsersAndGroupsSection.SearchEmployeeActorViewModel.ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false);
            model.UsersAndGroupsSection.SearchEmployeeActorViewModel.SearchCriteria = new();
            model.UsersAndGroupsSection.SearchEmployeeActorViewModel.SearchCriteria.idfEmployeeGroup = id;

            var viewData = new ViewDataDictionary<UserGroupPageDetailsViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }

        public async Task<List<EmployeesForUserGroupViewModel>> LoadUsersAndGroups(long? id)
        {
            var request = new EmployeesForUserGroupGetRequestModel();
            request.idfEmployeeGroup = id;
            request.langId = GetCurrentLanguage();
            request.pageNo = 1;
            request.pageSize = 100;
            request.SortColumn = "Name";
            request.SortOrder = "ASC";
            request.idfsSite = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
            var list = await _userGroupClient.GetEmployeesForUserGroupList(request);

            return list;
        }
        #region Users and Groups

        #endregion

        #region System Functions

        public async Task<IActionResult> SaveSystemFunctions(List<RoleSystemFunctionOperation> operations)
        {
            try
            {
                var model = new SaveResponseViewModel();
                //UserGroupSystemFunctionsSaveRequestModel request = new();
                SystemFunctionsSaveRequestModel request = new();

                if (ModelState.IsValid && operations != null)
                {
                    string strRoleFunctionsOperations = System.Text.Json.JsonSerializer.Serialize(operations);
                    request.rolesandfunctions = strRoleFunctionsOperations;
                    request.user = authenticatedUser.UserName;
                    //APIPostResponseModel response = await _userGroupClient.SaveUserGroupSystemFunctions(request);
                    APIPostResponseModel response = await _crossCuttingClient.SaveSystemFunctions(request);
                    if (response.ReturnCode != null)
                    {
                        switch (response.ReturnCode)
                        {
                            case 0:
                                // Success
                                model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                break;

                            default:
                                throw new ApplicationException("Unable to save System Functions.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save System Functions.");
                    }

                    model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                }

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Dashboard Icons

        [HttpPost()]
        [Route("SaveUserGroupDashboard")]
        public async Task<IActionResult> SaveUserGroupDashboard([FromBody] UserGroupDashboardSaveRequestModel request)
        {
            try
            {
                var model = new SaveResponseViewModel();

                if (ModelState.IsValid && request.roleId != 0)
                {
                    APIPostResponseModel response = await _userGroupClient.SaveUserGroupDashboard(request);

                    if (response.ReturnCode != null)
                    {
                        switch (response.ReturnCode)
                        {
                            case 0:
                                // Success
                                model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                break;

                            default:
                                throw new ApplicationException("Unable to save Dashboard.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save Dashboard.");
                    }

                    model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                }

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Review

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost()]
        //[Route("SaveUserGroup")]
        public async Task<IActionResult> SaveUserGroup([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                UserGroupPageDetailsViewModel model = new();
                model.InformationSection = new();
                model.InformationSection.UserGroupDetails = new();
                model.InformationSection.UserGroupDetails.idfEmployeeGroup = string.IsNullOrEmpty(jsonObject["idfEmployeeGroup"].ToString()) ? null : Convert.ToInt64(jsonObject["idfEmployeeGroup"]);
                model.InformationSection.UserGroupDetails.strDefault = string.IsNullOrEmpty(jsonObject["strDefault"].ToString()) ? null : jsonObject["strDefault"].ToString();
                model.InformationSection.UserGroupDetails.strName = string.IsNullOrEmpty(jsonObject["strName"].ToString()) ? null : jsonObject["strName"].ToString();
                model.InformationSection.UserGroupDetails.strDescription = string.IsNullOrEmpty(jsonObject["strDescription"].ToString()) ? null : jsonObject["strDescription"].ToString();

                if (await ValidateUserGroupAsync(model.InformationSection) == false)
                {
                    string strDuplcationMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), model.InformationSection.UserGroupDetails.strDefault);
                    model.ErrorMessage = strDuplcationMessage;
                }
                else
                //if (ModelState.IsValid)
                {
                    UserGroupSaveRequestModel request = new()
                    {
                        idfEmployeeGroup = model.InformationSection.UserGroupDetails.idfEmployeeGroup,
                        idfsSite = long.Parse(authenticatedUser.SiteId),
                        strDefault = model.InformationSection.UserGroupDetails.strDefault,
                        strName = model.InformationSection.UserGroupDetails.strName,
                        strDescription = model.InformationSection.UserGroupDetails.strDescription,
                        langId = GetCurrentLanguage(),
                        user = authenticatedUser.UserName
                    };

                    //UsersAndGroups
                    var usersAndGroupsModel = jsonObject["usersAndGroupsModel"].ToString();
                    string strEmployees = string.Empty;
                    if (!string.IsNullOrEmpty(usersAndGroupsModel))
                    {
                        var parsedUsersAndGroupsModel = JObject.Parse(usersAndGroupsModel);
                        var UsersAndGroupsToSave = parsedUsersAndGroupsModel.Last;

                        //string strEmployees = string.Empty;
                        string strEmployee = string.Empty;

                        foreach (var c in UsersAndGroupsToSave.Children())
                        {
                            JArray array = JArray.Parse(c.ToString());
                            for (int i = 0; i < array.Count; i++)
                            {
                                strEmployee = array[i]["idfEmployee"].ToString();

                                if (string.IsNullOrEmpty(strEmployees))
                                    strEmployees = strEmployee;
                                else
                                    strEmployees += ", " + strEmployee;
                            }
                        }
                    }
                    if (strEmployees != "")
                        request.strEmployees = strEmployees;
                    else
                        request.strEmployees = null;

                    //Save System Functions
                    JArray a = Newtonsoft.Json.Linq.JArray.Parse(jsonObject["rolesandfunctions"].ToString());
                    //if (request.idfEmployeeGroup == null)
                    //{
                    //    for (int i = 0; i < a.Count; i++)
                    //    {
                    //        a[i]["RoleId"] = response.idfEmployeeGroup;
                    //    }
                    //}
                    //List<RoleSystemFunctionOperation> operations = a.ToObject<List<RoleSystemFunctionOperation>>();
                    string strRoleFunctionsOperations = System.Text.Json.JsonSerializer.Serialize(a.ToObject<List<RoleSystemFunctionOperation>>());
                    request.rolesandfunctions = strRoleFunctionsOperations;
                    //request.rolesandfunctions = null;

                    //Save Dashboard Icons and Grid
                    if (jsonObject["dashboardItems"].ToString() != "")
                    {
                        request.strDashboardObject = jsonObject["dashboardItems"].ToString();
                    }

                    UserGroupSaveResponseModel response = await _userGroupClient.SaveUserGroup(request);

                    if (response.ReturnCode != null)
                    {
                        if (response.ReturnCode == 0)
                        {
                            model.InformationSection.UserGroupDetails.idfEmployeeGroup = response.idfEmployeeGroup;
                            model.InformationSection.UserGroupDetails.idfsEmployeeGroupName = response.idfsEmployeeGroupName;
                            model.UserGroupKey = response.idfEmployeeGroup;

                            ////UsersAndGroups
                            //var usersAndGroupsModel = jsonObject["usersAndGroupsModel"].ToString();
                            //if (!string.IsNullOrEmpty(usersAndGroupsModel))
                            //{
                            //    var parsedUsersAndGroupsModel = JObject.Parse(usersAndGroupsModel);
                            //    var UsersAndGroupsToSave = parsedUsersAndGroupsModel.Last;

                            //    string strEmployees = string.Empty;
                            //    string strEmployee = string.Empty;

                            //    foreach (var c in UsersAndGroupsToSave.Children())
                            //    {
                            //        JArray array = JArray.Parse(c.ToString());
                            //        for (int i = 0; i < array.Count; i++)
                            //        {
                            //            strEmployee = array[i]["idfEmployee"].ToString();

                            //            if (string.IsNullOrEmpty(strEmployees))
                            //                strEmployees = strEmployee;
                            //            else
                            //                strEmployees += ", " + strEmployee;
                            //        }
                            //    }

                            //    if (strEmployees != "")
                            //    {
                            //        EmployeesToUserGroupSaveRequestModel requestEmployees = new();
                            //        requestEmployees.idfEmployeeGroup = response.idfEmployeeGroup;
                            //        requestEmployees.strEmployees = strEmployees.ToString();
                            //        APIPostResponseModel responseEmployees = await _userGroupClient.SaveEmployeesToUserGroup(requestEmployees);
                            //    }
                            //}

                            //model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);

                            ////Save System Functions
                            ////JArray a = Newtonsoft.Json.Linq.JArray.Parse(jsonObject["rolesandfunctions"].ToString());
                            //if (request.idfEmployeeGroup == null)
                            //{
                            //    for (int i = 0; i < a.Count; i++)
                            //    {
                            //        a[i]["RoleId"] = response.idfEmployeeGroup;
                            //    }
                            //}
                            //List<RoleSystemFunctionOperation> operations = a.ToObject<List<RoleSystemFunctionOperation>>();
                            ////List<RoleSystemFunctionOperationModel> operations = a.ToObject<List<RoleSystemFunctionOperationModel>>();
                            //await SaveSystemFunctions(operations);

                            //if (jsonObject["dashboardItems"].ToString() != "")
                            //{
                            //    //Save Dashboard Icons and Grid
                            //    UserGroupDashboardSaveRequestModel requestDashboard = new();
                            //    requestDashboard.roleId = response.idfEmployeeGroup;
                            //    requestDashboard.strDashboardObject = jsonObject["dashboardItems"].ToString();
                            //    APIPostResponseModel responseDashboard = await _userGroupClient.SaveUserGroupDashboard(requestDashboard);
                            //}

                            model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                        }
                    }
                }
            

                return Json(model);
                //return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task<bool> ValidateUserGroupAsync(InformationSectionViewModel model)
        {
            UserGroupGetRequestModel request = new();
            request.LanguageId = GetCurrentLanguage();
            request.Page = 1;
            request.PageSize = 10;
            request.SortColumn = "strDefault";
            request.SortOrder = "DESC";
            request.strName = model.UserGroupDetails.strDefault;
            request.idfsSite = long.Parse(authenticatedUser.SiteId);

            List<UserGroupViewModel> duplicateList = await _userGroupClient.GetUserGroupList(request);
            List<UserGroupViewModel> list = duplicateList.Where(x => x.idfEmployeeGroup == (long)model.UserGroupDetails.idfEmployeeGroup).ToList();

            if (model.UserGroupDetails.idfEmployeeGroup == null && duplicateList.Count > 0)
            {
                return false;
            }
            else if (list.Count > 1)
            {
                return false;
            }

            return true;
        }

        #endregion

    }
}
