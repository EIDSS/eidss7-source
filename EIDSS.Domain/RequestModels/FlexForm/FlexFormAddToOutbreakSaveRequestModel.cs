using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormAddToOutbreakSaveRequestModel
    {
        public long? idfsFormTemplate { get; set; }
        public long? idfOutbreakSpeciesParameterUID { get; set; }
        public string strFormCategory { get; set; }
    }
}
