using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class ILIAggregateAddEditPageController : BaseController
    {
        ILIAggregatePageViewModel _pageViewModel;
        private IILIAggregateFormClient _iliAggregateFormClient;
        private IOrganizationClient _organizationClient;
        private UserPermissions userPermissions;
        private IStringLocalizer _localizer;
        private string _formID;

        public List<ILIAggregateDetailViewModel> ILIAggregateDetails { get; set; }

        [Inject]
        IHttpContextAccessor HttpContext { get; set; }

        public ILIAggregateAddEditPageController(
            IILIAggregateFormClient iliAggregateFormClient,
            IOrganizationClient organizationClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<ILIAggregateAddEditPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new ILIAggregatePageViewModel();
            _iliAggregateFormClient = iliAggregateFormClient;
            _organizationClient = organizationClient;
            _localizer = localizer;
            userPermissions = GetUserPermissions(PagePermission.CanManageBaseReferencePage);
            _pageViewModel.UserPermissions = userPermissions;
        }

        //[Route("Index")]
        public async Task<IActionResult> Index(string queryData)
        {
            //_pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            //_pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            if (!string.IsNullOrEmpty(queryData))
            {
                _pageViewModel.FormID = queryData;

                // grab header data
                var request = new ILIAggregateFormSearchRequestModel();

                request.LanguageId = GetCurrentLanguage();
                request.Page = 1;
                request.PageSize = 10;
                request.SortColumn = "FormID";
                request.SortOrder = "desc";
                request.FormID = queryData;
                //request.LegacyFormID = NEEDS HOOKUP
                request.LegacyFormID = null;
                request.AggregateHeaderID = null;
                request.UserSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                request.UserOrganizationID = null;
                //request.UserEmployeeID = Convert.ToInt64(authenticatedUser.EIDSSUserId);
                request.ApplySiteFiltrationIndicator = false;
                request.HospitalID = null;
                request.StartDate = null;
                request.FinishDate = null;
                request.UserOrganizationID = null;
                request.UserEmployeeID = null;
                request.ApplySiteFiltrationIndicator = false;

                List<ILIAggregateViewModel> response = await _iliAggregateFormClient.GetILIAggregateList(request);
                IEnumerable<ILIAggregateViewModel> iliAggregateList = response;

                _pageViewModel.EnteredBy = iliAggregateList.ElementAt(0).UserName;
                _pageViewModel.DateEntered = iliAggregateList.ElementAt(0).DateEntered;
                _pageViewModel.DateLastSaved = iliAggregateList.ElementAt(0).DateLastSaved == iliAggregateList.ElementAt(0).DateEntered ? 
                    null : iliAggregateList.ElementAt(0).DateLastSaved;
                _pageViewModel.Week = iliAggregateList.ElementAt(0).Week;
                _pageViewModel.Year = iliAggregateList.ElementAt(0).Year;
                _pageViewModel.Site = iliAggregateList.ElementAt(0).OrganizationName;
                _pageViewModel.IdfAggregateHeader = iliAggregateList.ElementAt(0).AggregateHeaderKey;
            }
            else
            {
                _pageViewModel.DateEntered = DateTime.Now;
                //_pageViewModel.DateLastSaved = 


                var currentCulture = CultureInfo.CurrentCulture;
                var weekNo = currentCulture.Calendar.GetWeekOfYear(
                                DateTime.Now,
                                currentCulture.DateTimeFormat.CalendarWeekRule,
                                currentCulture.DateTimeFormat.FirstDayOfWeek);
                _pageViewModel.Week = weekNo;

                _pageViewModel.Year = DateTime.Now.Year;
                _pageViewModel.EnteredBy = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                _pageViewModel.Site = authenticatedUser.Organization;
            }


            return View(_pageViewModel);
        }

        /*
        [HttpPost()]
        //[Route("GetList")]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            JObject searchFilter = JObject.Parse(dataTableQueryPostObj.postArgs.ToString());
            //request.FormID = searchFilter["txtFormID"].ToString() == string.Empty ? null : searchFilter["txtFormID"].ToString();

            _pageViewModel.FormID = searchFilter["txtFormID"].ToString();

            int iPage = dataTableQueryPostObj.page;
            int iLength = dataTableQueryPostObj.length;

            KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
            valuePair = dataTableQueryPostObj.ReturnSortParameter();

            // get details grid data
            var request = new ILIAggregateFormDetailRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                IdfAggregateHeader = -1,
                FormID = searchFilter["txtFormID"].ToString() == string.Empty ? null : searchFilter["txtFormID"].ToString(),
                Page = iPage,
                PageSize = iLength,
                SortColumn = !String.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "FormID",
                SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "desc"
            };

            List<ILIAggregateViewModel> response = await _iliAggregateFormClient.GetILIAggregateDetailList(request);
            IEnumerable<ILIAggregateViewModel> iliAggregateDetailList = response;

            TableData tableData = new TableData();
            tableData.data = new List<List<string>>();
            tableData.iTotalRecords = response.Count == 0 ? 0 : response[0].TotalRowCount;
            tableData.iTotalDisplayRecords = response.Count == 0 ? 0 : response[0].TotalRowCount;
            tableData.draw = dataTableQueryPostObj.draw;

            int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            if (iliAggregateDetailList.Count() > 0)
            {
                for (int i = 0; i < iliAggregateDetailList.Count(); i++)
                {
                    List<string> cols = new List<string>()
                        {
                            (row + i + 1).ToString(),
                            iliAggregateDetailList.ElementAt(i).AggregateHeaderKey.ToString(),
                            iliAggregateDetailList.ElementAt(i).IdfAggregateDetail.ToString(),
                            iliAggregateDetailList.ElementAt(i).IdfHospital.ToString(),
                            iliAggregateDetailList.ElementAt(i).HospitalName,
                            iliAggregateDetailList.ElementAt(i).IntAge0_4.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntAge5_14.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntAge15_29.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntAge30_64.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntAge65.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntTotalILI.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntTotalAdmissions.ToString(),
                            iliAggregateDetailList.ElementAt(i).IntILISamples.ToString()
                        };
                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);

            //return null;
        }
        */

        //[Microsoft.AspNetCore.Mvc.Route("SaveAll")]
        //public async Task<IActionResult> SaveAll(ILIAggregatePageViewModel model)
        //{
        //    var s = HttpSessionHelper.GetObjectFromJson<List<ILIAggregateDetailViewModel>>(HttpContext.HttpContext.Session, "ILIAggregateDetails");            

        //    ILIAggregateSaveRequestModel request = new();

        //    try
        //    {
        //        request.LangID = GetCurrentLanguage();
        //        request.StrFormId = model.FormID;
        //        request.IdfEnteredBy = Convert.ToInt64(authenticatedUser.PersonId);
        //        request.IdfsSite = Convert.ToInt64(authenticatedUser.SiteId);
        //        request.IntYear = model.Year;
        //        request.IntWeek = model.Week;
        //        request.RowStatus = 0;
        //        request.AuditUserName = authenticatedUser.UserName;

        //        if (string.IsNullOrEmpty(model.FormID))
        //        {
        //            request.IdfAggregateHeader = -1;
        //            request.DatStartDate = DateTime.Now;
        //        }
        //        else
        //        {
        //            request.IdfAggregateHeader = model.IdfAggregateHeader;
        //            request.DatStartDate = model.DateEntered;
        //        }
                
        //        request.DatFinishDate = DateTime.Now;

        //        ILIAggregateSaveRequestModel response = await _iliAggregateFormClient.SaveILIAggregate(null);
        //        //return View("Index", _pageViewModel); //https://localhost:44336/SaveHeader
        //        //return RedirectPermanent
        //        //return RedirectToActionPermanent

        //        return RedirectToAction("Index", "ILIAggregateAddEditPage", new { queryData = response.StrFormId });                
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, new object[] { request });
        //        throw;
        //    }
        //}

        //[Microsoft.AspNetCore.Mvc.Route("DeleteHeader")]
        //public async Task<IActionResult> DeleteHeader(ILIAggregatePageViewModel model)
        //{
        //    ILIAggregateSaveRequestModel request = new();

        //    try
        //    {
        //        APIPostResponseModel response = await _iliAggregateFormClient.DeleteILIAggregateHeader(model.IdfAggregateHeader);
        //        return RedirectToAction("Index", "ILIAggregateAddEditPage");
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, new object[] { request });
        //        throw;
        //    }
        //}

        //[HttpPost()]
        ////[Route("Human/ILIAggregateAddEditPage/Add")]
        //[Route("Add")]
        //public async Task<IActionResult> Add([FromBody] JsonElement data)
        //{
        //    ILIAggregateDetailSaveRequestModel request = new();

        //    try
        //    {
        //        var jsonObject = JObject.Parse(data.ToString());

        //        request.LanguageID = GetCurrentLanguage();
        //        request.IdfAggregateHeader = Convert.ToInt64(jsonObject["IdfAggregateHeader"].ToString());
        //        request.IdfAggregateDetail = null;
        //        request.IdfsSite = Convert.ToInt64(authenticatedUser.SiteId);
        //        request.RowStatus = 0;
        //        request.IdfHospital = long.Parse(jsonObject["IdfHospital"][0]["id"].ToString());
        //        request.IntAge0_4 = Convert.ToInt32(jsonObject["IntAge0_4"].ToString());
        //        request.IntAge5_14 = Convert.ToInt32(jsonObject["IntAge5_14"].ToString());
        //        request.IntAge15_29 = Convert.ToInt32(jsonObject["IntAge15_29"].ToString());
        //        request.IntAge30_64 = Convert.ToInt32(jsonObject["IntAge30_64"].ToString());
        //        request.IntAge65 = Convert.ToInt32(jsonObject["IntAge65"].ToString());
        //        request.IntTotalILI = Convert.ToInt32(jsonObject["IntTotalILI"].ToString());
        //        request.IntTotalAdmissions = Convert.ToInt32(jsonObject["IntTotalAdmissions"].ToString());
        //        request.IntILISamples = Convert.ToInt32(jsonObject["IntILISamples"].ToString());
        //        request.AuditUserName = string.Empty;
        //        request.RowAction = "I";


        //        if (request.IdfAggregateHeader == 0 || request.IdfAggregateHeader == null)
        //        {
        //            request.IdfEnteredBy = Convert.ToInt64(authenticatedUser.PersonId);
        //            request.IntYear = DateTime.Now.Year;
        //            var currentCulture = CultureInfo.CurrentCulture;
        //            var weekNo = currentCulture.Calendar.GetWeekOfYear(
        //                            DateTime.Now,
        //                            currentCulture.DateTimeFormat.CalendarWeekRule,
        //                            currentCulture.DateTimeFormat.FirstDayOfWeek);
        //            request.IntWeek = weekNo;
        //        }


        //        ILIAggregateDetailSaveRequestModel response = await _iliAggregateFormClient.SaveILIAggregateDetail(request);

        //        if (request.IdfAggregateHeader == 0 || request.IdfAggregateHeader == null) response.RefreshPage = true;

        //        return Json(response);

        //        //return View(_pageViewModel);
        //        //return null;
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, new object[] { request });
        //        throw;
        //    }

        //}


        //[HttpPost()]
        //[Route("Human/ILIAggregateAddEditPage/Edit")]
        ////[Route("Edit")]
        //public async Task<JsonResult> Edit([FromBody] JsonElement json)
        //{
        //    ILIAggregateDetailSaveRequestModel request = new ILIAggregateDetailSaveRequestModel();

        //    try
        //    {
        //        var jsonObject = JObject.Parse(json.ToString());

        //        request.LanguageID = GetCurrentLanguage();
        //        request.IdfAggregateHeader = null;
        //        request.IdfAggregateDetail = Convert.ToInt32(jsonObject["IdfAggregateDetail"].ToString());
        //        request.IdfsSite = Convert.ToInt64(authenticatedUser.SiteId);
        //        request.RowStatus = 0;

        //        //request.IdfHospital = long.Parse(jsonObject["HospitalName"][0]["id"].ToString());
        //        request.IdfHospital = long.Parse(jsonObject["idfHospital"].ToString());

        //        request.IntAge0_4 = Convert.ToInt32(jsonObject["Age0_4"].ToString());
        //        request.IntAge5_14 = Convert.ToInt32(jsonObject["Age5_14"].ToString());
        //        request.IntAge15_29 = Convert.ToInt32(jsonObject["Age15_29"].ToString());
        //        request.IntAge30_64 = Convert.ToInt32(jsonObject["Age30_64"].ToString());
        //        request.IntAge65 = Convert.ToInt32(jsonObject["Age65"].ToString());
        //        request.IntTotalILI = Convert.ToInt32(jsonObject["TotalILI"].ToString());
        //        request.IntTotalAdmissions = Convert.ToInt32(jsonObject["TotalAdmissions"].ToString());
        //        request.IntILISamples = Convert.ToInt32(jsonObject["ILISamples"].ToString());
        //        request.AuditUserName = string.Empty;
        //        request.RowAction = "U";

        //        APIPostResponseModel response = await _iliAggregateFormClient.SaveILIAggregateDetail(request);
        //        //response.strDuplicatedField = String.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
        //        return Json(response);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, new object[] { request });
        //        throw;
        //    }

        //}

        //[HttpPost()]
        //[Route("Delete")]
        //public async Task<JsonResult> Delete([FromBody] JsonElement json)
        //{
        //    long idfAggregateDetail = -1;
        //    try
        //    {
        //        var jsonObject = JObject.Parse(json.ToString());
        //        idfAggregateDetail = Convert.ToInt64(jsonObject["IdfAggregateDetail"].ToString());

        //        APIPostResponseModel response = await _iliAggregateFormClient.DeleteILIAggregateDetail(authenticatedUser.EIDSSUserId, idfAggregateDetail);
        //        return Json(response);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, new object[] { idfAggregateDetail });
        //        throw;
        //    }

        //    //if (response.ReturnMessage == "IN USE")
        //    //{
        //    //    //do Something
        //    //}
        //    //else
        //    //{
        //    //    //else do this
        //    //}

        //}

        //public async Task<JsonResult> HospitalsForSelect2DropDown()
        //{
        //    OrganizationGetRequestModel request = new OrganizationGetRequestModel();
        //    try
        //    {
        //        request.LanguageId = GetCurrentLanguage();
        //        request.Page = 1;
        //        request.PageSize = 99999;
        //        request.SortColumn = "Order";
        //        request.SortOrder = "ASC";
        //        request.OrganizationTypeID = Convert.ToInt64(OrganizationTypes.Hospital);
        //        //request.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
        //        //request.AccessoryCode = HACodeList.HumanHACode;

        //        var allSites = await _organizationClient.GetOrganizationList(request);

        //        List<Select2DataItem> select2DataItems = new();
        //        Select2DataResults select2DataObj = new();

        //        foreach (var s in allSites)
        //        {
        //            select2DataItems.Add(new Select2DataItem() { id = s.OrganizationKey.ToString(), text = s.FullName });
        //        }

        //        select2DataObj.results = select2DataItems;
        //        return Json(select2DataObj);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, new object[] { request });
        //        throw;
        //    }

        //}
    }
}
