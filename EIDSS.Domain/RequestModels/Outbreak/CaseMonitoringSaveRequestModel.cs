using EIDSS.Domain.Attributes;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class CaseMonitoringSaveRequestModel
    {
        public long CaseMonitoringID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? ObservationID { get; set; }
        public long? InvestigatedByOrganizationID { get; set; }
        public long? InvestigatedByPersonID { get; set; }
        public string AdditionalComments { get; set; }
        public DateTime? MonitoringDate { get; set; }
        [Required]
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}
