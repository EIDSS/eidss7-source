using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.Configuration;
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

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class VectorTypeSampleTypeMatrixPageController : BaseController
    {
        readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IVectorTypeSampleTypeMatrixClient _configurationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IVectorTypeClient _vectorTypeClient;
        private readonly ISampleTypesClient _sampleTypesClient;
        private readonly IStringLocalizer _localizer;

        public VectorTypeSampleTypeMatrixPageController(IVectorTypeSampleTypeMatrixClient configurationClient, ICrossCuttingClient crossCuttingClient, IVectorTypeClient vectorTypeClient, ISampleTypesClient sampleTypesClient, IStringLocalizer localizer,
            ILogger<VectorTypeSampleTypeMatrixPageController> logger, ITokenService tokenService) : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            _crossCuttingClient = crossCuttingClient;
            _vectorTypeClient = vectorTypeClient;
            _sampleTypesClient = sampleTypesClient;
            _localizer = localizer;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _configurationMatrixViewModel.UserPermissions = userPermissions;
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
            var postParameterDefinitions = new { VectorTypeDDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            long? id = null;
            if (referenceType.VectorTypeDDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.VectorTypeDDD))
                {
                    id = long.Parse(referenceType.VectorTypeDDD);
                }
            }
            var sortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "strSampleTypeName";
            var sortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Descending;

            var request = new VectorTypeSampleTypeMatrixGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsVectorType = id,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
            };

            var result = await _configurationClient.GetVectorTypeSampleTypeMatrixList(request);
            IEnumerable<VectorTypeSampleTypeMatrixViewModel> list = result;

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (!list.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < list.Count(); i++)
            {
                var cols = new List<string>
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).idfSampleTypeForVectorType.ToString(),
                    list.ElementAt(i).idfsVectorType.ToString(),
                    list.ElementAt(i).idfsSampleType.ToString(),
                    list.ElementAt(i).strSampleTypeName,
                    ""
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            try
            {
                var sampleType = "";
                if (jsonObject["VectorTypeDDD"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["VectorTypeDDD"][0]?["id"]?.ToString()))
                    {
                        // should select a Vector Type
                        return Json("");
                    }
                }

                long idfsSampleType = 0;
                if (jsonObject["idfsSampleType"]?[0]?["id"] != null)
                {
                    idfsSampleType = long.Parse(jsonObject["idfsSampleType"][0]["id"].ToString());
                }
                if (jsonObject["idfsSampleType"]?[0]?["text"] != null)
                {
                    sampleType = jsonObject["idfsSampleType"][0]["text"].ToString();
                }
                var request = new VectorTypeSampleTypeMatrixSaveRequestModel
                {
                    idfSampleTypeForVectorType = null,
                    idfsVectorType = jsonObject["VectorTypeDDD"]?[0]?["id"] != null ? long.Parse(jsonObject["VectorTypeDDD"][0]["id"].ToString()) : null,
                    idfsSampleType = idfsSampleType,
                    EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                var response = await _configurationClient.SaveVectorTypeSampleTypeMatrix(request);
                response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), sampleType);

                if (response.idfSampleTypeForVectorType != 0 && response.ReturnMessage == "SUCCESS")
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
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            try
            {
                if (jsonObject["KeyId"] != null)
                {
                    long idfsSampleType = 0;
                    if (jsonObject["idfsSampleType"] != null)
                    {
                        idfsSampleType = long.TryParse(jsonObject["strSampleTypeName"]?.ToString(), out var result) == false ? long.Parse(jsonObject["idfsSampleType"].ToString()) : result;
                    }
                    var request = new VectorTypeSampleTypeMatrixSaveRequestModel
                    {
                        idfSampleTypeForVectorType = long.Parse(jsonObject["KeyId"].ToString()),
                        idfsVectorType = jsonObject["idfsVectorType"] != null ? long.Parse(jsonObject["idfsVectorType"].ToString()) : null,
                        idfsSampleType = idfsSampleType,
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };

                    var response = await _configurationClient.SaveVectorTypeSampleTypeMatrix(request);

                    if (response.idfSampleTypeForVectorType != 0 && response.ReturnMessage == "SUCCESS")
                    {
                        // popup a modal with message “The record is submitted successful”
                    }

                    return Json("");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return Json("");
        }

        [HttpPost]
        public async Task<JsonResult> Delete([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new VectorTypeSampleTypeMatrixSaveRequestModel
                    {
                        idfSampleTypeForVectorType = long.Parse(jsonObject["KeyId"].ToString()),
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };
                    var response = await _configurationClient.DeleteVectorTypeSampleTypeMatrix(request);
                    if (response.ReturnMessage == "IN USE")
                    {
                        // popup a modal with message “You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?”
                    }

                    return Json(response);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json("");
        }

        [Route("create")]
        [Route("[controller]/[action]")]
        public async Task<JsonResult> VectorTypeList(int page, string data)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.VectorType, EIDSSConstants.HACodeList.VectorHACode);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.IdfsBaseReference.ToString(), text = item.Name }));
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return Json(select2DataObj);
        }

        [HttpPost]
        public async Task<IActionResult> AddSampleType([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var request = new SampleTypeSaveRequestModel();

            var intHACodeTotal = 0;
            if (jsonObject["IntHACode"] != null)
            {
                if (string.IsNullOrEmpty(jsonObject["IntHACode"].ToString()))
                {
                    // popup a modal with message "Accessory Code is mandatory. You must enter data in this field before saving the form. Do you want to correct the value?"
                    return Json("");
                }

                var a = JArray.Parse(jsonObject["IntHACode"].ToString());

                intHACodeTotal += a.Sum(t => int.Parse(t["id"]?.ToString() ?? string.Empty));
                request.intHACode = intHACodeTotal;
            }

            var intOrder = 0;
            if (jsonObject["intOrder"] != null)
            {
                intOrder = string.IsNullOrEmpty(((JValue)jsonObject["intOrder"]).Value?.ToString()) ? 0 : int.Parse(jsonObject["intOrder"].ToString());
            }

            request.SampleTypeId = null;
            request.Default = jsonObject["StrDefault"] != null ? jsonObject["StrDefault"].ToString() : string.Empty;
            request.Name = jsonObject["StrName"] != null ? jsonObject["StrName"].ToString() : string.Empty;
            request.SampleCode = jsonObject["StrSampleCode"] != null ? jsonObject["StrSampleCode"].ToString() : string.Empty;
            request.intOrder = intOrder;
            request.LanguageId = GetCurrentLanguage();

            var response = await _sampleTypesClient.SaveSampleType(request);
            response.StrDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            return Json(response);
        }

        [HttpPost]
        public async Task<IActionResult> AddVectorType([FromBody] JsonElement data)
        {
            var request = new VectorTypeSaveRequestModel();

            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            request.VectorTypeId = null;
            request.Default = jsonObject["Default"] != null && jsonObject["Default"].ToString() != string.Empty ? jsonObject["Default"].ToString() : "";
            request.Name = jsonObject["Name"] != null && jsonObject["Name"].ToString() != string.Empty ? jsonObject["Name"].ToString() : "";
            request.Code = jsonObject["Code"] != null && jsonObject["Code"].ToString() != string.Empty ? jsonObject["Code"].ToString() : "";
            request.intOrder = jsonObject["Order"] != null && jsonObject["Order"].ToString() != string.Empty ? int.Parse(jsonObject["Order"].ToString()) : null;
            request.CollectionByPool = false;
            if (jsonObject["CollectedByPool"] != null && jsonObject["CollectedByPool"].ToString() != string.Empty && jsonObject["CollectedByPool"].ToString().Contains("1"))
                request.CollectionByPool = true;

            request.LanguageId = GetCurrentLanguage();

            var response = await _vectorTypeClient.SaveVectorType(request);
            response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            return Json(response);
        }
    }
}
