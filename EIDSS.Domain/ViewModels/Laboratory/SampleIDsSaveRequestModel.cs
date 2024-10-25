using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SampleIDsSaveRequestModel
    {
        public string Samples { get; set; }
    }
}
