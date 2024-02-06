using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class SettlementViewModel : BaseModel
    {
        public long? idfsSettlement { get; set; }
        public string strSettlementName { get; set; }
        public string strSettlementExtendedName { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsCountry { get; set; }
        public long? idfsGISReferenceType { get; set; }
        public long? SettlementType { get; set; }
        public int? intRowStatus { get; set; }
        public int? intElevation { get; set; }
    }
}
