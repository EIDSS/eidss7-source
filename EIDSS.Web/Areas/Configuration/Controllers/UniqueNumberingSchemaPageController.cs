using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
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


namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class UniqueNumberingSchemaPageController : BaseController
    {
        BaseReferenceEditorPagesViewModel _pageViewModel;
        private IUniqueNumberingSchemaClient _numberingSchemaClient;        
        private IStringLocalizer _localizer;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private UserPermissions _userPermissions;

        public UniqueNumberingSchemaPageController(            
            IUniqueNumberingSchemaClient numberingSchemaClient,            
            ITokenService tokenService,
            IStringLocalizer localizer,
            ICrossCuttingClient crossCuttingClient,
            ILogger<DiseaseAgeGroupMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _numberingSchemaClient = numberingSchemaClient;            
            _localizer = localizer;
            _crossCuttingClient = crossCuttingClient;
            _userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _userPermissions.Create = false; // no Add button for this page
            _pageViewModel.UserPermissions = _userPermissions;
        }

        public IActionResult Index()
        {
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_pageViewModel);
        }

        [HttpPost()]
        //[Route("GetList")]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var postParameterDefinitions = new { SearchBox = "" };
                var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                //Sorting
                KeyValuePair<string, string> valuePair = new KeyValuePair<string, string>();
                valuePair = dataTableQueryPostObj.ReturnSortParameter();

                string strSortColumn = "StrPrefix";
                if (!String.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfsNumberName")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new UniqueNumberingSchemaGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    QuickSearch = referenceType.SearchBox.Trim(),
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !String.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc"
                };

                List<UniqueNumberingSchemaListViewModel> response = await _numberingSchemaClient.GetUniqueNumberingSchemaListAsync(request);
                IEnumerable<UniqueNumberingSchemaListViewModel> matrixList = response;

                TableData tableData = new TableData();

                tableData.iTotalRecords = matrixList.Count() == 0 ? 0 : matrixList.FirstOrDefault().TotalRowCount;
                tableData.iTotalDisplayRecords = matrixList.Count() == 0 ? 0 : matrixList.FirstOrDefault().TotalRowCount;
                tableData.draw = dataTableQueryPostObj.draw;
                tableData.data = new List<List<string>>();

                if (matrixList.Any())
                {
                    int row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                    for (int i = 0; i < matrixList.Count(); i++)
                    {                                
                        // Next Number

                        string strNextNumber = null;
                        var nextNumber = matrixList.ElementAt(i).intNumberNextValue;
                        if (nextNumber != null && !string.IsNullOrEmpty(nextNumber))
                        {
                            if (nextNumber.Length < 4)
                            {
                                int nextNumberLength = nextNumber.Length;

                                int padding = matrixList.ElementAt(i).IntMinNumberLength - nextNumberLength;
                                strNextNumber = new string('0', padding) + nextNumber;
                            }
                            else
                                strNextNumber = nextNumber;
                        }
                        else strNextNumber = string.Empty;
                        
                        // Special Character
                        var specialCharacter = string.IsNullOrEmpty(matrixList.ElementAt(i).StrSpecialChar) ? "-" : matrixList.ElementAt(i).StrSpecialChar;
                        var blnUseHacsCodeSite = matrixList.ElementAt(i).blnUseHACSCodeSite;
                        var siteCode = _tokenService.GetAuthenticatedUser().SiteCode;
                        var siteId = _tokenService.GetAuthenticatedUser().SiteId;
                        string siteName;
                        if (blnUseHacsCodeSite is true)
                        {
                            siteName = string.IsNullOrEmpty(siteCode)
                                ? siteId
                                : siteCode.Substring(2, siteCode.Length - 3);
                        }
                        else
                        {
                            siteName = siteId;
                        }
                        List<string> cols = new()
                        {
                            (row + i + 1).ToString(),
                            matrixList.ElementAt(i).IdfsNumberName.ToString() ?? string.Empty,
                            matrixList.ElementAt(i).StrDefault.ToString() ?? string.Empty,
                            matrixList.ElementAt(i).StrName ?? string.Empty,
                            matrixList.ElementAt(i).StrPrefix ?? string.Empty,
                            siteName,
                            DateTime.Today.ToString("yy"),                            
                            matrixList.ElementAt(i).IntNumberValue ?? string.Empty, // last document # (current number saved by application for the given report)
                            strNextNumber,
                            strNextNumber, // to compare the original value for validation on the save
                            specialCharacter,// special character
                            matrixList.ElementAt(i).StrSuffix ?? string.Empty, // suffix
                            matrixList.ElementAt(i).IntMinNumberLength.ToString() ?? string.Empty, // minimum length ,
                            matrixList.ElementAt(i).intNumberNextValue ?? string.Empty,                                                                    // 
                            matrixList.ElementAt(i).PreviousNumber.ToString() ?? string.Empty,
                            matrixList.ElementAt(i).NextNumber.ToString() ?? string.Empty,
                            siteId
                        };
                        tableData.data.Add(cols);
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
        [Route("EditUniqueNumberingSchema")]
        public async Task<JsonResult> EditUniqueNumberingSchema([FromBody] JsonElement json)
        {
            try
            {
                var jsonObject = JObject.Parse(json.ToString());

                UniqueNumberingSchemaSaveRequestModel request = new()
                {
                    IdfsNumberName = Convert.ToInt64(jsonObject["IdfsNumberName"].ToString()),
                    StrName = jsonObject["StrName"].ToString().Trim()
                };

                if (string.IsNullOrEmpty(jsonObject["IntNextNumberValue"].ToString()))
                {
                    UniqueNumberingSchemaSaveResquestResponseModel responseInvalid = new UniqueNumberingSchemaSaveResquestResponseModel();
                    responseInvalid.ReturnMessage = "INVALID";
                    responseInvalid.StrInvalidRange =
                        $"{_localizer.GetString(ColumnHeadingResourceKeyConstants.UniqueNumberingSchemaNextNumberValueColumnHeading)} {_localizer.GetString(MessageResourceKeyConstants.FieldIsRequiredMessage)}";
                    return Json(responseInvalid);

                }

                var previousNumber = (int?)Convert.ToInt64(jsonObject["PreviousNumber"].ToString());
                var nextNumber = (int?)Convert.ToInt64(jsonObject["NextNumber"].ToString());

                var intNextNumberValue = jsonObject["IntNextNumberValue"].ToString();

                int updatedNextValue;
                if (int.TryParse(intNextNumberValue, out updatedNextValue))
                {

                }
                else
                {
                     updatedNextValue = (int)Convert.ToInt64(jsonObject["NextNumber"].ToString());
                }


                // var updatedNextValue = (int?)Convert.ToInt64(jsonObject["IntNextNumberValue"].ToString());
                request.intNextNumberValue = updatedNextValue;
                request.IntNumberValue = previousNumber.Value;

                if (updatedNextValue <= 9999)
                {
                    if (updatedNextValue <= previousNumber)
                    {
                        UniqueNumberingSchemaSaveResquestResponseModel responseInvalid =
                            new UniqueNumberingSchemaSaveResquestResponseModel();
                        responseInvalid.ReturnMessage ="INVALID";
                        responseInvalid.StrInvalidRange = string.Format(
                            _localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage), previousNumber.Value + 1,
                            "9999");
                        return Json(responseInvalid);
                    }
                }
                else 
                {
                    if (updatedNextValue <= previousNumber)
                    {
                        UniqueNumberingSchemaSaveResquestResponseModel responseInvalid =
                            new UniqueNumberingSchemaSaveResquestResponseModel();
                        responseInvalid.ReturnMessage ="INVALID";
                        responseInvalid.StrInvalidRange =
                            $"{_localizer.GetString(ColumnHeadingResourceKeyConstants.UniqueNumberingSchemaNextNumberValueColumnHeading)} {_localizer.GetString(MessageResourceKeyConstants.NumberIsOutOfRangeMessage)}";
                        return Json(responseInvalid);
                    }
                }

                //if (updatedNextValue <= previousNumber)
                //{
                //    //if (previousNumber >= 9999)
                //    //{
                //    //    UniqueNumberingSchemaSaveResquestResponseModel responseInvalid =
                //    //        new UniqueNumberingSchemaSaveResquestResponseModel();
                //    //    responseInvalid.ReturnMessage = "INVALID";
                //    //    responseInvalid.StrInvalidRange = string.Concat("Next Number Value ", _localizer.GetString(MessageResourceKeyConstants.InvalidFieldMessage));
                //    //    return Json(responseInvalid);
                //    //}

                //    //else
                //    //{
                //    UniqueNumberingSchemaSaveResquestResponseModel responseInvalid =
                //        new UniqueNumberingSchemaSaveResquestResponseModel();
                //    responseInvalid.ReturnMessage = "INVALID";
                //    responseInvalid.StrInvalidRange = string.Format(
                //        _localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage), previousNumber.Value + 1,
                //        "9999");
                //    return Json(responseInvalid);
                //    //}


                //}


                //if (updatedNextValue > 9999)
                //{
                //    UniqueNumberingSchemaSaveResquestResponseModel responseInvalid =
                //        new UniqueNumberingSchemaSaveResquestResponseModel();
                //    responseInvalid.ReturnMessage = "INVALID";
                //    responseInvalid.StrInvalidRange = string.Concat("Next Number Value ", _localizer.GetString(MessageResourceKeyConstants.InvalidFieldMessage));
                //    return Json(responseInvalid);
                //}

                request.StrSpecialCharacter = jsonObject["StrSpecialCharacter"].ToString();
                request.StrSuffix = jsonObject["StrSuffix"].ToString();
                request.LangId = GetCurrentLanguage();
                var jsonstr = Newtonsoft.Json.JsonConvert.SerializeObject(request);
                UniqueNumberingSchemaSaveResquestResponseModel response = await _numberingSchemaClient.SaveUniqueNumberingSchemaAsync(request);
                return Json(response);

                //return null;
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }


      
        [HttpPost]
        public async Task<IActionResult> ShowPrintBarCodeScreen([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                var printViewModel = new UniqueNumberSchemaPrintModel
                {
                    TypeOfBarCodeLabel = jsonObject["TypeOfBarCodeLabel"].ToString(),
                    TypeOfBarCodeLabelName = jsonObject["TypeOfBarCodeLabelName"].ToString(),
                    LanguageId = GetCurrentLanguage(),
                    NoOfLabelsToPrint = jsonObject["NoOfLabelsToPrint"].ToString(),
                    Prefix = jsonObject["Prefix"].ToString(),
                    Site = jsonObject["Site"].ToString(),
                    Year = jsonObject["Year"].ToString(),
                    Date = jsonObject["Date"].ToString(),
                    ReportName = "PrintBarcodes",
                    //ReportHeader = _localizer.GetString(HeadingResourceKeyConstants.PrintBarcodesPageHeading),
                    ReportLanguageModels = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage()),
                    isPrefixChecked = true,
                    isSiteChecked = true,
                    isDateChecked = false,
                    isYearChecked = true,
                    ShowBarCodePrintArea=false,
                    PrintDateTime = DateTime.Parse(jsonObject["printDateTime"].ToString().ToString(uiCultureInfo))

                };

                
                //printViewModel.PrintParameters = new List<KeyValuePair<string, string>>();
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("TypeOfBarCodeLabel", printViewModel.TypeOfBarCodeLabel));
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("LangID", printViewModel.LanguageId));
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("NoOfLabelsToPrint", printViewModel.NoOfLabelsToPrint));
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Prefix", "1"));
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Site", printViewModel.Site));
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Year", printViewModel.Year));
                //printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Date", printViewModel.Date == "true" ? "1" : "0"));

                printViewModel.BarcodeParametersJSON = System.Text.Json.JsonSerializer.Serialize(printViewModel.PrintParameters);



                return PartialView("_PrintBarCodePartial", printViewModel);
            }
            catch (Exception)
            {
                throw;
            }
        }


        [HttpPost]
        public async Task<IActionResult> PrintBarCode([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString());
                var LanguageId = jsonObject["languageId"].ToString();
                var showBarCodePrintArea = jsonObject["showBarCodePrintArea"].ToString();

                var printViewModel = new UniqueNumberSchemaPrintModel
                {
                    TypeOfBarCodeLabel = jsonObject["typeOfBarCodeLabel"].ToString(),
                    LanguageId = jsonObject["languageId"].ToString(),
                    ReportLanguageModels = await _crossCuttingClient.GetReportLanguageList(LanguageId),
                    NoOfLabelsToPrint = jsonObject["noOfLabelsToPrint"].ToString(),
                    Prefix = jsonObject["prefix"].ToString(),
                    Site = jsonObject["site"].ToString(),
                    Year = jsonObject["year"].ToString(),
                    //Date = jsonObject["date"].ToString(),
                    isDateChecked = Convert.ToBoolean(jsonObject["isDateChecked"]),
                    isPrefixChecked = Convert.ToBoolean(jsonObject["isPrefixChecked"]),
                    isSiteChecked = Convert.ToBoolean(jsonObject["isSiteChecked"]),
                    isYearChecked = Convert.ToBoolean(jsonObject["isYearChecked"]),
                    TypeOfBarCodeLabelName = jsonObject["typeOfBarCodeLabelName"].ToString(),
                    ReportName = "PrintBarcodes",
                    ShowBarCodePrintArea = showBarCodePrintArea == "true",
                    PrintDateTime = DateTime.Parse(jsonObject["printDateTime"].ToString(), new CultureInfo("en-US"))


                };


                printViewModel.PrintParameters = new List<KeyValuePair<string, string>>();
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("TypeOfBarCodeLabel", printViewModel.TypeOfBarCodeLabel));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("LangID", printViewModel.LanguageId));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("NoOfLabelsToPrint", printViewModel.NoOfLabelsToPrint));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Prefix", printViewModel.isPrefixChecked ? "1":"0"));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Site", printViewModel.isSiteChecked ? printViewModel.Site.ToString():""));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Year", printViewModel.isYearChecked ? "1":"0"));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("Date", printViewModel.isDateChecked ? "1" : "0"));
                printViewModel.PrintParameters.Add(new KeyValuePair<string, string>("PrintDateTime",
                    printViewModel.PrintDateTime.ToString(uiCultureInfo)));


                printViewModel.BarcodeParametersJSON = System.Text.Json.JsonSerializer.Serialize(printViewModel.PrintParameters);



                return PartialView("_PrintBarCodePartial", printViewModel);
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
