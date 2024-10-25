using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class OrganizationGetListViewModel : BaseModel
    {
        public OrganizationGetListViewModel ShallowCopy()
        {
            return (OrganizationGetListViewModel)MemberwiseClone();
        }

        public long OrganizationKey { get; set; }
        public string OrganizationID { get; set; }
        public string AbbreviatedName { get; set; }
        public string FullName { get; set; }
        public int? Order { get; set; }
        public string AddressString { get; set; }
        public string OrganizationTypeName { get; set; }
        public int AccessoryCode { get; set; }
        public long? SiteID { get; set; }
        public int RowStatus { get; set; }
        public int? RowCount { get; set; }
        public int? RowAction { get; set; }
    }
}
