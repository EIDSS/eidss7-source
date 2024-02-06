using EIDSS.Domain.Abstracts;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SiteActorGetListViewModel : BaseModel
    {
        public SiteActorGetListViewModel ShallowCopy()
        {
            return (SiteActorGetListViewModel)MemberwiseClone();
        }

        public long ActorID { get; set; }
        public long ActorTypeID { get; set; }
        public string ActorTypeName { get; set; }
        public string ActorName { get; set; }
        public long SiteID { get; set; }
        public bool ExternalActorIndicator { get; set; }
        public bool DefaultEmployeeGroupIndicator { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
        public int? RecordCount { get; set; }

        public List<EmployeesForUserGroupViewModel> Employees { get; set; }
        public List<ObjectAccessGetListViewModel> Permissions { get; set; }
    }
}