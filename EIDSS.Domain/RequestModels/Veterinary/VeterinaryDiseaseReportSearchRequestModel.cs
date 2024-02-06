using EIDSS.Domain.Abstracts;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class VeterinaryDiseaseReportSearchRequestModel : BaseGetRequestModel
    {
        public long? ReportKey { get; set; }
        public string ReportID { get; set; }
        public string LegacyReportID { get; set; }
        public long? SessionKey { get; set; }
        public long? FarmMasterID { get; set; }
        public long? DiseaseID { get; set; }
        public long? ReportStatusTypeID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public DateTime? DateEnteredFrom { get; set; }
        public DateTime? DateEnteredTo { get; set; }
        public long? ClassificationTypeID { get; set; }
        public string PersonID { get; set; }
        public long? ReportTypeID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public bool? OutbreakCasesIndicator { get; set; }
        public DateTime? DiagnosisDateFrom { get; set; }
        public DateTime? DiagnosisDateTo { get; set; }
        public DateTime? InvestigationDateFrom { get; set; }
        public DateTime? InvestigationDateTo { get; set; }
        public string LocalOrFieldSampleID { get; set; }
        public int? TotalAnimalQuantityFrom { get; set; }
        public int? TotalAnimalQuantityTo { get; set; }
        public string SessionID { get; set; }
        public long? DataEntrySiteID { get; set; }
        public bool? RecordIdentifierSearchIndicator { get; set; }

        [Required]
        public long? UserSiteID { get; set; }
        [Required]
        public long? UserOrganizationID { get; set; }
        [Required]
        public long? UserEmployeeID { get; set; }
        public bool? ApplySiteFiltrationIndicator { get; set; } = false;
        public bool? IncludeSpeciesListIndicator { get; set; } = false;
        public int OutbreakCaseReportOnly { get; set; } = 0;

    }

    public class VeterinaryDiseaseReportDetailRequestModel : BaseGetRequestModel
    {
        public long ReportKey { get; set; }
    }

}
