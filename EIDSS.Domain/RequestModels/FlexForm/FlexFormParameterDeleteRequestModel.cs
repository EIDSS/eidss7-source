using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class FlexFormParameterDeleteRequestModel
    {
        public string LangId { get; set; }
        public long idfsParameter { get; set; }
        public string User { get; set; }
    }
}
