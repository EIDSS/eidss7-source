using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Helpers
{
    public static class ReportHelper
    {

        public static List<ReportYearModel> GetFilteredYearList(List<ReportYearModel> reportYearList, int[] filterYears,  string orderBy="asc")
        {
            if (reportYearList != null)
            {
                reportYearList = reportYearList.Where(x => filterYears.Any(y => y.Equals(x.Year.Value))).ToList();
                if (reportYearList !=null  && reportYearList.Count >0)
                {
                    if (orderBy.ToUpper() == "ASC")
                    {
                        reportYearList = reportYearList.OrderBy(y => y.Year).ToList();
                    }
                    else
                    {
                        reportYearList = reportYearList.OrderByDescending(y => y.Year).ToList();
                    }
                }
            }

            return reportYearList;
        }

        public static List<ReportMonthNameModel> GetFilteredMonthsList(List<ReportMonthNameModel> reportMonthsList, int[] filterMonths, string orderBy = "asc")
        {
            if (reportMonthsList != null)
            {
                reportMonthsList = reportMonthsList.Where(x => filterMonths.Any(y => y.Equals(x.intOrder.Value))).ToList();
                if (reportMonthsList != null && reportMonthsList.Count > 0)
                {
                    if (orderBy.ToUpper() == "ASC")
                    {
                        reportMonthsList = reportMonthsList.OrderBy(y => y.intOrder).ToList();
                    }
                    else
                    {
                        reportMonthsList = reportMonthsList.OrderByDescending(y => y.intOrder).ToList();
                    }
                }
            }

            return reportMonthsList;
        }

    }
}
