using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class FlexFormTemplateDeleteRequestModel
    {
        public string LangId { get; set; }
        public long idfsFormTemplate { get; set; }
    }
}
