using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class BorderRayonsIncidenceComparativeViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
        public List<HumanComparitiveCounterViewModel> CounterList { get; set; }

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("From Month")]
        public long idfsReference_FromMonth{ get; set; }

        [DisplayName("To Month")]
        public long idfsReference_ToMonth { get; set; }

        [DisplayName("Region")]
        [LocalizedRequired]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        [LocalizedRequired]
        public long? RayonId { get; set; }

        [DisplayName("Counter")]
        [LocalizedRequired]
        public string CounterId { get; set; }

        [DisplayName("Diagnosis")]
        public string[] DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class BorderRayonsIncidenceComparativeQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string IdfsReference_FromMonth { get; set; }
        public string IdfsReference_ToMonth { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string CounterId { get; set; }
        public string[] DiagnosisId { get; set; }
    }
}

