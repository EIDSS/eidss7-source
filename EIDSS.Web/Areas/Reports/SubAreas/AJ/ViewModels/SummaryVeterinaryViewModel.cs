using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;


namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class SummaryVeterinaryViewModel : ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
        public List<VetNameOfInvestigationOrMeasureViewModel> NameOfInvestigationOrMeasureList { get; set; }
        public List<SpeciesTypeViewModel> SpeciesTypeList { get; set; }
        public List<VetSummarySurveillanceTypeViewModel>  VetSummarySurveillanceTypes { get; set; }

        [DisplayName("Diagnosis")]
        [LocalizedRequired]
        public string DiagnosisId { get; set; }

        [DisplayName("Start Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]
        [DateComparer(nameof(StartIssueDate), "StartIssueDate", nameof(EndIssueDate), "EndIssueDate", CompareTypeEnum.LessThanOrEqualTo, nameof(StartIssueDate), nameof(EndIssueDate))]
        public string StartIssueDate { get; set; }

        [DisplayName("End Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]
        [DateComparer(nameof(EndIssueDate), "EndIssueDate", nameof(StartIssueDate), "StartIssueDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(EndIssueDate), nameof(StartIssueDate))]
        public string EndIssueDate { get; set; }

        [DisplayName("Name Of Investigation/Measure")]
        [LocalizedRequired]
        public string NameOfInvestigationOrMeasureId { get; set; }

        [DisplayName("Species Type")]
        [LocalizedRequired]
        [LocalizedStringArrayMax(3, nameof(MessageResourceKeyConstants.ReportsYouCanSpecifyNotMoreThanThreeSpeciesInSpeciesTypeFilterMessage))]
        public string[] SpeciesTypeId { get; set; }

        [DisplayName("Surveillance Type")]
        [LocalizedRequired]
        public string SurveillanceTypeId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class SummaryVeterinaryQueryModel:ReportQueryBaseModel
    {
        public string DiagnosisId { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string NameOfInvestigationOrMeasureId { get; set; }
        public string[] SpeciesTypeId { get; set; }
        public string SurveillanceTypeId { get; set; }
    }
}

