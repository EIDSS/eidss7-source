using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using EIDSS.Localization.Helpers;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class ExternalComparativeViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportFirstYearModels { get; set; }
        public List<ReportYearModel> ReportSecondYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }

        [DisplayName("Year 1")]
        [LocalizedRequired]
        [IntegerComparer(nameof(FirstYear), nameof(SecondYear), CompareTypeEnum.GreaterThan, nameof(MessageResourceKeyConstants.ReportsYear1ShallBeGreaterThanYear2Message))]
        public int FirstYear { get; set; }

        [DisplayName("Year 2")]
        [LocalizedRequired]
        [IntegerComparer(nameof(SecondYear), nameof(FirstYear), CompareTypeEnum.LessThan, nameof(MessageResourceKeyConstants.ReportsYear1ShallBeGreaterThanYear2Message))]
        public int SecondYear { get; set; }

        [Required]
        [DisplayName("From Month")]
        public long idfsReference_FromMonth{ get; set; }

        [Required]
        [DisplayName("To Month")]
        public long idfsReference_ToMonth { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ExternalComparativeQueryModel:ReportQueryBaseModel
    {
        public string FirstYear { get; set; }
        public string SecondYear { get; set; }
        public string idfsReference_FromMonth { get; set; }
        public string idfsReference_ToMonth { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
    }
}

