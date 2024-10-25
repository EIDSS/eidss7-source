using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class EmployeePageController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ISiteClient _siteClient;
        private readonly IAdminClient _adminClient;
        private readonly IEmployeeClient _employeeClient;
        private UserPermissions _userPermissions;
        private readonly IOrganizationClient _organizationClient;
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly IPersonalIdentificationTypeMatrixClient _personalIdentificationTypeMatrixClient;
        private readonly IStringLocalizer _localizer;

        private EmployeePageViewModel _employeePageViewModel;
        private readonly EmployeeDetailsPageViewModel _employeeDetailsPageViewModel;

        public EmployeePageController(ICrossCuttingClient crossCuttingClient, ISiteClient siteClient, IAdminClient adminClient, IOrganizationClient organizationClient, IEmployeeClient employeeClient, IPersonalIdentificationTypeMatrixClient personalIdentificationTypeMatrixClient, ILogger<EmployeePageController> logger, IStringLocalizer localizer, ITokenService tokenService) : base(logger, tokenService)
        {
            _employeePageViewModel = new EmployeePageViewModel();
            _employeeDetailsPageViewModel = new EmployeeDetailsPageViewModel();
            _crossCuttingClient = crossCuttingClient;
            _adminClient = adminClient;
            _employeeClient = employeeClient;
            _siteClient = siteClient;
            _localizer = localizer;
            _personalIdentificationTypeMatrixClient = personalIdentificationTypeMatrixClient;
            _organizationClient = organizationClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            _employeePageViewModel.UserPermissions = _userPermissions;

            _userPermissions = GetUserPermissions(PagePermission.CanManageUserAccounts);
            _employeeDetailsPageViewModel.UserPermissions = _userPermissions;
            _employeePageViewModel.AddEmployeeUserPermissions = _userPermissions;

            var canManageReferencesandConfiguratuionsPermission = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);

            var canAccessOrganizationsList = GetUserPermissions(PagePermission.CanAccessOrganizationsList);

            //Personal Info and Login
            _employeeDetailsPageViewModel.Select2Configurations = new List<Select2Configruation>();
            _employeeDetailsPageViewModel.PersonalInfoSection = new EmployeePersonalInfoPageViewModel
            {
                UserPermissions = _userPermissions,
                CanManageReferencesandConfiguratuionsPermission = canManageReferencesandConfiguratuionsPermission,
                CanAccessOrganizationsList = canAccessOrganizationsList
            };
            _employeeDetailsPageViewModel.LoginSection = new EmployeeLoginViewModel
            {
                UserPermissions = _userPermissions
            };
            _employeeDetailsPageViewModel.PersonalInfoSection.Select2Configurations = new List<Select2Configruation>();
            _employeeDetailsPageViewModel.PersonalInfoSection.OrganizationDD = new Select2Configruation();
            _employeeDetailsPageViewModel.PersonalInfoSection.PersonalIdTypeDD = new Select2Configruation();
            _employeeDetailsPageViewModel.PersonalInfoSection.SiteDD = new Select2Configruation();
            _employeeDetailsPageViewModel.PersonalInfoSection.DepartmentDD = new Select2Configruation();
            _employeeDetailsPageViewModel.PersonalInfoSection.PositionDD = new Select2Configruation();
            _employeeDetailsPageViewModel.PersonalInfoSection.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            //Account Management Add Button Initialization
            _employeeDetailsPageViewModel.AccountManagementSection = new EmployeeAccountManagementPageViewModel
            {
                eidssGridConfiguration = new EIDSSGridConfiguration(),
                eIDSSModalConfiguration = new List<EIDSSModalConfiguration>(),
                Select2Configurations = new List<Select2Configruation>(),
                EmployeeUserPermissionsPageViewModel = new EmployeeUserPermissionsPageViewModel
                {
                    Select2Configurations = new List<Select2Configruation>(),
                    eIDSSModalConfiguration = new List<EIDSSModalConfiguration>()
                },
                UserGroupsAndPermissions = new List<EmployeeUserGroupsAndPermissionsViewModel>(),
                UserPermissions = _userPermissions
            };
        }

        public IActionResult Index()
        {
            _employeePageViewModel.Select2Configurations = new List<Select2Configruation>();
            _employeePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _employeePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            _employeePageViewModel.Select2Configurations = new List<Select2Configruation>();
            return View(_employeePageViewModel);
        }

        [Route("LoadDefaultOrgDetails")]
        [HttpPost]
        public async Task<IActionResult> LoadDefaultOrgDetails([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            var defaultOrg = new EmployeeUserGroupsAndPermissionsViewModel
            {
                Row = 1
            };
            var empId = jsonObject["idfPerson"] != null && jsonObject["idfPerson"].ToString() != string.Empty ? long.Parse(jsonObject["idfPerson"].ToString()) : 0;
            if (empId == 0)
            {
                defaultOrg.OrganizationID = jsonObject["idfInstitution"] != null && jsonObject["idfInstitution"].ToString() != string.Empty ? long.Parse(jsonObject["idfInstitution"].ToString()) : 0;
                defaultOrg.idfsSite = jsonObject["idfsSite"] != null && jsonObject["idfsSite"].ToString() != string.Empty ? long.Parse(jsonObject["idfsSite"].ToString()) : 0;
                defaultOrg.Organization = jsonObject["idfInstitutionText"] != null && jsonObject["idfInstitutionText"].ToString() != string.Empty ? jsonObject["idfInstitutionText"].ToString() : "";
                defaultOrg.SiteID = jsonObject["idfsSiteText"] != null && jsonObject["idfsSiteText"].ToString() != string.Empty ? jsonObject["idfsSiteText"].ToString() : "";
                defaultOrg.IsDefault = true;
                defaultOrg.STATUS = 1;
                if (defaultOrg.OrganizationID != null && defaultOrg.OrganizationID != 0)
                    _employeeDetailsPageViewModel.AccountManagementSection.UserGroupsAndPermissions.Add(defaultOrg);
            }
            else
            {
                var request = new EmployeesUserGroupAndPermissionsGetRequestModel
                {
                    idfPerson = empId,
                    LangID = GetCurrentLanguage()
                };

                _employeeDetailsPageViewModel.AccountManagementSection.EmployeeID = empId;
                var employeeSiteDetails = await LoadLoginAndAccountManagementInfo(request.idfPerson.ToString());
                if (employeeSiteDetails != null && employeeSiteDetails.Count > 0)
                {
                    _employeeDetailsPageViewModel.LoginSection.Login = employeeSiteDetails.FirstOrDefault().strAccountName;
                    _employeeDetailsPageViewModel.AccountManagementSection.Reason = employeeSiteDetails.FirstOrDefault().strDisabledReason;
                    _employeeDetailsPageViewModel.AccountManagementSection.Disabled = employeeSiteDetails.FirstOrDefault().blnDisabled.Value;
                    _employeeDetailsPageViewModel.AccountManagementSection.blnDisabled = employeeSiteDetails.FirstOrDefault().blnDisabled != null && employeeSiteDetails.FirstOrDefault().blnDisabled.ToString() != string.Empty ? Convert.ToBoolean(employeeSiteDetails.FirstOrDefault().blnDisabled) : false;
                    _employeeDetailsPageViewModel.AccountManagementSection.blnLocked = employeeSiteDetails.FirstOrDefault().Locked == 1 && employeeSiteDetails.FirstOrDefault().Locked.ToString() != string.Empty ? true : false;
                    _employeeDetailsPageViewModel.LoginSection.Password = "Password999";
                    _employeeDetailsPageViewModel.LoginSection.ConfirmPassword = "Password999";
                    _employeeDetailsPageViewModel.LoginSection.strIdentity = employeeSiteDetails.FirstOrDefault().strIdentity;
                    _employeeDetailsPageViewModel.LoginSection.MustChangePassword = employeeSiteDetails.FirstOrDefault().PasswordResetRequired;
                    _employeeDetailsPageViewModel.LoginSection.DateDisabled = employeeSiteDetails.FirstOrDefault().DateDisabled;
                }

                var userGroupResponse = await _employeeClient.GetEmployeeUserGroupAndPermissions(request);
                if (userGroupResponse.Count > 0)
                {
                    _employeeDetailsPageViewModel.AccountManagementSection.UserGroupsAndPermissions.AddRange(userGroupResponse);
                }
                else
                {
                    defaultOrg.OrganizationID = jsonObject["idfInstitution"] != null && jsonObject["idfInstitution"].ToString() != string.Empty ? long.Parse(jsonObject["idfInstitution"].ToString()) : 0;
                    defaultOrg.idfsSite = jsonObject["idfsSite"] != null && jsonObject["idfsSite"].ToString() != string.Empty ? long.Parse(jsonObject["idfsSite"].ToString()) : 0;
                    defaultOrg.Organization = jsonObject["idfInstitutionText"] != null && jsonObject["idfInstitutionText"].ToString() != string.Empty ? jsonObject["idfInstitutionText"].ToString() : "";
                    defaultOrg.SiteID = jsonObject["idfsSiteText"] != null && jsonObject["idfsSiteText"].ToString() != string.Empty ? jsonObject["idfsSiteText"].ToString() : "";
                    defaultOrg.IsDefault = true;
                    defaultOrg.STATUS = 1;
                    if (defaultOrg.OrganizationID != null && defaultOrg.OrganizationID != 0)
                        _employeeDetailsPageViewModel.AccountManagementSection.UserGroupsAndPermissions.Add(defaultOrg);
                }
            }
            return PartialView("_AccountManagementPartial", _employeeDetailsPageViewModel.AccountManagementSection);
        }


        [HttpGet]
        [Route("ReloadAccountManagement")]
        public async Task<IActionResult> ReloadAccountManagement(string data)
        {
            var request = new EmployeesUserGroupAndPermissionsGetRequestModel
            {
                idfPerson = long.Parse(data),
                LangID = GetCurrentLanguage()
            };

            var employeeSiteDetails = await LoadLoginAndAccountManagementInfo(request.idfPerson.ToString());
            if (employeeSiteDetails != null && employeeSiteDetails.Count > 0)
            {
                _employeeDetailsPageViewModel.LoginSection.Login = employeeSiteDetails.FirstOrDefault().strAccountName;
                _employeeDetailsPageViewModel.AccountManagementSection.Reason = employeeSiteDetails.FirstOrDefault().strDisabledReason;
                _employeeDetailsPageViewModel.AccountManagementSection.Disabled = employeeSiteDetails.FirstOrDefault().blnDisabled != null && employeeSiteDetails.FirstOrDefault().blnDisabled.ToString() != string.Empty ? Convert.ToBoolean(employeeSiteDetails.FirstOrDefault().blnDisabled) : false;
                _employeeDetailsPageViewModel.AccountManagementSection.blnDisabled = employeeSiteDetails.FirstOrDefault().blnDisabled != null && employeeSiteDetails.FirstOrDefault().blnDisabled.ToString() != string.Empty ? Convert.ToBoolean(employeeSiteDetails.FirstOrDefault().blnDisabled) : false;
                _employeeDetailsPageViewModel.AccountManagementSection.blnLocked = employeeSiteDetails.FirstOrDefault().Locked == 1 && employeeSiteDetails.FirstOrDefault().Locked.ToString() != string.Empty ? true : false;
                _employeeDetailsPageViewModel.LoginSection.Password = "Password999";
                _employeeDetailsPageViewModel.LoginSection.ConfirmPassword = "Password999";
                _employeeDetailsPageViewModel.LoginSection.strIdentity = employeeSiteDetails.FirstOrDefault().strIdentity;
                _employeeDetailsPageViewModel.LoginSection.MustChangePassword = employeeSiteDetails.FirstOrDefault().PasswordResetRequired;
                _employeeDetailsPageViewModel.LoginSection.DateDisabled = employeeSiteDetails.FirstOrDefault().DateDisabled;
            }

            _employeeDetailsPageViewModel.AccountManagementSection.UserGroupsAndPermissions.AddRange(_employeeClient.GetEmployeeUserGroupAndPermissions(request).Result);
            _employeeDetailsPageViewModel.AccountManagementSection.EmployeeID = request.idfPerson.Value;
            return PartialView("_AccountManagementPartial", _employeeDetailsPageViewModel.AccountManagementSection);
        }

        public async Task<IActionResult> Details(string id)
        {
            List<AdminEmployeeSiteDetailsViewModel> employeeSiteDetails = new List<AdminEmployeeSiteDetailsViewModel>();

            if (!string.IsNullOrEmpty(id))
            {
                _employeeDetailsPageViewModel.EmployeeID = long.Parse(id);
                _employeeDetailsPageViewModel.IsEditEmployee = true;
                _employeeDetailsPageViewModel.AccountManagementSection.EmployeeID = long.Parse(id);
            }
            else
            {
                _employeeDetailsPageViewModel.IsAddEmployee = true;
            }

            if (!string.IsNullOrEmpty(id))
            {
                _employeeDetailsPageViewModel.PersonalInfoSection = await LoadPersonalInfo(id);

                employeeSiteDetails = await LoadLoginAndAccountManagementInfo(id);

                if (employeeSiteDetails != null && employeeSiteDetails.FirstOrDefault() != null)
                {
                    _employeeDetailsPageViewModel.AccountManagementSection.Disabled = Convert.ToBoolean(employeeSiteDetails.FirstOrDefault().blnDisabled);
                    _employeeDetailsPageViewModel.AccountManagementSection.blnLocked = employeeSiteDetails.FirstOrDefault().Locked == 1;
                    _employeeDetailsPageViewModel.AccountManagementSection.Reason = employeeSiteDetails.FirstOrDefault().strDisabledReason;
                    _employeeDetailsPageViewModel.AccountManagementSection.strLockoutReason = employeeSiteDetails.FirstOrDefault().strLockoutReason;
                    if (_employeeDetailsPageViewModel.AccountManagementSection.Disabled == true)
                    {
                        if (employeeSiteDetails.FirstOrDefault().DateDisabled != null)
                            _employeeDetailsPageViewModel.AccountManagementSection.strAccountDisabled = "Account is Disabled on " + (employeeSiteDetails.FirstOrDefault().DateDisabled == null ? String.Empty : employeeSiteDetails.FirstOrDefault().DateDisabled.ToString());
                        else
                            _employeeDetailsPageViewModel.AccountManagementSection.strAccountDisabled = _localizer.GetString(FieldLabelResourceKeyConstants.AccountIsDisabledFieldLabel);
                    }
                    _employeeDetailsPageViewModel.LoginSection.Login = employeeSiteDetails.FirstOrDefault().strAccountName;
                    _employeeDetailsPageViewModel.LoginSection.LastLogin = employeeSiteDetails.FirstOrDefault().strAccountName;
                    _employeeDetailsPageViewModel.LoginSection.Password = "Password999";
                    _employeeDetailsPageViewModel.LoginSection.ConfirmPassword = "Password999";
                    _employeeDetailsPageViewModel.LoginSection.strIdentity = employeeSiteDetails.FirstOrDefault().strIdentity;
                    _employeeDetailsPageViewModel.LoginSection.MustChangePassword = employeeSiteDetails.FirstOrDefault().PasswordResetRequired;
                    _employeeDetailsPageViewModel.LoginSection.DateDisabled = employeeSiteDetails.FirstOrDefault().DateDisabled;

                }

                EmployeesUserGroupAndPermissionsGetRequestModel request = new EmployeesUserGroupAndPermissionsGetRequestModel();

                request.idfPerson = long.Parse(id);
                request.LangID = GetCurrentLanguage();

                _employeeDetailsPageViewModel.AccountManagementSection.UserGroupsAndPermissions.AddRange(_employeeClient.GetEmployeeUserGroupAndPermissions(request).Result);
                _employeeDetailsPageViewModel.AccountManagementSection.EmployeeID = request.idfPerson.Value;
            }

            //get User and NonUser radio buttons
            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.EmployeeCategory, null);
            _employeeDetailsPageViewModel.PersonalInfoSection.EmployeeCategoryList = list;
            if (_employeeDetailsPageViewModel.PersonalInfoSection.idfsEmployeeCategory == null)
                _employeeDetailsPageViewModel.PersonalInfoSection.idfsEmployeeCategory = (long)EmployeeCategory.User;
            _employeeDetailsPageViewModel.PersonalInfoSection.EmployeeCategory = list.Find(v => v.IdfsBaseReference == (long)_employeeDetailsPageViewModel.PersonalInfoSection.idfsEmployeeCategory) == null ? String.Empty : list.Find(v => v.IdfsBaseReference == (long)_employeeDetailsPageViewModel.PersonalInfoSection.idfsEmployeeCategory).Name;

            return View(_employeeDetailsPageViewModel);
        }

        [Route("GetOrganizationsAdvancedListUser")]
        [HttpGet]
        public async Task<JsonResult> GetOrganizationsAdvancedListUser(int page, string data, string term)
        {
            Pagination pagination = new(); //Pagination
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            var request = new OrganizationAdvancedGetRequestModel();

            try
            {
                request.LangID = GetCurrentLanguage();
                request.AdvancedSearch = term;
                request.SiteFlag = 0;

                var list = await _organizationClient.GetOrganizationAdvancedList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfOffice.ToString(), text = item.name }));

                pagination.more = true; //Add Pagination
                select2DataObj.results = select2DataItems.GroupBy(x => x.id).Select(x => x.First()).ToList();
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public IActionResult UserPermissions()
        {
            _employeePageViewModel.Select2Configurations = new List<Select2Configruation>();
            _employeePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _employeePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            _employeePageViewModel.Select2Configurations = new List<Select2Configruation>();
            return View(_employeePageViewModel);
        }

        [Route("LoadUserPermissions")]
        [HttpPost]
        public async Task<ActionResult> LoadUserPermissions([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            RegisterViewModel registerViewModel = new RegisterViewModel();
            EmployeeUserPermissionsPageViewModel userPermissionsViewModel = new EmployeeUserPermissionsPageViewModel();
            if (jsonObject != null)
            {
                userPermissionsViewModel = await CreateRequestForUserPermissionsAsync(jsonObject);
                EmployeePersonalInfoSaveRequest = CreateRequestForEmployee(jsonObject, true, false);
                registerViewModel = CreateRequestForEmployeeLogin(jsonObject);
            }
            _employeeDetailsPageViewModel.AccountManagementSection.EmployeeUserPermissionsPageViewModel = userPermissionsViewModel;
            _employeeDetailsPageViewModel.AccountManagementSection.EmployeeUserPermissionsPageViewModel.PersonalInformation = EmployeePersonalInfoSaveRequest;
            _employeeDetailsPageViewModel.AccountManagementSection.EmployeeUserPermissionsPageViewModel.RegisterViewModel = registerViewModel;
            var isAddEmployee = jsonObject["isAddEmployee"] != null ? Convert.ToBoolean(jsonObject["isAddEmployee"].ToString()) : false;
            _employeeDetailsPageViewModel.AccountManagementSection.EmployeeUserPermissionsPageViewModel.IsAddEmployee = isAddEmployee;
            return PartialView("_UserPermissionsPartial", _employeeDetailsPageViewModel.AccountManagementSection.EmployeeUserPermissionsPageViewModel);
        }

        public IActionResult SearchEmployee()
        {
            _employeePageViewModel = new EmployeePageViewModel();
            _employeePageViewModel.Select2Configurations = new List<Select2Configruation>();
            return View(_employeePageViewModel);
        }

        // <summary>
        // Loads Data for the Grid
        // </summary>
        // <param name = "dataTableQueryPostObj" ></ param >
        // < returns ></ returns >
        [HttpPost()]
        public async Task<JsonResult> GetEmployeeListTable([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            bool isAtLeastOneFieldPopulated = false;
            EmployeeGetListRequestModel request = new EmployeeGetListRequestModel();
            //Object to hold deserialized post agrguments
            var postParameterDefinitions = new
            {
                EIDSSOrganizationID = "",
                OrganizationFullName = "",
                OrganizationAbbreviatedName = "",
                ContactPhone = "",
                EmployeeID = "",
                EmployeeCategoryDD = "",
                AccountStateDD = "",
                PersonalIdTypeDD = "",
                PositionDD = "",
                OrganizationDD = "",
                FirstName = "",
                LastName = "",
                MiddleName = "",
                UniqueOrganizationID = "",
                PersonalID = "",
                PositionTypeName = ""
            };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            List<EmployeeListViewModel> _employeeList = new List<EmployeeListViewModel>();

            //Data for Jquery Datatables
            TableData tableData = new TableData();
            request.LanguageId = GetCurrentLanguage();
            try
            {
                //API CALL
                if (dataTableQueryPostObj.postArgs.Length > 0)
                {
                    //Sorting
                    KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
                    valuePair = dataTableQueryPostObj.ReturnSortParameter();

                    if (!string.IsNullOrEmpty(referenceType.EmployeeID))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.EmployeeID = long.Parse(referenceType.EmployeeID);
                    }
                    if (!string.IsNullOrEmpty(referenceType.FirstName))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.FirstOrGivenName = referenceType.FirstName;
                    }
                    if (!string.IsNullOrEmpty(referenceType.MiddleName))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.SecondName = referenceType.MiddleName;
                    }
                    if (!string.IsNullOrEmpty(referenceType.LastName))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.LastOrSurName = referenceType.LastName;
                    }
                    if (!string.IsNullOrEmpty(referenceType.ContactPhone))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.ContactPhone = referenceType.ContactPhone;
                    }
                    if (!string.IsNullOrEmpty(referenceType.OrganizationAbbreviatedName))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.OrganizationAbbreviatedName = referenceType.OrganizationAbbreviatedName;
                    }
                    if (!string.IsNullOrEmpty(referenceType.OrganizationFullName))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.OrganizationFullName = referenceType.OrganizationFullName;
                    }
                    if (!string.IsNullOrEmpty(referenceType.UniqueOrganizationID))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.EIDSSOrganizationID = referenceType.UniqueOrganizationID;
                    }
                    if (!string.IsNullOrEmpty(referenceType.OrganizationDD))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.OrganizationID = long.Parse(referenceType.OrganizationDD);
                    }
                    if (!string.IsNullOrEmpty(referenceType.PositionTypeName))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.PositionTypeName = referenceType.PositionTypeName;
                    }
                    if (!string.IsNullOrEmpty(referenceType.PositionDD))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.PositionTypeID = long.Parse(referenceType.PositionDD);
                    }

                    if (!string.IsNullOrEmpty(referenceType.EmployeeCategoryDD))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.EmployeeCategory = long.Parse(referenceType.EmployeeCategoryDD);
                    }

                    if (!string.IsNullOrEmpty(referenceType.EmployeeCategoryDD))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.EmployeeCategoryID = long.Parse(referenceType.EmployeeCategoryDD);
                    }

                    if (!string.IsNullOrEmpty(referenceType.AccountStateDD))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.AccountState = long.Parse(referenceType.AccountStateDD);
                    }
                    if (!string.IsNullOrEmpty(referenceType.PersonalIdTypeDD))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.PersonalIdType = long.Parse(referenceType.PersonalIdTypeDD);
                    }
                    if (!string.IsNullOrEmpty(referenceType.PersonalID))
                    {
                        isAtLeastOneFieldPopulated = true;
                        request.PersonalIDValue = referenceType.PersonalID;
                    }

                    request.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "EmployeeID";
                    request.SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc";
                    request.Page = dataTableQueryPostObj.page;
                    request.PageSize = dataTableQueryPostObj.length;

                    if (isAtLeastOneFieldPopulated == true)
                    {
                        _employeePageViewModel.EmployeeList = await _employeeClient.GetEmployeeList(request);
                        _employeeList = _employeePageViewModel.EmployeeList.ToList();
                    }

                }

                tableData.iTotalRecords = _employeeList.Count() == 0 ? 0 : _employeeList.FirstOrDefault().TotalRowCount;
                tableData.iTotalDisplayRecords = _employeeList.Count() == 0 ? 0 : _employeeList.FirstOrDefault().TotalRowCount;
                tableData.draw = dataTableQueryPostObj.draw;
                tableData.data = new List<List<string>>();
                if (_employeeList.Count > 0)
                {
                    int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;
                    for (int i = 0; i < _employeeList.Count(); i++)
                    {
                        var accountState = _employeeList.ElementAt(i).AccountDisabled != null ? _employeeList.ElementAt(i).AccountDisabled : string.Empty;
                        if (string.IsNullOrEmpty(accountState))
                        {
                            accountState = _employeeList.ElementAt(i).AccountLocked != null ? _employeeList.ElementAt(i).AccountLocked : string.Empty;
                        }

                        List<string> cols = new List<string>()
                        {
                            (row + i + 1).ToString(),
                            _employeeList.ElementAt(i).EmployeeCategory != null ? _employeeList.ElementAt(i).EmployeeCategory : string.Empty,
                            accountState,
                            _employeeList.ElementAt(i).OrganizationAbbreviatedName != null ? _employeeList.ElementAt(i).OrganizationAbbreviatedName.ToString() :string.Empty,
                            _employeeList.ElementAt(i).LastOrSurName != null ? _employeeList.ElementAt(i).LastOrSurName.ToString() : string.Empty,
                            _employeeList.ElementAt(i).FirstOrGivenName != null ? _employeeList.ElementAt(i).FirstOrGivenName.ToString() : string.Empty,
                            _employeeList.ElementAt(i).SecondName != null ? _employeeList.ElementAt(i).SecondName.ToString() : string.Empty,
                            _employeeList.ElementAt(i).PositionTypeName != null ? _employeeList.ElementAt(i).PositionTypeName.ToString() : string.Empty,
                            _employeeList.ElementAt(i).ContactPhone != null ? _employeeList.ElementAt(i).ContactPhone.ToString() : string.Empty,
                            _employeeList.ElementAt(i).EmployeeID != null ? _employeeList.ElementAt(i).EmployeeID.ToString() : string.Empty,
                            string.Empty
                        };
                        tableData.data.Add(cols);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            return Json(tableData);
        }

        public async Task<EmployeePersonalInfoPageViewModel> LoadPersonalInfo(string queryData)
        {
            EmployeePersonalInfoPageViewModel model = new EmployeePersonalInfoPageViewModel();
            _userPermissions = GetUserPermissions(PagePermission.CanManageUserAccounts);
            model.UserPermissions = _userPermissions;
            var _CanManageReferencesandConfiguratuionsPermission = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            model.CanManageReferencesandConfiguratuionsPermission = _CanManageReferencesandConfiguratuionsPermission;
            var CanAccessOrganizationsList = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
            model.CanAccessOrganizationsList = CanAccessOrganizationsList;
            model.Select2Configurations = new List<Select2Configruation>();
            model.OrganizationDD = new Select2Configruation();
            model.SiteDD = new Select2Configruation();
            model.DepartmentDD = new Select2Configruation();
            model.PositionDD = new Select2Configruation();
            model.PersonalIdTypeDD = new Select2Configruation();
            model.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            try
            {
                EmployeeDetailsGetRequestModel detailRequest = new EmployeeDetailsGetRequestModel();
                detailRequest.idfPerson = long.Parse(queryData);
                detailRequest.LangID = GetCurrentLanguage();
                var detailResponse = await _employeeClient.GetEmployeeDetail(detailRequest);
                if (detailResponse != null && detailResponse.Count > 0)
                {
                    var details = detailResponse.FirstOrDefault();
                    model.FirstOrGivenName = details.strFirstName;
                    model.LastOrSurName = details.strFamilyName;
                    model.SecondName = details.strSecondName;

                    model.PersonalIDTypeName = details.strPersonalIDType;
                    model.PersonalIDType = details.PersonalIDTypeID;
                    model.PersonalID = details.PersonalIDValue;

                    model.OrganizationID = details.idfInstitution;
                    model.AbbreviatedName = details.strOrganizationName;

                    model.DepartmentID = details.idfDepartment;
                    model.DepartmentName = details.strDepartmentName;
                    if (details.idfsSite != 1)
                    {
                        model.SiteID = details.idfsSite;
                        model.SiteName = details.strSiteName;
                    }

                    model.EmployeeCategory = details.strEmployeeCategory;
                    if (model.EmployeeCategory == "Non-User")
                    {
                        model.EmployeeCategory = EmployeeCategory.NonUser.ToString();
                    }
                    model.idfsEmployeeCategory = details.idfsEmployeeCategory;

                    model.ContactPhone = details.strContactPhone;

                    model.PositionTypeID = details.idfsStaffPosition;
                    model.PositionTypeName = details.strStaffPosition;
                }

            }
            catch (Exception ex)
            {

            }
            return model;
        }

        public async Task<List<AdminEmployeeSiteDetailsViewModel>> LoadLoginAndAccountManagementInfo(string queryData)
        {
            List<AdminEmployeeSiteDetailsViewModel> employeeSiteDetails = new List<AdminEmployeeSiteDetailsViewModel>();
            EmployeesSiteDetailsGetRequestModel request = new EmployeesSiteDetailsGetRequestModel();
            request.LangID = GetCurrentLanguage();
            if (!string.IsNullOrEmpty(queryData))
            {
                request.idfPerson = long.Parse(queryData);
                employeeSiteDetails = await _employeeClient.GetEmployeeSiteDetails(request);
            }
            return employeeSiteDetails;
        }

        [HttpPost()]
        [Route("GetUserGroupsAndPermissionsList")]
        public async Task<JsonResult> GetUserGroupsAndPermissionsList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            EmployeesUserGroupAndPermissionsGetRequestModel request = new EmployeesUserGroupAndPermissionsGetRequestModel();

            request.idfPerson = 420664190000891;
            request.LangID = GetCurrentLanguage();

            var result = _employeeClient.GetEmployeeUserGroupAndPermissions(request).Result;
            IEnumerable<EmployeeUserGroupsAndPermissionsViewModel> list = result;
            TableData tableData = new TableData();
            tableData.data = new List<List<string>>();
            tableData.draw = dataTableQueryPostObj.draw;

            if (list.Count() > 0)
            {
                int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (int i = 0; i < list.Count(); i++)
                {
                    List<string> cols = new List<string>()
                    {
                        (row + i + 1).ToString(),
                        list.ElementAt(i).SiteID.ToString(),
                        list.ElementAt(i).OrganizationFullName.ToString(),
                        list.ElementAt(i).STATUS.ToString(),
                        list.ElementAt(i).IsDefault.ToString(),
                        ""
                    };

                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);
        }

        [Route("create")]
        [Route("[controller]/[action]")]
        public async Task<long> GetSiteID(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            long siteId = 0;

            try
            {
                OrganizationGetRequestModel model = new OrganizationGetRequestModel();
                model.LanguageId = GetCurrentLanguage();
                model.SortColumn = "OrganizationAbbreviatedName";
                model.SortOrder = "asc";
                model.PageSize = 10;
                JArray jsonArray = JArray.Parse(data);
                dynamic jsonObject;
                if (jsonArray.Count > 0)
                {
                    jsonObject = JObject.Parse(jsonArray[0].ToString());

                    if (jsonObject["text"] != null)
                    {
                        model.AbbreviatedName = jsonObject["text"].ToString();
                    }
                }
                var list = await _organizationClient.GetOrganizationList(model);
                if (list != null && list.Count > 0)
                {
                    siteId = (long)list.FirstOrDefault().SiteID;
                }
            }
            catch (Exception)
            {
                throw;
            }
            return siteId;
        }

        [HttpGet]
        public async Task<IActionResult> GetSiteDetails(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            long siteId = 0;
            List<EmployeeSiteFromOrgViewModel> response = new List<EmployeeSiteFromOrgViewModel>();

            try
            {
                long? OrgID = 0;
                JArray jsonArray = JArray.Parse(data);
                dynamic jsonObject;
                if (jsonArray.Count > 0)
                {
                    jsonObject = JObject.Parse(jsonArray[0].ToString());

                    if (jsonObject["id"] != null)
                    {
                        OrgID = long.Parse(jsonObject["id"].ToString());
                    }
                }
                response = await _employeeClient.GetEmployeeSiteFromOrg(OrgID);
            }
            catch (Exception ex)
            {
                throw;
            }

            return Ok(response.FirstOrDefault());
        }

        [HttpGet]
        public async Task<IActionResult> GetExistingOrg(long employeeId, string data)
        {
            EmployeeUserGroupsAndPermissionsViewModel response = new EmployeeUserGroupsAndPermissionsViewModel();

            JsonResult jsonResult = null;
            try
            {
                long? OrgID = 0;
                JArray jsonArray = JArray.Parse(data);
                dynamic jsonObject;
                if (jsonArray.Count > 0)
                {
                    jsonObject = JObject.Parse(jsonArray[0].ToString());
                    if (jsonObject["id"] != null)
                    {
                        OrgID = long.Parse(jsonObject["id"].ToString());
                    }
                }

                var model = new EmployeesUserGroupAndPermissionsGetRequestModel()
                {
                    idfPerson = employeeId,
                    LangID = GetCurrentLanguage(),
                };

                var userOrganizations = await _employeeClient.GetEmployeeUserGroupAndPermissions(model);

                var userOrg = userOrganizations?.FirstOrDefault(u => u.OrganizationID == OrgID);

                if (userOrg != null)
                {
                    jsonResult = Json(new { OrgName = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), userOrg.OrganizationFullName) });
                }

            }
            catch (Exception ex)
            {
                throw;
            }

            return Ok(jsonResult);
        }

        public async Task<JsonResult> GetSiteList(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            try
            {
                SiteGetRequestModel model = new SiteGetRequestModel();

                JArray jsonArray = JArray.Parse(data);
                dynamic jsonObject;
                if (jsonArray.Count > 0)
                {
                    jsonObject = JObject.Parse(jsonArray[0].ToString());
                    if (jsonObject["id"] != null)
                    {
                        model.OrganizationID = long.Parse(jsonObject["id"].ToString());
                    }
                }
                model.LanguageId = GetCurrentLanguage();
                model.PageSize = 10000;
                model.SortColumn = "SiteName";
                model.SortOrder = "ASC";

                var list = await _siteClient.GetSiteList(model);

                list = list.GroupBy(x => x.SiteID).Select(y => y.First()).OrderBy(x => x.EIDSSSiteID).ToList();

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.SiteID.ToString(), text = item.SiteName });
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

        public async Task<JsonResult> GetDepartmentList(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            try
            {
                DepartmentGetRequestModel model = new DepartmentGetRequestModel();
                JArray jsonArray = JArray.Parse(data);
                dynamic jsonObject;
                if (jsonArray.Count > 0)
                {
                    jsonObject = JObject.Parse(jsonArray[0].ToString());
                    if (jsonObject["id"] != null)
                    {
                        model.OrganizationID = long.Parse(jsonObject["id"].ToString());
                    }
                }
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
                        select2DataItems.Add(new Select2DataItem() { id = item.DepartmentID.ToString(), text = item.DepartmentNameNationalValue });
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

        public async Task<JsonResult> GetPositionList(int page, string data, string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = (long)ReferenceTypes.Position,
                Page = 1,
                LanguageId = GetCurrentLanguage(),
                PageSize = 99999,
                AdvancedSearch = term,
                SortColumn = "intorder",
                SortOrder = "asc"
            };

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.KeyId.ToString(), text = item.StrName });
                    }
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

        public async Task<JsonResult> GetUserGroupList(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new List<Select2DataItem>();
            Select2DataResults select2DataObj = new Select2DataResults();
            try
            {
                dynamic jsonObject;
                long siteId = 0;
                jsonObject = JObject.Parse(data);

                if (jsonObject != null)
                {
                    if (jsonObject["text"] != null && jsonObject["text"] != "")
                    {
                        siteId = long.Parse(jsonObject["text"].ToString());
                    }
                }

                var list = await _crossCuttingClient.GetUserGroupList(GetCurrentLanguage(), siteId);

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.idfEmployeeGroup.ToString(), text = item.strName });
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

        [HttpGet()]
        [Route("ReloadSystemFunctionsControl")]
        public async Task<IActionResult> ReloadSystemFunctionsControl(string data)
        {
            SystemFunctionsPagesViewModel svm = new SystemFunctionsPagesViewModel();
            JArray jsonArray = JArray.Parse(data);
            var loggedinUserId = _authenticatedUser.PersonId;
            dynamic jsonObject;
            if (jsonArray.Count > 0)
            {
                jsonObject = JObject.Parse(jsonArray[0].ToString());
                if (jsonObject["isChange"] != null)
                {
                    svm.isChange = Convert.ToBoolean(jsonObject["isChange"].ToString());
                }
                if (jsonObject["UserGroupDD"] != null)
                {
                    svm.UserIDAndUserGroups = jsonObject["UserGroupDD"].ToString();
                    if (jsonObject["EmployeeID"] != null && jsonObject["EmployeeID"] != "0")
                    {
                        svm.EmployeeID = jsonObject["EmployeeID"];
                    }
                }
                else
                {
                    svm.UserIDAndUserGroups = "-1";
                    svm.EmployeeID = jsonObject["EmployeeID"] != null && jsonObject["EmployeeID"].ToString() != string.Empty ? long.Parse(jsonObject["EmployeeID"].ToString()) : 0;
                }
            }

            return ViewComponent("SystemFunctionsView", svm);
        }

        [HttpPost()]
        [Route("SaveDepartment")]
        public async Task<IActionResult> SaveDepartment([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            long OrganizationID = 0;
            if (jsonObject["OrganizationDD"] != null)
            {
                if (jsonObject["OrganizationDD"][0]["id"] != null)
                {
                    OrganizationID = long.Parse(jsonObject["OrganizationDD"][0]["id"].ToString());
                }
            }
            else if (jsonObject["UPOrganizationDD"] != null)
            {
                if (jsonObject["UPOrganizationDD"][0]["id"] != null)
                {
                    OrganizationID = long.Parse(jsonObject["UPOrganizationDD"][0]["id"].ToString());
                }
            }

            DepartmentSaveRequestModel request = new DepartmentSaveRequestModel();
            request.DepartmentID = null;
            request.OrganizationID = OrganizationID;
            request.DefaultName = jsonObject["Default"] != null ? jsonObject["Default"].ToString() : string.Empty;
            request.NationalName = jsonObject["Name"] != null ? jsonObject["Name"].ToString() : string.Empty;
            request.Order = !string.IsNullOrEmpty(jsonObject["Order"].ToString()) ? Convert.ToInt32(jsonObject["Order"].ToString()) : null;
            request.LanguageId = GetCurrentLanguage();
            request.UserName = _authenticatedUser.UserName;

            var response = await _crossCuttingClient.SaveDepartment(request);
            if (response.ReturnMessage == "DOES EXIST")
            {
                response.StrDuplicateField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.DefaultName);
            }
            return Json(response);
        }

        [HttpPost()]
        [Route("SavePosition")]
        public async Task<IActionResult> SavePosition([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());

            int intHACodeTotal = 0;

            int intOrder = 0;
            if (jsonObject["intOrder"] != null)
            {
                intOrder = string.IsNullOrEmpty(((JValue)jsonObject["intOrder"]).Value.ToString()) == true ? 0 : int.Parse(jsonObject["intOrder"].ToString());
            }

            BaseReferenceSaveRequestModel request = new BaseReferenceSaveRequestModel
            {
                BaseReferenceId = null,
                Default = jsonObject["Default"] != null ? jsonObject["Default"].ToString() : string.Empty,
                Name = jsonObject["Name"] != null ? jsonObject["Name"].ToString() : string.Empty,
                intHACode = intHACodeTotal,
                intOrder = intOrder,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeId = (long)ReferenceTypes.Position,
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            var response = await _adminClient.SaveBaseReference(request);
            if (response.ReturnMessage == "DOES EXIST")
            {
                response.StrDuplicateField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            }
            return Json(response);
        }

        private EmployeeSaveRequestModel CreateRequestForEmployee(JObject jsonObject, bool EmployeeCategorySet = false, bool IsSave = false, bool IsSystemFunctionsCheck = false)
        {
            EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            if (jsonObject["idfPerson"] != null && jsonObject["idfPerson"].ToString() != "")
            {
                EmployeePersonalInfoSaveRequest.idfPerson = long.Parse(jsonObject["idfPerson"].ToString());
                _employeeDetailsPageViewModel.AccountManagementSection.EmployeeUserPermissionsPageViewModel.EmployeeID = long.Parse(jsonObject["idfPerson"].ToString());
            }
            var isEdit = jsonObject["isEdit"] != null ? Convert.ToBoolean(jsonObject["isEdit"].ToString()) : false;
            _employeeDetailsPageViewModel.AccountManagementSection.IsEdit = isEdit;
            bool finalSubmit = jsonObject["finalSubmit"] != null && jsonObject["finalSubmit"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["finalSubmit"].ToString()) : false;

            if ((!isEdit && !IsSave) || (finalSubmit))
            {
                EmployeePersonalInfoSaveRequest.idfInstitution = jsonObject["idfInstitution"] != null && jsonObject["idfInstitution"].ToString() != string.Empty && jsonObject["idfInstitution"].ToString() != "0" ? long.Parse(jsonObject["idfInstitution"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfsStaffPosition = jsonObject["idfsStaffPosition"] != null && jsonObject["idfsStaffPosition"].ToString() != string.Empty && jsonObject["idfsStaffPosition"].ToString() != "0" ? long.Parse(jsonObject["idfsStaffPosition"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfDepartment = jsonObject["idfDepartment"] != null && jsonObject["idfDepartment"].ToString() != string.Empty && jsonObject["idfDepartment"].ToString() != "0" ? long.Parse(jsonObject["idfDepartment"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfsSite = jsonObject["idfsSite"] != null && jsonObject["idfsSite"].ToString() != string.Empty && jsonObject["idfsSite"].ToString() != "0" ? long.Parse(jsonObject["idfsSite"].ToString()) : 1;
                EmployeePersonalInfoSaveRequest.strContactPhone = jsonObject["strContactPhone"] != null && jsonObject["strContactPhone"].ToString() != string.Empty ? jsonObject["strContactPhone"].ToString() : "";
            }
            else if (IsSave)
            {
                EmployeePersonalInfoSaveRequest.idfInstitution = jsonObject["UPidfInstitution"] != null && jsonObject["UPidfInstitution"].ToString() != string.Empty && jsonObject["UPidfInstitution"].ToString() != "0" ? long.Parse(jsonObject["UPidfInstitution"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfsStaffPosition = jsonObject["UPidfsStaffPosition"] != null && jsonObject["UPidfsStaffPosition"].ToString() != string.Empty && jsonObject["UPidfsStaffPosition"].ToString() != "0" ? long.Parse(jsonObject["UPidfsStaffPosition"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfDepartment = jsonObject["UPidfDepartment"] != null && jsonObject["UPidfDepartment"].ToString() != string.Empty && jsonObject["UPidfDepartment"].ToString() != "0" ? long.Parse(jsonObject["UPidfDepartment"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfsSite = jsonObject["UPidfsSite"] != null && jsonObject["UPidfsSite"].ToString() != string.Empty && jsonObject["UPidfsSite"].ToString() != "0" ? long.Parse(jsonObject["UPidfsSite"].ToString()) : 1;
                EmployeePersonalInfoSaveRequest.strContactPhone = jsonObject["UPstrContactPhone"] != null && jsonObject["UPstrContactPhone"].ToString() != string.Empty ? jsonObject["UPstrContactPhone"].ToString() : "";
            }
            else if (IsSystemFunctionsCheck)
            {
                EmployeePersonalInfoSaveRequest.idfInstitution = jsonObject["UPidfInstitution"] != null && jsonObject["UPidfInstitution"].ToString() != string.Empty && jsonObject["UPidfInstitution"].ToString() != "0" ? long.Parse(jsonObject["UPidfInstitution"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfsStaffPosition = jsonObject["UPidfsStaffPosition"] != null && jsonObject["UPidfsStaffPosition"].ToString() != string.Empty && jsonObject["UPidfsStaffPosition"].ToString() != "0" ? long.Parse(jsonObject["UPidfsStaffPosition"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfDepartment = jsonObject["UPidfDepartment"] != null && jsonObject["UPidfDepartment"].ToString() != string.Empty && jsonObject["UPidfDepartment"].ToString() != "0" ? long.Parse(jsonObject["UPidfDepartment"].ToString()) : null;
                EmployeePersonalInfoSaveRequest.idfsSite = jsonObject["UPidfsSite"] != null && jsonObject["UPidfsSite"].ToString() != string.Empty && jsonObject["UPidfsSite"].ToString() != "0" ? long.Parse(jsonObject["UPidfsSite"].ToString()) : 1;
                EmployeePersonalInfoSaveRequest.strContactPhone = jsonObject["UPstrContactPhone"] != null && jsonObject["UPstrContactPhone"].ToString() != string.Empty ? jsonObject["UPstrContactPhone"].ToString() : "";
            }
            EmployeePersonalInfoSaveRequest.strFamilyName = jsonObject["strFamilyName"] != null && jsonObject["strFamilyName"].ToString() != string.Empty ? jsonObject["strFamilyName"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strFirstName = jsonObject["strFirstName"] != null && jsonObject["strFirstName"].ToString() != string.Empty ? jsonObject["strFirstName"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strSecondName = jsonObject["strSecondName"] != null && jsonObject["strSecondName"].ToString() != string.Empty ? jsonObject["strSecondName"].ToString() : "";
            EmployeePersonalInfoSaveRequest.strPersonalID = jsonObject["strPersonalID"] != null && jsonObject["strPersonalID"].ToString() != string.Empty ? jsonObject["strPersonalID"].ToString() : null;
            EmployeePersonalInfoSaveRequest.idfPersonalIDType = jsonObject["idfPersonalIDType"] != null && jsonObject["idfPersonalIDType"].ToString() != string.Empty ? jsonObject["idfPersonalIDType"].ToString() : null;
            EmployeePersonalInfoSaveRequest.idfPersonalIDTypeText = jsonObject["idfPersonalIDTypeText"] != null && jsonObject["idfPersonalIDTypeText"].ToString() != string.Empty ? jsonObject["idfPersonalIDTypeText"].ToString() : null;

            if (finalSubmit)
            {
                EmployeeCategorySet = true;
            }
            if (EmployeeCategorySet && jsonObject != null && jsonObject["idfsEmployeeCategory"] != null && jsonObject["idfsEmployeeCategory"].ToString() != string.Empty)
            {
                if (jsonObject["idfsEmployeeCategory"].ToString() == ((long)EmployeeCategory.User).ToString())
                {
                    EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.User;
                }
                else
                {
                    EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;
                }

            }
            else if (!EmployeeCategorySet && jsonObject != null && jsonObject["idfsEmployeeCategory"] != null && jsonObject["idfsEmployeeCategory"].ToString() != string.Empty)
            {
                EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = long.Parse(jsonObject["idfsEmployeeCategory"].ToString());
            }
            return EmployeePersonalInfoSaveRequest;
        }

        private RegisterViewModel CreateRequestForEmployeeLogin(JObject jsonObject)
        {
            //Login
            RegisterViewModel registerViewModel = new RegisterViewModel();
            registerViewModel.Username = jsonObject["Username"] != null && jsonObject["Username"].ToString() != string.Empty ? jsonObject["Username"].ToString() : "";
            registerViewModel.Password = jsonObject["Password"] != null && jsonObject["Password"].ToString() != string.Empty ? jsonObject["Password"].ToString() : "";
            registerViewModel.IsPasswordResetRequired = jsonObject["IsPasswordResetRequired"] != null && jsonObject["IsPasswordResetRequired"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["IsPasswordResetRequired"].ToString()) : false;
            registerViewModel.Disabled = jsonObject["Disabled"] != null && jsonObject["Disabled"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["Disabled"].ToString()) : false;
            registerViewModel.blnLocked = jsonObject["blnLocked"] != null && jsonObject["blnLocked"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["blnLocked"].ToString()) : false;
            registerViewModel.Reason = jsonObject["Reason"] != null && jsonObject["Reason"].ToString() != string.Empty ? jsonObject["Reason"].ToString() : "";
            return registerViewModel;
        }

        private async Task<EmployeeUserPermissionsPageViewModel> CreateRequestForUserPermissionsAsync(JObject jsonObject)
        {
            EmployeeUserPermissionsPageViewModel userPermissionsViewModel = new EmployeeUserPermissionsPageViewModel();
            userPermissionsViewModel.Select2Configurations = new List<Select2Configruation>();
            userPermissionsViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            if (jsonObject["idfPerson"] != null && jsonObject["idfPerson"].ToString() != "")
            {
                userPermissionsViewModel.EmployeeID = long.Parse(jsonObject["idfPerson"].ToString());
            }
            userPermissionsViewModel.OrganizationID = jsonObject["idfInstitution"] != null && jsonObject["idfInstitution"].ToString() != string.Empty ? long.Parse(jsonObject["idfInstitution"].ToString()) : null;
            var isEdit = jsonObject["isEdit"] != null ? Convert.ToBoolean(jsonObject["isEdit"].ToString()) : false;
            var isDefault = jsonObject["isDefault"] != null ? Convert.ToBoolean(jsonObject["isDefault"].ToString()) : false;
            userPermissionsViewModel.isDefault = isDefault;
            userPermissionsViewModel.isEditOrg = isEdit;
            if (userPermissionsViewModel.EmployeeID != 0 && isEdit && userPermissionsViewModel.OrganizationID != null && !isDefault)
            {
                EmployeeUserGroupOrgDetailsGetRequestModel detailRequest = new EmployeeUserGroupOrgDetailsGetRequestModel();
                detailRequest.idfPerson = userPermissionsViewModel.EmployeeID;
                detailRequest.idfOffice = userPermissionsViewModel.OrganizationID;
                detailRequest.LangID = GetCurrentLanguage();
                List<EmployeeUserGroupOrgDetailsViewModel> detailResponse = _employeeClient.GetEmployeeUserGroupAndPermissionDetail(detailRequest).Result;
                if (detailResponse.Count > 0)
                {
                    EmployeeUserGroupOrgDetailsViewModel OrgDetails = detailResponse.FirstOrDefault();
                    userPermissionsViewModel.OrganizationFullName = OrgDetails.strOrganizationName;
                    userPermissionsViewModel.DepartmentName = OrgDetails.strDepartmentName;
                    userPermissionsViewModel.PositionTypeName = OrgDetails.strStaffPosition;
                    userPermissionsViewModel.OtherSiteName = OrgDetails.SiteName;
                    userPermissionsViewModel.PositionTypeID = OrgDetails.idfsStaffPosition;
                    userPermissionsViewModel.DepartmentID = OrgDetails.idfDepartment;
                    userPermissionsViewModel.OtherContactPhone = OrgDetails.strContactPhone;
                    userPermissionsViewModel.idfsSite = OrgDetails.idfsSite;
                    userPermissionsViewModel.idfUserID = OrgDetails.idfUserID;
                    userPermissionsViewModel.UserGroupID = Convert.ToInt64(OrgDetails.UserGroupID);
                    userPermissionsViewModel.UserGroupName = OrgDetails.UserGroup;

                    var userGroupID = userPermissionsViewModel.UserGroupID == null ? String.Empty : userPermissionsViewModel.UserGroupID.ToString();
                    var userGroupName = userPermissionsViewModel.UserGroupName;
                    var userGroupNameNew = userGroupName;

                    if (userGroupID != null && userGroupName != null && userGroupID != "" && userGroupName != "")
                    {
                        var list = await _crossCuttingClient.GetUserGroupList(GetCurrentLanguage(), userPermissionsViewModel.idfsSite);
                        string strID = EIDSSConstants.GlobalConstants.NullValue.ToLower();
                        string text = string.Empty;
                        var arrUserGroupIDDetails = userGroupID.Split(',');
                        var arrUserGroupDetails = userGroupName.Split(',');
                        userPermissionsViewModel.UserGroups = new List<Select2DataItem>();
                        for (int i = 0; i <= arrUserGroupIDDetails.Count() - 1; i++)
                        {
                            var UserGroupDetail = new Select2DataItem();
                            strID = arrUserGroupIDDetails[i].ToString();
                            text = list.Find(v => v.idfEmployeeGroup == long.Parse(arrUserGroupIDDetails[i])) == null ? String.Empty : list.Find(v => v.idfEmployeeGroup == long.Parse(arrUserGroupIDDetails[i])).strName;
                            var defaultReference = new Select2DataItem() { id = strID, text = text };
                            userPermissionsViewModel.UserGroups.Add(defaultReference);
                            userGroupNameNew = userGroupNameNew.Replace(arrUserGroupDetails[i], text);
                        }
                    }
                    userPermissionsViewModel.UserGroupName = userGroupNameNew;
                }
                else if (detailResponse.Count == 0)
                {
                    userPermissionsViewModel.OrganizationFullName = jsonObject["idfInstitutionText"] != null && jsonObject["idfInstitutionText"].ToString() != string.Empty ? jsonObject["idfInstitutionText"].ToString() : null;

                    userPermissionsViewModel.OtherSiteName = jsonObject["idfsSiteText"] != null && jsonObject["idfsSiteText"].ToString() != string.Empty ? jsonObject["idfsSiteText"].ToString() : null;
                    if (isDefault)
                    {
                        userPermissionsViewModel.PositionTypeID = jsonObject["idfsStaffPosition"] != null && jsonObject["idfsStaffPosition"].ToString() != string.Empty ? long.Parse(jsonObject["idfsStaffPosition"].ToString()) : null;
                        userPermissionsViewModel.DepartmentID = jsonObject["idfDepartment"] != null && jsonObject["idfDepartment"].ToString() != string.Empty ? long.Parse(jsonObject["idfDepartment"].ToString()) : null;
                        userPermissionsViewModel.DepartmentName = jsonObject["idfDepartmentText"] != null && jsonObject["idfDepartmentText"].ToString() != string.Empty ? jsonObject["idfDepartmentText"].ToString() : null;
                        userPermissionsViewModel.PositionTypeName = jsonObject["idfsStaffPositionText"] != null && jsonObject["idfsStaffPositionText"].ToString() != string.Empty ? jsonObject["idfsStaffPositionText"].ToString() : null;
                        userPermissionsViewModel.OtherContactPhone = jsonObject["strContactPhone"] != null && jsonObject["strContactPhone"].ToString() != string.Empty ? jsonObject["strContactPhone"].ToString() : null;
                    }

                    userPermissionsViewModel.idfsSite = jsonObject["idfsSite"] != null && jsonObject["idfsSite"].ToString() != string.Empty ? long.Parse(jsonObject["idfsSite"].ToString()) : null;
                    userPermissionsViewModel.UserGroupID = jsonObject["UserGroupID"] != null && jsonObject["UserGroupID"].ToString() != string.Empty ? long.Parse(jsonObject["UserGroupID"].ToString()) : -1;
                    userPermissionsViewModel.UserGroupName = jsonObject["UserGroup"] != null && jsonObject["UserGroup"].ToString() != string.Empty ? jsonObject["UserGroup"].ToString() : "";

                    var userGroupID = jsonObject["UserGroupID"] != null && jsonObject["UserGroupID"].ToString() != string.Empty ? jsonObject["UserGroupID"].ToString() : null;
                    var userGroupName = jsonObject["UserGroup"] != null && jsonObject["UserGroup"].ToString() != string.Empty ? jsonObject["UserGroup"].ToString() : null;
                    if (isDefault && userPermissionsViewModel.EmployeeID != 0)
                    {
                        if (userGroupID != null && userGroupName != null)
                        {
                            var arrUserGroupIDDetails = userGroupID.Split(',');
                            var arrUserGroupDetails = userGroupName.Split(',');
                            userPermissionsViewModel.UserGroups = new List<Select2DataItem>();
                            for (int i = 0; i <= arrUserGroupIDDetails.Count() - 1; i++)
                            {
                                var UserGroupDetail = new Select2DataItem();
                                var defaultReference = new Select2DataItem() { id = arrUserGroupIDDetails[i].ToString(), text = HtmlEncoder.Default.Encode(arrUserGroupDetails[i]) };
                                userPermissionsViewModel.UserGroups.Add(defaultReference);
                            }
                        }
                    }
                }
            }
            else if ((isEdit && userPermissionsViewModel.EmployeeID == 0) || isDefault)
            {
                userPermissionsViewModel.OrganizationFullName = jsonObject["idfInstitutionText"] != null && jsonObject["idfInstitutionText"].ToString() != string.Empty ? jsonObject["idfInstitutionText"].ToString() : "";
                userPermissionsViewModel.DepartmentName = jsonObject["idfDepartmentText"] != null && jsonObject["idfDepartmentText"].ToString() != string.Empty ? jsonObject["idfDepartmentText"].ToString() : "";
                userPermissionsViewModel.PositionTypeName = jsonObject["idfsStaffPositionText"] != null && jsonObject["idfsStaffPositionText"].ToString() != string.Empty ? jsonObject["idfsStaffPositionText"].ToString() : "";
                userPermissionsViewModel.OtherSiteName = jsonObject["idfsSiteText"] != null && jsonObject["idfsSiteText"].ToString() != string.Empty ? jsonObject["idfsSiteText"].ToString() : "";
                userPermissionsViewModel.PositionTypeID = jsonObject["idfsStaffPosition"] != null && jsonObject["idfsStaffPosition"].ToString() != string.Empty ? long.Parse(jsonObject["idfsStaffPosition"].ToString()) : 0;
                userPermissionsViewModel.DepartmentID = jsonObject["idfDepartment"] != null && jsonObject["idfDepartment"].ToString() != string.Empty ? long.Parse(jsonObject["idfDepartment"].ToString()) : 0;
                userPermissionsViewModel.OtherContactPhone = jsonObject["strContactPhone"] != null && jsonObject["strContactPhone"].ToString() != string.Empty ? jsonObject["strContactPhone"].ToString() : "";
                userPermissionsViewModel.idfsSite = jsonObject["idfsSite"] != null && jsonObject["idfsSite"].ToString() != string.Empty ? long.Parse(jsonObject["idfsSite"].ToString()) : 0;
                userPermissionsViewModel.UserGroupID = jsonObject["UserGroupID"] != null && jsonObject["UserGroupID"].ToString() != string.Empty ? long.Parse(jsonObject["UserGroupID"].ToString()) : -1;
                userPermissionsViewModel.UserGroupName = jsonObject["UserGroup"] != null && jsonObject["UserGroup"].ToString() != string.Empty ? jsonObject["UserGroup"].ToString() : "";

                var userGroupID = jsonObject["UserGroupID"] != null && jsonObject["UserGroupID"].ToString() != string.Empty ? jsonObject["UserGroupID"].ToString() : "";
                var userGroupName = jsonObject["UserGroup"] != null && jsonObject["UserGroup"].ToString() != string.Empty ? jsonObject["UserGroup"].ToString() : "";
                var userGroupNameNew = userGroupName;
                if (isDefault && userPermissionsViewModel.EmployeeID != 0)
                {
                    if (userGroupID != null && userGroupName != null && userGroupID != "" && userGroupName != "")
                    {
                        var list = await _crossCuttingClient.GetUserGroupList(GetCurrentLanguage(), userPermissionsViewModel.idfsSite);
                        string strID = EIDSSConstants.GlobalConstants.NullValue.ToLower();
                        string text = string.Empty;
                        var arrUserGroupIDDetails = userGroupID.Split(',');
                        var arrUserGroupDetails = userGroupName.Split(',');
                        userPermissionsViewModel.UserGroups = new List<Select2DataItem>();
                        for (int i = 0; i <= arrUserGroupIDDetails.Count() - 1; i++)
                        {
                            var UserGroupDetail = new Select2DataItem();
                            strID = arrUserGroupIDDetails[i].ToString();
                            text = list.Find(v => v.idfEmployeeGroup == long.Parse(arrUserGroupIDDetails[i])) == null ? String.Empty : list.Find(v => v.idfEmployeeGroup == long.Parse(arrUserGroupIDDetails[i])).strName;
                            var defaultReference = new Select2DataItem() { id = strID, text = text };
                            userPermissionsViewModel.UserGroups.Add(defaultReference);
                            userGroupNameNew = userGroupNameNew.Replace(arrUserGroupDetails[i], text);
                        }
                    }
                    userPermissionsViewModel.UserGroupName = userGroupNameNew;
                }
            }

            return userPermissionsViewModel;
        }

        [HttpPost()]
        [Route("SaveAdminEmployeeDetails")]
        public async Task<IActionResult> SaveAdminEmployeeDetails([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            var aspnetuserId = "0";
            EmployeeSaveRequestResponseModel response = new EmployeeSaveRequestResponseModel();
            long? EmployeeID = 0;
            long? NewEmployee = 0;
            EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            RegisterViewModel registerViewModel = new RegisterViewModel();
            EmployeeUserGroupMemberSaveRequestModel userGroupRequest = new EmployeeUserGroupMemberSaveRequestModel();
            long? employeeCategory = 0;
            var SavedEmployeeCategory = "";
            long? SavedEmployeeCategoryID = 0;
            bool IsChangeUserToNonUser = false;
            var userName = "";

            try
            {
                if (jsonObject != null)
                {
                    string duplicateMessage = "";
                    EmployeePersonalInfoSaveRequest = CreateRequestForEmployee(jsonObject, false, true);
                    NewEmployee = EmployeePersonalInfoSaveRequest.idfPerson;
                    bool UserPermissionsSaveDone = jsonObject["UserPermissionsSaveDone"] != null && jsonObject["UserPermissionsSaveDone"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["UserPermissionsSaveDone"].ToString()) : false;
                    bool isEditOrg = jsonObject["isEditOrg"] != null ? Convert.ToBoolean(jsonObject["isEditOrg"].ToString()) : false;
                    bool finalSubmit = jsonObject["finalSubmit"] != null && jsonObject["finalSubmit"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["finalSubmit"].ToString()) : false;
                    bool isEditEmployee = jsonObject["isEditEmployee"] != null && jsonObject["isEditEmployee"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["isEditEmployee"].ToString()) : false;
                    bool isAddEmployee = jsonObject["isAddEmployee"] != null && jsonObject["isAddEmployee"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["isAddEmployee"].ToString()) : false;
                    string LastLogin = jsonObject["LastLogin"] != null && jsonObject["LastLogin"].ToString() != string.Empty ? jsonObject["LastLogin"].ToString() : "";

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

                    userName = jsonObject["Username"] != null && jsonObject["Username"].ToString() != string.Empty ? jsonObject["Username"].ToString() : "";

                    List<EmployeeListViewModel> duplicateResponse = await _employeeClient.GetEmployeeList(DuplicateCheckRequest);
                    bool isDuplicateCheckRequired = false;
                    if (isEditEmployee && EmployeePersonalInfoSaveRequest.idfPerson != null && EmployeePersonalInfoSaveRequest.idfPerson != 0 && duplicateResponse != null && duplicateResponse.Count > 0 && duplicateResponse.FirstOrDefault().EmployeeID == EmployeePersonalInfoSaveRequest.idfPerson)
                    {
                        EmployeePersonalInfoSaveRequest.idfPerson = duplicateResponse.FirstOrDefault().EmployeeID;
                        isDuplicateCheckRequired = false;
                    }
                    else if ((!isEditEmployee && finalSubmit && !UserPermissionsSaveDone) || (!isEditEmployee && !isEditOrg && !finalSubmit))
                    {
                        isDuplicateCheckRequired = true;
                    }
                    else if (!isEditEmployee && isEditOrg && EmployeePersonalInfoSaveRequest.idfPerson != null && duplicateResponse != null && duplicateResponse.Count > 0 && duplicateResponse.FirstOrDefault().EmployeeID != EmployeePersonalInfoSaveRequest.idfPerson)
                    {
                        isDuplicateCheckRequired = true;
                    }

                    //Edit Employee
                    if (isDuplicateCheckRequired && duplicateResponse != null && duplicateResponse.Count > 0)
                    {
                        EmployeePersonalInfoSaveRequest.idfPerson = duplicateResponse.FirstOrDefault().EmployeeID;
                        response.RetunMessage = "Duplicate Record";
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
                        if ((isEditEmployee && finalSubmit && duplicateResponse != null && duplicateResponse.Count > 0) || (finalSubmit && UserPermissionsSaveDone && duplicateResponse != null && duplicateResponse.Count > 0))
                        {
                            EmployeePersonalInfoSaveRequest.idfPerson = duplicateResponse.FirstOrDefault().EmployeeID;
                            SavedEmployeeCategory = duplicateResponse.FirstOrDefault().EmployeeCategory;
                            if (SavedEmployeeCategory.Equals(EmployeeCategory.User.ToString()))
                            {
                                SavedEmployeeCategoryID = (long)EmployeeCategory.User;
                            }
                            else
                            {
                                SavedEmployeeCategoryID = (long)EmployeeCategory.NonUser;
                            }
                        }
                        else if (!isEditOrg && !finalSubmit)
                            EmployeePersonalInfoSaveRequest.idfPerson = 0;

                        employeeCategory = EmployeePersonalInfoSaveRequest.idfsEmployeeCategory;

                        if (SavedEmployeeCategoryID != 0 && employeeCategory != 0
                            && SavedEmployeeCategoryID == (long)EmployeeCategory.User
                            && employeeCategory == (long)EmployeeCategory.NonUser
                            && duplicateResponse.FirstOrDefault().EmployeeID == EmployeePersonalInfoSaveRequest.idfPerson)
                        {
                            IsChangeUserToNonUser = true;

                        }
                        if (EmployeePersonalInfoSaveRequest.idfsEmployeeCategory == (long)EmployeeCategory.User)
                        {
                            registerViewModel = CreateRequestForEmployeeLogin(jsonObject);
                        }

                        // Has to be removed for Edit
                        response = await _employeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);

                        if (response != null && response.RetunMessage == "Success")
                        {
                            EmployeeID = response.idfPerson;
                            _employeeDetailsPageViewModel.EmployeeID = (long)response.idfPerson;
                            _employeeDetailsPageViewModel.AccountManagementSection.EmployeeID = (long)response.idfPerson;

                            //Login and Account Management for User

                            if (EmployeePersonalInfoSaveRequest.idfsEmployeeCategory == (long)EmployeeCategory.User)
                            {
                                EmployeeLoginSaveRequestModel loginRequest = new EmployeeLoginSaveRequestModel();
                                loginRequest.idfEmployee = EmployeeID;
                                if (EmployeePersonalInfoSaveRequest.idfsSite == null)
                                    loginRequest.idfsPersonSite = 1;
                                else
                                    loginRequest.idfsPersonSite = EmployeePersonalInfoSaveRequest.idfsSite;
                                EmployeeLoginSaveRequestResponseModel loginResponse = new EmployeeLoginSaveRequestResponseModel();
                                loginResponse = await _employeeClient.SaveUserLoginInfo(loginRequest);
                                if (loginResponse != null && loginResponse.idfUserID != null && !loginResponse.ReturnMessage.Contains("Error"))
                                {
                                    //User Group Member Set
                                    if ((!finalSubmit) || (!isEditEmployee && finalSubmit && !UserPermissionsSaveDone))
                                    {
                                        //SIngle User Group
                                        userGroupRequest.idfEmployeeGroups = jsonObject["UPUserGroup"] != null && jsonObject["UPUserGroup"].ToString() != string.Empty && jsonObject["UPUserGroup"].ToString() != "  []" && jsonObject["UPUserGroup"].ToString() != "," ? jsonObject["UPUserGroup"].ToString() : "-1";
                                        userGroupRequest.idfEmployee = response.idfPerson;
                                        userGroupRequest.intRowStatus = 0;
                                        var userGroupresponse = await _employeeClient.SaveUserGroupMemberInfo(userGroupRequest);

                                    }
                                    AppUserViewModel user;
                                    //User Update
                                    if (string.IsNullOrEmpty(LastLogin))
                                    {
                                        user = await _adminClient.GetAppUser(registerViewModel.Username);
                                    }
                                    else
                                    {
                                        user = await _adminClient.GetAppUser(LastLogin);
                                    }

                                    registerViewModel.idfUserID = loginResponse.idfUserID.Value;
                                    _logger.LogInformation("before if" + registerViewModel.Username);
                                    if ((user == null || user.Id == "0") && (string.IsNullOrEmpty(LastLogin) || LastLogin == registerViewModel.Username))
                                    {
                                        ResponseViewModel resp = await _adminClient.AddEmployee(registerViewModel);
                                        user = resp.appUser;
                                    }
                                    else if (isEditEmployee && user != null && user.Id != "0" && EmployeeID != 0 && user.idfUserID == registerViewModel.idfUserID)
                                    {
                                        PasswordResetRequiredParams resetRequiredRequest = new PasswordResetRequiredParams();
                                        resetRequiredRequest.PasswordResetRequired = registerViewModel.IsPasswordResetRequired;
                                        resetRequiredRequest.UserName = registerViewModel.Username;
                                        var resetRequiredResponse = await _adminClient.UpdatePasswordResetRequired(resetRequiredRequest);
                                        if (!string.IsNullOrEmpty(LastLogin) && LastLogin != registerViewModel.Username)
                                        {
                                            UpdateUserNameParams updateParms = new UpdateUserNameParams();
                                            updateParms.UserID = user.Id;
                                            updateParms.NewUserName = registerViewModel.Username;
                                            ResponseViewModel resp = await _adminClient.UpdateUserName(updateParms);
                                        }
                                        if (registerViewModel.Password != "Password999")
                                        {
                                            ResetPasswordParams parms = new ResetPasswordParams();
                                            parms.password = registerViewModel.Password;
                                            parms.passwordResetRequired = registerViewModel.IsPasswordResetRequired;
                                            parms.updatingUser = registerViewModel.Username;
                                            parms.userId = user.Id;
                                            ResponseViewModel resp = await _adminClient.ResetPassword(parms);
                                        }
                                    }

                                    if (user != null && user.Id != "0")
                                    {
                                        long idfPerson = 0;
                                        var userDetail = await _employeeClient.GetASPNetUser_GetDetails(user.Id);
                                        if (userDetail != null && userDetail.Count > 0)
                                        {
                                            idfPerson = (long)userDetail.FirstOrDefault().idfPerson;
                                            EmployeesUserGroupAndPermissionsGetRequestModel request = new EmployeesUserGroupAndPermissionsGetRequestModel();
                                            request.idfPerson = idfPerson;
                                            request.LangID = GetCurrentLanguage();
                                            var userGroupAndPermissionsResponse = await _employeeClient.GetEmployeeUserGroupAndPermissions(request);
                                            var active = userGroupAndPermissionsResponse.Where(a => a.idfEmployee == idfPerson).ToList();
                                            EmployeeOrganizationSaveRequestModel EmpOrgRequest = new EmployeeOrganizationSaveRequestModel();
                                            EmpOrgRequest.aspNetUserId = user.Id;
                                            aspnetuserId = user.Id;
                                            EmpOrgRequest.intRowStatus = 0;
                                            EmpOrgRequest.idfUserId = registerViewModel.idfUserID;
                                            if ((userGroupRequest.idfEmployeeGroups == "-1" && (active == null || active.Count == 0))
                                                || (active != null && active.Count > 0 && active.FirstOrDefault().Active == false)
                                                || EmployeePersonalInfoSaveRequest.idfsSite == null
                                                || EmployeePersonalInfoSaveRequest.idfsSite == 1
                                                )
                                                EmpOrgRequest.active = false;
                                            else if (active != null && active.Count > 0 && active.FirstOrDefault().Active == true)
                                                EmpOrgRequest.active = true;
                                            else if (userGroupRequest.idfEmployeeGroups != "-1" && active.Count == 0)
                                                EmpOrgRequest.active = true;

                                            var list = userGroupAndPermissionsResponse.Where(a => a.IsDefault == true).ToList();
                                            if ((userGroupAndPermissionsResponse != null && userGroupAndPermissionsResponse.Count == 0) || (list.Count > 0 && list.FirstOrDefault().idfUserID == registerViewModel.idfUserID))
                                            {
                                                EmpOrgRequest.IsDefault = true;
                                            }
                                            else
                                            {
                                                EmpOrgRequest.IsDefault = false;
                                            }
                                            EmployeeOrganizationSaveRequestResponseModel EmpOrgResponse = await _employeeClient.SaveEmployeeOrganization(EmpOrgRequest);

                                            EmployeesUserGroupAndPermissionsGetRequestModel nonUserrequest = new EmployeesUserGroupAndPermissionsGetRequestModel();
                                            nonUserrequest.idfPerson = idfPerson;
                                            request.LangID = GetCurrentLanguage();
                                            userGroupAndPermissionsResponse = await _employeeClient.GetEmployeeUserGroupAndPermissions(request);

                                            //Check User to Non User Scenario
                                            var isExist = userGroupAndPermissionsResponse.Any(a => a.UserGroupID != null);

                                            var UserGroupPermissions = await _crossCuttingClient.GetUserGroupUserSystemFunctionPermissions(EmployeeID.ToString(), GetCurrentLanguage());
                                            var isReadExist = UserGroupPermissions.Any(a => a.ReadPermission == 0);
                                            var isWriteExist = UserGroupPermissions.Any(a => a.WritePermission == 0);
                                            var isCreateExist = UserGroupPermissions.Any(a => a.CreatePermission == 0);
                                            var isDeleteExist = UserGroupPermissions.Any(a => a.DeletePermission == 0);
                                            var isAccessToGenderAndAgeExist = UserGroupPermissions.Any(a => a.AccessToGenderAndAgeDataPermission == 0);
                                            var isAccessToPersonalExist = UserGroupPermissions.Any(a => a.AccessToPersonalDataPermission == 0);
                                            var isExecuteExist = UserGroupPermissions.Any(a => a.ExecutePermission == 0);

                                            if (!isExist && !isAddEmployee && !string.IsNullOrEmpty(userName) && !UserPermissionsSaveDone && finalSubmit
                                                && (UserGroupPermissions.Count == 0 || (UserGroupPermissions.Count > 0 && !isReadExist && !isWriteExist && !isExecuteExist && !isDeleteExist && !isCreateExist && !isAccessToGenderAndAgeExist && !isAccessToPersonalExist)))
                                            {
                                                EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;
                                                EmployeePersonalInfoSaveRequest.idfPerson = EmployeeID;
                                                response = await _employeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);
                                                await ChangeUserToNonUser(EmployeeID, userName);
                                                response.RetunMessage = "ChangeUserToNonUser";
                                            }
                                        }
                                    }
                                }

                            }
                            else if (EmployeePersonalInfoSaveRequest.idfsEmployeeCategory == (long)EmployeeCategory.NonUser && IsChangeUserToNonUser && !string.IsNullOrEmpty(userName))
                            {
                                await ChangeUserToNonUser(EmployeeID, userName);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (employeeCategory == (long)EmployeeCategory.User && EmployeeID != 0)
                {
                    //delete employee
                    APIPostResponseModel deleteResponse = await _employeeClient.DeleteEmployee(EmployeeID);
                    response = new EmployeeSaveRequestResponseModel();
                    var errorObj = JObject.Parse(ex.Message);
                    if (errorObj != null && errorObj["message"].ToString() != null)
                    {
                        response.RetunMessage = errorObj["message"].ToString();

                    }
                    else
                        response.RetunMessage = ex.Message;

                    _logger.LogError(ex.Message);
                }
            }
            return Ok(response);
        }

        public async Task<EmployeeSaveRequestResponseModel> SaveNonUserEmployee(JObject jsonObject, long? idfPerson, List<RoleSystemFunctionOperation> operation, long idfUserID)
        {
            EmployeesUserGroupAndPermissionsGetRequestModel request = new EmployeesUserGroupAndPermissionsGetRequestModel();
            request.idfPerson = idfPerson;
            request.LangID = GetCurrentLanguage();

            var userName = jsonObject["Username"] != null && jsonObject["Username"].ToString() != string.Empty ? jsonObject["Username"].ToString() : "";

            EmployeeSaveRequestResponseModel response = new EmployeeSaveRequestResponseModel();
            //Check User to Non User Scenario
            List<EmployeeUserGroupsAndPermissionsViewModel> userGroupAndPermissionsResponse = await _employeeClient.GetEmployeeUserGroupAndPermissions(request);

            var isExist = userGroupAndPermissionsResponse.Any(a => a.UserGroupID != null);

            bool finalSubmit = jsonObject["finalSubmit"] != null && jsonObject["finalSubmit"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["finalSubmit"].ToString()) : false;
            bool isAddEmployee = jsonObject["isAddEmployee"] != null && jsonObject["isAddEmployee"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["isAddEmployee"].ToString()) : false;
            bool isConvert = operation.Any(a => a.intRowStatus == 0);

            if (!isExist && !isAddEmployee && !string.IsNullOrEmpty(userName) && !isConvert && !finalSubmit)
            {
                EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = CreateRequestForEmployee(jsonObject, false, true);
                EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;
                EmployeePersonalInfoSaveRequest.idfPerson = idfPerson;
                response = await _employeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);
                await ChangeUserToNonUser(idfPerson, userName);
                response.RetunMessage = "ChangeUserToNonUser";
            }
            else if (!string.IsNullOrEmpty(userName) && (isExist || isConvert))
            {
                var user = await _adminClient.GetAppUser(userName);

                if (idfUserID == 0 && isAddEmployee)
                    idfUserID = user.idfUserID;

                if (user != null && user.Id != "0")
                {
                    EmployeeOrganizationSaveRequestModel EmpOrgRequest = new EmployeeOrganizationSaveRequestModel();
                    EmpOrgRequest.aspNetUserId = user.Id;
                    var aspnetuserId = user.Id;
                    EmpOrgRequest.intRowStatus = 0;
                    EmpOrgRequest.idfUserId = idfUserID;
                    EmpOrgRequest.active = true;

                    var list = userGroupAndPermissionsResponse.Where(a => a.IsDefault == true).ToList();
                    if ((userGroupAndPermissionsResponse != null && userGroupAndPermissionsResponse.Count == 0) || (list.Count > 0 && list.FirstOrDefault().idfUserID == idfUserID))
                    {
                        EmpOrgRequest.IsDefault = true;
                    }
                    else
                    {
                        EmpOrgRequest.IsDefault = false;
                    }
                    EmployeeOrganizationSaveRequestResponseModel EmpOrgResponse = await _employeeClient.SaveEmployeeOrganization(EmpOrgRequest);
                    response.RetunMessage = "Success";
                    response.idfPerson = idfPerson;
                }
            }
            return response;
        }

        public async Task<IActionResult> ChangeUserToNonUser(long? idfPerson, string Username)
        {
            APIPostResponseModel deleteResponse = new APIPostResponseModel();

            try
            {
                var user = await _adminClient.GetAppUser(Username);
                var idfUserID = user.idfUserID;

                if (user != null && user.Id != "0")
                {
                    deleteResponse = await _employeeClient.DeleteEmployeeOrganization(user.Id, idfUserID);

                    deleteResponse = await _adminClient.RemoveEmployee(user.Id);
                }

                var resp = await _employeeClient.GetEmployeeGroupsByUser(idfUserID);
                string idfEmployeeGroups = "";
                if (resp != null && resp.Count > 0)
                {
                    foreach (var item in resp)
                    {
                        idfEmployeeGroups += item.idfEmployeeGroup + ",";
                    }
                }

                //delete user group member info
                if (idfEmployeeGroups != null && idfEmployeeGroups != "")
                    deleteResponse = await _employeeClient.DeleteEmployeeGroupMemberInfo(idfEmployeeGroups, idfPerson);
            }
            catch (Exception ex)
            {

            }
            return Ok(deleteResponse);
        }

        public async Task<IActionResult> DeleteEmployeeOrganization([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new APIPostResponseModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                long? idfPerson = 0;

                if (jsonObject["idfPerson"] != null && jsonObject["idfPerson"].ToString() != "")
                {
                    idfPerson = long.Parse(jsonObject["idfPerson"].ToString());
                }

                response = await _employeeClient.EmployeeOrganizationStatusSet(idfPerson, 1);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return Ok(response);
        }

        public async Task<bool> ValidatePersonalID(string data)
        {
            JObject jsonObject = JObject.Parse(data);
            var personalID = "";
            long personalIDType = 0;
            bool isValid = false;

            try
            {
                if (jsonObject["PersonalIDType"] != null && jsonObject["PersonalIDType"].ToString() != string.Empty)
                {
                    personalIDType = long.Parse(jsonObject["PersonalIDType"].ToString());
                }

                if (jsonObject["PersonalID"] != null)
                {
                    personalID = jsonObject["PersonalID"].ToString().Trim();
                }

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
                        long result = 0;
                        if (personalID.Length == item.Length && long.TryParse(personalID, out result))
                        {
                            isValid = true;
                        }
                    }
                    else if (item != null && item.StrFieldType == "AlphaNumeric")
                    {
                        Regex rg = new Regex(@"^[a-zA-Z0-9\s,]*$", RegexOptions.None, TimeSpan.FromMilliseconds(5));

                        if (rg.IsMatch(personalID) && personalID.Length == item.Length)
                        {
                            isValid = true;
                        }
                    }
                    else
                    {
                        isValid = true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return isValid;
        }

        public async Task<bool> UserExists(string data)
        {
            bool isUserExists = false;
            try
            {
                JObject jsonObject = JObject.Parse(data);

                if (jsonObject["username"] != null)
                {
                    var userName = jsonObject["username"].ToString();
                    isUserExists = _adminClient.UserExists(userName).Result;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return isUserExists;
        }

        public async Task<IActionResult> UpdateNewDefaultOrganization([FromBody] JsonElement data)
        {
            EmployeeOrganizationSaveRequestResponseModel response = new EmployeeOrganizationSaveRequestResponseModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                long? idfPerson = 0;
                long? idfUserId = 0;
                long? idfNewUserId = 0;

                if (jsonObject["idfPerson"] != null && jsonObject["idfPerson"].ToString() != "")
                {
                    idfPerson = long.Parse(jsonObject["idfPerson"].ToString());
                }

                EmployeesUserGroupAndPermissionsGetRequestModel request = new EmployeesUserGroupAndPermissionsGetRequestModel();

                request.idfPerson = idfPerson;
                request.LangID = GetCurrentLanguage();

                var userGroupAndPermissionsResponse = await _employeeClient.GetEmployeeUserGroupAndPermissions(request);

                if (userGroupAndPermissionsResponse != null && userGroupAndPermissionsResponse.Count > 0)
                {
                    foreach (var item in userGroupAndPermissionsResponse)
                    {
                        if (item.IsDefault.Value)
                        {
                            idfUserId = item.idfUserID;
                        }
                        else if (item.idfEmployee == idfPerson)
                        {
                            idfNewUserId = item.idfUserID;
                        }
                    }

                }
                EmployeeNewDefaultOrganizationSaveRequestModel updateRequest = new EmployeeNewDefaultOrganizationSaveRequestModel();
                updateRequest.idfUserId = idfUserId;
                updateRequest.idfNewUserID = idfNewUserId;
                response = await _employeeClient.SaveAdminNewDefaultEmployeeOrganization(updateRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return Ok(response);
        }

        public async Task<IActionResult> ActivateDeactivateOrg([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new APIPostResponseModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                long? idfPerson = 0;
                bool Active = false;

                if (jsonObject["idfPerson"] != null && jsonObject["idfPerson"].ToString() != "")
                {
                    idfPerson = long.Parse(jsonObject["idfPerson"].ToString());
                }
                if (jsonObject["Active"] != null && jsonObject["Active"].ToString() != "")
                {
                    Active = Convert.ToBoolean(jsonObject["Active"].ToString()) == true ? true : false;
                }

                response = await _employeeClient.EmployeeOrganizationActivateDeactivateSet(idfPerson, Active);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return Ok(response);
        }

        public async Task<IActionResult> EnableDisableEmployeeAccount([FromBody] JsonElement data)
        {
            ResponseViewModel response = new ResponseViewModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                DisableUserAccountParams request = new DisableUserAccountParams();
                EnableUserAccountParams requestEnable = new EnableUserAccountParams();
                bool IsDisabled = false;

                if (jsonObject["Username"] != null && jsonObject["Username"].ToString() != "")
                {
                    request.UserName = jsonObject["Username"].ToString();
                    requestEnable.UserName = jsonObject["Username"].ToString();
                }
                if (jsonObject["Reason"] != null && jsonObject["Reason"].ToString() != "")
                {
                    request.disableReason = jsonObject["Reason"].ToString();
                    requestEnable.disableReason = jsonObject["Reason"].ToString();
                }
                if (jsonObject["Disabled"] != null && jsonObject["Disabled"].ToString() != "")
                {
                    IsDisabled = Convert.ToBoolean(jsonObject["Disabled"].ToString());
                }

                if (IsDisabled)
                    response = await _adminClient.DisableUserAccount(request);
                else
                    response = await _adminClient.EnableUserAccount(requestEnable);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return Ok(response);
        }

        public async Task<IActionResult> LockUnlockEmployeeAccount([FromBody] JsonElement data)
        {
            ResponseViewModel response = new ResponseViewModel();
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                LockUserAccountParams request = new LockUserAccountParams();
                UnLockUserAccountParams requestUnlock = new UnLockUserAccountParams();
                bool isLocked = false;

                if (jsonObject["Username"] != null && jsonObject["Username"].ToString() != "")
                {
                    request.UserName = jsonObject["Username"].ToString();
                    requestUnlock.UserName = jsonObject["Username"].ToString();
                }

                if (jsonObject["Locked"] != null && jsonObject["Locked"].ToString() != "")
                {
                    isLocked = Convert.ToBoolean(jsonObject["Locked"].ToString());
                }

                if (isLocked)
                    response = await _adminClient.LockAccount(request);
                else
                    response = await _adminClient.UnLockAccount(requestUnlock);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return Ok(response);
        }

        [Route("ValidatePassword")]
        [HttpGet]
        public async Task<ActionResult> ValidatePassword(string data)
        {
            ResponseViewModel resp = new ResponseViewModel();
            try
            {
                JObject jsonObject = JObject.Parse(data);
                RegisterViewModel model = new RegisterViewModel();
                bool isUserExists = false;

                if (jsonObject["username"] != null)
                {
                    model.Username = jsonObject["username"].ToString();
                }
                if (jsonObject["password"] != null)
                {
                    model.Password = jsonObject["password"].ToString();
                }
                resp = _adminClient.ValidatePassword(model.Username, model.Password).Result;
            }
            catch (Exception ex)
            {

            }

            return Ok(resp);
        }

        [HttpPost()]
        [Route("SaveSystemFunctions")]
        public async Task<IActionResult> SaveSystemFunctions([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            var jsonArray = JArray.Parse(jsonObject["systemFunctions"].ToString());
            long roleID = 0;
            IActionResult accountmgtview = new ViewResult();
            APIPostResponseModel response = new APIPostResponseModel();
            long idfUserID = jsonObject["idfUserID"].ToString() != null && jsonObject["idfUserID"].ToString() != "" ? long.Parse(jsonObject["idfUserID"].ToString()) : 0;

            List<RoleSystemFunctionOperation> operation = new List<RoleSystemFunctionOperation>();
            if (jsonArray != null && jsonArray.Count > 0)
            {
                foreach (var item in jsonArray)
                {
                    roleID = (long)item["RoleID"];
                    RoleSystemFunctionOperation rolesandfunctions = new RoleSystemFunctionOperation();
                    //Create
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.Create;
                    if (item["CreatePermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["CreatePermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                    //Read
                    rolesandfunctions = new RoleSystemFunctionOperation();
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.Read;
                    if (item["ReadPermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["ReadPermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                    //Write
                    rolesandfunctions = new RoleSystemFunctionOperation();
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.Write;
                    if (item["WritePermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["WritePermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                    //Delete
                    rolesandfunctions = new RoleSystemFunctionOperation();
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.Delete;
                    if (item["DeletePermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["DeletePermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                    //Execute
                    rolesandfunctions = new RoleSystemFunctionOperation();
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.Execute;
                    if (item["ExecutePermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["ExecutePermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                    //AccessToGenderAndAgeData
                    rolesandfunctions = new RoleSystemFunctionOperation();
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.AccessToGenderAndAgeData;
                    if (item["AccessToGenderAndAgeDataPermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["AccessToGenderAndAgeDataPermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                    //AccessToPersonalData
                    rolesandfunctions = new RoleSystemFunctionOperation();
                    if (!string.IsNullOrEmpty(item["RoleID"].ToString()))
                        rolesandfunctions.RoleId = (long)item["RoleID"];
                    rolesandfunctions.SystemFunction = (long)item["SystemFunctionID"];
                    rolesandfunctions.Operation = (long)PermissionLevelEnum.AccessToPersonalData;
                    if (item["AccessToPersonalDataPermission"] != null)
                        rolesandfunctions.intRowStatus = Convert.ToInt32(Convert.ToBoolean(item["AccessToPersonalDataPermission"]) == true ? 0 : 1);
                    operation.Add(rolesandfunctions);
                }
                var strOperations = JsonSerializer.Serialize(operation);
                SystemFunctionsSaveRequestModel request = new SystemFunctionsSaveRequestModel();
                request.rolesandfunctions = strOperations;
                request.roleID = roleID;
                request.langageId = GetCurrentLanguage();
                request.user = _authenticatedUser.UserName;

                response = await _crossCuttingClient.SaveSystemFunctions(request);

                //Change User To Non User
                EmployeeSaveRequestResponseModel empResponse = await SaveNonUserEmployee(jsonObject, roleID, operation, idfUserID);

                response.ReturnMessage = empResponse.RetunMessage;
            }

            return Ok(response);
        }

        [HttpPost()]
        public async Task<JsonResult> DeleteEmployee([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new();

            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                if (jsonObject["EmployeeID"] != null)
                {
                    response = await _employeeClient.DeleteEmployee(long.Parse(jsonObject["EmployeeID"].ToString()));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(response.ReturnMessage);
        }
    }
}
