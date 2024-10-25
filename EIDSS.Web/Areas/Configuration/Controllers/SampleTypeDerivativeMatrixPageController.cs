using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
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
    public class SampleTypeDerivativeMatrixPageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IConfigurationClient _configurationClient;
        private readonly IStringLocalizer _localizer;

        public SampleTypeDerivativeMatrixPageController(IConfigurationClient configurationClient, IStringLocalizer localizer,
            ILogger<SampleTypeDerivativeMatrixPageController> logger, ITokenService tokenService)
            : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
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
            var postParameterDefinitions = new { SampleTypeDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? id = null;
            if (referenceType.SampleTypeDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.SampleTypeDD))
                {
                    id = long.Parse(referenceType.SampleTypeDD);
                }
            }

            var list = new List<ConfigurationMatrixViewModel>();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "strDerivative";
                if (!string.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "KeyId")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new SampleTypeDerivativeMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsSampleType = id,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
                };

                list = await _configurationClient.GetSampleTypeDerivativeMatrixList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (!list.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < list.Count; i++)
            {
                var cols = new List<string>
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).KeyId.ToString(),
                    list.ElementAt(i).idfsSampleType.ToString(),
                    list.ElementAt(i).idfsDerivativeType.ToString(),
                    list.ElementAt(i).strDerivative,
                    ""
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
                if (jsonObject["SampleTypeDD"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["SampleTypeDD"][0]?["id"]?.ToString()))
                    {
                        // should select a Sample Type
                        return Json("");
                    }
                }

                long idfsDerivativeType = 0;
                if (jsonObject["idfsDerivativeType"] != null)
                {
                    idfsDerivativeType = long.Parse(jsonObject["idfsDerivativeType"][0]?["id"]?.ToString() ?? string.Empty);
                }

                var request = new SampleTypeDerivativeMatrixSaveRequestModel
                {
                    idfDerivativeForSampleType = null,
                    idfsSampleType = jsonObject["SampleTypeDD"]?[0]?["id"] != null ? long.Parse(jsonObject["SampleTypeDD"][0]["id"].ToString()) : null,
                    idfsDerivativeType = idfsDerivativeType,
                    EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                response = await _configurationClient.SaveSampleTypeDerivativeMatrix(request);
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        jsonObject["idfsDerivativeType"]?[0]?["text"]),
                    "SUCCESS" => _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                    _ => response.strClientPageMessage
                };
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
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                if (jsonObject["KeyId"] != null)
                {
                    var request = new SampleTypeDerivativeMatrixSaveRequestModel
                    {
                        idfDerivativeForSampleType = Convert.ToInt64(jsonObject["KeyId"].ToString()),
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName,
                        deleteAnyway = false
                    };

                    var response = await _configurationClient.DeleteSampleTypeDerivativeMatrix(request);

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
    }
}
