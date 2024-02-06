using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;


namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class ZoonoticComparativeReportViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
       
        [DisplayName("Year")]
        [LocalizedRequired]
        public long Year { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Diagnosis")]
        public string DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ZoonoticComparativeReportQueryModel:ReportQueryBaseModel
    {
        public string DiagnosisId { get; set; }
        public string Year { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
    }
}

