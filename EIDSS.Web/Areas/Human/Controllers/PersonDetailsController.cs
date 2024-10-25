using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.ViewModels.Person;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [ViewComponent(Name = "PersonDetails")]
    [Area("Human")]
    public class PersonDetailsController : BaseController
    {
        readonly IPersonClient _personClient;
        readonly private ICrossCuttingClient _crossCuttingClient;
        readonly private IConfigurationClient _configurationClient;
        private readonly IHumanDiseaseReportClient _humanDiseaseReportClient;
        private readonly IOutbreakClient _OutbreakClient;
        readonly IPersonalIdentificationTypeMatrixClient _personalIdentificationTypeMatrixClient;
        readonly IConfiguration _configuration;
        private readonly IStringLocalizer _localizer;
        readonly AuthenticatedUser _autenticatedUser;
        readonly UserPreferences _userPreferences;
        //private static ILogger logger;
        private readonly UserPermissions _permissionsAccessToHumanDiseaseReportData;
        private readonly UserPermissions _permissionsAccessToOutbreakHumanCaseData;
        private readonly CancellationTokenSource source;
        private readonly CancellationToken token;

        public PersonDetailsController(IPersonClient personClient,
            IConfiguration configuration,
            IConfigurationClient configurationClient,
            ICrossCuttingClient crossCuttingClient,
            IHumanDiseaseReportClient humanDiseaseReportClient,
            IOutbreakClient OutbreakClient,
            IPersonalIdentificationTypeMatrixClient personalIdentificationTypeMatrixClient,
            IStringLocalizer localizer, ITokenService tokenService,
            ILogger<PersonDetailsController> logger) :
            base(logger, tokenService)
        {
            _personClient = personClient;
            _autenticatedUser = tokenService.GetAuthenticatedUser();
            _configurationClient = configurationClient;
            _configuration = configuration;
            _userPreferences = _autenticatedUser.Preferences;
            _crossCuttingClient = crossCuttingClient;
            _humanDiseaseReportClient = humanDiseaseReportClient;
            _OutbreakClient = OutbreakClient;
            _personalIdentificationTypeMatrixClient = personalIdentificationTypeMatrixClient;
            _localizer = localizer;
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            _permissionsAccessToHumanDiseaseReportData = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            _permissionsAccessToOutbreakHumanCaseData = GetUserPermissions(PagePermission.AccessToOutbreakHumanCaseData);

            source = new();
            token = source.Token;
        }

        public async Task<IViewComponentResult> InvokeAsync(long? humanMasterID, int startIndex)
        {
            PersonDetailsViewModel model = new()
            {
                StartIndex = startIndex,
                PersonInformationSection = new()
                {
                    PersonDetails = new()
                },
                PersonAddressSection = new()
                {
                    PersonDetails = new(),
                    CurrentAddress = new()
                    {
                        CallingObjectID = "PersonAddressSection_CurrentAddress_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = false,
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
                        ShowLatitude = true,
                        ShowLongitude = true,
                        ShowMap = true,
                        ShowBuildingHouseApartmentGroup = true,
                        ShowPostalCode = true,
                        ShowCoordinates = true,
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
                    },
                    PermanentAddress = new()
                    {
                        CallingObjectID = "PersonAddressSection_PermanentAddress_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = false,
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
                        IsDbRequiredAdminLevel1 = false,
                        IsDbRequiredAdminLevel2 = false,
                        IsDbRequiredApartment = false,
                        IsDbRequiredBuilding = false,
                        IsDbRequiredHouse = false,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        IsDbRequiredStreet = false,
                        IsDbRequiredPostalCode = false,
                        AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    },
                    AlternateAddress = new()
                    {
                        CallingObjectID = "PersonAddressSection_AlternateAddress_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = false,
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
                        IsDbRequiredAdminLevel1 = false,
                        IsDbRequiredAdminLevel2 = false,
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
                PersonEmploymentSchoolSection = new()
                {
                    PersonDetails = new(),
                    WorkAddress = new()
                    {
                        CallingObjectID = "PersonEmploymentSchoolSection_WorkAddress_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = false,
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
                        IsDbRequiredAdminLevel1 = false,
                        IsDbRequiredAdminLevel2 = false,
                        IsDbRequiredApartment = false,
                        IsDbRequiredBuilding = false,
                        IsDbRequiredHouse = false,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        IsDbRequiredStreet = false,
                        IsDbRequiredPostalCode = false,
                        AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    },
                    SchoolAddress = new()
                    {
                        CallingObjectID = "PersonEmploymentSchoolSection_SchoolAddress_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = false,
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
                        IsDbRequiredAdminLevel1 = false,
                        IsDbRequiredAdminLevel2 = false,
                        IsDbRequiredApartment = false,
                        IsDbRequiredBuilding = false,
                        IsDbRequiredHouse = false,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        IsDbRequiredStreet = false,
                        IsDbRequiredPostalCode = false,
                        AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    },
                    DiseaseReports = new(),
                    OutbreakCaseReports = new()
                }
            };

            model.HumanMasterID = humanMasterID;
            model.PersonInformationSection.PermissionsAccessToHumanDiseaseReportData = _permissionsAccessToHumanDiseaseReportData;
            model.PersonInformationSection.PersonIDVisibleIndicator = false;
            model.PersonInformationSection.PersonalIDRequiredIndicator = false;
            model.PersonInformationSection.FindInPINSystemInVisibledicator = false;
            model.PersonEmploymentSchoolSection.ReportsVisibleIndicator = false;

            model.PersonEmploymentSchoolSection.DiseaseReports.PermissionsAccessToHumanDiseaseReportData = _permissionsAccessToHumanDiseaseReportData;
            model.PersonEmploymentSchoolSection.OutbreakCaseReports.PermissionsAccessToOutbreakHumanCaseData = _permissionsAccessToOutbreakHumanCaseData;

            if (humanMasterID != null)
            {
                HumanPersonDetailsRequestModel request = new HumanPersonDetailsRequestModel();
                request.LangID = "en-US";
                request.HumanMasterID = humanMasterID;
                var response = await _personClient.GetHumanDiseaseReportPersonInfoAsync(request);
                if (response != null && response.Count > 0)
                {
                    var personInfo = response.FirstOrDefault();

                    //Current Address
                    model.PersonAddressSection.CurrentAddress.AdminLevel1Text = personInfo.HumanRegion;
                    model.PersonAddressSection.CurrentAddress.AdminLevel1Value = personInfo.HumanidfsRegion;
                    model.PersonAddressSection.CurrentAddress.AdminLevel2Text = personInfo.HumanRayon;
                    model.PersonAddressSection.CurrentAddress.AdminLevel2Value = personInfo.HumanidfsRayon;
                    model.PersonAddressSection.CurrentAddress.SettlementType = personInfo.HumanidfsSettlementType;
                    model.PersonAddressSection.CurrentAddress.SettlementId = personInfo.HumanidfsSettlement;
                    model.PersonAddressSection.CurrentAddress.PostalCodeText = personInfo.HumanstrPostalCode;
                    model.PersonAddressSection.CurrentAddress.Latitude = personInfo.HumanstrLatitude;
                    model.PersonAddressSection.CurrentAddress.Longitude = personInfo.HumanstrLongitude;
                    model.PersonAddressSection.CurrentAddress.StreetText = personInfo.HumanstrStreetName;
                    model.PersonAddressSection.CurrentAddress.House = personInfo.HumanstrHouse;
                    model.PersonAddressSection.CurrentAddress.Building = personInfo.HumanstrBuilding;
                    model.PersonAddressSection.CurrentAddress.Apartment = personInfo.HumanstrApartment;

                    //Permanent Address
                    model.PersonAddressSection.PermanentAddress.AdminLevel1Text = personInfo.HumanPermRegion;
                    model.PersonAddressSection.PermanentAddress.AdminLevel1Value = personInfo.HumanPermidfsRegion;
                    model.PersonAddressSection.PermanentAddress.AdminLevel2Text = personInfo.HumanPermRayon;
                    model.PersonAddressSection.PermanentAddress.AdminLevel2Value = personInfo.HumanPermidfsRayon;
                    model.PersonAddressSection.PermanentAddress.SettlementType = personInfo.HumanPermidfsSettlementType;
                    model.PersonAddressSection.PermanentAddress.SettlementId = personInfo.HumanPermidfsSettlement;
                    model.PersonAddressSection.PermanentAddress.PostalCodeText = personInfo.HumanPermstrPostalCode;
                    model.PersonAddressSection.PermanentAddress.StreetText = personInfo.HumanPermstrStreetName;
                    model.PersonAddressSection.PermanentAddress.House = personInfo.HumanPermstrHouse;
                    model.PersonAddressSection.PermanentAddress.Building = personInfo.HumanPermstrBuilding;
                    model.PersonAddressSection.PermanentAddress.Apartment = personInfo.HumanPermstrApartment;

                    //Alternate Address
                    model.PersonAddressSection.AlternateAddress.AdminLevel1Text = personInfo.HumanAltRegion;
                    model.PersonAddressSection.AlternateAddress.AdminLevel1Value = personInfo.HumanAltidfsRegion;
                    model.PersonAddressSection.AlternateAddress.AdminLevel2Text = personInfo.HumanAltRayon;
                    model.PersonAddressSection.AlternateAddress.AdminLevel2Value = personInfo.HumanAltidfsRayon;
                    model.PersonAddressSection.AlternateAddress.SettlementType = personInfo.HumanAltidfsSettlementType;
                    model.PersonAddressSection.AlternateAddress.SettlementId = personInfo.HumanAltidfsSettlement;
                    model.PersonAddressSection.AlternateAddress.PostalCodeText = personInfo.HumanAltstrPostalCode;
                    model.PersonAddressSection.AlternateAddress.StreetText = personInfo.HumanAltstrStreetName;
                    model.PersonAddressSection.AlternateAddress.House = personInfo.HumanAltstrHouse;
                    model.PersonAddressSection.AlternateAddress.Building = personInfo.HumanAltstrBuilding;
                    model.PersonAddressSection.AlternateAddress.Apartment = personInfo.HumanAltstrApartment;

                    //Work Address
                    model.PersonEmploymentSchoolSection.WorkAddress.AdminLevel1Text = personInfo.EmployerRegion;
                    model.PersonEmploymentSchoolSection.WorkAddress.AdminLevel1Value = personInfo.EmployeridfsRegion;
                    model.PersonEmploymentSchoolSection.WorkAddress.AdminLevel2Text = personInfo.EmployerRayon;
                    model.PersonEmploymentSchoolSection.WorkAddress.AdminLevel2Value = personInfo.EmployeridfsRayon;
                    model.PersonEmploymentSchoolSection.WorkAddress.SettlementType = personInfo.EmployeridfsSettlementType;
                    model.PersonEmploymentSchoolSection.WorkAddress.SettlementId = personInfo.EmployeridfsSettlement;
                    model.PersonEmploymentSchoolSection.WorkAddress.PostalCodeText = personInfo.EmployerstrPostalCode;
                    model.PersonEmploymentSchoolSection.WorkAddress.StreetText = personInfo.EmployerstrStreetName;
                    model.PersonEmploymentSchoolSection.WorkAddress.House = personInfo.EmployerstrHouse;
                    model.PersonEmploymentSchoolSection.WorkAddress.Building = personInfo.EmployerstrBuilding;
                    model.PersonEmploymentSchoolSection.WorkAddress.Apartment = personInfo.EmployerstrApartment;

                    //School Address
                    model.PersonEmploymentSchoolSection.SchoolAddress.AdminLevel1Text = personInfo.SchoolRegion;
                    model.PersonEmploymentSchoolSection.SchoolAddress.AdminLevel1Value = personInfo.SchoolidfsRegion;
                    model.PersonEmploymentSchoolSection.SchoolAddress.AdminLevel2Text = personInfo.SchoolRayon;
                    model.PersonEmploymentSchoolSection.SchoolAddress.AdminLevel2Value = personInfo.SchoolidfsRayon;
                    model.PersonEmploymentSchoolSection.SchoolAddress.SettlementId = personInfo.SchoolidfsSettlement;
                    model.PersonEmploymentSchoolSection.SchoolAddress.PostalCodeText = personInfo.SchoolstrPostalCode;
                    model.PersonEmploymentSchoolSection.SchoolAddress.StreetText = personInfo.SchoolstrStreetName;
                    model.PersonEmploymentSchoolSection.SchoolAddress.House = personInfo.SchoolstrHouse;
                    model.PersonEmploymentSchoolSection.SchoolAddress.Building = personInfo.SchoolstrBuilding;
                    model.PersonEmploymentSchoolSection.SchoolAddress.Apartment = personInfo.SchoolstrApartment;

                    if (model.PersonInformationSection != null
                        && model.PersonInformationSection.PermissionsAccessToHumanDiseaseReportData != null)
                    {
                        if (!model.PersonInformationSection.PermissionsAccessToHumanDiseaseReportData.AccessToPersonalData)
                        {
                            personInfo.PersonalID = "********";
                            personInfo.FirstOrGivenName = "********";
                            personInfo.SecondName = "********";
                            personInfo.LastOrSurname = "********";
                        }
                        if (!model.PersonInformationSection.PermissionsAccessToHumanDiseaseReportData.AccessToGenderAndAgeData)
                        {
                            personInfo.GenderTypeName = "********";
                            personInfo.GenderTypeID = 0;
                        }
                    }

                    model.PersonInformationSection.PersonDetails = personInfo;
                    model.PersonInformationSection.PersonDetails.HumanActualId = humanMasterID;
                    model.PersonAddressSection.PersonDetails = personInfo;
                    model.PersonEmploymentSchoolSection.PersonDetails = personInfo;
                    model.PersonEmploymentSchoolSection.OutbreakCaseReports.HumanMasterID = (long)humanMasterID;
                }

                model.PersonInformationSection.PersonIDVisibleIndicator = true;
                model.PersonEmploymentSchoolSection.ReportsVisibleIndicator = true;
                if (model.PersonInformationSection.PersonDetails.PersonalIDType != null && model.PersonInformationSection.PersonDetails.PersonalIDTypeName != "Unknown")
                {
                    model.PersonInformationSection.PersonalIDRequiredIndicator = true;
                }
                if (model.PersonInformationSection.PersonDetails.PersonalID != null)
                {
                    model.PersonInformationSection.FindInPINSystemInVisibledicator = true;
                }
            }

            BaseReferenceViewModel item = new BaseReferenceViewModel();
            item.StrDefault = "";
            item.IdfsBaseReference = -1;

            model.PersonInformationSection.PersonalIDTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.PersonalIDType, null);
            model.PersonInformationSection.PersonalIDTypeList.Insert(0, item);

            model.PersonInformationSection.HumanGenderList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.HumanGender, HACodeList.HumanHACode);
            model.PersonInformationSection.HumanGenderList.Insert(0, item);

            model.PersonInformationSection.HumanAgeTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.HumanAgeType, HACodeList.HumanHACode);
            model.PersonInformationSection.HumanAgeTypeList.Insert(0, item);

            model.PersonInformationSection.CitizenshipList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.NationalityList, null);
            model.PersonInformationSection.CitizenshipList.Insert(0, item);

            model.PersonAddressSection.PhoneTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ContactPhoneType, HACodeList.HumanHACode);
            model.PersonAddressSection.PhoneTypeList.Insert(0, item);

            model.PersonAddressSection.Phone2TypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ContactPhoneType, HACodeList.HumanHACode);
            model.PersonAddressSection.Phone2TypeList.Insert(0, item);

            model.PersonEmploymentSchoolSection.OccupationTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OccupationType, HACodeList.HumanHACode);
            model.PersonEmploymentSchoolSection.OccupationTypeList.Insert(0, item);

            CountryModel item2 = new CountryModel();
            item2.idfsCountry = -1;
            item2.strCountryName = "";
            model.PersonAddressSection.HumanCountryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
            model.PersonAddressSection.HumanCountryList.Insert(0, item2);
            model.PersonEmploymentSchoolSection.WorkCountryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
            model.PersonEmploymentSchoolSection.WorkCountryList.Insert(0, item2);
            model.PersonEmploymentSchoolSection.SchoolCountryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
            model.PersonEmploymentSchoolSection.SchoolCountryList.Insert(0, item2);

            var viewData = new ViewDataDictionary<PersonDetailsViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }

        [HttpPost()]
        [Route("CopyCurrentAddressToPermanentAddress")]
        public IActionResult CopyCurrentAddressToPermanentAddress([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                var model = new LocationViewModel()
                {
                    CallingObjectID = "PersonAddressSection_PermanentAddress",
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = true,
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = false,
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
                    IsDbRequiredAdminLevel1 = false,
                    IsDbRequiredAdminLevel2 = false,
                    IsDbRequiredApartment = false,
                    IsDbRequiredBuilding = false,
                    IsDbRequiredHouse = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    IsDbRequiredStreet = false,
                    IsDbRequiredPostalCode = false,
                    AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                };

                model.AdminLevel0Value = jsonObject["HumanidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsCountry"]));
                model.AdminLevel1Value = jsonObject["HumanidfsRegion"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsRegion"]));
                model.AdminLevel2Value = jsonObject["HumanidfsRayon"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsRayon"]));
                model.SettlementType = jsonObject["HumanidfsSettlementType"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsSettlementType"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsSettlementType"]));
                model.Settlement = jsonObject["HumanidfsSettlement"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsSettlement"]));
                model.PostalCodeText = jsonObject["HumanidfsPostalCode"].ToString();
                model.StreetText = jsonObject["HumanstrStreetName"].ToString();
                model.House = jsonObject["HumanstrHouse"].ToString();
                model.Building = jsonObject["HumanstrBuilding"].ToString();
                model.Apartment = jsonObject["HumanstrApartment"].ToString();

                ViewData.TemplateInfo.HtmlFieldPrefix = model.CallingObjectID;

                return PartialView("_PersonLocationPartial", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost()]
        [Route("CopyCurrentAddressToWorkAddress")]
        public IActionResult CopyCurrentAddressToWorkAddress([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());

            var WorkAddressLocationViewModel = new LocationViewModel()
            {
                CallingObjectID = "PersonEmploymentSchoolSection_WorkAddress",
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                ShowAdminLevel0 = false,
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
                IsDbRequiredAdminLevel1 = false,
                IsDbRequiredAdminLevel2 = false,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
            };

            WorkAddressLocationViewModel.AdminLevel0Value = jsonObject["HumanidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsCountry"]));

            WorkAddressLocationViewModel.AdminLevel1Value = jsonObject["HumanidfsRegion"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsRegion"]));
            WorkAddressLocationViewModel.AdminLevel2Value = jsonObject["HumanidfsRayon"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsRayon"]));
            WorkAddressLocationViewModel.SettlementType = jsonObject["HumanidfsSettlementType"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsSettlementType"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsSettlementType"]));

            WorkAddressLocationViewModel.Settlement = jsonObject["HumanidfsSettlement"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsSettlement"]));

            WorkAddressLocationViewModel.PostalCodeText = jsonObject["HumanidfsPostalCode"].ToString();

            WorkAddressLocationViewModel.StreetText = jsonObject["HumanstrStreetName"].ToString();
            WorkAddressLocationViewModel.House = jsonObject["HumanstrHouse"].ToString();
            WorkAddressLocationViewModel.Building = jsonObject["HumanstrBuilding"].ToString();
            WorkAddressLocationViewModel.Apartment = jsonObject["HumanstrApartment"].ToString();

            ViewData.TemplateInfo.HtmlFieldPrefix = WorkAddressLocationViewModel.CallingObjectID;

            return PartialView("_PersonLocationPartial", WorkAddressLocationViewModel);
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
                    personalID = jsonObject["PersonalID"].ToString();
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
                        var result = 0;
                        if (personalID.Length == item.Length && Int32.TryParse(personalID, out result))
                        {
                            isValid = true;
                        }
                    }
                    else if (item != null && item.StrFieldType == "AlphaNumeric")
                    {
                        if (personalID.Length == item.Length)
                        {
                            Regex rg = new Regex(@"^[a-zA-Z0-9\s,]*$");
                            isValid = rg.IsMatch(personalID);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return isValid;
        }

        [HttpPost()]
        [Route("SavePerson")]
        public async Task<JsonResult> SavePerson([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString());

                PersonDetailsViewModel model = new();
                model.PersonInformationSection = new();
                model.PersonInformationSection.PersonDetails = new();
                model.PersonAddressSection = new();
                model.PersonEmploymentSchoolSection = new();
                model.HumanMasterID = string.IsNullOrEmpty(jsonObject["HumanMasterID"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanMasterID"]);
                model.PersonInformationSection.PersonDetails.HumanActualId = model.HumanMasterID;

                model.PersonInformationSection.PersonDetails.PersonalIDType = jsonObject["PersonalIDType"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["PersonalIDType"]);
                model.PersonInformationSection.PersonDetails.EIDSSPersonID = jsonObject["EIDSSPersonID"]?.ToString();
                model.PersonInformationSection.PersonDetails.PersonalID = jsonObject["PersonalID"].ToString();
                model.PersonInformationSection.PersonDetails.FirstOrGivenName = jsonObject["FirstOrGivenName"].ToString();
                model.PersonInformationSection.PersonDetails.SecondName = jsonObject["SecondName"].ToString();
                model.PersonInformationSection.PersonDetails.LastOrSurname = jsonObject["LastOrSurname"].ToString();
                model.PersonInformationSection.PersonDetails.DateOfBirth = jsonObject["DateOfBirth"] != null ? Convert.ToDateTime(jsonObject["DateOfBirth"]) : null;
                model.PersonInformationSection.PersonDetails.DateOfDeath = jsonObject["DateOfDeath"] != null ? Convert.ToDateTime(jsonObject["DateOfDeath"]) : null;
                model.PersonInformationSection.PersonDetails.ReportedAge = string.IsNullOrEmpty(jsonObject["ReportedAge"].ToString()) ? null : Convert.ToInt32(jsonObject["ReportedAge"]);
                model.PersonInformationSection.PersonDetails.ReportedAgeUOMID = jsonObject["ReportedAgeUOMID"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["ReportedAgeUOMID"]);
                model.PersonInformationSection.PersonDetails.GenderTypeID = jsonObject["GenderTypeID"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["GenderTypeID"]);
                model.PersonInformationSection.PersonDetails.CitizenshipTypeID = jsonObject["CitizenshipTypeID"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["CitizenshipTypeID"]);
                model.PersonInformationSection.PersonDetails.PassportNumber = jsonObject["PassportNumber"].ToString();

                model.PersonInformationSection.PersonDetails.HumanGeoLocationID = jsonObject["HumanGeoLocationID"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanGeoLocationID"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanGeoLocationID"]));
                model.PersonInformationSection.PersonDetails.HumanidfsCountry = jsonObject["HumanidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsCountry"]));
                model.PersonInformationSection.PersonDetails.HumanidfsRegion = jsonObject["HumanidfsRegion"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsRegion"]));
                model.PersonInformationSection.PersonDetails.HumanidfsRayon = jsonObject["HumanidfsRayon"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsRayon"]));
                model.PersonInformationSection.PersonDetails.HumanidfsSettlement = jsonObject["HumanidfsSettlement"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanidfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanidfsSettlement"]));
                model.PersonInformationSection.PersonDetails.HumanstrStreetName = jsonObject["HumanstrStreetName"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanstrApartment = jsonObject["HumanstrApartment"].ToString();
                model.PersonInformationSection.PersonDetails.HumanstrBuilding = jsonObject["HumanstrBuilding"].ToString();
                model.PersonInformationSection.PersonDetails.HumanstrHouse = jsonObject["HumanstrHouse"].ToString();
                model.PersonInformationSection.PersonDetails.HumanstrPostalCode = jsonObject["HumanidfsPostalCode"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanstrLatitude = string.IsNullOrEmpty(jsonObject["HumanstrLatitude"].ToString()) ? null : Convert.ToDouble(jsonObject["HumanstrLatitude"]);
                model.PersonInformationSection.PersonDetails.HumanstrLongitude = string.IsNullOrEmpty(jsonObject["HumanstrLongitude"].ToString()) ? null : Convert.ToDouble(jsonObject["HumanstrLongitude"]);

                model.PersonInformationSection.PersonDetails.HumanPermGeoLocationID = jsonObject["HumanPermGeoLocationID"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanPermGeoLocationID"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanPermGeoLocationID"]));
                model.PersonInformationSection.PersonDetails.HumanPermidfsCountry = jsonObject["HumanPermidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanPermidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanPermidfsCountry"]));
                model.PersonInformationSection.PersonDetails.HumanPermidfsRegion = jsonObject["HumanPermidfsRegion"] == null ? null : string.IsNullOrEmpty(jsonObject["HumanPermidfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanPermidfsRegion"]);
                model.PersonInformationSection.PersonDetails.HumanPermidfsRayon = jsonObject["HumanPermidfsRayon"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanPermidfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanPermidfsRayon"]));
                model.PersonInformationSection.PersonDetails.HumanPermidfsSettlement = jsonObject["HumanPermidfsSettlement"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanPermidfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanPermidfsSettlement"]));
                model.PersonInformationSection.PersonDetails.HumanPermstrStreetName = jsonObject["HumanPermstrStreetName"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanPermstrApartment = jsonObject["HumanPermstrApartment"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanPermstrBuilding = jsonObject["HumanPermstrBuilding"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanPermstrHouse = jsonObject["HumanPermstrHouse"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanPermstrPostalCode = jsonObject["HumanPermidfsPostalCode"]?.ToString();

                model.PersonInformationSection.PersonDetails.HumanAltGeoLocationID = jsonObject["HumanAltGeoLocationID"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanAltGeoLocationID"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanAltGeoLocationID"]));
                model.PersonInformationSection.PersonDetails.HumanAltForeignAddressIndicator = Convert.ToBoolean(jsonObject["HumanAltForeignAddressIndicator"].ToString());
                model.PersonAddressSection.HumanAltForeignidfsCountry = jsonObject["HumanAltForeignidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanAltForeignidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanAltForeignidfsCountry"]));
                model.PersonInformationSection.PersonDetails.HumanAltForeignAddressString = jsonObject["HumanAltForeignAddressString"].ToString();
                model.PersonInformationSection.PersonDetails.HumanAltidfsCountry = jsonObject["HumanAltidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanAltidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanAltidfsCountry"]));
                model.PersonInformationSection.PersonDetails.HumanAltidfsRegion = jsonObject["HumanAltidfsRegion"] == null ? null : string.IsNullOrEmpty(jsonObject["HumanAltidfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanAltidfsRegion"]);
                model.PersonInformationSection.PersonDetails.HumanAltidfsRayon = jsonObject["HumanAltidfsRayon"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanAltidfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanAltidfsRayon"]));
                model.PersonInformationSection.PersonDetails.HumanAltidfsSettlement = jsonObject["HumanAltidfsSettlement"] == null ? null : (string.IsNullOrEmpty(jsonObject["HumanAltidfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["HumanAltidfsSettlement"]));
                model.PersonInformationSection.PersonDetails.HumanAltstrStreetName = jsonObject["HumanAltstrStreetName"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanAltstrApartment = jsonObject["HumanAltstrApartment"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanAltstrBuilding = jsonObject["HumanAltstrBuilding"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanAltstrHouse = jsonObject["HumanAltstrHouse"]?.ToString();
                model.PersonInformationSection.PersonDetails.HumanAltstrPostalCode = jsonObject["HumanAltidfsPostalCode"]?.ToString();
                model.PersonInformationSection.PersonDetails.HomePhone = jsonObject["HomePhone"].ToString();
                model.PersonInformationSection.PersonDetails.WorkPhone = jsonObject["WorkPhone"].ToString();

                model.PersonInformationSection.PersonDetails.ContactPhoneCountryCode = jsonObject["ContactPhoneCountryCode"] == null ? null : string.IsNullOrEmpty(jsonObject["ContactPhoneCountryCode"].ToString()) ? null : Convert.ToInt32(jsonObject["ContactPhoneCountryCode"]);
                model.PersonInformationSection.PersonDetails.ContactPhone = jsonObject["ContactPhone"] == null ? null : (string.IsNullOrEmpty(jsonObject["ContactPhone"].ToString()) ? null : jsonObject["ContactPhone"].ToString());
                model.PersonInformationSection.PersonDetails.ContactPhoneTypeID = jsonObject["ContactPhoneTypeID"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["ContactPhoneTypeID"]);
                model.PersonInformationSection.PersonDetails.ContactPhone2CountryCode = jsonObject["ContactPhone2CountryCode"] == null ? null : string.IsNullOrEmpty(jsonObject["ContactPhone2CountryCode"].ToString()) ? null : Convert.ToInt32(jsonObject["PersonDetails_ContactPhone2CountryCode"]);
                model.PersonInformationSection.PersonDetails.ContactPhone2 = jsonObject["ContactPhone2"] == null ? null : (string.IsNullOrEmpty(jsonObject["ContactPhone2"].ToString()) ? null : jsonObject["ContactPhone2"].ToString());
                model.PersonInformationSection.PersonDetails.ContactPhone2TypeID = jsonObject["ContactPhone2TypeID"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["ContactPhone2TypeID"]);

                model.PersonInformationSection.PersonDetails.IsEmployedTypeID = string.IsNullOrEmpty(jsonObject["IsEmployedTypeID"].ToString()) ? null : Convert.ToInt64(jsonObject["IsEmployedTypeID"]);
                model.PersonInformationSection.PersonDetails.OccupationTypeID = jsonObject["OccupationTypeID"].ToString() == "-1" ? null : Convert.ToInt64(jsonObject["OccupationTypeID"]);
                model.PersonInformationSection.PersonDetails.EmployerName = jsonObject["EmployerName"].ToString();
                model.PersonInformationSection.PersonDetails.EmployedDateLastPresent = string.IsNullOrEmpty(jsonObject["EmployedDateLastPresent"].ToString()) ? null : Convert.ToDateTime(jsonObject["EmployedDateLastPresent"]);
                model.PersonInformationSection.PersonDetails.EmployerForeignAddressIndicator = Convert.ToBoolean(jsonObject["EmployerForeignAddressIndicator"].ToString());
                model.PersonEmploymentSchoolSection.EmployerForeignidfsCountry = jsonObject["EmployerForeignidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["EmployerForeignidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["EmployerForeignidfsCountry"]));
                model.PersonInformationSection.PersonDetails.EmployerForeignAddressString = jsonObject["EmployerForeignAddressString"].ToString();
                model.PersonInformationSection.PersonDetails.EmployerGeoLocationID = jsonObject["EmployerGeoLocationID"] == null ? null : (string.IsNullOrEmpty(jsonObject["EmployerGeoLocationID"].ToString()) ? null : Convert.ToInt64(jsonObject["EmployerGeoLocationID"]));
                model.PersonInformationSection.PersonDetails.EmployeridfsCountry = jsonObject["EmployeridfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["EmployeridfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["EmployeridfsCountry"]));
                model.PersonInformationSection.PersonDetails.EmployeridfsRegion = jsonObject["EmployeridfsRegion"] == null ? null : (string.IsNullOrEmpty(jsonObject["EmployeridfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["EmployeridfsRegion"]));
                model.PersonInformationSection.PersonDetails.EmployeridfsRayon = jsonObject["EmployeridfsRayon"] == null ? null : (string.IsNullOrEmpty(jsonObject["EmployeridfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["EmployeridfsRayon"]));
                model.PersonInformationSection.PersonDetails.EmployeridfsSettlement = jsonObject["EmployeridfsSettlement"] == null ? null : (string.IsNullOrEmpty(jsonObject["EmployeridfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["EmployeridfsSettlement"]));
                model.PersonInformationSection.PersonDetails.EmployerstrStreetName = jsonObject["EmployerstrStreetName"]?.ToString();
                model.PersonInformationSection.PersonDetails.EmployerstrApartment = jsonObject["EmployerstrApartment"]?.ToString();
                model.PersonInformationSection.PersonDetails.EmployerstrBuilding = jsonObject["EmployerstrBuilding"]?.ToString();
                model.PersonInformationSection.PersonDetails.EmployerstrHouse = jsonObject["EmployerstrHouse"]?.ToString();
                model.PersonInformationSection.PersonDetails.EmployerstrPostalCode = jsonObject["EmployeridfsPostalCode"]?.ToString();
                model.PersonInformationSection.PersonDetails.EmployerPhone = jsonObject["EmployerPhone"].ToString();

                model.PersonInformationSection.PersonDetails.IsStudentTypeID = string.IsNullOrEmpty(jsonObject["IsStudentTypeID"].ToString()) ? null : Convert.ToInt64(jsonObject["IsStudentTypeID"]);
                model.PersonInformationSection.PersonDetails.SchoolName = jsonObject["SchoolName"].ToString();
                model.PersonInformationSection.PersonDetails.SchoolDateLastAttended = string.IsNullOrEmpty(jsonObject["SchoolDateLastAttended"].ToString()) ? null : Convert.ToDateTime(jsonObject["SchoolDateLastAttended"]);
                model.PersonInformationSection.PersonDetails.SchoolForeignAddressIndicator = Convert.ToBoolean(jsonObject["SchoolForeignAddressIndicator"]);
                model.PersonEmploymentSchoolSection.SchoolForeignidfsCountry = jsonObject["SchoolForeignidfsCountry"] == null ? null : (string.IsNullOrEmpty(jsonObject["SchoolForeignidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["SchoolForeignidfsCountry"]));
                model.PersonInformationSection.PersonDetails.SchoolForeignAddressString = jsonObject["SchoolForeignAddressString"].ToString();
                model.PersonInformationSection.PersonDetails.SchoolGeoLocationID = jsonObject["SchoolGeoLocationID"] == null ? null : (string.IsNullOrEmpty(jsonObject["SchoolGeoLocationID"].ToString()) ? null : Convert.ToInt64(jsonObject["SchoolGeoLocationID"]));
                model.PersonInformationSection.PersonDetails.SchoolidfsCountry = jsonObject["SchoolidfsCountry"] == null ? null : string.IsNullOrEmpty(jsonObject["SchoolidfsCountry"].ToString()) ? null : Convert.ToInt64(jsonObject["SchoolidfsCountry"]);
                model.PersonInformationSection.PersonDetails.SchoolidfsRegion = jsonObject["SchoolidfsRegion"] == null ? null : string.IsNullOrEmpty(jsonObject["SchoolidfsRegion"].ToString()) ? null : Convert.ToInt64(jsonObject["SchoolidfsRegion"]);
                model.PersonInformationSection.PersonDetails.SchoolidfsRayon = jsonObject["SchoolidfsRayon"] == null ? null : string.IsNullOrEmpty(jsonObject["SchoolidfsRayon"].ToString()) ? null : Convert.ToInt64(jsonObject["SchoolidfsRayon"]);
                model.PersonInformationSection.PersonDetails.SchoolidfsSettlement = jsonObject["SchoolidfsSettlement"] == null ? null : string.IsNullOrEmpty(jsonObject["SchoolidfsSettlement"].ToString()) ? null : Convert.ToInt64(jsonObject["SchoolidfsSettlement"]);
                model.PersonInformationSection.PersonDetails.SchoolstrStreetName = jsonObject["SchoolstrStreetName"]?.ToString();
                model.PersonInformationSection.PersonDetails.SchoolstrApartment = jsonObject["SchoolstrApartment"]?.ToString();
                model.PersonInformationSection.PersonDetails.SchoolstrBuilding = jsonObject["SchoolstrBuilding"]?.ToString();
                model.PersonInformationSection.PersonDetails.SchoolstrHouse = jsonObject["SchoolstrHouse"]?.ToString();
                model.PersonInformationSection.PersonDetails.SchoolstrPostalCode = jsonObject["SchoolidfsPostalCode"]?.ToString();
                model.PersonInformationSection.PersonDetails.SchoolPhone = jsonObject["SchoolPhone"].ToString();

                string duplicateRecordsFound = await ValidatePersonAsync(model.PersonInformationSection.PersonDetails);
                if (duplicateRecordsFound != string.Empty)
                {
                    string duplicateMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.HumanActiveSurveillanceCampaignDuplicateRecordFoundDoYouWantToContinueSavingTheCurrentRecordMessage), duplicateRecordsFound);

                    model.InformationalMessage = duplicateMessage;
                }
                else
                {
                    PersonSaveRequestModel request = new();
                    request.HumanMasterID = model.HumanMasterID;
                    request.CopyToHumanIndicator = false;
                    request.PersonalIDType = model.PersonInformationSection.PersonDetails.PersonalIDType;
                    request.EIDSSPersonID = model.PersonInformationSection.PersonDetails.EIDSSPersonID;
                    request.PersonalID = model.PersonInformationSection.PersonDetails.PersonalID;
                    request.FirstName = model.PersonInformationSection.PersonDetails.FirstOrGivenName;
                    request.SecondName = model.PersonInformationSection.PersonDetails.SecondName;
                    request.LastName = model.PersonInformationSection.PersonDetails.LastOrSurname;
                    request.DateOfBirth = model.PersonInformationSection.PersonDetails.DateOfBirth;
                    request.DateOfDeath = model.PersonInformationSection.PersonDetails.DateOfDeath;
                    request.HumanGenderTypeID = model.PersonInformationSection.PersonDetails.GenderTypeID;
                    request.CitizenshipTypeID = model.PersonInformationSection.PersonDetails.CitizenshipTypeID;
                    request.PassportNumber = model.PersonInformationSection.PersonDetails.PassportNumber;

                    request.HumanGeoLocationID = model.PersonInformationSection.PersonDetails.HumanGeoLocationID;
                    request.HumanidfsLocation = GetLowestLocationID(model.PersonInformationSection.PersonDetails.HumanidfsCountry, model.PersonInformationSection.PersonDetails.HumanidfsRegion, model.PersonInformationSection.PersonDetails.HumanidfsRayon, model.PersonInformationSection.PersonDetails.HumanidfsSettlement);
                    request.HumanstrStreetName = model.PersonInformationSection.PersonDetails.HumanstrStreetName;
                    request.HumanstrApartment = model.PersonInformationSection.PersonDetails.HumanstrApartment;
                    request.HumanstrBuilding = model.PersonInformationSection.PersonDetails.HumanstrBuilding;
                    request.HumanstrHouse = model.PersonInformationSection.PersonDetails.HumanstrHouse;
                    request.HumanidfsPostalCode = model.PersonInformationSection.PersonDetails.HumanstrPostalCode;
                    request.HumanstrLatitude = model.PersonInformationSection.PersonDetails.HumanstrLatitude;
                    request.HumanstrLongitude = model.PersonInformationSection.PersonDetails.HumanstrLongitude;
                    request.HumanPermGeoLocationID = model.PersonInformationSection.PersonDetails.HumanPermGeoLocationID;
                    request.HumanPermidfsLocation = GetLowestLocationID(model.PersonInformationSection.PersonDetails.HumanPermidfsCountry, model.PersonInformationSection.PersonDetails.HumanPermidfsRegion, model.PersonInformationSection.PersonDetails.HumanPermidfsRayon, model.PersonInformationSection.PersonDetails.HumanPermidfsSettlement);
                    request.HumanPermstrStreetName = model.PersonInformationSection.PersonDetails.HumanPermstrStreetName;
                    request.HumanPermstrApartment = model.PersonInformationSection.PersonDetails.HumanPermstrApartment;
                    request.HumanPermstrBuilding = model.PersonInformationSection.PersonDetails.HumanPermstrBuilding;
                    request.HumanPermstrHouse = model.PersonInformationSection.PersonDetails.HumanPermstrHouse;
                    request.HumanPermidfsPostalCode = model.PersonInformationSection.PersonDetails.HumanPermstrPostalCode;

                    request.HumanAltGeoLocationID = model.PersonInformationSection.PersonDetails.HumanAltGeoLocationID;
                    request.HumanAltForeignAddressIndicator = model.PersonInformationSection.PersonDetails.HumanAltForeignAddressIndicator;
                    request.HumanAltForeignAddressString = model.PersonInformationSection.PersonDetails.HumanAltForeignAddressString;
                    if (request.HumanAltForeignAddressIndicator == true)
                        request.HumanAltidfsLocation = model.PersonAddressSection.HumanAltForeignidfsCountry;
                    else
                        request.HumanAltidfsLocation = GetLowestLocationID(model.PersonInformationSection.PersonDetails.HumanAltidfsCountry, model.PersonInformationSection.PersonDetails.HumanAltidfsRegion, model.PersonInformationSection.PersonDetails.HumanAltidfsRayon, model.PersonInformationSection.PersonDetails.HumanAltidfsSettlement);

                    request.HumanAltstrStreetName = model.PersonInformationSection.PersonDetails.HumanAltstrStreetName;
                    request.HumanAltstrApartment = model.PersonInformationSection.PersonDetails.HumanAltstrApartment;
                    request.HumanAltstrBuilding = model.PersonInformationSection.PersonDetails.HumanAltstrBuilding;
                    request.HumanAltstrHouse = model.PersonInformationSection.PersonDetails.HumanAltstrHouse;
                    request.HumanAltidfsPostalCode = model.PersonInformationSection.PersonDetails.HumanAltstrPostalCode;
                    request.HomePhone = model.PersonInformationSection.PersonDetails.HomePhone;
                    request.WorkPhone = model.PersonInformationSection.PersonDetails.WorkPhone;

                    request.ContactPhoneCountryCode = model.PersonInformationSection.PersonDetails.ContactPhoneCountryCode;
                    request.ContactPhone = model.PersonInformationSection.PersonDetails.ContactPhone;
                    request.ContactPhoneTypeID = model.PersonInformationSection.PersonDetails.ContactPhoneTypeID;
                    request.ContactPhone2CountryCode = model.PersonInformationSection.PersonDetails.ContactPhone2CountryCode;
                    request.ContactPhone2 = model.PersonInformationSection.PersonDetails.ContactPhone2;
                    request.ContactPhone2TypeID = model.PersonInformationSection.PersonDetails.ContactPhone2TypeID;

                    request.IsEmployedTypeID = model.PersonInformationSection.PersonDetails.IsEmployedTypeID;
                    request.OccupationTypeID = model.PersonInformationSection.PersonDetails.OccupationTypeID;
                    request.EmployerName = model.PersonInformationSection.PersonDetails.EmployerName;
                    request.EmployedDateLastPresent = model.PersonInformationSection.PersonDetails.EmployedDateLastPresent;
                    request.EmployerForeignAddressIndicator = model.PersonInformationSection.PersonDetails.EmployerForeignAddressIndicator;
                    request.EmployerForeignAddressString = model.PersonInformationSection.PersonDetails.EmployerForeignAddressString;
                    request.EmployerGeoLocationID = model.PersonInformationSection.PersonDetails.EmployerGeoLocationID;
                    if (request.EmployerForeignAddressIndicator == true)
                        request.EmployeridfsLocation = model.PersonEmploymentSchoolSection.EmployerForeignidfsCountry;
                    else
                        request.EmployeridfsLocation = GetLowestLocationID(model.PersonInformationSection.PersonDetails.EmployeridfsCountry, model.PersonInformationSection.PersonDetails.EmployeridfsRegion, model.PersonInformationSection.PersonDetails.EmployeridfsRayon, model.PersonInformationSection.PersonDetails.EmployeridfsSettlement);

                    request.EmployerstrStreetName = model.PersonInformationSection.PersonDetails.EmployerstrStreetName;
                    request.EmployerstrApartment = model.PersonInformationSection.PersonDetails.EmployerstrApartment;
                    request.EmployerstrBuilding = model.PersonInformationSection.PersonDetails.EmployerstrBuilding;
                    request.EmployerstrHouse = model.PersonInformationSection.PersonDetails.EmployerstrHouse;
                    request.EmployeridfsPostalCode = model.PersonInformationSection.PersonDetails.EmployerstrPostalCode;
                    request.EmployerPhone = model.PersonInformationSection.PersonDetails.EmployerPhone;

                    request.IsStudentTypeID = model.PersonInformationSection.PersonDetails.IsStudentTypeID;
                    request.SchoolName = model.PersonInformationSection.PersonDetails.SchoolName;
                    request.SchoolDateLastAttended = model.PersonInformationSection.PersonDetails.SchoolDateLastAttended;
                    request.SchoolForeignAddressIndicator = model.PersonInformationSection.PersonDetails.SchoolForeignAddressIndicator;
                    request.SchoolForeignAddressString = model.PersonInformationSection.PersonDetails.SchoolForeignAddressString;
                    request.SchoolGeoLocationID = model.PersonInformationSection.PersonDetails.SchoolGeoLocationID;
                    if (request.SchoolForeignAddressIndicator == true)
                        request.SchoolidfsLocation = model.PersonEmploymentSchoolSection.SchoolForeignidfsCountry;
                    else
                        request.SchoolidfsLocation = GetLowestLocationID(model.PersonInformationSection.PersonDetails.SchoolidfsCountry, model.PersonInformationSection.PersonDetails.SchoolidfsRegion, model.PersonInformationSection.PersonDetails.SchoolidfsRayon, model.PersonInformationSection.PersonDetails.SchoolidfsSettlement);

                    request.SchoolstrStreetName = model.PersonInformationSection.PersonDetails.SchoolstrStreetName;
                    request.SchoolstrApartment = model.PersonInformationSection.PersonDetails.SchoolstrApartment;
                    request.SchoolstrBuilding = model.PersonInformationSection.PersonDetails.SchoolstrBuilding;
                    request.SchoolstrHouse = model.PersonInformationSection.PersonDetails.SchoolstrHouse;
                    request.SchoolidfsPostalCode = model.PersonInformationSection.PersonDetails.SchoolstrPostalCode;
                    request.SchoolPhone = model.PersonInformationSection.PersonDetails.SchoolPhone;
                    request.AuditUser = authenticatedUser.UserName;

                    PersonSaveResponseModel response = new();
                    response = await _personClient.SavePerson(request);

                    if (response.ReturnCode != null)
                    {
                        switch (response.ReturnCode)
                        {
                            // Success
                            case 0:
                                model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                if (request.HumanMasterID == null)
                                {
                                    model.HumanMasterID = response.HumanMasterID;
                                    model.PersonInformationSection.PersonDetails.EIDSSPersonID = response.EIDSSPersonID;
                                    model.PersonInformationSection.PersonIDVisibleIndicator = true;
                                    model.PersonEmploymentSchoolSection.ReportsVisibleIndicator = true;
                                    model.InformationalMessage += "Record ID " + response.EIDSSPersonID + ".";
                                }
                                break;
                            default:
                                throw new ApplicationException("Unable to save Person.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save Person.");
                    }
                }

                return Json(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task<string> ValidatePersonAsync(DiseaseReportPersonalInformationViewModel model)
        {
            string duplicateRecordsFound = string.Empty;

            HumanPersonSearchRequestModel request = new()
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 10,
                SortColumn = "EIDSSPersonID",
                SortOrder = "DESC",
                DateOfBirthFrom = model.DateOfBirth,
                DateOfBirthTo = model.DateOfBirth,
                idfsLocation = model.HumanidfsRegion,
                LastOrSurname = model.LastOrSurname,
                FirstOrGivenName = model.FirstOrGivenName
            };

            List<PersonViewModel> duplicateList = await _personClient.GetPersonList(request);
            if (model.HumanActualId == null && duplicateList.Count > 0)
            {
                foreach (PersonViewModel item in duplicateList)
                {
                    duplicateRecordsFound += item.EIDSSPersonID + ", ";
                }

                // remove last omma and space
                duplicateRecordsFound = duplicateRecordsFound.Remove(duplicateRecordsFound.Length - 2, 2);
            }
            else if (model.HumanActualId != null && duplicateList.Where(x => x.HumanMasterID != (long)model.HumanActualId).Any())
            {
                var list = duplicateList.Where(x => x.HumanMasterID != (long)model.HumanActualId);
                foreach (PersonViewModel item in list)
                {
                    duplicateRecordsFound += item.EIDSSPersonID + ", ";
                }

                // remove last omma and space
                duplicateRecordsFound = duplicateRecordsFound.Remove(duplicateRecordsFound.Length - 2, 2);
            }

            return duplicateRecordsFound;
        }

        private static long? GetLowestLocationID(long? level0, long? level1, long? level2, long? level3)
        {
            long? idfsLocation;

            //Get lowest administrative level.
            if (level3 != null)
                idfsLocation = level3;
            else if (level2 != null)
                idfsLocation = level2;
            else if (level1 != null)
                idfsLocation = level1;
            else
                idfsLocation = level0;

            return idfsLocation;
        }

        [HttpPost]
        [Route("GetHumanDiseaseReportList")]
        public async Task<JsonResult> GetHumanDiseaseReportList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0,
                    draw = dataTableQueryPostObj.draw
                };

                var obj = JObject.Parse(dataTableQueryPostObj.postArgs.ToString())["PersonInformationSection_PersonDetails_HumanActualId"];
                if (obj != null)
                {
                    int iPage = dataTableQueryPostObj.page;
                    int iLength = dataTableQueryPostObj.length;

                    //Get sorting values.
                    KeyValuePair<string, string> valuePair = new();
                    valuePair = dataTableQueryPostObj.ReturnSortParameter();

                    if (valuePair.Key == "ReportKey")
                        valuePair = new KeyValuePair<string, string>();

                    HumanDiseaseReportSearchRequestModel model = new();
                    model.LanguageId = GetCurrentLanguage();
                    model.Page = iPage;
                    model.PageSize = iLength;
                    model.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "ReportID";
                    model.SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "DESC";
                    model.PatientID = long.Parse((string)obj);
                    //only these three fields are required
                    model.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    model.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    model.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                    model.ApplySiteFiltrationIndicator = false;

                    List<HumanDiseaseReportViewModel> list = await _humanDiseaseReportClient.GetHumanDiseaseReports(model, token);
                    IEnumerable<HumanDiseaseReportViewModel> humanDiseaseReportList = list;

                    if (list.Count > 0)
                    {
                        tableData.data.Clear();
                        tableData.iTotalRecords = list.Count;
                        tableData.iTotalDisplayRecords = (int)list[0].RecordCount;

                        for (int i = 0; i < list.Count; i++)
                        {
                            List<string> cols = new()
                            {
                                humanDiseaseReportList.ElementAt(i).ReportKey.ToString(),
                                humanDiseaseReportList.ElementAt(i).ReportID ?? "",
                                humanDiseaseReportList.ElementAt(i).DiseaseName ?? "",
                                humanDiseaseReportList.ElementAt(i).ClassificationTypeName ?? "",
                                humanDiseaseReportList.ElementAt(i).ReportStatusTypeName ?? ""
                            };

                            tableData.data.Add(cols);
                        }
                    }
                }

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost()]
        public async Task<JsonResult> GetOutbreakCaseList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            TableData tableData = new()
            {
                data = new List<List<string>>(),
                iTotalRecords = 0,
                iTotalDisplayRecords = 0,
                draw = dataTableQueryPostObj.draw
            };

            var obj = JObject.Parse(dataTableQueryPostObj.postArgs.ToString())["PersonInformationSection_PersonDetails_HumanActualId"];
            if (obj != null)
            {
                int iPage = dataTableQueryPostObj.page;
                int iLength = dataTableQueryPostObj.length;

                KeyValuePair<string, string> valuePair = new();
                valuePair = dataTableQueryPostObj.ReturnSortParameter();

                if (valuePair.Key == "idfsStatisticDataType")
                {
                    valuePair = new KeyValuePair<string, string>();
                }

                var request = new OutbreakCaseListRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    HumanMasterID = long.Parse((string)obj),
                    SearchTerm = null,
                    TodaysFollowUpsIndicator = false,
                    Page = iPage,
                    PageSize = iLength,
                    SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "EIDSSCaseID",
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Descending
                };

                List<CaseGetListViewModel> ocl = await _OutbreakClient.GetCasesList(request);
                IEnumerable<CaseGetListViewModel> OutbreakCaseList = ocl;

                tableData.iTotalRecords = ocl.Count == 0 ? 0 : ocl[0].TotalRowCount;
                tableData.iTotalDisplayRecords = ocl.Count == 0 ? 0 : ocl[0].TotalRowCount;
                tableData.draw = dataTableQueryPostObj.draw;

                if (ocl.Count > 0)
                {
                    for (int i = 0; i < ocl.Count; i++)
                    {
                        List<string> cols = new()
                        {
                            OutbreakCaseList.ElementAt(i).CaseID.ToString(),
                            OutbreakCaseList.ElementAt(i).CaseTypeName,
                            OutbreakCaseList.ElementAt(i).StatusTypeName,
                            OutbreakCaseList.ElementAt(i).DateOfSymptomOnset.ToString(),
                            OutbreakCaseList.ElementAt(i).ClassificationTypeName,
                            OutbreakCaseList.ElementAt(i).CaseLocation
                        };

                        tableData.data.Add(cols);
                    }
                }
            }

            return Json(tableData);
        }
    }
}
