using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class TestingGetRequestModel : BaseGetRequestModel
    {
        public long? SampleID { get; set; }
        public long? TestID { get; set; }
        public long? BatchTestID { get; set; }
        public string TestList { get; set; }
        public bool? AccessionedIndicator { get; set; }
        public int? DaysFromAccessionDate { get; set; }
        public long? TestStatusTypeID { get; set; }
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