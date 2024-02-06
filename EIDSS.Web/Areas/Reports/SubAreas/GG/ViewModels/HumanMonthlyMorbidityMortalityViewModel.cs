using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class HumanMonthlyMorbidityMortalityViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportMonthNameModels { get; set; }

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("Month")]
        public long Month{ get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class HumanMonthlyMorbidityMortalityQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string Month { get; set; }
    }
}

