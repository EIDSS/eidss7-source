using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;
using System;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.ViewModels
{
    public class HumanAberrationAnalysisViewModel  :ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
        public List<BaseReferenceViewModel> ReportTypeList { get; set; }
        public List<HumDateFieldSourceViewModel> DateFieldSourceList { get; set; }
        public List<BaseReferenceViewModel> CaseClassificationList { get; set; }
        public List<BaseReferenceViewModel> OrganizationList { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<GisLocationChildLevelModel> GisSettlementList { get; set; }
        public List<BaseReferenceViewModel> GenderList { get; set; }
        public List<Age> AgeFromList { get; set; }
        public List<Age> AgeToList { get; set; }
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

        [DisplayName("Diagnosis")]
        [LocalizedRequired]
        public string[] DiagnosisId { get; set; }

        [DisplayName("Report Type")]
        [LocalizedRequired]
        public string ReportTypeId { get; set; }

        [DisplayName("Date Field Source")]
        [LocalizedRequired]
        public string[] DateFieldSourceId { get; set; }

        [DisplayName("Case Classification")]
        [LocalizedRequired]
        public string[] CaseClassificationId { get; set; }

        [DisplayName("Notification Received from Facility")]
        public string OrganizationId { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Settlement")]
        public long? SettlementId { get; set; }

        [DisplayName("Gender")]
        public string GenderId { get; set; }

        [DisplayName("Age from (years)")]
        public string AgeFromId { get; set; }

        [DisplayName("Age to (years)")]
        public string AgeToId { get; set; }

        [DisplayName("Analysis Method")]
        [LocalizedRequired]
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

        public List<AnalysisMethod> AnalysisMethods { get; set; } 

    }
   
    public class AnalysisMethod
    {
        public string Id { get; set; }
        public string Value { get; set; }

    }

    public class HumanAberrationAnalysisQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string[] DiagnosisId { get; set; } = null;
        public string ReportTypeId { get; set; }
        public string[] DateFieldSourceId { get; set; }
        public string[] CaseClassificationId { get; set; }
        public string OrganizationId { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string SettlementId { get; set; }
        public string GenderId { get; set; }
        public string AgeFromId { get; set; }
        public string AgeToId { get; set; }
        public string AnalysisMethodId { get; set; }
        public string ThresholdId { get; set; }
        public string TimeUnitId { get; set; }
        public string BaselineId { get; set; }
        public string LagId { get; set; }
    }
}

