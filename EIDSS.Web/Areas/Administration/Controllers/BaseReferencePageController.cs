using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
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
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using JsonSerializer = System.Text.Json.JsonSerializer;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class BaseReferencePageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _baseReferencePageViewModel;

        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IAdminClient _adminClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;
        private static List<BaseReferenceViewModel> BaseReferenceTypes { get; set; }
        private static List<BaseReferenceEditorsViewModel> BaseReferenceEditorSettings { get; set; }

        public BaseReferencePageController(ICrossCuttingClient crossCuttingClient, IAdminClient adminClient,
            ITokenService tokenService, IStringLocalizer localizer,
            ILogger<BaseReferencePageController> logger) : base(logger, tokenService)
        {
            _baseReferencePageViewModel = new BaseReferenceEditorPagesViewModel();
            _crossCuttingClient = crossCuttingClient;
            _adminClient = adminClient;
            _userPermissions = GetUserPermissions(PagePermission.CanManageBaseReferencePage);
            _localizer = localizer;
            _baseReferencePageViewModel.UserPermissions = _userPermissions;

            if (BaseReferenceTypes is null)
            {
                BaseReferenceTypes = _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                EIDSSConstants.BaseReferenceConstants.ReferenceTypeName, null).Result;
            }

            _baseReferencePageViewModel.basereferenceTypes = BaseReferenceTypes.Where(x => x.BlnSystem == true)
                .Select(x => x.IdfsBaseReference.ToString()).ToList();

            _baseReferencePageViewModel.Case_AddSystemTypesToDisable = GetEditorSettings(EIDSSConstants.BaseReferenceEditorSetting.AddDisabled);
            _baseReferencePageViewModel.Case_LOINCSystemTypesToHide = GetEditorSettings(EIDSSConstants.BaseReferenceEditorSetting.LOINCHide);
            _baseReferencePageViewModel.Case_HACodeSystemTypesToHide = GetEditorSettings(EIDSSConstants.BaseReferenceEditorSetting.HACodeHide);
            _baseReferencePageViewModel.Case_DefaultReadOnly = GetEditorSettings(EIDSSConstants.BaseReferenceEditorSetting.DefaultReadOnly);
            _baseReferencePageViewModel.Case_OrderByReadOnly = GetEditorSettings(EIDSSConstants.BaseReferenceEditorSetting.OrderByReadOnly);

            var request = new BaseReferenceTranslationRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfsBaseReference = EIDSSConstants.BaseReferenceTypeIds.AccessionCondition
            };
            _baseReferencePageViewModel.DefaultPersonalIDType =
                _crossCuttingClient.GetBaseReferenceTranslation(request).Result.First().name;
        }

        public IActionResult Index()
        {
            try
            {
                _baseReferencePageViewModel.Select2Configurations = new List<Select2Configruation>();
                _baseReferencePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
                _baseReferencePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return View(_baseReferencePageViewModel);
        }

        public IActionResult Edit()
        {
            _baseReferencePageViewModel.Select2Configurations = new List<Select2Configruation>();
            _baseReferencePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _baseReferencePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            return View(_baseReferencePageViewModel);
        }

        /// <summary>
        ///     Loads Data for the Grid
        /// </summary>
        /// <param name="dataTableQueryPostObj"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> GetBaseReferenceTableNew(
            [FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { ReferenceTypeDD = "", LamontTestTextBox = "", LamontTestTextBox2 = "" };
            var referenceType =
                JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs,
                    postParameterDefinitions);
            var baseReferenceList = new List<BaseReferenceEditorsViewModel>();
            var tableData = new TableData();
            try
            {
                //API CALL
                if (dataTableQueryPostObj.postArgs.Length > 0)
                {
                    //Sorting
                    var valuePair = dataTableQueryPostObj.ReturnSortParameter();
                    if (!string.IsNullOrEmpty(referenceType.ReferenceTypeDD))
                    {
                        _baseReferencePageViewModel.baseReferenceListViewModel = await
                            _adminClient.GetBaseReferenceListAsync(
                                GetCurrentLanguage(),
                                long.Parse(referenceType.ReferenceTypeDD),
                                dataTableQueryPostObj.page,
                                dataTableQueryPostObj.length,
                                !string.IsNullOrEmpty(valuePair.Key) & (valuePair.Key != "BaseReferenceId")
                                    ? valuePair.Key
                                    : "intorder",
                                !string.IsNullOrEmpty(valuePair.Value)
                                    ? valuePair.Value
                                    : EIDSSConstants.SortConstants.Ascending);
                        baseReferenceList = _baseReferencePageViewModel.baseReferenceListViewModel.ToList();
                        BaseReferenceEditorSettings = baseReferenceList;
                    }
                }

                tableData.iTotalRecords = baseReferenceList.Count == 0 ? 0 : baseReferenceList.First().TotalRowCount;
                tableData.iTotalDisplayRecords = !baseReferenceList.Any() ? 0 : baseReferenceList.First().TotalRowCount;
                tableData.draw = dataTableQueryPostObj.draw;
                tableData.data = new List<List<string>>();
                if (baseReferenceList.Count > 0)
                {
                    var row = dataTableQueryPostObj.page > 0
                        ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length
                        : 0;
                    for (var i = 0; i < baseReferenceList.Count(); i++)
                    {
                        var cols = new List<string>
                        {
                            (row + i + 1).ToString(),
                            baseReferenceList.ElementAt(i).KeyId.ToString(),
                            baseReferenceList.ElementAt(i).IdfsReferenceType.ToString(),
                            baseReferenceList.ElementAt(i).StrDefault != null
                                ? baseReferenceList.ElementAt(i).StrDefault
                                : string.Empty,
                            baseReferenceList.ElementAt(i).StrName != null
                                ? baseReferenceList.ElementAt(i).StrName
                                : string.Empty,
                            baseReferenceList.ElementAt(i).LOINC != null
                                ? baseReferenceList.ElementAt(i).LOINC
                                : string.Empty,
                            baseReferenceList.ElementAt(i).StrHACodeNames != null
                                ? baseReferenceList.ElementAt(i).StrHACodeNames
                                : string.Empty,
                            baseReferenceList.ElementAt(i).StrHACode != null
                                ? baseReferenceList.ElementAt(i).StrHACode
                                : string.Empty,
                            baseReferenceList.ElementAt(i).IntOrder != null
                                ? baseReferenceList.ElementAt(i).IntOrder.ToString()
                                : string.Empty,
                            EditorSetting(baseReferenceList, i, "Edit").ToString(),
                            EditorSetting(baseReferenceList, i, "Delete").ToString()
                        };
                        tableData.data.Add(cols);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            return Json(tableData);
        }

        public ActionResult UpdateGrid()
        {
            try
            {
                _baseReferencePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
                _baseReferencePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
                return PartialView("_BaseReferenceEditorGridPartial", _baseReferencePageViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public bool EditorSetting(List<BaseReferenceEditorsViewModel> baseReferenceList, int i, string strSetting)
        {
            bool bEnabled = false;
            long? referenceTypeId = baseReferenceList.ElementAt(i).IdfsReferenceType;

            try
            {
                long? lEditSetting = baseReferenceList[0].EditorSettings;

                switch (strSetting)
                {
                    case "Edit":
                        bEnabled = ((lEditSetting & EIDSSConstants.BaseReferenceEditorSetting.EditDisabled) == 0);
                        break;
                    case "Delete":
                        bEnabled = ((lEditSetting & EIDSSConstants.BaseReferenceEditorSetting.DeleteDisabled) == 0);
                        break;
                }
            }
            catch (Exception ex)
            {

            }

            return bEnabled;
        }

        private string GetEditorSettings(long bres)
        {
            string strCases = string.Empty;

            foreach (var editorSetting in BaseReferenceTypes)
            {
                if ((editorSetting.EditorSettings & bres) == bres)
                {
                    strCases += "case " + editorSetting.IdfsBaseReference + ": ";
                }
            }

            return strCases;
        }

        /// <summary>
        ///     Edits Data
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> EditReferenceType([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);


            var response = new BaseReferenceSaveRequestResponseModel();
            var baseReferenceSaveRequestModel = new BaseReferenceSaveRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            try
            {
                if (jsonObject.Count > 0)
                {
                    if (jsonObject["StrDefault"] != null) baseReferenceSaveRequestModel.Default = jsonObject["StrDefault"].ToString();
                    if (jsonObject["StrName"] != null) baseReferenceSaveRequestModel.Name = jsonObject["StrName"].ToString();
                    baseReferenceSaveRequestModel.intOrder = !string.IsNullOrEmpty(jsonObject["IntOrder"]?.ToString()) ? int.Parse(jsonObject["IntOrder"].ToString()) : 0;
                    if (jsonObject["ReferenceTypeId"] != null) baseReferenceSaveRequestModel.ReferenceTypeId = long.Parse(jsonObject["ReferenceTypeId"].ToString());
                    if (jsonObject["BaseReferenceId"] != null) baseReferenceSaveRequestModel.BaseReferenceId = long.Parse(jsonObject["BaseReferenceId"].ToString());
                    if (jsonObject["LOINC"] != null) baseReferenceSaveRequestModel.LOINC = jsonObject["LOINC"].ToString();

                    if (jsonObject["StrHACodeNames"] != null)
                    {
                        var sumHaCode = 0;
                        for (var i = 0; i < jsonObject["StrHACodeNames"].Children().Count(); i++)
                        {
                            int.TryParse(jsonObject["StrHACodeNames"].Children().ElementAt(i)["id"]?.ToString(),
                                out var outResult);
                            sumHaCode += outResult;
                        }

                        baseReferenceSaveRequestModel.intHACode = sumHaCode;
                    }

                    response = await _adminClient.SaveBaseReference(baseReferenceSaveRequestModel);
                    response.strClientPageMessage =
                        string.Format(_localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage),
                            baseReferenceSaveRequestModel.Default);
                    response.strDuplicatedField =
                        string.Format(
                            _localizer.GetString(MessageResourceKeyConstants
                                .ItIsNotPossibleToHaveTwoRecordsWithSameValueDoYouWantToCorrectValueMessage),
                            baseReferenceSaveRequestModel.Default);
                    response.PageAction = PageActions.Edit;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            return Json(response);
        }

        /// <summary>
        ///     Adds a new Reference Type
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> AddNewReferenceType([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var serializer = JsonSerializer.Serialize(data);

            var response = new BaseReferenceSaveRequestResponseModel();
            var baseReferenceSaveRequestModel = new BaseReferenceSaveRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            try
            {
                if (jsonObject["StrHACode"] != null)
                {
                    var sumHaCode = 0;
                    for (var i = 0; i < jsonObject["StrHACode"].Children().Count(); i++)
                    {
                        int.TryParse(jsonObject["StrHACode"].Children().ElementAt(i)["id"]?.ToString(), out var outResult);
                        sumHaCode += outResult;
                    }

                    baseReferenceSaveRequestModel.intHACode = sumHaCode;
                }

                if (jsonObject["EnglishValue"] != null)
                    baseReferenceSaveRequestModel.Default = jsonObject["EnglishValue"].ToString();
                if (jsonObject["TranslatedValue"] != null)
                    baseReferenceSaveRequestModel.Name = jsonObject["TranslatedValue"].ToString();
                if (!string.IsNullOrEmpty(jsonObject["IntOrder"]?.ToString()))
                {
                    int.TryParse(jsonObject["IntOrder"].ToString(), out var intOrder);
                    baseReferenceSaveRequestModel.intOrder = intOrder;
                }
                else
                {
                    baseReferenceSaveRequestModel.intOrder = 0;
                }

                if (jsonObject["ReferenceTypeDD"] != null)
                    baseReferenceSaveRequestModel.ReferenceTypeId =
                        long.Parse(jsonObject["ReferenceTypeDD"][0]?["id"]?.ToString() ?? string.Empty);
                response = await _adminClient.SaveBaseReference(baseReferenceSaveRequestModel);
                response.PageAction = PageActions.Add;
                switch (response.ReturnMessage)
                {
                    case "DOES EXIST":
                        response.strClientPageMessage =
                            string.Format(_localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage),
                                baseReferenceSaveRequestModel.Default);
                        response.strDuplicatedField =
                            string.Format(
                                _localizer.GetString(MessageResourceKeyConstants
                                    .ItIsNotPossibleToHaveTwoRecordsWithSameValueDoYouWantToCorrectValueMessage),
                                baseReferenceSaveRequestModel.Default);
                        break;
                    case "SUCCESS":
                        response.strClientPageMessage =
                            string.Format(_localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage),
                                baseReferenceSaveRequestModel.Default);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(response);
        }

        public void HandleDeserializationError(object sender, ErrorEventArgs errorArgs)
        {
            errorArgs.ErrorContext.Handled = true;
        }

        /// <summary>
        ///     Deletes Data
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<JsonResult> DeleteModalData([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                var baseReferenceSaveRequestModel = new BaseReferenceSaveRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                if (jsonObject["BaseReferenceId"] != null)
                    baseReferenceSaveRequestModel.BaseReferenceId =
                        long.Parse(jsonObject["BaseReferenceId"].ToString());

                if (baseReferenceSaveRequestModel.BaseReferenceId != null)
                    await _adminClient.DeleteBaseReference(baseReferenceSaveRequestModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json("");
        }
    }
}