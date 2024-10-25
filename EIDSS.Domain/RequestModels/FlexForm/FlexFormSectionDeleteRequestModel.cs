using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormSectionDeleteRequestModel
    {
        public long idfsSection { get; set; }
    }
}
