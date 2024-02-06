using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SiteGroupGetListViewModel : BaseModel
    {
        public long? SiteGroupID { get; set; }
        public string SiteGroupTypeName { get; set; }
        public string SiteGroupName { get; set; }
        public string AdministrativeLevelName { get; set; }
        public string SiteGroupDescription { get; set; }
        public int? RowCount { get; set; }
    }
}
