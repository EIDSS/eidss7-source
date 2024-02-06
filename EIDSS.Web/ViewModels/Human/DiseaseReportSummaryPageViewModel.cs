using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportSummaryPageViewModel
    {
        public string ReportID { get; set; }
        public string LegacyID { get; set; }

        public long? DiseaseID { get; set; }
        public string Disease { get; set; }

        public string PersonID { get; set; }

        public long ReportStatusID { get; set; }

        public string ReportStatus { get; set; }

        public long idfsSite { get; set; }

        [LocalizedRequired]
        public Select2Configruation ReportStatusDD { get; set; }
        [LocalizedRequired]
        public Select2Configruation ReportTypeDD { get; set; }
        public bool IsReportTypeDisabled { get; set; } = false;

        public long ReportTypeID { get; set; }

        public string ReportType { get; set; }

        public string SessionID { get; set; }
        public long? IdfSessionID { get; set; }

        public string RelatedToReportIds { get; set; }

        public string relatedParentHumanDiseaseReportIdList { get; set; }
        public string relatedChildHumanDiseaseReportIdList { get; set; }

        public string PersonName { get; set; }

        public string DateEntered { get; set; }

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

        public long? RelateToHumanDiseaseReportID { get; set; }
        public string RelatedToHumanDiseaseEIDSSReportID { get; set; }
        public long? ConnectedDiseaseReportID { get; set; }
        public string ConnectedDiseaseEIDSSReportID { get; set; }

        //Default Select2 Text
        public string DefaultReportStatus { get; set; }
        public string DefaultReportType { get; set; }
    }
}
