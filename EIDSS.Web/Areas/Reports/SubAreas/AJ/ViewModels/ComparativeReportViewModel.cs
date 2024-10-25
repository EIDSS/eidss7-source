using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class ComparativeReportViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportFirstYearModels { get; set; }
        public List<ReportYearModel> ReportSecondYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegion1List { get; set; }
        public List<GisLocationChildLevelModel> GisRayon1List { get; set; }
        public List<GisLocationChildLevelModel> GisRegion2List { get; set; }
        public List<GisLocationChildLevelModel> GisRayon2List { get; set; }
        public List<BaseReferenceViewModel> OrganizationList { get; set; }
        public List<HumanComparitiveCounterViewModel> HumanComparitiveCounterList { get; set; }

        
        [DisplayName("Year 1")]
        [LocalizedRequired]
        [IntegerComparer(nameof(FirstYear), nameof(SecondYear), CompareTypeEnum.GreaterThan, nameof(MessageResourceKeyConstants.ReportsYear1ShallBeGreaterThanYear2Message))]
        public int FirstYear { get; set; }

        [DisplayName("Year 2")]
        [LocalizedRequired]
        [IntegerComparer(nameof(SecondYear), nameof(FirstYear), CompareTypeEnum.LessThan, nameof(MessageResourceKeyConstants.ReportsYear1ShallBeGreaterThanYear2Message))]
        public int SecondYear { get; set; }

        [DisplayName("From Month")]
        public long idfsReference_FromMonth{ get; set; }

        [DisplayName("To Month")]
        public long idfsReference_ToMonth { get; set; }

        [DisplayName("Region 1")]
        public long? Region1Id { get; set; }

        [DisplayName("Rayon 1")]
        public long? Rayon1Id { get; set; }

        [DisplayName("Counter")]
        [LocalizedRequired]
        public int CounterId { get; set; }

        [DisplayName("Entered by Organization")]
        public long? EnterByOrganizationId { get; set; }

        [DisplayName("Region 2")]
        public long? Region2Id { get; set; }

        [DisplayName("Rayon 2")]
        public long? Rayon2Id { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ComparativeReportQueryModel:ReportQueryBaseModel
    {
        public string FirstYear { get; set; }
        public string SecondYear { get; set; }
        public string idfsReference_FromMonth { get; set; }
        public string idfsReference_ToMonth { get; set; }
        public string Region1Id { get; set; }
        public string Rayon1Id { get; set; }
        public string CounterId { get; set; }
        public string EnterByOrganizationId { get; set; }
        public string Region2Id { get; set; }
        public string Rayon2Id { get; set; }
    }
}

