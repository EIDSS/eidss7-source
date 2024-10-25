using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Configuration.ViewModels;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Controllers.Configuration
{
    [Area("Configuration")]
    [Controller]
    public class ParameterTypeEditorPageController : BaseController
    {
        private ParameterTypeEditorPageViewModel _parameterTypeEditorPageViewModel;
        private IConfigurationClient _configurationClient;
        private IFlexFormClient _flexFormClient;
        private ICrossCuttingClient _crossCuttingClient;
        private IAdminClient _adminClient;
        private UserPermissions _userPermissions;
        private IStringLocalizer _localizer;

        public ParameterTypeEditorPageController(IConfigurationClient configurationClient,
            IFlexFormClient flexFormClient,
            ICrossCuttingClient crossCuttingClient,
            IAdminClient adminClient,
            ILogger<ParameterTypeEditorPageController> logger,
            IStringLocalizer localizer,
            ITokenService tokenService) : base(logger, tokenService)
        {
            _parameterTypeEditorPageViewModel = new ParameterTypeEditorPageViewModel();
            _parameterTypeEditorPageViewModel.SelectedDetail = new ParameterTypeEditorDetailsPageViewModel();
            _configurationClient = configurationClient;
            _flexFormClient = flexFormClient;
            _crossCuttingClient = crossCuttingClient;
            _localizer = localizer;
            _adminClient = adminClient;

            _userPermissions = GetUserPermissions(PagePermission.AccessToFlexibleFormsDesigner);
            _parameterTypeEditorPageViewModel.UserPermissions = _userPermissions;
            _parameterTypeEditorPageViewModel.SelectedDetail.UserPermissions = _userPermissions;
        }

        public IActionResult Index()
        {
            _parameterTypeEditorPageViewModel.ParameterTypeGridConfiguration = new EIDSSGridConfiguration();
            _parameterTypeEditorPageViewModel.ParameterTypeModalConfigurations = new List<EIDSSModalConfiguration>();
            _parameterTypeEditorPageViewModel.SelectedDetail.SelectConfigurations = new List<Select2Configruation>();
            _parameterTypeEditorPageViewModel.SelectedDetail.GridConfiguration = new EIDSSGridConfiguration();
            _parameterTypeEditorPageViewModel.SelectedDetail.ModalConfigurations = new List<EIDSSModalConfiguration>();
            _parameterTypeEditorPageViewModel.DefaultParameterType = new KeyValuePair<string, string>("0", _localizer.GetString(FieldLabelResourceKeyConstants.FixedPresetValuesLabel));
            return View(_parameterTypeEditorPageViewModel);
        }

        [HttpPost()]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            string searchString = null;
            if (referenceType.SearchBox != null)
            {
                searchString = referenceType.SearchBox;
            }

            KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
            string sortColumn;
            string sortOrder;
            List<ParameterTypeViewModel> list = new List<ParameterTypeViewModel>();

            //get the sort parameters
            valuePair = dataTableQueryPostObj.ReturnSortParameter();
            sortColumn = !String.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "IdfsParameterType"; //default sort by IdfsParameterType
            sortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc";

            var request = new ParameterTypeGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AdvancedSearch = !String.IsNullOrEmpty(searchString) ? searchString : null,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            list = await _configurationClient.GetParameterTypeList(request);

            TableData tableData = new TableData();
            tableData.data = new List<List<string>>();

            tableData.iTotalRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
            tableData.iTotalDisplayRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
            tableData.draw = dataTableQueryPostObj.draw;

            if (list.Count() > 0)
            {
                int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (int i = 0; i < list.Count(); i++)
                {
                    List<string> cols = new List<string>()
                    {
                        (row + i + 1).ToString(),
                        list.ElementAt(i).IdfsParameterType.ToString(),
                        list.ElementAt(i).DefaultName,
                        list.ElementAt(i).NationalName,
                        list.ElementAt(i).IdfsReferenceType.ToString(),
                        list.ElementAt(i).System,
                        list.ElementAt(i).ParameterTypeName,
                        list.ElementAt(i).BaseReferenceListName,
                        "",
                        "",
                        ""
                    };

                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);
        }

        [HttpPost]
        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            ParameterTypeSaveRequestResponseModel response = new ParameterTypeSaveRequestResponseModel();
            var jsonObject = JObject.Parse(data.ToString());

            //set the parameter type
            long? referenceTypeId = null;
            if (jsonObject["ParameterTypeName"] != null)
            {
                if (jsonObject["ParameterTypeName"][0]["id"].ToString().Contains("Fixed Preset Value") || jsonObject["ParameterTypeName"][0]["id"].ToString() == "0")
                {
                    referenceTypeId = BaseReferenceTypeIds.FixedPresetValueParameter;
                }
                else
                {
                    referenceTypeId = jsonObject["BaseReferenceDD"] != null ? long.Parse(jsonObject["BaseReferenceDD"][0]["id"].ToString()) : null;
                }
            }
            long? id = null;
            if (jsonObject["IdfsParameterType"] != null)
            {
                if (!string.IsNullOrEmpty(jsonObject["IdfsParameterType"].ToString()))
                {
                    id = long.Parse(jsonObject["IdfsParameterType"].ToString());
                }
            }
            try
            {
                var request = new ParameterTypeSaveRequestModel
                {
                    idfsParameterType = id,
                    idfsReferenceType = referenceTypeId,
                    DefaultName = jsonObject["DefaultName"].ToString(),
                    NationalName = jsonObject["NationalName"].ToString(),
                    HACode = EIDSSConstants.HACodeList.HALVHACode,
                    user = _tokenService.GetAuthenticatedUser().UserName,
                    langId = GetCurrentLanguage()
                };

                response = await _configurationClient.SaveParameterType(request);
                response.localizedMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.ItIsNotPossibleToCreateTwoRecordsWithTheSameValueTheRecordWithAlreadyExistsDoYouWantToCorrectTheValueMessage), jsonObject["DefaultName"].ToString());
            }
            catch (Exception ex)
            {
                throw;
            }

            return Json(response);
        }

        [HttpPost]
        public async Task<JsonResult> Save([FromBody] JsonElement data)
        {
            ParameterTypeSaveRequestResponseModel response = new ParameterTypeSaveRequestResponseModel();
            var jsonObject = JObject.Parse(data.ToString());

            //set the parameter type
            long? referenceTypeId = null;
            if (jsonObject["ParameterTypeName"] != null)
            {
                if (jsonObject["ParameterTypeName"][0]["id"].ToString().Contains("Fixed Preset Value") || jsonObject["ParameterTypeName"][0]["id"].ToString() == "0")
                {
                    referenceTypeId = BaseReferenceTypeIds.FixedPresetValueParameter;
                }
                else
                {
                    referenceTypeId = jsonObject["BaseReferenceListName"] != null ? long.Parse(jsonObject["BaseReferenceListName"][0]["id"].ToString()) : null;
                }
            }
            long? id = null;
            if (jsonObject["IdfsParameterType"] != null)
            {
                if (!string.IsNullOrEmpty(jsonObject["IdfsParameterType"].ToString()))
                {
                    id = long.Parse(jsonObject["IdfsParameterType"].ToString());
                }
            }
            try
            {
                var request = new ParameterTypeSaveRequestModel
                {
                    idfsParameterType = id,
                    idfsReferenceType = referenceTypeId,
                    DefaultName = jsonObject["DefaultName"].ToString(),
                    NationalName = jsonObject["NationalName"].ToString(),
                    HACode = EIDSSConstants.HACodeList.HALVHACode,
                    user = _tokenService.GetAuthenticatedUser().UserName,
                    langId = GetCurrentLanguage()
                };

                response = await _configurationClient.SaveParameterType(request);
            }
            catch (Exception ex)
            {
                throw;
            }

            return Json(response);
        }

        [Route("ParameterInUse")]
        [HttpPost()]
        public async Task<JsonResult> ParameterInUse([FromBody] JsonElement data)
        {
            var response = new List<FlexFormParameterInUseDetailViewModel>();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                if (jsonObject["IdfsParameterType"] != null)
                {
                    var _ = new FlexFormParameterInUseRequestModel()
                    {
                        idfsFormTemplate = null,
                        idfsParameter = long.Parse(jsonObject["IdfsParameterType"].ToString())
                    };
                    response = await _flexFormClient.IsParameterInUse(_);
                }
            }
            catch (Exception)
            {
                throw;
            }

            return Json(response);
        }

        [Route("[area]/[controller]/Delete")]
        [HttpPost()]
        public async Task<JsonResult> Delete([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new APIPostResponseModel();
            long id = 0;
            bool forceDelete;
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                if (jsonObject["IdfsParameterType"] != null)
                {
                    id = long.Parse(jsonObject["IdfsParameterType"].ToString());
                    if (jsonObject["ForceDelete"] == null)
                    {
                        forceDelete = false;
                    }
                    else
                    {
                        forceDelete = string.IsNullOrEmpty(jsonObject["ForceDelete"].ToString()) ? false : bool.Parse(jsonObject["ForceDelete"].ToString());
                    }

                    response = await _configurationClient.DeleteParameterType(id, _tokenService.GetAuthenticatedUser().UserName, forceDelete, GetCurrentLanguage());
                }
            }
            catch (Exception)
            {
                throw;
            }

            var jsonResponse = new
            {
                Id = id,
                ReturnCode = response.ReturnCode,
                ReturnMessage = response.ReturnMessage
            };

            return Json(jsonResponse);
        }

        [Route("GetParameterTypes")]
        public JsonResult GetParameterTypes(string term)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            List<SelectDataItemViewModel> list = new();

            list.Add(new SelectDataItemViewModel() { ID = "0", Name = _localizer.GetString(FieldLabelResourceKeyConstants.FixedPresetValuesLabel) });
            list.Add(new SelectDataItemViewModel() { ID = "1", Name = _localizer.GetString(FieldLabelResourceKeyConstants.ReferenceLabel) });

            if (!IsNullOrEmpty(term))
            {
                List<SelectDataItemViewModel> toList = list.Where(c => c.Name != null && c.Name.Contains(term, StringComparison.CurrentCultureIgnoreCase)).ToList();
                list = toList;
            }

            if (list != null)
            {
                foreach (var item in list)
                {
                    select2DataItems.Add(new Select2DataItem() { id = item.ID.ToString(), text = item.Name });
                }
            }

            select2DataObj.results = select2DataItems;

            return Json(select2DataObj);
        }

        [Route("LoadDetail")]
        [HttpPost]
        public async Task<IActionResult> LoadDetail([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                var systemType = jsonObject["System"].ToString();

                //look up the base reference
                string baseRefName = null;
                long? baseReferenceTypeId = long.TryParse(jsonObject["IdfsReferenceType"].ToString(), out long refTypeId) ? refTypeId : null;
                if (systemType == "1" && baseReferenceTypeId.HasValue)
                {
                    var request = new ParameterReferenceGetRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SortColumn = "NationalName",
                        SortOrder = "asc"
                    };
                    var list = await _configurationClient.GetParameterReferenceList(request);
                    baseRefName = list.Where(b => b.IdfsReferenceType == baseReferenceTypeId).FirstOrDefault().NationalName;
                }

                //populate a new detail model to return to partial
                var detailModel = _parameterTypeEditorPageViewModel.SelectedDetail;
                detailModel.UserPermissions = _userPermissions;
                detailModel.KeyId = long.Parse(jsonObject["IdfsParameterType"].ToString());
                detailModel.SelectConfigurations = new List<Select2Configruation>();
                detailModel.GridConfiguration = new EIDSSGridConfiguration();
                detailModel.ModalConfigurations = new List<EIDSSModalConfiguration>();
                detailModel.ParameterTypeName = jsonObject["ParameterTypeName"].ToString();
                detailModel.IdfsReferenceType = baseReferenceTypeId;
                detailModel.BaseReferenceListName = string.IsNullOrEmpty(baseRefName) ? string.Empty : baseRefName;
                detailModel.DefaultName = jsonObject["DefaultName"].ToString();
                detailModel.NationalName = jsonObject["NationalName"].ToString();
                detailModel.System = systemType;

                _parameterTypeEditorPageViewModel.SelectedDetail = detailModel;

                if (systemType == "1")
                {
                    return PartialView("_ReferenceValueDetailsPartial", _parameterTypeEditorPageViewModel.SelectedDetail);
                }
                else
                {
                    return PartialView("_FixedValueDetailsPartial", _parameterTypeEditorPageViewModel.SelectedDetail);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        [Route("SaveDetail")]
        [HttpPost]
        public async Task<JsonResult> SaveDetail([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());

            ParameterTypeSaveRequestResponseModel response = new ParameterTypeSaveRequestResponseModel();

            try
            {
                var request = new ParameterTypeSaveRequestModel
                {
                    idfsParameterType = jsonObject["IdfsParameterType"] != null ? long.Parse(jsonObject["IdfsParameterType"].ToString()) : null,
                    idfsReferenceType = jsonObject["IdfsReferenceType"] != null ? long.Parse(jsonObject["IdfsReferenceType"].ToString()) : null,
                    DefaultName = jsonObject["DefaultName"].ToString(),
                    NationalName = jsonObject["NationalName"].ToString(),
                    HACode = EIDSSConstants.HACodeList.HALVHACode,
                    langId = GetCurrentLanguage(),
                    user = _tokenService.GetAuthenticatedUser().UserName
                };

                response = await _configurationClient.SaveParameterType(request);
            }
            catch (Exception)
            {
                throw;
            }

            return Json(response);
        }

        [Route("GetParameterReferenceList")]
        public async Task<JsonResult> GetParameterReferenceList(string term)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();

            try
            {
                var request = new ParameterReferenceGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    SortColumn = "NationalName",
                    SortOrder = "asc"
                };

                var list = await _configurationClient.GetParameterReferenceList(request);

                if (!IsNullOrEmpty(term))
                {
                    List<ParameterReferenceViewModel> toList = list.Where(c => c.NationalName != null && c.NationalName.Contains(term, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    list = toList;
                }

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.IdfsReferenceType.ToString(), text = item.NationalName });
                    }
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception)
            {
                throw;
            }
            return Json(select2DataObj);
        }

        [Route("GetParameterReferenceValueList")]
        [HttpPost()]
        public async Task<JsonResult> GetParameterReferenceValueList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterReferenceDefinitions = new { ReferenceDD = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterReferenceDefinitions);
            List<ParameterReferenceValueViewModel> list = new List<ParameterReferenceValueViewModel>();
            KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();

            long id = 0;
            if (referenceType.ReferenceDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.ReferenceDD.ToString()))
                {
                    id = long.Parse(referenceType.ReferenceDD);
                }
            }

            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                valuePair = dataTableQueryPostObj.ReturnSortParameter();
            }

            var request = new ParameterReferenceValueGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsReferenceType = id,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = !String.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "DefaultName",
                SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc"
            };

            list = await _configurationClient.GetParameterReferenceValueList(request);

            TableData tableData = new TableData();
            tableData.data = new List<List<string>>();

            tableData.iTotalRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
            tableData.iTotalDisplayRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
            tableData.draw = dataTableQueryPostObj.draw;

            if (list.Count() > 0)
            {
                int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (int i = 0; i < list.Count(); i++)
                {
                    List<string> cols = new List<string>()
                    {
                        (row + i + 1).ToString(),
                        list.ElementAt(i).IdfsBaseReference.ToString(),
                        list.ElementAt(i).DefaultName,
                        list.ElementAt(i).NationalName,
                        list.ElementAt(i).IdfsReferenceType.ToString()
                    };

                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);
        }

        [Route("GetParameterFixedValueList")]
        [HttpPost()]
        public async Task<JsonResult> GetParameterFixedValueList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj, long id)
        {
            var postParameterFixedValueDefinitions = new { IdfsParameterType = "" };
            var parameterType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterFixedValueDefinitions);
            List<ParameterFixedPresetValueViewModel> list = new List<ParameterFixedPresetValueViewModel>();
            KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();

            var sortColumn = "intOrder";
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                valuePair = dataTableQueryPostObj.ReturnSortParameter();
                if (!String.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfsParameterType")
                {
                    sortColumn = valuePair.Key;
                }
            }

            var request = new ParameterFixedPresetValueGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsParameterType = id,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = sortColumn,
                SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc"
            };

            list = await _configurationClient.GetParameterFixedPresetValueList(request);

            TableData tableData = new TableData();
            tableData.data = new List<List<string>>();

            tableData.iTotalRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
            tableData.iTotalDisplayRecords = list.Count == 0 ? 0 : list.FirstOrDefault().TotalRowCount;
            tableData.draw = dataTableQueryPostObj.draw;

            if (list.Count() > 0)
            {
                int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (int i = 0; i < list.Count(); i++)
                {
                    List<string> cols = new List<string>()
                    {
                        //(row + i + 1).ToString(),
                        list.ElementAt(i).IdfsParameterType.ToString(),
                        list.ElementAt(i).IdfsReferenceType.ToString(),
                        list.ElementAt(i).IdfsParameterFixedPresetValue.ToString(),
                        list.ElementAt(i).DefaultName,
                        list.ElementAt(i).NationalName,
                        list.ElementAt(i).IntOrder.ToString(),
                        "",
                        ""
                    };

                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);
        }

        [Route("SaveParameterFixedValue")]
        [HttpPost()]
        public async Task<JsonResult> SaveParameterFixedValue([FromBody] JsonElement data)
        {
            var response = new ParameterFixedPresetValueSaveRequestResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                var request = new ParameterFixedPresetValueSaveRequestModel
                {
                    IdfsParameterType = jsonObject["IdfsParameterType"] != null ? long.Parse(jsonObject["IdfsParameterType"].ToString()) : null,
                    DefaultName = jsonObject["DefaultName"].ToString(),
                    NationalName = jsonObject["NationalName"].ToString(),
                    IdfsParameterFixedPresetValue = jsonObject["IdfsParameterFixedPresetValue"] != null ? long.Parse(jsonObject["IdfsParameterFixedPresetValue"].ToString()) : null,
                    LangId = GetCurrentLanguage(),
                    intOrder = jsonObject["IntOrder"] != null ? int.Parse(jsonObject["IntOrder"].ToString()) : 0
                };

                response = await _configurationClient.SaveParameterFixedPresetValue(request);
            }
            catch (Exception)
            {
                throw;
            }

            return Json(response);
        }

        [Route("CreateParameterFixedValue")]
        [HttpPost()]
        public async Task<JsonResult> CreateParameterFixedValue([FromBody] JsonElement data)
        {
            var response = new ParameterFixedPresetValueSaveRequestResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                var request = new ParameterFixedPresetValueSaveRequestModel
                {
                    IdfsParameterType = jsonObject["KeyId"] != null ? long.Parse(jsonObject["KeyId"].ToString()) : null,
                    DefaultName = jsonObject["DefaultName"].ToString(),
                    NationalName = jsonObject["NationalName"].ToString(),
                    IdfsParameterFixedPresetValue = jsonObject["IdfsParameterFixedPresetValue"] != null ? long.Parse(jsonObject["IdfsParameterFixedPresetValue"].ToString()) : null,
                    LangId = GetCurrentLanguage(),
                    // Bug 3863 - Handle if the user does not enter a value here
                    intOrder = jsonObject["Order"]?.ToString() == "" ? int.Parse("0") : int.Parse(jsonObject["Order"].ToString())
                };

                response = await _configurationClient.SaveParameterFixedPresetValue(request);
            }
            catch (Exception)
            {
                throw;
            }

            return Json(response);
        }

        [Route("DeleteParameterFixedValue")]
        [HttpPost()]
        public async Task<JsonResult> DeleteParameterFixedValue([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new APIPostResponseModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                if (jsonObject["IdfsParameterFixedPresetValue"] != null)
                {
                    response = await _configurationClient.DeleteParameterFixedPresetValue(long.Parse(jsonObject["IdfsParameterFixedPresetValue"].ToString()), false);
                }
            }
            catch (Exception)
            {
                throw;
            }

            return Json(response);
        }
    }
}