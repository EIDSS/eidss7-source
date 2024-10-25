using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class WhoReportOnMeaslesAndRubellaViewModel : ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportMonthNameModels { get; set; }
        public List<WhoMeaslesRubellaDiagnosisViewModel> GetHumanWhoMeaslesRubellaDiagnosis { get; set; }
          

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("Month")]
        public long Month { get; set; }

        [DisplayName("Disease")]
        public long? DiseaseId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class WhoReportOnMeaslesAndRubellaQueryModel : ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string Month { get; set; }
        public string DiseaseId { get; set; }
    }
}

