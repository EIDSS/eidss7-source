using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;
using static System.String;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class AgeGroupReferenceEditorPageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _baseReferencePageViewModel;
        private readonly IAdminClient _adminClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;

        public AgeGroupReferenceEditorPageController(IAdminClient adminClient, ITokenService tokenService, IStringLocalizer localizer,
            ILogger<AgeGroupReferenceEditorPageController> logger) : base(logger, tokenService)
        {
            _baseReferencePageViewModel = new BaseReferenceEditorPagesViewModel();
            _adminClient = adminClient;
            _localizer = localizer;
            _userPermissions = GetUserPermissions(PagePermission.CanManageAgeGroupReferenceEditorPage);

            _baseReferencePageViewModel.UserPermissions = _userPermissions;
        }

        public IActionResult Index()
        {
            _baseReferencePageViewModel.Select2Configurations = new List<Select2Configruation>();
            _baseReferencePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _baseReferencePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_baseReferencePageViewModel);
        }

        //Added Additional Sorting by intorder then by strdefault
        public async Task<JsonResult> GetAgeGroupTableNew([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { RefereceTypeDD = "" };
            Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            //Sorting
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            var requestModel = new AgeGroupGetRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = (!IsNullOrEmpty(valuePair.Key) & valuePair.Key != "BaseReferenceId") ? valuePair.Key : "Intorder",
                SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending,
            };
            //API CALL
            _baseReferencePageViewModel.baseReferenceListViewModel = await
            _adminClient.GetAgeGroupList(requestModel);
            var baseReferenceList = _baseReferencePageViewModel.baseReferenceListViewModel.ToList();

            var tableData = new TableData
            {
                data = new List<List<string>>()
            };
            if (baseReferenceList.Count <= 0) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;
            tableData.iTotalRecords = baseReferenceList.First().TotalRowCount;
            tableData.iTotalDisplayRecords = baseReferenceList.First().TotalRowCount;
            tableData.draw = dataTableQueryPostObj.draw;
            var sortedReferenceList = baseReferenceList.OrderBy(x => x.IntOrder).ThenBy(x => x.StrName).ToList();
            for (var i = 0; i < sortedReferenceList.Count(); i++)
            {
                var cols = new List<string>()
                {
                    (row + i + 1).ToString(),
                    sortedReferenceList.ElementAt(i).KeyId.ToString(),
                    sortedReferenceList.ElementAt(i).StrDefault != null
                        ? sortedReferenceList.ElementAt(i).StrDefault
                        : Empty,
                    sortedReferenceList.ElementAt(i).StrName != null
                        ? sortedReferenceList.ElementAt(i).StrName
                        : Empty,
                    sortedReferenceList.ElementAt(i).IntLowerBoundary.ToString(),
                    sortedReferenceList.ElementAt(i).IntUpperBoundary.ToString(),
                    sortedReferenceList.ElementAt(i).AgeTypeName,
                    sortedReferenceList.ElementAt(i).idfsAgeType.ToString(),
                    sortedReferenceList.ElementAt(i).IntOrder.ToString(),
                    Empty,
                    Empty
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        /// <summary>
        /// Adds a new Reference Type
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> AddNewAgeGroup([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            var serializer = JsonSerializer.Serialize(data);
            var response = new AgeGroupSaveRequestResponseModel();
            var ageGroupBaseReferenceSaveRequestModel = new AgeGroupSaveRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            try
            {
                if (jsonObject["AgeTypeName"] != null)
                {
                    long ageTypeId = 0;
                    for (var i = 0; i < jsonObject["AgeTypeName"].Children().Count(); i++)
                    {
                        TryParse(jsonObject["AgeTypeName"].Children().ElementAt(i)["id"]?.ToString(), out var outResult);
                        ageTypeId = outResult;
                    }
                    ageGroupBaseReferenceSaveRequestModel.IdfsAgeType = ageTypeId;
                }
                if (jsonObject["StrDefault"] != null)
                {
                    ageGroupBaseReferenceSaveRequestModel.StrDefault = jsonObject["StrDefault"].ToString();
                }
                if (jsonObject["StrName"] != null)
                {
                    ageGroupBaseReferenceSaveRequestModel.StrName = jsonObject["StrName"].ToString();
                }
                if (jsonObject["IntLowerBoundary"] != null)
                {
                    // MVB 03.15.22 -  Bug fix 3072
                    TryParse(jsonObject["IntLowerBoundary"].ToString(), out var lowerBound);
                    ageGroupBaseReferenceSaveRequestModel.IntLowerBoundary = lowerBound;
                }
                if (jsonObject["IntUpperBoundary"] != null)
                {
                    TryParse(jsonObject["IntUpperBoundary"].ToString(), out var upperBound);
                    ageGroupBaseReferenceSaveRequestModel.IntUpperBoundary = upperBound;
                }
                if (jsonObject["IntOrder"] != null)
                {
                    TryParse(jsonObject["IntOrder"].ToString(), out var intOrder);
                    ageGroupBaseReferenceSaveRequestModel.IntOrder = intOrder;
                }
                response = await _adminClient.SaveAgeGroup(ageGroupBaseReferenceSaveRequestModel);
                response.strDuplicatedField = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), ageGroupBaseReferenceSaveRequestModel.StrDefault);
                response.PageAction = Domain.Enumerations.PageActions.Add;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                //throw;
            }

            return Json(response);
        }


        /// <summary>
        /// Edits Data
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> EditAgeGroup([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            var serializer = JsonSerializer.Serialize(data);
            
            AgeGroupSaveRequestResponseModel response;
            var ageGroupSaveRequestModel = new AgeGroupSaveRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };
            try
            {
                if (jsonObject["IntLowerBoundary"] != null)
                {
                    // MVB 03.15.22 -  Bug fix 3073
                    TryParse(jsonObject["IntLowerBoundary"].ToString(), out var lowerBound);
                    ageGroupSaveRequestModel.IntLowerBoundary = lowerBound;
                }
                if (jsonObject["IntUpperBoundary"] != null)
                {
                    TryParse(jsonObject["IntUpperBoundary"].ToString(), out var upperBound);
                    ageGroupSaveRequestModel.IntUpperBoundary = upperBound;
                }
                if (jsonObject["IntOrder"] != null)
                {
                    ageGroupSaveRequestModel.IntOrder = Parse(jsonObject["IntOrder"].ToString());
                }
                if (jsonObject["BaseReferenceId"] != null)
                {
                    ageGroupSaveRequestModel.IdfsAgeGroup = long.Parse(jsonObject["BaseReferenceId"].ToString());
                }
                if (jsonObject["AgeTypeName"] != null)
                {
                    long sumHaCode = 0;
                    for (var i = 0; i < jsonObject["AgeTypeName"].Children().Count(); i++)
                    {
                        TryParse(jsonObject["AgeTypeName"].Children().ElementAt(i)["id"]?.ToString(), out var outResult);
                        sumHaCode += outResult;
                    }
                    ageGroupSaveRequestModel.IdfsAgeType = sumHaCode;
                }
                if (jsonObject["StrName"] != null)
                {
                    ageGroupSaveRequestModel.StrName = jsonObject["StrName"].ToString();
                }
                if (jsonObject["StrDefault"] != null)
                {
                    ageGroupSaveRequestModel.StrDefault = jsonObject["StrDefault"].ToString();
                }
                response = await _adminClient.SaveAgeGroup(ageGroupSaveRequestModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            response.strDuplicatedField = Format(_localizer.GetString(MessageResourceKeyConstants.ItIsNotPossibleToHaveTwoRecordsWithSameValueDoYouWantToCorrectValueMessage), ageGroupSaveRequestModel.StrDefault);
            response.PageAction = Domain.Enumerations.PageActions.Edit;
            return Json(response);
        }

        /// <summary>
        /// Deletes Data
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> DeleteAgeGroupModalData([FromBody] JsonElement data)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                var request = new AgeGroupSaveRequestModel
                {
                    DeleteAnyway = true, 
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                if (jsonObject["BaseReferenceId"] != null)
                {
                    request.IdfsAgeGroup =
                        long.Parse(jsonObject["BaseReferenceId"].ToString());

                    var response = await _adminClient.DeleteAgeGroup(request);

                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["BaseReferenceId"].ToString());

                    if (response.ReturnMessage == "IN USE")
                    {
                        responsePost.strClientPageMessage = "You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?";
                    }

                    return Json(responsePost);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(responsePost);
        }
    }
}
