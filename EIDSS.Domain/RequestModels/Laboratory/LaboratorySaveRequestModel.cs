using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class LaboratorySaveRequestModel
    {
        public string Samples { get; set; }
        public string Batches { get; set; }
        public string Tests { get; set; }
        public string TestAmendments { get; set; }
        public string Transfers { get; set; }
        public string FreezerBoxLocationAvailabilities { get; set; }
        public string Events { get; set; }
        public long UserID { get; set; }
        public string Favorites { get; set; }
        public string AuditUserName { get; set; }
    }
}