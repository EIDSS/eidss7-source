using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class VeterinaryDataQualityIndicatorsViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportFromYearModels { get; set; }
        public List<ReportYearModel> ReportToYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<BaseReferenceViewModel> OrganizationList { get; set; }

        [DisplayName("From Year")]
        [LocalizedRequired]
        [IntegerComparer(nameof(FromYear), nameof(ToYear), CompareTypeEnum.LessThanOrEqualTo, nameof(MessageResourceKeyConstants.FromToDatesCompareMessage))]
        public int FromYear { get; set; }

        [DisplayName("To Year")]
        [LocalizedRequired]
        [IntegerComparer(nameof(ToYear), nameof(FromYear), CompareTypeEnum.GreaterThanOrEqualTo, nameof(MessageResourceKeyConstants.FromToDatesCompareMessage))]
        public int ToYear { get; set; }

        [DisplayName("From Month")]
        public long FromMonth{ get; set; }

        [DisplayName("To Month")]
        public long ToMonth { get; set; }

        public long? RayonId { get; set; }

        [DisplayName("Entered by Organization")]
        public long? EnterByOrganizationId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class VeterinaryDataQualityIndicatorsQueryModel:ReportQueryBaseModel
    {
        public string FromYear { get; set; }
        public string ToYear { get; set; }
        public string FirstYear { get; set; }
        public string SecondYear { get; set; }
        public string FromMonth { get; set; }
        public string ToMonth { get; set; }
        public string EnterByOrganizationId { get; set; }
    }
}

