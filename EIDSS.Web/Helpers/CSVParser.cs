using EIDSS.Web.ViewModels.Administration;
using EIDSS.ClientLibrary.Enumerations;
using System.IO;
using System.Text;
using Microsoft.AspNetCore.Http;
using System;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using System.Linq;
using EIDSS.ClientLibrary.ApiClients.Admin;

namespace EIDSS.Web.Helpers
{
    public class CSVParser
    {

        //private ICrossCuttingClient _crossCuttingAPIClient;
        //private IStatisticalTypeClient _StatisticalTypeClient;

        //public CSVParser(ICrossCuttingClient crossCuttingAPIClient, IStatisticalTypeClient statisticalTypeClient)
        //{
        //    _crossCuttingAPIClient = crossCuttingAPIClient;
        //    _StatisticalTypeClient = statisticalTypeClient;
        //}
        //public void ProcessRequest(HttpContext context)
        //{
        //    if (context.Request.Files.Count > 0)
        //    {
        //        int totalRecords = 0;
        //        int recordsAdded = 0;
        //        int errorCount = 0;
        //        string message = string.Empty;
        //        string errorMessages = string.Empty;
        //        int rowNum = 0;
        //        var statDataParams = new AdminSetStatParams();
        //        statisticDataTypeServiceClient = new StatisticDataTypeServiceClient();
        //        statisticDataAdminAPIClient = new StatisticalDataAdminServiceClient();
        //        crossCuttingAPIClient = new CrossCuttingServiceClient();
        //        string[] currentRow;
        //        statisticalDataTypes = statisticDataTypeServiceClient.RefStatisticDataTypeGetList("en").Result;

        //        // Fetch the Uploaded File.
        //        HttpPostedFile postedFile = context.Request.Files(0);

        //        // Set the Folder Path.
        //        string folderPath = context.Server.MapPath("~/App_Data/");

        //        // Set the File Name.
        //        string fileName = Path.GetFileName(postedFile.FileName);
        //        string totalFileName = folderPath + fileName;
        //        // Save the File in Folder.
        //        postedFile.SaveAs(totalFileName);
        //        var reader = new TextFieldParser(totalFileName);
        //        reader.TextFieldType = Microsoft.VisualBasic.FileIO.FieldType.Delimited;
        //        reader.SetDelimiters(",");
        //        while (!reader.EndOfData)
        //        {
        //            if (errorCount >= 10)
        //            {
        //                break;
        //            }

        //            rowNum = rowNum + 1;
        //            currentRow = reader.ReadFields();
        //            if (currentRow.Length == 1)
        //            {
        //                currentRow = currentRow[0].Split(";");
        //            }

        //            if (currentRow.Length == 8)
        //            {
        //                RefStatisticdatatypeGetListModel statDataType = statisticalDataTypes.Where(x => Operators.ConditionalCompareObjectEqual(x.strName, currentRow(0), false)).FirstOrDefault();
        //                if (!(statDataType == null))
        //                {
        //                    DateTime? startDate = DateTime.Today;
        //                    if (!DateTime.TryParse(currentRow[1], startDate))
        //                    {
        //                        errorCount = errorCount + 1;
        //                        errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid date format. String " + currentRow[1] + " can't be converted to date. All dates must be presented in format 'mm/dd/yyyy'. " + Constants.vbNewLine;
        //                        continue;
        //                    }

        //                    if (!string.IsNullOrEmpty(currentRow[2]))
        //                    {
        //                        var country = crossCuttingAPIClient.GetCountryList("en").Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strCountryName, currentRow(2), false)).FirstOrDefault;
        //                        if (!(country == null))
        //                        {
        //                            long idfsCountry = country.idfsCountry;
        //                            if (statDataType.strStatisticalAreaType == "Region" | statDataType.strStatisticalAreaType == "Rayon" | statDataType.strStatisticalAreaType == "Settlement")
        //                            {
        //                                var region = crossCuttingAPIClient.GetRegionListAsync("en", statDataParams.locationUserControlidfsCountry, default).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strRegionName, currentRow(3), false)).FirstOrDefault;
        //                                if (!(region == null))
        //                                {
        //                                    long idfsRegion = region.idfsCountry;
        //                                    if (statDataType.strStatisticalAreaType == "Rayon" | statDataType.strStatisticalAreaType == "Settlement")
        //                                    {
        //                                        var rayon = crossCuttingAPIClient.GetRayonListAsync("en", statDataParams.locationUserControlidfsCountry, statDataParams.locationUserControlidfsRegion).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strRayonName, currentRow(4), false)).FirstOrDefault;
        //                                        if (!(rayon == null))
        //                                        {
        //                                            long idfsRayon = rayon.idfsRayon;
        //                                            if (statDataType.strStatisticalAreaType == "Settlement")
        //                                            {
        //                                                var settlement = crossCuttingAPIClient.GetSettlementListAsync("en", idfsRayon, default).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strSettlementName, currentRow(5), false)).FirstOrDefault;
        //                                                if (!(settlement == null))
        //                                                {
        //                                                    statDataParams.idfsUserControlidfsSettlement = settlement.idfsSettlement;
        //                                                }
        //                                                else
        //                                                {
        //                                                    errorCount = errorCount + 1;
        //                                                    errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid settlement. Value '" + currentRow[5] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                                                    continue;
        //                                                }
        //                                            }
        //                                        }
        //                                        else
        //                                        {
        //                                            errorCount = errorCount + 1;
        //                                            errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid rayon. Value '" + currentRow[4] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                                            continue;
        //                                        }
        //                                    }
        //                                }
        //                                else
        //                                {
        //                                    errorCount = errorCount + 1;
        //                                    errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid region. Value '" + currentRow[3] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                                    continue;
        //                                }
        //                            }
        //                        }
        //                        else
        //                        {
        //                            errorCount = errorCount + 1;
        //                            errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid country. Value '" + currentRow[2] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                            continue;
        //                        }
        //                    }

        //                    if (statDataType.blnStatisticalAgeGroup)
        //                    {
        //                        long? idfsStatisticalAgeGroup = crossCuttingAPIClient.GetBaseReferenceList("en", BaseReferenceConstants.StatisticalAgeGroups, HACodeList.HumanHACode).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.name, currentRow(6), false)).FirstOrDefault.idfsBaseReference;
        //                        if (idfsStatisticalAgeGroup is null)
        //                        {
        //                            errorCount = errorCount + 1;
        //                            errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid age group. Value '" + currentRow[6] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                            continue;
        //                        }
        //                    }

        //                    if (!(statDataType.strParameterType == null))
        //                    {
        //                        var parameter = crossCuttingAPIClient.GetBaseReferenceList("en", BaseReferenceConstants.HumanGender, HACodeList.HumanHACode).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.name, currentRow(6), false)).FirstOrDefault;
        //                        if (parameter is object)
        //                        {
        //                            statDataParams.idfsParameterName = parameter.idfsBaseReference;
        //                            statDataParams.idfsMainBaseReference = parameter.idfsBaseReference;
        //                        }
        //                        else
        //                        {
        //                            errorCount = errorCount + 1;
        //                            errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid parameter. Value '" + currentRow[7] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                            continue;
        //                        }
        //                    }

        //                    int value = 0;
        //                    if (string.IsNullOrEmpty(currentRow[7]) | currentRow[7] == null | !int.TryParse(currentRow[7], out value))
        //                    {
        //                        errorCount = errorCount + 1;
        //                        continue;
        //                    }
        //                }
        //                else
        //                {
        //                    errorCount = errorCount + 1;
        //                    errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid statistical data type. Value '" + currentRow[0] + "' is empty or not found in references table. " + Constants.vbNewLine;
        //                    continue;
        //                }
        //            }
        //            else
        //            {
        //                errorCount = errorCount + 1;
        //                errorMessages = errorMessages + "Row " + rowNum + " - " + "Invalid number of fields in line. Line must contains 8 fields separated by semicolon. " + Constants.vbNewLine;
        //                continue;
        //            }
        //        }

        //        if (errorCount == 0)
        //        {
        //            ImportData(totalFileName, totalRecords, recordsAdded);
        //            message = "No Errors";
        //        }
        //        else if (errorCount > 0 & errorCount < 10)
        //        {
        //            message = "Contains Errors";
        //        }
        //        else
        //        {
        //            message = "Maximum Errors Exceeded";
        //        }

        //        // Send File details in a JSON Response.
        //        string json = new JavaScriptSerializer().Serialize(new
        //        {
        //            totalRecords,
        //            recordsAdded,
        //            errorCount,
        //            message,
        //            errorMessages
        //        });
        //        context.Response.StatusCode = HttpStatusCode.OK;
        //        context.Response.ContentType = "text/json";
        //        context.Response.Write(json);
        //        context.Response.End();
        //    }
        //}



        //private async void ImportData(string totalFileName, ref int totalRecords, ref int recordsAdded)
        //{
        //    int errorCount = 0;
        //    string message = string.Empty;
        //    var statDataParams = new AdminSetStatParams();
        //   // _StatisticalTypeClient = new _StatisticalTypeClient();
        //    statisticDataAdminAPIClient = new StatisticalDataAdminServiceClient();
        //   // _crossCuttingAPIClient = new CrossCuttingServiceClient();
        //    string[] currentRow;
        //    statisticalDataTypes = _StatisticalTypeClient.GetStatisticalTypeList().Result;
        //    if (File.Exists(totalFileName))
        //    {
        //        var reader = new TextFieldParser(totalFileName);
        //        reader.TextFieldType = Microsoft.VisualBasic.FileIO.FieldType.Delimited;
        //        reader.SetDelimiters(",");
        //        while (!reader.EndOfData)
        //        {
        //            currentRow = reader.ReadFields();
        //            if (currentRow.Length == 1)
        //            {
        //                currentRow = currentRow[0].Split(";");
        //            }

        //            if (currentRow.Length == 8)
        //            {
        //                RefStatisticdatatypeGetListModel statDataType = statisticalDataTypes.Where(x => Operators.ConditionalCompareObjectEqual(x.strName, currentRow(0), false)).FirstOrDefault();
        //                if (!(statDataType == null))
        //                {
        //                    statDataParams.idfStatistic = null;
        //                    statDataParams.idfsStatisticDataType = statDataType.idfsStatisticDataType;
        //                    statDataParams.idfsStatisticAreaType = statDataType.idfsStatisticAreaType;
        //                    statDataParams.idfsStatisticPeriodType = statDataType.idfsStatisticPeriodType;
        //                    DateTime? startDate = DateTime.Today;
        //                    if (DateTime.TryParse(currentRow[1], startDate))
        //                    {
        //                        statDataParams.datStatisticStartDate = DateTime.Parse(currentRow[1]);
        //                    }
        //                    else
        //                    {
        //                        totalRecords = totalRecords + 1;
        //                        continue;
        //                    }

        //                    statDataParams.datStatisticFinishDate = null;
        //                    if (!string.IsNullOrEmpty(currentRow[2]))
        //                    {
        //                        var country = _crossCuttingAPIClient.GetCountryList("en").Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strCountryName, currentRow(2), false)).FirstOrDefault;
        //                        if (!(country == null))
        //                        {
        //                            statDataParams.locationUserControlidfsCountry = country.idfsCountry;
        //                            if (statDataType.strStatisticalAreaType == "Region" | statDataType.strStatisticalAreaType == "Rayon" | statDataType.strStatisticalAreaType == "Settlement")
        //                            {
        //                                var region = _crossCuttingAPIClient.Getr("en", statDataParams.locationUserControlidfsCountry, default).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strRegionName, currentRow(3), false)).FirstOrDefault;
        //                                if (!(region == null))
        //                                {
        //                                    statDataParams.locationUserControlidfsRegion = region.idfsCountry;
        //                                    if (statDataType.strStatisticalAreaType == "Rayon" | statDataType.strStatisticalAreaType == "Settlement")
        //                                    {
        //                                        var rayon = _crossCuttingAPIClient.GetRayonListAsync("en", statDataParams.locationUserControlidfsCountry, statDataParams.locationUserControlidfsRegion).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strRayonName, currentRow(4), false)).FirstOrDefault;
        //                                        if (!(rayon == null))
        //                                        {
        //                                            statDataParams.idfsUserControlidfsRayon = rayon.idfsRayon;
        //                                            if (statDataType.strStatisticalAreaType == "Settlement")
        //                                            {
        //                                                var settlement = _crossCuttingAPIClient.GetSettlementListAsync("en", statDataParams.idfsUserControlidfsRayon, default).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.strSettlementName, currentRow(5), false)).FirstOrDefault;
        //                                                if (!(settlement == null))
        //                                                {
        //                                                    statDataParams.idfsUserControlidfsSettlement = settlement.idfsSettlement;
        //                                                }
        //                                                else
        //                                                {
        //                                                    totalRecords = totalRecords + 1;
        //                                                    continue;
        //                                                }
        //                                            }
        //                                            else
        //                                            {
        //                                                statDataParams.idfsUserControlidfsSettlement = null;
        //                                            }
        //                                        }
        //                                        else
        //                                        {
        //                                            totalRecords = totalRecords + 1;
        //                                            continue;
        //                                        }
        //                                    }
        //                                    else
        //                                    {
        //                                        statDataParams.idfsUserControlidfsRayon = null;
        //                                        statDataParams.idfsUserControlidfsSettlement = null;
        //                                    }
        //                                }
        //                                else
        //                                {
        //                                    totalRecords = totalRecords + 1;
        //                                    continue;
        //                                }
        //                            }
        //                            else
        //                            {
        //                                statDataParams.locationUserControlidfsRegion = null;
        //                                statDataParams.idfsUserControlidfsRayon = null;
        //                                statDataParams.idfsUserControlidfsSettlement = null;
        //                            }
        //                        }
        //                        else
        //                        {
        //                            totalRecords = totalRecords + 1;
        //                            continue;
        //                        }

        //                        if (statDataType.blnStatisticalAgeGroup)
        //                        {
        //                            var idfsStatisticalAgeGroup = _crossCuttingAPIClient.GetBaseReferenceList("en", BaseReferenceConstants.StatisticalAgeGroups, HACodeList.HumanHACode).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.name, currentRow(6), false)).FirstOrDefault;
        //                            if (idfsStatisticalAgeGroup is object)
        //                            {
        //                                statDataParams.idfsStatisticalAgeGroup = idfsStatisticalAgeGroup.idfsBaseReference;
        //                            }
        //                            else
        //                            {
        //                                totalRecords = totalRecords + 1;
        //                                continue;
        //                            }
        //                        }
        //                        else
        //                        {
        //                            statDataParams.idfsStatisticalAgeGroup = null;
        //                        }

        //                        if (!(statDataType.strParameterType == null))
        //                        {
        //                            var parameter = _crossCuttingAPIClient.GetBaseReferenceList("en", BaseReferenceConstants.HumanGender, HACodeList.HumanHACode).Result.Where(x => Operators.ConditionalCompareObjectEqual(x.name, currentRow(6), false)).FirstOrDefault;
        //                            if (parameter is object)
        //                            {
        //                                statDataParams.idfsParameterName = parameter.idfsBaseReference;
        //                                statDataParams.idfsMainBaseReference = parameter.idfsBaseReference;
        //                            }
        //                            else
        //                            {
        //                                totalRecords = totalRecords + 1;
        //                                continue;
        //                            }
        //                        }
        //                        else
        //                        {
        //                            statDataParams.idfsParameterName = null;
        //                            statDataParams.idfsMainBaseReference = null;
        //                        }

        //                        int value = 0;
        //                        if (string.IsNullOrEmpty(currentRow[7]) | currentRow[7] == null | !int.TryParse(currentRow[7], out value))
        //                        {
        //                            errorCount = errorCount + 1;
        //                            continue;
        //                        }
        //                        else
        //                        {
        //                            statDataParams.varValue = value;
        //                        }

        //                        if (statisticDataAdminAPIClient.SetStatistic(statDataParams).Result(0).ReturnMessage == "SUCCESS")
        //                        {
        //                            recordsAdded = recordsAdded + 1;
        //                        }
        //                        else
        //                        {
        //                            totalRecords = totalRecords + 1;
        //                            continue;
        //                        }
        //                    }
        //                    else
        //                    {
        //                        totalRecords = totalRecords + 1;
        //                        continue;
        //                    }
        //                }
        //                else
        //                {
        //                    totalRecords = totalRecords + 1;
        //                    continue;
        //                }
        //            }

        //            totalRecords = totalRecords + 1;
        //        }
        //    }
        //}


        //}
    }
}
