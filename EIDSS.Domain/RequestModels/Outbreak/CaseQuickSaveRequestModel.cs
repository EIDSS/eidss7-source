using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class CaseQuickSaveRequestModel
    {
        public string CaseIdentifiers { get; set; }
        public long? StatusTypeId { get; set; }
        public long? ClassificationTypeId { get; set; }
        public string CaseMonitorings { get; set; }
        public string Events { get; set; }
    }
}
