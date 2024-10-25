#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Organization;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components
{
    /// <summary>
    /// 
    /// </summary>
    [ViewComponent(Name = "OrganizationDetails")]
    [Area("Administration")]
    public class OrganizationDetailsController : BaseController
    {
        #region Global Variables

        private readonly IOrganizationClient _organizationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContext;
        private readonly IStringLocalizer _localizer;
        private readonly UserPermissions _organizationPermissions;

        #endregion

        #region Constructors/Invocation

        /// <summary>
        /// 
        /// </summary>
        /// <param name="organizationId"></param>
        /// <param name="showInModalIndicator"></param>
        /// <returns></returns>
        public async Task<IViewComponentResult> InvokeAsync(long? organizationId, bool showInModalIndicator)
        {
            OrganizationDetailsViewModel model = new()
            {
                OrganizationInfoSection = new OrganizationInfoSectionViewModel
                {
                    OrganizationDetails = new OrganizationGetDetailViewModel(),
                    AccessoryCodes = new Select2Configruation(),
                    LegalFormTypes = new Select2Configruation(),
                    MainFormOfActivityTypes = new Select2Configruation(),
                    OrganizationTypes = new Select2Configruation(),
                    OwnershipFormTypes = new Select2Configruation(),
                    DetailsLocationViewModel = new LocationViewModel
                    {
                        CallingObjectID = "OrganizationInfoSection_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = true,
                        ShowAdminLevel1 = true,
                        ShowAdminLevel2 = true,
                        ShowAdminLevel3 = true,
                        ShowAdminLevel4 = false,
                        ShowAdminLevel5 = false,
                        ShowAdminLevel6 = false,
                        ShowSettlement = true,
                        ShowSettlementType = true,
                        ShowStreet = true,
                        ShowBuilding = true,
                        ShowApartment = true,
                        ShowElevation = false,
                        ShowHouse = true,
                        ShowLatitude = false,
                        ShowLongitude = false,
                        ShowMap = false,
                        ShowBuildingHouseApartmentGroup = true,
                        ShowPostalCode = true,
                        ShowCoordinates = false,
                        IsDbRequiredAdminLevel1 = true,
                        IsDbRequiredAdminLevel2 = true,
                        IsDbRequiredApartment = false,
                        IsDbRequiredBuilding = false,
                        IsDbRequiredHouse = false,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        IsDbRequiredStreet = false,
                        IsDbRequiredPostalCode = false,
                        AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    }
                },
                DepartmentsSection = new DepartmentsSectionViewModel { DepartmentDetails = new DepartmentSaveRequestModel() },
                ShowInModalIndicator = showInModalIndicator
            };

            if (organizationId != null)
            {
                model.OrganizationInfoSection.OrganizationDetails = await _organizationClient.GetOrganizationDetail(GetCurrentLanguage(), (long)organizationId);
                model.OrganizationInfoSection.DetailsLocationViewModel.AdminLevel1Value = model.OrganizationInfoSection.OrganizationDetails.AdministrativeLevel1ID;
                model.OrganizationInfoSection.DetailsLocationViewModel.AdminLevel2Value = model.OrganizationInfoSection.OrganizationDetails.AdministrativeLevel2ID;
                //model.OrganizationInfoSection.DetailsLocationViewModel.AdminLevel3Value = model.OrganizationInfoSection.OrganizationDetails.AdministrativeLevel3ID;
                model.OrganizationInfoSection.DetailsLocationViewModel.AdminLevel3Value = model.OrganizationInfoSection.OrganizationDetails.SettlementID;
                model.OrganizationInfoSection.DetailsLocationViewModel.AdminLevel4Value = model.OrganizationInfoSection.OrganizationDetails.AdministrativeLevel4ID;
                model.OrganizationInfoSection.DetailsLocationViewModel.SettlementType = model.OrganizationInfoSection.OrganizationDetails.SettlementTypeID;
                model.OrganizationInfoSection.DetailsLocationViewModel.Apartment = model.OrganizationInfoSection.OrganizationDetails.Apartment;
                model.OrganizationInfoSection.DetailsLocationViewModel.Building = model.OrganizationInfoSection.OrganizationDetails.Building;
                model.OrganizationInfoSection.DetailsLocationViewModel.House = model.OrganizationInfoSection.OrganizationDetails.House;
                model.OrganizationInfoSection.DetailsLocationViewModel.Street = model.OrganizationInfoSection.OrganizationDetails.StreetID;
                model.OrganizationInfoSection.DetailsLocationViewModel.StreetText = model.OrganizationInfoSection.OrganizationDetails.StreetName;
                model.OrganizationInfoSection.DetailsLocationViewModel.PostalCode = model.OrganizationInfoSection.OrganizationDetails.PostalCodeID;
                model.OrganizationInfoSection.DetailsLocationViewModel.PostalCodeText = model.OrganizationInfoSection.OrganizationDetails.PostalCode;

                _httpContext.HttpContext?.Response.Cookies.Append("OrganizationSearchPerformedIndicator", "true");
            }

            model.DepartmentsSection.DepartmentDetails.OrganizationID = model.OrganizationInfoSection.OrganizationDetails.OrganizationKey;

            model.OrganizationInfoSection.CountryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);

            model.DepartmentsSection.OrganizationAccessRightsUserPermissions = _organizationPermissions;

            var viewData = new ViewDataDictionary<OrganizationDetailsViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="organizationClient"></param>
        /// <param name="crossCuttingClient"></param>
        /// <param name="httpContext"></param>
        /// <param name="configuration"></param>
        /// <param name="localizer"></param>
        /// <param name="tokenService"></param>
        /// <param name="logger"></param>
        public OrganizationDetailsController(IOrganizationClient organizationClient, ICrossCuttingClient crossCuttingClient, IHttpContextAccessor httpContext, IConfiguration configuration, IStringLocalizer localizer,
            ITokenService tokenService, ILogger<OrganizationDetailsController> logger) :
            base(logger, tokenService)
        {
            _organizationClient = organizationClient;
            _crossCuttingClient = crossCuttingClient;
            _configuration = configuration;
            _httpContext = httpContext;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _localizer = localizer;
            _organizationPermissions = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
        }

        #endregion

        #region Organization Info

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost()]
        [Route("SaveOrganization")]
        public async Task<JsonResult> SaveOrganization([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                OrganizationDetailsViewModel model = new()
                {
                    DeleteVisibleIndicator = false,
                    OrganizationInfoSection = new OrganizationInfoSectionViewModel
                    {
                        OrganizationDetails = new OrganizationGetDetailViewModel
                        {
                            OrganizationKey = string.IsNullOrEmpty(jsonObject["OrganizationKey"]?.ToString()) ? null : Convert.ToInt64(jsonObject["OrganizationKey"]),
                            OrganizationID = string.IsNullOrEmpty(jsonObject["OrganizationID"]?.ToString()) ? null : jsonObject["OrganizationID"].ToString(),
                            OrganizationTypeID = string.IsNullOrEmpty(jsonObject["OrganizationTypeID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["OrganizationTypeID"]),
                            AbbreviatedNameDefaultValue = jsonObject["AbbreviatedNameDefaultValue"]?.ToString(),
                            AbbreviatedNameNationalValue = jsonObject["AbbreviatedNameNationalValue"]?.ToString(),
                            FullNameDefaultValue = jsonObject["FullNameDefaultValue"]?.ToString(),
                            FullNameNationalValue = jsonObject["FullNameNationalValue"]?.ToString(),
                            AddressID = string.IsNullOrEmpty(jsonObject["AddressID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["AddressID"]),                                                        
                            CountryID = Convert.ToInt64(jsonObject["CountryID"]),                            
                            AdministrativeLevel1ID = string.IsNullOrEmpty(jsonObject["AdministrativeLevel1ID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel1ID"]),
                            AdministrativeLevel2ID = string.IsNullOrEmpty(jsonObject["AdministrativeLevel2ID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel2ID"]),
                            AdministrativeLevel3ID = string.IsNullOrEmpty(jsonObject["AdministrativeLevel3ID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel3ID"]),
                            AdministrativeLevel4ID = string.IsNullOrEmpty(jsonObject["AdministrativeLevel4ID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel4ID"]),
                            StreetName = string.IsNullOrEmpty(jsonObject["StreetName"]?.ToString()) ? null : jsonObject["StreetName"].ToString(),
                            House = string.IsNullOrEmpty(jsonObject["House"]?.ToString()) ? null : jsonObject["House"].ToString(),
                            Building = string.IsNullOrEmpty(jsonObject["Building"]?.ToString()) ? null : jsonObject["Building"].ToString(),
                            Apartment = string.IsNullOrEmpty(jsonObject["Apartment"]?.ToString()) ? null : jsonObject["Apartment"].ToString(),
                            PostalCode = string.IsNullOrEmpty(jsonObject["PostalCode"]?.ToString()) ? null : jsonObject["PostalCode"].ToString(),
                            ForeignAddressIndicator = Convert.ToBoolean(jsonObject["ForeignAddressIndicator"]?.ToString()),
                            ForeignAddressString = string.IsNullOrEmpty(jsonObject["ForeignAddressString"]?.ToString()) ? null : jsonObject["ForeignAddressString"].ToString(),
                            ContactPhone = string.IsNullOrEmpty(jsonObject["ContactPhone"]?.ToString()) ? null : jsonObject["ContactPhone"].ToString(),
                            OwnershipFormTypeID = string.IsNullOrEmpty(jsonObject["OwnershipFormTypeID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["OwnershipFormTypeID"]),
                            LegalFormTypeID = string.IsNullOrEmpty(jsonObject["LegalFormTypeID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["LegalFormTypeID"]),
                            MainFormOfActivityTypeID = string.IsNullOrEmpty(jsonObject["MainFormOfActivityTypeID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["MainFormOfActivityTypeID"]),
                            AccessoryCodeIDsString = jsonObject["AccessoryCodeIDsString"]?.ToString(),
                            Order = string.IsNullOrEmpty(jsonObject["Order"]?.ToString()) ? 0 : Convert.ToInt32(jsonObject["Order"].ToString())
                        }
                    },
                    Departments = jsonObject["Departments"].ToString()
                };

                ModelState.ClearValidationState(nameof(OrganizationGetDetailViewModel));
                if (!TryValidateModel(model.OrganizationInfoSection.OrganizationDetails, nameof(OrganizationGetDetailViewModel)))
                {
                    model.ErrorMessage = "The record is not valid.  Please verify all data and correct any errors."; 
                    return Json(model);
                }

                if (!ModelState.IsValid) return Json(model);
                OrganizationSaveRequestModel request = new() { OrganizationDetails = model.OrganizationInfoSection.OrganizationDetails, Departments = model.Departments, AuditUserName = authenticatedUser.UserName, LanguageID = GetCurrentLanguage() };
                var response = await _organizationClient.SaveOrganization(request);

                if (response.ReturnCode != null)
                {
                    switch (response.ReturnCode)
                    {
                        // Success
                        case 0:
                            if (model.OrganizationInfoSection.OrganizationDetails.OrganizationKey == null)
                            {
                                model.OrganizationInfoSection.OrganizationDetails.OrganizationKey = response.KeyId;
                                model.OrganizationInfoSection.OrganizationDetails.AddressID = response.AdditionalKeyId;
                            }
                            model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage);
                            break;
                        // Duplicate unique organization ID found
                        case 1:
                            model.ErrorMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateUniqueOrganizationIDMessage), model.OrganizationInfoSection.OrganizationDetails.OrganizationID);
                            break;
                        // Duplicate abbreviated and full name found
                        case 2:
                            model.ErrorMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateOrganizationAbbreviatedNameFullNameMessage), model.OrganizationInfoSection.OrganizationDetails.AbbreviatedNameDefaultValue, model.OrganizationInfoSection.OrganizationDetails.FullNameDefaultValue);
                            break;
                        // Duplicate department default value within the organization's departments list found
                        case 3:
                            var returnMessage = response.ReturnMessage.Split(",");
                            model.ErrorMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), returnMessage[1]);
                            break;
                        default:
                            throw new ApplicationException("Unable to save organization.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to save organization.");
                }

                model.DeleteVisibleIndicator = _organizationPermissions.Delete;

                return Json(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Departments

        /// <summary>
        /// 
        /// </summary>
        /// <param name="organizationId"></param>
        /// <returns></returns>
        public async Task<JsonResult> GetDepartmentList([FromBody] long? organizationId)
        {
            try
            {
                DepartmentGetRequestModel model = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    OrganizationID = organizationId,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "DepartmentName",
                    SortOrder = EIDSSConstants.SortConstants.Ascending
                };

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    draw = 1,
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0
                };

                List<DepartmentGetListViewModel> list = new();

                if (organizationId != null)
                    list = await _crossCuttingClient.GetDepartmentList(model);

                IEnumerable<DepartmentGetListViewModel> departmentList = list;

                if (list.Count <= 0) return Json(tableData);
                tableData.iTotalRecords = list[0].RecordCount;
                tableData.iTotalDisplayRecords = list[0].RecordCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        departmentList.ElementAt(i).DepartmentID.ToString(),
                        departmentList.ElementAt(i).DepartmentNameDefaultValue,
                        departmentList.ElementAt(i).DepartmentNameNationalValue,
                        departmentList.ElementAt(i).Order.ToString(),
                        departmentList.ElementAt(i).RowStatus.ToString(),
                        departmentList.ElementAt(i).RowAction,
                        departmentList.ElementAt(i).DepartmentID.ToString(),
                        departmentList.ElementAt(i).DepartmentID.ToString()
                    };

                    tableData.data.Add(cols);
                }

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// Deletes a department row.
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult DeleteDepartment([FromBody] JsonElement data)
        {
            try
            {
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(data);
        }

        #endregion
    }
}
