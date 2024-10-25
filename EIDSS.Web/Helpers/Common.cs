using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Threading;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.RequestModels.CrossCutting;

namespace EIDSS.Web.Helpers
{
    public static class Common
    {
        public static long? ExtractLongValue(JObject jsonObject, string strMainParameter, string strSecondaryParameter)
        {
            JArray a = null;
            long idfs = 0;

            try
            {
                if (jsonObject[strSecondaryParameter] != null)
                {
                    a = JArray.Parse(jsonObject[strSecondaryParameter].ToString());
                }
                else if (jsonObject[strMainParameter] != null)
                {
                    a = JArray.Parse(jsonObject[strMainParameter].ToString());
                }

                if (a != null)
                {
                    if (!long.TryParse(a[0]["id"].ToString(), out idfs))
                    {
                        idfs = (jsonObject[strMainParameter] == null) ? 0 : long.Parse(jsonObject[strMainParameter].ToString());
                    }
                }
            }
            catch (Exception e)
            {

            }

            return idfs == 0 ? null : idfs;
        }

        public static int GetHAcodeTotal(JObject jsonObject, string strHACodeFieldName, ISpeciesTypeClient speciesTypeClient)
        {

            JArray a = JArray.Parse(jsonObject["strHACodeNames"].ToString());

            long intHACodeTotal = 0;
            long intHACode;

            for (int iIndex = 0; iIndex < a.Count; iIndex++)
            {
                if (!long.TryParse(a[iIndex]["id"].ToString(), out intHACode))
                {
                    intHACode = Common.GetHACodeList(a[iIndex]["id"].ToString(), speciesTypeClient);
                }
                intHACodeTotal += intHACode;
            }

            return (int)intHACodeTotal;
        }

        public static long GetHACodeList(string strDefault, ISpeciesTypeClient speciesTypeClient)
        {
            long intHACode = 0;

            var list = speciesTypeClient.GetHACodeList(Thread.CurrentThread.CurrentCulture.Name, (int)AccessoryCodes.HALVHACode).Result;

            foreach (var item in list)
            {
                if (item.CodeName == strDefault)
                {
                    intHACode = item.intHACode;
                    break;
                }
            }

            return intHACode;
        }

        public static Select2DataItem GetYearSelect2DataItem(DateTime date)
        {
            var select2DataItem = new Select2DataItem() { id = date.Year.ToString(), text = date.Year.ToString() };
            return select2DataItem;
        }

        public static Select2DataItem GetMonthSelect2DataItem(DateTime date, string LanguageId)
        {
            CultureInfo ci = new CultureInfo(LanguageId);
            var month = date.ToString("MMMM", ci);
            var select2DataItem = new Select2DataItem() { id = date.Month.ToString(), text = month };
            return select2DataItem;
        }


        public static int GetWeekNumberOfDate(DateTime date,string languageId)
        {
            CultureInfo ciCurr = CultureInfo.CurrentCulture;
            var ci = CultureInfo.GetCultureInfo(languageId);
            int weekNum = ciCurr.Calendar.GetWeekOfYear(date, CalendarWeekRule.FirstFullWeek, ci.DateTimeFormat.FirstDayOfWeek);
            return weekNum;
        }

        public static void GetFirstAndLastDateOfWeek(int year, int weekOfYear, string LanguageId, ref DateTime firstDay, ref DateTime lastDay)
        {
            var ci = CultureInfo.GetCultureInfo(LanguageId);
            DateTime jan1 = new DateTime(year, 1, 1);
            int daysOffset = System.Convert.ToInt32(ci.DateTimeFormat.FirstDayOfWeek) - System.Convert.ToInt32(jan1.DayOfWeek) + 7;
            DateTime firstWeekDay = jan1.AddDays(daysOffset);
            int firstWeek = ci.Calendar.GetWeekOfYear(jan1, ci.DateTimeFormat.CalendarWeekRule, ci.DateTimeFormat.FirstDayOfWeek);

            // If (firstWeek <= 1 OrElse firstWeek >= 52) AndAlso daysOffset >= -3 Then

            if ((firstWeek <= 1 || firstWeek >= 52))
                weekOfYear -= 1;

            firstDay = firstWeekDay.AddDays(weekOfYear * 7);
            lastDay = firstDay.AddDays(6);
        }


        public static Select2DataItem GetWeekSelect2DataItem(DateTime date, string LanguageId)
        {

            CultureInfo cul = CultureInfo.GetCultureInfo(LanguageId);
            var weekNumber = GetWeekNumberOfDate(date, LanguageId);

            DateTime weekStartDate = default;
            DateTime weekEndDate = default;

            GetFirstAndLastDateOfWeek(date.Year, weekNumber, LanguageId, ref weekStartDate, ref weekEndDate);

            var select2DataItem = new Select2DataItem() { id = weekNumber.ToString(), text = string.Format("{0:d} - {1:d}", weekStartDate, weekEndDate) };

            return select2DataItem;
        }

        public static DataTable CreatePeriodTable()
        {
            DataTable dt = new();
            dt.Columns.Add(new DataColumn("PeriodNumber", typeof(int)));
            dt.Columns.Add(new DataColumn("StartDay", typeof(System.DateTime)));
            dt.Columns.Add(new DataColumn("FinishDay", typeof(System.DateTime)));
            dt.Columns.Add(new DataColumn("PeriodName", typeof(string)));
            dt.Columns.Add(new DataColumn("PeriodID", typeof(string)));
            dt.PrimaryKey = new DataColumn[] { dt.Columns["PeriodNumber"] };
            return dt;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="year"></param>
        /// <returns></returns>
        public static DataTable FillQuarterList(int year)
        {
            DataTable m_QuarterList;
            //if (m_QuarterList != null)
            //    m_QuarterList.Clear();
            m_QuarterList = CreatePeriodTable();

            System.DateTime d = new(year, 1, 1);

            for (int i = 1; i <= 4; i++)
            {
                if (year == DateTime.Today.Year && d > DateTime.Today)
                {
                    break; // TODO: might not be correct. Was : Exit For
                }

                DataRow q = m_QuarterList.NewRow();
                q["StartDay"] = d;
                q["PeriodNumber"] = i;
                q["PeriodID"] = year.ToString() + "_" + i.ToString();
                d = d.AddMonths(3);
                d = d.AddDays(-1);
                q["FinishDay"] = d;
                d = d.AddDays(1);
                //Bug 3830 - Concatenate "Period Number" to the Quarter display values as specified in VAUC05  - Asim
                q["PeriodName"] = string.Format("{2} - {0:d} - {1:d}", q["StartDay"], q["FinishDay"], i);

                m_QuarterList.Rows.Add(q);
            }

            return m_QuarterList;
        }

        public static void AddMonthRow(DataTable monthTable, int year, int monthNum, string monthName)
        {
            System.DateTime d = new(year, monthNum, 1);
            if (d.Year == DateTime.Today.Year && d > DateTime.Today)
            {
                return;
            }
            DataRow m = monthTable.NewRow();
            m["PeriodName"] = monthName;
            m["StartDay"] = d;
            m["PeriodNumber"] = d.Month;
            m["PeriodID"] = year.ToString() + "_" + d.Month.ToString();
            d = d.AddMonths(1);
            m["FinishDay"] = d.AddDays(-1);
            monthTable.Rows.Add(m);
        }

        private static List<WeekPeriod> GetWeeksList(int year)
        {
            List<WeekPeriod> WeeksList = new();
            var firstDayofYear = new DateTime(year, 1, 1);
            int start = (int)firstDayofYear.DayOfWeek;
            int target = 0;
            if (target <= start && start != 0) target += 7;
            System.DateTime wStartDate = firstDayofYear.AddDays(target - start);            
            System.DateTime lastDayOfYear = wStartDate.AddYears(1).AddDays(-1);
            short weekNum = 1;

            try
            {
                //if year selected is current year, set last date to today
                if (lastDayOfYear > DateTime.Today)
                    lastDayOfYear = DateTime.Today;

                //in the loop, each week starts 7 days after the previous start date
                while (wStartDate < lastDayOfYear)
                {
                    WeekPeriod wPer = new()
                    {
                        Year = short.Parse(year.ToString()),
                        WeekNumber = weekNum,
                        WeekStartDate = wStartDate,
                        WeekEndDate = wStartDate.AddDays(6)
                    };
                    WeeksList.Add(wPer);

                    weekNum += 1;
                    wStartDate = wStartDate.AddDays(7);
                }
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex.Message, null);
                //throw;
            }

            return WeeksList;

        }

        public static DataTable FillWeekList(int year, bool addSequencePrefix = false)
        {
            DataTable m_WeekList = new();
            try
            {
                m_WeekList.Clear();
                m_WeekList = CreatePeriodTable();
                Int16 sequence = 1;
                foreach (WeekPeriod wp in GetWeeksList(year))
                {
                    if ((wp.WeekStartDate.Year == DateTime.Today.Year && wp.WeekStartDate > DateTime.Today))
                    {
                        break; // TODO: might not be correct. Was : Exit For
                    }
                    DataRow weekRow = m_WeekList.NewRow();
                    weekRow["PeriodNumber"] = wp.WeekNumber;
                    weekRow["StartDay"] = wp.WeekStartDate;
                    weekRow["PeriodID"] = year.ToString() + "_" + wp.WeekNumber.ToString();
                    weekRow["FinishDay"] = wp.WeekEndDate;
                    if (addSequencePrefix)
                    {
                        weekRow["PeriodName"] = string.Format("{0} - {1:d} - {2:d}", sequence, wp.WeekStartDate, wp.WeekEndDate);
                    }
                    else
                    {
                        weekRow["PeriodName"] = string.Format("{0:d} - {1:d}", wp.WeekStartDate, wp.WeekEndDate);
                    }
                    m_WeekList.Rows.Add(weekRow);
                    sequence += 1;
                }
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex.Message, null);
                //throw;
            }

            return m_WeekList;

        }

        public static string GetQuarterText(int id, int year)
        {
            string text = string.Empty;
            switch (id)
            {
                case 1:
                    text = String.Format("1 - 1/1/{0} - 3/31/{1}", year.ToString(), year.ToString());
                    break;
                case 2:
                    text = String.Format("2 - 4/1/{0} - 6/30/{1}", year.ToString(), year.ToString());
                    break;
                case 3:
                    text = String.Format("3 - 7/1/{0} - 9/30/{1}", year.ToString(), year.ToString());
                    break;
                case 4:
                    text = String.Format("4 – 10/1/{0} - 12/31/{1}", year.ToString(), year.ToString());
                    break;
            }
            return text;
        }

        public static long GetLocationId(LocationViewModel location)
        {
            long? idfsLocation;

            idfsLocation = location.AdminLevel6Value;
            idfsLocation = idfsLocation ?? location.AdminLevel5Value;
            idfsLocation = idfsLocation ?? location.AdminLevel4Value;
            idfsLocation = idfsLocation ?? location.AdminLevel3Value;
            idfsLocation = idfsLocation ?? location.AdminLevel2Value;
            idfsLocation = idfsLocation ?? location.AdminLevel1Value;
            idfsLocation = idfsLocation ?? location.AdminLevel0Value;

            return long.Parse(idfsLocation.ToString());
        }

        public static long? GetDataForEmptyOrNullLongJsonToken(JToken? token)
        {
            if (token == null ||
              (token.Type == JTokenType.Array && !token.HasValues) ||
              (token.Type == JTokenType.Object && !token.HasValues) ||
              (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
              (token.Type == JTokenType.Null))
            {
                return null;
            }
            else if (long.Parse(token.ToString()) != 0)
            {
                return long.Parse(token.ToString());
            }
            return null;
        }

        public static int? GetDataForEmptyOrNullInt32JsonToken(JToken? token)
        {
            if (token == null ||
                (token.Type == JTokenType.Array && !token.HasValues) ||
                (token.Type == JTokenType.Object && !token.HasValues) ||
                (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
                (token.Type == JTokenType.Null))
            {
                return null;
            }
            else if (int.Parse(token.ToString()) != 0)
            {
                return int.Parse(token.ToString());
            }
            return null;
        }

        public static double? GetDataForEmptyOrNullDoubleJsonToken(JToken? token)
        {
            if (token == null ||
              (token.Type == JTokenType.Array && !token.HasValues) ||
              (token.Type == JTokenType.Object && !token.HasValues) ||
              (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
              (token.Type == JTokenType.Null))
            {
                return null;
            }
            else if (double.Parse(token.ToString()) != 0)
            {
                return double.Parse(token.ToString());
            }
            return null;
        }

        public static long GetDataForlongJsonToken(JToken? token)
        {
            if (token == null ||
              (token.Type == JTokenType.Array && !token.HasValues) ||
              (token.Type == JTokenType.Object && !token.HasValues) ||
              (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
              (token.Type == JTokenType.Null))
            {
                return 0;
            }
            else if (long.Parse(token.ToString()) != 0)
            {
                return long.Parse(token.ToString());
            }
            return 0;
        }

        public static int GetDataForintJsonToken(JToken? token)
        {
            if (token == null ||
              (token.Type == JTokenType.Array && !token.HasValues) ||
              (token.Type == JTokenType.Object && !token.HasValues) ||
              (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
              (token.Type == JTokenType.Null))
            {
                return 0;
            }
            else if (int.Parse(token.ToString()) != 0)
            {
                return int.Parse(token.ToString());
            }
            return 0;
        }
        public static DateTime? GetDataForEmptyOrNullDateTimeJsonToken(JToken? token)
        {
            if (token == null ||
              (token.Type == JTokenType.Array && !token.HasValues) ||
              (token.Type == JTokenType.Object && !token.HasValues) ||
              (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
              (token.Type == JTokenType.Null))
            {
                return null;
            }
            else
            {
                var dateVal = DateTime.Parse(token.ToString(), CultureInfo.CurrentCulture);
                return dateVal;
            }
            return null;
        }

        public static string GetBaseReferenceTranslation(string strLanguage, long idfsBaseReference, ICrossCuttingClient _crossCuttingClient)
        {
            BaseReferenceTranslationRequestModel request = new BaseReferenceTranslationRequestModel();

            request.LanguageID = strLanguage;
            request.idfsBaseReference = idfsBaseReference;

            var result = _crossCuttingClient.GetBaseReferenceTranslation(request).Result;

            return result[0].name;
        }

        private static string GetCurrentLanguage()
        {
            throw new NotImplementedException();
        }
    }

    class WeekPeriod
    {
        public short Year { get; set; }

        public short WeekNumber { get; set; }

        public System.DateTime WeekStartDate { get; set; }

        public System.DateTime WeekEndDate { get; set; }
    }

    public class Period
    {
        public int PeriodNumber { get; set; }
        public DateTime StartDay { get; set; }
        public DateTime FinishDay { get; set; }
        public string PeriodName { get; set; }
        public string PeriodID { get; set; }
    }


}
