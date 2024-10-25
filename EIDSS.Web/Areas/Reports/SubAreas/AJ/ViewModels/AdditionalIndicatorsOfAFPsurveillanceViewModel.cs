using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class AdditionalIndicatorsOfAFPsurveillanceViewModel : ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }

        public List<ReportingPeriodTypeViewModel> ReportingPeriodTypeList { get; set; }

        public List<ReportingPeriodViewModel> ReportingPeriodList { get; set; }


        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("Reporting Period Type")]
        public string ReportingPeriodTypeId { get; set; }

        [DisplayName("Reporting Period")]
        public string ReportingPeriodId { get; set; }

        [HiddenInput]
        public bool ShowReportingPeriodId { get; set; } = false;

        public string JavascriptToRun { get; set; }
    }

    public class AdditionalIndicatorsOfAFPsurveillanceQueryModel : ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string ReportingPeriodTypeId { get; set; }
        public string ReportingPeriodId { get; set; }

    }
}

