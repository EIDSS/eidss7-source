using EIDSS.Web.Enumerations;

namespace EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication
{
    public class VeterinaryDiseaseReportDeduplicationDetailsViewModel
    {
        public long LeftVeterinaryDiseaseReportID { get; set; }
        public long RightVeterinaryDiseaseReportID { get; set; }
        public VeterinaryReportTypeEnum ReportType { get; set; }
    }
}
