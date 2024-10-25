using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm
{
    public class WeeklyReportingFormDetailsViewModel
    {
        public bool IsReadonly { get; set; }
        public long? FormID { get; set; }
        public bool DeleteVisibleIndicator { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public long? WeeklyReportFormId { get; set; }
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public WeeklyReportingFormDetailsSectionViewModel  WeeklyReportingFormDetailsSectionViewModel { get; set; }

    }
}
