using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class OutbreakSessionNoteDeleteRequestModel
    {
        public long idfOutbreakNote { get; set; }
        public bool? deleteFileObjectOnly { get; set; }
        public string User { get; set; }
    }
}
