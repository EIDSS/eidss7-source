using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormDeterminantSaveRequestModel
    {
        public long? idfsDiagnosisGroup { get; set; }
        public long? idfsFormTemplate { get; set; }
        public string User { get; set; } = "";
        public int? intRowStatus { get; set; } = 0;
        public int? FunctionCall { get; set; } = 0;
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
