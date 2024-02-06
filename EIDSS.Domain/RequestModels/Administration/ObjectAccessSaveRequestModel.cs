using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ObjectAccessSaveRequestModel : BaseSaveRequestModel
    {
        public long ObjectAccessID { get; set; }
        public long ObjectOperationTypeID { get; set; }
        public long ObjectTypeID { get; set; }
        public long ObjectID { get; set; }
        public long ActorID { get; set; }
        public bool DefaultEmployeeGroupIndicator { get; set; }
        public long SiteID { get; set; }
        public int PermissionTypeID { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
        public string ObjectAccessRecords { get; set; }
    }
}