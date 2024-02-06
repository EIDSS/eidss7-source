using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class ConcordanceBetweenInitialFinalDiagnosisViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportMonthNameModel> ReportMonthNameModels { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<GisLocationChildLevelModel> GisSettlementList { get; set; }
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
        public List<Age> ConcordanceList { get; set; }

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }
                
        [DisplayName("Month")]
        public long Month{ get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Settlement")]
        public long? SettlementId { get; set; }

        [DisplayName("Concordance")]
        public string ConcordanceId { get; set; }

        [DisplayName("InitialDiagnosis")]
        public string[] InitialDiagnosisId { get; set; }

        [DisplayName("FinalDiagnosis")]
        public string[] FinalDiagnosisId { get; set; }
        public string JavascriptToRun { get; set; }
    }

    public class ConcordanceBetweenInitialFinalDiagnosisQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string Month { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string SettlementId { get; set; }
        public string ConcordanceId { get; set; }
        public string[] InitialDiagnosisId { get; set; } = null;
        public string[] FinalDiagnosisId { get; set; } = null;

    }
}

