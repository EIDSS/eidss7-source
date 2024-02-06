using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions;
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

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [ViewComponent(Name = "SystemFunctionActor")]
    [Area("CrossCutting")]
    public class SystemFunctionActorController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ISystemFunctionsClient _systemFunctionsClient;


        public SystemFunctionActorController(ICrossCuttingClient crossCuttingClient, ISystemFunctionsClient systemFunctionsClient,
             ITokenService tokenService, ILogger<SystemFunctionActorController> logger) : base(logger, tokenService)
        {

            _crossCuttingClient = crossCuttingClient;
            _systemFunctionsClient = systemFunctionsClient;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        public IViewComponentResult Invoke(SearchPersonAndEmployeeGroupViewModel model)
        {
            //EIDSSGridConfiguration model = new();
            
           var viewData = new ViewDataDictionary<SearchPersonAndEmployeeGroupViewModel>(ViewData, model);
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
                SearchPersonAndEmployeeGroupViewModel model = new();

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
        /// GetSystemFunctionActorList
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost()]
        public async Task<JsonResult> GetSystemFunctionActorList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                //long systemFunctionId = 0;
                //if (TempData["SystemFunctionId"] !=null)
                //{
                //    systemFunctionId = Convert.ToInt64(TempData["SystemFunctionId"].ToString());
                //}
                //TempData.Keep();

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0,
                    draw = dataTableQueryPostObj.draw
                };
                tableData.data.Add(new List<string>() { string.Empty, string.Empty, string.Empty, string.Empty, string.Empty, string.Empty});

                var postParameterDefinitions = new { SearchPersonAndEmployeeGroupViewModel_SystemFunctionId="", SearchPersonAndEmployeeGroupViewModel_SearchCriteria_ActorTypeID = "", SearchPersonAndEmployeeGroupViewModel_SearchCriteria_ActorName = "", SearchPersonAndEmployeeGroupViewModel_SearchCriteria_OrganizationName = "", SearchPersonAndEmployeeGroupViewModel_SearchCriteria_Description = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (dataTableQueryPostObj.postArgs != "{}")
                {
                    int iPage = dataTableQueryPostObj.page;
                    int iLength = dataTableQueryPostObj.length;

                    // Sorting
                    KeyValuePair<string, string> valuePair = new();
                    valuePair = dataTableQueryPostObj.ReturnSortParameter();

                    PersonAndEmployeeGroupGetRequestModel model = new();
                   // model.SystemFunctionId = systemFunctionId;
                    model.LanguageId = GetCurrentLanguage();
                    model.Page = iPage;
                    model.PageSize = iLength;
                    model.SortColumn = !String.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "ActorName";
                    model.SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "ASC";
                    model.SystemFunctionId = Convert.ToInt64(searchCriteria.SearchPersonAndEmployeeGroupViewModel_SystemFunctionId);
                    model.ActorTypeID = searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_ActorTypeID == null ? null : Convert.ToInt64(searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_ActorTypeID);
                    model.ActorName = searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_ActorName == "" ? null : searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_ActorName;
                    model.OrganizationName = searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_OrganizationName == "" ? null : searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_OrganizationName;
                    model.Description = searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_Description == "" ? null : searchCriteria.SearchPersonAndEmployeeGroupViewModel_SearchCriteria_Description;
                    model.UserSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    model.UserOrganizationID = Convert.ToInt64(authenticatedUser.Institution);
                    model.UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId);

                    List<SystemFunctionPersonANDEmployeeGroupViewModel> list = await _systemFunctionsClient.GetPersonAndEmployeeGroupList(model);

                    IEnumerable<SystemFunctionPersonANDEmployeeGroupViewModel> actorList = list;

                    if (list.Count > 0)
                    {
                        tableData.iTotalRecords = list[0].TotalPages;
                        tableData.iTotalDisplayRecords = list[0].TotalRowCount;
                        for (int i = 0; i < list.Count; i++)
                        {
                            List<string> cols = new()
                            {
                                actorList.ElementAt(i).idfEmployee.ToString(),
                                actorList.ElementAt(i).idfsEmployeeType.ToString(),
                                actorList.ElementAt(i).EmployeeTypeName,
                                actorList.ElementAt(i).Name,
                                actorList.ElementAt(i).OrganizationName,
                                actorList.ElementAt(i).strDescription
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
