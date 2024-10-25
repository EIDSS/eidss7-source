using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
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

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class VectorTypePageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;
        private readonly IVectorTypeClient _vectorTypeClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;

        public VectorTypePageController(
            IVectorTypeClient vectorTypeClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<VectorTypePageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _vectorTypeClient = vectorTypeClient;
            _localizer = localizer;
            _userPermissions = GetUserPermissions(PagePermission.CanManageBaseReferencePage);
            _pageViewModel.UserPermissions = _userPermissions;
        }

        public IActionResult Index()
        {
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var postParameterDefinitions = new { SearchBox = "", Print = "" };
                var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "intOrder";
                if (!string.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfsVectorType")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new VectorTypesGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    SearchVectorType = referenceType.SearchBox.Trim(),
                    Page = dataTableQueryPostObj.page,
                    PageSize = Convert.ToBoolean(referenceType.Print) ? Int32.MaxValue - 1 : dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
                };

                var vtlvm = await _vectorTypeClient.GetVectorTypeList(request);
                IEnumerable<BaseReferenceEditorsViewModel> vectorTypeList = vtlvm;

                vectorTypeList = strSortColumn switch
                {
                    "intOrder" when request.SortOrder == EIDSSConstants.SortConstants.Descending => vectorTypeList.OrderByDescending(o => o.IntOrder)
                        .ThenBy(n => n.StrName),
                    "intOrder" when request.SortOrder == EIDSSConstants.SortConstants.Ascending => vectorTypeList.OrderBy(o => o.IntOrder)
                        .ThenBy(n => n.StrName),
                    _ => vectorTypeList
                };

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = vtlvm.Count == 0 ? 0 : vtlvm[0].TotalRowCount,
                    iTotalDisplayRecords = vtlvm.Count == 0 ? 0 : vtlvm[0].TotalRowCount,
                    draw = dataTableQueryPostObj.draw
                };

                var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (var i = 0; i < (vtlvm.Count); i++)
                {
                    var cols = new List<string>()
                    {
                        (row + i + 1).ToString(),
                        vectorTypeList.ElementAt(i).IdfsVectorType.ToString(),
                        vectorTypeList.ElementAt(i).StrDefault ?? string.Empty, // English Value
                        vectorTypeList.ElementAt(i).StrName ?? string.Empty,  // Translated Value                  
                        vectorTypeList.ElementAt(i).StrCode ?? string.Empty,
                        vectorTypeList.ElementAt(i).BitCollectionByPool.ToString(),
                        vectorTypeList.ElementAt(i).IntOrder.ToString()
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
        public async Task<IActionResult> AddVectorType([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                VectorTypeSaveRequestModel request = new()
                {
                    Default = jsonObject["Default"]?.ToString().Trim(),
                    Name = jsonObject["Name"]?.ToString().Trim(),
                    Code = jsonObject["Code"]?.ToString(),
                    intOrder = !string.IsNullOrEmpty(jsonObject["Order"]?.ToString()) ? Int32.Parse(jsonObject["Order"].ToString()) : 0,
                    CollectionByPool = jsonObject["CollectedByPool"]?.ToString().Contains("true"),
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                var response = await _vectorTypeClient.SaveVectorType(request);
                response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("EditVectorType")]
        public async Task<JsonResult> EditVectorType([FromBody] JsonElement json)
        {
            try
            {
                var jsonObject = JObject.Parse(json.ToString() ?? string.Empty);

                var request = new VectorTypeSaveRequestModel
                {
                    VectorTypeId = Convert.ToInt64(jsonObject["IdfsVectorType"]?.ToString()),
                    Default = jsonObject["StrDefault"]?.ToString().Trim(),
                    Name = jsonObject["StrName"]?.ToString().Trim(),
                    Code = jsonObject["StrCode"]?.ToString(),
                    intOrder = string.IsNullOrEmpty(jsonObject["intOrder"]?.ToString()) ? 0 : Int32.Parse(jsonObject["intOrder"].ToString()),
                    CollectionByPool = Convert.ToBoolean(jsonObject["BitCollectionByPool"]?.ToString()),
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                var response = await _vectorTypeClient.SaveVectorType(request);
                response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("DeleteVectorType")]
        public async Task<JsonResult> DeleteVectorType([FromBody] JsonElement json)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(json.ToString() ?? string.Empty);

                if (jsonObject["IdfsVectorType"] != null)
                {
                    var request = new VectorTypeSaveRequestModel
                    {
                        DeleteAnyway = true,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        VectorTypeId = Convert.ToInt64(jsonObject["IdfsVectorType"]?.ToString())
                    };

                    var response = await _vectorTypeClient.DeleteVectorType(request);

                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["IdfsVectorType"].ToString());
                    if (response.ReturnMessage == "IN USE")
                    {
                        responsePost.strClientPageMessage =
                            "You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?";
                    }

                    return Json(responsePost);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(responsePost);
        }
    }
}
