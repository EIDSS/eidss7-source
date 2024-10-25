using EIDSS.Localization.Helpers;
using System;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportSummaryPageViewModel
    {
        public string ReportID { get; set; }
        public string LegacyID { get; set; }

        public long? DiseaseID { get; set; }
        public string Disease { get; set; }

        public string PersonID { get; set; }

        [LocalizedRequired]
        public long? ReportStatusID { get; set; }

        public string ReportStatus { get; set; }

        public long idfsSite { get; set; }

        public bool IsReportTypeDisabled { get; set; } = false;

        [LocalizedRequired]
        public long? ReportTypeID { get; set; }

        public string ReportType { get; set; }

        public string SessionID { get; set; }
        public long? IdfSessionID { get; set; }

        public string RelatedToReportIds { get; set; }

        public string PersonName { get; set; }

        public DateTime? DateEntered { get; set; }

        public string DateLastUpdated { get; set; }

        public string EnteredBy { get; set; }
        public long? idfPersonEnteredBy { get; set; }

        public string EnteredByOrganization { get; set; }

        public string CaseClassification { get; set; }

        public long? idfHumanCase { get; set; }

        public long? HumanActualID { get; set; }

        public long? HumanID { get; set; }

        public bool? blnInitialSSD { get; set; }
        public bool? blnFinalSSD { get; set; }
        public bool? blnCanReopenClosedCase { get; set; }

        public bool IsReportClosed { get; set; }

        //Default Select2 Text
        public string DefaultReportStatus { get; set; }
        public string DefaultReportType { get; set; }

        public string DateEnteredFormatted
        {
            get
            {
                return DateEntered.HasValue ? DateEntered.Value.ToShortDateString() : string.Empty;
            }
        }
    }
}
