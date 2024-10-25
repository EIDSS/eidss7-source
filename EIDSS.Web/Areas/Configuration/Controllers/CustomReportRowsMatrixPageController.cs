using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
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

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class CustomReportRowsMatrixPageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IConfigurationClient _configurationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IStringLocalizer _localizer;

        public CustomReportRowsMatrixPageController(IConfigurationClient configurationClient, ICrossCuttingClient crossCuttingClient, IStringLocalizer localizer,
            ILogger<CustomReportRowsMatrixPageController> logger, ITokenService tokenService)
            : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            _crossCuttingClient = crossCuttingClient;
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
            var postParameterDefinitions = new { PageLevelDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? id = null;
            if (referenceType.PageLevelDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.PageLevelDD))
                {
                    id = long.Parse(referenceType.PageLevelDD);
                }
            }

            List<ConfigurationMatrixViewModel> list = new();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                //always sort by the user defined row order
                var strSortColumn = "intRowOrder";

                var request = new CustomReportRowsMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsCustomReportType = id,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
                };

                list = await _configurationClient.GetCustomReportRowsMatrixList(request);
            }

            TableData tableData = new()
            {
                data = new List<List<string>>(),

                iTotalRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (list.Count <= 0) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < list.Count; i++)
            {
                List<string> cols = new()
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).KeyId.ToString(),
                    list.ElementAt(i).intRowOrder.ToString(),
                    list.ElementAt(i).idfsCustomReportType.ToString(),
                    list.ElementAt(i).strDiseaseOrReportDiseaseGroup,
                    list.ElementAt(i).strDiagnosisOrDiagnosisGroupName,
                    list.ElementAt(i).strUsingType,
                    list.ElementAt(i).strAdditionalReportText,
                    list.ElementAt(i).strICDReportAdditionalText,
                    "True"
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            APISaveResponseModel response;

            try
            {
                if (jsonObject["PageLevelDD"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["PageLevelDD"][0]?["id"]?.ToString()))
                    {
                        // should select a Sample Type
                        return Json("");
                    }
                }

                long idfsDiagnosisOrReportDiagnosisGroup = 0;
                if (jsonObject["idfsDiagnosisOrReportDiagnosisGroup"] != null)
                {
                    idfsDiagnosisOrReportDiagnosisGroup = long.Parse(jsonObject["idfsDiagnosisOrReportDiagnosisGroup"][0]?["id"]?.ToString() ?? string.Empty);
                }

                var request = new CustomReportRowsMatrixSaveRequestModel
                {
                    idfReportRows = null,
                    idfsCustomReportType = jsonObject["PageLevelDD"]?[0]?["id"] != null ? long.Parse(jsonObject["PageLevelDD"]?[0]?["id"].ToString() ?? string.Empty) : null,
                    idfsDiagnosisOrReportDiagnosisGroup = idfsDiagnosisOrReportDiagnosisGroup,
                    idfsReportAdditionalText = jsonObject["idfsReportAdditionalText"] != null ? long.Parse(jsonObject["idfsReportAdditionalText"][0]?["id"]?.ToString() ?? string.Empty) : null,
                    idfsICDReportAdditionalText = jsonObject["idfsICDReportAdditionalText"] != null ? long.Parse(jsonObject["idfsICDReportAdditionalText"][0]?["id"]?.ToString() ?? string.Empty) : null,
                    EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                response = await _configurationClient.SaveCustomReportRowsMatrix(request);
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        jsonObject["idfsDiagnosisOrReportDiagnosisGroup"]?[0]?["text"]),
                    "SUCCESS" => _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                    _ => response.strClientPageMessage
                };
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
                throw;
            }

            return Json(response);
        }

        [HttpPost]
        public async Task<JsonResult> Delete([FromBody] JsonElement data)
        {
            var response = new APIPostResponseModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new CustomReportRowsMatrixSaveRequestModel
                    {
                        idfReportRows = long.Parse(jsonObject["KeyId"].ToString()),
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };
                    response = await _configurationClient.DeleteCustomReportRowsMatrix(request);
                    if (response.ReturnMessage == "IN USE")
                    {
                        // popup a modal with message “You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?”
                    }

                    // reload the grid
                    //BR: System shall sequentially renumber row, when row is deleted. 
                    return Json(response);
                }
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
                throw;
            }

            return Json("");
        }

        [HttpPost]
        public async Task<JsonResult> SaveRowOrder([FromBody] RowOrderModel[] model)
        {
            try
            {
                if (model != null)
                {
                    var request = new CustomReportRowsRowOrderSaveRequestModel
                    {
                        Rows = model
                    };

                    var response = await _configurationClient.SaveCustomReportRowsOrder(request);
                    return Json(response);
                }
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
                throw;
            }

            return Json("");
        }

        [HttpGet]
        public JsonResult DiseaseOrGroupList(string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            List<SelectDataItemViewModel> list = new();

            try
            {
                list.Add(new SelectDataItemViewModel { ID = "0", Name = string.Empty });
                list.Add(new SelectDataItemViewModel { ID = EIDSSConstants.ReportDiseaseGroupType.Disease.ToString(), Name = EIDSSConstants.ReportDiseaseGroupTypeConstants.Disease });
                list.Add(new SelectDataItemViewModel { ID = EIDSSConstants.ReportDiseaseGroupType.ReportDiseaseGroup.ToString(), Name = EIDSSConstants.ReportDiseaseGroupTypeConstants.ReportDiseaseGroup });

                if (!string.IsNullOrEmpty(term))
                {
                    var toList = list.Where(c => c.Name != null && c.Name.Contains(term, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    list = toList;
                }

                select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.ID, text = item.Name }));

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
                throw;
            }
            return Json(select2DataObj);
        }

        [HttpGet]
        public async Task<JsonResult> DiseaseList(string data)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();

            try
            {
                var jsonObject = JObject.Parse(data);
                var diseaseOrGroup = 0;
                if (jsonObject["id"] != null)
                {
                    diseaseOrGroup = int.Parse(jsonObject["id"].ToString());
                }

                List<BaseReferenceViewModel> list;
                if (diseaseOrGroup == EIDSSConstants.ReportDiseaseGroupType.Disease)
                {
                    list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.Disease, EIDSSConstants.HACodeList.HALVHACode);
                }
                else
                {
                    list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.ReportDiseaseGroup, EIDSSConstants.HACodeList.HALVHACode);
                }

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.IdfsBaseReference.ToString(), text = item.StrDefault }));
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
                throw ex;
            }

            return Json(select2DataObj);
        }

        [Route("GetDiseaseOrReportGroupDiseases")]
        public async Task<JsonResult> GetDiseaseOrReportGroupDiseases(int page, string data, string term)
        {
            Pagination pagination = new();
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            var referenceTypeId = (long)BaseReferenceTypeEnum.Disease;
            var jsonObject = JObject.Parse(data);

            if (jsonObject["id"] != null)
                referenceTypeId = (long)((long)jsonObject["id"] == (long)BaseReferenceTypeEnum.Disease ? BaseReferenceTypeEnum.Disease : BaseReferenceTypeEnum.ReportDiseaseGroup);

            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = referenceTypeId,
                Page = page,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                AdvancedSearch = term,
                SortColumn = "intorder",
                SortOrder = EIDSSConstants.SortConstants.Ascending
            };

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem
                    { id = item.KeyId.ToString(), text = item.StrName }));
                    select2DataObj.results = select2DataItems;

                    if (list.Any() && list.First().TotalRowCount > 10)
                    {
                        //Add Pagination
                        pagination.more = true;
                        select2DataObj.pagination = pagination;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }
    }
}
