using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Providers;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class InterfaceEditorPageController : BaseController
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IStringLocalizer _localizer;
        private readonly IInterfaceEditorClient _interfaceEditorClient;
        private readonly IConfiguration _configuration;
        private readonly ICrossCuttingService _crossCuttingService;
        private InterfaceEditorResourcePageViewModel _interfaceEditorResourcePageViewModel;
        internal CultureInfo _cultureInfo = Thread.CurrentThread.CurrentCulture;
        private readonly string _currentLanguage;
        private readonly UserPermissions _userPermissions;
        private InterfaceEditorPageViewModel _interfaceEditorPageViewModel;


        public InterfaceEditorPageController(ICrossCuttingClient crossCuttingClient,
            IStringLocalizer localizer,
            IInterfaceEditorClient interfaceEditorClient,
            IConfiguration configuration,
            ICrossCuttingService crossCuttingService,
            ITokenService tokenService, 
            ILogger<InterfaceEditorPageController> logger,
            IServiceProvider serviceProvider)
            : base(logger, tokenService)
        {
            _serviceProvider = serviceProvider;
            _crossCuttingClient = crossCuttingClient;
            _localizer = localizer;
            _crossCuttingService = crossCuttingService;
            _interfaceEditorClient = interfaceEditorClient;
            _configuration = configuration;
            _userPermissions = GetUserPermissions(PagePermission.AccessToInterfaceEditor);
            _currentLanguage = GetCurrentLanguage();

            //set up the initial model
            _interfaceEditorPageViewModel = new InterfaceEditorPageViewModel();
            _interfaceEditorPageViewModel.SearchCriteria = new InterfaceEditorSearchCriteria();
            _interfaceEditorPageViewModel.SearchCriteria.InterfaceEditorTypes = new List<SelectListItem>();
            _interfaceEditorResourcePageViewModel = new InterfaceEditorResourcePageViewModel();
            _interfaceEditorResourcePageViewModel.InterfaceEditorResourceGridConfiguration = new EIDSSGridConfiguration();
            _interfaceEditorPageViewModel.LanguageUpload = new InterfaceEditorLanguageUpload();
            _interfaceEditorResourcePageViewModel.UserPermissions = _tokenService.GerUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToInterfaceEditor);


        }

        public async Task<IActionResult> Index()
        {
            //temporary disable this module - until we refactor this solution #122527
            return RedirectToAction("index", "Dashboard");

            //get the modules
            var moduleRequest = new InterfaceEditorModuleGetRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 10,
                SortColumn = "idfsResourceSet",
                SortOrder = "asc"
            };
            var modules = await _interfaceEditorClient.GetInterfaceEditorModuleList(moduleRequest);
            modules.Sort((x, y) =>
            {
                if (x.DefaultName == "Global") return -2;
                else return x.DefaultName.CompareTo(y.DefaultName);
            });
            _interfaceEditorPageViewModel.ModuleTabs = modules;

            //get the sections
            foreach (var module in modules)
            {
                var sectionRequest = new InterfaceEditorSectionGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsResourceSet",
                    SortOrder = "asc",
                    ParentNode = module.ResourceSetNode
                };
                var sections = await _interfaceEditorClient.GetInterfaceEditorSectionList(sectionRequest);
                foreach (var section in sections)
                {
                    _interfaceEditorPageViewModel.Sections.Add(section);
                }

            }

            //get the interface editor types
            _interfaceEditorPageViewModel.SearchCriteria.InterfaceEditorTypes = await GetResourceTypes();

            _interfaceEditorPageViewModel.LanguageUpload.AvailableCultures = this.GetLanguageSelectItems();

            return View(_interfaceEditorPageViewModel);
        }

        [Route("GetResourceGridPartial")]
        [HttpPost]
        public IActionResult GetResourceGridPartial([FromBody] InterfaceEditorResourcePageViewModel model)
        {

            _interfaceEditorPageViewModel.SearchCriteria = model.SearchCriteria;
            _interfaceEditorResourcePageViewModel = model;
            _interfaceEditorResourcePageViewModel.InterfaceEditorResourceGridConfiguration = new EIDSSGridConfiguration();
            _interfaceEditorResourcePageViewModel.UserPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToInterfaceEditor);
            return PartialView("_ResourcePartial", _interfaceEditorResourcePageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetResourceList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj, long? idfsResourceSet, long? moduleId)
        {

            var postParameterDefinitions = new
            {
                SearchCriteria_SearchText = "",
                SearchCriteria_AllModules = "",
                SearchCriteria_InterfaceEditorSelectedTypes = "",
                SearchCriteria_Required = "",
                SearchCriteria_Hidden = ""
            };
            var postArgs = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            List<InterfaceEditorResourceViewModel> list = new List<InterfaceEditorResourceViewModel>();

            //resource set

            //sort parameters
            KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
            valuePair = dataTableQueryPostObj.ReturnSortParameter();
            var sortColumn = "strResourceName";
            if (!String.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfsResourceSet")
            {
                sortColumn = valuePair.Key;
            }
            string sortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc";            

            //search parameters
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                var includedTypes = !string.IsNullOrEmpty(postArgs.SearchCriteria_InterfaceEditorSelectedTypes) ? postArgs.SearchCriteria_InterfaceEditorSelectedTypes : null;
                bool? allModules = (!string.IsNullOrEmpty(postArgs.SearchCriteria_AllModules) && Convert.ToBoolean(postArgs.SearchCriteria_AllModules) == true) ? bool.Parse(postArgs.SearchCriteria_AllModules) : null;
                bool? isRequired = (!string.IsNullOrEmpty(postArgs.SearchCriteria_Required) && Convert.ToBoolean(postArgs.SearchCriteria_Required) == true) ? bool.Parse(postArgs.SearchCriteria_Required) : null;
                bool? isHidden = (!string.IsNullOrEmpty(postArgs.SearchCriteria_Hidden) && Convert.ToBoolean(postArgs.SearchCriteria_Hidden) == true) ? bool.Parse(postArgs.SearchCriteria_Hidden) : null;
                var searchText = !string.IsNullOrEmpty(postArgs.SearchCriteria_SearchText) ? postArgs.SearchCriteria_SearchText : null;

                if (allModules == true || moduleId == 0) moduleId = null;
                if (idfsResourceSet == 0) idfsResourceSet = null;

                if (searchText != null) idfsResourceSet = null;

                var request = new InterfaceEditorResourceGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = sortColumn,
                    SortOrder = sortOrder,
                    IdfsResourceSet = idfsResourceSet,
                    ModuleId = moduleId,
                    IncludedTypes = includedTypes,
                    AllModules = allModules,
                    IsRequired = isRequired,
                    IsHidden = isHidden,
                    SearchString = searchText
                };
                
                list = await _interfaceEditorClient.GetInterfaceEditorResourceList(request);                
            }

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
                        list.ElementAt(i).IdfsResourceSet.ToString(),
                        list.ElementAt(i).IdfsResource.ToString(),
                        list.ElementAt(i).StrResourceSet,
                        list.ElementAt(i).IdfsResourceType.ToString(),
                        list.ElementAt(i).BaseReferenceId.ToString(),
                        list.ElementAt(i).StrResourceName, //Hidden Field for Editing
                        list.ElementAt(i).StrResourceType, //Type
                        list.ElementAt(i).StrResourceName, //DefaultName
                        list.ElementAt(i).NationalName, //NationalName
                        //list.ElementAt(i).ModuleId.ToString(), //ModuleName
                        list.ElementAt(i).ModuleName, //ModuleName
                        list.ElementAt(i).StrResourceSet, //SectionName                        
                        list.ElementAt(i).IsRequired.ToString(),
                        list.ElementAt(i).IsHidden.ToString(),
                        ""
                    };

                    tableData.data.Add(cols);
                }
            }

            return new JsonResult(tableData);
        }

        [HttpPost()]
        [Route("SaveResource")]
        public async Task<JsonResult> SaveResource([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());

            var request = new InterfaceEditorResourceSaveRequestModel()
            {
                idfsResource = jsonObject["IdfsResource"] != null ? long.Parse(jsonObject["IdfsResource"].ToString()) : 0,
                idfsResourceSet = jsonObject["IdfsResourceSet"] != null ? long.Parse(jsonObject["IdfsResourceSet"].ToString()) : 0,
                DefaultName = jsonObject["StrResourceName"].ToString(),
                NationalName = jsonObject["NationalName"].ToString(),
                isHidden = jsonObject["IsHidden"].ToString() != null ? bool.Parse(jsonObject["IsHidden"].ToString()) : false,
                isRequired = jsonObject["IsRequired"].ToString() != null ? bool.Parse(jsonObject["IsRequired"].ToString()) : false,
                LanguageId = GetCurrentLanguage(),
                User = _tokenService.GetAuthenticatedUser().UserName

            };
            var response = await _interfaceEditorClient.SaveInterfaceEditorResource(request);

            //reset cache
            var cacheProvider = (LocalizationMemoryCacheProvider)_serviceProvider.GetService(typeof(LocalizationMemoryCacheProvider));
            cacheProvider.ReSetKey(null, "USP_GBL_Resource_GETListResult");

            return Json(response);
        }

        [Route("GetResourceTypes")]
        public async Task<List<SelectListItem>> GetResourceTypes()
        {
            List<SelectListItem> selectListItems = new List<SelectListItem>();

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ResourceType, HACodeList.AllHACode);

                if (list != null)
                {
                    list.OrderBy(r => r.IntOrder).ThenBy(r => r.Name);
                    foreach (var item in list)
                    {
                        selectListItems.Add(new SelectListItem() { Value = item.IdfsBaseReference.ToString(), Text = item.Name, Selected = true });
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }

            return selectListItems;
        }

        private SelectList GetLanguageSelectItems()
        {
            var cultures = new List<SelectListItem>();

            try
            {
                var cultureInfos = CultureInfo.GetCultures(CultureTypes.NeutralCultures).OrderBy(c => c.DisplayName).ToArray();

                if (cultures != null)
                {
                    foreach (var culture in cultureInfos)
                    {
                        cultures.Add(new SelectListItem() { Value = culture.Name, Text = culture.DisplayName });
                    }
                }

            }
            catch (Exception)
            {
                throw;
            }
            return new SelectList(cultures, "Value", "Text");
        }

        public async Task<IActionResult> DownloadLanguageTranslationTemplate()
        {

            try
            {
                //get all resources
                var list = new List<InterfaceEditorTemplateViewModel>();
                list = await _interfaceEditorClient.GetInterfaceEditorTemplateItems(GetCurrentLanguage());

                using MemoryStream memoryStream = new();
                using (TextWriter tw = new StreamWriter(memoryStream, Encoding.UTF8))
                {
                    StringBuilder sb = new StringBuilder();
                    sb.AppendLine("Set,Resource,Module,Section,Type,Default Name,National Name");
                    foreach (var res in list)
                    {
                        sb.AppendJoin
                        (
                            ',', 
                            res.SetId, 
                            res.ResourceId, 
                            res.ModuleName?.Replace("\r", "").Replace("\n", ""), 
                            res.SectionName?.Replace("\r", "").Replace("\n", ""), 
                            res.ResourceType, 
                            res.ResourceDefaultName?.Replace("\r\n", " ").Replace("\r", "").Replace("\n",""), 
                            string.Empty
                        );
                        sb.AppendLine();

                    }
                    await tw.WriteAsync(sb.ToString());
                    await tw.FlushAsync();
                    memoryStream.Position = 0;
                }



                //return a FileStreamResult
                return File(memoryStream.GetBuffer(), "text/plain", "new_language.csv");
            }
            catch (Exception)
            {

                throw;
            }
        }

      
        [HttpPost]
        public async Task<IActionResult> UploadLanguageTranslation([FromForm] InterfaceEditorLanguageUpload model)
        {

            if (!ModelState.IsValid)
            {
                model.PageResult = _localizer.GetString(string.Format(ModelBindingMessageConstants.ValueIsInvalidAccessor, model.LanguageFile.FileName));
                return PartialView("_LanguagePartial", model);
            }

            var formFileContent = await FileHelpers.ProcessFormFile<InterfaceEditorPageController>(
                model.LanguageFile, ModelState, new string[] { ".csv" },
                long.Parse(_configuration["EIDSSGlobalSettings:LanguageFileSizeLimit"]));

            if (!ModelState.IsValid)
            {
                model.PageResult = _localizer.GetString(string.Format(MessageResourceKeyConstants.InvalidFieldMessage));
                return PartialView("_LanguagePartial", model);
            }

            //pass the file over to the api
            var trustedFileName = Path.GetRandomFileName();
            var request = new InterfaceEditorLangaugeFileSaveRequestModel()
            {
                FileName = trustedFileName,
                LanguageFile = model.LanguageFile,
                LanguageName = model.LanguageName,
                LanguageCode = model.LanguageCode,
                User = _tokenService.GetAuthenticatedUser().UserName,
                CurrentLangId = GetCurrentLanguage()

            };

            var response = await _interfaceEditorClient.UploadLanguageTranslation(request);
            if (response.ReturnMessage == "SUCCESS")
            {
                model.PageResult = response.ReturnMessage;
            }
            return PartialView("_LanguagePartial", model);
        }

    }
}
