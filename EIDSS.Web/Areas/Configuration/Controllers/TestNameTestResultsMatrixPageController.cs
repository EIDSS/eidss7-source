using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class TestNameTestResultsMatrixPageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly ITestNameTestResultsMatrixClient _configurationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IAdminClient _adminClient;
        private readonly IStringLocalizer _localizer;

        public TestNameTestResultsMatrixPageController(ITestNameTestResultsMatrixClient configurationClient,
            ICrossCuttingClient crossCuttingClient, IAdminClient adminClient, IStringLocalizer localizer,
            ILogger<TestNameTestResultsMatrixPageController> logger, ITokenService tokenService) : base(logger,
            tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            _crossCuttingClient = crossCuttingClient;
            _adminClient = adminClient;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _configurationMatrixViewModel.UserPermissions = userPermissions;
            _localizer = localizer;
        }

        public IActionResult Index()
        {
            _configurationMatrixViewModel.Select2Configurations = new List<Select2Configruation>();
            _configurationMatrixViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _configurationMatrixViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_configurationMatrixViewModel);
        }


        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new {TestNameDD = "", SearchBox = "", RadioButton2Configurations = ""};
            var referenceType =
                JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            long? id = null;
            if (referenceType.TestNameDD != null)
            {
                if (!IsNullOrEmpty(referenceType.TestNameDD))
                {
                    id = long.Parse(referenceType.TestNameDD);
                }
            }

            long? testType = null;
            if (referenceType.RadioButton2Configurations != null)
            {
                if (!IsNullOrEmpty(referenceType.RadioButton2Configurations))
                {
                    testType = long.Parse(referenceType.RadioButton2Configurations);
                }
            }

            var sortColumn = !IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "strDefault";
            var sortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Descending;

            var request = new TestNameTestResultsMatrixGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsTestName = id,
                idfsTestResultRelation = testType,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
            };

            var list = new List<TestNameTestResultsMatrixViewModel>();

            if (id != null)
            {
                list = await _configurationClient.GetTestNameTestResultsMatrixList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (!list.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0
                ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length
                : 0;

            for (var i = 0; i < list.Count(); i++)
            {
                var cols = new List<string>
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).idfsTestResult.ToString(),
                    list.ElementAt(i).idfsTestName.ToString(),
                    list.ElementAt(i).strTestResultDefault,
                    list.ElementAt(i).blnIndicative.ToString(),
                    testType.ToString(),
                    "",
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            var testResult = "";

            try
            {
                if (jsonObject["idfsTestResult"] != null)
                {
                    if (IsNullOrEmpty(jsonObject["idfsTestResult"][0]?["id"]?.ToString()))
                    {
                        // should select a Test Name
                        return Json("");
                    }
                }

                long testType = 0;
                if (jsonObject["RadioButton2Configurations"] != null)
                {
                    testType = long.Parse(jsonObject["RadioButton2Configurations"].ToString());
                }

                long idfsTestResult = 0;
                if (jsonObject["idfsTestResult"]?[0]?["id"] != null)
                {
                    idfsTestResult = long.Parse(jsonObject["idfsTestResult"][0]["id"].ToString());
                }

                if (jsonObject["idfsTestResult"]?[0]?["text"] != null)
                {
                    testResult = jsonObject["idfsTestResult"][0]["text"].ToString();
                }

                var blnIndicative = false;
                if (jsonObject["blnIndicative"].Count() != 0 && jsonObject["blnIndicative"][0]?["Value"] != null)
                {
                    blnIndicative = Convert.ToBoolean(jsonObject["blnIndicative"][0]["Value"].ToString());
                }

                var request = new TestNameTestResultsMatrixSaveRequestModel
                {
                    //idfCollectionMethodForVectorType = null,
                    idfsTestName = jsonObject["TestNameDD"]?[0]?["id"] != null
                        ? long.Parse(jsonObject["TestNameDD"][0]["id"].ToString())
                        : null,
                    idfsTestResult = idfsTestResult,
                    idfsTestResultRelation = testType,
                    blnIndicative = blnIndicative,
                    EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                var response = await _configurationClient.SaveTestNameTestResultsMatrix(request);
                response.strDuplicatedField =
                    Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), testResult);

                if (response.idfsTestResult != 0 && response.ReturnMessage == "SUCCESS")
                {
                    // popup a modal with message “The record is submitted successful”

                    return Json(response);
                }

                return Json(response);
                // popup a modal with message "It is not possible to create two records with the same “Default Value” value. The record with Default Value <Name of Entry> already exists. Do you want to correct the value?"
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("Edit")]
        public async Task<JsonResult> Edit([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            if (jsonObject["KeyId"] == null) return Json("");
            long idfsTestResult = 0;
            if (jsonObject["idfsTestResult"] != null)
            {
                idfsTestResult = long.TryParse(jsonObject["strTestResultDefault"]?.ToString(), out var result) == false
                    ? long.Parse(jsonObject["idfsTestResult"].ToString())
                    : result;
            }

            var request = new TestNameTestResultsMatrixSaveRequestModel
            {
                idfsTestName = jsonObject["idfsTestName"] != null
                    ? long.Parse(jsonObject["idfsTestName"].ToString())
                    : null,
                idfsTestResult = idfsTestResult,
            };

            var response = await _configurationClient.SaveTestNameTestResultsMatrix(request);

            if (response.idfsTestResult != 0 && response.ReturnMessage == "SUCCESS")
            {
                // popup a modal with message “The record is submitted successful”
            }

            return Json("");
        }

        [HttpPost]
        public async Task<JsonResult> Delete([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            if (jsonObject["KeyId"] == null) return Json("");

            var request = new TestNameTestResultsMatrixSaveRequestModel
            {
                idfsTestName = long.Parse(jsonObject["idfsTestName"]?.ToString() ?? Empty),
                idfsTestResult = long.Parse(jsonObject["KeyId"].ToString()),
                idfsTestResultRelation = long.Parse(jsonObject["TestResultRelation"]?.ToString() ?? Empty),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            var response = await _configurationClient.DeleteTestNameTestResultsMatrix(request);
            
            if (response.ReturnMessage == "IN USE")
            {
                // popup a modal with message “You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?”
            }

            return Json(response);
        }

        [HttpPost]
        public async Task<IActionResult> AddTestName([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            var intHACodeTotal = 0;
            if (jsonObject["IntHACode"] != null)
            {
                if (IsNullOrEmpty(jsonObject["IntHACode"].ToString()))
                {
                    // popup a modal with message "Accessory Code is mandatory. You must enter data in this field before saving the form. Do you want to correct the value?"
                    return Json("");
                }

                var a = JArray.Parse(jsonObject["IntHACode"].ToString());

                intHACodeTotal += a.Sum(t => Parse(t["id"]?.ToString() ?? Empty));
            }

            var intOrder = 0;
            if (jsonObject["IntOrder"] != null)
            {
                intOrder = IsNullOrEmpty(((JValue) jsonObject["IntOrder"]).Value?.ToString())
                    ? 0
                    : Parse(jsonObject["IntOrder"].ToString());
            }

            var testType = 0;
            if (jsonObject["RadioButton2Configurations"] != null)
            {
                testType = IsNullOrEmpty(((JValue) jsonObject["RadioButton2Configurations"]).Value?.ToString())
                    ? 0
                    : Parse(jsonObject["RadioButton2Configurations"].ToString());
            }

            var request = new BaseReferenceSaveRequestModel
            {
                BaseReferenceId = null,
                Default = jsonObject["StrDefault"] != null ? jsonObject["StrDefault"].ToString() : Empty,
                Name = jsonObject["StrName"] != null ? jsonObject["StrName"].ToString() : Empty,
                intHACode = intHACodeTotal,
                intOrder = intOrder,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeId = testType,
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            var response = await _adminClient.SaveBaseReference(request);

            response.strDuplicatedField =
                Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);

            return Json(response);
        }

        //  [Route("create")]

        [Route("TestNameList")]
        public async Task<JsonResult> TestNameList(int page, string data)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            var idfsReferenceType = BaseReferenceConstants.TestName;
            var jsonObject = JObject.Parse(data);
            if (jsonObject["id"] != null)
            {
                if (jsonObject["text"] != null)
                {
                    idfsReferenceType = (long) jsonObject["text"] == (long) ReferenceTypes.PensideTestName
                        ? BaseReferenceConstants.PensideTestName
                        : BaseReferenceConstants.TestName;
                }
            }

            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), idfsReferenceType, null);

            if (list != null)
            {
                select2DataItems.AddRange(list.Select(item => new Select2DataItem
                    {id = item.IdfsBaseReference.ToString(), text = item.Name}));
            }

            select2DataObj.results = select2DataItems;
            return Json(select2DataObj);
        }

        [Route("create")]
        [Route("[controller]/[action]")]
        public async Task<JsonResult> GetTestResultsList(int page, string data, string term)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();
            var idfsReferenceType = BaseReferenceConstants.TestResult;
            var jsonObject = JObject.Parse(data);

            if (jsonObject["id"] != null)
            {
                if (jsonObject["text"] != null)
                {
                    idfsReferenceType = (long) jsonObject["text"] == (long) ReferenceTypes.PensideTestName ? BaseReferenceConstants.PensideTestResult : BaseReferenceConstants.TestResult;
                }
            }

            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), idfsReferenceType, null);
            if (!IsNullOrEmpty(term))
            {
                List<BaseReferenceViewModel> toList = list.Where(c => c.Name != null && c.Name.Contains(term, StringComparison.CurrentCultureIgnoreCase)).ToList();
                list = toList;
            }
            select2DataItems.Add(new Select2DataItem {id = "", text = ""});
            if (list != null)
            {
                select2DataItems.AddRange(list.Select(item => new Select2DataItem
                    {id = item.IdfsBaseReference.ToString(), text = item.Name}));
            }

            select2DataObj.results = select2DataItems;
            return Json(select2DataObj);
        }

        [HttpPost]
        [Route("AddTestResults")]
        public async Task<IActionResult> AddTestResults([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            var intHACodeTotal = 0;
            if (jsonObject["IntHACode"] != null)
            {
                if (IsNullOrEmpty(jsonObject["IntHACode"].ToString()))
                {
                    // popup a modal with message "Accessory Code is mandatory. You must enter data in this field before saving the form. Do you want to correct the value?"
                    return Json("");
                }

                var a = JArray.Parse(jsonObject["IntHACode"].ToString());

                intHACodeTotal += a.Sum(t => Parse(t["id"]?.ToString() ?? Empty));
            }

            var intOrder = 0;
            if (jsonObject["intOrder"] != null)
            {
                intOrder = IsNullOrEmpty(((JValue) jsonObject["IntOrder"])?.Value?.ToString())
                    ? 0
                    : Parse(jsonObject["IntOrder"]?.ToString() ?? Empty);
            }

            var testType = 0;
            if (jsonObject["RadioButton2Configurations"] != null)
            {
                testType = IsNullOrEmpty(((JValue) jsonObject["RadioButton2Configurations"]).Value?.ToString())
                    ? 0
                    : Parse(jsonObject["RadioButton2Configurations"].ToString());
            }

            long idfsReferenceType;
            if (testType == Convert.ToInt32(ReferenceTypes.PensideTestName))
            {
                idfsReferenceType = (long) ReferenceTypes.PensideTestResult;
            }
            else
            {
                idfsReferenceType = (long) ReferenceTypes.TestResults;
            }

            var request = new BaseReferenceSaveRequestModel
            {
                BaseReferenceId = null,
                Default = jsonObject["StrDefault"] != null ? jsonObject["StrDefault"].ToString() : Empty,
                Name = jsonObject["StrName"] != null ? jsonObject["StrName"].ToString() : Empty,
                intHACode = intHACodeTotal,
                intOrder = intOrder,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeId = idfsReferenceType,
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            var response = await _adminClient.SaveBaseReference(request);
            if (response.ReturnMessage == "DOES EXIST")
            {
                   response.strDuplicatedField =
                   Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            }

            return Json(response);
        }
    }
}
