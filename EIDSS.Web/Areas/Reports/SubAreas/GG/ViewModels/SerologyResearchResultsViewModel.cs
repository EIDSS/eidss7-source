using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class SerologyResearchResultsViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }

        [DisplayName("Sample ID")]
        [LocalizedRequired]
        public string SampleID { get; set; }

        [DisplayName("First Name")]
        public string FirstName { get; set; }

        [DisplayName("Last Name")]
        public string LastName { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class SerologyResearchResultsQueryModel:ReportQueryBaseModel
    {
        public string SampleID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
    }
}

