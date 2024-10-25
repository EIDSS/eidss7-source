using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SiteGroupGetRequestModel : BaseGetRequestModel
    {
        [StringLength(40)]
        public string SiteGroupName { get; set; }
        public long? SiteGroupTypeID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public long? CentralSiteID { get; set; }
        public long? SiteID { get; set; }
        [StringLength(36)]
        public string EIDSSSiteID { get; set; }
    }
}
