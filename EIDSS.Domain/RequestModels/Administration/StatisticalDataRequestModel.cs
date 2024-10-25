using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class StatisticalDataRequestModel
    {
        public string LangID { get; set; }
           
        public long? idfsStatisticalDataType { get; set; }
        public long? idfsArea { get; set; }
        public DateTime? datStatisticStartDateFrom { get; set; }
        public DateTime? datStatisticStartDateTo { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public int? pageSize { get; set; }
        public int? pageNo { get; set; }
        public string sortColumn { get; set; }
        public string sortOrder { get; set; }
    }
}
