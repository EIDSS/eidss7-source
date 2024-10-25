using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Abstracts;
using EIDSS.ClientLibrary.ApiClients.Human;
using Microsoft.Extensions.Configuration;
using EIDSS.Domain.ViewModels;
using EIDSS.ClientLibrary.Services;
using Microsoft.Extensions.Logging;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Web.Areas.Human.ViewModels;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Domain.RequestModels.DataTables;
using Newtonsoft.Json;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm;

namespace EIDSS.Web.Areas.Human.Controllers
{
    //[ViewComponent(Name = "WeeklyReportingFormSearch")]
    //[Area("Human")]
    //public class WeeklyReportingFormSearchController : BaseController
    //{

    //    #region Global Values
    //    private readonly IWeeklyReportingFormClient _weeklyReportingFormClient;
    //    private readonly IConfiguration _configuration;
    //    private readonly ISiteClient _siteClient;
    //    private readonly UserPreferences userPreferences;
    //    private readonly UserPermissions userPermissions;
    //    #endregion

    //    #region Constructor

    //    public WeeklyReportingFormSearchController(IWeeklyReportingFormClient weeklyReportingFormClient, ISiteClient siteClient ,IConfiguration configuration,
    //        ITokenService tokenService, ILogger<WeeklyReportingFormSearchController> logger) :
    //        base(logger, tokenService)
    //    {
    //        _weeklyReportingFormClient = weeklyReportingFormClient;
    //        _siteClient = siteClient;
    //        _configuration = configuration;
    //        authenticatedUser = _tokenService.GetAuthenticatedUser();
    //        userPermissions = GetUserPermissions(PagePermission.HumanWeeklyReport);
    //        userPreferences = authenticatedUser.Preferences;

    //    }
    //    #endregion

    //    #region  Component Invocation

    //    public IViewComponentResult Invoke(bool recordSelectionIndicator, bool showInModalIndicator)
    //    {
    //        WeeklyReportingFormSearchViewModel model = new()
    //        {
    //            SearchCriteria = new WeeklyReportingFormGetRequestModel() { },
    //            Permissions = userPermissions,
    //            //RecordSelectionIndicator = recordSelectionIndicator,
    //            //ShowInModalIndicator = showInModalIndicator,
    //            SearchLocationViewModel = new()
    //            {
    //                IsHorizontalLayout = true,
    //                EnableAdminLevel1 = true,
    //                ShowAdminLevel0 = false,
    //                ShowAdminLevel1 = true,
    //                ShowAdminLevel2 = true,
    //                ShowAdminLevel3 = false,
    //                ShowAdminLevel4 = false,
    //                ShowAdminLevel5 = false,
    //                ShowAdminLevel6 = false,
    //                ShowSettlement = true,
    //                ShowSettlementType = false,
    //                ShowStreet = false,
    //                ShowBuilding = false,
    //                ShowApartment = false,
    //                ShowElevation = false,
    //                ShowHouse = false,
    //                ShowLatitude = false,
    //                ShowLongitude = false,
    //                ShowMap = false,
    //                ShowBuildingHouseApartmentGroup = false,
    //                ShowPostalCode = false,
    //                ShowCoordinates = false,
    //                IsDbRequiredAdminLevel1 = false,
    //                IsDbRequiredSettlement = false,
    //                IsDbRequiredSettlementType = false,
    //                AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))

    //                // AdminLevel0Value = adminLevel0Value,
    //                //AdminLevel1Value =adminLevel1Value,
    //                //AdminLevel3Value= adminLevel2Value
    //            }
    //        };

    //        var viewData = new ViewDataDictionary<WeeklyReportingFormSearchViewModel>(ViewData, model);
    //        return new ViewViewComponentResult()
    //        {
    //            ViewData = viewData
    //        };
    //    }

    //    #endregion

    //    #region Search 
    //    /// <summary>
    //    /// GetWeeklyReportFormList
    //    /// </summary>
    //    /// <param name="dataTableQueryPostObj"></param>
    //    /// <returns></returns>
    //    [HttpPost()]
    //    [Route("GetWeeklyReportFormList")]
    //    public async Task<JsonResult> GetWeeklyReportFormList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
    //    {
    //        try
    //        {
    //            TableData tableData = new()
    //            {
    //                data = new List<List<string>>(),
    //                iTotalRecords = 0,
    //                iTotalDisplayRecords = 0,
    //                draw = dataTableQueryPostObj.draw
    //            };

    
    //            var postParameterDefinitions = new { SearchCriteria_EIDSSReportID = "", SearchCriteria_StartDate = "", SearchCriteria_EndDate = "", AdminLevel1Value = "", AdminLevel2Value = "", Settlement = "" };
    //            var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

    //            if (!string.IsNullOrEmpty(searchCriteria.SearchCriteria_EIDSSReportID)
    //                || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_StartDate)
    //                || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_EndDate)
    //                || !string.IsNullOrEmpty(searchCriteria.AdminLevel1Value)
    //                || !string.IsNullOrEmpty(searchCriteria.AdminLevel2Value)
    //                || !string.IsNullOrEmpty(searchCriteria.AdminLevel2Value)
    //                )
    //            {
    //                int iPage = dataTableQueryPostObj.page;
    //                int iLength = dataTableQueryPostObj.length;

    //                //Get sorting values.
    //                KeyValuePair<string, string> valuePair = new();
    //                valuePair = dataTableQueryPostObj.ReturnSortParameter();


    //                WeeklyReportingFormGetRequestModel model = JsonConvert.DeserializeObject<WeeklyReportingFormGetRequestModel>(dataTableQueryPostObj.postArgs);
    //                model.LanguageId = GetCurrentLanguage();
    //                model.Page = iPage;
    //                model.PageSize = iLength;
    //                model.SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "EIDSSReportID";
    //                model.SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "ASC";
    //                model.EIDSSReportID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_EIDSSReportID) ? null : searchCriteria.SearchCriteria_EIDSSReportID;
    //                model.StartDate = string.IsNullOrEmpty(searchCriteria.SearchCriteria_StartDate) ? null : Convert.ToDateTime(searchCriteria.SearchCriteria_StartDate);
    //                model.EndDate = string.IsNullOrEmpty(searchCriteria.SearchCriteria_EndDate) ? null : Convert.ToDateTime(searchCriteria.SearchCriteria_EndDate);
    //                model.TimeIntervalTypeId = (long)TimePeriodTypes.Week;

    //                //Get lowest administrative level.
    //                if (!string.IsNullOrEmpty(searchCriteria.Settlement))
    //                {
    //                    model.AdministrativeUnitTypeId = (long)AdministrativeUnitTypes.Settlement;
    //                    model.AdministrativeLevelId = Convert.ToInt64(searchCriteria.Settlement);
    //                }
    //                else if (!string.IsNullOrEmpty(searchCriteria.AdminLevel2Value))
    //                {
    //                    model.AdministrativeUnitTypeId = (long)AdministrativeUnitTypes.Rayon;
    //                    model.AdministrativeLevelId = Convert.ToInt64(searchCriteria.AdminLevel2Value);
    //                }
    //                else if (!string.IsNullOrEmpty(searchCriteria.AdminLevel1Value))
    //                {
    //                    model.AdministrativeUnitTypeId = (long)AdministrativeUnitTypes.Region;
    //                    model.AdministrativeLevelId = Convert.ToInt64(searchCriteria.AdminLevel1Value);
    //                }



    //                List<ReportFormViewModel> list = await _weeklyReportingFormClient.GetWeeklyReportingFormList(model);
    //                IEnumerable<ReportFormViewModel> organizationList = list;

    //                if (list.Count > 0)
    //                {
    //                    tableData.data.Clear();
    //                    tableData.iTotalRecords = (int)list[0].TotalRowCount;
    //                    tableData.iTotalDisplayRecords = (int)list[0].TotalRowCount;
    //                    tableData.recordsTotal = (int)list[0].TotalRowCount;

    //                    for (int i = 0; i < list.Count; i++)
    //                    {
    //                        List<string> cols = new()
    //                        {
    //                            organizationList.ElementAt(i).EIDSSReportID.ToString(),
    //                            organizationList.ElementAt(i).DisplayStartDate.ToString() ?? "",
    //                            organizationList.ElementAt(i).DisplayFinishDate.ToString() ?? "",
    //                            organizationList.ElementAt(i).AdminLevel1Name,
    //                            organizationList.ElementAt(i).AdminLevel2Name,
    //                            organizationList.ElementAt(i).SettlementName,
    //                            organizationList.ElementAt(i).EIDSSReportID.ToString(),
    //                            organizationList.ElementAt(i).EIDSSReportID.ToString()
    //                        };

    //                        tableData.data.Add(cols);
    //                    }
    //                }
                    
    //            }

    //            return Json(tableData);
    //        }
    //        catch (Exception ex)
    //        {
    //            _logger.LogError(ex.Message, null);
    //            throw;
    //        }
    //    }

    //    #endregion




    //    #region private methods

    //    private async Task FillConfigurtionSettingsAsync(long? AdministrativeUnitType)
    //    {
    //        LocationViewModel searchlocationViewModel = new LocationViewModel();

    //        var siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));
    //        if (siteDetails != null)
    //        {
    //            searchlocationViewModel.AdminLevel0Value = siteDetails.CountryID;


    //        }
    //    }
    //    #endregion

    //}
}
