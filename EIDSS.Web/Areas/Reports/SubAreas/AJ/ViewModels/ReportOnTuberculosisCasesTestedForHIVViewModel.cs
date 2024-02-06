using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;
//using Microsoft.VisualStudio.Web.CodeGeneration.Contracts.Messaging;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class ReportOnTuberculosisCasesTestedForHIVViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportFromMonthNameModels { get; set; }
        public List<ReportMonthNameModel> ReportToMonthNameModels { get; set; }
        public List<TuberculosisDiagnosisViewModel> DiagnosisList { get; set; }
       
        [DisplayName("Year")]
        [LocalizedRequired]
        [LocalizedStringArrayMax(5, nameof(MessageResourceKeyConstants.ReportsOnlyFiveSelectedYearsWillBeRepresentedInTheReportMessage))]
        public string[] Year { get; set; }

        [DisplayName("From Month")]
        public long idfsReference_FromMonth{ get; set; }

        [DisplayName("To Month")]
        public long idfsReference_ToMonth { get; set; }

        [DisplayName("Diagnosis")]
        public string DiagnosisId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ReportOnTuberculosisCasesTestedForHIVQueryModel:ReportQueryBaseModel
    {
        public string DiagnosisId { get; set; }
        public string[] Year { get; set; }
        public string IdfsReference_FromMonth { get; set; }
        public string IdfsReference_ToMonth { get; set; }
    }
}

