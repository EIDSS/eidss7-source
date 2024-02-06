using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class UniqueNumberingSchemaSaveRequestModel
    {
        public long IdfsNumberName { get; set; }
        public string StrDefault { get; set; }
        public string StrName { get; set; }
        public string StrPrefix { get; set; }
        public string StrSuffix { get; set; }
        public string StrSpecialCharacter { get; set; }
        public int IntNumberValue { get; set; }
        public string LangId { get; set; }
        public int? intNextNumberValue { get; set; }


    }
}
