using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ILIAggregateFormSearchRequestModel : BaseGetRequestModel
    {       
        public string FormID { get; set; }
        public string LegacyFormID { get; set; }
        public long? AggregateHeaderID { get; set; }        
        public long? HospitalID { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? FinishDate { get; set; }        
        public long UserSiteID { get; set; }        
        public long? UserOrganizationID { get; set; }        
        public long? UserEmployeeID { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; }                
    }
}
