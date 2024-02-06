using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Human
{
    public class ILIAggregateViewModel : BaseModel
    {
        public long AggregateHeaderKey { get; set; }
        public long IdfAggregateHeader { get; set; }
        public long IdfAggregateDetail { get; set; }
        public string FormID { get; set; }
        public string LegacyFormID { get; set; }
        public long IdfHospital { get; set; }
        public string HospitalName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        public DateTime DateEntered { get; set; }
        public DateTime DateLastSaved { get; set; }

        public int Year { get; set; }
        public int Week { get; set; }

        public string ILITablesList { get; set; }

        public string OrganizationName { get; set; }
        public string UserName { get; set; }

        public int IntAge0_4 { get; set; }
        public int IntAge5_14 { get; set; }
        public int IntAge15_29 { get; set; }
        public int IntAge30_64 { get; set; }
        public int IntAge65 { get; set; }
        public int IntTotalILI { get; set; }
        public int IntTotalAdmissions { get; set; }
        public int IntILISamples { get; set; }



    }
}
