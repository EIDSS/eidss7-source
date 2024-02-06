using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Reports.ViewModels
{
    public class WeeklySummaryReportViewModel : ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }

        [DisplayName("Start Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]
        public string StartIssueDate { get; set; }


        [DisplayName("End Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]
        public string EndIssueDate { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class WeeklySummaryReportQueryModel : ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
    }
}
