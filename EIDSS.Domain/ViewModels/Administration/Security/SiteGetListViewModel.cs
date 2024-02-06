using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class SiteGetListViewModel : BaseModel
    {
        public long SiteID { get; set; }
        public long? SiteToSiteGroupID { get; set; }
        public string SiteTypeName { get; set; }
        public string OrganizationName { get; set; }
        public string SiteName { get; set; }
        public string HASCSiteID { get; set; }
        public string EIDSSSiteID { get; set; }
        public string CountryName { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string AdministrativeLevel3Name { get; set; }
        public string SettlementName { get; set; }
        public string RowAction { get; set; }
        public int RowSelectionIndicator { get; set; }
        public int? RowCount { get; set; }
    }
}
