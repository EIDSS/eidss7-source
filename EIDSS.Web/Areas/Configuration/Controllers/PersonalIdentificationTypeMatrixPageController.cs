using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels.Configuration;
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
using static System.Int32;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class PersonalIdentificationTypeMatrixPageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;
        private readonly IPersonalIdentificationTypeMatrixClient _personalIdentificationTypeMatrixClient;
        private readonly IStringLocalizer _localizer;

        public PersonalIdentificationTypeMatrixPageController(IPersonalIdentificationTypeMatrixClient personalIdentificationTypeMatrixClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<PersonalIdentificationTypeMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _personalIdentificationTypeMatrixClient = personalIdentificationTypeMatrixClient;
            _localizer = localizer;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _pageViewModel.UserPermissions = userPermissions;

        }

        public IActionResult Index()
        {
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { SearchBox = "" };
            Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            //Sorting
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();
            var strSortColumn = "IntOrder";
            if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfPersonalIDType")
            {
                strSortColumn = valuePair.Key;
            }

            var request = new PersonalIdentificationTypeMatrixGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = strSortColumn,
                SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
            };            

            var response = await _personalIdentificationTypeMatrixClient.GetPersonalIdentificationTypeMatrixList(request);
            IEnumerable<PersonalIdentificationTypeMatrixViewModel> matrixList = response;

            var tableData = new TableData
            {
                iTotalRecords = !matrixList.Any() ? 0 : matrixList.First().TotalRowCount,
                iTotalDisplayRecords = !matrixList.Any() ? 0 : matrixList.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw,
                data = new List<List<string>>()
            };

            if (!matrixList.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < matrixList.Count(); i++)
            {
                List<string> cols = new()
                {
                    (row + i + 1).ToString(),
                    matrixList.ElementAt(i).IdfPersonalIDType.ToString(),
                    matrixList.ElementAt(i).StrPersonalIDType ?? Empty,
                    matrixList.ElementAt(i).StrFieldType ?? Empty,
                    matrixList.ElementAt(i).Length.ToString(),
                    matrixList.ElementAt(i).IntOrder.ToString()                        
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        [HttpPost]
        [Route("DeletePersonalIdentificationTypeMatrix")]
        public async Task<JsonResult> DeletePersonalIdentificationTypeMatrix([FromBody] JsonElement json)
        {
            var jsonObject = JObject.Parse(json.ToString() ?? Empty);
            var personalIdType = long.Parse(jsonObject["IdfPersonalIDType"]?.ToString() ?? Empty);

            var request = new PersonalIdentificationTypeMatrixSaveRequestModel
            {
                IdfPersonalIDType = personalIdType,
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };
            var response = await _personalIdentificationTypeMatrixClient.DeletePersonalIdentificationTypeMatrix(request);
            
            return Json(response);            
        }

        [HttpPost]
        [Route("AddPersonalIdentificationTypeMatrix")]
        public async Task<JsonResult> AddPersonalIdentificationTypeMatrix([FromBody] JsonElement json)
        {
            var jsonObject = JObject.Parse(json.ToString() ?? Empty);
            
            var saveRequest = new PersonalIdentificationTypeMatrixSaveRequestModel
            {
                IdfPersonalIDType = long.Parse(jsonObject["IdfPersonalIDType"]?[0]?["id"]?.ToString() ?? Empty),
                StrFieldType = jsonObject["IdfsFieldType"]?[0]?["text"]?.ToString(),
                Length = Parse(jsonObject["IntLength"]?.ToString() ?? Empty),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName,
                IntOrder = IsNullOrEmpty(jsonObject["IntOrder"]?.ToString()) ? 0 : Parse(jsonObject["IntOrder"].ToString())
            };

            var response = await _personalIdentificationTypeMatrixClient.SavePersonalIdentificationTypeMatrix(saveRequest);
            response.strClientPageMessage = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), jsonObject["IdfPersonalIDType"]?[0]?["text"]);

            return Json(response);
        }

        public JsonResult FieldTypesForSelect2DropDown(string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            List<SelectDataItemViewModel> list = new();

            try
            {

                list.Add(new SelectDataItemViewModel { ID = "0", Name = PersonalIDTypeMatriceAttributeTypes.AlphaNumeric });
                list.Add(new SelectDataItemViewModel { ID = "1", Name = PersonalIDTypeMatriceAttributeTypes.Numeric });

                if (!IsNullOrEmpty(term))
                {
                    var toList = list.Where(c => c.Name != null && c.Name.Contains(term, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    list = toList;
                }

                select2DataItems.AddRange(list.Select(item => new Select2DataItem {id = item.ID, text = item.Name}));

                select2DataObj.results = select2DataItems;
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
