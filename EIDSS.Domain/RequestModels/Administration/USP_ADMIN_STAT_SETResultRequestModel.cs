using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class USP_ADMIN_STAT_SETResultRequestModel
    {
        public long? idfStatistic { get; set; }
        public long? idfsStatisticDataType { get; set; }
        public long? idfsMainBaseReference { get; set; }
        public long? idfsStatisticAreaType { get; set; }
        public long? idfsStatisticPeriodType { get; set; }
        public long? LocationUserControlidfsCountry { get; set; }
        public long? LocationUserControlidfsRegion { get; set; }
        public long? LocationUserControlidfsRayon { get; set; }
        public long? LocationUserControlidfsSettlement { get; set; }
        public DateTime? datStatisticStartDate { get; set; }
        public DateTime? datStatisticFinishDate { get; set; }
        public int? varValue { get; set; }
        public long? idfsStatisticalAgeGroup { get; set; }
        public long? idfsParameterName { get; set; }
        public bool bulkImport { get; set; }
        public long UserId { get; set; }
        public long SiteId { get; set; }
    }
}
