using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SiteGetRequestModel : BaseGetRequestModel
    {
        public long? SiteID { get; set; }
        [StringLength(36)]
        public string EIDSSSiteID { get; set; }
        public long? SiteTypeID { get; set; }
        [StringLength(200)]
        public string SiteName { get; set; }
        [StringLength(50)]
        public string HASCSiteID { get; set; }
        public long? OrganizationID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public long? SiteGroupID { get; set; }
    }
}