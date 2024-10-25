using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormRequiredParameterSaveRequestModel
    {
        public long? idfsParameter { get; set; }
        public long? idfsEditMode { get; set; }
        public long? idfsFormTemplate { get; set; }
        public string User { get; set; }
    }
}
