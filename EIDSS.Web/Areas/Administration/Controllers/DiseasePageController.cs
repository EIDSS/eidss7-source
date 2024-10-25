using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
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
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class DiseasePageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _diseasePageViewModel;
        private readonly IDiseaseClient _diseaseClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ISpeciesTypeClient _speciesTypeClient;
        private readonly IStringLocalizer _localizer;

        public DiseasePageController(ICrossCuttingClient crossCuttingClient, IDiseaseClient diseaseClient, ISpeciesTypeClient speciesTypeClient, ITokenService tokenService,
            IStringLocalizer localizer, ILogger<DiseasePageController> logger) : base(logger, tokenService)
        {
            _diseasePageViewModel = new BaseReferenceEditorPagesViewModel
            {
                Select2Configurations = new List<Select2Configruation>()
            };
            _diseaseClient = diseaseClient;
            _crossCuttingClient = crossCuttingClient;
            _speciesTypeClient = speciesTypeClient;
            _localizer = localizer;
            _diseasePageViewModel.UserPermissions = GetUserPermissions(PagePermission.CanManageDiseasePage);
            _diseasePageViewModel.DiseaseAccessRightsUserPermissions = GetUserPermissions(PagePermission.CanWorkWithAccessRightsManagement);
        }

        public async Task<IActionResult> Index()
        {
            _diseasePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _diseasePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            _diseasePageViewModel.SearchActorViewModel = new()
            {
                ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.UsersAndGroupsListModalHeading),
                ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false),
                SearchCriteria = new ActorGetRequestModel(),
                SiteID = long.Parse(authenticatedUser.SiteId)
            };

            return View(_diseasePageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { SearchBox = "" };
            var search = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            var iPage = dataTableQueryPostObj.page;
            var iLength = dataTableQueryPostObj.length;

            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            if (valuePair.Key == "IdfsDiagnosis")
            {
                valuePair = new KeyValuePair<string, string>();
            }

            var request = new DiseasesGetRequestModel
            {
                AdvancedSearch = search.SearchBox == string.Empty ? null : search.SearchBox,
                Page = iPage,
                PageSize = iLength,
                SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "intOrder",
                SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending,
                SimpleSearch = null,
                LanguageId = GetCurrentLanguage(),
                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
            };

            var dlvm = await _diseaseClient.GetDiseasesList(request);
            IEnumerable<BaseReferenceEditorsViewModel> diseaseList = dlvm;

            TableData tableData = new()
            {
                data = new List<List<string>>(),
                iTotalRecords = dlvm.Count == 0 ? 0 : dlvm[0].TotalRowCount,
                iTotalDisplayRecords = dlvm.Count == 0 ? 0 : dlvm[0].TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            for (var i = 0; i < dlvm.Count; i++)
            {
                List<string> cols = new() {
                    (i + 1 + (iPage - 1) * iLength).ToString(),
                    diseaseList.ElementAt(i).KeyId.ToString(),
                    diseaseList.ElementAt(i).StrDefault != null ? diseaseList.ElementAt(i).StrDefault : "",
                    diseaseList.ElementAt(i).StrName != null ? diseaseList.ElementAt(i).StrName : "",
                    diseaseList.ElementAt(i).StrIDC10 != null ? diseaseList.ElementAt(i).StrIDC10 : "",
                    diseaseList.ElementAt(i).StrOIECode != null ? diseaseList.ElementAt(i).StrOIECode : "",
                    diseaseList.ElementAt(i).StrSampleType != null ? diseaseList.ElementAt(i).StrSampleType : "",
                    diseaseList.ElementAt(i).StrSampleTypeNames != null ? diseaseList.ElementAt(i).StrSampleTypeNames : "",
                    diseaseList.ElementAt(i).StrLabTest != null ? diseaseList.ElementAt(i).StrLabTest : "",
                    diseaseList.ElementAt(i).StrLabTestNames != null ? diseaseList.ElementAt(i).StrLabTestNames : "",
                    diseaseList.ElementAt(i).StrPensideTest != null ? diseaseList.ElementAt(i).StrPensideTest : "",
                    diseaseList.ElementAt(i).StrPensideTestNames != null ? diseaseList.ElementAt(i).StrPensideTestNames : "",
                    diseaseList.ElementAt(i).IdfsUsingType.ToString(),
                    diseaseList.ElementAt(i).StrUsingType != null ? diseaseList.ElementAt(i).StrUsingType : "",
                    SplitHACode(diseaseList.ElementAt(i).IntHACode),
                    diseaseList.ElementAt(i).StrHACodeNames != null ? diseaseList.ElementAt(i).StrHACodeNames : "",
                    diseaseList.ElementAt(i).BlnZoonotic.ToString(),
                    diseaseList.ElementAt(i).BlnSyndrome != null ? diseaseList.ElementAt(i).BlnSyndrome.ToString() : "",
                    diseaseList.ElementAt(i).IntOrder != null ? diseaseList.ElementAt(i).IntOrder.ToString() : "",
                    "",
                    "",
                    diseaseList.ElementAt(i).KeyId.ToString()
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        [HttpPost]
        public async Task<JsonResult> SaveDisease([FromForm] DiseaseSaveRequestModel request)
        {
            var response = await _diseaseClient.SaveDisease(request);

            var strDuplicationMessage = string.Empty;

            if (response.ReturnMessage == "DOES EXIST")
            {
                strDuplicationMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            }
            else
            {
                response.ReturnMessage = "SUCCESS";
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
        public async Task<JsonResult> DeleteDisease([FromBody] JsonElement data)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["IdfsDiagnosis"] != null)
                {
                    var request = new DiseaseSaveRequestModel
                    {
                        ForceDelete = true,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        DiagnosisId = long.Parse(jsonObject["IdfsDiagnosis"]?.ToString() ?? string.Empty)
                    };

                    var response = await _diseaseClient.DeleteDisease(request);
                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["IdfsDiagnosis"]?.ToString() ?? string.Empty);

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
                _logger.LogError(ex.Message);
                throw;
            }

            return Json("");
        }

        [HttpPost]
        public async Task<IActionResult> AddEditDisease([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var strSampleTypes = CSV(jsonObject, "strSampleTypeName", "Sample Type");
            var strLabTests = CSV(jsonObject, "strLabTestName", "Test Name");
            var strPensideTests = CSV(jsonObject, "strPensideTestName", "Penside Test Name");

            DiseaseSaveRequestModel request = new()
            {
                DiagnosisId = jsonObject["IdfsDiagnosis"] == null ? null : long.Parse(jsonObject["IdfsDiagnosis"].ToString()),
                SampleType = string.IsNullOrEmpty(strSampleTypes) ? null : strSampleTypes,
                LabTest = string.IsNullOrEmpty(strLabTests) ? null : strLabTests,
                PensideTest = string.IsNullOrEmpty(strPensideTests) ? null : strPensideTests,
                intHACode = Common.GetHAcodeTotal(jsonObject, "strHACodeNames", _speciesTypeClient),
                UsingTypeId = Common.ExtractLongValue(jsonObject, "idfsUsingType", "StrUsingType"),
                Default = jsonObject["strDefault"]?.ToString(),
                Name = jsonObject["strName"]?.ToString(),
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            int.TryParse(jsonObject["intOrder"]?.ToString(), out var intOrder);
            request.intOrder = intOrder;
            request.IDC10 = jsonObject["strIDC10"]?.ToString();
            request.OIECode = jsonObject["strOIECode"]?.ToString();

            request.Zoonotic = ExtractBoolValue(jsonObject, "blnZoonotic");
            request.Syndrome = ExtractBoolValue(jsonObject, "blnSyndrome");
            request.LanguageId = GetCurrentLanguage();

            return Json(await SaveDisease(request));
        }

        private long GetBaseReferenceList(string referenceType, string strDefault)
        {
            var list = _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), referenceType, 510).Result;
            return (from item in list where item.StrDefault == strDefault select item.IdfsBaseReference).FirstOrDefault();
        }

        private string CSV(JObject jsonObject, string strArrayId, string strReferenceType)
        {
            long idfs;
            var strCSV = string.Empty;

            if (jsonObject[strArrayId] == null) return strCSV;
            if (jsonObject[strArrayId].ToString() == string.Empty) return strCSV;
            var a = JArray.Parse(jsonObject[strArrayId].ToString());

            for (var iIndex = 0; iIndex < a.Count; iIndex++)
            {
                if (!long.TryParse(JArray.Parse(jsonObject[strArrayId].ToString())[iIndex]["id"]?.ToString(), out idfs))
                {
                    idfs = GetBaseReferenceList(strReferenceType, JArray.Parse(jsonObject[strArrayId].ToString())[iIndex]["id"]?.ToString());
                }

                strCSV += idfs + ",";
            }
            strCSV = (strCSV + ".").Replace(",.", "");

            return strCSV;
        }

        private static string SplitHACode(int intHaCode)
        {
            var strHaCodes = string.Empty;

            for (var i = 0; i < 8; i++)
            {
                if ((intHaCode & int.Parse(Math.Pow(2, i).ToString(CultureInfo.InvariantCulture))) == Math.Pow(2, i))
                {
                    strHaCodes += Math.Pow(2, i) + ",";
                }
            }

            return (strHaCodes + ".").Replace(",.", "");
        }

        private static bool? ExtractBoolValue(JObject jsonObject, string strValue)
        {
            bool? bl = null;

            if (jsonObject[strValue] == null) return bl;
            try
            {
                var a = JArray.Parse(jsonObject[strValue].ToString());
                bl = bool.Parse(a[0]["Value"]?.ToString() ?? string.Empty);
            }
            catch (Exception e)
            {
                bl = jsonObject[strValue].ToString() != "[]" && bool.Parse(jsonObject[strValue].ToString());
            }
            return bl;
        }

        [HttpPost]
        public async Task<JsonResult> GetActorList([FromBody] long diseaseId)
        {
            try
            {
                var model = new ActorGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DiseaseID = diseaseId,
                    DiseaseFiltrationSearchIndicator = true,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "ActorName",
                    SortOrder = EIDSSConstants.SortConstants.Ascending
                };

                var list = await _crossCuttingClient.GetActorList(model);
                IEnumerable<ActorGetListViewModel> actorList = list;

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    draw = 1,
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0
                };

                if (list.Count <= 0) return Json(tableData);
                tableData.iTotalRecords = list[0].TotalRowCount;
                tableData.iTotalDisplayRecords = list[0].TotalRowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        actorList.ElementAt(i).ActorID.ToString(),
                        actorList.ElementAt(i).ObjectAccessID.ToString(),
                        actorList.ElementAt(i).ActorTypeID.ToString(),
                        actorList.ElementAt(i).ActorTypeName,
                        actorList.ElementAt(i).ActorName
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
        public async Task<JsonResult> GetPermissions([FromBody] long diseaseId)
        {
            try
            {
                var model = new ObjectAccessGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    ObjectID = diseaseId,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "ActorName",
                    SortOrder = EIDSSConstants.SortConstants.Ascending
                };

                var list = await _crossCuttingClient.GetObjectAccessList(model);
                IEnumerable<ObjectAccessGetListViewModel> permissionsList = list;

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    draw = 1,
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0
                };

                if (list.Count <= 0) return Json(tableData);
                tableData.iTotalRecords = list[0].TotalRowCount;
                tableData.iTotalDisplayRecords = list[0].TotalRowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        permissionsList.ElementAt(i).ReadPermissionIndicator.ToString(),
                        permissionsList.ElementAt(i).ObjectOperationTypeName,
                        permissionsList.ElementAt(i).ObjectAccessID.ToString(),
                        permissionsList.ElementAt(i).ObjectOperationTypeID.ToString(),
                        permissionsList.ElementAt(i).ObjectTypeID.ToString(),
                        permissionsList.ElementAt(i).ObjectID.ToString(),
                        permissionsList.ElementAt(i).ActorID.ToString(),
                        permissionsList.ElementAt(i).SiteID.ToString(),
                        permissionsList.ElementAt(i).PermissionTypeID.ToString(),
                        permissionsList.ElementAt(i).RowStatus.ToString(),
                        permissionsList.ElementAt(i).RowAction
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
        public ActionResult SelectActorList([FromBody] JsonElement data)
        {
            try
            {
                var list = JsonConvert.DeserializeObject<List<ActorGetListViewModel>>(data.ToString() ?? string.Empty);

                return View("_ActorResultsPartial", list);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> SaveDataAccessDetails([FromBody] JsonElement data)
        {
            try
            {
                ObjectAccessSaveRequestModel request = new()
                {
                    User = authenticatedUser.UserName,
                    ObjectAccessRecords = data.ToString()
                };

                var response = await _crossCuttingClient.SaveObjectAccess(request);

                return Json("");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }
}