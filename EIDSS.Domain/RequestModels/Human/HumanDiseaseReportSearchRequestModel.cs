using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanDiseaseReportSearchRequestModel : BaseGetRequestModel
    {
        public long? ReportKey { get; set; }
        public string ReportID { get; set; }
        public string LegacyReportID { get; set; }
        public long? SessionKey { get; set; }
        public long? PatientID { get; set; }
        public string PersonID { get; set; }
        public long? DiseaseID { get; set; }
        public long? ReportStatusTypeID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public DateTime? DateEnteredFrom { get; set; }
        public DateTime? DateEnteredTo { get; set; }
        public long? ClassificationTypeID { get; set; }
        public long? HospitalizationYNID { get; set; }
        public string PatientFirstName { get; set; }
        public string PatientMiddleName { get; set; }
        public string PatientLastName { get; set; }
        public long? SentByFacilityID { get; set; }
        public long? ReceivedByFacilityID { get; set; }
        public DateTime? DiagnosisDateFrom { get; set; }
        public DateTime? DiagnosisDateTo { get; set; }
        public string LocalOrFieldSampleID { get; set; }
        public long? DataEntrySiteID { get; set; }
        public DateTime? DateOfSymptomsOnsetFrom { get; set; }
        public DateTime? DateOfSymptomsOnsetTo { get; set; }
        public DateTime? NotificationDateFrom { get; set; }
        public DateTime? NotificationDateTo { get; set; }
        public DateTime? DateOfFinalCaseClassificationFrom { get; set; }
        public DateTime? DateOfFinalCaseClassificationTo { get; set; }
        public long? LocationOfExposureAdministrativeLevelID { get; set; }
        public long? OutcomeID { get; set; }
        public int? FilterOutbreakTiedReports { get; set; }
        public bool? OutbreakCasesIndicator { get; set; }
        public bool? RecordIdentifierSearchIndicator { get; set; }
        [Required]
        public long? UserSiteID { get; set; }
        [Required]
        public long? UserOrganizationID { get; set; }
        [Required]
        public long? UserEmployeeID { get; set; }
        public bool? ApplySiteFiltrationIndicator { get; set; }

    }

    public class HumanDiseaseReportDetailRequestModel : BaseGetRequestModel
    { 
        public long SearchHumanCaseId { get; set; }
    }

}
