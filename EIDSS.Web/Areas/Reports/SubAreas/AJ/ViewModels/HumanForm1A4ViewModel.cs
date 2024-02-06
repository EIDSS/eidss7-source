using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class HumanForm1A4ViewModel : ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<BaseReferenceViewModel> OrganizationList { get; set; }

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("From Month")]
        public long idfsReference_FromMonth { get; set; }

        [DisplayName("To Month")]
        public long idfsReference_ToMonth { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Entered by Organization")]
        public long? EnterByOrganizationId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class HumanForm1A4QueryModel : ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string FirstYear { get; set; }
        public string SecondYear { get; set; }
        public string IdfsReference_FromMonth { get; set; }
        public string IdfsReference_ToMonth { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string EnterByOrganizationId { get; set; }
    }
}

