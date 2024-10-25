using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
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
    [ViewComponent(Name = "Actor")]
    [Area("CrossCutting")]
    public class ActorController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;

        public ActorController(ICrossCuttingClient crossCuttingClient,
             ITokenService tokenService, ILogger<ActorController> logger) : base(logger, tokenService)
        {

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
                SearchActorViewModel model = new()
                {
                    ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false)
                };

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [Route("GetActorList")]
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

                var postParameterDefinitions = new { SearchActorViewModel_SearchCriteria_ActorTypeID = "", SearchActorViewModel_SearchCriteria_ActorName = "", SearchActorViewModel_SearchCriteria_OrganizationName = "", SearchActorViewModel_SearchCriteria_UserGroupDescription = "", searchActorDataPermissionsDiseaseID = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (dataTableQueryPostObj.postArgs == "{}") return Json(tableData);
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                // Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                if (string.IsNullOrEmpty(searchCriteria.SearchActorViewModel_SearchCriteria_ActorTypeID) &&
                    string.IsNullOrEmpty(searchCriteria.SearchActorViewModel_SearchCriteria_ActorName) &&
                    string.IsNullOrEmpty(searchCriteria.SearchActorViewModel_SearchCriteria_OrganizationName) &&
                    string.IsNullOrEmpty(searchCriteria.SearchActorViewModel_SearchCriteria_UserGroupDescription) &&
                    string.IsNullOrEmpty(searchCriteria.searchActorDataPermissionsDiseaseID))
                    return Json(tableData);

                ActorGetRequestModel model = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = iPage,
                    PageSize = iLength,
                    SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "ActorName",
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending,
                    DiseaseFiltrationSearchIndicator =
                        (searchCriteria.searchActorDataPermissionsDiseaseID != string.Empty),
                    ActorTypeID = searchCriteria.SearchActorViewModel_SearchCriteria_ActorTypeID == null
                        ? null
                        : Convert.ToInt64(searchCriteria.SearchActorViewModel_SearchCriteria_ActorTypeID),
                    ActorName = searchCriteria.SearchActorViewModel_SearchCriteria_ActorName == ""
                        ? null
                        : searchCriteria.SearchActorViewModel_SearchCriteria_ActorName,
                    OrganizationName = searchCriteria.SearchActorViewModel_SearchCriteria_OrganizationName == ""
                        ? null
                        : searchCriteria.SearchActorViewModel_SearchCriteria_OrganizationName,
                    UserGroupDescription =
                        searchCriteria.SearchActorViewModel_SearchCriteria_UserGroupDescription == ""
                            ? null
                            : searchCriteria.SearchActorViewModel_SearchCriteria_UserGroupDescription,
                    ApplySiteFiltrationIndicator = (searchCriteria.searchActorDataPermissionsDiseaseID != string.Empty),
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                var list = await _crossCuttingClient.GetActorList(model);

                IEnumerable<ActorGetListViewModel> actorList = list;

                if (list.Count <= 0) return Json(tableData);
                tableData.iTotalRecords = list[0].RecordCount;
                tableData.iTotalDisplayRecords = list[0].RecordCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        actorList.ElementAt(i).ActorID.ToString(),
                        actorList.ElementAt(i).ActorTypeID.ToString(),
                        actorList.ElementAt(i).ActorTypeName,
                        actorList.ElementAt(i).ActorName,
                        actorList.ElementAt(i).EmployeeSiteID.ToString(),
                        actorList.ElementAt(i).EmployeeSiteName,
                        actorList.ElementAt(i).EmployeeUserID.ToString(),
                        actorList.ElementAt(i).ObjectAccessID.ToString(),
                        actorList.ElementAt(i).OrganizationName,
                        actorList.ElementAt(i).RowSelectionIndicator.ToString(),
                        actorList.ElementAt(i).UserGroupDescription,
                        actorList.ElementAt(i).UserGroupSiteID.ToString(),
                        actorList.ElementAt(i).UserGroupSiteName
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
    }
}
