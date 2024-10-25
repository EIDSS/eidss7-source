using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.ViewModels;
using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.Controllers
{
    //[ViewComponent(Name = "WeeklyReportingFormDetails")]
    //[Area("Human")]
    //public class WeeklyReportingFormDetailsController : BaseController
    //{

    //    #region Global Values
    //    private readonly IWeeklyReportingFormClient _weeklyReportingFormClient;
    //    private readonly IConfiguration _configuration;
    //    private readonly ISiteClient _siteClient;
    //    private readonly UserPreferences userPreferences;
    //    private readonly UserPermissions userPermissions;
    //    #endregion

    //    public WeeklyReportingFormDetailsController(IWeeklyReportingFormClient weeklyReportingFormClient, ISiteClient siteClient, IConfiguration configuration,
    //       ITokenService tokenService, ILogger<WeeklyReportingFormDetailsController> logger) :
    //       base(logger, tokenService)
    //    {
    //        _weeklyReportingFormClient = weeklyReportingFormClient;
    //        _siteClient = siteClient;
    //        _configuration = configuration;
    //        authenticatedUser = _tokenService.GetAuthenticatedUser();
    //        userPermissions = GetUserPermissions(PagePermission.HumanWeeklyReport);
    //        userPreferences = authenticatedUser.Preferences;
    //    }

    //    #region  Component Invocation

    //    public async Task<IViewComponentResult> InvokeAsync(bool recordSelectionIndicator, bool showInModalIndicator)
    //    {

    //        LocationViewModel searchlocationViewModel = new LocationViewModel();
    //        long? adminLevel0Value = null;
    //        long? adminLevel1Value = null;
    //        long? adminLevel2Value = null;

    //        var siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));
    //        if (siteDetails != null)
    //        {
    //            adminLevel0Value = siteDetails.CountryID;
    //            if (userPreferences.DefaultRegionInSearchPanels)
    //            {
    //                adminLevel1Value = siteDetails.AdministrativeLevel2ID;
    //            }
    //            if (userPreferences.DefaultRayonInSearchPanels)
    //            {
    //                adminLevel2Value = siteDetails.AdministrativeLevel3ID;
    //            }
    //        }

    //        WeeklyReportingFormDetailsViewModel model = new()
    //        {
               
    //          WeeklyReportingFormDetailsSectionViewModel= new()
    //            {
    //                DetailsLocationViewModel = new()
    //                {
    //                    IsHorizontalLayout = true,
    //                    EnableAdminLevel1 = true,
    //                    ShowAdminLevel0 = false,
    //                    ShowAdminLevel1 = true,
    //                    ShowAdminLevel2 = true,
    //                    ShowAdminLevel3 = false,
    //                    ShowAdminLevel4 = false,
    //                    ShowAdminLevel5 = false,
    //                    ShowAdminLevel6 = false,
    //                    ShowSettlement = false,
    //                    ShowSettlementType = false,
    //                    ShowStreet = false,
    //                    ShowBuilding = false,
    //                    ShowApartment = false,
    //                    ShowElevation = false,
    //                    ShowHouse = false,
    //                    ShowLatitude = false,
    //                    ShowLongitude = false,
    //                    ShowMap = false,
    //                    ShowBuildingHouseApartmentGroup = false,
    //                    ShowPostalCode = false,
    //                    ShowCoordinates = false,
    //                    IsDbRequiredAdminLevel1 = false,
    //                    IsDbRequiredSettlement = false,
    //                    IsDbRequiredSettlementType = false,
    //                    AdminLevel0Value = adminLevel0Value,
    //                    AdminLevel1Value = adminLevel1Value,
    //                    AdminLevel3Value = adminLevel2Value
    //                }
    //            }
    //        };

    //        var viewData = new ViewDataDictionary<WeeklyReportingFormDetailsViewModel>(ViewData, model);
    //        return new ViewViewComponentResult()
    //        {
    //            ViewData = viewData
    //        };
    //    }

    //    #endregion

    //    public IActionResult Index(long id)
    //    {
    //        return View();
    //    }



    //}
}
