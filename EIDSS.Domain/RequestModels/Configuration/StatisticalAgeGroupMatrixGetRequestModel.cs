using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class StatisticalAgeGroupMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsDiagnosisAgeGroup { get; set; }
    }

    public class StatisticalAgeGroupMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfDiagnosisAgeGroupToStatisticalAgeGroup { get; set; }
        public long? idfsDiagnosisAgeGroup { get; set; }
        public long? idfsStatisticalAgeGroup { get; set; }
        public bool DeleteAnyway { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }
}
