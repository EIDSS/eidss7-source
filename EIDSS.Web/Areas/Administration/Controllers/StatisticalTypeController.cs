using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
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
    public class StatisticalTypePageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _statisticalTypePageViewModel;
        private readonly IStatisticalTypeClient _statisticalTypeClient;
        private readonly IStringLocalizer _localizer;

        public class RootObject
        {
            public List<AddStatisticalTypeModel> response { get; set; }
        }

        public class AddStatisticalTypeModel
        {
            [JsonProperty("Default")]
            public string Default { get; set; }
            [JsonProperty("Name")]
            public string Name { get; set; }
            [JsonProperty("strCode")]
            public string strCode { get; set; }
            [JsonProperty("intOrder")]
            public int intOrder { get; set; }
        }

        public StatisticalTypePageController(IStatisticalTypeClient statisticalTypeClient, ITokenService tokenService, IStringLocalizer localizer, ILogger<StatisticalTypePageController> logger) : base(logger, tokenService)
        {
            _statisticalTypePageViewModel = new BaseReferenceEditorPagesViewModel
            {
                Select2Configurations = new List<Select2Configruation>()
            };
            _statisticalTypeClient = statisticalTypeClient;
            _localizer = localizer;
            _statisticalTypePageViewModel.UserPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
        }

        public IActionResult Index()
        {
            _statisticalTypePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _statisticalTypePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_statisticalTypePageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var iPage = dataTableQueryPostObj.page;
            var iLength = dataTableQueryPostObj.length;

            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            if (valuePair.Key == "idfsStatisticDataType")
            {
                valuePair = new KeyValuePair<string, string>();
            }

            var request = new StatisticalTypeGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AdvancedSearch = JObject.Parse(dataTableQueryPostObj.postArgs)["SearchBox"]?.ToString(),
                Page = iPage,
                PageSize = iLength,
                SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "strName",
                SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
            };

            var stlvm = await _statisticalTypeClient.GetStatisticalTypeList(request);
            IEnumerable<BaseReferenceEditorsViewModel> statisticalTypeList = stlvm;

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = stlvm.Count == 0 ? 0 : stlvm[0].TotalRowCount,
                iTotalDisplayRecords = stlvm.Count == 0 ? 0 : stlvm[0].TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (stlvm.Count <= 0) return Json(tableData);
            for (var i = 0; i < stlvm.Count(); i++)
            {
                var cols = new List<string>()
                {
                    (i + 1 + (iPage-1)*iLength).ToString(),
                    statisticalTypeList.ElementAt(i).KeyId.ToString(),
                    statisticalTypeList.ElementAt(i).StrDefault,
                    statisticalTypeList.ElementAt(i).StrName,
                    statisticalTypeList.ElementAt(i).IdfsReferenceType.ToString(),
                    (statisticalTypeList.ElementAt(i).StrParameterType == null) ? string.Empty : statisticalTypeList.ElementAt(i).StrParameterType,
                    statisticalTypeList.ElementAt(i).blnStatisticalAgeGroup.ToString(),
                    statisticalTypeList.ElementAt(i).IdfsStatisticAreaType.ToString(),
                    (statisticalTypeList.ElementAt(i).StrStatisticalAreaType == null) ? string.Empty : statisticalTypeList.ElementAt(i).StrStatisticalAreaType,
                    statisticalTypeList.ElementAt(i).IdfsStatisticPeriodType.ToString(),
                    (statisticalTypeList.ElementAt(i).StrStatisticPeriodType == null) ? string.Empty : statisticalTypeList.ElementAt(i).StrStatisticPeriodType
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> SaveStatisticalType([FromForm] StatisticalTypeSaveRequestModel request)
        {
            var response = await _statisticalTypeClient.SaveStatisticalType(request);

            var strDuplicationMessage = string.Empty;

            if (response.ReturnMessage == "DOES EXIST")
            {
                strDuplicationMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.StrDefault);
            }

            var data = new
            {
                DuplicationMessage = strDuplicationMessage,
                response.ReturnMessage,
                response.ReturnCode
            };

            return Json(data);
        }

        [HttpPost]
        public async Task<JsonResult> DeleteStatisticalType([FromBody] JsonElement data)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["idfsStatisticDataType"] != null)
                {
                    var request = new StatisticalTypeSaveRequestModel
                    {
                        DeleteAnyway = true,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        IdfsStatisticDataType = long.Parse(jsonObject["idfsStatisticDataType"].ToString())
                    };

                    var response = await _statisticalTypeClient.DeleteStatisticalType(request);
                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["idfsStatisticDataType"].ToString());
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

        [HttpPost]
        public async Task<IActionResult> AddEditStatisticalType([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            var request = new StatisticalTypeSaveRequestModel
            {
                IdfsStatisticDataType = (jsonObject["idfsStatisticDataType"] == null) ? null : long.Parse(jsonObject["idfsStatisticDataType"].ToString()),
                StrDefault = jsonObject["strDefault"]?.ToString(),
                StrName = jsonObject["strName"]?.ToString(),
                IdfsReferenceType = Helpers.Common.ExtractLongValue(jsonObject, "idfsParameterType", "strParameterType"),
                IdfsStatisticAreaType = Helpers.Common.ExtractLongValue(jsonObject, "idfsStatisticAreaType", "strStatisticAreaType"),
                IdfsStatisticPeriodType = Helpers.Common.ExtractLongValue(jsonObject, "idfsStatisticPeriodType", "strStatisticPeriodType"),
                BlnRelatedWithAgeGroup = ExtractBoolValue(jsonObject, "blnStatisticalAgeGroup"),
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                User = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            return Json(await SaveStatisticalType(request));
        }

        private static bool? ExtractBoolValue(JObject jsonObject, string strValue)
        {
            JArray a;
            bool? bl;

            try
            {
                a = JArray.Parse(jsonObject[strValue].ToString());
                bl = bool.Parse(a[0]["Value"]?.ToString() ?? string.Empty);
            }
            catch (Exception e)
            {
                bl = (jsonObject[strValue].ToString() != "[]") && bool.Parse(jsonObject[strValue].ToString());
            }
            return bl;
        }
    }
}
