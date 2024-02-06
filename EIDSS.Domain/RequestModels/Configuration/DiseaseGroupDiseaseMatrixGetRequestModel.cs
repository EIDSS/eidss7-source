using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class DiseaseGroupDiseaseMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsDiagnosisGroup { get; set; }
    }

    public class DiseaseGroupDiseaseMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfDiagnosisToDiagnosisGroup { get; set; }
        public long? idfsDiagnosisGroup { get; set; }
        public long? idfsDiagnosis { get; set; }
        public bool DeleteAnyway { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
