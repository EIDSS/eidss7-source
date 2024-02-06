using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class Journal60BViewModel  :ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }

        [DisplayName("Start Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]

        //[DateComparer(nameof(StartIssueDate), "StartIssueDate", nameof(EndIssueDate), "EndIssueDate", CompareType.LessThanOrEqualTo)]
        public string StartIssueDate { get; set; }


        [DisplayName("End Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]

        //[DateComparer(nameof(EndIssueDate), "EndIssueDate", nameof(StartIssueDate), "StartIssueDate", CompareType.GreaterThanOrEqualTo)]
        public string EndIssueDate { get; set; }
        public string MinimumStartIssueDate { get; set; }
        public string MaximumStartIssueDate { get; set; }
        public string MinimumEndIssueDate { get; set; }
        public string MaximumEndIssueDate { get; set; }

        [DisplayName("Diagnosis")]
        public string DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class Journal60BQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string DiagnosisId { get; set; }
    }
}

