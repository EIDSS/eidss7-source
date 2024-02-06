using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class ObjectAccessGetListViewModel : BaseModel
    {
        public ObjectAccessGetListViewModel ShallowCopy()
        {
            return (ObjectAccessGetListViewModel)MemberwiseClone();
        }

        public long ObjectAccessID { get; set; }
        public long? ObjectTypeID { get; set; }
        public string ObjectTypeName { get; set; }
        public long? ObjectOperationTypeID { get; set; }
        public string ObjectOperationTypeName { get; set; }
        public long? ObjectID { get; set; }
        public long ActorID { get; set; }
        public bool DefaultEmployeeGroupIndicator { get; set; }
        public long? SiteID { get; set; }
        public int PermissionTypeID { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool PermissionIndicator { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }
}