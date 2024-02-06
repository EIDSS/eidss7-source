using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
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
using static System.Int64;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class SpeciesAnimalAgePageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IConfigurationClient _configurationClient;
        private readonly IAdminClient _adminClient;
        private readonly IStringLocalizer _localizer;

        public SpeciesAnimalAgePageController(IConfigurationClient configurationClient, IAdminClient adminClient, IStringLocalizer localizer,
            ILogger<SpeciesAnimalAgePageController> logger, ITokenService tokenService)
            : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            //_crossCuttingClient = crossCuttingClient;
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
            var postParameterDefinitions = new { SpeciesDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? id = null;
            if (referenceType.SpeciesDD != null)
            {
                if (!IsNullOrEmpty(referenceType.SpeciesDD))
                {
                    id = Parse(referenceType.SpeciesDD);
                }
            }

            var list = new List<ConfigurationMatrixViewModel>();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "strAnimalType";
                if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "KeyId")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new SpeciesAnimalAgeGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsSpeciesType = id,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc"
                };

                list = await _configurationClient.GetSpeciesAnimalAgeList(request);
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
                    list.ElementAt(i).KeyId.ToString(),
                    list.ElementAt(i).idfsSpeciesType.ToString(),
                    list.ElementAt(i).strSpeciesType,
                    list.ElementAt(i).idfsAnimalAge.ToString(),
                    list.ElementAt(i).strAnimalType,
                    ""
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            APISaveResponseModel response;

            try
            {
                if (jsonObject["SpeciesDD"] != null)
                {
                    if (IsNullOrEmpty(jsonObject["SpeciesDD"][0]?["id"]?.ToString()))
                    {
                        // should select a Sample Type
                        return Json("");
                    }
                }

                long idfsAnimalAge = 0;
                if (jsonObject["idfsAnimalAge"] != null)
                {
                    idfsAnimalAge = Parse(jsonObject["idfsAnimalAge"][0]?["id"]?.ToString() ?? Empty);
                }

                var request = new SpeciesAnimalAgeSaveRequestModel
                {
                    idfSpeciesTypeToAnimalAge = null,
                    idfsSpeciesType = jsonObject["SpeciesDD"]?[0]?["id"] != null ? Parse(jsonObject["SpeciesDD"][0]["id"].ToString()) : null,
                    idfsAnimalAge = idfsAnimalAge,
                    EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

               response = await _configurationClient.SaveSpeciesAnimalAge(request);

                response.PageAction = Domain.Enumerations.PageActions.Add;
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        jsonObject["idfsAnimalAge"]?[0]?["text"]),
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
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new SpeciesAnimalAgeSaveRequestModel
                    {
                        idfSpeciesTypeToAnimalAge = Parse(jsonObject["KeyId"].ToString()),
                        EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };
                    var response = await _configurationClient.DeleteSpeciesAnimalAge(request);
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

        [HttpPost]
        public async Task<IActionResult> AddAnimalAge([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            var request = new BaseReferenceSaveRequestModel
            {
                BaseReferenceId = null,
                ReferenceTypeId = 19000005,
                Default = jsonObject["Default"]?.ToString(),
                Name = jsonObject["Name"]?.ToString(),
                intOrder = !IsNullOrEmpty(jsonObject["intOrder"]?.ToString()) ? int.Parse(jsonObject["intOrder"].ToString()) : 0,
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            var response = await _adminClient.SaveBaseReference(request);
            response.PageAction = Domain.Enumerations.PageActions.Add;
            response.strClientPageMessage = response.ReturnMessage switch
            {
                "DOES EXIST" => Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                    request.Default),
                "SUCCESS" => _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                _ => response.strClientPageMessage
            };
            return Json(response);
        }
    }
}
