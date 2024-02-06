using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class PersonDedupeRequestModel
    {
        public long SurvivorHumanMasterID { get; set; }
        public long SupersededHumanMasterID { get; set; }
    }
}
