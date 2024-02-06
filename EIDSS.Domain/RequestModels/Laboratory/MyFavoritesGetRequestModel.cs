using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class MyFavoritesGetRequestModel : BaseGetRequestModel
    {
        public bool? AccessionedIndicator { get; set; }
        [StringLength(2000)]
        public string SearchString { get; set; }
        public long? SampleID { get; set; }
        public long UserID { get; set; }
        public long UserEmployeeID { get; set; }
        public long UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserSiteGroupID { get; set; }
    }
}