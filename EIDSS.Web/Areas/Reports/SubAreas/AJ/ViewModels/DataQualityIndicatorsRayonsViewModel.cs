using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class DataQualityIndicatorsRayonsViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
       
        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("From Month")]
        public long idfsReference_FromMonth{ get; set; }

        [DisplayName("To Month")]
        public long idfsReference_ToMonth { get; set; }

        [DisplayName("Diagnosis")]
        public string[] DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class DataQualityIndicatorsRayonsQueryModel:ReportQueryBaseModel
    {
        public string[] DiagnosisId { get; set; }
        public string Year { get; set; }
        public string IdfsReference_FromMonth { get; set; }
        public string IdfsReference_ToMonth { get; set; }
    }
}

