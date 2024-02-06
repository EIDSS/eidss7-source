using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Administration.ViewModels.Administration;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "EmployeeActor")]
    [Area("Administration")]
    [SubArea("Security")]
    public class EmployeeActorController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IUserGroupClient _userGroupClient;

        public EmployeeActorController(IUserGroupClient userGroupClient, ICrossCuttingClient crossCuttingClient,
             ITokenService tokenService, ILogger<EmployeeActorController> logger) : base(logger, tokenService)
        {

            _userGroupClient = userGroupClient;
            _crossCuttingClient = crossCuttingClient;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        public IViewComponentResult Invoke()
        {
            EIDSSGridConfiguration model = new();
            var viewData = new ViewDataDictionary<EIDSSGridConfiguration>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }
        [HttpGet]
        public async Task<IActionResult> SearchCriteriaSettings()
        {
            try
            {
                SearchEmployeeActorViewModel model = new();

                model.ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false);

                return View(model);
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
        /// <param name="dataTableQueryPostObj"></param>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost()]
        public async Task<JsonResult> GetActorList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
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

                //tableData.data.Add(new List<string>() { string.Empty, string.Empty, string.Empty, string.Empty, string.Empty, string.Empty, string.Empty });

                var postParameterDefinitions = new { UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Type = "", UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Name = "", UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Organization = "", UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Description = "", UsersAndGroupsSection_idfEmployeeGroup = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (dataTableQueryPostObj.postArgs != "{}")
                {
                    int iPage = dataTableQueryPostObj.page;
                    int iLength = dataTableQueryPostObj.length;
                    long? idfEmployeeGroup = searchCriteria.UsersAndGroupsSection_idfEmployeeGroup == "" ? null : long.Parse(searchCriteria.UsersAndGroupsSection_idfEmployeeGroup.ToString());

                    // Sorting
                    KeyValuePair<string, string> valuePair = new();
                    valuePair = dataTableQueryPostObj.ReturnSortParameter();

                    EmployeesForUserGroupGetRequestModel model = new();
                    model.idfEmployeeGroup = idfEmployeeGroup;
                    model.langId = GetCurrentLanguage();
                    model.pageNo = iPage;
                    model.pageSize = iLength;
                    model.SortColumn = !String.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "Name";
                    model.SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "ASC";
                    model.Type = searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Type == null ? null : Convert.ToInt64(searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Type);
                    model.Name = searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Name == "" ? null : searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Name;
                    model.Organization = searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Organization == "" ? null : searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Organization;
                    model.Description = searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Description == "" ? null : searchCriteria.UsersAndGroupsSection_SearchEmployeeActorViewModel_SearchCriteria_Description;
                    model.idfsSite = long.Parse(authenticatedUser.SiteId);
                    model.user = "Search";

                    List<EmployeesForUserGroupViewModel> list = await _userGroupClient.GetEmployeesForUserGroupList(model);

                    //List<EmployeesForUserGroupViewModel> list = new List<EmployeesForUserGroupViewModel>();
                    //list = list0;


                    if (list.Count > 0)
                    {
                        tableData.iTotalRecords = list[0].TotalRowCount;
                        tableData.iTotalDisplayRecords = list[0].TotalRowCount;

                        for (int i = 0; i < list.Count; i++)
                        {
                            List<string> cols = new()
                            {
                                list.ElementAt(i).idfEmployee.ToString(),
                                list.ElementAt(i).idfEmployeeGroup.ToString(), 
                                list.ElementAt(i).TypeID.ToString(),
                                list.ElementAt(i).TypeName,
                                list.ElementAt(i).Name,
                                list.ElementAt(i).Organization,
                                list.ElementAt(i).Description,
                                //list.ElementAt(i).idfUserID.ToString() ?? String.Empty,
                                //list.ElementAt(i).UserName
                            };

                            tableData.data.Add(cols);
                        }
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
    }
}
