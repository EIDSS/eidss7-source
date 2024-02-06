using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Outbreak;
using System;
using System.Collections.Generic;
using EIDSS.Web.ViewModels;
using System.Globalization;
using EIDSS.Domain.Enumerations;
using EIDSS.Web.ViewModels.Outbreak;

namespace EIDSS.Web.Areas.Outbreak.ViewModels
{
    public class OutbreakCasesViewModel
    {
        public OutbreakCasesViewModel()
        {
            OutbreakReportPrintViewModel = new OutbreakReportPrintViewModel();
        }
        public OutbreakReportPrintViewModel OutbreakReportPrintViewModel { get; set; }

        public long idfOutbreak { get; set; }
        public string CancelURL { get; set; }
        public OutbreakTypeEnum OutbreakType { get; set; }
        public DateTime UpdateDate { get; set; }
        public string CurrentLanguage { get; set; }
        public string ReportName { get; set; } = "EpiCurve"; //TODO EpiCurve Localization
        public CultureInfo Culture { get; set; }
        public List<KeyValuePair<string, string>> EpiCurveParameters { get; set; }
        public List<OutbreakHeatMapResponseModel> HeatMapData { get; set; }
        public OutbreakSessionDetailsResponseModel SessionDetails { get; set; }
        public IList<CaseGetListViewModel> Cases { get; set; }
        public AuthenticatedUser User { get; set; }
        public OutbreakSessionNoteDetailsViewModel Update { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool ReadAccessToOutbreakHumanContactsDataPermissionIndicator { get; set; }
        public bool ReadAccessToOutbreakVeterinaryContactsDataPermissionIndicator { get; set; }
        public bool ReadAccessToVectorSurveillanceSessionDataPermissionIndicator { get; set; }

        public string CasesTabClass { get; set; } = "nav-link active";
        public string ContactsTabClass { get; set; } = "nav-link";
        public string AnalysisTabClass { get; set; } = "nav-link";
        public string UpdatesTabClass { get; set; } = "nav-link";
        public string VectorTabClass { get; set; } = "nav-link";

        public string CasesPaneClass { get; set; } = "tab-pane active";
        public string ContactsPaneClass { get; set; } = "tab-pane";
        public string AnalysisPaneClass { get; set; } = "tab-pane";
        public string UpdatesPaneClass { get; set; } = "tab-pane";
        public string VectorPaneClass { get; set; } = "tab-pane";

        public string ReturnMessage { get; set; }
    }
}
