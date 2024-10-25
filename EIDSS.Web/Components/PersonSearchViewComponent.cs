using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components
{
    //[ViewComponent(Name = "PersonSearchView")]
    //[Area("Human")]
    //public class PersonSearchViewComponent : BaseController
    //{
    //    PersonSearchPageViewModel _personPageViewModel;
    //    readonly IPersonClient _personClient;
    //    readonly private ISiteClient _siteClient;
    //    readonly private ICrossCuttingClient _crossCuttingClient;
    //    readonly private IConfigurationClient _configurationClient;
    //    private IStringLocalizer _localizer;
    //    AuthenticatedUser _autenticatedUser;
    //    UserPreferences _userPreferences;
    //    private readonly UserPermissions _personsListPermissions;
    //    private readonly UserPermissions _humanDiseaseReportDataPermissions;
    //    private readonly IConfiguration _configuration;

    //       public enum GISAdministrativeLevels : long
    //    {
    //        AdminLevel0 = 19000001,
    //        AdminLevel1 = 19000003,
    //        AdminLevel2 = 19000002,
    //    }

    //    public PersonSearchViewComponent(IPersonClient personClient, ISiteClient siteClient, 
    //        IConfigurationClient configurationClient, ICrossCuttingClient crossCuttingClient, 
    //        IStringLocalizer localizer, ITokenService tokenService,
    //        IConfiguration configuration,
    //        ILogger<PersonSearchViewComponent> logger) :
    //        base(logger, tokenService)
    //    {
    //        _personClient = personClient;
    //        _siteClient = siteClient;
    //        _autenticatedUser = tokenService.GetAuthenticatedUser();
    //        _configurationClient = configurationClient;
    //        _userPreferences = _autenticatedUser.Preferences;
    //        _crossCuttingClient = crossCuttingClient;
    //        _localizer = localizer;
    //        _personsListPermissions = GetUserPermissions(PagePermission.AccessToPersonsList);
    //        _humanDiseaseReportDataPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
    //        _configuration = configuration;
    //    }

    //    // GET: PersonController
    //    public async Task<IViewComponentResult> InvokeAsync()
    //    {
    //        _personPageViewModel = new PersonSearchPageViewModel();
    //        _personPageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
    //        _personPageViewModel.Select2Configurations = new List<Select2Configruation>();
    //        _personPageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
    //        _personPageViewModel.PersonsListPermissions = _personsListPermissions;
    //        _personPageViewModel.HumanDiseaseReportDataPermissions = _humanDiseaseReportDataPermissions;
    //        _personPageViewModel.SearchLocationViewModel = new()
    //        {
    //            IsHorizontalLayout = true,
    //            EnableAdminLevel1 = true,
    //            ShowAdminLevel0 = false,
    //            ShowAdminLevel1 = true,
    //            ShowAdminLevel2 = true,
    //            ShowAdminLevel3 = false,
    //            ShowAdminLevel4 = false,
    //            ShowAdminLevel5 = false,
    //            ShowAdminLevel6 = false,
    //            ShowSettlement = true,
    //            ShowSettlementType = true,
    //            ShowStreet = false,
    //            ShowBuilding = false,
    //            ShowApartment = false,
    //            ShowElevation = false,
    //            ShowHouse = false,
    //            ShowLatitude = false,
    //            ShowLongitude = false,
    //            ShowMap = false,
    //            ShowBuildingHouseApartmentGroup = false,
    //            ShowPostalCode = false,
    //            ShowCoordinates = false,
    //            IsDbRequiredAdminLevel1 = false,
    //            IsDbRequiredSettlement = false,
    //            IsDbRequiredSettlementType = false,
    //            AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
    //        };

    //        await FillConfigurtionSettingsAsync(null);

    //        //_personPageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
    //        //_personPageViewModel.Select2Configurations = new List<Select2Configruation>();
    //        //_personPageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
    //        //_personPageViewModel.PersonsListPermissions = _personsListPermissions;
    //        //_personPageViewModel.HumanDiseaseReportDataPermissions = _humanDiseaseReportDataPermissions;

    //        var viewData = new ViewDataDictionary<PersonSearchPageViewModel>(ViewData, _personPageViewModel);
    //        return new ViewViewComponentResult()
    //        {
    //            ViewData = viewData
    //        };
    //    }

    //    private async Task FillConfigurtionSettingsAsync(long? AdministrativeUnitType)
    //    {
    //        //Set PersonSearchPageViewModel SearchLocationViewModel Properties
    //        LocationViewModel searchlocationViewModel = new LocationViewModel();

    //        var siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_autenticatedUser.SiteId), Convert.ToInt64(_autenticatedUser.EIDSSUserId));

    //        if (siteDetails != null)
    //        {
    //            BaseReferenceViewModel item = new BaseReferenceViewModel();
    //            item.StrDefault = "";
    //            item.IdfsBaseReference = -1;

    //            _personPageViewModel.PersonalIDTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.PersonalIDType, null);
    //            _personPageViewModel.PersonalIDTypeList.Insert(0, item);

    //            _personPageViewModel.HumanGenderList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.HumanGender, null);
    //            _personPageViewModel.HumanGenderList.Insert(0, item);

    //            _personPageViewModel.AdminLevel0Value = siteDetails.CountryID;

    //            searchlocationViewModel.AdminLevel0Value = siteDetails.CountryID;

    //            if (_userPreferences.DefaultRegionInSearchPanels)
    //            {
    //                _personPageViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
    //                searchlocationViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
    //                _personPageViewModel.SearchLocationViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
    //            }
    //            else
    //            {
    //                _personPageViewModel.AdminLevel1Value = null;
    //                searchlocationViewModel.AdminLevel1Value = null;
    //                _personPageViewModel.SearchLocationViewModel.AdminLevel1Value = null;
    //            }

    //            if (_userPreferences.DefaultRayonInSearchPanels)
    //            {
    //                _personPageViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;
    //                searchlocationViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;
    //                _personPageViewModel.SearchLocationViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;
    //            }
    //            else
    //            {
    //                _personPageViewModel.AdminLevel2Value = null;
    //                searchlocationViewModel.AdminLevel2Value = null;
    //                _personPageViewModel.SearchLocationViewModel.AdminLevel2Value = null;
    //            }

    //            // Location Control
    //            searchlocationViewModel.IsHorizontalLayout = true;
    //            searchlocationViewModel.EnableAdminLevel1 = true;
    //            searchlocationViewModel.ShowAdminLevel0 = false;
    //            searchlocationViewModel.ShowAdminLevel1 = true;  //Region
    //            searchlocationViewModel.ShowAdminLevel2 = true;  //Rayon
    //            searchlocationViewModel.ShowAdminLevel3 = true;
    //            searchlocationViewModel.ShowAdminLevel4 = false;
    //            searchlocationViewModel.ShowAdminLevel5 = false;
    //            searchlocationViewModel.ShowAdminLevel6 = false;
    //            searchlocationViewModel.ShowSettlement = true;
    //            searchlocationViewModel.ShowSettlementType = false;
    //            searchlocationViewModel.ShowStreet = false;
    //            searchlocationViewModel.ShowApartment = false;
    //            searchlocationViewModel.ShowPostalCode = false;
    //            searchlocationViewModel.ShowCoordinates = false;
    //            searchlocationViewModel.ShowBuildingHouseApartmentGroup = false;
    //            searchlocationViewModel.IsDbRequiredAdminLevel1 = false;
    //            searchlocationViewModel.IsDbRequiredSettlement = false;
    //            searchlocationViewModel.IsDbRequiredSettlementType = false;
    //            searchlocationViewModel.AdminLevel0Value = siteDetails.CountryID;

    //            //searchlocationViewModel.AdminLevel1Text = _localizer.GetString(FieldLabelResourceKeyConstants.Region1FieldLabel);
    //            //searchlocationViewModel.AdminLevel2Text = _localizer.GetString(FieldLabelResourceKeyConstants.Rayon1FieldLabel);

    //            //_personPageViewModel.SearchAdministrativeUnitTypeID = (long)GISAdministrativeLevels.AdminLevel2;
    //            _personPageViewModel.SearchAdministrativeUnitTypeID = (long)AdministrativeUnitTypes.Rayon;

    //            switch (_personPageViewModel.SearchAdministrativeUnitTypeID)
    //            {
    //                //case (long)GISAdministrativeLevels.AdminLevel1:
    //                case (long)AdministrativeUnitTypes.Region:
    //                    searchlocationViewModel.AdminLevel1Value = _personPageViewModel.AdminLevel1Value;
    //                    searchlocationViewModel.IsDbRequiredAdminLevel1 = false;
    //                    searchlocationViewModel.ShowAdminLevel1 = true;
    //                    searchlocationViewModel.EnableAdminLevel1 = true;
    //                    break;

    //                //case (long)GISAdministrativeLevels.AdminLevel2:
    //                case (long)AdministrativeUnitTypes.Rayon:
    //                    //searchlocationViewModel.AdminLevel1Value = _personPageViewModel.AdminLevel1Value;
    //                    //searchlocationViewModel.AdminLevel2Value = _personPageViewModel.AdminLevel2Value;
    //                    searchlocationViewModel.AdminLevel1Value = _personPageViewModel.SearchLocationViewModel.AdminLevel1Value;
    //                    searchlocationViewModel.AdminLevel2Value = _personPageViewModel.SearchLocationViewModel.AdminLevel2Value;
    //                    //searchlocationViewModel.IsDbRequiredAdminLevel1 = false;
    //                    searchlocationViewModel.ShowAdminLevel1 = true;
    //                    searchlocationViewModel.EnableAdminLevel1 = true;
    //                    //searchlocationViewModel.IsDbRequiredAdminLevel2 = false;
    //                    searchlocationViewModel.ShowAdminLevel2 = true;
    //                    searchlocationViewModel.EnableAdminLevel2 = true;
    //                    searchlocationViewModel.ShowAdminLevel3 = true;
    //                    searchlocationViewModel.EnableAdminLevel3 = false;
    //                    break;
    //            }

    //            _personPageViewModel.SearchLocationViewModel = searchlocationViewModel;
    //        }
    //    }
    //}
}
