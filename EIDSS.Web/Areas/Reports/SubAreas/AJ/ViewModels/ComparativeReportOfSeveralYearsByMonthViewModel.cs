using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Localization.Helpers;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class ComparativeReportOfSeveralYearsByMonthViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportFirstYearModels { get; set; }
        public List<ReportYearModel> ReportSecondYearModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
        public List<HumanComparitiveCounterViewModel> CounterList { get; set; }

        [DisplayName("From")]
        [LocalizedRequired]
        [IntegerComparer(nameof(FirstYear), nameof(SecondYear), CompareTypeEnum.LessThan, nameof(MessageResourceKeyConstants.ReportsYearSelectedInToFilterShallBeGreaterThanYearSelectedInFromFilterYearsMessage))]
        public int FirstYear { get; set; }

        [DisplayName("To")]
        [LocalizedRequired]
        [IntegerComparer(nameof(SecondYear), nameof(FirstYear), CompareTypeEnum.GreaterThan, nameof(MessageResourceKeyConstants.ReportsYearSelectedInToFilterShallBeGreaterThanYearSelectedInFromFilterYearsMessage))]
        public int SecondYear { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Counter")]
        [LocalizedRequired]
        public string CounterId { get; set; }

        [DisplayName("Diagnosis")]
        public string DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ComparativeReportOfSeveralYearsByMonthQueryModel:ReportQueryBaseModel
    {
        public string FirstYear { get; set; }
        public string SecondYear { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string CounterId { get; set; }
        public string DiagnosisId { get; set; }
    }
}

