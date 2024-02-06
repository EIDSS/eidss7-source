using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class SamplesGetRequestModel : BaseGetRequestModel
    {
        public long? SampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public int? DaysFromAccessionDate { get; set; }
        public string SampleList { get; set; }
        public bool? AccessionedIndicator { get; set; }
        public bool? TestUnassignedIndicator { get; set; }
        public bool? TestCompletedIndicator { get; set; }
        [StringLength(2000)]
        public string SearchString { get; set; }
        public bool FiltrationIndicator { get; set; }
        public long UserID { get; set; }
        public long UserEmployeeID { get; set; }
        public long UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserSiteGroupID { get; set; }
    }
}