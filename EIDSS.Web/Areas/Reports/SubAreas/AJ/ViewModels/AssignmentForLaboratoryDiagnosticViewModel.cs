using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class AssignmentForLaboratoryDiagnosticViewModel : ReportBaseModel
    {

        public List<LABAssignmentDiagnosticAZSendToViewModel> LABAssignmentDiagnosticAZSendToList { get; set; }
          

        [DisplayName("Case ID")]
        [LocalizedRequired]
        public string CaseId { get; set; }

        [DisplayName("Sent to")]
        [LocalizedRequired]
        public string SentTo { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class AssignmentForLaboratoryDiagnosticQueryModel : ReportQueryBaseModel
    {
        public string CaseId { get; set; }
        public string SentTo { get; set; }
    }
}

