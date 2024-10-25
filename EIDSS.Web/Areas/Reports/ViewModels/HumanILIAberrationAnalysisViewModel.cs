using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.ViewModels
{
    public class HumanILIAberrationAnalysisViewModel  :ReportBaseModel
    {
        public List<BaseReferenceViewModel> AgeGroupList { get; set; }
        public List<BaseReferenceViewModel> OrganizationList { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<Age> ThresholdList { get; set; }
        public List<BaseReferenceViewModel> TimeUnitList { get; set; }
        public List<Age> BaselineList { get; set; }
        public List<Age> LagList { get; set; }

        [DisplayName("Date From")]
        [LocalizedRequired]
        [DateComparer(nameof(StartIssueDate), "StartIssueDate", nameof(EndIssueDate), "EndIssueDate", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.DateFromFieldLabel), nameof(FieldLabelResourceKeyConstants.DateToFieldLabel))]
        public string StartIssueDate { get; set; }

        [DisplayName("Date To")]
        [LocalizedRequired]
        [DateComparer(nameof(EndIssueDate), "EndIssueDate", nameof(StartIssueDate), "StartIssueDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.DateToFieldLabel), nameof(FieldLabelResourceKeyConstants.DateFromFieldLabel))]
        public string EndIssueDate { get; set; }

        [DisplayName("Age Group")]
        [LocalizedRequired]
        public string AgeGroupId { get; set; }

        [DisplayName("Hospital")]
        public string OrganizationId { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Analysis Method")]
        public string AnalysisMethodId { get; set; }

        [DisplayName("Threshold")]
        [LocalizedRequired]
        public string ThresholdId { get; set; }

        [DisplayName("Time unit")]
        [LocalizedRequired]
        public string TimeUnitId { get; set; }

        [DisplayName("Baseline")]
        [LocalizedRequired]
        public string BaselineId { get; set; }

        [DisplayName("Lag")]
        [LocalizedRequired]
        public string LagId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class HumanILIAberrationAnalysisQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string AgeGroupId { get; set; }
        public string OrganizationId { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string AnalysisMethodId { get; set; }
        public string ThresholdId { get; set; }
        public string TimeUnitId { get; set; }
        public string BaselineId { get; set; }
        public string LagId { get; set; }
    }
}

