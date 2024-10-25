using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Domain.ViewModels.Reports;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class HumanCasesByRayonAndDiseaseSummaryViewModel  :ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }

        [DisplayName("Start Issue Date")]
        [LocalizedRequired]
        [DateComparer(nameof(StartIssueDate), "StartIssueDate", nameof(EndIssueDate), "EndIssueDate", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.StartIssueDateFieldLabel), nameof(FieldLabelResourceKeyConstants.EndIssueDateFieldLabel))]
        public string StartIssueDate { get; set; }

        [DisplayName("End Issue Date")]
        [LocalizedRequired]
        [DateComparer(nameof(EndIssueDate), "EndIssueDate", nameof(StartIssueDate), "StartIssueDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.EndIssueDateFieldLabel), nameof(FieldLabelResourceKeyConstants.StartIssueDateFieldLabel))]
        public string EndIssueDate { get; set; }

        [DisplayName("Diagnosis")]
        [LocalizedRequired]
        [LocalizedStringArrayMax(5, nameof(MessageResourceKeyConstants.ReportsTooManyDiseasesMessage ))]
        public string[] DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class HumanCasesByRayonAndDiseaseSummaryQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string[] DiagnosisId { get; set; }
    }
}

