using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class AdministrativeUnitsSearchRequestModel: BaseGetRequestModel
    {
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public long? idfsAdminLevel { get; set; }
        public string AdminstrativeLevelValue { get; set; }
        public long? idfsCountry { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public long? idfsSettlementType { get; set; }
        public double? LatitudeFrom { get; set; }
        public double? LatitudeTo { get; set; }
        public double? LongitudeFrom { get; set; }
        public double? LongitudeTo { get; set; }
        public double? ElevationFrom { get; set; }
        public double? ElevationTo { get; set; }
        public string StrHASC { get; set; }
        public string StrCode { get; set; }


    }
}
