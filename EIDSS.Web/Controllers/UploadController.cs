using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.VisualBasic.FileIO;
using System;
using System.Collections.Generic;
using EIDSS.Localization.Constants;
using Microsoft.Extensions.Localization;
using System.Globalization;
using EIDSS.Web.Abstracts;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using System.Linq;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;

namespace EIDSS.Web.Controllers
{
    public class UploadController : BaseController
    {
        #region Dependencies

        private IBaseReferenceClient _baseReferenceClient;
        private IStringLocalizer _localizer;
        private IConfigurationClient _configurationClient;
        ICrossCuttingClient _crossCuttingClient;
        IAdminClient _adminClient;
        IStatisticalTypeClient StatisticalTypeClient;

        #endregion Dependencies

        string StatisticalPeriodType = String.Empty;
        string ParameterType = String.Empty;
        string StatisticalAreaType = string.Empty;
        long selectedAreaType = 0;
        long idfsStatisticalAgetype = 0;
        bool showAgeGroups = false;
        bool isHumanGenderSelected = false;

        StatisticalDataFileModel statisticalDataFileModel;        

        public UploadController(IBaseReferenceClient baseReferenceClient, ICrossCuttingClient crossCuttingClient, IAdminClient adminClient, IStringLocalizer localizer, IStatisticalTypeClient statisticalTypeClient, IConfigurationClient configurationClient, ILogger<UploadController> logger) : base(logger)
        {
            _baseReferenceClient = baseReferenceClient;
            _crossCuttingClient= crossCuttingClient;
            _adminClient= adminClient;
            _localizer= localizer;
            statisticalDataFileModel= new StatisticalDataFileModel();
            statisticalDataFileModel.GoodRows = new List<USP_ADMIN_STAT_SETResultRequestModel>();
            StatisticalTypeClient = statisticalTypeClient;
            _configurationClient= configurationClient;
        }
            
        [HttpPost("upload/StatisticalData")]
        public  async Task<JsonResult> StatisticalData(IFormFile file)
        {
            if (file != null)
            {
                Dictionary<string, string> lookup = new Dictionary<string, string>();
                //statisticalDataFileModel.MessageList = new List<List<StatisticalDataImportError>>();
                statisticalDataFileModel.ErrorMessagesList = new();


                List<USP_ADMIN_STAT_SETResultRequestModel> resuestList = new List<USP_ADMIN_STAT_SETResultRequestModel>();
                List<string[]> rows = new List<string[]>();

                try
                {                                        
                    using (TextFieldParser textFieldParser = new TextFieldParser(file.OpenReadStream()))
                    {
                        //USP_ADMIN_STAT_SETResultRequestModel saveRequest = new USP_ADMIN_STAT_SETResultRequestModel();

                        //saveRequest.bulkImport = true;
                        textFieldParser.TextFieldType = FieldType.Delimited;
                        textFieldParser.SetDelimiters(",");
                        DateTime resDate;
                        int resVal;
                        int rowNumber = 0;
                        int errorCount = 0;
                        double periodType = 0;
                        bool rowHasError;                        

                        // start looping through every row in the csv
                        while (!textFieldParser.EndOfData)
                        {
                            USP_ADMIN_STAT_SETResultRequestModel saveRequest = new USP_ADMIN_STAT_SETResultRequestModel();
                            saveRequest.bulkImport = true;

                            rowHasError = false;
                            string[] row = textFieldParser.ReadFields();

                            // check if it's not a csv file
                            if (file.ContentType != "text/csv")
                            {
                                //List<StatisticalDataImportError> msg = new List<StatisticalDataImportError>();
                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                {
                                    Row = string.Empty,
                                    LineNumber = string.Empty,
                                    ColumnNumber = string.Empty,                                    
                                    ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataThefileformatisincorrectPleaseselectproperfileformatMessage),
                                    Type = 1
                                });

                                errorCount++;
                                statisticalDataFileModel.IsIncorrectFileFormat = true;
                                //statisticalDataFileModel.MessageList.Add(msg);
                                rows.Add(row);
                                break;
                            }
                            
                            if (row.Length != 12)
                            {
                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                {
                                    Row = rowNumber.ToString(),
                                    LineNumber = rowNumber.ToString(),
                                    ColumnNumber = string.Empty,
                                    ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidnumberoffieldsinlineLinemustcontains8fieldsseparatedbycommaMessage)
                                });

                                errorCount++;
                                rowHasError = true;
                                //statisticalDataFileModel.MessageList.Add(msg);                                

                                // abort import if the header row doesn't have exactly 12 columns
                                if (rowNumber == 0)
                                {
                                    rows.Add(row);
                                    break;
                                }
                            }

                            // skip first row (header row)
                            if (rowNumber > 0)
                            {
                                //List<StatisticalDataImportError> msg = new List<StatisticalDataImportError>();

                                //if (file.ContentType != "text/csv")
                                //{
                                //    msg.Add(new StatisticalDataImportError()
                                //    {
                                //        Row = string.Empty,
                                //        lineNumber = string.Empty,
                                //        ColumnNumber = string.Empty,
                                //        ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataThefileformatisincorrectPleaseselectproperfileformatMessage),
                                //        Type = 1
                                //    });
                                //    errorCount++;
                                //    statisticalDataFileModel.message.Add(msg);
                                //    rows.Add(row);
                                //    break;
                                //}

                                // file should have exactly 12 columns
                                //if (row.Length != 12)
                                //{
                                //    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                //    {
                                //        Row = rowNumber.ToString(),
                                //        LineNumber = rowNumber.ToString(),
                                //        ColumnNumber = string.Empty,
                                //        ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidnumberoffieldsinlineLinemustcontains8fieldsseparatedbycommaMessage)
                                //    });

                                //    errorCount++;
                                //    //statisticalDataFileModel.MessageList.Add(msg);
                                //    rows.Add(row);
                                //    break;
                                //}

                                #region STATISTICAL DATA TYPE   
                                
                                if (String.IsNullOrEmpty(row[0]))
                                {
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[0], "1"),
                                        ColumnNumber = "1",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "1") + 
                                        " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    //rows.Add(row);
                                    rowHasError = true;
                                }
                                else 
                                {
                                    //LOOK UP IN DICTIONARY
                                    if (lookup.ContainsKey(row[0]))
                                    {
                                        saveRequest.idfsStatisticDataType = long.Parse(lookup[row[0]]);
                                    }
                                    else
                                    {                                                                          
                                        ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                                        request.ReferenceTypeIds = "19000090";
                                        request.MaxPagesPerFetch = 10;
                                        request.PageSize = 100;
                                        request.LanguageId = GetCurrentLanguage();
                                        request.PaginationSet = 1; 
                                        request.Term = row[0];

                                        List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                                        list = await _crossCuttingClient.GetReferenceTypesByIdPaged(request);

                                        BaseReferenceTypeListViewModel baseRefVal = new BaseReferenceTypeListViewModel();
                                        var baseRefList = from x in list where x.Name == row[0] select x;

                                        if (baseRefList != null)
                                        {                                           
                                            if (baseRefList.Count() > 0)
                                            {
                                                baseRefVal = baseRefList.ToList()[0];

                                                if (baseRefVal != null)
                                                {
                                                    //ASSIGN TO COLLECTION THAT WILL BE INSERTED AND ASSIGN TO DICTIONARY FOR NEXT PASS
                                                    saveRequest.idfsStatisticDataType = long.Parse(baseRefVal.BaseReferenceId.ToString());
                                                    lookup.Add(baseRefVal.Name, baseRefVal.BaseReferenceId.ToString());

                                                    //Get StatisticalData
                                                    List<BaseReferenceEditorsViewModel> stlvm = await GetStatisticalData(baseRefVal.BaseReferenceId);

                                                    if (stlvm.Count > 0)
                                                    {
                                                        StatisticalPeriodType = stlvm[0].StrStatisticPeriodType;
                                                        ParameterType = stlvm[0].StrParameterType;
                                                        StatisticalAreaType = stlvm[0].StrStatisticalAreaType;
                                                        selectedAreaType = stlvm[0].IdfsStatisticAreaType;
                                                        idfsStatisticalAgetype = stlvm[0].idfsAgeType;

                                                        if (stlvm[0].blnStatisticalAgeGroup == true)
                                                        {
                                                            showAgeGroups = stlvm[0].blnStatisticalAgeGroup;
                                                        }
                                                        else
                                                        {
                                                            showAgeGroups = false;
                                                        }

                                                        if (stlvm[0].IdfsReferenceType == 19000043)
                                                        {
                                                            isHumanGenderSelected = true;
                                                        }
                                                        else
                                                        {
                                                            isHumanGenderSelected = false;
                                                        }                                                        
                                                    }
                                                    else
                                                    {
                                                        statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                        {
                                                            Row = rowNumber.ToString(),
                                                            LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[0], "1"),
                                                            ColumnNumber = "1",
                                                            ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "1") + " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataThedataappearstobecorruptedatpositionXMessage)
                                                        });

                                                        errorCount++;
                                                        //statisticalDataFileModel.MessageList.Add(msg);
                                                        //rows.Add(row);
                                                        rowHasError = true;
                                                    }
                                                }
                                                else
                                                {
                                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                    {
                                                        Row = rowNumber.ToString(),
                                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[0], "1"),
                                                        ColumnNumber = "1",
                                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "1") + " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                                    });

                                                    errorCount++;
                                                    //statisticalDataFileModel.MessageList.Add(msg);
                                                    rowHasError = true;
                                                }
                                            }
                                            else
                                            {                                                
                                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                {
                                                    Row = rowNumber.ToString(),
                                                    LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidstatisticaldatatypeValueXisemptyornotfoundinreferencestableMessage), row[0], "1"),
                                                    ColumnNumber = "1",
                                                    ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "1") + " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                                });                                             

                                                errorCount++;
                                                //statisticalDataFileModel.MessageList.Add(msg);
                                                //rows.Add(row);
                                                rowHasError = true;
                                            }                                        
                                        }
                                        else
                                        {
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[0], "1"),
                                                ColumnNumber = "1",
                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "1") + " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;
                                        }
                                    }
                                }

                                #endregion STATISTICAL DATA TYPE      

                                #region STATISTICAL PERIOD TYPE

                                if (String.IsNullOrEmpty(row[1]))
                                {
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[1], "2"),
                                        ColumnNumber = "2",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "2") + " " + String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidstatisticaldatatypeValueXisemptyornotfoundinreferencestableMessage), row[1])
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                    //rows.Add(row);
                                }
                                else  // look up
                                {
                                    if (lookup.ContainsKey(row[1]))
                                    {
                                        saveRequest.idfsStatisticPeriodType = long.Parse(lookup[row[1]]);
                                        periodType = long.Parse(lookup[row[1]]);
                                    }
                                    else
                                    {
                                                                       
                                        ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                                        request.ReferenceTypeIds = "19000091";
                                        request.MaxPagesPerFetch = 10;
                                        request.PageSize = 100;
                                        request.LanguageId = GetCurrentLanguage();
                                        request.PaginationSet = 1; 
                                        request.Term = row[1];

                                        List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                                        list = await _crossCuttingClient.GetReferenceTypesByIdPaged(request);

                                        BaseReferenceTypeListViewModel baseRefVal = new BaseReferenceTypeListViewModel();
                                        var baseRefList = from x in list where x.Name == row[1] select x;

                                        if (baseRefList.Count() > 0)
                                        {
                                            baseRefVal = baseRefList.ToList()[0];
                                            saveRequest.idfsStatisticPeriodType = long.Parse(baseRefVal.BaseReferenceId.ToString());
                                            periodType = long.Parse(baseRefVal.BaseReferenceId.ToString());
                                            lookup.Add(baseRefVal.Name, baseRefVal.BaseReferenceId.ToString());
                                        }
                                        else
                                        {
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[1], "2"),
                                                ColumnNumber = "2",
                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "2") + " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;
                                            //rows.Add(row);
                                        }
                                    }
                                }
                                #endregion STATISTICAL PERIOD TYPE

                                #region START DATE FOR PERIOD

                                if (String.IsNullOrEmpty(row[2]))
                                {
                                    //Country
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[2], "3"),
                                        ColumnNumber = "3",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "3") + " " + _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)                                        
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                }
                                else if (!DateTime.TryParse(row[2], out resDate))
                                {
                                    //Date
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[2], "3"),
                                        ColumnNumber = "3",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "3") + " " + String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvaliddateformatStringXcantbeconvertedtodateAlldatesmustbepresentedinformat_ddmmyyyy_Message), row[2])
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                }
                                else
                                {
                                    DateTime toDate = new DateTime();
                                    DateTime fromDate = new DateTime();

                                    if (periodType == 10091005)
                                    {
                                        fromDate = new DateTime(resDate.Year, 1, 1);
                                        toDate = new DateTime(resDate.Year, 12, 31);
                                    }

                                    if (periodType == 10091003)
                                    {
                                        if (resDate.Month <= 3)
                                        {
                                            fromDate = new DateTime(resDate.Year, 1, 1);
                                            toDate = new DateTime(resDate.Year, 3, 31);
                                        }
                                        if (resDate.Month > 3 && resDate.Month <= 6)
                                        {
                                            fromDate = new DateTime(resDate.Year, 4, 1);
                                            toDate = new DateTime(resDate.Year, 6, 30);
                                        }
                                        if (resDate.Month > 6 && resDate.Month <= 9)
                                        {
                                            fromDate = new DateTime(resDate.Year, 7, 1);
                                            toDate = new DateTime(resDate.Year, 9, 30);
                                        }
                                        if (resDate.Month > 9 && resDate.Month <= 12)
                                        {
                                            fromDate = new DateTime(resDate.Year, 10, 1);
                                            toDate = new DateTime(resDate.Year, 12, 31);
                                        }
                                    }

                                    if (periodType == 10091001)
                                    {
                                        fromDate = new DateTime(resDate.Year, resDate.Month, 1);
                                        toDate = new DateTime(resDate.Year, resDate.Month, 1).AddMonths(1).AddDays(-1);
                                    }

                                    if (periodType == 10091004)
                                    {
                                        fromDate = GetFirstDayOfWeek(resDate);
                                        toDate = resDate.AddDays(7);
                                    }

                                    if (periodType == 10091002)
                                    {
                                        fromDate = resDate;
                                        toDate = resDate;
                                    }

                                    saveRequest.datStatisticStartDate = fromDate;
                                    saveRequest.datStatisticFinishDate = toDate;
                                }
                                /*
                                 * MessageResourceKeyConstants.StatisticalDataDateXisnotvalidstartmonthdateMessage
                                    MessageResourceKeyConstants.StatisticalDataDateXisnotvalidstartquarterdateMessage
                                    MessageResourceKeyConstants.StatisticalDataDateXisnotvalidstartweekdateMessage
                                    MessageResourceKeyConstants.StatisticalDataDateXisnotvalidstartyeardateMessage
                                 * */

                                #endregion START DATE FOR PERIOD

                                #region STATISTICAL AREA TYPE

                                if (String.IsNullOrEmpty(row[3]))
                                {
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[3], "4"),
                                        ColumnNumber = "4",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "4") + " " + 
                                            _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                }
                                else
                                {
                                    if (lookup.ContainsKey(row[3]))
                                    {
                                        saveRequest.idfsStatisticAreaType = long.Parse(lookup[row[3]]);
                                    }
                                    else
                                    {                                                                                
                                        ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                                        request.ReferenceTypeIds = "19000089";
                                        request.MaxPagesPerFetch = 10;
                                        request.PageSize = 100;
                                        request.LanguageId = GetCurrentLanguage();
                                        request.PaginationSet = 1; 
                                        request.Term = row[3];

                                        List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                                        list = await _crossCuttingClient.GetReferenceTypesByIdPaged(request);

                                        BaseReferenceTypeListViewModel baseRefVal = new BaseReferenceTypeListViewModel();
                                        var baseRefList = from x in list where x.Name == row[3] select x;

                                        if (baseRefList.Count() > 0)
                                        {
                                            baseRefVal = baseRefList.ToList()[0];
                                            lookup.Add(row[3], baseRefVal.BaseReferenceId.ToString());
                                            saveRequest.idfsStatisticAreaType = baseRefVal.BaseReferenceId;
                                        }
                                        else
                                        {
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[3], "4"),
                                                ColumnNumber = "4",
                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "4") + " " + 
                                                    String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidstatisticaldatatypeValueXisemptyornotfoundinreferencestableMessage), row[3])                                                    
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;
                                        }
                                    }
                                }

                                #endregion STATISTICAL AREA TYPE

                                #region COUNTRY   
                                
                                if (String.IsNullOrEmpty(row[4]))
                                {
                                    //Country
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message),row[4], "5"),
                                        ColumnNumber = "5",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "5") + " " + 
                                            _localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidcountrynameValueXisemptyornotfoundinreferencestableMessage)
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;                                    
                                }
                                else
                                {
                                    CountryModel country = new CountryModel();

                                    if (lookup.ContainsKey(row[4]))
                                    {
                                        saveRequest.LocationUserControlidfsCountry = long.Parse(lookup[row[4]]);                                        
                                        country.idfsCountry = (long)saveRequest.LocationUserControlidfsCountry;
                                    }
                                    else
                                    {
                                        List<CountryModel> countryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage());

                                        if (countryList != null)
                                        {
                                            var countryBaseRef = from cntry in countryList where cntry.strCountryName == row[4] select cntry;
                                            if (countryBaseRef != null && countryBaseRef.Count() > 0)
                                            {
                                                country = countryBaseRef.ToList()[0];
                                                long idfsCountry = country.idfsCountry;
                                                lookup.Add(row[4], country.idfsCountry.ToString());
                                                saveRequest.LocationUserControlidfsCountry = country.idfsCountry;                                                
                                            }
                                            else
                                            {
                                                //Country
                                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                {
                                                    Row = rowNumber.ToString(),
                                                    LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[4], "5"),
                                                    ColumnNumber = "5",
                                                    ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "5") + " " + 
                                                        String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidcountrynameValueXisemptyornotfoundinreferencestableMessage), row[4])
                                                });

                                                errorCount++;
                                                //statisticalDataFileModel.MessageList.Add(msg);
                                                rowHasError = true;
                                            }
                                        }
                                        else
                                        {
                                            //Country
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[4], "5"),
                                                ColumnNumber = "5",
                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "5") + " " + 
                                                    String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidcountrynameValueXisemptyornotfoundinreferencestableMessage), row[4])
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;

                                        }
                                    }

                                    // REGION
                                    if (String.IsNullOrEmpty(row[5]))
                                    {
                                        saveRequest.LocationUserControlidfsRegion = null;
                                    }
                                    else if (lookup.ContainsKey(row[5]))
                                    {
                                        saveRequest.LocationUserControlidfsRegion = long.Parse(lookup[row[5]]);
                                    }
                                    else
                                    {
                                        List<GisLocationChildLevelModel> childLevels = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), country.idfsCountry.ToString());
                                        if (childLevels.Count > 0)
                                        {
                                            var regionLevel2List = from x in childLevels where x.Name == row[5] select x;
                                            if (regionLevel2List.Count() > 0)
                                            {
                                                GisLocationChildLevelModel regionLevel2 = regionLevel2List.ToList()[0];
                                                long idfsRegion = regionLevel2.idfsReference.Value;
                                                lookup.Add(row[5], regionLevel2.idfsReference.Value.ToString());
                                                saveRequest.LocationUserControlidfsRegion = regionLevel2.idfsReference.Value;

                                                // RAYON
                                                if (String.IsNullOrEmpty(row[6]))
                                                {
                                                    saveRequest.LocationUserControlidfsRayon = null;
                                                }
                                                else if (lookup.ContainsKey(row[6]))
                                                {
                                                    saveRequest.LocationUserControlidfsRayon = long.Parse(lookup[row[6]]);
                                                }
                                                else
                                                {
                                                    List<GisLocationChildLevelModel> childLevels2 = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), regionLevel2.idfsReference.Value.ToString());
                                                    if (childLevels2.Count > 0)
                                                    {
                                                        var rayonLevel3List = from x in childLevels2 where x.Name == row[6] select x;
                                                        if (rayonLevel3List.Count() > 0)
                                                        {
                                                            GisLocationChildLevelModel rayonLevel3 = rayonLevel3List.ToList()[0];
                                                            long idfsRyaon = rayonLevel3.idfsReference.Value;
                                                            lookup.Add(row[6], rayonLevel3.idfsReference.Value.ToString());
                                                            saveRequest.LocationUserControlidfsRayon = rayonLevel3.idfsReference.Value;

                                                            // SETTLEMENT
                                                            if (String.IsNullOrEmpty(row[7]))
                                                            {
                                                                //SETTLEMENT
                                                                saveRequest.LocationUserControlidfsSettlement = null;
                                                            }
                                                            else if (lookup.ContainsKey(row[7]))
                                                            {
                                                                saveRequest.LocationUserControlidfsSettlement = long.Parse(lookup[row[7]]);
                                                            }
                                                            else
                                                            {
                                                                List<GisLocationChildLevelModel> childLevels3 = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), rayonLevel3.idfsReference.Value.ToString());

                                                                if (childLevels3.Count > 0)
                                                                {
                                                                    var settlementLevel3List = from x in childLevels3 where x.Name == row[7] select x;
                                                                    if (settlementLevel3List.Count() > 0)
                                                                    {
                                                                        GisLocationChildLevelModel settlementLevel3 = settlementLevel3List.ToList()[0];
                                                                        long idfsSettlement = settlementLevel3.idfsReference.Value;
                                                                        lookup.Add(row[7], settlementLevel3.idfsReference.Value.ToString());
                                                                        saveRequest.LocationUserControlidfsSettlement = settlementLevel3.idfsReference.Value;
                                                                    }
                                                                    else
                                                                    {
                                                                        statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                                        {
                                                                            Row = rowNumber.ToString(),
                                                                            LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[7], "8"),
                                                                            ColumnNumber = "8",
                                                                            ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "8") + " " +
                                                                           String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidsettlementnameValueXisemptyornotfoundinreferencestableMessage), row[7])
                                                                        });

                                                                        errorCount++;
                                                                        //statisticalDataFileModel.MessageList.Add(msg);
                                                                        rowHasError = true;
                                                                    }

                                                                }
                                                                else
                                                                {
                                                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                                    {
                                                                        Row = rowNumber.ToString(),
                                                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[7], "8"),
                                                                        ColumnNumber = "8",
                                                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "8") + " " +
                                                                            String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidsettlementnameValueXisemptyornotfoundinreferencestableMessage), row[7])
                                                                    });

                                                                    errorCount++;
                                                                    //statisticalDataFileModel.MessageList.Add(msg);
                                                                    rowHasError = true;
                                                                }
                                                            }
                                                        }
                                                        else
                                                        {
                                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                            {
                                                                Row = rowNumber.ToString(),
                                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[6], "7"),
                                                                ColumnNumber = "7",
                                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "7") + " " +
                                                                    String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidrayonnameValueXisemptyornotfoundinreferencestableMessage), row[6])
                                                            });

                                                            errorCount++;
                                                            //statisticalDataFileModel.MessageList.Add(msg);
                                                            rowHasError = true;
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                //Region
                                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                {
                                                    Row = rowNumber.ToString(),
                                                    LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[5], "6"),
                                                    ColumnNumber = "6",
                                                    ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "6") + " " +
                                                        String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidregionnameValueXisemptyornotfoundinreferencestableMessage), row[5])
                                                });

                                                errorCount++;
                                                //statisticalDataFileModel.MessageList.Add(msg);
                                                rowHasError = true;
                                            }
                                        }
                                        else
                                        {
                                            //Region
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), row[5], "6"),
                                                ColumnNumber = "6",
                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "6") + " " +
                                                    String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidstatisticaldatatypeValueXisemptyornotfoundinreferencestableMessage), row[5])
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;
                                        }
                                    }
                                }

                                #endregion COUNTRY

                                #region STATISTICAL AGE GROUP

                                if (String.IsNullOrEmpty(row[8]))
                                {
                                    saveRequest.idfsStatisticalAgeGroup = null;                                    
                                }
                                else
                                {
                                    if (lookup.ContainsKey(row[8]))
                                    {
                                        saveRequest.idfsStatisticalAgeGroup = long.Parse(lookup[row[8]]);
                                    }
                                    else
                                    {                                        
                                        ReferenceTypeByIdRequestModel ageGroupRequest = new ReferenceTypeByIdRequestModel();
                                        ageGroupRequest.ReferenceTypeIds = "19000145";
                                        ageGroupRequest.MaxPagesPerFetch = 10;
                                        ageGroupRequest.PageSize = 100;
                                        ageGroupRequest.LanguageId = GetCurrentLanguage();
                                        ageGroupRequest.PaginationSet = 1; 
                                        ageGroupRequest.Term = row[8];

                                        List<BaseReferenceTypeListViewModel> agegroupList = new List<BaseReferenceTypeListViewModel>();
                                        agegroupList = await _crossCuttingClient.GetReferenceTypesByIdPaged(ageGroupRequest);

                                        BaseReferenceTypeListViewModel baseRefVal = new BaseReferenceTypeListViewModel();
                                        var baseRefList = from x in agegroupList where x.Name == row[8] select x;

                                        if (baseRefList.Count() > 0)
                                        {
                                            baseRefVal = baseRefList.ToList()[0];
                                            if (baseRefVal != null)
                                            {                                                
                                                saveRequest.idfsStatisticalAgeGroup = long.Parse(baseRefVal.BaseReferenceId.ToString());
                                                lookup.Add(baseRefVal.Name, baseRefVal.BaseReferenceId.ToString());
                                            }
                                            else
                                            {
                                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                {
                                                    Row = rowNumber.ToString(),
                                                    LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "9"),
                                                    ColumnNumber = "9",
                                                    ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataThedataappearstobecorruptedatpositionXMessage), "9")
                                                });

                                                errorCount++;
                                                //statisticalDataFileModel.MessageList.Add(msg);
                                                rowHasError = true;                                                
                                            }
                                        }
                                        else
                                        {
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "9"),
                                                ColumnNumber = "9",
                                                ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;                                            
                                        }
                                    }
                                }

                                #endregion STATISTICAL AGE GROUP
                                
                                #region PARAMETER TYPE

                                if (String.IsNullOrEmpty(row[9]))
                                {
                                    saveRequest.idfsParameterName = null;                                                                       
                                }
                                else
                                {
                                    if (lookup.ContainsKey(row[9]))
                                    {
                                        saveRequest.idfsParameterName = long.Parse(lookup[row[9]]);
                                    }
                                    else
                                    {                                        
                                        var request = new ParameterReferenceGetRequestModel()
                                        {
                                            LanguageId = GetCurrentLanguage(),
                                            SortColumn = "NationalName",
                                            SortOrder = "asc"
                                        };

                                        List<ParameterReferenceViewModel> parameterTypeslist = await _configurationClient.GetParameterReferenceList(request);
                                        BaseReferenceTypeListViewModel baseRefVal = new BaseReferenceTypeListViewModel();
                                        var baseRefList = from x in parameterTypeslist where x.NationalName == row[9] select x;

                                        if (baseRefList.Count() > 0)
                                        {
                                            var parameterVals = baseRefList.ToList();
                                            if (parameterVals.Count() > 0)
                                            {
                                                //ASSIGN TO COLLECTION THAT WILL BE INSERTED AND ASSIGN TO DICTIONARY FOR NEXT PASS
                                                saveRequest.idfsParameterName = parameterVals[0].IdfsReferenceType;
                                                lookup.Add(row[9], saveRequest.idfsParameterName.ToString());
                                            }
                                            else
                                            {
                                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                {
                                                    Row = rowNumber.ToString(),
                                                    LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "10"),
                                                    ColumnNumber = "10",
                                                    ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataThedataappearstobecorruptedatpositionXMessage), "10")
                                                });

                                                errorCount++;
                                                //statisticalDataFileModel.MessageList.Add(msg);
                                                rowHasError = true;
                                            }
                                        }
                                        else
                                        {
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "10"),
                                                ColumnNumber = "10",
                                                ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;
                                        }
                                    }
                                }

                                #endregion PARAMETER TYPE
                                
                                #region PARAMETER

                                if (String.IsNullOrEmpty(row[10]))
                                {
                                    saveRequest.idfsParameterName = null;                                    
                                }
                                else
                                {
                                    if (lookup.ContainsKey(row[10]))
                                    {
                                        saveRequest.idfsParameterName = saveRequest.idfsMainBaseReference = long.Parse(lookup[row[10]]);
                                        //saveRequest.idfsMainBaseReference = saveRequest.idfsParameterName;
                                    }
                                    else
                                    {
                                        ReferenceTypeByIdRequestModel parameterRequest = new ReferenceTypeByIdRequestModel();
                                        parameterRequest.ReferenceTypeIds = "19000043";
                                        parameterRequest.MaxPagesPerFetch = 10;
                                        parameterRequest.PageSize = 100;
                                        parameterRequest.LanguageId = GetCurrentLanguage();
                                        parameterRequest.PaginationSet = 1;

                                        List<BaseReferenceTypeListViewModel> parameterlist = new List<BaseReferenceTypeListViewModel>();
                                        parameterlist = await _crossCuttingClient.GetReferenceTypesByIdPaged(parameterRequest);

                                        BaseReferenceTypeListViewModel baseRefVal = new BaseReferenceTypeListViewModel();
                                        var baseRefList = from x in parameterlist where x.Name == row[10] select x;

                                        if (baseRefList.Count() > 0)
                                        {
                                            baseRefVal = baseRefList.ToList()[0];
                                            if (baseRefVal != null)
                                            {                                                
                                                saveRequest.idfsParameterName = saveRequest.idfsMainBaseReference = baseRefVal.BaseReferenceId;
                                                //saveRequest.idfsMainBaseReference = saveRequest.idfsParameterName;
                                                lookup.Add(baseRefVal.Name, baseRefVal.BaseReferenceId.ToString());
                                            }
                                            else
                                            {
                                                statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                                {
                                                    Row = rowNumber.ToString(),
                                                    LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "11"),
                                                    ColumnNumber = "11",
                                                    ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataThedataappearstobecorruptedatpositionXMessage), "11")
                                                });

                                                errorCount++;
                                                //statisticalDataFileModel.MessageList.Add(msg);
                                                rowHasError = true;
                                            }
                                        }
                                        else
                                        {
                                            statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                            {
                                                Row = rowNumber.ToString(),
                                                LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "11"),
                                                ColumnNumber = "11",
                                                //ErrorMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidparameternameValueXisemptyornotfoundinreferencestableMessage).ToString, row[10])


                                                ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "11") + " " +
                                                    String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidparameternameValueXisemptyornotfoundinreferencestableMessage), row[10])

                                                 //ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "5") + " " +
                                                 //   String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidcountrynameValueXisemptyornotfoundinreferencestableMessage), row[4])
                                            });

                                            errorCount++;
                                            //statisticalDataFileModel.MessageList.Add(msg);
                                            rowHasError = true;
                                        }
                                    }
                                }
                                #endregion PARAMETER
                                                                
                                #region VALUE

                                if (String.IsNullOrEmpty(row[11]))
                                {
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "12"),
                                        ColumnNumber = "12",
                                        ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataFieldismissedMessage)
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                }
                                else if (!int.TryParse(row[11], out resVal))
                                {
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "12"),
                                        ColumnNumber = "12",
                                        ErrorMessage = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataInvalidstatisticvalueStringXcantbeconvertedtointegerMessage), row[11])
                                    });

                                    errorCount++;
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                }
                                else
                                {
                                    saveRequest.varValue = Int32.Parse(row[11]);
                                }

                                #endregion VALUE


                                if (errorCount > 10)
                                {
                                    statisticalDataFileModel.ErrorMessagesList.Add(new StatisticalDataImportError()
                                    {
                                        Row = rowNumber.ToString(),
                                        LineNumber = String.Format(_localizer.GetString(MessageResourceKeyConstants.StatisticalDataLine0Column1Message), rowNumber.ToString(), "12"),
                                        ColumnNumber = "12",
                                        ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.StatisticalDataDatawasnotimportedInputdatacontainstoomanyerrorsMaximumErrorNumberisexceededMessage)
                                    });
                                    
                                    //statisticalDataFileModel.MessageList.Add(msg);
                                    rowHasError = true;
                                    rows.Add(row);
                                    break;
                                }


                                rows.Add(row);
                                
                                if(!rowHasError) statisticalDataFileModel.GoodRows.Add(saveRequest);                                
                            }

                            rowNumber++;
                        } // while loops end here

                        statisticalDataFileModel.ErrorCount = errorCount; // loop ends here
                    }

                    statisticalDataFileModel.rows = rows;
                }
                catch (Exception ex)
                {
                    // return StatusCode(500, ex.Message);
                }
            }
            return Json(statisticalDataFileModel);
        }

         
        public DateTime GetFirstDayOfWeek(DateTime dayInWeek)
        {
            try
            {
                CultureInfo defaultCultureInfo = CultureInfo.CurrentCulture;
                return GetFirstDayOfWeek(dayInWeek, defaultCultureInfo);
            }
            catch (Exception ex)
            {

                _logger.LogError(ex.Message);
                throw;
            }
        }

        /// <summary>
        /// Returns the first day of the week that the specified date 
        /// is in. 
        /// </summary>
        public DateTime GetFirstDayOfWeek(DateTime dayInWeek, CultureInfo cultureInfo)
        {
            DayOfWeek firstDay = cultureInfo.DateTimeFormat.FirstDayOfWeek;
            DateTime firstDayInWeek = dayInWeek.Date;
            while (firstDayInWeek.DayOfWeek != firstDay)
                firstDayInWeek = firstDayInWeek.AddDays(-1);

            return firstDayInWeek;
        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetStatisticalData(long idfsStatisticDataType)
        {
            var request = new StatisticalTypeGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 10,
                SortColumn = "strName",
                SortOrder = "asc",
                idfsStatisticDataType = idfsStatisticDataType
            };

            List<BaseReferenceEditorsViewModel> stlvm = await StatisticalTypeClient.GetStatisticalTypeList(request);
            IEnumerable<BaseReferenceEditorsViewModel> StatisticalTypeList = stlvm;
            return stlvm;                       
        }

        [HttpPost("upload/multiple")]
        public IActionResult Multiple(IFormFile[] files)
        {
            try
            {
                // Put your code here
                return StatusCode(200);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPost("upload/{id}")]
        public IActionResult Post(IFormFile[] files, int id)
        {
            try
            {
                // Put your code here
                return StatusCode(200);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }
    }
}
