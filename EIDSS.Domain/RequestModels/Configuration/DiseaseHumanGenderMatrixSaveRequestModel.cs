using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class DiseaseHumanGenderMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long DiagnosisGroupToGenderUID { get; set; }
        public long DiagnosisGroupID { get; set; }
        public long? GenderID { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long? UserId { get; set; }
        public long LocationId { get; set; }
    }
}
