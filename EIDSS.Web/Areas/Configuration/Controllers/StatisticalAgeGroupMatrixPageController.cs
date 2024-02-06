using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int64;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class StatisticalAgeGroupMatrixPageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IConfigurationClient _configurationClient;
        private readonly IAdminClient _adminClient;
        private readonly IStringLocalizer _localizer;

        public StatisticalAgeGroupMatrixPageController(IConfigurationClient configurationClient,
            IAdminClient adminClient,
            ILogger<StatisticalAgeGroupMatrixPageController> logger,
            ITokenService tokenService,
            IStringLocalizer localizer) : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            _adminClient = adminClient;
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
            var postParameterDefinitions = new { AgeGroupDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? id = null;
            if (referenceType.AgeGroupDD != null)
            {
                if (!IsNullOrEmpty(referenceType.AgeGroupDD))
                {
                    id = Parse(referenceType.AgeGroupDD);
                }
            }

            var list = new List<StatisticalAgeGroupMatrixViewModel>();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                var sortColumn = "strStatisticalAgeGroupName";
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfDiagnosisAgeGroupToStatisticalAgeGroup")
                {
                    sortColumn = valuePair.Key;
                }

                var request = new StatisticalAgeGroupMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsDiagnosisAgeGroup = id,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = sortColumn,
                    SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
                };

                list = await _configurationClient.GetStatisticalAgeGroupMatrixList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (!list.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < list.Count; i++)
            {
                var cols = new List<string>
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).IdfDiagnosisAgeGroupToStatisticalAgeGroup.ToString(),
                    list.ElementAt(i).IdfsDiagnosisAgeGroup.ToString(),
                    list.ElementAt(i).IdfsStatisticalAgeGroup.ToString(),
                    list.ElementAt(i).StrStatisticalAgeGroupName,
                    ""
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            StatisticalAgeGroupMatrixSaveRequestResponseModel response;
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            try
            {
                var statisticalAgeGroup = Empty;
                if (jsonObject["StatisticalAgeGroupDD"] != null)
                {
                    if (IsNullOrEmpty(jsonObject["StatisticalAgeGroupDD"].ToString()))
                    {
                        // should select a Statistical Age Group
                        return Json("");
                    }
                    else
                    {
                        statisticalAgeGroup = jsonObject["StatisticalAgeGroupDD"][0]?["text"]?.ToString();
                    }
                }

                long idfsDiagnosisAgeGroup = 0;
                if (jsonObject["AgeGroupDD"] != null)
                {
                    idfsDiagnosisAgeGroup = Parse(jsonObject["AgeGroupDD"][0]?["id"]?.ToString() ?? Empty);
                }

                var request = new StatisticalAgeGroupMatrixSaveRequestModel
                {
                    idfDiagnosisAgeGroupToStatisticalAgeGroup = null,
                    idfsStatisticalAgeGroup = jsonObject["StatisticalAgeGroupDD"] != null ? Parse(jsonObject["StatisticalAgeGroupDD"][0]?["id"]?.ToString() ?? Empty) : null,
                    idfsDiagnosisAgeGroup = idfsDiagnosisAgeGroup,
                    EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                response = await _configurationClient.SaveStatisticalAgeGroupMatrix(request);
                response.DuplicatedField = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), statisticalAgeGroup);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
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
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                var request = new StatisticalAgeGroupMatrixSaveRequestModel
                {
                    EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                if (jsonObject["IdfDiagnosisAgeGroupToStatisticalAgeGroup"] != null)
                {
                    request.idfDiagnosisAgeGroupToStatisticalAgeGroup =
                        Parse(jsonObject["IdfDiagnosisAgeGroupToStatisticalAgeGroup"].ToString());
                    response = await _configurationClient.DeleteStatisticalAgeGroupMatrix(request);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(response);
        }

        [Route("GetAgeGroupList")]
        public async Task<JsonResult> GetAgeGroupList(int? page, string term)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            try
            {
                var request = new AgeGroupGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    AdvancedSearch = term,
                    Page = page ?? 1,
                    PageSize = 10,
                    SortColumn = "intOrder",
                    SortOrder = SortConstants.Ascending
                };
                var list = await _adminClient.GetAgeGroupList(request);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem {id = item.KeyId.ToString(), text = item.StrName}));
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

        [HttpPost()]
        public async Task<IActionResult> AddStatisticalAgeGroup([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            var intOrder = 0;
            if (jsonObject["intOrder"] != null)
            {
                intOrder = IsNullOrEmpty(((JValue)jsonObject["intOrder"]).Value?.ToString()) ? 0 : int.Parse(jsonObject["intOrder"].ToString());
            }

            var request = new BaseReferenceSaveRequestModel
            {
                BaseReferenceId = null,
                Default = jsonObject["StrDefault"] != null ? jsonObject["StrDefault"].ToString() : Empty,
                Name = jsonObject["StrName"] != null ? jsonObject["StrName"].ToString() : Empty,
                intHACode = (int) AccessoryCodes.HumanHACode, //always human in this case
                intOrder = intOrder,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeId = BaseReferenceTypeIds.StatisticalAgeGroup,
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            var response = await _adminClient.SaveBaseReference(request);
            response.strClientPageMessage = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Name);
            return Json(response);
        }
    }
}