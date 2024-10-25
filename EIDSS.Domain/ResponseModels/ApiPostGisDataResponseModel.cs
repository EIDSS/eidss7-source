using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels
{
    public class ApiPostGisDataResponseModel:APIPostResponseModel
    {

        public long? IdfsLocation { get; set; }
        public int? SettlementCount { get; set; }
        public int? RayonCount { get; set; }
        public int? RegionCount { get; set; }
        public int? GeoLocationRefCount { get; set; }
        public int? GeoLocationSharedRefCount { get; set; }

    }

}
