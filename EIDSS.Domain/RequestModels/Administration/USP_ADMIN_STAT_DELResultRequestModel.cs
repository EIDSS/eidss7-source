using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public  class USP_ADMIN_STAT_DELResultRequestModel
    {
        public long? idfStatistic { get; set; }
        public long UserId { get; set; }
        public long SiteId { get; set; }
    }
}
