using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Web.Areas.Human.ViewModels;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.Abstracts;
using Microsoft.Extensions.Logging;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using System.Linq;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using Newtonsoft.Json.Linq;
using System.Text.Json;
using EIDSS.Localization.Constants;
using Microsoft.Extensions.Localization;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.Extensions.Configuration;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.ViewModels.Configuration;
using System.Text.RegularExpressions;
using System.Security.Policy;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "AddNonUserEmployee")]
    [Area("Human")]
    public class AddNonUserEmployeeController : BaseController
    {
        //DiseaseReportComponentViewModel _diseaseReportComponentViewModel;
        readonly IPersonClient _personClient;
        readonly private ICrossCuttingClient _crossCuttingClient;
        readonly private IConfigurationClient _configurationClient;
        IConfiguration _configuration;
        private IStringLocalizer _localizer;
        AuthenticatedUser _authenticatedUser;
        UserPreferences _userPreferences;
        public string CountryId { get; set; }
        IEmployeeClient _employeeClient;
        IPersonalIdentificationTypeMatrixClient _personalIdentificationTypeMatrixClient;

        public AddNonUserEmployeeController(IPersonClient personClient, IConfiguration configuration, IConfigurationClient configurationClient, ICrossCuttingClient crossCuttingClient, IStringLocalizer localizer, ITokenService tokenService,IEmployeeClient employeeClient, IPersonalIdentificationTypeMatrixClient personalIdentificationTypeMatrixClient, ILogger<OrganizationSearchController> logger) : base(logger, tokenService)
        {
            _personClient = personClient;
            _authenticatedUser = tokenService.GetAuthenticatedUser();
            _configurationClient = configurationClient;
            _configuration = configuration;
            _userPreferences = _authenticatedUser.Preferences;
            _crossCuttingClient = crossCuttingClient;
            _employeeClient = employeeClient;
            _localizer = localizer;
            _personalIdentificationTypeMatrixClient = personalIdentificationTypeMatrixClient;
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

        }

        // GET: PersonController
        public async Task<IViewComponentResult> InvokeAsync(EmployeePersonalInfoPageViewModel model)
        {
            //EIDSSModalConfiguration NonUserEmployeeSave = new EIDSSModalConfiguration();
            // NonUserEmployeeSave.ModalId = ModalName;

            var viewData = new ViewDataDictionary<EmployeePersonalInfoPageViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
            //return View(model);
        }

        [HttpGet()]
        [Route("GetDepartmentList")]
        public async Task<JsonResult> GetDepartmentList(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            try
            {
                DepartmentGetRequestModel model = new DepartmentGetRequestModel();
                //JArray jsonArray = JArray.Parse(data);
                //dynamic jsonObject;
                //if (jsonArray.Count > 0)
                //{
                dynamic jsonObject = JObject.Parse(data);
                if (jsonObject["id"] != null)
                {
                    model.OrganizationID = long.Parse(jsonObject["id"].ToString());
                }
                // }
                model.LanguageId = GetCurrentLanguage();
                model.SortColumn = "intOrder";
                model.SortOrder = "asc";
                model.PageSize = 10000;
                model.Page = 1;
                var list = await _crossCuttingClient.GetDepartmentList(model);

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.DepartmentID.ToString(), text = item.DepartmentNameDefaultValue });
                    }
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                throw;
            }
            return Json(select2DataObj);
        }

        [HttpPost()]
        [Route("SaveNonUserEmployee")]
        public async Task<IActionResult> SaveNonUserEmployee([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            EmployeeSaveRequestResponseModel response = new EmployeeSaveRequestResponseModel();
            EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            EmployeePersonalInfoSaveRequest.strPersonalID = jsonObject["PersonalID"] != null ? jsonObject["PersonalID"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strFirstName = jsonObject["FirstOrGivenName"] != null ? jsonObject["FirstOrGivenName"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strSecondName = jsonObject["SecondName"] != null ? jsonObject["SecondName"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strFamilyName = jsonObject["LastOrSurName"] != null ? jsonObject["LastOrSurName"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strContactPhone = jsonObject["Phone"] != null ? jsonObject["Phone"].ToString() : "";
            EmployeePersonalInfoSaveRequest.idfsSite = Convert.ToInt64(_authenticatedUser.SiteId);


            //ValueKind = Object : "{"PersonalID":"","FirstOrGivenName":"abc","SecondName":"abc","LastOrSurName":"abc","OrganizationDD":[{"selected":false,"disabled":false,"text":"Absheron RCHE","id":"48120000000","_resultId":"select2-NonUserEmployeeSavectrlAdd_5-result-yjgq-48120000000","element":{}}],"DepartmentDD":[{"selected":false,"disabled":false,"text":"MMMMM","id":"51503910000000","_resultId":"select2-NonUserEmployeeSavectrlAdd_6-result-ilvb-51503910000000","element":{}}],"PositionDD":[{"selected":false,"disabled":false,"text":"abc","id":"389445040002767","_resultId":"select2-NonUserEmployeeSavectrlAdd_7-result-ydet-389445040002767","element":{}}],"notificationSentByNameDD":[{"selected":true,"disabled":false,"text":"","id":"","title":"","element":{}}]}"

            if (jsonObject["OrganizationDD"] != null)
            {
                if (jsonObject["OrganizationDD"][0]["id"] != null)
                {
                    EmployeePersonalInfoSaveRequest.idfInstitution = long.Parse(jsonObject["OrganizationDD"][0]["id"].ToString());
                }
            }
            if (jsonObject["DepartmentDD"] != null)
            {
                if (jsonObject["DepartmentDD"][0]["id"] != null)
                {
                    EmployeePersonalInfoSaveRequest.idfDepartment = long.Parse(jsonObject["DepartmentDD"][0]["id"].ToString());
                }
            }

            if (jsonObject["PositionDD"] != null)
            {
                if (jsonObject["PositionDD"][0]["id"] != null)
                {
                    EmployeePersonalInfoSaveRequest.idfsStaffPosition = long.Parse(jsonObject["PositionDD"][0]["id"].ToString());
                }
            }

            if (jsonObject["PersonalIdTypeDD"] != null)
            {
                if (jsonObject["PersonalIdTypeDD"][0]["id"] != null)
                {
                    EmployeePersonalInfoSaveRequest.idfPersonalIDType = jsonObject["PersonalIdTypeDD"][0]["id"].ToString();
                }
            }

            EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;

            EmployeeGetListRequestModel DuplicateCheckRequest = new EmployeeGetListRequestModel();

            DuplicateCheckRequest.FirstOrGivenName = EmployeePersonalInfoSaveRequest.strFirstName;
            DuplicateCheckRequest.LanguageId = GetCurrentLanguage();
            DuplicateCheckRequest.LastOrSurName = EmployeePersonalInfoSaveRequest.strFamilyName;
            DuplicateCheckRequest.PersonalIdType = EmployeePersonalInfoSaveRequest.idfPersonalIDType != null && EmployeePersonalInfoSaveRequest.idfPersonalIDType.ToString() != string.Empty ? long.Parse(EmployeePersonalInfoSaveRequest.idfPersonalIDType.ToString()) : null;
            DuplicateCheckRequest.PersonalIDValue = EmployeePersonalInfoSaveRequest.strPersonalID;
            DuplicateCheckRequest.OrganizationID = EmployeePersonalInfoSaveRequest.idfInstitution;
            DuplicateCheckRequest.Page = 1;
            DuplicateCheckRequest.PageSize = 10;
            DuplicateCheckRequest.SortOrder = "ASC";
            DuplicateCheckRequest.SortColumn = "EmployeeID";

            List<EmployeeListViewModel> duplicateResponse = await _employeeClient.GetEmployeeList(DuplicateCheckRequest);

            if (duplicateResponse != null && duplicateResponse.Count > 0)
            {
                EmployeePersonalInfoSaveRequest.idfPerson = duplicateResponse.FirstOrDefault().EmployeeID;
                response.RetunMessage = "DOES EXIST";
                string duplicate_Field = "";
                duplicate_Field = duplicateResponse.FirstOrDefault().LastOrSurName != null && duplicateResponse.FirstOrDefault().LastOrSurName != "" ? duplicateResponse.FirstOrDefault().LastOrSurName : "";
                duplicate_Field += duplicateResponse.FirstOrDefault().FirstOrGivenName != null && duplicateResponse.FirstOrDefault().FirstOrGivenName != "" ? " " + duplicateResponse.FirstOrDefault().FirstOrGivenName : "";
                duplicate_Field += duplicateResponse.FirstOrDefault().OrganizationID != null && duplicateResponse.FirstOrDefault().OrganizationID != 0 ? " " + duplicateResponse.FirstOrDefault().OrganizationAbbreviatedName : "";
                duplicate_Field += EmployeePersonalInfoSaveRequest.idfPersonalIDType != null && EmployeePersonalInfoSaveRequest.idfPersonalIDType != "" ? " " + EmployeePersonalInfoSaveRequest.idfPersonalIDTypeText : "";
                duplicate_Field += EmployeePersonalInfoSaveRequest.strPersonalID != null && EmployeePersonalInfoSaveRequest.strPersonalID != "" ? " " + EmployeePersonalInfoSaveRequest.strPersonalID : "";
                response.DuplicateMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), duplicate_Field);
            }
            else
            {
                bool isValid = false;
                if (EmployeePersonalInfoSaveRequest.strPersonalID != null && EmployeePersonalInfoSaveRequest.strPersonalID!="")
                {
                    isValid = await ValidatePersonalID(long.Parse(EmployeePersonalInfoSaveRequest.idfPersonalIDType), EmployeePersonalInfoSaveRequest.strPersonalID);
                    if(!isValid)
                    {
                        response.RetunMessage = "ERROR";
                        response.ValidationError =string.Format(_localizer.GetString(FieldLabelResourceKeyConstants.PersonalIDFieldLabel)) + ":" + string.Format(_localizer.GetString(MessageResourceKeyConstants.InvalidFieldMessage));
                    }                
                }
                else
                {
                    isValid = true;
                }

                if(isValid)
                    response = await _employeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);
            }

            return Json(response);
        }

        public async Task<bool> ValidatePersonalID(long personalIDType, string personalID)
        {
            bool isValid = false;
            try
            {
                var request = new PersonalIdentificationTypeMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SortOrder = "asc",
                    SortColumn = "IntOrder"
                };
                List<PersonalIdentificationTypeMatrixViewModel> response = await _personalIdentificationTypeMatrixClient.GetPersonalIdentificationTypeMatrixList(request);

                if (response != null)
                {
                    var item = response.Where(a => a.IdfPersonalIDType == personalIDType).FirstOrDefault();
                    if (item != null && item.StrFieldType == "Numeric")
                    {
                        var result = 0;
                        if (personalID.Length == item.Length && Int32.TryParse(personalID, out result))
                        {
                            isValid = true;
                        }
                    }
                    else if (item != null && item.StrFieldType == "AlphaNumeric")
                    {
                        Regex rg = new Regex(@"^[a-zA-Z0-9\s,]*$",RegexOptions.None,TimeSpan.FromMilliseconds(5));
                        isValid = rg.IsMatch(personalID);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return isValid;
        }
    }
}
