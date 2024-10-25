using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class VeterinaryYearlySituationViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class VeterinaryYearlySituationQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
    }
}

