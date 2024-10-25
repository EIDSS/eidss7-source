using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class RBEQuarterlySurveillanceSheetViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportQuarterModelGG> QuarterList { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("Quarter")]
        [LocalizedRequired]
        public string[] QuarterId { get; set; }

        [DisplayName("Region")]
        public string[] RegionId { get; set; }

        [DisplayName("Rayon")]
        public string[] RayonId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class RBEQuarterlySurveillanceSheetQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string[] QuarterId { get; set; }
        public string[] RegionId { get; set; }
        public string[] RayonId { get; set; }
    }
}

