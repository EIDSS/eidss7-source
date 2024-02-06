using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ReportDiseaseGroupDiseaseMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? IdfDiagnosisToGroupForReportType { get; set; }
        public long IdfsCustomReportType { get; set; }
        public long IdfsReportDiagnosisGroup { get; set; }
        public long IdfsDiagnosis { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
