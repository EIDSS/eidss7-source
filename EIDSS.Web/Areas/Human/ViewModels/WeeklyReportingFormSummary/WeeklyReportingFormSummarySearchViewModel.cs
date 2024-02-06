using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Helpers;
using EIDSS.ReportViewer;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingSummary
{
    public class WeeklyReportingFormSummarySearchViewModel
    {
        // this controls the search
        public WeeklyReportingFormSummarySearchViewModel()
        {
            WeeklyReportFormSummaryPermissions = new();
        }

        //public ReportViewerModel WeeeklyReportViewerModel { get; set; }

        public List<KeyValuePair<string, string>> ReportParameters { get; set; }

        public List<WeeklyReportingFormSummarySearchViewModel> SearchResults { get; set; }

        public string ReportPath { get; set; }
        public string Path { get; set; }
        public string ArchivedPath { get; set; }
        public string ReportFileName { get; set; } = "Weekly Reporting Form Summary";

        // not needed right now. just use idfsLocation        
        public long? idfsLocation { get; set; }
            
        public string InformationalMessage { get; set; }
        
        public bool RecordSelectionIndicator { get; set; }
        
        public UserPermissions WeeklyReportFormSummaryPermissions { get; set; }

        public LocationViewModel SearchLocationViewModel { get; set; }

        // add Month and Year properties 
        // then add drop down to bind to the drop downs
        // bind those these properties
        // mkae sure in my component that these are populated with month and year
        [LocalizedRequired]
        public int? Year { get; set; }

        [LocalizedRequired]
        public string Month { get; set; }

        [LocalizedRequired]
        public int CurrentYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));

        [LocalizedRequired]
        public string CurrentMonth { get; set; } = DateTime.Now.ToString("MMMM");
    }
}
