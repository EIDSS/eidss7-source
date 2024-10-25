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
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class VectorTypeFieldTestMatrixPageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IVectorTypeFieldTestMatrixClient _configurationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IAdminClient _adminClient;
        private readonly IVectorTypeClient _vectorTypeClient;
        private readonly IStringLocalizer _localizer;

        public VectorTypeFieldTestMatrixPageController(IVectorTypeFieldTestMatrixClient configurationClient, ICrossCuttingClient crossCuttingClient, IVectorTypeClient vectorTypeClient, IAdminClient adminClient, IStringLocalizer localizer,
            ILogger<VectorTypeFieldTestMatrixPageController> logger, ITokenService tokenService) : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            _crossCuttingClient = crossCuttingClient;
            _vectorTypeClient = vectorTypeClient;
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
        [Route("GetList")]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { VectorTypeDD = "", SearchBox = "" };
            var referenceType = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            long? id = null;
            if (referenceType.VectorTypeDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.VectorTypeDD))
                {
                    id = long.Parse(referenceType.VectorTypeDD);
                }
            }
            var sortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "strPensideTestName";
            var sortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Descending;

            var request = new VectorTypeFieldTestMatrixGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsVectorType = id,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            var result = await _configurationClient.GetVectorTypeFieldTestMatrixList(request);
            IEnumerable<ConfigurationMatrixViewModel> list = result;
            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (list.Any())
            {
                var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (var i = 0; i < list.Count(); i++)
                {
                    var cols = new List<string>
                    {
                        (row + i + 1).ToString(),
                        list.ElementAt(i).idfPensideTestTypeForVectorType.ToString(),
                        list.ElementAt(i).idfsVectorType.ToString(),
                        list.ElementAt(i).idfsPensideTestName.ToString(),
                        list.ElementAt(i).strPensideTestName,
                        ""
                    };

                    tableData.data.Add(cols);
                }
            }
            else
            {
                var cols = new List<string>
                {
                    string.Empty,
                    string.Empty,
                    string.Empty,
                    string.Empty,
                    string.Empty,
                    ""
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public List<T> Sort_List<T>(string sortDirection, string sortExpression, List<T> data)
        {

            var dataSorted = new List<T>();

            switch (sortDirection)
            {
                case "asc":
                    dataSorted = (from n in data
                                  orderby GetDynamicSortProperty(n, sortExpression)
                                  select n).ToList();
                    break;
                case "desc":
                    dataSorted = (from n in data
                                  orderby GetDynamicSortProperty(n, sortExpression) descending
                                  select n).ToList();
                    break;
            }

            return dataSorted;
        }

        public object GetDynamicSortProperty(object item, string propName)
        {
            //Use reflection to get order type
            return item.GetType().GetProperty(propName)?.GetValue(item, null);
        }

        public IQueryable<T> OrderByField<T>(IQueryable<T> q, string sortField, bool ascending)
        {
            var param = Expression.Parameter(typeof(T), "p");
            var prop = Expression.Property(param, sortField);
            var exp = Expression.Lambda(prop, param);
            var method = ascending ? "OrderBy" : "OrderByDescending";
            var types = new[] { q.ElementType, exp.Body.Type };
            var mce = Expression.Call(typeof(Queryable), method, types, q.Expression, exp);
            return q.Provider.CreateQuery<T>(mce);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var pensideTestName = "";

            try
            {
                if (jsonObject["VectorTypeDD"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["VectorTypeDD"][0]?["id"]?.ToString()))
                    {
                        // should select a Vector Type
                        return Json("");
                    }
                }

                long idfsPensideTestName = 0;
                if (jsonObject["idfsPensideTestName"]?[0]?["id"] != null)
                {
                    idfsPensideTestName = long.Parse(jsonObject["idfsPensideTestName"][0]["id"].ToString());
                }
                if (jsonObject["idfsPensideTestName"]?[0]?["text"] != null)
                {
                    pensideTestName = jsonObject["idfsPensideTestName"][0]["text"].ToString();
                }
                var request = new VectorTypeFieldTestMatrixSaveRequestModel
                {
                    idfPensideTestTypeForVectorType = null,
                    idfsVectorType = jsonObject["VectorTypeDD"]?[0]?["id"] != null ? long.Parse(jsonObject["VectorTypeDD"]?[0]?["id"].ToString() ?? string.Empty) : null,
                    idfsPensideTestName = idfsPensideTestName,
                    EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                var response = await _configurationClient.SaveVectorTypeFieldTestMatrix(request);
                response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), pensideTestName);

                if (response.idfPensideTestTypeForVectorType != 0 && response.ReturnMessage == "SUCCESS")
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
                    long idfsPensideTestName = 0;
                    if (jsonObject["idfsPensideTestName"] != null)
                    {
                        idfsPensideTestName = long.TryParse(jsonObject["strPensideTestName"]?.ToString(), out var result) == false ? long.Parse(jsonObject["idfsPensideTestName"].ToString()) : result;
                    }
                    var request = new VectorTypeFieldTestMatrixSaveRequestModel
                    {
                        idfPensideTestTypeForVectorType = long.Parse(jsonObject["KeyId"].ToString()),
                        idfsVectorType = jsonObject["idfsVectorType"] != null ? long.Parse(jsonObject["idfsVectorType"].ToString()) : null,
                        idfsPensideTestName = idfsPensideTestName,
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };

                    var response = await _configurationClient.SaveVectorTypeFieldTestMatrix(request);

                    if (response.idfPensideTestTypeForVectorType != 0 && response.ReturnMessage == "SUCCESS")
                    {
                        // popup a modal with message “The record is submitted successful”
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
        public async Task<JsonResult> Delete([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new VectorTypeFieldTestMatrixSaveRequestModel
                    {
                        idfPensideTestTypeForVectorType = long.Parse(jsonObject["KeyId"].ToString()),
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };
                    var response = await _configurationClient.DeleteVectorTypeFieldTestMatrix(request);
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
        [Route("AddVectorType")]
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
            if (jsonObject["CollectedByPool"].ToString().Contains("1"))
                request.CollectionByPool = true;

            request.LanguageId = GetCurrentLanguage();

            var response = await _vectorTypeClient.SaveVectorType(request);
            response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            return Json(response);
        }

        [HttpPost]
        [Route("AddFieldTest")]
        public async Task<IActionResult> AddFieldTest([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var request = new BaseReferenceSaveRequestModel();

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

            request.BaseReferenceId = null;
            request.Default = jsonObject["StrDefault"] != null ? jsonObject["StrDefault"].ToString() : string.Empty;
            request.Name = jsonObject["StrName"] != null ? jsonObject["StrName"].ToString() : string.Empty;
            request.intOrder = intOrder;
            request.LanguageId = GetCurrentLanguage();
            request.ReferenceTypeId = (long)ReferenceTypes.PensideTestName;
            request.EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange;
            request.AuditUserName = authenticatedUser.UserName;
            request.LocationId = authenticatedUser.RayonId;
            request.SiteId = Convert.ToInt64(authenticatedUser.SiteId);
            request.UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId);

            var response = await _adminClient.SaveBaseReference(request);
            response.strDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            return Json(response);
        }
    }
}