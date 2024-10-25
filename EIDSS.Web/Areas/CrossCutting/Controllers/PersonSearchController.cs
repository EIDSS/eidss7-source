using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Extensions;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [Area("CrossCutting")]
    [Controller]
    public class PersonSearchController : BaseController
    {
        readonly IPersonClient _personClient;
        private IStringLocalizer _localizer;

        public PersonSearchController(IPersonClient personClient, ILogger<PersonSearchController> logger,
            IStringLocalizer localizer) : base(logger)
        {
            _personClient = personClient;
            _localizer = localizer;
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpPost()]
        [Route("GetPIN")]
        public JsonResult GetPIN(long PersonalIDType, string PersonalID)
        {
            PersonSearchPageViewModel response = new PersonSearchPageViewModel();

            string status = string.Empty;

            if (PersonalID == "NYMX") //Psuedo test to demonstrate no data found in PIN system
            {
                response.PINSearchStatus = "FAILED";
            }
            else if (PersonalID.Length > 10) //Psuedo test to demonstrate warning for PIN character limitation
            {
                response.PINSearchStatus = "LIMIT";
            }
            else //Test PIN data, until a system has been integrated.
            {
                response.PINSearchStatus = "FOUND";

                //response.LastOrSurname = "Albanese";
                //response.FirstOrGivenName = "Roger";
                //response.SecondName = "Doug";
            }

            return Json(response);
        }

        //MJK - no longer needed because person search has been converted to a blazor component
        //[HttpPost()]
        //public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        //{
        //    try
        //    {
        //        int iPage = dataTableQueryPostObj.page;
        //        int iLength = dataTableQueryPostObj.length;

        //        KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
        //        valuePair = dataTableQueryPostObj.ReturnSortParameter();

        //        var request = new HumanPersonSearchRequestModel
        //        {
        //            LanguageId = GetCurrentLanguage(),
        //            Page = iPage,
        //            PageSize = iLength,
        //            SortColumn = !String.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "EIDSSPersonID",
        //            SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "desc"
        //        };

        //        JObject searchFilter = JObject.Parse(dataTableQueryPostObj.postArgs.ToString());

        //        request.EIDSSPersonID = searchFilter["EIDSSPersonID"].ToString() == string.Empty ? null : searchFilter["EIDSSPersonID"].ToString();
        //        request.PersonalIDType = long.Parse(searchFilter["PersonalIDType"].ToString());
        //        request.PersonalID = searchFilter["PersonalID"].ToString() == string.Empty ? null : searchFilter["PersonalID"].ToString();
        //        request.LastOrSurname = searchFilter["LastOrSurname"].ToString() == string.Empty ? null : searchFilter["LastOrSurname"].ToString();
        //        request.FirstOrGivenName = searchFilter["FirstOrGivenName"].ToString() == string.Empty ? null : searchFilter["FirstOrGivenName"].ToString();
        //        request.SecondName = searchFilter["SecondName"].ToString() == string.Empty ? null : searchFilter["SecondName"].ToString();
        //        request.DateOfBirthFrom = (searchFilter["DateOfBirthFrom"].ToString() == string.Empty) ? null : DateTime.Parse(searchFilter["DateOfBirthFrom"].ToString());
        //        request.DateOfBirthTo = (searchFilter["DateOfBirthTo"].ToString() == string.Empty) ? null : DateTime.Parse(searchFilter["DateOfBirthTo"].ToString());
        //        request.GenderTypeID = long.Parse(searchFilter["GenderTypeID"].ToString());
        //        //request.RegionID = (searchFilter["AdminLevel1Value"].ToString() == string.Empty) ? null : long.Parse(searchFilter["AdminLevel1Value"].ToString());
        //        //request.RayonID = (searchFilter["AdminLevel2Value"].ToString() == string.Empty) ? null : long.Parse(searchFilter["AdminLevel2Value"].ToString());

        //        //Get lowest administrative level.
        //        var onlyRegion = false;
        //        if (!string.IsNullOrEmpty((string)((JValue)searchFilter["AdminLevel3Value"]).Value))
        //            request.idfsLocation = string.IsNullOrEmpty((string)((JValue)searchFilter["AdminLevel3Value"]).Value) ? null : long.Parse((string)((JValue)searchFilter["AdminLevel3Value"]).Value);
        //        else if (!string.IsNullOrEmpty((string)((JValue)searchFilter["AdminLevel2Value"]).Value))
        //            request.idfsLocation = string.IsNullOrEmpty((string)((JValue)searchFilter["AdminLevel2Value"]).Value) ? null : long.Parse((string)((JValue)searchFilter["AdminLevel2Value"]).Value);
        //        else if (!string.IsNullOrEmpty((string)((JValue)searchFilter["AdminLevel1Value"]).Value))
        //        { 
        //            request.idfsLocation = string.IsNullOrEmpty((string)((JValue)searchFilter["AdminLevel1Value"]).Value) ? null : long.Parse((string)((JValue)searchFilter["AdminLevel1Value"]).Value);
        //            onlyRegion = true;
        //        }
        //        else
        //            request.idfsLocation = null;

        //        //long? idfsLocationDefault = null;
        //        //if (!string.IsNullOrEmpty((string)((JValue)searchFilter["SearchLocationViewModel_AdminLevel2Value"]).Value))
        //        //    idfsLocationDefault = string.IsNullOrEmpty((string)((JValue)searchFilter["SearchLocationViewModel_AdminLevel2Value"]).Value) ? null : long.Parse((string)((JValue)searchFilter["SearchLocationViewModel_AdminLevel2Value"]).Value);
        //        //else if (!string.IsNullOrEmpty((string)((JValue)searchFilter["SearchLocationViewModel_AdminLevel1Value"]).Value))
        //        //    request.idfsLocation = string.IsNullOrEmpty((string)((JValue)searchFilter["SearchLocationViewModel_AdminLevel1Value"]).Value) ? null : long.Parse((string)((JValue)searchFilter["SearchLocationViewModel_AdminLevel1Value"]).Value);
        //        //else
        //        //   idfsLocationDefault = null;

        //        if (string.IsNullOrEmpty(request.EIDSSPersonID) &&
        //            request.PersonalIDType == -1 &&
        //            string.IsNullOrEmpty(request.PersonalID) &&
        //            string.IsNullOrEmpty(request.LastOrSurname) &&
        //            string.IsNullOrEmpty(request.FirstOrGivenName) &&
        //            string.IsNullOrEmpty(request.SecondName) &&
        //            string.IsNullOrEmpty(request.DateOfBirthFrom.ToString()) &&
        //            string.IsNullOrEmpty(request.DateOfBirthTo.ToString()) &&
        //            request.GenderTypeID == -1 &&
        //            //request.RegionID == null &&
        //            //(request.idfsLocation == null || request.idfsLocation == idfsLocationDefault)
        //            (request.idfsLocation == null || onlyRegion == true)
        //            )
        //        {
        //            TableData emptyData = new TableData();
        //            emptyData.data = new List<List<string>>();
        //            emptyData.iTotalRecords = 0;
        //            emptyData.iTotalDisplayRecords = 0;
        //            emptyData.draw = dataTableQueryPostObj.draw;
        //            return Json(emptyData);
        //        }
        //        else
        //        {
        //            if (request.PersonalIDType == -1) { request.PersonalIDType = null; }
        //            if (request.GenderTypeID == -1) { request.GenderTypeID = null; }

        //            List<PersonViewModel> pvml = await _personClient.GetPersonList(request);
        //            IEnumerable<PersonViewModel> personList = pvml;

        //            TableData tableData = new TableData();
        //            tableData.data = new List<List<string>>();
        //            tableData.iTotalRecords = pvml.Count == 0 ? 0 : pvml[0].TotalRowCount;
        //            tableData.iTotalDisplayRecords = pvml.Count == 0 ? 0 : pvml[0].TotalRowCount;
        //            tableData.draw = dataTableQueryPostObj.draw;

        //            if (pvml.Count() > 0)
        //            {
        //                for (int i = 0; i < pvml.Count(); i++)
        //                {
        //                    List<string> cols = new List<string>()
        //                    {
        //                        personList.ElementAt(i).HumanMasterID.ToString(),
        //                        personList.ElementAt(i).EIDSSPersonID,
        //                        personList.ElementAt(i).LastOrSurname,
        //                        personList.ElementAt(i).FirstOrGivenName,
        //                        personList.ElementAt(i).PersonalID ?? "",
        //                        personList.ElementAt(i).PersonIDTypeName ?? "",
        //                        personList.ElementAt(i).DateOfBirth,
        //                        personList.ElementAt(i).GenderTypeName,
        //                        personList.ElementAt(i).RegionName,
        //                        personList.ElementAt(i).RayonName,
        //                        personList.ElementAt(i).CitizenshipTypeName ?? "",
        //                        personList.ElementAt(i).CountryName,
        //                        personList.ElementAt(i).SettlementName,
        //                        personList.ElementAt(i).AddressString,
        //                        personList.ElementAt(i).ContactPhoneNumber ?? "",
        //                        personList.ElementAt(i).Age.ToString() ?? ""
        //                    };
        //                    tableData.data.Add(cols);
        //                }
        //            }

        //            return Json(tableData);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, null);
        //        throw;
        //    }
        //}

        //[HttpPost]
        //public async Task<IActionResult> BuildDetailRowContentAsync([FromBody] EIDSSSGridChildRowParameter eIDSSSGridChildRowParameter)
        //{
        //    var request = new HumanPersonSearchRequestModel
        //    {
        //        LanguageId = GetCurrentLanguage(),
        //        EIDSSPersonID = eIDSSSGridChildRowParameter.Id,
        //        Page = 1,
        //        PageSize = 10,
        //        SortColumn = "EIDSSPersonID",
        //        SortOrder = "desc"
        //    };

        //    var response = await _personClient.GetPersonList(request);
        //    if (response?.Count > 0)
        //    {
        //        string viewFromAnotherController = await this.RenderViewToStringAsync("~/Views/Shared/_PersonDetailReadOnlyPartial.cshtml", response.FirstOrDefault());
        //        return Ok(viewFromAnotherController);
        //    }
        //    else
        //    {
        //        return Ok(string.Empty);
        //    }

        //}
    }
}
