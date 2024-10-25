using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class DiseaseAgeGroupSaveRequestModel : BaseSaveRequestModel
    {
        public long? IdfDiagnosisAgeGroupToDiagnosis { get; set; }
        public long? IdfsDiagnosis { get; set; }
        public long? IdfsDiagnosisAgeGroup { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
